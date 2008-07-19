Message-Id: <20080719133159.833677595@jp.fujitsu.com>
References: <20080719132959.550229715@jp.fujitsu.com>
Date: Sat, 19 Jul 2008 22:30:01 +0900
From: kosaki.motohiro@jp.fujitsu.com
Subject: [PATCH 2/3] change return type of shrink_zone()
Content-Disposition: inline; filename=02-change-return-type-of-shrink-functions.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

changelog
========================================
  v7 -> v8
     o no change

  v5 -> v6
     o created


change function return type for following enhancement.
this patch have no behaver change.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/vmscan.c |   71 +++++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 44 insertions(+), 27 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -53,6 +53,9 @@ struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
 
+	/* number of reclaimed pages by this scanning */
+	unsigned long nr_reclaimed;
+
 	/* This context's GFP mask */
 	gfp_t gfp_mask;
 
@@ -1440,8 +1443,8 @@ static void get_scan_ratio(struct zone *
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static unsigned long shrink_zone(int priority, struct zone *zone,
-				struct scan_control *sc)
+static int shrink_zone(int priority, struct zone *zone,
+		       struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
@@ -1502,8 +1505,9 @@ static unsigned long shrink_zone(int pri
 	if (scan_global_lru(sc) && inactive_anon_is_low(zone))
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
+	sc->nr_reclaimed += nr_reclaimed;
 	throttle_vm_writeout(sc->gfp_mask);
-	return nr_reclaimed;
+	return 0;
 }
 
 /*
@@ -1517,18 +1521,23 @@ static unsigned long shrink_zone(int pri
  * b) The zones may be over pages_high but they must go *over* pages_high to
  *    satisfy the `incremental min' zone defense algorithm.
  *
- * Returns the number of reclaimed pages.
+ * @priority: reclaim priority
+ * @zonelist: list of shrinking zones
+ * @sc: scan control context
+ * @ret_reclaimed: the number of reclaimed pages.
+ *
+ * Returns zonzero if error happend.
  *
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
-					struct scan_control *sc)
+static int shrink_zones(int priority, struct zonelist *zonelist,
+			struct scan_control *sc)
 {
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
-	unsigned long nr_reclaimed = 0;
 	struct zoneref *z;
 	struct zone *zone;
+	int ret = 0;
 
 	sc->all_unreclaimable = 1;
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
@@ -1557,10 +1566,13 @@ static unsigned long shrink_zones(int pr
 							priority);
 		}
 
-		nr_reclaimed += shrink_zone(priority, zone, sc);
+		ret = shrink_zone(priority, zone, sc);
+		if (ret)
+			goto out;
 	}
 
-	return nr_reclaimed;
+out:
+	return ret;
 }
 
 /*
@@ -1585,12 +1597,12 @@ static unsigned long do_try_to_free_page
 	int priority;
 	unsigned long ret = 0;
 	unsigned long total_scanned = 0;
-	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
 	struct zoneref *z;
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
+	int err;
 
 	delayacct_freepages_start();
 
@@ -1613,7 +1625,12 @@ static unsigned long do_try_to_free_page
 		sc->nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
-		nr_reclaimed += shrink_zones(priority, zonelist, sc);
+		err = shrink_zones(priority, zonelist, sc);
+		if (err == -EAGAIN) {
+			ret = 1;
+			goto out;
+		}
+
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1621,13 +1638,14 @@ static unsigned long do_try_to_free_page
 		if (scan_global_lru(sc)) {
 			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
 			if (reclaim_state) {
-				nr_reclaimed += reclaim_state->reclaimed_slab;
+				sc->nr_reclaimed +=
+					reclaim_state->reclaimed_slab;
 				reclaim_state->reclaimed_slab = 0;
 			}
 		}
 		total_scanned += sc->nr_scanned;
-		if (nr_reclaimed >= sc->swap_cluster_max) {
-			ret = nr_reclaimed;
+		if (sc->nr_reclaimed >= sc->swap_cluster_max) {
+			ret = sc->nr_reclaimed;
 			goto out;
 		}
 
@@ -1650,7 +1668,7 @@ static unsigned long do_try_to_free_page
 	}
 	/* top priority shrink_caches still had more to do? don't OOM, then */
 	if (!sc->all_unreclaimable && scan_global_lru(sc))
-		ret = nr_reclaimed;
+		ret = sc->nr_reclaimed;
 out:
 	/*
 	 * Now that we've scanned all the zones at this priority level, note
@@ -1745,7 +1763,6 @@ static unsigned long balance_pgdat(pg_da
 	int priority;
 	int i;
 	unsigned long total_scanned;
-	unsigned long nr_reclaimed;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
@@ -1764,7 +1781,6 @@ static unsigned long balance_pgdat(pg_da
 
 loop_again:
 	total_scanned = 0;
-	nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
 
@@ -1830,6 +1846,7 @@ loop_again:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 			int nr_slab;
+			unsigned long write_threshold;
 
 			if (!populated_zone(zone))
 				continue;
@@ -1850,11 +1867,11 @@ loop_again:
 			 */
 			if (!zone_watermark_ok(zone, order, 8*zone->pages_high,
 						end_zone, 0))
-				nr_reclaimed += shrink_zone(priority, zone, &sc);
+				shrink_zone(priority, zone, &sc);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
-			nr_reclaimed += reclaim_state->reclaimed_slab;
+			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
 			total_scanned += sc.nr_scanned;
 			if (zone_is_all_unreclaimable(zone))
 				continue;
@@ -1867,8 +1884,9 @@ loop_again:
 			 * the reclaim ratio is low, start doing writepage
 			 * even in laptop mode
 			 */
+			write_threshold = sc.nr_reclaimed + sc.nr_reclaimed / 2;
 			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
-			    total_scanned > nr_reclaimed + nr_reclaimed / 2)
+			    total_scanned > write_threshold)
 				sc.may_writepage = 1;
 		}
 		if (all_zones_ok)
