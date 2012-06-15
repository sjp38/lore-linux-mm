Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 1009F6B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 02:19:16 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (mailout4.samsung.com [203.254.224.34])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M5N00784AW2H490@mailout4.samsung.com> for
 linux-mm@kvack.org; Fri, 15 Jun 2012 15:19:14 +0900 (KST)
Received: from mcdsrvbld02.digital.local ([106.116.37.23])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0M5N00H36AVQDW10@mmp2.samsung.com> for linux-mm@kvack.org;
 Fri, 15 Jun 2012 15:19:13 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] common: dma-mapping: add support for generic dma_mmap_* calls
Date: Fri, 15 Jun 2012 08:18:55 +0200
Message-id: <1339741135-7841-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, David Gibson <david@gibson.dropbear.id.au>, Subash Patel <subash.ramaswamy@linaro.org>, Sumit Semwal <sumit.semwal@linaro.org>

Commit 9adc5374 ('common: dma-mapping: introduce mmap method') added a
generic method for implementing mmap user call to dma_map_ops structure.

This patch converts ARM and PowerPC architectures (the only providers of
dma_mmap_coherent/dma_mmap_writecombine calls) to use this generic
dma_map_ops based call and adds a generic cross architecture
definition for dma_mmap_attrs, dma_mmap_coherent, dma_mmap_writecombine
functions.

The generic mmap virt_to_page-based fallback implementation is provided for
architectures which don't provide their own implementation for mmap method.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Reviewed-by: Kyungmin Park <kyungmin.park@samsung.com>
---
Hello,

