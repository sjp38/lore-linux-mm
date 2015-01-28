Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 68BD86B006C
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:24:09 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id bj1so25588078pad.1
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 05:24:09 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id kt6si5840356pbc.47.2015.01.28.05.24.08
        for <linux-mm@kvack.org>;
        Wed, 28 Jan 2015 05:24:08 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/4] mm: move enum tlb_flush_reason into <trace/events/tlb.h>
Date: Wed, 28 Jan 2015 15:17:41 +0200
Message-Id: <1422451064-109023-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1422451064-109023-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The only user of tlb_flush_reason is trace_tlb_flush*(). There's no
reason to define it in mm_types.h

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm_types.h   |  8 --------
 include/trace/events/tlb.h | 15 ++++++++++++---
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 199a03aab8dc..5dfdd5ed5254 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -527,14 +527,6 @@ struct vm_special_mapping
 	struct page **pages;
 };
 
-enum tlb_flush_reason {
-	TLB_FLUSH_ON_TASK_SWITCH,
-	TLB_REMOTE_SHOOTDOWN,
-	TLB_LOCAL_SHOOTDOWN,
-	TLB_LOCAL_MM_SHOOTDOWN,
-	NR_TLB_FLUSH_REASONS,
-};
-
  /*
   * A swap entry has to fit into a "unsigned long", as the entry is hidden
   * in the "index" field of the swapper address space.
diff --git a/include/trace/events/tlb.h b/include/trace/events/tlb.h
index 13391d288107..1f764ff60cf6 100644
--- a/include/trace/events/tlb.h
+++ b/include/trace/events/tlb.h
@@ -4,9 +4,18 @@
 #if !defined(_TRACE_TLB_H) || defined(TRACE_HEADER_MULTI_READ)
 #define _TRACE_TLB_H
 
-#include <linux/mm_types.h>
 #include <linux/tracepoint.h>
 
+#ifndef TRACE_HEADER_MULTI_READ
+enum tlb_flush_reason {
+	TLB_FLUSH_ON_TASK_SWITCH,
+	TLB_REMOTE_SHOOTDOWN,
+	TLB_LOCAL_SHOOTDOWN,
+	TLB_LOCAL_MM_SHOOTDOWN,
+	NR_TLB_FLUSH_REASONS,
+};
+#endif
+
 #define TLB_FLUSH_REASON	\
 	{ TLB_FLUSH_ON_TASK_SWITCH,	"flush on task switch" },	\
 	{ TLB_REMOTE_SHOOTDOWN,		"remote shootdown" },		\
@@ -15,11 +24,11 @@
 
 TRACE_EVENT(tlb_flush,
 
-	TP_PROTO(int reason, unsigned long pages),
+	TP_PROTO(enum tlb_flush_reason reason, unsigned long pages),
 	TP_ARGS(reason, pages),
 
 	TP_STRUCT__entry(
-		__field(	  int, reason)
+		__field(enum tlb_flush_reason, reason)
 		__field(unsigned long,  pages)
 	),
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