@@ -1886,7 +1904,7 @@ loop_again:
 		 * matches the direct reclaim path behaviour in terms of impact
 		 * on zone->*_priority.
 		 */
-		if (nr_reclaimed >= SWAP_CLUSTER_MAX)
+		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
 			break;
 	}
 out:
@@ -1908,7 +1926,7 @@ out:
 		goto loop_again;
 	}
 
-	return nr_reclaimed;
+	return sc.nr_reclaimed;
 }
 
 /*
@@ -2260,7 +2278,6 @@ static int __zone_reclaim(struct zone *z
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
 	int priority;
-	unsigned long nr_reclaimed = 0;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
@@ -2293,9 +2310,9 @@ static int __zone_reclaim(struct zone *z
 		priority = ZONE_RECLAIM_PRIORITY;
 		do {
 			note_zone_scanning_priority(zone, priority);
-			nr_reclaimed += shrink_zone(priority, zone, &sc);
+			shrink_zone(priority, zone, &sc);
 			priority--;
-		} while (priority >= 0 && nr_reclaimed < nr_pages);
+		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
 	}
 
 	slab_reclaimable = zone_page_state(zone, NR_SLAB_RECLAIMABLE);
@@ -2319,13 +2336,13 @@ static int __zone_reclaim(struct zone *z
 		 * Update nr_reclaimed by the number of slab pages we
 		 * reclaimed from this zone.
 		 */
-		nr_reclaimed += slab_reclaimable -
+		sc.nr_reclaimed += slab_reclaimable -
 			zone_page_state(zone, NR_SLAB_RECLAIMABLE);
 	}
 
 	p->reclaim_state = NULL;
 	current->flags &= ~(PF_MEMALLOC | PF_SWAPWRITE);
-	return nr_reclaimed >= nr_pages;
+	return sc.nr_reclaimed >= nr_pages;
 }
 
 int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
