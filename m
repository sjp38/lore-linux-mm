Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id A2C506B029C
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:24:58 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id t3-v6so10135783pgp.0
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:24:58 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d23si21861755pgj.558.2018.11.14.00.24.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:24:57 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 33/34] powerpc/dma: remove set_dma_offset
Date: Wed, 14 Nov 2018 09:23:13 +0100
Message-Id: <20181114082314.8965-34-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

There is no good reason for this helper, just opencode it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/dma-mapping.h    | 6 ------
 arch/powerpc/kernel/pci-common.c          | 2 +-
 arch/powerpc/platforms/cell/iommu.c       | 4 ++--
 arch/powerpc/platforms/powernv/pci-ioda.c | 6 +++---
 arch/powerpc/platforms/pseries/iommu.c    | 7 ++-----
 arch/powerpc/sysdev/dart_iommu.c          | 2 +-
 arch/powerpc/sysdev/fsl_pci.c             | 2 +-
 drivers/misc/cxl/vphb.c                   | 2 +-
 8 files changed, 11 insertions(+), 20 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index c70f55d2f5e0..a59c42879194 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -43,11 +43,5 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return NULL;
 }
 
-static inline void set_dma_offset(struct device *dev, dma_addr_t off)
-{
-	if (dev)
-		dev->archdata.dma_offset = off;
-}
-
 #endif /* __KERNEL__ */
 #endif	/* _ASM_DMA_MAPPING_H */
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 661b937f31ed..b645b3882815 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -966,7 +966,7 @@ static void pcibios_setup_device(struct pci_dev *dev)
 
 	/* Hook up default DMA ops */
 	set_dma_ops(&dev->dev, pci_dma_ops);
-	set_dma_offset(&dev->dev, PCI_DRAM_OFFSET);
+	dev->dev.archdata.dma_offset = PCI_DRAM_OFFSET;
 
 	/* Additional platform DMA/iommu setup */
 	phb = pci_bus_to_host(dev->bus);
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 75fd2ee57e26..348a815779c1 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -577,10 +577,10 @@ static void cell_dma_dev_setup(struct device *dev)
 		u64 addr = cell_iommu_get_fixed_address(dev);
 
 		if (addr != OF_BAD_ADDR)
-			set_dma_offset(dev, addr + dma_iommu_fixed_base);
+			dev->archdata.dma_offset = addr + dma_iommu_fixed_base;
 		set_iommu_table_base(dev, cell_get_iommu_table(dev));
 	} else {
-		set_dma_offset(dev, cell_dma_nommu_offset);
+		dev->archdata.dma_offset = cell_dma_nommu_offset;
 	}
 }
 
diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
index 23fd46cd2ab3..e516d99bb2ed 100644
--- a/arch/powerpc/platforms/powernv/pci-ioda.c
+++ b/arch/powerpc/platforms/powernv/pci-ioda.c
@@ -1735,7 +1735,7 @@ static void pnv_pci_ioda_dma_dev_setup(struct pnv_phb *phb, struct pci_dev *pdev
 
 	pe = &phb->ioda.pe_array[pdn->pe_number];
 	WARN_ON(get_dma_ops(&pdev->dev) != &dma_iommu_ops);
-	set_dma_offset(&pdev->dev, pe->tce_bypass_base);
+	pdev->dev.archdata.dma_offset = pe->tce_bypass_base;
 	set_iommu_table_base(&pdev->dev, pe->table_group.tables[0]);
 	/*
 	 * Note: iommu_add_device() will fail here as
@@ -1848,7 +1848,7 @@ static bool pnv_pci_ioda_iommu_bypass_supported(struct pci_dev *pdev,
 		if (rc)
 			return rc;
 		/* 4GB offset bypasses 32-bit space */
-		set_dma_offset(&pdev->dev, (1ULL << 32));
+		pdev->dev.archdata.dma_offset = (1ULL << 32);
 		return true;
 	}
 
