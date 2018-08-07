Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A73D66B026F
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 12:50:18 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d194-v6so17099998qkb.12
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 09:50:18 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id f129-v6si1707198qkb.232.2018.08.07.09.50.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 09:50:17 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v3 09/10] dmapool: debug: prevent endless loop in case of
 corruption
Message-ID: <63e9878d-4819-572d-7288-b1b2329f056b@cybernetics.com>
Date: Tue, 7 Aug 2018 12:50:15 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "MPT-FusionLinux.pdl@broadcom.com" <MPT-FusionLinux.pdl@broadcom.com>

Prevent a possible endless loop with DMAPOOL_DEBUG enabled if a buggy
driver corrupts DMA pool memory.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---

Changes since v2:
This is closer to the improved version from "dmapool: reduce footprint
in struct page" in v2 thanks to a previous patch adding blks_per_alloc.

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
