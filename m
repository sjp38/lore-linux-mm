Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 967EA6B004D
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 03:53:57 -0400 (EDT)
Received: by lagz14 with SMTP id z14so991336lag.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 00:53:55 -0700 (PDT)
Subject: [PATCH 01/12] mm/vmscan: store "priority" in struct scan_control
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 26 Apr 2012 11:53:51 +0400
Message-ID: <20120426075351.18961.20221.stgit@zurg>
In-Reply-To: <20120426074632.18961.17803.stgit@zurg>
References: <20120426074632.18961.17803.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

In memory reclaimer's code some functions has too many arguments, "priority" is
one of them. It can be stored on "sc", we construct them on the same level.
Instead of open coded loop we set initial sc.priority, and do_try_to_free_pages()
decreases it down to zero.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

---

This patch unrelated to this patchset, but intersects by context with other patches.

add/remove: 1/1 grow/shrink: 2/7 up/down: 856/-1045 (-189)
function                                     old     new   delta
shrink_active_list                             -     824    +824
try_to_free_pages                            279     295     +16
try_to_free_mem_cgroup_pages                 295     311     +16
do_try_to_free_pages                        1255    1252      -3
shrink_zone                                  152     147      -5
static.shrink_page_list                     2309    2293     -16
shrink_inactive_list                        1001     985     -16
zone_reclaim                                 639     615     -24
balance_pgdat                               1909    1856     -53
shrink_mem_cgroup_zone                      1485    1381    -104
static.shrink_active_list                    824       -    -824
---
 mm/vmscan.c |  117 +++++++++++++++++++++++++++++++----------------------------
 1 file changed, 61 insertions(+), 56 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7bc7b8b..d81750c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -78,6 +78,9 @@ struct scan_control {
 
 	int order;
 
+	/* Scan (total_size >> priority) pages at once */
+	int priority;
+
 	/*
 	 * The memory cgroup that hit its limit and as a result is the
 	 * primary target of this reclaim invocation.
@@ -687,7 +690,6 @@ static enum page_references page_check_references(struct page *page,
 static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct mem_cgroup_zone *mz,
 				      struct scan_control *sc,
-				      int priority,
 				      unsigned long *ret_nr_dirty,
 				      unsigned long *ret_nr_writeback)
 {
@@ -790,7 +792,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			 * unless under significant pressure.
 			 */
 			if (page_is_file_cache(page) &&
-					(!current_is_kswapd() || priority >= DEF_PRIORITY - 2)) {
+					(!current_is_kswapd() ||
+					 sc->priority >= DEF_PRIORITY - 2)) {
 				/*
 				 * Immediately reclaim when written back.
 				 * Similar in principal to deactivate_page()
@@ -1257,7 +1260,7 @@ update_isolated_counts(struct mem_cgroup_zone *mz,
  */
 static noinline_for_stack unsigned long
 shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
-		     struct scan_control *sc, int priority, enum lru_list lru)
+		     struct scan_control *sc, enum lru_list lru)
 {
 	LIST_HEAD(page_list);
 	unsigned long nr_scanned;
@@ -1307,7 +1310,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 
 	update_isolated_counts(mz, &page_list, &nr_anon, &nr_file);
 
-	nr_reclaimed = shrink_page_list(&page_list, mz, sc, priority,
+	nr_reclaimed = shrink_page_list(&page_list, mz, sc,
 						&nr_dirty, &nr_writeback);
 
 	spin_lock_irq(&zone->lru_lock);
@@ -1351,13 +1354,14 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	 * DEF_PRIORITY-6 For SWAP_CLUSTER_MAX isolated pages, throttle if any
 	 *                     isolated page is PageWriteback
 	 */
-	if (nr_writeback && nr_writeback >= (nr_taken >> (DEF_PRIORITY-priority)))
+	if (nr_writeback && nr_writeback >=
+			(nr_taken >> (DEF_PRIORITY - sc->priority)))
 		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
 
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),
 		nr_scanned, nr_reclaimed,
-		priority,
+		sc->priority,
 		trace_shrink_flags(file));
 	return nr_reclaimed;
 }
