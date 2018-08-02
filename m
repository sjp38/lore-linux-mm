Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A291E6B026D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 16:01:16 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id e3-v6so3030836qkj.17
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 13:01:16 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id q13-v6si2644705qvd.106.2018.08.02.13.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 13:01:14 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v2 8/9] dmapool: reduce footprint in struct page
Message-ID: <0ccfd31b-0a3f-9ae8-85c8-e176cd5453a9@cybernetics.com>
Date: Thu, 2 Aug 2018 16:01:12 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com

This is my attempt to shrink 'dma_free_o' and 'dma_in_use' in 'struct
page' (originally 'offset' and 'in_use' in 'struct dma_page') to 16-bit
so that it is unnecessary to use the '_mapcount' field of 'struct
page'.  However, it adds complexity and makes allocating and freeing up
to 20% slower for little gain, so I am NOT recommending that it be
merged at this time.  I am posting it just for reference in case someone
finds it useful in the future.

The main difficulty is supporting archs that have PAGE_SIZE > 64 KiB,
for which a 16-bit byte offset is insufficient to cover the entire
page.  So I took the approach of converting everything from a "byte
offset" into a "block index".  That way the code can split any PAGE_SIZE
into as many as 65535 blocks (one 16-bit index value is reserved for the
list terminator).  For example, with PAGE_SIZE of 1 MiB, you get 65535
blocks for 'size' <= 16.  But that introduces a lot of ugly math due to
the 'boundary' checking, which makes the code slower and more complex.

I wrote a standalone program that iterates over all the combinations of
PAGE_SIZE, 'size', and 'boundary', and performs a series of consistency
checks on pool_blk_idx_to_offset(), pool_offset_to_blk_idx(), and
pool_initialize_free_block_list().  The math may be ugly but I am pretty
sure it is correct.

One of the nice things about this is that dma_pool_free() can do some
additional sanity checks:
*) Check that the offset of the passed-in address corresponds to a valid
block offset.
*) With DMAPOOL_DEBUG enabled, check that the number of blocks in the
freelist exactly matches the number that should be there.  This improves
the debug check I added in a previous patch by adding the calculation
for pool->blks_per_alloc.

