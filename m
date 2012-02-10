Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id D62406B1403
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 13:59:02 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LZ600BSPY2AMY80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Feb 2012 18:58:58 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LZ600CFCY29RK@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 10 Feb 2012 18:58:58 +0000 (GMT)
Date: Fri, 10 Feb 2012 19:58:43 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv6 6/7] ARM: dma-mapping: use alloc, mmap, free from dma_ops
In-reply-to: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1328900324-20946-7-git-send-email-m.szyprowski@samsung.com>
References: <1328900324-20946-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This patch converts dma_alloc/free/mmap_{coherent,writecombine}
functions to use generic alloc/free/mmap methods from dma_map_ops
structure. A new DMA_ATTR_WRITE_COMBINE DMA attribute have been
introduced to implement writecombine methods.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/common/dmabounce.c        |    3 +
 arch/arm/include/asm/dma-mapping.h |  107 ++++++++++++++++++++++++++----------
 arch/arm/mm/dma-mapping.c          |   53 ++++++------------
 3 files changed, 98 insertions(+), 65 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 5e7ba61..739407e 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -449,6 +449,9 @@ static int dmabounce_set_mask(struct device *dev, u64 dma_mask)
 }
 
 static struct dma_map_ops dmabounce_ops = {
+	.alloc			= arm_dma_alloc,
+	.free			= arm_dma_free,
+	.mmap			= arm_dma_mmap,
 	.map_page		= dmabounce_map_page,
 	.unmap_page		= dmabounce_unmap_page,
 	.sync_single_for_cpu	= dmabounce_sync_for_cpu,
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 0016bff..ca7a378 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -5,6 +5,7 @@
 
 #include <linux/mm_types.h>
 #include <linux/scatterlist.h>
+#include <linux/dma-attrs.h>
 #include <linux/dma-debug.h>
 
 #include <asm-generic/dma-coherent.h>
@@ -109,68 +110,115 @@ static inline void dma_free_noncoherent(struct device *dev, size_t size,
 extern int dma_supported(struct device *dev, u64 mask);
 
 /**
- * dma_alloc_coherent - allocate consistent memory for DMA
+ * arm_dma_alloc - allocate consistent memory for DMA
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
  * @size: required memory size
  * @handle: bus-specific DMA address
+ * @attrs: optinal attributes that specific mapping properties
  *
- * Allocate some uncached, unbuffered memory for a device for
- * performing DMA.  This function allocates pages, and will
- * return the CPU-viewed address, and sets @handle to be the
- * device-viewed address.
+ * Allocate some memory for a device for performing DMA.  This function
+ * allocates pages, and will return the CPU-viewed address, and sets @handle
+ * to be the device-viewed address.
  */
-extern void *dma_alloc_coherent(struct device *, size_t, dma_addr_t *, gfp_t);
+extern void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
+			   gfp_t gfp, struct dma_attrs *attrs);
+
+#define dma_alloc_coherent(d,s,h,f) dma_alloc_attrs(d,s,h,f,NULL)
+
+static inline void *dma_alloc_attrs(struct device *dev, size_t size,
+				       dma_addr_t *dma_handle, gfp_t flag,
+				       struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	void *cpu_addr;
+	BUG_ON(!ops);
+
+	cpu_addr = ops->alloc(dev, size, dma_handle, flag, attrs);
+	debug_dma_alloc_coherent(dev, size, *dma_handle, cpu_addr);
+	return cpu_addr;
+}
 
 /**
- * dma_free_coherent - free memory allocated by dma_alloc_coherent
+ * arm_dma_free - free memory allocated by arm_dma_alloc
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
  * @size: size of memory originally requested in dma_alloc_coherent
  * @cpu_addr: CPU-view address returned from dma_alloc_coherent
  * @handle: device-view address returned from dma_alloc_coherent
+ * @attrs: optinal attributes that specific mapping properties
  *
  * Free (and unmap) a DMA buffer previously allocated by
- * dma_alloc_coherent().
+ * arm_dma_alloc().
  *
  * References to memory and mappings associated with cpu_addr/handle
  * during and after this call executing are illegal.
  */
-extern void dma_free_coherent(struct device *, size_t, void *, dma_addr_t);
+extern void arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
+			 dma_addr_t handle, struct dma_attrs *attrs);
+
+#define dma_free_coherent(d,s,c,h) dma_free_attrs(d,s,c,h,NULL)
+
+static inline void dma_free_attrs(struct device *dev, size_t size,
+				     void *cpu_addr, dma_addr_t dma_handle,
+				     struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	BUG_ON(!ops);
+
+	debug_dma_free_coherent(dev, size, cpu_addr, dma_handle);
+	ops->free(dev, size, cpu_addr, dma_handle, attrs);
+}
 
 /**
- * dma_mmap_coherent - map a coherent DMA allocation into user space
+ * arm_dma_mmap - map a coherent DMA allocation into user space
  * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
  * @vma: vm_area_struct describing requested user mapping
  * @cpu_addr: kernel CPU-view address returned from dma_alloc_coherent
  * @handle: device-view address returned from dma_alloc_coherent
  * @size: size of memory originally requested in dma_alloc_coherent
+ * @attrs: optinal attributes that specific mapping properties
  *
  * Map a coherent DMA buffer previously allocated by dma_alloc_coherent
  * into user space.  The coherent DMA buffer must not be freed by the
  * driver until the user space mapping has been released.
  */
