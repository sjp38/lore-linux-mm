Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9742F6B04B6
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:07:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h126so11280294wmf.10
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 09:07:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r7si8332027wrc.241.2017.07.27.09.07.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 09:07:13 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 6/6] mm: make kcompactd more proactive
Date: Thu, 27 Jul 2017 18:07:01 +0200
Message-Id: <20170727160701.9245-7-vbabka@suse.cz>
In-Reply-To: <20170727160701.9245-1-vbabka@suse.cz>
References: <20170727160701.9245-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

Kcompactd activity is currently tied to kswapd - it is woken up when kswapd
goes to sleep, and compacts to make a single high-order page available, of the
order that was used to wake up kswapd. This leaves the rest of free pages
fragmented and results in direct compaction when the demand for fresh
high-order pages is higher than a single page per kswapd cycle.

Another extreme would be to let kcompactd compact whole zone the same way as
manual compaction from /proc interface. This would be wasteful if the resulting
high-order pages would be not needed, but just split back to base pages for
allocations.

This patch aims to adjust the kcompactd effort through observed demand for
high-order pages. This is done by hooking into alloc_pages_slowpath() and
counting (per each order > 0) allocation attempts that would pass the order-0
watermarks, but don't have the high-order page available. This demand is
(currently) recorded per node and then redistributed per zones in each node
according to their relative sizes.

The redistribution considers the current recorded failed attempts together with
the value used in the previous kcompactd cycle. If there were any recorded
failed attempts for the current cycle, it means the previous kcompactd activity
was insufficient, so the two values are added up. If there were zero failed
attempts it means either the previous amount of activity was optimum, or that
the demand decreased. We cannot know that without recording also successful
attempts, which would add overhead to allocator fast paths, so we use
exponential moving average to decay the kcompactd target in such case.
In any case, the target is capped to high watermark worth of base pages, since
that's the kswapd's target when balancing.

Kcompactd then uses a different termination criteria than direct compaction.
It checks whether for each order, the recorded number of attempted allocations
would fit within the free pages of that order of with possible splitting of
higher orders, assuming there would be no allocations of other orders. This
should make kcompactd effort reflect the high-order demand.

In the worst case, the demand is so high that kcompactd will in fact compact
the whole zone and would have to be run with higher frequency than kswapd to
make a larger difference. That possibility can be explored later.
---
 include/linux/compaction.h |   6 ++
 include/linux/mmzone.h     |   3 +
 mm/compaction.c            | 222 ++++++++++++++++++++++++++++++++++++++++++---
 mm/page_alloc.c            |  13 +++
 4 files changed, 233 insertions(+), 11 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 0d8415820fc3..b342a80bde17 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -176,6 +176,8 @@ bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
 extern int kcompactd_run(int nid);
 extern void kcompactd_stop(int nid);
 extern void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx);
+extern void kcompactd_inc_free_target(gfp_t gfp_mask, unsigned int order,
+				int alloc_flags, struct alloc_context *ac);
 
 #else
 static inline void reset_isolation_suitable(pg_data_t *pgdat)
@@ -224,6 +226,10 @@ static inline void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_i
 {
 }
 
+static inline void kcompactd_inc_free_target(gfp_t gfp_mask, unsigned int order,
+				int alloc_flags, struct alloc_context *ac)
+{
+}
 #endif /* CONFIG_COMPACTION */
 
 #if defined(CONFIG_COMPACTION) && defined(CONFIG_SYSFS) && defined(CONFIG_NUMA)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ef6a13b7bd3e..73d1a569bad2 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -484,6 +484,7 @@ struct zone {
 	unsigned int		compact_considered;
 	unsigned int		compact_defer_shift;
 	int			compact_order_failed;
