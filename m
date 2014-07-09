Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id BB7F182965
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 04:13:16 -0400 (EDT)
Received: by mail-wg0-f47.google.com with SMTP id y10so1675744wgg.18
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 01:13:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wr4si28081458wjb.15.2014.07.09.01.13.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 01:13:15 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 6/6] mm: page_alloc: Reduce cost of the fair zone allocation policy
Date: Wed,  9 Jul 2014 09:13:08 +0100
Message-Id: <1404893588-21371-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1404893588-21371-1-git-send-email-mgorman@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

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

On UMA, the benefit is negligible -- around 0.25%. On 4-socket NUMA
machine it's variable due to the variability of measuring overhead with
the vmstat changes. The system CPU overhead comparison looks like

          3.16.0-rc3  3.16.0-rc3  3.16.0-rc3
             vanilla   vmstat-v5 lowercost-v5
User          746.94      774.56      802.00
System      65336.22    32847.27    40852.33
Elapsed     27553.52    27415.04    27368.46

However it is worth noting that the overall benchmark still completed
faster and intuitively it makes sense to take as few passes as possible
through the zonelists.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |   6 +++
 mm/page_alloc.c        | 101 ++++++++++++++++++++++++++-----------------------
 2 files changed, 59 insertions(+), 48 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c0ee2ec..08a223b 100644
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
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0bf384a..c81087d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1604,6 +1604,9 @@ again:
 	}
 
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
+	if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
+	    !zone_is_fair_depleted(zone))
+		zone_set_flag(zone, ZONE_FAIR_DEPLETED);
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
@@ -1915,6 +1918,18 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 
 #endif	/* CONFIG_NUMA */
 
+static void reset_alloc_batches(struct zone *preferred_zone)
+{
+	struct zone *zone = preferred_zone->zone_pgdat->node_zones;
+
+	do {
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
@@ -1932,8 +1947,12 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
 				(gfp_mask & __GFP_WRITE);
+	int nr_fair_skipped = 0;
+	bool zonelist_rescan;
 
 zonelist_scan:
+	zonelist_rescan = false;
+
 	/*
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed_softwall() comment in kernel/cpuset.c.
@@ -1958,8 +1977,10 @@ zonelist_scan:
 		if (alloc_flags & ALLOC_FAIR) {
 			if (!zone_local(preferred_zone, zone))
 				break;
-			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
+			if (zone_is_fair_depleted(zone)) {
+				nr_fair_skipped++;
 				continue;
+			}
 		}
 		/*
 		 * When allocating a page cache page for writing, we
@@ -2065,13 +2086,7 @@ this_zone_full:
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
@@ -2080,8 +2095,37 @@ this_zone_full:
 		 * for !PFMEMALLOC purposes.
 		 */
 		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
+		return page;
+	}
 
-	return page;
+	/*
+	 * The first pass makes sure allocations are spread fairly within the
+	 * local node.  However, the local node might have free pages left
+	 * after the fairness batches are exhausted, and remote zones haven't
+	 * even been considered yet.  Try once more without fairness, and
+	 * include remote zones now, before entering the slowpath and waking
+	 * kswapd: prefer spilling to a remote zone over swapping locally.
+	 */
+	if (alloc_flags & ALLOC_FAIR) {
+		alloc_flags &= ~ALLOC_FAIR;
+		if (nr_fair_skipped) {
+			zonelist_rescan = true;
+			reset_alloc_batches(preferred_zone);
+		}
+		if (nr_online_nodes > 1)
+			zonelist_rescan = true;
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
@@ -2402,28 +2446,6 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
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
@@ -2759,29 +2781,12 @@ retry_cpuset:
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
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
