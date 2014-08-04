Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2243D6B0068
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 04:56:18 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id x48so7337179wes.19
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 01:56:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fu18si32280496wjc.113.2014.08.04.01.56.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 01:56:08 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 02/13] mm, compaction: defer each zone individually instead of preferred zone
Date: Mon,  4 Aug 2014 10:55:13 +0200
Message-Id: <1407142524-2025-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
References: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

When direct sync compaction is often unsuccessful, it may become deferred for
some time to avoid further useless attempts, both sync and async. Successful
high-order allocations un-defer compaction, while further unsuccessful
compaction attempts prolong the copmaction deferred period.

Currently the checking and setting deferred status is performed only on the
preferred zone of the allocation that invoked direct compaction. But compaction
itself is attempted on all eligible zones in the zonelist, so the behavior is
suboptimal and may lead both to scenarios where 1) compaction is attempted
uselessly, or 2) where it's not attempted despite good chances of succeeding,
as shown on the examples below:

1) A direct compaction with Normal preferred zone failed and set deferred
   compaction for the Normal zone. Another unrelated direct compaction with
   DMA32 as preferred zone will attempt to compact DMA32 zone even though
   the first compaction attempt also included DMA32 zone.

   In another scenario, compaction with Normal preferred zone failed to compact
   Normal zone, but succeeded in the DMA32 zone, so it will not defer
   compaction. In the next attempt, it will try Normal zone which will fail
   again, instead of skipping Normal zone and trying DMA32 directly.

2) Kswapd will balance DMA32 zone and reset defer status based on watermarks
   looking good. A direct compaction with preferred Normal zone will skip
   compaction of all zones including DMA32 because Normal was still deferred.
   The allocation might have succeeded in DMA32, but won't.

This patch makes compaction deferring work on individual zone basis instead of
preferred zone. For each zone, it checks compaction_deferred() to decide if the
zone should be skipped. If watermarks fail after compacting the zone,
defer_compaction() is called. The zone where watermarks passed can still be
deferred when the allocation attempt is unsuccessful. When allocation is
successful, compaction_defer_reset() is called for the zone containing the
allocated page. This approach should approximate calling defer_compaction()
only on zones where compaction was attempted and did not yield allocated page.
There might be corner cases but that is inevitable as long as the decision
to stop compacting dues not guarantee that a page will be allocated.

Due to a new COMPACT_DEFERRED return value, some functions relying implicitly
on COMPACT_SKIPPED = 0 had to be updated, with comments made more accurate.
The did_some_progress output parameter of __alloc_pages_direct_compact() is
removed completely, as the caller actually does not use it after compaction
sets it - it is only considered when direct reclaim sets it.

During testing on a two-node machine with a single very small Normal zone on
node 1, this patch has improved success rates in stress-highalloc mmtests
benchmark. The success here were previously made worse by commit 3a025760fc15
("mm: page_alloc: spill to remote nodes before waking kswapd") as kswapd was
no longer resetting often enough the deferred compaction for the Normal zone,
and DMA32 zones on both nodes were thus not considered for compaction.
On different machine, success rates were improved with __GFP_NO_KSWAPD
allocations.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Minchan Kim <minchan@kernel.org>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: David Rientjes <rientjes@google.com>
---
 include/linux/compaction.h | 16 ++++++++------
 mm/compaction.c            | 32 +++++++++++++++++++++-------
 mm/page_alloc.c            | 52 ++++++++++++++++++++++++++--------------------
 mm/vmscan.c                | 14 +++++++++----
 4 files changed, 74 insertions(+), 40 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 01e3132..b2e4c92 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -2,14 +2,16 @@
 #define _LINUX_COMPACTION_H
 
 /* Return values for compact_zone() and try_to_compact_pages() */
+/* compaction didn't start as it was deferred due to past failures */
+#define COMPACT_DEFERRED	0
 /* compaction didn't start as it was not possible or direct reclaim was more suitable */
