Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 015A38E0096
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:30:09 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id w2so7127254edc.13
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 06:30:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v17si605767edl.345.2018.12.11.06.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Dec 2018 06:30:08 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 3/3] mm, compaction: introduce deferred async compaction
Date: Tue, 11 Dec 2018 15:29:41 +0100
Message-Id: <20181211142941.20500-4-vbabka@suse.cz>
In-Reply-To: <20181211142941.20500-1-vbabka@suse.cz>
References: <20181211142941.20500-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>

Deferring compaction happens when it fails to fulfill the allocation request at
given order, and then a number of the following direct compaction attempts for
same or higher orders is skipped; with further failures, the number grows
exponentially up to 64. This is reset e.g. when compaction succeeds.

Until now, defering compaction is only performed after a sync compaction fails,
and then it also blocks async compaction attempts. The rationale is that only a
failed sync compaction is expected to fully exhaust all compaction potential of
a zone. However, for THP page faults that use __GFP_NORETRY, this means only
async compaction is attempted and thus it is never deferred, potentially
resulting in pointless reclaim/compaction attempts in a badly fragmented node.

This patch therefore tracks and checks async compaction deferred status in
addition, and mostly separately from sync compaction. This allows deferring THP
fault compaction without affecting any sync pageblock-order compaction.
Deferring for sync compaction however implies deferring for async compaction as
well. When deferred status is reset, it is reset for both modes.

The expected outcome is less compaction/reclaim activity for failing THP faults
likely with some expense on THP fault success rate.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>
---
 include/linux/compaction.h        | 10 ++--
 include/linux/mmzone.h            |  6 +--
 include/trace/events/compaction.h | 29 ++++++-----
 mm/compaction.c                   | 80 ++++++++++++++++++-------------
 4 files changed, 71 insertions(+), 54 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 68250a57aace..f1d4dc1deec9 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -100,11 +100,11 @@ extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern enum compact_result compaction_suitable(struct zone *zone, int order,
 		unsigned int alloc_flags, int classzone_idx);
 
-extern void defer_compaction(struct zone *zone, int order);
-extern bool compaction_deferred(struct zone *zone, int order);
+extern void defer_compaction(struct zone *zone, int order, bool sync);
+extern bool compaction_deferred(struct zone *zone, int order, bool sync);
 extern void compaction_defer_reset(struct zone *zone, int order,
 				bool alloc_success);
-extern bool compaction_restarting(struct zone *zone, int order);
+extern bool compaction_restarting(struct zone *zone, int order, bool sync);
 
 /* Compaction has made some progress and retrying makes sense */
 static inline bool compaction_made_progress(enum compact_result result)
@@ -189,11 +189,11 @@ static inline enum compact_result compaction_suitable(struct zone *zone, int ord
 	return COMPACT_SKIPPED;
 }
 
-static inline void defer_compaction(struct zone *zone, int order)
+static inline void defer_compaction(struct zone *zone, int order, bool sync)
 {
 }
 
-static inline bool compaction_deferred(struct zone *zone, int order)
+static inline bool compaction_deferred(struct zone *zone, int order, bool sync)
 {
 	return true;
 }
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 847705a6d0ec..4c59996dd4f9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -492,9 +492,9 @@ struct zone {
 	 * are skipped before trying again. The number attempted since
 	 * last failure is tracked with compact_considered.
 	 */
-	unsigned int		compact_considered;
-	unsigned int		compact_defer_shift;
-	int			compact_order_failed;
+	unsigned int		compact_considered[2];
+	unsigned int		compact_defer_shift[2];
+	int			compact_order_failed[2];
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 6074eff3d766..7ef40c76bfed 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -245,9 +245,9 @@ DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
 
 DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 
-	TP_PROTO(struct zone *zone, int order),
+	TP_PROTO(struct zone *zone, int order, bool sync),
 
-	TP_ARGS(zone, order),
+	TP_ARGS(zone, order, sync),
 
 	TP_STRUCT__entry(
 		__field(int, nid)
@@ -256,45 +256,48 @@ DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 		__field(unsigned int, considered)
 		__field(unsigned int, defer_shift)
 		__field(int, order_failed)
+		__field(bool, sync)
 	),
 
 	TP_fast_assign(
 		__entry->nid = zone_to_nid(zone);
 		__entry->idx = zone_idx(zone);
 		__entry->order = order;
-		__entry->considered = zone->compact_considered;
-		__entry->defer_shift = zone->compact_defer_shift;
-		__entry->order_failed = zone->compact_order_failed;
+		__entry->considered = zone->compact_considered[sync];
+		__entry->defer_shift = zone->compact_defer_shift[sync];
+		__entry->order_failed = zone->compact_order_failed[sync];
+		__entry->sync = sync;
 	),
 
-	TP_printk("node=%d zone=%-8s order=%d order_failed=%d consider=%u limit=%lu",
+	TP_printk("node=%d zone=%-8s order=%d order_failed=%d consider=%u limit=%lu sync=%d",
 		__entry->nid,
 		__print_symbolic(__entry->idx, ZONE_TYPE),
 		__entry->order,
 		__entry->order_failed,
 		__entry->considered,
-		1UL << __entry->defer_shift)
+		1UL << __entry->defer_shift,
+		__entry->sync)
 );
 
 DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_deferred,
 
