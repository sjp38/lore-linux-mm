Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4AFEC6B0070
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 13:45:03 -0500 (EST)
Received: by pablf10 with SMTP id lf10so38042892pab.6
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 10:45:03 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id ry1si14060305pac.187.2015.02.24.10.45.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 24 Feb 2015 10:45:02 -0800 (PST)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKA007CDHLKW950@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 24 Feb 2015 18:48:56 +0000 (GMT)
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: [PATCH v3 1/4] mm: cma: add trace events to debug
 physically-contiguous memory allocations
Date: Tue, 24 Feb 2015 21:44:32 +0300
Message-id: 
 <9ae4c45b49e8df6e079448550c2b81ade5d3603a.1424802755.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1424802755.git.s.strogin@partner.samsung.com>
References: <cover.1424802755.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Stefan Strogin <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Add trace events for cma_alloc() and cma_release().

Signed-off-by: Stefan Strogin <s.strogin@partner.samsung.com>
---
 include/trace/events/cma.h | 57 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/cma.c                   |  6 +++++
 2 files changed, 63 insertions(+)
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
index 9e3d44a..3a63c96 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -23,6 +23,7 @@
 #  define DEBUG
 #endif
 #endif
+#define CREATE_TRACE_POINTS
 
 #include <linux/memblock.h>
 #include <linux/err.h>
@@ -34,6 +35,7 @@
 #include <linux/cma.h>
 #include <linux/highmem.h>
 #include <linux/io.h>
+#include <trace/events/cma.h>
 
 #include "cma.h"
 
@@ -408,6 +410,9 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 		start = bitmap_no + mask + 1;
 	}
 
+	if (page)
+		trace_cma_alloc(cma, pfn, count);
+
 	pr_debug("%s(): returned %p\n", __func__, page);
 	return page;
 }
@@ -440,6 +445,7 @@ bool cma_release(struct cma *cma, struct page *pages, int count)
 
 	free_contig_range(pfn, count);
 	cma_clear_bitmap(cma, pfn, count);
+	trace_cma_release(cma, pfn, count);
 
 	return true;
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
