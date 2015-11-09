Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6F54A6B0256
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 02:24:34 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so190540718pab.0
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 23:24:34 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id qb9si20597081pac.90.2015.11.08.23.24.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Nov 2015 23:24:33 -0800 (PST)
Received: by padhx2 with SMTP id hx2so182019041pad.1
        for <linux-mm@kvack.org>; Sun, 08 Nov 2015 23:24:33 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/3] mm/cma: add new tracepoint, test_pages_isolated
Date: Mon,  9 Nov 2015 16:24:20 +0900
Message-Id: <1447053861-28824-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1447053861-28824-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

cma allocation should be guranteeded to succeed, but, sometimes,
it could be failed in current implementation. To track down
the problem, we need to know which page is problematic and
this new tracepoint will report it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/trace/events/cma.h | 26 ++++++++++++++++++++++++++
 mm/page_isolation.c        |  5 +++++
 2 files changed, 31 insertions(+)

diff --git a/include/trace/events/cma.h b/include/trace/events/cma.h
index d7cd961..82281b0 100644
--- a/include/trace/events/cma.h
+++ b/include/trace/events/cma.h
@@ -60,6 +60,32 @@ TRACE_EVENT(cma_release,
 		  __entry->count)
 );
 
+TRACE_EVENT(test_pages_isolated,
+
+	TP_PROTO(
+		unsigned long start_pfn,
+		unsigned long end_pfn,
+		unsigned long fin_pfn),
+
+	TP_ARGS(start_pfn, end_pfn, fin_pfn),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, start_pfn)
+		__field(unsigned long, end_pfn)
+		__field(unsigned long, fin_pfn)
+	),
+
+	TP_fast_assign(
+		__entry->start_pfn = start_pfn;
+		__entry->end_pfn = end_pfn;
+		__entry->fin_pfn = fin_pfn;
+	),
+
+	TP_printk("start_pfn=0x%lx end_pfn=0x%lx fin_pfn=0x%lx ret=%s",
+		__entry->start_pfn, __entry->end_pfn, __entry->fin_pfn,
+		__entry->end_pfn == __entry->fin_pfn ? "success" : "fail")
+);
+
 #endif /* _TRACE_CMA_H */
 
 /* This part must be outside protection */
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 6f5ae96..bda0fea 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -7,6 +7,8 @@
 #include <linux/pageblock-flags.h>
 #include <linux/memory.h>
 #include <linux/hugetlb.h>
+#include <trace/events/cma.h>
+
 #include "internal.h"
 
 static int set_migratetype_isolate(struct page *page,
@@ -268,6 +270,9 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 						skip_hwpoisoned_pages);
 	spin_unlock_irqrestore(&zone->lock, flags);
 
+#ifdef CONFIG_CMA
+	trace_test_pages_isolated(start_pfn, end_pfn, pfn);
+#endif
 	return (pfn < end_pfn) ? -EBUSY : 0;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