NOT for merging.
---
--- linux/include/linux/mm_types.h.orig	2018-08-01 12:25:25.000000000 -0400
+++ linux/include/linux/mm_types.h	2018-08-01 12:25:52.000000000 -0400
@@ -156,7 +156,8 @@ struct page {
 		struct {	/* dma_pool pages */
 			struct list_head dma_list;
 			dma_addr_t dma;
-			unsigned int dma_free_o;
+			unsigned short dma_free_idx;
+			unsigned short dma_in_use;
 		};
 
 		/** @rcu_head: You can use this to free a page by RCU. */
@@ -180,8 +181,6 @@ struct page {
 
 		unsigned int active;		/* SLAB */
 		int units;			/* SLOB */
-
-		unsigned int dma_in_use;	/* dma_pool pages */
 	};
 
 	/* Usage count. *DO NOT USE DIRECTLY*. See page_ref.h */
--- linux/mm/dmapool.c.orig	2018-08-02 14:02:42.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-02 14:03:31.000000000 -0400
@@ -51,16 +51,25 @@
 #define DMAPOOL_DEBUG 1
 #endif
 
+/*
+ * This matches the type of struct page::dma_free_idx, which is 16-bit to
+ * conserve space in struct page.
+ */
+typedef unsigned short pool_idx_t;
+#define POOL_IDX_MAX USHRT_MAX
+
 struct dma_pool {		/* the pool */
 #define POOL_FULL_IDX   0
 #define POOL_AVAIL_IDX  1
 #define POOL_N_LISTS    2
 	struct list_head page_list[POOL_N_LISTS];
 	spinlock_t lock;
-	size_t size;
 	struct device *dev;
-	size_t allocation;
-	size_t boundary;
+	unsigned int size;
+	unsigned int allocation;
+	unsigned int boundary_shift;
+	unsigned int blks_per_boundary;
+	unsigned int blks_per_alloc;
 	char name[32];
 	struct list_head pools;
 };
@@ -103,9 +112,9 @@ show_pools(struct device *dev, struct de
 		spin_unlock_irq(&pool->lock);
 
 		/* per-pool info, no real statistics yet */
-		temp = scnprintf(next, size, "%-16s %4u %4zu %4zu %2u\n",
+		temp = scnprintf(next, size, "%-16s %4u %4u %4u %2u\n",
 				 pool->name, blocks,
-				 pages * (pool->allocation / pool->size),
+				 pages * pool->blks_per_alloc,
 				 pool->size, pages);
 		size -= temp;
 		next += temp;
@@ -141,6 +150,7 @@ static DEVICE_ATTR(pools, 0444, show_pool
 struct dma_pool *dma_pool_create(const char *name, struct device *dev,
 				 size_t size, size_t align, size_t boundary)
 {
+	unsigned int boundary_shift;
 	struct dma_pool *retval;
 	size_t allocation;
 	bool empty = false;
@@ -150,10 +160,10 @@ struct dma_pool *dma_pool_create(const c
 	else if (align & (align - 1))
 		return NULL;
 
-	if (size == 0)
+	if (size == 0 || size > SZ_2G)
 		return NULL;
-	else if (size < 4)
-		size = 4;
+	else if (size < sizeof(pool_idx_t))
+		size = sizeof(pool_idx_t);
 
 	if ((size % align) != 0)
 		size = ALIGN(size, align);
@@ -165,6 +175,9 @@ struct dma_pool *dma_pool_create(const c
 	else if ((boundary < size) || (boundary & (boundary - 1)))
 		return NULL;
 
+	boundary_shift = get_count_order_long(min(boundary, allocation));
+	boundary = 1U << boundary_shift;
+
 	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
 	if (!retval)
 		return retval;
@@ -177,8 +190,29 @@ struct dma_pool *dma_pool_create(const c
 	INIT_LIST_HEAD(&retval->page_list[1]);
 	spin_lock_init(&retval->lock);
 	retval->size = size;
-	retval->boundary = boundary;
 	retval->allocation = allocation;
+	retval->boundary_shift = boundary_shift;
+	retval->blks_per_boundary = boundary / size;
+	retval->blks_per_alloc =
+		(allocation / boundary) * retval->blks_per_boundary +
+		(allocation % boundary) / size;
+	if (boundary >= allocation || boundary % size == 0) {
+		/*
+		 * When the blocks are packed together, an individual block
+		 * will never cross the boundary, so the boundary doesn't
+		 * matter in this case.  Enable some faster codepaths that skip
+		 * boundary calculations for a small speedup.
+		 */
+		retval->blks_per_boundary = 0;
+	}
+	if (retval->blks_per_alloc > POOL_IDX_MAX) {
+		/*
+		 * This would only affect archs with large PAGE_SIZE.  Limit
+		 * the total number of blocks per allocation to avoid
+		 * overflowing dma_in_use and dma_free_idx.
+		 */
+		retval->blks_per_alloc = POOL_IDX_MAX;
+	}
 
 	INIT_LIST_HEAD(&retval->pools);
 
@@ -214,20 +248,73 @@ struct dma_pool *dma_pool_create(const c
 }
 EXPORT_SYMBOL(dma_pool_create);
 
+/*
+ * Convert the index of a block of size pool->size to its offset within an
+ * allocated chunk of memory of size pool->allocation.
+ */
+static unsigned int pool_blk_idx_to_offset(struct dma_pool *pool,
+					   unsigned int blk_idx)
+{
+	unsigned int offset;
+
+	if (pool->blks_per_boundary == 0) {
+		offset = blk_idx * pool->size;
+	} else {
+		offset = ((blk_idx / pool->blks_per_boundary) <<
+			  pool->boundary_shift) +
+			 (blk_idx % pool->blks_per_boundary) * pool->size;
+	}
+	return offset;
+}
+
+/*
+ * Convert an offset within an allocated chunk of memory of size
+ * pool->allocation to the index of the possibly-smaller block of size
+ * pool->size.  If the given offset is not located at the beginning of a valid
+ * block, then the return value will be >= pool->blks_per_alloc.
+ */
+static unsigned int pool_offset_to_blk_idx(struct dma_pool *pool,
+					   unsigned int offset)
+{
+	unsigned int blk_idx;
+
+	if (pool->blks_per_boundary == 0) {
+		blk_idx = (likely(offset % pool->size == 0))
+			  ? (offset / pool->size)
+			  : pool->blks_per_alloc;
+	} else {
+		unsigned int offset_within_boundary =
+			offset & ((1U << pool->boundary_shift) - 1);
+		unsigned int idx_within_boundary =
+			offset_within_boundary / pool->size;
+
+		if (likely(offset_within_boundary % pool->size == 0 &&
+			   idx_within_boundary < pool->blks_per_boundary)) {
+			blk_idx = (offset >> pool->boundary_shift) *
+				  pool->blks_per_boundary +
+				  idx_within_boundary;
+		} else {
+			blk_idx = pool->blks_per_alloc;
+		}
+	}
+	return blk_idx;
+}
+
 static void pool_initialize_free_block_list(struct dma_pool *pool, void *vaddr)
 {
+	unsigned int next_boundary = 1U << pool->boundary_shift;
 	unsigned int offset = 0;
-	unsigned int next_boundary = pool->boundary;
+	unsigned int i;
+
+	for (i = 0; i < pool->blks_per_alloc; i++) {
+		*(pool_idx_t *)(vaddr + offset) = (pool_idx_t) i + 1;
 
-	do {
-		unsigned int next = offset + pool->size;
-		if (unlikely((next + pool->size) > next_boundary)) {
-			next = next_boundary;
-			next_boundary += pool->boundary;
+		offset += pool->size;
+		if (unlikely((offset + pool->size) > next_boundary)) {
+			offset = next_boundary;
+			next_boundary += 1U << pool->boundary_shift;
 		}
-		*(int *)(vaddr + offset) = next;
-		offset = next;
-	} while (offset < pool->allocation);
+	}
 }
 
 static struct page *pool_alloc_page(struct dma_pool *pool, gfp_t mem_flags)
@@ -248,7 +335,7 @@ static struct page *pool_alloc_page(stru
 
 	page = virt_to_page(vaddr);
 	page->dma = dma;
-	page->dma_free_o = 0;
+	page->dma_free_idx = 0;
 	page->dma_in_use = 0;
 
 	return page;
@@ -272,8 +359,8 @@ static void pool_free_page(struct dma_po
 	page->dma_list.next = NULL;
 	page->dma_list.prev = NULL;
 	page->dma = 0;
-	page->dma_free_o = 0;
-	page_mapcount_reset(page); /* clear dma_in_use */
+	page->dma_free_idx = 0;
+	page->dma_in_use = 0;
 
 	if (busy) {
 		dev_err(pool->dev,
@@ -342,9 +429,10 @@ EXPORT_SYMBOL(dma_pool_destroy);
 void *dma_pool_alloc(struct dma_pool *pool, gfp_t mem_flags,
 		     dma_addr_t *handle)
 {
+	unsigned int blk_idx;
+	unsigned int offset;
 	unsigned long flags;
 	struct page *page;
-	size_t offset;
 	void *retval;
 	void *vaddr;
 
@@ -370,9 +458,10 @@ void *dma_pool_alloc(struct dma_pool *po
  ready:
 	vaddr = page_to_virt(page);
 	page->dma_in_use++;
-	offset = page->dma_free_o;
-	page->dma_free_o = *(int *)(vaddr + offset);
-	if (page->dma_free_o >= pool->allocation) {
+	blk_idx = page->dma_free_idx;
+	offset = pool_blk_idx_to_offset(pool, blk_idx);
+	page->dma_free_idx = *(pool_idx_t *)(vaddr + offset);
+	if (page->dma_free_idx >= pool->blks_per_alloc) {
 		/* Move page from the "available" list to the "full" list. */
 		list_del(&page->dma_list);
 		list_add(&page->dma_list, &pool->page_list[POOL_FULL_IDX]);
@@ -383,8 +472,8 @@ void *dma_pool_alloc(struct dma_pool *po
 	{
 		int i;
 		u8 *data = retval;
-		/* page->dma_free_o is stored in first 4 bytes */
-		for (i = sizeof(page->dma_free_o); i < pool->size; i++) {
+		/* a pool_idx_t is stored at the beginning of the block */
+		for (i = sizeof(pool_idx_t); i < pool->size; i++) {
 			if (data[i] == POOL_POISON_FREED)
 				continue;
 			dev_err(pool->dev,
@@ -426,6 +515,7 @@ void dma_pool_free(struct dma_pool *pool
 	struct page *page;
 	unsigned long flags;
 	unsigned int offset;
+	unsigned int blk_idx;
 
 	if (unlikely(!virt_addr_valid(vaddr))) {
 		dev_err(pool->dev,
@@ -438,21 +528,28 @@ void dma_pool_free(struct dma_pool *pool
 	offset = offset_in_page(vaddr);
 
 	if (unlikely((dma - page->dma) != offset)) {
+ bad_vaddr:
 		dev_err(pool->dev,
 			"dma_pool_free %s, %p (bad vaddr)/%pad (or bad dma)\n",
 			pool->name, vaddr, &dma);
 		return;
 	}
 
+	blk_idx = pool_offset_to_blk_idx(pool, offset);
+	if (unlikely(blk_idx >= pool->blks_per_alloc))
+		goto bad_vaddr;
+
 	spin_lock_irqsave(&pool->lock, flags);
 #ifdef	DMAPOOL_DEBUG
 	{
 		void *page_vaddr = vaddr - offset;
-		unsigned int chain = page->dma_free_o;
-		size_t total_free = 0;
+		unsigned int chain_idx = page->dma_free_idx;
+		unsigned int n_free = 0;
+
+		while (chain_idx < pool->blks_per_alloc) {
+			unsigned int chain_offset;
 
-		while (chain < pool->allocation) {
-			if (unlikely(chain == offset)) {
+			if (unlikely(chain_idx == blk_idx)) {
 				spin_unlock_irqrestore(&pool->lock, flags);
 				dev_err(pool->dev,
 					"dma_pool_free %s, dma %pad already free\n",
@@ -461,15 +558,15 @@ void dma_pool_free(struct dma_pool *pool
 			}
 
 			/*
-			 * The calculation of the number of blocks per
-			 * allocation is actually more complicated than this
-			 * because of the boundary value.  But this comparison
-			 * does not need to be exact; it just needs to prevent
-			 * an endless loop in case a buggy driver causes a
-			 * circular loop in the freelist.
+			 * A buggy driver could corrupt the freelist by
+			 * use-after-free, buffer overflow, etc.  Besides
+			 * checking for corruption, this also prevents an
+			 * endless loop in case corruption causes a circular
+			 * loop in the freelist.
 			 */
-			total_free += pool->size;
-			if (unlikely(total_free >= pool->allocation)) {
+			if (unlikely(++n_free + page->dma_in_use >
+				     pool->blks_per_alloc)) {
+ freelist_corrupt:
 				spin_unlock_irqrestore(&pool->lock, flags);
 				dev_err(pool->dev,
 					"dma_pool_free %s, freelist corrupted\n",
@@ -477,20 +574,24 @@ void dma_pool_free(struct dma_pool *pool
 				return;
 			}
 
-			chain = *(int *)(page_vaddr + chain);
+			chain_offset = pool_blk_idx_to_offset(pool, chain_idx);
+			chain_idx =
+				*(pool_idx_t *) (page_vaddr + chain_offset);
 		}
+		if (n_free + page->dma_in_use != pool->blks_per_alloc)
+			goto freelist_corrupt;
 	}
 	memset(vaddr, POOL_POISON_FREED, pool->size);
 #endif
 
 	page->dma_in_use--;
-	if (page->dma_free_o >= pool->allocation) {
+	if (page->dma_free_idx >= pool->blks_per_alloc) {
 		/* Move page from the "full" list to the "available" list. */
 		list_del(&page->dma_list);
 		list_add(&page->dma_list, &pool->page_list[POOL_AVAIL_IDX]);
 	}
-	*(int *)vaddr = page->dma_free_o;
-	page->dma_free_o = offset;
+	*(pool_idx_t *)vaddr = page->dma_free_idx;
+	page->dma_free_idx = blk_idx;
 	/*
 	 * Resist a temptation to do
 	 *    if (!is_page_busy(page)) pool_free_page(pool, page);