@@ -1421,7 +1425,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 static void shrink_active_list(unsigned long nr_to_scan,
 			       struct mem_cgroup_zone *mz,
 			       struct scan_control *sc,
-			       int priority, enum lru_list lru)
+			       enum lru_list lru)
 {
 	unsigned long nr_taken;
 	unsigned long nr_scanned;
@@ -1604,17 +1608,17 @@ static int inactive_list_is_low(struct mem_cgroup_zone *mz, int file)
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 				 struct mem_cgroup_zone *mz,
-				 struct scan_control *sc, int priority)
+				 struct scan_control *sc)
 {
 	int file = is_file_lru(lru);
 
 	if (is_active_lru(lru)) {
 		if (inactive_list_is_low(mz, file))
-			shrink_active_list(nr_to_scan, mz, sc, priority, lru);
+			shrink_active_list(nr_to_scan, mz, sc, lru);
 		return 0;
 	}
 
-	return shrink_inactive_list(nr_to_scan, mz, sc, priority, lru);
+	return shrink_inactive_list(nr_to_scan, mz, sc, lru);
 }
 
 static int vmscan_swappiness(struct scan_control *sc)
@@ -1633,7 +1637,7 @@ static int vmscan_swappiness(struct scan_control *sc)
  * nr[0] = anon pages to scan; nr[1] = file pages to scan
  */
 static void get_scan_count(struct mem_cgroup_zone *mz, struct scan_control *sc,
-			   unsigned long *nr, int priority)
+			   unsigned long *nr)
 {
 	unsigned long anon, file, free;
 	unsigned long anon_prio, file_prio;
@@ -1735,8 +1739,8 @@ out:
 		unsigned long scan;
 
 		scan = zone_nr_lru_pages(mz, lru);
-		if (priority || noswap) {
-			scan >>= priority;
+		if (sc->priority || noswap) {
+			scan >>= sc->priority;
 			if (!scan && force_scan)
 				scan = SWAP_CLUSTER_MAX;
 			scan = div64_u64(scan * fraction[file], denominator);
@@ -1746,11 +1750,11 @@ out:
 }
 
 /* Use reclaim/compaction for costly allocs or under memory pressure */
-static bool in_reclaim_compaction(int priority, struct scan_control *sc)
+static bool in_reclaim_compaction(struct scan_control *sc)
 {
 	if (COMPACTION_BUILD && sc->order &&
 			(sc->order > PAGE_ALLOC_COSTLY_ORDER ||
-			 priority < DEF_PRIORITY - 2))
+			 sc->priority < DEF_PRIORITY - 2))
 		return true;
 
 	return false;
@@ -1766,14 +1770,13 @@ static bool in_reclaim_compaction(int priority, struct scan_control *sc)
 static inline bool should_continue_reclaim(struct mem_cgroup_zone *mz,
 					unsigned long nr_reclaimed,
 					unsigned long nr_scanned,
-					int priority,
 					struct scan_control *sc)
 {
 	unsigned long pages_for_compaction;
 	unsigned long inactive_lru_pages;
 
 	/* If not in reclaim/compaction mode, stop */
-	if (!in_reclaim_compaction(priority, sc))
+	if (!in_reclaim_compaction(sc))
 		return false;
 
 	/* Consider stopping depending on scan and reclaim activity */
@@ -1824,7 +1827,7 @@ static inline bool should_continue_reclaim(struct mem_cgroup_zone *mz,
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static void shrink_mem_cgroup_zone(int priority, struct mem_cgroup_zone *mz,
+static void shrink_mem_cgroup_zone(struct mem_cgroup_zone *mz,
 				   struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
@@ -1837,7 +1840,7 @@ static void shrink_mem_cgroup_zone(int priority, struct mem_cgroup_zone *mz,
 restart:
 	nr_reclaimed = 0;
 	nr_scanned = sc->nr_scanned;
-	get_scan_count(mz, sc, nr, priority);
+	get_scan_count(mz, sc, nr);
 
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
@@ -1849,7 +1852,7 @@ restart:
 				nr[lru] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(lru, nr_to_scan,
-							    mz, sc, priority);
+							    mz, sc);
 			}
 		}
 		/*
@@ -1860,7 +1863,8 @@ restart:
 		 * with multiple processes reclaiming pages, the total
 		 * freeing target can get unreasonably large.
 		 */
-		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
+		if (nr_reclaimed >= nr_to_reclaim &&
+		    sc->priority < DEF_PRIORITY)
 			break;
 	}
 	blk_finish_plug(&plug);
@@ -1872,24 +1876,22 @@ restart:
 	 */
 	if (inactive_anon_is_low(mz))
 		shrink_active_list(SWAP_CLUSTER_MAX, mz,
-				   sc, priority, LRU_ACTIVE_ANON);
+				   sc, LRU_ACTIVE_ANON);
 
 	/* reclaim/compaction might need reclaim to continue */
 	if (should_continue_reclaim(mz, nr_reclaimed,
-					sc->nr_scanned - nr_scanned,
-					priority, sc))
+				    sc->nr_scanned - nr_scanned, sc))
 		goto restart;
 
 	throttle_vm_writeout(sc->gfp_mask);
 }
 
