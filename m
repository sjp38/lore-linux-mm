Date: Fri, 10 Oct 2008 15:33:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re:
 vmscan-give-referenced-active-and-unmapped-pages-a-second-trip-around-the-lru.patch
Message-Id: <20081010153346.e25b90f7.akpm@linux-foundation.org>
In-Reply-To: <20081010152540.79ed64cb.akpm@linux-foundation.org>
References: <200810081655.06698.nickpiggin@yahoo.com.au>
	<20081008185401.D958.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081010151701.e9e50bdb.akpm@linux-foundation.org>
	<20081010152540.79ed64cb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kosaki.motohiro@jp.fujitsu.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org, riel@redhat.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 10 Oct 2008 15:25:40 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 10 Oct 2008 15:17:01 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Wed,  8 Oct 2008 19:03:07 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > Hi
> > > 
> > > Nick, Andrew, very thanks for good advice.
> > > your helpful increase my investigate speed.
> > > 
> > > 
> > > > This patch, like I said when it was first merged, has the problem that
> > > > it can cause large stalls when reclaiming pages.
> > > > 
> > > > I actually myself tried a similar thing a long time ago. The problem is
> > > > that after a long period of no reclaiming, your file pages can all end
> > > > up being active and referenced. When the first guy wants to reclaim a
> > > > page, it might have to scan through gigabytes of file pages before being
> > > > able to reclaim a single one.
> > > 
> > > I perfectly agree this opinion.
> > > all pages stay on active list is awful.
> > > 
> > > In addition, my mesurement tell me this patch cause latency degression on really heavy io workload.
> > > 
> > > 2.6.27-rc8: Throughput 13.4231 MB/sec  4000 clients  4000 procs  max_latency=1421988.159 ms
> > >  + patch  : Throughput 12.0953 MB/sec  4000 clients  4000 procs  max_latency=1731244.847 ms
> > > 
> > > 
> > > > While it would be really nice to be able to just lazily set PageReferenced
> > > > and nothing else in mark_page_accessed, and then do file page aging based
> > > > on the referenced bit, the fact is that we virtually have O(1) reclaim
> > > > for file pages now, and this can make it much more like O(n) (in worst case,
> > > > especially).
> > > > 
> > > > I don't think it is right to say "we broke aging and this patch fixes it".
> > > > It's all a big crazy heuristic. Who's to say that the previous behaviour
> > > > wasn't better and this patch breaks it? :)
> > > > 
> > > > Anyway, I don't think it is exactly productive to keep patches like this in
> > > > the tree (that doesn't seem ever intended to be merged) while there are
> > > > other big changes to reclaim there.
> > 
> > Well yes.  I've been hanging onto these in the hope that someone would
> > work out whether they are changes which we should make.
> > 
> > 
> > > > Same for vm-dont-run-touch_buffer-during-buffercache-lookups.patch
> > > 
> > > I mesured it too,
> > > 
> > > 2.6.27-rc8: Throughput 13.4231 MB/sec  4000 clients  4000 procs  max_latency=1421988.159 ms
> > >  + patch  : Throughput 11.8494 MB/sec  4000 clients  4000 procs  max_latency=3463217.227 ms
> > > 
> > > dbench latency increased about x2.5
> > > 
> > > So, the patch desctiption already descibe this risk. 
> > > metadata dropping can decrease performance largely.
> > > that just appeared, imho.
> > 
> > Oh well, that'll suffice, thanks - I'll drop them.
> 
> Which means that after vmscan-split-lru-lists-into-anon-file-sets.patch,
> shrink_active_list() simply does
> 
> 	while (!list_empty(&l_hold)) {
> 		cond_resched();
> 		page = lru_to_page(&l_hold);
> 		list_add(&page->lru, &l_inactive);
> 	}
> 
> yes?
> 
> We might even be able to list_splice those pages..

OK, that wasn't a particularly good time to drop those patches.

Here's how shrink_active_list() ended up:

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

		list_add(&page->lru, &l_inactive);
		if (!page_mapping_inuse(page)) {
			/*
			 * Bypass use-once, make the next access count. See
			 * mark_page_accessed and shrink_page_list.
			 */
			SetPageReferenced(page);
		}
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


Note the first use of pgmoved there.  It no longer does anything.  erk.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
