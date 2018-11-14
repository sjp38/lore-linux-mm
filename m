Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6F96B028B
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:24:36 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id a24-v6so12593966pfn.12
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:24:36 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d16-v6si22556505pgd.555.2018.11.14.00.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:24:35 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 25/34] powerpc/dma: remove max_direct_dma_addr
Date: Wed, 14 Nov 2018 09:23:05 +0100
Message-Id: <20181114082314.8965-26-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The max_direct_dma_addr duplicates the bus_dma_mask field in struct
device.  Use the generic field instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/device.h     |  3 ---
 arch/powerpc/include/asm/dma-direct.h |  4 +---
 arch/powerpc/kernel/dma-swiotlb.c     | 20 --------------------
 arch/powerpc/kernel/dma.c             |  5 ++---
 arch/powerpc/sysdev/fsl_pci.c         |  3 +--
 5 files changed, 4 insertions(+), 31 deletions(-)

diff --git a/arch/powerpc/include/asm/device.h b/arch/powerpc/include/asm/device.h
index 3814e1c2d4bc..a130be13ee83 100644
--- a/arch/powerpc/include/asm/device.h
+++ b/arch/powerpc/include/asm/device.h
@@ -38,9 +38,6 @@ struct dev_archdata {
 #ifdef CONFIG_IOMMU_API
 	void			*iommu_domain;
 #endif
-#ifdef CONFIG_SWIOTLB
-	dma_addr_t		max_direct_dma_addr;
-#endif
 #ifdef CONFIG_PPC64
 	struct pci_dn		*pci_data;
 #endif
diff --git a/arch/powerpc/include/asm/dma-direct.h b/arch/powerpc/include/asm/dma-direct.h
index 7702875aabb7..e00ab5d0612d 100644
--- a/arch/powerpc/include/asm/dma-direct.h
+++ b/arch/powerpc/include/asm/dma-direct.h
@@ -5,9 +5,7 @@
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
 #ifdef CONFIG_SWIOTLB
-	struct dev_archdata *sd = &dev->archdata;
-
-	if (sd->max_direct_dma_addr && addr + size > sd->max_direct_dma_addr)
+	if (dev->bus_dma_mask && addr + size > dev->bus_dma_mask)
 		return false;
 #endif
 
diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index 38a2c9f5ab54..62caa16b91a9 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -24,21 +24,6 @@
 
 unsigned int ppc_swiotlb_enable;
 
-static u64 swiotlb_powerpc_get_required(struct device *dev)
-{
-	u64 end, mask, max_direct_dma_addr = dev->archdata.max_direct_dma_addr;
-
-	end = memblock_end_of_DRAM();
-	if (max_direct_dma_addr && end > max_direct_dma_addr)
-		end = max_direct_dma_addr;
-	end += get_dma_offset(dev);
-
-	mask = 1ULL << (fls64(end) - 1);
-	mask += mask - 1;
-
-	return mask;
-}
-
 /*
  * At the moment, all platforms that use this code only require
  * swiotlb to be used if we're operating on HIGHMEM.  Since
@@ -60,22 +45,17 @@ const struct dma_map_ops powerpc_swiotlb_dma_ops = {
 	.sync_sg_for_cpu = swiotlb_sync_sg_for_cpu,
 	.sync_sg_for_device = swiotlb_sync_sg_for_device,
 	.mapping_error = dma_direct_mapping_error,
-	.get_required_mask = swiotlb_powerpc_get_required,
 };
 
 static int ppc_swiotlb_bus_notify(struct notifier_block *nb,
 				  unsigned long action, void *data)
 {
 	struct device *dev = data;
-	struct dev_archdata *sd;
 
 	/* We are only intereted in device addition */
 	if (action != BUS_NOTIFY_ADD_DEVICE)
 		return 0;
 
-	sd = &dev->archdata;
-	sd->max_direct_dma_addr = 0;
-
 	/* May need to bounce if the device can't address all of DRAM */
 	if ((dma_get_mask(dev) + 1) < memblock_end_of_DRAM())
 		set_dma_ops(dev, &powerpc_swiotlb_dma_ops);
diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index f9f51fc505a1..59f38ca3975c 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -30,11 +30,10 @@
 static u64 __maybe_unused get_pfn_limit(struct device *dev)
 {
 	u64 pfn = (dev->coherent_dma_mask >> PAGE_SHIFT) + 1;
-	struct dev_archdata __maybe_unused *sd = &dev->archdata;
 
 #ifdef CONFIG_SWIOTLB
-	if (sd->max_direct_dma_addr && dev->dma_ops == &powerpc_swiotlb_dma_ops)
-		pfn = min_t(u64, pfn, sd->max_direct_dma_addr >> PAGE_SHIFT);
+	if (dev->bus_dma_mask && dev->dma_ops == &powerpc_swiotlb_dma_ops)
+		pfn = min_t(u64, pfn, dev->bus_dma_mask >> PAGE_SHIFT);
 #endif
 
 	return pfn;
diff --git a/arch/powerpc/sysdev/fsl_pci.c b/arch/powerpc/sysdev/fsl_pci.c
index 561f97d698cc..f136567a5ed5 100644
--- a/arch/powerpc/sysdev/fsl_pci.c
+++ b/arch/powerpc/sysdev/fsl_pci.c
@@ -117,9 +117,8 @@ static u64 pci64_dma_offset;
 static void pci_dma_dev_setup_swiotlb(struct pci_dev *pdev)
 {
 	struct pci_controller *hose = pci_bus_to_host(pdev->bus);
-	struct dev_archdata *sd = &pdev->dev.archdata;
 
-	sd->max_direct_dma_addr =
+	pdev->dev.bus_dma_mask =
 		hose->dma_window_base_cur + hose->dma_window_size;
 }
 
-- 
2.19.1