-int dma_mmap_coherent(struct device *, struct vm_area_struct *,
-		void *, dma_addr_t, size_t);
+extern int arm_dma_mmap(struct device *dev, struct vm_area_struct *vma,
+			void *cpu_addr, dma_addr_t dma_addr, size_t size,
+			struct dma_attrs *attrs);
 
+#define dma_mmap_coherent(d,v,c,h,s) dma_mmap_attrs(d,v,c,h,s,NULL)
 
-/**
- * dma_alloc_writecombine - allocate writecombining memory for DMA
- * @dev: valid struct device pointer, or NULL for ISA and EISA-like devices
- * @size: required memory size
- * @handle: bus-specific DMA address
- *
- * Allocate some uncached, buffered memory for a device for
- * performing DMA.  This function allocates pages, and will
- * return the CPU-viewed address, and sets @handle to be the
- * device-viewed address.
- */
-extern void *dma_alloc_writecombine(struct device *, size_t, dma_addr_t *,
-		gfp_t);
+static inline int dma_mmap_attrs(struct device *dev, struct vm_area_struct *vma,
+				  void *cpu_addr, dma_addr_t dma_addr,
+				  size_t size, struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	BUG_ON(!ops);
+	return ops->mmap(dev, vma, cpu_addr, dma_addr, size, attrs);
+}
 
-#define dma_free_writecombine(dev,size,cpu_addr,handle) \
-	dma_free_coherent(dev,size,cpu_addr,handle)
+static inline void *dma_alloc_writecombine(struct device *dev, size_t size,
+				       dma_addr_t *dma_handle, gfp_t flag)
+{
+	DEFINE_DMA_ATTRS(attrs);
+	dma_set_attr(DMA_ATTR_WRITE_COMBINE, &attrs);
+	return dma_alloc_attrs(dev, size, dma_handle, flag, &attrs);
+}
 
-int dma_mmap_writecombine(struct device *, struct vm_area_struct *,
-		void *, dma_addr_t, size_t);
+static inline void dma_free_writecombine(struct device *dev, size_t size,
+				     void *cpu_addr, dma_addr_t dma_handle)
+{
+	DEFINE_DMA_ATTRS(attrs);
+	dma_set_attr(DMA_ATTR_WRITE_COMBINE, &attrs);
+	return dma_free_attrs(dev, size, cpu_addr, dma_handle, &attrs);
+}
+
+static inline int dma_mmap_writecombine(struct device *dev, struct vm_area_struct *vma,
+		      void *cpu_addr, dma_addr_t dma_addr, size_t size)
+{
+	DEFINE_DMA_ATTRS(attrs);
+	dma_set_attr(DMA_ATTR_WRITE_COMBINE, &attrs);
+	return dma_mmap_attrs(dev, vma, cpu_addr, dma_addr, size, &attrs);
+}
 
 /*
  * This can be called during boot to increase the size of the consistent
@@ -179,7 +227,6 @@ int dma_mmap_writecombine(struct device *, struct vm_area_struct *,
  */
 extern void __init init_consistent_dma_size(unsigned long size);
 
