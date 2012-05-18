Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 8199E6B0083
	for <linux-mm@kvack.org>; Fri, 18 May 2012 02:10:50 -0400 (EDT)
From: Hiroshi DOYU <hdoyu@nvidia.com>
Subject: [RFC 1/2] dma-mapping: Export arm_iommu_{alloc,free}_iova() functions
Date: Fri, 18 May 2012 09:10:26 +0300
Message-ID: <1337321427-27748-2-git-send-email-hdoyu@nvidia.com>
In-Reply-To: <1337321427-27748-1-git-send-email-hdoyu@nvidia.com>
References: <1337321427-27748-1-git-send-email-hdoyu@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hdoyu@nvidia.com, m.szyprowski@samsung.com, linaro-mm-sig@lists.linaro.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, iommu@lists.linux-foundation.org, linux-tegra@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Kyungmin Park <kyungmin.park@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org

Export __{alloc,free}_iova() as arm_iommu_{alloc,free}_iova().

There are some cases that IOVA allocation and mapping have to be done
seperately, especially for perf optimization reasons. This patch
allows client modules to {alloc,free} IOVA space by themselves without
backing up actual pages for that area.

Signed-off-by: Hiroshi DOYU <hdoyu@nvidia.com>
---
 arch/arm/include/asm/dma-iommu.h |    4 ++++
 arch/arm/mm/dma-mapping.c        |   31 +++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/arch/arm/include/asm/dma-iommu.h b/arch/arm/include/asm/dma-iommu.h
index 799b094..2595928 100644
--- a/arch/arm/include/asm/dma-iommu.h
+++ b/arch/arm/include/asm/dma-iommu.h
@@ -30,5 +30,9 @@ void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping);
 int arm_iommu_attach_device(struct device *dev,
 					struct dma_iommu_mapping *mapping);
 
+dma_addr_t arm_iommu_alloc_iova(struct device *dev, size_t size);
+
+void arm_iommu_free_iova(struct device *dev, dma_addr_t addr, size_t size);
+
 #endif /* __KERNEL__ */
 #endif
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index afb5e7a..bca1715 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1041,6 +1041,21 @@ static inline dma_addr_t __alloc_iova(struct dma_iommu_mapping *mapping,
 	return mapping->base + (start << (mapping->order + PAGE_SHIFT));
 }
 
+/**
+ * arm_iommu_alloc_iova
+ * @dev: valid struct device pointer
+ * @size: size of buffer to allocate
+ *
+ * Allocate IOVA address range
+ */
+dma_addr_t arm_iommu_alloc_iova(struct device *dev, size_t size)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+
+	return __alloc_iova(mapping, size);
+}
+EXPORT_SYMBOL_GPL(arm_iommu_alloc_iova);
+
 static inline void __free_iova(struct dma_iommu_mapping *mapping,
 			       dma_addr_t addr, size_t size)
 {
@@ -1055,6 +1070,22 @@ static inline void __free_iova(struct dma_iommu_mapping *mapping,
 	spin_unlock_irqrestore(&mapping->lock, flags);
 }
 
+/**
+ * arm_iommu_free_iova
+ * @dev: valid struct device pointer
+ * @iova: iova address being free'ed
+ * @size: size of buffer to allocate
+ *
+ * Free IOVA address range
+ */
+void arm_iommu_free_iova(struct device *dev, dma_addr_t addr, size_t size)
+{
+	struct dma_iommu_mapping *mapping = dev->archdata.mapping;
+
+	__free_iova(mapping, addr, size);
+}
+EXPORT_SYMBOL_GPL(arm_iommu_free_iova);
+
 static struct page **__iommu_alloc_buffer(struct device *dev, size_t size, gfp_t gfp)
 {
 	struct page **pages;
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
