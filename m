Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 354806B028E
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:26:31 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z12-v6so1074356pfl.17
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:26:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d9-v6si10273790pgc.299.2018.10.09.06.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:26:29 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 21/33] powerpc/dma: remove get_pci_dma_ops
Date: Tue,  9 Oct 2018 15:24:48 +0200
Message-Id: <20181009132500.17643-22-hch@lst.de>
In-Reply-To: <20181009132500.17643-1-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

This function is only used by the Cell iommu code, which can keep track
if it is using the iommu internally just as good.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/pci.h      |  2 --
 arch/powerpc/kernel/pci-common.c    |  6 ------
 arch/powerpc/platforms/cell/iommu.c | 17 ++++++++---------
 3 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/arch/powerpc/include/asm/pci.h b/arch/powerpc/include/asm/pci.h
index a01d2e3d6ff9..4f7cf0a7f89d 100644
--- a/arch/powerpc/include/asm/pci.h
+++ b/arch/powerpc/include/asm/pci.h
@@ -52,10 +52,8 @@ static inline int pci_get_legacy_ide_irq(struct pci_dev *dev, int channel)
 
 #ifdef CONFIG_PCI
 extern void set_pci_dma_ops(const struct dma_map_ops *dma_ops);
-extern const struct dma_map_ops *get_pci_dma_ops(void);
 #else	/* CONFIG_PCI */
 #define set_pci_dma_ops(d)
-#define get_pci_dma_ops()	NULL
 #endif
 
 #ifdef CONFIG_PPC64
diff --git a/arch/powerpc/kernel/pci-common.c b/arch/powerpc/kernel/pci-common.c
index 88e4f69a09e5..a84707680525 100644
--- a/arch/powerpc/kernel/pci-common.c
+++ b/arch/powerpc/kernel/pci-common.c
@@ -69,12 +69,6 @@ void set_pci_dma_ops(const struct dma_map_ops *dma_ops)
 	pci_dma_ops = dma_ops;
 }
 
-const struct dma_map_ops *get_pci_dma_ops(void)
-{
-	return pci_dma_ops;
-}
-EXPORT_SYMBOL(get_pci_dma_ops);
-
 /*
  * This function should run under locking protection, specifically
  * hose_spinlock.
diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index fb51f78035ce..93c7e4aef571 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -544,6 +544,7 @@ static struct cbe_iommu *cell_iommu_for_node(int nid)
 static unsigned long cell_dma_nommu_offset;
 
 static unsigned long dma_iommu_fixed_base;
+static bool cell_iommu_enabled;
 
 /* iommu_fixed_is_weak is set if booted with iommu_fixed=weak */
 bool iommu_fixed_is_weak;
@@ -572,16 +573,14 @@ static u64 cell_iommu_get_fixed_address(struct device *dev);
 
 static void cell_dma_dev_setup(struct device *dev)
 {
-	if (get_pci_dma_ops() == &dma_iommu_ops) {
+	if (cell_iommu_enabled) {
 		u64 addr = cell_iommu_get_fixed_address(dev);
 
 		if (addr != OF_BAD_ADDR)
 			set_dma_offset(dev, addr + dma_iommu_fixed_base);
 		set_iommu_table_base(dev, cell_get_iommu_table(dev));
-	} else if (get_pci_dma_ops() == &dma_nommu_ops) {
-		set_dma_offset(dev, cell_dma_nommu_offset);
 	} else {
-		BUG();
+		set_dma_offset(dev, cell_dma_nommu_offset);
 	}
 }
 
@@ -599,11 +598,11 @@ static int cell_of_bus_notify(struct notifier_block *nb, unsigned long action,
 	if (action != BUS_NOTIFY_ADD_DEVICE)
 		return 0;
 
-	/* We use the PCI DMA ops */
-	dev->dma_ops = get_pci_dma_ops();
-
+	if (cell_iommu_enabled)
+		dev->dma_ops = &dma_iommu_ops;
+	else
+		dev->dma_ops = &dma_nommu_ops;
 	cell_dma_dev_setup(dev);
-
 	return 0;
 }
 
@@ -1091,7 +1090,7 @@ static int __init cell_iommu_init(void)
 				cell_pci_iommu_bypass_supported;
 	}
 	set_pci_dma_ops(&dma_iommu_ops);
-
+	cell_iommu_enabled = true;
  bail:
 	/* Register callbacks on OF platform device addition/removal
 	 * to handle linking them to the right DMA operations
-- 
2.19.0
