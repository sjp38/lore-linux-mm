Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 514A16B029C
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:24:58 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id j9-v6so12635821pfn.20
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:24:58 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 185-v6si18603449pff.77.2018.11.14.00.24.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:24:57 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 28/34] dma-mapping, powerpc: simplify the arch dma_set_mask override
Date: Wed, 14 Nov 2018 09:23:08 +0100
Message-Id: <20181114082314.8965-29-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Instead of letting the architecture supply all of dma_set_mask just
give it an additional hook selected by Kconfig.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/Kconfig                   |  1 +
 arch/powerpc/include/asm/dma-mapping.h |  3 ---
 arch/powerpc/kernel/dma-swiotlb.c      |  8 ++++++++
 arch/powerpc/kernel/dma.c              | 12 ------------
 arch/powerpc/sysdev/fsl_pci.c          |  4 ----
 include/linux/dma-mapping.h            | 11 ++++++++---
 kernel/dma/Kconfig                     |  3 +++
 7 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 2d4a19bc8023..4f03997ad54a 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -126,6 +126,7 @@ config PPC
 	# Please keep this list sorted alphabetically.
 	#
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
+	select ARCH_HAS_DMA_SET_MASK		if SWIOTLB
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index e5ee4ac97c14..16d45518d9bb 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -110,8 +110,5 @@ static inline void set_dma_offset(struct device *dev, dma_addr_t off)
 		dev->archdata.dma_offset = off;
 }
 
-#define HAVE_ARCH_DMA_SET_MASK 1
-extern int dma_set_mask(struct device *dev, u64 dma_mask);
-
 #endif /* __KERNEL__ */
 #endif	/* _ASM_DMA_MAPPING_H */
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index 62caa16b91a9..b3266f7a6915 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -22,6 +22,14 @@
 #include <asm/swiotlb.h>
 #include <asm/dma.h>
 
+bool arch_dma_set_mask(struct device *dev, u64 dma_mask)
+{
+	if (!ppc_md.dma_set_mask)
+		return 0;
+	return ppc_md.dma_set_mask(dev, dma_mask);
+}
+EXPORT_SYMBOL(arch_dma_set_mask);
+
 unsigned int ppc_swiotlb_enable;
 
 /*
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index 59f38ca3975c..cf0ae0b3fb24 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -209,18 +209,6 @@ const struct dma_map_ops dma_nommu_ops = {
 };
 EXPORT_SYMBOL(dma_nommu_ops);
 
-int dma_set_mask(struct device *dev, u64 dma_mask)
-{
-	if (ppc_md.dma_set_mask)
-		return ppc_md.dma_set_mask(dev, dma_mask);
-
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
-	*dev->dma_mask = dma_mask;
-	return 0;
-}
-EXPORT_SYMBOL(dma_set_mask);
-
 static int __init dma_init(void)
 {
 #ifdef CONFIG_IBMVIO
diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index 296ffabc9386..cb91a3d113d1 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -135,9 +135,6 @@ static inline void setup_swiotlb_ops(struct pci_controller *hose) {}
 
 static int fsl_pci_dma_set_mask(struct device *dev, u64 dma_mask)
 {
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
-
 	/*
 	 * Fix up PCI devices that are able to DMA to the large inbound
 	 * mapping that allows addressing any RAM address from across PCI.
@@ -147,7 +144,6 @@ static int fsl_pci_dma_set_mask(struct device *dev, u64 dma_mask)
 		set_dma_offset(dev, pci64_dma_offset);
 	}
 
-	*dev->dma_mask = dma_mask;
 	return 0;
 }
 
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 15bd41447025..8dd19e66c0e5 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -598,18 +598,23 @@ static inline int dma_supported(struct device *dev, u64 mask)
 	return ops->dma_supported(dev, mask);
 }
 
-#ifndef HAVE_ARCH_DMA_SET_MASK
+#ifdef CONFIG_ARCH_HAS_DMA_SET_MASK
+bool arch_dma_set_mask(struct device *dev, u64 mask);
+#else
+#define arch_dma_set_mask(dev, mask)		true
+#endif
+
 static inline int dma_set_mask(struct device *dev, u64 mask)
 {
 	if (!dev->dma_mask || !dma_supported(dev, mask))
 		return -EIO;
-
+	if (!arch_dma_set_mask(dev, mask))
+		return -EIO;
 	dma_check_mask(dev, mask);
 
 	*dev->dma_mask = mask;
 	return 0;
 }
-#endif
 
 static inline u64 dma_get_mask(struct device *dev)
 {
diff --git a/kernel/dma/Kconfig b/kernel/dma/Kconfig
index 645c7a2ecde8..951045c90c2c 100644
--- a/kernel/dma/Kconfig
+++ b/kernel/dma/Kconfig
@@ -16,6 +16,9 @@ config ARCH_DMA_ADDR_T_64BIT
 config ARCH_HAS_DMA_COHERENCE_H
 	bool
 
+config ARCH_HAS_DMA_SET_MASK
+	bool
+
 config HAVE_GENERIC_DMA_COHERENT
 	bool
 
-- 
2.19.1
