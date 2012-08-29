Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 4C3546B006E
	for <linux-mm@kvack.org>; Wed, 29 Aug 2012 02:56:43 -0400 (EDT)
From: Hiroshi Doyu <hdoyu@nvidia.com>
Subject: [RFC 2/5] ARM: dma-mapping: New dma_map_ops->iova_{alloc,free}() functions
Date: Wed, 29 Aug 2012 09:55:32 +0300
Message-ID: <1346223335-31455-3-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
References: <1346223335-31455-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com
Cc: iommu@lists.linux-foundation.org, Hiroshi Doyu <hdoyu@nvidia.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kyungmin.park@samsung.com, arnd@arndb.de, linux@arm.linux.org.uk, chunsang.jeong@linaro.org, vdumpa@nvidia.com, subashrp@gmail.com, minchan@kernel.org, pullip.cho@samsung.com, konrad.wilk@oracle.com, linux-tegra@vger.kernel.org

There are some cases that IOVA allocation and mapping have to be done
seperately, especially for perf optimization reasons. This patch
allows client modules to {alloc,free} IOVA space without backing up
actual pages for that area.

Signed-off-by: Hiroshi Doyu <hdoyu@nvidia.com>
---
 arch/arm/include/asm/dma-mapping.h |   17 +++++++++++++++++
 arch/arm/mm/dma-mapping.c          |   17 +++++++++++++++++
 include/linux/dma-mapping.h        |    2 ++
 3 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index 1cbd279..5b86600 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -170,6 +170,23 @@ static inline void dma_free_attrs(struct device *dev, size_t size,
 	ops->free(dev, size, cpu_addr, dma_handle, attrs);
 }
 
+static inline dma_addr_t dma_iova_alloc(struct device *dev, size_t size)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	BUG_ON(!ops);
+
+	return ops->iova_alloc(dev, size);
+}
+
+static inline void dma_iova_free(struct device *dev, dma_addr_t addr,
+				 size_t size)
+{
+	struct dma_map_ops *ops = get_dma_ops(dev);
+	BUG_ON(!ops);
+
+	ops->iova_free(dev, addr, size);
+}
+
 static inline size_t dma_iova_get_free_total(struct device *dev)
 {
 	struct dma_map_ops *ops = get_dma_ops(dev);
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index db17338..c18522a 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1080,6 +1080,13 @@ static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
 	return mapping->base + (start << (mapping->order + PAGE_SHIFT));
 }
 
+static dma_addr_t arm_iommu_iova_alloc(struct device *dev, size_t size)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+
+	return __alloc_iova(mapping, size);
+}
+
 static inline void __free_iova(struct dma_iommu_mapping *mapping,
 			       dma_addr_t addr, size_t size)
 {
@@ -1094,6 +1101,14 @@ static inline void __free_iova(struct dma_iommu_mapping *mapping,
 	spin_unlock_irqrestore(&mapping->lock, flags);
 }
 
+static void arm_iommu_iova_free(struct device *dev, dma_addr_t addr,
+				size_t size)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+
+	__free_iova(mapping, addr, size);
+}
+
 static struct page **__iommu_alloc_buffer(struct device *dev, size_t size, gfp_t gfp)
 {
 	struct page **pages;
@@ -1773,6 +1788,8 @@ struct dma_map_ops iommu_ops = {
 	.sync_sg_for_cpu	= arm_iommu_sync_sg_for_cpu,
 	.sync_sg_for_device	= arm_iommu_sync_sg_for_device,
 
+	.iova_alloc		= arm_iommu_iova_alloc,
+	.iova_free		= arm_iommu_iova_free,
 	.iova_get_free_total	= arm_iommu_iova_get_free_total,
 	.iova_get_free_max	= arm_iommu_iova_get_free_max,
 };
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 0337182..e85aa04 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -53,6 +53,8 @@ struct dma_map_ops {
 #ifdef ARCH_HAS_DMA_GET_REQUIRED_MASK
 	u64 (*get_required_mask)(struct device *dev);
 #endif
+	dma_addr_t (*iova_alloc)(struct device *dev, size_t size);
+	void (*iova_free)(struct device *dev, dma_addr_t addr, size_t size);
 	size_t (*iova_get_free_total)(struct device *dev);
 	size_t (*iova_get_free_max)(struct device *dev);
 
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
