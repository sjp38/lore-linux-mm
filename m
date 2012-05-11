Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 72EC68D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 04:33:45 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M3U000EENR1R630@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 11 May 2012 09:33:01 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M3U008GWNS7BE@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 11 May 2012 09:33:43 +0100 (BST)
Date: Fri, 11 May 2012 10:33:36 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] ARM: dma-mapping: fix build break on no-MMU systems
In-reply-to: <1334756652-30830-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1336725216-24434-1-git-send-email-m.szyprowski@samsung.com>
References: <1334756652-30830-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>, Paul Gortmaker <paul.gortmaker@windriver.com>

Fix the following build issue:

arch/arm/mm/dma-mapping.c:726:42: error: 'pgprot_kernel' undeclared
(first use in this function)
make[2]: *** [arch/arm/mm/dma-mapping.o] Error 1

Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 arch/arm/mm/dma-mapping.c |   17 +++++++++--------
 1 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 2d11aa0..686ef02 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -428,10 +428,19 @@ static void __dma_free_remap(void *cpu_addr, size_t size)
 	arm_vmregion_free(&consistent_head, c);
 }
 
+static inline pgprot_t __get_dma_pgprot(struct dma_attrs *attrs, pgprot_t prot)
+{
+	prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
+			    pgprot_writecombine(prot) :
+			    pgprot_dmacoherent(prot);
+	return prot;
+}
+
 #else	/* !CONFIG_MMU */
 
 #define __dma_alloc_remap(page, size, gfp, prot, c)	page_address(page)
 #define __dma_free_remap(addr, size)			do { } while (0)
+#define __get_dma_pgprot(attrs, prot)	__pgprot(0)
 
 #endif	/* CONFIG_MMU */
 
@@ -471,14 +480,6 @@ __dma_alloc(struct device *dev, size_t size, dma_addr_t *handle, gfp_t gfp,
 	return addr;
 }
 
-static inline pgprot_t __get_dma_pgprot(struct dma_attrs *attrs, pgprot_t prot)
-{
-	prot = dma_get_attr(DMA_ATTR_WRITE_COMBINE, attrs) ?
-			    pgprot_writecombine(prot) :
-			    pgprot_dmacoherent(prot);
-	return prot;
-}
-
 /*
  * Allocate DMA-coherent memory space and return both the kernel remapped
  * virtual and bus address for that space.
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
