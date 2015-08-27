Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2A51B6B0254
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 11:24:20 -0400 (EDT)
Received: by wicge2 with SMTP id ge2so5468698wic.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:24:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ab3si17089574wid.70.2015.08.27.08.24.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Aug 2015 08:24:18 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/3] mm, compaction: export tracepoints status strings to userspace
Date: Thu, 27 Aug 2015 17:24:02 +0200
Message-Id: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

Some compaction tracepoints convert the integer return values to strings using
the compaction_status_string array. This works for in-kernel printing, but not
userspace trace printing of raw captured trace such as via trace-cmd report.

This patch converts the private array to appropriate tracepoint macros that
result in proper userspace support.

trace-cmd output before:
transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
  zone=ffffffff81815d7a order=9 ret=

after:
transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
  zone=ffffffff81815d7a order=9 ret=partial

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
---
 include/trace/events/compaction.h | 33 +++++++++++++++++++++++++++++++--
 mm/compaction.c                   | 11 -----------
 2 files changed, 31 insertions(+), 13 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 9a6a3fe..1275a55 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -9,6 +9,35 @@
 #include <linux/tracepoint.h>
 #include <trace/events/gfpflags.h>
 
+#define COMPACTION_STATUS					\
+	EM( COMPACT_DEFERRED,		"deferred")		\
+	EM( COMPACT_SKIPPED,		"skipped")		\
+	EM( COMPACT_CONTINUE,		"continue")		\
+	EM( COMPACT_PARTIAL,		"partial")		\
+	EM( COMPACT_COMPLETE,		"complete")		\
+	EM( COMPACT_NO_SUITABLE_PAGE,	"no_suitable_page")	\
+	EMe(COMPACT_NOT_SUITABLE_ZONE,	"not_suitable_zone")
+
+/*
+ * First define the enums in the above macros to be exported to userspace
+ * via TRACE_DEFINE_ENUM().
+ */
+#undef EM
+#undef EMe
+#define EM(a, b)	TRACE_DEFINE_ENUM(a);
+#define EMe(a, b)	TRACE_DEFINE_ENUM(a);
+
+COMPACTION_STATUS
+
+/*
+ * Now redefine the EM() and EMe() macros to map the enums to the strings
+ * that will be printed in the output.
+ */
+#undef EM
+#undef EMe
+#define EM(a, b)	{a, b},
+#define EMe(a, b)	{a, b}
+
 DECLARE_EVENT_CLASS(mm_compaction_isolate_template,
 
 	TP_PROTO(
@@ -161,7 +190,7 @@ TRACE_EVENT(mm_compaction_end,
 		__entry->free_pfn,
 		__entry->zone_end,
 		__entry->sync ? "sync" : "async",
-		compaction_status_string[__entry->status])
+		__print_symbolic(__entry->status, COMPACTION_STATUS))
 );
 
 TRACE_EVENT(mm_compaction_try_to_compact_pages,
@@ -217,7 +246,7 @@ DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
 		__entry->nid,
 		__entry->name,
 		__entry->order,
-		compaction_status_string[__entry->ret])
+		__print_symbolic(__entry->ret, COMPACTION_STATUS))
 );
 
 DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_finished,
diff --git a/mm/compaction.c b/mm/compaction.c
index 018f08d..7d6ef6e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -35,17 +35,6 @@ static inline void count_compact_events(enum vm_event_item item, long delta)
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
-#ifdef CONFIG_TRACEPOINTS
-static const char *const compaction_status_string[] = {
-	"deferred",
-	"skipped",
-	"continue",
-	"partial",
-	"complete",
-	"no_suitable_page",
-	"not_suitable_zone",
-};
-#endif
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/compaction.h>
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
