Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9FEEA6B000C
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 14:54:59 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u68-v6so2176274qku.5
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:54:59 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id j125-v6si1957933qkc.143.2018.07.26.11.54.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 11:54:58 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH 2/3] dmapool: improve scalability of dma_pool_free
Message-ID: <1288e597-a67a-25b3-b7c6-db883ca67a25@cybernetics.com>
Date: Thu, 26 Jul 2018 14:54:56 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Matthew Wilcox <willy@infradead.org>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi <linux-scsi@vger.kernel.org>, MPT-FusionLinux.pdl@broadcom.com

dma_pool_free() scales poorly when the pool contains many pages because
pool_find_page() does a linear scan of all allocated pages.  Improve its
scalability by replacing the linear scan with a red-black tree lookup. 
In big O notation, this improves the algorithm from O(n^2) to O(n * log n).

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---

I moved some code from dma_pool_destroy() into pool_free_page() to avoid code
repetition.

--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -15,11 +15,12 @@
  * Many older drivers still have their own code to do this.
  *
  * The current design of this allocator is fairly simple.  The pool is
- * represented by the 'struct dma_pool' which keeps a doubly-linked list of
- * allocated pages.  Each page in the page_list is split into blocks of at
- * least 'size' bytes.  Free blocks are tracked in an unsorted singly-linked
- * list of free blocks within the page.  Used blocks aren't tracked, but we
- * keep a count of how many are currently allocated from each page.
+ * represented by the 'struct dma_pool' which keeps a red-black tree of all
+ * allocated pages, keyed by DMA address for fast lookup when freeing.
+ * Each page in the page_tree is split into blocks of at least 'size' bytes.
+ * Free blocks are tracked in an unsorted singly-linked list of free blocks
+ * within the page.  Used blocks aren't tracked, but we keep a count of how
+ * many are currently allocated from each page.
  *
  * The avail_page_list keeps track of pages that have one or more free blocks
  * available to (re)allocate.  Pages are moved in and out of avail_page_list
