Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E0EF96B0253
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 21:24:01 -0500 (EST)
Received: by padhx2 with SMTP id hx2so84071834pad.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 18:24:01 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id gn10si23859559pac.10.2015.11.12.18.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 18:24:01 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so83937428pac.3
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 18:24:01 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/3] mm/page_isolation: add new tracepoint, test_pages_isolated
Date: Fri, 13 Nov 2015 11:23:47 +0900
Message-Id: <1447381428-12445-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1447381428-12445-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1447381428-12445-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

cma allocation should be guranteeded to succeed, but, sometimes,
it could be failed in current implementation. To track down
the problem, we need to know which page is problematic and
this new tracepoint will report it.

Acked-by: Michal Nazarewicz <mina86@mina86.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/trace/events/page_isolation.h | 38 +++++++++++++++++++++++++++++++++++
 mm/page_isolation.c                   |  5 +++++
 2 files changed, 43 insertions(+)
 create mode 100644 include/trace/events/page_isolation.h

diff --git a/include/trace/events/page_isolation.h b/include/trace/events/page_isolation.h
new file mode 100644
index 0000000..6fb6440
--- /dev/null
+++ b/include/trace/events/page_isolation.h
@@ -0,0 +1,38 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM page_isolation
+
+#if !defined(_TRACE_PAGE_ISOLATION_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_PAGE_ISOLATION_H
+
+#include <linux/tracepoint.h>
+
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
+#endif /* _TRACE_PAGE_ISOLATION_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 029a171..f484b93 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -9,6 +9,9 @@
 #include <linux/hugetlb.h>
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/page_isolation.h>
+
 static int set_migratetype_isolate(struct page *page,
 				bool skip_hwpoisoned_pages)
 {
@@ -268,6 +271,8 @@ int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 						skip_hwpoisoned_pages);
 	spin_unlock_irqrestore(&zone->lock, flags);
 
+	trace_test_pages_isolated(start_pfn, end_pfn, pfn);
+
 	return pfn < end_pfn ? -EBUSY : 0;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
