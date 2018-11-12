Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18E5F6B0296
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:42:57 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id 92so24498462qkx.19
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:42:57 -0800 (PST)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id d9si3485494qto.61.2018.11.12.07.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 07:42:55 -0800 (PST)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v4 3/9] dmapool: cleanup dma_pool_destroy
Message-ID: <2ff327bb-59f7-5105-0bba-72329cb73154@cybernetics.com>
Date: Mon, 12 Nov 2018 10:42:48 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: linux-scsi@vger.kernel.org

Remove a small amount of code duplication between dma_pool_destroy() and
pool_free_page() in preparation for adding more code without having to
duplicate it.  No functional changes.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---
--- linux/mm/dmapool.c.orig	2018-08-02 09:59:15.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-02 10:01:26.000000000 -0400
@@ -249,13 +249,22 @@ static inline bool is_page_busy(struct d
 
 static void pool_free_page(struct dma_pool *pool, struct dma_page *page)
 {
+	void *vaddr = page->vaddr;
 	dma_addr_t dma = page->dma;
 
+	list_del(&page->page_list);
+
+	if (is_page_busy(page)) {
+		dev_err(pool->dev,
+			"dma_pool_destroy %s, %p busy\n",
+			pool->name, vaddr);
+		/* leak the still-in-use consistent memory */
+	} else {
 #ifdef	DMAPOOL_DEBUG
-	memset(page->vaddr, POOL_POISON_FREED, pool->allocation);
+		memset(vaddr, POOL_POISON_FREED, pool->allocation);
 #endif
-	dma_free_coherent(pool->dev, pool->allocation, page->vaddr, dma);
-	list_del(&page->page_list);
+		dma_free_coherent(pool->dev, pool->allocation, vaddr, dma);
+	}
 	kfree(page);
 }
 
@@ -269,6 +278,7 @@ static void pool_free_page(struct dma_po
  */
 void dma_pool_destroy(struct dma_pool *pool)
 {
+	struct dma_page *page;
 	bool empty = false;
 
 	if (unlikely(!pool))
@@ -284,19 +294,10 @@ void dma_pool_destroy(struct dma_pool *p
 		device_remove_file(pool->dev, &dev_attr_pools);
 	mutex_unlock(&pools_reg_lock);
 
-	while (!list_empty(&pool->page_list)) {
-		struct dma_page *page;
-		page = list_entry(pool->page_list.next,
-				  struct dma_page, page_list);
-		if (is_page_busy(page)) {
-			dev_err(pool->dev,
-				"dma_pool_destroy %s, %p busy\n",
-				pool->name, page->vaddr);
-			/* leak the still-in-use consistent memory */
-			list_del(&page->page_list);
-			kfree(page);
-		} else
-			pool_free_page(pool, page);
+	while ((page = list_first_entry_or_null(&pool->page_list,
+						struct dma_page,
+						page_list))) {
+		pool_free_page(pool, page);
 	}
 
 	kfree(pool);
