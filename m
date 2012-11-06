Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 0A3996B0068
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:42:59 -0500 (EST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 01:12:44 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JgeYe36176096
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 01:12:40 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6JgeI4029724
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:42:40 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 08/10] mm: Modify vmscan
Date: Wed, 07 Nov 2012 01:11:36 +0530
Message-ID: <20121106194132.6560.72786.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
References: <20121106193650.6560.71366.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Ankita Garg <gargankita@gmail.com>

Modify vmscan to take into account the changed node-zone hierarchy.

Signed-off-by: Ankita Garg <gargankita@gmail.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/vmscan.c |  364 +++++++++++++++++++++++++++++++----------------------------
 1 file changed, 193 insertions(+), 171 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2624edc..4d8f303 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2209,11 +2209,14 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 	unsigned long free_pages = 0;
 	int i;
 	bool wmark_ok;
+	struct mem_region *region;
 
 	for (i = 0; i <= ZONE_NORMAL; i++) {
-		zone = &pgdat->node_zones[i];
-		pfmemalloc_reserve += min_wmark_pages(zone);
-		free_pages += zone_page_state(zone, NR_FREE_PAGES);
+		for_each_mem_region_in_node(region, pgdat->node_id) {
+			zone = &region->region_zones[i];
+			pfmemalloc_reserve += min_wmark_pages(zone);
+			free_pages += zone_page_state(zone, NR_FREE_PAGES);
+		}
 	}
 
 	wmark_ok = free_pages > pfmemalloc_reserve / 2;
