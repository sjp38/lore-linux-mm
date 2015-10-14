Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C61746B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 16:24:02 -0400 (EDT)
Received: by padcn9 with SMTP id cn9so32519623pad.2
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 13:24:02 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id gh4si15712859pbc.211.2015.10.14.13.24.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 13:24:02 -0700 (PDT)
From: Rohit Vaswani <rvaswani@codeaurora.org>
Subject: [PATCH] mm: cma: Fix incorrect type conversion for size during dma allocation
Date: Wed, 14 Oct 2015 13:23:51 -0700
Message-Id: <1444854232-4085-1-git-send-email-rvaswani@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Rohit Vaswani <rvaswani@codeaurora.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This was found during userspace fuzzing test when a large size
dma cma allocation is made by driver(like ion) through userspace.

 show_stack+0x10/0x1c
 dump_stack+0x74/0xc8
 kasan_report_error+0x2b0/0x408
 kasan_report+0x34/0x40
 __asan_storeN+0x15c/0x168
 memset+0x20/0x44
 __dma_alloc_coherent+0x114/0x18c

Signed-off-by: Rohit Vaswani <rvaswani@codeaurora.org>
---
 drivers/base/dma-contiguous.c  | 2 +-
 include/linux/cma.h            | 2 +-
 include/linux/dma-contiguous.h | 4 ++--
 mm/cma.c                       | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 950fff9..a12ff98 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -187,7 +187,7 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
  * global one. Requires architecture specific dev_get_cma_area() helper
  * function.
  */
-struct page *dma_alloc_from_contiguous(struct device *dev, int count,
+struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
 				       unsigned int align)
 {
 	if (align > CONFIG_CMA_ALIGNMENT)
diff --git a/include/linux/cma.h b/include/linux/cma.h
index f7ef093..29f9e77 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -26,6 +26,6 @@ extern int __init cma_declare_contiguous(phys_addr_t base,
 extern int cma_init_reserved_mem(phys_addr_t base, phys_addr_t size,
 					unsigned int order_per_bit,
 					struct cma **res_cma);
-extern struct page *cma_alloc(struct cma *cma, unsigned int count, unsigned int align);
+extern struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align);
 extern bool cma_release(struct cma *cma, const struct page *pages, unsigned int count);
 #endif
diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
index 569bbd0..fec734d 100644
--- a/include/linux/dma-contiguous.h
+++ b/include/linux/dma-contiguous.h
@@ -111,7 +111,7 @@ static inline int dma_declare_contiguous(struct device *dev, phys_addr_t size,
 	return ret;
 }
 
-struct page *dma_alloc_from_contiguous(struct device *dev, int count,
+struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
 				       unsigned int order);
 bool dma_release_from_contiguous(struct device *dev, struct page *pages,
 				 int count);
@@ -144,7 +144,7 @@ int dma_declare_contiguous(struct device *dev, phys_addr_t size,
 }
 
 static inline
-struct page *dma_alloc_from_contiguous(struct device *dev, int count,
+struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
 				       unsigned int order)
 {
 	return NULL;
diff --git a/mm/cma.c b/mm/cma.c
index e7d1db5..4eb56bad 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -361,7 +361,7 @@ err:
  * This function allocates part of contiguous memory on specific
  * contiguous memory area.
  */
-struct page *cma_alloc(struct cma *cma, unsigned int count, unsigned int align)
+struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align)
 {
 	unsigned long mask, offset, pfn, start = 0;
 	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
@@ -371,7 +371,7 @@ struct page *cma_alloc(struct cma *cma, unsigned int count, unsigned int align)
 	if (!cma || !cma->count)
 		return NULL;
 
-	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
+	pr_debug("%s(cma %p, count %zu, align %d)\n", __func__, (void *)cma,
 		 count, align);
 
 	if (!count)
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
