Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CEA276B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 07:07:05 -0500 (EST)
Date: Wed, 14 Jan 2009 13:06:52 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] fsblock latest rollup
Message-ID: <20090114120652.GA27644@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Hi,

Here is my next iteration of fsblock. This has been sitting around for a while,
but I just spent a bit of time last week to convert it to a private linear
metadata inode, which worked out so well that I spent a bit more to write this
and submit it.

I don't expect it to be reviewed thoroughly at this point. I need to submit
broken up patches. Part of the problem is that I discover races or
insufficiencies in other code as I'm going. Have to spend time breaking those
bits out. Mainly just introducing the idea of merging this code at some
point.

Since last time (ages ago):

- Added support code for creating a private inode for metadata rather than
  using blockdev buffercache. This means fsblock no longer uses a page flag
  or really touches any other code at all (OK, I actually do add a page flag
  just for debugging, and I do touch generic code to add a couple of hooks
  and close some races in the VM, and move some things out of buffer.c where
  they don't belong).

- Added an "intermediate" mode, which adds a lowmem ->data pointer to fsblocks
  and makes filesystem conversions more trivial (although they don't support
  big blocks or highmem buffercache). Also, makes the structure significantly
  bigger.

- Found 8 more bytes to make sizeof(struct fsblock) == 32, so now less than 1/3
  the size of a bh. (intermediate mode makes metadata fsblocks 40 bytes).

- Closed all known races in fsblock refcounting, and synchronising of buffer and
  page state. This means no memory allocation on writeout path (provided the
  filesystem DTRT WRT delayed allocation and logging etc).

- Ported xfs over, although it's not included here because it was never 100%
  stable. But it required me to add necessary support code for delayed and
  unwritten allocation.

- Added an allocation extent cache helper library (fsb-extent) that can sit
  between fsblock and the filesystem. It caches the layout of block allocation
  in efficient extent based structures, which can be useful if the filesystem
  does not keep that information efficiently. Probably needs a shrinker callback.

- Ported ext2 to intermediate mode, and fsb-extent.

- There are one or two places that will go bug with smaller block size than
  page size, but that's because fsblock cares a lot more about consistency
  than does buffer.c.

- Higher order blocks haven't been tested for a while. They were never completely
  bug free, because there needs to be a little bit more work done to pagecache
  layer eg. in the pagecache->fs callbacks.

- Text is smaller than buffer.o when higher order block support compiled out:
     text    data     bss     dec     hex filename
  16929     224       0   17153    4301 fs/fsblock.o
  20740      96      28   20864    5180 fs/buffer.o

- fsblock is faster and more scalable than buffer_head. There is less locking.
  There is no private_lock (unless modifying associated metadata list), and no
  tree_lock in the lookup paths, and so no need for per-cpu lookup LRUs like
  buffer.c. Each memory access to an fsblock will cost 1 cacheline. For multi
  block pages, several blocks can be touched per cacheline. There tend to be
  fewer atomic operations for a given operation.

  dbench to ext2 on ramdisk (10 runs each)
  procs      tput (stddev) vanilla, fsblock
  1           392.40  (2.15),  392.40   (2.98)
  2           912.91  (7.10),  920.90   (6.27)
  4          1703.26 (17.83),  1706.25 (16.66)
  8          2854.87 (27.08),  2894.95 (20.46)

  OK, dbench isn't the best measurement, it isn't too heavy on the buffer
  layer and is not too stable... but every one of the averages was faster with
  fsblock. At least we can say it is comparable -- not obviously slower.

Given that this is obviously better in every way than buffer-heads, is now
unintrusive due to private metadata inode, and is now easy to convert over
filesystems due to the intermediate mode, I'm planning to submit fsblock
to be merged eventually after I have found enough time to get it into shape.
Probably will merge it with the super-block page code stripped out, and then
attempt to submit that at some stage. With the intermediate mode, it is now
feasible to convert all filesystems that now use buffer heads to fsblock.

This would not prevent subsequent addition of some type of extent state
library like Chris has, but fsblock is more of an evolutionary change
to buffer heads.

---
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -82,6 +82,7 @@ enum pageflags {
 	PG_arch_1,
 	PG_reserved,
 	PG_private,		/* If pagecache, has fs-private data */
+	PG_blocks,
 	PG_writeback,		/* Page is under writeback */
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
 	PG_head,		/* A head page */
@@ -183,7 +184,8 @@ struct page;	/* forward declaration */
 TESTPAGEFLAG(Locked, locked)
 PAGEFLAG(Error, error)
 PAGEFLAG(Referenced, referenced) TESTCLEARFLAG(Referenced, referenced)
-PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
+//TESTPAGEFLAG(Dirty, dirty) SETPAGEFLAG(Dirty, dirty) TESTSETFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
+TESTPAGEFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
 PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
 PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
 	TESTCLEARFLAG(Active, active)
@@ -194,6 +196,7 @@ PAGEFLAG(SavePinned, savepinned);			/* X
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(Private, private) __CLEARPAGEFLAG(Private, private)
 	__SETPAGEFLAG(Private, private)
+PAGEFLAG(Blocks, blocks)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
 __PAGEFLAG(SlobPage, slob_page)
@@ -256,6 +259,22 @@ PAGEFLAG(Uncached, uncached)
 PAGEFLAG_FALSE(Uncached)
 #endif
 
+#define ClearPageDirty(page)					\
+do {								\
+	VM_BUG_ON(!PageLocked(page));				\
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
@@ -381,7 +400,7 @@ static inline void __ClearPageTail(struc
 	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
 	 1 << PG_buddy | 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active | \
-	 __PG_UNEVICTABLE | __PG_MLOCKED)
+	 1 << PG_blocks | __PG_UNEVICTABLE | __PG_MLOCKED)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.
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
@@ -0,0 +1,3784 @@
+/*
+ * fs/fsblock.c
+ *
+ * Copyright (C) 2008 Nick Piggin, SuSE Labs, Novell Inc.
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
+//#include <linux/buffer_head.h> /* too much crap in me */
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
+static struct kmem_cache *block_cache[NR_SUB_SIZES] __read_mostly;
+static struct kmem_cache *mblock_cache[NR_SUB_SIZES] __read_mostly;
+
+void __init fsblock_init(void)
+{
+	unsigned int i;
+
+	for (i = MIN_SECTOR_SHIFT; i <= PAGE_CACHE_SHIFT; i++) {
+		int nr = 1UL << (PAGE_CACHE_SHIFT - i);
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
+		block_cache[i - MIN_SECTOR_SHIFT] = kmem_cache_create(name,
+			sizeof(struct fsblock)*nr, 0,
+			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_HWCACHE_ALIGN, NULL);
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
+		mblock_cache[i - MIN_SECTOR_SHIFT] = kmem_cache_create(name,
+			sizeof(struct fsblock_meta)*nr, 0,
+			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_HWCACHE_ALIGN, NULL);
+	}
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
+//	INIT_LIST_HEAD(&mblock->assoc_list);
+//	mblock->assoc_mapping = NULL;
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
+	int nr = PAGE_CACHE_SIZE >> bits;
+
+	block = kmem_cache_alloc_node(block_cache[bits - MIN_SECTOR_SHIFT],
+						gfp_flags, nid);
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
+	int nr = PAGE_CACHE_SIZE >> bits;
+
+	mblock = kmem_cache_alloc_node(mblock_cache[bits - MIN_SECTOR_SHIFT],
+						gfp_flags, nid);
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
+	if (block->flags & BL_metadata) {
+		kmem_cache_free(mblock_cache[bits - MIN_SECTOR_SHIFT], block);
+	} else {
+		kmem_cache_free(block_cache[bits - MIN_SECTOR_SHIFT], block);
+	}
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
+//	printk("__block_put block:%p count:%d\n", block, block->count);
+//	dump_stack();
+}
+static void __block_put(struct fsblock *block)
+{
+	FSB_BUG_ON(fsblock_midpage(block) && block->count <= 1);
+
+	___block_put(block);
+}
+
+#ifdef VMAP_CACHE
+#include <linux/hardirq.h>
+#endif
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
+	 * the pagecache is truncated as well).
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
+	unsigned int size;
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
+	if (!in_interrupt()) {
+		spin_lock(&vc_lock);
+		list_del(&vce->lru);
+		vc_size--;
+		spin_unlock(&vc_lock);
+		vm_unmap_ram(vce->vmap, vce->count);
+		kfree(vce);
+	}
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
+	spin_unlock(&vc_lock);
+
+	while (!list_empty(&list)) {
+		struct vmap_cache_entry *vce;
+		FSB_BUG_ON(nr == 0);
+		nr--;
+		vce = list_entry(list.next, struct vmap_cache_entry, lru);
+		list_del(&vce->lru);
+		vm_unmap_ram(vce->vmap, vce->count);
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
+		spin_lock(&vc_lock);
+		vc_misses++;
+		spin_lock_block_irq(block);
+		if (!(block->flags & BL_vmapped)) {
+			mblock->vce = vce;
+			vce->mblock = mblock;
+			vce->vmap = addr;
+			vce->count = nr;
+			vce->count = 1;
+			vce->touched = 0;
+			block->flags |= BL_vmapped;
+			spin_unlock_block_irq(block);
+			list_add(&vce->lru, &vc_lru);
+			vc_size++;
+			if (vc_size > VC_MAX_ENTRIES)
+				prune_vmap_cache();
+			else
+				spin_unlock(&vc_lock);
+		} else {
+			spin_unlock(&vc_lock);
+			mblock->vce->count++;
+			spin_unlock_block_irq(block);
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
+	/*
+	 * XXX: maybe use private alloc funcions so fses can embed block into
+	 * their fs-private block rather than using ->private? Maybe ->private
+	 * is easier though...
+	 */
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
+		WARN_ON(1);
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
+static void clear_block_dirty_check_page(struct fsblock *block, struct page *page, int io)
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
+#if 0
+/* XXX: have this callable by filesystems and not by default for new blocks */
+static void sync_underlying_metadata(struct fsblock *block)
+{
+	struct address_space *mapping = block->page->mapping;
+	struct block_device *bdev = mapping_data_bdev(mapping);
+	struct fsblock *meta_block;
+	sector_t blocknr = block->block_nr;
+
+	/* XXX: should this just invalidate rather than write back? */
+
+	FSB_BUG_ON(test_bit(BL_metadata, &block->flags));
+
+	meta_block = __find_get_block(bdev->XXXbd_inode->i_mapping, blocknr, 1);
+	if (meta_block) {
+		int err;
+
+		FSB_BUG_ON(!test_bit(BL_metadata, &meta_block->flags));
+		/*
+		 * Could actually do a memory copy here to bring
+		 * the block uptodate. Probably not worthwhile.
+		 */
+		FSB_BUG_ON(block == meta_block);
+		err = sync_block(meta_block);
+		if (!err)
+			FSB_BUG_ON(test_bit(BL_dirty, &meta_block->flags));
+	}
+}
+#endif
+
+void mbforget(struct fsblock_meta *mblock)
+{
+	struct fsblock *block = mblock_block(mblock);
+	struct page *page = block->page;
+	unsigned long flags;
+
+	iolock_block(block); /* hold page lock while clearing PG_dirty */
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
+
+		spin_unlock_block_irq(block);
+
+		/* This may happen if we cleared dirty on mmap blocks past eof */
+		if (nr == 0)
+			goto out_drop;
+
+		FSB_BUG_ON(PageWriteback(page));
+		set_page_writeback(page);
+		for_each_block(block, b) {
+			if (!(b->flags & BL_writeback))
+				continue;
+			spin_lock_block_irq(b);
+			ret = submit_block(b, WRITE);
+			if (ret)
+				goto out_drop;
+			/* XXX: error handling */
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
+			FSB_BUG_ON(PageWriteback(page));
+			set_page_writeback(page);
+			ret = submit_block(block, WRITE);
+			if (ret)
+				goto out_drop;
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
+		for_each_page(page, size, p) {
+			clear_page_dirty(p);
+			FSB_BUG_ON(PageWriteback(p));
+			FSB_BUG_ON(!PageUptodate(p));
+			set_page_writeback(p);
+		} end_for_each_page;
+
+		/* XXX: recheck ordering here! don't want to lose dirty bits */
+
+		clear_block_dirty(block);
+		ret = write_block(block);
+		if (ret)
+			goto out_drop;
+
+		for_each_page(page, size, p) {
+			unlock_page(p);
+		} end_for_each_page;
+	}
+	FSB_BUG_ON(ret);
+	block_put(block);
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
+	FSB_BUG_ON(!(block->flags & BL_mapped));
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
+	/* XXX: hack */
+	if (*pagep) {
+		FSB_BUG_ON(*pagep != find_page(mapping, index));
+		unlock_page(*pagep);
+	}
+
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
+	}
+
+	if (*pagep) /* hack */
+		page_cache_release(*pagep);
+	else
+		*pagep = find_page(mapping, index);
+
+	return 0;
+
+out_unlock:
+	if (*pagep) {
+		unlock_page_range(page, size);
+		*pagep = NULL;
+	}
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
+	FSB_BUG_ON(!(block->flags & BL_mapped));
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
+			FSB_BUG_ON(!(b->flags & BL_mapped));
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
+		FSB_BUG_ON(!(block->flags & BL_mapped));
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
+	mapping = page->mapping;
+	FSB_BUG_ON(!mapping);
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
+		FSB_BUG_ON(!(page_blocks(page)->flags & BL_mapped));
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
+#if 0
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
+#if 0
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
+#if 0 // XXX
+	if (offset == 0) {
+		if (!__try_to_free_blocks(page, block)) {
+			msleep(1);
+			block = page_get_block(page);
+			if (block) {
+				printk("block=%p could not be freed\n", block);
+				printk("block->count=%d flags=%x private=%p\n", block->count, block->flags, block->private);
+				FSB_WARN();
+				spin_unlock_block_irq(block);
+			}
+		}
+		local_irq_enable();
+	} else {
+exit:
+		spin_unlock_block_irq(block);
+	}
+#endif
+
+	if (!__try_to_free_blocks(page, block)) {
+		if (offset == 0) {
+			msleep(1);
+			block = page_get_block(page);
+			if (block) {
+				printk("block=%p could not be freed\n", block);
+				printk("block->count=%d flags=%x private=%p\n", block->count, block->flags, block->private);
+				FSB_WARN();
+				spin_unlock_block(block);
+			}
+		}
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
+	struct block_device *bdev = arg;
+	struct fsblock_bd *fbd;
+	struct backing_dev_info *bdi;
+
+	fbd = (struct fsblock_bd *)bdev->bd_private;
+	bdi = bdev->bd_inode_backing_dev_info;
+	if (!bdi)
+		bdi = bdev->XXXbd_inode->i_mapping->backing_dev_info;
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
+static int fsblock_register_bdev(struct block_device *bdev)
+{
+	struct fsblock_bd *fbd;
+
+	if (bdev->bd_private) {
+		printk("could not register fsblock bdev. something already at private\n");
+		return -EEXIST;
+	}
+
+	fbd = kmalloc(sizeof(struct fsblock_bd), GFP_KERNEL);
+	if (!fbd)
+		return -ENOMEM;
+	spin_lock_init(&fbd->lock);
+	fbd->dirty_root = RB_ROOT;
+	fbd->nr_dirty = 0;
+	fbd->bdflush = kthread_create(bdflush, bdev, "bdflush");
+	if (IS_ERR(fbd->bdflush)) {
+		int err = PTR_ERR(fbd->bdflush);
+		kfree(fbd);
+		return err;
+	}
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
+static void fsblock_unregister_bdev(struct block_device *bdev)
+{
+	struct fsblock_bd *fbd;
+
+	fbd = (struct fsblock_bd *)bdev->bd_private;
+	kthread_stop(fbd->bdflush);
+	bdev->bd_private = 0UL;
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
+	if (!fbd) {
+		FSB_WARN();
+		return;
+	}
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
+	if (!fbd) {
+		FSB_WARN();
+		block->flags &= ~BL_dirty;
+	} else
+		fbd_del_dirty_block(fbd, block);
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
+	if (!fbd) {
+		FSB_WARN();
+		block->flags |= BL_dirty;
+	} else
+		fbd_add_dirty_block(fbd, block);
+
+	return 0;
+}
+
+#else /* BDFLUSH_FLUSHING */
+
+static int fsblock_register_bdev(struct block_device *bdev)
+{
+	return 0;
+}
+
+static void fsblock_unregister_bdev(struct block_device *bdev)
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
+	ret = fsblock_register_bdev(bdev);
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
+
+void fsblock_unregister_super(struct super_block *sb, struct fsblock_sb *fsb_sb)
+{
+	struct block_device	*bdev = sb->s_bdev;
+
+	filemap_write_and_wait(fsb_sb->mapping);
+	iput(fsb_sb->mapping->host);
+
+	fsblock_unregister_bdev(bdev);
+}
Index: linux-2.6/include/linux/fsblock.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/fsblock.h
@@ -0,0 +1,597 @@
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
+ * the blkdev page_tree (with the host inode still at page->mapping). This
+ * could allow coherent blkdev/pagecache and also sweet block device based
+ * page writeout.
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
+	FSB_BUG_ON(!bit_spin_is_locked(0, &page->private));
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
+	bit_spin_lock(0, &block->page->private);
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
+
+static inline void map_fsblock(struct fsblock *block, sector_t blocknr)
+{
+	FSB_BUG_ON(!spin_is_locked_block(block)); /* XXX: xfs? */
+	FSB_BUG_ON(block->flags & BL_mapped); /* XXX: XFS? */
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
@@ -0,0 +1,88 @@
+#ifndef __FSBLOCK_TYPES_H__
+#define __FSBLOCK_TYPES_H__
+
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/mm_types.h>
+#include <linux/rbtree.h>
+
+//#define FSB_DEBUG	1
+
+#ifdef FSB_DEBUG
+# define FSB_BUG()	BUG()
+# define FSB_BUG_ON(x)	do { if (x) { printk("Warning: " #x "\n"); } BUG_ON(x); } while (0)
+# define FSB_WARN()	WARN_ON(1)
+# define FSB_WARN_ON(x)	do { if (x) { printk("Warning: " #x "\n"); } WARN_ON(x); } while (0)
+#else
+# define FSB_BUG()	do { } while (0)
+# define FSB_BUG_ON(x)	do { } while (0)
+# define FSB_WARN()	do { } while (0)
+# define FSB_WARN_ON(x)	do { } while (0)
+#endif
+
+//#define BLOCK_SUPERPAGE_SUPPORT	1
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
+//#define VMAP_CACHE	1
+
+//#define BDFLUSH_FLUSHING 1 XXX: broken for the minute
+
+struct super_block;
+struct address_space;
+struct fsblock_sb {
+	struct address_space *mapping;
+	struct super_block *sb;
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
+#ifdef VMAP_CACHE
+	struct vmap_cache_entry *vce;
+#endif
+
+	/* XXX: could just get rid of fsblock_meta? */
+
+	char *data;	/* XXX: use until callers are converted to accessors */
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
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -34,6 +34,7 @@
 #include <linux/hash.h>
 #include <linux/suspend.h>
 #include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/task_io_accounting_ops.h>
 #include <linux/bio.h>
 #include <linux/notifier.h>
@@ -166,151 +167,6 @@ void end_buffer_write_sync(struct buffer
 }
 
 /*
- * Write out and wait upon all the dirty data associated with a block
- * device via its mapping.  Does not take the superblock lock.
- */
-int sync_blockdev(struct block_device *bdev)
-{
-	int ret = 0;
-
-	if (bdev)
-		ret = filemap_write_and_wait(bdev->bd_inode->i_mapping);
-	return ret;
-}
-EXPORT_SYMBOL(sync_blockdev);
-
-/*
- * Write out and wait upon all dirty data associated with this
- * device.   Filesystem data as well as the underlying block
- * device.  Takes the superblock lock.
- */
-int fsync_bdev(struct block_device *bdev)
-{
-	struct super_block *sb = get_super(bdev);
-	if (sb) {
-		int res = fsync_super(sb);
-		drop_super(sb);
-		return res;
-	}
-	return sync_blockdev(bdev);
-}
-
-/**
- * freeze_bdev  --  lock a filesystem and force it into a consistent state
- * @bdev:	blockdevice to lock
- *
- * This takes the block device bd_mount_sem to make sure no new mounts
- * happen on bdev until thaw_bdev() is called.
- * If a superblock is found on this device, we take the s_umount semaphore
- * on it to make sure nobody unmounts until the snapshot creation is done.
- * The reference counter (bd_fsfreeze_count) guarantees that only the last
- * unfreeze process can unfreeze the frozen filesystem actually when multiple
- * freeze requests arrive simultaneously. It counts up in freeze_bdev() and
- * count down in thaw_bdev(). When it becomes 0, thaw_bdev() will unfreeze
- * actually.
- */
-struct super_block *freeze_bdev(struct block_device *bdev)
-{
-	struct super_block *sb;
-	int error = 0;
-
-	mutex_lock(&bdev->bd_fsfreeze_mutex);
-	if (bdev->bd_fsfreeze_count > 0) {
-		bdev->bd_fsfreeze_count++;
-		sb = get_super(bdev);
-		mutex_unlock(&bdev->bd_fsfreeze_mutex);
-		return sb;
-	}
-	bdev->bd_fsfreeze_count++;
-
-	down(&bdev->bd_mount_sem);
-	sb = get_super(bdev);
-	if (sb && !(sb->s_flags & MS_RDONLY)) {
-		sb->s_frozen = SB_FREEZE_WRITE;
-		smp_wmb();
-
-		__fsync_super(sb);
-
-		sb->s_frozen = SB_FREEZE_TRANS;
-		smp_wmb();
-
-		sync_blockdev(sb->s_bdev);
-
-		if (sb->s_op->freeze_fs) {
-			error = sb->s_op->freeze_fs(sb);
-			if (error) {
-				printk(KERN_ERR
-					"VFS:Filesystem freeze failed\n");
-				sb->s_frozen = SB_UNFROZEN;
-				drop_super(sb);
-				up(&bdev->bd_mount_sem);
-				bdev->bd_fsfreeze_count--;
-				mutex_unlock(&bdev->bd_fsfreeze_mutex);
-				return ERR_PTR(error);
-			}
-		}
-	}
-
-	sync_blockdev(bdev);
-	mutex_unlock(&bdev->bd_fsfreeze_mutex);
-
-	return sb;	/* thaw_bdev releases s->s_umount and bd_mount_sem */
-}
-EXPORT_SYMBOL(freeze_bdev);
-
-/**
- * thaw_bdev  -- unlock filesystem
- * @bdev:	blockdevice to unlock
- * @sb:		associated superblock
- *
- * Unlocks the filesystem and marks it writeable again after freeze_bdev().
- */
-int thaw_bdev(struct block_device *bdev, struct super_block *sb)
-{
-	int error = 0;
-
-	mutex_lock(&bdev->bd_fsfreeze_mutex);
-	if (!bdev->bd_fsfreeze_count) {
-		mutex_unlock(&bdev->bd_fsfreeze_mutex);
-		return -EINVAL;
-	}
-
-	bdev->bd_fsfreeze_count--;
-	if (bdev->bd_fsfreeze_count > 0) {
-		if (sb)
-			drop_super(sb);
-		mutex_unlock(&bdev->bd_fsfreeze_mutex);
-		return 0;
-	}
-
-	if (sb) {
-		BUG_ON(sb->s_bdev != bdev);
-		if (!(sb->s_flags & MS_RDONLY)) {
-			if (sb->s_op->unfreeze_fs) {
-				error = sb->s_op->unfreeze_fs(sb);
-				if (error) {
-					printk(KERN_ERR
-						"VFS:Filesystem thaw failed\n");
-					sb->s_frozen = SB_FREEZE_TRANS;
-					bdev->bd_fsfreeze_count++;
-					mutex_unlock(&bdev->bd_fsfreeze_mutex);
-					return error;
-				}
-			}
-			sb->s_frozen = SB_UNFROZEN;
-			smp_wmb();
-			wake_up(&sb->s_wait_unfrozen);
-		}
-		drop_super(sb);
-	}
-
-	up(&bdev->bd_mount_sem);
-	mutex_unlock(&bdev->bd_fsfreeze_mutex);
-	return 0;
-}
-EXPORT_SYMBOL(thaw_bdev);
-
-/*
  * Various filesystems appear to want __find_get_block to be non-blocking.
  * But it's the page lock which protects the buffers.  To get around this,
  * we get exclusion from try_to_free_buffers with the blockdev mapping's
@@ -599,7 +455,7 @@ EXPORT_SYMBOL(mark_buffer_async_write);
  * written back and waited upon before fsync() returns.
  *
  * The functions mark_buffer_inode_dirty(), fsync_inode_buffers(),
- * inode_has_buffers() and invalidate_inode_buffers() are provided for the
+ * mapping_has_private() and invalidate_inode_buffers() are provided for the
  * management of a list of dependent buffers at ->i_mapping->private_list.
  *
  * Locking is a little subtle: try_to_free_buffers() will remove buffers
@@ -652,11 +508,6 @@ static void __remove_assoc_queue(struct
 	bh->b_assoc_map = NULL;
 }
 
-int inode_has_buffers(struct inode *inode)
-{
-	return !list_empty(&inode->i_data.private_list);
-}
-
 /*
  * osync is designed to support O_SYNC io.  It waits synchronously for
  * all already-submitted IO to complete, but does not queue any new
@@ -931,8 +782,9 @@ static int fsync_buffers_list(spinlock_t
  */
 void invalidate_inode_buffers(struct inode *inode)
 {
-	if (inode_has_buffers(inode)) {
-		struct address_space *mapping = &inode->i_data;
+	struct address_space *mapping = &inode->i_data;
+
+	if (mapping_has_private(mapping)) {
 		struct list_head *list = &mapping->private_list;
 		struct address_space *buffer_mapping = mapping->assoc_mapping;
 
@@ -952,10 +804,10 @@ EXPORT_SYMBOL(invalidate_inode_buffers);
  */
 int remove_inode_buffers(struct inode *inode)
 {
+	struct address_space *mapping = &inode->i_data;
 	int ret = 1;
 
-	if (inode_has_buffers(inode)) {
-		struct address_space *mapping = &inode->i_data;
+	if (mapping_has_private(mapping)) {
 		struct list_head *list = &mapping->private_list;
 		struct address_space *buffer_mapping = mapping->assoc_mapping;
 
@@ -1585,6 +1437,7 @@ void block_invalidatepage(struct page *p
 	BUG_ON(!PageLocked(page));
 	if (!page_has_buffers(page))
 		goto out;
+	FSB_BUG_ON(PageBlocks(page));
 
 	head = page_buffers(page);
 	bh = head;
@@ -1719,10 +1572,9 @@ static int __block_write_full_page(struc
 
 	last_block = (i_size_read(inode) - 1) >> inode->i_blkbits;
 
-	if (!page_has_buffers(page)) {
+	if (!page_has_buffers(page))
 		create_empty_buffers(page, blocksize,
 					(1 << BH_Dirty)|(1 << BH_Uptodate));
-	}
 
 	/*
 	 * Be very careful.  We have no exclusion from __set_page_dirty_buffers
@@ -2473,12 +2325,12 @@ block_page_mkwrite(struct vm_area_struct
 	loff_t size;
 	int ret = -EINVAL;
 
-	lock_page(page);
+	BUG_ON(page->mapping != inode->i_mapping);
+
 	size = i_size_read(inode);
-	if ((page->mapping != inode->i_mapping) ||
-	    (page_offset(page) > size)) {
+	if (page_offset(page) > size) {
 		/* page got truncated out from underneath us */
-		goto out_unlock;
+		goto out;
 	}
 
 	/* page is wholly or partially inside EOF */
@@ -2491,8 +2343,7 @@ block_page_mkwrite(struct vm_area_struct
 	if (!ret)
 		ret = block_commit_write(page, 0, end);
 
-out_unlock:
-	unlock_page(page);
+out:
 	return ret;
 }
 
@@ -2728,6 +2579,9 @@ int nobh_writepage(struct page *page, ge
 	unsigned offset;
 	int ret;
 
+	if (!clear_page_dirty_for_io(page))
+		return 0;
+
 	/* Is the page fully inside i_size? */
 	if (page->index < end_index)
 		goto out;
@@ -2927,6 +2781,9 @@ int block_write_full_page(struct page *p
 	const pgoff_t end_index = i_size >> PAGE_CACHE_SHIFT;
 	unsigned offset;
 
+	if (!clear_page_dirty_for_io(page))
+		return 0;
+
 	/* Is the page fully inside i_size? */
 	if (page->index < end_index)
 		return __block_write_full_page(inode, page, get_block, wbc);
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -26,6 +26,7 @@
 #include <linux/swap.h>
 #include <linux/writeback.h>
 #include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
 #include <linux/uio.h>
@@ -59,8 +60,10 @@ static int page_cache_pipe_buf_steal(str
 		 */
 		wait_on_page_writeback(page);
 
-		if (PagePrivate(page) && !try_to_release_page(page, GFP_KERNEL))
-			goto out_unlock;
+		if (PagePrivate(page)) {
+			if (!try_to_release_page(page, GFP_KERNEL))
+				goto out_unlock;
+		}
 
 		/*
 		 * If we succeeded in removing the mapping, set LRU flag
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h
+++ linux-2.6/include/linux/buffer_head.h
@@ -12,6 +12,7 @@
 #include <linux/linkage.h>
 #include <linux/pagemap.h>
 #include <linux/wait.h>
+#include <linux/fsblock_types.h>
 #include <asm/atomic.h>
 
 #ifdef CONFIG_BLOCK
@@ -136,6 +137,7 @@ BUFFER_FNS(Unwritten, unwritten)
 #define page_buffers(page)					\
 	({							\
 		BUG_ON(!PagePrivate(page));			\
+		FSB_BUG_ON(PageBlocks(page));			\
 		((struct buffer_head *)page_private(page));	\
 	})
 #define page_has_buffers(page)	PagePrivate(page)
@@ -158,22 +160,14 @@ void end_buffer_write_sync(struct buffer
 
 /* Things to do with buffers at mapping->private_list */
 void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode);
-int inode_has_buffers(struct inode *);
 void invalidate_inode_buffers(struct inode *);
 int remove_inode_buffers(struct inode *inode);
 int sync_mapping_buffers(struct address_space *mapping);
 void unmap_underlying_metadata(struct block_device *bdev, sector_t block);
 
 void mark_buffer_async_write(struct buffer_head *bh);
-void invalidate_bdev(struct block_device *);
-int sync_blockdev(struct block_device *bdev);
 void __wait_on_buffer(struct buffer_head *);
 wait_queue_head_t *bh_waitq_head(struct buffer_head *bh);
-int fsync_bdev(struct block_device *);
-struct super_block *freeze_bdev(struct block_device *);
-int thaw_bdev(struct block_device *, struct super_block *);
-int fsync_super(struct super_block *);
-int fsync_no_super(struct block_device *);
 struct buffer_head *__find_get_block(struct block_device *bdev, sector_t block,
 			unsigned size);
 struct buffer_head *__getblk(struct block_device *bdev, sector_t block,
@@ -340,7 +334,6 @@ extern int __set_page_dirty_buffers(stru
 static inline void buffer_init(void) {}
 static inline int try_to_free_buffers(struct page *page) { return 1; }
 static inline int sync_blockdev(struct block_device *bdev) { return 0; }
-static inline int inode_has_buffers(struct inode *inode) { return 0; }
 static inline void invalidate_inode_buffers(struct inode *inode) {}
 static inline int remove_inode_buffers(struct inode *inode) { return 1; }
 static inline int sync_mapping_buffers(struct address_space *mapping) { return 0; }
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -40,6 +40,7 @@
  * FIXME: remove all knowledge of the buffer layer from the core VM
  */
 #include <linux/buffer_head.h> /* for generic_osync_inode */
+#include <linux/fsblock.h>
 
 #include <asm/mman.h>
 
@@ -121,6 +122,7 @@ void __remove_from_page_cache(struct pag
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	BUG_ON(page_mapped(page));
+	BUG_ON(PageBlocks(page));
 	mem_cgroup_uncharge_cache_page(page);
 
 	/*
@@ -2469,6 +2471,7 @@ int try_to_release_page(struct page *pag
 	if (PageWriteback(page))
 		return 0;
 
+	BUG_ON(!PagePrivate(page));
 	if (mapping && mapping->a_ops->releasepage)
 		return mapping->a_ops->releasepage(page, gfp_mask);
 	return try_to_free_buffers(page);
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -16,8 +16,9 @@
 #include <linux/highmem.h>
 #include <linux/pagevec.h>
 #include <linux/task_io_accounting_ops.h>
-#include <linux/buffer_head.h>	/* grr. try_to_release_page,
-				   do_invalidatepage */
+#include <linux/buffer_head.h>	/* try_to_release_page, do_invalidatepage */
+#include <linux/fsblock.h>
+
 #include "internal.h"
 
 
@@ -38,20 +39,28 @@
 void do_invalidatepage(struct page *page, unsigned long offset)
 {
 	void (*invalidatepage)(struct page *, unsigned long);
+
+	if (!PagePrivate(page))
+		return;
+
 	invalidatepage = page->mapping->a_ops->invalidatepage;
-#ifdef CONFIG_BLOCK
-	if (!invalidatepage)
-		invalidatepage = block_invalidatepage;
-#endif
 	if (invalidatepage)
 		(*invalidatepage)(page, offset);
+#ifdef CONFIG_BLOCK
+	else if (PagePrivate(page))
+		block_invalidatepage(page, offset);
+#endif
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
@@ -70,15 +79,19 @@ static inline void truncate_partial_page
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
+	BUG_ON(!PageDirty(page));
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
@@ -99,15 +112,22 @@ truncate_complete_page(struct address_sp
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
@@ -126,8 +146,9 @@ invalidate_complete_page(struct address_
 	if (page->mapping != mapping)
 		return 0;
 
-	if (PagePrivate(page) && !try_to_release_page(page, 0))
-		return 0;
+	if (PagePrivate(page))
+		if (!try_to_release_page(page, 0))
+			return 0;
 
 	clear_page_mlock(page);
 	ret = remove_mapping(mapping, page);
@@ -182,27 +203,23 @@ void truncate_inode_pages_range(struct a
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
@@ -219,33 +236,23 @@ void truncate_inode_pages_range(struct a
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
@@ -348,8 +355,10 @@ invalidate_complete_page2(struct address
 	if (page->mapping != mapping)
 		return 0;
 
-	if (PagePrivate(page) && !try_to_release_page(page, GFP_KERNEL))
-		return 0;
+	if (PagePrivate(page)) {
+		if (!try_to_release_page(page, GFP_KERNEL))
+			return 0;
+	}
 
 	spin_lock_irq(&mapping->tree_lock);
 	if (PageDirty(page))
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -23,8 +23,8 @@
 #include <linux/file.h>
 #include <linux/writeback.h>
 #include <linux/blkdev.h>
-#include <linux/buffer_head.h>	/* for try_to_release_page(),
-					buffer_heads_over_limit */
+#include <linux/buffer_head.h> /* try_to_release_page, buffer_heads_over_limit*/
+#include <linux/fsblock.h>
 #include <linux/mm_inline.h>
 #include <linux/pagevec.h>
 #include <linux/backing-dev.h>
@@ -374,7 +374,7 @@ static pageout_t pageout(struct page *pa
 	if (!may_write_to_queue(mapping->backing_dev_info))
 		return PAGE_KEEP;
 
-	if (clear_page_dirty_for_io(page)) {
+	if (PageDirty(page)) {
 		int res;
 		struct writeback_control wbc = {
 			.sync_mode = WB_SYNC_NONE,
Index: linux-2.6/fs/fs-writeback.c
===================================================================
--- linux-2.6.orig/fs/fs-writeback.c
+++ linux-2.6/fs/fs-writeback.c
@@ -23,6 +23,7 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include "internal.h"
 
 
@@ -38,7 +39,7 @@
  * unless they implement their own.  Which is somewhat inefficient, as this
  * may prevent concurrent writeback against multiple devices.
  */
-static int writeback_acquire(struct backing_dev_info *bdi)
+int writeback_acquire(struct backing_dev_info *bdi)
 {
 	return !test_and_set_bit(BDI_pdflush, &bdi->state);
 }
@@ -58,7 +59,7 @@ int writeback_in_progress(struct backing
  * writeback_release - relinquish exclusive writeback access against a device.
  * @bdi: the device's backing_dev_info structure
  */
-static void writeback_release(struct backing_dev_info *bdi)
+void writeback_release(struct backing_dev_info *bdi)
 {
 	BUG_ON(!writeback_in_progress(bdi));
 	clear_bit(BDI_pdflush, &bdi->state);
@@ -782,9 +783,15 @@ int generic_osync_inode(struct inode *in
 	if (what & OSYNC_DATA)
 		err = filemap_fdatawrite(mapping);
 	if (what & (OSYNC_METADATA|OSYNC_DATA)) {
-		err2 = sync_mapping_buffers(mapping);
-		if (!err)
-			err = err2;
+		if (!mapping->a_ops->sync) {
+			err2 = sync_mapping_buffers(mapping);
+			if (!err)
+				err = err2;
+		} else {
+			err2 = mapping->a_ops->sync(mapping);
+			if (!err)
+				err = err2;
+		}
 	}
 	if (what & OSYNC_DATA) {
 		err2 = filemap_fdatawait(mapping);
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c
+++ linux-2.6/fs/inode.c
@@ -33,6 +33,7 @@
  * FIXME: remove all knowledge of the buffer layer from this file
  */
 #include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 
 /*
  * New inode.c implementation.
@@ -208,7 +209,8 @@ static struct inode *alloc_inode(struct
 
 void destroy_inode(struct inode *inode) 
 {
-	BUG_ON(inode_has_buffers(inode));
+	BUG_ON(mapping_has_private(&inode->i_data));
+	BUG_ON(inode->i_data.nrpages);
 	security_inode_free(inode);
 	if (inode->i_sb->s_op->destroy_inode)
 		inode->i_sb->s_op->destroy_inode(inode);
@@ -277,10 +279,14 @@ void __iget(struct inode * inode)
  */
 void clear_inode(struct inode *inode)
 {
+	struct address_space *mapping = &inode->i_data;
+
 	might_sleep();
-	invalidate_inode_buffers(inode);
+	if (!mapping->a_ops->release)
+		invalidate_inode_buffers(inode);
        
-	BUG_ON(inode->i_data.nrpages);
+	BUG_ON(mapping_has_private(mapping));
+	BUG_ON(mapping->nrpages);
 	BUG_ON(!(inode->i_state & I_FREEING));
 	BUG_ON(inode->i_state & I_CLEAR);
 	inode_sync_wait(inode);
@@ -343,6 +349,7 @@ static int invalidate_list(struct list_h
 	for (;;) {
 		struct list_head * tmp = next;
 		struct inode * inode;
+		struct address_space * mapping;
 
 		/*
 		 * We can reschedule here without worrying about the list's
@@ -356,7 +363,12 @@ static int invalidate_list(struct list_h
 		if (tmp == head)
 			break;
 		inode = list_entry(tmp, struct inode, i_sb_list);
-		invalidate_inode_buffers(inode);
+		mapping = &inode->i_data;
+		if (!mapping->a_ops->release)
+			invalidate_inode_buffers(inode);
+		else
+			mapping->a_ops->release(mapping, 1); /* XXX: should be done in fs? */
+		BUG_ON(mapping_has_private(mapping));
 		if (!atomic_read(&inode->i_count)) {
 			list_move(&inode->i_list, dispose);
 			inode->i_state |= I_FREEING;
@@ -399,13 +411,15 @@ EXPORT_SYMBOL(invalidate_inodes);
 
 static int can_unuse(struct inode *inode)
 {
+	struct address_space *mapping = &inode->i_data;
+
 	if (inode->i_state)
 		return 0;
-	if (inode_has_buffers(inode))
+	if (mapping_has_private(mapping))
 		return 0;
 	if (atomic_read(&inode->i_count))
 		return 0;
-	if (inode->i_data.nrpages)
+	if (mapping->nrpages)
 		return 0;
 	return 1;
 }
@@ -434,6 +448,7 @@ static void prune_icache(int nr_to_scan)
 	spin_lock(&inode_lock);
 	for (nr_scanned = 0; nr_scanned < nr_to_scan; nr_scanned++) {
 		struct inode *inode;
+		struct address_space *mapping;
 
 		if (list_empty(&inode_unused))
 			break;
@@ -444,10 +459,17 @@ static void prune_icache(int nr_to_scan)
 			list_move(&inode->i_list, &inode_unused);
 			continue;
 		}
-		if (inode_has_buffers(inode) || inode->i_data.nrpages) {
+		mapping = &inode->i_data;
+		if (mapping_has_private(mapping) || mapping->nrpages) {
+			int ret;
+
 			__iget(inode);
 			spin_unlock(&inode_lock);
-			if (remove_inode_buffers(inode))
+			if (mapping->a_ops->release)
+				ret = mapping->a_ops->release(mapping, 0);
+			else
+				ret = remove_inode_buffers(inode);
+			if (ret)
 				reap += invalidate_mapping_pages(&inode->i_data,
 								0, -1);
 			iput(inode);
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
@@ -1028,8 +1032,6 @@ continue_unlock:
 			}
 
 			BUG_ON(PageWriteback(page));
-			if (!clear_page_dirty_for_io(page))
-				goto continue_unlock;
 
 			ret = (*writepage)(page, wbc, data);
 			if (unlikely(ret)) {
@@ -1159,7 +1161,7 @@ int write_one_page(struct page *page, in
 	if (wait)
 		wait_on_page_writeback(page);
 
-	if (clear_page_dirty_for_io(page)) {
+	if (PageDirty(page)) {
 		page_cache_get(page);
 		ret = mapping->a_ops->writepage(page, &wbc);
 		if (ret == 0 && wait) {
@@ -1180,9 +1182,7 @@ EXPORT_SYMBOL(write_one_page);
  */
 int __set_page_dirty_no_writeback(struct page *page)
 {
-	if (!PageDirty(page))
-		SetPageDirty(page);
-	return 0;
+	return !TestSetPageDirty(page);
 }
 
 /*
@@ -1213,7 +1213,8 @@ int __set_page_dirty_nobuffers(struct pa
 		mapping2 = page_mapping(page);
 		if (mapping2) { /* Race with truncate? */
 			BUG_ON(mapping2 != mapping);
-			WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
+			WARN_ON_ONCE(!PagePrivate(page) && !PageBlocks(page) &&
+						 !PageUptodate(page));
 			if (mapping_cap_account_dirty(mapping)) {
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
 				__inc_bdi_stat(mapping->backing_dev_info,
@@ -1241,6 +1242,9 @@ EXPORT_SYMBOL(__set_page_dirty_nobuffers
  */
 int redirty_page_for_writepage(struct writeback_control *wbc, struct page *page)
 {
+	printk("redirty!\n");
+	dump_stack();
+	/* XXX: this is crap. the whole idea of clearing page dirty before writepage is a load of shit */
 	wbc->pages_skipped++;
 	return __set_page_dirty_nobuffers(page);
 }
@@ -1299,6 +1303,24 @@ int set_page_dirty_lock(struct page *pag
 }
 EXPORT_SYMBOL(set_page_dirty_lock);
 
+void clean_page_prepare(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageDirty(page));
+	page_mkclean(page);
+}
+
+void clear_page_dirty(struct page *page)
+{
+	struct address_space *mapping = page_mapping(page);
+	BUG_ON(!mapping);
+	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageDirty(page));
+	ClearPageDirty(page);
+	dec_zone_page_state(page, NR_FILE_DIRTY);
+	dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+}
+
 /*
  * Clear a page's dirty flag, while caring for dirty memory accounting.
  * Returns true if the page was previously dirty.
@@ -1318,6 +1340,7 @@ int clear_page_dirty_for_io(struct page
 	struct address_space *mapping = page_mapping(page);
 
 	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageDirty(page));
 
 	ClearPageReclaim(page);
 	if (mapping && mapping_cap_account_dirty(mapping)) {
@@ -1358,15 +1381,13 @@ int clear_page_dirty_for_io(struct page
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
@@ -1250,6 +1251,14 @@ static struct ctl_table vm_table[] = {
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
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -525,6 +525,20 @@ struct address_space_operations {
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
+
+	/*
+	 * release_mapping releases any private data on the mapping so that
+	 * it may be reclaimed. Returns 1 on success or 0 on failure. Second
+	 * parameter 'force' causes dirty data to be invalidated. (XXX: could
+	 * have other flags like sync/async, etc).
+	 */
+	int (*release)(struct address_space *, int);
+
+	/*
+	 * sync writes back and waits for any private data on the mapping,
+	 * as a data consistency operation.
+	 */
+	int (*sync)(struct address_space *);
 };
 
 /*
@@ -610,6 +624,14 @@ struct block_device {
 int mapping_tagged(struct address_space *mapping, int tag);
 
 /*
+ * Does this mapping have anything on its private list?
+ */
+static inline int mapping_has_private(struct address_space *mapping)
+{
+	return !list_empty(&mapping->private_list);
+}
+
+/*
  * Might pages of this file be mapped into userspace?
  */
 static inline int mapping_mapped(struct address_space *mapping)
@@ -1724,6 +1746,13 @@ extern void bd_set_size(struct block_dev
 extern void bd_forget(struct inode *inode);
 extern void bdput(struct block_device *);
 extern struct block_device *open_by_devnum(dev_t, fmode_t);
+extern void invalidate_bdev(struct block_device *);
+extern int sync_blockdev(struct block_device *bdev);
+extern struct super_block *freeze_bdev(struct block_device *);
+extern int thaw_bdev(struct block_device *bdev, struct super_block *sb);
+extern int fsync_bdev(struct block_device *);
+extern int fsync_super(struct super_block *);
+extern int fsync_no_super(struct block_device *);
 #else
 static inline void bd_forget(struct inode *inode) {}
 #endif
Index: linux-2.6/fs/block_dev.c
===================================================================
--- linux-2.6.orig/fs/block_dev.c
+++ linux-2.6/fs/block_dev.c
@@ -18,6 +18,7 @@
 #include <linux/module.h>
 #include <linux/blkpg.h>
 #include <linux/buffer_head.h>
+#include <linux/pagevec.h>
 #include <linux/writeback.h>
 #include <linux/mpage.h>
 #include <linux/mount.h>
@@ -64,14 +65,14 @@ static void kill_bdev(struct block_devic
 {
 	if (bdev->bd_inode->i_mapping->nrpages == 0)
 		return;
-	invalidate_bh_lrus();
+	invalidate_bh_lrus(); /* XXX: this can go when buffers goes */
 	truncate_inode_pages(bdev->bd_inode->i_mapping, 0);
 }	
 
 int set_blocksize(struct block_device *bdev, int size)
 {
 	/* Size must be a power of two, and between 512 and PAGE_SIZE */
-	if (size > PAGE_SIZE || size < 512 || !is_power_of_2(size))
+	if (size < 512 || !is_power_of_2(size))
 		return -EINVAL;
 
 	/* Size cannot be smaller than the size supported by the device */
@@ -95,7 +96,7 @@ int sb_set_blocksize(struct super_block
 	if (set_blocksize(sb->s_bdev, size))
 		return 0;
 	/* If we get here, we know size is power of two
-	 * and it's value is between 512 and PAGE_SIZE */
+	 * and it's value is >= 512 */
 	sb->s_blocksize = size;
 	sb->s_blocksize_bits = blksize_bits(size);
 	return sb->s_blocksize;
@@ -115,19 +116,12 @@ EXPORT_SYMBOL(sb_min_blocksize);
 
 static int
 blkdev_get_block(struct inode *inode, sector_t iblock,
-		struct buffer_head *bh, int create)
+                struct buffer_head *bh, int create)
 {
 	if (iblock >= max_block(I_BDEV(inode))) {
 		if (create)
 			return -EIO;
-
-		/*
-		 * for reads, we're just trying to fill a partial page.
-		 * return a hole, they will have to call get_block again
-		 * before they can fill it, and they will get -EIO at that
-		 * time
-		 */
-		return 0;
+                return 0;
 	}
 	bh->b_bdev = I_BDEV(inode);
 	bh->b_blocknr = iblock;
@@ -174,6 +168,151 @@ blkdev_direct_IO(int rw, struct kiocb *i
 				iov, offset, nr_segs, blkdev_get_blocks, NULL);
 }
 
+/*
+ * Write out and wait upon all the dirty data associated with a block
+ * device via its mapping.  Does not take the superblock lock.
+ */
+int sync_blockdev(struct block_device *bdev)
+{
+	int ret = 0;
+
+	if (bdev)
+		ret = filemap_write_and_wait(bdev->bd_inode->i_mapping);
+	return ret;
+}
+EXPORT_SYMBOL(sync_blockdev);
+
+/*
+ * Write out and wait upon all dirty data associated with this
+ * device.   Filesystem data as well as the underlying block
+ * device.  Takes the superblock lock.
+ */
+int fsync_bdev(struct block_device *bdev)
+{
+	struct super_block *sb = get_super(bdev);
+	if (sb) {
+		int res = fsync_super(sb);
+		drop_super(sb);
+		return res;
+	}
+	return sync_blockdev(bdev);
+}
+
+/**
+ * freeze_bdev  --  lock a filesystem and force it into a consistent state
+ * @bdev:	blockdevice to lock
+ *
+ * This takes the block device bd_mount_sem to make sure no new mounts
+ * happen on bdev until thaw_bdev() is called.
+ * If a superblock is found on this device, we take the s_umount semaphore
+ * on it to make sure nobody unmounts until the snapshot creation is done.
+ * The reference counter (bd_fsfreeze_count) guarantees that only the last
+ * unfreeze process can unfreeze the frozen filesystem actually when multiple
+ * freeze requests arrive simultaneously. It counts up in freeze_bdev() and
+ * count down in thaw_bdev(). When it becomes 0, thaw_bdev() will unfreeze
+ * actually.
+ */
+struct super_block *freeze_bdev(struct block_device *bdev)
+{
+	struct super_block *sb;
+	int error = 0;
+
+	mutex_lock(&bdev->bd_fsfreeze_mutex);
+	if (bdev->bd_fsfreeze_count > 0) {
+		bdev->bd_fsfreeze_count++;
+		sb = get_super(bdev);
+		mutex_unlock(&bdev->bd_fsfreeze_mutex);
+		return sb;
+	}
+	bdev->bd_fsfreeze_count++;
+
+	down(&bdev->bd_mount_sem);
+	sb = get_super(bdev);
+	if (sb && !(sb->s_flags & MS_RDONLY)) {
+		sb->s_frozen = SB_FREEZE_WRITE;
+		smp_wmb();
+
+		__fsync_super(sb);
+
+		sb->s_frozen = SB_FREEZE_TRANS;
+		smp_wmb();
+
+		sync_blockdev(sb->s_bdev);
+
+		if (sb->s_op->freeze_fs) {
+			error = sb->s_op->freeze_fs(sb);
+			if (error) {
+				printk(KERN_ERR
+					"VFS:Filesystem freeze failed\n");
+				sb->s_frozen = SB_UNFROZEN;
+				drop_super(sb);
+				up(&bdev->bd_mount_sem);
+				bdev->bd_fsfreeze_count--;
+				mutex_unlock(&bdev->bd_fsfreeze_mutex);
+				return ERR_PTR(error);
+			}
+		}
+	}
+
+	sync_blockdev(bdev);
+	mutex_unlock(&bdev->bd_fsfreeze_mutex);
+
+	return sb;	/* thaw_bdev releases s->s_umount and bd_mount_sem */
+}
+EXPORT_SYMBOL(freeze_bdev);
+
+/**
+ * thaw_bdev  -- unlock filesystem
+ * @bdev:	blockdevice to unlock
+ * @sb:		associated superblock
+ *
+ * Unlocks the filesystem and marks it writeable again after freeze_bdev().
+ */
+int thaw_bdev(struct block_device *bdev, struct super_block *sb)
+{
+	int error = 0;
+
+	mutex_lock(&bdev->bd_fsfreeze_mutex);
+	if (!bdev->bd_fsfreeze_count) {
+		mutex_unlock(&bdev->bd_fsfreeze_mutex);
+		return -EINVAL;
+	}
+
+	bdev->bd_fsfreeze_count--;
+	if (bdev->bd_fsfreeze_count > 0) {
+		if (sb)
+			drop_super(sb);
+		mutex_unlock(&bdev->bd_fsfreeze_mutex);
+		return 0;
+	}
+
+	if (sb) {
+		BUG_ON(sb->s_bdev != bdev);
+		if (!(sb->s_flags & MS_RDONLY)) {
+			if (sb->s_op->unfreeze_fs) {
+				error = sb->s_op->unfreeze_fs(sb);
+				if (error) {
+					printk(KERN_ERR
+						"VFS:Filesystem thaw failed\n");
+					sb->s_frozen = SB_FREEZE_TRANS;
+					bdev->bd_fsfreeze_count++;
+					mutex_unlock(&bdev->bd_fsfreeze_mutex);
+					return error;
+				}
+			}
+			sb->s_frozen = SB_UNFROZEN;
+			smp_wmb();
+			wake_up(&sb->s_wait_unfrozen);
+		}
+		drop_super(sb);
+	}
+
+	up(&bdev->bd_mount_sem);
+	mutex_unlock(&bdev->bd_fsfreeze_mutex);
+	return 0;
+}
+EXPORT_SYMBOL(thaw_bdev);
+
 static int blkdev_writepage(struct page *page, struct writeback_control *wbc)
 {
 	return block_write_full_page(page, blkdev_get_block, wbc);
@@ -188,9 +327,12 @@ static int blkdev_write_begin(struct fil
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata)
 {
+	int err;
+
 	*pagep = NULL;
-	return block_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
+	err = block_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
 				blkdev_get_block);
+	return err;
 }
 
 static int blkdev_write_end(struct file *file, struct address_space *mapping,
@@ -198,6 +340,7 @@ static int blkdev_write_end(struct file
 			struct page *page, void *fsdata)
 {
 	int ret;
+
 	ret = block_write_end(file, mapping, pos, len, copied, page, fsdata);
 
 	unlock_page(page);
@@ -206,6 +349,11 @@ static int blkdev_write_end(struct file
 	return ret;
 }
 
+static void blkdev_invalidate_page(struct page *page, unsigned long offset)
+{
+	block_invalidatepage(page, offset);
+}
+
 /*
  * private llseek:
  * for a block special file file->f_path.dentry->d_inode->i_size is zero
@@ -1177,6 +1325,10 @@ static int __blkdev_put(struct block_dev
 		bdev->bd_part_count--;
 
 	if (!--bdev->bd_openers) {
+		/*
+		 * XXX: This could go away when block dev and inode
+		 * mappings are in sync?
+		 */
 		sync_blockdev(bdev);
 		kill_bdev(bdev);
 	}
@@ -1259,6 +1411,8 @@ static const struct address_space_operat
 	.writepages	= generic_writepages,
 	.releasepage	= blkdev_releasepage,
 	.direct_IO	= blkdev_direct_IO,
+	.set_page_dirty	= __set_page_dirty_buffers,
+	.invalidatepage = blkdev_invalidate_page,
 };
 
 const struct file_operations def_blk_fops = {
Index: linux-2.6/fs/super.c
===================================================================
--- linux-2.6.orig/fs/super.c
+++ linux-2.6/fs/super.c
@@ -28,7 +28,7 @@
 #include <linux/blkdev.h>
 #include <linux/quotaops.h>
 #include <linux/namei.h>
-#include <linux/buffer_head.h>		/* for fsync_super() */
+#include <linux/fs.h>			/* for fsync_super() */
 #include <linux/mount.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
@@ -38,6 +38,7 @@
 #include <linux/kobject.h>
 #include <linux/mutex.h>
 #include <linux/file.h>
+#include <linux/buffer_head.h>		/* sync_blockdev */
 #include <linux/async.h>
 #include <asm/uaccess.h>
 #include "internal.h"
Index: linux-2.6/fs/ext2/balloc.c
===================================================================
--- linux-2.6.orig/fs/ext2/balloc.c
+++ linux-2.6/fs/ext2/balloc.c
@@ -14,7 +14,7 @@
 #include "ext2.h"
 #include <linux/quotaops.h>
 #include <linux/sched.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/capability.h>
 
 /*
@@ -37,7 +37,7 @@
 
 struct ext2_group_desc * ext2_get_group_desc(struct super_block * sb,
 					     unsigned int block_group,
-					     struct buffer_head ** bh)
+					     struct fsblock_meta ** mb)
 {
 	unsigned long group_desc;
 	unsigned long offset;
@@ -63,16 +63,16 @@ struct ext2_group_desc * ext2_get_group_
 		return NULL;
 	}
 
-	desc = (struct ext2_group_desc *) sbi->s_group_desc[group_desc]->b_data;
-	if (bh)
-		*bh = sbi->s_group_desc[group_desc];
+	desc = (struct ext2_group_desc *) sbi->s_group_desc[group_desc]->data;
+	if (mb)
+		*mb = sbi->s_group_desc[group_desc];
 	return desc + offset;
 }
 
 static int ext2_valid_block_bitmap(struct super_block *sb,
 					struct ext2_group_desc *desc,
 					unsigned int block_group,
-					struct buffer_head *bh)
+					struct fsblock_meta *mb)
 {
 	ext2_grpblk_t offset;
 	ext2_grpblk_t next_zero_bit;
@@ -84,21 +84,21 @@ static int ext2_valid_block_bitmap(struc
 	/* check whether block bitmap block number is set */
 	bitmap_blk = le32_to_cpu(desc->bg_block_bitmap);
 	offset = bitmap_blk - group_first_block;
-	if (!ext2_test_bit(offset, bh->b_data))
+	if (!ext2_test_bit(offset, mb->data))
 		/* bad block bitmap */
 		goto err_out;
 
 	/* check whether the inode bitmap block number is set */
 	bitmap_blk = le32_to_cpu(desc->bg_inode_bitmap);
 	offset = bitmap_blk - group_first_block;
-	if (!ext2_test_bit(offset, bh->b_data))
+	if (!ext2_test_bit(offset, mb->data))
 		/* bad block bitmap */
 		goto err_out;
 
 	/* check whether the inode table block number is set */
 	bitmap_blk = le32_to_cpu(desc->bg_inode_table);
 	offset = bitmap_blk - group_first_block;
-	next_zero_bit = ext2_find_next_zero_bit(bh->b_data,
+	next_zero_bit = ext2_find_next_zero_bit(mb->data,
 				offset + EXT2_SB(sb)->s_itb_per_group,
 				offset);
 	if (next_zero_bit >= offset + EXT2_SB(sb)->s_itb_per_group)
@@ -117,32 +117,38 @@ err_out:
  * Read the bitmap for a given block_group,and validate the
  * bits for block/inode/inode tables are set in the bitmaps
  *
- * Return buffer_head on success or NULL in case of failure.
+ * Return fsblock_meta on success or NULL in case of failure.
  */
-static struct buffer_head *
+static struct fsblock_meta *
 read_block_bitmap(struct super_block *sb, unsigned int block_group)
 {
 	struct ext2_group_desc * desc;
-	struct buffer_head * bh = NULL;
+	struct fsblock_meta * mb = NULL;
 	ext2_fsblk_t bitmap_blk;
 
 	desc = ext2_get_group_desc(sb, block_group, NULL);
 	if (!desc)
 		return NULL;
 	bitmap_blk = le32_to_cpu(desc->bg_block_bitmap);
-	bh = sb_getblk(sb, bitmap_blk);
-	if (unlikely(!bh)) {
+	mb = sb_find_or_create_mblock(&EXT2_SB(sb)->fsb_sb, bitmap_blk);
+	if (unlikely(!mb)) {
 		ext2_error(sb, __func__,
 			    "Cannot read block bitmap - "
 			    "block_group = %d, block_bitmap = %u",
 			    block_group, le32_to_cpu(desc->bg_block_bitmap));
 		return NULL;
 	}
-	if (likely(bh_uptodate_or_lock(bh)))
-		return bh;
+	if (likely(mb->block.flags & BL_uptodate))
+		return mb;
+	lock_block(mb); /* XXX: may not need to lock */
+	if (likely(mb->block.flags & BL_uptodate)) {
+		unlock_block(mb);
+		return mb;
+	}
 
-	if (bh_submit_read(bh) < 0) {
-		brelse(bh);
+	if (mblock_read_sync(mb) < 0) {
+		unlock_block(mb);
+		block_put(mb);
 		ext2_error(sb, __func__,
 			    "Cannot read block bitmap - "
 			    "block_group = %d, block_bitmap = %u",
@@ -150,12 +156,13 @@ read_block_bitmap(struct super_block *sb
 		return NULL;
 	}
 
-	ext2_valid_block_bitmap(sb, desc, block_group, bh);
+	unlock_block(mb);
+	ext2_valid_block_bitmap(sb, desc, block_group, mb);
 	/*
 	 * file system mounted not to panic on error, continue with corrupt
 	 * bitmap
 	 */
-	return bh;
+	return mb;
 }
 
 static void release_blocks(struct super_block *sb, int count)
@@ -169,7 +176,7 @@ static void release_blocks(struct super_
 }
 
 static void group_adjust_blocks(struct super_block *sb, int group_no,
-	struct ext2_group_desc *desc, struct buffer_head *bh, int count)
+	struct ext2_group_desc *desc, struct fsblock_meta *mb, int count)
 {
 	if (count) {
 		struct ext2_sb_info *sbi = EXT2_SB(sb);
@@ -180,7 +187,7 @@ static void group_adjust_blocks(struct s
 		desc->bg_free_blocks_count = cpu_to_le16(free_blocks + count);
 		spin_unlock(sb_bgl_lock(sbi, group_no));
 		sb->s_dirt = 1;
-		mark_buffer_dirty(bh);
+		mark_mblock_dirty(mb);
 	}
 }
 
@@ -486,8 +493,8 @@ void ext2_discard_reservation(struct ino
 void ext2_free_blocks (struct inode * inode, unsigned long block,
 		       unsigned long count)
 {
-	struct buffer_head *bitmap_bh = NULL;
-	struct buffer_head * bh2;
+	struct fsblock_meta *bitmap_mb = NULL;
+	struct fsblock_meta *mb;
 	unsigned long block_group;
 	unsigned long bit;
 	unsigned long i;
@@ -506,6 +513,8 @@ void ext2_free_blocks (struct inode * in
 			    "block = %lu, count = %lu", block, count);
 		goto error_return;
 	}
+	for (i = 0; i < count; i++)
+		fbd_discard_block(inode->i_mapping, block + i);
 
 	ext2_debug ("freeing block(s) %lu-%lu\n", block, block + count - 1);
 
@@ -523,12 +532,13 @@ do_more:
 		overflow = bit + count - EXT2_BLOCKS_PER_GROUP(sb);
 		count -= overflow;
 	}
-	brelse(bitmap_bh);
-	bitmap_bh = read_block_bitmap(sb, block_group);
-	if (!bitmap_bh)
+	if (bitmap_mb)
+		block_put(bitmap_mb);
+	bitmap_mb = read_block_bitmap(sb, block_group);
+	if (!bitmap_mb)
 		goto error_return;
 
-	desc = ext2_get_group_desc (sb, block_group, &bh2);
+	desc = ext2_get_group_desc (sb, block_group, &mb);
 	if (!desc)
 		goto error_return;
 
@@ -547,7 +557,7 @@ do_more:
 
 	for (i = 0, group_freed = 0; i < count; i++) {
 		if (!ext2_clear_bit_atomic(sb_bgl_lock(sbi, block_group),
-						bit + i, bitmap_bh->b_data)) {
+						bit + i, bitmap_mb->data)) {
 			ext2_error(sb, __func__,
 				"bit already cleared for block %lu", block + i);
 		} else {
@@ -555,11 +565,11 @@ do_more:
 		}
 	}
 
-	mark_buffer_dirty(bitmap_bh);
+	mark_mblock_dirty(bitmap_mb);
 	if (sb->s_flags & MS_SYNCHRONOUS)
-		sync_dirty_buffer(bitmap_bh);
+		sync_block(bitmap_mb);
 
-	group_adjust_blocks(sb, block_group, desc, bh2, group_freed);
+	group_adjust_blocks(sb, block_group, desc, mb, group_freed);
 	freed += group_freed;
 
 	if (overflow) {
@@ -568,7 +578,8 @@ do_more:
 		goto do_more;
 	}
 error_return:
-	brelse(bitmap_bh);
+	if (bitmap_mb)
+		block_put(bitmap_mb);
 	release_blocks(sb, freed);
 	DQUOT_FREE_BLOCK(inode, freed);
 }
@@ -576,19 +587,19 @@ error_return:
 /**
  * bitmap_search_next_usable_block()
  * @start:		the starting block (group relative) of the search
- * @bh:			bufferhead contains the block group bitmap
+ * @mb:			fsblock_meta contains the block group bitmap
  * @maxblocks:		the ending block (group relative) of the reservation
  *
  * The bitmap search --- search forward through the actual bitmap on disk until
  * we find a bit free.
  */
 static ext2_grpblk_t
-bitmap_search_next_usable_block(ext2_grpblk_t start, struct buffer_head *bh,
+bitmap_search_next_usable_block(ext2_grpblk_t start, struct fsblock_meta *mb,
 					ext2_grpblk_t maxblocks)
 {
 	ext2_grpblk_t next;
 
-	next = ext2_find_next_zero_bit(bh->b_data, maxblocks, start);
+	next = ext2_find_next_zero_bit(mb->data, maxblocks, start);
 	if (next >= maxblocks)
 		return -1;
 	return next;
@@ -598,7 +609,7 @@ bitmap_search_next_usable_block(ext2_grp
  * find_next_usable_block()
  * @start:		the starting block (group relative) to find next
  * 			allocatable block in bitmap.
- * @bh:			bufferhead contains the block group bitmap
+ * @mb:			fsblock_meta contains the block group bitmap
  * @maxblocks:		the ending block (group relative) for the search
  *
  * Find an allocatable block in a bitmap.  We perform the "most
@@ -607,7 +618,7 @@ bitmap_search_next_usable_block(ext2_grp
  * then for any free bit in the bitmap.
  */
 static ext2_grpblk_t
-find_next_usable_block(int start, struct buffer_head *bh, int maxblocks)
+find_next_usable_block(int start, struct fsblock_meta *mb, int maxblocks)
 {
 	ext2_grpblk_t here, next;
 	char *p, *r;
@@ -624,7 +635,7 @@ find_next_usable_block(int start, struct
 		ext2_grpblk_t end_goal = (start + 63) & ~63;
 		if (end_goal > maxblocks)
 			end_goal = maxblocks;
-		here = ext2_find_next_zero_bit(bh->b_data, end_goal, start);
+		here = ext2_find_next_zero_bit(mb->data, end_goal, start);
 		if (here < end_goal)
 			return here;
 		ext2_debug("Bit not found near goal\n");
@@ -634,14 +645,14 @@ find_next_usable_block(int start, struct
 	if (here < 0)
 		here = 0;
 
-	p = ((char *)bh->b_data) + (here >> 3);
+	p = ((char *)mb->data) + (here >> 3);
 	r = memscan(p, 0, ((maxblocks + 7) >> 3) - (here >> 3));
-	next = (r - ((char *)bh->b_data)) << 3;
+	next = (r - ((char *)mb->data)) << 3;
 
 	if (next < maxblocks && next >= here)
 		return next;
 
-	here = bitmap_search_next_usable_block(here, bh, maxblocks);
+	here = bitmap_search_next_usable_block(here, mb, maxblocks);
 	return here;
 }
 
@@ -650,7 +661,7 @@ find_next_usable_block(int start, struct
  * @sb:			superblock
  * @handle:		handle to this transaction
  * @group:		given allocation block group
- * @bitmap_bh:		bufferhead holds the block bitmap
+ * @bitmap_mb:		fsblock_meta holds the block bitmap
  * @grp_goal:		given target block within the group
  * @count:		target number of blocks to allocate
  * @my_rsv:		reservation window
@@ -670,7 +681,7 @@ find_next_usable_block(int start, struct
  */
 static int
 ext2_try_to_allocate(struct super_block *sb, int group,
-			struct buffer_head *bitmap_bh, ext2_grpblk_t grp_goal,
+			struct fsblock_meta *bitmap_mb, ext2_grpblk_t grp_goal,
 			unsigned long *count,
 			struct ext2_reserve_window *my_rsv)
 {
@@ -706,7 +717,7 @@ ext2_try_to_allocate(struct super_block
 
 repeat:
 	if (grp_goal < 0) {
-		grp_goal = find_next_usable_block(start, bitmap_bh, end);
+		grp_goal = find_next_usable_block(start, bitmap_mb, end);
 		if (grp_goal < 0)
 			goto fail_access;
 		if (!my_rsv) {
@@ -714,7 +725,7 @@ repeat:
 
 			for (i = 0; i < 7 && grp_goal > start &&
 					!ext2_test_bit(grp_goal - 1,
-					     		bitmap_bh->b_data);
+					     		bitmap_mb->data);
 			     		i++, grp_goal--)
 				;
 		}
@@ -722,7 +733,7 @@ repeat:
 	start = grp_goal;
 
 	if (ext2_set_bit_atomic(sb_bgl_lock(EXT2_SB(sb), group), grp_goal,
-			       				bitmap_bh->b_data)) {
+			       				bitmap_mb->data)) {
 		/*
 		 * The block was allocated by another thread, or it was
 		 * allocated and then freed by another thread
@@ -737,7 +748,7 @@ repeat:
 	grp_goal++;
 	while (num < *count && grp_goal < end
 		&& !ext2_set_bit_atomic(sb_bgl_lock(EXT2_SB(sb), group),
-					grp_goal, bitmap_bh->b_data)) {
+					grp_goal, bitmap_mb->data)) {
 		num++;
 		grp_goal++;
 	}
@@ -900,12 +911,12 @@ static int find_next_reservable_window(
  *
  *	@sb: the super block
  *	@group: the group we are trying to allocate in
- *	@bitmap_bh: the block group block bitmap
+ *	@bitmap_mb: the block group block bitmap
  *
  */
 static int alloc_new_reservation(struct ext2_reserve_window_node *my_rsv,
 		ext2_grpblk_t grp_goal, struct super_block *sb,
-		unsigned int group, struct buffer_head *bitmap_bh)
+		unsigned int group, struct fsblock_meta *bitmap_mb)
 {
 	struct ext2_reserve_window_node *search_head;
 	ext2_fsblk_t group_first_block, group_end_block, start_block;
@@ -996,7 +1007,7 @@ retry:
 	spin_unlock(rsv_lock);
 	first_free_block = bitmap_search_next_usable_block(
 			my_rsv->rsv_start - group_first_block,
-			bitmap_bh, group_end_block - group_first_block + 1);
+			bitmap_mb, group_end_block - group_first_block + 1);
 
 	if (first_free_block < 0) {
 		/*
@@ -1074,7 +1085,7 @@ static void try_to_extend_reservation(st
  * ext2_try_to_allocate_with_rsv()
  * @sb:			superblock
  * @group:		given allocation block group
- * @bitmap_bh:		bufferhead holds the block bitmap
+ * @bitmap_mb:		fsblock_meta holds the block bitmap
  * @grp_goal:		given target block within the group
  * @count:		target number of blocks to allocate
  * @my_rsv:		reservation window
@@ -1098,7 +1109,7 @@ static void try_to_extend_reservation(st
  */
 static ext2_grpblk_t
 ext2_try_to_allocate_with_rsv(struct super_block *sb, unsigned int group,
-			struct buffer_head *bitmap_bh, ext2_grpblk_t grp_goal,
+			struct fsblock_meta *bitmap_mb, ext2_grpblk_t grp_goal,
 			struct ext2_reserve_window_node * my_rsv,
 			unsigned long *count)
 {
@@ -1113,7 +1124,7 @@ ext2_try_to_allocate_with_rsv(struct sup
 	 * or last attempt to allocate a block with reservation turned on failed
 	 */
 	if (my_rsv == NULL) {
-		return ext2_try_to_allocate(sb, group, bitmap_bh,
+		return ext2_try_to_allocate(sb, group, bitmap_mb,
 						grp_goal, count, NULL);
 	}
 	/*
@@ -1147,7 +1158,7 @@ ext2_try_to_allocate_with_rsv(struct sup
 			if (my_rsv->rsv_goal_size < *count)
 				my_rsv->rsv_goal_size = *count;
 			ret = alloc_new_reservation(my_rsv, grp_goal, sb,
-							group, bitmap_bh);
+							group, bitmap_mb);
 			if (ret < 0)
 				break;			/* failed */
 
@@ -1168,7 +1179,7 @@ ext2_try_to_allocate_with_rsv(struct sup
 			rsv_window_dump(&EXT2_SB(sb)->s_rsv_window_root, 1);
 			BUG();
 		}
-		ret = ext2_try_to_allocate(sb, group, bitmap_bh, grp_goal,
+		ret = ext2_try_to_allocate(sb, group, bitmap_mb, grp_goal,
 					   &num, &my_rsv->rsv_window);
 		if (ret >= 0) {
 			my_rsv->rsv_alloc_hit += num;
@@ -1217,8 +1228,8 @@ static int ext2_has_free_blocks(struct e
 ext2_fsblk_t ext2_new_blocks(struct inode *inode, ext2_fsblk_t goal,
 		    unsigned long *count, int *errp)
 {
-	struct buffer_head *bitmap_bh = NULL;
-	struct buffer_head *gdp_bh;
+	struct fsblock_meta *bitmap_mb = NULL;
+	struct fsblock_meta *gdp_mb;
 	int group_no;
 	int goal_group;
 	ext2_grpblk_t grp_target_blk;	/* blockgroup relative goal block */
@@ -1285,7 +1296,7 @@ ext2_fsblk_t ext2_new_blocks(struct inod
 			EXT2_BLOCKS_PER_GROUP(sb);
 	goal_group = group_no;
 retry_alloc:
-	gdp = ext2_get_group_desc(sb, group_no, &gdp_bh);
+	gdp = ext2_get_group_desc(sb, group_no, &gdp_mb);
 	if (!gdp)
 		goto io_error;
 
@@ -1302,11 +1313,11 @@ retry_alloc:
 	if (free_blocks > 0) {
 		grp_target_blk = ((goal - le32_to_cpu(es->s_first_data_block)) %
 				EXT2_BLOCKS_PER_GROUP(sb));
-		bitmap_bh = read_block_bitmap(sb, group_no);
-		if (!bitmap_bh)
+		bitmap_mb = read_block_bitmap(sb, group_no);
+		if (!bitmap_mb)
 			goto io_error;
 		grp_alloc_blk = ext2_try_to_allocate_with_rsv(sb, group_no,
-					bitmap_bh, grp_target_blk,
+					bitmap_mb, grp_target_blk,
 					my_rsv, &num);
 		if (grp_alloc_blk >= 0)
 			goto allocated;
@@ -1323,7 +1334,7 @@ retry_alloc:
 		group_no++;
 		if (group_no >= ngroups)
 			group_no = 0;
-		gdp = ext2_get_group_desc(sb, group_no, &gdp_bh);
+		gdp = ext2_get_group_desc(sb, group_no, &gdp_mb);
 		if (!gdp)
 			goto io_error;
 
@@ -1336,15 +1347,16 @@ retry_alloc:
 		if (my_rsv && (free_blocks <= (windowsz/2)))
 			continue;
 
-		brelse(bitmap_bh);
-		bitmap_bh = read_block_bitmap(sb, group_no);
-		if (!bitmap_bh)
+		if (bitmap_mb)
+			block_put(bitmap_mb);
+		bitmap_mb = read_block_bitmap(sb, group_no);
+		if (!bitmap_mb)
 			goto io_error;
 		/*
 		 * try to allocate block(s) from this group, without a goal(-1).
 		 */
 		grp_alloc_blk = ext2_try_to_allocate_with_rsv(sb, group_no,
-					bitmap_bh, -1, my_rsv, &num);
+					bitmap_mb, -1, my_rsv, &num);
 		if (grp_alloc_blk >= 0)
 			goto allocated;
 	}
@@ -1400,15 +1412,15 @@ allocated:
 		goto out;
 	}
 
-	group_adjust_blocks(sb, group_no, gdp, gdp_bh, -num);
+	group_adjust_blocks(sb, group_no, gdp, gdp_mb, -num);
 	percpu_counter_sub(&sbi->s_freeblocks_counter, num);
 
-	mark_buffer_dirty(bitmap_bh);
+	mark_mblock_dirty(bitmap_mb);
 	if (sb->s_flags & MS_SYNCHRONOUS)
-		sync_dirty_buffer(bitmap_bh);
+		sync_block(bitmap_mb);
 
 	*errp = 0;
-	brelse(bitmap_bh);
+	block_put(bitmap_mb);
 	DQUOT_FREE_BLOCK(inode, *count-num);
 	*count = num;
 	return ret_block;
@@ -1421,7 +1433,8 @@ out:
 	 */
 	if (!performed_allocation)
 		DQUOT_FREE_BLOCK(inode, *count);
-	brelse(bitmap_bh);
+	if (bitmap_mb)
+		block_put(bitmap_mb);
 	return 0;
 }
 
@@ -1436,7 +1449,7 @@ ext2_fsblk_t ext2_new_block(struct inode
 
 static const int nibblemap[] = {4, 3, 3, 2, 3, 2, 2, 1, 3, 2, 2, 1, 2, 1, 1, 0};
 
-unsigned long ext2_count_free (struct buffer_head * map, unsigned int numchars)
+unsigned long ext2_count_free (struct fsblock_meta * map, unsigned int numchars)
 {
 	unsigned int i;
 	unsigned long sum = 0;
@@ -1444,8 +1457,8 @@ unsigned long ext2_count_free (struct bu
 	if (!map)
 		return (0);
 	for (i = 0; i < numchars; i++)
-		sum += nibblemap[map->b_data[i] & 0xf] +
-			nibblemap[(map->b_data[i] >> 4) & 0xf];
+		sum += nibblemap[map->data[i] & 0xf] +
+			nibblemap[(map->data[i] >> 4) & 0xf];
 	return (sum);
 }
 
@@ -1465,20 +1478,20 @@ unsigned long ext2_count_free_blocks (st
 	bitmap_count = 0;
 	desc = NULL;
 	for (i = 0; i < EXT2_SB(sb)->s_groups_count; i++) {
-		struct buffer_head *bitmap_bh;
+		struct fsblock_meta *bitmap_mb;
 		desc = ext2_get_group_desc (sb, i, NULL);
 		if (!desc)
 			continue;
 		desc_count += le16_to_cpu(desc->bg_free_blocks_count);
-		bitmap_bh = read_block_bitmap(sb, i);
-		if (!bitmap_bh)
+		bitmap_mb = read_block_bitmap(sb, i);
+		if (!bitmap_mb)
 			continue;
 		
-		x = ext2_count_free(bitmap_bh, sb->s_blocksize);
+		x = ext2_count_free(bitmap_mb, sb->s_blocksize);
 		printk ("group %d: stored = %d, counted = %lu\n",
 			i, le16_to_cpu(desc->bg_free_blocks_count), x);
 		bitmap_count += x;
-		brelse(bitmap_bh);
+		block_put(bitmap_mb);
 	}
 	printk("ext2_count_free_blocks: stored = %lu, computed = %lu, %lu\n",
 		(long)le32_to_cpu(es->s_free_blocks_count),
Index: linux-2.6/fs/ext2/dir.c
===================================================================
--- linux-2.6.orig/fs/ext2/dir.c
+++ linux-2.6/fs/ext2/dir.c
@@ -22,7 +22,7 @@
  */
 
 #include "ext2.h"
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/pagemap.h>
 #include <linux/swap.h>
 
@@ -88,7 +88,7 @@ static int ext2_commit_chunk(struct page
 	int err = 0;
 
 	dir->i_version++;
-	block_write_end(NULL, mapping, pos, len, len, page, NULL);
+	__fsblock_write_end(mapping, pos, len, len, page, NULL);
 
 	if (pos+len > dir->i_size) {
 		i_size_write(dir, pos+len);
@@ -198,10 +198,12 @@ static struct page * ext2_get_page(struc
 			ext2_check_page(page, quiet);
 		if (PageError(page))
 			goto fail;
-	}
+	} else
+		printk("ext2_get_page read_mapping_page error\n");
 	return page;
 
 fail:
+	printk("ext2_get_page PageError\n");
 	ext2_put_page(page);
 	return ERR_PTR(-EIO);
 }
Index: linux-2.6/fs/ext2/ext2.h
===================================================================
--- linux-2.6.orig/fs/ext2/ext2.h
+++ linux-2.6/fs/ext2/ext2.h
@@ -1,5 +1,6 @@
 #include <linux/fs.h>
 #include <linux/ext2_fs.h>
+#include <linux/fsb_extentmap.h>
 
 /*
  * ext2 mount options
@@ -62,6 +63,7 @@ struct ext2_inode_info {
 	struct mutex truncate_mutex;
 	struct inode	vfs_inode;
 	struct list_head i_orphan;	/* unlinked but open inodes */
+	struct fsb_ext_root fsb_ext_root;
 };
 
 /*
@@ -97,7 +99,7 @@ extern unsigned long ext2_count_dirs (st
 extern void ext2_check_blocks_bitmap (struct super_block *);
 extern struct ext2_group_desc * ext2_get_group_desc(struct super_block * sb,
 						    unsigned int block_group,
-						    struct buffer_head ** bh);
+						    struct fsblock_meta ** mb);
 extern void ext2_discard_reservation (struct inode *);
 extern int ext2_should_retry_alloc(struct super_block *sb, int *retries);
 extern void ext2_init_block_alloc_info(struct inode *);
@@ -121,23 +123,24 @@ extern struct inode * ext2_new_inode (st
 extern void ext2_free_inode (struct inode *);
 extern unsigned long ext2_count_free_inodes (struct super_block *);
 extern void ext2_check_inodes_bitmap (struct super_block *);
-extern unsigned long ext2_count_free (struct buffer_head *, unsigned);
+extern unsigned long ext2_count_free (struct fsblock_meta *, unsigned);
 
 /* inode.c */
 extern struct inode *ext2_iget (struct super_block *, unsigned long);
 extern int ext2_write_inode (struct inode *, int);
 extern void ext2_delete_inode (struct inode *);
 extern int ext2_sync_inode (struct inode *);
-extern int ext2_get_block(struct inode *, sector_t, struct buffer_head *, int);
+extern int ext2_insert_mapping(struct address_space *, loff_t, size_t, int);
 extern void ext2_truncate (struct inode *);
 extern int ext2_setattr (struct dentry *, struct iattr *);
 extern void ext2_set_inode_flags(struct inode *inode);
 extern void ext2_get_inode_flags(struct ext2_inode_info *);
 extern int ext2_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
 		       u64 start, u64 len);
-int __ext2_write_begin(struct file *file, struct address_space *mapping,
+extern int __ext2_write_begin(struct file *file, struct address_space *mapping,
 		loff_t pos, unsigned len, unsigned flags,
 		struct page **pagep, void **fsdata);
+extern int ext2_page_mkwrite(struct vm_area_struct *vma, struct page *page);
 
 /* ioctl.c */
 extern long ext2_ioctl(struct file *, unsigned int, unsigned long);
Index: linux-2.6/fs/ext2/fsync.c
===================================================================
--- linux-2.6.orig/fs/ext2/fsync.c
+++ linux-2.6/fs/ext2/fsync.c
@@ -23,7 +23,7 @@
  */
 
 #include "ext2.h"
-#include <linux/buffer_head.h>		/* for sync_mapping_buffers() */
+#include <linux/fsblock.h>		/* for sync_mapping_buffers() */
 
 
 /*
@@ -37,7 +37,7 @@ int ext2_sync_file(struct file *file, st
 	int err;
 	int ret;
 
-	ret = sync_mapping_buffers(inode->i_mapping);
+	ret = fsblock_sync(inode->i_mapping);
 	if (!(inode->i_state & I_DIRTY))
 		return ret;
 	if (datasync && !(inode->i_state & I_DIRTY_DATASYNC))
Index: linux-2.6/fs/ext2/ialloc.c
===================================================================
--- linux-2.6.orig/fs/ext2/ialloc.c
+++ linux-2.6/fs/ext2/ialloc.c
@@ -15,7 +15,7 @@
 #include <linux/quotaops.h>
 #include <linux/sched.h>
 #include <linux/backing-dev.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/random.h>
 #include "ext2.h"
 #include "xattr.h"
@@ -40,34 +40,34 @@
  * Read the inode allocation bitmap for a given block_group, reading
  * into the specified slot in the superblock's bitmap cache.
  *
- * Return buffer_head of bitmap on success or NULL.
+ * Return fsblock_meta of bitmap on success or NULL.
  */
-static struct buffer_head *
+static struct fsblock_meta *
 read_inode_bitmap(struct super_block * sb, unsigned long block_group)
 {
 	struct ext2_group_desc *desc;
-	struct buffer_head *bh = NULL;
+	struct fsblock_meta *mb = NULL;
 
 	desc = ext2_get_group_desc(sb, block_group, NULL);
 	if (!desc)
 		goto error_out;
 
-	bh = sb_bread(sb, le32_to_cpu(desc->bg_inode_bitmap));
-	if (!bh)
+	mb = sb_mbread(&EXT2_SB(sb)->fsb_sb, le32_to_cpu(desc->bg_inode_bitmap));
+	if (!mb)
 		ext2_error(sb, "read_inode_bitmap",
 			    "Cannot read inode bitmap - "
 			    "block_group = %lu, inode_bitmap = %u",
 			    block_group, le32_to_cpu(desc->bg_inode_bitmap));
 error_out:
-	return bh;
+	return mb;
 }
 
 static void ext2_release_inode(struct super_block *sb, int group, int dir)
 {
 	struct ext2_group_desc * desc;
-	struct buffer_head *bh;
+	struct fsblock_meta *mb;
 
-	desc = ext2_get_group_desc(sb, group, &bh);
+	desc = ext2_get_group_desc(sb, group, &mb);
 	if (!desc) {
 		ext2_error(sb, "ext2_release_inode",
 			"can't get descriptor for group %d", group);
@@ -82,7 +82,7 @@ static void ext2_release_inode(struct su
 	if (dir)
 		percpu_counter_dec(&EXT2_SB(sb)->s_dirs_counter);
 	sb->s_dirt = 1;
-	mark_buffer_dirty(bh);
+	mark_mblock_dirty(mb);
 }
 
 /*
@@ -106,7 +106,7 @@ void ext2_free_inode (struct inode * ino
 	struct super_block * sb = inode->i_sb;
 	int is_directory;
 	unsigned long ino;
-	struct buffer_head *bitmap_bh = NULL;
+	struct fsblock_meta *bitmap_mb = NULL;
 	unsigned long block_group;
 	unsigned long bit;
 	struct ext2_super_block * es;
@@ -139,23 +139,25 @@ void ext2_free_inode (struct inode * ino
 	}
 	block_group = (ino - 1) / EXT2_INODES_PER_GROUP(sb);
 	bit = (ino - 1) % EXT2_INODES_PER_GROUP(sb);
-	brelse(bitmap_bh);
-	bitmap_bh = read_inode_bitmap(sb, block_group);
-	if (!bitmap_bh)
+	if (bitmap_mb)
+		block_put(bitmap_mb);
+	bitmap_mb = read_inode_bitmap(sb, block_group);
+	if (!bitmap_mb)
 		goto error_return;
 
 	/* Ok, now we can actually update the inode bitmaps.. */
 	if (!ext2_clear_bit_atomic(sb_bgl_lock(EXT2_SB(sb), block_group),
-				bit, (void *) bitmap_bh->b_data))
+				bit, (void *) bitmap_mb->data))
 		ext2_error (sb, "ext2_free_inode",
 			      "bit already cleared for inode %lu", ino);
 	else
 		ext2_release_inode(sb, block_group, is_directory);
-	mark_buffer_dirty(bitmap_bh);
+	mark_mblock_dirty(bitmap_mb);
 	if (sb->s_flags & MS_SYNCHRONOUS)
-		sync_dirty_buffer(bitmap_bh);
+		sync_block(bitmap_mb);
 error_return:
-	brelse(bitmap_bh);
+	if (bitmap_mb)
+		block_put(bitmap_mb);
 }
 
 /*
@@ -178,6 +180,8 @@ static void ext2_preread_inode(struct in
 	struct ext2_group_desc * gdp;
 	struct backing_dev_info *bdi;
 
+	return;  /* XXX */
+
 	bdi = inode->i_mapping->backing_dev_info;
 	if (bdi_read_congested(bdi))
 		return;
@@ -196,7 +200,7 @@ static void ext2_preread_inode(struct in
 				EXT2_INODE_SIZE(inode->i_sb);
 	block = le32_to_cpu(gdp->bg_inode_table) +
 				(offset >> EXT2_BLOCK_SIZE_BITS(inode->i_sb));
-	sb_breadahead(inode->i_sb, block);
+//	sb_breadahead(inode->i_sb, block);
 }
 
 /*
@@ -438,8 +442,8 @@ found:
 struct inode *ext2_new_inode(struct inode *dir, int mode)
 {
 	struct super_block *sb;
-	struct buffer_head *bitmap_bh = NULL;
-	struct buffer_head *bh2;
+	struct fsblock_meta *bitmap_mb = NULL;
+	struct fsblock_meta *mb;
 	int group, i;
 	ino_t ino = 0;
 	struct inode * inode;
@@ -471,17 +475,18 @@ struct inode *ext2_new_inode(struct inod
 	}
 
 	for (i = 0; i < sbi->s_groups_count; i++) {
-		gdp = ext2_get_group_desc(sb, group, &bh2);
-		brelse(bitmap_bh);
-		bitmap_bh = read_inode_bitmap(sb, group);
-		if (!bitmap_bh) {
+		gdp = ext2_get_group_desc(sb, group, &mb);
+		if (bitmap_mb)
+			block_put(bitmap_mb);
+		bitmap_mb = read_inode_bitmap(sb, group);
+		if (!bitmap_mb) {
 			err = -EIO;
 			goto fail;
 		}
 		ino = 0;
 
 repeat_in_this_group:
-		ino = ext2_find_next_zero_bit((unsigned long *)bitmap_bh->b_data,
+		ino = ext2_find_next_zero_bit((unsigned long *)bitmap_mb->data,
 					      EXT2_INODES_PER_GROUP(sb), ino);
 		if (ino >= EXT2_INODES_PER_GROUP(sb)) {
 			/*
@@ -497,7 +502,7 @@ repeat_in_this_group:
 			continue;
 		}
 		if (ext2_set_bit_atomic(sb_bgl_lock(sbi, group),
-						ino, bitmap_bh->b_data)) {
+						ino, bitmap_mb->data)) {
 			/* we lost this inode */
 			if (++ino >= EXT2_INODES_PER_GROUP(sb)) {
 				/* this group is exhausted, try next group */
@@ -517,10 +522,10 @@ repeat_in_this_group:
 	err = -ENOSPC;
 	goto fail;
 got:
-	mark_buffer_dirty(bitmap_bh);
+	mark_mblock_dirty(bitmap_mb);
 	if (sb->s_flags & MS_SYNCHRONOUS)
-		sync_dirty_buffer(bitmap_bh);
-	brelse(bitmap_bh);
+		sync_block(bitmap_mb);
+	block_put(bitmap_mb);
 
 	ino += group * EXT2_INODES_PER_GROUP(sb) + 1;
 	if (ino < EXT2_FIRST_INO(sb) || ino > le32_to_cpu(es->s_inodes_count)) {
@@ -549,7 +554,7 @@ got:
 	spin_unlock(sb_bgl_lock(sbi, group));
 
 	sb->s_dirt = 1;
-	mark_buffer_dirty(bh2);
+	mark_mblock_dirty(mb);
 	inode->i_uid = current_fsuid();
 	if (test_opt (sb, GRPID))
 		inode->i_gid = dir->i_gid;
@@ -630,7 +635,7 @@ unsigned long ext2_count_free_inodes (st
 #ifdef EXT2FS_DEBUG
 	struct ext2_super_block *es;
 	unsigned long bitmap_count = 0;
-	struct buffer_head *bitmap_bh = NULL;
+	struct fsblock_meta *bitmap_mb = NULL;
 
 	es = EXT2_SB(sb)->s_es;
 	for (i = 0; i < EXT2_SB(sb)->s_groups_count; i++) {
@@ -640,17 +645,19 @@ unsigned long ext2_count_free_inodes (st
 		if (!desc)
 			continue;
 		desc_count += le16_to_cpu(desc->bg_free_inodes_count);
-		brelse(bitmap_bh);
-		bitmap_bh = read_inode_bitmap(sb, i);
-		if (!bitmap_bh)
+		if (bitmap_mb)
+			block_put(bitmap_mb);
+		bitmap_mb = read_inode_bitmap(sb, i);
+		if (!bitmap_mb)
 			continue;
 
-		x = ext2_count_free(bitmap_bh, EXT2_INODES_PER_GROUP(sb) / 8);
+		x = ext2_count_free(bitmap_mb, EXT2_INODES_PER_GROUP(sb) / 8);
 		printk("group %d: stored = %d, counted = %u\n",
 			i, le16_to_cpu(desc->bg_free_inodes_count), x);
 		bitmap_count += x;
 	}
-	brelse(bitmap_bh);
+	if (bitmap_mb)
+		block_put(bitmap_mb);
 	printk("ext2_count_free_inodes: stored = %lu, computed = %lu, %lu\n",
 		percpu_counter_read(&EXT2_SB(sb)->s_freeinodes_counter),
 		desc_count, bitmap_count);
Index: linux-2.6/fs/ext2/inode.c
===================================================================
--- linux-2.6.orig/fs/ext2/inode.c
+++ linux-2.6/fs/ext2/inode.c
@@ -29,7 +29,7 @@
 #include <linux/quotaops.h>
 #include <linux/module.h>
 #include <linux/writeback.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/mpage.h>
 #include <linux/fiemap.h>
 #include <linux/namei.h>
@@ -71,6 +71,7 @@ void ext2_delete_inode (struct inode * i
 	inode->i_size = 0;
 	if (inode->i_blocks)
 		ext2_truncate (inode);
+	fsblock_release(&inode->i_data, 1); /* XXX: just do this at delete time? (but that goes bug in clear_inode mapping has private check) */
 	ext2_free_inode (inode);
 
 	return;
@@ -81,13 +82,13 @@ no_delete:
 typedef struct {
 	__le32	*p;
 	__le32	key;
-	struct buffer_head *bh;
+	struct fsblock_meta *mb;
 } Indirect;
 
-static inline void add_chain(Indirect *p, struct buffer_head *bh, __le32 *v)
+static inline void add_chain(Indirect *p, struct fsblock_meta *mb, __le32 *v)
 {
 	p->key = *(p->p = v);
-	p->bh = bh;
+	p->mb = mb;
 }
 
 static inline int verify_chain(Indirect *from, Indirect *to)
@@ -175,16 +176,16 @@ static int ext2_block_to_path(struct ino
  *	@chain: place to store the result
  *	@err: here we store the error value
  *
- *	Function fills the array of triples <key, p, bh> and returns %NULL
+ *	Function fills the array of triples <key, p, mb> and returns %NULL
  *	if everything went OK or the pointer to the last filled triple
  *	(incomplete one) otherwise. Upon the return chain[i].key contains
  *	the number of (i+1)-th block in the chain (as it is stored in memory,
  *	i.e. little-endian 32-bit), chain[i].p contains the address of that
- *	number (it points into struct inode for i==0 and into the bh->b_data
- *	for i>0) and chain[i].bh points to the buffer_head of i-th indirect
+ *	number (it points into struct inode for i==0 and into the mb->data
+ *	for i>0) and chain[i].mb points to the fsblock_meta of i-th indirect
  *	block for i>0 and NULL for i==0. In other words, it holds the block
  *	numbers of the chain, addresses they were taken from (and where we can
- *	verify that chain did not change) and buffer_heads hosting these
+ *	verify that chain did not change) and fsblock_meta hosting these
  *	numbers.
  *
  *	Function stops when it stumbles upon zero pointer (absent block)
@@ -204,7 +205,7 @@ static Indirect *ext2_get_branch(struct
 {
 	struct super_block *sb = inode->i_sb;
 	Indirect *p = chain;
-	struct buffer_head *bh;
+	struct fsblock_meta *mb;
 
 	*err = 0;
 	/* i_data is not going away, no lock needed */
@@ -212,13 +213,13 @@ static Indirect *ext2_get_branch(struct
 	if (!p->key)
 		goto no_block;
 	while (--depth) {
-		bh = sb_bread(sb, le32_to_cpu(p->key));
-		if (!bh)
+		mb = sb_mbread(&EXT2_SB(sb)->fsb_sb, le32_to_cpu(p->key));
+		if (!mb)
 			goto failure;
 		read_lock(&EXT2_I(inode)->i_meta_lock);
 		if (!verify_chain(chain, p))
 			goto changed;
-		add_chain(++p, bh, (__le32*)bh->b_data + *++offsets);
+		add_chain(++p, mb, (__le32*)mb->data + *++offsets);
 		read_unlock(&EXT2_I(inode)->i_meta_lock);
 		if (!p->key)
 			goto no_block;
@@ -227,7 +228,7 @@ static Indirect *ext2_get_branch(struct
 
 changed:
 	read_unlock(&EXT2_I(inode)->i_meta_lock);
-	brelse(bh);
+	block_put(mb);
 	*err = -EAGAIN;
 	goto no_block;
 failure:
@@ -259,7 +260,7 @@ no_block:
 static ext2_fsblk_t ext2_find_near(struct inode *inode, Indirect *ind)
 {
 	struct ext2_inode_info *ei = EXT2_I(inode);
-	__le32 *start = ind->bh ? (__le32 *) ind->bh->b_data : ei->i_data;
+	__le32 *start = ind->mb ? (__le32 *) ind->mb->data : ei->i_data;
 	__le32 *p;
 	ext2_fsblk_t bg_start;
 	ext2_fsblk_t colour;
@@ -270,8 +271,8 @@ static ext2_fsblk_t ext2_find_near(struc
 			return le32_to_cpu(*p);
 
 	/* No such thing, so let's try location of indirect block */
-	if (ind->bh)
-		return ind->bh->b_blocknr;
+	if (ind->mb)
+		return ind->mb->block.block_nr;
 
 	/*
 	 * It is going to be refered from inode itself? OK, just put it into
@@ -431,19 +432,19 @@ failed_out:
  *	be placed into *branch->p to fill that gap.
  *
  *	If allocation fails we free all blocks we've allocated (and forget
- *	their buffer_heads) and return the error value the from failed
+ *	their fsblock_meta) and return the error value the from failed
  *	ext2_alloc_block() (normally -ENOSPC). Otherwise we set the chain
  *	as described above and return 0.
  */
 
-static int ext2_alloc_branch(struct inode *inode,
+static noinline int ext2_alloc_branch(struct inode *inode,
 			int indirect_blks, int *blks, ext2_fsblk_t goal,
 			int *offsets, Indirect *branch)
 {
 	int blocksize = inode->i_sb->s_blocksize;
 	int i, n = 0;
 	int err = 0;
-	struct buffer_head *bh;
+	struct fsblock_meta *mb;
 	int num;
 	ext2_fsblk_t new_blocks[4];
 	ext2_fsblk_t current_block;
@@ -459,15 +460,19 @@ static int ext2_alloc_branch(struct inod
 	 */
 	for (n = 1; n <= indirect_blks;  n++) {
 		/*
-		 * Get buffer_head for parent block, zero it out
+		 * Get fsblock_meta for parent block, zero it out
 		 * and set the pointer to new one, then send
 		 * parent to disk.
 		 */
-		bh = sb_getblk(inode->i_sb, new_blocks[n-1]);
-		branch[n].bh = bh;
-		lock_buffer(bh);
-		memset(bh->b_data, 0, blocksize);
-		branch[n].p = (__le32 *) bh->b_data + offsets[n];
+		mb = sb_find_or_create_mblock(&EXT2_SB(inode->i_sb)->fsb_sb, new_blocks[n-1]);
+		if (IS_ERR(mb)) {
+			err = PTR_ERR(mb);
+			break; /* XXX: proper error handling */
+		}
+		branch[n].mb = mb;
+		lock_block(mb);
+		memset(mb->data, 0, blocksize);
+		branch[n].p = (__le32 *) mb->data + offsets[n];
 		branch[n].key = cpu_to_le32(new_blocks[n]);
 		*branch[n].p = branch[n].key;
 		if ( n == indirect_blks) {
@@ -480,15 +485,15 @@ static int ext2_alloc_branch(struct inod
 			for (i=1; i < num; i++)
 				*(branch[n].p + i) = cpu_to_le32(++current_block);
 		}
-		set_buffer_uptodate(bh);
-		unlock_buffer(bh);
-		mark_buffer_dirty_inode(bh, inode);
-		/* We used to sync bh here if IS_SYNC(inode).
+		mark_mblock_uptodate(mb);
+		unlock_block(mb);
+		mark_mblock_dirty_inode(mb, inode);
+		/* We used to sync mb here if IS_SYNC(inode).
 		 * But we now rely upon generic_osync_inode()
 		 * and b_inode_buffers.  But not for directories.
 		 */
 		if (S_ISDIR(inode->i_mode) && IS_DIRSYNC(inode))
-			sync_dirty_buffer(bh);
+			sync_block(mb);
 	}
 	*blks = num;
 	return err;
@@ -506,7 +511,7 @@ static int ext2_alloc_branch(struct inod
  * inode (->i_blocks, etc.). In case of success we end up with the full
  * chain to new block and return 0.
  */
-static void ext2_splice_branch(struct inode *inode,
+static noinline void ext2_splice_branch(struct inode *inode,
 			long block, Indirect *where, int num, int blks)
 {
 	int i;
@@ -521,7 +526,7 @@ static void ext2_splice_branch(struct in
 	*where->p = where->key;
 
 	/*
-	 * Update the host buffer_head or inode to point to more just allocated
+	 * Update the host fsblock_meta or inode to point to more just allocated
 	 * direct blocks blocks
 	 */
 	if (num == 0 && blks > 1) {
@@ -544,8 +549,8 @@ static void ext2_splice_branch(struct in
 	/* We are done with atomic stuff, now do the rest of housekeeping */
 
 	/* had we spliced it onto indirect block? */
-	if (where->bh)
-		mark_buffer_dirty_inode(where->bh, inode);
+	if (where->mb)
+		mark_mblock_dirty_inode(where->mb, inode);
 
 	inode->i_ctime = CURRENT_TIME_SEC;
 	mark_inode_dirty(inode);
@@ -569,10 +574,10 @@ static void ext2_splice_branch(struct in
  * return = 0, if plain lookup failed.
  * return < 0, error case.
  */
-static int ext2_get_blocks(struct inode *inode,
-			   sector_t iblock, unsigned long maxblocks,
-			   struct buffer_head *bh_result,
-			   int create)
+static int ext2_get_blocks(struct inode *inode, sector_t blocknr,
+				unsigned long maxblocks, int create,
+				sector_t *offset, sector_t *block,
+				unsigned int *size, unsigned int *flags)
 {
 	int err = -EIO;
 	int offsets[4];
@@ -586,7 +591,11 @@ static int ext2_get_blocks(struct inode
 	int count = 0;
 	ext2_fsblk_t first_block = 0;
 
-	depth = ext2_block_to_path(inode,iblock,offsets,&blocks_to_boundary);
+	FSB_BUG_ON(create == MAP_BLOCK_ALLOCATE);
+
+	*flags = 0;
+
+	depth = ext2_block_to_path(inode, blocknr, offsets,&blocks_to_boundary);
 
 	if (depth == 0)
 		return (err);
@@ -596,7 +605,6 @@ reread:
 	/* Simplest case - block found, no allocation needed */
 	if (!partial) {
 		first_block = le32_to_cpu(chain[depth - 1].key);
-		clear_buffer_new(bh_result); /* What's this do? */
 		count++;
 		/*map more blocks*/
 		while (count < maxblocks && count <= blocks_to_boundary) {
@@ -622,6 +630,11 @@ reread:
 	}
 
 	/* Next simple case - plain lookup or failed read of indirect block */
+	if (!create && err != -EIO) {
+		*size = 1;
+		*offset = blocknr;
+		*flags |= FE_hole;
+	}
 	if (!create || err == -EIO)
 		goto cleanup;
 
@@ -634,7 +647,7 @@ reread:
 	if (S_ISREG(inode->i_mode) && (!ei->i_block_alloc_info))
 		ext2_init_block_alloc_info(inode);
 
-	goal = ext2_find_goal(inode, iblock, partial);
+	goal = ext2_find_goal(inode, blocknr, partial);
 
 	/* the number of blocks need to allocate for [d,t]indirect blocks */
 	indirect_blks = (chain + depth) - partial - 1;
@@ -667,73 +680,117 @@ reread:
 		}
 	}
 
-	ext2_splice_branch(inode, iblock, partial, indirect_blks, count);
+	ext2_splice_branch(inode, blocknr, partial, indirect_blks, count);
 	mutex_unlock(&ei->truncate_mutex);
-	set_buffer_new(bh_result);
+	*flags |= FE_new;
+	*flags &= ~FE_hole;
 got_it:
-	map_bh(bh_result, inode->i_sb, le32_to_cpu(chain[depth-1].key));
-	if (count > blocks_to_boundary)
-		set_buffer_boundary(bh_result);
+	FSB_BUG_ON(*flags & FE_hole);
+	*flags |= FE_mapped;
+	*offset = blocknr;
+	*size = 1;
+	*block = le32_to_cpu(chain[depth-1].key);
+//	if (count > blocks_to_boundary)
+//		set_buffer_boundary(bh_result);
 	err = count;
 	/* Clean up and exit */
 	partial = chain + depth - 1;	/* the whole chain */
 cleanup:
 	while (partial > chain) {
-		brelse(partial->bh);
+		block_put(partial->mb);
 		partial--;
 	}
 	return err;
 changed:
 	while (partial > chain) {
-		brelse(partial->bh);
+		block_put(partial->mb);
 		partial--;
 	}
 	goto reread;
 }
 
-int ext2_get_block(struct inode *inode, sector_t iblock, struct buffer_head *bh_result, int create)
-{
-	unsigned max_blocks = bh_result->b_size >> inode->i_blkbits;
-	int ret = ext2_get_blocks(inode, iblock, max_blocks,
-			      bh_result, create);
-	if (ret > 0) {
-		bh_result->b_size = (ret << inode->i_blkbits);
+#ifdef EXT2_EXTMAP
+static int ext2_map_extent(struct address_space *mapping, loff_t pos, int mode,
+				sector_t *offset, sector_t *block,
+				unsigned int *size, unsigned int *flags)
+{
+	struct inode *inode = mapping->host;
+	sector_t blocknr;
+	int ret;
+
+	blocknr = pos >> inode->i_blkbits;
+
+	ret = ext2_get_blocks(inode, blocknr, 1, mode, offset, block, size, flags);
+	if (ret > 0)
 		ret = 0;
-	}
 	return ret;
-
 }
 
-int ext2_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
-		u64 start, u64 len)
+static int ext2_map_block(struct address_space *mapping,
+			struct fsblock *block, loff_t pos, int mode)
 {
-	return generic_block_fiemap(inode, fieinfo, start, len,
-				    ext2_get_block);
+	FSB_BUG_ON(block->flags & BL_mapped);
+	FSB_BUG_ON(mode == MAP_BLOCK_ALLOCATE);
+
+	return fsb_ext_map_fsblock(mapping, pos, block, mode, &EXT2_I(mapping->host)->fsb_ext_root, ext2_map_extent);
 }
+#else
 
-static int ext2_writepage(struct page *page, struct writeback_control *wbc)
+static int ext2_map_block(struct address_space *mapping,
+			struct fsblock *b, loff_t pos, int mode)
 {
-	return block_write_full_page(page, ext2_get_block, wbc);
+	struct inode *inode = mapping->host;
+	sector_t blocknr;
+	sector_t offset;
+	sector_t block = (sector_t)ULLONG_MAX;
+	unsigned int flags, size;
+	int ret;
+
+	FSB_BUG_ON(b->flags & BL_mapped);
+	FSB_BUG_ON(mode == MAP_BLOCK_ALLOCATE);
+
+	blocknr = pos >> inode->i_blkbits;
+
+	ret = ext2_get_blocks(inode, blocknr, 1, mode, &offset, &block, &size, &flags);
+	if (ret > 0) {
+		ret = 0;
+	}
+	if (!ret) {
+		if (flags & FE_mapped) {
+			spin_lock_block_irq(b);
+			map_fsblock(b, block);
+			if (flags & FE_new) {
+				b->flags |= BL_new;
+				b->flags &= ~BL_hole;
+			}
+			FSB_BUG_ON(b->flags & BL_hole);
+			spin_unlock_block_irq(b);
+		} else if (flags & FE_hole) {
+			spin_lock_block_irq(b);
+			b->flags |= BL_hole;
+			spin_unlock_block_irq(b);
+		}
+	}
+	return ret;
 }
+#endif
 
-static int ext2_readpage(struct file *file, struct page *page)
+static int ext2_writepage(struct page *page, struct writeback_control *wbc)
 {
-	return mpage_readpage(page, ext2_get_block);
+	return fsblock_write_page(page, ext2_map_block, wbc);
 }
 
-static int
-ext2_readpages(struct file *file, struct address_space *mapping,
-		struct list_head *pages, unsigned nr_pages)
+static int ext2_readpage(struct file *file, struct page *page)
 {
-	return mpage_readpages(mapping, pages, nr_pages, ext2_get_block);
+	return fsblock_read_page(page, ext2_map_block);
 }
 
 int __ext2_write_begin(struct file *file, struct address_space *mapping,
 		loff_t pos, unsigned len, unsigned flags,
 		struct page **pagep, void **fsdata)
 {
-	return block_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
-							ext2_get_block);
+	return fsblock_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
+							ext2_map_block);
 }
 
 static int
@@ -745,31 +802,17 @@ ext2_write_begin(struct file *file, stru
 	return __ext2_write_begin(file, mapping, pos, len, flags, pagep,fsdata);
 }
 
-static int
-ext2_nobh_write_begin(struct file *file, struct address_space *mapping,
-		loff_t pos, unsigned len, unsigned flags,
-		struct page **pagep, void **fsdata)
-{
-	/*
-	 * Dir-in-pagecache still uses ext2_write_begin. Would have to rework
-	 * directory handling code to pass around offsets rather than struct
-	 * pages in order to make this work easily.
-	 */
-	return nobh_write_begin(file, mapping, pos, len, flags, pagep, fsdata,
-							ext2_get_block);
-}
-
-static int ext2_nobh_writepage(struct page *page,
-			struct writeback_control *wbc)
+static sector_t ext2_bmap(struct address_space *mapping, sector_t block)
 {
-	return nobh_writepage(page, ext2_get_block, wbc);
+	return fsblock_bmap(mapping, block, ext2_map_block);
 }
 
-static sector_t ext2_bmap(struct address_space *mapping, sector_t block)
+int ext2_page_mkwrite(struct vm_area_struct *vma, struct page *page)
 {
-	return generic_block_bmap(mapping,block,ext2_get_block);
+	return fsblock_page_mkwrite(vma, page, ext2_map_block);
 }
 
+#if 0
 static ssize_t
 ext2_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs)
@@ -786,19 +829,25 @@ ext2_writepages(struct address_space *ma
 {
 	return mpage_writepages(mapping, wbc, ext2_get_block);
 }
+#endif
 
 const struct address_space_operations ext2_aops = {
 	.readpage		= ext2_readpage,
-	.readpages		= ext2_readpages,
+//	.readpages		= ext2_readpages,
 	.writepage		= ext2_writepage,
-	.sync_page		= block_sync_page,
+//	.sync_page		= block_sync_page,
 	.write_begin		= ext2_write_begin,
-	.write_end		= generic_write_end,
+	.write_end		= fsblock_write_end,
 	.bmap			= ext2_bmap,
-	.direct_IO		= ext2_direct_IO,
-	.writepages		= ext2_writepages,
-	.migratepage		= buffer_migrate_page,
-	.is_partially_uptodate	= block_is_partially_uptodate,
+//	.direct_IO		= ext2_direct_IO,
+//	.writepages		= ext2_writepages,
+//	.migratepage		= buffer_migrate_page,
+//	.is_partially_uptodate	= block_is_partially_uptodate,
+	.set_page_dirty		= fsblock_set_page_dirty,
+	.invalidatepage		= fsblock_invalidate_page,
+	.releasepage		= fsblock_releasepage,
+	.release		= fsblock_release,
+	.sync			= fsblock_sync,
 };
 
 const struct address_space_operations ext2_aops_xip = {
@@ -806,19 +855,6 @@ const struct address_space_operations ex
 	.get_xip_mem		= ext2_get_xip_mem,
 };
 
-const struct address_space_operations ext2_nobh_aops = {
-	.readpage		= ext2_readpage,
-	.readpages		= ext2_readpages,
-	.writepage		= ext2_nobh_writepage,
-	.sync_page		= block_sync_page,
-	.write_begin		= ext2_nobh_write_begin,
-	.write_end		= nobh_write_end,
-	.bmap			= ext2_bmap,
-	.direct_IO		= ext2_direct_IO,
-	.writepages		= ext2_writepages,
-	.migratepage		= buffer_migrate_page,
-};
-
 /*
  * Probably it should be a library function... search for first non-zero word
  * or memcmp with zero_page, whatever is better for particular architecture.
@@ -853,7 +889,7 @@ static inline int all_zeroes(__le32 *p,
  *	point might try to populate it.
  *
  *	We atomically detach the top of branch from the tree, store the block
- *	number of its root in *@top, pointers to buffer_heads of partially
+ *	number of its root in *@top, pointers to fsblock_meta of partially
  *	truncated blocks - in @chain[].bh and pointers to their last elements
  *	that should not be removed - in @chain[].p. Return value is the pointer
  *	to last filled element of @chain.
@@ -890,7 +926,7 @@ static Indirect *ext2_find_shared(struct
 		write_unlock(&EXT2_I(inode)->i_meta_lock);
 		goto no_top;
 	}
-	for (p=partial; p>chain && all_zeroes((__le32*)p->bh->b_data,p->p); p--)
+	for (p=partial; p>chain && all_zeroes((__le32*)p->mb->data,p->p); p--)
 		;
 	/*
 	 * OK, we've found the last block that must survive. The rest of our
@@ -908,7 +944,7 @@ static Indirect *ext2_find_shared(struct
 
 	while(partial > p)
 	{
-		brelse(partial->bh);
+		block_put(partial->mb);
 		partial--;
 	}
 no_top:
@@ -967,7 +1003,7 @@ static inline void ext2_free_data(struct
  */
 static void ext2_free_branches(struct inode *inode, __le32 *p, __le32 *q, int depth)
 {
-	struct buffer_head * bh;
+	struct fsblock_meta * mb;
 	unsigned long nr;
 
 	if (depth--) {
@@ -977,22 +1013,22 @@ static void ext2_free_branches(struct in
 			if (!nr)
 				continue;
 			*p = 0;
-			bh = sb_bread(inode->i_sb, nr);
+			mb = sb_mbread(&EXT2_SB(inode->i_sb)->fsb_sb, nr);
 			/*
 			 * A read failure? Report error and clear slot
 			 * (should be rare).
 			 */ 
-			if (!bh) {
+			if (!mb) {
 				ext2_error(inode->i_sb, "ext2_free_branches",
 					"Read failure, inode=%ld, block=%ld",
 					inode->i_ino, nr);
 				continue;
 			}
 			ext2_free_branches(inode,
-					   (__le32*)bh->b_data,
-					   (__le32*)bh->b_data + addr_per_block,
+					   (__le32*)mb->data,
+					   (__le32*)mb->data + addr_per_block,
 					   depth);
-			bforget(bh);
+			mbforget(mb);
 			ext2_free_blocks(inode, nr, 1);
 			mark_inode_dirty(inode);
 		}
@@ -1000,7 +1036,7 @@ static void ext2_free_branches(struct in
 		ext2_free_data(inode, p, q);
 }
 
-void ext2_truncate(struct inode *inode)
+noinline void ext2_truncate(struct inode *inode)
 {
 	__le32 *i_data = EXT2_I(inode)->i_data;
 	struct ext2_inode_info *ei = EXT2_I(inode);
@@ -1027,12 +1063,14 @@ void ext2_truncate(struct inode *inode)
 
 	if (mapping_is_xip(inode->i_mapping))
 		xip_truncate_page(inode->i_mapping, inode->i_size);
-	else if (test_opt(inode->i_sb, NOBH))
-		nobh_truncate_page(inode->i_mapping,
-				inode->i_size, ext2_get_block);
-	else
-		block_truncate_page(inode->i_mapping,
-				inode->i_size, ext2_get_block);
+	else {
+		/* XXX: error codes? */
+		fsblock_truncate_page(inode->i_mapping,
+				inode->i_size);
+#ifdef EXT2_EXTMAP
+		fsb_ext_unmap_fsblock(inode->i_mapping, inode->i_size, -1, &EXT2_I(inode)->fsb_ext_root);
+#endif
+	}
 
 	n = ext2_block_to_path(inode, iblock, offsets, NULL);
 	if (n == 0)
@@ -1056,17 +1094,17 @@ void ext2_truncate(struct inode *inode)
 		if (partial == chain)
 			mark_inode_dirty(inode);
 		else
-			mark_buffer_dirty_inode(partial->bh, inode);
+			mark_mblock_dirty_inode(partial->mb, inode);
 		ext2_free_branches(inode, &nr, &nr+1, (chain+n-1) - partial);
 	}
 	/* Clear the ends of indirect blocks on the shared branch */
 	while (partial > chain) {
 		ext2_free_branches(inode,
 				   partial->p + 1,
-				   (__le32*)partial->bh->b_data+addr_per_block,
+				   (__le32*)partial->mb->data+addr_per_block,
 				   (chain+n-1) - partial);
-		mark_buffer_dirty_inode(partial->bh, inode);
-		brelse (partial->bh);
+		mark_mblock_dirty_inode(partial->mb, inode);
+		block_put(partial->mb);
 		partial--;
 	}
 do_indirects:
@@ -1102,7 +1140,7 @@ do_indirects:
 	mutex_unlock(&ei->truncate_mutex);
 	inode->i_mtime = inode->i_ctime = CURRENT_TIME_SEC;
 	if (inode_needs_sync(inode)) {
-		sync_mapping_buffers(inode->i_mapping);
+		fsblock_sync(inode->i_mapping);
 		ext2_sync_inode (inode);
 	} else {
 		mark_inode_dirty(inode);
@@ -1110,9 +1148,9 @@ do_indirects:
 }
 
 static struct ext2_inode *ext2_get_inode(struct super_block *sb, ino_t ino,
-					struct buffer_head **p)
+					struct fsblock_meta **p)
 {
-	struct buffer_head * bh;
+	struct fsblock_meta * mb;
 	unsigned long block_group;
 	unsigned long block;
 	unsigned long offset;
@@ -1133,12 +1171,12 @@ static struct ext2_inode *ext2_get_inode
 	offset = ((ino - 1) % EXT2_INODES_PER_GROUP(sb)) * EXT2_INODE_SIZE(sb);
 	block = le32_to_cpu(gdp->bg_inode_table) +
 		(offset >> EXT2_BLOCK_SIZE_BITS(sb));
-	if (!(bh = sb_bread(sb, block)))
+	if (!(mb = sb_mbread(&EXT2_SB(sb)->fsb_sb, block)))
 		goto Eio;
 
-	*p = bh;
+	*p = mb;
 	offset &= (EXT2_BLOCK_SIZE(sb) - 1);
-	return (struct ext2_inode *) (bh->b_data + offset);
+	return (struct ext2_inode *) (mb->data + offset);
 
 Einval:
 	ext2_error(sb, "ext2_get_inode", "bad inode number: %lu",
@@ -1191,7 +1229,7 @@ void ext2_get_inode_flags(struct ext2_in
 struct inode *ext2_iget (struct super_block *sb, unsigned long ino)
 {
 	struct ext2_inode_info *ei;
-	struct buffer_head * bh;
+	struct fsblock_meta * mb;
 	struct ext2_inode *raw_inode;
 	struct inode *inode;
 	long ret = -EIO;
@@ -1210,7 +1248,7 @@ struct inode *ext2_iget (struct super_bl
 #endif
 	ei->i_block_alloc_info = NULL;
 
-	raw_inode = ext2_get_inode(inode->i_sb, ino, &bh);
+	raw_inode = ext2_get_inode(inode->i_sb, ino, &mb);
 	if (IS_ERR(raw_inode)) {
 		ret = PTR_ERR(raw_inode);
  		goto bad_inode;
@@ -1237,7 +1275,7 @@ struct inode *ext2_iget (struct super_bl
 	 */
 	if (inode->i_nlink == 0 && (inode->i_mode == 0 || ei->i_dtime)) {
 		/* this inode is deleted */
-		brelse (bh);
+		block_put(mb);
 		ret = -ESTALE;
 		goto bad_inode;
 	}
@@ -1270,9 +1308,6 @@ struct inode *ext2_iget (struct super_bl
 		if (ext2_use_xip(inode->i_sb)) {
 			inode->i_mapping->a_ops = &ext2_aops_xip;
 			inode->i_fop = &ext2_xip_file_operations;
-		} else if (test_opt(inode->i_sb, NOBH)) {
-			inode->i_mapping->a_ops = &ext2_nobh_aops;
-			inode->i_fop = &ext2_file_operations;
 		} else {
 			inode->i_mapping->a_ops = &ext2_aops;
 			inode->i_fop = &ext2_file_operations;
@@ -1280,10 +1315,7 @@ struct inode *ext2_iget (struct super_bl
 	} else if (S_ISDIR(inode->i_mode)) {
 		inode->i_op = &ext2_dir_inode_operations;
 		inode->i_fop = &ext2_dir_operations;
-		if (test_opt(inode->i_sb, NOBH))
-			inode->i_mapping->a_ops = &ext2_nobh_aops;
-		else
-			inode->i_mapping->a_ops = &ext2_aops;
+		inode->i_mapping->a_ops = &ext2_aops;
 	} else if (S_ISLNK(inode->i_mode)) {
 		if (ext2_inode_is_fast_symlink(inode)) {
 			inode->i_op = &ext2_fast_symlink_inode_operations;
@@ -1291,10 +1323,7 @@ struct inode *ext2_iget (struct super_bl
 				sizeof(ei->i_data) - 1);
 		} else {
 			inode->i_op = &ext2_symlink_inode_operations;
-			if (test_opt(inode->i_sb, NOBH))
-				inode->i_mapping->a_ops = &ext2_nobh_aops;
-			else
-				inode->i_mapping->a_ops = &ext2_aops;
+			inode->i_mapping->a_ops = &ext2_aops;
 		}
 	} else {
 		inode->i_op = &ext2_special_inode_operations;
@@ -1305,7 +1334,7 @@ struct inode *ext2_iget (struct super_bl
 			init_special_inode(inode, inode->i_mode,
 			   new_decode_dev(le32_to_cpu(raw_inode->i_block[1])));
 	}
-	brelse (bh);
+	block_put(mb);
 	ext2_set_inode_flags(inode);
 	unlock_new_inode(inode);
 	return inode;
@@ -1315,15 +1344,15 @@ bad_inode:
 	return ERR_PTR(ret);
 }
 
-static int ext2_update_inode(struct inode * inode, int do_sync)
+static noinline int ext2_update_inode(struct inode * inode, int do_sync)
 {
 	struct ext2_inode_info *ei = EXT2_I(inode);
 	struct super_block *sb = inode->i_sb;
 	ino_t ino = inode->i_ino;
 	uid_t uid = inode->i_uid;
 	gid_t gid = inode->i_gid;
-	struct buffer_head * bh;
-	struct ext2_inode * raw_inode = ext2_get_inode(sb, ino, &bh);
+	struct fsblock_meta * mb;
+	struct ext2_inode * raw_inode = ext2_get_inode(sb, ino, &mb);
 	int n;
 	int err = 0;
 
@@ -1382,11 +1411,9 @@ static int ext2_update_inode(struct inod
 			       /* If this is the first large file
 				* created, add a flag to the superblock.
 				*/
-				lock_kernel();
 				ext2_update_dynamic_rev(sb);
 				EXT2_SET_RO_COMPAT_FEATURE(sb,
 					EXT2_FEATURE_RO_COMPAT_LARGE_FILE);
-				unlock_kernel();
 				ext2_write_super(sb);
 			}
 		}
@@ -1406,17 +1433,18 @@ static int ext2_update_inode(struct inod
 		}
 	} else for (n = 0; n < EXT2_N_BLOCKS; n++)
 		raw_inode->i_block[n] = ei->i_data[n];
-	mark_buffer_dirty(bh);
+	mark_mblock_dirty(mb);
 	if (do_sync) {
-		sync_dirty_buffer(bh);
-		if (buffer_req(bh) && !buffer_uptodate(bh)) {
+		sync_block(mb);
+//		if (buffer_req(bh) && !buffer_uptodate(bh)) {
+		if (!(mb->block.flags & BL_uptodate)) {
 			printk ("IO error syncing ext2 inode [%s:%08lx]\n",
 				sb->s_id, (unsigned long) ino);
 			err = -EIO;
 		}
 	}
 	ei->i_state &= ~EXT2_STATE_NEW;
-	brelse (bh);
+	block_put(mb);
 	return err;
 }
 
Index: linux-2.6/fs/ext2/super.c
===================================================================
--- linux-2.6.orig/fs/ext2/super.c
+++ linux-2.6/fs/ext2/super.c
@@ -24,7 +24,7 @@
 #include <linux/blkdev.h>
 #include <linux/parser.h>
 #include <linux/random.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/exportfs.h>
 #include <linux/smp_lock.h>
 #include <linux/vfs.h>
@@ -32,6 +32,7 @@
 #include <linux/mount.h>
 #include <linux/log2.h>
 #include <linux/quotaops.h>
+#include <linux/buffer_head.h>
 #include <asm/uaccess.h>
 #include "ext2.h"
 #include "xattr.h"
@@ -121,16 +122,19 @@ static void ext2_put_super (struct super
 		es->s_state = cpu_to_le16(sbi->s_mount_state);
 		ext2_sync_super(sb, es);
 	}
+
 	db_count = sbi->s_gdb_count;
 	for (i = 0; i < db_count; i++)
 		if (sbi->s_group_desc[i])
-			brelse (sbi->s_group_desc[i]);
+			block_put(sbi->s_group_desc[i]);
 	kfree(sbi->s_group_desc);
 	kfree(sbi->s_debts);
 	percpu_counter_destroy(&sbi->s_freeblocks_counter);
 	percpu_counter_destroy(&sbi->s_freeinodes_counter);
 	percpu_counter_destroy(&sbi->s_dirs_counter);
-	brelse (sbi->s_sbh);
+	if (sbi->s_smb)
+		block_put(sbi->s_smb);
+	fsblock_unregister_super(sb, &sbi->fsb_sb);
 	sb->s_fs_info = NULL;
 	kfree(sbi->s_blockgroup_lock);
 	kfree(sbi);
@@ -152,11 +156,16 @@ static struct inode *ext2_alloc_inode(st
 #endif
 	ei->i_block_alloc_info = NULL;
 	ei->vfs_inode.i_version = 1;
+	fsb_ext_root_init(&ei->fsb_ext_root);
 	return &ei->vfs_inode;
 }
 
 static void ext2_destroy_inode(struct inode *inode)
 {
+	fsblock_release(&inode->i_data, 1);
+#ifdef EXT2_EXTMAP
+	fsb_ext_release(inode->i_mapping, &EXT2_I(inode)->fsb_ext_root);
+#endif
 	kmem_cache_free(ext2_inode_cachep, EXT2_I(inode));
 }
 
@@ -739,6 +748,7 @@ static unsigned long descriptor_loc(stru
 static int ext2_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct buffer_head * bh;
+	struct fsblock_meta * mb;
 	struct ext2_sb_info * sbi;
 	struct ext2_super_block * es;
 	struct inode *root;
@@ -803,8 +813,10 @@ static int ext2_fill_super(struct super_
 	sbi->s_es = es;
 	sb->s_magic = le16_to_cpu(es->s_magic);
 
-	if (sb->s_magic != EXT2_SUPER_MAGIC)
+	if (sb->s_magic != EXT2_SUPER_MAGIC) {
+		printk("ext2 fill super wrong magic\n");
 		goto cantfind_ext2;
+	}
 
 	/* Set defaults before we parse the mount options */
 	def_mount_opts = le32_to_cpu(es->s_default_mount_opts);
@@ -881,7 +893,7 @@ static int ext2_fill_super(struct super_
 
 	/* If the blocksize doesn't match, re-read the thing.. */
 	if (sb->s_blocksize != blocksize) {
-		brelse(bh);
+		put_bh(bh);
 
 		if (!sb_set_blocksize(sb, blocksize)) {
 			printk(KERN_ERR "EXT2-fs: blocksize too small for device.\n");
@@ -904,6 +916,20 @@ static int ext2_fill_super(struct super_
 		}
 	}
 
+	ret = fsblock_register_super(sb, &sbi->fsb_sb);
+	if (ret)
+		goto failed_fsblock;
+
+	mb = sb_mbread(&sbi->fsb_sb, logic_sb_block);
+	if (!mb) {
+		printk("EXT2-fs: Could not read fsblock metadata block for superblock\n");
+		goto failed_fsblock;
+	}
+
+	put_bh(bh);
+	es = (struct ext2_super_block *) (((char *)mb->data) + offset);
+	sbi->s_es = es;
+
 	sb->s_maxbytes = ext2_max_size(sb->s_blocksize_bits);
 
 	if (le32_to_cpu(es->s_rev_level) == EXT2_GOOD_OLD_REV) {
@@ -940,7 +966,7 @@ static int ext2_fill_super(struct super_
 					sbi->s_inodes_per_block;
 	sbi->s_desc_per_block = sb->s_blocksize /
 					sizeof (struct ext2_group_desc);
-	sbi->s_sbh = bh;
+	sbi->s_smb = mb;
 	sbi->s_mount_state = le16_to_cpu(es->s_state);
 	sbi->s_addr_per_block_bits =
 		ilog2 (EXT2_ADDR_PER_BLOCK(sb));
@@ -950,7 +976,7 @@ static int ext2_fill_super(struct super_
 	if (sb->s_magic != EXT2_SUPER_MAGIC)
 		goto cantfind_ext2;
 
-	if (sb->s_blocksize != bh->b_size) {
+	if (sb->s_blocksize != fsblock_size(mb)) {
 		if (!silent)
 			printk ("VFS: Unsupported blocksize on dev "
 				"%s.\n", sb->s_id);
@@ -986,7 +1012,7 @@ static int ext2_fill_super(struct super_
  					/ EXT2_BLOCKS_PER_GROUP(sb)) + 1;
 	db_count = (sbi->s_groups_count + EXT2_DESC_PER_BLOCK(sb) - 1) /
 		   EXT2_DESC_PER_BLOCK(sb);
-	sbi->s_group_desc = kmalloc (db_count * sizeof (struct buffer_head *), GFP_KERNEL);
+	sbi->s_group_desc = kmalloc (db_count * sizeof (struct fsblock_meta *), GFP_KERNEL);
 	if (sbi->s_group_desc == NULL) {
 		printk ("EXT2-fs: not enough memory\n");
 		goto failed_mount;
@@ -999,10 +1025,10 @@ static int ext2_fill_super(struct super_
 	}
 	for (i = 0; i < db_count; i++) {
 		block = descriptor_loc(sb, logic_sb_block, i);
-		sbi->s_group_desc[i] = sb_bread(sb, block);
+		sbi->s_group_desc[i] = sb_mbread(&EXT2_SB(sb)->fsb_sb, block);
 		if (!sbi->s_group_desc[i]) {
 			for (j = 0; j < i; j++)
-				brelse (sbi->s_group_desc[j]);
+				block_put(sbi->s_group_desc[j]);
 			printk ("EXT2-fs: unable to read group descriptors\n");
 			goto failed_mount_group_desc;
 		}
@@ -1085,14 +1111,17 @@ failed_mount3:
 	percpu_counter_destroy(&sbi->s_dirs_counter);
 failed_mount2:
 	for (i = 0; i < db_count; i++)
-		brelse(sbi->s_group_desc[i]);
+		block_put(sbi->s_group_desc[i]);
 failed_mount_group_desc:
 	kfree(sbi->s_group_desc);
 	kfree(sbi->s_debts);
 failed_mount:
-	brelse(bh);
+	put_bh(bh);
 failed_sbi:
+	fsblock_unregister_super(sb, &sbi->fsb_sb);
 	sb->s_fs_info = NULL;
+failed_fsblock:
+	block_put(mb);
 	kfree(sbi);
 	return ret;
 }
@@ -1101,7 +1130,7 @@ static void ext2_commit_super (struct su
 			       struct ext2_super_block * es)
 {
 	es->s_wtime = cpu_to_le32(get_seconds());
-	mark_buffer_dirty(EXT2_SB(sb)->s_sbh);
+	mark_mblock_dirty(EXT2_SB(sb)->s_smb);
 	sb->s_dirt = 0;
 }
 
@@ -1110,8 +1139,8 @@ static void ext2_sync_super(struct super
 	es->s_free_blocks_count = cpu_to_le32(ext2_count_free_blocks(sb));
 	es->s_free_inodes_count = cpu_to_le32(ext2_count_free_inodes(sb));
 	es->s_wtime = cpu_to_le32(get_seconds());
-	mark_buffer_dirty(EXT2_SB(sb)->s_sbh);
-	sync_dirty_buffer(EXT2_SB(sb)->s_sbh);
+	mark_mblock_dirty(EXT2_SB(sb)->s_smb);
+	sync_block(EXT2_SB(sb)->s_smb);
 	sb->s_dirt = 0;
 }
 
@@ -1129,7 +1158,6 @@ static void ext2_sync_super(struct super
 void ext2_write_super (struct super_block * sb)
 {
 	struct ext2_super_block * es;
-	lock_kernel();
 	if (!(sb->s_flags & MS_RDONLY)) {
 		es = EXT2_SB(sb)->s_es;
 
@@ -1144,7 +1172,6 @@ void ext2_write_super (struct super_bloc
 			ext2_commit_super (sb, es);
 	}
 	sb->s_dirt = 0;
-	unlock_kernel();
 }
 
 static int ext2_remount (struct super_block * sb, int * flags, char * data)
@@ -1301,107 +1328,7 @@ static int ext2_get_sb(struct file_syste
 
 #ifdef CONFIG_QUOTA
 
-/* Read data from quotafile - avoid pagecache and such because we cannot afford
- * acquiring the locks... As quota files are never truncated and quota code
- * itself serializes the operations (and noone else should touch the files)
- * we don't have to be afraid of races */
-static ssize_t ext2_quota_read(struct super_block *sb, int type, char *data,
-			       size_t len, loff_t off)
-{
-	struct inode *inode = sb_dqopt(sb)->files[type];
-	sector_t blk = off >> EXT2_BLOCK_SIZE_BITS(sb);
-	int err = 0;
-	int offset = off & (sb->s_blocksize - 1);
-	int tocopy;
-	size_t toread;
-	struct buffer_head tmp_bh;
-	struct buffer_head *bh;
-	loff_t i_size = i_size_read(inode);
-
-	if (off > i_size)
-		return 0;
-	if (off+len > i_size)
-		len = i_size-off;
-	toread = len;
-	while (toread > 0) {
-		tocopy = sb->s_blocksize - offset < toread ?
-				sb->s_blocksize - offset : toread;
-
-		tmp_bh.b_state = 0;
-		err = ext2_get_block(inode, blk, &tmp_bh, 0);
-		if (err < 0)
-			return err;
-		if (!buffer_mapped(&tmp_bh))	/* A hole? */
-			memset(data, 0, tocopy);
-		else {
-			bh = sb_bread(sb, tmp_bh.b_blocknr);
-			if (!bh)
-				return -EIO;
-			memcpy(data, bh->b_data+offset, tocopy);
-			brelse(bh);
-		}
-		offset = 0;
-		toread -= tocopy;
-		data += tocopy;
-		blk++;
-	}
-	return len;
-}
-
-/* Write to quotafile */
-static ssize_t ext2_quota_write(struct super_block *sb, int type,
-				const char *data, size_t len, loff_t off)
-{
-	struct inode *inode = sb_dqopt(sb)->files[type];
-	sector_t blk = off >> EXT2_BLOCK_SIZE_BITS(sb);
-	int err = 0;
-	int offset = off & (sb->s_blocksize - 1);
-	int tocopy;
-	size_t towrite = len;
-	struct buffer_head tmp_bh;
-	struct buffer_head *bh;
-
-	mutex_lock_nested(&inode->i_mutex, I_MUTEX_QUOTA);
-	while (towrite > 0) {
-		tocopy = sb->s_blocksize - offset < towrite ?
-				sb->s_blocksize - offset : towrite;
-
-		tmp_bh.b_state = 0;
-		err = ext2_get_block(inode, blk, &tmp_bh, 1);
-		if (err < 0)
-			goto out;
-		if (offset || tocopy != EXT2_BLOCK_SIZE(sb))
-			bh = sb_bread(sb, tmp_bh.b_blocknr);
-		else
-			bh = sb_getblk(sb, tmp_bh.b_blocknr);
-		if (!bh) {
-			err = -EIO;
-			goto out;
-		}
-		lock_buffer(bh);
-		memcpy(bh->b_data+offset, data, tocopy);
-		flush_dcache_page(bh->b_page);
-		set_buffer_uptodate(bh);
-		mark_buffer_dirty(bh);
-		unlock_buffer(bh);
-		brelse(bh);
-		offset = 0;
-		towrite -= tocopy;
-		data += tocopy;
-		blk++;
-	}
-out:
-	if (len == towrite)
-		return err;
-	if (inode->i_size < off+len-towrite)
-		i_size_write(inode, off+len-towrite);
-	inode->i_version++;
-	inode->i_mtime = inode->i_ctime = CURRENT_TIME;
-	mark_inode_dirty(inode);
-	mutex_unlock(&inode->i_mutex);
-	return len - towrite;
-}
-
+#error "not yet supported"
 #endif
 
 static struct file_system_type ext2_fs_type = {
Index: linux-2.6/fs/ext2/xattr.c
===================================================================
--- linux-2.6.orig/fs/ext2/xattr.c
+++ linux-2.6/fs/ext2/xattr.c
@@ -53,7 +53,7 @@
  * to avoid deadlocks.
  */
 
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -64,9 +64,9 @@
 #include "xattr.h"
 #include "acl.h"
 
-#define HDR(bh) ((struct ext2_xattr_header *)((bh)->b_data))
+#define HDR(fsb) ((struct ext2_xattr_header *)((fsb)->data))
 #define ENTRY(ptr) ((struct ext2_xattr_entry *)(ptr))
-#define FIRST_ENTRY(bh) ENTRY(HDR(bh)+1)
+#define FIRST_ENTRY(fsb) ENTRY(HDR(fsb)+1)
 #define IS_LAST_ENTRY(entry) (*(__u32 *)(entry) == 0)
 
 #ifdef EXT2_XATTR_DEBUG
@@ -76,11 +76,11 @@
 		printk(f); \
 		printk("\n"); \
 	} while (0)
-# define ea_bdebug(bh, f...) do { \
+# define ea_bdebug(fsb, f...) do { \
 		char b[BDEVNAME_SIZE]; \
-		printk(KERN_DEBUG "block %s:%lu: ", \
-			bdevname(bh->b_bdev, b), \
-			(unsigned long) bh->b_blocknr); \
+		printk(KERN_DEBUG "block %s:%llu: ", \
+			bdevname(fsb->page->mapping->host->i_sb->sb_bdev, b), \
+			(unsigned long long) fsb->blocknr); \
 		printk(f); \
 		printk("\n"); \
 	} while (0)
@@ -89,11 +89,11 @@
 # define ea_bdebug(f...)
 #endif
 
-static int ext2_xattr_set2(struct inode *, struct buffer_head *,
+static int ext2_xattr_set2(struct inode *, struct fsblock *,
 			   struct ext2_xattr_header *);
 
-static int ext2_xattr_cache_insert(struct buffer_head *);
-static struct buffer_head *ext2_xattr_cache_find(struct inode *,
+static int ext2_xattr_cache_insert(struct fsblock *);
+static struct fsblock *ext2_xattr_cache_find(struct inode *,
 						 struct ext2_xattr_header *);
 static void ext2_xattr_rehash(struct ext2_xattr_header *,
 			      struct ext2_xattr_entry *);
@@ -149,7 +149,7 @@ int
 ext2_xattr_get(struct inode *inode, int name_index, const char *name,
 	       void *buffer, size_t buffer_size)
 {
-	struct buffer_head *bh = NULL;
+	struct fsblock *fsb = NULL;
 	struct ext2_xattr_entry *entry;
 	size_t name_len, size;
 	char *end;
@@ -165,15 +165,15 @@ ext2_xattr_get(struct inode *inode, int
 	if (!EXT2_I(inode)->i_file_acl)
 		goto cleanup;
 	ea_idebug(inode, "reading block %d", EXT2_I(inode)->i_file_acl);
-	bh = sb_bread(inode->i_sb, EXT2_I(inode)->i_file_acl);
+	fsb = sb_mbread(inode->i_sb, EXT2_I(inode)->i_file_acl);
 	error = -EIO;
-	if (!bh)
+	if (!fsb)
 		goto cleanup;
-	ea_bdebug(bh, "b_count=%d, refcount=%d",
-		atomic_read(&(bh->b_count)), le32_to_cpu(HDR(bh)->h_refcount));
-	end = bh->b_data + bh->b_size;
-	if (HDR(bh)->h_magic != cpu_to_le32(EXT2_XATTR_MAGIC) ||
-	    HDR(bh)->h_blocks != cpu_to_le32(1)) {
+	ea_bdebug(fsb, "count=%d, refcount=%d",
+		atomic_read(&(fsb->count)), le32_to_cpu(HDR(fsb)->h_refcount));
+	end = fsb->data + fsblock_size(fsb);
+	if (HDR(fsb)->h_magic != cpu_to_le32(EXT2_XATTR_MAGIC) ||
+	    HDR(fsb)->h_blocks != cpu_to_le32(1)) {
 bad_block:	ext2_error(inode->i_sb, "ext2_xattr_get",
 			"inode %ld: bad block %d", inode->i_ino,
 			EXT2_I(inode)->i_file_acl);
@@ -186,7 +186,7 @@ bad_block:	ext2_error(inode->i_sb, "ext2
 	error = -ERANGE;
 	if (name_len > 255)
 		goto cleanup;
-	entry = FIRST_ENTRY(bh);
+	entry = FIRST_ENTRY(fsb);
 	while (!IS_LAST_ENTRY(entry)) {
 		struct ext2_xattr_entry *next =
 			EXT2_XATTR_NEXT(entry);
@@ -206,7 +206,7 @@ bad_block:	ext2_error(inode->i_sb, "ext2
 			goto bad_block;
 		entry = next;
 	}
-	if (ext2_xattr_cache_insert(bh))
+	if (ext2_xattr_cache_insert(fsb))
 		ea_idebug(inode, "cache insert failed");
 	error = -ENODATA;
 	goto cleanup;
@@ -219,20 +219,20 @@ found:
 	    le16_to_cpu(entry->e_value_offs) + size > inode->i_sb->s_blocksize)
 		goto bad_block;
 
-	if (ext2_xattr_cache_insert(bh))
+	if (ext2_xattr_cache_insert(fsb))
 		ea_idebug(inode, "cache insert failed");
 	if (buffer) {
 		error = -ERANGE;
 		if (size > buffer_size)
 			goto cleanup;
 		/* return value of attribute */
-		memcpy(buffer, bh->b_data + le16_to_cpu(entry->e_value_offs),
+		memcpy(buffer, fsb->data + le16_to_cpu(entry->e_value_offs),
 			size);
 	}
 	error = size;
 
 cleanup:
-	brelse(bh);
+	mbrelse(fsb);
 	up_read(&EXT2_I(inode)->xattr_sem);
 
 	return error;
@@ -251,7 +251,7 @@ cleanup:
 static int
 ext2_xattr_list(struct inode *inode, char *buffer, size_t buffer_size)
 {
-	struct buffer_head *bh = NULL;
+	struct fsblock *fsb = NULL;
 	struct ext2_xattr_entry *entry;
 	char *end;
 	size_t rest = buffer_size;
@@ -265,15 +265,15 @@ ext2_xattr_list(struct inode *inode, cha
 	if (!EXT2_I(inode)->i_file_acl)
 		goto cleanup;
 	ea_idebug(inode, "reading block %d", EXT2_I(inode)->i_file_acl);
-	bh = sb_bread(inode->i_sb, EXT2_I(inode)->i_file_acl);
+	fsb = sb_mbread(inode->i_sb, EXT2_I(inode)->i_file_acl);
 	error = -EIO;
-	if (!bh)
+	if (!fsb)
 		goto cleanup;
-	ea_bdebug(bh, "b_count=%d, refcount=%d",
-		atomic_read(&(bh->b_count)), le32_to_cpu(HDR(bh)->h_refcount));
-	end = bh->b_data + bh->b_size;
-	if (HDR(bh)->h_magic != cpu_to_le32(EXT2_XATTR_MAGIC) ||
-	    HDR(bh)->h_blocks != cpu_to_le32(1)) {
+	ea_bdebug(fsb, "count=%d, refcount=%d",
+		atomic_read(&(fsb->count)), le32_to_cpu(HDR(bh)->h_refcount));
+	end = fsb->data + fsblock_size(fsb);
+	if (HDR(fsb)->h_magic != cpu_to_le32(EXT2_XATTR_MAGIC) ||
+	    HDR(fsb)->h_blocks != cpu_to_le32(1)) {
 bad_block:	ext2_error(inode->i_sb, "ext2_xattr_list",
 			"inode %ld: bad block %d", inode->i_ino,
 			EXT2_I(inode)->i_file_acl);
@@ -282,7 +282,7 @@ bad_block:	ext2_error(inode->i_sb, "ext2
 	}
 
 	/* check the on-disk data structure */
-	entry = FIRST_ENTRY(bh);
+	entry = FIRST_ENTRY(fsb);
 	while (!IS_LAST_ENTRY(entry)) {
 		struct ext2_xattr_entry *next = EXT2_XATTR_NEXT(entry);
 
@@ -290,11 +290,11 @@ bad_block:	ext2_error(inode->i_sb, "ext2
 			goto bad_block;
 		entry = next;
 	}
-	if (ext2_xattr_cache_insert(bh))
+	if (ext2_xattr_cache_insert(fsb))
 		ea_idebug(inode, "cache insert failed");
 
 	/* list the attribute names */
-	for (entry = FIRST_ENTRY(bh); !IS_LAST_ENTRY(entry);
+	for (entry = FIRST_ENTRY(fsb); !IS_LAST_ENTRY(entry);
 	     entry = EXT2_XATTR_NEXT(entry)) {
 		struct xattr_handler *handler =
 			ext2_xattr_handler(entry->e_name_index);
@@ -316,7 +316,7 @@ bad_block:	ext2_error(inode->i_sb, "ext2
 	error = buffer_size - rest;  /* total size */
 
 cleanup:
-	brelse(bh);
+	mbrelse(fsb);
 	up_read(&EXT2_I(inode)->xattr_sem);
 
 	return error;
@@ -344,7 +344,7 @@ static void ext2_xattr_update_super_bloc
 
 	EXT2_SET_COMPAT_FEATURE(sb, EXT2_FEATURE_COMPAT_EXT_ATTR);
 	sb->s_dirt = 1;
-	mark_buffer_dirty(EXT2_SB(sb)->s_sbh);
+	mark_mblock_dirty(EXT2_SB(sb)->s_smb);
 }
 
 /*
@@ -364,7 +364,7 @@ ext2_xattr_set(struct inode *inode, int
 	       const void *value, size_t value_len, int flags)
 {
 	struct super_block *sb = inode->i_sb;
-	struct buffer_head *bh = NULL;
+	struct fsblock *fsb = NULL;
 	struct ext2_xattr_header *header = NULL;
 	struct ext2_xattr_entry *here, *last;
 	size_t name_len, free, min_offs = sb->s_blocksize;
@@ -372,7 +372,7 @@ ext2_xattr_set(struct inode *inode, int
 	char *end;
 	
 	/*
-	 * header -- Points either into bh, or to a temporarily
+	 * header -- Points either into fsb, or to a temporarily
 	 *           allocated buffer.
 	 * here -- The named entry found, or the place for inserting, within
 	 *         the block pointed to by header.
@@ -396,15 +396,15 @@ ext2_xattr_set(struct inode *inode, int
 	down_write(&EXT2_I(inode)->xattr_sem);
 	if (EXT2_I(inode)->i_file_acl) {
 		/* The inode already has an extended attribute block. */
-		bh = sb_bread(sb, EXT2_I(inode)->i_file_acl);
+		fsb = sb_mbread(sb, EXT2_I(inode)->i_file_acl);
 		error = -EIO;
-		if (!bh)
+		if (!fsb)
 			goto cleanup;
-		ea_bdebug(bh, "b_count=%d, refcount=%d",
-			atomic_read(&(bh->b_count)),
-			le32_to_cpu(HDR(bh)->h_refcount));
-		header = HDR(bh);
-		end = bh->b_data + bh->b_size;
+		ea_bdebug(fsb, "count=%d, refcount=%d",
+			atomic_read(&(fsb->count)),
+			le32_to_cpu(HDR(fsb)->h_refcount));
+		header = HDR(fsb);
+		end = fsb->data + fsblock_size(fsb);
 		if (header->h_magic != cpu_to_le32(EXT2_XATTR_MAGIC) ||
 		    header->h_blocks != cpu_to_le32(1)) {
 bad_block:		ext2_error(sb, "ext2_xattr_set",
@@ -414,7 +414,7 @@ bad_block:		ext2_error(sb, "ext2_xattr_s
 			goto cleanup;
 		}
 		/* Find the named attribute. */
-		here = FIRST_ENTRY(bh);
+		here = FIRST_ENTRY(fsb);
 		while (!IS_LAST_ENTRY(here)) {
 			struct ext2_xattr_entry *next = EXT2_XATTR_NEXT(here);
 			if ((char *)next >= end)
@@ -488,12 +488,12 @@ bad_block:		ext2_error(sb, "ext2_xattr_s
 	if (header) {
 		struct mb_cache_entry *ce;
 
-		/* assert(header == HDR(bh)); */
-		ce = mb_cache_entry_get(ext2_xattr_cache, bh->b_bdev,
-					bh->b_blocknr);
-		lock_buffer(bh);
+		/* assert(header == HDR(fsb)); */
+		ce = mb_cache_entry_get(ext2_xattr_cache, fsb->b_bdev,
+					fsb->blocknr);
+		lock_block(fsb);
 		if (header->h_refcount == cpu_to_le32(1)) {
-			ea_bdebug(bh, "modifying in-place");
+			ea_bdebug(fsb, "modifying in-place");
 			if (ce)
 				mb_cache_entry_free(ce);
 			/* keep the buffer locked while modifying it. */
@@ -502,18 +502,18 @@ bad_block:		ext2_error(sb, "ext2_xattr_s
 
 			if (ce)
 				mb_cache_entry_release(ce);
-			unlock_buffer(bh);
-			ea_bdebug(bh, "cloning");
-			header = kmalloc(bh->b_size, GFP_KERNEL);
+			unlock_block(fsb);
+			ea_bdebug(fsb, "cloning");
+			header = kmalloc(fsb->b_size, GFP_KERNEL);
 			error = -ENOMEM;
 			if (header == NULL)
 				goto cleanup;
-			memcpy(header, HDR(bh), bh->b_size);
+			memcpy(header, HDR(fsb), fsb->b_size);
 			header->h_refcount = cpu_to_le32(1);
 
-			offset = (char *)here - bh->b_data;
+			offset = (char *)here - fsb->data;
 			here = ENTRY((char *)header + offset);
-			offset = (char *)last - bh->b_data;
+			offset = (char *)last - fsb->data;
 			last = ENTRY((char *)header + offset);
 		}
 	} else {
@@ -528,7 +528,7 @@ bad_block:		ext2_error(sb, "ext2_xattr_s
 		last = here = ENTRY(header+1);
 	}
 
-	/* Iff we are modifying the block in-place, bh is locked here. */
+	/* Iff we are modifying the block in-place, fsb is locked here. */
 
 	if (not_found) {
 		/* Insert the new name. */
@@ -600,19 +600,19 @@ bad_block:		ext2_error(sb, "ext2_xattr_s
 skip_replace:
 	if (IS_LAST_ENTRY(ENTRY(header+1))) {
 		/* This block is now empty. */
-		if (bh && header == HDR(bh))
-			unlock_buffer(bh);  /* we were modifying in-place. */
-		error = ext2_xattr_set2(inode, bh, NULL);
+		if (fsb && header == HDR(fsb))
+			unlock_buffer(fsb);  /* we were modifying in-place. */
+		error = ext2_xattr_set2(inode, fsb, NULL);
 	} else {
 		ext2_xattr_rehash(header, here);
-		if (bh && header == HDR(bh))
-			unlock_buffer(bh);  /* we were modifying in-place. */
-		error = ext2_xattr_set2(inode, bh, header);
+		if (fsb && header == HDR(fsb))
+			unlock_buffer(fsb);  /* we were modifying in-place. */
+		error = ext2_xattr_set2(inode, fsb, header);
 	}
 
 cleanup:
-	brelse(bh);
-	if (!(bh && header == HDR(bh)))
+	mbrelse(fsb);
+	if (!(fsb && header == HDR(fsb)))
 		kfree(header);
 	up_write(&EXT2_I(inode)->xattr_sem);
 
@@ -623,11 +623,11 @@ cleanup:
  * Second half of ext2_xattr_set(): Update the file system.
  */
 static int
-ext2_xattr_set2(struct inode *inode, struct buffer_head *old_bh,
+ext2_xattr_set2(struct inode *inode, struct fsblock *old_fsb,
 		struct ext2_xattr_header *header)
 {
 	struct super_block *sb = inode->i_sb;
-	struct buffer_head *new_bh = NULL;
+	struct fsblock *new_fsb = NULL;
 	int error;
 
 	if (header) {
@@ -754,7 +754,7 @@ cleanup:
 void
 ext2_xattr_delete_inode(struct inode *inode)
 {
-	struct buffer_head *bh = NULL;
+	struct fsblock *fsb = NULL;
 	struct mb_cache_entry *ce;
 
 	down_write(&EXT2_I(inode)->xattr_sem);
@@ -824,7 +824,7 @@ ext2_xattr_put_super(struct super_block
  * Returns 0, or a negative error number on failure.
  */
 static int
-ext2_xattr_cache_insert(struct buffer_head *bh)
+ext2_xattr_cache_insert(struct fsblock *fsb)
 {
 	__u32 hash = le32_to_cpu(HDR(bh)->h_hash);
 	struct mb_cache_entry *ce;
@@ -897,7 +897,7 @@ ext2_xattr_cmp(struct ext2_xattr_header
  * Returns a locked buffer head to the block found, or NULL if such
  * a block was not found or an error occurred.
  */
-static struct buffer_head *
+static struct fsblock *
 ext2_xattr_cache_find(struct inode *inode, struct ext2_xattr_header *header)
 {
 	__u32 hash = le32_to_cpu(header->h_hash);
@@ -910,7 +910,7 @@ again:
 	ce = mb_cache_entry_find_first(ext2_xattr_cache, 0,
 				       inode->i_sb->s_bdev, hash);
 	while (ce) {
-		struct buffer_head *bh;
+		struct fsblock *fsb;
 
 		if (IS_ERR(ce)) {
 			if (PTR_ERR(ce) == -EAGAIN)
Index: linux-2.6/fs/ext2/xip.c
===================================================================
--- linux-2.6.orig/fs/ext2/xip.c
+++ linux-2.6/fs/ext2/xip.c
@@ -8,7 +8,7 @@
 #include <linux/mm.h>
 #include <linux/fs.h>
 #include <linux/genhd.h>
-#include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/ext2_fs_sb.h>
 #include <linux/ext2_fs.h>
 #include <linux/blkdev.h>
@@ -33,16 +33,16 @@ static inline int
 __ext2_get_block(struct inode *inode, pgoff_t pgoff, int create,
 		   sector_t *result)
 {
-	struct buffer_head tmp;
+	struct fsblock tmp;
 	int rc;
 
-	memset(&tmp, 0, sizeof(struct buffer_head));
-	rc = ext2_get_block(inode, pgoff, &tmp, create);
-	*result = tmp.b_blocknr;
+	memset(&tmp, 0, sizeof(struct fsblock));
+	rc = ext2_map_block(inode, pgoff, &tmp, create);
+	*result = tmp.blocknr;
 
 	/* did we get a sparse block (hole in the file)? */
-	if (!tmp.b_blocknr && !rc) {
-		BUG_ON(create);
+	if (!tmp.blocknr && !rc) {
+		WARN_ON(create);
 		rc = -ENODATA;
 	}
 
Index: linux-2.6/include/linux/ext2_fs_sb.h
===================================================================
--- linux-2.6.orig/include/linux/ext2_fs_sb.h
+++ linux-2.6/include/linux/ext2_fs_sb.h
@@ -19,6 +19,7 @@
 #include <linux/blockgroup_lock.h>
 #include <linux/percpu_counter.h>
 #include <linux/rbtree.h>
+#include <linux/fsblock.h>
 
 /* XXX Here for now... not interested in restructing headers JUST now */
 
@@ -81,9 +82,9 @@ struct ext2_sb_info {
 	unsigned long s_groups_count;	/* Number of groups in the fs */
 	unsigned long s_overhead_last;  /* Last calculated overhead */
 	unsigned long s_blocks_last;    /* Last seen block count */
-	struct buffer_head * s_sbh;	/* Buffer containing the super block */
+	struct fsblock_meta * s_smb;	/* Buffer containing the super block */
 	struct ext2_super_block * s_es;	/* Pointer to the super block in the buffer */
-	struct buffer_head ** s_group_desc;
+	struct fsblock_meta ** s_group_desc;
 	unsigned long  s_mount_opt;
 	unsigned long s_sb_block;
 	uid_t s_resuid;
@@ -106,6 +107,7 @@ struct ext2_sb_info {
 	spinlock_t s_rsv_window_lock;
 	struct rb_root s_rsv_window_root;
 	struct ext2_reserve_window_node s_rsv_window_head;
+	struct fsblock_sb fsb_sb;
 };
 
 static inline spinlock_t *
Index: linux-2.6/fs/ext2/namei.c
===================================================================
--- linux-2.6.orig/fs/ext2/namei.c
+++ linux-2.6/fs/ext2/namei.c
@@ -98,9 +98,6 @@ static int ext2_create (struct inode * d
 		if (ext2_use_xip(inode->i_sb)) {
 			inode->i_mapping->a_ops = &ext2_aops_xip;
 			inode->i_fop = &ext2_xip_file_operations;
-		} else if (test_opt(inode->i_sb, NOBH)) {
-			inode->i_mapping->a_ops = &ext2_nobh_aops;
-			inode->i_fop = &ext2_file_operations;
 		} else {
 			inode->i_mapping->a_ops = &ext2_aops;
 			inode->i_fop = &ext2_file_operations;
@@ -151,10 +148,7 @@ static int ext2_symlink (struct inode *
 	if (l > sizeof (EXT2_I(inode)->i_data)) {
 		/* slow symlink */
 		inode->i_op = &ext2_symlink_inode_operations;
-		if (test_opt(inode->i_sb, NOBH))
-			inode->i_mapping->a_ops = &ext2_nobh_aops;
-		else
-			inode->i_mapping->a_ops = &ext2_aops;
+		inode->i_mapping->a_ops = &ext2_aops;
 		err = page_symlink(inode, symname, l);
 		if (err)
 			goto out_fail;
@@ -217,10 +211,7 @@ static int ext2_mkdir(struct inode * dir
 
 	inode->i_op = &ext2_dir_inode_operations;
 	inode->i_fop = &ext2_dir_operations;
-	if (test_opt(inode->i_sb, NOBH))
-		inode->i_mapping->a_ops = &ext2_nobh_aops;
-	else
-		inode->i_mapping->a_ops = &ext2_aops;
+	inode->i_mapping->a_ops = &ext2_aops;
 
 	inode_inc_link_count(inode);
 
Index: linux-2.6/fs/ext2/file.c
===================================================================
--- linux-2.6.orig/fs/ext2/file.c
+++ linux-2.6/fs/ext2/file.c
@@ -38,6 +38,18 @@ static int ext2_release_file (struct ino
 	return 0;
 }
 
+static struct vm_operations_struct ext2_file_vm_ops = {
+	.fault          = filemap_fault,
+	.page_mkwrite   = ext2_page_mkwrite,
+};
+
+static int ext2_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	file_accessed(file);
+	vma->vm_ops = &ext2_file_vm_ops;
+	return 0;
+}
+
 /*
  * We have mostly NULL's here: the current defaults are ok for
  * the ext2 filesystem.
@@ -52,7 +64,7 @@ const struct file_operations ext2_file_o
 #ifdef CONFIG_COMPAT
 	.compat_ioctl	= ext2_compat_ioctl,
 #endif
-	.mmap		= generic_file_mmap,
+	.mmap		= ext2_file_mmap,
 	.open		= generic_file_open,
 	.release	= ext2_release_file,
 	.fsync		= ext2_sync_file,
@@ -86,5 +98,5 @@ const struct inode_operations ext2_file_
 #endif
 	.setattr	= ext2_setattr,
 	.permission	= ext2_permission,
-	.fiemap		= ext2_fiemap,
+//	.fiemap		= ext2_fiemap,
 };
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
@@ -0,0 +1,439 @@
+#include <linux/fsb_extentmap.h>
+#include <linux/fsblock.h>
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
+int __fsb_ext_map_fsblock(struct address_space *mapping, loff_t off,
+			struct fsblock *fsblock, int mode,
+			struct fsb_ext_root *root, map_fsb_extent_fn mapfn)
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
+/* XXX: this is just to test... */
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
+	BUG_ON(size != 1);
+	BUG_ON(off >> mapping->host->i_blkbits != offset);
+
+	if (((fsblock->flags >> 8) & 0x3) != (flags & 0x3))
+		printk("fsblock->flags=%x flags=%x\n", fsblock->flags, flags);
+	if (!(fsblock->flags & BL_hole) && fsblock->block_nr != block)
+		printk("fsblock->block_nr=%llx block=%llx\n", (unsigned long long)fsblock->block_nr, (unsigned long long)block);
+
+	return ret;
+}
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
+
+int fsb_ext_release(struct address_space *mapping, struct fsb_ext_root *root)
+{
+	return fsb_ext_unmap_fsblock(mapping, 0, ~((loff_t)0), root);
+}
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1948,9 +1948,16 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_cache_get(old_page);
 			pte_unmap_unlock(page_table, ptl);
+			lock_page(old_page);
+			if (!old_page->mapping) {
+				ret = 0;
+				goto out_error;
+			}
 
-			if (vma->vm_ops->page_mkwrite(vma, old_page) < 0)
-				goto unwritable_page;
+			if (vma->vm_ops->page_mkwrite(vma, old_page) < 0) {
+				ret = VM_FAULT_SIGBUS;
+				goto out_error;
+			}
 
 			/*
 			 * Since we dropped the lock we need to revalidate
@@ -1960,9 +1967,11 @@ static int do_wp_page(struct mm_struct *
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
-			page_cache_release(old_page);
-			if (!pte_same(*page_table, orig_pte))
+			if (!pte_same(*page_table, orig_pte)) {
+				unlock_page(old_page);
+				page_cache_release(old_page);
 				goto unlock;
+			}
 
 			page_mkwrite = 1;
 		}
@@ -2085,19 +2094,28 @@ unlock:
 		 *
 		 * do_no_page is protected similarly.
 		 */
-		wait_on_page_locked(dirty_page);
 		set_page_dirty_balance(dirty_page, page_mkwrite);
 		put_page(dirty_page);
+		if (page_mkwrite) {
+			unlock_page(old_page);
+			page_cache_release(old_page);
+		}
 	}
 	return ret;
 oom_free_new:
 	page_cache_release(new_page);
 oom:
-	if (old_page)
+	if (old_page) {
+		if (page_mkwrite) {
+			unlock_page(old_page);
+			page_cache_release(old_page);
+		}
 		page_cache_release(old_page);
+	}
 	return VM_FAULT_OOM;
 
-unwritable_page:
+out_error:
+	unlock_page(old_page);
 	page_cache_release(old_page);
 	return VM_FAULT_SIGBUS;
 }
@@ -2643,23 +2661,9 @@ static int __do_fault(struct mm_struct *
 			 * to become writable
 			 */
 			if (vma->vm_ops->page_mkwrite) {
-				unlock_page(page);
 				if (vma->vm_ops->page_mkwrite(vma, page) < 0) {
 					ret = VM_FAULT_SIGBUS;
 					anon = 1; /* no anon but release vmf.page */
-					goto out_unlocked;
-				}
-				lock_page(page);
-				/*
-				 * XXX: this is not quite right (racy vs
-				 * invalidate) to unlock and relock the page
-				 * like this, however a better fix requires
-				 * reworking page_mkwrite locking API, which
-				 * is better done later.
-				 */
-				if (!page->mapping) {
-					ret = 0;
-					anon = 1; /* no anon but release vmf.page */
 					goto out;
 				}
 				page_mkwrite = 1;
@@ -2713,8 +2717,6 @@ static int __do_fault(struct mm_struct *
 	pte_unmap_unlock(page_table, ptl);
 
 out:
-	unlock_page(vmf.page);
-out_unlocked:
 	if (anon)
 		page_cache_release(vmf.page);
 	else if (dirty_page) {
@@ -2724,6 +2726,7 @@ out_unlocked:
 		set_page_dirty_balance(dirty_page, page_mkwrite);
 		put_page(dirty_page);
 	}
+	unlock_page(vmf.page);
 
 	return ret;
 }
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
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -837,6 +837,8 @@ int redirty_page_for_writepage(struct wr
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
+void clean_page_prepare(struct page *page);
+void clear_page_dirty(struct page *page);
 
 extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -486,7 +486,7 @@ static int writeout(struct address_space
 		/* No write method for the address space */
 		return -EINVAL;
 
-	if (!clear_page_dirty_for_io(page))
+	if (!PageDirty(page))
 		/* Someone else already triggered a write */
 		return -EAGAIN;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
