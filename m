Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 225BD6B0044
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 04:56:10 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id t60so7315930wes.34
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 01:56:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id by4si19389684wib.73.2014.08.04.01.56.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 04 Aug 2014 01:56:03 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v6 07/13] mm, compaction: khugepaged should not give up due to need_resched()
Date: Mon,  4 Aug 2014 10:55:18 +0200
Message-Id: <1407142524-2025-8-git-send-email-vbabka@suse.cz>
In-Reply-To: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
References: <1407142524-2025-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Async compaction aborts when it detects zone lock contention or need_resched()
is true. David Rientjes has reported that in practice, most direct async
compactions for THP allocation abort due to need_resched(). This means that a
second direct compaction is never attempted, which might be OK for a page
fault, but khugepaged is intended to attempt a sync compaction in such case and
in these cases it won't.

This patch replaces "bool contended" in compact_control with an int that
distinguieshes between aborting due to need_resched() and aborting due to lock
contention. This allows propagating the abort through all compaction functions
as before, but passing the abort reason up to __alloc_pages_slowpath() which
decides when to continue with direct reclaim and another compaction attempt.

Another problem is that try_to_compact_pages() did not act upon the reported
contention (both need_resched() or lock contention) immediately and would
proceed with another zone from the zonelist. When need_resched() is true, that
means initializing another zone compaction, only to check again need_resched()
in isolate_migratepages() and aborting. For zone lock contention, the
unintended consequence is that the lock contended status reported back to the
allocator is detrmined from the last zone where compaction was attempted, which
is rather arbitrary.

This patch fixes the problem in the following way:
- async compaction of a zone aborting due to need_resched() or fatal signal
  pending means that further zones should not be tried. We report
  COMPACT_CONTENDED_SCHED to the allocator.
- aborting zone compaction due to lock contention means we can still try
  another zone, since it has different set of locks. We report back
  COMPACT_CONTENDED_LOCK only if *all* zones where compaction was attempted,
  it was aborted due to lock contention.

As a result of these fixes, khugepaged will proceed with second sync compaction
as intended, when the preceding async compaction aborted due to need_resched().
Page fault compactions aborting due to need_resched() will spare some cycles
previously wasted by initializing another zone compaction only to abort again.
Lock contention will be reported only when compaction in all zones aborted due
to lock contention, and therefore it's not a good idea to try again after
reclaim.

In stress-highalloc from mmtests configured to use __GFP_NO_KSWAPD, this has
improved number of THP collapse allocations by 10%, which shows positive
effect on khugepaged. The benchmark's success rates are unchanged as it is not
recognized as khugepaged. Numbers of compact_stall and compact_fail events
have however decreased by 20%, with compact_success still a bit improved,
which is good. With benchmark configured not to use __GFP_NO_KSWAPD, there is
6% improvement in THP collapse allocations, and only slight improvement in
stalls and failures.

Reported-by: David Rientjes <rientjes@google.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Nazarewicz <mina86@mina86.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Rik van Riel <riel@redhat.com>
---
 include/linux/compaction.h | 12 +++++--
 mm/compaction.c            | 87 ++++++++++++++++++++++++++++++++++++++++------
 mm/internal.h              |  4 +--
 mm/page_alloc.c            | 43 +++++++++++++++++------
 4 files changed, 120 insertions(+), 26 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index b2e4c92..60bdf8d 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -13,6 +13,14 @@
 /* The full zone was compacted */
 #define COMPACT_COMPLETE	4
 
+/* Used to signal whether compaction detected need_sched() or lock contention */
+/* No contention detected */
+#define COMPACT_CONTENDED_NONE	0
+/* Either need_sched() was true or fatal signal pending */
+#define COMPACT_CONTENDED_SCHED	1
+/* Zone lock or lru_lock was contended in async compaction */
+#define COMPACT_CONTENDED_LOCK	2
+
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
@@ -24,7 +32,7 @@ extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *mask,
-			enum migrate_mode mode, bool *contended,
+			enum migrate_mode mode, int *contended,
 			struct zone **candidate_zone);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
@@ -94,7 +102,7 @@ static inline bool compaction_restarting(struct zone *zone, int order)
 #else
 static inline unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			enum migrate_mode mode, bool *contended,
