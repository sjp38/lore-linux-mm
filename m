Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B37DF6B02C2
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 08:20:28 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id m2-v6so10044473plt.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 05:20:28 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id v32-v6si14741886plb.273.2018.07.09.05.20.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 05:20:27 -0700 (PDT)
Received: from eucas1p2.samsung.com (unknown [182.198.249.207])
	by mailout1.w1.samsung.com (KnoxPortal) with ESMTP id 20180709122021euoutp0149d550c9eb9d7000303158dd48041a11~-sqVloVWF1579615796euoutp01D
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 12:20:21 +0000 (GMT)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 2/2] dma: remove unsupported gfp_mask parameter from
 dma_alloc_from_contiguous()
Date: Mon,  9 Jul 2018 14:19:56 +0200
In-Reply-To: <20180709121956.20200-1-m.szyprowski@samsung.com>
Message-Id: <20180709122020eucas1p21a71b092975cb4a3b9954ffc63f699d1~-sqUFoa-h2939329393eucas1p2Y@eucas1p2.samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <20180709121956.20200-1-m.szyprowski@samsung.com>
	<CGME20180709122020eucas1p21a71b092975cb4a3b9954ffc63f699d1@eucas1p2.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Mackerras <paulus@ozlabs.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Chris Zankel <chris@zankel.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Joerg Roedel <joro@8bytes.org>, Sumit Semwal <sumit.semwal@linaro.org>, Robin Murphy <robin.murphy@arm.com>, Laura Abbott <labbott@redhat.com>, linaro-mm-sig@lists.linaro.org

The CMA memory allocator doesn't support standard gfp flags for memory
allocation, so there is no point having it as a parameter for
dma_alloc_from_contiguous() function. Replace it by a boolean no_warn
argument, which covers all the underlaying cma_alloc() function supports.

