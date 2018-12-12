Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC28E8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:36:06 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id e1so1872635wmg.0
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 06:36:06 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id y13si11491229wrr.124.2018.12.12.06.36.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 06:36:05 -0800 (PST)
Date: Wed, 12 Dec 2018 15:36:04 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 12/34] powerpc/cell: move dma direct window setup out
 of dma_configure
Message-ID: <20181212143604.GA5137@lst.de>
References: <20181114082314.8965-1-hch@lst.de> <20181114082314.8965-13-hch@lst.de> <871s6r3sno.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871s6r3sno.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Christoph Hellwig <hch@lst.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Dec 09, 2018 at 09:23:39PM +1100, Michael Ellerman wrote:
> Christoph Hellwig <hch@lst.de> writes:
> 
> > Configure the dma settings at device setup time, and stop playing games
> > with get_pci_dma_ops.  This prepares for using the common dma_configure
> > code later on.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  arch/powerpc/platforms/cell/iommu.c | 20 +++++++++++---------
> >  1 file changed, 11 insertions(+), 9 deletions(-)
> 
> This one's crashing, haven't dug into why yet:

Can you provide a gdb assembly of the exact crash site?  This looks
like for some odd reason the DT structures aren't fully setup by the
time we are probing the device, which seems odd.

Either way, something like the patch below would ensure we call
cell_iommu_get_fixed_address from a similar context as before, can you
check if that fixes the issue?

diff --git a/arch/powerpc/platforms/cell/iommu.c b/arch/powerpc/platforms/cell/iommu.c
index 93c7e4aef571..4891b338bf9f 100644
--- a/arch/powerpc/platforms/cell/iommu.c
+++ b/arch/powerpc/platforms/cell/iommu.c
@@ -569,19 +569,12 @@ static struct iommu_table *cell_get_iommu_table(struct device *dev)
 	return &window->table;
 }
 
-static u64 cell_iommu_get_fixed_address(struct device *dev);
-
 static void cell_dma_dev_setup(struct device *dev)
 {
-	if (cell_iommu_enabled) {
-		u64 addr = cell_iommu_get_fixed_address(dev);
-
-		if (addr != OF_BAD_ADDR)
-			set_dma_offset(dev, addr + dma_iommu_fixed_base);
+	if (cell_iommu_enabled)
 		set_iommu_table_base(dev, cell_get_iommu_table(dev));
-	} else {
+	else
 		set_dma_offset(dev, cell_dma_nommu_offset);
-	}
 }
 
 static void cell_pci_dma_dev_setup(struct pci_dev *dev)
@@ -865,8 +858,16 @@ static u64 cell_iommu_get_fixed_address(struct device *dev)
 
 static bool cell_pci_iommu_bypass_supported(struct pci_dev *pdev, u64 mask)
 {
-	return mask == DMA_BIT_MASK(64) &&
-		cell_iommu_get_fixed_address(&pdev->dev) != OF_BAD_ADDR;
+	if (mask == DMA_BIT_MASK(64)) {
+		u64 addr = cell_iommu_get_fixed_address(&pdev->dev);
+
+		if (addr != OF_BAD_ADDR) {
+			set_dma_offset(&pdev->dev, dma_iommu_fixed_base + addr);
+			return true;
+		}
+	}
+
+	return true;
 }
 
 static void insert_16M_pte(unsigned long addr, unsigned long *ptab,
