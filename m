Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 471956B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 23:00:15 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id u2so3745553itb.7
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 20:00:15 -0700 (PDT)
Received: from smtpproxy19.qq.com (smtpproxy19.qq.com. [184.105.206.84])
        by mx.google.com with ESMTPS id d14si5636230oic.537.2017.09.14.20.00.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Sep 2017 20:00:11 -0700 (PDT)
From: Huacai Chen <chenhc@lemote.com>
Subject: [PATCH V4 2/3] mm: dmapool: Align to ARCH_DMA_MINALIGN in non-coherent DMA mode
Date: Fri, 15 Sep 2017 11:00:54 +0800
Message-Id: <1505444454-21321-1-git-send-email-chenhc@lemote.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fuxin Zhang <zhangfx@lemote.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huacai Chen <chenhc@lemote.com>, stable@vger.kernel.org

In non-coherent DMA mode, kernel uses cache flushing operations to
maintain I/O coherency, so the dmapool objects should be aligned to
ARCH_DMA_MINALIGN. Otherwise, it will cause data corruption, at least
on MIPS:

	Step 1, dma_map_single
	Step 2, cache_invalidate (no writeback)
	Step 3, dma_from_device
	Step 4, dma_unmap_single

If a DMA buffer and a kernel structure share a same cache line, and if
the kernel structure has dirty data, cache_invalidate (no writeback)
will cause data lost.

Cc: stable@vger.kernel.org
Signed-off-by: Huacai Chen <chenhc@lemote.com>
---
 mm/dmapool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index 4d90a64..2ac6f4a 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -140,6 +140,9 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
 	else if (align & (align - 1))
 		return NULL;
 
+	if (!plat_device_is_coherent(dev))
+		align = max_t(size_t, align, dma_get_cache_alignment());
+
 	if (size == 0)
 		return NULL;
 	else if (size < 4)
-- 
2.7.0



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
