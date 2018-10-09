Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB6C66B028C
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:26:24 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f4-v6so1102505pff.2
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:26:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f94-v6si24786490plb.10.2018.10.09.06.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:26:23 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 25/33] cxl: drop the dma_set_mask callback from vphb
Date: Tue,  9 Oct 2018 15:24:52 +0200
Message-Id: <20181009132500.17643-26-hch@lst.de>
In-Reply-To: <20181009132500.17643-1-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The CXL code never even looks at the dma mask, so there is no good
reason for this sanity check.  Remove it because it gets in the way
of the dma ops refactoring.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/misc/cxl/vphb.c | 12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/misc/cxl/vphb.c b/drivers/misc/cxl/vphb.c
index 7908633d9204..49da2f744bbf 100644
--- a/drivers/misc/cxl/vphb.c
+++ b/drivers/misc/cxl/vphb.c
@@ -11,17 +11,6 @@
 #include <misc/cxl.h>
 #include "cxl.h"
 
-static int cxl_dma_set_mask(struct pci_dev *pdev, u64 dma_mask)
-{
-	if (dma_mask < DMA_BIT_MASK(64)) {
-		pr_info("%s only 64bit DMA supported on CXL", __func__);
-		return -EIO;
-	}
-
-	*(pdev->dev.dma_mask) = dma_mask;
-	return 0;
-}
-
 static int cxl_pci_probe_mode(struct pci_bus *bus)
 {
 	return PCI_PROBE_NORMAL;
@@ -220,7 +209,6 @@ static struct pci_controller_ops cxl_pci_controller_ops =
 	.reset_secondary_bus = cxl_pci_reset_secondary_bus,
 	.setup_msi_irqs = cxl_setup_msi_irqs,
 	.teardown_msi_irqs = cxl_teardown_msi_irqs,
-	.dma_set_mask = cxl_dma_set_mask,
 };
 
 int cxl_pci_vphb_add(struct cxl_afu *afu)
-- 
2.19.0
