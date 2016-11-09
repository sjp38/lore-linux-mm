Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 034D86B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 04:10:41 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id bi5so48810336pad.0
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 01:10:40 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id n9si34302592pad.79.2016.11.09.01.10.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Nov 2016 01:10:40 -0800 (PST)
Received: from epcpsbgm1new.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0OGD00A7UATQM2A0@mailout3.samsung.com> for linux-mm@kvack.org;
 Wed, 09 Nov 2016 18:10:38 +0900 (KST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH] [RFC] drivers: dma-coherent: use MEMREMAP_WB instead of
 MEMREMAP_WC
Date: Wed, 09 Nov 2016 18:10:09 +0900
Message-id: <1478682609-26477-1-git-send-email-jaewon31.kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: brian.starkey@arm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@samsung.com

Commit 6b03ae0d42bf (drivers: dma-coherent: use MEMREMAP_WC for DMA_MEMORY_MA)
added MEMREMAP_WC for DMA_MEMORY_MAP. If, however, CPU cache can be used on
DMA_MEMORY_MAP, I think MEMREMAP_WC can be changed to MEMREMAP_WB. On my local
ARM device, memset in dma_alloc_from_coherent sometimes takes much longer with
MEMREMAP_WC compared to MEMREMAP_WB.

Test results on AArch64 by allocating 4MB with putting trace_printk right
before and after memset.
	MEMREMAP_WC : 11.0ms, 5.7ms, 4.2ms, 4.9ms, 5.4ms, 4.3ms, 3.5ms
	MEMREMAP_WB : 0.7ms, 0.6ms, 0.6ms, 0.6ms, 0.6ms, 0.5ms, 0.4 ms

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 drivers/base/dma-coherent.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
index 640a7e6..0512a1d 100644
--- a/drivers/base/dma-coherent.c
+++ b/drivers/base/dma-coherent.c
@@ -33,7 +33,7 @@ static bool dma_init_coherent_memory(
 		goto out;
 
 	if (flags & DMA_MEMORY_MAP)
-		mem_base = memremap(phys_addr, size, MEMREMAP_WC);
+		mem_base = memremap(phys_addr, size, MEMREMAP_WB);
 	else
 		mem_base = ioremap(phys_addr, size);
 	if (!mem_base)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
