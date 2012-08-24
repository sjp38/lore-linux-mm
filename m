Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 7DED46B0069
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 04:30:19 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [v3 4/4] ARM: dma-mapping: IOMMU allocates pages from atomic_pool with GFP_ATOMIC
Date: Fri, 24 Aug 2012 11:29:05 +0300
Message-ID: <1345796945-21115-5-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1345796945-21115-1-git-send-email-hdoyu@nvidia.com>
References: <1345796945-21115-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com
Cc: Hiroshi Doyu <hdoyu@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, konrad.wilk@oracle.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com

Make use of the same atomic pool as DMA does, and skip a kernel page
mapping which can involve sleep'able operations at allocating a kernel
page table.

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
---
 arch/arm/mm/dma-mapping.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 58a852b..3ce152a 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1205,6 +1205,34 @@ static struct page **__iommu_get_pages(void *cpu_addr, struct dma_attrs *attrs)
 	return NULL;
 }
 
+static void *__iommu_alloc_atomic(struct device *dev, size_t size,
+				  dma_addr_t *handle)
+{
+	struct page *page;
+	void *addr;
+
+	addr = __alloc_from_pool(size, &page);
+	if (!addr)
+		return NULL;
+
+	*handle = __iommu_create_mapping(dev, &page, size);
+	if (*handle == DMA_ERROR_CODE)
+		goto err_mapping;
+
+	return addr;
+
+err_mapping:
+	__free_from_pool(addr, size);
+	return NULL;
+}
+
+static void __iommu_free_atomic(struct device *dev, struct page **pages,
+				dma_addr_t handle, size_t size)
+{
+	__iommu_remove_mapping(dev, handle, size);
+	__free_from_pool(page_address(pages[0]), size);
+}
+
 static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
 	    dma_addr_t *handle, gfp_t gfp, struct dma_attrs *attrs)
 {
@@ -1215,6 +1243,9 @@ static void *arm_iommu_alloc_attrs(struct device *dev, size_t size,
 	*handle = DMA_ERROR_CODE;
 	size = PAGE_ALIGN(size);
 
+	if (gfp & GFP_ATOMIC)
+		return __iommu_alloc_atomic(dev, size, handle);
+
 	pages = __iommu_alloc_buffer(dev, size, gfp);
 	if (!pages)
 		return NULL;
@@ -1281,6 +1312,11 @@ void arm_iommu_free_attrs(struct device *dev, size_t size, void *cpu_addr,
 		return;
 	}
 
+	if (__in_atomic_pool(cpu_addr, size)) {
+		__iommu_free_atomic(dev, pages, handle, size);
+		return;
+	}
+
 	if (!dma_get_attr(DMA_ATTR_NO_KERNEL_MAPPING, attrs)) {
 		unmap_kernel_range((unsigned long)cpu_addr, size);
 		vunmap(cpu_addr);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