This will help to avoid giving false feeling that this function supports
standard gfp flags and callers can pass __GFP_ZERO to get zeroed buffer,
what has already been an issue: see commit dd65a941f6ba ("arm64:
dma-mapping: clear buffers allocated with FORCE_CONTIGUOUS flag").

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 arch/arm/mm/dma-mapping.c      | 5 +++--
 arch/arm64/mm/dma-mapping.c    | 4 ++--
 arch/xtensa/kernel/pci-dma.c   | 2 +-
 drivers/iommu/amd_iommu.c      | 2 +-
 drivers/iommu/intel-iommu.c    | 3 ++-
 include/linux/dma-contiguous.h | 4 ++--
 kernel/dma/contiguous.c        | 7 +++----
 kernel/dma/direct.c            | 3 ++-
 8 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index be0fa7e39c26..121c6c3ba9e0 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -594,7 +594,7 @@ static void *__alloc_from_contiguous(struct device *dev, size_t size,
 	struct page *page;
 	void *ptr = NULL;
 
-	page = dma_alloc_from_contiguous(dev, count, order, gfp);
+	page = dma_alloc_from_contiguous(dev, count, order, gfp & __GFP_NOWARN);
 	if (!page)
 		return NULL;
 
@@ -1294,7 +1294,8 @@ static struct page **__iommu_alloc_buffer(struct device *dev, size_t size,
 		unsigned long order = get_order(size);
 		struct page *page;
 
-		page = dma_alloc_from_contiguous(dev, count, order, gfp);
+		page = dma_alloc_from_contiguous(dev, count, order,
+						 gfp & __GFP_NOWARN);
 		if (!page)
 			goto error;
 
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index 61e93f0b5482..072c51fb07d7 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -355,7 +355,7 @@ static int __init atomic_pool_init(void)
 
 	if (dev_get_cma_area(NULL))
 		page = dma_alloc_from_contiguous(NULL, nr_pages,
-						 pool_size_order, GFP_KERNEL);
+						 pool_size_order, false);
 	else
 		page = alloc_pages(GFP_DMA32, pool_size_order);
 
@@ -573,7 +573,7 @@ static void *__iommu_alloc_attrs(struct device *dev, size_t size,
 		struct page *page;
 
 		page = dma_alloc_from_contiguous(dev, size >> PAGE_SHIFT,
-						 get_order(size), gfp);
+					get_order(size), gfp & __GFP_NOWARN);
 		if (!page)
 			return NULL;
 
diff --git a/arch/xtensa/kernel/pci-dma.c b/arch/xtensa/kernel/pci-dma.c
index ba4640cc0093..b2c7ba91fb08 100644
--- a/arch/xtensa/kernel/pci-dma.c
+++ b/arch/xtensa/kernel/pci-dma.c
@@ -137,7 +137,7 @@ static void *xtensa_dma_alloc(struct device *dev, size_t size,
 
 	if (gfpflags_allow_blocking(flag))
 		page = dma_alloc_from_contiguous(dev, count, get_order(size),
-						 flag);
+						 flag & __GFP_NOWARN);
 
 	if (!page)
 		page = alloc_pages(flag, get_order(size));
diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index 64cfe854e0f5..5ec97ffb561a 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -2622,7 +2622,7 @@ static void *alloc_coherent(struct device *dev, size_t size,
 			return NULL;
 
 		page = dma_alloc_from_contiguous(dev, size >> PAGE_SHIFT,
-						 get_order(size), flag);
+					get_order(size), flag & __GFP_NOWARN);
 		if (!page)
 			return NULL;
 	}
diff --git a/drivers/iommu/intel-iommu.c b/drivers/iommu/intel-iommu.c
index 869321c594e2..dd2d343428ab 100644
--- a/drivers/iommu/intel-iommu.c
+++ b/drivers/iommu/intel-iommu.c
@@ -3746,7 +3746,8 @@ static void *intel_alloc_coherent(struct device *dev, size_t size,
 	if (gfpflags_allow_blocking(flags)) {
 		unsigned int count = size >> PAGE_SHIFT;
 
-		page = dma_alloc_from_contiguous(dev, count, order, flags);
+		page = dma_alloc_from_contiguous(dev, count, order,
+						 flags & __GFP_NOWARN);
 		if (page && iommu_no_mapping(dev) &&
 		    page_to_phys(page) + size > dev->coherent_dma_mask) {
 			dma_release_from_contiguous(dev, page, count);
diff --git a/include/linux/dma-contiguous.h b/include/linux/dma-contiguous.h
index 3c5a4cb3eb95..f247e8aa5e3d 100644
--- a/include/linux/dma-contiguous.h
+++ b/include/linux/dma-contiguous.h
@@ -112,7 +112,7 @@ static inline int dma_declare_contiguous(struct device *dev, phys_addr_t size,
 }
 
 struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
-				       unsigned int order, gfp_t gfp_mask);
+				       unsigned int order, bool no_warn);
 bool dma_release_from_contiguous(struct device *dev, struct page *pages,
 				 int count);
 
@@ -145,7 +145,7 @@ int dma_declare_contiguous(struct device *dev, phys_addr_t size,
 
 static inline
 struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
-				       unsigned int order, gfp_t gfp_mask)
+				       unsigned int order, bool no_warn)
 {
 	return NULL;
 }
diff --git a/kernel/dma/contiguous.c b/kernel/dma/contiguous.c
index 19ea5d70150c..286d82329eb0 100644
--- a/kernel/dma/contiguous.c
+++ b/kernel/dma/contiguous.c
@@ -178,7 +178,7 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
  * @dev:   Pointer to device for which the allocation is performed.
  * @count: Requested number of pages.
  * @align: Requested alignment of pages (in PAGE_SIZE order).
- * @gfp_mask: GFP flags to use for this allocation.
+ * @no_warn: Avoid printing message about failed allocation.
  *
  * This function allocates memory buffer for specified device. It uses
  * device specific contiguous memory area if available or the default
@@ -186,13 +186,12 @@ int __init dma_contiguous_reserve_area(phys_addr_t size, phys_addr_t base,
  * function.
  */
 struct page *dma_alloc_from_contiguous(struct device *dev, size_t count,
-				       unsigned int align, gfp_t gfp_mask)
+				       unsigned int align, bool no_warn)
 {
 	if (align > CONFIG_CMA_ALIGNMENT)
 		align = CONFIG_CMA_ALIGNMENT;
 
-	return cma_alloc(dev_get_cma_area(dev), count, align,
-			 gfp_mask & __GFP_NOWARN);
+	return cma_alloc(dev_get_cma_area(dev), count, align, no_warn);
 }
 
 /**
diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
index 8be8106270c2..e0241beeb645 100644
--- a/kernel/dma/direct.c
+++ b/kernel/dma/direct.c
@@ -78,7 +78,8 @@ void *dma_direct_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
 again:
 	/* CMA can be used only in the context which permits sleeping */
 	if (gfpflags_allow_blocking(gfp)) {
-		page = dma_alloc_from_contiguous(dev, count, page_order, gfp);
+		page = dma_alloc_from_contiguous(dev, count, page_order,
+						 gfp & __GFP_NOWARN);
 		if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
 			dma_release_from_contiguous(dev, page, count);
 			page = NULL;
-- 
2.17.1
