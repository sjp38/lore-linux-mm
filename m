Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C83086B0293
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 09:26:37 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z28-v6so948499pff.4
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 06:26:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j185-v6si607667pfc.186.2018.10.09.06.26.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Oct 2018 06:26:36 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 29/33] powerpc/dma: remove get_dma_offset
Date: Tue,  9 Oct 2018 15:24:56 +0200
Message-Id: <20181009132500.17643-30-hch@lst.de>
In-Reply-To: <20181009132500.17643-1-hch@lst.de>
References: <20181009132500.17643-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Just fold the calculation into __phys_to_dma/__dma_to_phys as those are
the only places that should know about it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 arch/powerpc/include/asm/dma-direct.h  |  8 ++++++--
 arch/powerpc/include/asm/dma-mapping.h | 16 ----------------
 2 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-direct.h b/arch/powerpc/include/asm/dma-direct.h
index 92d8aed86422..a2912b47102c 100644
--- a/arch/powerpc/include/asm/dma-direct.h
+++ b/arch/powerpc/include/asm/dma-direct.h
@@ -13,11 +13,15 @@ static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 
 static inline dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t paddr)
 {
-	return paddr + get_dma_offset(dev);
+	if (!dev)
+		return paddr + PCI_DRAM_OFFSET;
+	return paddr + dev->archdata.dma_offset;
 }
 
 static inline phys_addr_t __dma_to_phys(struct device *dev, dma_addr_t daddr)
 {
-	return daddr - get_dma_offset(dev);
+	if (!dev)
+		return daddr - PCI_DRAM_OFFSET;
+	return daddr - dev->archdata.dma_offset;
 }
 #endif /* ASM_POWERPC_DMA_DIRECT_H */
diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index 7694985f05ee..2d0879b0acf3 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -87,22 +87,6 @@ static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
 	return NULL;
 }
 
-/*
- * get_dma_offset()
- *
- * Get the dma offset on configurations where the dma address can be determined
- * from the physical address by looking at a simple offset.  Direct dma and
- * swiotlb use this function, but it is typically not used by implementations
- * with an iommu.
- */
-static inline dma_addr_t get_dma_offset(struct device *dev)
-{
-	if (dev)
-		return dev->archdata.dma_offset;
-
-	return PCI_DRAM_OFFSET;
-}
-
 static inline void set_dma_offset(struct device *dev, dma_addr_t off)
 {
 	if (dev)
-- 
2.19.0
