Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1436B029F
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:44:44 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id d196so24618728qkb.6
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:44:44 -0800 (PST)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id j5si7014859qtd.148.2018.11.12.07.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 07:44:42 -0800 (PST)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v4 6/9] dmapool: improve scalability of dma_pool_free
Message-ID: <4c3c25ab-5793-c394-9fe4-221b81805536@cybernetics.com>
Date: Mon, 12 Nov 2018 10:44:40 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

dma_pool_free() scales poorly when the pool contains many pages because
pool_find_page() does a linear scan of all allocated pages.  Improve its
scalability by replacing the linear scan with virt_to_page() and storing
dmapool private data directly in 'struct page', thereby eliminating
'struct dma_page'.  In big O notation, this improves the algorithm from
O(n^2) to O(n) while also reducing memory usage.

Thanks to Matthew Wilcox for the suggestion to use struct page.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---
--- linux/include/linux/mm_types.h.orig	2018-08-01 17:59:46.000000000 -0400
+++ linux/include/linux/mm_types.h	2018-08-01 17:59:56.000000000 -0400
@@ -156,6 +156,12 @@ struct page {
 			unsigned long _zd_pad_1;	/* uses mapping */
 		};
 
+		struct {	/* dma_pool pages */
+			struct list_head dma_list;
+			dma_addr_t dma;
+			unsigned int dma_free_off;
+		};
+
 		/** @rcu_head: You can use this to free a page by RCU. */
 		struct rcu_head rcu_head;
 	};
@@ -177,6 +183,8 @@ struct page {
 
 		unsigned int active;		/* SLAB */
 		int units;			/* SLOB */
+
+		unsigned int dma_in_use;	/* dma_pool pages */
 	};
 
 	/* Usage count. *DO NOT USE DIRECTLY*. See page_ref.h */
--- linux/mm/dmapool.c.orig	2018-08-03 17:47:03.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-03 17:47:22.000000000 -0400
@@ -25,6 +25,10 @@
  * list tracks pages that have one or more free blocks, and the 'full' list
  * tracks pages that have no free blocks.  Pages are moved from one list to
  * the other as their blocks are allocated and freed.
+ *
+ * When allocating DMA pages, we use some available space in 'struct page' to
+ * store data private to dmapool; search 'dma_pool' in the definition of
+ * 'struct page' for details.
  */
 
 #include <linux/device.h>
@@ -61,14 +65,6 @@ struct dma_pool {		/* the pool */
 	struct list_head pools;
 };
 
-struct dma_page {		/* cacheable header for 'allocation' bytes */
-	struct list_head dma_list;
-	void *vaddr;
-	dma_addr_t dma;
-	unsigned int dma_in_use;
-	unsigned int dma_free_off;
-};
-
 static DEFINE_MUTEX(pools_lock);
 static DEFINE_MUTEX(pools_reg_lock);
 