-	TP_PROTO(struct zone *zone, int order),
+	TP_PROTO(struct zone *zone, int order, bool sync),
 
-	TP_ARGS(zone, order)
+	TP_ARGS(zone, order, sync)
 );
 
 DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_compaction,
 
-	TP_PROTO(struct zone *zone, int order),
+	TP_PROTO(struct zone *zone, int order, bool sync),
 
-	TP_ARGS(zone, order)
+	TP_ARGS(zone, order, sync)
 );
 
 DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_reset,
 
-	TP_PROTO(struct zone *zone, int order),
+	TP_PROTO(struct zone *zone, int order, bool sync),
 
-	TP_ARGS(zone, order)
+	TP_ARGS(zone, order, sync)
 );
 #endif
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 7c607479de4a..cb139b63a754 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -139,36 +139,40 @@ EXPORT_SYMBOL(__ClearPageMovable);
  * allocation success. 1 << compact_defer_limit compactions are skipped up
  * to a limit of 1 << COMPACT_MAX_DEFER_SHIFT
  */
-void defer_compaction(struct zone *zone, int order)
+void defer_compaction(struct zone *zone, int order, bool sync)
 {
-	zone->compact_considered = 0;
-	zone->compact_defer_shift++;
+	zone->compact_considered[sync] = 0;
+	zone->compact_defer_shift[sync]++;
 
-	if (order < zone->compact_order_failed)
-		zone->compact_order_failed = order;
+	if (order < zone->compact_order_failed[sync])
+		zone->compact_order_failed[sync] = order;
 
-	if (zone->compact_defer_shift > COMPACT_MAX_DEFER_SHIFT)
-		zone->compact_defer_shift = COMPACT_MAX_DEFER_SHIFT;
+	if (zone->compact_defer_shift[sync] > COMPACT_MAX_DEFER_SHIFT)
+		zone->compact_defer_shift[sync] = COMPACT_MAX_DEFER_SHIFT;
 
-	trace_mm_compaction_defer_compaction(zone, order);
+	trace_mm_compaction_defer_compaction(zone, order, sync);
+
+	/* deferred sync compaciton implies deferred async compaction */
+	if (sync)
+		defer_compaction(zone, order, false);
 }
 
 /* Returns true if compaction should be skipped this time */
-bool compaction_deferred(struct zone *zone, int order)
+bool compaction_deferred(struct zone *zone, int order, bool sync)
 {
-	unsigned long defer_limit = 1UL << zone->compact_defer_shift;
+	unsigned long defer_limit = 1UL << zone->compact_defer_shift[sync];
 
-	if (order < zone->compact_order_failed)
+	if (order < zone->compact_order_failed[sync])
 		return false;
 
 	/* Avoid possible overflow */
-	if (++zone->compact_considered > defer_limit)
-		zone->compact_considered = defer_limit;
+	if (++zone->compact_considered[sync] > defer_limit)
+		zone->compact_considered[sync] = defer_limit;
 
-	if (zone->compact_considered >= defer_limit)
+	if (zone->compact_considered[sync] >= defer_limit)
 		return false;
 
-	trace_mm_compaction_deferred(zone, order);
+	trace_mm_compaction_deferred(zone, order, sync);
 
 	return true;
 }
