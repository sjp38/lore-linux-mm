Date: Tue, 26 Oct 2004 07:25:35 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: migration cache, updated
Message-ID: <20041026092535.GE24462@logos.cnet>
References: <20041025213923.GD23133@logos.cnet> <20041026.181504.38310112.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041026.181504.38310112.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-mm@kvack.org, iwamoto@valinux.co.jp, haveblue@us.ibm.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 26, 2004 at 06:15:04PM +0900, Hirokazu Takahashi wrote:
> Hi, Marcelo,
> 
> > Hi,
> > 
> > This is an improved version of the migration cache patch - 
> > thanks to everyone who contributed - Hirokazu, Iwamoto, Dave,
> > Hugh.
> 
> Some comments.
> 
> > diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/memory.c linux-2.6.9-rc2-mm4.build/mm/memory.c
> > --- linux-2.6.9-rc2-mm4.mhp.orig/mm/memory.c	2004-10-05 15:08:23.000000000 -0300
> > +++ linux-2.6.9-rc2-mm4.build/mm/memory.c	2004-10-25 19:35:18.000000000 -0200
> > @@ -1408,6 +1412,9 @@ static int do_swap_page(struct mm_struct
> >  	pte_unmap(page_table);
> >  	spin_unlock(&mm->page_table_lock);
> >  again:
> > +	if (pte_is_migration(orig_pte)) {
> > +		page = lookup_migration_cache(entry.val);
> > +	} else {
> >  	page = lookup_swap_cache(entry);
> >  	if (!page) {
> >   		swapin_readahead(entry, address, vma);
> > @@ -1433,15 +1440,22 @@ again:
> >  		inc_page_state(pgmajfault);
> >  		grab_swap_token();
> >  	}
> > -
> >  	mark_page_accessed(page);
> >  	lock_page(page);
> >  	if (!PageSwapCache(page)) {
> > +		/* hiro: add !PageMigration(page) here */
> >  		/* page-migration has occured */
> 
> Now, !PageSwapCache(page) means the page isn't neither in the swap-cache
> nor in the migration-cache. The original code is enough.

OK!

> >  		unlock_page(page);
> >  		page_cache_release(page);
> >  		goto again;
> >  	}
> > +	}
> > +
> > +
> > +	if (pte_is_migration(orig_pte)) {
> > +		mark_page_accessed(page);
> > +		lock_page(page);
> > +	}
> >  
> >  	/*
> >  	 * Back out if somebody else faulted in this pte while we
> 
> > diff -Nur --show-c-function linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c linux-2.6.9-rc2-mm4.build/mm/vmscan.c
> > --- linux-2.6.9-rc2-mm4.mhp.orig/mm/vmscan.c	2004-10-05 15:08:23.000000000 -0300
> > +++ linux-2.6.9-rc2-mm4.build/mm/vmscan.c	2004-10-25 19:15:56.000000000 -0200
> > @@ -38,8 +38,6 @@
> >  #include <asm/tlbflush.h>
> >  #include <asm/div64.h>
> >  
> > -#include <linux/swapops.h>
> > -
> >  /*
> >   * The list of shrinker callbacks used by to apply pressure to
> >   * ageable caches.
> > @@ -459,7 +457,9 @@ int shrink_list(struct list_head *page_l
> >  		}
> >  
> >  #ifdef CONFIG_SWAP
> > -		if (PageSwapCache(page)) {
> > +		// FIXME: allow relocation of migrate cache pages 
> > +		// into real swap pages for swapout.
> 
> 
> In my thought, it would be better to remove a target page from the
> LRU lists prior to migration. So that it makes the swap code not to
> grab the page, which is in the migration cache.

I dont see a problem with having the pages on LRU - the reclaiming 
code sees it, but its unfreeable, so it doesnt touch it. 

The reclaiming path should see its a migration page, unmap the pte's
to it, remap them to swapcache pages (and ptes), so they can be
swapped out on pressure.

Can you please expand your thoughts?

> > +		if (PageSwapCache(page) && !PageMigration(page)) {
> >  			swp_entry_t swap = { .val = page->private };
> >  			__delete_from_swap_cache(page);
> >  			write_unlock_irq(&mapping->tree_lock);
> > 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