This patch is a continuation of my works on dma-mapping cleanup and
unification. Previous works (commit 58bca4a8fa ('Merge branch
'for-linus' of git://git.linaro.org/people/mszyprowski/linux-dma-mapping')
has been merged to v3.4-rc2. Now I've focuses on providing implementation 
for all architectures so the drivers and some cross-architecture common 
helpers (like for example videobuf2) can start using this new api.

I'm not 100% sure if the PowerPC changes are correct. The cases of
dma_iommu_ops and vio_dma_mapping_ops are a bit suspicious for me, but I
have no way to test and check if my changes works for that hardware.

Best regards
Marek Szyprowski
Samsung Poland R&D Center

---
 arch/arm/include/asm/dma-mapping.h       |   19 ---------------
 arch/powerpc/include/asm/dma-mapping.h   |    8 +++---
 arch/powerpc/kernel/dma-iommu.c          |    1 +
 arch/powerpc/kernel/dma-swiotlb.c        |    1 +
 arch/powerpc/kernel/dma.c                |   36 +++++++++++++++-------------
 arch/powerpc/kernel/vio.c                |    1 +
 drivers/base/dma-mapping.c               |   31 +++++++++++++++++++++++++
 include/asm-generic/dma-coherent.h       |    1 +
 include/asm-generic/dma-mapping-common.h |   37 ++++++++++++++++++++++++++++++
 9 files changed, 95 insertions(+), 40 deletions(-)

diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index bbef15d..8645088 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -186,17 +186,6 @@ extern int arm_dma_mmap(struct device *dev, struct vm_area_struct *vma,
 			void *cpu_addr, dma_addr_t dma_addr, size_t size,
 			struct dma_attrs *attrs);
 
-#define dma_mmap_coherent(d, v, c, h, s) dma_mmap_attrs(d, v, c, h, s, NULL)
-
-static inline int dma_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
-				  void *cpu_addr, dma_addr_t dma_addr,
-				  size_t size, struct dma_attrs *attrs)
-{
-	struct dma_map_ops *ops = get_dma_ops(dev);
-	BUG_ON(!ops);
-	return ops->mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
-}
-
 static inline void *dma_alloc_writecombine(struct device *dev, size_t size,
 				       dma_addr_t *dma_handle, gfp_t flag)
 {
@@ -213,14 +202,6 @@ static inline void dma_free_writecombine(struct device *dev, size_t size,
 	return dma_free_attrs(dev, size, cpu_addr, dma_handle, &attrs);
 }
 
-static inline int dma_mmap_writecombine(struct device *dev, struct vm_area_struct *vma,
-		      void *cpu_addr, dma_addr_t dma_addr, size_t size)
-{
-	DEFINE_DMA_ATTRS(attrs);
-	dma_set_attr(DMA_ATTR_WRITE_COMBINE, &attrs);
-	return dma_mmap_attrs(dev, vma, cpu_addr, dma_addr, size, &attrs);
-}
-
 /*
  * This can be called during boot to increase the size of the consistent
  * DMA region above it's default value of 2MB. It must be called before the
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 62678e3..7816087 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -27,7 +27,10 @@ extern void *dma_direct_alloc_coherent(struct device *dev, size_t size,
 extern void dma_direct_free_coherent(struct device *dev, size_t size,
 				     void *vaddr, dma_addr_t dma_handle,
 				     struct dma_attrs *attrs);
-
+extern int dma_direct_mmap_coherent(struct device *dev,
+				    struct vm_area_struct *vma,
+				    void *cpu_addr, dma_addr_t handle,
+				    size_t size, struct dma_attrs *attrs);
 
 #ifdef CONFIG_NOT_COHERENT_CACHE
 /*
@@ -207,11 +210,8 @@ static inline phys_addr_t dma_to_phys(struct device *dev, dma_addr_t daddr)
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
 #define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
 
-extern int dma_mmap_coherent(struct device *, struct vm_area_struct *,
-			     void *, dma_addr_t, size_t);
 #define ARCH_HAS_DMA_MMAP_COHERENT
 
-
 static inline void dma_cache_sync(struct device *dev, void *vaddr, size_t size,
 		enum dma_data_direction direction)
 {
diff --git a/arch/powerpc/kernel/dma-iommu.c b/arch/powerpc/kernel/dma-iommu.c
index bcfdcd2..2d7bb8c 100644
--- a/arch/powerpc/kernel/dma-iommu.c
+++ b/arch/powerpc/kernel/dma-iommu.c
@@ -109,6 +109,7 @@ static u64 dma_iommu_get_required_mask(struct device *dev)
 struct dma_map_ops dma_iommu_ops = {
 	.alloc			= dma_iommu_alloc_coherent,
 	.free			= dma_iommu_free_coherent,
+	.mmap			= dma_direct_mmap_coherent,
 	.map_sg			= dma_iommu_map_sg,
 	.unmap_sg		= dma_iommu_unmap_sg,
 	.dma_supported		= dma_iommu_dma_supported,
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index 4ab88da..4694365 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -49,6 +49,7 @@ static u64 swiotlb_powerpc_get_required(struct device *dev)
 struct dma_map_ops swiotlb_dma_ops = {
 	.alloc = dma_direct_alloc_coherent,
 	.free = dma_direct_free_coherent,
+	.mmap = dma_direct_mmap_coherent,
 	.map_sg = swiotlb_map_sg_attrs,
 	.unmap_sg = swiotlb_unmap_sg_attrs,
 	.dma_supported = swiotlb_dma_supported,
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index b1ec983..062bf20 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -65,6 +65,24 @@ void dma_direct_free_coherent(struct device *dev, size_t size,
 #endif
 }
 
+int dma_direct_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
+			     void *cpu_addr, dma_addr_t handle, size_t size,
+			     struct dma_attrs *attrs)
+{
+	unsigned long pfn;
+
+#ifdef CONFIG_NOT_COHERENT_CACHE
+	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+	pfn = __dma_get_coherent_pfn((unsigned long)cpu_addr);
+#else
+	pfn = page_to_pfn(virt_to_page(cpu_addr));
+#endif
+	return remap_pfn_range(vma, vma->vm_start,
+			       pfn + vma->vm_pgoff,
+			       vma->vm_end - vma->vm_start,
+			       vma->vm_page_prot);
+}
+
 static int dma_direct_map_sg(struct device *dev, struct scatterlist *sgl,
 			     int nents, enum dma_data_direction direction,
 			     struct dma_attrs *attrs)
@@ -154,6 +172,7 @@ static inline void dma_direct_sync_single(struct device *dev,
 struct dma_map_ops dma_direct_ops = {
 	.alloc				= dma_direct_alloc_coherent,
 	.free				= dma_direct_free_coherent,
+	.mmap				= dma_direct_mmap_coherent,
 	.map_sg				= dma_direct_map_sg,
 	.unmap_sg			= dma_direct_unmap_sg,
 	.dma_supported			= dma_direct_dma_supported,
@@ -211,20 +230,3 @@ static int __init dma_init(void)
 }
 fs_initcall(dma_init);
 
-int dma_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
-		      void *cpu_addr, dma_addr_t handle, size_t size)
-{
-	unsigned long pfn;
-
-#ifdef CONFIG_NOT_COHERENT_CACHE
-	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-	pfn = __dma_get_coherent_pfn((unsigned long)cpu_addr);
-#else
-	pfn = page_to_pfn(virt_to_page(cpu_addr));
-#endif
-	return remap_pfn_range(vma, vma->vm_start,
-			       pfn + vma->vm_pgoff,
-			       vma->vm_end - vma->vm_start,
-			       vma->vm_page_prot);
-}
-EXPORT_SYMBOL_GPL(dma_mmap_coherent);
diff --git a/arch/powerpc/kernel/vio.c b/arch/powerpc/kernel/vio.c
index cb87301..dda3d9a 100644
--- a/arch/powerpc/kernel/vio.c
+++ b/arch/powerpc/kernel/vio.c
@@ -613,6 +613,7 @@ static u64 vio_dma_get_required_mask(struct device *dev)
 struct dma_map_ops vio_dma_mapping_ops = {
 	.alloc             = vio_dma_iommu_alloc_coherent,
 	.free              = vio_dma_iommu_free_coherent,
+	.mmap		   = dma_direct_mmap_coherent,
 	.map_sg            = vio_dma_iommu_map_sg,
 	.unmap_sg          = vio_dma_iommu_unmap_sg,
 	.map_page          = vio_dma_iommu_map_page,
diff --git a/drivers/base/dma-mapping.c b/drivers/base/dma-mapping.c
index 6f3676f..db5db02 100644
--- a/drivers/base/dma-mapping.c
+++ b/drivers/base/dma-mapping.c
@@ -10,6 +10,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/export.h>
 #include <linux/gfp.h>
+#include <asm-generic/dma-coherent.h>
 
 /*
  * Managed DMA API
@@ -218,3 +219,33 @@ void dmam_release_declared_memory(struct device *dev)
 EXPORT_SYMBOL(dmam_release_declared_memory);
 
 #endif
+
+/*
+ * Create userspace mapping for the DMA-coherent memory.
+ */
+int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
+		    void *cpu_addr, dma_addr_t dma_addr, size_t size)
+{
+	int ret = -ENXIO;
+#ifdef CONFIG_MMU
+	unsigned long user_count = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+	unsigned long count = PAGE_ALIGN(size) >> PAGE_SHIFT;
+	unsigned long pfn = page_to_pfn(virt_to_page(cpu_addr));
+	unsigned long off = vma->vm_pgoff;
+
+	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+
+	if (dma_mmap_from_coherent(dev, vma, cpu_addr, size, &ret))
+		return ret;
+
+	if (off < count && user_count <= (count - off)) {
+		ret = remap_pfn_range(vma, vma->vm_start,
+				      pfn + off,
+				      user_count << PAGE_SHIFT,
+				      vma->vm_page_prot);
+	}
+#endif	/* CONFIG_MMU */
+
+	return ret;
+}
+EXPORT_SYMBOL(dma_common_mmap);
diff --git a/include/asm-generic/dma-coherent.h b/include/asm-generic/dma-coherent.h
index abfb268..2be8a2d 100644
--- a/include/asm-generic/dma-coherent.h
+++ b/include/asm-generic/dma-coherent.h
@@ -29,6 +29,7 @@ dma_mark_declared_memory_occupied(struct device *dev,
 #else
 #define dma_alloc_from_coherent(dev, size, handle, ret) (0)
 #define dma_release_from_coherent(dev, order, vaddr) (0)
+#define dma_mmap_from_coherent(dev, vma, vaddr, order, ret) (0)
 #endif
 
 #endif
diff --git a/include/asm-generic/dma-mapping-common.h b/include/asm-generic/dma-mapping-common.h
index 2e248d8..9073aeb 100644
--- a/include/asm-generic/dma-mapping-common.h
+++ b/include/asm-generic/dma-mapping-common.h
@@ -176,4 +176,41 @@ dma_sync_sg_for_device(struct device *dev, struct scatterlist *sg,
 #define dma_map_sg(d, s, n, r) dma_map_sg_attrs(d, s, n, r, NULL)
 #define dma_unmap_sg(d, s, n, r) dma_unmap_sg_attrs(d, s, n, r, NULL)
 
+extern int dma_common_mmap(struct device *dev, struct vm_area_struct *vma,
+			   void *cpu_addr, dma_addr_t dma_addr, size_t size);
+
+/**
+ * dma_mmap_attrs - map a coherent DMA allocation into user space
+ * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
+ * @vma: vm_area_struct describing requested user mapping
+ * @cpu_addr: kernel CPU-view address returned from dma_alloc_attrs
+ * @handle: device-view address returned from dma_alloc_attrs
+ * @size: size of memory originally requested in dma_alloc_attrs
+ * @attrs: attributes of mapping properties requested in dma_alloc_attrs
+ *
+ * Map a coherent DMA buffer previously allocated by dma_alloc_attrs
+ * into user space.  The coherent DMA buffer must not be freed by the
+ * driver until the user space mapping has been released.
+ */
+static inline int
+dma_mmap_attrs(struct device *dev, struct vm_area_struct *vma, void *cpu_addr,
+	       dma_addr_t dma_addr, size_t size, struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	BUG_ON(!ops);
+	if (ops->mmap)
+		return ops->mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
+	return dma_common_mmap(dev, vma, cpu_addr, dma_addr, size);
+}
+
+#define dma_mmap_coherent(d, v, c, h, s) dma_mmap_attrs(d, v, c, h, s, NULL)
+
+static inline int dma_mmap_writecombine(struct device *dev, struct vm_area_struct *vma,
+		      void *cpu_addr, dma_addr_t dma_addr, size_t size)
+{
+	DEFINE_DMA_ATTRS(attrs);
+	dma_set_attr(DMA_ATTR_WRITE_COMBINE, &attrs);
+	return dma_mmap_attrs(dev, vma, cpu_addr, dma_addr, size, &attrs);
+}
+
 #endif
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
