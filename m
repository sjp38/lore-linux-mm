Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5286B0070
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 02:48:46 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id p10so14964396pdj.11
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 23:48:46 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id ob9si14377320pdb.199.2014.12.02.23.48.42
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 23:48:44 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/3] mm/compaction: add tracepoint to observe behaviour of compaction defer
Date: Wed,  3 Dec 2014 16:52:07 +0900
Message-Id: <1417593127-6819-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

compaction deferring logic is heavy hammer that block the way to
the compaction. It doesn't consider overall system state, so it
could prevent user from doing compaction falsely. In other words,
even if system has enough range of memory to compact, compaction would be
skipped due to compaction deferring logic. This patch add new tracepoint
to understand work of deferring logic. This will also help to check
compaction success and fail.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/trace/events/compaction.h |   56 +++++++++++++++++++++++++++++++++++++
 mm/compaction.c                   |    7 ++++-
 2 files changed, 62 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 5e47cb2..673d59a 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -255,6 +255,62 @@ DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
 	TP_ARGS(zone, order, alloc_flags, classzone_idx, ret)
 );
 
+DECLARE_EVENT_CLASS(mm_compaction_defer_template,
+
+	TP_PROTO(struct zone *zone,
+		unsigned int order),
+
+	TP_ARGS(zone, order),
+
+	TP_STRUCT__entry(
+		__field(char *, name)
+		__field(unsigned int, order)
+		__field(unsigned int, considered)
+		__field(unsigned int, defer_shift)
+		__field(int, order_failed)
+	),
+
+	TP_fast_assign(
+		__entry->name = (char *)zone->name;
+		__entry->order = order;
+		__entry->considered = zone->compact_considered;
+		__entry->defer_shift = zone->compact_defer_shift;
+		__entry->order_failed = zone->compact_order_failed;
+	),
+
+	TP_printk("zone=%-8s order=%u order_failed=%u reason=%s consider=%u limit=%lu",
+		__entry->name,
+		__entry->order,
+		__entry->order_failed,
+		__entry->order < __entry->order_failed ? "order" : "try",
+		__entry->considered,
+		1UL << __entry->defer_shift)
+);
+
+DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_deffered,
+
+	TP_PROTO(struct zone *zone,
+		unsigned int order),
+
+	TP_ARGS(zone, order)
+);
+
+DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_compaction,
+
+	TP_PROTO(struct zone *zone,
+		unsigned int order),
+
+	TP_ARGS(zone, order)
+);
+
+DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_reset,
+
+	TP_PROTO(struct zone *zone,
+		unsigned int order),
+
+	TP_ARGS(zone, order)
+);
+
 #endif /* _TRACE_COMPACTION_H */
 
 /* This part must be outside protection */
diff --git a/mm/compaction.c b/mm/compaction.c
index f5d2405..e005620 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1413,8 +1413,10 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 		int status;
 		int zone_contended;
 
-		if (compaction_deferred(zone, order))
+		if (compaction_deferred(zone, order)) {
+			trace_mm_compaction_deffered(zone, order);
 			continue;
+		}
 
 		status = compact_zone_order(zone, order, gfp_mask, mode,
 				&zone_contended, alloc_flags, classzone_idx);
@@ -1435,6 +1437,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			 * succeeds in this zone.
 			 */
 			compaction_defer_reset(zone, order, false);
+			trace_mm_compaction_defer_reset(zone, order);
+
 			/*
 			 * It is possible that async compaction aborted due to
 			 * need_resched() and the watermarks were ok thanks to
@@ -1456,6 +1460,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 			 * succeeding after all, it will be reset.
 			 */
 			defer_compaction(zone, order);
+			trace_mm_compaction_defer_compaction(zone, order);
 		}
 
 		/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
