Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id E83F66B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 15:06:33 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH] ramster: switch over to zsmalloc and crypto interface
Date: Thu, 10 May 2012 12:06:21 -0700
Message-Id: <1336676781-8571-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com

RAMster does many zcache-like things.  In order to avoid major
merge conflicts at 3.4, ramster used lzo1x directly for compression
and retained a local copy of xvmalloc, while zcache moved to the
new zsmalloc allocator and the crypto API.

This patch moves ramster forward to use zsmalloc and crypto.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com
---
 drivers/staging/ramster/Kconfig        |    6 +-
 drivers/staging/ramster/Makefile       |    2 +-
 drivers/staging/ramster/TODO           |    4 +-
 drivers/staging/ramster/xvmalloc.c     |  509 --------------------------------
 drivers/staging/ramster/xvmalloc.h     |   30 --
 drivers/staging/ramster/xvmalloc_int.h |   95 ------
 drivers/staging/ramster/zcache-main.c  |  288 ++++++++++++------
 7 files changed, 199 insertions(+), 735 deletions(-)
 delete mode 100644 drivers/staging/ramster/xvmalloc.c
 delete mode 100644 drivers/staging/ramster/xvmalloc.h
 delete mode 100644 drivers/staging/ramster/xvmalloc_int.h

diff --git a/drivers/staging/ramster/Kconfig b/drivers/staging/ramster/Kconfig
index 8349887..98df39c 100644
--- a/drivers/staging/ramster/Kconfig
+++ b/drivers/staging/ramster/Kconfig
@@ -1,8 +1,8 @@
 config RAMSTER
 	bool "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
-	depends on (CLEANCACHE || FRONTSWAP) && CONFIGFS_FS=y && !ZCACHE && !XVMALLOC && !HIGHMEM && NET
-	select LZO_COMPRESS
-	select LZO_DECOMPRESS
+	depends on (CLEANCACHE || FRONTSWAP) && CONFIGFS_FS=y && !ZCACHE && CRYPTO=y && !HIGHMEM && NET
+	select ZSMALLOC
+	select CRYPTO_LZO
 	default n
 	help
 	  RAMster allows RAM on other machines in a cluster to be utilized
diff --git a/drivers/staging/ramster/Makefile b/drivers/staging/ramster/Makefile
index bcc13c8..07ffd75 100644
--- a/drivers/staging/ramster/Makefile
+++ b/drivers/staging/ramster/Makefile
@@ -1 +1 @@
-obj-$(CONFIG_RAMSTER)	+=	zcache-main.o tmem.o r2net.o xvmalloc.o cluster/
+obj-$(CONFIG_RAMSTER)	+=	zcache-main.o tmem.o r2net.o cluster/
diff --git a/drivers/staging/ramster/TODO b/drivers/staging/ramster/TODO
index 46fcf0c..4688233 100644
--- a/drivers/staging/ramster/TODO
+++ b/drivers/staging/ramster/TODO
@@ -1,7 +1,5 @@
 For this staging driver, RAMster duplicates code from drivers/staging/zcache
-then incorporates changes to the local copy of the code.  For V5, it also
-directly incorporates the soon-to-be-removed drivers/staging/zram/xvmalloc.[ch]
-as all testing has been done with xvmalloc rather than the new zsmalloc.
+then incorporates changes to the local copy of the code.
 Before RAMster can be promoted from staging, the zcache and RAMster drivers
 should be either merged or reorganized to separate out common code.
 