+			enum migrate_mode mode, int *contended,
 			struct zone **candidate_zone)
 {
 	return COMPACT_CONTINUE;
diff --git a/mm/compaction.c b/mm/compaction.c
index 606c119..862c69a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -223,9 +223,21 @@ static void update_pageblock_skip(struct compact_control *cc,
 }
 #endif /* CONFIG_COMPACTION */
 
-static inline bool should_release_lock(spinlock_t *lock)
+static int should_release_lock(spinlock_t *lock)
 {
-	return need_resched() || spin_is_contended(lock);
+	/*
+	 * Sched contention has higher priority here as we may potentially
+	 * have to abort whole compaction ASAP. Returning with lock contention
+	 * means we will try another zone, and further decisions are
+	 * influenced only when all zones are lock contended. That means
+	 * potentially missing a lock contention is less critical.
+	 */
+	if (need_resched())
+		return COMPACT_CONTENDED_SCHED;
+	else if (spin_is_contended(lock))
+		return COMPACT_CONTENDED_LOCK;
+
+	return COMPACT_CONTENDED_NONE;
 }
 
 /*
@@ -240,7 +252,9 @@ static inline bool should_release_lock(spinlock_t *lock)
 static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 				      bool locked, struct compact_control *cc)
 {
-	if (should_release_lock(lock)) {
+	int contended = should_release_lock(lock);
+
+	if (contended) {
 		if (locked) {
 			spin_unlock_irqrestore(lock, *flags);
 			locked = false;
@@ -248,7 +262,7 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 
 		/* async aborts if taking too long or contended */
 		if (cc->mode == MIGRATE_ASYNC) {
-			cc->contended = true;
+			cc->contended = contended;
 			return false;
 		}
 
@@ -274,7 +288,7 @@ static inline bool compact_should_abort(struct compact_control *cc)
 	/* async compaction aborts if contended */
 	if (need_resched()) {
 		if (cc->mode == MIGRATE_ASYNC) {
-			cc->contended = true;
+			cc->contended = COMPACT_CONTENDED_SCHED;
 			return true;
 		}
 
@@ -1140,7 +1154,7 @@ out:
 }
 
 static unsigned long compact_zone_order(struct zone *zone, int order,
-		gfp_t gfp_mask, enum migrate_mode mode, bool *contended)
+		gfp_t gfp_mask, enum migrate_mode mode, int *contended)
 {
 	unsigned long ret;
 	struct compact_control cc = {
@@ -1172,14 +1186,15 @@ int sysctl_extfrag_threshold = 500;
  * @gfp_mask: The GFP mask of the current allocation
  * @nodemask: The allowed nodes to allocate from
  * @mode: The migration mode for async, sync light, or sync migration
- * @contended: Return value that is true if compaction was aborted due to lock contention
+ * @contended: Return value that determines if compaction was aborted due to
+ *	       need_resched() or lock contention
  * @candidate_zone: Return the zone where we think allocation should succeed
  *
  * This is the main entry point for direct page compaction.
  */
 unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			int order, gfp_t gfp_mask, nodemask_t *nodemask,
-			enum migrate_mode mode, bool *contended,
+			enum migrate_mode mode, int *contended,
 			struct zone **candidate_zone)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
@@ -1189,6 +1204,9 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	struct zone *zone;
 	int rc = COMPACT_DEFERRED;
 	int alloc_flags = 0;
+	int all_zones_contended = COMPACT_CONTENDED_LOCK; /* init for &= op */
+
+	*contended = COMPACT_CONTENDED_NONE;
 
 	/* Check if the GFP flags allow compaction */
 	if (!order || !may_enter_fs || !may_perform_io)
@@ -1202,13 +1220,19 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
 								nodemask) {
 		int status;
+		int zone_contended;
 
 		if (compaction_deferred(zone, order))
 			continue;
 
 		status = compact_zone_order(zone, order, gfp_mask, mode,
-						contended);
+							&zone_contended);
 		rc = max(status, rc);
+		/*
+		 * It takes at least one zone that wasn't lock contended
+		 * to clear all_zones_contended.
+		 */
+		all_zones_contended &= zone_contended;
 
 		/* If a normal allocation would succeed, stop compacting */
 		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0,
@@ -1221,8 +1245,21 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			 * succeeds in this zone.
 			 */
 			compaction_defer_reset(zone, order, false);
