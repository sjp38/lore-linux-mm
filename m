Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 71B746B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 09:31:53 -0400 (EDT)
Received: by pdea3 with SMTP id a3so3844921pde.3
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 06:31:53 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ko8si2925009pdb.191.2015.04.01.06.31.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 01 Apr 2015 06:31:52 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NM400HP6R3S3610@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 01 Apr 2015 14:35:52 +0100 (BST)
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: [PATCH] mm: cma: add trace events for CMA allocations and freeings
Date: Wed, 01 Apr 2015 16:31:43 +0300
Message-id: <1427895103-9431-1-git-send-email-s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Stefan Strogin <s.strogin@partner.samsung.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Sasha Levin <sasha.levin@oracle.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gioh.kim@lge.com, stefan.strogin@gmail.com

Add trace events for cma_alloc() and cma_release().

The cma_alloc tracepoint is used both for successful and failed allocations,
in case of allocation failure pfn=-1UL is stored and printed.

Signed-off-by: Stefan Strogin <stefan.strogin@gmail.com>
---

Took out from the patch set "mm: cma: add some debug information for CMA" v4
(http://thread.gmane.org/gmane.linux.kernel.mm/129903) because of probable
uselessness of the rest of the patches.

Changes from the version from the patch set:
- Constify the struct page * parameter passed to the tracepoints.
- Pass both pfn and struct page * to the tracepoints to decrease unnecessary
  pfn_to_page() and page_to_pfn() calls and avoid using them in TP_printk.
- Store and print pfn=-1UL instead of pfn=0, because 0th pfn can truly exist
  on some architectures.

 include/trace/events/cma.h | 63 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/cma.c                   |  5 ++++
 2 files changed, 68 insertions(+)
 create mode 100644 include/trace/events/cma.h

diff --git a/include/trace/events/cma.h b/include/trace/events/cma.h
new file mode 100644
index 0000000..e01b35d
--- /dev/null
+++ b/include/trace/events/cma.h
@@ -0,0 +1,63 @@
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
+	TP_PROTO(unsigned long pfn, const struct page *page,
+		 unsigned int count),
+
+	TP_ARGS(pfn, page, count),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(const struct page *, page)
+		__field(unsigned int, count)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+		__entry->page = page;
+		__entry->count = count;
+	),
+
+	TP_printk("pfn=%lx page=%p count=%u",
+		  __entry->pfn,
+		  __entry->page,
+		  __entry->count)
+);
+
+TRACE_EVENT(cma_release,
+
+	TP_PROTO(unsigned long pfn, const struct page *page,
+		 unsigned int count),
+
+	TP_ARGS(pfn, page, count),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(const struct page *, page)
+		__field(unsigned int, count)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+		__entry->page = page;
+		__entry->count = count;
+	),
+
+	TP_printk("pfn=%lx page=%p count=%u",
+		  __entry->pfn,
+		  __entry->page,
+		  __entry->count)
+);
+
+#endif /* _TRACE_CMA_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/cma.c b/mm/cma.c
index 47203fa..e9410b7c 100644
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
 
@@ -414,6 +416,8 @@ struct page *cma_alloc(struct cma *cma, unsigned int count, unsigned int align)
 		start = bitmap_no + mask + 1;
 	}
 
+	trace_cma_alloc(page ? pfn : -1UL, page, count);
+
 	pr_debug("%s(): returned %p\n", __func__, page);
 	return page;
 }
@@ -446,6 +450,7 @@ bool cma_release(struct cma *cma, const struct page *pages, unsigned int count)
 
 	free_contig_range(pfn, count);
 	cma_clear_bitmap(cma, pfn, count);
+	trace_cma_release(pfn, pages, count);
 
 	return true;
 }
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
