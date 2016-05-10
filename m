Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8286B0264
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:37:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r12so6444513wme.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:37:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iq6si1011447wjb.116.2016.05.10.00.37.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 May 2016 00:37:08 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 07/13] mm, compaction: introduce direct compaction priority
Date: Tue, 10 May 2016 09:35:57 +0200
Message-Id: <1462865763-22084-8-git-send-email-vbabka@suse.cz>
In-Reply-To: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
References: <1462865763-22084-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

In the context of direct compaction, for some types of allocations we would
like the compaction to either succeed or definitely fail while trying as hard
as possible. Current async/sync_light migration mode is insufficient, as there
are heuristics such as caching scanner positions, marking pageblocks as
unsuitable or deferring compaction for a zone. At least the final compaction
attempt should be able to override these heuristics.

To communicate how hard compaction should try, we replace migration mode with
a new enum compact_priority and change the relevant function signatures. In
compact_zone_order() where struct compact_control is constructed, the priority
is mapped to suitable control flags. This patch itself has no functional
change, as the current priority levels are mapped back to the same migration
modes as before. Expanding them will be done next.

Note that !CONFIG_COMPACTION variant of try_to_compact_pages() is removed, as
the only caller exists under CONFIG_COMPACTION.
---
 include/linux/compaction.h | 18 +++++++++---------
 mm/compaction.c            | 14 ++++++++------
 mm/page_alloc.c            | 27 +++++++++++++--------------
 3 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 4ba90e74969c..900d181ff1b0 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -1,6 +1,14 @@
 #ifndef _LINUX_COMPACTION_H
 #define _LINUX_COMPACTION_H
 
+// TODO: lower value means higher priority to match reclaim, makes sense?
+enum compact_priority {
+	COMPACT_PRIO_SYNC_LIGHT,
+	DEF_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
+	COMPACT_PRIO_ASYNC,
+	INIT_COMPACT_PRIORITY = COMPACT_PRIO_ASYNC
+};
+
 /* Return values for compact_zone() and try_to_compact_pages() */
 /* When adding new states, please adjust include/trace/events/compaction.h */
 enum compact_result {
@@ -66,7 +74,7 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern enum compact_result try_to_compact_pages(gfp_t gfp_mask,
 			unsigned int order,
 			unsigned int alloc_flags, const struct alloc_context *ac,
-			enum migrate_mode mode, int *contended);
+			enum compact_priority prio, int *contended);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern enum compact_result compaction_suitable(struct zone *zone, int order,
@@ -151,14 +159,6 @@ extern void kcompactd_stop(int nid);
 extern void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx);
 
 #else
-static inline enum compact_result try_to_compact_pages(gfp_t gfp_mask,
-			unsigned int order, unsigned int alloc_flags,
-			const struct alloc_context *ac,
-			enum migrate_mode mode, int *contended)
-{
-	return COMPACT_CONTINUE;
-}
-
 static inline void compact_pgdat(pg_data_t *pgdat, int order)
 {
 }
diff --git a/mm/compaction.c b/mm/compaction.c
index 481004c73c90..abfd71e1f1a3 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1571,7 +1571,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 }
 
 static enum compact_result compact_zone_order(struct zone *zone, int order,
-		gfp_t gfp_mask, enum migrate_mode mode, int *contended,
+		gfp_t gfp_mask, enum compact_priority prio, int *contended,
 		unsigned int alloc_flags, int classzone_idx)
 {
 	enum compact_result ret;
@@ -1581,7 +1581,8 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 		.order = order,
 		.gfp_mask = gfp_mask,
 		.zone = zone,
-		.mode = mode,
+		.mode = (prio == COMPACT_PRIO_ASYNC) ?
+					MIGRATE_ASYNC :	MIGRATE_SYNC_LIGHT,
 		.alloc_flags = alloc_flags,
 		.classzone_idx = classzone_idx,
 		.direct_compaction = true,
@@ -1614,7 +1615,7 @@ int sysctl_extfrag_threshold = 500;
  */
 enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			unsigned int alloc_flags, const struct alloc_context *ac,
-			enum migrate_mode mode, int *contended)
+			enum compact_priority prio, int *contended)
 {
 	int may_enter_fs = gfp_mask & __GFP_FS;
 	int may_perform_io = gfp_mask & __GFP_IO;
@@ -1629,7 +1630,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 	if (!order || !may_enter_fs || !may_perform_io)
 		return COMPACT_SKIPPED;
 
-	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, mode);
+	//XXX: FIXME
+	//trace_mm_compaction_try_to_compact_pages(order, gfp_mask, mode);
 
 	/* Compact each zone in the list */
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
@@ -1642,7 +1644,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			continue;
 		}
 
