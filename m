Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id F26CB6B00E9
	for <linux-mm@kvack.org>; Thu, 17 May 2012 09:16:03 -0400 (EDT)
Received: from euspt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0M4600JRO4R3FV@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Thu, 17 May 2012 14:13:51 +0100 (BST)
Received: from ubuntu.arm.acom ([106.210.236.191])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M46005864TPC2@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 17 May 2012 14:16:00 +0100 (BST)
Date: Thu, 17 May 2012 15:13:54 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv10 04/11] ARM: dma-mapping: introduce DMA_ERROR_CODE constant
In-reply-to: <1337260441-8121-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1337260441-8121-5-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1337260441-8121-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

Replace all uses of ~0 with DMA_ERROR_CODE, what should make the code
easier to read.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
Tested-By: Subash Patel <subash.ramaswamy@linaro.org>
---
 arch/arm/common/dmabounce.c        |    6 +++---
 arch/arm/include/asm/dma-mapping.h |    4 +++-
 arch/arm/mm/dma-mapping.c          |    2 +-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.c
index 595ecd29..210ad1b 100644
--- a/arch/arm/common/dmabounce.c
+++ b/arch/arm/common/dmabounce.c
@@ -254,7 +254,7 @@ static inline dma_addr_t map_single(struct device *dev, void *ptr, size_t size,
 	if (buf == NULL) {
 		dev_err(dev, "%s: unable to map unsafe buffer %p!\n",
 		       __func__, ptr);
-		return ~0;
+		return DMA_ERROR_CODE;
 	}
 
 	dev_dbg(dev, "%s: unsafe buffer %p (dma=%#x) mapped to %p (dma=%#x)\n",
@@ -320,7 +320,7 @@ dma_addr_t __dma_map_page(struct device *dev, struct page *page,
 
 	ret = needs_bounce(dev, dma_addr, size);
 	if (ret < 0)
-		return ~0;
+		return DMA_ERROR_CODE;
 
 	if (ret == 0) {
 		__dma_page_cpu_to_dev(page, offset, size, dir);
@@ -329,7 +329,7 @@ dma_addr_t __dma_map_page(struct device *dev, struct page *page,
 
 	if (PageHighMem(page)) {
 		dev_err(dev, "DMA buffer bouncing of HIGHMEM pages is not supported\n");
-		return ~0;
+		return DMA_ERROR_CODE;
 	}
 
 	return map_single(dev, page_address(page) + offset, size, dir);
diff --git a/arch/arm/include/asm/dma-mapping.h b/arch/arm/include/asm/dma-mapping.h
index cb3b7c9..6a838da 100644
--- a/arch/arm/include/asm/dma-mapping.h
+++ b/arch/arm/include/asm/dma-mapping.h
@@ -10,6 +10,8 @@
 #include <asm-generic/dma-coherent.h>
 #include <asm/memory.h>
 
+#define DMA_ERROR_CODE	(~0)
+
 #ifdef __arch_page_to_dma
 #error Please update to __arch_pfn_to_dma
 #endif
@@ -123,7 +125,7 @@ extern int dma_set_mask(struct device *, u64);
  */
 static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 {
-	return dma_addr == ~0;
+	return dma_addr == DMA_ERROR_CODE;
 }
 
 /*
diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 322c70a..e4ac5fc 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -342,7 +342,7 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp,
 	 */
 	gfp &= ~(__GFP_COMP);
 
-	*handle = ~0;
+	*handle = DMA_ERROR_CODE;
 	size = PAGE_ALIGN(size);
 
 	page = __dma_alloc_buffer(dev, size, gfp);
-- 
1.7.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
