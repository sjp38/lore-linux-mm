Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id A9D8E6B002B
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 12:44:47 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id jm19so1168689bkc.8
        for <linux-mm@kvack.org>; Wed, 19 Dec 2012 09:44:45 -0800 (PST)
From: Michal Nazarewicz <mpn@google.com>
Subject: [PATCH] cma: use unsigned type for count argument
Date: Wed, 19 Dec 2012 18:44:40 +0100
Message-Id: <52fd3c7b677ff01f1cd6d54e38a567b463ec1294.1355938871.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>

From: Michal Nazarewicz <mina86@mina86.com>

Specifying negative size of buffer makes no sense and thus this commit
changes the type of the count argument to unsigned.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
---
 arch/arm/mm/dma-mapping.c      |   12 ++++++------
 drivers/base/dma-contiguous.c  |    6 +++---
 include/linux/dma-contiguous.h |    8 ++++----
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 6b2fb87..77e292e 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1038,9 +1038,9 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
 					  gfp_t gfp, struct dma_attrs *attrs)
 {
 	struct page **pages;
-	int count = size >> PAGE_SHIFT;
-	int array_size = count * sizeof(struct page *);
-	int i = 0;
+	unsigned int count = size >> PAGE_SHIFT;
+	unsigned int array_size = count * sizeof(struct page *);
+	unsigned int i = 0;
 
 	if (array_size <= PAGE_SIZE)
 		pages = kzalloc(array_size, gfp);
@@ -1102,9 +1102,9 @@ error:
 static int __iommu_free_buffer(struct device *dev, struct page **pages,
 			       size_t size, struct dma_attrs *attrs)
 {
-	int count = size >> PAGE_SHIFT;
-	int array_size = count * sizeof(struct page *);
-	int i;
+	unsigned int count = size >> PAGE_SHIFT;
+	unsigned int array_size = count * sizeof(struct page *);
+	unsigned int i;
 
 	if (dma_get_attr(DMA_ATTR_FORCE_CONTIGUOUS, attrs)) {
 		dma_release_from_contiguous(dev, pages[0], count);
diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 0ca5442..e34e3e0 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -303,7 +303,7 @@ err:
  * global one. Requires architecture specific get_dev_cma_area() helper
  * function.
  */
-struct page *dma_alloc_from_contiguous(struct device *dev, int count,
+struct page *dma_alloc_from_contiguous(struct device *dev, unsigned int count,
 				       unsigned int align)
 {
 	unsigned long mask, pfn, pageno, start = 0;
@@ -317,7 +317,7 @@ struct page *dma_alloc_from_contiguous(struct device *dev, int count,
 	if (align > CONFIG_CMA_ALIGNMENT)
 		align = CONFIG_CMA_ALIGNMENT;
 
-	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
+	pr_debug("%s(cma %p, count %u, align %u)\n", __func__, (void *)cma,
 		 count, align);
 
 	if (!count)
@@ -364,7 +364,7 @@ struct page *dma_alloc_from_contiguous(struct device *dev, int count,
  * true otherwise.
  */
 bool dma_release_from_contiguous(struct device *dev, struct page *pages,
-				 int count)
+				 unsigned int count)
 {
 	struct cma *cma = dev_get_cma_area(dev);
 	unsigned long pfn;
diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
index 01b5c84..040501a 100644
--- a/include/linux/dma-contiguous.h
+++ b/include/linux/dma-contiguous.h
@@ -71,10 +71,10 @@ void dma_contiguous_reserve(phys_addr_t addr_limit);
 int dma_declare_contiguous(struct device *dev, phys_addr_t size,
 			   phys_addr_t base, phys_addr_t limit);
 
-struct page *dma_alloc_from_contiguous(struct device *dev, int count,
+struct page *dma_alloc_from_contiguous(struct device *dev, unsigned int count,
 				       unsigned int order);
 bool dma_release_from_contiguous(struct device *dev, struct page *pages,
-				 int count);
+				 unsigned int count);
 
 #else
 
@@ -90,7 +90,7 @@ int dma_declare_contiguous(struct device *dev, phys_addr_t size,
 }
 
 static inline
-struct page *dma_alloc_from_contiguous(struct device *dev, int count,
+struct page *dma_alloc_from_contiguous(struct device *dev, unsigned int count,
 				       unsigned int order)
 {
 	return NULL;
@@ -98,7 +98,7 @@ struct page *dma_alloc_from_contiguous(struct device *dev, int count,
 
 static inline
 bool dma_release_from_contiguous(struct device *dev, struct page *pages,
-				 int count)
+				 unsigned int count)
 {
 	return false;
 }
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
