Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6040E6B0069
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 19:42:18 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f5so468511254pgi.1
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 16:42:18 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id p10si696343pge.292.2017.01.31.16.42.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Jan 2017 16:42:17 -0800 (PST)
Received: from epcas1p3.samsung.com (unknown [182.195.41.47])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OKO00LI47AEJK90@mailout4.samsung.com> for linux-mm@kvack.org;
 Wed, 01 Feb 2017 09:42:14 +0900 (KST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH v2] mm: cma: print allocation failure reason and bitmap status
Date: Wed, 01 Feb 2017 09:43:05 +0900
Message-id: <1485909785-3952-1-git-send-email-jaewon31.kim@samsung.com>
References: 
 <CGME20170201004214epcas1p314af5e7b53fd2098fafb65a631f49bd3@epcas1p3.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org
Cc: labbott@redhat.com, mina86@mina86.com, m.szyprowski@samsung.com, gregory.0xf0@gmail.com, laurent.pinchart@ideasonboard.com, akinobu.mita@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com, Jaewon Kim <jaewon31.kim@samsung.com>

There are many reasons of CMA allocation failure such as EBUSY, ENOMEM, EINTR.
But we did not know error reason so far. This patch prints the error value.

Additionally if CONFIG_CMA_DEBUG is enabled, this patch shows bitmap status to
know available pages. Actually CMA internally tries on all available regions
because some regions can be failed because of EBUSY. Bitmap status is useful to
know in detail on both ENONEM and EBUSY;
 ENOMEM: not tried at all because of no available region
         it could be too small total region or could be fragmentation issue
 EBUSY:  tried some region but all failed

This is an ENOMEM example with this patch.
[   12.415458]  [2:   Binder:714_1:  744] cma: cma_alloc: alloc failed, req-size: 256 pages, ret: -12

If CONFIG_CMA_DEBUG is enabled, avabile pages also will be shown as concatenated
size@position format. So 4@572 means that there are 4 available pages at 572
position starting from 0 position.
[   12.415503]  [2:   Binder:714_1:  744] cma: number of available pages: 4@572+7@585+7@601+8@632+38@730+166@1114+127@1921=> 357 free of 2048 total pages

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
Acked-by: Michal Nazarewicz <mina86@mina86.com>
---
 mm/cma.c | 34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/mm/cma.c b/mm/cma.c
index c960459..c393229 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -353,6 +353,32 @@ int __init cma_declare_contiguous(phys_addr_t base,
 	return ret;
 }
 
+#ifdef CONFIG_CMA_DEBUG
+static void cma_debug_show_areas(struct cma *cma)
+{
+	unsigned long next_zero_bit, next_set_bit;
+	unsigned long start = 0;
+	unsigned int nr_zero, nr_total = 0;
+
+	mutex_lock(&cma->lock);
+	pr_info("number of available pages: ");
+	for (;;) {
+		next_zero_bit = find_next_zero_bit(cma->bitmap, cma->count, start);
+		if (next_zero_bit >= cma->count)
+			break;
+		next_set_bit = find_next_bit(cma->bitmap, cma->count, next_zero_bit);
+		nr_zero = next_set_bit - next_zero_bit;
+		pr_cont("%s%u@%lu", nr_total ? "+" : "", nr_zero, next_zero_bit);
+		nr_total += nr_zero;
+		start = next_zero_bit + nr_zero;
+	}
+	pr_cont("=> %u free of %lu total pages\n", nr_total, cma->count);
+	mutex_unlock(&cma->lock);
+}
+#else
+static inline void cma_debug_show_areas(struct cma *cma) { }
+#endif
+
 /**
  * cma_alloc() - allocate pages from contiguous area
  * @cma:   Contiguous memory region for which the allocation is performed.
@@ -369,7 +395,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
 	unsigned long start = 0;
 	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
 	struct page *page = NULL;
-	int ret;
+	int ret = -ENOMEM;
 
 	if (!cma || !cma->count)
 		return NULL;
@@ -426,6 +452,12 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
 
 	trace_cma_alloc(pfn, page, count, align);
 
+	if (ret) {
+		pr_info("%s: alloc failed, req-size: %zu pages, ret: %d\n",
+			__func__, count, ret);
+		cma_debug_show_areas(cma);
+	}
+
 	pr_debug("%s(): returned %p\n", __func__, page);
 	return page;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
