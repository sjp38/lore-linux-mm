Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 4C8AC6B0092
	for <linux-mm@kvack.org>; Fri, 18 May 2012 02:11:09 -0400 (EDT)
From: Hiroshi DOYU <hdoyu@nvidia.com>
Subject: [RFC 2/2] dma-mapping: Enable IOVA mapping with specific address
Date: Fri, 18 May 2012 09:10:27 +0300
Message-ID: <1337321427-27748-3-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1337321427-27748-1-git-send-email-hdoyu@nvidia.com>
References: <1337321427-27748-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hdoyu@nvidia.com, m.szyprowski@samsung.com, linaro-mm-sig@lists.linaro.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-tegra@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Kyungmin Park <kyungmin.park@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Jon Medhurst <tixy@yxit.co.uk>, Nicolas Pitre <nicolas.pitre@linaro.org>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org

Enable IOVA (un)mapping at a specific IOVA address, independent of
allocating/freeing IOVA area, introducing the following
dma_(un)map_page_*at*() functions:

	dma_map_page_at()
	dma_unmap_page_at()

The above create a mapping between pre-allocated iova and a page, and
remov just a mapping, leaving iova itself allocated. At mapping, it
also checks if IOVA is already reserved or not.

There are the version with the prefix "arm_iommu_", and they are
exactly same as the above.

Signed-off-by: Hiroshi DOYU <hdoyu@nvidia.com>
---
 arch/arm/include/asm/dma-iommu.h   |   29 +++++++-
 arch/arm/include/asm/dma-mapping.h |    1 +
 arch/arm/mm/dma-mapping.c          |  158 +++++++++++++++++++++++++++---------
 3 files changed, 150 insertions(+), 38 deletions(-)

diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
index 2595928..99eba3d 100644
--- a/arch/arm/include/asm/dma-iommu.h
+++ b/arch/arm/include/asm/dma-iommu.h
@@ -30,9 +30,36 @@ void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping);
 int arm_iommu_attach_device(struct device *dev,
 					struct dma_iommu_mapping *mapping);
 
-dma_addr_t arm_iommu_alloc_iova(struct device *dev, size_t size);
+dma_addr_t arm_iommu_alloc_iova_at(struct device *dev, dma_addr_t addr,
+				size_t size);
+
+static inline dma_addr_t arm_iommu_alloc_iova(struct device *dev, size_t size)
+{
+	return arm_iommu_alloc_iova_at(dev, DMA_ANON_ADDR, size);
+}
 
 void arm_iommu_free_iova(struct device *dev, dma_addr_t addr, size_t size);
 
+dma_addr_t arm_iommu_map_page_at(struct device *dev, struct page *page,
+			 dma_addr_t addr, unsigned long offset, size_t size,
+			 enum dma_data_direction dir, struct dma_attrs *attrs);
+
+static inline dma_addr_t dma_map_page_at(struct device *d, struct page *p,
+					 dma_addr_t a, size_t o, size_t s,
+					 enum dma_data_direction r)
+{
+	return arm_iommu_map_page_at(d, p, a, o, s, r, 0);
+}
+
+void arm_iommu_unmap_page_at(struct device *dev, dma_addr_t handle,
+			     size_t size, enum dma_data_direction dir,
+			     struct dma_attrs *attrs);
+
+static inline void dma_unmap_page_at(struct device *d, dma_addr_t a, size_t s,
+				     enum dma_data_direction r)
+{
+	return arm_iommu_unmap_page_at(d, a, s, r, 0);
+}
+
 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index bbef15d..b73eb73 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -12,6 +12,7 @@
 #include <asm/memory.h>
 
 #define DMA_ERROR_CODE	(~0)
+#define DMA_ANON_ADDR	(~0)
 extern struct dma_map_ops arm_dma_ops;
 
 static inline struct dma_map_ops *get_dma_ops(struct device *dev)
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index bca1715..b98e668 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1013,48 +1013,65 @@ fs_initcall(dma_debug_do_init);
 
 /* IOMMU */
 
