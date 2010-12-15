Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E52FF6B0093
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 15:38:39 -0500 (EST)
Received: from spt2.w1.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LDH0063HLCCZQ@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Wed, 15 Dec 2010 20:38:36 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LDH00HM0LCBI7@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 15 Dec 2010 20:38:36 +0000 (GMT)
Date: Wed, 15 Dec 2010 21:34:23 +0100
From: Michal Nazarewicz <m.nazarewicz@samsung.com>
Subject: [PATCHv8 03/12] lib: genalloc: Generic allocator improvements
In-reply-to: <cover.1292443200.git.m.nazarewicz@samsung.com>
Message-id: 
 <31e3629b4eef8e8e3f3c4550b15862790a543d03.1292443200.git.m.nazarewicz@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <cover.1292443200.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This commit adds a gen_pool_alloc_aligned() function to the
generic allocator API.  It allows specifying alignment for the
allocated block.  This feature uses
the bitmap_find_next_zero_area_off() function.

It also fixes possible issue with bitmap's last element being
not fully allocated (ie. space allocated for chunk->bits is
not a multiple of sizeof(long)).

It also makes some other smaller changes:
- moves structure definitions out of the header file,
- adds __must_check to functions returning value,
- makes gen_pool_add() return -ENOMEM rater than -1 on error,
- changes list_for_each to list_for_each_entry, and
- makes use of bitmap_clear().

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
---
 include/linux/genalloc.h |   46 ++++++------
 lib/genalloc.c           |  182 ++++++++++++++++++++++++++-------------------
 2 files changed, 129 insertions(+), 99 deletions(-)

diff --git a/include/linux/genalloc.h b/include/linux/genalloc.h
index 9869ef3..8ac7337 100644
--- a/include/linux/genalloc.h
+++ b/include/linux/genalloc.h
@@ -8,29 +8,31 @@
  * Version 2.  See the file COPYING for more details.
  */
 
+struct gen_pool;
 
-/*
- *  General purpose special memory pool descriptor.
- */
-struct gen_pool {
-	rwlock_t lock;
-	struct list_head chunks;	/* list of chunks in this pool */
-	int min_alloc_order;		/* minimum allocation order */
-};
+struct gen_pool *__must_check gen_pool_create(unsigned order, int nid);
 
-/*
- *  General purpose special memory pool chunk descriptor.
+int __must_check gen_pool_add(struct gen_pool *pool, unsigned long addr,
+			      size_t size, int nid);
+
+void gen_pool_destroy(struct gen_pool *pool);
+
+unsigned long __must_check
+gen_pool_alloc_aligned(struct gen_pool *pool, size_t size,
+		       unsigned alignment_order);
+
+/**
+ * gen_pool_alloc() - allocate special memory from the pool
+ * @pool:	Pool to allocate from.
+ * @size:	Number of bytes to allocate from the pool.
+ *
+ * Allocate the requested number of bytes from the specified pool.
+ * Uses a first-fit algorithm.
  */
-struct gen_pool_chunk {
-	spinlock_t lock;
-	struct list_head next_chunk;	/* next chunk in pool */
-	unsigned long start_addr;	/* starting address of memory chunk */
-	unsigned long end_addr;		/* ending address of memory chunk */
-	unsigned long bits[0];		/* bitmap for allocating memory chunk */
-};
+static inline unsigned long __must_check
+gen_pool_alloc(struct gen_pool *pool, size_t size)
+{
+	return gen_pool_alloc_aligned(pool, size, 0);
+}
 
-extern struct gen_pool *gen_pool_create(int, int);
-extern int gen_pool_add(struct gen_pool *, unsigned long, size_t, int);
-extern void gen_pool_destroy(struct gen_pool *);
-extern unsigned long gen_pool_alloc(struct gen_pool *, size_t);
-extern void gen_pool_free(struct gen_pool *, unsigned long, size_t);
+void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size);
diff --git a/lib/genalloc.c b/lib/genalloc.c
index 1923f14..0761079 100644
--- a/lib/genalloc.c
+++ b/lib/genalloc.c
@@ -16,53 +16,80 @@
 #include <linux/genalloc.h>
 
 
+/* General purpose special memory pool descriptor. */
+struct gen_pool {
+	rwlock_t lock;			/* protects chunks list */
+	struct list_head chunks;	/* list of chunks in this pool */
+	unsigned order;			/* minimum allocation order */
+};
+
+/* General purpose special memory pool chunk descriptor. */
+struct gen_pool_chunk {
+	spinlock_t lock;		/* protects bits */
+	struct list_head next_chunk;	/* next chunk in pool */
+	unsigned long start;		/* start of memory chunk */
+	unsigned long size;		/* number of bits */
+	unsigned long bits[0];		/* bitmap for allocating memory chunk */
+};
+
+
 /**
- * gen_pool_create - create a new special memory pool
- * @min_alloc_order: log base 2 of number of bytes each bitmap bit represents
- * @nid: node id of the node the pool structure should be allocated on, or -1
+ * gen_pool_create() - create a new special memory pool
+ * @order:	Log base 2 of number of bytes each bitmap bit
+ *		represents.
+ * @nid:	Node id of the node the pool structure should be allocated
+ *		on, or -1.  This will be also used for other allocations.
  *
  * Create a new special memory pool that can be used to manage special purpose
  * memory not managed by the regular kmalloc/kfree interface.
  */