diff --git a/drivers/staging/ramster/xvmalloc.c b/drivers/staging/ramster/xvmalloc.c
deleted file mode 100644
index 44ceb0b..0000000
--- a/drivers/staging/ramster/xvmalloc.c
+++ /dev/null
@@ -1,509 +0,0 @@
-/*
- * xvmalloc memory allocator
- *
- * Copyright (C) 2008, 2009, 2010  Nitin Gupta
- *
- * This code is released using a dual license strategy: BSD/GPL
- * You can choose the licence that better fits your requirements.
- *
- * Released under the terms of 3-clause BSD License
- * Released under the terms of GNU General Public License Version 2.0
- */
-
-#ifdef CONFIG_ZRAM_DEBUG
-#define DEBUG
-#endif
-
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/bitops.h>
-#include <linux/errno.h>
-#include <linux/highmem.h>
-#include <linux/init.h>
-#include <linux/string.h>
-#include <linux/slab.h>
-
-#include "xvmalloc.h"
-#include "xvmalloc_int.h"
-
-static void stat_inc(u64 *value)
-{
-	*value = *value + 1;
-}
-
-static void stat_dec(u64 *value)
-{
-	*value = *value - 1;
-}
-
-static int test_flag(struct block_header *block, enum blockflags flag)
-{
-	return block->prev & BIT(flag);
-}
-
-static void set_flag(struct block_header *block, enum blockflags flag)
-{
-	block->prev |= BIT(flag);
-}
-
-static void clear_flag(struct block_header *block, enum blockflags flag)
-{
-	block->prev &= ~BIT(flag);
-}
-
-/*
- * Given <page, offset> pair, provide a dereferencable pointer.
- * This is called from xv_malloc/xv_free path, so it
- * needs to be fast.
- */
-static void *get_ptr_atomic(struct page *page, u16 offset)
-{
-	unsigned char *base;
-
-	base = kmap_atomic(page);
-	return base + offset;
-}
-
-static void put_ptr_atomic(void *ptr)
-{
-	kunmap_atomic(ptr);
-}
-
-static u32 get_blockprev(struct block_header *block)
-{
-	return block->prev & PREV_MASK;
-}
-
-static void set_blockprev(struct block_header *block, u16 new_offset)
-{
-	block->prev = new_offset | (block->prev & FLAGS_MASK);
-}
-
-static struct block_header *BLOCK_NEXT(struct block_header *block)
-{
-	return (struct block_header *)
-		((char *)block + block->size + XV_ALIGN);
-}
-
-/*
- * Get index of free list containing blocks of maximum size
- * which is less than or equal to given size.
- */
-static u32 get_index_for_insert(u32 size)
-{
-	if (unlikely(size > XV_MAX_ALLOC_SIZE))
-		size = XV_MAX_ALLOC_SIZE;
-	size &= ~FL_DELTA_MASK;
-	return (size - XV_MIN_ALLOC_SIZE) >> FL_DELTA_SHIFT;
-}
-
-/*
- * Get index of free list having blocks of size greater than
- * or equal to requested size.
- */
-static u32 get_index(u32 size)
-{
-	if (unlikely(size < XV_MIN_ALLOC_SIZE))
-		size = XV_MIN_ALLOC_SIZE;
-	size = ALIGN(size, FL_DELTA);
-	return (size - XV_MIN_ALLOC_SIZE) >> FL_DELTA_SHIFT;
-}
-
-/**
- * find_block - find block of at least given size
- * @pool: memory pool to search from
- * @size: size of block required
- * @page: page containing required block
- * @offset: offset within the page where block is located.
- *
- * Searches two level bitmap to locate block of at least
- * the given size. If such a block is found, it provides
- * <page, offset> to identify this block and returns index
- * in freelist where we found this block.
- * Otherwise, returns 0 and <page, offset> params are not touched.
- */
-static u32 find_block(struct xv_pool *pool, u32 size,
-			struct page **page, u32 *offset)
-{
-	ulong flbitmap, slbitmap;
-	u32 flindex, slindex, slbitstart;
-
-	/* There are no free blocks in this pool */
-	if (!pool->flbitmap)
-		return 0;
-
-	/* Get freelist index corresponding to this size */
-	slindex = get_index(size);
-	slbitmap = pool->slbitmap[slindex / BITS_PER_LONG];
-	slbitstart = slindex % BITS_PER_LONG;
-
-	/*
-	 * If freelist is not empty at this index, we found the
-	 * block - head of this list. This is approximate best-fit match.
-	 */
-	if (test_bit(slbitstart, &slbitmap)) {
-		*page = pool->freelist[slindex].page;
-		*offset = pool->freelist[slindex].offset;
-		return slindex;
-	}
-
-	/*
-	 * No best-fit found. Search a bit further in bitmap for a free block.
-	 * Second level bitmap consists of series of 32-bit chunks. Search
-	 * further in the chunk where we expected a best-fit, starting from
-	 * index location found above.
-	 */
-	slbitstart++;
-	slbitmap >>= slbitstart;
-
-	/* Skip this search if we were already at end of this bitmap chunk */
-	if ((slbitstart != BITS_PER_LONG) && slbitmap) {
-		slindex += __ffs(slbitmap) + 1;
-		*page = pool->freelist[slindex].page;
-		*offset = pool->freelist[slindex].offset;
-		return slindex;
-	}
-
-	/* Now do a full two-level bitmap search to find next nearest fit */
-	flindex = slindex / BITS_PER_LONG;
-
-	flbitmap = (pool->flbitmap) >> (flindex + 1);
-	if (!flbitmap)
-		return 0;
-
-	flindex += __ffs(flbitmap) + 1;
-	slbitmap = pool->slbitmap[flindex];
-	slindex = (flindex * BITS_PER_LONG) + __ffs(slbitmap);
-	*page = pool->freelist[slindex].page;
-	*offset = pool->freelist[slindex].offset;
-
-	return slindex;
-}
-
-/*
- * Insert block at <page, offset> in freelist of given pool.
- * freelist used depends on block size.
- */
-static void insert_block(struct xv_pool *pool, struct page *page, u32 offset,
-			struct block_header *block)
-{
-	u32 flindex, slindex;
-	struct block_header *nextblock;
-
-	slindex = get_index_for_insert(block->size);
-	flindex = slindex / BITS_PER_LONG;
-
-	block->link.prev_page = NULL;
-	block->link.prev_offset = 0;
-	block->link.next_page = pool->freelist[slindex].page;
-	block->link.next_offset = pool->freelist[slindex].offset;
-	pool->freelist[slindex].page = page;
-	pool->freelist[slindex].offset = offset;
-
-	if (block->link.next_page) {
-		nextblock = get_ptr_atomic(block->link.next_page,
-					block->link.next_offset);
-		nextblock->link.prev_page = page;
-		nextblock->link.prev_offset = offset;
-		put_ptr_atomic(nextblock);
-		/* If there was a next page then the free bits are set. */
-		return;
-	}
-
-	__set_bit(slindex % BITS_PER_LONG, &pool->slbitmap[flindex]);
-	__set_bit(flindex, &pool->flbitmap);
-}
-
-/*
- * Remove block from freelist. Index 'slindex' identifies the freelist.
- */
-static void remove_block(struct xv_pool *pool, struct page *page, u32 offset,
-			struct block_header *block, u32 slindex)
-{
-	u32 flindex = slindex / BITS_PER_LONG;
-	struct block_header *tmpblock;
-
-	if (block->link.prev_page) {
-		tmpblock = get_ptr_atomic(block->link.prev_page,
-				block->link.prev_offset);
-		tmpblock->link.next_page = block->link.next_page;
-		tmpblock->link.next_offset = block->link.next_offset;
-		put_ptr_atomic(tmpblock);
-	}
-
-	if (block->link.next_page) {
-		tmpblock = get_ptr_atomic(block->link.next_page,
-				block->link.next_offset);
-		tmpblock->link.prev_page = block->link.prev_page;
-		tmpblock->link.prev_offset = block->link.prev_offset;
-		put_ptr_atomic(tmpblock);
-	}
-
-	/* Is this block is at the head of the freelist? */
-	if (pool->freelist[slindex].page == page
-	   && pool->freelist[slindex].offset == offset) {
-
-		pool->freelist[slindex].page = block->link.next_page;
-		pool->freelist[slindex].offset = block->link.next_offset;
-
-		if (pool->freelist[slindex].page) {
-			struct block_header *tmpblock;
-			tmpblock = get_ptr_atomic(pool->freelist[slindex].page,
-					pool->freelist[slindex].offset);
-			tmpblock->link.prev_page = NULL;
-			tmpblock->link.prev_offset = 0;
-			put_ptr_atomic(tmpblock);
-		} else {
-			/* This freelist bucket is empty */
-			__clear_bit(slindex % BITS_PER_LONG,
-				    &pool->slbitmap[flindex]);
-			if (!pool->slbitmap[flindex])
-				__clear_bit(flindex, &pool->flbitmap);
-		}
-	}
-
-	block->link.prev_page = NULL;
-	block->link.prev_offset = 0;
-	block->link.next_page = NULL;
-	block->link.next_offset = 0;
-}
-
-/*
- * Allocate a page and add it to freelist of given pool.
- */
-static int grow_pool(struct xv_pool *pool, gfp_t flags)
-{
-	struct page *page;
-	struct block_header *block;
-
-	page = alloc_page(flags);
-	if (unlikely(!page))
-		return -ENOMEM;
-
-	stat_inc(&pool->total_pages);
-
-	spin_lock(&pool->lock);
-	block = get_ptr_atomic(page, 0);
-
-	block->size = PAGE_SIZE - XV_ALIGN;
-	set_flag(block, BLOCK_FREE);
-	clear_flag(block, PREV_FREE);
-	set_blockprev(block, 0);
-
-	insert_block(pool, page, 0, block);
-
-	put_ptr_atomic(block);
-	spin_unlock(&pool->lock);
-
-	return 0;
-}
-
-/*
- * Create a memory pool. Allocates freelist, bitmaps and other
- * per-pool metadata.
- */
-struct xv_pool *xv_create_pool(void)
-{
-	u32 ovhd_size;
-	struct xv_pool *pool;
-
-	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
-	pool = kzalloc(ovhd_size, GFP_KERNEL);
-	if (!pool)
-		return NULL;
-
-	spin_lock_init(&pool->lock);
-
-	return pool;
-}
-EXPORT_SYMBOL_GPL(xv_create_pool);
-
-void xv_destroy_pool(struct xv_pool *pool)
-{
-	kfree(pool);
-}
-EXPORT_SYMBOL_GPL(xv_destroy_pool);
-
-/**
- * xv_malloc - Allocate block of given size from pool.
- * @pool: pool to allocate from
- * @size: size of block to allocate
- * @page: page no. that holds the object
- * @offset: location of object within page
- *
- * On success, <page, offset> identifies block allocated
- * and 0 is returned. On failure, <page, offset> is set to
- * 0 and -ENOMEM is returned.
- *
- * Allocation requests with size > XV_MAX_ALLOC_SIZE will fail.
- */
-int xv_malloc(struct xv_pool *pool, u32 size, struct page **page,
-		u32 *offset, gfp_t flags)
-{
-	int error;
-	u32 index, tmpsize, origsize, tmpoffset;
-	struct block_header *block, *tmpblock;
-
-	*page = NULL;
-	*offset = 0;
-	origsize = size;
-
-	if (unlikely(!size || size > XV_MAX_ALLOC_SIZE))
-		return -ENOMEM;
-
-	size = ALIGN(size, XV_ALIGN);
-
-	spin_lock(&pool->lock);
-
-	index = find_block(pool, size, page, offset);
-
-	if (!*page) {
-		spin_unlock(&pool->lock);
-		if (flags & GFP_NOWAIT)
-			return -ENOMEM;
-		error = grow_pool(pool, flags);
-		if (unlikely(error))
-			return error;
-
-		spin_lock(&pool->lock);
-		index = find_block(pool, size, page, offset);
-	}
-
-	if (!*page) {
-		spin_unlock(&pool->lock);
-		return -ENOMEM;
-	}
-
-	block = get_ptr_atomic(*page, *offset);
-
-	remove_block(pool, *page, *offset, block, index);
-
-	/* Split the block if required */
-	tmpoffset = *offset + size + XV_ALIGN;
-	tmpsize = block->size - size;
-	tmpblock = (struct block_header *)((char *)block + size + XV_ALIGN);
-	if (tmpsize) {
-		tmpblock->size = tmpsize - XV_ALIGN;
-		set_flag(tmpblock, BLOCK_FREE);
-		clear_flag(tmpblock, PREV_FREE);
-
-		set_blockprev(tmpblock, *offset);
-		if (tmpblock->size >= XV_MIN_ALLOC_SIZE)
-			insert_block(pool, *page, tmpoffset, tmpblock);
-
-		if (tmpoffset + XV_ALIGN + tmpblock->size != PAGE_SIZE) {
-			tmpblock = BLOCK_NEXT(tmpblock);
-			set_blockprev(tmpblock, tmpoffset);
-		}
-	} else {
-		/* This block is exact fit */
-		if (tmpoffset != PAGE_SIZE)
-			clear_flag(tmpblock, PREV_FREE);
-	}
-
-	block->size = origsize;
-	clear_flag(block, BLOCK_FREE);
-
-	put_ptr_atomic(block);
-	spin_unlock(&pool->lock);
-
-	*offset += XV_ALIGN;
-
-	return 0;
-}
-EXPORT_SYMBOL_GPL(xv_malloc);
-
-/*
- * Free block identified with <page, offset>
- */
-void xv_free(struct xv_pool *pool, struct page *page, u32 offset)
-{
-	void *page_start;
-	struct block_header *block, *tmpblock;
-
-	offset -= XV_ALIGN;
-
-	spin_lock(&pool->lock);
-
-	page_start = get_ptr_atomic(page, 0);
-	block = (struct block_header *)((char *)page_start + offset);
-
-	/* Catch double free bugs */
-	BUG_ON(test_flag(block, BLOCK_FREE));
-
-	block->size = ALIGN(block->size, XV_ALIGN);
-
-	tmpblock = BLOCK_NEXT(block);
-	if (offset + block->size + XV_ALIGN == PAGE_SIZE)
-		tmpblock = NULL;
-
-	/* Merge next block if its free */
-	if (tmpblock && test_flag(tmpblock, BLOCK_FREE)) {
-		/*
-		 * Blocks smaller than XV_MIN_ALLOC_SIZE
-		 * are not inserted in any free list.
-		 */
-		if (tmpblock->size >= XV_MIN_ALLOC_SIZE) {
-			remove_block(pool, page,
-				    offset + block->size + XV_ALIGN, tmpblock,
-				    get_index_for_insert(tmpblock->size));
-		}
-		block->size += tmpblock->size + XV_ALIGN;
-	}
-
-	/* Merge previous block if its free */
-	if (test_flag(block, PREV_FREE)) {
-		tmpblock = (struct block_header *)((char *)(page_start) +
-						get_blockprev(block));
-		offset = offset - tmpblock->size - XV_ALIGN;
-
-		if (tmpblock->size >= XV_MIN_ALLOC_SIZE)
-			remove_block(pool, page, offset, tmpblock,
-				    get_index_for_insert(tmpblock->size));
-
-		tmpblock->size += block->size + XV_ALIGN;
-		block = tmpblock;
-	}
-
-	/* No used objects in this page. Free it. */
-	if (block->size == PAGE_SIZE - XV_ALIGN) {
-		put_ptr_atomic(page_start);
-		spin_unlock(&pool->lock);
-
-		__free_page(page);
-		stat_dec(&pool->total_pages);
-		return;
-	}
-
-	set_flag(block, BLOCK_FREE);
-	if (block->size >= XV_MIN_ALLOC_SIZE)
-		insert_block(pool, page, offset, block);
-
-	if (offset + block->size + XV_ALIGN != PAGE_SIZE) {
-		tmpblock = BLOCK_NEXT(block);
-		set_flag(tmpblock, PREV_FREE);
-		set_blockprev(tmpblock, offset);
-	}
-
-	put_ptr_atomic(page_start);
-	spin_unlock(&pool->lock);
-}
-EXPORT_SYMBOL_GPL(xv_free);
-
-u32 xv_get_object_size(void *obj)
-{
-	struct block_header *blk;
-
-	blk = (struct block_header *)((char *)(obj) - XV_ALIGN);
-	return blk->size;
-}
-EXPORT_SYMBOL_GPL(xv_get_object_size);
-
-/*
- * Returns total memory used by allocator (userdata + metadata)
- */
-u64 xv_get_total_size_bytes(struct xv_pool *pool)
-{
-	return pool->total_pages << PAGE_SHIFT;
-}
-EXPORT_SYMBOL_GPL(xv_get_total_size_bytes);
diff --git a/drivers/staging/ramster/xvmalloc.h b/drivers/staging/ramster/xvmalloc.h
deleted file mode 100644
index 5b1a81a..0000000
--- a/drivers/staging/ramster/xvmalloc.h
+++ /dev/null
@@ -1,30 +0,0 @@
-/*
- * xvmalloc memory allocator
- *
- * Copyright (C) 2008, 2009, 2010  Nitin Gupta
- *
- * This code is released using a dual license strategy: BSD/GPL
- * You can choose the licence that better fits your requirements.
- *
- * Released under the terms of 3-clause BSD License
- * Released under the terms of GNU General Public License Version 2.0
- */
-
-#ifndef _XV_MALLOC_H_
-#define _XV_MALLOC_H_
-
-#include <linux/types.h>
-
-struct xv_pool;
-
-struct xv_pool *xv_create_pool(void);
-void xv_destroy_pool(struct xv_pool *pool);
-
-int xv_malloc(struct xv_pool *pool, u32 size, struct page **page,
-			u32 *offset, gfp_t flags);
-void xv_free(struct xv_pool *pool, struct page *page, u32 offset);
-
-u32 xv_get_object_size(void *obj);
-u64 xv_get_total_size_bytes(struct xv_pool *pool);
-
-#endif
diff --git a/drivers/staging/ramster/xvmalloc_int.h b/drivers/staging/ramster/xvmalloc_int.h
deleted file mode 100644
index b5f1f7f..0000000
--- a/drivers/staging/ramster/xvmalloc_int.h
+++ /dev/null
@@ -1,95 +0,0 @@
-/*
- * xvmalloc memory allocator
- *
- * Copyright (C) 2008, 2009, 2010  Nitin Gupta
- *
- * This code is released using a dual license strategy: BSD/GPL
- * You can choose the licence that better fits your requirements.
- *
- * Released under the terms of 3-clause BSD License
- * Released under the terms of GNU General Public License Version 2.0
- */
-
-#ifndef _XV_MALLOC_INT_H_
-#define _XV_MALLOC_INT_H_
-
-#include <linux/kernel.h>
-#include <linux/types.h>
-
-/* User configurable params */
-
-/* Must be power of two */
-#ifdef CONFIG_64BIT
-#define XV_ALIGN_SHIFT 3
-#else
-#define XV_ALIGN_SHIFT	2
-#endif
-#define XV_ALIGN	(1 << XV_ALIGN_SHIFT)
-#define XV_ALIGN_MASK	(XV_ALIGN - 1)
-
-/* This must be greater than sizeof(link_free) */
-#define XV_MIN_ALLOC_SIZE	32
-#define XV_MAX_ALLOC_SIZE	(PAGE_SIZE - XV_ALIGN)
-
-/*
- * Free lists are separated by FL_DELTA bytes
- * This value is 3 for 4k pages and 4 for 64k pages, for any
- * other page size, a conservative (PAGE_SHIFT - 9) is used.
- */
-#if PAGE_SHIFT == 16
-#define FL_DELTA_SHIFT 4
-#else
-#define FL_DELTA_SHIFT (PAGE_SHIFT - 9)
-#endif
-#define FL_DELTA	(1 << FL_DELTA_SHIFT)
-#define FL_DELTA_MASK	(FL_DELTA - 1)
-#define NUM_FREE_LISTS	((XV_MAX_ALLOC_SIZE - XV_MIN_ALLOC_SIZE) \
-				/ FL_DELTA + 1)
-
-#define MAX_FLI		DIV_ROUND_UP(NUM_FREE_LISTS, BITS_PER_LONG)
-
-/* End of user params */
-
-enum blockflags {
-	BLOCK_FREE,
-	PREV_FREE,
-	__NR_BLOCKFLAGS,
-};
-
-#define FLAGS_MASK	XV_ALIGN_MASK
-#define PREV_MASK	(~FLAGS_MASK)
-
-struct freelist_entry {
-	struct page *page;
-	u16 offset;
-	u16 pad;
-};
-
-struct link_free {
-	struct page *prev_page;
-	struct page *next_page;
-	u16 prev_offset;
-	u16 next_offset;
-};
-
-struct block_header {
-	union {
-		/* This common header must be XV_ALIGN bytes */
-		u8 common[XV_ALIGN];
-		struct {
-			u16 size;
-			u16 prev;
-		};
-	};
-	struct link_free link;
-};
-
-struct xv_pool {
-	ulong flbitmap;
-	ulong slbitmap[MAX_FLI];
-	u64 total_pages;	/* stats */
-	struct freelist_entry freelist[NUM_FREE_LISTS];
-	spinlock_t lock;
-};
-
-#endif
diff --git a/drivers/staging/ramster/zcache-main.c b/drivers/staging/ramster/zcache-main.c
index 4e7ef0e..225e3b3 100644
--- a/drivers/staging/ramster/zcache-main.c
+++ b/drivers/staging/ramster/zcache-main.c
@@ -6,9 +6,10 @@
  *
  * Zcache provides an in-kernel "host implementation" for transcendent memory
  * and, thus indirectly, for cleancache and frontswap.  Zcache includes two