@@ -95,7 +91,7 @@ show_pools(struct device *dev, struct de
 
 		spin_lock_irq(&pool->lock);
 		for (list_idx = 0; list_idx < POOL_MAX_IDX; list_idx++) {
-			struct dma_page *page;
+			struct page *page;
 
 			list_for_each_entry(page,
 					    &pool->page_list[list_idx],
@@ -218,7 +214,7 @@ struct dma_pool *dma_pool_create(const c
 }
 EXPORT_SYMBOL(dma_pool_create);
 
-static void pool_initialise_page(struct dma_pool *pool, struct dma_page *page)
+static void pool_initialize_free_block_list(struct dma_pool *pool, void *vaddr)
 {
 	unsigned int offset = 0;
 	unsigned int next_boundary = pool->boundary;
@@ -229,47 +225,57 @@ static void pool_initialise_page(struct 
 			next = next_boundary;
 			next_boundary += pool->boundary;
 		}
-		*(int *)(page->vaddr + offset) = next;
+		*(int *)(vaddr + offset) = next;
 		offset = next;
 	} while (offset < pool->allocation);
 }
 
-static struct dma_page *pool_alloc_page(struct dma_pool *pool, gfp_t mem_flags)
+static struct page *pool_alloc_page(struct dma_pool *pool, gfp_t mem_flags)
 {
-	struct dma_page *page;
+	struct page *page;
+	dma_addr_t dma;
+	void *vaddr;
 
-	page = kmalloc(sizeof(*page), mem_flags);
-	if (!page)
+	vaddr = dma_alloc_coherent(pool->dev, pool->allocation, &dma,
+				   mem_flags);
+	if (!vaddr)
 		return NULL;
-	page->vaddr = dma_alloc_coherent(pool->dev, pool->allocation,
-					 &page->dma, mem_flags);
-	if (page->vaddr) {
+
 #ifdef	DMAPOOL_DEBUG
-		memset(page->vaddr, POOL_POISON_FREED, pool->allocation);
+	memset(vaddr, POOL_POISON_FREED, pool->allocation);
 #endif
-		pool_initialise_page(pool, page);
-		page->dma_in_use = 0;
-		page->dma_free_off = 0;
-	} else {
-		kfree(page);
-		page = NULL;
-	}
+	pool_initialize_free_block_list(pool, vaddr);
+
+	page = virt_to_page(vaddr);
+	page->dma = dma;
+	page->dma_free_off = 0;
+	page->dma_in_use = 0;
+
 	return page;
 }
 
-static inline bool is_page_busy(struct dma_page *page)
+static inline bool is_page_busy(struct page *page)
 {
 	return page->dma_in_use != 0;
 }
 
-static void pool_free_page(struct dma_pool *pool, struct dma_page *page)
+static void pool_free_page(struct dma_pool *pool, struct page *page)
 {
-	void *vaddr = page->vaddr;
+	/* Save local copies of some page fields. */
+	void *vaddr = page_to_virt(page);
+	bool busy = is_page_busy(page);
 	dma_addr_t dma = page->dma;
 
 	list_del(&page->dma_list);
 
-	if (is_page_busy(page)) {
+	/* Clear all the page fields we use. */
+	page->dma_list.next = NULL;
+	page->dma_list.prev = NULL;
+	page->dma = 0;
+	page->dma_free_off = 0;
+	page_mapcount_reset(page); /* clear dma_in_use */
+
+	if (busy) {
 		dev_err(pool->dev,
 			"dma_pool_destroy %s, %p busy\n",
 			pool->name, vaddr);
@@ -280,7 +286,6 @@ static void pool_free_page(struct dma_po
 #endif
 		dma_free_coherent(pool->dev, pool->allocation, vaddr, dma);
 	}
-	kfree(page);
 }
 
 /**
@@ -310,11 +315,11 @@ void dma_pool_destroy(struct dma_pool *p
 	mutex_unlock(&pools_reg_lock);
 
 	for (list_idx = 0; list_idx < POOL_MAX_IDX; list_idx++) {
-		struct dma_page *page;
+		struct page *page;
 
 		while ((page = list_first_entry_or_null(
 					&pool->page_list[list_idx],
-					struct dma_page,
+					struct page,
 					dma_list))) {
 			pool_free_page(pool, page);
 		}
@@ -338,15 +343,16 @@ void *dma_pool_alloc(struct dma_pool *po
 		     dma_addr_t *handle)
 {
 	unsigned long flags;
-	struct dma_page *page;
+	struct page *page;
 	size_t offset;
 	void *retval;
+	void *vaddr;
 
 	might_sleep_if(gfpflags_allow_blocking(mem_flags));
 
 	spin_lock_irqsave(&pool->lock, flags);
 	page = list_first_entry_or_null(&pool->page_list[POOL_AVAIL_IDX],
-					struct dma_page,
+					struct page,
 					dma_list);
 	if (page)
 		goto ready;
@@ -362,14 +368,15 @@ void *dma_pool_alloc(struct dma_pool *po
 
 	list_add(&page->dma_list, &pool->page_list[POOL_AVAIL_IDX]);
  ready:
+	vaddr = page_to_virt(page);
 	page->dma_in_use++;
 	offset = page->dma_free_off;
-	page->dma_free_off = *(int *)(page->vaddr + offset);
+	page->dma_free_off = *(int *)(vaddr + offset);
 	if (page->dma_free_off >= pool->allocation)
 		/* Move page from the "available" list to the "full" list. */
 		list_move_tail(&page->dma_list,
 			       &pool->page_list[POOL_FULL_IDX]);
-	retval = offset + page->vaddr;
+	retval = offset + vaddr;
 	*handle = offset + page->dma;
 #ifdef	DMAPOOL_DEBUG
 	{
@@ -404,25 +411,6 @@ void *dma_pool_alloc(struct dma_pool *po
 }
 EXPORT_SYMBOL(dma_pool_alloc);
 
-static struct dma_page *pool_find_page(struct dma_pool *pool, dma_addr_t dma)
-{
-	int list_idx;
-
-	for (list_idx = 0; list_idx < POOL_MAX_IDX; list_idx++) {
-		struct dma_page *page;
-
-		list_for_each_entry(page,
-				    &pool->page_list[list_idx],
-				    dma_list) {
-			if (dma < page->dma)
-				continue;
-			if ((dma - page->dma) < pool->allocation)
-				return page;
-		}
-	}
-	return NULL;
-}
-
 /**
  * dma_pool_free - put block back into dma pool
  * @pool: the dma pool holding the block
@@ -434,34 +422,35 @@ static struct dma_page *pool_find_page(s
  */
 void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t dma)
 {
-	struct dma_page *page;
+	struct page *page;
 	unsigned long flags;
 	unsigned int offset;
 
-	spin_lock_irqsave(&pool->lock, flags);
-	page = pool_find_page(pool, dma);
-	if (!page) {
-		spin_unlock_irqrestore(&pool->lock, flags);
+	if (unlikely(!virt_addr_valid(vaddr))) {
 		dev_err(pool->dev,
-			"dma_pool_free %s, %p/%lx (bad dma)\n",
-			pool->name, vaddr, (unsigned long)dma);
+			"dma_pool_free %s, %p (bad vaddr)/%pad\n",
+			pool->name, vaddr, &dma);
 		return;
 	}
 
-	offset = vaddr - page->vaddr;
-#ifdef	DMAPOOL_DEBUG
-	if ((dma - page->dma) != offset) {
-		spin_unlock_irqrestore(&pool->lock, flags);
+	page = virt_to_page(vaddr);
+	offset = offset_in_page(vaddr);
+
+	if (unlikely((dma - page->dma) != offset)) {
 		dev_err(pool->dev,
-			"dma_pool_free %s, %p (bad vaddr)/%pad\n",
+			"dma_pool_free %s, %p (bad vaddr)/%pad (or bad dma)\n",
 			pool->name, vaddr, &dma);
 		return;
 	}
+
+	spin_lock_irqsave(&pool->lock, flags);
+#ifdef	DMAPOOL_DEBUG
 	{
+		void *page_vaddr = vaddr - offset;
 		unsigned int chain = page->dma_free_off;
 		while (chain < pool->allocation) {
 			if (chain != offset) {
-				chain = *(int *)(page->vaddr + chain);
+				chain = *(int *)(page_vaddr + chain);
 				continue;
 			}
 			spin_unlock_irqrestore(&pool->lock, flags);
