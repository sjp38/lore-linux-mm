Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 949526B0285
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:24:31 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id x23-v6so11539427pln.20
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:24:31 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p186si21702456pgp.37.2018.11.14.00.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:24:30 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 18/34] powerpc/powernv: use the generic iommu bypass code
Date: Wed, 14 Nov 2018 09:22:58 +0100
Message-Id: <20181114082314.8965-19-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Use the generic iommu bypass code instead of overriding set_dma_mask.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/platforms/powernv/pci-ioda.c | 95 ++++++-----------------
 1 file changed, 25 insertions(+), 70 deletions(-)

diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
index 1d9f446f3eff..23fd46cd2ab3 100644
--- a/arch/powerpc/platforms/powernv/pci-ioda.c
+++ b/arch/powerpc/platforms/powernv/pci-ioda.c
@@ -1814,89 +1814,45 @@ static int pnv_pci_ioda_dma_64bit_bypass(struct pnv_ioda_pe *pe)
 	return -EIO;
 }
 
-static int pnv_pci_ioda_dma_set_mask(struct pci_dev *pdev, u64 dma_mask)
+static bool pnv_pci_ioda_iommu_bypass_supported(struct pci_dev *pdev,
+		u64 dma_mask)
 {
 	struct pci_controller *hose = pci_bus_to_host(pdev->bus);
 	struct pnv_phb *phb = hose->private_data;
 	struct pci_dn *pdn = pci_get_pdn(pdev);
 	struct pnv_ioda_pe *pe;
-	uint64_t top;
-	bool bypass = false;
-	s64 rc;
 
 	if (WARN_ON(!pdn || pdn->pe_number == IODA_INVALID_PE))
 		return -ENODEV;
 
 	pe = &phb->ioda.pe_array[pdn->pe_number];
 	if (pe->tce_bypass_enabled) {
-		top = pe->tce_bypass_base + memblock_end_of_DRAM() - 1;
-		bypass = (dma_mask >= top);
+		u64 top = pe->tce_bypass_base + memblock_end_of_DRAM() - 1;
+		if (dma_mask >= top)
+			return true;
 	}
 
-	if (bypass) {
-		dev_info(&pdev->dev, "Using 64-bit DMA iommu bypass\n");
-		set_dma_ops(&pdev->dev, &dma_nommu_ops);
-	} else {
-		/*
-		 * If the device can't set the TCE bypass bit but still wants
-		 * to access 4GB or more, on PHB3 we can reconfigure TVE#0 to
-		 * bypass the 32-bit region and be usable for 64-bit DMAs.
-		 * The device needs to be able to address all of this space.
-		 */
-		if (dma_mask >> 32 &&
-		    dma_mask > (memory_hotplug_max() + (1ULL << 32)) &&
-		    /* pe->pdev should be set if it's a single device, pe->pbus if not */
-		    (pe->device_count == 1 || !pe->pbus) &&
-		    phb->model == PNV_PHB_MODEL_PHB3) {
-			/* Configure the bypass mode */
-			rc = pnv_pci_ioda_dma_64bit_bypass(pe);
-			if (rc)
-				return rc;
-			/* 4GB offset bypasses 32-bit space */
-			set_dma_offset(&pdev->dev, (1ULL << 32));
-			set_dma_ops(&pdev->dev, &dma_nommu_ops);
-		} else if (dma_mask >> 32 && dma_mask != DMA_BIT_MASK(64)) {
-			/*
-			 * Fail the request if a DMA mask between 32 and 64 bits
-			 * was requested but couldn't be fulfilled. Ideally we
-			 * would do this for 64-bits but historically we have
-			 * always fallen back to 32-bits.
-			 */
-			return -ENOMEM;
-		} else {
-			dev_info(&pdev->dev, "Using 32-bit DMA via iommu\n");
-			set_dma_ops(&pdev->dev, &dma_iommu_ops);
-		}
+	/*
+	 * If the device can't set the TCE bypass bit but still wants
+	 * to access 4GB or more, on PHB3 we can reconfigure TVE#0 to
+	 * bypass the 32-bit region and be usable for 64-bit DMAs.
+	 * The device needs to be able to address all of this space.
+	 */
+	if (dma_mask >> 32 &&
+	    dma_mask > (memory_hotplug_max() + (1ULL << 32)) &&
+	    /* pe->pdev should be set if it's a single device, pe->pbus if not */
+	    (pe->device_count == 1 || !pe->pbus) &&
+	    phb->model == PNV_PHB_MODEL_PHB3) {
+		/* Configure the bypass mode */
+		s64 rc = pnv_pci_ioda_dma_64bit_bypass(pe);
+		if (rc)
+			return rc;
+		/* 4GB offset bypasses 32-bit space */
+		set_dma_offset(&pdev->dev, (1ULL << 32));
+		return true;
 	}
-	*pdev->dev.dma_mask = dma_mask;
-
-	/* Update peer npu devices */
-	pnv_npu_try_dma_set_bypass(pdev, bypass);
-
-	return 0;
-}
-
-static u64 pnv_pci_ioda_dma_get_required_mask(struct pci_dev *pdev)
-{
-	struct pci_controller *hose = pci_bus_to_host(pdev->bus);
-	struct pnv_phb *phb = hose->private_data;
-	struct pci_dn *pdn = pci_get_pdn(pdev);
-	struct pnv_ioda_pe *pe;
-	u64 end, mask;
 
-	if (WARN_ON(!pdn || pdn->pe_number == IODA_INVALID_PE))
-		return 0;
-
-	pe = &phb->ioda.pe_array[pdn->pe_number];
-	if (!pe->tce_bypass_enabled)
-		return __dma_get_required_mask(&pdev->dev);
-
-
-	end = pe->tce_bypass_base + memblock_end_of_DRAM();
-	mask = 1ULL << (fls64(end) - 1);
-	mask += mask - 1;
-
-	return mask;
+	return false;
 }
 
 static void pnv_ioda_setup_bus_dma(struct pnv_ioda_pe *pe,
@@ -3674,6 +3630,7 @@ static void pnv_pci_ioda_shutdown(struct pci_controller *hose)
 static const struct pci_controller_ops pnv_pci_ioda_controller_ops = {
 	.dma_dev_setup		= pnv_pci_dma_dev_setup,
 	.dma_bus_setup		= pnv_pci_dma_bus_setup,
+	.iommu_bypass_supported	= pnv_pci_ioda_iommu_bypass_supported,
 #ifdef CONFIG_PCI_MSI
 	.setup_msi_irqs		= pnv_setup_msi_irqs,
 	.teardown_msi_irqs	= pnv_teardown_msi_irqs,
@@ -3683,8 +3640,6 @@ static const struct pci_controller_ops pnv_pci_ioda_controller_ops = {
 	.window_alignment	= pnv_pci_window_alignment,
 	.setup_bridge		= pnv_pci_setup_bridge,
 	.reset_secondary_bus	= pnv_pci_reset_secondary_bus,
-	.dma_set_mask		= pnv_pci_ioda_dma_set_mask,
-	.dma_get_required_mask	= pnv_pci_ioda_dma_get_required_mask,
 	.shutdown		= pnv_pci_ioda_shutdown,
 };
 
-- 
2.19.1