- * page-accessible memory [1] interfaces, both utilizing lzo1x compression:
+ * page-accessible memory [1] interfaces, both utilizing the crypto compression
+ * API:
  * 1) "compression buddies" ("zbud") is used for ephemeral pages
- * 2) xvmalloc is used for persistent pages.
+ * 2) zsmalloc is used for persistent pages.
  * Xvmalloc (based on the TLSF allocator) has very low fragmentation
  * so maximizes space efficiency, while zbud allows pairs (and potentially,
  * in the future, more than a pair of) compressed pages to be closely linked
@@ -26,18 +27,19 @@
 #include <linux/cpu.h>
 #include <linux/highmem.h>
 #include <linux/list.h>
-#include <linux/lzo.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/types.h>
 #include <linux/atomic.h>
 #include <linux/math64.h>
+#include <linux/crypto.h>
+#include <linux/string.h>
 #include "tmem.h"
 #include "zcache.h"
 #include "ramster.h"
 #include "cluster/tcp.h"
 
-#include "xvmalloc.h"	/* temporary until change to zsmalloc */
+#include "../zsmalloc/zsmalloc.h"
 
 #define	RAMSTER_TESTING
 
@@ -88,6 +90,7 @@ struct zv_hdr {
 	uint16_t pool_id;
 	struct tmem_oid oid;
 	uint32_t index;
+	size_t size;
 	DECL_SENTINEL
 };
 
