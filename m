Date: Wed, 16 Aug 2000 21:18:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: some silly things
In-Reply-To: <00081702242301.00670@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0008162111130.11513-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root <mumismo@wanadoo.es>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 17 Aug 2000, root wrote:

>  - it seems to me that you don't do nr_inactive_clear_pages++
> when you get a new inactive_clear page

That's because there is no global counter for the number
of inactive_clean pages. We only count these per zone.

>  - I don't know why you have to test if a page is dirty in
> reclaim_page(), there isn't the place, it is supposed that when
> the page is written, in other place must be allocated in
> inactive_dirty. Here we can expect inactive_clean pages are
> really inactive clean pages.

Unless somebody does something with the page _after_ it is
added to the inactive_clean list. Granted, __find_page_nolock
should have moved the page to the active list by then, but
that is only valid in the _current_ VM and I would like to
have the code resistant against some future VM modifications
too.

Defensive programming is important if you want to avoid (or
detect) bugs. Both bugs in your own code and in other code.

>  - what do you think of 4 lists, active_clean active_dirty
> inactive_clean inactive_dirty. When a write operation occurs in
> a page this will go to active_dirty, from active_dirty to
> inactive_dirty , from active_clean to inactive_clean directly
> without need to test if it's dirty or not.

Doesn't make any sense. Checking for dirty state will have to
be done somewhere, so why not do it just before we actually
plan on writing the page to disk?

>  In fact is the same but with 4 list you can make a state
> machine and you can track exactly a page trought the states,

Wooohoooo, fun!  ;)

> > if ((PageActiveClear(page)) && (page->age < MINIM )){
> > deactivate_page(page); //this page will go to inactive_clear
> > }
> > else if ((PageActiveDirty(page)) && (!page->age )){
> > deactivate_page(page); // this will go to inactive_dirty 
> > }

NOOOOOOO!  The whole idea is to have -page aging- and
-page flushing- SEPARATE, so that we always make the
right decision in flushing pages.

Whether a page is dirty or clean should not make any
difference in how "important" we think it is to keep
the page in memory.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
