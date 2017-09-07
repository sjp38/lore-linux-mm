Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DEE946B04C2
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 04:46:45 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e199so17288169pfh.3
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 01:46:45 -0700 (PDT)
Received: from smtpbgsg2.qq.com (smtpbgsg2.qq.com. [54.254.200.128])
        by mx.google.com with ESMTPS id j6si1622568plt.64.2017.09.07.01.46.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Sep 2017 01:46:44 -0700 (PDT)
From: Huacai Chen <chenhc@lemote.com>
Subject: [PATCH 1/2] mm: dmapool: Align to ARCH_DMA_MINALIGN in non-coherent DMA mode
Date: Thu,  7 Sep 2017 16:47:51 +0800
Message-Id: <1504774071-11581-1-git-send-email-chenhc@lemote.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fuxin Zhang <zhangfx@lemote.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huacai Chen <chenhc@lemote.com>, stable@vger.kernel.org

In non-coherent DMA mode, kernel uses cache flushing operations to
maintain I/O coherency, so the dmapool objects should be aligned to
ARCH_DMA_MINALIGN.

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
