Date: Tue, 26 Oct 2004 23:01:10 +0900 (JST)
Message-Id: <20041026.230110.21315175.taka@valinux.co.jp>
Subject: Re: migration cache, updated
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041026092535.GE24462@logos.cnet>
References: <20041025213923.GD23133@logos.cnet>
	<20041026.181504.38310112.taka@valinux.co.jp>
	<20041026092535.GE24462@logos.cnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Hi, Marcelo,

> > > diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c linux-2.6.9-rc2-mm4.build/mm/vmscan.c
> > > --- linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c	2004-10-05 15:08:23.000000000 -0300
> > > +++ linux-2.6.9-rc2-mm4.build/mm/vmscan.c	2004-10-25 19:15:56.000000000 -0200
> > > @@ -459,7 +457,9 @@ int shrink_list(struct list_head *page_l
> > >  		}
> > >  
> > >  #ifdef CONFIG_SWAP
> > > -		if (PageSwapCache(page)) {
> > > +		// FIXME: allow relocation of migrate cache pages 
> > > +		// into real swap pages for swapout.
> > 
> > 
> > In my thought, it would be better to remove a target page from the
> > LRU lists prior to migration. So that it makes the swap code not to
> > grab the page, which is in the migration cache.
> 
> I dont see a problem with having the pages on LRU - the reclaiming 
> code sees it, but its unfreeable, so it doesnt touch it. 
> 
> The reclaiming path should see its a migration page, unmap the pte's
> to it, remap them to swapcache pages (and ptes), so they can be
> swapped out on pressure.
> 
> Can you please expand your thoughts?

I thought the easiest way to avoid the race condition was
removing the page from LRU during memory migration.
But there may be no problem about the page, which is unfreeable
as you mentioned.

BTW, I wonder how the migration code avoid to choose some pages
on LRU, which may have count == 0. This may happen the pages
are going to be removed. We have to care about it.


> > > +		if (PageSwapCache(page) && !PageMigration(page)) {
> > >  			swp_entry_t swap = { .val = page->private };
> > >  			__delete_from_swap_cache(page);
> > >  			write_unlock_irq(&mapping->tree_lock);
> > > 

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
