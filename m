Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E66EE6B00E9
	for <linux-mm@kvack.org>; Thu, 17 May 2012 12:53:29 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M46006KCEVU6D70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 17:52:42 +0100 (BST)
Received: from ubuntu.arm.acom ([106.210.236.191])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M46008IQEWVMY@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 17:53:28 +0100 (BST)
Date: Thu, 17 May 2012 18:53:06 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 3/3] ARM: dma-mapping: add support for dma_get_sgtable()
In-reply-to: <1337273586-11089-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1337273586-11089-4-git-send-email-m.szyprowski@samsung.com>
References: <1337273586-11089-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subash.ramaswamy@linaro.org>, Sumit Semwal <sumit.semwal@linaro.org>, Abhinav Kochhar <abhinav.k@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>

This patch adds dma_get_sgtable() function which is required to let
drivers to share the buffers allocated by DMA-mapping subsystem. Right
now the driver gets a dma address of the allocated buffer and the kernel
virtual mapping for it. If it wants to share it with other device (= map
into its dma address space) it usually hacks around kernel virtual
addresses to get pointers to pages or assumes that both devices share
the DMA address space. Both solutions are just hacks for the special
cases, which should be avoided in the final version of buffer sharing.
To solve this issue in a generic way, a new call to DMA mapping has been
introduced - dma_get_sgtable(). It allocates a scatter-list which
describes the allocated buffer and lets the driver(s) to use it with
other device(s) by calling dma_map_sg() on it.

This patch adds this extension only to ARM architecture, mainly to
demonstrate the buffer sharing. I plan to provide some generic
implementations for other architectures once this idea gets accepted.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 arch/arm/include/asm/dma-mapping.h |   12 ++++++++++++
 arch/arm/mm/dma-mapping.c          |   31 +++++++++++++++++++++++++++++++
 include/linux/dma-mapping.h        |    3 +++
 3 files changed, 46 insertions(+)

diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 80777d87..2e37778 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -221,6 +221,15 @@ static inline int dma_mmap_writecombine(struct device *dev, struct vm_area_struc
 	return dma_mmap_attrs(dev, vma, cpu_addr, dma_addr, size, &attrs);
 }
 
+static inline int dma_get_sgtable(struct device *dev, struct sg_table *sgt,
+				  void *cpu_addr, dma_addr_t dma_addr,
+				  size_t size, struct dma_attrs *attrs)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	BUG_ON(!ops);
+	return ops->get_sgtable(dev, sgt, cpu_addr, dma_addr, size, attrs);
+}
+
 /*
  * This can be called during boot to increase the size of the consistent
  * DMA region above it's default value of 2MB. It must be called before the
@@ -280,6 +289,9 @@ extern void arm_dma_sync_sg_for_cpu(struct device *, struct scatterlist *, int,
 		enum dma_data_direction);
 extern void arm_dma_sync_sg_for_device(struct device *, struct scatterlist *, int,
 		enum dma_data_direction);
+extern int arm_dma_get_sgtable(struct device *dev, struct sg_table *sgt,
+		void *cpu_addr, dma_addr_t dma_addr, size_t size,
+		struct dma_attrs *attrs);
 
 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 23d0ace..b140440 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -120,6 +120,7 @@ struct dma_map_ops arm_dma_ops = {
 	.alloc			= arm_dma_alloc,
 	.free			= arm_dma_free,
 	.mmap			= arm_dma_mmap,
+	.get_sgtable		= arm_dma_get_sgtable,
 	.map_page		= arm_dma_map_page,
 	.unmap_page		= arm_dma_unmap_page,
 	.map_sg			= arm_dma_map_sg,
@@ -529,6 +530,21 @@ void arm_dma_free(struct device *dev, size_t size, void *cpu_addr,
 	__dma_free_buffer(pfn_to_page(dma_to_pfn(dev, handle)), size);
 }
 
+int arm_dma_get_sgtable(struct device *dev, struct sg_table *sgt,
+		 void *cpu_addr, dma_addr_t handle, size_t size,
+		 struct dma_attrs *attrs)
+{
+	struct page *page = pfn_to_page(dma_to_pfn(dev, handle));
+	int ret;
+
+	ret = sg_alloc_table(sgt, 1, GFP_KERNEL);
+	if (unlikely(ret))
+		return ret;
+
+	sg_set_page(sgt->sgl, page, PAGE_ALIGN(size), 0);
+	return 0;
+}
+
 static void dma_cache_maint_page(struct page *page, unsigned long offset,
 	size_t size, enum dma_data_direction dir,
 	void (*op)(const void *, size_t, int))
@@ -1042,6 +1058,20 @@ void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
 	__iommu_free_buffer(dev, pages, size);
 }
 
+static int arm_iommu_get_sgtable(struct device *dev, struct sg_table *sgt,
+				 void *cpu_addr, dma_addr_t dma_addr,
+				 size_t size, struct dma_attrs *attrs)
+{
+	unsigned int count = PAGE_ALIGN(size) >> PAGE_SHIFT;
+	struct page **pages = __iommu_get_pages(cpu_addr, attrs);
+
+	if (!pages)
+		return -ENXIO;
+
+	return sg_alloc_table_from_pages(sgt, pages, count, 0, size,
+					 GFP_KERNEL);
+}
+
 /*
  * Map a part of the scatter-gather list into contiguous io address space
  */
@@ -1301,6 +1331,7 @@ struct dma_map_ops iommu_ops = {
 	.alloc		= arm_iommu_alloc_attrs,
 	.free		= arm_iommu_free_attrs,
 	.mmap		= arm_iommu_mmap_attrs,
+	.get_sgtable	= arm_iommu_get_sgtable,
 
 	.map_page		= arm_iommu_map_page,
 	.unmap_page		= arm_iommu_unmap_page,
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index dfc099e..94af418 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -18,6 +18,9 @@ struct dma_map_ops {
 	int (*mmap)(struct device *, struct vm_area_struct *,
 			  void *, dma_addr_t, size_t, struct dma_attrs *attrs);
 
+	int (*get_sgtable)(struct device *dev, struct sg_table *sgt, void *,
+			   dma_addr_t, size_t, struct dma_attrs *attrs);
+
 	dma_addr_t (*map_page)(struct device *dev, struct page *page,
 			       unsigned long offset, size_t size,
 			       enum dma_data_direction dir,
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
