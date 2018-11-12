Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B580D6B02A2
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 10:45:29 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id w185so24919232qka.9
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 07:45:29 -0800 (PST)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id k5si3203197qkb.174.2018.11.12.07.45.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 07:45:28 -0800 (PST)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v4 7/9] dmapool: cleanup integer types
Message-ID: <39edbec6-9c58-e6f0-61ab-02cb94ab4146@cybernetics.com>
Date: Mon, 12 Nov 2018 10:45:21 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org
Cc: linux-scsi@vger.kernel.org

To represent the size of a single allocation, dmapool currently uses
'unsigned int' in some places and 'size_t' in other places.  Standardize
on 'unsigned int' to reduce overhead, but use 'size_t' when counting all
the blocks in the entire pool.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---

This puts an upper bound on 'size' of INT_MAX to avoid overflowing the
following comparison in pool_initialize_free_block_list():

unsigned int offset = 0;
unsigned int next = offset + pool->size;
if (unlikely((next + pool->size) > ...

The actual maximum allocation size is probably lower anyway, probably
KMALLOC_MAX_SIZE, but that gets into the implementation details of other
subsystems which don't export a predefined maximum, so I didn't want to
hardcode it here.  The purpose of the added bounds check is to avoid
overflowing integers, not to check the actual
(platform/device/config-specific?) maximum allocation size.

'boundary' is passed in as a size_t but gets stored as an unsigned int. 
'boundary' values >= 'allocation' do not have any effect, so clipping
'boundary' to 'allocation' keeps it within the range of unsigned int
without affecting anything else.  A few lines above (not in the diff)
you can see that if 'boundary' is passed in as 0 then it is set to
'allocation', so it is nothing new.  For reference, here is the
relevant code after being patched:

	if (!boundary)
		boundary = allocation;
	else if ((boundary < size) || (boundary & (boundary - 1)))
		return NULL;

	boundary = min(boundary, allocation);

--- linux/mm/dmapool.c.orig	2018-08-06 17:48:19.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-06 17:48:54.000000000 -0400
@@ -57,10 +57,10 @@ struct dma_pool {		/* the pool */
 #define POOL_MAX_IDX    2
 	struct list_head page_list[POOL_MAX_IDX];
 	spinlock_t lock;
-	size_t size;
+	unsigned int size;
 	struct device *dev;
-	size_t allocation;
-	size_t boundary;
+	unsigned int allocation;
+	unsigned int boundary;
 	char name[32];
 	struct list_head pools;
 };
@@ -86,7 +86,7 @@ show_pools(struct device *dev, struct de
 	mutex_lock(&pools_lock);
 	list_for_each_entry(pool, &dev->dma_pools, pools) {
 		unsigned pages = 0;
-		unsigned blocks = 0;
+		size_t blocks = 0;
 		int list_idx;
 
 		spin_lock_irq(&pool->lock);
@@ -103,9 +103,10 @@ show_pools(struct device *dev, struct de
 		spin_unlock_irq(&pool->lock);
 
 		/* per-pool info, no real statistics yet */
-		temp = scnprintf(next, size, "%-16s %4u %4zu %4zu %2u\n",
+		temp = scnprintf(next, size, "%-16s %4zu %4zu %4u %2u\n",
 				 pool->name, blocks,
-				 pages * (pool->allocation / pool->size),
+				 (size_t) pages *
+				 (pool->allocation / pool->size),
 				 pool->size, pages);
 		size -= temp;
 		next += temp;
@@ -150,7 +151,7 @@ struct dma_pool *dma_pool_create(const c
 	else if (align & (align - 1))
 		return NULL;
 
-	if (size == 0)
+	if (size == 0 || size > INT_MAX)
 		return NULL;
 	else if (size < 4)
 		size = 4;
@@ -165,6 +166,8 @@ struct dma_pool *dma_pool_create(const c
 	else if ((boundary < size) || (boundary & (boundary - 1)))
 		return NULL;
 
+	boundary = min(boundary, allocation);
+
 	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
 	if (!retval)
 		return retval;
@@ -344,7 +347,7 @@ void *dma_pool_alloc(struct dma_pool *po
 {
 	unsigned long flags;
 	struct page *page;
-	size_t offset;
+	unsigned int offset;
 	void *retval;
 	void *vaddr;
 
