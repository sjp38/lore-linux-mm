Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7FF6B0074
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:56:54 -0400 (EDT)
Received: by lbcue7 with SMTP id ue7so81314346lbc.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:56:53 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t11si5347088wju.28.2015.06.08.06.56.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:52 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/25] mm, vmscan: Make kswapd think of reclaim in terms of nodes
Date: Mon,  8 Jun 2015 14:56:13 +0100
Message-Id: <1433771791-30567-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Patch "mm: vmscan: Begin reclaiming pages on a per-node basis" was
the start of thinking of reclaim in terms of nodes but kswapd is still
very zone-centric. This patch gets rid of many of the node-based versus
zone-based decisions.

o A node is considered balanced when any eligible lower zone is balanced.
  This eliminates one class of age-inversion problem because we avoid
  reclaiming a newer page just because it's in the wrong zone
o pgdat_balanced disappears because we now only care about one zone being
  balanced.
o Some anomalies related to writeback and congestion tracking being based on
  zones disappear.
o kswapd no longer has to take care to reclaim zones in the reverse order
  that the page allocator uses.
o Most importantly of all, reclaim from node 0 which often has multiple
  zones will have similar aging and reclaiming characteristics as every
  other node.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c | 264 ++++++++++++++++++++----------------------------------------
 1 file changed, 87 insertions(+), 177 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 975c315f1bf5..4d7ddaf4f2f4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2900,7 +2900,8 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 }
 #endif
 
