Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3776B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 00:58:23 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x66so18749835pfe.21
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 21:58:23 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id e20si17424490pgn.605.2017.11.23.21.58.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 21:58:21 -0800 (PST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [RFC v2] dma-coherent: introduce no-align to avoid allocation
 failure and save memory
Date: Fri, 24 Nov 2017 14:58:33 +0900
Message-id: <20171124055833.10998-1-jaewon31.kim@samsung.com>
References: <CGME20171124055811epcas1p364177b515eb072d25cd9f49573daef72@epcas1p3.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com, hch@lst.de, robin.murphy@arm.com, gregkh@linuxfoundation.org
Cc: iommu@lists.linux-foundation.org, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com, Jaewon Kim <jaewon31.kim@samsung.com>

dma-coherent uses bitmap APIs which internally consider align based on the
requested size. If most of allocations are small size like KBs, using
alignment scheme seems to be good for anti-fragmentation. But if large
allocation are commonly used, then an allocation could be failed because
of the alignment. To avoid the allocation failure, we had to increase total
size.

This is a example, total size is 30MB, only few memory at front is being
used, and 9MB is being requsted. Then 9MB will be aligned to 16MB. The
first try on offset 0MB will be failed because others already are using
them. The second try on offset 16MB will be failed because of ouf of bound.

So if the alignment is not necessary on a specific dma-coherent memory
region, we can set no-align property. Then dma-coherent will ignore the
alignment only for the memory region.

patch changelog:

v2: use no-align property rather than forcely using no-align

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 .../bindings/reserved-memory/reserved-memory.txt   |  6 +++
 arch/arm/mm/dma-mapping-nommu.c                    |  3 +-
 drivers/base/dma-coherent.c                        | 49 ++++++++++++++++------
 include/linux/dma-mapping.h                        | 12 +++---
 4 files changed, 50 insertions(+), 20 deletions(-)

diff --git a/Documentation/devicetree/bindings/reserved-memory/reserved-memory.txt b/Documentation/devicetree/bindings/reserved-memory/reserved-memory.txt
index 16291f2a4688..b279e111a7ca 100644
--- a/Documentation/devicetree/bindings/reserved-memory/reserved-memory.txt
+++ b/Documentation/devicetree/bindings/reserved-memory/reserved-memory.txt
@@ -63,6 +63,12 @@ reusable (optional) - empty property
       able to reclaim it back. Typically that means that the operating
       system can use that region to store volatile or cached data that
       can be otherwise regenerated or migrated elsewhere.
+no-align (optional) - empty property
+    - Depending on a device or its usage pattern, tring to do aligning is not
+      useful. Because of aligning, allocation can be failed and that leads to
+      increasing total memory size to avoid the allocation failure. This
+      property indicates allocator will not try to do aligning on size nor
+      offset.
 
 Linux implementation note:
 - If a "linux,cma-default" property is present, then Linux will use the
diff --git a/arch/arm/mm/dma-mapping-nommu.c b/arch/arm/mm/dma-mapping-nommu.c
index 6db5fc26d154..6512dae5d19b 100644
--- a/arch/arm/mm/dma-mapping-nommu.c
+++ b/arch/arm/mm/dma-mapping-nommu.c
@@ -75,8 +75,7 @@ static void arm_nommu_dma_free(struct device *dev, size_t size,
 	if (attrs & DMA_ATTR_NON_CONSISTENT) {
 		ops->free(dev, size, cpu_addr, dma_addr, attrs);
 	} else {
-		int ret = dma_release_from_global_coherent(get_order(size),
-							   cpu_addr);
+		int ret = dma_release_from_global_coherent(size, cpu_addr);
 
 		WARN_ON_ONCE(ret == 0);
 	}
diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
index 1e6396bb807b..95d96bd764d9 100644
--- a/drivers/base/dma-coherent.c
+++ b/drivers/base/dma-coherent.c
@@ -17,6 +17,7 @@ struct dma_coherent_mem {
 	int		flags;
 	unsigned long	*bitmap;
 	spinlock_t	spinlock;
+	bool		no_align;
 	bool		use_dev_dma_pfn_offset;
 };
 
@@ -163,19 +164,35 @@ EXPORT_SYMBOL(dma_mark_declared_memory_occupied);
 static void *__dma_alloc_from_coherent(struct dma_coherent_mem *mem,
 		ssize_t size, dma_addr_t *dma_handle)
 {
-	int order = get_order(size);
 	unsigned long flags;
 	int pageno;
 	void *ret;
 
 	spin_lock_irqsave(&mem->spinlock, flags);
 
-	if (unlikely(size > (mem->size << PAGE_SHIFT)))
+	if (unlikely(size > (mem->size << PAGE_SHIFT))) {
+		WARN_ONCE(1, "%s too big size, req-size: %zu total-size: %d\n",
+			  __func__, size, (mem->size << PAGE_SHIFT));
 		goto err;
+	}
 
-	pageno = bitmap_find_free_region(mem->bitmap, mem->size, order);
-	if (unlikely(pageno < 0))
-		goto err;
+	if (mem->no_align) {
+		int nr_page = PAGE_ALIGN(size) >> PAGE_SHIFT;
+
+		pageno = bitmap_find_next_zero_area(mem->bitmap, mem->size, 0,
+						    nr_page, 0);
+		if (unlikely(pageno >= mem->size)) {
+			pr_err("%s: alloc failed, req-size: %u pages\n", __func__, nr_page);
+			goto err;
+		}
+		bitmap_set(mem->bitmap, pageno, nr_page);
+	} else {
+		int order = get_order(size);
+
+		pageno = bitmap_find_free_region(mem->bitmap, mem->size, order);
+		if (unlikely(pageno < 0))
+			goto err;
+	}
 
 	/*
 	 * Memory was found in the coherent area.
@@ -235,7 +252,7 @@ void *dma_alloc_from_global_coherent(ssize_t size, dma_addr_t *dma_handle)
 }
 
 static int __dma_release_from_coherent(struct dma_coherent_mem *mem,
-				       int order, void *vaddr)
+				       size_t size, void *vaddr)
 {
 	if (mem && vaddr >= mem->virt_base && vaddr <
 		   (mem->virt_base + (mem->size << PAGE_SHIFT))) {
@@ -243,7 +260,12 @@ static int __dma_release_from_coherent(struct dma_coherent_mem *mem,
 		unsigned long flags;
 
 		spin_lock_irqsave(&mem->spinlock, flags);
-		bitmap_release_region(mem->bitmap, page, order);
+		if (mem->no_align)
+			bitmap_clear(mem->bitmap, page,
+				     PAGE_ALIGN(size) >> PAGE_SHIFT);
+		else
+			bitmap_release_region(mem->bitmap, page,
+					      get_order(size));
 		spin_unlock_irqrestore(&mem->spinlock, flags);
 		return 1;
 	}
@@ -253,7 +275,7 @@ static int __dma_release_from_coherent(struct dma_coherent_mem *mem,
 /**
  * dma_release_from_dev_coherent() - free memory to device coherent memory pool
  * @dev:	device from which the memory was allocated
- * @order:	the order of pages allocated
+ * @size:	the size of allocated
  * @vaddr:	virtual address of allocated pages
  *
  * This checks whether the memory was allocated from the per-device
@@ -262,20 +284,20 @@ static int __dma_release_from_coherent(struct dma_coherent_mem *mem,
  * Returns 1 if we correctly released the memory, or 0 if the caller should
  * proceed with releasing memory from generic pools.
  */
-int dma_release_from_dev_coherent(struct device *dev, int order, void *vaddr)
+int dma_release_from_dev_coherent(struct device *dev, ssize_t size, void *vaddr)
 {
 	struct dma_coherent_mem *mem = dev_get_coherent_memory(dev);
 
-	return __dma_release_from_coherent(mem, order, vaddr);
+	return __dma_release_from_coherent(mem, size, vaddr);
 }
 EXPORT_SYMBOL(dma_release_from_dev_coherent);
 
-int dma_release_from_global_coherent(int order, void *vaddr)
+int dma_release_from_global_coherent(ssize_t size, void *vaddr)
 {
 	if (!dma_coherent_default_memory)
 		return 0;
 
-	return __dma_release_from_coherent(dma_coherent_default_memory, order,
+	return __dma_release_from_coherent(dma_coherent_default_memory, size,
 			vaddr);
 }
 
@@ -347,6 +369,7 @@ static struct reserved_mem *dma_reserved_default_memory __initdata;
 static int rmem_dma_device_init(struct reserved_mem *rmem, struct device *dev)
 {
 	struct dma_coherent_mem *mem = rmem->priv;
+	unsigned long node = rmem->fdt_node;
 	int ret;
 
 	if (!mem) {
@@ -361,6 +384,8 @@ static int rmem_dma_device_init(struct reserved_mem *rmem, struct device *dev)
 	}
 	mem->use_dev_dma_pfn_offset = true;
 	rmem->priv = mem;
+	if (of_get_flat_dt_prop(node, "no-align", NULL))
+		mem->no_align = true;
 	dma_assign_coherent_memory(dev, mem);
 	return 0;
 }
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index e8f8e8fb244d..883e4ccb7c59 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -162,20 +162,20 @@ static inline int is_device_dma_capable(struct device *dev)
  */
 int dma_alloc_from_dev_coherent(struct device *dev, ssize_t size,
 				       dma_addr_t *dma_handle, void **ret);
-int dma_release_from_dev_coherent(struct device *dev, int order, void *vaddr);
+int dma_release_from_dev_coherent(struct device *dev, ssize_t size, void *vaddr);
 
 int dma_mmap_from_dev_coherent(struct device *dev, struct vm_area_struct *vma,
 			    void *cpu_addr, size_t size, int *ret);
 
 void *dma_alloc_from_global_coherent(ssize_t size, dma_addr_t *dma_handle);
-int dma_release_from_global_coherent(int order, void *vaddr);
+int dma_release_from_global_coherent(ssize_t size, void *vaddr);
 int dma_mmap_from_global_coherent(struct vm_area_struct *vma, void *cpu_addr,
 				  size_t size, int *ret);
 
 #else
 #define dma_alloc_from_dev_coherent(dev, size, handle, ret) (0)
-#define dma_release_from_dev_coherent(dev, order, vaddr) (0)
-#define dma_mmap_from_dev_coherent(dev, vma, vaddr, order, ret) (0)
+#define dma_release_from_dev_coherent(dev, size, vaddr) (0)
+#define dma_mmap_from_dev_coherent(dev, vma, cpu_addr, size, ret) (0)
 
 static inline void *dma_alloc_from_global_coherent(ssize_t size,
 						   dma_addr_t *dma_handle)
@@ -183,7 +183,7 @@ static inline void *dma_alloc_from_global_coherent(ssize_t size,
 	return NULL;
 }
 
-static inline int dma_release_from_global_coherent(int order, void *vaddr)
+static inline int dma_release_from_global_coherent(size_t size, void *vaddr)
 {
 	return 0;
 }
@@ -536,7 +536,7 @@ static inline void dma_free_attrs(struct device *dev, size_t size,
 	BUG_ON(!ops);
 	WARN_ON(irqs_disabled());
 
-	if (dma_release_from_dev_coherent(dev, get_order(size), cpu_addr))
+	if (dma_release_from_dev_coherent(dev, size, cpu_addr))
 		return;
 
 	if (!ops->free || !cpu_addr)
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