-#define COMPACT_SKIPPED		0
+#define COMPACT_SKIPPED		1
 /* compaction should continue to another pageblock */
-#define COMPACT_CONTINUE	1
+#define COMPACT_CONTINUE	2
 /* direct compaction partially compacted a zone and there are suitable pages */
-#define COMPACT_PARTIAL		2
+#define COMPACT_PARTIAL		3
 /* The full zone was compacted */
-#define COMPACT_COMPLETE	3
+#define COMPACT_COMPLETE	4
 
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
@@ -22,7 +24,8 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
-			enum migrate_mode mode, bool *contended);
+			enum migrate_mode mode, bool *contended,
+			struct zone **candidate_zone);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order);
@@ -91,7 +94,8 @@ static inline bool compaction_restarting(struct zone *zone, int order)
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			enum migrate_mode mode, bool *contended)
+			enum migrate_mode mode, bool *contended,
+			struct zone **candidate_zone)
 {
 	return COMPACT_CONTINUE;
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index 5175019..68803c8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1122,27 +1122,26 @@ int sysctl_extfrag_threshold = 500;
  * @nodemask: The allowed nodes to allocate from
  * @mode: The migration mode for async, sync light, or sync migration
  * @contended: Return value that is true if compaction was aborted due to lock contention
- * @page: Optionally capture a free page of the requested order during compaction
+ * @candidate_zone: Return the zone where we think allocation should succeed
  *
  * This is the main entry point for direct page compaction.
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			enum migrate_mode mode, bool *contended)
+			enum migrate_mode mode, bool *contended,
+			struct zone **candidate_zone)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	int may_enter_fs = gfp_mask & __GFP_FS;
 	int may_perform_io = gfp_mask & __GFP_IO;
 	struct zoneref *z;
 	struct zone *zone;
-	int rc = COMPACT_SKIPPED;
+	int rc = COMPACT_DEFERRED;
 	int alloc_flags = 0;
 
 	/* Check if the GFP flags allow compaction */
 	if (!order || !may_enter_fs || !may_perform_io)
-		return rc;
-
-	count_compact_event(COMPACTSTALL);
+		return COMPACT_SKIPPED;
 
 #ifdef CONFIG_CMA
 	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
@@ -1153,14 +1152,33 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 								nodemask) {
 		int status;
 
+		if (compaction_deferred(zone, order))
+			continue;
+
 		status = compact_zone_order(zone, order, gfp_mask, mode,
 						contended);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
 		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0,
-				      alloc_flags))
+				      alloc_flags)) {
+			*candidate_zone = zone;
+			/*
+			 * We think the allocation will succeed in this zone,
+			 * but it is not certain, hence the false. The caller
+			 * will repeat this with true if allocation indeed
+			 * succeeds in this zone.
+			 */
+			compaction_defer_reset(zone, order, false);
 			break;
+		} else if (mode != MIGRATE_ASYNC) {
+			/*
+			 * We think that allocation won't succeed in this zone
+			 * so we defer compaction there. If it ends up
+			 * succeeding after all, it will be reset.
+			 */
+			defer_compaction(zone, order);
+		}
 	}
 
 	return rc;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d0e3d2f..e8affbf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2296,24 +2296,28 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
 	int classzone_idx, int migratetype, enum migrate_mode mode,
-	bool *contended_compaction, bool *deferred_compaction,
-	unsigned long *did_some_progress)
+	bool *contended_compaction, bool *deferred_compaction)
 {
-	if (!order)
-		return NULL;
+	struct zone *last_compact_zone = NULL;
+	unsigned long compact_result;
 
-	if (compaction_deferred(preferred_zone, order)) {
-		*deferred_compaction = true;
+
+	if (!order)
 		return NULL;
-	}
 
 	current->flags |= PF_MEMALLOC;
-	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
+	compact_result = try_to_compact_pages(zonelist, order, gfp_mask,
 						nodemask, mode,
-						contended_compaction);
+						contended_compaction,
+						&last_compact_zone);
 	current->flags &= ~PF_MEMALLOC;
 