-			break;
-		} else if (mode != MIGRATE_ASYNC) {
+			/*
+			 * It is possible that async compaction aborted due to
+			 * need_resched() and the watermarks were ok thanks to
+			 * somebody else freeing memory. The allocation can
+			 * however still fail so we better signal the
+			 * need_resched() contention anyway (this will not
+			 * prevent the allocation attempt).
+			 */
+			if (zone_contended == COMPACT_CONTENDED_SCHED)
+				*contended = COMPACT_CONTENDED_SCHED;
+
+			goto break_loop;
+		}
+
+		if (mode != MIGRATE_ASYNC) {
 			/*
 			 * We think that allocation won't succeed in this zone
 			 * so we defer compaction there. If it ends up
@@ -1230,8 +1267,36 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			 */
 			defer_compaction(zone, order);
 		}
+
+		/*
+		 * We might have stopped compacting due to need_resched() in
+		 * async compaction, or due to a fatal signal detected. In that
+		 * case do not try further zones and signal need_resched()
+		 * contention.
+		 */
+		if ((zone_contended == COMPACT_CONTENDED_SCHED)
+					|| fatal_signal_pending(current)) {
+			*contended = COMPACT_CONTENDED_SCHED;
+			goto break_loop;
+		}
+
+		continue;
+break_loop:
+		/*
+		 * We might not have tried all the zones, so  be conservative
+		 * and assume they are not all lock contended.
+		 */
+		all_zones_contended = 0;
+		break;
 	}
 
+	/*
+	 * If at least one zone wasn't deferred or skipped, we report if all
+	 * zones that were tried were lock contended.
+	 */
+	if (rc > COMPACT_SKIPPED && all_zones_contended)
+		*contended = COMPACT_CONTENDED_LOCK;
+
 	return rc;
 }
 
diff --git a/mm/internal.h b/mm/internal.h
index 5a0738f..4c1d604 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -144,8 +144,8 @@ struct compact_control {
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
-	bool contended;			/* True if a lock was contended, or
-					 * need_resched() true during async
+	int contended;			/* Signal need_sched() or lock
+					 * contention detected during
 					 * compaction
 					 */
 };
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5a1e0de..23a1e06 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2296,7 +2296,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
 	int classzone_idx, int migratetype, enum migrate_mode mode,
-	bool *contended_compaction, bool *deferred_compaction)
+	int *contended_compaction, bool *deferred_compaction)
 {
 	struct zone *last_compact_zone = NULL;
 	unsigned long compact_result;
@@ -2547,7 +2547,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	unsigned long did_some_progress;
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
-	bool contended_compaction = false;
+	int contended_compaction = COMPACT_CONTENDED_NONE;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -2651,15 +2651,36 @@ rebalance:
 	if (page)
 		goto got_pg;
 
-	/*
-	 * If compaction is deferred for high-order allocations, it is because
-	 * sync compaction recently failed. In this is the case and the caller
-	 * requested a movable allocation that does not heavily disrupt the
-	 * system then fail the allocation instead of entering direct reclaim.
-	 */
-	if ((deferred_compaction || contended_compaction) &&
-						(gfp_mask & __GFP_NO_KSWAPD))
-		goto nopage;
+	/* Checks for THP-specific high-order allocations */
+	if ((gfp_mask & GFP_TRANSHUGE) == GFP_TRANSHUGE) {
+		/*
+		 * If compaction is deferred for high-order allocations, it is
+		 * because sync compaction recently failed. If this is the case
+		 * and the caller requested a THP allocation, we do not want
+		 * to heavily disrupt the system, so we fail the allocation
+		 * instead of entering direct reclaim.
+		 */
+		if (deferred_compaction)
+			goto nopage;
+
+		/*
+		 * In all zones where compaction was attempted (and not
+		 * deferred or skipped), lock contention has been detected.
+		 * For THP allocation we do not want to disrupt the others
+		 * so we fallback to base pages instead.
+		 */
+		if (contended_compaction == COMPACT_CONTENDED_LOCK)
+			goto nopage;
+
+		/*
+		 * If compaction was aborted due to need_resched(), we do not
+		 * want to further increase allocation latency, unless it is
+		 * khugepaged trying to collapse.
+		 */
+		if (contended_compaction == COMPACT_CONTENDED_SCHED
+			&& !(current->flags & PF_KTHREAD))
+			goto nopage;
+	}
 
 	/*
 	 * It can become very expensive to allocate transparent hugepages at
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
