Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC5EE90010B
	for <linux-mm@kvack.org>; Fri, 27 May 2011 08:32:05 -0400 (EDT)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4RCVxUJ013825
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:01:59 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RCVsCl2560192
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:01:59 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RCVrXD003685
	for <linux-mm@kvack.org>; Fri, 27 May 2011 22:31:53 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 08/10] mm: Modify vmscan
Date: Fri, 27 May 2011 18:01:36 +0530
Message-Id: <1306499498-14263-9-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

Modify vmscan to take into account the changed node-zone hierarchy.

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 mm/vmscan.c |  284 ++++++++++++++++++++++++++++++++---------------------------
 1 files changed, 153 insertions(+), 131 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8bfd450..2e11974 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2235,10 +2235,16 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
 						int classzone_idx)
 {
 	unsigned long present_pages = 0;
-	int i;
-
-	for (i = 0; i <= classzone_idx; i++)
-		present_pages += pgdat->node_zones[i].present_pages;
+	int i, p;
+
+	for (i = 0; i <= classzone_idx; i++) {
+		for_each_mem_region_in_nid(p, pgdat->node_id) {
+			mem_region_t *mem_region = &pgdat->mem_regions[p];
+			struct zone *zone = mem_region->zones + i;
+	
+			present_pages += zone->present_pages;
+		}
+	}
 
 	return balanced_pages > (present_pages >> 2);
 }
@@ -2247,7 +2253,7 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
 static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 					int classzone_idx)
 {
-	int i;
+	int i, j;
 	unsigned long balanced = 0;
 	bool all_zones_ok = true;
 
@@ -2257,29 +2263,31 @@ static bool sleeping_prematurely(pg_data_t *pgdat, int order, long remaining,
 
 	/* Check the watermark levels */
 	for (i = 0; i < pgdat->nr_zones; i++) {
-		struct zone *zone = pgdat->node_zones + i;
+		for_each_mem_region_in_nid(j, pgdat->node_id) {
+			mem_region_t *mem_region = &pgdat->mem_regions[j];
+			struct zone *zone = mem_region->zones + i;
 
-		if (!populated_zone(zone))
-			continue;
+			if (!populated_zone(zone))
+				continue;
 
-		/*
-		 * balance_pgdat() skips over all_unreclaimable after
-		 * DEF_PRIORITY. Effectively, it considers them balanced so
-		 * they must be considered balanced here as well if kswapd
-		 * is to sleep
-		 */
-		if (zone->all_unreclaimable) {
-			balanced += zone->present_pages;
-			continue;
-		}
+			/*
+			 * balance_pgdat() skips over all_unreclaimable after
+			 * DEF_PRIORITY. Effectively, it considers them balanced so
+			 * they must be considered balanced here as well if kswapd
+			 * is to sleep
+			 */
+			if (zone->all_unreclaimable) {
+				balanced += zone->present_pages;
+				continue;
+			}
 
-		if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
-							classzone_idx, 0))
-			all_zones_ok = false;
-		else
-			balanced += zone->present_pages;
+			if (!zone_watermark_ok_safe(zone, order, high_wmark_pages(zone),
+								classzone_idx, 0))
+				all_zones_ok = false;
+			else
+				balanced += zone->present_pages;
+		}
 	}
