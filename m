From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 4/4] capture pages freed during direct reclaim for allocation by the reclaimer
Date: Tue,  1 Jul 2008 18:58:42 +0100
Message-Id: <1214935122-20828-5-git-send-email-apw@shadowen.org>
In-Reply-To: <1214935122-20828-1-git-send-email-apw@shadowen.org>
References: <1214935122-20828-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

When a process enters direct reclaim it will spend a considerable effort
identifying and releasing pages in the hope of obtaining a page.  However
as these pages are released asynchronously there is every possibility
that the pages will have been consumed by other allocators before the
reclaimer gets a look in.  This is particularly problematic where the
reclaimer is attempting to allocate a higher order page.  It is highly
likely that a parallel allocation will consume lower order constituent
pages as we release them preventing them coelescing into the higher order
page the reclaimer desires.

This patch set attempts to address this by temporarily collecting the pages
we are releasing onto a local free list.  Instead of freeing them to the
main buddy lists, pages are collected and coelesced on this per direct
reclaimer free list.  Pages which are freed by other processes are also
considered, where they coelesce with a page already under capture they
will be moved to the capture list.  When pressure has been applied to
a zone we then consult the capture list and if there is an appropriatly
sized page available it is taken immediatly and the remainder returned to
the free pool.  Capture is only enabled when the reclaimer's allocation
order exceeds ALLOC_COSTLY_ORDER, as free pages below this order should
naturally occur in large numbers following regular reclaim.

