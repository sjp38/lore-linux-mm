Received: from imr2.americas.sgi.com (imr2.americas.sgi.com [198.149.16.18])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k1A5YHOX026806
	for <linux-mm@kvack.org>; Thu, 9 Feb 2006 23:34:17 -0600
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by imr2.americas.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k1A5p1a513716292
	for <linux-mm@kvack.org>; Thu, 9 Feb 2006 21:51:01 -0800 (PST)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k1A5YGhP23205158
	for <linux-mm@kvack.org>; Thu, 9 Feb 2006 21:34:16 -0800 (PST)
Date: Thu, 9 Feb 2006 21:02:00 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Get rid of scan_control
Message-ID: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.62.0602092134110.13398@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au
Cc: akpm@osdl.org
List-ID: <linux-mm.kvack.org>

This is done through a variety of measures:

1. nr_reclaimed is the return value of functions and each function
   does the summing of the reclaimed pages on its own.

2. nr_scanned is passed as a reference parameter (sigh... the only leftover)

3. nr_mapped is calculated on each invocation of refill_inactive_list. 
   This is not that optimal but then swapping is not that performance 
   critical.

4. gfp_mask is passed as a parameter. OR flags to gfp_mask for may_swap 
   and may_writepage.

5. Pass swap_cluster_max as a parameter

Most of the parameters passed through scan_control become local variables.
Therefore the compilers are able to generate better code.

And we do no longer have the problem of initializing scan control the
right way.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc2-mm1.orig/mm/vmscan.c	2006-02-09 20:04:37.000000000 -0800
+++ linux-2.6.16-rc2-mm1/mm/vmscan.c	2006-02-09 20:26:32.000000000 -0800
@@ -51,29 +51,12 @@ typedef enum {
 	PAGE_CLEAN,
 } pageout_t;
 
-struct scan_control {
-	/* Incremented by the number of inactive pages that were scanned */
-	unsigned long nr_scanned;
-
-	/* Incremented by the number of pages reclaimed */
-	unsigned long nr_reclaimed;
-
-	unsigned long nr_mapped;	/* From page_state */
-
-	/* This context's GFP mask */
-	gfp_t gfp_mask;
-
-	int may_writepage;
-
-	/* Can pages be swapped as part of reclaim? */
-	int may_swap;
-
-	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
-	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
-	 * In this context, it doesn't matter that we scan the
-	 * whole list at once. */
-	int swap_cluster_max;
-};
+/*
+ * Some additional flags to be added to gfp_t in the context
+ * of swap processing.
+ */
+#define MAY_SWAP      (1 << __GFP_BITS_SHIFT)
+#define MAY_WRITEPAGE (1 << (__GFP_BITS_SHIFT + 1))
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
@@ -409,12 +392,14 @@ cannot_free:
 /*
  * shrink_list adds the number of reclaimed pages to sc->nr_reclaimed
  */
