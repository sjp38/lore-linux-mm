Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 552966B0265
	for <linux-mm@kvack.org>; Tue, 31 May 2016 09:08:51 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id n2so43595866wma.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 06:08:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 63si19298999wmy.109.2016.05.31.06.08.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 May 2016 06:08:36 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 07/18] mm, compaction: introduce direct compaction priority
Date: Tue, 31 May 2016 15:08:07 +0200
Message-Id: <20160531130818.28724-8-vbabka@suse.cz>
In-Reply-To: <20160531130818.28724-1-vbabka@suse.cz>
References: <20160531130818.28724-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

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

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/compaction.h        | 22 +++++++++++++---------
 include/trace/events/compaction.h | 12 ++++++------
 mm/compaction.c                   | 13 +++++++------
 mm/page_alloc.c                   | 28 ++++++++++++++--------------
 4 files changed, 40 insertions(+), 35 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index a58c852a268f..ba67bc8edbb6 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -1,6 +1,18 @@
 #ifndef _LINUX_COMPACTION_H
 #define _LINUX_COMPACTION_H
 
+/*
+ * Determines how hard direct compaction should try to succeed.
+ * Lower value means higher priority, analogically to reclaim priority.
+ */
+enum compact_priority {
+	COMPACT_PRIO_SYNC_LIGHT,
+	MIN_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
+	DEF_COMPACT_PRIORITY = COMPACT_PRIO_SYNC_LIGHT,
+	COMPACT_PRIO_ASYNC,
+	INIT_COMPACT_PRIORITY = COMPACT_PRIO_ASYNC
+};
+
 /* Return values for compact_zone() and try_to_compact_pages() */
 /* When adding new states, please adjust include/trace/events/compaction.h */
 enum compact_result {
@@ -66,7 +78,7 @@ extern int fragmentation_index(struct zone *zone, unsigned int order);
 extern enum compact_result try_to_compact_pages(gfp_t gfp_mask,
 			unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum migrate_mode mode, int *contended);
+		enum compact_priority prio, int *contended);
 extern void compact_pgdat(pg_data_t *pgdat, int order);
 extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern enum compact_result compaction_suitable(struct zone *zone, int order,
@@ -151,14 +163,6 @@ extern void kcompactd_stop(int nid);
 extern void wakeup_kcompactd(pg_data_t *pgdat, int order, int classzone_idx);
 
 #else
-static inline enum compact_result try_to_compact_pages(gfp_t gfp_mask,
-			unsigned int order, int alloc_flags,
-			const struct alloc_context *ac,
-			enum migrate_mode mode, int *contended)
-{
-	return COMPACT_CONTINUE;
-}
-
 static inline void compact_pgdat(pg_data_t *pgdat, int order)
 {
 }
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 36e2d6fb1360..c2ba402ab256 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -226,26 +226,26 @@ TRACE_EVENT(mm_compaction_try_to_compact_pages,
 	TP_PROTO(
 		int order,
 		gfp_t gfp_mask,
-		enum migrate_mode mode),
+		int prio),
 
-	TP_ARGS(order, gfp_mask, mode),
+	TP_ARGS(order, gfp_mask, prio),
 
 	TP_STRUCT__entry(
 		__field(int, order)
 		__field(gfp_t, gfp_mask)
-		__field(enum migrate_mode, mode)
+		__field(int, prio)
 	),
 
 	TP_fast_assign(
 		__entry->order = order;
 		__entry->gfp_mask = gfp_mask;
-		__entry->mode = mode;
+		__entry->prio = prio;
 	),
 
-	TP_printk("order=%d gfp_mask=0x%x mode=%d",
+	TP_printk("order=%d gfp_mask=0x%x priority=%d",
 		__entry->order,
 		__entry->gfp_mask,
-		(int)__entry->mode)
+		__entry->prio)
 );
 
 DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
diff --git a/mm/compaction.c b/mm/compaction.c
index e611f3f90f5f..19a4f4fd6632 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1572,7 +1572,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 }
 
 static enum compact_result compact_zone_order(struct zone *zone, int order,
-		gfp_t gfp_mask, enum migrate_mode mode, int *contended,
+		gfp_t gfp_mask, enum compact_priority prio, int *contended,
 		unsigned int alloc_flags, int classzone_idx)
 {
 	enum compact_result ret;
@@ -1582,7 +1582,8 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
 		.order = order,
 		.gfp_mask = gfp_mask,
 		.zone = zone,
-		.mode = mode,
+		.mode = (prio == COMPACT_PRIO_ASYNC) ?
+					MIGRATE_ASYNC :	MIGRATE_SYNC_LIGHT,
 		.alloc_flags = alloc_flags,
 		.classzone_idx = classzone_idx,
 		.direct_compaction = true,
@@ -1615,7 +1616,7 @@ int sysctl_extfrag_threshold = 500;
  */
 enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum migrate_mode mode, int *contended)
