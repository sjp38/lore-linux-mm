Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4106B003D
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 06:40:41 -0500 (EST)
Date: Sat, 28 Feb 2009 12:40:32 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 2/5] fsblock: fsblock proper
Message-ID: <20090228114031.GF28496@wotan.suse.de>
References: <20090228112858.GD28496@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090228112858.GD28496@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>
List-ID: <linux-mm.kvack.org>

This is the core fsblock code. It also touches a few other little things which
I should break out, but can basically be ignored.

Non-fsblock changes:
fs-writeback.c, page-writeback.c, backing-dev.h: minor changes to support my
bdflush flusher experiment (flushing data and metadata together based on bdev
rather than pdflush looping over inodes etc, but this is disabled by default
unless you uncomment BDFLUSH_FLUSHING in fsblock_types.h).
 
main.c: fsblock_init();

sysctl.c: sysctl disable fsblock freeing on 0 refcount. Just helps comparison.

truncate.c: should effectively be a noop... some leftover stuff to fix
            superpage block truncation but it isn't quite finished.

page-flags.h: PageBlocks alias for PagePrivate, and some debugging stuff.
---
 fs/Makefile                   |    4 
 fs/fs-writeback.c             |    4 
 fs/fsb_extentmap.c            |  451 ++++
 fs/fsblock.c                  | 3869 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/backing-dev.h   |    3 
 include/linux/fsb_extentmap.h |   46 
 include/linux/fsblock.h       |  609 ++++++
 include/linux/fsblock_types.h |   99 +
 include/linux/page-flags.h    |   23 
 init/main.c                   |    2 
 kernel/sysctl.c               |    9 
 mm/page-writeback.c           |   29 
 mm/truncate.c                 |  113 -
 13 files changed, 5189 insertions(+), 72 deletions(-)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -106,6 +106,9 @@ enum pageflags {
 	/* Filesystems */
 	PG_checked = PG_owner_priv_1,
 
+	/* fsblock metadata */
+	PG_blocks = PG_private,
+
 	/* XEN */
 	PG_pinned = PG_owner_priv_1,
 	PG_savepinned = PG_dirty,
@@ -183,7 +186,8 @@ struct page;	/* forward declaration */
 TESTPAGEFLAG(Locked, locked)
 PAGEFLAG(Error, error)
 PAGEFLAG(Referenced, referenced) TESTCLEARFLAG(Referenced, referenced)
-PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
+//TESTPAGEFLAG(Dirty, dirty) SETPAGEFLAG(Dirty, dirty) TESTSETFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
+TESTPAGEFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
 PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
 PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
 	TESTCLEARFLAG(Active, active)
@@ -194,6 +198,7 @@ PAGEFLAG(SavePinned, savepinned);			/* X
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(Private, private) __CLEARPAGEFLAG(Private, private)
 	__SETPAGEFLAG(Private, private)
+PAGEFLAG(Blocks, blocks)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
 __PAGEFLAG(SlobPage, slob_page)
@@ -256,6 +261,22 @@ PAGEFLAG(Uncached, uncached)
 PAGEFLAG_FALSE(Uncached)
 #endif
 
+#define ClearPageDirty(page)					\
+do {								\
+	/* VM_BUG_ON(!PageLocked(page)); */				\
+	clear_bit(PG_dirty, &(page)->flags);			\
+} while (0)
+
+#define SetPageDirty(page)					\
+do {								\
+	set_bit(PG_dirty, &(page)->flags);			\
+} while (0)
+
+#define TestSetPageDirty(page)					\
+({								\
+	test_and_set_bit(PG_dirty, &(page)->flags);		\
+})
+
 static inline int PageUptodate(struct page *page)
 {
 	int ret = test_bit(PG_uptodate, &(page)->flags);
Index: linux-2.6/fs/Makefile
===================================================================
--- linux-2.6.orig/fs/Makefile
+++ linux-2.6/fs/Makefile
@@ -14,11 +14,13 @@ obj-y :=	open.o read_write.o file_table.
 		stack.o
 
 ifeq ($(CONFIG_BLOCK),y)
-obj-y +=	buffer.o bio.o block_dev.o direct-io.o mpage.o ioprio.o
+obj-y +=	fsblock.o buffer.o bio.o block_dev.o direct-io.o mpage.o ioprio.o
 else
 obj-y +=	no-block.o
 endif
 
+#obj-$(CONFIG_EXTMAP)		+= fsb_extentmap.o
+obj-y				+= fsb_extentmap.o
 obj-$(CONFIG_BLK_DEV_INTEGRITY) += bio-integrity.o
 obj-y				+= notify/
 obj-$(CONFIG_EPOLL)		+= eventpoll.o
Index: linux-2.6/fs/fsblock.c
===================================================================
--- /dev/null
+++ linux-2.6/fs/fsblock.c
@@ -0,0 +1,3869 @@
+/*
+ * fs/fsblock.c
+ *
+ * Copyright (C) 2009 Nick Piggin, SuSE Labs, Novell Inc.
+ */
+
+#include <linux/swap.h>
+#include <linux/fsblock.h>
+#include <linux/bitops.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/bio.h>
+#include <linux/blkdev.h>
+#include <linux/backing-dev.h>
+#include <linux/mm.h>
+#include <linux/migrate.h>
+#include <linux/gfp.h>
+#include <linux/bitops.h>
+#include <linux/pagevec.h>
+#include <linux/pagemap.h>
+#include <linux/page-flags.h>
+#include <linux/module.h>
+#include <linux/bit_spinlock.h> /* bit_spin_lock for subpage blocks */
+#include <linux/vmalloc.h> /* vmap for superpage blocks */
+#include <linux/gfp.h>
+#include <linux/cache.h>
+#include <linux/rbtree.h>
+#include <linux/kthread.h>
+#include <linux/delay.h>
+#include <linux/fsb_extentmap.h>
+
+/*
+ * XXX: take fewer page references to avoid atomics if possible, use
+ * __put_page where possible
+ */
+
+extern int try_to_free_buffers(struct page *);
+
+#define SECTOR_SHIFT	MIN_SECTOR_SHIFT
+#define NR_SUB_SIZES	(1 << (PAGE_CACHE_SHIFT - MIN_SECTOR_SHIFT))
+
+struct fsblock_kmem_cache {
+	struct kmem_cache *cache[2]; /* 1st is data, 2nd is metadata */
+	unsigned int refcount;
+	char *name[2];
+};
+
+static DEFINE_MUTEX(fsblock_kmem_cache_mutex);
+
+static struct fsblock_kmem_cache fsblock_cache[NR_SUB_SIZES + 1] __read_mostly;
+
+void __init fsblock_init(void)
+{
+	unsigned int i;
+
+	for (i = MIN_SECTOR_SHIFT; i <= PAGE_CACHE_SHIFT; i++) {
+		char *name;
+
+		name = kmalloc(32, GFP_KERNEL);
+		if (!name)
+			goto nomem;
+		if (i < 10)
+			snprintf(name, 32, "fsblock-data-%uB", 1U << i);
+		else if (i < 20)
+			snprintf(name, 32, "fsblock-data-%uKB", 1U << (i-10));
+		else if (i < 30)
+			snprintf(name, 32, "fsblock-data-%uMB", 1U << (i-20));
+		fsblock_cache[i - MIN_SECTOR_SHIFT].name[0] = name;
+
+		name = kmalloc(32, GFP_KERNEL);
+		if (!name)
+			goto nomem;
+		if (i < 10)
+			snprintf(name, 32, "fsblock-metadata-%uB", 1U << i);
+		else if (i < 20)
+			snprintf(name, 32, "fsblock-metadata-%uKB", 1U << (i-10));
+		else if (i < 30)
+			snprintf(name, 32, "fsblock-metadata-%uMB", 1U << (i-20));
+		fsblock_cache[i - MIN_SECTOR_SHIFT].name[1] = name;
+	}
+	fsblock_cache[i - MIN_SECTOR_SHIFT].name[0] = "fsblock-data-superpage";
+	fsblock_cache[i - MIN_SECTOR_SHIFT].name[1] = "fsblock-metadata-superpage";
+
+#ifdef FSB_EXTENTMAP
+	fsb_extent_init();
+#endif
+
+	return;
+
+nomem:
+	panic("Could not allocate memory for fsblock");
+}
+
+static int cache_use_block_size(unsigned int bits)
+{
+	int idx;
+	int nr;
+	int ret = 0;
+
+	if (bits <= PAGE_CACHE_SHIFT) {
+ 		idx = bits - MIN_SECTOR_SHIFT;
+		nr = 1UL << (PAGE_CACHE_SHIFT - bits);
+	} else {
+		idx = NR_SUB_SIZES;
+		nr = 1;
+	}
+
+	mutex_lock(&fsblock_kmem_cache_mutex);
+	if (!fsblock_cache[idx].refcount) {
+		struct kmem_cache *cache;
+		cache = kmem_cache_create(fsblock_cache[idx].name[0],
+			sizeof(struct fsblock)*nr, 0,
+			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_HWCACHE_ALIGN, NULL);
+		if (!cache)
+			goto out;
+
+		fsblock_cache[idx].cache[0] = cache;
+
+		cache = kmem_cache_create(
+			fsblock_cache[idx].name[1], sizeof(struct fsblock_meta)*nr, 0,
+			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_HWCACHE_ALIGN, NULL);
+		if (!cache) {
+			kmem_cache_destroy(fsblock_cache[idx].cache[0]);
+			ret = -ENOMEM;
+			goto out;
+		}
+		fsblock_cache[idx].cache[1] = cache;
+
+		fsblock_cache[idx].refcount = 1;
+	} else {
+		fsblock_cache[idx].refcount++;
+	}
+
+out:
+	mutex_unlock(&fsblock_kmem_cache_mutex);
+
+	return ret;
+}
+
+static void cache_unuse_block_size(unsigned int bits)
+{
+	int idx;
+
+	if (bits <= PAGE_CACHE_SHIFT)
+ 		idx = bits - MIN_SECTOR_SHIFT;
+	else
+		idx = NR_SUB_SIZES;
+
+	mutex_lock(&fsblock_kmem_cache_mutex);
+	FSB_BUG_ON(!fsblock_cache[idx].refcount);
+	fsblock_cache[idx].refcount--;
+	if (!fsblock_cache[idx].refcount) {
+		kmem_cache_destroy(fsblock_cache[idx].cache[0]);
+		kmem_cache_destroy(fsblock_cache[idx].cache[1]);
+	}
+	mutex_unlock(&fsblock_kmem_cache_mutex);
+}
+
+static void init_block(struct page *page, struct fsblock *block, unsigned int bits)
+{
+	block->flags = 0;
+	block->block_nr = (sector_t)ULLONG_MAX;
+	block->page = page;
+	block->private = NULL;
+	block->count = 1;
+	fsblock_set_bits(block, bits);
+}
+
+static void init_mblock(struct page *page, struct fsblock_meta *mblock, unsigned int bits)
+{
+	init_block(page, &mblock->block, bits);
+	mblock->block.flags |= BL_metadata;
+#ifdef FSB_DEBUG
+	mblock->vmap_count = 0;
+#endif
+#ifdef VMAP_CACHE
+	mblock->vce = NULL;
+#endif
+}
+
+static struct fsblock *alloc_blocks(struct page *page, unsigned int bits, gfp_t gfp_flags)
+{
+	struct fsblock *block;
+	int nid = page_to_nid(page);
+	int idx;
+	int nr;
+
+	if (bits <= PAGE_CACHE_SHIFT) {
+ 		idx = bits - MIN_SECTOR_SHIFT;
+		nr = 1UL << (PAGE_CACHE_SHIFT - bits);
+	} else {
+		idx = NR_SUB_SIZES;
+		nr = 1;
+	}
+
+	block = kmem_cache_alloc_node(fsblock_cache[idx].cache[0], gfp_flags, nid);
+	if (likely(block)) {
+		int i;
+		for (i = 0; i < nr; i++) {
+			struct fsblock *b = block + i;
+			init_block(page, b, bits);
+		}
+	}
+	return block;
+}
+
+static struct fsblock_meta *alloc_mblocks(struct page *page, unsigned int bits, gfp_t gfp_flags)
+{
+	struct fsblock_meta *mblock;
+	int nid = page_to_nid(page);
+	int idx;
+	int nr;
+
+	if (bits <= PAGE_CACHE_SHIFT) {
+ 		idx = bits - MIN_SECTOR_SHIFT;
+		nr = 1UL << (PAGE_CACHE_SHIFT - bits);
+	} else {
+		idx = NR_SUB_SIZES;
+		nr = 1;
+	}
+
+	mblock = kmem_cache_alloc_node(fsblock_cache[idx].cache[1], gfp_flags, nid);
+	if (likely(mblock)) {
+		int i;
+		for (i = 0; i < nr; i++) {
+			struct fsblock_meta *mb = mblock + i;
+			init_mblock(page, mb, bits);
+		}
+	}
+	return mblock;
+}
+
+#ifdef FSB_DEBUG
+int some_refcounted(struct fsblock *block)
+{
+	if (fsblock_subpage(block)) {
+		struct fsblock *b;
+		block = page_blocks(block->page);
+
+		for_each_block(block, b) {
+			if (b->count > 0)
+				return 1;
+			if (b->flags & (BL_dirty|BL_writeback))
+				return 1;
+			if (b->private)
+				return 1;
+		}
+		return 0;
+	}
+	if (block->count > 0)
+		return 1;
+	if (block->flags & (BL_dirty|BL_writeback))
+		return 1;
+	if (block->private)
+		return 1;
+	return 0;
+}
+EXPORT_SYMBOL(some_refcounted);
+
+void assert_block(struct fsblock *block)
+{
+	struct page *page = block->page;
+
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	FSB_BUG_ON(!PagePrivate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+	FSB_BUG_ON(!fsblock_subpage(block) && page_blocks(page) != block);
+
+	if (fsblock_superpage(block)) {
+		struct page *p;
+
+		FSB_BUG_ON(page->index != first_page_idx(page->index,
+							fsblock_size(block)));
+
+		for_each_page(page, fsblock_size(block), p) {
+			FSB_BUG_ON(!PagePrivate(p));
+			FSB_BUG_ON(!PageBlocks(p));
+			FSB_BUG_ON(page_blocks(p) != block);
+			FSB_BUG_ON((block->flags & BL_uptodate) && !PageUptodate(p));
+		} end_for_each_page;
+	} else if (fsblock_subpage(block)) {
+		struct fsblock *b;
+		block = page_blocks(block->page);
+
+		for_each_block(block, b) {
+			FSB_BUG_ON(PageUptodate(page) && !(b->flags & BL_uptodate));
+			FSB_BUG_ON(b->page != page);
+		}
+	} else {
+//		FSB_BUG_ON(PageUptodate(page) && !(block->flags & BL_uptodate));
+		FSB_BUG_ON(block->page != page);
+	}
+}
+EXPORT_SYMBOL(assert_block);
+
+static void free_block_check(struct fsblock *block)
+{
+	unsigned int flags = block->flags;
+	unsigned int badflags =
+			(BL_locked	|
+			 BL_dirty	|
+			 /* BL_error	| */
+			 BL_new	|
+			 BL_writeback |
+			 BL_readin	|
+			 BL_sync_io);
+	unsigned int goodflags = 0;
+	unsigned int size = fsblock_size(block);
+	unsigned int count = block->count;
+	unsigned int vmap_count = 0;
+	void *private = block->private;
+
+	if (block->flags & BL_metadata) {
+		struct fsblock_meta *mblock = block_mblock(block);
+		vmap_count = mblock->vmap_count;
+	}
+
+	if ((flags & badflags) || ((flags & goodflags) != goodflags) || count != 0 || private || vmap_count) {
+		printk("block flags = %x\n", flags);
+		printk("block size  = %u\n", size);
+		printk("block count = %u\n", count);
+		printk("block private = %p\n", private);
+		printk("vmap count  = %u\n", vmap_count);
+		FSB_BUG();
+	}
+}
+#endif
+
+#ifdef VMAP_CACHE
+static void invalidate_vmap_cache(struct fsblock_meta *mblock);
+#endif
+
+static void free_block(struct fsblock *block)
+{
+	unsigned int bits = fsblock_bits(block);
+	int idx;
+
+	if (fsblock_subpage(block)) {
+#ifdef FSB_DEBUG
+		int i, nr = PAGE_CACHE_SIZE >> bits;
+
+		for (i = 0; i < nr; i++) {
+			struct fsblock *b;
+			if (block->flags & BL_metadata)
+				b = &(block_mblock(block) + i)->block;
+			else
+				b = block + i;
+			free_block_check(b);
+		}
+#endif
+	} else {
+#ifdef VMAP_CACHE
+		if (block->flags & BL_vmapped) {
+			struct fsblock_meta *mblock = block_mblock(block);
+			invalidate_vmap_cache(mblock);
+		}
+#endif
+#ifdef FSB_DEBUG
+		free_block_check(block);
+#endif
+	}
+
+	if (bits <= PAGE_CACHE_SHIFT)
+ 		idx = bits - MIN_SECTOR_SHIFT;
+	else
+		idx = NR_SUB_SIZES;
+
+	kmem_cache_free(fsblock_cache[idx].cache[!!(block->flags & BL_metadata)], block);
+}
+
+static void __block_get(struct fsblock *block)
+{
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	/*
+	 * Don't check for 0 count because spin lock already ensures we have
+	 * appropriate references
+	 */
+	block->count++;
+#ifdef FSB_DEBUG
+//	printk("__block_get block:%p count:%d\n", block, block->count);
+//	dump_stack();
+	if (block->count % 128 == 127) {
+		printk("__block_get probable leak\n");
+		dump_stack();
+	}
+#endif
+}
+
+void block_get(struct fsblock *block)
+{
+	unsigned long flags;
+	spin_lock_block_irqsave(block, flags);
+	__block_get(block);
+	spin_unlock_block_irqrestore(block, flags);
+}
+EXPORT_SYMBOL(block_get);
+
+int fsblock_noblock __read_mostly = 1; /* sysctl. Like nobh mode */
+
+static void ___block_put(struct fsblock *block)
+{
+	FSB_BUG_ON(!spin_is_locked_block(block));
+//XXX	FSB_BUG_ON(block->count == 1 &&	block->vmap_count);
+	FSB_BUG_ON(block->count == 0);
+
+	/*
+	 * Don't check for 0 count because spin lock already ensures we have
+	 * appropriate references
+	 */
+	block->count--;
+}
+static void __block_put(struct fsblock *block)
+{
+	FSB_BUG_ON(fsblock_midpage(block) && block->count <= 1);
+
+	___block_put(block);
+}
+
+static int __try_to_free_blocks(struct page *page, struct fsblock *block);
+static void block_put_unlock(struct fsblock *block)
+{
+	struct page *page;
+
+	page = block->page;
+	FSB_BUG_ON(!PagePrivate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+	___block_put(block);
+
+	if (block->count > 1)
+		goto out;
+
+	if (!fsblock_noblock && likely(page->mapping))
+		goto out;
+
+	if (block->flags & (BL_dirty|BL_writeback|BL_locked))
+		goto out;
+
+	/*
+	 * At this point we'd like to try stripping the block if it is only
+	 * existing in a self-referential relationship with the pagecache (ie.
+	 * the pagecache is truncated as well), or if the block has no
+	 * pinned refcount and we in "nocache" mode.
+	 */
+	__try_to_free_blocks(page, block);
+	/* unlock in try to free gives required release memory barrier */
+	return;
+out:
+	spin_unlock_block_nocheck(block);
+}
+
+void block_put(struct fsblock *block)
+{
+	unsigned long flags;
+
+	spin_lock_block_irqsave(block, flags);
+	block_put_unlock(block);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(block_put);
+
+static int sleep_on_block(void *unused)
+{
+	io_schedule();
+	return 0;
+}
+
+int trylock_block(struct fsblock *block)
+{
+	unsigned long flags;
+	int ret;
+
+	FSB_BUG_ON(!some_refcounted(block));
+	/* XXX: audit for possible irq uses */
+	spin_lock_block_irqsave(block, flags);
+	ret = !(block->flags & BL_locked);
+	block->flags |= BL_locked;
+	spin_unlock_block_irqrestore(block, flags);
+
+	return likely(ret);
+}
+EXPORT_SYMBOL(trylock_block);
+
+void lock_block(struct fsblock *block)
+{
+	might_sleep();
+
+	while (!trylock_block(block))
+		wait_on_bit(&block->flags, BL_locked_bit, sleep_on_block,
+							TASK_UNINTERRUPTIBLE);
+}
+EXPORT_SYMBOL(lock_block);
+
+void unlock_block(struct fsblock *block)
+{
+	unsigned long flags;
+
+	FSB_BUG_ON(!some_refcounted(block));
+	spin_lock_block_irqsave(block, flags);
+	FSB_BUG_ON(!(block->flags & BL_locked));
+	block->flags &= ~BL_locked;
+	spin_unlock_block_irqrestore(block, flags);
+	smp_mb();
+	wake_up_bit(&block->flags, BL_locked_bit);
+	/* XXX: must be able to optimise this somehow by doing waitqueue
+	 * operations under block spinlock */
+}
+EXPORT_SYMBOL(unlock_block);
+
+void wait_on_block_locked(struct fsblock *block)
+{
+	might_sleep();
+
+	FSB_BUG_ON(block->count == 0);
+	if (block->flags & BL_locked)
+		wait_on_bit(&block->flags, BL_locked_bit, sleep_on_block,
+							TASK_UNINTERRUPTIBLE);
+}
+EXPORT_SYMBOL(wait_on_block_locked);
+
+static void set_block_sync_io(struct fsblock *block)
+{
+	FSB_BUG_ON(!PageLocked(block->page));
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	FSB_BUG_ON(block->flags & BL_sync_io);
+#ifdef FSB_DEBUG
+	if (fsblock_superpage(block)) {
+		struct page *page = block->page, *p;
+		for_each_page(page, fsblock_size(block), p) {
+			FSB_BUG_ON(!PageLocked(p));
+			FSB_BUG_ON(PageWriteback(p));
+		} end_for_each_page;
+	} else {
+		FSB_BUG_ON(!PageLocked(block->page));
+		FSB_BUG_ON(fsblock_midpage(block) && PageWriteback(block->page));
+	}
+#endif
+	block->flags |= BL_sync_io;
+}
+
+static void end_block_sync_io(struct fsblock *block)
+{
+	FSB_BUG_ON(!PageLocked(block->page));
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	FSB_BUG_ON(!(block->flags & BL_sync_io));
+	block->flags &= ~BL_sync_io;
+	smp_mb();
+	wake_up_bit(&block->flags, BL_sync_io_bit);
+	/* XXX: optimize by un spin locking first? */
+}
+
+static void wait_on_block_sync_io(struct fsblock *block)
+{
+	might_sleep();
+
+	FSB_BUG_ON(!PageLocked(block->page));
+	if (block->flags & BL_sync_io)
+		wait_on_bit(&block->flags, BL_sync_io_bit, sleep_on_block,
+							TASK_UNINTERRUPTIBLE);
+}
+
+static void iolock_block(struct fsblock *block)
+{
+	struct page *page, *p;
+	might_sleep();
+
+	page = block->page;
+	if (!fsblock_superpage(block))
+		lock_page(page);
+	else {
+		for_each_page(page, fsblock_size(block), p) {
+			lock_page(p);
+		} end_for_each_page;
+	}
+}
+
+static void iounlock_block(struct fsblock *block)
+{
+	struct page *page, *p;
+
+	page = block->page;
+	if (!fsblock_superpage(block))
+		unlock_page(page);
+	else {
+		for_each_page(page, fsblock_size(block), p) {
+			unlock_page(p);
+		} end_for_each_page;
+	}
+}
+
+static void wait_on_block_iolock(struct fsblock *block)
+{
+	struct page *page, *p;
+	might_sleep();
+
+	page = block->page;
+	if (!fsblock_superpage(block))
+		wait_on_page_locked(page);
+	else {
+		for_each_page(page, fsblock_size(block), p) {
+			wait_on_page_locked(p);
+		} end_for_each_page;
+	}
+}
+
+static void set_block_writeback(struct fsblock *block)
+{
+	struct page *page, *p;
+
+	page = block->page;
+	if (!fsblock_superpage(block)) {
+		FSB_BUG_ON(PageWriteback(page));
+		set_page_writeback(page);
+		unlock_page(page);
+	} else {
+		for_each_page(page, fsblock_size(block), p) {
+			FSB_BUG_ON(PageWriteback(p));
+			set_page_writeback(p);
+			unlock_page(p);
+		} end_for_each_page;
+	}
+}
+
+static void end_block_writeback(struct fsblock *block)
+{
+	struct page *page, *p;
+
+	page = block->page;
+	if (!fsblock_superpage(block))
+		end_page_writeback(page);
+	else {
+		for_each_page(page, fsblock_size(block), p) {
+			end_page_writeback(p);
+		} end_for_each_page;
+	}
+}
+
+static void wait_on_block_writeback(struct fsblock *block)
+{
+	struct page *page, *p;
+	might_sleep();
+
+	page = block->page;
+	if (!fsblock_superpage(block))
+		wait_on_page_writeback(page);
+	else {
+		for_each_page(page, fsblock_size(block), p) {
+			wait_on_page_writeback(p);
+		} end_for_each_page;
+	}
+}
+
+static struct block_device *mapping_data_bdev(struct address_space *mapping)
+{
+	struct inode *inode = mapping->host;
+	if (unlikely(S_ISBLK(inode->i_mode)))
+		return inode->i_bdev;
+	else
+		return inode->i_sb->s_bdev;
+}
+
+static int ___set_page_dirty_noblocks(struct page *page, int warn)
+{
+	FSB_BUG_ON(!PagePrivate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+	FSB_BUG_ON(warn && (!fsblock_subpage(page_blocks(page)) &&
+				!PageUptodate(page)));
+
+	return __set_page_dirty_nobuffers(page);
+}
+
+static int __set_page_dirty_noblocks(struct page *page)
+{
+	return ___set_page_dirty_noblocks(page, 1);
+}
+
+static int __set_page_dirty_noblocks_nowarn(struct page *page)
+{
+	return ___set_page_dirty_noblocks(page, 0);
+}
+
+int fsblock_set_page_dirty(struct page *page)
+{
+	unsigned long flags;
+	struct fsblock *block;
+	int ret = 0;
+
+	FSB_BUG_ON(!PageUptodate(page));
+	FSB_BUG_ON(!PagePrivate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+
+	block = page_blocks(page);
+	FSB_BUG_ON(!some_refcounted(block));
+	spin_lock_block_irqsave(block, flags);
+
+	if (fsblock_subpage(block)) {
+		struct fsblock *b;
+
+		for_each_block(block, b) {
+			FSB_BUG_ON(!(b->flags & BL_uptodate));
+			if (!(b->flags & BL_dirty)) {
+				set_block_dirty(b);
+				ret = 1;
+			}
+		}
+	} else {
+		FSB_BUG_ON(!(block->flags & BL_uptodate));
+		if (!(block->flags & BL_dirty)) {
+			set_block_dirty(block);
+			ret = 1;
+		}
+	}
+	if (__set_page_dirty_noblocks(page))
+		ret = 1;
+
+	spin_unlock_block_irqrestore(block, flags);
+
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_set_page_dirty);
+
+#ifdef VMAP_CACHE
+struct vmap_cache_entry {
+	unsigned int count, touched;
+	unsigned int nr, size;
+	void *vmap;
+	struct fsblock_meta *mblock;
+	struct list_head lru;
+};
+
+static LIST_HEAD(vc_lru);
+static DEFINE_SPINLOCK(vc_lock);
+static unsigned int vc_size;
+static unsigned int vc_hits;
+static unsigned int vc_misses;
+#define VC_MAX_ENTRIES	128
+#define VC_PRUNE_BATCH	8
+
+static void invalidate_vmap_cache(struct fsblock_meta *mblock)
+{
+	struct fsblock *block = mblock_block(mblock);
+	struct vmap_cache_entry *vce;
+
+	vce = mblock->vce;
+	FSB_BUG_ON(vce->count);
+	mblock->vce = NULL;
+	block->flags &= ~BL_vmapped;
+
+	spin_lock(&vc_lock);
+	list_del(&vce->lru);
+	vc_size--;
+	spin_unlock(&vc_lock);
+	vm_unmap_ram(vce->vmap, vce->nr);
+	kfree(vce);
+}
+
+static void prune_vmap_cache(void)
+{
+	LIST_HEAD(list);
+	int i;
+	int nr = 0;
+
+	for (i = 0; i < vc_size && vc_size > VC_MAX_ENTRIES-VC_PRUNE_BATCH; i++) {
+		struct fsblock *block;
+		struct vmap_cache_entry *vce;
+
+		FSB_BUG_ON(list_empty(&vc_lru));
+
+		vce = list_entry(vc_lru.prev, struct vmap_cache_entry, lru);
+		list_del(&vce->lru);
+
+		if (!vce->mblock) {
+			list_add_tail(&vce->lru, &list);
+			continue;
+		}
+
+		if (vce->count || vce->touched) {
+			if (!vce->count)
+				vce->touched = 0;
+busy:
+			list_add(&vce->lru, &vc_lru);
+			continue;
+		}
+
+		block = mblock_block(vce->mblock);
+		spin_lock_block_irq(block);
+		if (vce->count) {
+			spin_unlock_block_irq(block);
+			goto busy;
+		}
+		block->flags &= ~BL_vmapped;
+		vce->mblock->vce = NULL;
+		list_add_tail(&vce->lru, &list);
+		spin_unlock_block_irq(block);
+		nr++;
+		vc_size--;
+	}
+	spin_unlock_irq(&vc_lock);
+
+	while (!list_empty(&list)) {
+		struct vmap_cache_entry *vce;
+		FSB_BUG_ON(nr == 0);
+		nr--;
+		vce = list_entry(list.next, struct vmap_cache_entry, lru);
+		list_del(&vce->lru);
+		vm_unmap_ram(vce->vmap, vce->nr);
+		kfree(vce);
+	}
+	FSB_BUG_ON(nr != 0);
+}
+#endif
+
+/*
+ * Do we need a fast atomic version for just page sized / aligned maps?
+ */
+void *vmap_mblock(struct fsblock_meta *mblock, off_t off, size_t len)
+{
+	struct fsblock *block = mblock_block(mblock);
+	struct address_space *mapping = block->page->mapping;
+	unsigned int size = fsblock_size(block);
+
+	FSB_BUG_ON(off < 0);
+	FSB_BUG_ON(off + len > size);
+
+	if (!fsblock_superpage(block)) {
+		unsigned int page_offset = 0;
+		if (fsblock_subpage(block))
+			page_offset = block_page_offset(block, size);
+#ifdef FSB_DEBUG
+		spin_lock_block_irq(block);
+		mblock->vmap_count++;
+		spin_unlock_block_irq(block);
+#endif
+		return kmap(block->page) + page_offset + off;
+	} else {
+#ifdef VMAP_CACHE
+		struct vmap_cache_entry *vce;
+#endif
+		pgoff_t pgoff, start, end;
+		unsigned long pos;
+		int nr;
+		struct page **pages;
+		void *addr;
+
+#ifdef VMAP_CACHE
+		if (block->flags & BL_vmapped) {
+			spin_lock_block_irq(block);
+			if (!(block->flags & BL_vmapped)) {
+				spin_unlock_block_irq(block);
+				goto nomap;
+			}
+#ifdef FSB_DEBUG
+			mblock->vmap_count++;
+#endif
+			vc_hits++;
+			mblock->vce->count++;
+			spin_unlock_block_irq(block);
+			return mblock->vce->vmap + off;
+		}
+nomap:
+#endif
+		pgoff = block->page->index;
+		FSB_BUG_ON(pgoff != block->block_nr * (size >> PAGE_CACHE_SHIFT)); /* because it is metadata */
+		start = pgoff + (off >> PAGE_CACHE_SHIFT);
+		end = pgoff + ((off + len - 1) >> PAGE_CACHE_SHIFT);
+		pos = off & ~PAGE_CACHE_MASK;
+
+		if (start == end) {
+			struct page *page;
+
+			page = find_page(mapping, start);
+
+#ifdef FSB_DEBUG
+			spin_lock_block_irq(block);
+			mblock->vmap_count++;
+			spin_unlock_block_irq(block);
+#endif
+			return kmap(page) + pos;
+		}
+
+#ifndef VMAP_CACHE
+		nr = end - start + 1;
+#else
+		nr = size >> PAGE_CACHE_SHIFT;
+#endif
+		pages = kmalloc(nr * sizeof(struct page *), GFP_NOFS);
+		if (!pages) {
+			WARN_ON(1);
+			return ERR_PTR(-ENOMEM);
+		}
+#ifndef VMAP_CACHE
+		find_pages(mapping, start, nr, pages);
+#else
+		find_pages(mapping, pgoff, nr, pages);
+
+		vce = kmalloc(sizeof(struct vmap_cache_entry), GFP_NOFS);
+		if (!vce) {
+			kfree(pages);
+			WARN_ON(1);
+			return ERR_PTR(-ENOMEM);
+		}
+#endif
+
+		addr = vm_map_ram(pages, nr, page_to_nid(pages[0]), PAGE_KERNEL);
+		kfree(pages);
+		if (!addr) {
+			WARN_ON(1);
+			return ERR_PTR(-ENOMEM);
+		}
+
+//		profile_hit(VMAPBLK_PROFILING, __builtin_return_address(0));
+#ifdef FSB_DEBUG
+		spin_lock_block_irq(block);
+		mblock->vmap_count++;
+		spin_unlock_block_irq(block);
+#endif
+#ifndef VMAP_CACHE
+		return addr + pos;
+#else
+		spin_lock_irq(&vc_lock);
+		vc_misses++;
+		spin_lock_block(block);
+		if (!(block->flags & BL_vmapped)) {
+			mblock->vce = vce;
+			vce->mblock = mblock;
+			vce->vmap = addr;
+			vce->nr = nr;
+			vce->count = 1;
+			vce->touched = 0;
+			block->flags |= BL_vmapped;
+			spin_unlock_block(block);
+			list_add(&vce->lru, &vc_lru);
+			vc_size++;
+			if (vc_size > VC_MAX_ENTRIES)
+				prune_vmap_cache();
+			else
+				spin_unlock_irq(&vc_lock);
+		} else {
+			mblock->vce->count++;
+			spin_unlock_block(block);
+			spin_unlock_irq(&vc_lock);
+			vm_unmap_ram(addr, nr);
+			kfree(vce);
+		}
+		return mblock->vce->vmap + off;
+#endif
+	}
+}
+EXPORT_SYMBOL(vmap_mblock);
+
+void vunmap_mblock(struct fsblock_meta *mblock, off_t off, size_t len, void *vaddr)
+{
+	struct fsblock *block = mblock_block(mblock);
+#ifdef FSB_DEBUG
+	spin_lock_block_irq(block);
+	FSB_BUG_ON(mblock->vmap_count <= 0);
+	mblock->vmap_count--;
+	spin_unlock_block_irq(block);
+#endif
+	if (!fsblock_superpage(block))
+		kunmap(block->page);
+	else {
+		unsigned int size = fsblock_size(block);
+		pgoff_t pgoff, start, end;
+
+#ifdef VMAP_CACHE
+		if (block->flags & BL_vmapped) {
+			spin_lock_block(block);
+			if (!(block->flags & BL_vmapped) ||
+					vaddr - off != mblock->vce->vmap) {
+				spin_unlock_block(block);
+				goto nocache;
+			}
+			mblock->vce->count--;
+			mblock->vce->touched++;
+			spin_unlock_block(block);
+			return;
+		}
+nocache:
+#endif
+
+		pgoff = block->block_nr * (size >> PAGE_CACHE_SHIFT);
+		FSB_BUG_ON(pgoff != block->page->index);
+		start = pgoff + (off >> PAGE_CACHE_SHIFT);
+		end = pgoff + ((off + len - 1) >> PAGE_CACHE_SHIFT);
+
+		if (start == end) {
+			struct address_space *mapping = block->page->mapping;
+			struct page *page;
+
+			page = find_page(mapping, start);
+
+			kunmap(page);
+		} else {
+			unsigned long pos;
+
+			pos = off & ~PAGE_CACHE_MASK;
+			vm_unmap_ram(vaddr - pos, (len + (PAGE_CACHE_SIZE - 1)) >> PAGE_CACHE_SHIFT);
+		}
+	}
+}
+EXPORT_SYMBOL(vunmap_mblock);
+
+static struct fsblock *__find_get_block(struct address_space *mapping, sector_t blocknr, int mapped)
+{
+	struct inode *inode = mapping->host;
+	struct page *page;
+	pgoff_t pgoff;
+
+	pgoff = sector_pgoff(blocknr, inode->i_blkbits);
+
+	page = find_get_page(mapping, pgoff);
+	if (page) {
+		struct fsblock *block;
+
+		block = page_get_block(page);
+		page_cache_release(page);
+		if (block) {
+			if (fsblock_subpage(block)) {
+				struct fsblock *b;
+
+				for_each_block(block, b) {
+					if (b->block_nr == blocknr) {
+						block = b;
+						goto found;
+					}
+				}
+				FSB_BUG();
+			}
+found:
+			if (unlikely(!(block->flags & (BL_mapped|BL_hole)) &&
+								mapped)) {
+				spin_unlock_block_irq(block);
+				return NULL;
+			}
+			__block_get(block);
+			FSB_BUG_ON(block->block_nr != blocknr);
+
+			return block;
+		}
+	}
+	return NULL;
+}
+
+struct fsblock_meta *find_get_mblock(struct fsblock_sb *fsb_sb, sector_t blocknr, unsigned int size)
+{
+	struct fsblock *block;
+
+	block = __find_get_block(fsb_sb->mapping, blocknr, 1);
+	if (block) {
+		if (block->flags & BL_metadata) {
+			/*
+			 * XXX: need a better way than 'size' to tag and
+			 * identify metadata fsblocks?
+			 */
+			if (fsblock_size(block) == size) {
+				spin_unlock_block_irq(block);
+				return block_mblock(block);
+			}
+		}
+
+		block_put_unlock(block);
+		local_irq_enable();
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(find_get_mblock);
+
+static void attach_block_page(struct page *page, struct fsblock *block, unsigned int offset)
+{
+	if (block->flags & BL_metadata) {
+		unsigned int size = fsblock_size(block);
+		if (!size_is_superpage(size)) {
+			struct fsblock_meta *mblock = block_mblock(block);
+			if (!PageHighMem(page))
+				mblock->data = page_address(page);
+			else
+				mblock->data = NULL;
+			mblock->data += offset;
+		}
+	}
+
+	if (PageUptodate(page))
+		block->flags |= BL_uptodate;
+}
+
+static int invalidate_aliasing_blocks(struct page *page, unsigned int size)
+{
+	/* could check for compatible blocks here, but meh */
+	return fsblock_releasepage(page, GFP_KERNEL);
+}
+
+#define CREATE_METADATA	0x01
+int create_unmapped_blocks(struct page *page, gfp_t gfp_flags, unsigned int size, unsigned int flags)
+{
+	unsigned int bits = ffs(size) - 1;
+	struct fsblock *block;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(PageDirty(page)); /* XXX: blockdev mapping bugs here */
+	FSB_BUG_ON(PageWriteback(page));
+
+	FSB_BUG_ON(PagePrivate(page));
+
+	if (!(flags & CREATE_METADATA)) {
+		block = alloc_blocks(page, bits, gfp_flags);
+		if (!block)
+			return -ENOMEM;
+	} else {
+		struct fsblock_meta *mblock;
+		mblock = alloc_mblocks(page, bits, gfp_flags);
+		if (!mblock)
+			return -ENOMEM;
+		block = mblock_block(mblock);
+	}
+
+	if (!fsblock_superpage(block)) {
+		if (fsblock_subpage(block)) {
+			struct fsblock *b;
+			unsigned int offset = 0;
+			__for_each_block_unattached(block, size, b) {
+				attach_block_page(page, b, offset);
+				offset += size;
+			}
+		} else
+			attach_block_page(page, block, 0);
+
+		/*
+		 * Ensure block becomes visible after it is fully set up.
+		 */
+		local_irq_disable();
+		bit_spin_lock(0, &page->private);
+		FSB_BUG_ON(!page->mapping);
+		attach_page_blocks(page, block);
+
+	} else {
+		struct page *p;
+		int uptodate = 1;
+
+		FSB_BUG_ON(page->index != first_page_idx(page->index, size));
+
+		for_each_page(page, size, p) {
+			if (!PageUptodate(p))
+				uptodate = 0;
+		} end_for_each_page;
+		if (uptodate)
+			block->flags |= BL_uptodate;
+
+		local_irq_disable();
+		bit_spin_lock(0, &page->private);
+		for_each_page(page, size, p) {
+			FSB_BUG_ON(!p->mapping);
+			attach_page_blocks(p, block);
+		} end_for_each_page;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(create_unmapped_blocks);
+
+static int create_unmapped_blocks_oneref(struct page *page, gfp_t gfp_flags, unsigned int size, unsigned int flags)
+{
+	int ret;
+
+	ret = create_unmapped_blocks(page, gfp_flags, size, flags);
+	if (ret)
+		return ret;
+
+	if (size_is_subpage(size)) {
+		int i;
+		struct fsblock *block, *b;
+
+		i = 0;
+		block = page_blocks(page);
+		for_each_block(block, b) {
+			/* create unmapped blocks ref */
+			if (i > 0)
+				__block_put(b);
+			i++;
+		}
+	}
+	return ret;
+}
+
+static int lock_or_create_first_block(struct page *page, struct fsblock **block, gfp_t gfp_flags, unsigned int size, unsigned int flags)
+{
+	struct fsblock *b;
+
+	FSB_BUG_ON(!PageLocked(page));
+	b = page_get_block(page);
+	if (b) {
+		__block_get(b);
+	} else {
+		int ret;
+		ret = create_unmapped_blocks_oneref(page, GFP_NOFS, size, 0);
+		if (ret)
+			return ret;
+		else
+			b = page_blocks(page);
+	}
+	*block = b;
+	return 0;
+}
+
+static struct page *create_lock_page_range(struct address_space *mapping,
+				pgoff_t pgoff, unsigned int size)
+{
+	int nofs = 1; /* XXX: use write_begin flags for this */
+	struct page *page;
+	gfp_t gfp;
+
+	gfp = mapping_gfp_mask(mapping);
+	if (nofs)
+		gfp &= ~__GFP_FS;
+	page = find_or_create_page(mapping, pgoff, gfp);
+	if (!page)
+		return NULL;
+
+	FSB_BUG_ON(!page->mapping);
+
+	if (size_is_superpage(size)) {
+		int i, nr = size >> PAGE_CACHE_SHIFT;
+
+		FSB_BUG_ON(pgoff != first_page_idx(pgoff, size));
+
+		for (i = 1; i < nr; i++) {
+			struct page *p;
+
+			p = find_or_create_page(mapping, pgoff + i, gfp);
+			if (!p) {
+				nr = i;
+				for (i = 0; i < nr; i++) {
+					p = find_page(mapping, pgoff + i);
+					unlock_page(p);
+					page_cache_release(p);
+				}
+				return NULL;
+			}
+			FSB_BUG_ON(!p->mapping);
+		}
+	}
+	FSB_BUG_ON(page->index != pgoff);
+
+	return page;
+}
+
+static void unlock_page_range(struct page *page, unsigned int size)
+{
+	if (!size_is_superpage(size)) {
+		unlock_page(page);
+		page_cache_release(page);
+	} else {
+		struct page *p;
+
+		FSB_BUG_ON(page->index != first_page_idx(page->index, size));
+		for_each_page(page, size, p) {
+			FSB_BUG_ON(!p);
+			unlock_page(p);
+			page_cache_release(p);
+		} end_for_each_page;
+	}
+}
+
+struct fsblock_meta *find_or_create_mblock(struct fsblock_sb *fsb_sb, sector_t blocknr, unsigned int size)
+{
+	struct page *page;
+	struct fsblock *block;
+	struct fsblock_meta *mblock;
+	pgoff_t pgoff;
+	int ret;
+
+	pgoff = sector_pgoff(blocknr, fsb_sb->blkbits);
+
+again:
+	mblock = find_get_mblock(fsb_sb, blocknr, size);
+	if (mblock)
+		return mblock;
+
+	page = create_lock_page_range(fsb_sb->mapping, pgoff, size);
+	if (!page) {
+		WARN_ON(1); /* XXX */
+		return ERR_PTR(-ENOMEM);
+	}
+
+	if (PagePrivate(page) && !invalidate_aliasing_blocks(page, size)) {
+		unlock_page_range(page, size);
+		goto again;
+		/* XXX infinite loop? */
+		WARN_ON(1);
+		mblock = ERR_PTR(-EBUSY);
+		goto failed;
+	}
+	ret = create_unmapped_blocks(page, GFP_NOFS, size, CREATE_METADATA);
+	if (ret) {
+		WARN_ON(1);
+		mblock = ERR_PTR(ret);
+		goto failed;
+	}
+
+	block = page_blocks(page);
+	mblock = block_mblock(block);
+
+	/*
+	 * Technically this is just the block dev's direct mapping. Maybe
+	 * logically in that file, but on the other hand it is "metadata".
+	 */
+	if (fsblock_subpage(block)) {
+		struct fsblock_meta *ret = NULL, *mb;
+		sector_t base_block;
+		base_block = pgoff << (PAGE_CACHE_SHIFT - fsb_sb->blkbits);
+		__for_each_mblock(mblock, size, mb) {
+			mb->block.block_nr = base_block;
+			mb->block.flags |= BL_mapped;
+			if (mb->block.block_nr == blocknr) {
+				FSB_BUG_ON(ret);
+				ret = mb;
+			} else
+				__block_put(&mb->block); /* create unmapped blocks ref */
+			base_block++;
+		}
+		FSB_BUG_ON(!ret);
+		mblock = ret;
+	} else {
+		mblock->block.block_nr = blocknr;
+		mblock->block.flags |= BL_mapped;
+	}
+	spin_unlock_block_irq(&mblock->block);
+failed:
+	unlock_page_range(page, size);
+	return mblock;
+}
+EXPORT_SYMBOL(find_or_create_mblock);
+
+static void block_end_read(struct fsblock *block, int uptodate)
+{
+	int sync_io;
+	int finished_readin = 1;
+	struct page *page = block->page;
+	unsigned int size = fsblock_size(block);
+	unsigned long flags;
+
+	spin_lock_block_irqsave(block, flags);
+
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	FSB_BUG_ON(block->flags & BL_uptodate);
+	FSB_BUG_ON(block->flags & BL_error);
+	FSB_BUG_ON(!block->page->mapping);
+
+	sync_io = block->flags & BL_sync_io;
+
+	if (unlikely(!uptodate)) {
+		block->flags |= BL_error;
+		if (!fsblock_superpage(block))
+			SetPageError(page);
+		else {
+			struct page *p;
+			for_each_page(page, size, p) {
+				SetPageError(p);
+			} end_for_each_page;
+		}
+	} else
+		block->flags |= BL_uptodate;
+
+	if (fsblock_subpage(block)) {
+		struct fsblock *b, *first = page_blocks(page);
+
+		block->flags &= ~BL_readin;
+		for_each_block(first, b) {
+			if (b->flags & BL_readin) {
+				finished_readin = 0;
+				uptodate = 0;
+				break;
+			}
+			if (!(b->flags & BL_uptodate))
+				uptodate = 0;
+		}
+	} else
+		block->flags &= ~BL_readin;
+
+	if (sync_io)
+		finished_readin = 0; /* don't unlock */
+
+	if (!size_is_superpage(size)) {
+		FSB_BUG_ON(!size_is_subpage(size) && PageWriteback(page));
+		if (uptodate)
+			SetPageUptodate(page);
+		if (finished_readin)
+			unlock_page(page);
+	} else {
+		struct page *p;
+
+		for_each_page(page, size, p) {
+			FSB_BUG_ON(PageDirty(p));
+			FSB_BUG_ON(PageWriteback(p));
+			if (uptodate)
+				SetPageUptodate(p);
+			if (finished_readin)
+				unlock_page(p);
+		} end_for_each_page;
+	}
+	if (finished_readin)
+		page_cache_release(page); // __put_page(p);
+
+	if (sync_io) {
+		/*
+		 * sync_io blocks have a caller pinning the ref, so we still
+		 * are guaranteed one here. Must not touch the block after
+		 * clearing the sync_io flag, however.
+		 */
+		FSB_BUG_ON(!PageLocked(block->page));
+		end_block_sync_io(block);
+	}
+
+	block_put_unlock(block);
+	local_irq_restore(flags);
+}
+
+static void block_end_write(struct fsblock *block, int uptodate)
+{
+	int sync_io;
+	int finished_writeback = 1;
+	struct page *page = block->page;
+	unsigned int size = fsblock_size(block);
+	unsigned long flags;
+
+	spin_lock_block_irqsave(block, flags);
+
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	FSB_BUG_ON(!(block->flags & BL_uptodate));
+	FSB_BUG_ON(block->flags & BL_error);
+	FSB_BUG_ON(!block->page->mapping);
+
+	sync_io = block->flags & BL_sync_io;
+
+	if (unlikely(!uptodate)) {
+		block->flags |= BL_error;
+		if (!fsblock_superpage(block))
+			SetPageError(page);
+		else {
+			struct page *p;
+			for_each_page(page, size, p) {
+				SetPageError(p);
+			} end_for_each_page;
+			/* XXX: should we redirty the page here so it can be rewritten? */
+		}
+		set_bit(AS_EIO, &page->mapping->flags);
+	}
+
+	if (fsblock_subpage(block)) {
+		struct fsblock *b, *first = page_blocks(page);
+
+		block->flags &= ~BL_writeback;
+		for_each_block(first, b) {
+			if (b->flags & BL_writeback) {
+				finished_writeback = 0;
+				break;
+			}
+		}
+	} else
+		block->flags &= ~BL_writeback;
+
+	if (!sync_io) {
+		if (finished_writeback) {
+			if (!size_is_superpage(size)) {
+				end_page_writeback(page);
+			} else {
+				struct page *p;
+				for_each_page(page, size, p) {
+					FSB_BUG_ON(!p->mapping);
+					end_page_writeback(p);
+				} end_for_each_page;
+			}
+			page_cache_release(page); // __put_page(page);
+		}
+	} else {
+		FSB_BUG_ON(!PageLocked(block->page));
+		end_block_sync_io(block);
+	}
+
+	block_put_unlock(block);
+	local_irq_restore(flags);
+}
+
+void fsblock_end_io(struct fsblock *block, int uptodate)
+{
+	if (block->flags & BL_readin)
+		block_end_read(block, uptodate);
+	else
+		block_end_write(block, uptodate);
+}
+EXPORT_SYMBOL(fsblock_end_io);
+
+static void block_end_bio_io(struct bio *bio, int err)
+{
+	struct fsblock *block = bio->bi_private;
+	int uptodate;
+
+	uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
+	if (err == -EOPNOTSUPP) {
+		printk(KERN_WARNING "block_end_bio_io: op not supported!\n");
+		WARN_ON(uptodate);
+	}
+
+	FSB_BUG_ON((block->flags & (BL_readin|BL_writeback)) == (BL_readin|BL_writeback));
+	FSB_BUG_ON((block->flags & (BL_readin|BL_writeback)) == 0);
+
+	fsblock_end_io(block, uptodate);
+
+	bio_put(bio);
+}
+
+static int submit_block(struct fsblock *block, int rw)
+{
+	struct page *page = block->page;
+	struct address_space *mapping = page->mapping;
+	struct bio *bio;
+	int ret = 0;
+	unsigned int bits = fsblock_bits(block);
+	unsigned int size = 1 << bits;
+	int nr = (size + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
+
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	FSB_BUG_ON(rw == READ && !PageLocked(page));
+	FSB_BUG_ON(rw == WRITE && !PageWriteback(page));
+	FSB_BUG_ON(!mapping);
+	FSB_BUG_ON(!(block->flags & BL_mapped));
+
+#if 0
+	printk("submit_block for %s [blocknr=%lu, sector=%lu, size=%u] inode->i_blkbits=%d\n",
+		(block->flags & BL_readin ? "read" : "write"),
+		(unsigned long)block->block_nr,
+		(unsigned long)block->block_nr * (size >> SECTOR_SHIFT), size,
+		mapping->host->i_blkbits);
+#endif
+
+	block->flags &= ~BL_error;
+	__block_get(block);
+	spin_unlock_block_irq(block);
+
+	bio = bio_alloc(GFP_NOIO, nr);
+	bio->bi_sector = block->block_nr << (bits - SECTOR_SHIFT);
+	bio->bi_bdev = mapping_data_bdev(mapping);
+	bio->bi_end_io = block_end_bio_io;
+	bio->bi_private = block;
+
+	if (!fsblock_superpage(block)) {
+		unsigned int offset = 0;
+
+		if (fsblock_subpage(block))
+			offset = block_page_offset(block, size);
+		if (bio_add_page(bio, page, size, offset) != size)
+			FSB_BUG();
+	} else {
+		struct page *p;
+		int i;
+
+		i = 0;
+		for_each_page(page, size, p) {
+			if (bio_add_page(bio, p, PAGE_CACHE_SIZE, 0) != PAGE_CACHE_SIZE)
+				FSB_BUG();
+			i++;
+		} end_for_each_page;
+		FSB_BUG_ON(i != nr);
+	}
+
+	bio_get(bio);
+	submit_bio(rw, bio);
+	if (bio_flagged(bio, BIO_EOPNOTSUPP)) {
+		ret = -EOPNOTSUPP;
+		block_end_bio_io(bio, ret); /* XXX? */
+	}
+	bio_put(bio);
+
+	return ret;
+}
+
+static int read_block(struct fsblock *block)
+{
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	FSB_BUG_ON(!fsblock_subpage(block) && PageWriteback(block->page));
+	FSB_BUG_ON(block->flags & BL_readin);
+	FSB_BUG_ON(block->flags & BL_writeback);
+	FSB_BUG_ON(block->flags & BL_dirty);
+	block->flags |= BL_readin;
+	return submit_block(block, READ);
+}
+
+static int write_block(struct fsblock *block)
+{
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	FSB_BUG_ON(!PageWriteback(block->page));
+	FSB_BUG_ON(block->flags & BL_readin);
+	FSB_BUG_ON(block->flags & BL_writeback);
+	FSB_BUG_ON(!(block->flags & BL_uptodate));
+	block->flags |= BL_writeback;
+	return submit_block(block, WRITE);
+}
+
+void clear_block_dirty_check_page(struct fsblock *block, struct page *page, int io)
+{
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	if (fsblock_subpage(block)) {
+		struct fsblock *b;
+		for_each_block(page_blocks(page), b) {
+			if (b->flags & BL_dirty)
+				return;
+		}
+	}
+	if (!fsblock_superpage(block)) {
+		if (io)
+			clear_page_dirty(page);
+		else
+			cancel_dirty_page(page, PAGE_CACHE_SIZE);
+	} else {
+		struct page *p;
+		for_each_page(page, fsblock_size(block), p) {
+			if (io)
+				clear_page_dirty(p);
+			else
+				cancel_dirty_page(p, PAGE_CACHE_SIZE);
+		} end_for_each_page;
+	}
+}
+EXPORT_SYMBOL(clear_block_dirty_check_page);
+
+static int writeout_block(struct fsblock *block)
+{
+	int ret;
+	struct page *page = block->page;
+
+	clean_page_prepare(page);
+
+	spin_lock_block(block);
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(PageWriteback(page));
+	FSB_BUG_ON(!(block->flags & BL_dirty));
+	FSB_BUG_ON(!(block->flags & BL_uptodate));
+
+	if (!(block->flags & BL_dirty)) {
+		spin_unlock_block(block);
+		return 0;
+	}
+	clear_block_dirty(block);
+	clear_block_dirty_check_page(block, page, 1);
+
+	page_cache_get(page); /* dropped by end_io */
+	set_block_writeback(block);
+
+	ret = write_block(block);
+	if (!ret)
+		ret = 1;
+
+	return ret;
+}
+
+static int sync_block_write(struct fsblock *block)
+{
+	int ret = 0;
+	iolock_block(block);
+	wait_on_block_writeback(block);
+	if (block->flags & BL_dirty)
+		ret = writeout_block(block);
+	else
+		iounlock_block(block);
+
+	return ret;
+}
+
+static int sync_block_wait(struct fsblock *block)
+{
+	wait_on_block_writeback(block);
+	if (block->flags & BL_error)
+		return -EIO;
+	return 0;
+}
+
+int sync_block(struct fsblock *block)
+{
+	int ret = 0;
+
+	might_sleep();
+
+	if (block->flags & BL_dirty) {
+		ret = sync_block_write(block);
+		if (ret == 1)
+			ret = sync_block_wait(block);
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(sync_block);
+
+void mark_mblock_uptodate(struct fsblock_meta *mblock)
+{
+	struct fsblock *block = mblock_block(mblock);
+	struct page *page = block->page;
+	unsigned long flags;
+
+	spin_lock_block_irqsave(block, flags);
+	if (fsblock_superpage(block)) {
+		struct page *p;
+		for_each_page(page, fsblock_size(block), p) {
+			SetPageUptodate(p);
+		} end_for_each_page;
+	} else if (fsblock_midpage(block)) {
+		SetPageUptodate(page);
+	} else {
+		struct fsblock *first = page_blocks(page), *b;
+		int uptodate = 1;
+
+		for_each_block(first, b) {
+			if (b == block)
+				continue;
+			if (!(b->flags & BL_uptodate)) {
+				uptodate = 0;
+				break;
+			}
+		}
+
+		if (uptodate)
+			SetPageUptodate(page);
+	}
+	block->flags |= BL_uptodate;
+	spin_unlock_block_irqrestore(block, flags);
+}
+EXPORT_SYMBOL(mark_mblock_uptodate);
+
+int mark_mblock_dirty(struct fsblock_meta *mblock)
+{
+	struct fsblock *block = mblock_block(mblock);
+	struct page *page;
+	unsigned long flags;
+
+	FSB_BUG_ON(!fsblock_superpage(block) &&
+		!(block->flags & BL_uptodate));
+
+	if (block->flags & BL_dirty) /* memory ordering OK? */
+		return 0;
+
+	spin_lock_block_irqsave(block, flags);
+	if (test_and_set_block_dirty(block)) {
+		spin_unlock_block_irqrestore(block, flags);
+		return 0;
+	}
+
+	page = block->page;
+	if (!fsblock_superpage(block)) {
+		__set_page_dirty_noblocks(page);
+	} else {
+		struct page *p;
+		for_each_page(page, fsblock_size(block), p) {
+			__set_page_dirty_noblocks(p);
+		} end_for_each_page;
+	}
+	spin_unlock_block_irqrestore(block, flags);
+	return 1;
+}
+EXPORT_SYMBOL(mark_mblock_dirty);
+
+/*
+ * XXX: this is good, but is complex and inhibits block reclaim for now.
+ * Reworking so that it gets removed if the block is cleaned might be a
+ * good option? (would require a block flag)
+ */
+struct mb_assoc {
+	struct list_head mlist;
+	struct address_space *mapping;
+
+	struct list_head blist;
+	struct fsblock_meta *mblock;
+	int temp;
+};
+
+int mark_mblock_dirty_inode(struct fsblock_meta *mblock, struct inode *inode)
+{
+	struct address_space *mapping = inode->i_mapping;
+	struct fsblock *block = mblock_block(mblock);
+	struct mb_assoc *mba;
+	unsigned long flags;
+	int ret;
+
+	ret = mark_mblock_dirty(mblock);
+
+	spin_lock_block_irqsave(block, flags);
+	if (block->private) {
+		mba = (struct mb_assoc *)block->private;
+		do {
+			FSB_BUG_ON(mba->mblock != mblock);
+			if (mba->mapping == inode->i_mapping)
+				goto out;
+			mba = list_entry(mba->blist.next,struct mb_assoc,blist);
+		} while (mba != block->private);
+	}
+	mba = kmalloc(sizeof(struct mb_assoc), GFP_ATOMIC);
+	if (unlikely(!mba)) {
+		spin_unlock_block_irqrestore(block, flags);
+		sync_block(block);
+		return ret;
+	}
+	INIT_LIST_HEAD(&mba->mlist);
+	mba->mapping = mapping;
+	INIT_LIST_HEAD(&mba->blist);
+	mba->mblock = mblock;
+	if (block->private)
+		list_add(&mba->blist, ((struct mb_assoc *)block->private)->blist.prev);
+	else
+		__block_get(block);
+	block->private = mba;
+	spin_lock(&mapping->private_lock);
+	list_add_tail(&mba->mlist, &mapping->private_list);
+	spin_unlock(&mapping->private_lock);
+
+out:
+	spin_unlock_block_irqrestore(block, flags);
+	return ret;
+}
+EXPORT_SYMBOL(mark_mblock_dirty_inode);
+
+int fsblock_sync(struct address_space *mapping)
+{
+	int err, ret;
+	LIST_HEAD(list);
+	struct mb_assoc *mba, *tmp;
+
+	spin_lock(&mapping->private_lock);
+	list_splice_init(&mapping->private_list, &list);
+	spin_unlock(&mapping->private_lock);
+
+	err = 0;
+	list_for_each_entry_safe(mba, tmp, &list, mlist) {
+		struct fsblock *block = mblock_block(mba->mblock);
+
+		FSB_BUG_ON(mba->mapping != mapping);
+
+		spin_lock_block_irq(block);
+		if (list_empty(&mba->blist)) {
+			mba->temp = 1;
+			block->private = NULL;
+		} else {
+			mba->temp = 0;
+			if (block->private == mba)
+				block->private = list_entry(mba->blist.next, struct mb_assoc, blist);
+			list_del(&mba->blist);
+		}
+		spin_unlock_block_irq(block);
+
+		if (block->flags & BL_dirty) {
+			ret = sync_block_write(block);
+			if (ret < 0) {
+				if (!err)
+					err = ret;
+				set_bit(AS_EIO, &mba->mapping->flags);
+			}
+		}
+	}
+
+	while (!list_empty(&list)) {
+		struct fsblock *block;
+
+		/* Go in reverse order to reduce context switching */
+		mba = list_entry(list.prev, struct mb_assoc, mlist);
+		list_del(&mba->mlist);
+
+		block = mblock_block(mba->mblock);
+		ret = sync_block_wait(block);
+		if (ret < 0) {
+			if (!err)
+				err = ret;
+			set_bit(AS_EIO, &mba->mapping->flags);
+		}
+		if (mba->temp) {
+			spin_lock_block_irq(block);
+			block_put_unlock(block);
+			local_irq_enable();
+		}
+		kfree(mba);
+	}
+	return err;
+}
+EXPORT_SYMBOL(fsblock_sync);
+
+int fsblock_release(struct address_space *mapping, int force)
+{
+	struct mb_assoc *mba;
+	LIST_HEAD(list);
+
+	if (!mapping_has_private(mapping))
+		return 1;
+
+	spin_lock(&mapping->private_lock);
+	if (!force) {
+		list_for_each_entry(mba, &mapping->private_list, mlist) {
+			struct fsblock *block = mblock_block(mba->mblock);
+			if (block->flags & BL_dirty) {
+				spin_unlock(&mapping->private_lock);
+				return 0;
+			}
+		}
+	}
+	list_splice_init(&mapping->private_list, &list);
+	spin_unlock(&mapping->private_lock);
+
+	while (!list_empty(&list)) {
+		struct fsblock *block;
+		int free;
+
+		mba = list_entry(list.prev, struct mb_assoc, mlist);
+		list_del(&mba->mlist);
+
+		block = mblock_block(mba->mblock);
+		spin_lock_block_irq(block);
+		if (list_empty(&mba->blist)) {
+			free = 1;
+			block->private = NULL;
+		} else {
+			free = 0;
+			if (block->private == mba)
+				block->private = list_entry(mba->blist.next, struct mb_assoc, blist);
+			list_del(&mba->blist);
+		}
+
+		if (block->flags & BL_error)
+			set_bit(AS_EIO, &mba->mapping->flags);
+		if (free) {
+			block_put_unlock(block);
+			local_irq_enable();
+		} else
+			spin_unlock_block_irq(block);
+		kfree(mba);
+	}
+	return 1;
+}
+EXPORT_SYMBOL(fsblock_release);
+
+/*
+ * XXX: have this callable by filesystems and not by default for new blocks
+ */
+static void sync_underlying_metadata(struct fsblock_sb *fsb_sb,
+					struct fsblock *block)
+{
+	struct address_space *mapping = fsb_sb->mapping;
+	sector_t blocknr = block->block_nr;
+	struct fsblock_meta *mblock;
+
+	FSB_BUG_ON(block->flags & BL_metadata);
+
+	mblock = (struct fsblock_meta *)__find_get_block(mapping, blocknr, 1);
+	if (mblock) {
+		FSB_BUG_ON(!(block->flags & BL_metadata));
+		FSB_BUG_ON(block == (struct fsblock *)mblock);
+		mbforget(mblock);
+	}
+}
+
+void mbforget(struct fsblock_meta *mblock)
+{
+	struct fsblock *block = mblock_block(mblock);
+	struct page *page = block->page;
+	unsigned long flags;
+
+	iolock_block(block); /* hold page lock while clearing PG_dirty */
+	wait_on_block_writeback(block);
+	spin_lock_block_irqsave(block, flags);
+	if (!(block->flags & BL_dirty))
+		goto out;
+
+	if (block->flags & BL_dirty) {
+		FSB_BUG_ON(!(block->flags & BL_uptodate));
+		/* Is it ever possible to mmap these guys? Then must prepare */
+		clear_block_dirty(block);
+		clear_block_dirty_check_page(block, page, 0);
+	}
+out:
+	FSB_BUG_ON(block->flags & BL_dirty);
+
+	iounlock_block(block);
+	block_put_unlock(block);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(mbforget);
+
+int mblock_read_sync(struct fsblock_meta *mblock)
+{
+	struct fsblock *block = mblock_block(mblock);
+	int ret = 0;
+
+	if (block->flags & BL_uptodate)
+		return 0;
+
+	iolock_block(block);
+	if (!(block->flags & BL_uptodate)) {
+		spin_lock_block_irq(block);
+		FSB_BUG_ON(!fsblock_subpage(block) &&
+				PageWriteback(block->page));
+		FSB_BUG_ON(block->flags & BL_dirty);
+		set_block_sync_io(block);
+		ret = read_block(block);
+		if (ret) {
+			/* XXX: handle errors properly */
+			//block_put(block);
+		} else {
+			wait_on_block_sync_io(block);
+			if (!(block->flags & BL_uptodate))
+				ret = -EIO;
+			FSB_BUG_ON(fsblock_size(block) >= PAGE_CACHE_SIZE && !PageUptodate(block->page));
+		}
+	}
+	iounlock_block(block);
+
+	return ret;
+}
+EXPORT_SYMBOL(mblock_read_sync);
+
+struct fsblock_meta *mbread(struct fsblock_sb *fsb_sb, sector_t blocknr, unsigned int size)
+{
+	struct fsblock_meta *mblock;
+
+	mblock = find_or_create_mblock(fsb_sb, blocknr, size);
+	if (!IS_ERR(mblock)) {
+		int ret;
+
+		ret = mblock_read_sync(mblock);
+		if (ret) {
+			FSB_WARN();
+			return ERR_PTR(ret);
+		}
+	} else
+		FSB_WARN();
+
+	return mblock;
+}
+EXPORT_SYMBOL(mbread);
+
+/*
+ * XXX: maybe either don't have a generic version, or change the
+ * map_block scheme so that it fills fsblocks rather than inserts them
+ * live into pages?
+ */
+sector_t fsblock_bmap(struct address_space *mapping, sector_t blocknr, map_block_fn *map_block)
+{
+	struct fsblock *block;
+	struct inode *inode = mapping->host;
+	sector_t ret;
+
+	block = __find_get_block(mapping, blocknr, 1);
+	if (!block) {
+		unsigned int size = 1 << inode->i_blkbits;
+		struct page *page;
+		pgoff_t pgoff;
+		unsigned int nr;
+
+		pgoff = sector_pgoff(blocknr, inode->i_blkbits);
+		nr = blocknr - pgoff_sector(pgoff, inode->i_blkbits);
+
+		FSB_BUG_ON(!size_is_subpage(size) && nr > 0);
+
+		page = create_lock_page_range(mapping, pgoff, size);
+		if (!page)
+			return 0;
+
+		ret = lock_or_create_first_block(page, &block, GFP_NOFS, size, 0);
+		unlock_page_range(page, size);
+
+		if (ret)
+			return (sector_t)ULLONG_MAX;
+
+		if (fsblock_subpage(block)) {
+			struct fsblock *b;
+			int i = 0;
+
+			for_each_block(block, b) {
+				if (i == nr) {
+					block = b;
+					break;
+				}
+				i++;
+			}
+			FSB_BUG_ON(i != nr);
+		}
+		if (!(block->flags & (BL_mapped|BL_hole))) {
+			loff_t off;
+			spin_unlock_block_irq(block);
+			off = sector_offset(blocknr, inode->i_blkbits);
+			/* create block? */
+			ret = map_block(mapping, block, off, MAP_BLOCK_READ);
+			spin_lock_block_irq(block);
+			if (ret)
+				goto out_unlock;
+			FSB_BUG_ON((block->flags & (BL_hole|BL_mapped)) ==
+							(BL_hole|BL_mapped));
+		}
+	}
+
+out_unlock:
+	FSB_BUG_ON(block->flags & BL_new);
+	ret = (sector_t)ULLONG_MAX;
+	if (block->flags & BL_mapped)
+		ret = block->block_nr;
+	block_put_unlock(block);
+	local_irq_enable();
+
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_bmap);
+
+static int relock_superpage_block(struct page **pagep, unsigned int size)
+{
+	struct page *page = *pagep;
+	pgoff_t first = first_page_idx(page->index, size);
+	struct address_space *mapping = page->mapping;
+
+	/*
+	 * XXX: this is a bit of a hack because the ->readpage and other
+	 * aops APIs are not so nice. Should convert over to a ->read_range
+	 * API that does the offset, length thing and allows caller locking?
+	 * (also getting rid of ->readpages).
+	 */
+	unlock_page(page);
+	*pagep = create_lock_page_range(mapping, first, size);
+	if (!*pagep) {
+		lock_page(page);
+		return -ENOMEM;
+	}
+	if (page->mapping != mapping) {
+		unlock_page_range(*pagep, size);
+		return AOP_TRUNCATED_PAGE;
+	}
+	return 0;
+}
+
+static int block_read_helper(struct page *page, struct fsblock *block)
+{
+	FSB_BUG_ON(block->flags & BL_new);
+
+	if (block->flags & BL_uptodate)
+		return 0;
+
+	FSB_BUG_ON(PageUptodate(page));
+
+	if (block->flags & BL_hole) {
+		unsigned int size = fsblock_size(block);
+		unsigned int offset = block_page_offset(block, size);
+		zero_user(page, offset, size);
+		block->flags |= BL_uptodate;
+		return 0;
+	}
+
+	if (!(block->flags & BL_uptodate)) {
+		FSB_BUG_ON(block->flags & BL_readin);
+		FSB_BUG_ON(block->flags & BL_writeback);
+		block->flags |= BL_readin;
+		return 1;
+	}
+	return 0;
+}
+
+int fsblock_read_page(struct page *page, map_block_fn *map_block)
+{
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
+	loff_t off;
+	unsigned int size = 1 << inode->i_blkbits;
+	struct fsblock *block;
+	int ret = 0;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(PageUptodate(page));
+	FSB_BUG_ON(PageWriteback(page));
+
+	if (size_is_superpage(size)) {
+		struct page *orig_page = page;
+
+		ret = relock_superpage_block(&page, size);
+		if (ret)
+			return ret;
+		if (PageUptodate(orig_page))
+			goto out_unlock;
+	} else
+		page_cache_get(page);
+
+	ret = lock_or_create_first_block(page, &block, GFP_NOFS, size, 0);
+	if (ret)
+		goto out_unlock;
+
+	off = page_offset(page);
+
+	if (fsblock_subpage(block)) {
+		int nr = 0;
+		struct fsblock *b;
+		int i;
+
+		for_each_block(block, b) {
+			if (!(b->flags & (BL_mapped|BL_hole))) {
+				spin_unlock_block_irq(block);
+				ret = map_block(mapping, b, off, MAP_BLOCK_READ);
+				spin_lock_block_irq(block);
+				/* XXX: SetPageError on failure? */
+				if (ret)
+					goto out_drop;
+				FSB_BUG_ON((b->flags & (BL_hole|BL_mapped)) ==
+							(BL_hole|BL_mapped));
+			}
+			if (block_read_helper(page, b))
+				nr++;
+
+			off += size;
+		}
+		if (nr == 0) {
+			SetPageUptodate(page);
+			block_put_unlock(block);
+			local_irq_enable();
+			goto out_unlock;
+		}
+
+		spin_unlock_block_irq(block);
+		i = 0;
+		for_each_block(block, b) {
+			if (b->flags & BL_readin) {
+				spin_lock_block_irq(block);
+				ret = submit_block(b, READ);
+				if (ret)
+					goto out_drop;
+				i++;
+			}
+		}
+		FSB_BUG_ON(i < nr);
+		/*
+		 * XXX: must handle errors properly (eg. wait
+		 * for outstanding reads before unlocking the
+		 * page?
+		 */
+
+	} else if (fsblock_midpage(block)) {
+
+		if (!(block->flags & (BL_mapped|BL_hole))) {
+			spin_unlock_block_irq(block);
+			ret = map_block(mapping, block, off, MAP_BLOCK_READ);
+			/* XXX: SetPageError on failure? */
+			if (ret)
+				goto out_drop;
+			spin_lock_block_irq(block);
+			FSB_BUG_ON((block->flags & (BL_hole|BL_mapped)) ==
+							(BL_hole|BL_mapped));
+		}
+		if (block_read_helper(page, block)) {
+			ret = submit_block(block, READ);
+			if (ret)
+				goto out_drop;
+		} else {
+			SetPageUptodate(page);
+			block_put_unlock(block);
+			local_irq_enable();
+			goto out_unlock;
+		}
+
+	} else {
+		struct page *p;
+
+		ret = 0;
+
+		FSB_BUG_ON(block->flags & BL_new);
+		FSB_BUG_ON(block->flags & BL_uptodate);
+		FSB_BUG_ON(block->flags & BL_dirty);
+
+		if (!(block->flags & (BL_mapped|BL_hole))) {
+			spin_unlock_block_irq(block);
+			ret = map_block(mapping, block, off, MAP_BLOCK_READ);
+			if (ret)
+				goto out_drop;
+			spin_lock_block_irq(block);
+			FSB_BUG_ON((block->flags & (BL_hole|BL_mapped)) ==
+							(BL_hole|BL_mapped));
+		}
+
+		if (block->flags & BL_hole) {
+			spin_unlock_block_irq(block);
+			for_each_page(page, size, p) {
+				FSB_BUG_ON(PageUptodate(p));
+				zero_user(p, 0, PAGE_CACHE_SIZE);
+				SetPageUptodate(p);
+			} end_for_each_page;
+
+			spin_lock_block_irq(block);
+			block->flags |= BL_uptodate;
+			for_each_page(page, size, p) {
+				unlock_page(p);
+				page_cache_release(p); //__put_page(p);
+			} end_for_each_page;
+		} else {
+			ret = read_block(block);
+			if (ret)
+				goto out_unlock;
+		}
+	}
+	block_put(block);
+	FSB_BUG_ON(ret);
+	return 0;
+
+out_drop:
+	spin_lock_block_irq(block);
+	block_put_unlock(block);
+	local_irq_enable();
+
+out_unlock:
+	unlock_page_range(page, size);
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_read_page);
+
+static int block_write_helper(struct page *page, struct fsblock *block)
+{
+#if 0
+	if (test_bit(BL_new, &block->flags)) {
+		sync_underlying_metadata(block);
+		clear_bit(BL_new, &block->flags);
+		set_block_dirty(block);
+	}
+#endif
+
+	if (block->flags & BL_dirty) {
+		FSB_BUG_ON(!(block->flags & BL_mapped));
+		FSB_BUG_ON(block->flags & BL_new);
+		FSB_BUG_ON(!(block->flags & BL_uptodate));
+		clear_block_dirty(block);
+		FSB_BUG_ON(block->flags & BL_readin);
+		FSB_BUG_ON(block->flags & BL_writeback);
+		block->flags |= BL_writeback;
+		return 1;
+	}
+	return 0;
+}
+
+int fsblock_write_page(struct page *page, map_block_fn *map_block,
+				struct writeback_control *wbc)
+{
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
+	unsigned int size = 1 << inode->i_blkbits;
+	struct fsblock *block;
+	loff_t off;
+	int ret = 0;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(PageWriteback(page)); /* XXX: could allow this with work */
+
+	if (size_is_superpage(size)) {
+		struct page *p;
+
+		/* XXX: must obey non-blocking writeout! */
+		ret = relock_superpage_block(&page, size); /* takes refs */
+		if (ret)
+			return ret;
+
+		for_each_page(page, size, p) {
+			if (PageDirty(p))
+				goto has_dirty;
+		} end_for_each_page;
+		goto out_unlock;
+	} else {
+		FSB_BUG_ON(!PageDirty(page));
+		page_cache_get(page);
+	}
+
+has_dirty:
+	FSB_BUG_ON(!PagePrivate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+
+	/*
+	 * XXX: todo - i_size handling ... should it be here?!?
+	 * No - I would prefer partial page zeroing to go in filemap_nopage
+	 * and tolerate writing of crap past EOF in filesystems -- no
+	 * other sane way to do it other than invalidating a partial page
+	 * before zeroing before writing it out in order that we can
+	 * guarantee it isn't touched after zeroing.
+	 */
+
+	clean_page_prepare(page);
+
+	off = page_offset(page);
+	block = page_get_block(page);
+	if (!block) {
+		WARN_ON(1);
+		return 0;
+	}
+	__block_get(block);
+
+	if (fsblock_subpage(block)) {
+		int did_unlock;
+		int nr = 0;
+		struct fsblock *b;
+		loff_t iend;
+
+again:
+		iend = i_size_read(inode);
+
+		did_unlock = 0;
+		for_each_block(block, b) {
+			if (off >= iend) {
+				/* mmaped block can be dirtied here */
+				clear_block_dirty(b);
+			}
+			if ((b->flags & (BL_delay|BL_dirty))
+					== (BL_delay|BL_dirty)) {
+				spin_unlock_block_irq(b);
+				ret = map_block(mapping, b, off, MAP_BLOCK_ALLOCATE);
+				if (ret)
+					goto out_drop;
+				spin_lock_block_irq(b);
+				did_unlock = 1;
+				FSB_BUG_ON((b->flags & (BL_hole|BL_mapped)) ==
+							(BL_hole|BL_mapped));
+			}
+			off += size;
+		}
+		if (did_unlock)
+			goto again;
+
+		if (!PageDirty(page)) {
+			for_each_block(block, b) {
+				FSB_BUG_ON(b->flags & BL_dirty);
+			}
+			goto out_drop_locked;
+		}
+
+		clear_page_dirty(page);
+                for_each_block(block, b) {
+			/*
+			 * this happens because a file is extended via truncate
+			 * but its previous last page had blocks past isize that
+			 * were dirtied via mmap write.
+			 *
+			 * this could be solved by intercepting truncates earlier
+			 * end fixing it up there (which we need to do anyway
+			 * in case fsblock_truncate_page fails it has no way to
+			 * resolve the condition now because its too late)
+			 *
+			 * or it could possibly be solved by just not dirtying
+			 * blocks past isize via mmap. This would be nice, but
+			 * careful of isize races. Also, we have to do the above
+			 * anyway, so do that first, and then try this.
+			 */
+			BUG_ON((b->flags & (BL_dirty|BL_mapped)) == BL_dirty);
+			nr += block_write_helper(page, b);
+		}
+		/* This may happen if we cleared dirty on mmap blocks past eof */
+		if (nr == 0)
+			goto out_drop_locked;
+
+		/* Don't need ref because BL_writeback is set to pin */
+		___block_put(block);
+		spin_unlock_block_irq(block);
+
+		FSB_BUG_ON(PageWriteback(page));
+		set_page_writeback(page);
+		for_each_block(block, b) {
+			int tmp;
+
+			if (!(b->flags & BL_writeback))
+				continue;
+			spin_lock_block_irq(b);
+			tmp = submit_block(b, WRITE);
+			if (!ret)
+				ret = tmp;
+			nr--;
+			if (nr <= 0) {
+				FSB_WARN_ON(nr < 0); /* could happen */
+				/*
+				 * At this point, block is no longer
+				 * pinned because IO completion may
+				 * happen at any time. Must not keep
+				 * executing for_each_block() loop.
+				 */
+				break;
+			}
+		}
+		/* XXX: error handling */
+		if (ret)
+			goto out_unlock;
+		unlock_page(page);
+
+	} else if (fsblock_midpage(block)) {
+		if ((block->flags & (BL_delay|BL_dirty))
+				== (BL_delay|BL_dirty)) {
+			spin_unlock_block_irq(block);
+			ret = map_block(mapping, block, off, MAP_BLOCK_ALLOCATE);
+			spin_lock_block_irq(block);
+			FSB_BUG_ON((block->flags & (BL_hole|BL_mapped)) ==
+							(BL_hole|BL_mapped));
+		}
+		if (!PageDirty(page)) {
+			FSB_BUG_ON(block->flags & BL_dirty);
+			goto out_drop_locked;
+		}
+		clear_page_dirty(page);
+		if (block_write_helper(page, block)) {
+			/* Don't need ref because BL_writeback is set to pin */
+			___block_put(block);
+			FSB_BUG_ON(PageWriteback(page));
+			set_page_writeback(page);
+			ret = submit_block(block, WRITE);
+			if (ret)
+				goto out_unlock;
+			unlock_page(page);
+		} else {
+			spin_unlock_block_irq(block);
+			FSB_WARN(); /* XXX: see above */
+			goto out_drop;
+		}
+
+	} else {
+		struct page *p;
+
+		FSB_BUG_ON(!(block->flags & BL_mapped));
+		FSB_BUG_ON(!(block->flags & BL_uptodate));
+		FSB_BUG_ON(!(block->flags & BL_dirty));
+		FSB_BUG_ON(block->flags & BL_new);
+
+		for_each_page(page, size, p) {
+			FSB_BUG_ON(page_blocks(p) != block);
+			FSB_BUG_ON(!PageUptodate(p));
+		} end_for_each_page;
+
+		if (!(block->flags & BL_dirty)) {
+			for_each_page(page, size, p) {
+				FSB_BUG_ON(PageDirty(p));
+			} end_for_each_page;
+			goto out_drop_locked;
+		}
+
+		/* Don't need ref because BL_writeback is set to pin */
+		clear_block_dirty(block);
+		FSB_BUG_ON(block->flags & BL_writeback);
+		block->flags |= BL_writeback;
+		___block_put(block);
+
+		for_each_page(page, size, p) {
+			clear_page_dirty(p);
+			FSB_BUG_ON(PageWriteback(p));
+			FSB_BUG_ON(!PageUptodate(p));
+			set_page_writeback(p);
+		} end_for_each_page;
+
+		/* XXX: recheck ordering here! don't want to lose dirty bits */
+
+		FSB_BUG_ON(block->flags & BL_readin);
+		FSB_BUG_ON(!(block->flags & BL_uptodate));
+		ret = submit_block(block, WRITE);
+		if (ret)
+			goto out_unlock;
+
+		for_each_page(page, size, p) {
+			unlock_page(p);
+		} end_for_each_page;
+	}
+	FSB_BUG_ON(ret);
+	return 0;
+
+out_drop:
+	spin_lock_block_irq(block);
+out_drop_locked:
+	block_put_unlock(block);
+	local_irq_enable();
+out_unlock:
+	unlock_page_range(page, size);
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_write_page);
+
+static void page_zero_new_block(struct page *page, struct fsblock *block,
+			unsigned from, unsigned to)
+{
+	if (block->flags & BL_new) {
+		if (!PageUptodate(page)) {
+			unsigned int size = fsblock_size(block);
+			unsigned int offset = block_page_offset(block, size);
+			offset = max(from, offset);
+			size = min(size, to - offset);
+			zero_user(page, offset, size);
+		}
+
+		spin_lock_block_irq(block);
+		block->flags |= BL_uptodate;
+// XXX			sync_underlying_metadata(block);
+		FSB_BUG_ON(block->flags & BL_writeback);
+		block->flags &= ~BL_new;
+		set_block_dirty(block);
+		__set_page_dirty_noblocks(page);
+		spin_unlock_block_irq(block);
+		/* XXX: set page uptodate if blocks are brought uptodate? */
+	}
+}
+
+/*
+ * If a page has any new buffers, zero them out here, and mark them uptodate
+ * and dirty so they'll be written out (in order to prevent uninitialised
+ * block data from leaking). And clear the new bit.
+ */
+static void page_zero_new_blocks(struct page *page, struct fsblock *block,
+			unsigned from, unsigned to)
+{
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(!PagePrivate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+	FSB_BUG_ON(fsblock_superpage(block));
+
+	if (fsblock_subpage(block)) {
+		struct fsblock *b;
+
+		for_each_block(block, b)
+			page_zero_new_block(page, b, from, to);
+	} else {
+		page_zero_new_block(page, block, from, to);
+	}
+}
+
+static int block_dirty_helper(struct page *page, struct fsblock *block,
+					unsigned size, unsigned offset,
+					unsigned from, unsigned to)
+{
+	FSB_BUG_ON(!(block->flags & (BL_mapped|BL_delay)));
+
+	FSB_BUG_ON(PageUptodate(page) && !(block->flags & BL_uptodate));
+
+	if (block->flags & BL_new) {
+		if (!PageUptodate(page)) {
+			/*
+			 * Block partially uncovered from write.
+			 */
+			if (from > offset)
+				zero_user(page, offset, from - offset);
+			if (to < offset+size)
+				zero_user(page, to, offset+size - to);
+			return 0; /* not brought uptodate */
+		}
+		block->flags |= BL_uptodate;
+// XXX		sync_underlying_metadata(block);
+		FSB_BUG_ON(block->flags & BL_writeback);
+		block->flags &= ~BL_new;
+		set_block_dirty(block);
+		/*
+		 * don't warn because we set page uptodate afterwards
+		 * (it's a bit easier)
+		 */
+		__set_page_dirty_noblocks_nowarn(page);
+		return 0;
+	} else if (block->flags & (BL_uptodate|BL_delay|BL_unwritten)) {
+		return 0;
+	} else {
+		if (from <= offset && to >= offset+size)
+			return 0; /* not brought uptodate */
+		return 1;
+	}
+}
+
+static int fsblock_write_begin_super(struct file *file, struct address_space *mapping, unsigned int size, loff_t pos, unsigned len, unsigned flags, struct page **pagep, void **fsdata, map_block_fn map_block)
+{
+	pgoff_t index;
+	struct fsblock *block;
+	struct page *page, *p;
+	int ret;
+
+	index = pos >> PAGE_CACHE_SHIFT;
+
+	if (*pagep) {
+		/* XXX: caller should lock the range */
+		unlock_page(*pagep); /* hack */
+	}
+	page = create_lock_page_range(mapping, first_page_idx(index, size), size);
+	if (!page)
+		return -ENOMEM;
+
+	ret = lock_or_create_first_block(page, &block, GFP_NOFS, size, 0);
+	if (ret)
+		return ret;
+
+	if (!(block->flags & BL_mapped)) {
+		spin_unlock_block_irq(block);
+		ret = map_block(mapping, block, pos & ~(size-1), MAP_BLOCK_RESERVE);
+		if (ret)
+			goto out_unlock;
+		spin_lock_block_irq(block);
+		FSB_BUG_ON((block->flags & (BL_hole|BL_mapped)) ==
+							(BL_hole|BL_mapped));
+	}
+
+	if (block->flags & BL_new) {
+		spin_unlock_block_irq(block);
+		for_each_page(page, size, p) {
+			if (!PageUptodate(p)) {
+				FSB_BUG_ON(PageDirty(p));
+				zero_user(p, 0, PAGE_CACHE_SIZE);
+				SetPageUptodate(p);
+			}
+			__set_page_dirty_noblocks(p);
+		} end_for_each_page;
+
+		spin_lock_block_irq(block);
+		block->flags |= BL_uptodate;
+// XXX		sync_underlying_metadata(block);
+		FSB_BUG_ON(block->flags & BL_writeback);
+		block->flags &= ~BL_new;
+		set_block_dirty(block);
+		spin_unlock_block_irq(block);
+
+	} else if (!(block->flags & BL_uptodate)) {
+		FSB_BUG_ON(block->flags & BL_dirty);
+
+		set_block_sync_io(block);
+		ret = read_block(block);
+		if (ret)
+			goto out_unlock;
+		wait_on_block_sync_io(block);
+		if (!(block->flags & BL_uptodate)) {
+			ret = -EIO;
+			goto out_unlock;
+		}
+
+	} else
+		spin_unlock_block_irq(block);
+
+	if (*pagep)
+		page_cache_release(*pagep);
+	else
+		*pagep = find_page(mapping, index);
+
+	return 0;
+
+out_unlock:
+	unlock_page_range(page, size);
+	if (*pagep)
+		lock_page(*pagep);
+	return ret;
+}
+
+int fsblock_write_begin(struct file *file, struct address_space *mapping, loff_t pos, unsigned len, unsigned flags, struct page **pagep, void **fsdata, map_block_fn map_block)
+{
+	unsigned int from, to;
+	unsigned int size = 1 << mapping->host->i_blkbits;
+	struct fsblock *block;
+	struct page *page = *pagep;
+	pgoff_t index;
+	int nr_read;
+	int ret = 0;
+	int ownpage = 0;
+
+	FSB_BUG_ON(len > PAGE_CACHE_SIZE);
+
+	if (size_is_superpage(size))
+		return fsblock_write_begin_super(file, mapping, size, pos, len, flags, pagep, fsdata, map_block);
+
+	index = pos >> PAGE_CACHE_SHIFT;
+
+	if (page == NULL) {
+		ownpage = 1;
+		page = grab_cache_page_write_begin(mapping, index, flags);
+		if (!page)
+			return -ENOMEM;
+		*pagep = page;
+	}
+
+	/* XXX: could create with GFP_KERNEL here if aop flags are OK? */
+	ret = lock_or_create_first_block(page, &block, GFP_NOFS, size, 0);
+	if (ret)
+		return ret;
+
+	from = pos & ~PAGE_CACHE_MASK;
+	to = from + len;
+
+	pos &= PAGE_CACHE_MASK;
+
+	nr_read = 0;
+
+	if (fsblock_subpage(block)) {
+		struct fsblock *b;
+		unsigned off;
+
+		off = 0;
+		spin_unlock_block_irq(block);
+
+		for_each_block(block, b) {
+			if (off < to && off + size > from) {
+				if (!(b->flags & BL_mapped)) {
+					ret = map_block(mapping, b, pos+off, MAP_BLOCK_RESERVE);
+					if (ret)
+						goto out_zero_new;
+					FSB_BUG_ON((b->flags & (BL_hole|BL_mapped)) ==
+							(BL_hole|BL_mapped));
+				}
+
+				spin_lock_block_irq(block);
+				if (block_dirty_helper(page, b, size, off,
+								from, to)) {
+					nr_read++;
+					set_block_sync_io(b);
+					ret = read_block(b);
+					if (ret)
+						goto out_zero_new;
+					wait_on_block_sync_io(b);
+					if (!(b->flags & BL_uptodate)) {
+						ret = -EIO;
+						goto out_zero_new;
+					}
+				} else
+					spin_unlock_block_irq(block);
+			}
+			off += size;
+		}
+
+#if 0
+	//XXX: would like to do this? so we can do other things concurrently
+		if (nr_read) {
+			off = 0;
+			for_each_block(block, b) {
+				if (off < to && off + size > from) {
+					wait_on_block_sync_io(b);
+					if (!ret && !(b->flags & BL_uptodate))
+						ret = -EIO;
+				}
+				off += size;
+			}
+			if (ret)
+				goto out_zero_new;
+		}
+#endif
+	} else {
+		/*
+		 * XXX: distinguish map_block at write_begin time from
+		 * map_block at writeout time (eg block reserve vs allocate).
+		 */
+		if (!(block->flags & BL_mapped)) {
+			spin_unlock_block_irq(block);
+			ret = map_block(mapping, block, pos, MAP_BLOCK_RESERVE);
+			if (ret)
+				goto out_zero_new;
+			spin_lock_block_irq(block);
+			FSB_BUG_ON((block->flags & (BL_hole|BL_mapped)) ==
+							(BL_hole|BL_mapped));
+		}
+
+		if (block_dirty_helper(page, block, PAGE_CACHE_SIZE, 0, from, to)) {
+			nr_read++;
+			set_block_sync_io(block);
+			ret = read_block(block);
+		} else
+			spin_unlock_block_irq(block);
+
+		if (nr_read) {
+			wait_on_block_sync_io(block);
+			if (!ret && !(block->flags & BL_uptodate))
+				ret = -EIO;
+			if (ret)
+				goto out_zero_new;
+		}
+	}
+
+	FSB_BUG_ON(ret);
+	return ret;
+
+out_zero_new:
+	page_zero_new_blocks(page, block, from, to);
+	spin_lock_block_irq(block);
+	block_put_unlock(block);
+	local_irq_enable();
+
+	FSB_BUG_ON(!ret);
+
+	if (ownpage) {
+		unlock_page(page);
+		page_cache_release(page);
+		*pagep = NULL;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_write_begin);
+
+static void __fsblock_write_end_super(struct address_space *mapping, loff_t pos, unsigned len, unsigned copied, struct page *orig_page, void *fsdata, struct fsblock *block)
+{
+	unsigned int size = fsblock_size(block);
+	struct page *page, *p;
+
+	FSB_BUG_ON(!(block->flags & (BL_mapped|BL_delay)));
+	FSB_BUG_ON(!(block->flags & BL_uptodate));
+	set_block_dirty(block);
+	page = block->page;
+	for_each_page(page, size, p) {
+		FSB_BUG_ON(!PageUptodate(p));
+		__set_page_dirty_noblocks(p);
+	} end_for_each_page;
+	for_each_page(page, size, p) {
+		if (p != orig_page) { /* hack */
+			unlock_page(p);
+			page_cache_release(p);
+		}
+	} end_for_each_page;
+}
+
+static void __fsblock_write_end_sub(struct address_space *mapping, loff_t pos, unsigned len, unsigned copied, struct page *page, void *fsdata, struct fsblock *block)
+{
+	unsigned int size = fsblock_size(block);
+	loff_t off;
+	loff_t start_block = pos & ~(size - 1);
+	loff_t end_block = (pos + copied + size - 1) & ~(size - 1);
+	struct fsblock *b;
+	int uptodate = 1;
+
+	off = page_offset(page);
+	for_each_block(block, b) {
+		if (off < end_block && off + size > start_block) {
+			FSB_BUG_ON(!(b->flags & (BL_mapped|BL_delay)));
+			if (!(b->flags & BL_uptodate))
+				b->flags |= BL_uptodate;
+			if (!(b->flags & BL_dirty))
+				set_block_dirty(b);
+			if (b->flags & BL_new)
+				b->flags &= ~BL_new;
+		} else {
+			if (!(b->flags & BL_uptodate))
+				uptodate = 0;
+			FSB_BUG_ON(b->flags & BL_new);
+		}
+		off += size;
+
+	}
+	if (uptodate)
+		SetPageUptodate(page);
+	__set_page_dirty_noblocks(page);
+}
+
+int __fsblock_write_end(struct address_space *mapping, loff_t pos, unsigned len, unsigned copied, struct page *page, void *fsdata)
+{
+	pgoff_t index;
+	struct fsblock *block;
+
+	index = pos >> PAGE_CACHE_SHIFT;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(len > PAGE_CACHE_SIZE);
+	FSB_BUG_ON(copied > PAGE_CACHE_SIZE);
+	FSB_BUG_ON(copied > len);
+	FSB_BUG_ON(!PagePrivate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+	FSB_BUG_ON(page->index != index);
+
+	block = page_blocks(page); /* XXX: get size info from mapping? */
+
+	if (unlikely(copied < len)) {
+		unsigned start = pos & (PAGE_CACHE_SIZE - 1);
+		/* XXX: handle superpages (already handled via bringing pages uptodate?) */
+		/*
+		 * The buffers that were written will now be uptodate, so we
+		 * don't have to worry about a readpage reading them and
+		 * overwriting a partial write. However if we have encountered
+		 * a short write and only partially written into a buffer, it
+		 * will not be marked uptodate, so a readpage might come in and
+		 * destroy our partial write.
+		 *
+		 * Do the simplest thing, and just treat any short write to a
+		 * non uptodate page as a zero-length write, and force the
+		 * caller to redo the whole thing.
+		 */
+		if (!PageUptodate(page))
+			copied = 0;
+		page_zero_new_blocks(page, block, start+copied, start+len);
+		spin_lock_block_irq(block);
+		goto out;
+	}
+
+	spin_lock_block_irq(block);
+	if (fsblock_superpage(block)) {
+		__fsblock_write_end_super(mapping, pos, len, copied, page, fsdata, block);
+
+	} else if (fsblock_subpage(block)) {
+		__fsblock_write_end_sub(mapping, pos, len, copied, page, fsdata, block);
+
+	} else {
+		FSB_BUG_ON(!(block->flags & (BL_mapped|BL_delay)));
+		if (!(block->flags & BL_uptodate))
+			block->flags |= BL_uptodate;
+		if (!(block->flags & BL_dirty))
+			set_block_dirty(block);
+		if (block->flags & BL_new)
+			block->flags &= ~BL_new;
+		SetPageUptodate(page);
+		__set_page_dirty_noblocks(page);
+	}
+
+out:
+	block_put_unlock(block);
+	local_irq_enable();
+
+	return copied;
+}
+EXPORT_SYMBOL(__fsblock_write_end);
+
+int fsblock_write_end(struct file *file, struct address_space *mapping, loff_t pos, unsigned len, unsigned copied, struct page *page, void *fsdata)
+{
+	int ret;
+
+	ret = __fsblock_write_end(mapping, pos, len, copied, page, fsdata);
+
+	/*
+	 * XXX: extend must be under page lock (see Hugh's write_end data
+	 * corruption bug)! Hard for superpage blocks!
+	 */
+	if (ret > 0) {
+		struct inode *inode;
+
+		copied = ret;
+		inode = mapping->host;
+		if (pos+copied > inode->i_size) { /* XXX: real copied can be made 0 if !pageuptodate */
+			/*
+			 * No need to use i_size_read() here, the i_size cannot
+			 * change under us because we hold i_mutex.
+			 */
+			i_size_write(inode, pos+copied);
+			mark_inode_dirty(inode);
+		}
+	}
+	unlock_page(page);
+	page_cache_release(page);
+
+        return ret;
+
+}
+EXPORT_SYMBOL(fsblock_write_end);
+
+/*
+ * Must have some operation to pin a page's metadata while dirtying it. (this
+ * will fix get_user_pages for dirty as well once callers are converted).
+ */
+int fsblock_page_mkwrite(struct vm_area_struct *vma, struct page *page, map_block_fn map_block)
+{
+	loff_t isize;
+	loff_t off, eoff;
+	unsigned len;
+	void *fsdata;
+	struct address_space *mapping;
+	const struct address_space_operations *a_ops;
+	int ret = 0;
+
+	lock_page(page);
+	mapping = page->mapping;
+	if (!mapping)
+		return ret;
+
+	FSB_BUG_ON(mapping != vma->vm_file->f_path.dentry->d_inode->i_mapping);
+	a_ops = mapping->a_ops;
+
+	isize = i_size_read(mapping->host);
+	off = page_offset(page);
+	eoff = min_t(loff_t, isize, off+PAGE_CACHE_SIZE);
+	len = eoff - off;
+
+	FSB_BUG_ON(!PageUptodate(page));
+	/* XXX: don't instantiate blocks past isize! (same for truncate?) */
+	ret = fsblock_write_begin(NULL, mapping, off, len, AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata, map_block);
+	if (ret == 0) {
+		FSB_BUG_ON(!PageUptodate(page));
+		ret = __fsblock_write_end(mapping, off, len, len, page, fsdata);
+		if (ret != len)
+			ret = -1;
+		else
+			ret = 0;
+
+		FSB_BUG_ON(!PageDirty(page));
+		FSB_BUG_ON(!PagePrivate(page));
+		FSB_BUG_ON(!PageBlocks(page));
+		FSB_BUG_ON(!(page_blocks(page)->flags & (BL_mapped|BL_delay)));
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_page_mkwrite);
+
+static int fsblock_truncate_page_super(struct address_space *mapping, loff_t from)
+{
+	unsigned offset;
+	const struct address_space_operations *a_ops = mapping->a_ops;
+	unsigned int size = 1 << mapping->host->i_blkbits;
+	unsigned int nr_pages;
+	unsigned int length;
+	int i, err;
+
+	length = from & (size - 1);
+	if (length == 0)
+		return 0;
+
+	offset = from & (PAGE_CACHE_SIZE-1);
+	nr_pages = ((size - length + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT);
+
+	err = 0;
+	for (i = 0; i < nr_pages; i++) {
+		unsigned int zero;
+		struct page *page;
+		void *fsdata;
+
+		zero = PAGE_CACHE_SIZE - offset;
+		err = a_ops->write_begin(NULL, mapping, from, zero,
+				AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata);
+		if (err)
+			break;
+		FSB_BUG_ON(!PagePrivate(page));
+		FSB_BUG_ON(!PageBlocks(page));
+		zero_user(page, offset, zero);
+		err = __fsblock_write_end(mapping, from, zero, zero, page, fsdata);
+		if (err == zero)
+			err = 0;
+		/* XXX: further sanitize err? */
+		unlock_page(page);
+		page_cache_release(page);
+
+		offset = 0;
+		from = (from + PAGE_CACHE_SIZE-1) & ~(PAGE_CACHE_SIZE-1);
+	}
+	return err;
+}
+
+#include <linux/kallsyms.h>
+int fsblock_truncate_page(struct address_space *mapping, loff_t from)
+{
+	struct page *page;
+	unsigned offset;
+	unsigned zero;
+	void *fsdata;
+	const struct address_space_operations *a_ops = mapping->a_ops;
+	unsigned int size = 1 << mapping->host->i_blkbits;
+	unsigned int length;
+	int err;
+
+	if (size_is_superpage(size))
+		return fsblock_truncate_page_super(mapping, from);
+
+	length = from & (size - 1);
+	if (length == 0)
+		return 0;
+
+	zero = size - length;
+
+	offset = from & (PAGE_CACHE_SIZE-1);
+
+	err = a_ops->write_begin(NULL, mapping, from, zero, AOP_FLAG_UNINTERRUPTIBLE, &page, &fsdata);
+	if (err)
+		return err;
+
+	FSB_BUG_ON(!PagePrivate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+	zero_user(page, offset, zero);
+	/*
+	 * a_ops->write_begin would extend i_size :( Have to assume
+	 * caller uses fsblock_write_begin.
+	 */
+	err = __fsblock_write_end(mapping, from, zero, zero, page, fsdata);
+	if (err == zero)
+		err = 0;
+	/* XXX: sanitize err */
+
+#if 0 // YYY: last partial page mmaps can trigger this
+#ifdef FSB_DEBUG
+	if (size_is_subpage(size)) {
+		struct fsblock *block = page_blocks(page), *b;
+		loff_t off = page_offset(page);
+		for_each_block(block, b) {
+			FSB_BUG_ON((b->flags & BL_dirty) &&
+				((from + size - 1) & ~(size - 1)) < off+size);
+			off += size;
+		}
+	}
+#endif
+#endif
+
+	unlock_page(page);
+	page_cache_release(page);
+
+	return err;
+}
+EXPORT_SYMBOL(fsblock_truncate_page);
+
+static int can_free_block(struct fsblock *block)
+{
+	return block->count == 0 &&
+		!(block->flags & (BL_dirty|BL_writeback|BL_locked)) &&
+		!block->private;
+}
+
+static int try_to_free_blocks_super(struct page *orig_page, struct fsblock *block)
+{
+	unsigned int size;
+	struct page *page, *p;
+
+	page = block->page;
+	size = fsblock_size(block);
+
+	if (!can_free_block(block)) {
+		spin_unlock_block(block);
+		return 0;
+	}
+
+	for_each_page(page, size, p) {
+		FSB_BUG_ON(PageDirty(p));
+		FSB_BUG_ON(PageWriteback(p));
+		FSB_BUG_ON(!PagePrivate(p));
+		FSB_BUG_ON(!PageBlocks(p));
+		clear_page_blocks(p); /* XXX: will go bug after first page clears lock bit! unlock first page on last clear. */
+	} end_for_each_page;
+	preempt_enable();
+
+	free_block(block);
+
+	return 1;
+}
+
+static int __try_to_free_blocks(struct page *page, struct fsblock *block)
+{
+	FSB_BUG_ON(!(page->private & 1UL));
+	FSB_BUG_ON(!PagePrivate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+	FSB_BUG_ON(!fsblock_subpage(block) && page_blocks(page) != block);
+
+	if (fsblock_superpage(block))
+		return try_to_free_blocks_super(page, block);
+
+	if (fsblock_subpage(block)) {
+		struct fsblock *b;
+
+		if (PageDirty(page) || PageWriteback(page))
+			goto out;
+
+		if (block->flags & (BL_dirty|BL_writeback|BL_locked))
+			goto out;
+
+		block = page_blocks(page);
+		for_each_block(block, b) {
+			if (!can_free_block(b))
+				goto out;
+		}
+
+		FSB_BUG_ON(block != page_blocks(page));
+
+	} else {
+		if (!can_free_block(block))
+			goto out;
+
+		FSB_BUG_ON(PageDirty(page));
+		FSB_BUG_ON(PageWriteback(page));
+	}
+
+	clear_page_blocks(page);
+	preempt_enable();
+	free_block(block);
+
+	return 1;
+out:
+	spin_unlock_block_nocheck(block);
+	return 0;
+}
+
+int fsblock_releasepage(struct page *page, gfp_t gfp)
+{
+	struct fsblock *block;
+	int ret;
+
+	if (fsblock_noblock)
+		return !PageBlocks(page);;
+
+	block = page_get_block(page);
+	if (!block)
+		return 1;
+	ret = __try_to_free_blocks(page, block);
+	local_irq_enable();
+
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_releasepage);
+
+static void invalidate_block(struct fsblock *block)
+{
+	FSB_BUG_ON(block->flags & BL_readin);
+	FSB_BUG_ON(block->flags & BL_writeback);
+	FSB_BUG_ON(block->flags & BL_locked);
+	FSB_BUG_ON(!block->page->mapping);
+
+#if 1
+	__block_get(block);
+	spin_unlock_block_irq(block);
+	lock_block(block); /* XXX: why lock? For XFS */
+	spin_lock_block_irq(block);
+#endif
+	/*
+	 * XXX
+	 * FSB_BUG_ON(block->flags & BL_new);
+	 * -- except vmtruncate of new pages can come here
+	 *    via write_begin failure
+	 */
+	clear_block_dirty(block);
+	block->flags &= ~BL_new;
+	/* Don't clear uptodate because if the block essentially turns into a hole and remains uptodate */
+	block->flags &= ~(BL_mapped|BL_hole|BL_delay|BL_unwritten);
+	block->block_nr = (sector_t)ULLONG_MAX;
+#if 1
+	spin_unlock_block_irq(block);
+	unlock_block(block);
+	spin_lock_block_irq(block);
+	block->count--;
+#endif
+	/* XXX: if metadata, then have an fs-private release? */
+}
+
+void fsblock_invalidate_page(struct page *page, unsigned long offset)
+{
+	struct fsblock *block;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(PageWriteback(page));
+
+	/*
+	 * Could get block size from mapping, and shortcut here if offset
+	 * does not match. Not worthwhile yet.
+	 */
+
+	/* XXX: invalidate page should cancel dirty itself */
+	block = page_get_block(page);
+	if (!block)
+		return;
+
+	if (fsblock_superpage(block)) {
+		struct page *p;
+		unsigned int size = fsblock_size(block);
+		/* XXX: the below may not work for hole punching? */
+		if (page->index & ((size >> PAGE_CACHE_SHIFT) - 1))
+			goto exit;
+		if (offset != 0)
+			goto exit;
+		page = block->page;
+
+		/* XXX: could lock these pages? */
+		invalidate_block(block);
+		for_each_page(page, size, p) {
+			FSB_BUG_ON(PageWriteback(p));
+#if 0
+			XXX: generic code should not do it for us
+			if (p->index == orig_page->index)
+				continue;
+#endif
+			cancel_dirty_page(p, PAGE_CACHE_SIZE);
+			ClearPageUptodate(p);
+			ClearPageMappedToDisk(p);
+		} end_for_each_page;
+		__try_to_free_blocks(page, block);
+		local_irq_enable();
+
+		return;
+	}
+
+	if (fsblock_subpage(block)) {
+		unsigned int size = fsblock_size(block);
+		unsigned int curr;
+		struct fsblock *b;
+		int clean;
+
+		curr = 0;
+		clean = 1;
+		for_each_block(block, b) {
+			if (offset <= curr)
+				invalidate_block(b);
+			if (b->flags & BL_dirty)
+				clean = 0;
+			curr += size;
+		}
+		if (!clean)
+			goto exit;
+		cancel_dirty_page(page, PAGE_CACHE_SIZE);
+	} else {
+		if (offset == 0) {
+			invalidate_block(block);
+			cancel_dirty_page(page, PAGE_CACHE_SIZE);
+		}
+	}
+
+	if (!__try_to_free_blocks(page, block)) {
+#ifdef FSB_DEBUG
+		if (offset == 0) {
+			block = page_get_block(page);
+			if (block) {
+				printk("block=%p could not be freed\n", block);
+				printk("block->count=%d flags=%x private=%p\n", block->count, block->flags, block->private);
+				FSB_WARN();
+				block_put_unlock(block);
+			}
+		}
+#endif
+	}
+	local_irq_enable();
+	return;
+exit:
+	spin_unlock_block_irq(block);
+}
+EXPORT_SYMBOL(fsblock_invalidate_page);
+
+static struct vm_operations_struct fsblock_file_vm_ops = {
+	.fault		= filemap_fault,
+};
+
+/* This is used for a general mmap of a disk file */
+
+int fsblock_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct address_space *mapping = file->f_mapping;
+
+	if (!mapping->a_ops->readpage)
+		return -ENOEXEC;
+	file_accessed(file);
+	vma->vm_ops = &fsblock_file_vm_ops;
+	return 0;
+}
+EXPORT_SYMBOL(fsblock_file_mmap);
+
+#ifdef BDFLUSH_FLUSHING
+/*** block based writeout ***/
+struct fsblock_bd {
+	spinlock_t lock;
+	struct fsblock_sb *fsb_sb;
+	struct rb_root dirty_root;
+	unsigned long nr_dirty;
+	struct task_struct *bdflush;
+	struct list_head list;
+};
+
+static LIST_HEAD(fsblock_bd_list);
+static DEFINE_MUTEX(fsblock_bd_mutex);
+
+static void fsblock_writeout_data(struct fsblock_bd *fbd, struct backing_dev_info *bdi)
+{
+	sector_t last_block_nr = (sector_t)ULLONG_MAX;
+	unsigned long nr = 0;
+
+	/* XXX: should do write_inode() */
+
+	spin_lock(&fbd->lock);
+	FSB_BUG_ON(!RB_EMPTY_ROOT(&fbd->dirty_root) != !!fbd->nr_dirty);
+	while (fbd->nr_dirty) {
+		struct page *page;
+		struct rb_node *node;
+		struct fsblock *block;
+
+		if (last_block_nr == (sector_t)ULLONG_MAX) {
+			node = rb_first(&fbd->dirty_root);
+			block = rb_entry(node, struct fsblock, block_node);
+			printk("bdflush wrote %lu\n", nr);
+			nr = 0;
+		} else {
+			struct fsblock *tmp = NULL;
+
+			node = fbd->dirty_root.rb_node;
+			do {
+				block = rb_entry(node, struct fsblock, block_node);
+				if (block->block_nr <= last_block_nr)
+					node = node->rb_right;
+				else {
+					tmp = block;
+					if (tmp->block_nr == last_block_nr + 1)
+						break;
+					node = node->rb_left;
+				}
+			} while (node);
+			if (!tmp)
+				break;
+#if 0
+			if (!tmp) {
+				spin_unlock(&fbd->lock);
+
+				last_block_nr = (sector_t)ULLONG_MAX;
+
+				/* Batch things up a bit */
+				if (fbd->nr_dirty < 16) {
+					msleep(100);
+					printk("bdflush wrote %lu\n", nr);
+					nr = 0;
+				}
+
+				goto again;
+			}
+#endif
+			block = tmp;
+		}
+		last_block_nr = block->block_nr;
+		FSB_BUG_ON(last_block_nr == (sector_t)ULLONG_MAX);
+
+		page = block->page;
+		FSB_BUG_ON(!PagePrivate(page));
+		FSB_BUG_ON(!PageBlocks(page));
+		if (PageLocked(page) || PageWriteback(page)) {
+//			printk("page locked or writeback\n");
+			continue;
+		}
+		page_cache_get(page);
+		if (!trylock_page(page)) {
+//			printk("couldn't lock page\n");
+			page_cache_release(page);
+			continue;
+		}
+		if (PageWriteback(page)) {
+//			printk("page writeback\n");
+			unlock_page(page);
+			page_cache_release(page);
+			continue;
+		}
+		block_get(block);
+		spin_unlock(&fbd->lock);
+
+		if (fsblock_superpage(block)) {
+			struct page *p;
+			for_each_page(page, fsblock_size(block), p) {
+				if (p == block->page)
+					continue;
+				lock_page(p);
+			} end_for_each_page;
+		}
+		if (block->flags & BL_dirty)
+			writeout_block(block);
+		else
+			unlock_page(page);
+		page_cache_release(page);
+		block_put(block);
+		nr++;
+
+		if (bdi_write_congested(bdi)) {
+			printk("bdflush wrote %lu [congested]\n", nr);
+			nr = 0;
+			while (bdi_write_congested(bdi))
+				congestion_wait(WRITE, HZ);
+		}
+		cond_resched();
+
+		spin_lock(&fbd->lock);
+	}
+	spin_unlock(&fbd->lock);
+
+	printk("bdflush wrote %lu\n", nr);
+}
+
+static int bdflush(void *arg)
+{
+	struct fsblock_sb *fsb_sb = arg;
+	struct block_device *bdev = fsb_sb->sb->s_bdev;
+	struct fsblock_bd *fbd = fsb_sb->fbd;
+	struct backing_dev_info *bdi;
+
+	bdi = bdev->bd_inode_backing_dev_info;
+	if (!bdi)
+		bdi = bdev->bd_inode->i_mapping->backing_dev_info;
+
+	printk("bdflush\n");
+	while (!writeback_acquire(bdi)) {
+		printk("bdflush could not acquire bdi\n");
+		cpu_relax();
+		ssleep(1);
+	}
+	printk("bdflush starting\n");
+	while (!kthread_should_stop()) {
+		if (!fbd->nr_dirty) {
+			set_current_state(TASK_INTERRUPTIBLE);
+			if (!fbd->nr_dirty)
+				schedule_timeout(30*HZ);
+		} else
+			fsblock_writeout_data(fbd, bdi);
+	}
+	printk("bdflush finished\n");
+
+	writeback_release(bdi);
+
+	return 0;
+}
+
+void writeback_blockdevs_background(void)
+{
+	struct fsblock_bd *fbd;
+	might_sleep();
+
+	mutex_lock(&fsblock_bd_mutex);
+	list_for_each_entry(fbd, &fsblock_bd_list, list) {
+		if (!fbd->nr_dirty)
+			continue;
+
+		wake_up_process(fbd->bdflush);
+	}
+	mutex_unlock(&fsblock_bd_mutex);
+}
+
+static int fsblock_register_sb_bdev(struct fsblock_sb *fsb_sb,
+				struct block_device *bdev)
+{
+	struct fsblock_bd *fbd;
+
+	FSB_BUG_ON(bdev->bd_private);
+
+	fbd = kmalloc(sizeof(struct fsblock_bd), GFP_KERNEL);
+	if (!fbd)
+		return -ENOMEM;
+	fsb_sb->fbd = fbd;
+	spin_lock_init(&fbd->lock);
+	fbd->fsb_sb = fsb_sb;
+	fbd->dirty_root = RB_ROOT;
+	fbd->nr_dirty = 0;
+	fbd->bdflush = kthread_create(bdflush, fsb_sb, "bdflush");
+	if (IS_ERR(fbd->bdflush)) {
+		int err = PTR_ERR(fbd->bdflush);
+		kfree(fbd);
+		return err;
+	}
+
+	bdev->bd_private = (unsigned long)fbd;
+
+	mutex_lock(&fsblock_bd_mutex);
+	list_add_tail(&fbd->list, &fsblock_bd_list);
+	mutex_unlock(&fsblock_bd_mutex);
+
+	wake_up_process(fbd->bdflush);
+
+	return 0;
+}
+
+static void fsblock_unregister_sb_bdev(struct fsblock_sb *fsb_sb,
+				struct block_device *bdev)
+{
+	struct fsblock_bd *fbd;
+
+	fbd = fsb_sb->fbd;
+	kthread_stop(fbd->bdflush);
+	FSB_BUG_ON(bdev->bd_private != (unsigned long)fbd);
+	bdev->bd_private = 0;
+	fsb_sb->fbd = NULL;
+
+	mutex_lock(&fsblock_bd_mutex);
+	list_del(&fbd->list);
+	mutex_unlock(&fsblock_bd_mutex);
+
+	kfree(fbd);
+}
+
+#ifdef FSB_DEBUG
+void fbd_discard_block(struct address_space *mapping, sector_t block_nr)
+{
+	struct fsblock_bd *fbd;
+	struct rb_node **p;
+	struct rb_node *parent = NULL;
+
+
+	fbd = (struct fsblock_bd *)mapping_data_bdev(mapping)->bd_private;
+
+	p = &fbd->dirty_root.rb_node;
+	spin_lock(&fbd->lock);
+
+	FSB_BUG_ON(!fbd->nr_dirty && !RB_EMPTY_ROOT(&fbd->dirty_root));
+	FSB_BUG_ON(fbd->nr_dirty && RB_EMPTY_ROOT(&fbd->dirty_root));
+	while (*p != NULL) {
+		struct fsblock *tmp;
+
+		parent = *p;
+		tmp = rb_entry(parent, struct fsblock, block_node);
+
+		if (block_nr < tmp->block_nr)
+			p = &parent->rb_left;
+		else if (block_nr > tmp->block_nr)
+			p = &parent->rb_right;
+		else {
+			FSB_WARN(); /* XXX: no alias avoidance so this may trigger */
+			printk("dirty block discarded block_nr=%llx mapping=%p\n", (unsigned long long)block_nr, mapping);
+			break;
+		}
+	}
+
+	spin_unlock(&fbd->lock);
+}
+#endif
+
+static void fbd_add_dirty_block(struct fsblock_bd *fbd, struct fsblock *block)
+{
+	struct rb_node **p = &fbd->dirty_root.rb_node;
+	struct rb_node *parent = NULL;
+
+	spin_lock(&fbd->lock);
+
+	FSB_BUG_ON(!fbd->nr_dirty && !RB_EMPTY_ROOT(&fbd->dirty_root));
+	FSB_BUG_ON(fbd->nr_dirty && RB_EMPTY_ROOT(&fbd->dirty_root));
+	FSB_BUG_ON(block->flags & BL_dirty);
+
+	block->flags |= BL_dirty;
+
+	VM_BUG_ON(block->flags & BL_dirty_acct);
+	block->flags |= BL_dirty_acct;
+
+	while (*p != NULL) {
+		struct fsblock *tmp;
+
+		parent = *p;
+		tmp = rb_entry(parent, struct fsblock, block_node);
+
+		if (block->block_nr < tmp->block_nr)
+			p = &parent->rb_left;
+		else if (block->block_nr > tmp->block_nr)
+			p = &parent->rb_right;
+		else {
+			FSB_WARN(); /* XXX: no alias avoidance so this may trigger */
+			/* XXX: truncating subpage blocks that are mmapped can cause big problems. Must fix */
+			goto out;
+		}
+	}
+
+	rb_link_node(&block->block_node, parent, p);
+	rb_insert_color(&block->block_node, &fbd->dirty_root);
+
+	fbd->nr_dirty++;
+	FSB_BUG_ON(RB_EMPTY_ROOT(&fbd->dirty_root));
+out:
+	spin_unlock(&fbd->lock);
+}
+
+static void fbd_del_dirty_block(struct fsblock_bd *fbd, struct fsblock *block)
+{
+	spin_lock(&fbd->lock);
+
+	FSB_BUG_ON(!(block->flags & BL_dirty));
+//	printk("fbd_del_dirty_block block=%p block->block_nr=%llx page->mapping=%p page->index=%lx\n", block, (unsigned long long)block->block_nr, block->page->mapping, block->page->index);
+	FSB_BUG_ON(RB_EMPTY_NODE(&block->block_node));
+	rb_erase(&block->block_node, &fbd->dirty_root);
+	RB_CLEAR_NODE(&block->block_node);
+
+	FSB_BUG_ON(!(block->flags & BL_dirty_acct));
+	block->flags &= ~(BL_dirty|BL_dirty_acct);
+	FSB_BUG_ON(fbd->nr_dirty == 0);
+	fbd->nr_dirty--;
+	FSB_BUG_ON(!fbd->nr_dirty && !RB_EMPTY_ROOT(&fbd->dirty_root));
+	FSB_BUG_ON(fbd->nr_dirty && RB_EMPTY_ROOT(&fbd->dirty_root));
+
+	spin_unlock(&fbd->lock);
+}
+
+/* XXX: must have something to clear the page dirty state when all blocks
+ * go clean
+ */
+void clear_block_dirty(struct fsblock *block)
+{
+	struct fsblock_bd *fbd;
+
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	if (!(block->flags & BL_dirty))
+		return;
+
+	fbd = (struct fsblock_bd *)mapping_data_bdev(block->page->mapping)->bd_private;
+	fbd_del_dirty_block(fbd, block);
+}
+
+int test_and_set_block_dirty(struct fsblock *block)
+{
+	struct fsblock_bd *fbd;
+
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	if (block->flags & BL_dirty)
+		return 1;
+
+	fbd = (struct fsblock_bd *)mapping_data_bdev(block->page->mapping)->bd_private;
+	fbd_add_dirty_block(fbd, block);
+
+	return 0;
+}
+
+#else /* BDFLUSH_FLUSHING */
+
+static int fsblock_register_sb_bdev(struct fsblock_sb *fsb_sb,
+				struct block_device *bdev)
+{
+	return 0;
+}
+
+static void fsblock_unregister_sb_bdev(struct fsblock_sb *fsb_sb,
+				struct block_device *bdev)
+{
+}
+
+#endif
+
+static int meta_map_block(struct address_space *mapping,
+				struct fsblock *fsblock, loff_t off,
+				int create)
+{
+	FSB_BUG();
+	return 0;
+}
+
+static int fsblock_meta_write_page(struct page *page,
+				struct writeback_control *wbc)
+{
+	return fsblock_write_page(page, meta_map_block, wbc);
+}
+
+int fsblock_register_super(struct super_block *sb, struct fsblock_sb *fsb_sb)
+{
+        struct backing_dev_info *bdi;
+        struct inode            *inode;
+        struct address_space    *mapping;
+	struct block_device	*bdev = sb->s_bdev;
+	static const struct address_space_operations mapping_aops = {
+		.writepage = fsblock_meta_write_page,
+		.set_page_dirty = fsblock_set_page_dirty,
+		.releasepage = fsblock_releasepage,
+		.invalidatepage = fsblock_invalidate_page,
+		.migratepage = fail_migrate_page,
+	};
+	int ret;
+
+	ret = cache_use_block_size(sb->s_blocksize_bits);
+	if (ret)
+		return ret;
+
+	ret = fsblock_register_sb_bdev(fsb_sb, bdev);
+	if (ret)
+		return ret;
+
+        inode = new_inode(bdev->bd_inode->i_sb);
+        if (!inode)
+                return -ENOMEM;
+        inode->i_mode = S_IFBLK;
+        inode->i_bdev = bdev;
+        inode->i_rdev = bdev->bd_dev;
+        bdi = blk_get_backing_dev_info(bdev);
+        if (!bdi)
+                bdi = &default_backing_dev_info;
+        mapping = &inode->i_data;
+        mapping->a_ops = &mapping_aops;
+        mapping->backing_dev_info = bdi;
+        mapping_set_gfp_mask(mapping, GFP_KERNEL);
+	FSB_BUG_ON(!mapping_cap_account_dirty(mapping));
+	fsb_sb->mapping = mapping;
+	fsb_sb->sb = sb;
+	fsb_sb->blocksize = sb->s_blocksize;
+	fsb_sb->blkbits = sb->s_blocksize_bits;
+
+	inode->i_blkbits = sb->s_blocksize_bits;
+	i_size_write(inode, i_size_read(bdev->bd_inode));
+
+	printk("blocksize=%x blkbits=%d size=%lld\n", fsb_sb->blocksize, fsb_sb->blkbits, i_size_read(inode));
+
+	return 0;
+}
+EXPORT_SYMBOL(fsblock_register_super);
+
+void fsblock_unregister_super(struct super_block *sb, struct fsblock_sb *fsb_sb)
+{
+	struct block_device	*bdev = sb->s_bdev;
+
+	filemap_write_and_wait(fsb_sb->mapping);
+	iput(fsb_sb->mapping->host);
+
+	fsblock_unregister_sb_bdev(fsb_sb, bdev);
+	cache_unuse_block_size(sb->s_blocksize_bits);
+}
+EXPORT_SYMBOL(fsblock_unregister_super);
+
+int fsblock_register_super_light(struct super_block *sb)
+{
+	return cache_use_block_size(sb->s_blocksize_bits);
+}
+EXPORT_SYMBOL(fsblock_register_super_light);
+
+void fsblock_unregister_super_light(struct super_block *sb)
+{
+	cache_unuse_block_size(sb->s_blocksize_bits);
+}
+EXPORT_SYMBOL(fsblock_unregister_super_light);
Index: linux-2.6/include/linux/fsblock.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/fsblock.h
@@ -0,0 +1,609 @@
+#ifndef __FSBLOCK_H__
+#define __FSBLOCK_H__
+
+#include <linux/fsblock_types.h>
+#include <linux/types.h>
+#include <linux/spinlock.h>
+#include <linux/bit_spinlock.h>
+#include <linux/fs.h>
+#include <linux/bitops.h>
+#include <linux/page-flags.h>
+#include <linux/mm_types.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/gfp.h>
+
+#include <linux/kallsyms.h>
+#define MIN_SECTOR_SHIFT	9 /* 512 bytes */
+#define MIN_SECTOR_SIZE		(1UL<<MIN_SECTOR_SHIFT)
+#ifndef MAX_BUF_PER_PAGE
+#define MAX_BUF_PER_PAGE (PAGE_CACHE_SIZE / MIN_SECTOR_SIZE)
+#endif
+
+#define BL_bits_mask	0x000f
+
+#define BL_locked	0x0010
+#define BL_locked_bit	4
+#define BL_dirty	0x0020
+#define BL_error	0x0040
+#define BL_uptodate	0x0080
+
+#define BL_mapped	0x0100
+#define BL_hole		0x0200
+#define BL_new		0x0400
+#define BL_writeback	0x0800
+
+#define BL_readin	0x1000
+#define BL_sync_io	0x2000	/* IO completion doesn't unlock/unwriteback */
+#define BL_sync_io_bit	13
+#define BL_metadata	0x4000	/* Metadata. If set, page->mapping is the
+				 * blkdev inode. */
+#ifdef VMAP_CACHE
+#define BL_vmapped	0x8000
+#endif
+
+#define BL_dirty_acct	0x10000
+#define BL_unwritten	0x20000
+#define BL_delay	0x40000
+
+#ifndef FSB_DEBUG
+static inline void assert_block(struct fsblock *block)
+{
+}
+#else
+void assert_block(struct fsblock *block);
+#endif
+
+
+#define MAP_BLOCK_READ		0
+#define MAP_BLOCK_RESERVE	1
+#define MAP_BLOCK_ALLOCATE	2
+
+/*
+ * XXX: should distinguish data buffer and metadata buffer. data buffer
+ * attachment (or dirtyment?) could cause the page to *also* be added to
+ * the metadata page_tree (with the host inode still at page->mapping). This
+ * could allow coherent blkdev/pagecache and also nice block device based
+ * page writeout. Probably lots of weird problems though.
+ */
+
+static inline struct fsblock_meta *block_mblock(struct fsblock *block)
+{
+	FSB_BUG_ON(!(block->flags & BL_metadata));
+	return (struct fsblock_meta *)block;
+}
+
+static inline struct fsblock *mblock_block(struct fsblock_meta *mblock)
+{
+	return &mblock->block;
+}
+
+static inline unsigned int fsblock_bits(struct fsblock *block)
+{
+	unsigned int bits = (block->flags & BL_bits_mask) + MIN_SECTOR_SHIFT;
+#if 0
+#ifdef FSB_DEBUG
+	if (!(block->flags & BL_metadata))
+		FSB_BUG_ON(block->page->mapping->host->i_blkbits != bits);
+#endif
+#endif
+	return bits;
+}
+
+static inline void fsblock_set_bits(struct fsblock *block, unsigned int bits)
+{
+	FSB_BUG_ON(block->flags & BL_bits_mask);
+	FSB_BUG_ON(bits < MIN_SECTOR_SHIFT);
+	FSB_BUG_ON(bits > BL_bits_mask + MIN_SECTOR_SHIFT);
+	block->flags |= bits - MIN_SECTOR_SHIFT;
+}
+
+static inline int size_is_superpage(unsigned int size)
+{
+#ifdef BLOCK_SUPERPAGE_SUPPORT
+	return size > PAGE_CACHE_SIZE;
+#else
+	return 0;
+#endif
+}
+
+static inline int size_is_subpage(unsigned int size)
+{
+#ifdef BLOCK_SUBPAGE_SUPPORT
+	return size < PAGE_CACHE_SIZE;
+#else
+	return 0;
+#endif
+}
+
+static inline int fsblock_subpage(struct fsblock *block)
+{
+	return fsblock_bits(block) < PAGE_CACHE_SHIFT;
+}
+
+static inline int fsblock_midpage(struct fsblock *block)
+{
+	return fsblock_bits(block) == PAGE_CACHE_SHIFT;
+}
+
+static inline int fsblock_superpage(struct fsblock *block)
+{
+#ifdef BLOCK_SUPERPAGE_SUPPORT
+	return fsblock_bits(block) > PAGE_CACHE_SHIFT;
+#else
+	return 0;
+#endif
+}
+
+static inline unsigned int fsblock_size(struct fsblock *block)
+{
+	return 1 << fsblock_bits(block);
+}
+
+static inline int sizeof_block(struct fsblock *block)
+{
+	if (block->flags & BL_metadata)
+		return sizeof(struct fsblock_meta);
+	else
+		return sizeof(struct fsblock);
+
+}
+
+static inline struct fsblock *page_blocks(struct page *page)
+{
+	struct fsblock *block;
+	FSB_BUG_ON(!PagePrivate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+
+	block = (struct fsblock *)(page->private & ~1UL);
+	FSB_BUG_ON(!block);
+	FSB_BUG_ON(!fsblock_superpage(block) && block->page != page);
+	/* XXX these go bang if put here
+	FSB_BUG_ON(PageUptodate(page) && !(block->flags & BL_uptodate));
+	FSB_BUG_ON((block->flags & BL_dirty) && !PageDirty(page));
+	*/
+	return block;
+}
+
+static inline struct fsblock *page_get_block(struct page *page)
+{
+	struct fsblock *block = NULL;
+
+	if (!PagePrivate(page))
+		return NULL;
+
+	local_irq_disable();
+	bit_spin_lock(0, &page->private);
+	if (PagePrivate(page)) {
+		block = page_blocks(page);
+		assert_block(block);
+	} else {
+		__bit_spin_unlock(0, &page->private);
+		local_irq_enable();
+	}
+
+	return block;
+}
+
+static inline struct fsblock_meta *page_mblocks(struct page *page)
+{
+	return block_mblock(page_blocks(page));
+}
+
+static inline void attach_page_blocks(struct page *page, struct fsblock *block)
+{
+	FSB_BUG_ON((unsigned long)block & 1);
+	FSB_BUG_ON(!bit_spin_is_locked(0, &block->page->private));
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(PagePrivate(page));
+	FSB_BUG_ON(PageBlocks(page));
+	FSB_BUG_ON(PageWriteback(page));
+	FSB_BUG_ON(PageDirty(page));
+	SetPagePrivate(page);
+	SetPageBlocks(page);
+	page->private = (unsigned long)block | 1UL; /* this retains the lock bit */
+	page_cache_get(page);
+}
+
+static inline void clear_page_blocks(struct page *page)
+{
+	FSB_BUG_ON(!(page->private & 1UL));
+	FSB_BUG_ON(!PagePrivate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+	FSB_BUG_ON(PageWriteback(page));
+	FSB_BUG_ON(PageDirty(page));
+	ClearPagePrivate(page);
+	ClearPageBlocks(page);
+	page->private = (unsigned long)NULL;
+	page_cache_release(page);
+}
+
+
+#define assert_first_block(first)					\
+({									\
+	FSB_BUG_ON((struct fsblock *)first != page_blocks(first->page));\
+	first;								\
+})
+
+#define block_inbounds(first, b, bsize, size_of)			\
+({									\
+	int ret;							\
+	FSB_BUG_ON(!fsblock_subpage(first));				\
+	FSB_BUG_ON(sizeof_block(first) != size_of);			\
+	ret = ((unsigned long)b - (unsigned long)first) * bsize <	\
+					PAGE_CACHE_SIZE * size_of;	\
+	if (ret) {							\
+		FSB_BUG_ON(!fsblock_subpage(b));			\
+		FSB_BUG_ON((first->flags ^ b->flags) & BL_metadata);	\
+		FSB_BUG_ON(sizeof_block(b) != size_of);			\
+	}								\
+	ret;								\
+})
+
+#define for_each_block(first, b)					\
+ for (b = assert_first_block(first); block_inbounds(first, b, fsblock_size(first), sizeof_block(first)); b = (void *)((unsigned long)b + sizeof_block(first)))
+
+#define __for_each_block(first, size, b)				\
+ for (b = assert_first_block(first); block_inbounds(first, b, size, sizeof(struct fsblock)); b++)
+
+/* can't access page_blocks() (inconsistent because we take block and mblock) */
+#define __for_each_block_unattached(first, size, b)			\
+ for (b = first; block_inbounds(first, b, size, sizeof_block(first)); b = (void *)((unsigned long)b + sizeof_block(first)))
+
+#define __for_each_mblock(first, size, mb)				\
+ for (mb = block_mblock(assert_first_block(mblock_block(first))); block_inbounds(mblock_block(first), mblock_block(mb), size, sizeof(struct fsblock_meta)); mb++)
+
+
+#define first_page_idx(idx, bsize) ((idx) & ~(((bsize) >> PAGE_CACHE_SHIFT)-1))
+
+static inline struct page *find_page(struct address_space *mapping, pgoff_t index)
+{
+	struct page *page;
+
+	page = radix_tree_lookup(&mapping->page_tree, index);
+	FSB_BUG_ON(!page);
+
+	return page;
+}
+
+static inline void find_pages(struct address_space *mapping, pgoff_t start, int nr_pages, struct page **pages)
+{
+	int ret;
+
+        ret = radix_tree_gang_lookup(&mapping->page_tree,
+				(void **)pages, start, nr_pages);
+	FSB_BUG_ON(ret != nr_pages);
+}
+
+#define for_each_page(page, size, p)					\
+do {									\
+	pgoff_t ___idx = (page)->index;					\
+	int ___i, ___nr = (size) >> PAGE_CACHE_SHIFT;			\
+	(p) = (page);							\
+	FSB_BUG_ON(___idx != first_page_idx(___idx, size));		\
+	for (___i = 0; ___i < ___nr; ___i++) {				\
+		(p) = find_page(page->mapping, ___idx + ___i);		\
+		FSB_BUG_ON(!(p));					\
+		{ struct { int i; } page; (void)page.i;			\
+
+#define end_for_each_page } } } while (0)
+
+static inline loff_t sector_offset(sector_t blocknr, unsigned int blkbits)
+{
+	return (loff_t)blocknr << blkbits;
+}
+
+static inline pgoff_t sector_pgoff(sector_t blocknr, unsigned int blkbits)
+{
+#ifdef BLOCK_SUPERPAGE_SUPPORT
+	if (blkbits > PAGE_CACHE_SHIFT)
+		return blocknr << (blkbits - PAGE_CACHE_SHIFT);
+#endif
+	return blocknr >> (PAGE_CACHE_SHIFT - blkbits);
+}
+
+static inline sector_t pgoff_sector(pgoff_t pgoff, unsigned int blkbits)
+{
+#ifdef BLOCK_SUPERPAGE_SUPPORT
+	if (blkbits > PAGE_CACHE_SHIFT)
+		return (sector_t)pgoff >> (blkbits - PAGE_CACHE_SHIFT);
+#endif
+	return (sector_t)pgoff << (PAGE_CACHE_SHIFT - blkbits);
+}
+
+static inline unsigned int block_page_offset(struct fsblock *block, unsigned int size)
+{
+	unsigned int idx;
+	unsigned int size_of = sizeof_block(block);
+	idx = (unsigned long)block - (unsigned long)page_blocks(block->page);
+	return size * (idx / size_of); /* XXX: could use bit shift */
+}
+
+int fsblock_set_page_dirty(struct page *page);
+
+int mblock_read_sync(struct fsblock_meta *mb);
+
+struct fsblock_meta *find_get_mblock(struct fsblock_sb *fsb_sb, sector_t blocknr, unsigned int size);
+
+struct fsblock_meta *find_or_create_mblock(struct fsblock_sb *fsb_sb, sector_t blocknr, unsigned int size);
+
+struct fsblock_meta *mbread(struct fsblock_sb *fsb_sb, sector_t blocknr, unsigned int size);
+
+
+int fsblock_register_super(struct super_block *sb, struct fsblock_sb *fsb_sb);
+void fsblock_unregister_super(struct super_block *sb, struct fsblock_sb *fsb_sb);
+int fsblock_register_super_light(struct super_block *sb);
+void fsblock_unregister_super_light(struct super_block *sb);
+
+static inline struct fsblock_meta *sb_find_get_mblock(struct fsblock_sb *fsb_sb, sector_t blocknr)
+{
+	return find_get_mblock(fsb_sb, blocknr, fsb_sb->blocksize);
+}
+
+static inline struct fsblock_meta *sb_find_or_create_mblock(struct fsblock_sb *fsb_sb, sector_t blocknr)
+{
+	return find_or_create_mblock(fsb_sb, blocknr, fsb_sb->blocksize);
+}
+
+static inline struct fsblock_meta *sb_mbread(struct fsblock_sb *fsb_sb, sector_t blocknr)
+{
+	return mbread(fsb_sb, blocknr, fsb_sb->blocksize);
+}
+
+void mbforget(struct fsblock_meta *mblock);
+
+int create_unmapped_blocks(struct page *page, gfp_t gfp_flags, unsigned int size, unsigned int flags);
+void mark_mblock_uptodate(struct fsblock_meta *mblock);
+int mark_mblock_dirty(struct fsblock_meta *mblock);
+int mark_mblock_dirty_inode(struct fsblock_meta *mblock, struct inode *inode);
+
+int sync_block(struct fsblock *block);
+
+/* XXX: are these always for metablocks? (no, directory in pagecache?) */
+void *vmap_mblock(struct fsblock_meta *mblock, off_t off, size_t len);
+void vunmap_mblock(struct fsblock_meta *mblock, off_t off, size_t len, void *vaddr);
+
+void block_get(struct fsblock *block);
+#define mblock_get(b) block_get(mblock_block(b))
+void block_put(struct fsblock *block);
+#define mblock_put(b) block_put(mblock_block(b))
+
+#ifndef FSB_DEBUG
+static inline int some_refcounted(struct fsblock *block)
+{
+	return 1;
+}
+#else
+int some_refcounted(struct fsblock *block);
+#endif
+
+static inline int spin_is_locked_block(struct fsblock *block)
+{
+//	FSB_BUG_ON(!some_refcounted(block)); XXX: hard to check for...
+	return bit_spin_is_locked(0, &block->page->private);
+}
+
+static inline int spin_trylock_block(struct fsblock *block)
+{
+	int ret;
+
+	FSB_BUG_ON(!some_refcounted(block));
+	ret = bit_spin_trylock(0, &block->page->private);
+	if (ret) {
+		assert_block(block);
+	}
+	return ret;
+}
+
+static inline int spin_trylock_block_irq(struct fsblock *block)
+{
+	int ret;
+
+	local_irq_disable();
+	ret = spin_trylock_block(block);
+	if (!ret)
+		local_irq_enable();
+
+	return ret;
+}
+
+#define spin_trylock_block_irqsave(block, flags)			\
+({									\
+	int ret;							\
+									\
+	local_irq_save(flags);						\
+	ret = spin_trylock_block(block);				\
+	if (!ret)							\
+		local_irq_restore(flags);				\
+									\
+	ret;								\
+})
+
+static inline void spin_lock_block(struct fsblock *block)
+{
+	int i;
+	for (i = 0; i < 100000; i++) {
+		if (bit_spin_trylock(0, &block->page->private))
+			goto locked;
+	}
+
+	printk("block not locked\n");
+	dump_stack();
+	bit_spin_lock(0, &block->page->private);
+locked:
+	assert_block(block);
+}
+
+static inline void spin_lock_block_irq(struct fsblock *block)
+{
+	local_irq_disable();
+	spin_lock_block(block);
+}
+
+#define spin_lock_block_irqsave(block, flags)				\
+do {									\
+	local_irq_save(flags);						\
+	spin_lock_block(block);						\
+} while (0)
+
+static inline void spin_unlock_block_nocheck(struct fsblock *block)
+{
+	__bit_spin_unlock(0, &block->page->private);
+}
+
+static inline void spin_unlock_block(struct fsblock *block)
+{
+//XXXYYYZZZXXX cancel dirty page in invalidatepage? 1K blocks with fsx and
+//drop_caches loop running
+#if 0
+Bug: !some_refcounted(block)
+------------[ cut here ]------------
+kernel BUG at include/linux/fsblock.h:468!
+invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
+last sysfs file: /sys/devices/system/cpu/cpu7/cache/index2/shared_cpu_map
+CPU 0
+Modules linked in: brd [last unloaded: brd]
+Pid: 3771, comm: fsx-linux Tainted: G        W  2.6.28-06859-gede6f5a-dirty #30
+RIP: 0010:[<ffffffff802e9db8>]  [<ffffffff802e9db8>] fsblock_invalidate_page+0x418/0x580
+RSP: 0018:ffff8800654f3c98  EFLAGS: 00010092
+RAX: 0000000000000020 RBX: ffff88007c8b5ef0 RCX: 0000000000000000
+RDX: ffff88006b1311b0 RSI: 0000000000000001 RDI: ffffffff805941c8
+RBP: ffff8800654f3cd8 R08: 0000000000000000 R09: 0000000000000000
+R10: ffffffff80855620 R11: ffff8800654f3bb8 R12: ffffe20002be4ef0
+R13: ffff88007c8b5ff0 R14: ffffe20002be4ee0 R15: 0000000000000001
+FS:  00007f9d5ff026e0(0000) GS:ffffffff80807040(0000) knlGS:0000000000000000
+CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
+CR2: 00007f9d5fe7f0d0 CR3: 000000011fc8c000 CR4: 00000000000006e0
+DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
+DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
+Process fsx-linux (pid: 3771, threadinfo ffff8800654f2000, task ffff88006b1311b0)
+Stack:
+ 0000000000000086 ffffe20002be4ee0 0000100000000400 0000000000000086
+ ffffe20002be4ee0 0000000000000086 0000000000000030 ffffffffffffffff
+ ffff8800654f3ce8 ffffffff80296fb2 ffff8800654f3dd8 ffffffff802973fa
+Call Trace:
+ [<ffffffff80296fb2>] do_invalidatepage+0x22/0x40
+ [<ffffffff802973fa>] truncate_inode_pages_range+0x3ba/0x3f0
+ [<ffffffff80297440>] truncate_inode_pages+0x10/0x20
+ [<ffffffff802a40ad>] vmtruncate+0xed/0x110
+ [<ffffffff802dbc40>] inode_setattr+0x30/0x180
+ [<ffffffff8034d41f>] ext2_setattr+0x2f/0x40
+ [<ffffffff802dbea9>] notify_change+0x119/0x2f0
+ [<ffffffff802c5015>] do_truncate+0x65/0x90
+ [<ffffffff802c5128>] sys_ftruncate+0xe8/0x130
+ [<ffffffff8020ba9b>] system_call_fastpath+0x16/0x1b
+Code: 48 8b 53 18 f6 42 10 01 0f 1f 00 75 04 0f 0b eb fe 48 8d 42 10 0f ba 72 10 00 e9 de fe ff ff 48 c7 c7 08 e4 66 80 e8 c5 6c 2a 00 <0f> 0b eb fe 0f 0b eb fe fae8 0a 04 f8 ff eb 0e 41 f6 04 24 01
+RIP  [<ffffffff802e9db8>] fsblock_invalidate_page+0x418/0x580
+ RSP <ffff8800654f3c98>
+#endif
+	FSB_BUG_ON(!some_refcounted(block));
+	assert_block(block);
+	spin_unlock_block_nocheck(block);
+}
+
+static inline void spin_unlock_block_irq(struct fsblock *block)
+{
+	spin_unlock_block(block);
+	local_irq_enable();
+}
+
+#define spin_unlock_block_irqrestore(block, flags)			\
+do {									\
+	spin_unlock_block(block);					\
+	local_irq_restore(flags);					\
+} while (0)
+
+int trylock_block(struct fsblock *block);
+void lock_block(struct fsblock *block);
+void unlock_block(struct fsblock *block);
+
+#ifdef BDFLUSH_FLUSHING
+void clear_block_dirty(struct fsblock *block);
+
+int test_and_set_block_dirty(struct fsblock *block);
+
+static inline void set_block_dirty(struct fsblock *block)
+{
+	test_and_set_block_dirty(block);
+}
+#else
+static inline void clear_block_dirty(struct fsblock *block)
+{
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	block->flags &= ~BL_dirty;
+}
+
+static inline int test_and_set_block_dirty(struct fsblock *block)
+{
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	if (block->flags & BL_dirty)
+		return 1;
+	block->flags |= BL_dirty;
+	return 0;
+}
+
+static inline void set_block_dirty(struct fsblock *block)
+{
+	FSB_BUG_ON(!spin_is_locked_block(block));
+	block->flags |= BL_dirty;
+}
+#endif
+void clear_block_dirty_check_page(struct fsblock *block, struct page *page, int io);
+
+static inline void map_fsblock(struct fsblock *block, sector_t blocknr)
+{
+	FSB_BUG_ON(!spin_is_locked_block(block)); /* XXX: xfs? */
+	FSB_BUG_ON(block->flags & BL_mapped);
+	block->block_nr = blocknr;
+	block->flags |= BL_mapped;
+	block->flags &= ~(BL_delay|BL_unwritten);
+#ifdef FSB_DEBUG
+	/* XXX: test for inside bdev? */
+	if (block->flags & BL_metadata) {
+		FSB_BUG_ON(block->block_nr << fsblock_bits(block) >> PAGE_CACHE_SHIFT != block->page->index);
+	}
+#endif
+}
+
+sector_t fsblock_bmap(struct address_space *mapping, sector_t block, map_block_fn *insert_mapping);
+
+int fsblock_read_page(struct page *page, map_block_fn *insert_mapping);
+int fsblock_write_page(struct page *page, map_block_fn *insert_mapping,
+				struct writeback_control *wbc);
+
+int fsblock_write_begin(struct file *file, struct address_space *mapping, loff_t pos, unsigned len, unsigned flags, struct page **pagep, void **fsdata, map_block_fn insert_mapping);
+int __fsblock_write_end(struct address_space *mapping, loff_t pos, unsigned len, unsigned copied, struct page *page, void *fsdata);
+int fsblock_write_end(struct file *file, struct address_space *mapping, loff_t pos, unsigned len, unsigned copied, struct page *page, void *fsdata);
+
+int fsblock_page_mkwrite(struct vm_area_struct *vma, struct page *page, map_block_fn *insert_mapping);
+int fsblock_truncate_page(struct address_space *mapping, loff_t from);
+void fsblock_invalidate_page(struct page *page, unsigned long offset);
+int fsblock_release(struct address_space *mapping, int force);
+int fsblock_sync(struct address_space *mapping);
+
+//int alloc_mapping_blocks(struct address_space *mapping, pgoff_t pgoff, gfp_t gfp_flags);
+int fsblock_releasepage(struct page *page, gfp_t gfp);
+
+int fsblock_file_mmap(struct file *file, struct vm_area_struct *vma);
+
+#ifdef BDFLUSH_FLUSHING
+void writeback_blockdevs_background(void);
+
+#ifdef FSB_DEBUG
+void fbd_discard_block(struct address_space *mapping, sector_t block_nr);
+#else
+static inline void fbd_discard_block(struct address_space *mapping, sector_t block_nr) {}
+#endif
+#else
+static inline void fbd_discard_block(struct address_space *mapping, sector_t block_nr)
+{
+}
+static inline void writeback_blockdevs_background(void)
+{
+}
+#endif
+
+void fsblock_init(void);
+void fsblock_end_io(struct fsblock *block, int uptodate);
+
+#endif
Index: linux-2.6/include/linux/fsblock_types.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/fsblock_types.h
@@ -0,0 +1,99 @@
+#ifndef __FSBLOCK_TYPES_H__
+#define __FSBLOCK_TYPES_H__
+
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/mm_types.h>
+#include <linux/rbtree.h>
+
+#define FSB_DEBUG	1
+
+#ifdef FSB_DEBUG
+# define FSB_BUG()	do { printk("Bug\n"); BUG(); } while (0)
+# define FSB_BUG_ON(x)	do { if (x) { printk("Bug: " #x "\n"); } BUG_ON(x); } while (0)
+# define FSB_WARN()	do { printk("Warn\n"); WARN_ON(1); } while (0)
+# define FSB_WARN_ON(x)	do { if (x) { printk("Warning: " #x "\n"); } WARN_ON(x); } while (0)
+#else
+# define FSB_BUG()	do { } while (0)
+# define FSB_BUG_ON(x)	do { } while (0)
+# define FSB_WARN()	do { } while (0)
+# define FSB_WARN_ON(x)	do { } while (0)
+#endif
+
+#define BLOCK_SUPERPAGE_SUPPORT	1
+#define BLOCK_MIDPAGE_SUPPORT	1
+#define BLOCK_SUBPAGE_SUPPORT	1
+
+#define FSB_EXTENTMAP		1
+#define EXT2_EXTMAP		1
+
+/*
+ * XXX: this is a hack for filesystems that vmap the entire block regularly,
+ * and won't even work for systems with limited vmalloc space.
+ * Should make fs'es vmap in page sized chunks instead (providing some
+ * helpers too). Currently racy when vunmapping at end_io interrupt.
+ */
+#define VMAP_CACHE	1
+
+//#define BDFLUSH_FLUSHING 1
+
+struct super_block;
+struct address_space;
+struct fsblock_bd;
+
+struct fsblock_sb {
+	struct address_space *mapping;
+	struct super_block *sb;
+	struct fsblock_bd *fbd;
+	unsigned int blocksize;
+	unsigned int blkbits;
+};
+
+/*
+ * inode == page->mapping->host
+ * bsize == inode->i_blkbits
+ * bdev  == inode->i_bdev
+ */
+struct fsblock {
+	unsigned int	flags;
+	unsigned int	count;
+
+#ifdef BDFLUSH_FLUSHING
+	struct rb_node	block_node;
+#endif
+	sector_t	block_nr;
+	void		*private;
+	struct page	*page;	/* Superpage block pages found via ->mapping */
+};
+
+struct vmap_cache_entry;
+struct fsblock_meta {
+	struct fsblock block;
+
+#ifdef FSB_DEBUG
+	unsigned int	vmap_count;
+#endif
+
+	union {
+#ifdef VMAP_CACHE
+		/* filesystems using vmap APIs should not use ->data */
+		struct vmap_cache_entry *vce;
+#endif
+
+		/*
+		 * data is a direct mapping to the block device data, used by
+		 * "intermediate" mode filesystems.
+		 * XXX: could provide a different allocation path for these
+		 * guys so converted filesystems don't have the overhead (and
+		 * can use highmem metadata buffercache
+		 */
+		char *data;
+	};
+};
+
+typedef int (map_block_fn)(struct address_space *mapping,
+				struct fsblock *fsblock, loff_t off,
+				int create);
+
+#endif
Index: linux-2.6/init/main.c
===================================================================
--- linux-2.6.orig/init/main.c
+++ linux-2.6/init/main.c
@@ -51,6 +51,7 @@
 #include <linux/mempolicy.h>
 #include <linux/key.h>
 #include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/page_cgroup.h>
 #include <linux/debug_locks.h>
 #include <linux/debugobjects.h>
@@ -661,6 +662,7 @@ asmlinkage void __init start_kernel(void
 	fork_init(num_physpages);
 	proc_caches_init();
 	buffer_init();
+	fsblock_init();
 	key_init();
 	security_init();
 	vfs_caches_init(num_physpages);
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -16,8 +16,8 @@
 #include <linux/highmem.h>
 #include <linux/pagevec.h>
 #include <linux/task_io_accounting_ops.h>
-#include <linux/buffer_head.h>	/* grr. try_to_release_page,
-				   do_invalidatepage */
+#include <linux/buffer_head.h>	/* block_invalidatepage */
+
 #include "internal.h"
 
 
@@ -38,20 +38,27 @@
 void do_invalidatepage(struct page *page, unsigned long offset)
 {
 	void (*invalidatepage)(struct page *, unsigned long);
+
+	if (!PagePrivate(page))
+		return;
+
 	invalidatepage = page->mapping->a_ops->invalidatepage;
 #ifdef CONFIG_BLOCK
 	if (!invalidatepage)
 		invalidatepage = block_invalidatepage;
 #endif
-	if (invalidatepage)
-		(*invalidatepage)(page, offset);
+	(*invalidatepage)(page, offset);
 }
 
 static inline void truncate_partial_page(struct page *page, unsigned partial)
 {
+	/*
+	 * XXX: this is only to get the already-invalidated tail and thus
+	 * it doesn't actually "dirty" the page. This probably should be
+	 * solved in the fs truncate_page operation.
+	 */
 	zero_user_segment(page, partial, PAGE_CACHE_SIZE);
-	if (PagePrivate(page))
-		do_invalidatepage(page, partial);
+	do_invalidatepage(page, partial);
 }
 
 /*
@@ -70,15 +77,18 @@ static inline void truncate_partial_page
  */
 void cancel_dirty_page(struct page *page, unsigned int account_size)
 {
-	if (TestClearPageDirty(page)) {
-		struct address_space *mapping = page->mapping;
-		if (mapping && mapping_cap_account_dirty(mapping)) {
-			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_bdi_stat(mapping->backing_dev_info,
-					BDI_RECLAIMABLE);
-			if (account_size)
-				task_io_account_cancelled_write(account_size);
-		}
+	struct address_space *mapping;
+
+	if (!PageDirty(page))
+		return;
+
+	ClearPageDirty(page);
+	mapping = page->mapping;
+	if (mapping && mapping_cap_account_dirty(mapping)) {
+		dec_zone_page_state(page, NR_FILE_DIRTY);
+		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		if (account_size)
+			task_io_account_cancelled_write(account_size);
 	}
 }
 EXPORT_SYMBOL(cancel_dirty_page);
@@ -99,15 +109,22 @@ truncate_complete_page(struct address_sp
 	if (page->mapping != mapping)
 		return;
 
-	if (PagePrivate(page))
-		do_invalidatepage(page, 0);
-
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
-	clear_page_mlock(page);
-	remove_from_page_cache(page);
-	ClearPageMappedToDisk(page);
-	page_cache_release(page);	/* pagecache ref */
+	do_invalidatepage(page, 0);
+
+	/*
+	 * XXX: this check is meant to avoid truncating some pages out of
+	 * superpage blocks, but could be racy if invalidate fails somehow.
+	 * should hook the do_invalidatepage return value or otherwise somehow
+	 * make it race free.
+	 */
+	/* if (!PageBlocks(page)) XXX: rework for big block handling */ {
+		clear_page_mlock(page);
+		remove_from_page_cache(page);
+		ClearPageMappedToDisk(page);
+		page_cache_release(page);	/* pagecache ref */
+	}
 }
 
 /*
@@ -182,27 +199,23 @@ void truncate_inode_pages_range(struct a
 			struct page *page = pvec.pages[i];
 			pgoff_t page_index = page->index;
 
-			if (page_index > end) {
-				next = page_index;
+			next = page_index+1;
+			if (next-1 > end)
 				break;
-			}
 
-			if (page_index > next)
-				next = page_index;
-			next++;
-			if (!trylock_page(page))
+			if (PageWriteback(page))
 				continue;
-			if (PageWriteback(page)) {
+			if (trylock_page(page)) {
+				if (!PageWriteback(page)) {
+					if (page_mapped(page)) {
+						unmap_mapping_range(mapping,
+						  (loff_t)page_index<<PAGE_CACHE_SHIFT,
+						  PAGE_CACHE_SIZE, 0);
+					}
+					truncate_complete_page(mapping, page);
+				}
 				unlock_page(page);
-				continue;
-			}
-			if (page_mapped(page)) {
-				unmap_mapping_range(mapping,
-				  (loff_t)page_index<<PAGE_CACHE_SHIFT,
-				  PAGE_CACHE_SIZE, 0);
 			}
-			truncate_complete_page(mapping, page);
-			unlock_page(page);
 		}
 		pagevec_release(&pvec);
 		cond_resched();
@@ -219,33 +232,23 @@ void truncate_inode_pages_range(struct a
 	}
 
 	next = start;
-	for ( ; ; ) {
-		cond_resched();
-		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
-			if (next == start)
-				break;
-			next = start;
-			continue;
-		}
-		if (pvec.pages[0]->index > end) {
-			pagevec_release(&pvec);
-			break;
-		}
+	while (next <= end &&
+	       pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			if (page->index > end)
-				break;
 			lock_page(page);
+			next = page->index + 1;
+			if (next-1 > end) {
+				unlock_page(page);
+				break;
+			}
 			wait_on_page_writeback(page);
 			if (page_mapped(page)) {
 				unmap_mapping_range(mapping,
 				  (loff_t)page->index<<PAGE_CACHE_SHIFT,
 				  PAGE_CACHE_SIZE, 0);
 			}
-			if (page->index > next)
-				next = page->index;
-			next++;
 			truncate_complete_page(mapping, page);
 			unlock_page(page);
 		}
Index: linux-2.6/fs/fs-writeback.c
===================================================================
--- linux-2.6.orig/fs/fs-writeback.c
+++ linux-2.6/fs/fs-writeback.c
@@ -38,7 +38,7 @@
  * unless they implement their own.  Which is somewhat inefficient, as this
  * may prevent concurrent writeback against multiple devices.
  */
-static int writeback_acquire(struct backing_dev_info *bdi)
+int writeback_acquire(struct backing_dev_info *bdi)
 {
 	return !test_and_set_bit(BDI_pdflush, &bdi->state);
 }
@@ -58,7 +58,7 @@ int writeback_in_progress(struct backing
  * writeback_release - relinquish exclusive writeback access against a device.
  * @bdi: the device's backing_dev_info structure
  */
-static void writeback_release(struct backing_dev_info *bdi)
+void writeback_release(struct backing_dev_info *bdi)
 {
 	BUG_ON(!writeback_in_progress(bdi));
 	clear_bit(BDI_pdflush, &bdi->state);
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -20,6 +20,7 @@
 #include <linux/slab.h>
 #include <linux/pagemap.h>
 #include <linux/writeback.h>
+#include <linux/fsblock.h>
 #include <linux/init.h>
 #include <linux/backing-dev.h>
 #include <linux/task_io_accounting_ops.h>
@@ -543,6 +544,7 @@ static void balance_dirty_pages(struct a
 		 */
 		if (bdi_nr_reclaimable) {
 			writeback_inodes(&wbc);
+			writeback_blockdevs_background();
 			pages_written += write_chunk - wbc.nr_to_write;
 			get_dirty_limits(&background_thresh, &dirty_thresh,
 				       &bdi_thresh, bdi);
@@ -592,8 +594,10 @@ static void balance_dirty_pages(struct a
 	if ((laptop_mode && pages_written) ||
 			(!laptop_mode && (global_page_state(NR_FILE_DIRTY)
 					  + global_page_state(NR_UNSTABLE_NFS)
-					  > background_thresh)))
+					  > background_thresh))) {
 		pdflush_operation(background_writeout, 0);
+		writeback_blockdevs_background();
+	}
 }
 
 void set_page_dirty_balance(struct page *page, int page_mkwrite)
@@ -1190,9 +1194,7 @@ EXPORT_SYMBOL(write_one_page);
  */
 int __set_page_dirty_no_writeback(struct page *page)
 {
-	if (!PageDirty(page))
-		SetPageDirty(page);
-	return 0;
+	return !TestSetPageDirty(page);
 }
 
 /*
@@ -1317,6 +1319,7 @@ void clean_page_prepare(struct page *pag
 			set_page_dirty(page);
 	}
 }
+EXPORT_SYMBOL(clean_page_prepare);
 
 void clear_page_dirty(struct page *page)
 {
@@ -1332,6 +1335,7 @@ void clear_page_dirty(struct page *page)
 		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
 	}
 }
+EXPORT_SYMBOL(clear_page_dirty);
 
 /*
  * Clear a page's dirty flag, while caring for dirty memory accounting.
@@ -1352,6 +1356,7 @@ int clear_page_dirty_for_io(struct page
 	struct address_space *mapping = page_mapping(page);
 
 	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageDirty(page));
 
 	ClearPageReclaim(page);
 	if (mapping && mapping_cap_account_dirty(mapping)) {
@@ -1392,15 +1397,13 @@ int clear_page_dirty_for_io(struct page
 		 * the desired exclusion. See mm/memory.c:do_wp_page()
 		 * for more comments.
 		 */
-		if (TestClearPageDirty(page)) {
-			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_bdi_stat(mapping->backing_dev_info,
-					BDI_RECLAIMABLE);
-			return 1;
-		}
-		return 0;
-	}
-	return TestClearPageDirty(page);
+		ClearPageDirty(page);
+		dec_zone_page_state(page, NR_FILE_DIRTY);
+		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+	} else
+		ClearPageDirty(page);
+
+	return 1;
 }
 EXPORT_SYMBOL(clear_page_dirty_for_io);
 
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c
+++ linux-2.6/kernel/sysctl.c
@@ -71,6 +71,7 @@ extern int sysctl_panic_on_oom;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_oom_dump_tasks;
 extern int max_threads;
+extern int fsblock_noblock;
 extern int core_uses_pid;
 extern int suid_dumpable;
 extern char core_pattern[];
@@ -1260,6 +1261,14 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "fsblock_no_cache",
+		.data		= &fsblock_noblock,
+		.maxlen		= sizeof(fsblock_noblock),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
Index: linux-2.6/include/linux/fsb_extentmap.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/fsb_extentmap.h
@@ -0,0 +1,46 @@
+#ifndef __FSB_EXTENTMAP_H__
+#define __FSB_EXTENTMAP_H__
+
+#include <linux/fs.h>
+#include <linux/rbtree.h>
+#include <linux/spinlock.h>
+#include <linux/types.h>
+#include <linux/fsblock.h>
+
+struct fsb_ext_root {
+	/* XXX: perhaps a list to make linear traversals cheaper? */
+	spinlock_t		lock;
+	struct rb_root		tree;
+	unsigned long		nr_extents;
+	unsigned long		nr_sectors;
+};
+
+#define FE_mapped	0x1
+#define FE_hole		0x2
+#define FE_new		0x4
+
+struct fsb_extent {
+	struct rb_node		rb_node;
+	sector_t		offset;
+	sector_t		block;
+	unsigned int		size;
+	unsigned int		flags;
+};
+
+void __init fsb_extent_init(void);
+
+static inline void fsb_ext_root_init(struct fsb_ext_root *root)
+{
+	spin_lock_init(&root->lock);
+	root->tree = RB_ROOT;
+}
+
+typedef int (*map_fsb_extent_fn)(struct address_space *mapping, loff_t off, int create, sector_t *offset, sector_t *block, unsigned int *size, unsigned int *flags);
+
+int fsb_ext_map_fsblock(struct address_space *mapping, loff_t off,
+			struct fsblock *fsblock, int create,
+			struct fsb_ext_root *root, map_fsb_extent_fn mapfn);
+int fsb_ext_unmap_fsblock(struct address_space *mapping, loff_t start, loff_t end, struct fsb_ext_root *root);
+int fsb_ext_release(struct address_space *mapping, struct fsb_ext_root *root);
+
+#endif
Index: linux-2.6/fs/fsb_extentmap.c
===================================================================
--- /dev/null
+++ linux-2.6/fs/fsb_extentmap.c
@@ -0,0 +1,451 @@
+#include <linux/fsb_extentmap.h>
+#include <linux/fsblock.h>
+#include <linux/module.h>
+#include <linux/bitops.h>
+#include <linux/sched.h>
+
+static struct kmem_cache *extent_cache __read_mostly;
+
+void __init fsb_extent_init(void)
+{
+	extent_cache = kmem_cache_create("fsb-extent",
+			sizeof(struct fsb_extent), 0,
+			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD, NULL);
+}
+
+#ifdef FSB_DEBUG
+static void __rbtree_print(struct fsb_ext_root *root)
+{
+	struct rb_node *node;
+
+	for (node = rb_first(&root->tree); node; node = rb_next(node)) {
+		struct fsb_extent *ext;
+		ext = rb_entry(node, struct fsb_extent, rb_node);
+		printk("[%llx-%llx] ", (unsigned long long)ext->offset, (unsigned long long)ext->offset + ext->size);
+	}
+	printk("\n");
+}
+
+static void __rbtree_verify(struct fsb_ext_root *root)
+{
+	struct rb_node *node;
+	sector_t curr = 0;
+
+	for (node = rb_first(&root->tree); node; node = rb_next(node)) {
+		struct fsb_extent *ext;
+		ext = rb_entry(node, struct fsb_extent, rb_node);
+		BUG_ON(ext->offset < curr);
+		curr = ext->offset + ext->size;
+	}
+}
+#else
+static void __rbtree_verify(struct fsb_ext_root *root)
+{
+}
+#endif
+
+static void __rbtree_insert(struct fsb_ext_root *root, struct fsb_extent *ext)
+{
+	struct rb_node **p = &root->tree.rb_node;
+	struct rb_node *parent = NULL;
+
+	while (*p) {
+		struct fsb_extent *tmp;
+
+		parent = *p;
+		tmp = rb_entry(parent, struct fsb_extent, rb_node);
+
+		if (ext->offset < tmp->offset)
+			p = &(*p)->rb_left;
+		else if (ext->offset > tmp->offset)
+			p = &(*p)->rb_right;
+		else
+			FSB_BUG();
+	}
+
+	rb_link_node(&ext->rb_node, parent, p);
+	rb_insert_color(&ext->rb_node, &root->tree);
+
+	__rbtree_verify(root);
+}
+
+static void __rbtree_delete(struct fsb_ext_root *root, struct fsb_extent *ext)
+{
+	FSB_BUG_ON(RB_EMPTY_NODE(&ext->rb_node));
+	rb_erase(&ext->rb_node, &root->tree);
+	RB_CLEAR_NODE(&ext->rb_node);
+
+	__rbtree_verify(root);
+}
+
+static struct fsb_extent *__rbtree_find(struct fsb_ext_root *root, sector_t offset)
+{
+	struct rb_node *n = root->tree.rb_node;
+	struct fsb_extent *ext;
+
+	while (n) {
+		ext = rb_entry(n, struct fsb_extent, rb_node);
+
+		if (offset < ext->offset)
+			n = n->rb_left;
+		else if (offset >= ext->offset + ext->size)
+			n = n->rb_right;
+		else
+			return ext;
+	}
+
+	return NULL;
+}
+
+static int fsb_ext_can_merge(struct fsb_extent *f, struct fsb_extent *s)
+{
+	unsigned int difference;
+
+	FSB_BUG_ON(f->offset > s->offset);
+	FSB_BUG_ON(f->offset + f->size < s->offset);
+	FSB_BUG_ON(f->offset + f->size > s->offset + s->size);
+
+	if (f->flags != s->flags)
+		return 0;
+
+	if (f->flags & FE_hole)
+		return 1;
+
+	difference = s->offset - f->offset;
+	if (f->block + difference != s->block)
+		return 0;
+
+	return 1;
+}
+
+static int fsb_ext_merge_after(struct fsb_extent *f, struct fsb_extent *s)
+{
+	if (!fsb_ext_can_merge(f, s))
+		return 0;
+
+	f->size = s->offset + s->size - f->offset;
+
+	return 1;
+}
+
+#ifdef FSB_DEBUG
+static int __fsb_ext_map_fsblock(struct address_space *mapping, loff_t off,
+			struct fsblock *fsblock, int mode,
+			struct fsb_ext_root *root, map_fsb_extent_fn mapfn)
+#else
+int fsb_ext_map_fsblock(struct address_space *mapping, loff_t off,
+			struct fsblock *fsblock, int mode,
+			struct fsb_ext_root *root, map_fsb_extent_fn mapfn)
+#endif
+{
+	struct inode *inode = mapping->host;
+	struct fsb_extent *ext;
+	sector_t offset, blocknr;
+
+	offset = off >> inode->i_blkbits;
+
+	spin_lock(&root->lock);
+	ext = __rbtree_find(root, offset);
+	if (!ext)
+		goto get_new;
+
+	if ((ext->flags & FE_mapped) || ((ext->flags & FE_hole) &&
+						(mode == MAP_BLOCK_READ))) {
+		spin_lock_block_irq(fsblock);
+		if (ext->flags & FE_mapped) {
+			blocknr = ext->block + (offset - ext->offset);
+			map_fsblock(fsblock, blocknr);
+			fsblock->flags &= ~BL_hole;
+		} else {
+			fsblock->flags |= BL_hole;
+		}
+		spin_unlock_block_irq(fsblock);
+	} else
+		goto get_new;
+	spin_unlock(&root->lock);
+
+	return 0;
+
+get_new:
+	spin_unlock(&root->lock);
+
+	{
+		struct rb_node *n;
+		struct fsb_extent *tmp, *new, *split;
+		int ret;
+		int newblock;
+
+		new = kmem_cache_alloc(extent_cache, GFP_NOFS);
+		if (!new)
+			return -ENOMEM;
+
+		split = kmem_cache_alloc(extent_cache, GFP_NOFS);
+		if (!split) {
+			kmem_cache_free(extent_cache, new);
+			return -ENOMEM;
+		}
+
+		ret = mapfn(mapping, off, mode, &new->offset, &new->block,
+						&new->size, &new->flags);
+		if (ret) {
+			kmem_cache_free(extent_cache, split);
+			kmem_cache_free(extent_cache, new);
+			return ret;
+		}
+
+		newblock = new->flags & FE_new;
+		new->flags &= ~FE_new;
+
+		if (new->flags & FE_mapped)
+			FSB_BUG_ON(new->flags & FE_hole);
+		if (new->flags & FE_hole)
+			FSB_BUG_ON(new->flags & FE_mapped);
+
+		spin_lock(&root->lock);
+		/* XXX: what if something has changed? */
+
+		n = root->tree.rb_node;
+		ext = NULL;
+		while (n) {
+			tmp = rb_entry(n, struct fsb_extent, rb_node);
+
+			if (tmp->offset + tmp->size >= new->offset) {
+				if (tmp->offset <= new->offset) {
+					ext = tmp;
+					break;
+				}
+				n = n->rb_left;
+			} else {
+				n = n->rb_right;
+			}
+		}
+
+try_next:
+		if (!ext) {
+			__rbtree_insert(root, new);
+
+		} else if (new->offset == ext->offset) {
+			if (ext->size <= new->size) {
+				ext->flags = new->flags;
+				ext->block = new->block;
+				ext->size = new->size;
+				__rbtree_verify(root);
+				kmem_cache_free(extent_cache, new);
+				new = ext;
+			} else {
+				ext->size -= new->size;
+				ext->offset += new->size;
+				ext->block += new->size;
+				__rbtree_verify(root);
+				__rbtree_insert(root, new);
+			}
+
+		} else {
+			if (ext->offset + ext->size > new->offset + new->size) {
+
+				*split = *ext;
+				ext->size = new->offset - ext->offset;
+				__rbtree_verify(root);
+
+				split->offset = new->offset + new->size;
+				split->size -= split->offset - ext->offset;
+				split->block += split->offset - ext->offset;
+				__rbtree_insert(root, split);
+				split = NULL;
+			}
+
+			if (fsb_ext_merge_after(ext, new)) {
+				kmem_cache_free(extent_cache, new);
+				new = ext;
+			} else {
+				if (ext->offset + ext->size == new->offset) {
+					n = rb_next(&ext->rb_node);
+					if (n) {
+						tmp = rb_entry(n, struct fsb_extent, rb_node);
+						if (tmp->offset == new->offset) {
+							ext->size = new->offset - ext->offset;
+							ext = tmp;
+							goto try_next;
+						}
+					}
+				}
+
+				ext->size = new->offset - ext->offset;
+				__rbtree_verify(root);
+				__rbtree_insert(root, new);
+			}
+		}
+
+		/* punch hole */
+		for (;;) {
+			struct fsb_extent *next;
+			n = rb_next(&new->rb_node);
+			if (!n)
+				break;
+			next = rb_entry(n, struct fsb_extent, rb_node);
+
+			FSB_BUG_ON(new->offset >= next->offset);
+
+			if (new->offset + new->size < next->offset)
+				break;
+
+			if (new->offset + new->size >= next->offset + next->size) {
+				__rbtree_delete(root, next);
+				kmem_cache_free(extent_cache, next);
+				continue;
+			}
+
+			if (fsb_ext_merge_after(new, next)) {
+				__rbtree_delete(root, next);
+				kmem_cache_free(extent_cache, next);
+				break;
+			}
+
+			next->size = (next->offset + next->size) - (new->offset + new->size);
+			next->offset = new->offset + new->size;
+
+			__rbtree_verify(root);
+			break;
+		}
+
+		spin_lock_block_irq(fsblock);
+		if (new->flags & FE_mapped) {
+			FSB_BUG_ON(offset < new->offset);
+			FSB_BUG_ON(offset >= new->offset + new->size);
+			blocknr = new->block + (offset - new->offset);
+			map_fsblock(fsblock, blocknr);
+			if (newblock)
+				fsblock->flags |= BL_new;
+			fsblock->flags &= ~BL_hole;
+		} else {
+			FSB_BUG_ON(!(new->flags & FE_hole));
+			FSB_BUG_ON(mode != MAP_BLOCK_READ);
+			fsblock->flags |= BL_hole;
+		}
+		spin_unlock_block_irq(fsblock);
+		spin_unlock(&root->lock);
+
+		if (split)
+			kmem_cache_free(extent_cache, split);
+
+		return 0;
+	}
+}
+
+#ifdef FSB_DEBUG
+/*
+ * Run both cached lookup and filesystem direct lookup. Compare the
+ * results and ensure they match. Just for debugging purposes.
+ */
+int fsb_ext_map_fsblock(struct address_space *mapping, loff_t off,
+			struct fsblock *fsblock, int mode,
+			struct fsb_ext_root *root, map_fsb_extent_fn mapfn)
+{
+	sector_t offset, block;
+	unsigned int size, flags;
+	int ret;
+
+	ret = __fsb_ext_map_fsblock(mapping, off, fsblock, mode, root, mapfn);
+	if (ret)
+		return ret;
+
+	ret = mapfn(mapping, off, mode, &offset, &block, &size, &flags);
+	if (ret)
+		return ret;
+
+	FSB_BUG_ON(size != 1);
+	FSB_BUG_ON(off >> mapping->host->i_blkbits != offset);
+	FSB_BUG_ON(((fsblock->flags >> 8) & 0x3) != (flags & 0x3));
+	FSB_BUG_ON(!(fsblock->flags & BL_hole) && fsblock->block_nr != block);
+
+	return ret;
+}
+#endif
+EXPORT_SYMBOL(fsb_ext_map_fsblock);
+
+int fsb_ext_unmap_fsblock(struct address_space *mapping, loff_t start, loff_t end, struct fsb_ext_root *root)
+{
+	struct rb_node *n;
+	struct fsb_extent *tmp, *split;
+	struct inode *inode = mapping->host;
+	struct fsb_extent *ext;
+	sector_t offset;
+	unsigned int size;
+
+	offset = start >> inode->i_blkbits;
+	size = (end >> inode->i_blkbits) - offset;
+
+	split = kmem_cache_alloc(extent_cache, GFP_NOFS);
+	if (!split)
+		return -ENOMEM;
+
+	spin_lock(&root->lock);
+	n = root->tree.rb_node;
+	ext = NULL;
+	while (n) {
+		tmp = rb_entry(n, struct fsb_extent, rb_node);
+
+		if (tmp->offset + tmp->size > offset) {
+			ext = tmp;
+			if (tmp->offset <= offset)
+				break;
+			n = n->rb_left;
+		} else {
+			n = n->rb_right;
+		}
+	}
+
+	while (ext) {
+		n = rb_next(&ext->rb_node);
+
+		if (ext->offset >= offset && ext->offset + ext->size <= offset + size) {
+			__rbtree_delete(root, ext);
+			kmem_cache_free(extent_cache, ext);
+			goto next;
+		}
+
+		if (ext->offset < offset && ext->offset + ext->size > offset + size) {
+			*split = *ext;
+			split->offset = offset + size;
+			split->size -= split->offset - ext->offset;
+			split->block += split->offset - ext->offset;
+			__rbtree_insert(root, split);
+			split = NULL;
+
+			ext->size = offset - ext->offset;
+			goto next;
+		}
+
+		if (ext->offset < offset) {
+			ext->size = offset - ext->offset;
+			goto next;
+
+		} else {
+			ext->size -= offset + size - ext->offset;
+			ext->block += offset + size - ext->offset;
+			ext->offset = offset + size;
+			goto next;
+		}
+
+		FSB_BUG();
+
+next:
+		if (!n)
+			break;
+		ext = rb_entry(n, struct fsb_extent, rb_node);
+	}
+
+	spin_unlock(&root->lock);
+
+	if (split)
+		kmem_cache_free(extent_cache, split);
+
+	return 0;
+}
+EXPORT_SYMBOL(fsb_ext_unmap_fsblock);
+
+int fsb_ext_release(struct address_space *mapping, struct fsb_ext_root *root)
+{
+	return fsb_ext_unmap_fsblock(mapping, 0, ~((loff_t)0), root);
+}
+EXPORT_SYMBOL(fsb_ext_release);
Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h
+++ linux-2.6/include/linux/backing-dev.h
@@ -26,6 +26,7 @@ enum bdi_state {
 	BDI_pdflush,		/* A pdflush thread is working this device */
 	BDI_write_congested,	/* The write queue is getting full */
 	BDI_read_congested,	/* The read queue is getting full */
+	BDI_block_writeout,	/* Block rather than inode based writeout */
 	BDI_unused,		/* Available bits start here */
 };
 
@@ -204,7 +205,9 @@ int bdi_set_max_ratio(struct backing_dev
 extern struct backing_dev_info default_backing_dev_info;
 void default_unplug_io_fn(struct backing_dev_info *bdi, struct page *page);
 
+int writeback_acquire(struct backing_dev_info *bdi);
 int writeback_in_progress(struct backing_dev_info *bdi);
+void writeback_release(struct backing_dev_info *bdi);
 
 static inline int bdi_congested(struct backing_dev_info *bdi, int bdi_bits)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