@@ -123,7 +126,7 @@ MODULE_LICENSE("GPL");
 
 struct zcache_client {
 	struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
-	struct xv_pool *xvpool;
+	struct zs_pool *zspool;
 	bool allocated;
 	atomic_t refcount;
 };
@@ -144,6 +147,38 @@ static inline bool is_local_client(struct zcache_client *cli)
 	return cli == &zcache_host;
 }
 
+/* crypto API for zcache  */
+#define ZCACHE_COMP_NAME_SZ CRYPTO_MAX_ALG_NAME
+static char zcache_comp_name[ZCACHE_COMP_NAME_SZ];
+static struct crypto_comp * __percpu *zcache_comp_pcpu_tfms;
+
+enum comp_op {
+	ZCACHE_COMPOP_COMPRESS,
+	ZCACHE_COMPOP_DECOMPRESS
+};
+
+static inline int zcache_comp_op(enum comp_op op,
+				const u8 *src, unsigned int slen,
+				u8 *dst, unsigned int *dlen)
+{
+	struct crypto_comp *tfm;
+	int ret;
+
+	BUG_ON(!zcache_comp_pcpu_tfms);
+	tfm = *per_cpu_ptr(zcache_comp_pcpu_tfms, get_cpu());
+	BUG_ON(!tfm);
+	switch (op) {
+	case ZCACHE_COMPOP_COMPRESS:
+		ret = crypto_comp_compress(tfm, src, slen, dst, dlen);
+		break;
+	case ZCACHE_COMPOP_DECOMPRESS:
+		ret = crypto_comp_decompress(tfm, src, slen, dst, dlen);
+		break;
+	}
+	put_cpu();
+	return ret;
+}
+
 /**********
  * Compression buddies ("zbud") provides for packing two (or, possibly
  * in the future, more) compressed ephemeral pages into a single "raw"
@@ -374,11 +409,13 @@ static void zbud_free_and_delist(struct zbud_hdr *zh)
 	/* FIXME, should be BUG_ON, pool destruction path doesn't disable
 	 * interrupts tmem_destroy_pool()->tmem_pampd_destroy_all_in_obj()->
 	 * tmem_objnode_node_destroy()-> zcache_pampd_free() */
