Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC3516B0265
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 07:23:28 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so112051941lfw.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 04:23:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n125si14220050wmb.87.2016.07.18.04.23.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 18 Jul 2016 04:23:10 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 8/8] mm, compaction: simplify contended compaction handling
Date: Mon, 18 Jul 2016 13:23:02 +0200
Message-Id: <20160718112302.27381-9-vbabka@suse.cz>
In-Reply-To: <20160718112302.27381-1-vbabka@suse.cz>
References: <20160718112302.27381-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

Async compaction detects contention either due to failing trylock on zone->lock
or lru_lock, or by need_resched(). Since 1f9efdef4f3f ("mm, compaction:
khugepaged should not give up due to need_resched()") the code got quite
complicated to distinguish these two up to the __alloc_pages_slowpath() level,
so different decisions could be taken for khugepaged allocations.

After the recent changes, khugepaged allocations don't check for contended
compaction anymore, so we again don't need to distinguish lock and sched
contention, and simplify the current convoluted code a lot.

However, I believe it's also possible to simplify even more and completely
remove the check for contended compaction after the initial async compaction
for costly orders, which was originally aimed at THP page fault allocations.
There are several reasons why this can be done now:

- with the new defaults, THP page faults no longer do reclaim/compaction at
  all, unless the system admin has overridden the default, or application has
  indicated via madvise that it can benefit from THP's. In both cases, it
  means that the potential extra latency is expected and worth the benefits.
- even if reclaim/compaction proceeds after this patch where it previously
  wouldn't, the second compaction attempt is still async and will detect the
  contention and back off, if the contention persists
- there are still heuristics like deferred compaction and pageblock skip bits
  in place that prevent excessive THP page fault latencies

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/compaction.h | 13 ++-------
 mm/compaction.c            | 72 +++++++++-------------------------------------
 mm/internal.h              |  5 +---
 mm/page_alloc.c            | 28 +-----------------
 4 files changed, 17 insertions(+), 101 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 0980a6ce4436..d4e106b5dc27 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -55,14 +55,6 @@ enum compact_result {
 	COMPACT_PARTIAL,
 };
 
-/* Used to signal whether compaction detected need_sched() or lock contention */
-/* No contention detected */
-#define COMPACT_CONTENDED_NONE	0
-/* Either need_sched() was true or fatal signal pending */
-#define COMPACT_CONTENDED_SCHED	1
-/* Zone lock or lru_lock was contended in async compaction */
-#define COMPACT_CONTENDED_LOCK	2
-
 struct alloc_context; /* in mm/internal.h */
 
 #ifdef CONFIG_COMPACTION
@@ -76,9 +68,8 @@ extern int sysctl_compact_unevictable_allowed;
 
 extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern enum compact_result try_to_compact_pages(gfp_t gfp_mask,
-			unsigned int order,
-		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum compact_priority prio, int *contended);
+		unsigned int order, unsigned int alloc_flags,
+		const struct alloc_context *ac, enum compact_priority prio);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern enum compact_result compaction_suitable(struct zone *zone, int order,
diff --git a/mm/compaction.c b/mm/compaction.c
index bb969711d979..124a5b3384dd 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -331,7 +331,7 @@ static bool compact_trylock_irqsave(spinlock_t *lock, unsigned long *flags,
 {
 	if (cc->mode == MIGRATE_ASYNC) {
 		if (!spin_trylock_irqsave(lock, *flags)) {
-			cc->contended = COMPACT_CONTENDED_LOCK;
+			cc->contended = true;
 			return false;
 		}
 	} else {
@@ -365,13 +365,13 @@ static bool compact_unlock_should_abort(spinlock_t *lock,
 	}
 
 	if (fatal_signal_pending(current)) {
-		cc->contended = COMPACT_CONTENDED_SCHED;
+		cc->contended = true;
 		return true;
 	}
 
 	if (need_resched()) {
 		if (cc->mode == MIGRATE_ASYNC) {
-			cc->contended = COMPACT_CONTENDED_SCHED;
+			cc->contended = true;
 			return true;
 		}
 		cond_resched();
@@ -394,7 +394,7 @@ static inline bool compact_should_abort(struct compact_control *cc)
 	/* async compaction aborts if contended */
 	if (need_resched()) {
 		if (cc->mode == MIGRATE_ASYNC) {
-			cc->contended = COMPACT_CONTENDED_SCHED;
+			cc->contended = true;
 			return true;
 		}
 
@@ -1637,14 +1637,11 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
 				cc->free_pfn, end_pfn, sync, ret);
 
-	if (ret == COMPACT_CONTENDED)
-		ret = COMPACT_PARTIAL;
-
 	return ret;
 }
 
 static enum compact_result compact_zone_order(struct zone *zone, int order,
-		gfp_t gfp_mask, enum compact_priority prio, int *contended,
+		gfp_t gfp_mask, enum compact_priority prio,
 		unsigned int alloc_flags, int classzone_idx)
 {
 	enum compact_result ret;
@@ -1668,7 +1665,6 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 	VM_BUG_ON(!list_empty(&cc.freepages));
 	VM_BUG_ON(!list_empty(&cc.migratepages));
 
-	*contended = cc.contended;
 	return ret;
 }
 
@@ -1681,23 +1677,18 @@ int sysctl_extfrag_threshold = 500;
  * @alloc_flags: The allocation flags of the current allocation
  * @ac: The context of current allocation
  * @mode: The migration mode for async, sync light, or sync migration
- * @contended: Return value that determines if compaction was aborted due to
- *	       need_resched() or lock contention
  *
  * This is the main entry point for direct page compaction.
  */
 enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum compact_priority prio, int *contended)
+		enum compact_priority prio)
 {
 	int may_enter_fs = gfp_mask & __GFP_FS;
 	int may_perform_io = gfp_mask & __GFP_IO;
 	struct zoneref *z;
 	struct zone *zone;
 	enum compact_result rc = COMPACT_SKIPPED;
-	int all_zones_contended = COMPACT_CONTENDED_LOCK; /* init for &= op */
-
-	*contended = COMPACT_CONTENDED_NONE;
 
 	/* Check if the GFP flags allow compaction */
 	if (!may_enter_fs || !may_perform_io)
@@ -1709,7 +1700,6 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
 		enum compact_result status;
-		int zone_contended;
 
 		if (compaction_deferred(zone, order)) {
 			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
@@ -1717,14 +1707,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		}
 
 		status = compact_zone_order(zone, order, gfp_mask, prio,
-				&zone_contended, alloc_flags,
-				ac_classzone_idx(ac));
+					alloc_flags, ac_classzone_idx(ac));
 		rc = max(status, rc);
-		/*
-		 * It takes at least one zone that wasn't lock contended
-		 * to clear all_zones_contended.
-		 */
-		all_zones_contended &= zone_contended;
 
 		/* If a normal allocation would succeed, stop compacting */
 		if (zone_watermark_ok(zone, order, low_wmark_pages(zone),
@@ -1736,59 +1720,29 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			 * succeeds in this zone.
 			 */
 			compaction_defer_reset(zone, order, false);
-			/*
-			 * It is possible that async compaction aborted due to
-			 * need_resched() and the watermarks were ok thanks to
-			 * somebody else freeing memory. The allocation can
-			 * however still fail so we better signal the
-			 * need_resched() contention anyway (this will not
-			 * prevent the allocation attempt).
-			 */
-			if (zone_contended == COMPACT_CONTENDED_SCHED)
-				*contended = COMPACT_CONTENDED_SCHED;
 
-			goto break_loop;
+			break;
 		}
 
 		if (prio != COMPACT_PRIO_ASYNC && (status == COMPACT_COMPLETE ||
-					status == COMPACT_PARTIAL_SKIPPED)) {
+					status == COMPACT_PARTIAL_SKIPPED))
 			/*
 			 * We think that allocation won't succeed in this zone
 			 * so we defer compaction there. If it ends up
 			 * succeeding after all, it will be reset.
 			 */
 			defer_compaction(zone, order);
-		}
 
 		/*
 		 * We might have stopped compacting due to need_resched() in
 		 * async compaction, or due to a fatal signal detected. In that
-		 * case do not try further zones and signal need_resched()
-		 * contention.
-		 */
-		if ((zone_contended == COMPACT_CONTENDED_SCHED)
-					|| fatal_signal_pending(current)) {
-			*contended = COMPACT_CONTENDED_SCHED;
-			goto break_loop;
-		}
-
-		continue;
-break_loop:
-		/*
-		 * We might not have tried all the zones, so  be conservative
-		 * and assume they are not all lock contended.
+		 * case do not try further zones
 		 */
-		all_zones_contended = 0;
-		break;
+		if ((prio == COMPACT_PRIO_ASYNC && need_resched())
+					|| fatal_signal_pending(current))
+			break;
 	}
 
