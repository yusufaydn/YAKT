=begin 
The MIT License (MIT)
Copyright (c) 2013 ali kargin,tansel ersavas,hande kuskonmaz,yusuf aydin,kevin bongart

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE
=end
class CardsController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /cards
  # GET /cards.json
  def index
    @cards = Card.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @cards }
    end
  end

  # GET /cards/1
  # GET /cards/1.json
  def show
    @card = Card.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @card }
    end
  end

  # GET /cards/new
  # GET /cards/new.json
  def new
    @card = Card.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @card }
    end
  end

  # GET /cards/1/edit
  def edit
    @card = Card.find(params[:id])
  end

  # POST /cards
  # POST /cards.json
  def create
    
    @card = Card.new(params[:card])
    current_board = Board.find(params[:board_id])
    @card.state = current_board.states.find_by_name("Backlog")
    #TODO make better
    @card.requested_by = current_user.id
    if @card.save
       render 'new_card' and return if !!request.xhr?
       redirect_to current_board
    end
  end

  # PUT /cards/1
  # PUT /cards/1.json
  def update
    @card = Card.find(params[:id])
    params[:card][:updated_by] = current_user
    respond_to do |format|
      if @card.update_attributes(params[:card])
        
        @card.versions.last.user = current_user
        @card.versions.last.save
        format.html { redirect_to @card, :notice => 'Card was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @card.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cards/1
  # DELETE /cards/1.json
  def destroy
    @card = Card.find(params[:id])
    @card.destroy

    respond_to do |format|
      format.html { redirect_to cards_url }
      format.json { head :ok }
    end
  end

  def sort
    unless params[:cards].blank?
      card_ids = params[:cards].map {|i| i.scan(/\d+/).first}
      state_id  = params[:state].scan(/\d+/).first
         
      Card.find(card_ids).each_with_index do |card, i|
        card.update_attributes(:position => i, :state_id => state_id,:updated_by => current_user)
      end
    end

    render :nothing => true
  end
  
  def  add_task_to_card
    task_name = params[:name]
    card_id = params[:card_id]
    card = Card.find_by_id(card_id)
    if task_name.present?
      card.tasks << Task.new(:name=>task_name)
    end
    if request.xhr?
      json = {}
      json["name"] = task_name
      render :json => json, :status => :ok
    end
  end
  def open_new_card_modal
    @card = Card.new
    render :partial => 'shared/modal',:locals => {:page_url =>'cards/form'}
  end
  
  
  
  
end