-static int shrink_list(struct list_head *page_list, struct scan_control *sc)
+static int shrink_list(struct list_head *page_list, gfp_t gfp_mask,
+				unsigned long *total_scanned)
 {
 	LIST_HEAD(ret_pages);
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	int reclaimed = 0;
+	int nr_scanned = 0;
 
 	cond_resched();
 
@@ -435,10 +420,10 @@ static int shrink_list(struct list_head 
 
 		BUG_ON(PageActive(page));
 
-		sc->nr_scanned++;
+		nr_scanned++;
 		/* Double the slab pressure for mapped and swapcache pages */
 		if (page_mapped(page) || PageSwapCache(page))
-			sc->nr_scanned++;
+			nr_scanned++;
 
 		if (PageWriteback(page))
 			goto keep_locked;
@@ -454,7 +439,7 @@ static int shrink_list(struct list_head 
 		 * Try to allocate it some swap space here.
 		 */
 		if (PageAnon(page) && !PageSwapCache(page)) {
-			if (!sc->may_swap)
+			if (!(gfp_mask & MAY_SWAP))
 				goto keep_locked;
 			if (!add_to_swap(page, GFP_ATOMIC))
 				goto activate_locked;
@@ -462,8 +447,8 @@ static int shrink_list(struct list_head 
 #endif /* CONFIG_SWAP */
 
 		mapping = page_mapping(page);
-		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
-			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
+		may_enter_fs = (gfp_mask & __GFP_FS) ||
+			(PageSwapCache(page) && (gfp_mask & __GFP_IO));
 
 		/*
 		 * The page is mapped into the page tables of one or more
@@ -473,7 +458,7 @@ static int shrink_list(struct list_head 
 			/*
 			 * No unmapping if we do not swap
 			 */
-			if (!sc->may_swap)
+			if (!(gfp_mask & MAY_SWAP))
 				goto keep_locked;
 
 			switch (try_to_unmap(page, 0)) {
@@ -491,7 +476,7 @@ static int shrink_list(struct list_head 
 				goto keep_locked;
 			if (!may_enter_fs)
 				goto keep_locked;
-			if (!sc->may_writepage)
+			if (!(gfp_mask & MAY_WRITEPAGE))
 				goto keep_locked;
 
 			/* Page is dirty, try to write it out here */
@@ -539,7 +524,7 @@ static int shrink_list(struct list_head 
 		 * Otherwise, leave the page on the LRU so it is swappable.
 		 */
 		if (PagePrivate(page)) {
-			if (!try_to_release_page(page, sc->gfp_mask))
+			if (!try_to_release_page(page, gfp_mask))
 				goto activate_locked;
 			/*
 			 * file system may manually remove page from the page
@@ -573,7 +558,7 @@ keep:
 	if (pagevec_count(&freed_pvec))
 		__pagevec_release_nonlru(&freed_pvec);
 	mod_page_state(pgactivate, pgactivate);
-	sc->nr_reclaimed += reclaimed;
+	*total_scanned += nr_scanned;
 	return reclaimed;
 }
 
@@ -1085,10 +1070,12 @@ static int isolate_lru_pages(int nr_to_s
 /*
  * shrink_cache() adds the number of pages reclaimed to sc->nr_reclaimed
  */
-static void shrink_cache(int max_scan, struct zone *zone, struct scan_control *sc)
+static int shrink_cache(int max_scan, struct zone *zone, gfp_t gfp_mask,
+			int swap_cluster_max, unsigned long *nr_scanned)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
+	int nr_reclaimed = 0;
 
 	pagevec_init(&pvec, 1);
 
@@ -1100,7 +1087,7 @@ static void shrink_cache(int max_scan, s
 		int nr_scan;
 		int nr_freed;
 
-		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
+		nr_taken = isolate_lru_pages(swap_cluster_max,
 					     &zone->inactive_list,
 					     &page_list, &nr_scan);
 		zone->nr_inactive -= nr_taken;
@@ -1111,7 +1098,7 @@ static void shrink_cache(int max_scan, s
 			goto done;
 
 		max_scan -= nr_scan;
-		nr_freed = shrink_list(&page_list, sc);
+		nr_reclaimed += nr_freed = shrink_list(&page_list, gfp_mask, nr_scanned);
 
 		local_irq_disable();
 		if (current_is_kswapd()) {
@@ -1144,6 +1131,7 @@ static void shrink_cache(int max_scan, s
 	spin_unlock_irq(&zone->lru_lock);
 done:
 	pagevec_release(&pvec);
+	return nr_reclaimed;
 }
 
 /*
@@ -1164,7 +1152,7 @@ done:
  * But we had to alter page->flags anyway.
  */
 static void
-refill_inactive_zone(int nr_pages, struct zone *zone, struct scan_control *sc)
+refill_inactive_zone(int nr_pages, struct zone *zone)
 {
 	int pgmoved;
 	int pgdeactivate = 0;
@@ -1198,7 +1186,7 @@ refill_inactive_zone(int nr_pages, struc
 	 * mapped memory instead of just pagecache.  Work out how much memory
 	 * is mapped.
 	 */
-	mapped_ratio = (sc->nr_mapped * 100) / total_memory;
+	mapped_ratio = (read_page_state(nr_mapped) * 100) / total_memory;
 
 	/*
 	 * Now decide how much we really want to unmap some pages.  The mapped
@@ -1295,12 +1283,14 @@ refill_inactive_zone(int nr_pages, struc
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static void
-shrink_zone(int priority, struct zone *zone, struct scan_control *sc)
+static int
+shrink_zone(int priority, struct zone *zone, gfp_t gfp_mask,
+		unsigned long swap_cluster_max, unsigned long *nr_scanned)
 {
 	unsigned long nr_active;
 	unsigned long nr_inactive;
 	unsigned long nr_to_scan;
+	unsigned long nr_reclaimed = 0;
 
 	atomic_inc(&zone->reclaim_in_progress);
 
@@ -1310,37 +1300,37 @@ shrink_zone(int priority, struct zone *z
 	 */
 	zone->nr_scan_active += (zone->nr_active >> priority) + 1;
 	nr_active = zone->nr_scan_active;
-	if (nr_active >= sc->swap_cluster_max)
+	if (nr_active >= swap_cluster_max)
 		zone->nr_scan_active = 0;
 	else
 		nr_active = 0;
 
 	zone->nr_scan_inactive += (zone->nr_inactive >> priority) + 1;
 	nr_inactive = zone->nr_scan_inactive;
-	if (nr_inactive >= sc->swap_cluster_max)
+	if (nr_inactive >= swap_cluster_max)
 		zone->nr_scan_inactive = 0;
 	else
 		nr_inactive = 0;
 
 	while (nr_active || nr_inactive) {
 		if (nr_active) {
-			nr_to_scan = min(nr_active,
-					(unsigned long)sc->swap_cluster_max);
+			nr_to_scan = min(nr_active, swap_cluster_max);
 			nr_active -= nr_to_scan;
-			refill_inactive_zone(nr_to_scan, zone, sc);
+			refill_inactive_zone(nr_to_scan, zone);
 		}
 
 		if (nr_inactive) {
-			nr_to_scan = min(nr_inactive,
-					(unsigned long)sc->swap_cluster_max);
+			nr_to_scan = min(nr_inactive, swap_cluster_max);
 			nr_inactive -= nr_to_scan;
-			shrink_cache(nr_to_scan, zone, sc);
+			nr_reclaimed += shrink_cache(nr_to_scan, zone, gfp_mask,
+							swap_cluster_max, nr_scanned);
 		}
 	}
 
 	throttle_vm_writeout();
 
 	atomic_dec(&zone->reclaim_in_progress);
+	return nr_reclaimed;
 }
 
 /*
@@ -1359,10 +1349,12 @@ shrink_zone(int priority, struct zone *z
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static void
-shrink_caches(int priority, struct zone **zones, struct scan_control *sc)
+static int
+shrink_caches(int priority, struct zone **zones, gfp_t gfp_mask,
+			int swap_cluster_max, unsigned long *nr_scanned)
 {
 	int i;
+	int nr_reclaimed = 0;
 
 	for (i = 0; zones[i] != NULL; i++) {
 		struct zone *zone = zones[i];
@@ -1380,8 +1372,10 @@ shrink_caches(int priority, struct zone 
 		if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
 
-		shrink_zone(priority, zone, sc);
+		nr_reclaimed += shrink_zone(priority, zone, gfp_mask,
+						swap_cluster_max, nr_scanned);
 	}
+	return nr_reclaimed;
 }
  
 /*
@@ -1403,13 +1397,12 @@ int try_to_free_pages(struct zone **zone
 	int ret = 0;
 	int total_scanned = 0, total_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
-	struct scan_control sc;
 	unsigned long lru_pages = 0;
 	int i;
 
-	sc.gfp_mask = gfp_mask;
-	sc.may_writepage = !laptop_mode;
-	sc.may_swap = 1;
+	gfp_mask |= MAY_SWAP;
+	if (!laptop_mode)
+		gfp_mask |= MAY_WRITEPAGE;
 
 	inc_page_state(allocstall);
 
@@ -1424,21 +1417,19 @@ int try_to_free_pages(struct zone **zone
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
-		sc.nr_mapped = read_page_state(nr_mapped);
-		sc.nr_scanned = 0;
-		sc.nr_reclaimed = 0;
-		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
+		unsigned long nr_scanned = 0;
+
 		if (!priority)
 			disable_swap_token();
-		shrink_caches(priority, zones, &sc);
-		shrink_slab(sc.nr_scanned, gfp_mask, lru_pages);
+		total_reclaimed += shrink_caches(priority, zones, gfp_mask,
+						SWAP_CLUSTER_MAX, &nr_scanned);
+		shrink_slab(nr_scanned, gfp_mask, lru_pages);
 		if (reclaim_state) {
-			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
+			total_reclaimed += reclaim_state->reclaimed_slab;
 			reclaim_state->reclaimed_slab = 0;
 		}
-		total_scanned += sc.nr_scanned;
-		total_reclaimed += sc.nr_reclaimed;
-		if (total_reclaimed >= sc.swap_cluster_max) {
+		total_scanned += nr_scanned;
+		if (total_reclaimed >= SWAP_CLUSTER_MAX) {
 			ret = 1;
 			goto out;
 		}
@@ -1450,13 +1441,13 @@ int try_to_free_pages(struct zone **zone
 		 * that's undesirable in laptop mode, where we *want* lumpy
 		 * writeout.  So in laptop mode, write out the whole world.
 		 */
-		if (total_scanned > sc.swap_cluster_max + sc.swap_cluster_max/2) {
+		if (total_scanned > SWAP_CLUSTER_MAX + SWAP_CLUSTER_MAX/2) {
 			wakeup_pdflush(laptop_mode ? 0 : total_scanned);
-			sc.may_writepage = 1;
+			gfp_mask |= MAY_WRITEPAGE;
 		}
 
 		/* Take a nap, wait for some writeback to complete */
-		if (sc.nr_scanned && priority < DEF_PRIORITY - 2)
+		if (nr_scanned && priority < DEF_PRIORITY - 2)
 			blk_congestion_wait(WRITE, HZ/10);
 	}
 out:
@@ -1504,15 +1495,14 @@ static int balance_pgdat(pg_data_t *pgda
 	int i;
 	int total_scanned, total_reclaimed;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
-	struct scan_control sc;
+	gfp_t gfp_mask;
 
 loop_again:
 	total_scanned = 0;
 	total_reclaimed = 0;
-	sc.gfp_mask = GFP_KERNEL;
-	sc.may_writepage = !laptop_mode;
-	sc.may_swap = 1;
-	sc.nr_mapped = read_page_state(nr_mapped);
+	gfp_mask = GFP_KERNEL | MAY_SWAP;
+	if (!laptop_mode)
+		gfp_mask |= MAY_WRITEPAGE;
 
 	inc_page_state(pageoutrun);
 
@@ -1575,6 +1565,7 @@ scan:
 		 */
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
+			unsigned long nr_scanned = 0;
 			int nr_slab;
 
 			if (!populated_zone(zone))
@@ -1591,18 +1582,16 @@ scan:
 			zone->temp_priority = priority;
 			if (zone->prev_priority > priority)
 				zone->prev_priority = priority;
-			sc.nr_scanned = 0;
-			sc.nr_reclaimed = 0;
-			sc.swap_cluster_max = nr_pages? nr_pages : SWAP_CLUSTER_MAX;
+
 			atomic_inc(&zone->reclaim_in_progress);
-			shrink_zone(priority, zone, &sc);
+			total_reclaimed += shrink_zone(priority, zone, gfp_mask,
+						max(nr_pages, SWAP_CLUSTER_MAX), &nr_scanned);
 			atomic_dec(&zone->reclaim_in_progress);
 			reclaim_state->reclaimed_slab = 0;
-			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
+			nr_slab = shrink_slab(nr_scanned, GFP_KERNEL,
 						lru_pages);
-			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-			total_reclaimed += sc.nr_reclaimed;
-			total_scanned += sc.nr_scanned;
+			total_reclaimed += reclaim_state->reclaimed_slab;
+			total_scanned += nr_scanned;
 			if (zone->all_unreclaimable)
 				continue;
 			if (nr_slab == 0 && zone->pages_scanned >=
@@ -1615,7 +1604,7 @@ scan:
 			 */
 			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
 			    total_scanned > total_reclaimed+total_reclaimed/2)
-				sc.may_writepage = 1;
+				gfp_mask |= MAY_WRITEPAGE;
 		}
 		if (nr_pages && to_free > total_reclaimed)
 			continue;	/* swsusp: need to do more work */
@@ -1848,10 +1837,11 @@ int zone_reclaim(struct zone *zone, gfp_
 	int nr_pages;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
-	struct scan_control sc;
 	cpumask_t mask;
 	int node_id;
 	int priority;
+	int total_reclaimed;
+	unsigned long nr_scanned;
 
 	if (time_before(jiffies,
 		zone->last_unsuccessful_zone_reclaim + zone_reclaim_interval))
@@ -1867,20 +1857,16 @@ int zone_reclaim(struct zone *zone, gfp_
 	if (!cpus_empty(mask) && node_id != numa_node_id())
 		return 0;
 
-	sc.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE);
-	sc.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP);
-	sc.nr_scanned = 0;
-	sc.nr_reclaimed = 0;
-	sc.nr_mapped = read_page_state(nr_mapped);
-	sc.gfp_mask = gfp_mask;
+	if (zone_reclaim_mode & RECLAIM_WRITE)
+		gfp_mask |= MAY_WRITEPAGE;
+	if (zone_reclaim_mode & RECLAIM_SWAP)
+		gfp_mask |= MAY_SWAP;
 
 	disable_swap_token();
 
 	nr_pages = 1 << order;
-	if (nr_pages > SWAP_CLUSTER_MAX)
-		sc.swap_cluster_max = nr_pages;
-	else
-		sc.swap_cluster_max = SWAP_CLUSTER_MAX;
+	nr_scanned = 0;
+	total_reclaimed = 0;
 
 	cond_resched();
 	p->flags |= PF_MEMALLOC;
@@ -1893,11 +1879,12 @@ int zone_reclaim(struct zone *zone, gfp_
 	 */
 	priority = ZONE_RECLAIM_PRIORITY;
 	do {
-		shrink_zone(priority, zone, &sc);
+		total_reclaimed += shrink_zone(priority, zone, gfp_mask,
+					max(nr_pages, SWAP_CLUSTER_MAX), &nr_scanned);
 		priority--;
-	} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
+	} while (priority >= 0 && total_reclaimed < nr_pages);
 
-	if (sc.nr_reclaimed < nr_pages && (zone_reclaim_mode & RECLAIM_SLAB)) {
+	if (total_reclaimed < nr_pages && (zone_reclaim_mode & RECLAIM_SLAB)) {
 		/*
 		 * shrink_slab does not currently allow us to determine
 		 * how many pages were freed in the zone. So we just
@@ -1906,17 +1893,17 @@ int zone_reclaim(struct zone *zone, gfp_
 		 * shrink_slab will free memory on all zones and may take
 		 * a long time.
 		 */
-		shrink_slab(sc.nr_scanned, gfp_mask, order);
-		sc.nr_reclaimed = 1;    /* Avoid getting the off node timeout */
+		shrink_slab(nr_scanned, gfp_mask, order);
+		total_reclaimed = 1;    /* Avoid getting the off node timeout */
 	}
 
 	p->reclaim_state = NULL;
 	current->flags &= ~PF_MEMALLOC;
 
-	if (sc.nr_reclaimed == 0)
+	if (total_reclaimed == 0)
 		zone->last_unsuccessful_zone_reclaim = jiffies;
 
-	return sc.nr_reclaimed >= nr_pages;
+	return total_reclaimed >= nr_pages;
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