-	/*
-	 * If at least one zone wasn't deferred or skipped, we report if all
-	 * zones that were tried were lock contended.
-	 */
-	if (rc > COMPACT_INACTIVE && all_zones_contended)
-		*contended = COMPACT_CONTENDED_LOCK;
-
 	return rc;
 }
 
diff --git a/mm/internal.h b/mm/internal.h
index 28932cd6a195..1501304f87a4 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -185,10 +185,7 @@ struct compact_control {
 	const unsigned int alloc_flags;	/* alloc flags of a direct compactor */
 	const int classzone_idx;	/* zone index of a direct compactor */
 	struct zone *zone;
-	int contended;			/* Signal need_sched() or lock
-					 * contention detected during
-					 * compaction
-					 */
+	bool contended;			/* Signal lock or sched contention */
 };
 
 unsigned long
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 04cab9d92e30..bb9b4fb66e85 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3099,14 +3099,13 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		enum compact_priority prio, enum compact_result *compact_result)
 {
 	struct page *page;
-	int contended_compaction;
 
 	if (!order)
 		return NULL;
 
 	current->flags |= PF_MEMALLOC;
 	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
-						prio, &contended_compaction);
+									prio);
 	current->flags &= ~PF_MEMALLOC;
 
 	if (*compact_result <= COMPACT_INACTIVE)
@@ -3135,24 +3134,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	 */
 	count_vm_event(COMPACTFAIL);
 
-	/*
-	 * In all zones where compaction was attempted (and not
-	 * deferred or skipped), lock contention has been detected.
-	 * For THP allocation we do not want to disrupt the others
-	 * so we fallback to base pages instead.
-	 */
-	if (contended_compaction == COMPACT_CONTENDED_LOCK)
-		*compact_result = COMPACT_CONTENDED;
-
-	/*
-	 * If compaction was aborted due to need_resched(), we do not
-	 * want to further increase allocation latency, unless it is
-	 * khugepaged trying to collapse.
-	 */
-	if (contended_compaction == COMPACT_CONTENDED_SCHED
-		&& !(current->flags & PF_KTHREAD))
-		*compact_result = COMPACT_CONTENDED;
-
 	cond_resched();
 
 	return NULL;
@@ -3576,13 +3557,6 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 				goto nopage;
 
 			/*
-			 * Compaction is contended so rather back off than cause
-			 * excessive stalls.
-			 */
-			if (compact_result == COMPACT_CONTENDED)
-				goto nopage;
-
-			/*
 			 * Looks like reclaim/compaction is worth trying, but
 			 * sync compaction could be very expensive, so keep
 			 * using async compaction.
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
