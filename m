Date: Wed, 7 Mar 2007 03:34:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 8/6] mm: fix cpdfio vs fault race
Message-Id: <20070307033400.83922b12.akpm@linux-foundation.org>
In-Reply-To: <20070307032038.f08333a8.akpm@linux-foundation.org>
References: <20070307110429.GF5555@wotan.suse.de>
	<20070307032038.f08333a8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>, miklos@szeredi.hu, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Mar 2007 03:20:38 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> > ===================================================================
> > --- linux-2.6.orig/mm/memory.c
> > +++ linux-2.6/mm/memory.c
> > @@ -1676,6 +1676,17 @@ gotten:
> >  unlock:
> >  	pte_unmap_unlock(page_table, ptl);
> >  	if (dirty_page) {
> > +		/*
> > +		 * Yes, Virginia, this is actually required to prevent a race
> > +		 * with clear_page_dirty_for_io() from clearing the page dirty
> > +		 * bit after it clear all dirty ptes, but before a racing
> > +		 * do_wp_page installs a dirty pte.
> > +		 *
> > +		 * do_fault is protected similarly by holding the page lock
> > +		 * after the dirty pte is installed.
> > +		 */
> > +		lock_page(dirty_page);
> > +		unlock_page(dirty_page);
> >  		set_page_dirty_balance(dirty_page);
> >  		put_page(dirty_page);
> 
> Yes, I think that'll plug it.  A wait_on_page_locked() should suffice.

Or will it?  Suppose after the unlock_page() a _second_
clear_page_dirty_for_io() gets run - the same thing happens?

Extending the lock_page() coverage around the set_page_dirty() would
prevent that.

I guess not needed - the second clear_page_dirty_for_io() will have cleaned the
pte.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