-
 	/*
 	 * For high-order requests, the balanced zones must contain at least
 	 * 25% of the nodes pages for kswapd to sleep. For order-0, all zones
@@ -2318,7 +2326,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	int all_zones_ok;
 	unsigned long balanced;
 	int priority;
-	int i;
+	int i, p;
 	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
@@ -2357,36 +2365,42 @@ loop_again:
 		 * zone which needs scanning
 		 */
 		for (i = pgdat->nr_zones - 1; i >= 0; i--) {
-			struct zone *zone = pgdat->node_zones + i;
+			for_each_mem_region_in_nid(p, pgdat->node_id) {
+				mem_region_t *mem_region = &pgdat->mem_regions[p];
+				struct zone *zone = mem_region->zones + i;
 
-			if (!populated_zone(zone))
-				continue;
+				if (!populated_zone(zone))
+					continue;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
-				continue;
+				if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+					continue;
 
-			/*
-			 * Do some background aging of the anon list, to give
-			 * pages a chance to be referenced before reclaiming.
-			 */
-			if (inactive_anon_is_low(zone, &sc))
-				shrink_active_list(SWAP_CLUSTER_MAX, zone,
-							&sc, priority, 0);
-
-			if (!zone_watermark_ok_safe(zone, order,
-					high_wmark_pages(zone), 0, 0)) {
-				end_zone = i;
-				*classzone_idx = i;
-				break;
+				/*
+				 * Do some background aging of the anon list, to give
+				 * pages a chance to be referenced before reclaiming.
+				 */
+				if (inactive_anon_is_low(zone, &sc))
+					shrink_active_list(SWAP_CLUSTER_MAX, zone,
+								&sc, priority, 0);
+
+				if (!zone_watermark_ok_safe(zone, order,
+						high_wmark_pages(zone), 0, 0)) {
+					end_zone = i;
+					*classzone_idx = i;
+					break;
+				}
 			}
 		}
 		if (i < 0)
 			goto out;
 
 		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
+			for_each_mem_region_in_nid(p, pgdat->node_id) {
+				mem_region_t *mem_region = &pgdat->mem_regions[p];
+				struct zone *zone = mem_region->zones + i;
 
-			lru_pages += zone_reclaimable_pages(zone);
+				lru_pages += zone_reclaimable_pages(zone);
+			}
 		}
 
 		/*
@@ -2399,84 +2413,86 @@ loop_again:
 		 * cause too much scanning of the lower zones.
 		 */
 		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
-			int nr_slab;
-			unsigned long balance_gap;
-
-			if (!populated_zone(zone))
-				continue;
+			for_each_mem_region_in_nid(p, pgdat->node_id) {
+				mem_region_t *mem_region = &pgdat->mem_regions[p];
+				struct zone *zone = mem_region->zones + i;
+				int nr_slab;
+				unsigned long balance_gap;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
-				continue;
+				if (!populated_zone(zone))
+					continue;
 
-			sc.nr_scanned = 0;
+				if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+					continue;
 
-			/*
-			 * Call soft limit reclaim before calling shrink_zone.
-			 * For now we ignore the return value
-			 */
-			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
+				sc.nr_scanned = 0;
 
-			/*
-			 * We put equal pressure on every zone, unless
-			 * one zone has way too many pages free
-			 * already. The "too many pages" is defined
-			 * as the high wmark plus a "gap" where the
-			 * gap is either the low watermark or 1%
-			 * of the zone, whichever is smaller.
-			 */
-			balance_gap = min(low_wmark_pages(zone),
-				(zone->present_pages +
-					KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
-				KSWAPD_ZONE_BALANCE_GAP_RATIO);
-			if (!zone_watermark_ok_safe(zone, order,
-					high_wmark_pages(zone) + balance_gap,
-					end_zone, 0))
-				shrink_zone(priority, zone, &sc);
-			reclaim_state->reclaimed_slab = 0;
-			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
-						lru_pages);
-			sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-			total_scanned += sc.nr_scanned;
-
-			if (zone->all_unreclaimable)
-				continue;
-			if (nr_slab == 0 &&
-			    !zone_reclaimable(zone))
-				zone->all_unreclaimable = 1;
-			/*
-			 * If we've done a decent amount of scanning and
-			 * the reclaim ratio is low, start doing writepage
-			 * even in laptop mode
-			 */
-			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
-			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
-				sc.may_writepage = 1;
+				/*
+				 * Call soft limit reclaim before calling shrink_zone.
+				 * For now we ignore the return value
+				 */
+				mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
 
-			if (!zone_watermark_ok_safe(zone, order,
-					high_wmark_pages(zone), end_zone, 0)) {
-				all_zones_ok = 0;
 				/*
-				 * We are still under min water mark.  This
-				 * means that we have a GFP_ATOMIC allocation
-				 * failure risk. Hurry up!
+				 * We put equal pressure on every zone, unless
+				 * one zone has way too many pages free
+				 * already. The "too many pages" is defined
+				 * as the high wmark plus a "gap" where the
+				 * gap is either the low watermark or 1%
+				 * of the zone, whichever is smaller.
 				 */
+				balance_gap = min(low_wmark_pages(zone),
+					(zone->present_pages +
+						KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
+					KSWAPD_ZONE_BALANCE_GAP_RATIO);
 				if (!zone_watermark_ok_safe(zone, order,
-					    min_wmark_pages(zone), end_zone, 0))
-					has_under_min_watermark_zone = 1;
-			} else {
+						high_wmark_pages(zone) + balance_gap,
+						end_zone, 0))
+					shrink_zone(priority, zone, &sc);
+				reclaim_state->reclaimed_slab = 0;
+				nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
+							lru_pages);
+				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
+				total_scanned += sc.nr_scanned;
+
+				if (zone->all_unreclaimable)
+					continue;
+				if (nr_slab == 0 &&
+				    !zone_reclaimable(zone))
+					zone->all_unreclaimable = 1;
 				/*
-				 * If a zone reaches its high watermark,
-				 * consider it to be no longer congested. It's
-				 * possible there are dirty pages backed by
-				 * congested BDIs but as pressure is relieved,
-				 * spectulatively avoid congestion waits
+				 * If we've done a decent amount of scanning and
+				 * the reclaim ratio is low, start doing writepage
+				 * even in laptop mode
 				 */