+	unsigned int		compact_free_target[MAX_ORDER];
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
@@ -643,6 +644,8 @@ typedef struct pglist_data {
 	enum zone_type kcompactd_classzone_idx;
 	wait_queue_head_t kcompactd_wait;
 	struct task_struct *kcompactd;
+	atomic_t compact_free_target[MAX_ORDER];
+	unsigned int compact_free_target_ema[MAX_ORDER];
 #endif
 #ifdef CONFIG_NUMA_BALANCING
 	/* Lock serializing the migrate rate limiting window */
diff --git a/mm/compaction.c b/mm/compaction.c
index 6647359dc8e3..6843cf74bfaa 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -21,6 +21,7 @@
 #include <linux/kthread.h>
 #include <linux/freezer.h>
 #include <linux/page_owner.h>
+#include <linux/cpuset.h>
 #include "internal.h"
 
 #ifdef CONFIG_COMPACTION
@@ -1286,6 +1287,56 @@ static inline bool is_via_compact_memory(int order)
 	return order == -1;
 }
 
+static enum compact_result kcompactd_finished(struct zone *zone)
+{
+	unsigned int order;
+	unsigned long sum_nr_free = 0;
+	bool success = true;
+	unsigned long watermark;
+	unsigned long zone_nr_free;
+
+	zone_nr_free = zone_page_state(zone, NR_FREE_PAGES);
+
+	for (order = MAX_ORDER - 1; order > 0; order--) {
+		unsigned long nr_free;
+		unsigned long target;
+
+		nr_free = zone->free_area[order].nr_free;
+		sum_nr_free += nr_free;
+
+		/*
+		 * If we can't achieve the target via compacting the existing
+		 * free pages, no point in continuing compaction.
+		 */
+		target = zone->compact_free_target[order];
+		if (sum_nr_free < min(target, zone_nr_free >> order)) {
+			success = false;
+			break;
+		}
+
+		/*
+		 * Each free page of current order can fit two pages of the
+		 * next lower order
+		 */
+		sum_nr_free <<= 1UL;
+	}
+
+	if (success)
+		return COMPACT_SUCCESS;
+
+	/*
+	 * If number of pages dropped below low watermark, kswapd will be woken
+	 * up, so it's better for kcompactd to give up for now.
+	 */
+	watermark = low_wmark_pages(zone);
+	if (!__zone_watermark_ok(zone, 0, watermark, zone_idx(zone), 0,
+								zone_nr_free))
+		return COMPACT_PARTIAL_SKIPPED;
+
+	return COMPACT_CONTINUE;
+
+}
+
 static enum compact_result __compact_finished(struct zone *zone,
 						struct compact_control *cc)
 {
@@ -1330,6 +1381,13 @@ static enum compact_result __compact_finished(struct zone *zone,
 			return COMPACT_CONTINUE;
 	}
 
+	/*
+	 * Compaction that's neither direct nor is_via_compact_memory() has to
+	 * be from kcompactd, which has different criteria.
+	 */
+	if (!cc->direct_compaction)
+		return kcompactd_finished(zone);
+
 	/* Direct compactor: Is a suitable page free? */
 	for (order = cc->order; order < MAX_ORDER; order++) {
 		struct free_area *area = &zone->free_area[order];
@@ -1381,14 +1439,9 @@ static enum compact_result __compact_finished(struct zone *zone,
 	 * In that case, let's stop now and not waste time searching for migrate
 	 * pages.
 	 * For direct compaction, the check is close to the one in
-	 * __isolate_free_page().  For kcompactd, we use the low watermark,
-	 * because that's the point when kswapd gets woken up, so it's better
-	 * for kcompactd to let kswapd free memory first.
+	 * __isolate_free_page().
 	 */
-	if (cc->direct_compaction)
-		watermark = min_wmark_pages(zone);
-	else
-		watermark = low_wmark_pages(zone);
+	watermark = min_wmark_pages(zone);
 	if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
 		return COMPACT_PARTIAL_SKIPPED;
 
@@ -1918,7 +1971,7 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
 	struct zone *zone;
 	enum zone_type classzone_idx = pgdat->kcompactd_classzone_idx;
 
-	for (zoneid = 0; zoneid <= classzone_idx; zoneid++) {
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 		zone = &pgdat->node_zones[zoneid];
 
 		if (!populated_zone(zone))
@@ -1927,11 +1980,155 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
 		if (compaction_suitable(zone, pgdat->kcompactd_max_order, 0,
 					classzone_idx) == COMPACT_CONTINUE)
 			return true;
+
+		if (kcompactd_finished(zone) == COMPACT_CONTINUE)
+			return true;
 	}
 
 	return false;
 }
 
+void kcompactd_inc_free_target(gfp_t gfp_mask, unsigned int order,
+				int alloc_flags, struct alloc_context *ac)
+{
+	struct zone *zone;
+	struct zoneref *zref;
+
+	// FIXME: spread over nodes instead of increasing all?
+	for_each_zone_zonelist_nodemask(zone, zref, ac->zonelist,
+					ac->high_zoneidx, ac->nodemask) {
+		unsigned long mark;
+		int nid = zone_to_nid(zone);
+		int zoneidx;
+		bool zone_not_highest = false;
+
+		/*
+		 * A kludge to avoid incrementing for the same node twice or
+		 * more, regardless of zonelist being in zone or node order.
+		 * This is to avoid allocating a nodemask on stack to mark
+		 * visited nodes.
+		 */
+		for (zoneidx = zonelist_zone_idx(zref) + 1;
+						zoneidx <= ac->high_zoneidx;
+						zoneidx++) {
+			struct zone *z = &zone->zone_pgdat->node_zones[zoneidx];
+
+			if (populated_zone(z)) {
+				zone_not_highest = true;
+				break;
+			}
+		}
+
+		if (zone_not_highest)
+			continue;
+
+		if (cpusets_enabled() &&
+				(alloc_flags & ALLOC_CPUSET) &&
+				!cpuset_zone_allowed(zone, gfp_mask))
+			continue;
+
+		/* The high-order allocation should succeed on this node */
+		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
+		if (zone_watermark_ok(zone, order, mark,
+				       ac_classzone_idx(ac), alloc_flags))
+			continue;
+
+		/*
+		 * High-order allocation wouldn't succeed. If order-0
+		 * allocations of same total size would pass the watermarks,
+		 * we know it's due to fragmentation, and kcompactd trying
+		 * harder could help.
+		 */
+		mark += (1UL << order) - 1;
+		if (zone_watermark_ok(zone, 0, mark, ac_classzone_idx(ac),
+								alloc_flags)) {
+			/*
+			 * TODO: consider prioritizing based on gfp_mask, e.g.
+			 * THP faults are opportunistic and should not result
+			 * in perpetual kcompactd activity. Allocation attempts
+			 * without easy fallback should be more important.
+			 */
+			atomic_inc(&NODE_DATA(nid)->compact_free_target[order]);
+		}
+	}
+}
+
+static void kcompactd_adjust_free_targets(pg_data_t *pgdat)
+{
+	unsigned long managed_pages = 0;
+	unsigned long high_wmark = 0;
+	int zoneid, order;
+	struct zone *zone;
+
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+		zone = &pgdat->node_zones[zoneid];
+
+		if (!populated_zone(zone))
+			continue;
+
+		managed_pages += zone->managed_pages;
+		high_wmark += high_wmark_pages(zone);
+	}
+
+	if (!managed_pages)
+		return;
+
+	for (order = 1; order < MAX_ORDER; order++) {
+		unsigned int target;
+
+		target = atomic_xchg(&pgdat->compact_free_target[order], 0);
+
+		/*
+		 * If the target is non-zero, it means we could have done more
+		 * in the previous run, so add it to the previous run's target.
+		 * Otherwise start decaying the target.
+		 */
+		if (target)
+			target += pgdat->compact_free_target_ema[order];
+		else
+			/* Exponential moving average, coefficient 0.5 */
+			target = DIV_ROUND_UP(target
+				+ pgdat->compact_free_target_ema[order], 2);
+
+
+		/*
+		 * Limit the target by high wmark worth of pages, otherwise
+		 * kcompactd can't achieve it anyway.
+		 */
+		if ((target << order) > high_wmark)
+			target = high_wmark >> order;
+
+		pgdat->compact_free_target_ema[order] = target;
+
+		if (!target)
+			continue;
+
+		/* Distribute the target among zones */
+		for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
+
+			unsigned long zone_target = target;
+
+			zone = &pgdat->node_zones[zoneid];
+
+			if (!populated_zone(zone))
+				continue;
+
+			/* For a single zone on node, take a shortcut */
+			if (managed_pages == zone->managed_pages) {
+				zone->compact_free_target[order] = zone_target;
+				continue;
+			}
+
+			/* Take proportion of zone's page to whole node */
+			zone_target *= zone->managed_pages;
+			/* Round up for remainder of at least 1/2 */
+			zone_target = DIV_ROUND_UP_ULL(zone_target, managed_pages);
+
+			zone->compact_free_target[order] = zone_target;
+		}
+	}
+}
+
 static void kcompactd_do_work(pg_data_t *pgdat)
 {
 	/*
@@ -1954,7 +2151,9 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 							cc.classzone_idx);
 	count_compact_event(KCOMPACTD_WAKE);
 
-	for (zoneid = 0; zoneid <= cc.classzone_idx; zoneid++) {
+	kcompactd_adjust_free_targets(pgdat);
+
+	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 		int status;
 
 		zone = &pgdat->node_zones[zoneid];
@@ -1964,8 +2163,9 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		if (compaction_deferred(zone, cc.order))
 			continue;
 
-		if (compaction_suitable(zone, cc.order, 0, zoneid) !=
+		if ((compaction_suitable(zone, cc.order, 0, zoneid) !=
 							COMPACT_CONTINUE)
+			&& kcompactd_finished(zone) != COMPACT_CONTINUE)
 			continue;
 
 		cc.nr_freepages = 0;
@@ -1982,7 +2182,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 
 		if (status == COMPACT_SUCCESS) {
 			compaction_defer_reset(zone, cc.order, false);
-		} else if (status == COMPACT_PARTIAL_SKIPPED || status == COMPACT_COMPLETE) {
+		} else if (status == COMPACT_COMPLETE) {
 			/*
 			 * We use sync migration mode here, so we defer like
 			 * sync direct compaction does.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index faed38d52721..82483ce9a202 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3780,6 +3780,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto got_pg;
 
 	/*
+	 * If it looks like increased kcompactd effort could have spared
+	 * us from direct compaction (or allocation failure if we cannot
+	 * compact), increase kcompactd's target.
+	 */
+	if (order > 0)
+		kcompactd_inc_free_target(gfp_mask, order, alloc_flags, ac);
+
+	/*
 	 * For costly allocations, try direct compaction first, as it's likely
 	 * that we have enough base pages and don't need to reclaim. For non-
 	 * movable high-order allocations, do that as well, as compaction will
@@ -6038,6 +6046,7 @@ static unsigned long __paginginit calc_memmap_size(unsigned long spanned_pages,
  */
 static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 {
+	int i;
 	enum zone_type j;
 	int nid = pgdat->node_id;
 	int ret;
@@ -6057,6 +6066,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
 	init_waitqueue_head(&pgdat->pfmemalloc_wait);
 #ifdef CONFIG_COMPACTION
 	init_waitqueue_head(&pgdat->kcompactd_wait);
+	for (i = 0; i < MAX_ORDER; i++) {
+		atomic_set(&pgdat->compact_free_target[i], 0);
+		pgdat->compact_free_target_ema[i] = 0;
+	}
 #endif
 	pgdat_page_ext_init(pgdat);
 	spin_lock_init(&pgdat->lru_lock);
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