@@ -181,24 +185,32 @@ bool compaction_deferred(struct zone *zone, int order)
 void compaction_defer_reset(struct zone *zone, int order,
 		bool alloc_success)
 {
-	if (alloc_success) {
-		zone->compact_considered = 0;
-		zone->compact_defer_shift = 0;
-	}
-	if (order >= zone->compact_order_failed)
-		zone->compact_order_failed = order + 1;
+	int sync;
+
+	for (sync = 0; sync <= 1; sync++) {
+		if (alloc_success) {
+			zone->compact_considered[sync] = 0;
+			zone->compact_defer_shift[sync] = 0;
+		}
+		if (order >= zone->compact_order_failed[sync])
+			zone->compact_order_failed[sync] = order + 1;
 
-	trace_mm_compaction_defer_reset(zone, order);
+		trace_mm_compaction_defer_reset(zone, order, sync);
+	}
 }
 
 /* Returns true if restarting compaction after many failures */
-bool compaction_restarting(struct zone *zone, int order)
+bool compaction_restarting(struct zone *zone, int order, bool sync)
 {
-	if (order < zone->compact_order_failed)
+	int defer_shift;
+
+	if (order < zone->compact_order_failed[sync])
 		return false;
 
-	return zone->compact_defer_shift == COMPACT_MAX_DEFER_SHIFT &&
-		zone->compact_considered >= 1UL << zone->compact_defer_shift;
+	defer_shift = zone->compact_defer_shift[sync];
+
+	return defer_shift == COMPACT_MAX_DEFER_SHIFT &&
+		zone->compact_considered[sync] >= 1UL << defer_shift;
 }
 
 /* Returns true if the pageblock should be scanned for pages to isolate. */
@@ -1555,7 +1567,7 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
 	 * Clear pageblock skip if there were failures recently and compaction
 	 * is about to be retried after being deferred.
 	 */
-	if (compaction_restarting(zone, cc->order))
+	if (compaction_restarting(zone, cc->order, sync))
 		__reset_isolation_suitable(zone);
 
 	/*
@@ -1767,7 +1779,8 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 		enum compact_result status;
 
 		if (prio > MIN_COMPACT_PRIORITY
-					&& compaction_deferred(zone, order)) {
+				&& compaction_deferred(zone, order,
+					prio != COMPACT_PRIO_ASYNC)) {
 			rc = max_t(enum compact_result, COMPACT_DEFERRED, rc);
 			continue;
 		}
@@ -1789,14 +1802,15 @@ enum compact_result try_to_compact_pages(gfp_t gfp_mask, unsigned int order,
 			break;
 		}
 
-		if (prio != COMPACT_PRIO_ASYNC && (status == COMPACT_COMPLETE ||
-					status == COMPACT_PARTIAL_SKIPPED))
+		if (status == COMPACT_COMPLETE ||
+				status == COMPACT_PARTIAL_SKIPPED)
 			/*
 			 * We think that allocation won't succeed in this zone
 			 * so we defer compaction there. If it ends up
 			 * succeeding after all, it will be reset.
 			 */
-			defer_compaction(zone, order);
+			defer_compaction(zone, order,
+						prio != COMPACT_PRIO_ASYNC);
 
 		/*
 		 * We might have stopped compacting due to need_resched() in
@@ -1966,7 +1980,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 		if (!populated_zone(zone))
 			continue;
 
-		if (compaction_deferred(zone, cc.order))
+		if (compaction_deferred(zone, cc.order, true))
 			continue;
 
 		if (compaction_suitable(zone, cc.order, 0, zoneid) !=
@@ -2000,7 +2014,7 @@ static void kcompactd_do_work(pg_data_t *pgdat)
 			 * We use sync migration mode here, so we defer like
 			 * sync direct compaction does.
 			 */
-			defer_compaction(zone, cc.order);
+			defer_compaction(zone, cc.order, true);
 		}
 
 		count_compact_events(KCOMPACTD_MIGRATE_SCANNED,
-- 
2.19.2
