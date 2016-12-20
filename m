Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E03DD6B02F6
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:01:45 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id hb5so53332254wjc.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:01:45 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id e124si18924828wme.48.2016.12.20.05.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:01:44 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id u144so24184256wmu.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:01:44 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/3] mm, trace: extract COMPACTION_STATUS and ZONE_TYPE to a common header
Date: Tue, 20 Dec 2016 14:01:33 +0100
Message-Id: <20161220130135.15719-2-mhocko@kernel.org>
In-Reply-To: <20161220130135.15719-1-mhocko@kernel.org>
References: <20161220130135.15719-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

COMPACTION_STATUS resp. ZONE_TYPE are currently used to translate enum
compact_result resp. struct zone index into their symbolic names for
an easier post processing. The follow up patch would like to reuse
this as well. The code involves some preprocessor black magic which is
better not duplicated elsewhere so move it to a common mm tracing relate
header.

Changes since v1
- fix compile issue with CONFIG_COMPACTION=n reported by kbuild test
  robot

Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/trace/events/compaction.h | 60 ++----------------------------------
 include/trace/events/mmflags.h    | 64 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+), 57 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index cbdb90b6b308..0a18ab6483ff 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -9,62 +9,6 @@
 #include <linux/tracepoint.h>
 #include <trace/events/mmflags.h>
 
-#define COMPACTION_STATUS					\
-	EM( COMPACT_SKIPPED,		"skipped")		\
-	EM( COMPACT_DEFERRED,		"deferred")		\
-	EM( COMPACT_CONTINUE,		"continue")		\
-	EM( COMPACT_SUCCESS,		"success")		\
-	EM( COMPACT_PARTIAL_SKIPPED,	"partial_skipped")	\
-	EM( COMPACT_COMPLETE,		"complete")		\
-	EM( COMPACT_NO_SUITABLE_PAGE,	"no_suitable_page")	\
-	EM( COMPACT_NOT_SUITABLE_ZONE,	"not_suitable_zone")	\
-	EMe(COMPACT_CONTENDED,		"contended")
-
-#ifdef CONFIG_ZONE_DMA
-#define IFDEF_ZONE_DMA(X) X
-#else
-#define IFDEF_ZONE_DMA(X)
-#endif
-
-#ifdef CONFIG_ZONE_DMA32
-#define IFDEF_ZONE_DMA32(X) X
-#else
-#define IFDEF_ZONE_DMA32(X)
-#endif
-
-#ifdef CONFIG_HIGHMEM
-#define IFDEF_ZONE_HIGHMEM(X) X
-#else
-#define IFDEF_ZONE_HIGHMEM(X)
-#endif
-
-#define ZONE_TYPE						\
-	IFDEF_ZONE_DMA(		EM (ZONE_DMA,	 "DMA"))	\
-	IFDEF_ZONE_DMA32(	EM (ZONE_DMA32,	 "DMA32"))	\
-				EM (ZONE_NORMAL, "Normal")	\
-	IFDEF_ZONE_HIGHMEM(	EM (ZONE_HIGHMEM,"HighMem"))	\
-				EMe(ZONE_MOVABLE,"Movable")
-
-/*
- * First define the enums in the above macros to be exported to userspace
- * via TRACE_DEFINE_ENUM().
- */
-#undef EM
-#undef EMe
-#define EM(a, b)	TRACE_DEFINE_ENUM(a);
-#define EMe(a, b)	TRACE_DEFINE_ENUM(a);
-
-COMPACTION_STATUS
-ZONE_TYPE
-
-/*
- * Now redefine the EM() and EMe() macros to map the enums to the strings
- * that will be printed in the output.
- */
-#undef EM
-#undef EMe
-#define EM(a, b)	{a, b},
-#define EMe(a, b)	{a, b}
 
 DECLARE_EVENT_CLASS(mm_compaction_isolate_template,
 
@@ -187,6 +131,7 @@ TRACE_EVENT(mm_compaction_begin,
 		__entry->sync ? "sync" : "async")
 );
 
+#ifdef CONFIG_COMPACTION
 TRACE_EVENT(mm_compaction_end,
 	TP_PROTO(unsigned long zone_start, unsigned long migrate_pfn,
 		unsigned long free_pfn, unsigned long zone_end, bool sync,
@@ -220,6 +165,7 @@ TRACE_EVENT(mm_compaction_end,
 		__entry->sync ? "sync" : "async",
 		__print_symbolic(__entry->status, COMPACTION_STATUS))
 );
+#endif
 
 TRACE_EVENT(mm_compaction_try_to_compact_pages,
 
@@ -248,6 +194,7 @@ TRACE_EVENT(mm_compaction_try_to_compact_pages,
 		__entry->prio)
 );
 
+#ifdef CONFIG_COMPACTION
 DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
 
 	TP_PROTO(struct zone *zone,
@@ -295,7 +242,6 @@ DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
 	TP_ARGS(zone, order, ret)
 );
 
-#ifdef CONFIG_COMPACTION
 DECLARE_EVENT_CLASS(mm_compaction_defer_template,
 
 	TP_PROTO(struct zone *zone, int order),
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 5a81ab48a2fb..7e4cfede873c 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -1,3 +1,6 @@
+#include <linux/node.h>
+#include <linux/mmzone.h>
+#include <linux/compaction.h>
 /*
  * The order of these masks is important. Matching masks will be seen
  * first and the left over flags will end up showing by themselves.
@@ -172,3 +175,64 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
 	(flags) ? __print_flags(flags, "|",				\
 	__def_vmaflag_names						\
 	) : "none"
+
+#ifdef CONFIG_COMPACTION
+#define COMPACTION_STATUS					\
+	EM( COMPACT_SKIPPED,		"skipped")		\
+	EM( COMPACT_DEFERRED,		"deferred")		\
+	EM( COMPACT_CONTINUE,		"continue")		\
+	EM( COMPACT_SUCCESS,		"success")		\
+	EM( COMPACT_PARTIAL_SKIPPED,	"partial_skipped")	\
+	EM( COMPACT_COMPLETE,		"complete")		\
+	EM( COMPACT_NO_SUITABLE_PAGE,	"no_suitable_page")	\
+	EM( COMPACT_NOT_SUITABLE_ZONE,	"not_suitable_zone")	\
+	EMe(COMPACT_CONTENDED,		"contended")
+#else
+#define COMPACTION_STATUS
+#endif
+
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
+#ifdef CONFIG_HIGHMEM
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
+ZONE_TYPE
+
+/*
+ * Now redefine the EM() and EMe() macros to map the enums to the strings
+ * that will be printed in the output.
+ */
+#undef EM
+#undef EMe
+#define EM(a, b)	{a, b},
+#define EMe(a, b)	{a, b}
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
