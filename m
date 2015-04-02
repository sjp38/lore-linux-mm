Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id D19596B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 09:14:02 -0400 (EDT)
Received: by pddn5 with SMTP id n5so89284908pdd.2
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 06:14:02 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id nt4si7428553pbc.114.2015.04.02.06.14.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 02 Apr 2015 06:14:01 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NM600FTBKXUNBA0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 02 Apr 2015 14:17:54 +0100 (BST)
From: Stefan Strogin <stefan.strogin@gmail.com>
Subject: [PATCH] mm-cma-add-trace-events-for-cma-allocations-and-freeings-fix
Date: Thu, 02 Apr 2015 16:13:17 +0300
Message-id: <1427980397-21832-1-git-send-email-stefan.strogin@gmail.com>
In-reply-to: <551D3E73.9070405@partner.samsung.com>
References: <551D3E73.9070405@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Stefan Strogin <stefan.strogin@gmail.com>, Stefan Strogin <s.strogin@partner.samsung.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Sasha Levin <sasha.levin@oracle.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gioh.kim@lge.com

Trace 'align' too in cma_alloc trace event.

Signed-off-by: Stefan Strogin <stefan.strogin@gmail.com>
---
 include/trace/events/cma.h | 11 +++++++----
 mm/cma.c                   |  2 +-
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/trace/events/cma.h b/include/trace/events/cma.h
index e01b35d..d7cd961 100644
--- a/include/trace/events/cma.h
+++ b/include/trace/events/cma.h
@@ -10,26 +10,29 @@
 TRACE_EVENT(cma_alloc,
 
 	TP_PROTO(unsigned long pfn, const struct page *page,
-		 unsigned int count),
+		 unsigned int count, unsigned int align),
 
-	TP_ARGS(pfn, page, count),
+	TP_ARGS(pfn, page, count, align),
 
 	TP_STRUCT__entry(
 		__field(unsigned long, pfn)
 		__field(const struct page *, page)
 		__field(unsigned int, count)
+		__field(unsigned int, align)
 	),
 
 	TP_fast_assign(
 		__entry->pfn = pfn;
 		__entry->page = page;
 		__entry->count = count;
+		__entry->align = align;
 	),
 
-	TP_printk("pfn=%lx page=%p count=%u",
+	TP_printk("pfn=%lx page=%p count=%u align=%u",
 		  __entry->pfn,
 		  __entry->page,
-		  __entry->count)
+		  __entry->count,
+		  __entry->align)
 );
 
 TRACE_EVENT(cma_release,
diff --git a/mm/cma.c b/mm/cma.c
index e9410b7c..3a7a67b 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -416,7 +416,7 @@ struct page *cma_alloc(struct cma *cma, unsigned int count, unsigned int align)
 		start = bitmap_no + mask + 1;
 	}
 
-	trace_cma_alloc(page ? pfn : -1UL, page, count);
+	trace_cma_alloc(page ? pfn : -1UL, page, count, align);
 
 	pr_debug("%s(): returned %p\n", __func__, page);
 	return page;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
