Date: Mon, 24 Nov 2008 14:50:57 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] vmscan: bail out of page reclaim after swap_cluster_max
 pages
Message-ID: <20081124145057.4211bd46@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mel@csn.ul.ie, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Sometimes the VM spends the first few priority rounds rotating back
referenced pages and submitting IO.  Once we get to a lower priority,
sometimes the VM ends up freeing way too many pages.

The fix is relatively simple: in shrink_zone() we can check how many
pages we have already freed, direct reclaim tasks break out of the
scanning loop if they have already freed enough pages and have reached
a lower priority level.

However, in order to do this we do need to know how many pages we already
freed, so move nr_reclaimed into scan_control.

Signed-off-by: Rik van Riel <riel@redhat.com>
---
Kosaki, this should address the zone scanning pressure issue.

Nick, this includes the cleanups suggested by you.

 mm/vmscan.c |   62 +++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 33 insertions(+), 29 deletions(-)

Index: linux-2.6.28-rc5/mm/vmscan.c
===================================================================
--- linux-2.6.28-rc5.orig/mm/vmscan.c	2008-11-17 15:22:22.000000000 -0500
+++ linux-2.6.28-rc5/mm/vmscan.c	2008-11-24 14:47:17.000000000 -0500
@@ -52,6 +52,9 @@ struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
 
+	/* Number of pages freed so far during a call to shrink_zones() */
+	unsigned long nr_reclaimed;
+
 	/* This context's GFP mask */
 	gfp_t gfp_mask;
 
@@ -1405,12 +1408,11 @@ static void get_scan_ratio(struct zone *
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static unsigned long shrink_zone(int priority, struct zone *zone,
+static void shrink_zone(int priority, struct zone *zone,
 				struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
-	unsigned long nr_reclaimed = 0;
 	unsigned long percent[2];	/* anon @ 0; file @ 1 */
 	enum lru_list l;
 
@@ -1451,10 +1453,21 @@ static unsigned long shrink_zone(int pri
 					(unsigned long)sc->swap_cluster_max);
 				nr[l] -= nr_to_scan;
 
-				nr_reclaimed += shrink_list(l, nr_to_scan,
+				sc->nr_reclaimed += shrink_list(l, nr_to_scan,
 							zone, sc, priority);
 			}
 		}
+		/*
+		 * On large memory systems, scan >> priority can become
+		 * really large. This is fine for the starting priority;
+		 * we want to put equal scanning pressure on each zone.
+		 * However, if the VM has a harder time of freeing pages,
+		 * with multiple processes reclaiming pages, the total
+		 * freeing target can get unreasonably large.
+		 */
+		if (sc->nr_reclaimed > sc->swap_cluster_max &&
+			sc->priority < DEF_PRIORITY && !current_is_kswapd())
+			break;
 	}
 
 	/*
@@ -1467,7 +1480,6 @@ static unsigned long shrink_zone(int pri
 		shrink_active_list(SWAP_CLUSTER_MAX, zone, sc, priority, 0);
 
 	throttle_vm_writeout(sc->gfp_mask);
-	return nr_reclaimed;
 }
 
 /*
@@ -1481,16 +1493,13 @@ static unsigned long shrink_zone(int pri
  * b) The zones may be over pages_high but they must go *over* pages_high to
  *    satisfy the `incremental min' zone defense algorithm.
  *
- * Returns the number of reclaimed pages.
- *
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
+static void shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
 	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
-	unsigned long nr_reclaimed = 0;
 	struct zoneref *z;
 	struct zone *zone;
 
@@ -1521,10 +1530,8 @@ static unsigned long shrink_zones(int pr
 							priority);
 		}
 
-		nr_reclaimed += shrink_zone(priority, zone, sc);
+		shrink_zone(priority, zone, sc);
 	}
-
-	return nr_reclaimed;
 }
 
 /*
@@ -1549,7 +1556,6 @@ static unsigned long do_try_to_free_page
 	int priority;
 	unsigned long ret = 0;
 	unsigned long total_scanned = 0;
-	unsigned long nr_reclaimed = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	unsigned long lru_pages = 0;
 	struct zoneref *z;
@@ -1577,7 +1583,7 @@ static unsigned long do_try_to_free_page
 		sc->nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
-		nr_reclaimed += shrink_zones(priority, zonelist, sc);
+		shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1585,13 +1591,13 @@ static unsigned long do_try_to_free_page
 		if (scan_global_lru(sc)) {
 			shrink_slab(sc->nr_scanned, sc->gfp_mask, lru_pages);
 			if (reclaim_state) {
-				nr_reclaimed += reclaim_state->reclaimed_slab;
+				sc->nr_reclaimed += reclaim_state->reclaimed_slab;
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
 
@@ -1614,7 +1620,7 @@ static unsigned long do_try_to_free_page
 	}
 	/* top priority shrink_zones still had more to do? don't OOM, then */
 	if (!sc->all_unreclaimable && scan_global_lru(sc))
-		ret = nr_reclaimed;
+		ret = sc->nr_reclaimed;
 out:
 	/*
 	 * Now that we've scanned all the zones at this priority level, note
@@ -1709,7 +1715,6 @@ static unsigned long balance_pgdat(pg_da
 	int priority;
 	int i;
 	unsigned long total_scanned;
-	unsigned long nr_reclaimed;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
@@ -1728,7 +1733,7 @@ static unsigned long balance_pgdat(pg_da
 
 loop_again:
 	total_scanned = 0;
-	nr_reclaimed = 0;
+	sc.nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
 
@@ -1814,11 +1819,11 @@ loop_again:
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
@@ -1832,7 +1837,7 @@ loop_again:
 			 * even in laptop mode
 			 */
 			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
-			    total_scanned > nr_reclaimed + nr_reclaimed / 2)
+			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
 				sc.may_writepage = 1;
 		}
 		if (all_zones_ok)
@@ -1850,7 +1855,7 @@ loop_again:
 		 * matches the direct reclaim path behaviour in terms of impact
 		 * on zone->*_priority.
 		 */
-		if (nr_reclaimed >= SWAP_CLUSTER_MAX)
+		if (sc.nr_reclaimed >= SWAP_CLUSTER_MAX)
 			break;
 	}
 out:
@@ -1872,7 +1877,7 @@ out:
 		goto loop_again;
 	}
 
-	return nr_reclaimed;
+	return sc.nr_reclaimed;
 }
 
 /*
@@ -2224,7 +2229,6 @@ static int __zone_reclaim(struct zone *z
 	struct task_struct *p = current;
 	struct reclaim_state reclaim_state;
 	int priority;
-	unsigned long nr_reclaimed = 0;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
@@ -2257,9 +2261,9 @@ static int __zone_reclaim(struct zone *z
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
@@ -2283,13 +2287,13 @@ static int __zone_reclaim(struct zone *z
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
