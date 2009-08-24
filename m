Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EF7686B00B2
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 16:31:37 -0400 (EDT)
Received: by pzk36 with SMTP id 36so1837948pzk.12
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 13:31:36 -0700 (PDT)
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
Subject: [PATCH 1/4] compcache: xvmalloc memory allocator
Date: Mon, 24 Aug 2009 10:07:47 +0530
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200908241007.47910.ngupta@vflare.org>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org
List-ID: <linux-mm.kvack.org>

xvmalloc is a memory allocator designed specifically for ramzswap project.

* Features:
 - Low metadata overhead (just 4 bytes per object)
 - O(1) Alloc/Free - except when we have to call system page allocator to
   get additional memory.
 - Very low fragmentation: In all tests, xvmalloc memory usage is within 12%
   of "Ideal".
 - Pool based allocator: Each pool can grow and shrink.
 - It maps pages only when required. So, it does not hog vmalloc area which
   is very small on 32-bit systems.

SLUB allocator could not be used due to fragmentation issues:
http://code.google.com/p/compcache/wiki/AllocatorsComparison
Data here shows kmalloc using ~43% more memory than TLSF and xvMalloc
is showed ~2% more space efficiency than TLSF (due to smaller metadata).
Creating various kmem_caches can reduce space efficiency gap but still
problem of being limited to low memory exists. Also, it depends on
allocating higher order pages to reduce fragmentation - this is not
acceptable for ramzswap as it is used under memory crunch (its a swap
device!).

SLOB allocator could not be used do to reasons mentioned here:
http://lkml.org/lkml/2009/3/18/210

* Implementation:
It uses two-level bitmap search to find free list containing block of
correct size. This idea is taken from TLSF (Two-Level Segregate Fit)
allocator and is well explained in its paper (see [Links] below).

* Limitations:
 - Poor scalability: No per-cpu data structures (work in progress).

[Links]
1. Details and Performance data:
http://code.google.com/p/compcache/wiki/xvMalloc
http://code.google.com/p/compcache/wiki/xvMallocPerformance

2. TLSF memory allocator:
home: http://rtportal.upv.es/rtmalloc/
paper: http://rtportal.upv.es/rtmalloc/files/MRBC_2008.pdf

Signed-off-by: Nitin Gupta <ngupta@vflare.org>
---

 drivers/block/ramzswap/xvmalloc.c     |  556 +++++++++++++++++++++++++++++++++
 drivers/block/ramzswap/xvmalloc.h     |   30 ++
 drivers/block/ramzswap/xvmalloc_int.h |   86 +++++
 3 files changed, 672 insertions(+), 0 deletions(-)

