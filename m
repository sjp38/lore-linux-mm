Message-ID: <4020BE77.7040303@cyberone.com.au>
Date: Wed, 04 Feb 2004 20:42:15 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: [PATCH 4/5] mm improvements
References: <4020BDCB.8030707@cyberone.com.au>
In-Reply-To: <4020BDCB.8030707@cyberone.com.au>
Content-Type: multipart/mixed;
 boundary="------------000602050502010505010704"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000602050502010505010704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Nick Piggin wrote:

> 4/5: vm-fix-shrink-zone.patch
>     Most significant part of this patch changes active / inactive
>     balancing. This improves non swapping kbuild by a few %. Helps
>     swapping significantly.
>
>     It also contains a number of other small fixes which have little
>     measurable impact on kbuild.
>



--------------000602050502010505010704
Content-Type: text/plain;
 name="vm-fix-shrink-zone.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-fix-shrink-zone.patch"


This patch helps high kbuild loads (swapping) significantly.
It actually also takes 2-3 seconds off a single threaded and non swapping
make bzImage on a 64MB system, and improves light and medium swapping
performance as well.

* Improve precision in shrink_slab by doing a multiply first.
* Calculate nr_scanned correctly instead of using max_scanned.
* In shrink_cache, loop again if (nr_taken == 0) or
  (nr_freed <= 0 && list_empty(&page_list)) instead of terminating.
  Use max_scan to determine termination.
* In shrink_zone, scan the active list more aggressively at low and
  medium imbalances. This gives improvements to kbuild at no and low
  swapping loads.
* Scan the active list more aggressively at high loads, but cap the
  amount of scanning that can be done. This helps high swapping loads.
* The more aggressive scanning helps by making better use of the inactive
  list to provide reclaim information.
* Calculate max_scan after we have refilled the inactive list.
* In try_to_free_pages, put even pressure on the slab even if we have
  reclaimed enough pages from the LRU.
  


 linux-2.6-npiggin/mm/vmscan.c |  137 ++++++++++++++++++++----------------------
 1 files changed, 66 insertions(+), 71 deletions(-)

diff -puN mm/vmscan.c~vm-fix-shrink-zone mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-fix-shrink-zone	2004-02-04 14:09:45.000000000 +1100
+++ linux-2.6-npiggin/mm/vmscan.c	2004-02-04 14:09:45.000000000 +1100
@@ -137,7 +137,7 @@ EXPORT_SYMBOL(remove_shrinker);
  *
  * We do weird things to avoid (scanned*seeks*entries) overflowing 32 bits.
  */
