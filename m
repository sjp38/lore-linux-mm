Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6ADC66B0298
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:43:29 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id y83so24255925qka.7
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:43:29 -0800 (PST)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id k17si8091222qkh.130.2018.11.12.07.43.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 07:43:28 -0800 (PST)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v4 4/9] dmapool: improve scalability of dma_pool_alloc
Message-ID: <e982cd38-a721-bd06-8da8-0d6a0480685c@cybernetics.com>
Date: Mon, 12 Nov 2018 10:43:25 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

dma_pool_alloc() scales poorly when allocating a large number of pages
because it does a linear scan of all previously-allocated pages before
allocating a new one.  Improve its scalability by maintaining a separate
list of pages that have free blocks ready to (re)allocate.  In big O
notation, this improves the algorithm from O(n^2) to O(n).

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---
--- linux/mm/dmapool.c.orig	2018-08-03 16:16:49.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-03 16:45:33.000000000 -0400
@@ -15,11 +15,16 @@
  * Many older drivers still have their own code to do this.
  *
  * The current design of this allocator is fairly simple.  The pool is
- * represented by the 'struct dma_pool' which keeps a doubly-linked list of
- * allocated pages.  Each page in the page_list is split into blocks of at
- * least 'size' bytes.  Free blocks are tracked in an unsorted singly-linked
- * list of free blocks within the page.  Used blocks aren't tracked, but we
- * keep a count of how many are currently allocated from each page.
+ * represented by the 'struct dma_pool'.  Each allocated page is split into
+ * blocks of at least 'size' bytes.  Free blocks are tracked in an unsorted
+ * singly-linked list of free blocks within the page.  Used blocks aren't
+ * tracked, but we keep a count of how many are currently allocated from each
+ * page.
+ *
+ * The pool keeps two doubly-linked list of allocated pages.  The 'available'
+ * list tracks pages that have one or more free blocks, and the 'full' list
+ * tracks pages that have no free blocks.  Pages are moved from one list to
+ * the other as their blocks are allocated and freed.
  */
 
 #include <linux/device.h>