diff --git a/drivers/block/ramzswap/xvmalloc.c b/drivers/block/ramzswap/xvmalloc.c
new file mode 100644
index 0000000..57a3639
--- /dev/null
+++ b/drivers/block/ramzswap/xvmalloc.c
@@ -0,0 +1,556 @@
+/*
+ * xvmalloc memory allocator
+ *
+ * Copyright (C) 2008, 2009  Nitin Gupta
+ *
+ * This code is released using a dual license strategy: BSD/GPL
+ * You can choose the licence that better fits your requirements.
+ *
+ * Released under the terms of 3-clause BSD License
+ * Released under the terms of GNU General Public License Version 2.0
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/bitops.h>
+#include <linux/errno.h>
+#include <linux/highmem.h>
+#include <linux/init.h>
+#include <linux/string.h>
+#include <linux/slab.h>
+
+#include "xvmalloc.h"
+#include "xvmalloc_int.h"
+
+static void stat_inc(u64 *value)
+{
+	*value = *value + 1;
+}
+
+static void stat_dec(u64 *value)
+{
+	*value = *value - 1;
+}
+
+static int test_flag(struct block_header *block, enum blockflags flag)
+{
+	return block->prev & BIT(flag);
+}
+
+static void set_flag(struct block_header *block, enum blockflags flag)
+{
+	block->prev |= BIT(flag);
+}
+
+static void clear_flag(struct block_header *block, enum blockflags flag)
+{
+	block->prev &= ~BIT(flag);
+}
+
+/*
+ * Given <pagenum, offset> pair, provide a derefrencable pointer.
+ * This is called from xv_malloc/xv_free path, so it needs to be fast.
+ */
+static void *get_ptr_atomic(u32 pagenum, u16 offset, enum km_type type)
+{
+	unsigned char *base;
+
+	base = kmap_atomic(pfn_to_page(pagenum), type);
+	return base + offset;
+}
+
+static void put_ptr_atomic(void *ptr, enum km_type type)
+{
+	kunmap_atomic(ptr, type);
+}
+
+static u32 get_blockprev(struct block_header *block)
+{
+	return block->prev & PREV_MASK;
+}
+
+static void set_blockprev(struct block_header *block, u16 new_offset)
+{
+	block->prev = new_offset | (block->prev & FLAGS_MASK);
+}
+
+static struct block_header *BLOCK_NEXT(struct block_header *block)
+{
+	return (struct block_header *)((char *)block + block->size + XV_ALIGN);
+}
+
+/*
+ * Get index of free list containing blocks of maximum size
+ * which is less than or equal to given size.
+ */
+static u32 get_index_for_insert(u32 size)
+{
+	if (unlikely(size > XV_MAX_ALLOC_SIZE))
+		size = XV_MAX_ALLOC_SIZE;
+	size &= ~FL_DELTA_MASK;
+	return (size - XV_MIN_ALLOC_SIZE) >> FL_DELTA_SHIFT;
+}
+
+/*
+ * Get index of free list having blocks of size greater than
+ * or equal to requested size.
+ */
+static u32 get_index(u32 size)
+{
+	if (unlikely(size < XV_MIN_ALLOC_SIZE))
+		size = XV_MIN_ALLOC_SIZE;
+	size = ALIGN(size, FL_DELTA);
+	return (size - XV_MIN_ALLOC_SIZE) >> FL_DELTA_SHIFT;
+}
+
+/*
+ * Allocate a memory page. Called when a pool needs to grow.
+ */
+static u32 xv_alloc_page(gfp_t flags)
+{
+	struct page *page;
+
+	page = alloc_page(flags);
+	if (unlikely(!page))
+		return 0;
+
+	return page_to_pfn(page);
+}
+
+/*
+ * Called when all objects in a page are freed.
+ */
+static void xv_free_page(u32 pagenum)
+{
+	__free_page(pfn_to_page(pagenum));
+}
+
+/**
+ * find_block - find block of at least given size
+ * @pool: memory pool to search from
+ * @size: size of block required
+ * @pagenum: page no. containing required block
+ * @offset: offset within the page where block is located.
+ *
+ * Searches two level bitmap to locate block of at least
+ * the given size. If such a block is found, it provides
+ * <pagenum, offset> to identify this block and returns index
+ * in freelist where we found this block.
+ * Otherwise, returns 0 and <pagenum, offset> params are not touched.
+ */
+static u32 find_block(struct xv_pool *pool, u32 size,
+			u32 *pagenum, u32 *offset)
+{
+	ulong flbitmap, slbitmap;
+	u32 flindex, slindex, slbitstart;
+
+	/* There are no free blocks in this pool */
+	if (!pool->flbitmap)
+		return 0;
+
+	/* Get freelist index correspoding to this size */
+	slindex = get_index(size);
+	slbitmap = pool->slbitmap[slindex / BITS_PER_LONG];
+	slbitstart = slindex % BITS_PER_LONG;
+
+	/*
+	 * If freelist is not empty at this index, we found the
+	 * block - head of this list. This is approximate best-fit match.
+	 */
+	if (test_bit(slbitstart, &slbitmap)) {
+		*pagenum = pool->freelist[slindex].pagenum;
+		*offset = pool->freelist[slindex].offset;
+		return slindex;
+	}
+
+	/*
+	 * No best-fit found. Search a bit further in bitmap for a free block.
+	 * Second level bitmap consists of series of 32-bit chunks. Search
+	 * further in the chunk where we expected a best-fit, starting from
+	 * index location found above.
+	 */
+	slbitstart++;
+	slbitmap >>= slbitstart;
+
+	/* Skip this search if we were already at end of this bitmap chunk */
+	if ((slbitstart != BITS_PER_LONG) && slbitmap) {
+		slindex += __ffs(slbitmap) + 1;
+		*pagenum = pool->freelist[slindex].pagenum;
+		*offset = pool->freelist[slindex].offset;
+		return slindex;
+	}
+
+	/* Now do a full two-level bitmap search to find next nearest fit */
+	flindex = slindex / BITS_PER_LONG;
+
+	flbitmap = (pool->flbitmap) >> (flindex + 1);
+	if (!flbitmap)
+		return 0;
+
+	flindex += __ffs(flbitmap) + 1;
+	slbitmap = pool->slbitmap[flindex];
+	slindex = (flindex * BITS_PER_LONG) + __ffs(slbitmap);
+	*pagenum = pool->freelist[slindex].pagenum;
+	*offset = pool->freelist[slindex].offset;
+
+	return slindex;
+}
+
+/*
+ * Insert block at <pagenum, offset> in freelist of given pool.
+ * freelist used depends on block size.
+ */
+static void insert_block(struct xv_pool *pool, u32 pagenum, u32 offset,
+			struct block_header *block)
+{
+	u32 flindex, slindex;
+	struct block_header *nextblock;
+
+	slindex = get_index_for_insert(block->size);
+	flindex = slindex / BITS_PER_LONG;
+
+	block->link.prev_pagenum = 0;
+	block->link.prev_offset = 0;
+	block->link.next_pagenum = pool->freelist[slindex].pagenum;
+	block->link.next_offset = pool->freelist[slindex].offset;
+	pool->freelist[slindex].pagenum = pagenum;
+	pool->freelist[slindex].offset = offset;
+
+	if (block->link.next_pagenum) {
+		nextblock = get_ptr_atomic(block->link.next_pagenum,
+					block->link.next_offset, KM_USER1);
+		nextblock->link.prev_pagenum = pagenum;
+		nextblock->link.prev_offset = offset;
+		put_ptr_atomic(nextblock, KM_USER1);
+	}
+
+	__set_bit(slindex % BITS_PER_LONG, &pool->slbitmap[flindex]);
+	__set_bit(flindex, &pool->flbitmap);
+}
+
+/*
+ * Remove block from head of freelist. Index 'slindex' identifies the freelist.
+ */
+static void remove_block_head(struct xv_pool *pool,
+			struct block_header *block, u32 slindex)
+{
+	struct block_header *tmpblock;
+	u32 flindex = slindex / BITS_PER_LONG;
+
+	pool->freelist[slindex].pagenum = block->link.next_pagenum;
+	pool->freelist[slindex].offset = block->link.next_offset;
+	block->link.prev_pagenum = 0;
+	block->link.prev_offset = 0;
+
+	if (!pool->freelist[slindex].pagenum) {
+		__clear_bit(slindex % BITS_PER_LONG, &pool->slbitmap[flindex]);
+		if (!pool->slbitmap[flindex])
+			__clear_bit(flindex, &pool->flbitmap);
+	} else {
+		/*
+		 * DEBUG ONLY: We need not reinitialize freelist head previous
+		 * pointer to 0 - we never depend on its value. But just for
+		 * sanity, lets do it.
+		 */
+		tmpblock = get_ptr_atomic(pool->freelist[slindex].pagenum,
+				pool->freelist[slindex].offset, KM_USER1);
+		tmpblock->link.prev_pagenum = 0;
+		tmpblock->link.prev_offset = 0;
+		put_ptr_atomic(tmpblock, KM_USER1);
+	}
+}
+
+/*
+ * Remove block from freelist. Index 'slindex' identifies the freelist.
+ */
+static void remove_block(struct xv_pool *pool, u32 pagenum, u32 offset,
+			struct block_header *block, u32 slindex)
+{
+	u32 flindex;
+	struct block_header *tmpblock;
+
+	if (pool->freelist[slindex].pagenum == pagenum
+	   && pool->freelist[slindex].offset == offset) {
+		remove_block_head(pool, block, slindex);
+		return;
+	}
+
+	flindex = slindex / BITS_PER_LONG;
+
+	if (block->link.prev_pagenum) {
+		tmpblock = get_ptr_atomic(block->link.prev_pagenum,
+				block->link.prev_offset, KM_USER1);
+		tmpblock->link.next_pagenum = block->link.next_pagenum;
+		tmpblock->link.next_offset = block->link.next_offset;
+		put_ptr_atomic(tmpblock, KM_USER1);
+	}
+
+	if (block->link.next_pagenum) {
+		tmpblock = get_ptr_atomic(block->link.next_pagenum,
+				block->link.next_offset, KM_USER1);
+		tmpblock->link.prev_pagenum = block->link.prev_pagenum;
+		tmpblock->link.prev_offset = block->link.prev_offset;
+		put_ptr_atomic(tmpblock, KM_USER1);
+	}
+
+	return;
+}
+
+/*
+ * Allocate a page and add it freelist of given pool.
+ */
+static int grow_pool(struct xv_pool *pool, gfp_t flags)
+{
+	u32 pagenum;
+	struct block_header *block;
+
+	pagenum = xv_alloc_page(flags);
+	if (unlikely(!pagenum))
+		return -ENOMEM;
+
+	stat_inc(&pool->total_pages);
+
+	spin_lock(&pool->lock);
+	block = get_ptr_atomic(pagenum, 0, KM_USER0);
+
+	block->size = PAGE_SIZE - XV_ALIGN;
+	set_flag(block, BLOCK_FREE);
+	clear_flag(block, PREV_FREE);
+	set_blockprev(block, 0);
+
+	insert_block(pool, pagenum, 0, block);
+
+	put_ptr_atomic(block, KM_USER0);
+	spin_unlock(&pool->lock);
+
+	return 0;
+}
+
+/*
+ * Create a memory pool. Allocates freelist, bitmaps and other
+ * per-pool metadata.
+ */
+struct xv_pool *xv_create_pool(void)
+{
+	u32 ovhd_size;
+	struct xv_pool *pool;
+
+	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
+	pool = kzalloc(ovhd_size, GFP_KERNEL);
+	if (!pool)
+		return NULL;
+
+	spin_lock_init(&pool->lock);
+
+	return pool;
+}
+EXPORT_SYMBOL_GPL(xv_create_pool);
+
+void xv_destroy_pool(struct xv_pool *pool)
+{
+	kfree(pool);
+}
+EXPORT_SYMBOL_GPL(xv_destroy_pool);
+
+/**
+ * xv_malloc - Allocate block of given size from pool.
+ * @pool: pool to allocate from
+ * @size: size of block to allocate
+ * @pagenum: page no. that holds the object
+ * @offset: location of object within pagenum
+ *
+ * On success, <pagenum, offset> identifies block allocated
+ * and 0 is returned. On failure, <pagenum, offset> is set to
+ * 0 and -ENOMEM is returned.
+ *
+ * Allocation requests with size > XV_MAX_ALLOC_SIZE will fail.
+ */
+int xv_malloc(struct xv_pool *pool, u32 size, u32 *pagenum, u32 *offset,
+							gfp_t flags)
+{
+	int error;
+	u32 index, tmpsize, origsize, tmpoffset;
+	struct block_header *block, *tmpblock;
+
+	*pagenum = 0;
+	*offset = 0;
+	origsize = size;
+
+	if (unlikely(!size || size > XV_MAX_ALLOC_SIZE))
+		return -ENOMEM;
+
+	size = ALIGN(size, XV_ALIGN);
+
+	spin_lock(&pool->lock);
+
+	index = find_block(pool, size, pagenum, offset);
+
+	if (!*pagenum) {
+		spin_unlock(&pool->lock);
+		if (flags & GFP_NOWAIT)
+			return -ENOMEM;
+		error = grow_pool(pool, flags);
+		if (unlikely(error))
+			return -ENOMEM;
+
+		spin_lock(&pool->lock);
+		index = find_block(pool, size, pagenum, offset);
+	}
+
+	if (!*pagenum) {
+		spin_unlock(&pool->lock);
+		return -ENOMEM;
+	}
+
+	block = get_ptr_atomic(*pagenum, *offset, KM_USER0);
+
+	remove_block_head(pool, block, index);
+
+	/* Split the block if required */
+	tmpoffset = *offset + size + XV_ALIGN;
+	tmpsize = block->size - size;
+	tmpblock = (struct block_header *)((char *)block + size + XV_ALIGN);
+	if (tmpsize) {
+		tmpblock->size = tmpsize - XV_ALIGN;
+		set_flag(tmpblock, BLOCK_FREE);
+		clear_flag(tmpblock, PREV_FREE);
+
+		set_blockprev(tmpblock, *offset);
+		if (tmpblock->size >= XV_MIN_ALLOC_SIZE)
+			insert_block(pool, *pagenum, tmpoffset, tmpblock);
+
+		if (tmpoffset + XV_ALIGN + tmpblock->size != PAGE_SIZE) {
+			tmpblock = BLOCK_NEXT(tmpblock);
+			set_blockprev(tmpblock, tmpoffset);
+		}
+	} else {
+		/* This block is exact fit */
+		if (tmpoffset != PAGE_SIZE)
+			clear_flag(tmpblock, PREV_FREE);
+	}
+
+	block->size = origsize;
+	clear_flag(block, BLOCK_FREE);
+
+	put_ptr_atomic(block, KM_USER0);
+	spin_unlock(&pool->lock);
+
+	*offset += XV_ALIGN;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(xv_malloc);
+
+/*
+ * Free block identified with <pagenum, offset>
+ */
+void xv_free(struct xv_pool *pool, u32 pagenum, u32 offset)
+{
+	void *page;
+	struct block_header *block, *tmpblock;
+
+	offset -= XV_ALIGN;
+
+	spin_lock(&pool->lock);
+
+	page = get_ptr_atomic(pagenum, 0, KM_USER0);
+	block = (struct block_header *)((char *)page + offset);
+
+	/* Catch double free bugs */
+	BUG_ON(test_flag(block, BLOCK_FREE));
+
+	block->size = ALIGN(block->size, XV_ALIGN);
+
+	tmpblock = BLOCK_NEXT(block);
+	if (offset + block->size + XV_ALIGN == PAGE_SIZE)
+		tmpblock = NULL;
+
+	/* Merge next block if its free */
+	if (tmpblock && test_flag(tmpblock, BLOCK_FREE)) {
+		/*
+		 * Blocks smaller than XV_MIN_ALLOC_SIZE
+		 * are not inserted in any free list.
+		 */
+		if (tmpblock->size >= XV_MIN_ALLOC_SIZE) {
+			remove_block(pool, pagenum,
+				    offset + block->size + XV_ALIGN, tmpblock,
+				    get_index_for_insert(tmpblock->size));
+		}
+		block->size += tmpblock->size + XV_ALIGN;
+	}
+
+	/* Merge previous block if its free */
+	if (test_flag(block, PREV_FREE)) {
+		tmpblock = (struct block_header *)((char *)(page) +
+						get_blockprev(block));
+		offset = offset - tmpblock->size - XV_ALIGN;
+
+		if (tmpblock->size >= XV_MIN_ALLOC_SIZE)
+			remove_block(pool, pagenum, offset, tmpblock,
+				    get_index_for_insert(tmpblock->size));
+
+		tmpblock->size += block->size + XV_ALIGN;
+		block = tmpblock;
+	}
+
+	/* No used objects in this page. Free it. */
+	if (block->size == PAGE_SIZE - XV_ALIGN) {
+		put_ptr_atomic(page, KM_USER0);
+		spin_unlock(&pool->lock);
+
+		xv_free_page(pagenum);
+		stat_dec(&pool->total_pages);
+		return;
+	}
+
+	set_flag(block, BLOCK_FREE);
+	if (block->size >= XV_MIN_ALLOC_SIZE)
+		insert_block(pool, pagenum, offset, block);
+
+	if (offset + block->size + XV_ALIGN != PAGE_SIZE) {
+		tmpblock = BLOCK_NEXT(block);
+		set_flag(tmpblock, PREV_FREE);
+		set_blockprev(tmpblock, offset);
+	}
+
+	put_ptr_atomic(page, KM_USER0);
+	spin_unlock(&pool->lock);
+
+	return;
+}
+EXPORT_SYMBOL_GPL(xv_free);
+
+u32 xv_get_object_size(void *obj)
+{
+	struct block_header *blk;
+
+	blk = (struct block_header *)((char *)(obj) - XV_ALIGN);
+	return blk->size;
+}
+EXPORT_SYMBOL_GPL(xv_get_object_size);
+
+/*
+ * Returns total memory used by allocator (userdata + metadata)
+ */
+u64 xv_get_total_size_bytes(struct xv_pool *pool)
+{
+	return pool->total_pages << PAGE_SHIFT;
+}
+EXPORT_SYMBOL_GPL(xv_get_total_size_bytes);
+
+static int __init xv_malloc_init(void)
+{
+	return 0;
+}
+
+static void __exit xv_malloc_exit(void)
+{
+	return;
+}
+
+module_init(xv_malloc_init);
+module_exit(xv_malloc_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
+MODULE_DESCRIPTION("xvmalloc memory allocator");
diff --git a/drivers/block/ramzswap/xvmalloc.h b/drivers/block/ramzswap/xvmalloc.h
new file mode 100644
index 0000000..699bb04
--- /dev/null
+++ b/drivers/block/ramzswap/xvmalloc.h
@@ -0,0 +1,30 @@
+/*
+ * xvmalloc memory allocator
+ *
+ * Copyright (C) 2008, 2009  Nitin Gupta
+ *
+ * This code is released using a dual license strategy: BSD/GPL
+ * You can choose the licence that better fits your requirements.
+ *
+ * Released under the terms of 3-clause BSD License
+ * Released under the terms of GNU General Public License Version 2.0
+ */
+
+#ifndef _XVMALLOC_H_
+#define _XVMALLOC_H_
+
+#include <linux/types.h>
+
+struct xv_pool;
+
+struct xv_pool *xv_create_pool(void);
+void xv_destroy_pool(struct xv_pool *pool);
+
+int xv_malloc(struct xv_pool *pool, u32 size, u32 *pagenum, u32 *offset,
+							gfp_t flags);
+void xv_free(struct xv_pool *pool, u32 pagenum, u32 offset);
+
+u32 xv_get_object_size(void *obj);
+u64 xv_get_total_size_bytes(struct xv_pool *pool);
+
+#endif
diff --git a/drivers/block/ramzswap/xvmalloc_int.h b/drivers/block/ramzswap/xvmalloc_int.h
new file mode 100644
index 0000000..4d96c48
--- /dev/null
+++ b/drivers/block/ramzswap/xvmalloc_int.h
@@ -0,0 +1,86 @@
+/*
+ * xvmalloc memory allocator
+ *
+ * Copyright (C) 2008, 2009  Nitin Gupta
+ *
+ * This code is released using a dual license strategy: BSD/GPL
+ * You can choose the licence that better fits your requirements.
+ *
+ * Released under the terms of 3-clause BSD License
+ * Released under the terms of GNU General Public License Version 2.0
+ */
+
+#ifndef _XVMALLOC_INT_H_
+#define _XVMALLOC_INT_H_
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+
+/* User configurable params */
+
+/* This must be greater than sizeof(LinkFree) */
+#define XV_MIN_ALLOC_SIZE       32
+#define XV_MAX_ALLOC_SIZE       (PAGE_SIZE - XV_ALIGN)
+
+/* Must be power of two */
+#define XV_ALIGN_SHIFT	2
+#define XV_ALIGN	(1 << XV_ALIGN_SHIFT)
+#define XV_ALIGN_MASK	(XV_ALIGN - 1)
+
+/* Free lists are separated by FL_DELTA bytes */
+#define FL_DELTA_SHIFT	3
+#define FL_DELTA	(1 << FL_DELTA_SHIFT)
+#define FL_DELTA_MASK	(FL_DELTA - 1)
+#define NUM_FREE_LISTS	((XV_MAX_ALLOC_SIZE - XV_MIN_ALLOC_SIZE) \
+				/ FL_DELTA + 1)
+
+#define MAX_FLI		DIV_ROUND_UP(NUM_FREE_LISTS, BITS_PER_LONG)
+
+/* End of user params */
+
+enum blockflags {
+	BLOCK_FREE,
+	PREV_FREE,
+	__NR_BLOCKFLAGS,
+};
+
+#define FLAGS_MASK	XV_ALIGN_MASK
+#define PREV_MASK	(~FLAGS_MASK)
+
+struct freelist_entry {
+	u32 pagenum;
+	u16 offset;
+	u16 pad;
+};
+
+struct link_free {
+	u32 prev_pagenum;
+	u32 next_pagenum;
+	u16 prev_offset;
+	u16 next_offset;
+};
+
+struct block_header {
+	union {
+		/* This common header must be ALIGN bytes */
+		u8 common[XV_ALIGN];
+		struct {
+			u16 size;
+			u16 prev;
+		};
+	};
+	struct link_free link;
+};
+
+struct xv_pool {
+	ulong flbitmap;
+	ulong slbitmap[MAX_FLI];
+	spinlock_t lock;
+
+	struct freelist_entry freelist[NUM_FREE_LISTS];
+
+	/* stats */
+	u64 total_pages;
+};
+
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
