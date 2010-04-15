Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8474F6B01FB
	for <linux-mm@kvack.org>; Thu, 15 Apr 2010 13:21:47 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 02/10] vmscan: move priority variable into scan_control
Date: Thu, 15 Apr 2010 18:21:35 +0100
Message-Id: <1271352103-2280-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1271352103-2280-1-git-send-email-mel@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Now very lots function in vmscan have `priority' argument. It consume
stack slightly. To move it on struct scan_control reduce stack.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |   83 ++++++++++++++++++++++++++--------------------------------
 1 files changed, 37 insertions(+), 46 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1db19f8..5c276f0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -77,6 +77,8 @@ struct scan_control {
 
 	int order;
 
+	int priority;
+
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
 
@@ -1123,7 +1125,7 @@ static int too_many_isolated(struct zone *zone, int file,
  */
 static unsigned long shrink_inactive_list(unsigned long max_scan,
 			struct zone *zone, struct scan_control *sc,
-			int priority, int file)
+			int file)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
@@ -1149,7 +1151,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 	 */
 	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
 		lumpy_reclaim = 1;
-	else if (sc->order && priority < DEF_PRIORITY - 2)
+	else if (sc->order && sc->priority < DEF_PRIORITY - 2)
 		lumpy_reclaim = 1;
 
 	pagevec_init(&pvec, 1);
@@ -1328,7 +1330,7 @@ static void move_active_pages_to_lru(struct zone *zone,
 }
 
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
-			struct scan_control *sc, int priority, int file)
+			struct scan_control *sc, int file)
 {
 	unsigned long nr_taken;
 	unsigned long pgscanned;
@@ -1491,17 +1493,17 @@ static int inactive_list_is_low(struct zone *zone, struct scan_control *sc,
 }
 
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
-	struct zone *zone, struct scan_control *sc, int priority)
+	struct zone *zone, struct scan_control *sc)
 {
 	int file = is_file_lru(lru);
 
 	if (is_active_lru(lru)) {
 		if (inactive_list_is_low(zone, sc, file))
-		    shrink_active_list(nr_to_scan, zone, sc, priority, file);
+		    shrink_active_list(nr_to_scan, zone, sc, file);
 		return 0;
 	}
 
-	return shrink_inactive_list(nr_to_scan, zone, sc, priority, file);
+	return shrink_inactive_list(nr_to_scan, zone, sc, file);
 }
 
 /*
@@ -1608,8 +1610,7 @@ static unsigned long nr_scan_try_batch(unsigned long nr_to_scan,
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static void shrink_zone(int priority, struct zone *zone,
-				struct scan_control *sc)
+static void shrink_zone(struct zone *zone, struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
@@ -1633,8 +1634,8 @@ static void shrink_zone(int priority, struct zone *zone,
 		unsigned long scan;
 
 		scan = zone_nr_lru_pages(zone, sc, l);
-		if (priority || noswap) {
-			scan >>= priority;
+		if (sc->priority || noswap) {
+			scan >>= sc->priority;
 			scan = (scan * percent[file]) / 100;
 		}
 		nr[l] = nr_scan_try_batch(scan,
@@ -1650,7 +1651,7 @@ static void shrink_zone(int priority, struct zone *zone,
 				nr[l] -= nr_to_scan;
 
 				nr_reclaimed += shrink_list(l, nr_to_scan,
-							    zone, sc, priority);
+							    zone, sc);
 			}
 		}
 		/*
@@ -1661,7 +1662,8 @@ static void shrink_zone(int priority, struct zone *zone,
 		 * with multiple processes reclaiming pages, the total
 		 * freeing target can get unreasonably large.
 		 */
-		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
+		if (nr_reclaimed >= nr_to_reclaim &&
+		    sc->priority < DEF_PRIORITY)
 			break;
 	}
 
@@ -1672,7 +1674,7 @@ static void shrink_zone(int priority, struct zone *zone,
 	 * rebalance the anon lru active/inactive ratio.
 	 */
 	if (inactive_anon_is_low(zone, sc) && nr_swap_pages > 0)
-		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
+		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);
 }
@@ -1693,8 +1695,7 @@ static void shrink_zone(int priority, struct zone *zone,
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static void shrink_zones(int priority, struct zonelist *zonelist,
-					struct scan_control *sc)
+static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 {
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	struct zoneref *z;
@@ -1712,7 +1713,8 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 		if (scanning_global_lru(sc)) {
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+			if (zone->all_unreclaimable &&
+			    sc->priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
 			sc->all_unreclaimable = 0;
 		} else
@@ -1722,7 +1724,7 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 			 */
 			sc->all_unreclaimable = 0;
 
-		shrink_zone(priority, zone, sc);
+		shrink_zone(zone, sc);
 	}
 }
 
@@ -1745,7 +1747,6 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 					struct scan_control *sc)
 {
-	int priority;
 	unsigned long ret = 0;
 	unsigned long total_scanned = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
@@ -1772,11 +1773,11 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		}
 	}
 
-	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
+	for (sc->priority = DEF_PRIORITY; sc->priority >= 0; sc->priority--) {
 		sc->nr_scanned = 0;
-		if (!priority)
+		if (!sc->priority)
 			disable_swap_token();
-		shrink_zones(priority, zonelist, sc);
+		shrink_zones(zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1809,23 +1810,14 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 		/* Take a nap, wait for some writeback to complete */
 		if (!sc->hibernation_mode && sc->nr_scanned &&
-		    priority < DEF_PRIORITY - 2)
+		    sc->priority < DEF_PRIORITY - 2)
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
 	/* top priority shrink_zones still had more to do? don't OOM, then */
 	if (!sc->all_unreclaimable && scanning_global_lru(sc))
 		ret = sc->nr_reclaimed;
-out:
-	/*
-	 * Now that we've scanned all the zones at this priority level, note
-	 * that level within the zone so that the next thread which performs
-	 * scanning of this zone will immediately start out at this priority
-	 * level.  This affects only the decision whether or not to bring
-	 * mapped pages onto the inactive list.
-	 */
-	if (priority < 0)
-		priority = 0;
 
+out:
 	if (scanning_global_lru(sc))
 		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
@@ -1885,7 +1877,8 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_zone(0, zone, &sc);
+	sc.priority = 0;
+	shrink_zone(zone, &sc);
 	return sc.nr_reclaimed;
 }
 
@@ -1965,7 +1958,6 @@ static int sleeping_prematurely(pg_data_t *pgdat, int order, long remaining)
 static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 {
 	int all_zones_ok;
-	int priority;
 	int i;
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
@@ -1989,13 +1981,13 @@ loop_again:
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
 
-	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
+	for (sc.priority = DEF_PRIORITY; sc.priority >= 0; sc.priority--) {
 		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 		unsigned long lru_pages = 0;
 		int has_under_min_watermark_zone = 0;
 
 		/* The swap token gets in the way of swapout... */
-		if (!priority)
+		if (!sc.priority)
 			disable_swap_token();
 
 		all_zones_ok = 1;
@@ -2010,7 +2002,7 @@ loop_again:
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+			if (zone->all_unreclaimable && sc.priority != DEF_PRIORITY)
 				continue;
 
 			/*
@@ -2019,7 +2011,7 @@ loop_again:
 			 */
 			if (inactive_anon_is_low(zone, &sc))
 				shrink_active_list(SWAP_CLUSTER_MAX, zone,
-							&sc, priority, 0);
+							&sc, 0);
 
 			if (!zone_watermark_ok(zone, order,
 					high_wmark_pages(zone), 0, 0)) {
@@ -2053,7 +2045,7 @@ loop_again:
 			if (!populated_zone(zone))
 				continue;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+			if (zone->all_unreclaimable && sc.priority != DEF_PRIORITY)
 				continue;
 
 			sc.nr_scanned = 0;
@@ -2072,7 +2064,7 @@ loop_again:
 			 */
 			if (!zone_watermark_ok(zone, order,
 					8*high_wmark_pages(zone), end_zone, 0))
-				shrink_zone(priority, zone, &sc);
+				shrink_zone(zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
@@ -2112,7 +2104,7 @@ loop_again:
 		 * OK, kswapd is getting into trouble.  Take a nap, then take
 		 * another pass across the zones.
 		 */
-		if (total_scanned && (priority < DEF_PRIORITY - 2)) {
+		if (total_scanned && (sc.priority < DEF_PRIORITY - 2)) {
 			if (has_under_min_watermark_zone)
 				count_vm_event(KSWAPD_SKIP_CONGESTION_WAIT);
 			else
@@ -2513,7 +2505,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	const unsigned long nr_pages = 1 << order;
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
-	int priority;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
@@ -2544,11 +2535,11 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 * Free memory by calling shrink zone with increasing
 		 * priorities until we have enough memory freed.
 		 */
-		priority = ZONE_RECLAIM_PRIORITY;
+		sc.priority = ZONE_RECLAIM_PRIORITY;
 		do {
-			shrink_zone(priority, zone, &sc);
-			priority--;
-		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
+			shrink_zone(zone, &sc);
+			sc.priority--;
+		} while (sc.priority >= 0 && sc.nr_reclaimed < nr_pages);
 	}
 
 	slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
