Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CC3006B0073
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 17:17:11 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so14296620pab.3
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 14:17:11 -0800 (PST)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id t1si388127pdr.156.2015.02.12.14.17.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 12 Feb 2015 14:17:11 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJO007U2JF85UA0@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 12 Feb 2015 22:21:08 +0000 (GMT)
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: [PATCH 4/4] mm: cma: add trace events to debug physically-contiguous
 memory allocations
Date: Fri, 13 Feb 2015 01:15:44 +0300
Message-id: 
 <3cf88b9b40a883673924571c26608d922f59d900.1423777850.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1423777850.git.s.strogin@partner.samsung.com>
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1423777850.git.s.strogin@partner.samsung.com>
References: <cover.1423777850.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Stefan Strogin <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Add trace events for cma_alloc() and cma_release().

Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>
---
 include/trace/events/cma.h | 57 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/cma.c                   |  7 +++++-
 2 files changed, 63 insertions(+), 1 deletion(-)
 create mode 100644 include/trace/events/cma.h

diff --git a/include/trace/events/cma.h b/include/trace/events/cma.h
new file mode 100644
index 0000000..3fe7a56
--- /dev/null
+++ b/include/trace/events/cma.h
@@ -0,0 +1,57 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM cma
+
+#if !defined(_TRACE_CMA_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_CMA_H
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(cma_alloc,
+
+	TP_PROTO(struct cma *cma, unsigned long pfn, int count),
+
+	TP_ARGS(cma, pfn, count),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(unsigned long, count)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+		__entry->count = count;
+	),
+
+	TP_printk("pfn=%lu page=%p count=%lu\n",
+		  __entry->pfn,
+		  pfn_to_page(__entry->pfn),
+		  __entry->count)
+);
+
+TRACE_EVENT(cma_release,
+
+	TP_PROTO(struct cma *cma, unsigned long pfn, int count),
+
+	TP_ARGS(cma, pfn, count),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(unsigned long, count)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+		__entry->count = count;
+	),
+
+	TP_printk("pfn=%lu page=%p count=%lu\n",
+		  __entry->pfn,
+		  pfn_to_page(__entry->pfn),
+		  __entry->count)
+);
+
+#endif /* _TRACE_CMA_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/cma.c b/mm/cma.c
index c68d383..a7bd7f0 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -23,6 +23,7 @@
 #  define DEBUG
 #endif
 #endif
+#define CREATE_TRACE_POINTS
 
 #include <linux/memblock.h>
 #include <linux/err.h>
@@ -37,6 +38,7 @@
 #include <linux/list.h>
 #include <linux/proc_fs.h>
 #include <linux/time.h>
+#include <trace/events/cma.h>
 
 #include "cma.h"
 
@@ -443,8 +445,10 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 		start = bitmap_no + mask + 1;
 	}
 
-	if (page)
+	if (page) {
 		cma_buffer_list_add(cma, pfn, count);
+		trace_cma_alloc(cma, pfn, count);
+	}
 
 	pr_debug("%s(): returned %p\n", __func__, page);
 	return page;
@@ -478,6 +482,7 @@ bool cma_release(struct cma *cma, struct page *pages, int count)
 
 	free_contig_range(pfn, count);
 	cma_clear_bitmap(cma, pfn, count);
+	trace_cma_release(cma, pfn, count);
 	cma_buffer_list_del(cma, pfn, count);
 
 	return true;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