-static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
-				      size_t size)
+static dma_addr_t __alloc_iova_at(struct dma_iommu_mapping *mapping,
+				     dma_addr_t iova, size_t size)
 {
 	unsigned int order = get_order(size);
 	unsigned int align = 0;
-	unsigned int count, start;
+	unsigned int count, start, orig = 0;
 	unsigned long flags;
+	bool anon = (iova == DMA_ANON_ADDR) ? true : false;
 
 	count = ((PAGE_ALIGN(size) >> PAGE_SHIFT) +
 		 (1 << mapping->order) - 1) >> mapping->order;
 
-	if (order > mapping->order)
+	if (anon && (order > mapping->order))
 		align = (1 << (order - mapping->order)) - 1;
 
 	spin_lock_irqsave(&mapping->lock, flags);
-	start = bitmap_find_next_zero_area(mapping->bitmap, mapping->bits, 0,
-					   count, align);
-	if (start > mapping->bits) {
-		spin_unlock_irqrestore(&mapping->lock, flags);
-		return DMA_ERROR_CODE;
-	}
+	if (!anon)
+		orig = (iova - mapping->base) >> (mapping->order + PAGE_SHIFT);
+
+	start = bitmap_find_next_zero_area(mapping->bitmap, mapping->bits,
+					   orig, count, align);
+	if (start > mapping->bits)
+		goto not_found;
+
+	if (!anon && (orig != start))
+		goto not_found;
 
 	bitmap_set(mapping->bitmap, start, count);
 	spin_unlock_irqrestore(&mapping->lock, flags);
 
 	return mapping->base + (start << (mapping->order + PAGE_SHIFT));
+
+not_found:
+	spin_unlock_irqrestore(&mapping->lock, flags);
+	return DMA_ERROR_CODE;
+}
+
+static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
+				      size_t size)
+{
+	return __alloc_iova_at(mapping, DMA_ANON_ADDR, size);
 }
 
 /**
- * arm_iommu_alloc_iova
+ * arm_iommu_alloc_iova_at
  * @dev: valid struct device pointer
+ * @iova: iova address being requested. Set DMA_ANON_ADDR for arbitral
  * @size: size of buffer to allocate
  *
  * Allocate IOVA address range
  */
-dma_addr_t arm_iommu_alloc_iova(struct device *dev, size_t size)
+dma_addr_t arm_iommu_alloc_iova_at(struct device *dev, dma_addr_t iova,
+				size_t size)
 {
 	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
 
-	return __alloc_iova(mapping, size);
+	return __alloc_iova_at(mapping, iova, size);
 }
-EXPORT_SYMBOL_GPL(arm_iommu_alloc_iova);
+EXPORT_SYMBOL_GPL(arm_iommu_alloc_iova_at);
 
 static inline void __free_iova(struct dma_iommu_mapping *mapping,
 			       dma_addr_t addr, size_t size)
@@ -1507,6 +1524,41 @@ void arm_iommu_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 			__dma_page_cpu_to_dev(sg_page(s), s->offset, s->length, dir);
 }
 
