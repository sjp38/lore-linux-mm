Date: Fri, 10 Oct 2008 18:42:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re:
 vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
Message-Id: <20081010184217.f689f493.akpm@linux-foundation.org>
In-Reply-To: <48EFEC68.6000705@redhat.com>
References: <200810081655.06698.nickpiggin@yahoo.com.au>
	<20081008185401.D958.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081010151701.e9e50bdb.akpm@linux-foundation.org>
	<20081010152540.79ed64cb.akpm@linux-foundation.org>
	<20081010153346.e25b90f7.akpm@linux-foundation.org>
	<48EFEC68.6000705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 10 Oct 2008 19:59:36 -0400 Rik van Riel <riel@redhat.com> wrote:

> Andrew Morton wrote:
> 
> > OK, that wasn't a particularly good time to drop those patches.
> > 
> > Here's how shrink_active_list() ended up:
> 
> You're close.
> 
> > 	while (!list_empty(&l_hold)) {
> > 		cond_resched();
> > 		page = lru_to_page(&l_hold);
> > 		list_del(&page->lru);
> > 
> > 		if (unlikely(!page_evictable(page, NULL))) {
> > 			putback_lru_page(page);
> > 			continue;
> > 		}
> 
> These three lines are needed here:
> 
> 		/* page_referenced clears PageReferenced */
> 		if (page_mapping_inuse(page) && page_referenced(page))
> 			pgmoved++;
> 
> > 		list_add(&page->lru, &l_inactive);
> 
> That allows us to drop these lines:
> 
> > 		if (!page_mapping_inuse(page)) {
> > 			/*
> > 			 * Bypass use-once, make the next access count. See
> > 			 * mark_page_accessed and shrink_page_list.
> > 			 */
> > 			SetPageReferenced(page);
> > 		}
> 
> Other than that, it looks good.
> 
> > 	}
> > 
> > 	/*
> > 	 * Count the referenced pages as rotated, even when they are moved
> > 	 * to the inactive list.  This helps balance scan pressure between
> > 	 * file and anonymous pages in get_scan_ratio.
> >  	 */
> > 	zone->recent_rotated[!!file] += pgmoved;
> 
> This now automatically does the right thing.

hm, OK.

I implemented this as a fix against
vmscan-fix-pagecache-reclaim-referenced-bit-check.patch, but that patch
says 

  The -mm tree contains the patch
  vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
  which gives referenced pagecache pages another trip around the active
  list.  This seems to help keep frequently accessed pagecache pages in
  memory.

  However, it means that pagecache pages that get moved to the
  inactive list do not have their referenced bit set, and the next
  access to the page will not get it moved back to the active list. 
  This patch sets the referenced bit on pagecache pages that get
  deactivated, so the next access to the page will promote it back to
  the active list.

  This works because shrink_page_list() will reclaim unmapped pages
  with the referenced bit set.

which isn't true any more.

Sorry about this mess.


static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
			struct scan_control *sc, int priority, int file)
{
	unsigned long pgmoved;
	int pgdeactivate = 0;
	unsigned long pgscanned;
	LIST_HEAD(l_hold);	/* The pages which were snipped off */
	LIST_HEAD(l_active);
	LIST_HEAD(l_inactive);
	struct page *page;
	struct pagevec pvec;
	enum lru_list lru;

	lru_add_drain();
	spin_lock_irq(&zone->lru_lock);
	pgmoved = sc->isolate_pages(nr_pages, &l_hold, &pgscanned, sc->order,
					ISOLATE_ACTIVE, zone,
					sc->mem_cgroup, 1, file);
	/*
	 * zone->pages_scanned is used for detect zone's oom
	 * mem_cgroup remembers nr_scan by itself.
	 */
	if (scan_global_lru(sc)) {
		zone->pages_scanned += pgscanned;
		zone->recent_scanned[!!file] += pgmoved;
	}

	if (file)
		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
	else
		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
	spin_unlock_irq(&zone->lru_lock);

	pgmoved = 0;
	while (!list_empty(&l_hold)) {
		cond_resched();
		page = lru_to_page(&l_hold);
		list_del(&page->lru);

		if (unlikely(!page_evictable(page, NULL))) {
			putback_lru_page(page);
			continue;
		}

		/* page_referenced clears PageReferenced */
		if (page_mapping_inuse(page) && page_referenced(page))
			pgmoved++;

		list_add(&page->lru, &l_inactive);
	}

	/*
	 * Count the referenced pages as rotated, even when they are moved
	 * to the inactive list.  This helps balance scan pressure between
	 * file and anonymous pages in get_scan_ratio.
 	 */
	zone->recent_rotated[!!file] += pgmoved;

	/*
	 * Now put the pages back on the appropriate [file or anon] inactive
	 * and active lists.
	 */
	pagevec_init(&pvec, 1);
	pgmoved = 0;
	lru = LRU_BASE + file * LRU_FILE;
	spin_lock_irq(&zone->lru_lock);
	while (!list_empty(&l_inactive)) {
		page = lru_to_page(&l_inactive);
		prefetchw_prev_lru_page(page, &l_inactive, flags);
		VM_BUG_ON(PageLRU(page));
		SetPageLRU(page);
		VM_BUG_ON(!PageActive(page));
		ClearPageActive(page);

		list_move(&page->lru, &zone->lru[lru].list);
		mem_cgroup_move_lists(page, lru);
		pgmoved++;
		if (!pagevec_add(&pvec, page)) {
			__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
			spin_unlock_irq(&zone->lru_lock);
			pgdeactivate += pgmoved;
			pgmoved = 0;
			if (buffer_heads_over_limit)
				pagevec_strip(&pvec);
			__pagevec_release(&pvec);
			spin_lock_irq(&zone->lru_lock);
		}
	}
	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
	pgdeactivate += pgmoved;
	if (buffer_heads_over_limit) {
		spin_unlock_irq(&zone->lru_lock);
		pagevec_strip(&pvec);
		spin_lock_irq(&zone->lru_lock);
	}

	pgmoved = 0;
	lru = LRU_ACTIVE + file * LRU_FILE;
	while (!list_empty(&l_active)) {
		page = lru_to_page(&l_active);
		prefetchw_prev_lru_page(page, &l_active, flags);
		VM_BUG_ON(PageLRU(page));
		SetPageLRU(page);
		VM_BUG_ON(!PageActive(page));

		list_move(&page->lru, &zone->lru[lru].list);
		mem_cgroup_move_lists(page, lru);
		pgmoved++;
		if (!pagevec_add(&pvec, page)) {
			__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
			pgmoved = 0;
			spin_unlock_irq(&zone->lru_lock);
			if (vm_swap_full())
				pagevec_swap_free(&pvec);
			__pagevec_release(&pvec);
			spin_lock_irq(&zone->lru_lock);
		}
	}
	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);

	__count_zone_vm_events(PGREFILL, zone, pgscanned);
	__count_vm_events(PGDEACTIVATE, pgdeactivate);
	spin_unlock_irq(&zone->lru_lock);
	if (vm_swap_full())
		pagevec_swap_free(&pvec);

	pagevec_release(&pvec);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