@@ -41,13 +42,14 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/wait.h>
+#include <linux/rbtree.h>
 
 #if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB_DEBUG_ON)
 #define DMAPOOL_DEBUG 1
 #endif
 
 struct dma_pool {		/* the pool */
-	struct list_head page_list;
+	struct rb_root page_tree;
 	struct list_head avail_page_list;
 	spinlock_t lock;
 	size_t size;
@@ -59,7 +61,7 @@ struct dma_pool {		/* the pool */
 };
 
 struct dma_page {		/* cacheable header for 'allocation' bytes */
-	struct list_head page_list;
+	struct rb_node page_node;
 	struct list_head avail_page_link;
 	void *vaddr;
 	dma_addr_t dma;
@@ -78,6 +80,7 @@ show_pools(struct device *dev, struct de
 	char *next;
 	struct dma_page *page;
 	struct dma_pool *pool;
+	struct rb_node *node;
 
 	next = buf;
 	size = PAGE_SIZE;
@@ -92,7 +95,10 @@ show_pools(struct device *dev, struct de
 		unsigned blocks = 0;
 
 		spin_lock_irq(&pool->lock);
-		list_for_each_entry(page, &pool->page_list, page_list) {
+		for (node = rb_first(&pool->page_tree);
+		     node;
+		     node = rb_next(node)) {
+			page = rb_entry(node, struct dma_page, page_node);
 			pages++;
 			blocks += page->in_use;
 		}
@@ -169,7 +175,7 @@ struct dma_pool *dma_pool_create(const c
 
 	retval->dev = dev;
 
-	INIT_LIST_HEAD(&retval->page_list);
+	retval->page_tree = RB_ROOT;
 	INIT_LIST_HEAD(&retval->avail_page_list);
 	spin_lock_init(&retval->lock);
 	retval->size = size;
@@ -210,6 +216,65 @@ struct dma_pool *dma_pool_create(const c
 }
 EXPORT_SYMBOL(dma_pool_create);
 
+/*
+ * Find the dma_page that manages the given DMA address.
+ */
+static struct dma_page *pool_find_page(struct dma_pool *pool, dma_addr_t dma)
+{
+	struct rb_node *node = pool->page_tree.rb_node;
+
+	while (node) {
+		struct dma_page *page =
+			container_of(node, struct dma_page, page_node);
+
+		if (dma < page->dma)
+			node = node->rb_left;
+		else if ((dma - page->dma) >= pool->allocation)
+			node = node->rb_right;
+		else
+			return page;
+	}
+	return NULL;
+}
+
+/*
+ * Insert a dma_page into the page_tree.
+ */
+static int pool_insert_page(struct dma_pool *pool, struct dma_page *new_page)
+{
+	dma_addr_t dma = new_page->dma;
+	struct rb_node **node = &(pool->page_tree.rb_node), *parent = NULL;
+
+	while (*node) {
+		struct dma_page *this_page =
+			container_of(*node, struct dma_page, page_node);
+
+		parent = *node;
+		if (dma < this_page->dma)
+			node = &((*node)->rb_left);
+		else if (likely((dma - this_page->dma) >= pool->allocation))
+			node = &((*node)->rb_right);
+		else {
+			/*
+			 * A page that overlaps the new DMA range is already
+			 * present in the tree.  This should not happen.
+			 */
+			WARN(1,
+			     "%s: %s: DMA address overlap: old 0x%llx new 0x%llx len %zu\n",
+			     pool->dev ? dev_name(pool->dev) : "(nodev)",
+			     pool->name, (u64) this_page->dma, (u64) dma,
+			     pool->allocation);
+			return -1;
+		}
+	}
+
+	/* Add new node and rebalance tree. */
+	rb_link_node(&new_page->page_node, parent, node);
+	rb_insert_color(&new_page->page_node, &pool->page_tree);
+
+	return 0;
+}
+
 static void pool_initialise_page(struct dma_pool *pool, struct dma_page *page)
 {
 	unsigned int offset = 0;
@@ -254,15 +319,36 @@ static inline bool is_page_busy(struct d
 	return page->in_use != 0;
 }
 
-static void pool_free_page(struct dma_pool *pool, struct dma_page *page)
+static void pool_free_page(struct dma_pool *pool,
+			   struct dma_page *page,
+			   bool destroying_pool)
 {
-	dma_addr_t dma = page->dma;
-
+	if (destroying_pool && is_page_busy(page)) {
+		if (pool->dev)
+			dev_err(pool->dev,
+				"dma_pool_destroy %s, %p busy\n",
+				pool->name, page->vaddr);
+		else
+			pr_err("dma_pool_destroy %s, %p busy\n",
+			       pool->name, page->vaddr);
+		/* leak the still-in-use consistent memory */
+	} else {
 #ifdef	DMAPOOL_DEBUG
-	memset(page->vaddr, POOL_POISON_FREED, pool->allocation);
+		memset(page->vaddr, POOL_POISON_FREED, pool->allocation);
 #endif
-	dma_free_coherent(pool->dev, pool->allocation, page->vaddr, dma);
-	list_del(&page->page_list);
+		dma_free_coherent(pool->dev,
+				  pool->allocation,
+				  page->vaddr,
+				  page->dma);
+	}
+
+	/*
+	 * If the pool is being destroyed, it is not safe to modify the
+	 * page_tree while iterating over it, and it is also unnecessary since
+	 * the whole tree will be discarded anyway.
+	 */
+	if (!destroying_pool)
+		rb_erase(&page->page_node, &pool->page_tree);
 	list_del(&page->avail_page_link);
 	kfree(page);
 }
@@ -277,6 +363,7 @@ static void pool_free_page(struct dma_po
  */
 void dma_pool_destroy(struct dma_pool *pool)
 {
+	struct dma_page *page, *tmp_page;
 	bool empty = false;
 
 	if (unlikely(!pool))
@@ -292,24 +379,11 @@ void dma_pool_destroy(struct dma_pool *p
 		device_remove_file(pool->dev, &dev_attr_pools);
 	mutex_unlock(&pools_reg_lock);
 
-	while (!list_empty(&pool->page_list)) {
-		struct dma_page *page;
-		page = list_entry(pool->page_list.next,
-				  struct dma_page, page_list);
-		if (is_page_busy(page)) {
-			if (pool->dev)
-				dev_err(pool->dev,
-					"dma_pool_destroy %s, %p busy\n",
-					pool->name, page->vaddr);
-			else
-				pr_err("dma_pool_destroy %s, %p busy\n",
-				       pool->name, page->vaddr);
-			/* leak the still-in-use consistent memory */
-			list_del(&page->page_list);
-			list_del(&page->avail_page_link);
-			kfree(page);
-		} else
-			pool_free_page(pool, page);
+	rbtree_postorder_for_each_entry_safe(page,
+					     tmp_page,
+					     &pool->page_tree,
+					     page_node) {
+		pool_free_page(pool, page, true);
 	}
 
 	kfree(pool);
@@ -353,7 +427,15 @@ void *dma_pool_alloc(struct dma_pool *po
 
 	spin_lock_irqsave(&pool->lock, flags);
 
-	list_add(&page->page_list, &pool->page_list);
+	if (unlikely(pool_insert_page(pool, page))) {
+		/*
+		 * This should not happen, so something must have gone horribly
+		 * wrong.  Instead of crashing, intentionally leak the memory
+		 * and make for the exit.
+		 */
+		spin_unlock_irqrestore(&pool->lock, flags);
+		return NULL;
+	}
 	list_add(&page->avail_page_link, &pool->avail_page_list);
  ready:
 	page->in_use++;
@@ -400,19 +482,6 @@ void *dma_pool_alloc(struct dma_pool *po
 }
 EXPORT_SYMBOL(dma_pool_alloc);
 
-static struct dma_page *pool_find_page(struct dma_pool *pool, dma_addr_t dma)
-{
-	struct dma_page *page;
-
-	list_for_each_entry(page, &pool->page_list, page_list) {
-		if (dma < page->dma)
-			continue;
-		if ((dma - page->dma) < pool->allocation)
-			return page;
-	}
-	return NULL;
-}
-
 /**
  * dma_pool_free - put block back into dma pool
  * @pool: the dma pool holding the block
@@ -484,7 +553,7 @@ void dma_pool_free(struct dma_pool *pool
 	page->offset = offset;
 	/*
 	 * Resist a temptation to do
-	 *    if (!is_page_busy(page)) pool_free_page(pool, page);
+	 *    if (!is_page_busy(page)) pool_free_page(pool, page, false);
 	 * Better have a few empty pages hang around.
 	 */
 	spin_unlock_irqrestore(&pool->lock, flags);
