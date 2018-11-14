Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C413B6B0275
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:23:59 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id w7-v6so11548631plp.9
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:23:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n15-v6si23229396pgc.143.2018.11.14.00.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:23:58 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 11/34] powerpc/pseries: use the generic iommu bypass code
Date: Wed, 14 Nov 2018 09:22:51 +0100
Message-Id: <20181114082314.8965-12-hch@lst.de>
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
 arch/powerpc/platforms/pseries/iommu.c | 100 +++++++------------------
 1 file changed, 27 insertions(+), 73 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/iommu.c b/arch/powerpc/platforms/pseries/iommu.c
index da5716de7f4c..8965d174c53b 100644
--- a/arch/powerpc/platforms/pseries/iommu.c
+++ b/arch/powerpc/platforms/pseries/iommu.c
@@ -973,7 +973,7 @@ static LIST_HEAD(failed_ddw_pdn_list);
  * pdn: the parent pe node with the ibm,dma_window property
  * Future: also check if we can remap the base window for our base page size
  *
- * returns the dma offset for use by dma_set_mask
+ * returns the dma offset for use by the direct mapped DMA code.
  */
 static u64 enable_ddw(struct pci_dev *dev, struct device_node *pdn)
 {
@@ -1193,87 +1193,40 @@ static void pci_dma_dev_setup_pSeriesLP(struct pci_dev *dev)
 	iommu_add_device(&dev->dev);
 }
 
-static int dma_set_mask_pSeriesLP(struct device *dev, u64 dma_mask)
+static bool iommu_bypass_supported_pSeriesLP(struct pci_dev *pdev, u64 dma_mask)
 {
-	bool ddw_enabled = false;
-	struct device_node *pdn, *dn;
-	struct pci_dev *pdev;
+	struct device_node *dn = pci_device_to_OF_node(pdev), *pdn;
 	const __be32 *dma_window = NULL;
 	u64 dma_offset;
 
-	if (!dev->dma_mask)
-		return -EIO;
-
-	if (!dev_is_pci(dev))
-		goto check_mask;
-
-	pdev = to_pci_dev(dev);
-
 	/* only attempt to use a new window if 64-bit DMA is requested */
-	if (!disable_ddw && dma_mask == DMA_BIT_MASK(64)) {
-		dn = pci_device_to_OF_node(pdev);
-		dev_dbg(dev, "node is %pOF\n", dn);
+	if (dma_mask < DMA_BIT_MASK(64))
+		return false;
 
-		/*
-		 * the device tree might contain the dma-window properties
-		 * per-device and not necessarily for the bus. So we need to
-		 * search upwards in the tree until we either hit a dma-window
-		 * property, OR find a parent with a table already allocated.
-		 */
-		for (pdn = dn; pdn && PCI_DN(pdn) && !PCI_DN(pdn)->table_group;
-				pdn = pdn->parent) {
-			dma_window = of_get_property(pdn, "ibm,dma-window", NULL);
-			if (dma_window)
-				break;
-		}
-		if (pdn && PCI_DN(pdn)) {
-			dma_offset = enable_ddw(pdev, pdn);
-			if (dma_offset != 0) {
-				dev_info(dev, "Using 64-bit direct DMA at offset %llx\n", dma_offset);
-				set_dma_offset(dev, dma_offset);
-				set_dma_ops(dev, &dma_nommu_ops);
-				ddw_enabled = true;
-			}
-		}
-	}
+	dev_dbg(&pdev->dev, "node is %pOF\n", dn);
 
-	/* fall back on iommu ops */
-	if (!ddw_enabled && get_dma_ops(dev) != &dma_iommu_ops) {
-		dev_info(dev, "Restoring 32-bit DMA via iommu\n");
-		set_dma_ops(dev, &dma_iommu_ops);
+	/*
+	 * the device tree might contain the dma-window properties
+	 * per-device and not necessarily for the bus. So we need to
+	 * search upwards in the tree until we either hit a dma-window
+	 * property, OR find a parent with a table already allocated.
+	 */
+	for (pdn = dn; pdn && PCI_DN(pdn) && !PCI_DN(pdn)->table_group;
+			pdn = pdn->parent) {
+		dma_window = of_get_property(pdn, "ibm,dma-window", NULL);
+		if (dma_window)
+			break;
 	}
 
-check_mask:
-	if (!dma_supported(dev, dma_mask))
-		return -EIO;
-
-	*dev->dma_mask = dma_mask;
-	return 0;
-}
-
-static u64 dma_get_required_mask_pSeriesLP(struct device *dev)
-{
-	if (!dev->dma_mask)
-		return 0;
-
-	if (!disable_ddw && dev_is_pci(dev)) {
-		struct pci_dev *pdev = to_pci_dev(dev);
-		struct device_node *dn;
-
-		dn = pci_device_to_OF_node(pdev);
-
-		/* search upwards for ibm,dma-window */
-		for (; dn && PCI_DN(dn) && !PCI_DN(dn)->table_group;
-				dn = dn->parent)
-			if (of_get_property(dn, "ibm,dma-window", NULL))
-				break;
-		/* if there is a ibm,ddw-applicable property require 64 bits */
-		if (dn && PCI_DN(dn) &&
-				of_get_property(dn, "ibm,ddw-applicable", NULL))
-			return DMA_BIT_MASK(64);
+	if (pdn && PCI_DN(pdn)) {
+		dma_offset = enable_ddw(pdev, pdn);
+		if (dma_offset != 0) {
+			set_dma_offset(&pdev->dev, dma_offset);
+			return true;
+		}
 	}
 
-	return dma_iommu_get_required_mask(dev);
+	return false;
 }
 
 static int iommu_mem_notifier(struct notifier_block *nb, unsigned long action,
@@ -1368,8 +1321,9 @@ void iommu_init_early_pSeries(void)
 	if (firmware_has_feature(FW_FEATURE_LPAR)) {
 		pseries_pci_controller_ops.dma_bus_setup = pci_dma_bus_setup_pSeriesLP;
 		pseries_pci_controller_ops.dma_dev_setup = pci_dma_dev_setup_pSeriesLP;
-		ppc_md.dma_set_mask = dma_set_mask_pSeriesLP;
-		ppc_md.dma_get_required_mask = dma_get_required_mask_pSeriesLP;
+		if (!disable_ddw)
+			pseries_pci_controller_ops.iommu_bypass_supported =
+				iommu_bypass_supported_pSeriesLP;
 	} else {
 		pseries_pci_controller_ops.dma_bus_setup = pci_dma_bus_setup_pSeries;
 		pseries_pci_controller_ops.dma_dev_setup = pci_dma_dev_setup_pSeries;
-- 
2.19.1
