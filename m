Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6679E6B0254
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 11:24:22 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so81550547wid.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:24:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n18si5483674wij.109.2015.08.27.08.24.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Aug 2015 08:24:18 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/3] mm, compaction: export tracepoints zone names to userspace
Date: Thu, 27 Aug 2015 17:24:03 +0200
Message-Id: <1440689044-2922-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
References: <1440689044-2922-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>

Some compaction tracepoints use zone->name to print which zone is being
compacted. This works for in-kernel printing, but not userspace trace printing
of raw captured trace such as via trace-cmd report.

This patch uses zone_idx() instead of zone->name as the raw value, and when
printing, converts the zone_type to string using the appropriate EM() macros
and some ugly tricks to overcome the problem that half the values depend on
CONFIG_ options and one does not simply use #ifdef inside of #define.

trace-cmd output before:
transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
zone=ffffffff81815d7a order=9 ret=partial

after:
transhuge-stres-4235  [000]   453.149280: mm_compaction_finished: node=0
zone=Normal   order=9 ret=partial

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>
---
 include/trace/events/compaction.h | 38 ++++++++++++++++++++++++++++++++------
 1 file changed, 32 insertions(+), 6 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 1275a55..8daa8fa 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -18,6 +18,31 @@
 	EM( COMPACT_NO_SUITABLE_PAGE,	"no_suitable_page")	\
 	EMe(COMPACT_NOT_SUITABLE_ZONE,	"not_suitable_zone")
 
+#ifdef CONFIG_ZONE_DMA
+#define IFDEF_ZONE_DMA(X) X
+#else
+#define IFDEF_ZONE_DMA(X)
+#endif
+
+#ifdef CONFIG_ZONE_DMA32
+#define IFDEF_ZONE_DMA32(X) X
+#else
+#define IFDEF_ZONE_DMA32(X)
+#endif
+
+#ifdef CONFIG_ZONE_HIGHMEM_
+#define IFDEF_ZONE_HIGHMEM(X) X
+#else
+#define IFDEF_ZONE_HIGHMEM(X)
+#endif
+
+#define ZONE_TYPE						\
+	IFDEF_ZONE_DMA(		EM (ZONE_DMA,	 "DMA"))	\
+	IFDEF_ZONE_DMA32(	EM (ZONE_DMA32,	 "DMA32"))	\
+				EM (ZONE_NORMAL, "Normal")	\
+	IFDEF_ZONE_HIGHMEM(	EM (ZONE_HIGHMEM,"HighMem"))	\
+				EMe(ZONE_MOVABLE,"Movable")
+
 /*
  * First define the enums in the above macros to be exported to userspace
  * via TRACE_DEFINE_ENUM().
@@ -28,6 +53,7 @@
 #define EMe(a, b)	TRACE_DEFINE_ENUM(a);
 
 COMPACTION_STATUS
+ZONE_TYPE
 
 /*
  * Now redefine the EM() and EMe() macros to map the enums to the strings
@@ -230,21 +256,21 @@ DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
 
 	TP_STRUCT__entry(
 		__field(int, nid)
-		__field(char *, name)
+		__field(enum zone_type, idx)
 		__field(int, order)
 		__field(int, ret)
 	),
 
 	TP_fast_assign(
 		__entry->nid = zone_to_nid(zone);
-		__entry->name = (char *)zone->name;
+		__entry->idx = zone_idx(zone);
 		__entry->order = order;
 		__entry->ret = ret;
 	),
 
 	TP_printk("node=%d zone=%-8s order=%d ret=%s",
 		__entry->nid,
-		__entry->name,
+		__print_symbolic(__entry->idx, ZONE_TYPE),
 		__entry->order,
 		__print_symbolic(__entry->ret, COMPACTION_STATUS))
 );
@@ -276,7 +302,7 @@ DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 
 	TP_STRUCT__entry(
 		__field(int, nid)
-		__field(char *, name)
+		__field(enum zone_type, idx)
 		__field(int, order)
 		__field(unsigned int, considered)
 		__field(unsigned int, defer_shift)
@@ -285,7 +311,7 @@ DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 
 	TP_fast_assign(
 		__entry->nid = zone_to_nid(zone);
-		__entry->name = (char *)zone->name;
+		__entry->idx = zone_idx(zone);
 		__entry->order = order;
 		__entry->considered = zone->compact_considered;
 		__entry->defer_shift = zone->compact_defer_shift;
@@ -294,7 +320,7 @@ DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 
 	TP_printk("node=%d zone=%-8s order=%d order_failed=%d consider=%u limit=%lu",
 		__entry->nid,
-		__entry->name,
+		__print_symbolic(__entry->idx, ZONE_TYPE),
 		__entry->order,
 		__entry->order_failed,
 		__entry->considered,
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
