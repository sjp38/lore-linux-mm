From: jordi polo <wigsm@LatinMail.com>
Date: Wed, 16 Aug 2000 20:26:15 -0400
Subject: some silly things
Message-Id: <200008162026446.SM00157@latinmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 - it seems to me that you don't do nr_inactive_clear_pages   when you get a new inactive_clear page
 
 - I don't know why you have to test if a page is dirty in reclaim_page(), there isn't the place, it is supposed that when the page is written, in other place must be allocated in inactive_dirty. Here we can expect inactive_clean pages are really inactive clean pages.
 
 - what do you think of 4 lists, active_clean active_dirty inactive_clean inactive_dirty. When a write operation occurs in a page this will go to active_dirty, from active_dirty to inactive_dirty , from active_clean to inactive_clean directly without need to test if it's dirty or not.
 In fact is the same but with 4 list you can make a state machine and you can track exactly a page trought the states, but your 3 list approach seems all right for me too.
 
> - And the improvement I was trying to explain you the other day, something this way:
> 
> if ((PageActiveClear(page)) && (page->age < MINIM )){
> deactivate_page(page); //this page will go to inactive_clear
> }
> else if ((PageActiveDirty(page)) && (!page->age )){
> deactivate_page(page); // this will go to inactive_dirty 
> }
 
> Here MINIM will be something like 1 (or 2) (maybe need to change
PAGE_AGE_START and PAGE_AGE_ADV), this will do that the clear pages have it
easier to go to inactive_clear and then easier to become free pages and I think
this is a good thing because it's harder to get a free page from inactive_dirty
than from inactive_clear. > I know in your code first begin to free the
inactive_clear and when you are running off it you use inactive_dirty, that's
allright, but if you do it my way there will be more pages in inactive_clear
that will make that you need to free less pages from inactive_dirty  

- age_page_down() : page->age /=2;   > you make a silly improvement with  
page->age >>=2; 
- you can do in the zone structure a field named available_pages=
free_pages inactive_free so you mustn't calculate it everytime.   


 Just hoping these things will be useful to you.
 Jordi Polo (trusmis)
 mumismo@wanadoo.es






_________________________________________________________
http://www.latinmail.com.  Gratuito, latino y en espanol.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
