Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 897336B02A0
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:24:59 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r16so10118438pgr.15
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:24:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a61-v6si26097445pla.430.2018.11.14.00.24.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:24:58 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 34/34] powerpc/dma: trim the fat from <asm/dma-mapping.h>
Date: Wed, 14 Nov 2018 09:23:14 +0100
Message-Id: <20181114082314.8965-35-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
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
 arch/powerpc/include/asm/dma-mapping.h        | 29 -------------------
 arch/powerpc/include/asm/iommu.h              | 10 +++++++
 arch/powerpc/platforms/44x/ppc476.c           |  1 +
 arch/powerpc/platforms/85xx/corenet_generic.c |  1 +
 arch/powerpc/platforms/85xx/qemu_e500.c       |  1 +
 arch/powerpc/sysdev/fsl_pci.c                 |  1 +
 6 files changed, 14 insertions(+), 29 deletions(-)

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
index 5128aac8e165..46a8d4716d90 100644
--- a/arch/powerpc/include/asm/iommu.h
+++ b/arch/powerpc/include/asm/iommu.h
@@ -332,5 +332,15 @@ extern bool iommu_fixed_is_weak;
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
diff --git a/arch/powerpc/platforms/85xx/corenet_generic.c b/arch/powerpc/platforms/85xx/corenet_generic.c
index b0dac307bebf..0ea13697189e 100644
--- a/arch/powerpc/platforms/85xx/corenet_generic.c
+++ b/arch/powerpc/platforms/85xx/corenet_generic.c
@@ -27,6 +27,7 @@
 #include <asm/udbg.h>
 #include <asm/mpic.h>
 #include <asm/ehv_pic.h>
+#include <asm/swiotlb.h>
 #include <soc/fsl/qe/qe_ic.h>
 
 #include <linux/of_platform.h>
diff --git a/arch/powerpc/platforms/85xx/qemu_e500.c b/arch/powerpc/platforms/85xx/qemu_e500.c
index 27631c607f3d..c52c8f9e8385 100644
--- a/arch/powerpc/platforms/85xx/qemu_e500.c
+++ b/arch/powerpc/platforms/85xx/qemu_e500.c
@@ -22,6 +22,7 @@
 #include <asm/time.h>
 #include <asm/udbg.h>
 #include <asm/mpic.h>
+#include <asm/swiotlb.h>
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
 #include "smp.h"
diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index 964a4aede6b1..9584765dbe3b 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -40,6 +40,7 @@
 #include <asm/mpc85xx.h>
 #include <asm/disassemble.h>
 #include <asm/ppc-opcode.h>
+#include <asm/swiotlb.h>
 #include <sysdev/fsl_soc.h>
 #include <sysdev/fsl_pci.h>
 
-- 
2.19.1
