Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B91CC6B0283
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:26:51 -0400 (EDT)
Received: by mail-wm0-f47.google.com with SMTP id u206so21734876wme.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:26:51 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id s3si21693844wmb.94.2016.04.12.03.26.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 03:26:50 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id C5EBF1C2340
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:26:49 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 07/28] mm, vmscan: Make kswapd reclaim in terms of nodes
Date: Tue, 12 Apr 2016 11:26:02 +0100
Message-Id: <1460456783-30996-8-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
References: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Patch "mm: vmscan: Begin reclaiming pages on a per-node basis" started
thinking of reclaim in terms of nodes but kswapd is still zone-centric. This
patch gets rid of many of the node-based versus zone-based decisions.

o A node is considered balanced when any eligible lower zone is balanced.
  This eliminates one class of age-inversion problem because we avoid
  reclaiming a newer page just because it's in the wrong zone
o pgdat_balanced disappears because we now only care about one zone being
  balanced.
o Some anomalies related to writeback and congestion tracking being based on
  zones disappear.
o kswapd no longer has to take care to reclaim zones in the reverse order
  that the page allocator uses.
o Most importantly of all, reclaim from node 0 with multiple zones will
  have similar aging and reclaiming characteristics as every
  other node.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 292 +++++++++++++++++++++---------------------------------------
 1 file changed, 101 insertions(+), 191 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index f2534e8f8527..c23d8f9722ad 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2979,7 +2979,8 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
 }
 #endif
 
-static void age_active_anon(struct zone *zone, struct scan_control *sc)
+static void age_active_anon(struct pglist_data *pgdat,
+				struct zone *zone, struct scan_control *sc)
 {
 	struct mem_cgroup *memcg;
 
@@ -2998,85 +2999,15 @@ static void age_active_anon(struct zone *zone, struct scan_control *sc)
 	} while (memcg);
 }
 
