Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A2A696B0073
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 02:40:51 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so15867246pad.13
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 23:40:51 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id wx10si741424pab.220.2015.01.14.23.40.40
        for <linux-mm@kvack.org>;
        Wed, 14 Jan 2015 23:40:41 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 4/5] mm/compaction: more trace to understand when/why compaction start/finish
Date: Thu, 15 Jan 2015 16:41:12 +0900
Message-Id: <1421307673-24084-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1421307673-24084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1421307673-24084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It is not well analyzed that when/why compaction start/finish or not. With
these new tracepoints, we can know much more about start/finish reason of
compaction. I can find following bug with these tracepoint.

http://www.spinics.net/lists/linux-mm/msg81582.html

Change from v2: omit alloc_flag, classzone_idx from tracepoint output

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/compaction.h        |    3 ++
 include/trace/events/compaction.h |   74 +++++++++++++++++++++++++++++++++++++
 mm/compaction.c                   |   38 +++++++++++++++++--
 3 files changed, 111 insertions(+), 4 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index a9547b6..d82181a 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -12,6 +12,9 @@
 #define COMPACT_PARTIAL		3
 /* The full zone was compacted */
 #define COMPACT_COMPLETE	4
+/* For more detailed tracepoint output */
+#define COMPACT_NO_SUITABLE_PAGE	5
+#define COMPACT_NOT_SUITABLE_ZONE	6
 /* When adding new state, please change compaction_status_string, too */
 
 /* Used to signal whether compaction detected need_sched() or lock contention */
diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 139020b..d465358 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -164,6 +164,80 @@ TRACE_EVENT(mm_compaction_end,
 		compaction_status_string[__entry->status])
 );
 
+TRACE_EVENT(mm_compaction_try_to_compact_pages,
+
+	TP_PROTO(
+		int order,
+		gfp_t gfp_mask,
+		enum migrate_mode mode),
+
+	TP_ARGS(order, gfp_mask, mode),
+
+	TP_STRUCT__entry(
+		__field(int, order)
+		__field(gfp_t, gfp_mask)
+		__field(enum migrate_mode, mode)
+	),
+
+	TP_fast_assign(
+		__entry->order = order;
+		__entry->gfp_mask = gfp_mask;
+		__entry->mode = mode;
+	),
+
+	TP_printk("order=%d gfp_mask=0x%x mode=%d",
+		__entry->order,
+		__entry->gfp_mask,
+		(int)__entry->mode)
+);
+
+DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
+
+	TP_PROTO(struct zone *zone,
+		int order,
+		int ret),
+
+	TP_ARGS(zone, order, ret),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(char *, name)
+		__field(int, order)
+		__field(int, ret)
+	),
+
+	TP_fast_assign(
+		__entry->nid = zone_to_nid(zone);
+		__entry->name = (char *)zone->name;
+		__entry->order = order;
+		__entry->ret = ret;
+	),
+
+	TP_printk("node=%d zone=%-8s order=%d ret=%s",
+		__entry->nid,
+		__entry->name,
+		__entry->order,
+		compaction_status_string[__entry->ret])
+);
+
+DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_finished,
+
+	TP_PROTO(struct zone *zone,
+		int order,
+		int ret),
+
+	TP_ARGS(zone, order, ret)
+);
+
+DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
+
+	TP_PROTO(struct zone *zone,
+		int order,
+		int ret),
+
+	TP_ARGS(zone, order, ret)
+);
+
 #endif /* _TRACE_COMPACTION_H */
 
 /* This part must be outside protection */
diff --git a/mm/compaction.c b/mm/compaction.c
index be28469..97702a8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -25,6 +25,8 @@ char *compaction_status_string[] = {
 	"continue",
 	"partial",
 	"complete",
+	"no_suitable_page",
+	"not_suitable_zone",
 };
 
 static inline void count_compact_event(enum vm_event_item item)
@@ -1048,7 +1050,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 	return cc->nr_migratepages ? ISOLATE_SUCCESS : ISOLATE_NONE;
 }
 
-static int compact_finished(struct zone *zone, struct compact_control *cc,
+static int __compact_finished(struct zone *zone, struct compact_control *cc,
 			    const int migratetype)
 {
 	unsigned int order;
@@ -1103,7 +1105,20 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
 			return COMPACT_PARTIAL;
 	}
 
-	return COMPACT_CONTINUE;
+	return COMPACT_NO_SUITABLE_PAGE;
+}
+
+static int compact_finished(struct zone *zone, struct compact_control *cc,
+			    const int migratetype)
+{
+	int ret;
+
+	ret = __compact_finished(zone, cc, migratetype);
+	trace_mm_compaction_finished(zone, cc->order, ret);
+	if (ret == COMPACT_NO_SUITABLE_PAGE)
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
@@ -1157,11 +1172,24 @@ unsigned long compaction_suitable(struct zone *zone, int order,
 	 */
 	fragindex = fragmentation_index(zone, order);
 	if (fragindex >= 0 && fragindex <= sysctl_extfrag_threshold)
-		return COMPACT_SKIPPED;
+		return COMPACT_NOT_SUITABLE_ZONE;
 
 	return COMPACT_CONTINUE;
 }
 
+unsigned long compaction_suitable(struct zone *zone, int order,
+					int alloc_flags, int classzone_idx)
+{
+	unsigned long ret;
+
+	ret = __compaction_suitable(zone, order, alloc_flags, classzone_idx);
+	trace_mm_compaction_suitable(zone, order, ret);
+	if (ret == COMPACT_NOT_SUITABLE_ZONE)
+		ret = COMPACT_SKIPPED;
+
+	return ret;
+}
+
 static int compact_zone(struct zone *zone, struct compact_control *cc)
 {
 	int ret;
@@ -1377,6 +1405,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	if (!order || !may_enter_fs || !may_perform_io)
 		return COMPACT_SKIPPED;
 
+	trace_mm_compaction_try_to_compact_pages(order, gfp_mask, mode);
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