@@ -1863,7 +1863,7 @@ static void pnv_ioda_setup_bus_dma(struct pnv_ioda_pe *pe,
 
 	list_for_each_entry(dev, &bus->devices, bus_list) {
 		set_iommu_table_base(&dev->dev, pe->table_group.tables[0]);
-		set_dma_offset(&dev->dev, pe->tce_bypass_base);
+		dev->dev.archdata.dma_offset = pe->tce_bypass_base;
 		if (add_to_group)
 			iommu_add_device(&dev->dev);
 
diff --git a/arch/powerpc/platforms/pseries/iommu.c b/arch/powerpc/platforms/pseries/iommu.c
index 8965d174c53b..a2ff20d154fe 100644
--- a/arch/powerpc/platforms/pseries/iommu.c
+++ b/arch/powerpc/platforms/pseries/iommu.c
@@ -1197,7 +1197,6 @@ static bool iommu_bypass_supported_pSeriesLP(struct pci_dev *pdev, u64 dma_mask)
 {
 	struct device_node *dn = pci_device_to_OF_node(pdev), *pdn;
 	const __be32 *dma_window = NULL;
-	u64 dma_offset;
 
 	/* only attempt to use a new window if 64-bit DMA is requested */
 	if (dma_mask < DMA_BIT_MASK(64))
@@ -1219,11 +1218,9 @@ static bool iommu_bypass_supported_pSeriesLP(struct pci_dev *pdev, u64 dma_mask)
 	}
 
 	if (pdn && PCI_DN(pdn)) {
-		dma_offset = enable_ddw(pdev, pdn);
-		if (dma_offset != 0) {
-			set_dma_offset(&pdev->dev, dma_offset);
+		pdev->dev.archdata.dma_offset = enable_ddw(pdev, pdn);
+		if (pdev->dev.archdata.dma_offset)
 			return true;
-		}
 	}
 
 	return false;
diff --git a/arch/powerpc/sysdev/dart_iommu.c b/arch/powerpc/sysdev/dart_iommu.c
index 2681a19347ba..2e24fc87ed84 100644
--- a/arch/powerpc/sysdev/dart_iommu.c
+++ b/arch/powerpc/sysdev/dart_iommu.c
@@ -386,7 +386,7 @@ static bool dart_device_on_pcie(struct device *dev)
 static void pci_dma_dev_setup_dart(struct pci_dev *dev)
 {
 	if (dart_is_u4 && dart_device_on_pcie(&dev->dev))
-		set_dma_offset(&dev->dev, DART_U4_BYPASS_BASE);
+		dev->dev.archdata.dma_offset = DART_U4_BYPASS_BASE;
 	set_iommu_table_base(&dev->dev, &iommu_table_dart);
 }
 
diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index 081ed84c3f4c..964a4aede6b1 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -141,7 +141,7 @@ static int fsl_pci_dma_set_mask(struct device *dev, u64 dma_mask)
 	 */
 	if (dev_is_pci(dev) && dma_mask >= pci64_dma_offset * 2 - 1) {
 		dev->bus_dma_mask = 0;
-		set_dma_offset(dev, pci64_dma_offset);
+		dev->archdata.dma_offset = pci64_dma_offset;
 	}
 
 	return 0;
diff --git a/drivers/misc/cxl/vphb.c b/drivers/misc/cxl/vphb.c
index f4c0e9d2affe..f4ca1a4ada66 100644
--- a/drivers/misc/cxl/vphb.c
+++ b/drivers/misc/cxl/vphb.c
@@ -44,7 +44,7 @@ static bool cxl_pci_enable_device_hook(struct pci_dev *dev)
 	}
 
 	set_dma_ops(&dev->dev, &dma_direct_ops);
-	set_dma_offset(&dev->dev, PAGE_OFFSET);
+	dev->dev.archdata.dma_offset = PAGE_OFFSET;
 
 	/*
 	 * Allocate a context to do cxl things too.  If we eventually do real
-- 
2.19.1
