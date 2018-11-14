Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2FE6B027B
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:24:16 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s71so1024860pfi.22
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:24:16 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 16-v6si9217264pfm.51.2018.11.14.00.24.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:24:15 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 12/34] powerpc/cell: move dma direct window setup out of dma_configure
Date: Wed, 14 Nov 2018 09:22:52 +0100
Message-Id: <20181114082314.8965-13-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Configure the dma settings at device setup time, and stop playing games
with get_pci_dma_ops.  This prepares for using the common dma_configure
code later on.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/platforms/cell/iommu.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 12352a58072a..cce5bf9515e5 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -657,14 +657,21 @@ static const struct dma_map_ops dma_iommu_fixed_ops = {
 	.mapping_error	= dma_iommu_mapping_error,
 };
 
+static u64 cell_iommu_get_fixed_address(struct device *dev);
+
 static void cell_dma_dev_setup(struct device *dev)
 {
-	if (get_pci_dma_ops() == &dma_iommu_ops)
+	if (get_pci_dma_ops() == &dma_iommu_ops) {
+		u64 addr = cell_iommu_get_fixed_address(dev);
+
+		if (addr != OF_BAD_ADDR)
+			set_dma_offset(dev, addr + dma_iommu_fixed_base);
 		set_iommu_table_base(dev, cell_get_iommu_table(dev));
-	else if (get_pci_dma_ops() == &dma_nommu_ops)
+	} else if (get_pci_dma_ops() == &dma_nommu_ops) {
 		set_dma_offset(dev, cell_dma_nommu_offset);
-	else
+	} else {
 		BUG();
+	}
 }
 
 static void cell_pci_dma_dev_setup(struct pci_dev *dev)
@@ -950,19 +957,14 @@ static int dma_suported_and_switch(struct device *dev, u64 dma_mask)
 {
 	if (dma_mask == DMA_BIT_MASK(64) &&
 	    cell_iommu_get_fixed_address(dev) != OF_BAD_ADDR) {
-		u64 addr = cell_iommu_get_fixed_address(dev) +
-			dma_iommu_fixed_base;
 		dev_dbg(dev, "iommu: 64-bit OK, using fixed ops\n");
-		dev_dbg(dev, "iommu: fixed addr = %llx\n", addr);
 		set_dma_ops(dev, &dma_iommu_fixed_ops);
-		set_dma_offset(dev, addr);
 		return 1;
 	}
 
 	if (dma_iommu_dma_supported(dev, dma_mask)) {
 		dev_dbg(dev, "iommu: not 64-bit, using default ops\n");
-		set_dma_ops(dev, get_pci_dma_ops());
-		cell_dma_dev_setup(dev);
+		set_dma_ops(dev, &dma_iommu_ops);
 		return 1;
 	}
 
-- 
2.19.1