-static void shrink_zone(int priority, struct zone *zone,
-			struct scan_control *sc)
+static void shrink_zone(struct zone *zone, struct scan_control *sc)
 {
 	struct mem_cgroup *root = sc->target_mem_cgroup;
 	struct mem_cgroup_reclaim_cookie reclaim = {
 		.zone = zone,
-		.priority = priority,
+		.priority = sc->priority,
 	};
 	struct mem_cgroup *memcg;
 
@@ -1900,7 +1902,7 @@ static void shrink_zone(int priority, struct zone *zone,
 			.zone = zone,
 		};
 
-		shrink_mem_cgroup_zone(priority, &mz, sc);
+		shrink_mem_cgroup_zone(&mz, sc);
 		/*
 		 * Limit reclaim has historically picked one memcg and
 		 * scanned it with decreasing priority levels until
@@ -1976,8 +1978,7 @@ static inline bool compaction_ready(struct zone *zone, struct scan_control *sc)
  * the caller that it should consider retrying the allocation instead of
  * further reclaim.
  */
-static bool shrink_zones(int priority, struct zonelist *zonelist,
-					struct scan_control *sc)
+static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
@@ -2004,7 +2005,8 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 		if (global_reclaim(sc)) {
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+			if (zone->all_unreclaimable &&
+					sc->priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
 			if (COMPACTION_BUILD) {
 				/*
@@ -2036,7 +2038,7 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 			/* need some check for avoid more shrink_zone() */
 		}
 
-		shrink_zone(priority, zone, sc);
+		shrink_zone(zone, sc);
 	}
 
 	return aborted_reclaim;
@@ -2087,7 +2089,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 					struct scan_control *sc,
 					struct shrink_control *shrink)
 {
-	int priority;
 	unsigned long total_scanned = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct zoneref *z;
@@ -2100,9 +2101,9 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	if (global_reclaim(sc))
 		count_vm_event(ALLOCSTALL);
 
-	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
+	do {
 		sc->nr_scanned = 0;
-		aborted_reclaim = shrink_zones(priority, zonelist, sc);
+		aborted_reclaim = shrink_zones(zonelist, sc);
 
 		/*
 		 * Don't shrink slabs when reclaiming memory from
@@ -2144,7 +2145,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 		/* Take a nap, wait for some writeback to complete */
 		if (!sc->hibernation_mode && sc->nr_scanned &&
-		    priority < DEF_PRIORITY - 2) {
+		    sc->priority < DEF_PRIORITY - 2) {
 			struct zone *preferred_zone;
 
 			first_zones_zonelist(zonelist, gfp_zone(sc->gfp_mask),
@@ -2152,7 +2153,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 						&preferred_zone);
 			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/10);
 		}
-	}
+	} while (--sc->priority >= 0);
 
 out:
 	delayacct_freepages_end();
@@ -2190,6 +2191,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.may_unmap = 1,
 		.may_swap = 1,
 		.order = order,
+		.priority = DEF_PRIORITY,
 		.target_mem_cgroup = NULL,
 		.nodemask = nodemask,
 	};