-		status = compact_zone_order(zone, order, gfp_mask, mode,
+		status = compact_zone_order(zone, order, gfp_mask, prio,
 				&zone_contended, alloc_flags,
 				ac_classzone_idx(ac));
 		rc = max(status, rc);
@@ -1676,7 +1678,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			goto break_loop;
 		}
 
-		if (mode != MIGRATE_ASYNC && (status == COMPACT_COMPLETE ||
+		if (prio != COMPACT_PRIO_ASYNC && (status == COMPACT_COMPLETE ||
 					status == COMPACT_PARTIAL_SKIPPED)) {
 			/*
 			 * We think that allocation won't succeed in this zone
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1a5ff4525a0e..17abc05be972 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3193,7 +3193,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum migrate_mode mode, enum compact_result *compact_result)
+		enum compact_priority prio, enum compact_result *compact_result)
 {
 	struct page *page;
 	int contended_compaction;
@@ -3203,7 +3203,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 	current->flags |= PF_MEMALLOC;
 	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
-						mode, &contended_compaction);
+						prio, &contended_compaction);
 	current->flags &= ~PF_MEMALLOC;
 
 	if (*compact_result <= COMPACT_INACTIVE)
@@ -3258,7 +3258,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 static inline bool
 should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
-		     enum compact_result compact_result, enum migrate_mode *migrate_mode,
+		     enum compact_result compact_result, enum compact_priority *compact_priority,
 		     int compaction_retries)
 {
 	int max_retries = MAX_COMPACT_RETRIES;
@@ -3269,11 +3269,11 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	/*
 	 * compaction considers all the zone as desperately out of memory
 	 * so it doesn't really make much sense to retry except when the
-	 * failure could be caused by weak migration mode.
+	 * failure could be caused by insufficient priority
 	 */
 	if (compaction_failed(compact_result)) {
-		if (*migrate_mode == MIGRATE_ASYNC) {
-			*migrate_mode = MIGRATE_SYNC_LIGHT;
+		if (*compact_priority > 0) {
+			(*compact_priority)--;
 			return true;
 		}
 		return false;
@@ -3307,7 +3307,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum migrate_mode mode, enum compact_result *compact_result)
+		enum compact_priority prio, enum compact_result *compact_result)
 {
 	return NULL;
 }
@@ -3315,7 +3315,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 static inline bool
 should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_flags,
 		     enum compact_result compact_result,
-		     enum migrate_mode *migrate_mode,
+		     enum compact_priority *compact_priority,
 		     int compaction_retries)
 {
 	return false;
@@ -3549,7 +3549,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct page *page = NULL;
 	unsigned int alloc_flags;
 	unsigned long did_some_progress;
-	enum migrate_mode migration_mode = MIGRATE_SYNC_LIGHT;
+	enum compact_priority compact_priority = DEF_COMPACT_PRIORITY;
 	enum compact_result compact_result;
 	int compaction_retries = 0;
 	int no_progress_loops = 0;
@@ -3599,7 +3599,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (can_direct_reclaim && order > PAGE_ALLOC_COSTLY_ORDER) {
 		page = __alloc_pages_direct_compact(gfp_mask, order,
 						alloc_flags, ac,
-						MIGRATE_ASYNC,
+						INIT_COMPACT_PRIORITY,
 						&compact_result);
 		if (page)
 			goto got_pg;
@@ -3632,7 +3632,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 			 * sync compaction could be very expensive, so keep
 			 * using async compaction.
 			 */
-			migration_mode = MIGRATE_ASYNC;
+			compact_priority = INIT_COMPACT_PRIORITY;
 		}
 	}
 
@@ -3693,8 +3693,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 	/* Try direct compaction and then allocating */
 	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
-					migration_mode,
-					&compact_result);
+					compact_priority, &compact_result);
 	if (page)
 		goto got_pg;
 
@@ -3734,7 +3733,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	if (did_some_progress > 0 &&
 			should_compact_retry(ac, order, alloc_flags,
-				compact_result, &migration_mode,
+				compact_result, &compact_priority,
 				compaction_retries))
 		goto retry;
 
-- 
2.8.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
