Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id A391E6B0290
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 03:24:40 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id g12-v6so11537613plo.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 00:24:40 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f4-v6si26557226plm.393.2018.11.14.00.24.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Nov 2018 00:24:39 -0800 (PST)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 26/34] powerpc/dma: fix an off-by-one in dma_capable
Date: Wed, 14 Nov 2018 09:23:06 +0100
Message-Id: <20181114082314.8965-27-hch@lst.de>
In-Reply-To: <20181114082314.8965-1-hch@lst.de>
References: <20181114082314.8965-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

We need to compare the last byte in the dma range and not the one after it
for the bus_dma_mask, just like we do for the regular dma_mask.  Fix this
cleanly by merging the two comparisms into one.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/include/asm/dma-direct.h | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-direct.h b/arch/powerpc/include/asm/dma-direct.h
index e00ab5d0612d..92d8aed86422 100644
--- a/arch/powerpc/include/asm/dma-direct.h
+++ b/arch/powerpc/include/asm/dma-direct.h
@@ -4,15 +4,11 @@
 
 static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
 {
-#ifdef CONFIG_SWIOTLB
-	if (dev->bus_dma_mask && addr + size > dev->bus_dma_mask)
-		return false;
-#endif
-
 	if (!dev->dma_mask)
 		return false;
 
-	return addr + size - 1 <= *dev->dma_mask;
+	return addr + size - 1 <=
+		min_not_zero(*dev->dma_mask, dev->bus_dma_mask);
 }
 
 static inline dma_addr_t __phys_to_dma(struct device *dev, phys_addr_t paddr)
-- 
2.19.1
