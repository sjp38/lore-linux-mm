Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B5EFF6B02FE
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 13:37:13 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 3so273719ity.3
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 10:37:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k124sor30499itg.31.2017.09.07.10.37.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Sep 2017 10:37:12 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [PATCH v6 08/11] arm64/mm: Add support for XPFO to swiotlb
Date: Thu,  7 Sep 2017 11:36:06 -0600
Message-Id: <20170907173609.22696-9-tycho@docker.com>
In-Reply-To: <20170907173609.22696-1-tycho@docker.com>
References: <20170907173609.22696-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-arm-kernel@lists.infradead.org, Tycho Andersen <tycho@docker.com>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

Pages that are unmapped by XPFO need to be mapped before and unmapped
again after (to restore the original state) the __dma_{map,unmap}_area()
operations to prevent fatal page faults.

v6: * use the hoisted out temporary mapping code instead

CC: linux-arm-kernel@lists.infradead.org
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
---
 arch/arm64/include/asm/cacheflush.h | 11 +++++++++++
 arch/arm64/mm/dma-mapping.c         | 32 ++++++++++++++++----------------
 arch/arm64/mm/xpfo.c                | 18 ++++++++++++++++++
 include/linux/xpfo.h                |  2 ++
 4 files changed, 47 insertions(+), 16 deletions(-)

diff --git a/arch/arm64/include/asm/cacheflush.h b/arch/arm64/include/asm/cacheflush.h
index d74a284abdc2..b6a462e3b2f9 100644
--- a/arch/arm64/include/asm/cacheflush.h
+++ b/arch/arm64/include/asm/cacheflush.h
@@ -93,6 +93,17 @@ extern void __dma_map_area(const void *, size_t, int);
 extern void __dma_unmap_area(const void *, size_t, int);
 extern void __dma_flush_area(const void *, size_t);
 
