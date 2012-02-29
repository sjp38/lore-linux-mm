Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 472346B007E
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 10:04:48 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M05002JOTVWC2A0@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 29 Feb 2012 15:04:44 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M0500EHDTVW16@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 29 Feb 2012 15:04:44 +0000 (GMT)
Date: Wed, 29 Feb 2012 16:04:14 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv7 1/9] ARM: dma-mapping: introduce ARM_DMA_ERROR constant
In-reply-to: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1330527862-16234-2-git-send-email-m.szyprowski@samsung.com>
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Replace all uses of ~0 with ARM_DMA_ERROR, what should make the code
easier to read.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 arch/arm/common/dmabounce.c        |    6 +++---
 arch/arm/include/asm/dma-mapping.h |    4 +++-
 arch/arm/mm/dma-mapping.c          |    2 +-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 595ecd29..a1abdc9 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -254,7 +254,7 @@ static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
 	if (buf == NULL) {
 		dev_err(dev, "%s: unable to map unsafe buffer %p!\n",
 		       __func__, ptr);
-		return ~0;
+		return ARM_DMA_ERROR;
 	}
 
 	dev_dbg(dev, "%s: unsafe buffer %p (dma=%#x) mapped to %p (dma=%#x)\n",
@@ -320,7 +320,7 @@ dma_addr_t __dma_map_page(struct device *dev, struct page *page,
 
 	ret = needs_bounce(dev, dma_addr, size);
 	if (ret < 0)
-		return ~0;
+		return ARM_DMA_ERROR;
 
 	if (ret == 0) {
 		__dma_page_cpu_to_dev(page, offset, size, dir);
@@ -329,7 +329,7 @@ dma_addr_t __dma_map_page(struct device *dev, struct page *page,
 
 	if (PageHighMem(page)) {
 		dev_err(dev, "DMA buffer bouncing of HIGHMEM pages is not supported\n");
-		return ~0;
+		return ARM_DMA_ERROR;
 	}
 
 	return map_single(dev, page_address(page) + offset, size, dir);
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index cb3b7c9..6ba92f9 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -10,6 +10,8 @@
 #include <asm-generic/dma-coherent.h>
 #include <asm/memory.h>
 
+#define ARM_DMA_ERROR	~0
+
 #ifdef __arch_page_to_dma
 #error Please update to __arch_pfn_to_dma
 #endif
@@ -123,7 +125,7 @@ extern int dma_set_mask(struct device *, u64);
  */
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
-	return dma_addr == ~0;
+	return dma_addr == ARM_DMA_ERROR;
 }
 
 /*
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 1aa664a..496b453 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -341,7 +341,7 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp,
 	 */
 	gfp &= ~(__GFP_COMP);
 
-	*handle = ~0;
+	*handle = ARM_DMA_ERROR;
 	size = PAGE_ALIGN(size);
 
 	page = __dma_alloc_buffer(dev, size, gfp);
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
