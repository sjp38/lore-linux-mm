Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 47C316B0294
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:26:42 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id f5-v6so975523plf.11
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:26:42 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 16-v6si27379086pfc.21.2018.10.09.06.26.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:26:41 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 26/33] powerpc/fsl_pci: simplify fsl_pci_dma_set_mask
Date: Tue,  9 Oct 2018 15:24:53 +0200
Message-Id: <20181009132500.17643-27-hch@lst.de>
In-Reply-To: <20181009132500.17643-1-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

swiotlb will only bounce buffer the effectice dma address for the device
is smaller than the actual DMA range.  Instead of flipping between the
swiotlb and nommu ops for FSL SOCs that have the second outbound window
just don't set the bus dma_mask in this case.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/sysdev/fsl_pci.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index f136567a5ed5..296ffabc9386 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -143,7 +143,7 @@ static int fsl_pci_dma_set_mask(struct device *dev, u64 dma_mask)
 	 * mapping that allows addressing any RAM address from across PCI.
 	 */
 	if (dev_is_pci(dev) && dma_mask >= pci64_dma_offset * 2 - 1) {
-		set_dma_ops(dev, &dma_nommu_ops);
+		dev->bus_dma_mask = 0;
 		set_dma_offset(dev, pci64_dma_offset);
 	}
 
@@ -403,10 +403,6 @@ static void setup_pci_atmu(struct pci_controller *hose)
 				out_be32(&pci->piw[win_idx].piwar,  piwar);
 			}
 
-			/*
-			 * install our own dma_set_mask handler to fixup dma_ops
-			 * and dma_offset
-			 */
 			ppc_md.dma_set_mask = fsl_pci_dma_set_mask;
 
 			pr_info("%pOF: Setup 64-bit PCI DMA window\n", hose->dn);
-- 
2.19.0
