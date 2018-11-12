Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 228F66B0294
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:42:16 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id f22so24028094qkm.11
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:42:16 -0800 (PST)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id y80si12964580qkg.186.2018.11.12.07.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 07:42:14 -0800 (PST)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v4 2/9] dmapool: remove checks for dev == NULL
Message-ID: <df529b6e-6744-b1af-01ce-a1b691fbcf0d@cybernetics.com>
Date: Mon, 12 Nov 2018 10:42:12 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

dmapool originally tried to support pools without a device because
dma_alloc_coherent() supports allocations without a device.  But nobody
ended up using dma pools without a device, so the current checks in
dmapool.c for pool->dev == NULL are both insufficient and causing bloat.
Remove them.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---
--- linux/mm/dmapool.c.orig	2018-08-03 16:12:23.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-03 16:13:44.000000000 -0400
@@ -277,7 +277,7 @@ void dma_pool_destroy(struct dma_pool *p
 	mutex_lock(&pools_reg_lock);
 	mutex_lock(&pools_lock);
 	list_del(&pool->pools);
-	if (pool->dev && list_empty(&pool->dev->dma_pools))
+	if (list_empty(&pool->dev->dma_pools))
 		empty = true;
 	mutex_unlock(&pools_lock);
 	if (empty)
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
