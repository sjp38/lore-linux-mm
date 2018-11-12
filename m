Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A01F6B02A6
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:46:40 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id g22so24594514qke.15
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:46:40 -0800 (PST)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id k17si8097660qkh.130.2018.11.12.07.46.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 07:46:39 -0800 (PST)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v4 9/9] dmapool: debug: prevent endless loop in case of
 corruption
Message-ID: <9e65ec2e-5e22-4f65-7b92-ca2af0c555f3@cybernetics.com>
Date: Mon, 12 Nov 2018 10:46:35 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

Prevent a possible endless loop with DMAPOOL_DEBUG enabled if a buggy
driver corrupts DMA pool memory.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---
--- linux/mm/dmapool.c.orig	2018-08-06 17:52:53.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-06 17:53:31.000000000 -0400
@@ -454,17 +454,39 @@ void dma_pool_free(struct dma_pool *pool
 	{
 		void *page_vaddr = vaddr - offset;
 		unsigned int chain = page->dma_free_off;
+		unsigned int free_blks = 0;
+
 		while (chain < pool->allocation) {
-			if (chain != offset) {
-				chain = *(int *)(page_vaddr + chain);
-				continue;
+			if (unlikely(chain == offset)) {
+				spin_unlock_irqrestore(&pool->lock, flags);
+				dev_err(pool->dev,
+					"dma_pool_free %s, dma %pad already free\n",
+					pool->name, &dma);
+				return;
+			}
+
+			/*
+			 * A buggy driver could corrupt the freelist by
+			 * use-after-free, buffer overflow, etc.  Besides
+			 * checking for corruption, this also prevents an
+			 * endless loop in case corruption causes a circular
+			 * loop in the freelist.
+			 */
+			if (unlikely(++free_blks + page->dma_in_use >
+				     pool->blks_per_alloc)) {
+ freelist_corrupt:
+				spin_unlock_irqrestore(&pool->lock, flags);
+				dev_err(pool->dev,
+					"dma_pool_free %s, freelist corrupted\n",
+					pool->name);
+				return;
 			}
-			spin_unlock_irqrestore(&pool->lock, flags);
-			dev_err(pool->dev,
-				"dma_pool_free %s, dma %pad already free\n",
-				pool->name, &dma);
-			return;
+
+			chain = *(int *)(page_vaddr + chain);
 		}
+		if (unlikely(free_blks + page->dma_in_use !=
+			     pool->blks_per_alloc))
+			goto freelist_corrupt;
 	}
 	memset(vaddr, POOL_POISON_FREED, pool->size);
 #endif
