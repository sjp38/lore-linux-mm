Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94E576B0038
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 00:20:46 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 4so14995167itv.4
        for <linux-mm@kvack.org>; Sun, 17 Sep 2017 21:20:46 -0700 (PDT)
Received: from smtpbg65.qq.com (smtpbg65.qq.com. [103.7.28.233])
        by mx.google.com with ESMTPS id o184si609515oih.395.2017.09.17.21.20.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Sep 2017 21:20:45 -0700 (PDT)
From: Huacai Chen <chenhc@lemote.com>
Subject: [PATCH V5 2/3] mm: dmapool: Align to ARCH_DMA_MINALIGN in non-coherent DMA mode
Date: Mon, 18 Sep 2017 12:22:28 +0800
Message-Id: <1505708548-4750-1-git-send-email-chenhc@lemote.com>
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
index 4d90a64..6263905 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -140,6 +140,9 @@ struct dma_pool *dma_pool_create(const char *name, struct device *dev,
 	else if (align & (align - 1))
 		return NULL;
 
+	if (!device_is_coherent(dev))
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
