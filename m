Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 55A206B003A
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 04:23:34 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id t60so465845wes.0
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 01:23:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hv4si1813039wib.3.2014.06.18.01.23.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 01:23:31 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/4] mm: page_alloc: Reset fair zone allocation policy when batch counts are expired
Date: Wed, 18 Jun 2014 09:23:26 +0100
Message-Id: <1403079807-24690-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1403079807-24690-1-git-send-email-mgorman@suse.de>
References: <1403079807-24690-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mgorman@suse.de>

The fair zone allocation policy round-robins allocations between zones
within a node to avoid age inversion problems during reclaim. If the
first allocation fails, the batch counts is reset and a second attempt
made before entering the slow path.

One assumption made with this scheme is that batches expire at roughly the
same time and the resets each time are justified. This assumption does not
hold when zones reach their low watermark as the batches will be consumed
at uneven rates.  Allocation failure due to watermark depletion result in
additional zonelist scans for the reset and another watermark check before
hitting the slowpath. On large NUMA machines, the scanning overhead is
higher as zones are scanned that are ineligible for zone allocation policy.

This patch makes a number of changes which are all related to each
other. First and foremost, the patch resets the fair zone policy counts when
all the counters are depleted, avoids scanning remote nodes unnecessarily
and reduces the frequency that resets are required. Second, when the fair
zone batch counter is expired, the zone is flagged which has a lighter
cache footprint than accessing the counters. Lastly, if the local node
has only one zone then the fair zone allocation policy is not applied to
reduce overall overhead.

Comparison is tiobench with data size 2*RAM on a small single-node machine
and on an ext3 filesystem although it is known that ext4 sees similar gains.
I'm reporting sequental reads only as the other operations are essentially
flat.

                                      3.16.0-rc1            3.16.0-rc1            3.16.0-rc1                 3.0.0
                                         vanilla          cfq600              fairzone                     vanilla
Mean   SeqRead-MB/sec-1         121.88 (  0.00%)      121.60 ( -0.23%)      131.68 (  8.04%)      134.59 ( 10.42%)
Mean   SeqRead-MB/sec-2         101.99 (  0.00%)      102.35 (  0.36%)      113.24 ( 11.04%)      122.59 ( 20.20%)
Mean   SeqRead-MB/sec-4          97.42 (  0.00%)       99.71 (  2.35%)      107.43 ( 10.28%)      114.78 ( 17.82%)
Mean   SeqRead-MB/sec-8          83.39 (  0.00%)       90.39 (  8.39%)       96.81 ( 16.09%)      100.14 ( 20.09%)
Mean   SeqRead-MB/sec-16         68.90 (  0.00%)       77.29 ( 12.18%)       81.88 ( 18.85%)       81.64 ( 18.50%)

Where as the CFQ patch helped throughput for higher number of threads, this
patch (fairzone) whos performance increases for all thread counts and brings
performance much closer to 3.0-vanilla. Note that performance can be further
increased by tuning CFQ but the latencies of read operations are then higher
but from the IO stats they are still acceptable.

                  3.16.0-rc1  3.16.0-rc1  3.16.0-rc1       3.0.0
                     vanilla      cfq600    fairzone     vanilla
Mean sda-avgqz        912.29      939.89      947.90     1000.70
Mean sda-await       4268.03     4403.99     4450.89     4887.67
Mean sda-r_await       79.42       80.33       81.34      108.53
Mean sda-w_await    13073.49    11038.81    13217.25    11599.83
Max  sda-avgqz       2194.84     2215.01     2307.48     2626.78
Max  sda-await      18157.88    17586.08    14189.21    24971.00
Max  sda-r_await      888.40      874.22      800.80     5308.00
Max  sda-w_await   212563.59   190265.33   173295.33   177698.47

The primary concern with this patch is that it'll break the fair zone
allocation policy but it should be still fine as long as the working set
fits in memory. When the low watermark is constantly hit and the spread
is still even as before. However, the policy is still in force most of the
time. This is the allocation spread when running tiobench at 80% of memory

                            3.16.0-rc1  3.16.0-rc1  3.16.0-rc1       3.0.0
                               vanilla      cfq600    fairzone     vanilla
DMA32 allocs                  11099122    11020083     9459921     7698716
Normal allocs                 18823134    18801874    20429838    18787406
Movable allocs                       0           0           0           0