Thanks go to Mel Gorman for numerous discussions during the development
of this patch and for his repeated reviews.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 include/linux/mm_types.h   |    1 +
 include/linux/page-flags.h |    6 ++
 mm/internal.h              |    6 ++
 mm/page_alloc.c            |  142 +++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                |  112 +++++++++++++++++++++++++++++------
 5 files changed, 247 insertions(+), 20 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 45eb71f..67229ba 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -71,6 +71,7 @@ struct page {
 	    struct page *first_page;	/* Compound tail pages */
 	    struct {
 		unsigned long buddy_order;     /* buddy: free page order */
+		struct list_head *buddy_free;  /* buddy: free list pointer */
 	    };
 	};
 	union {
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 0df0e75..405db40 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -111,6 +111,9 @@ enum pageflags {
 	/* SLUB */
 	PG_slub_frozen = PG_active,
 	PG_slub_debug = PG_error,
+
+	/* BUDDY overlays. */
+	PG_buddy_capture = PG_owner_priv_1,
 };
 
 #ifndef __GENERATING_BOUNDS_H
@@ -187,6 +190,9 @@ __PAGEFLAG(SlubDebug, slub_debug)
  */
 TESTPAGEFLAG(Writeback, writeback) TESTSCFLAG(Writeback, writeback)
 __PAGEFLAG(Buddy, buddy)
+PAGEFLAG(BuddyCapture, buddy_capture)	/* A buddy page, but reserved. */
+	__SETPAGEFLAG(BuddyCapture, buddy_capture)
+	__CLEARPAGEFLAG(BuddyCapture, buddy_capture)
 PAGEFLAG(MappedToDisk, mappedtodisk)
 
 /* PG_readahead is only used for file reads; PG_reclaim is only for writes */
diff --git a/mm/internal.h b/mm/internal.h
index ac0f600..e17f7f7 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -59,4 +59,10 @@ static inline unsigned long page_order(struct page *page)
 #define __paginginit __init
 #endif
 
+extern struct page *capture_alloc_or_return(struct zone *, struct zone *,
+					struct list_head *, int, int, gfp_t);
+void capture_one_page(struct list_head *, struct zone *, struct page *, int);
+unsigned long try_to_free_pages_alloc(struct page **, struct zonelist *,
+					nodemask_t *, int, gfp_t, int);
+
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d73e1e1..1ac703d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -410,6 +410,51 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  * -- wli
  */
 
+static inline void __capture_one_page(struct list_head *capture_list,
+		struct page *page, struct zone *zone, unsigned int order)
+{
+	unsigned long page_idx;
+	unsigned long order_size = 1UL << order;
+
+	if (unlikely(PageCompound(page)))
+		destroy_compound_page(page, order);
+
+	page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
+
+	VM_BUG_ON(page_idx & (order_size - 1));
+	VM_BUG_ON(bad_range(zone, page));
+
+	while (order < MAX_ORDER-1) {
+		unsigned long combined_idx;
+		struct page *buddy;
+
+		buddy = __page_find_buddy(page, page_idx, order);
+		if (!page_is_buddy(page, buddy, order))
+			break;
+
+		/* Our buddy is free, merge with it and move up one order. */
+		list_del(&buddy->lru);
+		if (PageBuddyCapture(buddy)) {
+			buddy->buddy_free = 0;
+			__ClearPageBuddyCapture(buddy);
+		} else {
+			zone->free_area[order].nr_free--;
+			__mod_zone_page_state(zone,
+					NR_FREE_PAGES, -(1UL << order));
+		}
+		rmv_page_order(buddy);
+		combined_idx = __find_combined_index(page_idx, order);
+		page = page + (combined_idx - page_idx);
+		page_idx = combined_idx;
+		order++;
+	}
+	set_page_order(page, order);
+	__SetPageBuddyCapture(page);
+	page->buddy_free = capture_list;
+
+	list_add(&page->lru, capture_list);
+}
+
 static inline void __free_one_page(struct page *page,
 		struct zone *zone, unsigned int order)
 {
@@ -433,6 +478,12 @@ static inline void __free_one_page(struct page *page,
 		buddy = __page_find_buddy(page, page_idx, order);
 		if (!page_is_buddy(page, buddy, order))
 			break;
+		if (PageBuddyCapture(buddy)) {
+			__mod_zone_page_state(zone,
+					NR_FREE_PAGES, -(1UL << order));
+			return __capture_one_page(buddy->buddy_free,
+							page, zone, order);
+		}
 
 		/* Our buddy is free, merge with it and move up one order. */
 		list_del(&buddy->lru);
@@ -534,6 +585,19 @@ static void free_one_page(struct zone *zone, struct page *page, int order)
 	spin_unlock(&zone->lock);
 }
 
+void capture_one_page(struct list_head *free_list,
+			struct zone *zone, struct page *page, int order)
+{
+	unsigned long flags;
+
+	if (!free_page_prepare(page, order))
+		return;
+
+	spin_lock_irqsave(&zone->lock, flags);
+	__capture_one_page(free_list, page, zone, order);
+	spin_unlock_irqrestore(&zone->lock, flags);
+}
+
 static void __free_pages_ok(struct page *page, unsigned int order)
 {
 	unsigned long flags;
@@ -607,6 +671,18 @@ static inline void expand(struct zone *zone, struct page *page,
 	}
 }
 
+void __carve_off(struct page *page, unsigned long actual_order,
+					unsigned long desired_order)
+{
+	int migratetype = get_pageblock_migratetype(page);
+	struct zone *zone = page_zone(page);
+	struct free_area *area = &(zone->free_area[actual_order]);
+
+	__mod_zone_page_state(zone, NR_FREE_PAGES,
+				(1UL << actual_order) - (1UL << desired_order));
+	expand(zone, page, desired_order, actual_order, area, migratetype);
+}
+
 /*
  * This page is about to be returned from the page allocator
  */
@@ -1585,11 +1661,15 @@ nofail_alloc:
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
+	did_some_progress = try_to_free_pages_alloc(&page, zonelist, nodemask,
+						order, gfp_mask, alloc_flags);
 
 	p->reclaim_state = NULL;
 	p->flags &= ~PF_MEMALLOC;
 
+	if (page)
+		goto got_pg;
+
 	cond_resched();
 
 	if (order != 0)
@@ -4561,6 +4641,66 @@ out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
+#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
+
+/*
+ * Run through the accumulated list of captured pages and the first
+ * which is big enough to satisfy the original allocation.  Free
+ * the remainder of that page and all other pages.
+ */
+struct page *capture_alloc_or_return(struct zone *zone,
+		struct zone *preferred_zone, struct list_head *capture_list,
+		int order, int alloc_flags, gfp_t gfp_mask)
+{
+	struct page *capture_page = 0;
+	unsigned long flags;
+	int classzone_idx = zone_idx(preferred_zone);
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	while (!list_empty(capture_list)) {
+		struct page *page;
+		int pg_order;
+
+		page = lru_to_page(capture_list);
+		list_del(&page->lru);
+		pg_order = page_order(page);
+
+		/* This page is being allocated, clear our buddy info. */
+		rmv_page_order(page);
+		page->buddy_free = 0;
+		ClearPageBuddyCapture(page);
+
+		if (!capture_page && pg_order >= order) {
+			__carve_off(page, pg_order, order);
+			capture_page = page;
+		} else
+			__free_one_page(page, zone, pg_order);
+	}
+
+	/* Ensure that this capture would not violate the watermarks. */
+	if (capture_page &&
+	    (!zone_cpuset_ok(zone, alloc_flags, gfp_mask) ||
+	     !zone_alloc_ok(zone, order, classzone_idx,
+					     alloc_flags, gfp_mask))) {
+		__free_one_page(capture_page, zone, order);
+		capture_page = NULL;
+	}
+
+	if (capture_page)
+		__count_zone_vm_events(PGALLOC, zone, 1 << order);
+
+	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
+	zone->pages_scanned = 0;
+
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	if (capture_page)
+		prep_new_page(capture_page, order, gfp_mask);
+
+	return capture_page;
+}
+
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * All pages in the range must be isolated before calling this.
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9a29901..c9d99ff 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -53,6 +53,8 @@ struct scan_control {
 	/* This context's GFP mask */
 	gfp_t gfp_mask;
 
+	int alloc_flags;
+
 	int may_writepage;
 
 	/* Can pages be swapped as part of reclaim? */
@@ -78,6 +80,12 @@ struct scan_control {
 			unsigned long *scanned, int order, int mode,
 			struct zone *z, struct mem_cgroup *mem_cont,
 			int active);
+
+	/* Captured page. */
+	struct page **capture;
+	
+	/* Nodemask for acceptable allocations. */
+	nodemask_t *nodemask;
 };
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -454,7 +462,8 @@ cannot_free:
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
-static unsigned long shrink_page_list(struct list_head *page_list,
+static unsigned long shrink_page_list(struct list_head *free_list,
+					struct list_head *page_list,
 					struct scan_control *sc,
 					enum pageout_io sync_writeback)
 {
@@ -607,8 +616,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 free_it:
 		unlock_page(page);
 		nr_reclaimed++;
-		if (!pagevec_add(&freed_pvec, page))
-			__pagevec_release_nonlru(&freed_pvec);
+		if (free_list) {
+			if (put_page_testzero(page))
+				capture_one_page(free_list,
+						page_zone(page), page, 0);
+		} else {
+			if (!pagevec_add(&freed_pvec, page))
+				__pagevec_release_nonlru(&freed_pvec);
+		}
+
 		continue;
 
 activate_locked:
@@ -813,8 +829,8 @@ static unsigned long clear_active_flags(struct list_head *page_list)
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
  */
-static unsigned long shrink_inactive_list(unsigned long max_scan,
-				struct zone *zone, struct scan_control *sc)
+static unsigned long shrink_inactive_list(struct list_head *free_list,
+	unsigned long max_scan, struct zone *zone, struct scan_control *sc)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
@@ -848,7 +864,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		spin_unlock_irq(&zone->lru_lock);
 
 		nr_scanned += nr_scan;
-		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
+		nr_freed = shrink_page_list(free_list, &page_list,
+							sc, PAGEOUT_IO_ASYNC);
 
 		/*
 		 * If we are direct reclaiming for contiguous pages and we do
@@ -867,8 +884,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 			nr_active = clear_active_flags(&page_list);
 			count_vm_events(PGDEACTIVATE, nr_active);
 
-			nr_freed += shrink_page_list(&page_list, sc,
-							PAGEOUT_IO_SYNC);
+			nr_freed += shrink_page_list(free_list, &page_list,
+							sc, PAGEOUT_IO_SYNC);
 		}
 
 		nr_reclaimed += nr_freed;
@@ -1168,13 +1185,30 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static unsigned long shrink_zone(int priority, struct zone *zone,
-				struct scan_control *sc)
+			struct zone *preferred_zone, struct scan_control *sc)
 {
 	unsigned long nr_active;
 	unsigned long nr_inactive;
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
 
+	struct list_head __capture_list;
+	struct list_head *capture_list = NULL;
+	struct page *capture_page;
+
+	/*
+	 * When direct reclaimers are asking for larger orders
+	 * capture pages for them.  There is no point if we already
+	 * have an acceptable page or if this zone is not within the
+	 * nodemask.
+	 */
+	if (sc->order > PAGE_ALLOC_COSTLY_ORDER &&
+	    sc->capture && !*(sc->capture) && (sc->nodemask == NULL ||
+	    node_isset(zone_to_nid(zone), *sc->nodemask))) {
+		capture_list = &__capture_list;
+		INIT_LIST_HEAD(capture_list);
+	}
+
 	if (scan_global_lru(sc)) {
 		/*
 		 * Add one to nr_to_scan just to make sure that the kernel
@@ -1208,6 +1242,7 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
 					zone, priority);
 	}
 
+	capture_page = NULL;
 
 	while (nr_active || nr_inactive) {
 		if (nr_active) {
@@ -1221,11 +1256,22 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
 			nr_to_scan = min(nr_inactive,
 					(unsigned long)sc->swap_cluster_max);
 			nr_inactive -= nr_to_scan;
-			nr_reclaimed += shrink_inactive_list(nr_to_scan, zone,
-								sc);
+			nr_reclaimed += shrink_inactive_list(capture_list,
+							nr_to_scan, zone, sc);
+		}
+
+		if (capture_list) {
+			capture_page = capture_alloc_or_return(zone,
+				preferred_zone, capture_list, sc->order,
+				sc->alloc_flags, sc->gfp_mask);
+			if (capture_page)
+				capture_list = NULL;
 		}
 	}
 
+	if (capture_page)
+		*(sc->capture) = capture_page;
+
 	throttle_vm_writeout(sc->gfp_mask);
 	return nr_reclaimed;
 }
@@ -1247,7 +1293,7 @@ static unsigned long shrink_zone(int priority, struct zone *zone,
  * scan then give up on it.
  */
 static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
-					struct scan_control *sc)
+		struct zone *preferred_zone, struct scan_control *sc)
 {
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	unsigned long nr_reclaimed = 0;
@@ -1281,7 +1327,7 @@ static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
 							priority);
 		}
 
-		nr_reclaimed += shrink_zone(priority, zone, sc);
+		nr_reclaimed += shrink_zone(priority, zone, preferred_zone, sc);
 	}
 
 	return nr_reclaimed;
@@ -1314,8 +1360,14 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	unsigned long lru_pages = 0;
 	struct zoneref *z;
 	struct zone *zone;
+	struct zone *preferred_zone;
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 
+	/* This should never fail as we should be scanning a real zonelist. */
+	(void)first_zones_zonelist(zonelist, high_zoneidx, sc->nodemask,
+							&preferred_zone);
+	BUG_ON(!preferred_zone);
+
 	if (scan_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
 	/*
@@ -1336,7 +1388,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		sc->nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
-		nr_reclaimed += shrink_zones(priority, zonelist, sc);
+		nr_reclaimed += shrink_zones(priority, zonelist,
+							preferred_zone, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1399,11 +1452,13 @@ out:
 	return ret;
 }
 
-unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-								gfp_t gfp_mask)
+unsigned long try_to_free_pages_alloc(struct page **capture_pagep,
+		struct zonelist *zonelist, nodemask_t *nodemask,
+		int order, gfp_t gfp_mask, int alloc_flags)
 {
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
+		.alloc_flags = alloc_flags,
 		.may_writepage = !laptop_mode,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.may_swap = 1,
@@ -1411,17 +1466,28 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.order = order,
 		.mem_cgroup = NULL,
 		.isolate_pages = isolate_pages_global,
+		.capture = capture_pagep,
+		.nodemask = nodemask,
 	};
 
 	return do_try_to_free_pages(zonelist, &sc);
 }
 
+unsigned long try_to_free_pages(struct zonelist *zonelist,
+						int order, gfp_t gfp_mask)
+{
+	return try_to_free_pages_alloc(NULL, zonelist, NULL,
+							order, gfp_mask, 0);
+}
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 						gfp_t gfp_mask)
 {
 	struct scan_control sc = {
+		.gfp_mask = gfp_mask,
+		.alloc_flags = 0,
 		.may_writepage = !laptop_mode,
 		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
@@ -1429,6 +1495,8 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.order = 0,
 		.mem_cgroup = mem_cont,
 		.isolate_pages = mem_cgroup_isolate_pages,
+		.capture = NULL,
+		.nodemask = NULL,
 	};
 	struct zonelist *zonelist;
 
@@ -1470,12 +1538,15 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
+		.alloc_flags = 0,
 		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
 		.isolate_pages = isolate_pages_global,
+		.capture = NULL,
+		.nodemask = NULL,
 	};
 	/*
 	 * temp_priority is used to remember the scanning priority at which
@@ -1564,7 +1635,8 @@ loop_again:
 			 */
 			if (!zone_watermark_ok(zone, order, 8*zone->pages_high,
 						end_zone, 0))
-				nr_reclaimed += shrink_zone(priority, zone, &sc);
+				nr_reclaimed += shrink_zone(priority,
+							zone, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
@@ -1762,7 +1834,7 @@ static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
 			zone->nr_scan_inactive = 0;
 			nr_to_scan = min(nr_pages,
 				zone_page_state(zone, NR_INACTIVE));
-			ret += shrink_inactive_list(nr_to_scan, zone, sc);
+			ret += shrink_inactive_list(NULL, nr_to_scan, zone, sc);
 			if (ret >= nr_pages)
 				return ret;
 		}
@@ -1792,6 +1864,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
+		.alloc_flags = 0,
 		.may_swap = 0,
 		.swap_cluster_max = nr_pages,
 		.may_writepage = 1,
@@ -1980,6 +2053,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		.swap_cluster_max = max_t(unsigned long, nr_pages,
 					SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
+		.alloc_flags = 0,
 		.swappiness = vm_swappiness,
 		.isolate_pages = isolate_pages_global,
 	};
@@ -2006,7 +2080,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		priority = ZONE_RECLAIM_PRIORITY;
 		do {
 			note_zone_scanning_priority(zone, priority);
-			nr_reclaimed += shrink_zone(priority, zone, &sc);
+			nr_reclaimed += shrink_zone(priority, zone, zone, &sc);
 			priority--;
 		} while (priority >= 0 && nr_reclaimed < nr_pages);
 	}
-- 
1.5.6.1.201.g3e7d3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