+		enum compact_priority prio, int *contended)
 {
 	int may_enter_fs = gfp_mask & __GFP_FS;
 	int may_perform_io = gfp_mask & __GFP_IO;
@@ -1630,7 +1631,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 	if (!order || !may_enter_fs || !may_perform_io)
 		return COMPACT_SKIPPED;
 
-	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, mode);
+	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, prio);
 
 	/* Compact each zone in the list */
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
@@ -1643,7 +1644,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			continue;
 		}
 
-		status = compact_zone_order(zone, order, gfp_mask, mode,
+		status = compact_zone_order(zone, order, gfp_mask, prio,
 				&zone_contended, alloc_flags,
 				ac_classzone_idx(ac));
 		rc = max(status, rc);
@@ -1677,7 +1678,7 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			goto break_loop;
 		}
 
-		if (mode != MIGRATE_ASYNC && (status == COMPACT_COMPLETE ||
+		if (prio != COMPACT_PRIO_ASYNC && (status == COMPACT_COMPLETE ||
 					status == COMPACT_PARTIAL_SKIPPED)) {
 			/*
 			 * We think that allocation won't succeed in this zone
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d7fc4c86e077..4466543a57ab 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3180,7 +3180,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum migrate_mode mode, enum compact_result *compact_result)
+		enum compact_priority prio, enum compact_result *compact_result)
 {
 	struct page *page;
 	int contended_compaction;
@@ -3190,7 +3190,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 	current->flags |= PF_MEMALLOC;
 	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
-						mode, &contended_compaction);
+						prio, &contended_compaction);
 	current->flags &= ~PF_MEMALLOC;
 
 	if (*compact_result <= COMPACT_INACTIVE)
@@ -3244,7 +3244,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 static inline bool
 should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
-		     enum compact_result compact_result, enum migrate_mode *migrate_mode,
+		     enum compact_result compact_result,
+		     enum compact_priority *compact_priority,
 		     int compaction_retries)
 {
 	int max_retries = MAX_COMPACT_RETRIES;
@@ -3255,11 +3256,11 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 	/*
 	 * compaction considers all the zone as desperately out of memory
 	 * so it doesn't really make much sense to retry except when the
-	 * failure could be caused by weak migration mode.
+	 * failure could be caused by insufficient priority
 	 */
 	if (compaction_failed(compact_result)) {
-		if (*migrate_mode == MIGRATE_ASYNC) {
-			*migrate_mode = MIGRATE_SYNC_LIGHT;
+		if (*compact_priority > MIN_COMPACT_PRIORITY) {
+			(*compact_priority)--;
 			return true;
 		}
 		return false;
@@ -3293,7 +3294,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		unsigned int alloc_flags, const struct alloc_context *ac,
-		enum migrate_mode mode, enum compact_result *compact_result)
+		enum compact_priority prio, enum compact_result *compact_result)
 {
 	*compact_result = COMPACT_SKIPPED;
 	return NULL;
@@ -3302,7 +3303,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 static inline bool
 should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_flags,
 		     enum compact_result compact_result,
-		     enum migrate_mode *migrate_mode,
+		     enum compact_priority *compact_priority,
 		     int compaction_retries)
 {
 	struct zone *zone;
@@ -3554,7 +3555,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct page *page = NULL;
 	unsigned int alloc_flags;
 	unsigned long did_some_progress;
-	enum migrate_mode migration_mode = MIGRATE_SYNC_LIGHT;
+	enum compact_priority compact_priority = DEF_COMPACT_PRIORITY;
 	enum compact_result compact_result;
 	int compaction_retries = 0;
 	int no_progress_loops = 0;
@@ -3603,7 +3604,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (can_direct_reclaim && order > PAGE_ALLOC_COSTLY_ORDER) {
 		page = __alloc_pages_direct_compact(gfp_mask, order,
 						alloc_flags, ac,
-						MIGRATE_ASYNC,
+						INIT_COMPACT_PRIORITY,
 						&compact_result);
 		if (page)
 			goto got_pg;
@@ -3636,7 +3637,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 			 * sync compaction could be very expensive, so keep
 			 * using async compaction.
 			 */
-			migration_mode = MIGRATE_ASYNC;
+			compact_priority = INIT_COMPACT_PRIORITY;
 		}
 	}
 
@@ -3697,8 +3698,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 
 	/* Try direct compaction and then allocating */
 	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
-					migration_mode,
-					&compact_result);
+					compact_priority, &compact_result);
 	if (page)
 		goto got_pg;
 
@@ -3738,7 +3738,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 */
 	if (did_some_progress > 0 &&
 			should_compact_retry(ac, order, alloc_flags,
-				compact_result, &migration_mode,
+				compact_result, &compact_priority,
 				compaction_retries))
 		goto retry;
 
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