-	WARN_ON(!irqs_disabled());
+	/* WARN_ON(!irqs_disabled()); FIXME for now, just avoid spew */
+	spin_lock(&zbud_budlists_spinlock);
 	spin_lock(&zbpg->lock);
 	if (list_empty(&zbpg->bud_list)) {
 		/* ignore zombie page... see zbud_evict_pages() */
 		spin_unlock(&zbpg->lock);
+		spin_unlock(&zbud_budlists_spinlock);
 		return;
 	}
 	size = zbud_free(zh);
@@ -386,7 +423,6 @@ static void zbud_free_and_delist(struct zbud_hdr *zh)
 	zh_other = &zbpg->buddy[(budnum == 0) ? 1 : 0];
 	if (zh_other->size == 0) { /* was unbuddied: unlist and free */
 		chunks = zbud_size_to_chunks(size) ;
-		spin_lock(&zbud_budlists_spinlock);
 		BUG_ON(list_empty(&zbud_unbuddied[chunks].list));
 		list_del_init(&zbpg->bud_list);
 		zbud_unbuddied[chunks].count--;
@@ -394,13 +430,12 @@ static void zbud_free_and_delist(struct zbud_hdr *zh)
 		zbud_free_raw_page(zbpg);
 	} else { /* was buddied: move remaining buddy to unbuddied list */
 		chunks = zbud_size_to_chunks(zh_other->size) ;
-		spin_lock(&zbud_budlists_spinlock);
 		list_del_init(&zbpg->bud_list);
 		zcache_zbud_buddied_count--;
 		list_add_tail(&zbpg->bud_list, &zbud_unbuddied[chunks].list);
 		zbud_unbuddied[chunks].count++;
-		spin_unlock(&zbud_budlists_spinlock);
 		spin_unlock(&zbpg->lock);
+		spin_unlock(&zbud_budlists_spinlock);
 	}
 }
 
@@ -469,6 +504,7 @@ init_zh:
 	memcpy(to, cdata, size);
 	spin_unlock(&zbpg->lock);
 	spin_unlock(&zbud_budlists_spinlock);
+
 	zbud_cumul_chunk_counts[nchunks]++;
 	atomic_inc(&zcache_zbud_curr_zpages);
 	zcache_zbud_cumul_zpages++;