-
 /*
  * For SA-1111, IXP425, and ADI systems  the dma-mapping functions are "magic"
  * and utilize bounce buffers as needed to work around limited DMA windows.
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 7c0e68b..4845c09 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -114,6 +114,9 @@ static void arm_dma_sync_single_for_device(struct device *dev,
 static int arm_dma_set_mask(struct device *dev, u64 dma_mask);
 
 struct dma_map_ops arm_dma_ops = {
+	.alloc			= arm_dma_alloc,
+	.free			= arm_dma_free,
+	.mmap			= arm_dma_mmap,
 	.map_page		= arm_dma_map_page,
 	.unmap_page		= arm_dma_unmap_page,
 	.map_sg			= arm_dma_map_sg,
@@ -462,33 +465,26 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp,
  * Allocate DMA-coherent memory space and return both the kernel remapped
  * virtual and bus address for that space.
  */
-void *
-dma_alloc_coherent(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp)
+void *arm_dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
+		    gfp_t gfp, struct dma_attrs *attrs)
 {
+	pgprot_t prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
+			pgprot_writecombine(pgprot_kernel) :
+			pgprot_dmacoherent(pgprot_kernel);
 	void *memory;
 
 	if (dma_alloc_from_coherent(dev, size, handle, &memory))
 		return memory;
 
-	return __dma_alloc(dev, size, handle, gfp,
-			   pgprot_dmacoherent(pgprot_kernel));
+	return __dma_alloc(dev, size, handle, gfp, prot);
 }
-EXPORT_SYMBOL(dma_alloc_coherent);
 
 /*
- * Allocate a writecombining region, in much the same way as
- * dma_alloc_coherent above.
+ * Create userspace mapping for the DMA-coherent memory.
  */
-void *
-dma_alloc_writecombine(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp)
-{
-	return __dma_alloc(dev, size, handle, gfp,
-			   pgprot_writecombine(pgprot_kernel));
-}
-EXPORT_SYMBOL(dma_alloc_writecombine);
-
-static int dma_mmap(struct device *dev, struct vm_area_struct *vma,
-		    void *cpu_addr, dma_addr_t dma_addr, size_t size)
+int arm_dma_mmap(struct device *dev, struct vm_area_struct *vma,
+		 void *cpu_addr, dma_addr_t dma_addr, size_t size,
+		 struct dma_attrs *attrs)
 {
 	int ret = -ENXIO;
 #ifdef CONFIG_MMU
@@ -496,6 +492,9 @@ static int dma_mmap(struct device *dev, struct vm_area_struct *vma,
 	struct arm_vmregion *c;
 
 	user_size = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+	vma->vm_page_prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
+			    pgprot_writecombine(vma->vm_page_prot) :
+			    pgprot_dmacoherent(vma->vm_page_prot);
 
 	c = arm_vmregion_find(&consistent_head, (unsigned long)cpu_addr);
 	if (c) {
@@ -516,27 +515,12 @@ static int dma_mmap(struct device *dev, struct vm_area_struct *vma,
 	return ret;
 }
 
-int dma_mmap_coherent(struct device *dev, struct vm_area_struct *vma,
-		      void *cpu_addr, dma_addr_t dma_addr, size_t size)
-{
-	vma->vm_page_prot = pgprot_dmacoherent(vma->vm_page_prot);
-	return dma_mmap(dev, vma, cpu_addr, dma_addr, size);
-}
-EXPORT_SYMBOL(dma_mmap_coherent);
-
-int dma_mmap_writecombine(struct device *dev, struct vm_area_struct *vma,
-			  void *cpu_addr, dma_addr_t dma_addr, size_t size)
-{
-	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
-	return dma_mmap(dev, vma, cpu_addr, dma_addr, size);
-}
-EXPORT_SYMBOL(dma_mmap_writecombine);
-
 /*
  * free a page as defined by the above mapping.
  * Must not be called with IRQs disabled.
  */
-void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr_t handle)
+void arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
+		  dma_addr_t handle, struct dma_attrs *attrs)
 {
 	WARN_ON(irqs_disabled());
 
@@ -550,7 +534,6 @@ void dma_free_coherent(struct device *dev, size_t size, void *cpu_addr, dma_addr
 
 	__dma_free_buffer(pfn_to_page(dma_to_pfn(dev, handle)), size);
 }
-EXPORT_SYMBOL(dma_free_coherent);
 
 static void dma_cache_maint_page(struct page *page, unsigned long offset,
 	size_t size, enum dma_data_direction dir,
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
