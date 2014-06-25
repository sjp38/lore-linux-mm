Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id AB6E56B003D
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 03:59:06 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id u57so1552695wes.31
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 00:59:06 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d11si5386618wic.34.2014.06.25.00.59.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 25 Jun 2014 00:59:01 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/6] mm: page_alloc: Reduce cost of the fair zone allocation policy
Date: Wed, 25 Jun 2014 08:58:47 +0100
Message-Id: <1403683129-10814-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1403683129-10814-1-git-send-email-mgorman@suse.de>
References: <1403683129-10814-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Jeff Moyer <jmoyer@redhat.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.de>

The fair zone allocation policy round-robins allocations between zones
within a node to avoid age inversion problems during reclaim. If the
first allocation fails, the batch counts is reset and a second attempt
made before entering the slow path.

One assumption made with this scheme is that batches expire at roughly the
same time and the resets each time are justified. This assumption does not
hold when zones reach their low watermark as the batches will be consumed
at uneven rates.  Allocation failure due to watermark depletion result in
additional zonelist scans for the reset and another watermark check before
hitting the slowpath.

This patch makes a number of changes that should reduce the overall cost

o Do not apply the fair zone policy to small zones such as DMA
o Abort the fair zone allocation policy once remote or small zones are
  encountered
o Use a simplier scan when resetting NR_ALLOC_BATCH
o Use a simple flag to identify depleted zones instead of accessing a
  potentially write-intensive cache line for counters
o Track zones who met the watermark but failed the NR_ALLOC_BATCH check
  to avoid doing a rescan of the zonelist when the counters are reset

On UMA machines, the effect is marginal. Even judging from system CPU
usage it's small for the tiobench test

          3.16.0-rc2  3.16.0-rc2
            checklow    fairzone
User          396.24      396.23
System        395.23      391.50
Elapsed      5182.65     5165.49

And the number of pages allocated from each zone is comparable

                            3.16.0-rc2  3.16.0-rc2
                              checklow    fairzone
DMA allocs                           0           0
DMA32 allocs                   7374217     7920241
Normal allocs                999277551   996568115

On NUMA machines, the scanning overhead is higher as zones are scanned
that are ineligible for use by zone allocation policy. This patch fixes
the zone-order zonelist policy and reduces the numbers of zones scanned
by the allocator.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |   7 ++
 mm/mm_init.c           |   5 +-
 mm/page_alloc.c        | 179 ++++++++++++++++++++++++++++++++-----------------
 3 files changed, 128 insertions(+), 63 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index a2f6443..afb08be 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -534,6 +534,7 @@ typedef enum {
 	ZONE_WRITEBACK,			/* reclaim scanning has recently found
 					 * many pages under writeback
 					 */
+	ZONE_FAIR_DEPLETED,		/* fair zone policy batch depleted */
 } zone_flags_t;
 
 static inline void zone_set_flag(struct zone *zone, zone_flags_t flag)
@@ -571,6 +572,11 @@ static inline int zone_is_reclaim_locked(const struct zone *zone)
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
@@ -694,6 +700,7 @@ struct zonelist_cache;
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
index ebbdbcd..e954bf1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1541,10 +1541,11 @@ int split_free_page(struct page *page)
  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
  * or two.
  */
-static inline
+static
 struct page *buffered_rmqueue(struct zone *preferred_zone,
 			struct zone *zone, unsigned int order,
-			gfp_t gfp_flags, int migratetype)
+			gfp_t gfp_flags, int migratetype,
+			bool acct_fair)
 {
 	unsigned long flags;
 	struct page *page;
@@ -1596,7 +1597,11 @@ again:
 					  get_freepage_migratetype(page));
 	}
 
-	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
+	if (acct_fair) {
+		__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
+		if (zone_page_state(zone, NR_ALLOC_BATCH) == 0)
+			zone_set_flag(zone, ZONE_FAIR_DEPLETED);
+	}
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
@@ -1908,6 +1913,20 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 
 #endif	/* CONFIG_NUMA */
 