-				zone_clear_flag(zone, ZONE_CONGESTED);
-				if (i <= *classzone_idx)
-					balanced += zone->present_pages;
-			}
+				if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
+				    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
+					sc.may_writepage = 1;
 
+				if (!zone_watermark_ok_safe(zone, order,
+						high_wmark_pages(zone), end_zone, 0)) {
+					all_zones_ok = 0;
+					/*
+					 * We are still under min water mark.  This
+					 * means that we have a GFP_ATOMIC allocation
+					 * failure risk. Hurry up!
+					 */
+					if (!zone_watermark_ok_safe(zone, order,
+						    min_wmark_pages(zone), end_zone, 0))
+						has_under_min_watermark_zone = 1;
+				} else {
+					/*
+					 * If a zone reaches its high watermark,
+					 * consider it to be no longer congested. It's
+					 * possible there are dirty pages backed by
+					 * congested BDIs but as pressure is relieved,
+					 * spectulatively avoid congestion waits
+					 */
+					zone_clear_flag(zone, ZONE_CONGESTED);
+					if (i <= *classzone_idx)
+						balanced += zone->present_pages;
+				}
+			}
 		}
 		if (all_zones_ok || (order && pgdat_balanced(pgdat, balanced, *classzone_idx)))
 			break;		/* kswapd: all done */
@@ -2542,23 +2558,26 @@ out:
 	 */
 	if (order) {
 		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
+			for_each_mem_region_in_nid(p, pgdat->node_id) {
+				mem_region_t *mem_region = &pgdat->mem_regions[p];
+				struct zone *zone = mem_region->zones + i;
 
-			if (!populated_zone(zone))
-				continue;
+				if (!populated_zone(zone))
+					continue;
 
-			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
-				continue;
+				if (zone->all_unreclaimable && priority != DEF_PRIORITY)
+					continue;
 
-			/* Confirm the zone is balanced for order-0 */
-			if (!zone_watermark_ok(zone, 0,
-					high_wmark_pages(zone), 0, 0)) {
-				order = sc.order = 0;
-				goto loop_again;
-			}
+				/* Confirm the zone is balanced for order-0 */
+				if (!zone_watermark_ok(zone, 0,
+						high_wmark_pages(zone), 0, 0)) {
+					order = sc.order = 0;
+					goto loop_again;
+				}
 
-			/* If balanced, clear the congested flag */
-			zone_clear_flag(zone, ZONE_CONGESTED);
+				/* If balanced, clear the congested flag */
+				zone_clear_flag(zone, ZONE_CONGESTED);
+			}
 		}
 	}
 
@@ -3304,18 +3323,21 @@ static ssize_t write_scan_unevictable_node(struct sys_device *dev,
 					   struct sysdev_attribute *attr,
 					const char *buf, size_t count)
 {
-	struct zone *node_zones = NODE_DATA(dev->id)->node_zones;
-	struct zone *zone;
 	unsigned long res;
+	int i,j;
 	unsigned long req = strict_strtoul(buf, 10, &res);
 
 	if (!req)
 		return 1;	/* zero is no-op */
 
-	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
-		if (!populated_zone(zone))
-			continue;
-		scan_zone_unevictable_pages(zone);
+	for (j = 0; j < MAX_NR_ZONES; ++j) {
+		for_each_mem_region_in_nid(i, dev->id) {
+			mem_region_t *mem_region = &(NODE_DATA(dev->id)->mem_regions[i]);
+			struct zone *zone = mem_region->zones;
+			if (!populated_zone(zone))
+				continue;
+			scan_zone_unevictable_pages(zone);
+		}
 	}
 	return 1;
 }
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