-static int shrink_slab(long scanned, unsigned int gfp_mask)
+static int shrink_slab(unsigned long scanned, unsigned int gfp_mask)
 {
 	struct shrinker *shrinker;
 	long pages;
@@ -149,7 +149,7 @@ static int shrink_slab(long scanned, uns
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		unsigned long long delta;
 
-		delta = 4 * (scanned / shrinker->seeks);
+		delta = 4 * scanned / shrinker->seeks;
 		delta *= (*shrinker->shrinker)(0, gfp_mask);
 		do_div(delta, pages + 1);
 		shrinker->nr += delta;
@@ -245,8 +245,7 @@ static void handle_write_error(struct ad
  * shrink_list returns the number of reclaimed pages
  */
 static int
-shrink_list(struct list_head *page_list, unsigned int gfp_mask,
-		int *max_scan, int *nr_mapped)
+shrink_list(struct list_head *page_list, unsigned int gfp_mask, int *nr_mapped)
 {
 	struct address_space *mapping;
 	LIST_HEAD(ret_pages);
@@ -481,13 +480,15 @@ keep:
  */
 static int
 shrink_cache(const int nr_pages, struct zone *zone,
-		unsigned int gfp_mask, int max_scan, int *nr_mapped)
+		unsigned int gfp_mask, int max_scan, int *nr_scanned)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
 	int nr_to_process;
 	int ret = 0;
 
+	*nr_scanned = 0;
+
 	/*
 	 * Try to ensure that we free `nr_pages' pages in one pass of the loop.
 	 */
@@ -498,8 +499,9 @@ shrink_cache(const int nr_pages, struct 
 	pagevec_init(&pvec, 1);
 
 	lru_add_drain();
+again:
 	spin_lock_irq(&zone->lru_lock);
-	while (max_scan > 0 && ret < nr_pages) {
+	while (*nr_scanned < max_scan && ret < nr_pages) {
 		struct page *page;
 		int nr_taken = 0;
 		int nr_scan = 0;
@@ -529,18 +531,19 @@ shrink_cache(const int nr_pages, struct 
 		zone->pages_scanned += nr_taken;
 		spin_unlock_irq(&zone->lru_lock);
 
+		*nr_scanned += nr_scan;
 		if (nr_taken == 0)
-			goto done;
+			goto again;
 
-		max_scan -= nr_scan;
 		mod_page_state(pgscan, nr_scan);
-		nr_freed = shrink_list(&page_list, gfp_mask,
-					&max_scan, nr_mapped);
+		nr_freed = shrink_list(&page_list, gfp_mask, nr_scanned);
 		ret += nr_freed;
+
 		if (nr_freed <= 0 && list_empty(&page_list))
-			goto done;
+			goto again;
 
 		spin_lock_irq(&zone->lru_lock);
+
 		/*
 		 * Put back any unfreeable pages.
 		 */
@@ -561,7 +564,6 @@ shrink_cache(const int nr_pages, struct 
 		}
   	}
 	spin_unlock_irq(&zone->lru_lock);
-done:
 	pagevec_release(&pvec);
 	return ret;
 }
@@ -570,9 +572,8 @@ done:
 /* move pages from @page_list to the @spot, that should be somewhere on the
  * @zone->active_list */
 static int
-spill_on_spot(struct zone *zone,
-	      struct list_head *page_list, struct list_head *spot,
-	      struct pagevec *pvec)
+spill_on_spot(struct zone *zone, struct list_head *page_list,
+		struct list_head *spot, struct pagevec *pvec)
 {
 	struct page *page;
 	int          moved;
@@ -793,41 +794,47 @@ refill_inactive_zone(struct zone *zone, 
  * direct reclaim.
  */
 static int
-shrink_zone(struct zone *zone, int max_scan, unsigned int gfp_mask,
-	const int nr_pages, int *nr_mapped, struct page_state *ps)
+shrink_zone(struct zone *zone, unsigned int gfp_mask,
+	int nr_pages, int *nr_scanned, struct page_state *ps, int priority)
 {
-	unsigned long ratio;
+	unsigned long imbalance;
+	unsigned long nr_refill_inact;
+	unsigned long max_scan;
 
 	/*
 	 * Try to keep the active list 2/3 of the size of the cache.  And
 	 * make sure that refill_inactive is given a decent number of pages.
 	 *
-	 * The "ratio+1" here is important.  With pagecache-intensive workloads
-	 * the inactive list is huge, and `ratio' evaluates to zero all the
-	 * time.  Which pins the active list memory.  So we add one to `ratio'
-	 * just to make sure that the kernel will slowly sift through the
-	 * active list.
+	 * Keeping imbalance > 0 is important.  With pagecache-intensive loads
+	 * the inactive list is huge, and imbalance evaluates to zero all the
+	 * time which would pin the active list memory.
 	 */
-	ratio = (unsigned long)nr_pages * zone->nr_active /
-				((zone->nr_inactive | 1) * 2);
-	atomic_add(ratio+1, &zone->refill_counter);
-	if (atomic_read(&zone->refill_counter) > SWAP_CLUSTER_MAX) {
-		int count;
-
-		/*
-		 * Don't try to bring down too many pages in one attempt.
-		 * If this fails, the caller will increase `priority' and
-		 * we'll try again, with an increased chance of reclaiming
-		 * mapped memory.
-		 */
-		count = atomic_read(&zone->refill_counter);
-		if (count > SWAP_CLUSTER_MAX * 4)
-			count = SWAP_CLUSTER_MAX * 4;
-		atomic_set(&zone->refill_counter, 0);
-		refill_inactive_zone(zone, count, ps);
+	if (zone->nr_active >= zone->nr_inactive*4)
+		/* ratio will be >= 2 */
+		imbalance = 8*nr_pages;
+	else if (zone->nr_active >= zone->nr_inactive*2)
+		/* 1 < ratio < 2 */
+		imbalance = 4*nr_pages*zone->nr_active / (zone->nr_inactive*2);
+	else
+		imbalance = nr_pages / 2;
+
+	imbalance++;
+
+	nr_refill_inact = atomic_read(&zone->refill_counter) + imbalance;
+	if (nr_refill_inact > SWAP_CLUSTER_MAX) {
+		refill_inactive_zone(zone, nr_refill_inact, ps);
+		nr_refill_inact = 0;
 	}
-	return shrink_cache(nr_pages, zone, gfp_mask,
-				max_scan, nr_mapped);
+	atomic_set(&zone->refill_counter, nr_refill_inact);
+
+	/*
+	 * Now pull pages from the inactive list
+	 */
+	max_scan = zone->nr_inactive >> priority;
+	if (max_scan < nr_pages * 2)
+		max_scan = nr_pages * 2;
+
+	return shrink_cache(nr_pages, zone, gfp_mask, max_scan, nr_scanned);
 }
 
 /*
@@ -856,8 +863,7 @@ shrink_caches(struct zone **zones, int p
 	for (i = 0; zones[i] != NULL; i++) {
 		int to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX);
 		struct zone *zone = zones[i];
-		int nr_mapped = 0;
-		int max_scan;
+		int nr_scanned;
 
 		if (zone->free_pages < zone->pages_high)
 			zone->temp_priority = priority;
@@ -865,16 +871,9 @@ shrink_caches(struct zone **zones, int p
 		if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
 
-		/*
-		 * If we cannot reclaim `nr_pages' pages by scanning twice
-		 * that many pages then fall back to the next zone.
-		 */
-		max_scan = zone->nr_inactive >> priority;
-		if (max_scan < to_reclaim * 2)
-			max_scan = to_reclaim * 2;
-		ret += shrink_zone(zone, max_scan, gfp_mask,
-				to_reclaim, &nr_mapped, ps);
-		*total_scanned += max_scan + nr_mapped;
+		ret += shrink_zone(zone, gfp_mask,
+				to_reclaim, &nr_scanned, ps, priority);
+		*total_scanned += nr_scanned;
 		if (ret >= nr_pages)
 			break;
 	}
@@ -920,6 +919,15 @@ int try_to_free_pages(struct zone **zone
 		get_page_state(&ps);
 		nr_reclaimed += shrink_caches(zones, priority, &total_scanned,
 						gfp_mask, nr_pages, &ps);
+
+		if (zones[0] - zones[0]->zone_pgdat->node_zones < ZONE_HIGHMEM) {
+			shrink_slab(total_scanned, gfp_mask);
+			if (reclaim_state) {
+				nr_reclaimed += reclaim_state->reclaimed_slab;
+				reclaim_state->reclaimed_slab = 0;
+			}
+		}
+
 		if (nr_reclaimed >= nr_pages) {
 			ret = 1;
 			goto out;
@@ -935,13 +943,6 @@ int try_to_free_pages(struct zone **zone
 
 		/* Take a nap, wait for some writeback to complete */
 		blk_congestion_wait(WRITE, HZ/10);
-		if (zones[0] - zones[0]->zone_pgdat->node_zones < ZONE_HIGHMEM) {
-			shrink_slab(total_scanned, gfp_mask);
-			if (reclaim_state) {
-				nr_reclaimed += reclaim_state->reclaimed_slab;
-				reclaim_state->reclaimed_slab = 0;
-			}
-		}
 	}
 	if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY))
 		out_of_memory();
@@ -989,8 +990,7 @@ static int balance_pgdat(pg_data_t *pgda
 
 		for (i = 0; i < pgdat->nr_zones; i++) {
 			struct zone *zone = pgdat->node_zones + i;
-			int nr_mapped = 0;
-			int max_scan;
+			int nr_scanned;
 			int to_reclaim;
 			int reclaimed;
 
@@ -1005,16 +1005,11 @@ static int balance_pgdat(pg_data_t *pgda
 					continue;
 			}
 			zone->temp_priority = priority;
-			max_scan = zone->nr_inactive >> priority;
-			if (max_scan < to_reclaim * 2)
-				max_scan = to_reclaim * 2;
-			if (max_scan < SWAP_CLUSTER_MAX)
-				max_scan = SWAP_CLUSTER_MAX;
-			reclaimed = shrink_zone(zone, max_scan, GFP_KERNEL,
-					to_reclaim, &nr_mapped, ps);
+			reclaimed = shrink_zone(zone, GFP_KERNEL,
+					to_reclaim, &nr_scanned, ps, priority);
 			if (i < ZONE_HIGHMEM) {
 				reclaim_state->reclaimed_slab = 0;
-				shrink_slab(max_scan + nr_mapped, GFP_KERNEL);
+				shrink_slab(nr_scanned, GFP_KERNEL);
 				reclaimed += reclaim_state->reclaimed_slab;
 			}
 			to_free -= reclaimed;

_

--------------000602050502010505010704--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