+static void reset_alloc_batches(struct zone *preferred_zone)
+{
+	struct zone *zone = preferred_zone->zone_pgdat->node_zones;
+
+	do {
+		if (!zone_is_fair_depleted(zone))
+			continue;
+		mod_zone_page_state(zone, NR_ALLOC_BATCH,
+			high_wmark_pages(zone) - low_wmark_pages(zone) -
+			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
+		zone_clear_flag(zone, ZONE_FAIR_DEPLETED);
+	} while (zone++ != preferred_zone);
+}
+
 /*
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
@@ -1925,8 +1944,12 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
 				(gfp_mask & __GFP_WRITE);
+	int nr_fair_skipped = 0;
+	struct zone *fair_zone = NULL;
+	bool zonelist_rescan;
 
 zonelist_scan:
+	zonelist_rescan = false;
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
@@ -1949,11 +1972,15 @@ zonelist_scan:
 		 * time the page has in memory before being reclaimed.
 		 */
 		if (alloc_flags & ALLOC_FAIR) {
-			if (!zone_local(preferred_zone, zone))
-				continue;
-			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
+			if (!zone_local(preferred_zone, zone) || !z->fair_enabled)
+				break;
+
+			if (fair_zone && zone_is_fair_depleted(zone)) {
+				nr_fair_skipped++;
 				continue;
+			}
 		}
+
 		/*
 		 * When allocating a page cache page for writing, we
 		 * want to get it from a zone that is within its dirty
@@ -2049,22 +2076,27 @@ zonelist_scan:
 		}
 
 try_this_zone:
+		if (alloc_flags & ALLOC_FAIR) {
+			if (zone_is_fair_depleted(zone)) {
+				if (!fair_zone)
+					fair_zone = zone;
+				nr_fair_skipped++;
+				continue;
+			}
+		}
+
 		page = buffered_rmqueue(preferred_zone, zone, order,
-						gfp_mask, migratetype);
+						gfp_mask, migratetype,
+						z->fair_enabled);
 		if (page)
 			break;
+
 this_zone_full:
 		if (IS_ENABLED(CONFIG_NUMA) && zlc_active)
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
@@ -2073,8 +2105,39 @@ this_zone_full:
 		 * for !PFMEMALLOC purposes.
 		 */
 		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
+		return page;
+	}
 
-	return page;
+	if (alloc_flags & ALLOC_FAIR) {
+		if (nr_fair_skipped)
+			reset_alloc_batches(preferred_zone);
+
+		/*
+		 * If there was a zone with a depleted fair policy batch but
+		 * that made the watermark then use it now instead of stalling
+		 * waiting on kswapd to make progress
+		 */
+		if (fair_zone)
+			return buffered_rmqueue(preferred_zone, fair_zone,
+					order, gfp_mask, migratetype, true);
+
+		/* Recheck remote nodes if there are any */
+		if (nr_online_nodes > 1) {
+			alloc_flags &= ~ALLOC_FAIR;
+			zonelist_rescan = true;
+		}
+	}
+
+	if (unlikely(IS_ENABLED(CONFIG_NUMA) && zlc_active)) {
+		/* Disable zlc cache for second zonelist scan */
+		zlc_active = 0;
+		zonelist_rescan = true;
+	}
+
+	if (zonelist_rescan)
+		goto zonelist_scan;
+
+	return NULL;
 }
 
 /*
@@ -2395,28 +2458,6 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
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
@@ -2748,33 +2789,18 @@ retry_cpuset:
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
@@ -3287,10 +3313,19 @@ void show_free_areas(unsigned int filter)
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
@@ -3303,17 +3338,26 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
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
 
@@ -3510,6 +3554,7 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int node)
 	j = build_zonelists_node(NODE_DATA(node), zonelist, j);
 	zonelist->_zonerefs[j].zone = NULL;
 	zonelist->_zonerefs[j].zone_idx = 0;
+	zonelist->_zonerefs[j].fair_enabled = false;
 }
 
 /*
@@ -3538,8 +3583,9 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
 {
 	int pos, j, node;
 	int zone_type;		/* needs to be signed */
-	struct zone *z;
+	struct zone *z, *preferred_zone = NULL;
 	struct zonelist *zonelist;
+	int nr_fair = 0;
 
 	zonelist = &pgdat->node_zonelists[0];
 	pos = 0;
@@ -3547,15 +3593,26 @@ static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
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
+	/*
+	 * For this policy, the fair zone allocation policy is disabled as the
+	 * stated priority is to preserve lower zones, not balance them fairly.
+	 */
+	if (nr_fair == 1 || nr_online_nodes > 1)
+		zonelist->_zonerefs[0].fair_enabled = false;
 }
 
 static int default_zonelist_order(void)
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