Note that the number of pages allocated from the Normal zone is still
comparable.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |   7 +++
 mm/mm_init.c           |   5 +-
 mm/page_alloc.c        | 161 ++++++++++++++++++++++++++++++-------------------
 3 files changed, 109 insertions(+), 64 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6cbd1b6..e041f63 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -529,6 +529,7 @@ typedef enum {
 	ZONE_WRITEBACK,			/* reclaim scanning has recently found
 					 * many pages under writeback
 					 */
+	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
 } zone_flags_t;
 
 static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
@@ -566,6 +567,11 @@ static inline int zone_is_reclaim_locked(const struct zone *zone)
 	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
 }
 
+static inline int zone_is_fair_depleted(const struct zone *zone)
+{
+	return test_bit(ZONE_FAIR_DEPLETED, &zone->flags);
+}
+
 static inline int zone_is_oom_locked(const struct zone *zone)
 {
 	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
@@ -689,6 +695,7 @@ struct zonelist_cache;
 struct zoneref {
 	struct zone *zone;	/* Pointer to actual zone */
 	int zone_idx;		/* zone_idx(zoneref->zone) */
+	bool fair_enabled;	/* eligible for fair zone policy */
 };
 
 /*
diff --git a/mm/mm_init.c b/mm/mm_init.c
index 4074caf..37b7337 100644
--- a/mm/mm_init.c
+++ b/mm/mm_init.c
@@ -54,8 +54,9 @@ void mminit_verify_zonelist(void)
 			/* Iterate the zonelist */
 			for_each_zone_zonelist(zone, z, zonelist, zoneid) {
 #ifdef CONFIG_NUMA
-				printk(KERN_CONT "%d:%s ",
-					zone->node, zone->name);
+				printk(KERN_CONT "%d:%s%s ",
+					zone->node, zone->name,
+					z->fair_enabled ? "(F)" : "");
 #else
 				printk(KERN_CONT "0:%s ", zone->name);
 #endif /* CONFIG_NUMA */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4f59fa2..7614404 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1543,6 +1543,7 @@ int split_free_page(struct page *page)
  */
 static inline
 struct page *buffered_rmqueue(struct zone *preferred_zone,
+			struct zoneref *z,
 			struct zone *zone, unsigned int order,
 			gfp_t gfp_flags, int migratetype)
 {
@@ -1596,7 +1597,11 @@ again:
 					  get_freepage_migratetype(page));
 	}
 
-	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
+	if (z->fair_enabled) {
+		__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
+		if (zone_page_state(zone, NR_ALLOC_BATCH) == 0)
+			zone_set_flag(zone, ZONE_FAIR_DEPLETED);
+	}
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
@@ -1909,6 +1914,18 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 
 #endif	/* CONFIG_NUMA */
 
+static void reset_alloc_batches(struct zone *preferred_zone)
+{
+	struct zone *zone = preferred_zone->zone_pgdat->node_zones;
+
+	do {
+		mod_zone_page_state(zone, NR_ALLOC_BATCH,
+			(zone->managed_pages >> 2) -
+			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
+		zone_clear_flag(zone, ZONE_FAIR_DEPLETED);
+	} while (zone++ != preferred_zone);
+}
+
 /*
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
@@ -1926,8 +1943,11 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
 				(gfp_mask & __GFP_WRITE);
+	int nr_fair_skipped = 0, nr_fair_eligible = 0, nr_fail_watermark = 0;
+	bool zonelist_rescan;
 
 zonelist_scan:
+	zonelist_rescan = false;
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
@@ -1950,11 +1970,15 @@ zonelist_scan:
 		 * time the page has in memory before being reclaimed.
 		 */
 		if (alloc_flags & ALLOC_FAIR) {
-			if (!zone_local(preferred_zone, zone))
-				continue;
-			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
+			if (!zone_local(preferred_zone, zone) || !z->fair_enabled)
+				break;
+			nr_fair_eligible++;
+			if (zone_is_fair_depleted(zone)) {
+				nr_fair_skipped++;
 				continue;
+			}
 		}
+
 		/*
 		 * When allocating a page cache page for writing, we
 		 * want to get it from a zone that is within its dirty
@@ -1994,6 +2018,8 @@ zonelist_scan:
 			if (alloc_flags & ALLOC_NO_WATERMARKS)
 				goto try_this_zone;
 
+			nr_fail_watermark++;
+
 			if (IS_ENABLED(CONFIG_NUMA) &&
 					!did_zlc_setup && nr_online_nodes > 1) {
 				/*
@@ -2050,7 +2076,7 @@ zonelist_scan:
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(preferred_zone, zone, order,
+		page = buffered_rmqueue(preferred_zone, z, zone, order,
 						gfp_mask, migratetype);
 		if (page)
 			break;
@@ -2059,13 +2085,7 @@ this_zone_full:
 			zlc_mark_zone_full(zonelist, z);
 	}
 
-	if (unlikely(IS_ENABLED(CONFIG_NUMA) && page == NULL && zlc_active)) {
-		/* Disable zlc cache for second zonelist scan */
-		zlc_active = 0;
-		goto zonelist_scan;
-	}
-
-	if (page)
+	if (page) {
 		/*
 		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
 		 * necessary to allocate the page. The expectation is
@@ -2074,8 +2094,36 @@ this_zone_full:
 		 * for !PFMEMALLOC purposes.
 		 */
 		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
+		return page;
+	}
 
-	return page;
+	if (unlikely(IS_ENABLED(CONFIG_NUMA) && zlc_active)) {
+		/* Disable zlc cache for second zonelist scan */
+		zlc_active = 0;
+		zonelist_rescan = true;
+	}
+
+	/*
+	 * The first pass spreads allocations fairly within the local node.
+	 * Reset the counters if necessary and recheck the zonelist taking
+	 * the remote nodes and the fact that a batch count might have
+	 * failed due to per-cpu vmstat accounting drift into account. This
+	 * is preferable to entering the slowpath and waking kswapd.
+	 */
+	if (alloc_flags & ALLOC_FAIR) {
+		alloc_flags &= ~ALLOC_FAIR;
+		if (nr_online_nodes > 1)
+			zonelist_rescan = true;
+		if (nr_fail_watermark || nr_fair_eligible == nr_fair_skipped) {
+			zonelist_rescan = true;
+			reset_alloc_batches(preferred_zone);
+		}
+	}
+
+	if (zonelist_rescan)
+		goto zonelist_scan;
+
+	return NULL;
 }
 
 /*
@@ -2396,28 +2444,6 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-static void reset_alloc_batches(struct zonelist *zonelist,
-				enum zone_type high_zoneidx,
-				struct zone *preferred_zone)
-{
-	struct zoneref *z;
-	struct zone *zone;
-
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
-		/*
-		 * Only reset the batches of zones that were actually
-		 * considered in the fairness pass, we don't want to
-		 * trash fairness information for zones that are not
-		 * actually part of this zonelist's round-robin cycle.
-		 */
-		if (!zone_local(preferred_zone, zone))
-			continue;
-		mod_zone_page_state(zone, NR_ALLOC_BATCH,
-			high_wmark_pages(zone) - low_wmark_pages(zone) -
-			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
-	}
-}
-
 static void wake_all_kswapds(unsigned int order,
 			     struct zonelist *zonelist,
 			     enum zone_type high_zoneidx,
@@ -2718,7 +2744,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	struct page *page = NULL;
 	int migratetype = allocflags_to_migratetype(gfp_mask);
 	unsigned int cpuset_mems_cookie;
-	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET|ALLOC_FAIR;
+	int alloc_flags = ALLOC_WMARK_LOW|ALLOC_CPUSET;
 	int classzone_idx;
 
 	gfp_mask &= gfp_allowed_mask;
@@ -2749,33 +2775,18 @@ retry_cpuset:
 		goto out;
 	classzone_idx = zonelist_zone_idx(preferred_zoneref);
 
+	if (preferred_zoneref->fair_enabled)
+		alloc_flags |= ALLOC_FAIR;
 #ifdef CONFIG_CMA
 	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 #endif
-retry:
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
 			preferred_zone, classzone_idx, migratetype);
 	if (unlikely(!page)) {
 		/*
-		 * The first pass makes sure allocations are spread
-		 * fairly within the local node.  However, the local
-		 * node might have free pages left after the fairness
-		 * batches are exhausted, and remote zones haven't
-		 * even been considered yet.  Try once more without
-		 * fairness, and include remote zones now, before
-		 * entering the slowpath and waking kswapd: prefer
-		 * spilling to a remote zone over swapping locally.
-		 */
-		if (alloc_flags & ALLOC_FAIR) {
-			reset_alloc_batches(zonelist, high_zoneidx,
-					    preferred_zone);
-			alloc_flags &= ~ALLOC_FAIR;
-			goto retry;
-		}
-		/*
 		 * Runtime PM, block IO and its error handling path
 		 * can deadlock because I/O on the device might not
 		 * complete.
@@ -3288,10 +3299,19 @@ void show_free_areas(unsigned int filter)
 	show_swap_cache_info();
 }
 
-static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
+static int zoneref_set_zone(pg_data_t *pgdat, struct zone *zone,
+			struct zoneref *zoneref, struct zone *preferred_zone)
 {
+	int zone_type = zone_idx(zone);
+	bool fair_enabled = zone_local(zone, preferred_zone);
+	if (zone_type == 0 &&
+			zone->managed_pages < (pgdat->node_present_pages >> 4))
+		fair_enabled = false;
+
 	zoneref->zone = zone;
-	zoneref->zone_idx = zone_idx(zone);
+	zoneref->zone_idx = zone_type;
+	zoneref->fair_enabled = fair_enabled;
+	return fair_enabled;
 }
 
 /*
@@ -3304,17 +3324,26 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
 {
 	struct zone *zone;
 	enum zone_type zone_type = MAX_NR_ZONES;
+	struct zone *preferred_zone = NULL;
+	int nr_fair = 0;
 
 	do {
 		zone_type--;
 		zone = pgdat->node_zones + zone_type;
 		if (populated_zone(zone)) {
-			zoneref_set_zone(zone,
-				&zonelist->_zonerefs[nr_zones++]);
+			if (!preferred_zone)
+				preferred_zone = zone;
+
+			nr_fair += zoneref_set_zone(pgdat, zone,
+				&zonelist->_zonerefs[nr_zones++],
+				preferred_zone);
 			check_highest_zone(zone_type);
 		}
 	} while (zone_type);
 
+	if (nr_fair <= 1)
+		zonelist->_zonerefs[0].fair_enabled = false;
+
 	return nr_zones;
 }
 
@@ -3511,6 +3540,7 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
 	j = build_zonelists_node(NODE_DATA(node), zonelist, j);
 	zonelist->_zonerefs[j].zone = NULL;
 	zonelist->_zonerefs[j].zone_idx = 0;
+	zonelist->_zonerefs[j].fair_enabled = false;
 }
 
 /*
@@ -3539,8 +3569,9 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 {
 	int pos, j, node;
 	int zone_type;		/* needs to be signed */
-	struct zone *z;
+	struct zone *z, *preferred_zone = NULL;
 	struct zonelist *zonelist;
+	int nr_fair = 0;
 
 	zonelist = &pgdat->node_zonelists[0];
 	pos = 0;
@@ -3548,15 +3579,22 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 		for (j = 0; j < nr_nodes; j++) {
 			node = node_order[j];
 			z = &NODE_DATA(node)->node_zones[zone_type];
+			if (!preferred_zone)
+				preferred_zone = z;
 			if (populated_zone(z)) {
-				zoneref_set_zone(z,
-					&zonelist->_zonerefs[pos++]);
+				nr_fair += zoneref_set_zone(pgdat, z,
+					&zonelist->_zonerefs[pos++],
+					preferred_zone);
 				check_highest_zone(zone_type);
 			}
 		}
 	}
 	zonelist->_zonerefs[pos].zone = NULL;
 	zonelist->_zonerefs[pos].zone_idx = 0;
+	zonelist->_zonerefs[pos].fair_enabled = false;
+
+	if (nr_fair <= 1)
+		zonelist->_zonerefs[0].fair_enabled = false;
 }
 
 static int default_zonelist_order(void)
@@ -5681,8 +5719,7 @@ static void __setup_per_zone_wmarks(void)
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
 
 		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
-				      high_wmark_pages(zone) -
-				      low_wmark_pages(zone) -
+				      (zone->managed_pages >> 2) -
 				      zone_page_state(zone, NR_ALLOC_BATCH));
 
 		setup_zone_migrate_reserve(zone);
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
