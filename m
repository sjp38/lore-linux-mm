Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6A736B026B
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 16:00:40 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d18-v6so2488877qtj.20
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 13:00:40 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id l54-v6si2750111qtk.229.2018.08.02.13.00.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 13:00:39 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v2 7/9] dmapool: debug: prevent endless loop in case of
 corruption
Message-ID: <36e483e9-d779-497a-551e-32f96e184b49@cybernetics.com>
Date: Thu, 2 Aug 2018 16:00:37 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com

Prevent a possible endless loop with DMAPOOL_DEBUG enabled if a buggy
driver corrupts DMA pool memory.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---
--- linux/mm/dmapool.c.orig	2018-08-02 10:14:25.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-02 10:16:17.000000000 -0400
@@ -449,16 +449,35 @@ void dma_pool_free(struct dma_pool *pool
 	{
 		void *page_vaddr = vaddr - offset;
 		unsigned int chain = page->dma_free_o;
+		size_t total_free = 0;
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
+			 * The calculation of the number of blocks per
+			 * allocation is actually more complicated than this
+			 * because of the boundary value.  But this comparison
+			 * does not need to be exact; it just needs to prevent
+			 * an endless loop in case a buggy driver causes a
+			 * circular loop in the freelist.
+			 */
+			total_free += pool->size;
+			if (unlikely(total_free >= pool->allocation)) {
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
 	}
 	memset(vaddr, POOL_POISON_FREED, pool->size);