-static void age_active_anon(struct zone *zone, struct scan_control *sc)
+static void age_active_anon(struct pglist_data *pgdat,
+				struct zone *zone, struct scan_control *sc)
 {
 	struct mem_cgroup *memcg;
 
@@ -2934,65 +2935,6 @@ static bool zone_balanced(struct zone *zone, int order,
 }
 
 /*
- * pgdat_balanced() is used when checking if a node is balanced.
- *
- * For order-0, all zones must be balanced!
- *
- * For high-order allocations only zones that meet watermarks and are in a
- * zone allowed by the callers classzone_idx are added to balanced_pages. The
- * total of balanced pages must be at least 25% of the zones allowed by
- * classzone_idx for the node to be considered balanced. Forcing all zones to
- * be balanced for high orders can cause excessive reclaim when there are
- * imbalanced zones.
- * The choice of 25% is due to
- *   o a 16M DMA zone that is balanced will not balance a zone on any
- *     reasonable sized machine
- *   o On all other machines, the top zone must be at least a reasonable
- *     percentage of the middle zones. For example, on 32-bit x86, highmem
- *     would need to be at least 256M for it to be balance a whole node.
- *     Similarly, on x86-64 the Normal zone would need to be at least 1G
- *     to balance a node on its own. These seemed like reasonable ratios.
- */
-static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
-{
-	unsigned long managed_pages = 0;
-	unsigned long balanced_pages = 0;
-	int i;
-
-	/* Check the watermark levels */
-	for (i = 0; i <= classzone_idx; i++) {
-		struct zone *zone = pgdat->node_zones + i;
-
-		if (!populated_zone(zone))
-			continue;
-
-		managed_pages += zone->managed_pages;
-
-		/*
-		 * A special case here:
-		 *
-		 * balance_pgdat() skips over all_unreclaimable after
-		 * DEF_PRIORITY. Effectively, it considers them balanced so
-		 * they must be considered balanced here as well!
-		 */
-		if (!pgdat_reclaimable(zone->zone_pgdat)) {
-			balanced_pages += zone->managed_pages;
-			continue;
-		}
-
-		if (zone_balanced(zone, order, 0, i))
-			balanced_pages += zone->managed_pages;
-		else if (!order)
-			return false;
-	}
-
-	if (order)
-		return balanced_pages >= (managed_pages >> 2);
-	else
-		return true;
-}
-
-/*
  * Prepare kswapd for sleeping. This verifies that there are no processes
  * waiting in throttle_direct_reclaim() and that watermarks have been met.
  *
@@ -3001,6 +2943,8 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 					int classzone_idx)
 {
+	int i;
+
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
 		return false;
@@ -3021,78 +2965,69 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 	if (waitqueue_active(&pgdat->pfmemalloc_wait))
 		wake_up_all(&pgdat->pfmemalloc_wait);
 
-	return pgdat_balanced(pgdat, order, classzone_idx);
+	for (i = 0; i <= classzone_idx; i++) {
+		struct zone *zone = pgdat->node_zones + i;
+
+		if (zone_balanced(zone, order, 0, classzone_idx))
+			return true;
+	}
+
+	return false;
 }
 
 /*
- * kswapd shrinks the zone by the number of pages required to reach
- * the high watermark.
+ * kswapd shrinks a node of pages that are at or below the highest usable
+ * zone that is currently unbalanced.
  *
  * Returns true if kswapd scanned at least the requested number of pages to
  * reclaim or if the lack of progress was due to pages under writeback.
  * This is used to determine if the scanning priority needs to be raised.
  */
-static bool kswapd_shrink_zone(struct zone *zone,
-			       int classzone_idx,
-			       struct scan_control *sc,
+static bool kswapd_shrink_node(pg_data_t *pgdat,
+			       int end_zone, struct scan_control *sc,
 			       unsigned long *nr_attempted)
 {
-	int testorder = sc->order;
-	unsigned long balance_gap;
-	bool lowmem_pressure;
-	struct pglist_data *pgdat = zone->zone_pgdat;
+	struct zone *zone;
+	unsigned long nr_to_reclaim = 0;
+	int z;
 
-	/* Reclaim above the high watermark. */
-	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
+	/* Aim to reclaim above all the zone high watermarks */
+	for (z = 0; z <= end_zone; z++) {
+		zone = pgdat->node_zones + end_zone;
+		nr_to_reclaim += high_wmark_pages(zone);
 
-	/*
-	 * Kswapd reclaims only single pages with compaction enabled. Trying
-	 * too hard to reclaim until contiguous free pages have become
-	 * available can hurt performance by evicting too much useful data
-	 * from memory. Do not reclaim more than needed for compaction.
-	 */
-	if (IS_ENABLED(CONFIG_COMPACTION) && sc->order &&
-			compaction_suitable(zone, sc->order, 0, classzone_idx)
+		/*
+		 * Kswapd reclaims only single pages with compaction enabled.
+		 * Trying too hard to reclaim until contiguous free pages have
+		 * become available can hurt performance by evicting too much
+		 * useful data from memory. Do not reclaim more than needed
+		 * for compaction.
+		 */
+		if (IS_ENABLED(CONFIG_COMPACTION) && sc->order &&
+				compaction_suitable(zone, sc->order, 0, end_zone)
 							!= COMPACT_SKIPPED)
-		testorder = 0;
-
-	/*
-	 * We put equal pressure on every zone, unless one zone has way too
-	 * many pages free already. The "too many pages" is defined as the
-	 * high wmark plus a "gap" where the gap is either the low
-	 * watermark or 1% of the zone, whichever is smaller.
-	 */
-	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
-			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
+			sc->order = 0;
+	}
+	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, nr_to_reclaim);
 
 	/*
-	 * If there is no low memory pressure or the zone is balanced then no
-	 * reclaim is necessary
+	 * Historically care was taken to put equal pressure on all zones but
+	 * now pressure is applied based on node LRU order.
 	 */
-	lowmem_pressure = (buffer_heads_over_limit && is_highmem(zone));
-	if (!lowmem_pressure && zone_balanced(zone, testorder,
-						balance_gap, classzone_idx))
-		return true;
-
-	shrink_node(zone->zone_pgdat, sc, zone_idx(zone), classzone_idx);
+	shrink_node(zone->zone_pgdat, sc, end_zone, end_zone);
 
 	/* Account for the number of pages attempted to reclaim */
 	*nr_attempted += sc->nr_to_reclaim;
 
-	/* TODO: ANOMALY */
-	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
-
 	/*
-	 * If a zone reaches its high watermark, consider it to be no longer
-	 * congested. It's possible there are dirty pages backed by congested
-	 * BDIs but as pressure is relieved, speculatively avoid congestion
-	 * waits.
+	 * Fragmentation may mean that the system cannot be rebalanced for
+	 * high-order allocations. If twice the allocation size has been
+	 * reclaimed then recheck watermarks only at order-0 to prevent
+	 * excessive reclaim. Assume that a process requested a high-order
+	 * can direct reclaim/compact.
 	 */
-	if (pgdat_reclaimable(zone->zone_pgdat) &&
-	    zone_balanced(zone, testorder, 0, classzone_idx)) {
-		clear_bit(PGDAT_CONGESTED, &pgdat->flags);
-		clear_bit(PGDAT_DIRTY, &pgdat->flags);
-	}
+	if (sc->order && sc->nr_reclaimed >= 2UL << sc->order)
+		sc->order = 0;
 
 	return sc->nr_scanned >= sc->nr_to_reclaim;
 }
@@ -3122,9 +3057,10 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 							int *classzone_idx)
 {
 	int i;
-	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
+	int end_zone = MAX_NR_ZONES - 1;
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
+	struct zone *zone;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.order = order,
@@ -3142,23 +3078,16 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 
 		sc.nr_reclaimed = 0;
 
+		/* Allow writeout later if the pgdat appears unreclaimable */
+		if (!pgdat_reclaimable(pgdat))
+			sc.priority = min(sc.priority, DEF_PRIORITY - 3);
+
 		/* Scan from the highest requested zone to dma */
 		for (i = *classzone_idx; i >= 0; i--) {
-			struct zone *zone = pgdat->node_zones + i;
-
+			zone = pgdat->node_zones + i;
 			if (!populated_zone(zone))
 				continue;
 
-			if (sc.priority != DEF_PRIORITY &&
-			    !pgdat_reclaimable(zone->zone_pgdat))
-				continue;
-
-			/*
-			 * Do some background aging of the anon list, to give
-			 * pages a chance to be referenced before reclaiming.
-			 */
-			age_active_anon(zone, &sc);
-
 			/*
 			 * If the number of buffer_heads in the machine
 			 * exceeds the maximum allowed level and this node
@@ -3175,10 +3104,8 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				break;
 			} else {
 				/*
-				 * If balanced, clear the dirty and congested
-				 * flags
-				 *
-				 * TODO: ANOMALY
+				 * If any eligible zone is balanced then the
+				 * node is not considered congested or dirty.
 				 */
 				clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
 				clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);
@@ -3202,51 +3129,32 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			goto out;
 
 		/*
+		 * Do some background aging of the anon list, to give
+		 * pages a chance to be referenced before reclaiming.
+		 */
+		age_active_anon(pgdat, &pgdat->node_zones[end_zone], &sc);
+
+		/*
 		 * If we're getting trouble reclaiming, start doing writepage
 		 * even in laptop mode.
 		 */
 		if (sc.priority < DEF_PRIORITY - 2)
 			sc.may_writepage = 1;
 
+		/* Call soft limit reclaim before calling shrink_node. */
+		sc.nr_scanned = 0;
+		nr_soft_scanned = 0;
+		nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone, order,
+						sc.gfp_mask, &nr_soft_scanned);
+		sc.nr_reclaimed += nr_soft_reclaimed;
+
 		/*
-		 * Continue scanning in the highmem->dma direction stopping at
-		 * the last zone which needs scanning. This may reclaim lowmem
-		 * pages that are not necessary for zone balancing but it
-		 * preserves LRU ordering. It is assumed that the bulk of
-		 * allocation requests can use arbitrary zones with the
-		 * possible exception of big highmem:lowmem configurations.
+		 * There should be no need to raise the scanning priority if
+		 * enough pages are already being scanned that that high
+		 * watermark would be met at 100% efficiency.
 		 */
-		for (i = end_zone; i >= end_zone; i--) {
-			struct zone *zone = pgdat->node_zones + i;
-
-			if (!populated_zone(zone))
-				continue;
-
-			if (sc.priority != DEF_PRIORITY &&
-			    !pgdat_reclaimable(zone->zone_pgdat))
-				continue;
-
-			sc.nr_scanned = 0;
-
-			nr_soft_scanned = 0;
-			/*
-			 * Call soft limit reclaim before calling shrink_zone.
-			 */
-			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
-							order, sc.gfp_mask,
-							&nr_soft_scanned);
-			sc.nr_reclaimed += nr_soft_reclaimed;
-
-			/*
-			 * There should be no need to raise the scanning
-			 * priority if enough pages are already being scanned
-			 * that that high watermark would be met at 100%
-			 * efficiency.
-			 */
-			if (kswapd_shrink_zone(zone, end_zone,
-					       &sc, &nr_attempted))
-				raise_priority = false;
-		}
+		if (kswapd_shrink_node(pgdat, end_zone, &sc, &nr_attempted))
+			raise_priority = false;
 
 		/*
 		 * If the low watermark is met there is no need for processes
@@ -3257,17 +3165,6 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 				pfmemalloc_watermark_ok(pgdat))
 			wake_up_all(&pgdat->pfmemalloc_wait);
 
-		/*
-		 * Fragmentation may mean that the system cannot be rebalanced
-		 * for high-order allocations in all zones. If twice the
-		 * allocation size has been reclaimed and the zones are still
-		 * not balanced then recheck the watermarks at order-0 to
-		 * prevent kswapd reclaiming excessively. Assume that a
-		 * process requested a high-order can direct reclaim/compact.
-		 */
-		if (order && sc.nr_reclaimed >= 2UL << order)
-			order = sc.order = 0;
-
 		/* Check if kswapd should be suspending */
 		if (try_to_freeze() || kthread_should_stop())
 			break;
@@ -3280,13 +3177,26 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 			compact_pgdat(pgdat, order);
 
 		/*
+		 * Stop reclaiming if any eligible zone is balanced and clear
+		 * node writeback or congested.
+		 */
+		for (i = 0; i <= *classzone_idx; i++) {
+			zone = pgdat->node_zones + i;
+
+			if (zone_balanced(zone, sc.order, 0, *classzone_idx)) {
+				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
+				clear_bit(PGDAT_DIRTY, &pgdat->flags);
+				break;
+			}
+		}
+
+		/*
 		 * Raise priority if scanning rate is too low or there was no
 		 * progress in reclaiming pages
 		 */
 		if (raise_priority || !sc.nr_reclaimed)
 			sc.priority--;
-	} while (sc.priority >= 1 &&
-		 !pgdat_balanced(pgdat, order, *classzone_idx));
+	} while (sc.priority >= 1);
 
 out:
 	/*
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