@@ -2222,6 +2224,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.order = 0,
+		.priority = 0,
 		.target_mem_cgroup = memcg,
 	};
 	struct mem_cgroup_zone mz = {
@@ -2232,7 +2235,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
-	trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
+	trace_mm_vmscan_memcg_softlimit_reclaim_begin(sc.order,
 						      sc.may_writepage,
 						      sc.gfp_mask);
 
@@ -2243,7 +2246,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_mem_cgroup_zone(0, &mz, &sc);
+	shrink_mem_cgroup_zone(&mz, &sc);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
@@ -2264,6 +2267,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 		.may_swap = !noswap,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
 		.order = 0,
+		.priority = DEF_PRIORITY,
 		.target_mem_cgroup = memcg,
 		.nodemask = NULL, /* we don't care the placement */
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
@@ -2294,8 +2298,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 }
 #endif
 
-static void age_active_anon(struct zone *zone, struct scan_control *sc,
-			    int priority)
+static void age_active_anon(struct zone *zone, struct scan_control *sc)
 {
 	struct mem_cgroup *memcg;
 
@@ -2311,7 +2314,7 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc,
 
 		if (inactive_anon_is_low(&mz))
 			shrink_active_list(SWAP_CLUSTER_MAX, &mz,
-					   sc, priority, LRU_ACTIVE_ANON);
+					   sc, LRU_ACTIVE_ANON);
 
 		memcg = mem_cgroup_iter(NULL, memcg, NULL);
 	} while (memcg);
@@ -2420,7 +2423,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 {
 	int all_zones_ok;
 	unsigned long balanced;
-	int priority;
 	int i;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
@@ -2444,11 +2446,12 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	};
 loop_again:
 	total_scanned = 0;
+	sc.priority = DEF_PRIORITY;
 	sc.nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
 
-	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
+	do {
 		unsigned long lru_pages = 0;
 		int has_under_min_watermark_zone = 0;
 
@@ -2465,14 +2468,15 @@ loop_again:
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+			if (zone->all_unreclaimable &&
+			    sc.priority != DEF_PRIORITY)
 				continue;
 
 			/*
 			 * Do some background aging of the anon list, to give
 			 * pages a chance to be referenced before reclaiming.
 			 */
-			age_active_anon(zone, &sc, priority);
+			age_active_anon(zone, &sc);
 
 			/*
 			 * If the number of buffer_heads in the machine
@@ -2520,7 +2524,8 @@ loop_again:
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+			if (zone->all_unreclaimable &&
+			    sc.priority != DEF_PRIORITY)
 				continue;
 
 			sc.nr_scanned = 0;
@@ -2564,7 +2569,7 @@ loop_again:
 				    !zone_watermark_ok_safe(zone, testorder,
 					high_wmark_pages(zone) + balance_gap,
 					end_zone, 0)) {
-				shrink_zone(priority, zone, &sc);
+				shrink_zone(zone, &sc);
 
 				reclaim_state->reclaimed_slab = 0;
 				nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
@@ -2621,7 +2626,7 @@ loop_again:
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
 		 */
-		if (total_scanned && (priority < DEF_PRIORITY - 2)) {
+		if (total_scanned && (sc.priority < DEF_PRIORITY - 2)) {
 			if (has_under_min_watermark_zone)
 				count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
 			else
@@ -2636,7 +2641,7 @@ loop_again:
 		 */
 		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
 			break;
-	}
+	} while (--sc.priority >= 0);
 out:
 
 	/*
@@ -2686,7 +2691,8 @@ out:
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+			if (zone->all_unreclaimable &&
+			    sc.priority != DEF_PRIORITY)
 				continue;
 
 			/* Would compaction fail due to lack of free memory? */
@@ -2953,6 +2959,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 		.nr_to_reclaim = nr_to_reclaim,
 		.hibernation_mode = 1,
 		.order = 0,
+		.priority = DEF_PRIORITY,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -3130,7 +3137,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
-	int priority;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
@@ -3139,6 +3145,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 				       SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
 		.order = order,
+		.priority = ZONE_RECLAIM_PRIORITY,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -3161,11 +3168,9 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * Free memory by calling shrink zone with increasing
 		 * priorities until we have enough memory freed.
 		 */
-		priority = ZONE_RECLAIM_PRIORITY;
 		do {
-			shrink_zone(priority, zone, &sc);
-			priority--;
-		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
+			shrink_zone(zone, &sc);
+		} while (sc.nr_reclaimed < nr_pages && --sc.priority >= 0);
 	}
 
 	nr_slab_pages0 = zone_page_state(zone, NR_SLAB_RECLAIMABLE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
