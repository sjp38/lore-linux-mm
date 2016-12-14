Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 810CB6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 09:53:34 -0500 (EST)
Received: by mail-vk0-f70.google.com with SMTP id y197so26127842vky.6
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 06:53:34 -0800 (PST)
Received: from mail-qk0-f195.google.com (mail-qk0-f195.google.com. [209.85.220.195])
        by mx.google.com with ESMTPS id 44si15315393uaq.3.2016.12.14.06.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 06:53:33 -0800 (PST)
Received: by mail-qk0-f195.google.com with SMTP id n204so3326604qke.2
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 06:53:33 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/3] mm, trace: extract COMPACTION_STATUS and ZONE_TYPE to a common header
Date: Wed, 14 Dec 2016 15:53:22 +0100
Message-Id: <20161214145324.26261-2-mhocko@kernel.org>
In-Reply-To: <20161214145324.26261-1-mhocko@kernel.org>
References: <20161214145324.26261-1-mhocko@kernel.org>
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

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/trace/events/compaction.h | 56 ----------------------------------
 include/trace/events/mmflags.h    | 64 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 64 insertions(+), 56 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index cbdb90b6b308..2334faa56323 100644
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