@@ -2442,10 +2445,16 @@ static bool pgdat_balanced(pg_data_t *pgdat, unsigned long balanced_pages,
 						int classzone_idx)
 {
 	unsigned long present_pages = 0;
+	struct mem_region *region;
 	int i;
 
-	for (i = 0; i <= classzone_idx; i++)
-		present_pages += pgdat->node_zones[i].present_pages;
+	for (i = 0; i <= classzone_idx; i++) {
+		for_each_mem_region_in_node(region, pgdat->node_id) {
+			struct zone *zone = region->region_zones + i;
+
+			present_pages += zone->present_pages;
+		}
+	}
 
 	/* A special case here: if zone has no page, we think it's balanced */
 	return balanced_pages >= (present_pages >> 2);
@@ -2463,6 +2472,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 	int i;
 	unsigned long balanced = 0;
 	bool all_zones_ok = true;
+	struct mem_region *region;
 
 	/* If a direct reclaimer woke kswapd within HZ/10, it's premature */
 	if (remaining)
@@ -2484,27 +2494,29 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, long remaining,
 
 	/* Check the watermark levels */
 	for (i = 0; i <= classzone_idx; i++) {
-		struct zone *zone = pgdat->node_zones + i;
+		for_each_mem_region_in_node(region, pgdat->node_id) {
+			struct zone *zone = region->region_zones + i;
 
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
+				/*
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
-							i, 0))
-			all_zones_ok = false;
-		else
-			balanced += zone->present_pages;
+			if (!zone_watermark_ok_safe(zone, order,
+						high_wmark_pages(zone), i, 0))
+				all_zones_ok = false;
+			else
+				balanced += zone->present_pages;
+		}
 	}
 
 	/*
@@ -2565,6 +2577,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
 	};
+	struct mem_region *region;
 loop_again:
 	total_scanned = 0;
 	sc.priority = DEF_PRIORITY;
@@ -2583,49 +2596,55 @@ loop_again:
 		 * Scan in the highmem->dma direction for the highest
 		 * zone which needs scanning
 		 */
-		for (i = pgdat->nr_zones - 1; i >= 0; i--) {
-			struct zone *zone = pgdat->node_zones + i;
+		for (i = pgdat->nr_node_zone_types - 1; i >= 0; i--) {
+			for_each_mem_region_in_node(region, pgdat->node_id) {
+				struct zone *zone = region->region_zones + i;
 
-			if (!populated_zone(zone))
-				continue;
+				if (!populated_zone(zone))
+					continue;
 
-			if (zone->all_unreclaimable &&
-			    sc.priority != DEF_PRIORITY)
-				continue;
+				if (zone->all_unreclaimable &&
+				    sc.priority != DEF_PRIORITY)
+					continue;
 
-			/*
-			 * Do some background aging of the anon list, to give
-			 * pages a chance to be referenced before reclaiming.
-			 */
-			age_active_anon(zone, &sc);
+				/*
+				 * Do some background aging of the anon list, to give
+				 * pages a chance to be referenced before reclaiming.
+				 */
+				age_active_anon(zone, &sc);
 
-			/*
-			 * If the number of buffer_heads in the machine
-			 * exceeds the maximum allowed level and this node
-			 * has a highmem zone, force kswapd to reclaim from
-			 * it to relieve lowmem pressure.
-			 */
-			if (buffer_heads_over_limit && is_highmem_idx(i)) {
-				end_zone = i;
-				break;
-			}
+				/*
+				 * If the number of buffer_heads in the machine
+				 * exceeds the maximum allowed level and this node
+				 * has a highmem zone, force kswapd to reclaim from
+				 * it to relieve lowmem pressure.
+				 */
+				if (buffer_heads_over_limit && is_highmem_idx(i)) {
+					end_zone = i;
+					goto out_loop;
+				}
 
-			if (!zone_watermark_ok_safe(zone, order,
-					high_wmark_pages(zone), 0, 0)) {
-				end_zone = i;
-				break;
-			} else {
-				/* If balanced, clear the congested flag */
-				zone_clear_flag(zone, ZONE_CONGESTED);
+				if (!zone_watermark_ok_safe(zone, order,
+						high_wmark_pages(zone), 0, 0)) {
+					end_zone = i;
+					goto out_loop;
+				} else {
+					/* If balanced, clear the congested flag */
+					zone_clear_flag(zone, ZONE_CONGESTED);
+				}
 			}
 		}
+
+	out_loop:
 		if (i < 0)
 			goto out;
 
 		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
+			for_each_mem_region_in_node(region, pgdat->node_id) {
+				struct zone *zone = region->region_zones + i;
 
-			lru_pages += zone_reclaimable_pages(zone);
+				lru_pages += zone_reclaimable_pages(zone);
+			}
 		}
 
 		/*
@@ -2638,108 +2657,109 @@ loop_again:
 		 * cause too much scanning of the lower zones.
 		 */
 		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
-			int nr_slab, testorder;
-			unsigned long balance_gap;
-
-			if (!populated_zone(zone))
-				continue;
+			for_each_mem_region_in_node(region, pgdat->node_id) {
+				struct zone *zone = region->region_zones + i;
+				int nr_slab, testorder;
+				unsigned long balance_gap;
 
-			if (zone->all_unreclaimable &&
-			    sc.priority != DEF_PRIORITY)
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
-			total_scanned += nr_soft_scanned;
-
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
-			/*
-			 * Kswapd reclaims only single pages with compaction
-			 * enabled. Trying too hard to reclaim until contiguous
-			 * free pages have become available can hurt performance
-			 * by evicting too much useful data from memory.
-			 * Do not reclaim more than needed for compaction.
-			 */
-			testorder = order;
-			if (COMPACTION_BUILD && order &&
-					compaction_suitable(zone, order) !=
-						COMPACT_SKIPPED)
-				testorder = 0;
-
-			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
-				    !zone_watermark_ok_safe(zone, testorder,
-					high_wmark_pages(zone) + balance_gap,
-					end_zone, 0)) {
-				shrink_zone(zone, &sc);
-
-				reclaim_state->reclaimed_slab = 0;
-				nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
-				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-				total_scanned += sc.nr_scanned;
+				if (!populated_zone(zone))
+					continue;
 
-				if (nr_slab == 0 && !zone_reclaimable(zone))
-					zone->all_unreclaimable = 1;
-			}
+				if (zone->all_unreclaimable &&
+				    sc.priority != DEF_PRIORITY)
+					continue;
 
-			/*
-			 * If we've done a decent amount of scanning and
-			 * the reclaim ratio is low, start doing writepage
-			 * even in laptop mode
-			 */
-			if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
-			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
-				sc.may_writepage = 1;
+				sc.nr_scanned = 0;
 
-			if (zone->all_unreclaimable) {
-				if (end_zone && end_zone == i)
-					end_zone--;
-				continue;
-			}
+				nr_soft_scanned = 0;
+				/*
+				 * Call soft limit reclaim before calling shrink_zone.
+				 */
+				nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
+								order, sc.gfp_mask,
+								&nr_soft_scanned);
+				sc.nr_reclaimed += nr_soft_reclaimed;
+				total_scanned += nr_soft_scanned;
 
-			if (!zone_watermark_ok_safe(zone, testorder,
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
-				if (!zone_watermark_ok_safe(zone, order,
-					    min_wmark_pages(zone), end_zone, 0))
-					has_under_min_watermark_zone = 1;
-			} else {
+				balance_gap = min(low_wmark_pages(zone),
+					(zone->present_pages +
+						KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
+					KSWAPD_ZONE_BALANCE_GAP_RATIO);
 				/*
-				 * If a zone reaches its high watermark,
-				 * consider it to be no longer congested. It's
-				 * possible there are dirty pages backed by
-				 * congested BDIs but as pressure is relieved,
-				 * speculatively avoid congestion waits
+				 * Kswapd reclaims only single pages with compaction
+				 * enabled. Trying too hard to reclaim until contiguous
+				 * free pages have become available can hurt performance
+				 * by evicting too much useful data from memory.
+				 * Do not reclaim more than needed for compaction.
 				 */
-				zone_clear_flag(zone, ZONE_CONGESTED);
-				if (i <= *classzone_idx)
-					balanced += zone->present_pages;
-			}
+				testorder = order;
+				if (COMPACTION_BUILD && order &&
+						compaction_suitable(zone, order) !=
+							COMPACT_SKIPPED)
+					testorder = 0;
+
+				if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
+					    !zone_watermark_ok_safe(zone, testorder,
+						high_wmark_pages(zone) + balance_gap,
+						end_zone, 0)) {
+					shrink_zone(zone, &sc);
+
+					reclaim_state->reclaimed_slab = 0;
+					nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
+					sc.nr_reclaimed += reclaim_state->reclaimed_slab;
+					total_scanned += sc.nr_scanned;
+
+					if (nr_slab == 0 && !zone_reclaimable(zone))
+						zone->all_unreclaimable = 1;
+				}
 
+				/*
+				 * If we've done a decent amount of scanning and
+				 * the reclaim ratio is low, start doing writepage
+				 * even in laptop mode
+				 */
+				if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
+				    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
+					sc.may_writepage = 1;
+
+				if (zone->all_unreclaimable) {
+					if (end_zone && end_zone == i)
+						end_zone--;
+					continue;
+				}
+
+				if (!zone_watermark_ok_safe(zone, testorder,
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
+					 * speculatively avoid congestion waits
+					 */
+					zone_clear_flag(zone, ZONE_CONGESTED);
+					if (i <= *classzone_idx)
+						balanced += zone->present_pages;
+				}
+			}
 		}
 
 		/*
@@ -2817,34 +2837,36 @@ out:
 		int zones_need_compaction = 1;
 
 		for (i = 0; i <= end_zone; i++) {
-			struct zone *zone = pgdat->node_zones + i;
+			for_each_mem_region_in_node(region, pgdat->node_id) {
+				struct zone *zone = region->region_zones + i;
 
-			if (!populated_zone(zone))
-				continue;
+				if (!populated_zone(zone))
+					continue;
 
-			if (zone->all_unreclaimable &&
-			    sc.priority != DEF_PRIORITY)
-				continue;
+				if (zone->all_unreclaimable &&
+				    sc.priority != DEF_PRIORITY)
+					continue;
 
-			/* Would compaction fail due to lack of free memory? */
-			if (COMPACTION_BUILD &&
-			    compaction_suitable(zone, order) == COMPACT_SKIPPED)
-				goto loop_again;
+				/* Would compaction fail due to lack of free memory? */
+				if (COMPACTION_BUILD &&
+				    compaction_suitable(zone, order) == COMPACT_SKIPPED)
+					goto loop_again;
 
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
 
-			/* Check if the memory needs to be defragmented. */
-			if (zone_watermark_ok(zone, order,
-				    low_wmark_pages(zone), *classzone_idx, 0))
-				zones_need_compaction = 0;
+				/* Check if the memory needs to be defragmented. */
+				if (zone_watermark_ok(zone, order,
+					    low_wmark_pages(zone), *classzone_idx, 0))
+					zones_need_compaction = 0;
 
-			/* If balanced, clear the congested flag */
-			zone_clear_flag(zone, ZONE_CONGESTED);
+				/* If balanced, clear the congested flag */
+				zone_clear_flag(zone, ZONE_CONGESTED);
+			}
 		}
 
 		if (zones_need_compaction)
@@ -2966,7 +2988,7 @@ static int kswapd(void *p)
 
 	order = new_order = 0;
 	balanced_order = 0;
-	classzone_idx = new_classzone_idx = pgdat->nr_zones - 1;
+	classzone_idx = new_classzone_idx = pgdat->nr_node_zone_types - 1;
 	balanced_classzone_idx = classzone_idx;
 	for ( ; ; ) {
 		int ret;
@@ -2981,7 +3003,7 @@ static int kswapd(void *p)
 			new_order = pgdat->kswapd_max_order;
 			new_classzone_idx = pgdat->classzone_idx;
 			pgdat->kswapd_max_order =  0;
-			pgdat->classzone_idx = pgdat->nr_zones - 1;
+			pgdat->classzone_idx = pgdat->nr_node_zone_types - 1;
 		}
 
 		if (order < new_order || classzone_idx > new_classzone_idx) {
@@ -2999,7 +3021,7 @@ static int kswapd(void *p)
 			new_order = order;
 			new_classzone_idx = classzone_idx;
 			pgdat->kswapd_max_order = 0;
-			pgdat->classzone_idx = pgdat->nr_zones - 1;
+			pgdat->classzone_idx = pgdat->nr_node_zone_types - 1;
 		}
 
 		ret = try_to_freeze();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
