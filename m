Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94AF06B03B4
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 16:09:05 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id k62so7133264oia.6
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:09:05 -0700 (PDT)
Received: from mail-it0-x22a.google.com (mail-it0-x22a.google.com. [2607:f8b0:4001:c0b::22a])
        by mx.google.com with ESMTPS id p8si3467699oia.385.2017.08.09.13.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 13:09:04 -0700 (PDT)
Received: by mail-it0-x22a.google.com with SMTP id m34so3266187iti.1
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 13:09:04 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [PATCH v5 08/10] arm64/mm: Add support for XPFO to swiotlb
Date: Wed,  9 Aug 2017 14:07:53 -0600
Message-Id: <20170809200755.11234-9-tycho@docker.com>
In-Reply-To: <20170809200755.11234-1-tycho@docker.com>
References: <20170809200755.11234-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>, Tycho Andersen <tycho@docker.com>

From: Juerg Haefliger <juerg.haefliger@hpe.com>

Pages that are unmapped by XPFO need to be mapped before and unmapped
again after (to restore the original state) the __dma_{map,unmap}_area()
operations to prevent fatal page faults.

Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
---
 arch/arm64/include/asm/cacheflush.h | 11 +++++++++
 arch/arm64/mm/dma-mapping.c         | 32 +++++++++++++-------------
 arch/arm64/mm/xpfo.c                | 45 +++++++++++++++++++++++++++++++++++++
 3 files changed, 72 insertions(+), 16 deletions(-)

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
index de03a652d48a..c4deb2b720cf 100644
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
 
@@ -62,3 +64,46 @@ inline void xpfo_flush_kernel_page(struct page *page, int order)
 
 	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
 }
+
+inline void xpfo_dma_map_unmap_area(bool map, const void *addr, size_t size,
+				    int dir)
+{
+	unsigned long flags;
+	struct page *page = virt_to_page(addr);
+
+	/*
+	 * +2 here because we really want
+	 * ceil(size / PAGE_SIZE), not floor(), and one extra in case things are
+	 * not page aligned
+	 */
+	int i, possible_pages = size / PAGE_SIZE + 2;
+	void *buf[possible_pages];
+
+	memset(buf, 0, sizeof(void *) * possible_pages);
+
+	local_irq_save(flags);
+
+	/* Map the first page */
+	if (xpfo_page_is_unmapped(page))
+		buf[0] = kmap_atomic(page);
+
+	/* Map the remaining pages */
+	for (i = 1; i < possible_pages; i++) {
+		if (page_to_virt(page + i) >= addr + size)
+			break;
+
+		if (xpfo_page_is_unmapped(page + i))
+			buf[i] = kmap_atomic(page + i);
+	}
+
+	if (map)
+		__dma_map_area(addr, size, dir);
+	else
+		__dma_unmap_area(addr, size, dir);
+
+	for (i = 0; i < possible_pages; i++)
+		if (buf[i])
+			kunmap_atomic(buf[i]);
+
+	local_irq_restore(flags);
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
