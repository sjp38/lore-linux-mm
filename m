Message-ID: <48F00737.1080707@redhat.com>
Date: Fri, 10 Oct 2008 21:53:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
References: <200810081655.06698.nickpiggin@yahoo.com.au>	<20081008185401.D958.KOSAKI.MOTOHIRO@jp.fujitsu.com>	<20081010151701.e9e50bdb.akpm@linux-foundation.org>	<20081010152540.79ed64cb.akpm@linux-foundation.org>	<20081010153346.e25b90f7.akpm@linux-foundation.org>	<48EFEC68.6000705@redhat.com> <20081010184217.f689f493.akpm@linux-foundation.org>
In-Reply-To: <20081010184217.f689f493.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> I implemented this as a fix against
> vmscan-fix-pagecache-reclaim-referenced-bit-check.patch, but that patch
> says 

> which isn't true any more.

> Sorry about this mess.

I'm not sure what else is still in the -mm tree and what got
removed, so I'm not sure what the new comment for the patch
should be.

Maybe the patch could just be folded into an earlier split
LRU patch now since there no longer is a special case for
page cache pages?

Btw, a few more cleanups to shrink_active_list are possible
now that every page always goes to the inactive list.

> static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> 			struct scan_control *sc, int priority, int file)
> {
> 	unsigned long pgmoved;
> 	int pgdeactivate = 0;
> 	unsigned long pgscanned;
> 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
> 	LIST_HEAD(l_active);

We no longer need l_active.

> 	/*
> 	 * Count the referenced pages as rotated, even when they are moved
> 	 * to the inactive list.  This helps balance scan pressure between
> 	 * file and anonymous pages in get_scan_ratio.
>  	 */
> 	zone->recent_rotated[!!file] += pgmoved;

This can be rewritten as

	/*
	 * Count referenced pages from currently used mappings as
	 * rotated, even though they are moved to the inactive list.
	 * This helps balance scan pressure between file and anonymous
	 * pages in get_scan_ratio.
	 */

> 	/*
> 	 * Now put the pages back on the appropriate [file or anon] inactive
> 	 * and active lists.
> 	 */

	/*
	 * Move the pages to the [file or anon] inactive list.
	 */

We keep the code that moves pages from l_inactive to the inactive
list.

We can throw away the loop that moves pages from l_active to the
active list, because we no longer do that:

> 	pgmoved = 0;
> 	lru = LRU_ACTIVE + file * LRU_FILE;
> 	while (!list_empty(&l_active)) {
> 		page = lru_to_page(&l_active);
> 		prefetchw_prev_lru_page(page, &l_active, flags);
> 		VM_BUG_ON(PageLRU(page));
> 		SetPageLRU(page);
> 		VM_BUG_ON(!PageActive(page));
> 
> 		list_move(&page->lru, &zone->lru[lru].list);
> 		mem_cgroup_move_lists(page, lru);
> 		pgmoved++;
> 		if (!pagevec_add(&pvec, page)) {
> 			__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> 			pgmoved = 0;
> 			spin_unlock_irq(&zone->lru_lock);
> 			if (vm_swap_full())
> 				pagevec_swap_free(&pvec);
> 			__pagevec_release(&pvec);
> 			spin_lock_irq(&zone->lru_lock);
> 		}
> 	}
> 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);

These last few lines are useful and should be kept:

> 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
> 	__count_vm_events(PGDEACTIVATE, pgdeactivate);
> 	spin_unlock_irq(&zone->lru_lock);
> 	if (vm_swap_full())
> 		pagevec_swap_free(&pvec);
> 
> 	pagevec_release(&pvec);
> }


-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
