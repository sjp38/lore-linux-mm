Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 607776B027F
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:26:12 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y86-v6so1096738pff.6
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:26:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g4-v6si20769714plo.254.2018.10.09.06.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:26:11 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 14/33] powerpc/dart: use the generic iommu bypass code
Date: Tue,  9 Oct 2018 15:24:41 +0200
Message-Id: <20181009132500.17643-15-hch@lst.de>
In-Reply-To: <20181009132500.17643-1-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Use the generic iommu bypass code instead of overriding set_dma_mask.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/sysdev/dart_iommu.c | 45 +++++++++++---------------------
 1 file changed, 15 insertions(+), 30 deletions(-)

diff --git a/arch/powerpc/sysdev/dart_iommu.c b/arch/powerpc/sysdev/dart_iommu.c
index ce5dd2048f57..e7d1645a2d2e 100644
--- a/arch/powerpc/sysdev/dart_iommu.c
+++ b/arch/powerpc/sysdev/dart_iommu.c
@@ -360,13 +360,6 @@ static void iommu_table_dart_setup(void)
 	set_bit(iommu_table_dart.it_size - 1, iommu_table_dart.it_map);
 }
 
-static void pci_dma_dev_setup_dart(struct pci_dev *dev)
-{
-	if (dart_is_u4)
-		set_dma_offset(&dev->dev, DART_U4_BYPASS_BASE);
-	set_iommu_table_base(&dev->dev, &iommu_table_dart);
-}
-
 static void pci_dma_bus_setup_dart(struct pci_bus *bus)
 {
 	if (!iommu_table_dart_inited) {
@@ -390,27 +383,16 @@ static bool dart_device_on_pcie(struct device *dev)
 	return false;
 }
 
-static int dart_dma_set_mask(struct device *dev, u64 dma_mask)
+static void pci_dma_dev_setup_dart(struct pci_dev *dev)
 {
-	if (!dev->dma_mask || !dma_supported(dev, dma_mask))
-		return -EIO;
-
-	/* U4 supports a DART bypass, we use it for 64-bit capable
-	 * devices to improve performances. However, that only works
-	 * for devices connected to U4 own PCIe interface, not bridged
-	 * through hypertransport. We need the device to support at
-	 * least 40 bits of addresses.
-	 */
-	if (dart_device_on_pcie(dev) && dma_mask >= DMA_BIT_MASK(40)) {
-		dev_info(dev, "Using 64-bit DMA iommu bypass\n");
-		set_dma_ops(dev, &dma_nommu_ops);
-	} else {
-		dev_info(dev, "Using 32-bit DMA via iommu\n");
-		set_dma_ops(dev, &dma_iommu_ops);
-	}
+	if (dart_is_u4 && dart_device_on_pcie(&dev->dev))
+		set_dma_offset(&dev->dev, DART_U4_BYPASS_BASE);
+	set_iommu_table_base(&dev->dev, &iommu_table_dart);
+}
 
-	*dev->dma_mask = dma_mask;
-	return 0;
+static bool iommu_bypass_supported_dart(struct pci_dev *dev, u64 mask)
+{
+	return dart_is_u4 && dart_device_on_pcie(&dev->dev);
 }
 
 void __init iommu_init_early_dart(struct pci_controller_ops *controller_ops)
@@ -430,12 +412,15 @@ void __init iommu_init_early_dart(struct pci_controller_ops *controller_ops)
 	if (dart_init(dn) != 0)
 		return;
 
-	/* Setup bypass if supported */
-	if (dart_is_u4)
-		ppc_md.dma_set_mask = dart_dma_set_mask;
-
+	/*
+	 * U4 supports a DART bypass, we use it for 64-bit capable devices to
+	 * improve performance.  However, that only works for devices connected
+	 * to the U4 own PCIe interface, not bridged through hypertransport.
+	 * We need the device to support at least 40 bits of addresses.
+	 */
 	controller_ops->dma_dev_setup = pci_dma_dev_setup_dart;
 	controller_ops->dma_bus_setup = pci_dma_bus_setup_dart;
+	controller_ops->iommu_bypass_supported = iommu_bypass_supported_dart;
 
 	/* Setup pci_dma ops */
 	set_pci_dma_ops(&dma_iommu_ops);
-- 
2.19.0
