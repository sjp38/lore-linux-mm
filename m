Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24F7C6B0006
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 15:57:32 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j11-v6so2534343qtp.0
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 12:57:32 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id u186-v6si2793887qkd.81.2018.08.02.12.57.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 12:57:31 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v2 2/9] dmapool: cleanup error messages
Message-ID: <a9f7ca9a-38d5-12e2-7d15-ab026425e85a@cybernetics.com>
Date: Thu, 2 Aug 2018 15:57:28 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com

Remove code duplication in error messages.  It is now safe to pas a NULL
dev to dev_err(), so the checks to avoid doing so are no longer
necessary.

Example:

Error message with dev != NULL:
  mpt3sas 0000:02:00.0: dma_pool_destroy chain pool, (____ptrval____) busy

Same error message with dev == NULL before patch:
  dma_pool_destroy chain pool, (____ptrval____) busy

Same error message with dev == NULL after patch:
  (NULL device *): dma_pool_destroy chain pool, (____ptrval____) busy

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---
--- linux/mm/dmapool.c.orig	2018-08-02 09:54:25.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-02 09:57:58.000000000 -0400
@@ -289,13 +289,9 @@ void dma_pool_destroy(struct dma_pool *p
 		page = list_entry(pool->page_list.next,
 				  struct dma_page, page_list);
 		if (is_page_busy(page)) {
-			if (pool->dev)
-				dev_err(pool->dev,
-					"dma_pool_destroy %s, %p busy\n",
-					pool->name, page->vaddr);
-			else
-				pr_err("dma_pool_destroy %s, %p busy\n",
-				       pool->name, page->vaddr);
+			dev_err(pool->dev,
+				"dma_pool_destroy %s, %p busy\n",
+				pool->name, page->vaddr);
 			/* leak the still-in-use consistent memory */
 			list_del(&page->page_list);
 			kfree(page);
@@ -357,13 +353,9 @@ void *dma_pool_alloc(struct dma_pool *po
 		for (i = sizeof(page->offset); i < pool->size; i++) {
 			if (data[i] == POOL_POISON_FREED)
 				continue;
-			if (pool->dev)
-				dev_err(pool->dev,
-					"dma_pool_alloc %s, %p (corrupted)\n",
-					pool->name, retval);
-			else
-				pr_err("dma_pool_alloc %s, %p (corrupted)\n",
-					pool->name, retval);
+			dev_err(pool->dev,
+				"dma_pool_alloc %s, %p (corrupted)\n",
+				pool->name, retval);
 
 			/*
 			 * Dump the first 4 bytes even if they are not
@@ -418,13 +410,9 @@ void dma_pool_free(struct dma_pool *pool
 	page = pool_find_page(pool, dma);
 	if (!page) {
 		spin_unlock_irqrestore(&pool->lock, flags);
-		if (pool->dev)
-			dev_err(pool->dev,
-				"dma_pool_free %s, %p/%lx (bad dma)\n",
-				pool->name, vaddr, (unsigned long)dma);
-		else
-			pr_err("dma_pool_free %s, %p/%lx (bad dma)\n",
-			       pool->name, vaddr, (unsigned long)dma);
+		dev_err(pool->dev,
+			"dma_pool_free %s, %p/%lx (bad dma)\n",
+			pool->name, vaddr, (unsigned long)dma);
 		return;
 	}
 
@@ -432,13 +420,9 @@ void dma_pool_free(struct dma_pool *pool
 #ifdef	DMAPOOL_DEBUG
 	if ((dma - page->dma) != offset) {
 		spin_unlock_irqrestore(&pool->lock, flags);
-		if (pool->dev)
-			dev_err(pool->dev,
-				"dma_pool_free %s, %p (bad vaddr)/%pad\n",
-				pool->name, vaddr, &dma);
-		else
-			pr_err("dma_pool_free %s, %p (bad vaddr)/%pad\n",
-			       pool->name, vaddr, &dma);
+		dev_err(pool->dev,
+			"dma_pool_free %s, %p (bad vaddr)/%pad\n",
+			pool->name, vaddr, &dma);
 		return;
 	}
 	{
@@ -449,12 +433,9 @@ void dma_pool_free(struct dma_pool *pool
 				continue;
 			}
 			spin_unlock_irqrestore(&pool->lock, flags);
-			if (pool->dev)
-				dev_err(pool->dev, "dma_pool_free %s, dma %pad already free\n",
-					pool->name, &dma);
-			else
-				pr_err("dma_pool_free %s, dma %pad already free\n",
-				       pool->name, &dma);
+			dev_err(pool->dev,
+				"dma_pool_free %s, dma %pad already free\n",
+				pool->name, &dma);
 			return;
 		}
 	}