+#ifdef CONFIG_XPFO
+#include <linux/xpfo.h>
+#define _dma_map_area(addr, size, dir) \
+	xpfo_dma_map_unmap_area(true, addr, size, dir)
+#define _dma_unmap_area(addr, size, dir) \
+	xpfo_dma_map_unmap_area(false, addr, size, dir)
+#else
+#define _dma_map_area(addr, size, dir) __dma_map_area(addr, size, dir)
+#define _dma_unmap_area(addr, size, dir) __dma_unmap_area(addr, size, dir)
+#endif
+
 /*
  * Copy user data from/to a page which is mapped into a different
  * processes address space.  Really, we want to allow our "user
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index f27d4dd04384..a79f200786ab 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -204,7 +204,7 @@ static dma_addr_t __swiotlb_map_page(struct device *dev, struct page *page,
 	dev_addr = swiotlb_map_page(dev, page, offset, size, dir, attrs);
 	if (!is_device_dma_coherent(dev) &&
 	    (attrs & DMA_ATTR_SKIP_CPU_SYNC) == 0)
-		__dma_map_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
+		_dma_map_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
 
 	return dev_addr;
 }
@@ -216,7 +216,7 @@ static void __swiotlb_unmap_page(struct device *dev, dma_addr_t dev_addr,
 {
 	if (!is_device_dma_coherent(dev) &&
 	    (attrs & DMA_ATTR_SKIP_CPU_SYNC) == 0)
-		__dma_unmap_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
+		_dma_unmap_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
 	swiotlb_unmap_page(dev, dev_addr, size, dir, attrs);
 }
 
@@ -231,8 +231,8 @@ static int __swiotlb_map_sg_attrs(struct device *dev, struct scatterlist *sgl,
 	if (!is_device_dma_coherent(dev) &&
 	    (attrs & DMA_ATTR_SKIP_CPU_SYNC) == 0)
 		for_each_sg(sgl, sg, ret, i)
-			__dma_map_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
-				       sg->length, dir);
+			_dma_map_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
+				      sg->length, dir);
 
 	return ret;
 }
@@ -248,8 +248,8 @@ static void __swiotlb_unmap_sg_attrs(struct device *dev,
 	if (!is_device_dma_coherent(dev) &&
 	    (attrs & DMA_ATTR_SKIP_CPU_SYNC) == 0)
 		for_each_sg(sgl, sg, nelems, i)
-			__dma_unmap_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
-					 sg->length, dir);
+			_dma_unmap_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
+					sg->length, dir);
 	swiotlb_unmap_sg_attrs(dev, sgl, nelems, dir, attrs);
 }
 
@@ -258,7 +258,7 @@ static void __swiotlb_sync_single_for_cpu(struct device *dev,
 					  enum dma_data_direction dir)
 {
 	if (!is_device_dma_coherent(dev))
-		__dma_unmap_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
+		_dma_unmap_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
 	swiotlb_sync_single_for_cpu(dev, dev_addr, size, dir);
 }
 
@@ -268,7 +268,7 @@ static void __swiotlb_sync_single_for_device(struct device *dev,
 {
 	swiotlb_sync_single_for_device(dev, dev_addr, size, dir);
 	if (!is_device_dma_coherent(dev))
-		__dma_map_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
+		_dma_map_area(phys_to_virt(dma_to_phys(dev, dev_addr)), size, dir);
 }
 
 static void __swiotlb_sync_sg_for_cpu(struct device *dev,
@@ -280,8 +280,8 @@ static void __swiotlb_sync_sg_for_cpu(struct device *dev,
 
 	if (!is_device_dma_coherent(dev))
 		for_each_sg(sgl, sg, nelems, i)
-			__dma_unmap_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
-					 sg->length, dir);
+			_dma_unmap_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
+					sg->length, dir);
 	swiotlb_sync_sg_for_cpu(dev, sgl, nelems, dir);
 }
 
@@ -295,8 +295,8 @@ static void __swiotlb_sync_sg_for_device(struct device *dev,
 	swiotlb_sync_sg_for_device(dev, sgl, nelems, dir);
 	if (!is_device_dma_coherent(dev))
 		for_each_sg(sgl, sg, nelems, i)
-			__dma_map_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
-				       sg->length, dir);
+			_dma_map_area(phys_to_virt(dma_to_phys(dev, sg->dma_address)),
+				      sg->length, dir);
 }
 
 static int __swiotlb_mmap_pfn(struct vm_area_struct *vma,
@@ -758,7 +758,7 @@ static void __iommu_sync_single_for_cpu(struct device *dev,
 		return;
 
 	phys = iommu_iova_to_phys(iommu_get_domain_for_dev(dev), dev_addr);
-	__dma_unmap_area(phys_to_virt(phys), size, dir);
+	_dma_unmap_area(phys_to_virt(phys), size, dir);
 }
 
 static void __iommu_sync_single_for_device(struct device *dev,
@@ -771,7 +771,7 @@ static void __iommu_sync_single_for_device(struct device *dev,
 		return;
 
 	phys = iommu_iova_to_phys(iommu_get_domain_for_dev(dev), dev_addr);
-	__dma_map_area(phys_to_virt(phys), size, dir);
+	_dma_map_area(phys_to_virt(phys), size, dir);
 }
 
 static dma_addr_t __iommu_map_page(struct device *dev, struct page *page,
@@ -811,7 +811,7 @@ static void __iommu_sync_sg_for_cpu(struct device *dev,
 		return;
 
 	for_each_sg(sgl, sg, nelems, i)
-		__dma_unmap_area(sg_virt(sg), sg->length, dir);
+		_dma_unmap_area(sg_virt(sg), sg->length, dir);
 }
 
 static void __iommu_sync_sg_for_device(struct device *dev,
@@ -825,7 +825,7 @@ static void __iommu_sync_sg_for_device(struct device *dev,
 		return;
 
 	for_each_sg(sgl, sg, nelems, i)
-		__dma_map_area(sg_virt(sg), sg->length, dir);
+		_dma_map_area(sg_virt(sg), sg->length, dir);
 }
 
 static int __iommu_map_sg_attrs(struct device *dev, struct scatterlist *sgl,
diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
index 678e2be848eb..342a9ccb93c1 100644
--- a/arch/arm64/mm/xpfo.c
+++ b/arch/arm64/mm/xpfo.c
@@ -11,8 +11,10 @@
  * the Free Software Foundation.
  */
 
+#include <linux/highmem.h>
 #include <linux/mm.h>
 #include <linux/module.h>
+#include <linux/xpfo.h>
 
 #include <asm/tlbflush.h>
 
@@ -56,3 +58,19 @@ inline void xpfo_flush_kernel_tlb(struct page *page, int order)
 
 	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
 }
+
+void xpfo_dma_map_unmap_area(bool map, const void *addr, size_t size,
+				    enum dma_data_direction dir)
+{
+	unsigned long num_pages = XPFO_NUM_PAGES(addr, size);
+	void *mapping[num_pages];
+
+	xpfo_temp_map(addr, size, mapping, sizeof(mapping[0]) * num_pages);
+
+	if (map)
+		__dma_map_area(addr, size, dir);
+	else
+		__dma_unmap_area(addr, size, dir);
+
+	xpfo_temp_unmap(addr, size, mapping, sizeof(mapping[0]) * num_pages);
+}
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
index 304b104ec637..d37a06c9d62c 100644
--- a/include/linux/xpfo.h
+++ b/include/linux/xpfo.h
@@ -18,6 +18,8 @@
 
 #ifdef CONFIG_XPFO
 
+#include <linux/dma-mapping.h>
+
 extern struct page_ext_operations page_xpfo_ops;
 
 void set_kpte(void *kaddr, struct page *page, pgprot_t prot);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
