Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0EBF16B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 09:01:12 -0500 (EST)
Received: by mail-ie0-f180.google.com with SMTP id tp5so13916190ieb.39
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 06:01:10 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id k10si5062870igx.4.2013.11.28.05.53.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 05:53:15 -0800 (PST)
From: Vandana Salve <vsalve@nvidia.com>
Subject: [PATCH] common: DMA-mapping: add DMA_ATTR_ALLOC_EXACT_SIZE attribute
Date: Thu, 28 Nov 2013 19:23:16 +0530
Message-ID: <1385646796-9396-1-git-send-email-vsalve@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, hdoyu@nvidia.com, Vandana Salve <vsalve@nvidia.com>

This patch adds DMA_ATTR_ALLOC_EXACT_SIZE attribute to the DMA-mapping subsystem

By default dma coherent alloc/free functions allocates/release memory in
order of 2^pages. By specifying this attribute, allocation/release can
be done for exact size of memory there by reducing internal memory
fragmentation when allocation is in large chunks of MBs

Added attr version of dma_alloc/release_from_coherent()

Signed-off-by: Vandana Salve <vsalve@nvidia.com>
---
 arch/arm/mm/dma-mapping.c          |  6 ++---
 drivers/base/dma-coherent.c        | 51 ++++++++++++++++++++++++++++----------
 include/asm-generic/dma-coherent.h | 15 ++++++++---
 include/linux/dma-attrs.h          |  1 +
 4 files changed, 54 insertions(+), 19 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 79f8b39..a39c1c1 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -710,7 +710,7 @@ void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
 	pgprot_t prot = __get_dma_pgprot(attrs, PAGE_KERNEL);
 	void *memory;
 
