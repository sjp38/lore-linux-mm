Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 578626B006E
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 02:48:45 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so15306692pac.39
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 23:48:45 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id fq4si16507840pbd.242.2014.12.02.23.48.41
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 23:48:43 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/3] mm/compaction: add more trace to understand compaction start/finish condition
Date: Wed,  3 Dec 2014 16:52:06 +0900
Message-Id: <1417593127-6819-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1417593127-6819-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It is not well analyzed that when compaction start and when compaction
finish. With this tracepoint for compaction start/finish condition, I can
find following bug.

http://www.spinics.net/lists/linux-mm/msg81582.html

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/compaction.h        |    2 +
 include/trace/events/compaction.h |   91 +++++++++++++++++++++++++++++++++++++
 mm/compaction.c                   |   40 ++++++++++++++--
 3 files changed, 129 insertions(+), 4 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index a9547b6..bdb4b99 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -12,6 +12,8 @@
 #define COMPACT_PARTIAL		3
 /* The full zone was compacted */
 #define COMPACT_COMPLETE	4
+/* For more detailed tracepoint output, will be converted to COMPACT_CONTINUE */
+#define COMPACT_NOT_SUITABLE	5
 /* When adding new state, please change compaction_status_string, too */
 
 /* Used to signal whether compaction detected need_sched() or lock contention */
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 139020b..5e47cb2 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -164,6 +164,97 @@ TRACE_EVENT(mm_compaction_end,
 		compaction_status_string[__entry->status])
 );
 
+TRACE_EVENT(mm_compaction_try_to_compact_pages,
+
+	TP_PROTO(
+		unsigned int order,
+		gfp_t gfp_mask,
+		enum migrate_mode mode,
+		int alloc_flags,
+		int classzone_idx),
+
+	TP_ARGS(order, gfp_mask, mode, alloc_flags, classzone_idx),
+
+	TP_STRUCT__entry(
+		__field(unsigned int, order)
+		__field(gfp_t, gfp_mask)
+		__field(enum migrate_mode, mode)
+		__field(int, alloc_flags)
+		__field(int, classzone_idx)
+	),
+
+	TP_fast_assign(
+		__entry->order = order;
+		__entry->gfp_mask = gfp_mask;
+		__entry->mode = mode;
+		__entry->alloc_flags = alloc_flags;
+		__entry->classzone_idx = classzone_idx;
+	),
+
+	TP_printk("order=%u gfp_mask=0x%x mode=%d alloc_flags=0x%x classzone_idx=%d",
+		__entry->order,
+		__entry->gfp_mask,
+		(int)__entry->mode,
+		__entry->alloc_flags,
+		__entry->classzone_idx)
+);
+
+DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
+
+	TP_PROTO(struct zone *zone,
+		unsigned int order,
+		int alloc_flags,
+		int classzone_idx,
+		int ret),
+
+	TP_ARGS(zone, order, alloc_flags, classzone_idx, ret),
+
+	TP_STRUCT__entry(
+		__field(char *, name)
+		__field(unsigned int, order)
+		__field(int, alloc_flags)
+		__field(int, classzone_idx)
+		__field(int, ret)
+	),
+
+	TP_fast_assign(
+		__entry->name = (char *)zone->name;
+		__entry->order = order;
+		__entry->alloc_flags = alloc_flags;
+		__entry->classzone_idx = classzone_idx;
+		__entry->ret = ret;
+	),
+
+	TP_printk("zone=%-8s order=%u alloc_flags=0x%x classzone_idx=%d ret=%s",
+		__entry->name,
+		__entry->order,
+		__entry->alloc_flags,
+		__entry->classzone_idx,
+		compaction_status_string[__entry->ret])
+);
+
+DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_finished,
+
+	TP_PROTO(struct zone *zone,
+		unsigned int order,
+		int alloc_flags,
+		int classzone_idx,
+		int ret),
+
+	TP_ARGS(zone, order, alloc_flags, classzone_idx, ret)
+);
+
+DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
+
+	TP_PROTO(struct zone *zone,
+		unsigned int order,
+		int alloc_flags,
+		int classzone_idx,
+		int ret),
+
+	TP_ARGS(zone, order, alloc_flags, classzone_idx, ret)
+);
+
 #endif /* _TRACE_COMPACTION_H */
 
 /* This part must be outside protection */
diff --git a/mm/compaction.c b/mm/compaction.c
index 4c7b837..f5d2405 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -25,6 +25,7 @@ char *compaction_status_string[] = {
 	"continue",
 	"partial",
 	"complete",
+	"not_suitable_page",
 };
 
 static inline void count_compact_event(enum vm_event_item item)
@@ -1048,7 +1049,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
 
-static int compact_finished(struct zone *zone, struct compact_control *cc,
+static int __compact_finished(struct zone *zone, struct compact_control *cc,
 			    const int migratetype)
 {
 	unsigned int order;
@@ -1103,7 +1104,21 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
 			return COMPACT_PARTIAL;
 	}
 
-	return COMPACT_CONTINUE;
+	return COMPACT_NOT_SUITABLE;
+}
+
+static int compact_finished(struct zone *zone, struct compact_control *cc,
+			    const int migratetype)
+{
+	int ret;
+
+	ret = __compact_finished(zone, cc, migratetype);
+	trace_mm_compaction_finished(zone, cc->order, cc->alloc_flags,
+						cc->classzone_idx, ret);
+	if (ret == COMPACT_NOT_SUITABLE)
+		ret = COMPACT_CONTINUE;
+
+	return ret;
 }
 
 /*
@@ -1113,7 +1128,7 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
  *   COMPACT_PARTIAL  - If the allocation would succeed without compaction
  *   COMPACT_CONTINUE - If compaction should run now
  */
-unsigned long compaction_suitable(struct zone *zone, int order,
+static unsigned long __compaction_suitable(struct zone *zone, int order,
 					int alloc_flags, int classzone_idx)
 {
 	int fragindex;
@@ -1157,11 +1172,25 @@ unsigned long compaction_suitable(struct zone *zone, int order,
 	 */
 	fragindex = fragmentation_index(zone, order);
 	if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
-		return COMPACT_SKIPPED;
+		return COMPACT_NOT_SUITABLE;
 
 	return COMPACT_CONTINUE;
 }
 
+unsigned long compaction_suitable(struct zone *zone, int order,
+					int alloc_flags, int classzone_idx)
+{
+	unsigned long ret;
+
+	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx);
+	trace_mm_compaction_suitable(zone, order, alloc_flags,
+						classzone_idx, ret);
+	if (ret == COMPACT_NOT_SUITABLE)
+		ret = COMPACT_SKIPPED;
+
+	return ret;
+}
+
 static int compact_zone(struct zone *zone, struct compact_control *cc)
 {
 	int ret;
@@ -1375,6 +1404,9 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	if (!order || !may_enter_fs || !may_perform_io)
 		return COMPACT_SKIPPED;
 
+	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, mode,
+					alloc_flags, classzone_idx);
+
 	/* Compact each zone in the list */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
 								nodemask) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