-static bool zone_balanced(struct zone *zone, int order, bool highorder,
+static bool zone_balanced(struct zone *zone, int order,
 			unsigned long balance_gap, int classzone_idx)
 {
 	unsigned long mark = high_wmark_pages(zone) + balance_gap;
 
-	/*
-	 * When checking from pgdat_balanced(), kswapd should stop and sleep
-	 * when it reaches the high order-0 watermark and let kcompactd take
-	 * over. Other callers such as wakeup_kswapd() want to determine the
-	 * true high-order watermark.
-	 */
-	if (IS_ENABLED(CONFIG_COMPACTION) && !highorder) {
-		mark += (1UL << order);
-		order = 0;
-	}
-
 	return zone_watermark_ok_safe(zone, order, mark, classzone_idx);
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
-		if (zone_balanced(zone, order, false, 0, i))
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
@@ -3085,6 +3016,8 @@ static bool pgdat_balanced(pg_data_t *pgdat, int order, int classzone_idx)
 static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 					int classzone_idx)
 {
+	int i;
+
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
 		return false;
@@ -3105,101 +3038,90 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 	if (waitqueue_active(&pgdat->pfmemalloc_wait))
 		wake_up_all(&pgdat->pfmemalloc_wait);
 
-	return pgdat_balanced(pgdat, order, classzone_idx);
+	for (i = 0; i <= classzone_idx; i++) {
+		struct zone *zone = pgdat->node_zones + i;
+
+		if (!populated_zone(zone))
+			continue;
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
+static bool kswapd_shrink_node(pg_data_t *pgdat,
 			       int classzone_idx,
 			       struct scan_control *sc)
 {
-	unsigned long balance_gap;
-	bool lowmem_pressure;
-	struct pglist_data *pgdat = zone->zone_pgdat;
+	struct zone *zone;
+	unsigned long nr_to_reclaim = 0;
+	int z;
 
-	/* Reclaim above the high watermark. */
-	sc->nr_to_reclaim = max(SWAP_CLUSTER_MAX, high_wmark_pages(zone));
+	/* Reclaim a number of pages proportional to the number of zones */
+	for (z = 0; z <= classzone_idx; z++) {
+		zone = pgdat->node_zones + z;
+		if (!populated_zone(zone))
+			continue;
 
-	/*
-	 * We put equal pressure on every zone, unless one zone has way too
-	 * many pages free already. The "too many pages" is defined as the
-	 * high wmark plus a "gap" where the gap is either the low
-	 * watermark or 1% of the zone, whichever is smaller.
-	 */
-	balance_gap = min(low_wmark_pages(zone), DIV_ROUND_UP(
-			zone->managed_pages, KSWAPD_ZONE_BALANCE_GAP_RATIO));
+		nr_to_reclaim += max(high_wmark_pages(zone), SWAP_CLUSTER_MAX);
+	}
 
 	/*
-	 * If there is no low memory pressure or the zone is balanced then no
-	 * reclaim is necessary
+	 * Historically care was taken to put equal pressure on all zones but
+	 * now pressure is applied based on node LRU order.
 	 */
-	lowmem_pressure = (buffer_heads_over_limit && is_highmem(zone));
-	if (!lowmem_pressure && zone_balanced(zone, sc->order, false,
-						balance_gap, classzone_idx))
-		return true;
-
-	shrink_node(zone->zone_pgdat, sc, classzone_idx);
-
-	/* TODO: ANOMALY */
-	clear_bit(PGDAT_WRITEBACK, &pgdat->flags);
+	shrink_node(pgdat, sc, classzone_idx);
 
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
-	    zone_balanced(zone, sc->order, false, 0, classzone_idx)) {
-		clear_bit(PGDAT_CONGESTED, &pgdat->flags);
-		clear_bit(PGDAT_DIRTY, &pgdat->flags);
-	}
+	if (sc->order && sc->nr_reclaimed >= 2UL << sc->order)
+		sc->order = 0;
 
 	return sc->nr_scanned >= sc->nr_to_reclaim;
 }
 
 /*
- * For kswapd, balance_pgdat() will work across all this node's zones until
- * they are all at high_wmark_pages(zone).
- *
- * Returns the highest zone idx kswapd was reclaiming at
+ * For kswapd, balance_pgdat() will reclaim pages across a node from zones
+ * that are eligible for use by the caller until at least one zone is
+ * balanced.
  *
- * There is special handling here for zones which are full of pinned pages.
- * This can happen if the pages are all mlocked, or if they are all used by
- * device drivers (say, ZONE_DMA).  Or if they are all in use by hugetlb.
- * What we do is to detect the case where all pages in the zone have been
- * scanned twice and there has been zero successful reclaim.  Mark the zone as
- * dead and from now on, only perform a short scan.  Basically we're polling
- * the zone for when the problem goes away.
+ * Returns the order kswapd finished reclaiming at.
  *
  * kswapd scans the zones in the highmem->normal->dma direction.  It skips
  * zones which have free_pages > high_wmark_pages(zone), but once a zone is
- * found to have free_pages <= high_wmark_pages(zone), we scan that zone and the
- * lower zones regardless of the number of free pages in the lower zones. This
- * interoperates with the page allocator fallback scheme to ensure that aging
- * of pages is balanced across the zones.
+ * found to have free_pages <= high_wmark_pages(zone), any page is that zone
+ * or lower is eligible for reclaim until at least one usable zone is
+ * balanced.
  */
 static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 {
 	int i;
-	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long nr_soft_reclaimed;
 	unsigned long nr_soft_scanned;
+	struct zone *zone;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
-		.reclaim_idx = MAX_NR_ZONES - 1,
 		.order = order,
 		.priority = DEF_PRIORITY,
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = 1,
+		.reclaim_idx = classzone_idx,
 	};
 	count_vm_event(PAGEOUTRUN);
 
@@ -3210,21 +3132,10 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 
 		/* Scan from the highest requested zone to dma */
 		for (i = classzone_idx; i >= 0; i--) {
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
@@ -3232,19 +3143,17 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			 * it to relieve lowmem pressure.
 			 */
 			if (buffer_heads_over_limit && is_highmem_idx(i)) {
-				end_zone = i;
+				classzone_idx = i;
 				break;
 			}
 
-			if (!zone_balanced(zone, order, false, 0, 0)) {
-				end_zone = i;
+			if (!zone_balanced(zone, order, 0, 0)) {
+				classzone_idx = i;
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
@@ -3255,51 +3164,34 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			goto out;
 
 		/*
+		 * Do some background aging of the anon list, to give
+		 * pages a chance to be referenced before reclaiming. All
+		 * pages are rotated regardless of classzone as this is
+		 * about consistent aging.
+		 */
+		age_active_anon(pgdat, &pgdat->node_zones[MAX_NR_ZONES - 1], &sc);
+
+		/*
 		 * If we're getting trouble reclaiming, start doing writepage
 		 * even in laptop mode.
 		 */
-		if (sc.priority < DEF_PRIORITY - 2)
+		if (sc.priority < DEF_PRIORITY - 2 || !pgdat_reclaimable(pgdat))
 			sc.may_writepage = 1;
 
+		/* Call soft limit reclaim before calling shrink_node. */
+		sc.nr_scanned = 0;
+		nr_soft_scanned = 0;
+		nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone, sc.order,
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
-			sc.reclaim_idx = i;
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
-			if (kswapd_shrink_zone(zone, end_zone, &sc))
-				raise_priority = false;
-		}
+		if (kswapd_shrink_node(pgdat, classzone_idx, &sc))
+			raise_priority = false;
 
 		/*
 		 * If the low watermark is met there is no need for processes
@@ -3315,20 +3207,37 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 			break;
 
 		/*
+		 * Stop reclaiming if any eligible zone is balanced and clear
+		 * node writeback or congested.
+		 */
+		for (i = 0; i <= classzone_idx; i++) {
+			zone = pgdat->node_zones + i;
+			if (!populated_zone(zone))
+				continue;
+
+			if (zone_balanced(zone, sc.order, 0, classzone_idx)) {
+				clear_bit(PGDAT_CONGESTED, &pgdat->flags);
+				clear_bit(PGDAT_DIRTY, &pgdat->flags);
+				goto out;
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
-			!pgdat_balanced(pgdat, order, classzone_idx));
+	} while (sc.priority >= 1);
 
 out:
 	/*
-	 * Return the highest zone idx we were reclaiming at so
-	 * prepare_kswapd_sleep() makes the same decisions as here.
+	 * Return the order kswapd stopped reclaiming at as
+	 * prepare_kswapd_sleep() takes it into account. If another caller
+	 * entered the allocator slow path while kswapd was awake, order will
+	 * remain at the higher level.
 	 */
-	return end_zone;
+	return sc.order;
 }
 
 static void kswapd_try_to_sleep(pg_data_t *pgdat, int order,
@@ -3485,8 +3394,9 @@ static int kswapd(void *p)
 		 */
 		if (!ret) {
 			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
-			balanced_classzone_idx = balance_pgdat(pgdat, order,
-								classzone_idx);
+
+			/* return value ignored until next patch */
+			balance_pgdat(pgdat, order, classzone_idx);
 		}
 	}
 
@@ -3516,7 +3426,7 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
 	}
 	if (!waitqueue_active(&pgdat->kswapd_wait))
 		return;
-	if (zone_balanced(zone, order, true, 0, 0))
+	if (zone_balanced(zone, order, 0, 0))
 		return;
 
 	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