@@ -482,7 +518,7 @@ static int zbud_decompress(struct page *page, struct zbud_hdr *zh)
 {
 	struct zbud_page *zbpg;
 	unsigned budnum = zbud_budnum(zh);
-	size_t out_len = PAGE_SIZE;
+	unsigned int out_len = PAGE_SIZE;
 	char *to_va, *from_va;
 	unsigned size;
 	int ret = 0;
@@ -499,8 +535,9 @@ static int zbud_decompress(struct page *page, struct zbud_hdr *zh)
 	to_va = kmap_atomic(page);
 	size = zh->size;
 	from_va = zbud_data(zh, size);
-	ret = lzo1x_decompress_safe(from_va, size, to_va, &out_len);
-	BUG_ON(ret != LZO_E_OK);
+	ret = zcache_comp_op(ZCACHE_COMPOP_DECOMPRESS, from_va, size,
+				to_va, &out_len);
+	BUG_ON(ret);
 	BUG_ON(out_len != PAGE_SIZE);
 	kunmap_atomic(to_va);
 out:
@@ -861,7 +898,7 @@ static void zcache_remote_pers_put(struct zv_hdr *zv)
 	xh.pool_id = zv->pool_id;
 	xh.oid = zv->oid;
 	xh.index = zv->index;
-	size = xv_get_object_size(zv) - sizeof(*zv);
+	size = zv->size;
 	BUG_ON(size == 0 || size > zv_max_page_size);
 	data = (char *)zv + sizeof(*zv);
 	for (p = data, cksum = 0, i = 0; i < size; i++)
@@ -1063,8 +1100,8 @@ static int zbud_show_cumul_chunk_counts(char *buf)
 #endif
 
 /**********
- * This "zv" PAM implementation combines the TLSF-based xvMalloc
- * with lzo1x compression to maximize the amount of data that can
+ * This "zv" PAM implementation combines the slab-based zsmalloc
+ * with the crypto compression API to maximize the amount of data that can
  * be packed into a physical page.
  *
  * Zv represents a PAM page with the index and object (plus a "size" value
@@ -1094,26 +1131,23 @@ static struct zv_hdr *zv_create(struct zcache_client *cli, uint32_t pool_id,
 				struct tmem_oid *oid, uint32_t index,
 				void *cdata, unsigned clen)
 {
-	struct page *page;
-	struct zv_hdr *zv = NULL;
-	uint32_t offset;
-	int alloc_size = clen + sizeof(struct zv_hdr);
-	int chunks = (alloc_size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
-	int ret;
+	struct zv_hdr *zv;
+	int size = clen + sizeof(struct zv_hdr);
+	int chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
+	void *handle = NULL;
 
 	BUG_ON(!irqs_disabled());
 	BUG_ON(chunks >= NCHUNKS);
-	ret = xv_malloc(cli->xvpool, clen + sizeof(struct zv_hdr),
-			&page, &offset, ZCACHE_GFP_MASK);
-	if (unlikely(ret))
+	handle = zs_malloc(cli->zspool, size);
+	if (!handle)
 		goto out;
 	atomic_inc(&zv_curr_dist_counts[chunks]);
 	atomic_inc(&zv_cumul_dist_counts[chunks]);
-	zv = kmap_atomic(page) + offset;
+	zv = zs_map_object(cli->zspool, handle);
 	zv->index = index;
 	zv->oid = *oid;
 	zv->pool_id = pool_id;
-	SET_SENTINEL(zv, ZVH);
+	zv->size = clen;
 	INIT_LIST_HEAD(&zv->rem_op.list);
 	zv->client_id = get_client_id_from_client(cli);
 	zv->rem_op.op = RAMSTER_REMOTIFY_PERS_PUT;
@@ -1122,10 +1156,11 @@ static struct zv_hdr *zv_create(struct zcache_client *cli, uint32_t pool_id,
 		list_add_tail(&zv->rem_op.list, &zcache_rem_op_list);
 		spin_unlock(&zcache_rem_op_list_lock);
 	}
+	SET_SENTINEL(zv, ZVH);
 	memcpy((char *)zv + sizeof(struct zv_hdr), cdata, clen);
-	kunmap_atomic(zv);
+	zs_unmap_object(cli->zspool, handle);
 out:
-	return zv;
+	return handle;
 }
 
 /* similar to zv_create, but just reserve space, no data yet */
@@ -1134,71 +1169,74 @@ static struct zv_hdr *zv_alloc(struct tmem_pool *pool,
 				unsigned clen)
 {
 	struct zcache_client *cli = pool->client;
-	struct page *page;
-	struct zv_hdr *zv = NULL;
-	uint32_t offset;
-	int ret;
+	struct zv_hdr *zv;
+	int size = clen + sizeof(struct zv_hdr);
+	void *handle = NULL;
 
 	BUG_ON(!irqs_disabled());
 	BUG_ON(!is_local_client(pool->client));
-	ret = xv_malloc(cli->xvpool, clen + sizeof(struct zv_hdr),
-			&page, &offset, ZCACHE_GFP_MASK);
-	if (unlikely(ret))
+	handle = zs_malloc(cli->zspool, size);
+	if (!handle)
 		goto out;
-	zv = kmap_atomic(page) + offset;
-	SET_SENTINEL(zv, ZVH);
+	zv = zs_map_object(cli->zspool, handle);
 	INIT_LIST_HEAD(&zv->rem_op.list);
 	zv->client_id = LOCAL_CLIENT;
 	zv->rem_op.op = RAMSTER_INTRANSIT_PERS;
 	zv->index = index;
 	zv->oid = *oid;
 	zv->pool_id = pool->pool_id;
-	kunmap_atomic(zv);
+	zv->size = clen;
+	SET_SENTINEL(zv, ZVH);
+	zs_unmap_object(cli->zspool, handle);
 out:
-	return zv;
+	return handle;
 }
 
-static void zv_free(struct xv_pool *xvpool, struct zv_hdr *zv)
+static void zv_free(struct zs_pool *pool, void *handle)
 {
 	unsigned long flags;
-	struct page *page;
-	uint32_t offset;
-	uint16_t size = xv_get_object_size(zv);
-	int chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
+	struct zv_hdr *zv;
+	uint16_t size;
+	int chunks;
 
+	zv = zs_map_object(pool, handle);
 	ASSERT_SENTINEL(zv, ZVH);
+	size = zv->size + sizeof(struct zv_hdr);
+	INVERT_SENTINEL(zv, ZVH);
+
+	chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
 	BUG_ON(chunks >= NCHUNKS);
 	atomic_dec(&zv_curr_dist_counts[chunks]);
-	size -= sizeof(*zv);
 	spin_lock(&zcache_rem_op_list_lock);
-	size = xv_get_object_size(zv) - sizeof(*zv);
 	BUG_ON(size == 0);
-	INVERT_SENTINEL(zv, ZVH);
 	if (!list_empty(&zv->rem_op.list))
 		list_del_init(&zv->rem_op.list);
 	spin_unlock(&zcache_rem_op_list_lock);
-	page = virt_to_page(zv);
-	offset = (unsigned long)zv & ~PAGE_MASK;
+	zs_unmap_object(pool, handle);
+
 	local_irq_save(flags);
-	xv_free(xvpool, page, offset);
+	zs_free(pool, handle);
 	local_irq_restore(flags);
 }
 
-static void zv_decompress(struct page *page, struct zv_hdr *zv)
+static void zv_decompress(struct tmem_pool *pool,
+				struct page *page, void *handle)
 {
-	size_t clen = PAGE_SIZE;
+	unsigned int clen = PAGE_SIZE;
 	char *to_va;
-	unsigned size;
 	int ret;
+	struct zv_hdr *zv;
+	struct zcache_client *cli = pool->client;
 
+	zv = zs_map_object(cli->zspool, handle);
+	BUG_ON(zv->size == 0);
 	ASSERT_SENTINEL(zv, ZVH);
-	size = xv_get_object_size(zv) - sizeof(*zv);
-	BUG_ON(size == 0);
 	to_va = kmap_atomic(page);
-	ret = lzo1x_decompress_safe((char *)zv + sizeof(*zv),
-					size, to_va, &clen);
+	ret = zcache_comp_op(ZCACHE_COMPOP_DECOMPRESS, (char *)zv + sizeof(*zv),
+				zv->size, to_va, &clen);
 	kunmap_atomic(to_va);
-	BUG_ON(ret != LZO_E_OK);
+	zs_unmap_object(cli->zspool, handle);
+	BUG_ON(ret);
 	BUG_ON(clen != PAGE_SIZE);
 }
 
@@ -1207,7 +1245,7 @@ static void zv_copy_from_pampd(char *data, size_t *bufsize, struct zv_hdr *zv)
 	unsigned size;
 
 	ASSERT_SENTINEL(zv, ZVH);
-	size = xv_get_object_size(zv) - sizeof(*zv);
+	size = zv->size;
 	BUG_ON(size == 0 || size > zv_max_page_size);
 	BUG_ON(size > *bufsize);
 	memcpy(data, (char *)zv + sizeof(*zv), size);
@@ -1219,7 +1257,7 @@ static void zv_copy_to_pampd(struct zv_hdr *zv, char *data, size_t size)
 	unsigned zv_size;
 
 	ASSERT_SENTINEL(zv, ZVH);
-	zv_size = xv_get_object_size(zv) - sizeof(*zv);
+	zv_size = zv->size;
 	BUG_ON(zv_size != size);
 	BUG_ON(zv_size == 0 || zv_size > zv_max_page_size);
 	memcpy((char *)zv + sizeof(*zv), data, size);
@@ -1448,8 +1486,8 @@ int zcache_new_client(uint16_t cli_id)
 		goto out;
 	cli->allocated = 1;
 #ifdef CONFIG_FRONTSWAP
-	cli->xvpool = xv_create_pool();
-	if (cli->xvpool == NULL)
+	cli->zspool = zs_create_pool("zcache", ZCACHE_GFP_MASK);
+	if (cli->zspool == NULL)
 		goto out;
 #endif
 	ret = 0;
@@ -1701,7 +1739,7 @@ static atomic_t zcache_curr_pers_pampd_count = ATOMIC_INIT(0);
 static unsigned long zcache_curr_pers_pampd_count_max;
 
 /* forward reference */
-static int zcache_compress(struct page *from, void **out_va, size_t *out_len);
+static int zcache_compress(struct page *from, void **out_va, unsigned *out_len);
 
 static int zcache_pampd_eph_create(char *data, size_t size, bool raw,
 				struct tmem_pool *pool, struct tmem_oid *oid,
@@ -1709,7 +1747,7 @@ static int zcache_pampd_eph_create(char *data, size_t size, bool raw,
 {
 	int ret = -1;
 	void *cdata = data;
-	size_t clen = size;
+	unsigned int clen = size;
 	struct zcache_client *cli = pool->client;
 	uint16_t client_id = get_client_id_from_client(cli);
 	struct page *page = NULL;
@@ -1750,7 +1788,7 @@ static int zcache_pampd_pers_create(char *data, size_t size, bool raw,
 {
 	int ret = -1;
 	void *cdata = data;
-	size_t clen = size;
+	unsigned int clen = size;
 	struct zcache_client *cli = pool->client;
 	struct page *page;
 	unsigned long count;
@@ -1788,7 +1826,7 @@ static int zcache_pampd_pers_create(char *data, size_t size, bool raw,
 	}
 	/* reject if mean compression is too poor */
 	if ((clen > zv_max_mean_zsize) && (curr_pers_pampd_count > 0)) {
-		total_zsize = xv_get_total_size_bytes(cli->xvpool);
+		total_zsize = zs_get_total_size_bytes(cli->zspool);
 		zv_mean_zsize = div_u64(total_zsize, curr_pers_pampd_count);
 		if (zv_mean_zsize > zv_max_mean_zsize) {
 			zcache_mean_compress_poor++;
@@ -1851,7 +1889,7 @@ static int zcache_pampd_get_data(char *data, size_t *bufsize, bool raw,
 	if (raw)
 		zv_copy_from_pampd(data, bufsize, pampd);
 	else
-		zv_decompress(virt_to_page(data), pampd);
+		zv_decompress(pool, virt_to_page(data), pampd);
 	return ret;
 }
 
@@ -1882,8 +1920,8 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *bufsize, bool raw,
 		if (raw)
 			zv_copy_from_pampd(data, bufsize, pampd);
 		else
-			zv_decompress(virt_to_page(data), pampd);
-		zv_free(cli->xvpool, pampd);
+			zv_decompress(pool, virt_to_page(data), pampd);
+		zv_free(cli->zspool, pampd);
 		if (!is_local_client(cli))
 			dec_and_check(&ramster_foreign_pers_pampd_count);
 		dec_and_check(&zcache_curr_pers_pampd_count);
@@ -1951,7 +1989,7 @@ local_pers:
 		zv = (struct zv_hdr *)pampd;
 		if (!is_local_client(pool->client))
 			dec_and_check(&ramster_foreign_pers_pampd_count);
-		zv_free(cli->xvpool, zv);
+		zv_free(cli->zspool, zv);
 		if (acct)
 			/* FIXME get these working properly again */
 			dec_and_check(&zcache_curr_pers_pampd_count);
@@ -2019,7 +2057,7 @@ int zcache_localify(int pool_id, struct tmem_oid *oidp,
 	unsigned long flags;
 	struct tmem_pool *pool;
 	bool ephemeral, delete = false;
-	size_t clen = PAGE_SIZE;
+	unsigned int clen = PAGE_SIZE;
 	void *pampd, *saved_hb;
 	struct tmem_obj *obj;
 
@@ -2074,9 +2112,9 @@ int zcache_localify(int pool_id, struct tmem_oid *oidp,
 	}
 	if (extra != NULL) {
 		/* decompress direct-to-memory to complete remotify */
-		ret = lzo1x_decompress_safe((char *)data, size,
-						(char *)extra, &clen);
-		BUG_ON(ret != LZO_E_OK);
+		ret = zcache_comp_op(ZCACHE_COMPOP_DECOMPRESS, (char *)data,
+				size, (char *)extra, &clen);
+		BUG_ON(ret);
 		BUG_ON(clen != PAGE_SIZE);
 	}
 	if (ephemeral)
@@ -2188,25 +2226,24 @@ static struct tmem_pamops zcache_pamops = {
  * zcache compression/decompression and related per-cpu stuff
  */
 
-#define LZO_WORKMEM_BYTES LZO1X_1_MEM_COMPRESS
-#define LZO_DSTMEM_PAGE_ORDER 1
-static DEFINE_PER_CPU(unsigned char *, zcache_workmem);
 static DEFINE_PER_CPU(unsigned char *, zcache_dstmem);
+#define ZCACHE_DSTMEM_ORDER 1
 
-static int zcache_compress(struct page *from, void **out_va, size_t *out_len)
+static int zcache_compress(struct page *from, void **out_va, unsigned *out_len)
 {
 	int ret = 0;
 	unsigned char *dmem = __get_cpu_var(zcache_dstmem);
-	unsigned char *wmem = __get_cpu_var(zcache_workmem);
 	char *from_va;
 
 	BUG_ON(!irqs_disabled());
-	if (unlikely(dmem == NULL || wmem == NULL))
-		goto out;  /* no buffer, so can't compress */
+	if (unlikely(dmem == NULL))
+		goto out;  /* no buffer or no compressor so can't compress */
+	*out_len = PAGE_SIZE << ZCACHE_DSTMEM_ORDER;
 	from_va = kmap_atomic(from);
 	mb();
-	ret = lzo1x_1_compress(from_va, PAGE_SIZE, dmem, out_len, wmem);
-	BUG_ON(ret != LZO_E_OK);
+	ret = zcache_comp_op(ZCACHE_COMPOP_COMPRESS, from_va, PAGE_SIZE, dmem,
+				out_len);
+	BUG_ON(ret);
 	*out_va = dmem;
 	kunmap_atomic(from_va);
 	ret = 1;
@@ -2214,33 +2251,52 @@ out:
 	return ret;
 }
 
+static int zcache_comp_cpu_up(int cpu)
+{
+	struct crypto_comp *tfm;
+
+	tfm = crypto_alloc_comp(zcache_comp_name, 0, 0);
+	if (IS_ERR(tfm))
+		return NOTIFY_BAD;
+	*per_cpu_ptr(zcache_comp_pcpu_tfms, cpu) = tfm;
+	return NOTIFY_OK;
+}
+
+static void zcache_comp_cpu_down(int cpu)
+{
+	struct crypto_comp *tfm;
+
+	tfm = *per_cpu_ptr(zcache_comp_pcpu_tfms, cpu);
+	crypto_free_comp(tfm);
+	*per_cpu_ptr(zcache_comp_pcpu_tfms, cpu) = NULL;
+}
 
 static int zcache_cpu_notifier(struct notifier_block *nb,
 				unsigned long action, void *pcpu)
 {
-	int cpu = (long)pcpu;
+	int ret, cpu = (long)pcpu;
 	struct zcache_preload *kp;
 
 	switch (action) {
 	case CPU_UP_PREPARE:
+		ret = zcache_comp_cpu_up(cpu);
+		if (ret != NOTIFY_OK) {
+			pr_err("zcache: can't allocate compressor transform\n");
+			return ret;
+		}
 		per_cpu(zcache_dstmem, cpu) = (void *)__get_free_pages(
-			GFP_KERNEL | __GFP_REPEAT,
-			LZO_DSTMEM_PAGE_ORDER),
-		per_cpu(zcache_workmem, cpu) =
-			kzalloc(LZO1X_MEM_COMPRESS,
-				GFP_KERNEL | __GFP_REPEAT);
+			GFP_KERNEL | __GFP_REPEAT, ZCACHE_DSTMEM_ORDER),
 		per_cpu(zcache_remoteputmem, cpu) =
 			kzalloc(PAGE_SIZE, GFP_KERNEL | __GFP_REPEAT);
 		break;
 	case CPU_DEAD:
 	case CPU_UP_CANCELED:
+		zcache_comp_cpu_down(cpu);
 		kfree(per_cpu(zcache_remoteputmem, cpu));
 		per_cpu(zcache_remoteputmem, cpu) = NULL;
 		free_pages((unsigned long)per_cpu(zcache_dstmem, cpu),
-				LZO_DSTMEM_PAGE_ORDER);
+				ZCACHE_DSTMEM_ORDER);
 		per_cpu(zcache_dstmem, cpu) = NULL;
-		kfree(per_cpu(zcache_workmem, cpu));
-		per_cpu(zcache_workmem, cpu) = NULL;
 		kp = &per_cpu(zcache_preloads, cpu);
 		while (kp->nr) {
 			kmem_cache_free(zcache_objnode_cache,
@@ -2752,7 +2808,8 @@ int zcache_client_destroy_pool(int cli_id, int pool_id)
 	ret = tmem_destroy_pool(pool);
 	local_bh_enable();
 	kfree(pool);
-	pr_info("ramster: destroyed pool id=%d cli_id=%d\n", pool_id, cli_id);
+	pr_info("ramster: destroyed pool id=%d cli_id=%d\n",
+			pool_id, cli_id);
 out:
 	return ret;
 }
@@ -3245,6 +3302,44 @@ static int __init no_frontswap(char *s)
 
 __setup("nofrontswap", no_frontswap);
 
+static int __init enable_zcache_compressor(char *s)
+{
+	strncpy(zcache_comp_name, s, ZCACHE_COMP_NAME_SZ);
+	ramster_enabled = 1;
+	return 1;
+}
+__setup("zcache=", enable_zcache_compressor);
+
+
+static int zcache_comp_init(void)
+{
+	int ret = 0;
+
+	/* check crypto algorithm */
+	if (*zcache_comp_name != '\0') {
+		ret = crypto_has_comp(zcache_comp_name, 0, 0);
+		if (!ret)
+			pr_info("zcache: %s not supported\n",
+					zcache_comp_name);
+	}
+	if (!ret)
+		strcpy(zcache_comp_name, "lzo");
+	ret = crypto_has_comp(zcache_comp_name, 0, 0);
+	if (!ret) {
+		ret = 1;
+		goto out;
+	}
+	pr_info("zcache: using %s compressor\n", zcache_comp_name);
+
+	/* alloc percpu transforms */
+	ret = 0;
+	zcache_comp_pcpu_tfms = alloc_percpu(struct crypto_comp *);
+	if (!zcache_comp_pcpu_tfms)
+		ret = 1;
+out:
+	return ret;
+}
+
 static int __init zcache_init(void)
 {
 	int ret = 0;
@@ -3269,6 +3364,11 @@ static int __init zcache_init(void)
 			pr_err("ramster: can't register cpu notifier\n");
 			goto out;
 		}
+		ret = zcache_comp_init();
+		if (ret) {
+			pr_err("zcache: compressor initialization failed\n");
+			goto out;
+		}
 		for_each_online_cpu(cpu) {
 			void *pcpu = (void *)(long)cpu;
 			zcache_cpu_notifier(&zcache_cpu_notifier_block,
@@ -3306,7 +3406,7 @@ static int __init zcache_init(void)
 		zcache_new_client(LOCAL_CLIENT);
 		old_ops = zcache_frontswap_register_ops();
 		pr_info("ramster: frontswap enabled using kernel "
-			"transcendent memory and xvmalloc\n");
+			"transcendent memory and zsmalloc\n");
 		if (old_ops.init != NULL)
 			pr_warning("ramster: frontswap_ops overridden");
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