-struct gen_pool *gen_pool_create(int min_alloc_order, int nid)
+struct gen_pool *__must_check gen_pool_create(unsigned order, int nid)
 {
 	struct gen_pool *pool;
 
-	pool = kmalloc_node(sizeof(struct gen_pool), GFP_KERNEL, nid);
-	if (pool != NULL) {
+	if (WARN_ON(order >= BITS_PER_LONG))
+		return NULL;
+
+	pool = kmalloc_node(sizeof *pool, GFP_KERNEL, nid);
+	if (pool) {
 		rwlock_init(&pool->lock);
 		INIT_LIST_HEAD(&pool->chunks);
-		pool->min_alloc_order = min_alloc_order;
+		pool->order = order;
 	}
 	return pool;
 }
 EXPORT_SYMBOL(gen_pool_create);
 
 /**
- * gen_pool_add - add a new chunk of special memory to the pool
- * @pool: pool to add new memory chunk to
- * @addr: starting address of memory chunk to add to pool
- * @size: size in bytes of the memory chunk to add to pool
- * @nid: node id of the node the chunk structure and bitmap should be
- *       allocated on, or -1
+ * gen_pool_add() - add a new chunk of special memory to the pool
+ * @pool:	Pool to add new memory chunk to.
+ * @addr:	Starting address of memory chunk to add to pool.
+ * @size:	Size in bytes of the memory chunk to add to pool.
  *
  * Add a new chunk of special memory to the specified pool.
  */
-int gen_pool_add(struct gen_pool *pool, unsigned long addr, size_t size,
-		 int nid)
+int __must_check
+gen_pool_add(struct gen_pool *pool, unsigned long addr, size_t size, int nid)
 {
 	struct gen_pool_chunk *chunk;
-	int nbits = size >> pool->min_alloc_order;
-	int nbytes = sizeof(struct gen_pool_chunk) +
-				(nbits + BITS_PER_BYTE - 1) / BITS_PER_BYTE;
+	size_t nbytes;
+
+	if (WARN_ON(!addr || addr + size < addr ||
+		    (addr & ((1 << pool->order) - 1))))
+		return -EINVAL;
 
-	chunk = kmalloc_node(nbytes, GFP_KERNEL | __GFP_ZERO, nid);
-	if (unlikely(chunk == NULL))
-		return -1;
+	size = size >> pool->order;
+	if (WARN_ON(!size))
+		return -EINVAL;
+
+	nbytes = sizeof *chunk + BITS_TO_LONGS(size) * sizeof *chunk->bits;
+	chunk = kzalloc_node(nbytes, GFP_KERNEL, nid);
+	if (!chunk)
+		return -ENOMEM;
 
 	spin_lock_init(&chunk->lock);
-	chunk->start_addr = addr;
-	chunk->end_addr = addr + size;
+	chunk->start = addr >> pool->order;
+	chunk->size  = size;
 
 	write_lock(&pool->lock);
 	list_add(&chunk->next_chunk, &pool->chunks);
@@ -73,115 +100,116 @@ int gen_pool_add(struct gen_pool *pool, unsigned long addr, size_t size,
 EXPORT_SYMBOL(gen_pool_add);
 
 /**
- * gen_pool_destroy - destroy a special memory pool
- * @pool: pool to destroy
+ * gen_pool_destroy() - destroy a special memory pool
+ * @pool:	Pool to destroy.
  *
  * Destroy the specified special memory pool. Verifies that there are no
  * outstanding allocations.
  */
 void gen_pool_destroy(struct gen_pool *pool)
 {
-	struct list_head *_chunk, *_next_chunk;
 	struct gen_pool_chunk *chunk;
-	int order = pool->min_alloc_order;
-	int bit, end_bit;
-
+	int bit;
 
-	list_for_each_safe(_chunk, _next_chunk, &pool->chunks) {
-		chunk = list_entry(_chunk, struct gen_pool_chunk, next_chunk);
+	while (!list_empty(&pool->chunks)) {
+		chunk = list_entry(pool->chunks.next, struct gen_pool_chunk,
+				   next_chunk);
 		list_del(&chunk->next_chunk);
 
-		end_bit = (chunk->end_addr - chunk->start_addr) >> order;
-		bit = find_next_bit(chunk->bits, end_bit, 0);
-		BUG_ON(bit < end_bit);
+		bit = find_next_bit(chunk->bits, chunk->size, 0);
+		BUG_ON(bit < chunk->size);
 
 		kfree(chunk);
 	}
 	kfree(pool);
-	return;
 }
 EXPORT_SYMBOL(gen_pool_destroy);
 
 /**
- * gen_pool_alloc - allocate special memory from the pool
- * @pool: pool to allocate from
- * @size: number of bytes to allocate from the pool
+ * gen_pool_alloc_aligned() - allocate special memory from the pool
+ * @pool:	Pool to allocate from.
+ * @size:	Number of bytes to allocate from the pool.
+ * @alignment_order:	Order the allocated space should be
+ *			aligned to (eg. 20 means allocated space
+ *			must be aligned to 1MiB).
  *
  * Allocate the requested number of bytes from the specified pool.
  * Uses a first-fit algorithm.
  */
-unsigned long gen_pool_alloc(struct gen_pool *pool, size_t size)
+unsigned long __must_check
+gen_pool_alloc_aligned(struct gen_pool *pool, size_t size,
+		       unsigned alignment_order)
 {
-	struct list_head *_chunk;
+	unsigned long addr, align_mask = 0, flags, start;
 	struct gen_pool_chunk *chunk;
-	unsigned long addr, flags;
-	int order = pool->min_alloc_order;
-	int nbits, start_bit, end_bit;
 
 	if (size == 0)
 		return 0;
 
-	nbits = (size + (1UL << order) - 1) >> order;
+	if (alignment_order > pool->order)
+		align_mask = (1 << (alignment_order - pool->order)) - 1;
 
-	read_lock(&pool->lock);
-	list_for_each(_chunk, &pool->chunks) {
-		chunk = list_entry(_chunk, struct gen_pool_chunk, next_chunk);
+	size = (size + (1UL << pool->order) - 1) >> pool->order;
 
-		end_bit = (chunk->end_addr - chunk->start_addr) >> order;
+	read_lock(&pool->lock);
+	list_for_each_entry(chunk, &pool->chunks, next_chunk) {
+		if (chunk->size < size)
+			continue;
 
 		spin_lock_irqsave(&chunk->lock, flags);
-		start_bit = bitmap_find_next_zero_area(chunk->bits, end_bit, 0,
-						nbits, 0);
-		if (start_bit >= end_bit) {
+		start = bitmap_find_next_zero_area_off(chunk->bits, chunk->size,
+						       0, size, align_mask,
+						       chunk->start);
+		if (start >= chunk->size) {
 			spin_unlock_irqrestore(&chunk->lock, flags);
 			continue;
 		}
 
-		addr = chunk->start_addr + ((unsigned long)start_bit << order);
-
-		bitmap_set(chunk->bits, start_bit, nbits);
+		bitmap_set(chunk->bits, start, size);
 		spin_unlock_irqrestore(&chunk->lock, flags);
-		read_unlock(&pool->lock);
-		return addr;
+		addr = (chunk->start + start) << pool->order;
+		goto done;
 	}
+
+	addr = 0;
+done:
 	read_unlock(&pool->lock);
-	return 0;
+	return addr;
 }
-EXPORT_SYMBOL(gen_pool_alloc);
+EXPORT_SYMBOL(gen_pool_alloc_aligned);
 
 /**
- * gen_pool_free - free allocated special memory back to the pool
- * @pool: pool to free to
- * @addr: starting address of memory to free back to pool
- * @size: size in bytes of memory to free
+ * gen_pool_free() - free allocated special memory back to the pool
+ * @pool:	Pool to free to.
+ * @addr:	Starting address of memory to free back to pool.
+ * @size:	Size in bytes of memory to free.
  *
  * Free previously allocated special memory back to the specified pool.
  */
 void gen_pool_free(struct gen_pool *pool, unsigned long addr, size_t size)
 {
-	struct list_head *_chunk;
 	struct gen_pool_chunk *chunk;
 	unsigned long flags;
-	int order = pool->min_alloc_order;
-	int bit, nbits;
 
-	nbits = (size + (1UL << order) - 1) >> order;
+	if (!size)
+		return;
 
-	read_lock(&pool->lock);
-	list_for_each(_chunk, &pool->chunks) {
-		chunk = list_entry(_chunk, struct gen_pool_chunk, next_chunk);
+	addr = addr >> pool->order;
+	size = (size + (1UL << pool->order) - 1) >> pool->order;
+
+	BUG_ON(addr + size < addr);
 
-		if (addr >= chunk->start_addr && addr < chunk->end_addr) {
-			BUG_ON(addr + size > chunk->end_addr);
+	read_lock(&pool->lock);
+	list_for_each_entry(chunk, &pool->chunks, next_chunk)
+		if (addr >= chunk->start &&
+		    addr + size <= chunk->start + chunk->size) {
 			spin_lock_irqsave(&chunk->lock, flags);
-			bit = (addr - chunk->start_addr) >> order;
-			while (nbits--)
-				__clear_bit(bit++, chunk->bits);
+			bitmap_clear(chunk->bits, addr - chunk->start, size);
 			spin_unlock_irqrestore(&chunk->lock, flags);
-			break;
+			goto done;
 		}
-	}
-	BUG_ON(nbits > 0);
+	BUG_ON(1);
+done:
 	read_unlock(&pool->lock);
 }
 EXPORT_SYMBOL(gen_pool_free);
-- 
1.7.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