@@ -43,7 +48,10 @@
 #endif
 
 struct dma_pool {		/* the pool */
-	struct list_head page_list;
+#define POOL_FULL_IDX   0
+#define POOL_AVAIL_IDX  1
+#define POOL_MAX_IDX    2
+	struct list_head page_list[POOL_MAX_IDX];
 	spinlock_t lock;
 	size_t size;
 	struct device *dev;
@@ -54,7 +62,7 @@ struct dma_pool {		/* the pool */
 };
 
 struct dma_page {		/* cacheable header for 'allocation' bytes */
-	struct list_head page_list;
+	struct list_head dma_list;
 	void *vaddr;
 	dma_addr_t dma;
 	unsigned int in_use;
@@ -70,7 +78,6 @@ show_pools(struct device *dev, struct de
 	unsigned temp;
 	unsigned size;
 	char *next;
-	struct dma_page *page;
 	struct dma_pool *pool;
 
 	next = buf;
@@ -84,11 +91,18 @@ show_pools(struct device *dev, struct de
 	list_for_each_entry(pool, &dev->dma_pools, pools) {
 		unsigned pages = 0;
 		unsigned blocks = 0;
+		int list_idx;
 
 		spin_lock_irq(&pool->lock);
-		list_for_each_entry(page, &pool->page_list, page_list) {
-			pages++;
-			blocks += page->in_use;
+		for (list_idx = 0; list_idx < POOL_MAX_IDX; list_idx++) {
+			struct dma_page *page;
+
+			list_for_each_entry(page,
+					    &pool->page_list[list_idx],
+					    dma_list) {
+				pages++;
+				blocks += page->in_use;
+			}
 		}
 		spin_unlock_irq(&pool->lock);
 
@@ -163,7 +177,8 @@ struct dma_pool *dma_pool_create(const c
 
 	retval->dev = dev;
 
-	INIT_LIST_HEAD(&retval->page_list);
+	INIT_LIST_HEAD(&retval->page_list[POOL_FULL_IDX]);
+	INIT_LIST_HEAD(&retval->page_list[POOL_AVAIL_IDX]);
 	spin_lock_init(&retval->lock);
 	retval->size = size;
 	retval->boundary = boundary;
@@ -252,7 +267,7 @@ static void pool_free_page(struct dma_po
 	void *vaddr = page->vaddr;
 	dma_addr_t dma = page->dma;
 
-	list_del(&page->page_list);
+	list_del(&page->dma_list);
 
 	if (is_page_busy(page)) {
 		dev_err(pool->dev,
@@ -278,8 +293,8 @@ static void pool_free_page(struct dma_po
  */
 void dma_pool_destroy(struct dma_pool *pool)
 {
-	struct dma_page *page;
 	bool empty = false;
+	int list_idx;
 
 	if (unlikely(!pool))
 		return;
@@ -294,10 +309,15 @@ void dma_pool_destroy(struct dma_pool *p
 		device_remove_file(pool->dev, &dev_attr_pools);
 	mutex_unlock(&pools_reg_lock);
 
-	while ((page = list_first_entry_or_null(&pool->page_list,
-						struct dma_page,
-						page_list))) {
-		pool_free_page(pool, page);
+	for (list_idx = 0; list_idx < POOL_MAX_IDX; list_idx++) {
+		struct dma_page *page;
+
+		while ((page = list_first_entry_or_null(
+					&pool->page_list[list_idx],
+					struct dma_page,
+					dma_list))) {
+			pool_free_page(pool, page);
+		}
 	}
 
 	kfree(pool);
@@ -325,10 +345,11 @@ void *dma_pool_alloc(struct dma_pool *po
 	might_sleep_if(gfpflags_allow_blocking(mem_flags));
 
 	spin_lock_irqsave(&pool->lock, flags);
-	list_for_each_entry(page, &pool->page_list, page_list) {
-		if (page->offset < pool->allocation)
-			goto ready;
-	}
+	page = list_first_entry_or_null(&pool->page_list[POOL_AVAIL_IDX],
+					struct dma_page,
+					dma_list);
+	if (page)
+		goto ready;
 
 	/* pool_alloc_page() might sleep, so temporarily drop &pool->lock */
 	spin_unlock_irqrestore(&pool->lock, flags);
@@ -339,11 +360,15 @@ void *dma_pool_alloc(struct dma_pool *po
 
 	spin_lock_irqsave(&pool->lock, flags);
 
-	list_add(&page->page_list, &pool->page_list);
+	list_add(&page->dma_list, &pool->page_list[POOL_AVAIL_IDX]);
  ready:
 	page->in_use++;
 	offset = page->offset;
 	page->offset = *(int *)(page->vaddr + offset);
+	if (page->offset >= pool->allocation)
+		/* Move page from the "available" list to the "full" list. */
+		list_move_tail(&page->dma_list,
+			       &pool->page_list[POOL_FULL_IDX]);
 	retval = offset + page->vaddr;
 	*handle = offset + page->dma;
 #ifdef	DMAPOOL_DEBUG
@@ -381,13 +406,19 @@ EXPORT_SYMBOL(dma_pool_alloc);
 
 static struct dma_page *pool_find_page(struct dma_pool *pool, dma_addr_t dma)
 {
-	struct dma_page *page;
+	int list_idx;
 
-	list_for_each_entry(page, &pool->page_list, page_list) {
-		if (dma < page->dma)
-			continue;
-		if ((dma - page->dma) < pool->allocation)
-			return page;
+	for (list_idx = 0; list_idx < POOL_MAX_IDX; list_idx++) {
+		struct dma_page *page;
+
+		list_for_each_entry(page,
+				    &pool->page_list[list_idx],
+				    dma_list) {
+			if (dma < page->dma)
+				continue;
+			if ((dma - page->dma) < pool->allocation)
+				return page;
+		}
 	}
 	return NULL;
 }
@@ -444,6 +475,9 @@ void dma_pool_free(struct dma_pool *pool
 #endif
 
 	page->in_use--;
+	if (page->offset >= pool->allocation)
+		/* Move page from the "full" list to the "available" list. */
+		list_move(&page->dma_list, &pool->page_list[POOL_AVAIL_IDX]);
 	*(int *)vaddr = page->offset;
 	page->offset = offset;
 	/*