-	if (dma_alloc_from_coherent(dev, size, handle, &memory))
+	if (dma_alloc_from_coherent_attr(dev, size, handle, &memory, attrs))
 		return memory;
 
 	return __dma_alloc(dev, size, handle, gfp, prot, false,
@@ -723,7 +723,7 @@ static void *arm_coherent_dma_alloc(struct device *dev, size_t size,
 	pgprot_t prot = __get_dma_pgprot(attrs, PAGE_KERNEL);
 	void *memory;
 
-	if (dma_alloc_from_coherent(dev, size, handle, &memory))
+	if (dma_alloc_from_coherent_attr(dev, size, handle, &memory, attrs))
 		return memory;
 
 	return __dma_alloc(dev, size, handle, gfp, prot, true,
@@ -769,7 +769,7 @@ static void __arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
 {
 	struct page *page = pfn_to_page(dma_to_pfn(dev, handle));
 
-	if (dma_release_from_coherent(dev, get_order(size), cpu_addr))
+	if (dma_release_from_coherent_attr(dev, size, cpu_addr, attrs))
 		return;
 
 	size = PAGE_ALIGN(size);
diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
index bc256b6..51e8ff6 100644
--- a/drivers/base/dma-coherent.c
+++ b/drivers/base/dma-coherent.c
@@ -96,26 +96,31 @@ void *dma_mark_declared_memory_occupied(struct device *dev,
 EXPORT_SYMBOL(dma_mark_declared_memory_occupied);
 
 /**
- * dma_alloc_from_coherent() - try to allocate memory from the per-device coherent area
+ * dma_alloc_from_coherent_attr() - try to allocate memory from the per-device
+ * coherent area
  *
  * @dev:	device from which we allocate memory
  * @size:	size of requested memory area
  * @dma_handle:	This will be filled with the correct dma handle
  * @ret:	This pointer will be filled with the virtual address
  *		to allocated area.
+ * @attrs:	DMA Attribute
  *
  * This function should be only called from per-arch dma_alloc_coherent()
  * to support allocation from per-device coherent memory pools.
  *
- * Returns 0 if dma_alloc_coherent should continue with allocating from
+ * Returns 0 if dma_alloc_coherent_attr should continue with allocating from
  * generic memory areas, or !0 if dma_alloc_coherent should return @ret.
  */
-int dma_alloc_from_coherent(struct device *dev, ssize_t size,
-				       dma_addr_t *dma_handle, void **ret)
+int dma_alloc_from_coherent_attr(struct device *dev, ssize_t size,
+				       dma_addr_t *dma_handle, void **ret,
+				       struct dma_attrs *attrs)
 {
 	struct dma_coherent_mem *mem;
 	int order = get_order(size);
 	int pageno;
+	unsigned int count;
+	unsigned long align;
 
 	if (!dev)
 		return 0;
@@ -127,11 +132,22 @@ int dma_alloc_from_coherent(struct device *dev, ssize_t size,
 
 	if (unlikely(size > (mem->size << PAGE_SHIFT)))
 		goto err;
+	if (dma_get_attr(DMA_ATTR_ALLOC_EXACT_SIZE, attrs)) {
+		align = 0;
+		count = PAGE_ALIGN(size) >> PAGE_SHIFT;
+	} else {
+		align = (1 << order) - 1;
+		count = 1 << order;
+	}
+
+	pageno = bitmap_find_next_zero_area(mem->bitmap, mem->size,
+			0, count, align);
 
-	pageno = bitmap_find_free_region(mem->bitmap, mem->size, order);
-	if (unlikely(pageno < 0))
+	if (pageno >= mem->size)
 		goto err;
 
+	bitmap_set(mem->bitmap, pageno, count);
+
 	/*
 	 * Memory was found in the per-device area.
 	 */
@@ -149,35 +165,44 @@ err:
 	 */
 	return mem->flags & DMA_MEMORY_EXCLUSIVE;
 }
-EXPORT_SYMBOL(dma_alloc_from_coherent);
+EXPORT_SYMBOL(dma_alloc_from_coherent_attr);
 
 /**
- * dma_release_from_coherent() - try to free the memory allocated from per-device coherent memory pool
+ * dma_release_from_coherent_attr() - try to free the memory allocated from
+ * per-device coherent memory pool
  * @dev:	device from which the memory was allocated
- * @order:	the order of pages allocated
+ * @size:	size of the memory area to free
  * @vaddr:	virtual address of allocated pages
+ * @attrs:	DMA Attribute
  *
  * This checks whether the memory was allocated from the per-device
  * coherent memory pool and if so, releases that memory.
  *
  * Returns 1 if we correctly released the memory, or 0 if
- * dma_release_coherent() should proceed with releasing memory from
+ * dma_release_coherent_attr() should proceed with releasing memory from
  * generic pools.
  */
-int dma_release_from_coherent(struct device *dev, int order, void *vaddr)
+int dma_release_from_coherent_attr(struct device *dev, size_t size, void *vaddr,
+				struct dma_attrs *attrs)
 {
 	struct dma_coherent_mem *mem = dev ? dev->dma_mem : NULL;
+	unsigned int count;
 
 	if (mem && vaddr >= mem->virt_base && vaddr <
 		   (mem->virt_base + (mem->size << PAGE_SHIFT))) {
 		int page = (vaddr - mem->virt_base) >> PAGE_SHIFT;
 
-		bitmap_release_region(mem->bitmap, page, order);
+		if (dma_get_attr(DMA_ATTR_ALLOC_EXACT_SIZE, attrs))
+			count = PAGE_ALIGN(size) >> PAGE_SHIFT;
+		else
+			count = 1 << size;
+
+		bitmap_clear(mem->bitmap, page, count);
 		return 1;
 	}
 	return 0;
 }
-EXPORT_SYMBOL(dma_release_from_coherent);
+EXPORT_SYMBOL(dma_release_from_coherent_attr);
 
 /**
  * dma_mmap_from_coherent() - try to mmap the memory allocated from
diff --git a/include/asm-generic/dma-coherent.h b/include/asm-generic/dma-coherent.h
index 2be8a2d..55e49bd 100644
--- a/include/asm-generic/dma-coherent.h
+++ b/include/asm-generic/dma-coherent.h
@@ -6,9 +6,16 @@
  * These three functions are only for dma allocator.
  * Don't use them in device drivers.
  */
-int dma_alloc_from_coherent(struct device *dev, ssize_t size,
-				       dma_addr_t *dma_handle, void **ret);
-int dma_release_from_coherent(struct device *dev, int order, void *vaddr);
+int dma_alloc_from_coherent_attr(struct device *dev, ssize_t size,
+				       dma_addr_t *dma_handle, void **ret,
+				       struct dma_attrs *attrs);
+int dma_release_from_coherent_attr(struct device *dev, size_t size, void *vaddr,
+				       struct dma_attrs *attrs);
+#define dma_alloc_from_coherent(d, s, h, r) \
+	dma_alloc_from_coherent_attr(d, s, h, r, NULL)
+
+#define dma_release_from_coherent(d, s, v) \
+	dma_release_from_coherent_attr(d, s, v, NULL)
 
 int dma_mmap_from_coherent(struct device *dev, struct vm_area_struct *vma,
 			    void *cpu_addr, size_t size, int *ret);
@@ -27,6 +34,8 @@ extern void *
 dma_mark_declared_memory_occupied(struct device *dev,
 				  dma_addr_t device_addr, size_t size);
 #else
+#define dma_alloc_from_coherent_attr(dev, size, handle, ret, attr) (0)
+#define dma_release_from_coherent_attr(dev, size, vaddr, attr) (0)
 #define dma_alloc_from_coherent(dev, size, handle, ret) (0)
 #define dma_release_from_coherent(dev, order, vaddr) (0)
 #define dma_mmap_from_coherent(dev, vma, vaddr, order, ret) (0)
diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
index c8e1831..d23f28f 100644
--- a/include/linux/dma-attrs.h
+++ b/include/linux/dma-attrs.h
@@ -18,6 +18,7 @@ enum dma_attr {
 	DMA_ATTR_NO_KERNEL_MAPPING,
 	DMA_ATTR_SKIP_CPU_SYNC,
 	DMA_ATTR_FORCE_CONTIGUOUS,
+	DMA_ATTR_ALLOC_EXACT_SIZE,
 	DMA_ATTR_MAX,
 };
 
-- 
1.8.1.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
