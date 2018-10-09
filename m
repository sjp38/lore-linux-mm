Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B61ED6B0299
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:26:47 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d40-v6so977251pla.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:26:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m17-v6si22581170pfe.187.2018.10.09.06.26.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:26:46 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 33/33] powerpc/dma: trim the fat from <asm/dma-mapping.h>
Date: Tue,  9 Oct 2018 15:25:00 +0200
Message-Id: <20181009132500.17643-34-hch@lst.de>
In-Reply-To: <20181009132500.17643-1-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

There is no need to provide anything but get_arch_dma_ops to
<linux/dma-mapping.h>.  More the remaining declarations to <asm/iommu.h>
and drop all the includes.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/dma-mapping.h | 29 --------------------------
 arch/powerpc/include/asm/iommu.h       | 10 +++++++++
 arch/powerpc/platforms/44x/ppc476.c    |  1 +
 3 files changed, 11 insertions(+), 29 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index a59c42879194..565d6f74b189 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -1,37 +1,9 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /*
  * Copyright (C) 2004 IBM
- *
- * Implements the generic device dma API for powerpc.
- * the pci and vio busses
  */
 #ifndef _ASM_DMA_MAPPING_H
 #define _ASM_DMA_MAPPING_H
-#ifdef __KERNEL__
-
-#include <linux/types.h>
-#include <linux/cache.h>
-/* need struct page definitions */
-#include <linux/mm.h>
-#include <linux/scatterlist.h>
-#include <linux/dma-debug.h>
-#include <asm/io.h>
-#include <asm/swiotlb.h>
-
-static inline unsigned long device_to_mask(struct device *dev)
-{
-	if (dev->dma_mask && *dev->dma_mask)
-		return *dev->dma_mask;
-	/* Assume devices without mask can take 32 bit addresses */
-	return 0xfffffffful;
-}
-
-/*
- * Available generic sets of operations
- */
-#ifdef CONFIG_PPC64
-extern const struct dma_map_ops dma_iommu_ops;
-#endif
 
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 {
@@ -43,5 +15,4 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return NULL;
 }
 
-#endif /* __KERNEL__ */
 #endif	/* _ASM_DMA_MAPPING_H */
diff --git a/arch/powerpc/include/asm/iommu.h b/arch/powerpc/include/asm/iommu.h
index 264d04f1dcd1..db745575e6a4 100644
--- a/arch/powerpc/include/asm/iommu.h
+++ b/arch/powerpc/include/asm/iommu.h
@@ -334,5 +334,15 @@ extern bool iommu_fixed_is_weak;
 #define iommu_fixed_is_weak false
 #endif
 
+extern const struct dma_map_ops dma_iommu_ops;
+
+static inline unsigned long device_to_mask(struct device *dev)
+{
+	if (dev->dma_mask && *dev->dma_mask)
+		return *dev->dma_mask;
+	/* Assume devices without mask can take 32 bit addresses */
+	return 0xfffffffful;
+}
+
 #endif /* __KERNEL__ */
 #endif /* _ASM_IOMMU_H */
diff --git a/arch/powerpc/platforms/44x/ppc476.c b/arch/powerpc/platforms/44x/ppc476.c
index e55933f9cd55..a5e61e5c16e2 100644
--- a/arch/powerpc/platforms/44x/ppc476.c
+++ b/arch/powerpc/platforms/44x/ppc476.c
@@ -34,6 +34,7 @@
 #include <asm/ppc4xx.h>
 #include <asm/mpic.h>
 #include <asm/mmu.h>
+#include <asm/swiotlb.h>
 
 #include <linux/pci.h>
 #include <linux/i2c.h>
-- 
2.19.0
