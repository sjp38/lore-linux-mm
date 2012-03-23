Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 29CA66B0092
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 08:26:12 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M1C00D127VOV050@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Mar 2012 12:26:12 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1C00MBR7VLND@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Mar 2012 12:26:10 +0000 (GMT)
Date: Fri, 23 Mar 2012 13:26:02 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 1/2] common: add dma_mmap_from_coherent() function
In-reply-to: <1332505563-17646-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1332505563-17646-2-git-send-email-m.szyprowski@samsung.com>
References: <08af01cd08ee$2fd04770$8f70d650$%szyprowski@samsung.com>
 <1332505563-17646-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

Add a common helper for dma-mapping core for mapping a coherent buffer
to userspace.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 drivers/base/dma-coherent.c        |   42 ++++++++++++++++++++++++++++++++++++
 include/asm-generic/dma-coherent.h |    4 ++-
 2 files changed, 45 insertions(+), 1 deletions(-)

diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
index bb0025c..ef5ae05 100644
--- a/drivers/base/dma-coherent.c
+++ b/drivers/base/dma-coherent.c
@@ -10,6 +10,7 @@
 struct dma_coherent_mem {
 	void		*virt_base;
 	dma_addr_t	device_base;
+	phys_addr_t	pfn_base;
 	int		size;
 	int		flags;
 	unsigned long	*bitmap;
@@ -44,6 +45,7 @@ int dma_declare_coherent_memory(struct device *dev, dma_addr_t bus_addr,
 
 	dev->dma_mem->virt_base = mem_base;
 	dev->dma_mem->device_base = device_addr;
+	dev->dma_mem->pfn_base = PFN_DOWN(bus_addr);
 	dev->dma_mem->size = pages;
 	dev->dma_mem->flags = flags;
 
@@ -176,3 +178,43 @@ int dma_release_from_coherent(struct device *dev, int order, void *vaddr)
 	return 0;
 }
 EXPORT_SYMBOL(dma_release_from_coherent);
+
+/**
+ * dma_mmap_from_coherent() - try to mmap the memory allocated from 
+ * per-device coherent memory pool to userspace
+ * @dev:	device from which the memory was allocated
+ * @vma:	vm_area for the userspace memory
+ * @vaddr:	cpu address returned by dma_alloc_from_coherent
+ * @size:	size of the memory buffer allocated by dma_alloc_from_coherent
+ *
+ * This checks whether the memory was allocated from the per-device
+ * coherent memory pool and if so, maps that memory to the provided vma.
+ *
+ * Returns 1 if we correctly mapped the memory, or 0 if
+ * dma_release_coherent() should proceed with mapping memory from
+ * generic pools.
+ */
+int dma_mmap_from_coherent(struct device *dev, struct vm_area_struct *vma,
+			   void *vaddr, size_t size, int *ret)
+{
+	struct dma_coherent_mem *mem = dev ? dev->dma_mem : NULL;
+
+	if (mem && vaddr >= mem->virt_base && vaddr + size <=
+		   (mem->virt_base + (mem->size << PAGE_SHIFT))) {
+		unsigned long off = vma->vm_pgoff;
+		int start = (vaddr - mem->virt_base) >> PAGE_SHIFT;
+		int user_count = (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
+		int count = size >> PAGE_SHIFT;
+
+		*ret = -ENXIO;
+		if (off < count && user_count <= count - off) {
+			unsigned pfn = mem->pfn_base + start + off;
+			*ret = remap_pfn_range(vma, vma->vm_start, pfn,
+					       user_count << PAGE_SHIFT,
+					       vma->vm_page_prot);
+		}
+		return 1;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(dma_mmap_from_coherent);
diff --git a/include/asm-generic/dma-coherent.h b/include/asm-generic/dma-coherent.h
index 85a3ffa..b82051d 100644
--- a/include/asm-generic/dma-coherent.h
+++ b/include/asm-generic/dma-coherent.h
@@ -3,13 +3,15 @@
 
 #ifdef CONFIG_HAVE_GENERIC_DMA_COHERENT
 /*
- * These two functions are only for dma allocator.
+ * These three functions are only for dma allocator.
  * Don't use them in device drivers.
  */
 int dma_alloc_from_coherent(struct device *dev, ssize_t size,
 				       dma_addr_t *dma_handle, void **ret);
 int dma_release_from_coherent(struct device *dev, int order, void *vaddr);
 
+int dma_mmap_from_coherent(struct device *dev, struct vm_area_struct *vma,
+                           void *cpu_addr, size_t size, int *ret);
 /*
  * Standard interface
  */
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
