Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id C74046B003A
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 01:36:43 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id rr13so1519127pbb.18
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:36:43 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id bl3si9676958pbc.235.2014.06.15.22.36.41
        for <linux-mm@kvack.org>;
        Sun, 15 Jun 2014 22:36:42 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 -next 2/9] DMA, CMA: separate core CMA management codes from DMA APIs
Date: Mon, 16 Jun 2014 14:40:44 +0900
Message-Id: <1402897251-23639-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1402897251-23639-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

To prepare future generalization work on CMA area management code,
we need to separate core CMA management codes from DMA APIs.
We will extend these core functions to cover requirements of
PPC KVM's CMA area management functionality in following patches.
This separation helps us not to touch DMA APIs while extending
core functions.

v3: move decriptions to exporeted APIs (Minchan)
    pass aligned base and size to dma_contiguous_early_fixup() (Minchan)

Acked-by: Michal Nazarewicz <mina86@mina86.com>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 6467c91..9021762 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -213,26 +213,9 @@ static int __init cma_init_reserved_areas(void)
 }
 core_initcall(cma_init_reserved_areas);
 
-/**
- * dma_contiguous_reserve_area() - reserve custom contiguous area
- * @size: Size of the reserved area (in bytes),
- * @base: Base address of the reserved area optional, use 0 for any
- * @limit: End address of the reserved memory (optional, 0 for any).
- * @res_cma: Pointer to store the created cma region.
- * @fixed: hint about where to place the reserved area
- *
- * This function reserves memory from early allocator. It should be
- * called by arch specific code once the early allocator (memblock or bootmem)
- * has been activated and all other subsystems have already allocated/reserved
- * memory. This function allows to create custom reserved areas for specific
- * devices.
- *
- * If @fixed is true, reserve contiguous area at exactly @base.  If false,
- * reserve in range from @base to @limit.
- */
-int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
-				       phys_addr_t limit, struct cma **res_cma,
-				       bool fixed)
+static int __init __dma_contiguous_reserve_area(phys_addr_t size,
+				phys_addr_t base, phys_addr_t limit,
+				struct cma **res_cma, bool fixed)
 {
 	struct cma *cma = &cma_areas[cma_area_count];
 	phys_addr_t alignment;
@@ -286,15 +269,47 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
 
 	pr_info("CMA: reserved %ld MiB at %08lx\n", (unsigned long)size / SZ_1M,
 		(unsigned long)base);
-
-	/* Architecture specific contiguous memory fixup. */
-	dma_contiguous_early_fixup(base, size);
 	return 0;
+
 err:
 	pr_err("CMA: failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
 	return ret;
 }
 
+/**
+ * dma_contiguous_reserve_area() - reserve custom contiguous area
+ * @size: Size of the reserved area (in bytes),
+ * @base: Base address of the reserved area optional, use 0 for any
+ * @limit: End address of the reserved memory (optional, 0 for any).
+ * @res_cma: Pointer to store the created cma region.
+ * @fixed: hint about where to place the reserved area
+ *
+ * This function reserves memory from early allocator. It should be
+ * called by arch specific code once the early allocator (memblock or bootmem)
+ * has been activated and all other subsystems have already allocated/reserved
+ * memory. This function allows to create custom reserved areas for specific
+ * devices.
+ *
+ * If @fixed is true, reserve contiguous area at exactly @base.  If false,
+ * reserve in range from @base to @limit.
+ */
+int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
+				       phys_addr_t limit, struct cma **res_cma,
+				       bool fixed)
+{
+	int ret;
+
+	ret = __dma_contiguous_reserve_area(size, base, limit, res_cma, fixed);
+	if (ret)
+		return ret;
+
+	/* Architecture specific contiguous memory fixup. */
+	dma_contiguous_early_fixup(PFN_PHYS((*res_cma)->base_pfn),
+				(*res_cma)->count << PAGE_SHIFT);
+
+	return 0;
+}
+
 static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
 {
 	mutex_lock(&cma->lock);
@@ -302,31 +317,16 @@ static void clear_cma_bitmap(struct cma *cma, unsigned long pfn, int count)
 	mutex_unlock(&cma->lock);
 }
 
-/**
- * dma_alloc_from_contiguous() - allocate pages from contiguous area
- * @dev:   Pointer to device for which the allocation is performed.
- * @count: Requested number of pages.
- * @align: Requested alignment of pages (in PAGE_SIZE order).
- *
- * This function allocates memory buffer for specified device. It uses
- * device specific contiguous memory area if available or the default
- * global one. Requires architecture specific dev_get_cma_area() helper
- * function.
- */
-struct page *dma_alloc_from_contiguous(struct device *dev, int count,
+static struct page *__dma_alloc_from_contiguous(struct cma *cma, int count,
 				       unsigned int align)
 {
 	unsigned long mask, pfn, pageno, start = 0;
-	struct cma *cma = dev_get_cma_area(dev);
 	struct page *page = NULL;
 	int ret;
 
 	if (!cma || !cma->count)
 		return NULL;
 
-	if (align > CONFIG_CMA_ALIGNMENT)
-		align = CONFIG_CMA_ALIGNMENT;
-
 	pr_debug("%s(cma %p, count %d, align %d)\n", __func__, (void *)cma,
 		 count, align);
 
@@ -375,19 +375,30 @@ struct page *dma_alloc_from_contiguous(struct device *dev, int count,
 }
 
 /**
- * dma_release_from_contiguous() - release allocated pages
- * @dev:   Pointer to device for which the pages were allocated.
- * @pages: Allocated pages.
- * @count: Number of allocated pages.
+ * dma_alloc_from_contiguous() - allocate pages from contiguous area
+ * @dev:   Pointer to device for which the allocation is performed.
+ * @count: Requested number of pages.
+ * @align: Requested alignment of pages (in PAGE_SIZE order).
  *
- * This function releases memory allocated by dma_alloc_from_contiguous().
- * It returns false when provided pages do not belong to contiguous area and
- * true otherwise.
+ * This function allocates memory buffer for specified device. It uses
+ * device specific contiguous memory area if available or the default
+ * global one. Requires architecture specific dev_get_cma_area() helper
+ * function.
  */
-bool dma_release_from_contiguous(struct device *dev, struct page *pages,
-				 int count)
+struct page *dma_alloc_from_contiguous(struct device *dev, int count,
+				       unsigned int align)
 {
 	struct cma *cma = dev_get_cma_area(dev);
+
+	if (align > CONFIG_CMA_ALIGNMENT)
+		align = CONFIG_CMA_ALIGNMENT;
+
+	return __dma_alloc_from_contiguous(cma, count, align);
+}
+
+static bool __dma_release_from_contiguous(struct cma *cma, struct page *pages,
+				 int count)
+{
 	unsigned long pfn;
 
 	if (!cma || !pages)
@@ -407,3 +418,21 @@ bool dma_release_from_contiguous(struct device *dev, struct page *pages,
 
 	return true;
 }
+
+/**
+ * dma_release_from_contiguous() - release allocated pages
+ * @dev:   Pointer to device for which the pages were allocated.
+ * @pages: Allocated pages.
+ * @count: Number of allocated pages.
+ *
+ * This function releases memory allocated by dma_alloc_from_contiguous().
+ * It returns false when provided pages do not belong to contiguous area and
+ * true otherwise.
+ */
+bool dma_release_from_contiguous(struct device *dev, struct page *pages,
+				 int count)
+{
+	struct cma *cma = dev_get_cma_area(dev);
+
+	return __dma_release_from_contiguous(cma, pages, count);
+}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