-	if (*did_some_progress != COMPACT_SKIPPED) {
+	if (compact_result > COMPACT_DEFERRED)
+		count_vm_event(COMPACTSTALL);
+	else
+		*deferred_compaction = true;
+
+	if (compact_result > COMPACT_SKIPPED) {
 		struct page *page;
 
 		/* Page migration frees to the PCP lists but we want merging */
@@ -2324,27 +2328,31 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 				order, zonelist, high_zoneidx,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
 				preferred_zone, classzone_idx, migratetype);
+
 		if (page) {
-			preferred_zone->compact_blockskip_flush = false;
-			compaction_defer_reset(preferred_zone, order, true);
+			struct zone *zone = page_zone(page);
+
+			zone->compact_blockskip_flush = false;
+			compaction_defer_reset(zone, order, true);
 			count_vm_event(COMPACTSUCCESS);
 			return page;
 		}
 
 		/*
+		 * last_compact_zone is where try_to_compact_pages thought
+		 * allocation should succeed, so it did not defer compaction.
+		 * But now we know that it didn't succeed, so we do the defer.
+		 */
+		if (last_compact_zone && mode != MIGRATE_ASYNC)
+			defer_compaction(last_compact_zone, order);
+
+		/*
 		 * It's bad if compaction run occurs and fails.
 		 * The most likely reason is that pages exist,
 		 * but not enough to satisfy watermarks.
 		 */
 		count_vm_event(COMPACTFAIL);
 
-		/*
-		 * As async compaction considers a subset of pageblocks, only
-		 * defer if the failure was a sync compaction failure.
-		 */
-		if (mode != MIGRATE_ASYNC)
-			defer_compaction(preferred_zone, order);
-
 		cond_resched();
 	}
 
@@ -2633,8 +2641,7 @@ rebalance:
 					preferred_zone,
 					classzone_idx, migratetype,
 					migration_mode, &contended_compaction,
-					&deferred_compaction,
-					&did_some_progress);
+					&deferred_compaction);
 	if (page)
 		goto got_pg;
 
@@ -2726,8 +2733,7 @@ rebalance:
 					preferred_zone,
 					classzone_idx, migratetype,
 					migration_mode, &contended_compaction,
-					&deferred_compaction,
-					&did_some_progress);
+					&deferred_compaction);
 		if (page)
 			goto got_pg;
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d698f4f..d07f2ff 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2309,7 +2309,10 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc)
 	return reclaimable;
 }
 
-/* Returns true if compaction should go ahead for a high-order request */
+/*
+ * Returns true if compaction should go ahead for a high-order request, or
+ * the high-order allocation would succeed without compaction.
+ */
 static inline bool compaction_ready(struct zone *zone, int order)
 {
 	unsigned long balance_gap, watermark;
@@ -2333,8 +2336,11 @@ static inline bool compaction_ready(struct zone *zone, int order)
 	if (compaction_deferred(zone, order))
 		return watermark_ok;
 
-	/* If compaction is not ready to start, keep reclaiming */
-	if (!compaction_suitable(zone, order))
+	/*
+	 * If compaction is not ready to start and allocation is not likely
+	 * to succeed without it, then keep reclaiming.
+	 */
+	if (compaction_suitable(zone, order) == COMPACT_SKIPPED)
 		return false;
 
 	return watermark_ok;
@@ -2812,7 +2818,7 @@ static bool zone_balanced(struct zone *zone, int order,
 		return false;
 
 	if (IS_ENABLED(CONFIG_COMPACTION) && order &&
-	    !compaction_suitable(zone, order))
+	    compaction_suitable(zone, order) == COMPACT_SKIPPED)
 		return false;
 
 	return true;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