+static dma_addr_t __arm_iommu_map_page_at(struct device *dev, struct page *page,
+			  dma_addr_t req, unsigned long offset, size_t size,
+			  enum dma_data_direction dir, struct dma_attrs *attrs)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+	dma_addr_t dma_addr;
+	int ret, len = PAGE_ALIGN(size + offset);
+
+	if (!arch_is_coherent())
+		__dma_page_cpu_to_dev(page, offset, size, dir);
+
+	dma_addr = __alloc_iova_at(mapping, req, len);
+	if (dma_addr == DMA_ERROR_CODE) {
+		if (req == DMA_ANON_ADDR)
+			return DMA_ERROR_CODE;
+		/*
+		 * Verified that iova(req) is reserved in advance if
+		 * @req is specified.
+		 */
+		dma_addr = req;
+	}
+
+	if (req != DMA_ANON_ADDR)
+		BUG_ON(dma_addr != req);
+
+	ret = iommu_map(mapping->domain, dma_addr, page_to_phys(page), len, 0);
+	if (ret < 0)
+		goto fail;
+
+	return dma_addr + offset;
+fail:
+	if (req == DMA_ANON_ADDR)
+		__free_iova(mapping, dma_addr, len);
+	return DMA_ERROR_CODE;
+}
 
 /**
  * arm_iommu_map_page
@@ -1522,25 +1574,47 @@ static dma_addr_t arm_iommu_map_page(struct device *dev, struct page *page,
 	     unsigned long offset, size_t size, enum dma_data_direction dir,
 	     struct dma_attrs *attrs)
 {
-	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
-	dma_addr_t dma_addr;
-	int ret, len = PAGE_ALIGN(size + offset);
+	return __arm_iommu_map_page_at(dev, page, DMA_ANON_ADDR,
+				       offset, size, dir, attrs);
+}
 
-	if (!arch_is_coherent())
-		__dma_page_cpu_to_dev(page, offset, size, dir);
+/**
+ * arm_iommu_map_page_at
+ * @dev: valid struct device pointer
+ * @page: page that buffer resides in
+ * @req: iova address being requested. Set DMA_ANON_ADDR for arbitral
+ * @offset: offset into page for start of buffer
+ * @size: size of buffer to map
+ * @dir: DMA transfer direction
+ *
+ * The version with a specified iova address of arm_iommu_map_page().
+ */
+dma_addr_t arm_iommu_map_page_at(struct device *dev, struct page *page,
+		 dma_addr_t req, unsigned long offset, size_t size,
+		 enum dma_data_direction dir, struct dma_attrs *attrs)
+{
+	return __arm_iommu_map_page_at(dev, page, req, offset, size, dir,
+				       attrs);
+}
+EXPORT_SYMBOL_GPL(arm_iommu_map_page_at);
 
-	dma_addr = __alloc_iova(mapping, len);
-	if (dma_addr == DMA_ERROR_CODE)
-		return dma_addr;
+static inline int __arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,
+		size_t size, enum dma_data_direction dir,
+		struct dma_attrs *attrs)
+{
+	dma_addr_t iova = handle & PAGE_MASK;
+	struct page *page = phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
+	int offset = handle & ~PAGE_MASK;
+	int len = PAGE_ALIGN(size + offset);
 
-	ret = iommu_map(mapping->domain, dma_addr, page_to_phys(page), len, 0);
-	if (ret < 0)
-		goto fail;
+	if (!iova)
+		return -EINVAL;
 
-	return dma_addr + offset;
-fail:
-	__free_iova(mapping, dma_addr, len);
-	return DMA_ERROR_CODE;
+	if (!arch_is_coherent())
+		__dma_page_dev_to_cpu(page, offset, size, dir);
+
+	iommu_unmap(mapping->domain, iova, len);
+	return 0;
 }
 
 /**
@@ -1558,20 +1632,30 @@ static void arm_iommu_unmap_page(struct device *dev, dma_addr_t handle,
 {
 	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
 	dma_addr_t iova = handle & PAGE_MASK;
-	struct page *page = phys_to_page(iommu_iova_to_phys(mapping->domain, iova));
-	int offset = handle & ~PAGE_MASK;
 	int len = PAGE_ALIGN(size + offset);
 
-	if (!iova)
+	if (__arm_iommu_unmap_page(dev, handle, size, dir, attrs))
 		return;
-
-	if (!arch_is_coherent())
-		__dma_page_dev_to_cpu(page, offset, size, dir);
-
-	iommu_unmap(mapping->domain, iova, len);
 	__free_iova(mapping, iova, len);
 }
 
+/**
+ * arm_iommu_unmap_page_at
+ * @dev: valid struct device pointer
+ * @handle: DMA address of buffer
+ * @size: size of buffer (same as passed to dma_map_page)
+ * @dir: DMA transfer direction (same as passed to dma_map_page)
+ *
+ * The version without freeing iova of arm_iommu_unmap_page().
+ */
+void arm_iommu_unmap_page_at(struct device *dev, dma_addr_t handle,
+		size_t size, enum dma_data_direction dir,
+		struct dma_attrs *attrs)
+{
+	__arm_iommu_unmap_page(dev, handle, size, dir, attrs);
+}
+EXPORT_SYMBOL_GPL(arm_iommu_unmap_page_at);
+
 static void arm_iommu_sync_single_for_cpu(struct device *dev,
 		dma_addr_t handle, size_t size, enum dma_data_direction dir)
 {
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
