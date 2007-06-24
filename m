Date: Sun, 24 Jun 2007 03:46:13 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/3] add the fsblock layer
Message-ID: <20070624014613.GB17609@wotan.suse.de>
References: <20070624014528.GA17609@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070624014528.GA17609@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rewrite the buffer layer.

---
 fs/Makefile                   |    2 
 fs/buffer.c                   |   31 
 fs/fs-writeback.c             |   13 
 fs/fsblock.c                  | 2511 ++++++++++++++++++++++++++++++++++++++++++
 fs/inode.c                    |   37 
 fs/splice.c                   |    3 
 include/linux/buffer_head.h   |    1 
 include/linux/fsblock.h       |  347 +++++
 include/linux/fsblock_types.h |   70 +
 include/linux/page-flags.h    |   15 
 init/main.c                   |    2 
 mm/filemap.c                  |    7 
 mm/page_alloc.c               |    3 
 mm/swap.c                     |    7 
 mm/truncate.c                 |   93 -
 mm/vmscan.c                   |    6 
 16 files changed, 3077 insertions(+), 71 deletions(-)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -90,6 +90,8 @@
 #define PG_reclaim		17	/* To be reclaimed asap */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
+#define PG_blocks		20	/* Page has block mappings */
+
 /* PG_owner_priv_1 users should have descriptive aliases */
 #define PG_checked		PG_owner_priv_1 /* Used by some filesystems */
 
@@ -134,8 +136,17 @@ static inline void SetPageUptodate(struc
 	if (!test_and_set_bit(PG_uptodate, &page->flags))
 		page_clear_dirty(page);
 }
+static inline void TestSetPageUptodate(struct page *page)
+{
+	if (!test_and_set_bit(PG_uptodate, &page->flags)) {
+		page_clear_dirty(page);
+		return 0;
+	}
+	return 1;
+}
 #else
 #define SetPageUptodate(page)	set_bit(PG_uptodate, &(page)->flags)
+#define TestSetPageUptodate(page) test_and_set_bit(PG_uptodate, &(page)->flags)
 #endif
 #define ClearPageUptodate(page)	clear_bit(PG_uptodate, &(page)->flags)
 
@@ -217,6 +228,10 @@ static inline void SetPageUptodate(struc
 #define __SetPageBuddy(page)	__set_bit(PG_buddy, &(page)->flags)
 #define __ClearPageBuddy(page)	__clear_bit(PG_buddy, &(page)->flags)
 
+#define PageBlocks(page)	test_bit(PG_blocks, &(page)->flags)
+#define SetPageBlocks(page)	set_bit(PG_blocks, &(page)->flags)
+#define ClearPageBlocks(page)	clear_bit(PG_blocks, &(page)->flags)
+
 #define PageMappedToDisk(page)	test_bit(PG_mappedtodisk, &(page)->flags)
 #define SetPageMappedToDisk(page) set_bit(PG_mappedtodisk, &(page)->flags)
 #define ClearPageMappedToDisk(page) clear_bit(PG_mappedtodisk, &(page)->flags)
Index: linux-2.6/fs/Makefile
===================================================================
--- linux-2.6.orig/fs/Makefile
+++ linux-2.6/fs/Makefile
@@ -14,7 +14,7 @@ obj-y :=	open.o read_write.o file_table.
 		stack.o
 
 ifeq ($(CONFIG_BLOCK),y)
-obj-y +=	buffer.o bio.o block_dev.o direct-io.o mpage.o ioprio.o
+obj-y +=	fsblock.o buffer.o bio.o block_dev.o direct-io.o mpage.o ioprio.o
 else
 obj-y +=	no-block.o
 endif
Index: linux-2.6/fs/fsblock.c
===================================================================
--- /dev/null
+++ linux-2.6/fs/fsblock.c
@@ -0,0 +1,2511 @@
+/*
+ * fs/fsblock.c
+ *
+ * Copyright (C) 2007 Nick Piggin, SuSE Labs, Novell Inc.
+ */
+
+#include <linux/fsblock.h>
+#include <linux/bitops.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/bio.h>
+#include <linux/mm.h>
+#include <linux/gfp.h>
+#include <linux/bitops.h>
+#include <linux/pagevec.h>
+#include <linux/pagemap.h>
+#include <linux/page-flags.h>
+#include <linux/rcupdate.h> /* XXX: get rid of RCU */
+#include <linux/module.h>
+#include <linux/bit_spinlock.h> /* bit_spin_lock for subpage blocks */
+#include <linux/vmalloc.h> /* vmap for superpage blocks */
+#include <linux/gfp.h>
+//#include <linux/buffer_head.h> /* too much crap in me */
+extern int try_to_free_buffers(struct page *);
+
+/* XXX: add a page / block invariant checker function? */
+
+#include <asm/atomic.h>
+
+#define SECTOR_SHIFT	MIN_SECTOR_SHIFT
+#define NR_SUB_SIZES	(1 << (PAGE_CACHE_SHIFT - MIN_SECTOR_SHIFT))
+
+static struct kmem_cache *block_cache __read_mostly;
+static struct kmem_cache *mblock_cache __read_mostly;
+
+static void block_ctor(void *data, struct kmem_cache *cachep,
+			unsigned long flags)
+{
+	struct fsblock *block = data;
+	atomic_set(&block->count, 0);
+}
+
+void __init fsblock_init(void)
+{
+	block_cache = kmem_cache_create("fsblock-data",
+			sizeof(struct fsblock), 0,
+			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_DESTROY_BY_RCU,
+			block_ctor, NULL);
+
+	mblock_cache = kmem_cache_create("fsblock-metadata",
+			sizeof(struct fsblock_meta), 0,
+			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD|SLAB_DESTROY_BY_RCU,
+			block_ctor, NULL);
+}
+
+static void init_block(struct page *page, struct fsblock *block, unsigned int bits)
+{
+	block->flags = 0;
+	block->block_nr = -1;
+	block->page = page;
+	block->private = NULL;
+	FSB_BUG_ON(atomic_read(&block->count));
+	atomic_inc(&block->count);
+	__set_bit(BL_locked, &block->flags);
+	fsblock_set_bits(block, bits);
+#ifdef FSB_DEBUG
+	atomic_set(&block->vmap_count, 0);
+#endif
+}
+
+static void init_mblock(struct page *page, struct fsblock_meta *mblock, unsigned int bits)
+{
+	init_block(page, &mblock->block, bits);
+	__set_bit(BL_metadata, &mblock->block.flags);
+	INIT_LIST_HEAD(&mblock->assoc_list);
+	mblock->assoc_mapping = NULL;
+}
+
+static struct fsblock *alloc_blocks(struct page *page, unsigned int bits, gfp_t gfp_flags)
+{
+	struct fsblock *block;
+	int nid = page_to_nid(page);
+
+	if (bits >= PAGE_CACHE_SHIFT) { /* !subpage */
+		block = kmem_cache_alloc_node(block_cache, gfp_flags, nid);
+		if (likely(block))
+			init_block(page, block, bits);
+	} else {
+		int nr = PAGE_CACHE_SIZE >> bits;
+		/* XXX: could have a range of cache sizes */
+		block = kmalloc_node(sizeof(struct fsblock)*nr, gfp_flags, nid);
+		if (likely(block)) {
+			int i;
+			for (i = 0; i < nr; i++) {
+				struct fsblock *b = block + i;
+				atomic_set(&b->count, 0);
+				init_block(page, b, bits);
+			}
+		}
+	}
+	return block;
+}
+
+static struct fsblock_meta *alloc_mblocks(struct page *page, unsigned int bits, gfp_t gfp_flags)
+{
+	struct fsblock_meta *mblock;
+	int nid = page_to_nid(page);
+
+	if (bits >= PAGE_CACHE_SHIFT) { /* !subpage */
+		mblock = kmem_cache_alloc_node(mblock_cache, gfp_flags, nid);
+		if (likely(mblock))
+			init_mblock(page, mblock, bits);
+	} else {
+		int nr = PAGE_CACHE_SIZE >> bits;
+		mblock = kmalloc_node(sizeof(struct fsblock_meta)*nr, gfp_flags, nid);
+		if (likely(mblock)) {
+			int i;
+			for (i = 0; i < nr; i++) {
+				struct fsblock_meta *mb = mblock + i;
+				atomic_set(&mb->block.count, 0);
+				init_mblock(page, mb, bits);
+			}
+		}
+	}
+	return mblock;
+}
+
+#ifdef FSB_DEBUG
+static void assert_block(struct fsblock *block)
+{
+	struct page *page = block->page;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(!PageBlocks(page));
+
+	if (fsblock_superpage(block)) {
+		struct page *p;
+
+		FSB_BUG_ON(page->index != first_page_idx(page->index,
+							fsblock_size(block)));
+
+		for_each_page(page, fsblock_size(block), p) {
+			FSB_BUG_ON(!PageBlocks(p));
+			FSB_BUG_ON(page_blocks(p) != block);
+		} end_for_each_page;
+	} else if (fsblock_subpage(block)) {
+		struct fsblock *b;
+		block = page_blocks(block->page);
+
+		for_each_block(block, b)
+			FSB_BUG_ON(b->page != page);
+	}
+}
+
+static void free_block_check(struct fsblock *block)
+{
+	unsigned long flags = block->flags;
+	unsigned long badflags =
+			(1 << BL_locked	|
+			 1 << BL_dirty	|
+			 /* 1 << BL_error	| */
+			 1 << BL_new	|
+			 1 << BL_writeback |
+			 1 << BL_readin	|
+			 1 << BL_sync_io);
+	unsigned long goodflags = 0;
+	unsigned int size = fsblock_size(block);
+	unsigned int count = atomic_read(&block->count);
+	unsigned int vmap_count = atomic_read(&block->vmap_count);
+	void *private = block->private;
+
+	if ((flags & badflags) || ((flags & goodflags) != goodflags) || count || private || vmap_count) {
+		printk("block flags = %lx\n", flags);
+		printk("block size  = %u\n", size);
+		printk("block count = %u\n", count);
+		printk("block private = %p\n", private);
+		printk("vmap count  = %u\n", vmap_count);
+		BUG();
+	}
+}
+#else
+static inline void assert_block(struct fsblock *block) {}
+#endif
+
+static void rcu_free_block(struct rcu_head *head)
+{
+	struct fsblock *block = container_of(head, struct fsblock, rcu_head);
+	kfree(block);
+}
+
+static void free_block(struct fsblock *block)
+{
+	if (fsblock_subpage(block)) {
+#ifdef FSB_DEBUG
+		unsigned int bits = fsblock_bits(block);
+		int i, nr = PAGE_CACHE_SIZE >> bits;
+
+		for (i = 0; i < nr; i++) {
+			struct fsblock *b;
+			if (test_bit(BL_metadata, &block->flags))
+				b = &(block_mblock(block) + i)->block;
+			else
+				b = block + i;
+			free_block_check(b);
+		}
+#endif
+
+		INIT_RCU_HEAD(&block->rcu_head);
+		call_rcu(&block->rcu_head, rcu_free_block);
+	} else {
+#ifdef VMAP_CACHE
+		if (test_bit(BL_vmapped, &block->flags)) {
+			vunmap(block->vaddr);
+			block->vaddr = NULL;
+			clear_bit(BL_vmapped, &block->flags);
+		}
+#endif
+#ifdef FSB_DEBUG
+		free_block_check(block);
+#endif
+		if (test_bit(BL_metadata, &block->flags))
+			kmem_cache_free(mblock_cache, block);
+		else
+			kmem_cache_free(block_cache, block);
+	}
+}
+
+int block_get_unless_zero(struct fsblock *block)
+{
+	return atomic_inc_not_zero(&block->count);
+}
+
+void block_get(struct fsblock *block)
+{
+	FSB_BUG_ON(atomic_read(&block->count) == 0);
+	atomic_inc(&block->count);
+}
+EXPORT_SYMBOL(block_get);
+
+static int fsblock_noblock = 1 __read_mostly; /* Like nobh mode */
+
+void block_put(struct fsblock *block)
+{
+	int free_it;
+	struct page *page;
+
+	page = block->page;
+	free_it = 0;
+	if (!page->mapping || fsblock_noblock) {
+		free_it = 1;
+		page_cache_get(page);
+	}
+
+#ifdef FSB_DEBUG
+	FSB_BUG_ON(atomic_read(&block->count) == 2 &&
+			atomic_read(&block->vmap_count));
+#endif
+	FSB_BUG_ON(atomic_read(&block->count) <= 1);
+
+	/* dec_return required for the release memory barrier */
+	if (atomic_dec_return(&block->count) == 1) {
+		if (free_it && !test_bit(BL_dirty, &block->flags)) {
+			/*
+			 * At this point we'd like to try stripping the block
+			 * if it is only existing in a self-referential
+			 * relationship with the pagecache (ie. the pagecache
+			 * is truncated as well).
+			 */
+			if (!TestSetPageLocked(page)) {
+				try_to_free_blocks(page);
+				unlock_page(page);
+			}
+		}
+	}
+	if (free_it)
+		page_cache_release(page);
+}
+EXPORT_SYMBOL(block_put);
+
+static int sleep_on_block(void *unused)
+{
+	io_schedule();
+	return 0;
+}
+
+void lock_block(struct fsblock *block)
+{
+	might_sleep();
+
+	if (!trylock_block(block))
+		wait_on_bit_lock(&block->flags, BL_locked, sleep_on_block,
+							TASK_UNINTERRUPTIBLE);
+}
+EXPORT_SYMBOL(lock_block);
+
+void unlock_block(struct fsblock *block)
+{
+	FSB_BUG_ON(!test_bit(BL_locked, &block->flags));
+	smp_mb__before_clear_bit();
+	clear_bit(BL_locked, &block->flags);
+	smp_mb__after_clear_bit();
+	wake_up_bit(&block->flags, BL_locked);
+}
+EXPORT_SYMBOL(unlock_block);
+
+void wait_on_block_locked(struct fsblock *block)
+{
+	might_sleep();
+
+	if (test_bit(BL_locked, &block->flags))
+		wait_on_bit(&block->flags, BL_locked, sleep_on_block,
+							TASK_UNINTERRUPTIBLE);
+}
+EXPORT_SYMBOL(wait_on_block_locked);
+
+static void set_block_sync_io(struct fsblock *block)
+{
+	FSB_BUG_ON(!PageLocked(block->page));
+	FSB_BUG_ON(test_bit(BL_sync_io, &block->flags));
+#ifdef FSB_DEBUG
+	if (fsblock_superpage(block)) {
+		struct page *page = block->page, *p;
+		for_each_page(page, fsblock_size(block), p) {
+			FSB_BUG_ON(!PageLocked(p));
+			FSB_BUG_ON(PageWriteback(p));
+		} end_for_each_page;
+	} else {
+		FSB_BUG_ON(!PageLocked(block->page));
+		FSB_BUG_ON(PageWriteback(block->page));
+	}
+#endif
+	set_bit(BL_sync_io, &block->flags);
+}
+
+static void end_block_sync_io(struct fsblock *block)
+{
+	FSB_BUG_ON(!PageLocked(block->page));
+	FSB_BUG_ON(!test_bit(BL_sync_io, &block->flags));
+	clear_bit(BL_sync_io, &block->flags);
+	smp_mb__after_clear_bit();
+	wake_up_bit(&block->flags, BL_sync_io);
+}
+
+static void wait_on_block_sync_io(struct fsblock *block)
+{
+	might_sleep();
+
+	FSB_BUG_ON(!PageLocked(block->page));
+	if (test_bit(BL_sync_io, &block->flags))
+		wait_on_bit(&block->flags, BL_sync_io, sleep_on_block,
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
+	might_sleep();
+
+	page = block->page;
+	if (!fsblock_superpage(block)) {
+		set_page_writeback(page);
+		unlock_page(page);
+	} else {
+		for_each_page(page, fsblock_size(block), p) {
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
+static struct fsblock *find_get_page_block(struct page *page)
+{
+	struct fsblock *block;
+
+	rcu_read_lock();
+again:
+	block = page_blocks_rcu(page);
+	if (block) {
+		/*
+		 * Might be better off implementing this as a bit spinlock
+		 * rather than count (which requires tricks with ordering
+		 * eg. release vs set page dirty).
+		 */
+		if (block_get_unless_zero(block)) {
+			if ((page_blocks_rcu(page) != block)) {
+				block_put(block);
+				block = NULL;
+			}
+		} else {
+			cpu_relax();
+			goto again;
+		}
+	}
+	rcu_read_unlock();
+
+	return block;
+}
+
+static int __set_page_dirty_noblocks(struct page *page)
+{
+	FSB_BUG_ON(!PageBlocks(page));
+	FSB_BUG_ON(!fsblock_subpage(page_blocks(page)) && !PageUptodate(page));
+
+	return __set_page_dirty_nobuffers(page);
+}
+
+int fsblock_set_page_dirty(struct page *page)
+{
+	struct fsblock *block;
+	int ret = 0;
+
+	FSB_BUG_ON(!PageUptodate(page));
+	FSB_BUG_ON(!PageBlocks(page));
+//	FSB_BUG_ON(!PageLocked(page)); /* XXX: this can go away when we pin a page's metadata */
+
+	block = page_blocks(page);
+	if (fsblock_subpage(block)) {
+		struct fsblock *b;
+
+		for_each_block(block, b) {
+			FSB_BUG_ON(!test_bit(BL_uptodate, &b->flags));
+			if (!test_bit(BL_dirty, &b->flags)) {
+				set_bit(BL_dirty, &b->flags);
+				ret = 1;
+			}
+		}
+	} else {
+		FSB_BUG_ON(!test_bit(BL_uptodate, &block->flags));
+		if (!test_bit(BL_dirty, &block->flags)) {
+			set_bit(BL_dirty, &block->flags);
+			ret = 1;
+		}
+	}
+	/*
+	 * XXX: this is slightly racy because the above blocks could be
+	 * cleaned in a writeback that's underway, while the page will
+	 * still get marked dirty below. This technically breaks some
+	 * invariants that we check for (that a dirty page must have at
+	 * least 1 dirty buffer). Eventually we could just relax those
+	 * invariants, but keep them in for now to catch bugs.
+	 */
+	return __set_page_dirty_noblocks(page);
+}
+EXPORT_SYMBOL(fsblock_set_page_dirty);
+
+/*
+ * Do we need a fast atomic version for just page sized / aligned maps?
+ */
+void *vmap_block(struct fsblock *block, off_t off, size_t len)
+{
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
+		atomic_inc(&block->vmap_count);
+#endif
+		return kmap(block->page) + page_offset + off;
+	} else {
+		pgoff_t pgoff, start, end;
+		unsigned long pos;
+
+#ifdef VMAP_CACHE
+		if (test_bit(BL_vmapped, &block->flags)) {
+			while (test_bit(BL_vmap_lock, &block->flags))
+				cpu_relax();
+			smp_rmb();
+#ifdef FSB_DEBUG
+			atomic_inc(&block->vmap_count);
+#endif
+			return block->vaddr + off;
+		}
+#endif
+
+		pgoff = block->page->index;
+		FSB_BUG_ON(test_bit(BL_metadata, &block->flags) &&
+			pgoff != block->block_nr * (size >> PAGE_CACHE_SHIFT));
+		start = pgoff + (off >> PAGE_CACHE_SHIFT);
+		end = pgoff + ((off + len - 1) >> PAGE_CACHE_SHIFT);
+		pos = off & ~PAGE_CACHE_MASK;
+
+#ifndef VMAP_CACHE
+		if (start == end) {
+			struct page *page;
+
+			page = find_page(mapping, start);
+			FSB_BUG_ON(!page);
+
+#ifdef FSB_DEBUG
+			atomic_inc(&block->vmap_count);
+#endif
+			return kmap(page) + pos;
+		} else
+#endif
+		{
+			int nr;
+			struct page **pages;
+			void *addr;
+#ifndef VMAP_CACHE
+			nr = end - start + 1;
+#else
+			nr = size >> PAGE_CACHE_SHIFT;
+#endif
+			pages = kmalloc(nr * sizeof(struct page *), GFP_NOFS);
+			if (!pages)
+				return ERR_PTR(-ENOMEM);
+#ifndef VMAP_CACHE
+			find_pages(mapping, start, nr, pages);
+#else
+			find_pages(mapping, pgoff, nr, pages);
+#endif
+
+			addr = vmap(pages, nr, VM_MAP, PAGE_KERNEL);
+			kfree(pages);
+			if (!addr)
+				return ERR_PTR(-ENOMEM);
+
+#ifdef FSB_DEBUG
+			atomic_inc(&block->vmap_count);
+#endif
+#ifndef VMAP_CACHE
+			return addr + pos;
+#else
+			bit_spin_lock(BL_vmap_lock, &block->flags);
+			if (!test_bit(BL_vmapped, &block->flags)) {
+				block->vaddr = addr;
+				set_bit(BL_vmapped, &block->flags);
+			}
+			bit_spin_unlock(BL_vmap_lock, &block->flags);
+			if (block->vaddr != addr)
+				vunmap(addr);
+			return block->vaddr + off;
+#endif
+		}
+	}
+}
+EXPORT_SYMBOL(vmap_block);
+
+void vunmap_block(struct fsblock *block, off_t off, size_t len, void *vaddr)
+{
+#ifdef FSB_DEBUG
+	FSB_BUG_ON(atomic_read(&block->vmap_count) <= 0);
+	atomic_dec(&block->vmap_count);
+#endif
+	if (!fsblock_superpage(block))
+		kunmap(block->page);
+#ifndef VMAP_CACHE
+	else {
+		unsigned int size = fsblock_size(block);
+		pgoff_t pgoff, start, end;
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
+			FSB_BUG_ON(!page);
+
+			kunmap(page);
+		} else {
+			unsigned long pos;
+
+			pos = off & ~PAGE_CACHE_MASK;
+			vunmap(vaddr - pos);
+		}
+	}
+#endif
+}
+EXPORT_SYMBOL(vunmap_block);
+
+static struct fsblock *__find_get_block(struct address_space *mapping, sector_t blocknr)
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
+		block = find_get_page_block(page);
+		if (block) {
+			if (fsblock_subpage(block)) {
+				struct fsblock *b;
+				for_each_block(block, b) {
+					if (b->block_nr == blocknr) {
+						block_get(b);
+						block_put(block);
+						block = b;
+						goto found;
+					}
+				}
+				FSB_BUG();
+			} else
+				FSB_BUG_ON(block->block_nr != blocknr);
+found:
+			FSB_BUG_ON(!test_bit(BL_mapped, &block->flags));
+		}
+
+		page_cache_release(page);
+		return block;
+	}
+	return NULL;
+}
+
+struct fsblock_meta *find_get_mblock(struct block_device *bdev, sector_t blocknr, unsigned int size)
+{
+	struct fsblock *block;
+
+	block = __find_get_block(bdev->bd_inode->i_mapping, blocknr);
+	if (block) {
+		if (test_bit(BL_metadata, &block->flags)) {
+			/*
+			 * XXX: need a better way than 'size' to tag and
+			 * identify metadata fsblocks?
+			 */
+			if (fsblock_size(block) == size)
+				return block_mblock(block);
+		}
+
+		block_put(block);
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(find_get_mblock);
+
+static void attach_block_page(struct page *page, struct fsblock *block)
+{
+	if (PageUptodate(page))
+		set_bit(BL_uptodate, &block->flags);
+	unlock_block(block); /* XXX: need this? */
+}
+
+/* This goes away when we get rid of buffer.c */
+static int invalidate_aliasing_buffers(struct page *page, unsigned int size)
+{
+	if (!size_is_superpage(size)) {
+		if (PagePrivate(page))
+			return try_to_free_buffers(page);
+	} else {
+		struct page *p;
+
+		for_each_page(page, size, p) {
+			FSB_BUG_ON(!PageLocked(p));
+			FSB_BUG_ON(PageBlocks(p));
+
+			if (PagePrivate(p)) {
+				if (!try_to_free_buffers(p))
+					return 0;
+			}
+		} end_for_each_page;
+	}
+	return 1;
+}
+
+static int __try_to_free_blocks(struct page *page, int all_locked);
+static int invalidate_aliasing_blocks(struct page *page, unsigned int size)
+{
+	if (!size_is_superpage(size)) {
+		if (PageBlocks(page)) {
+			/* could check for compatible blocks here, but meh */
+			return __try_to_free_blocks(page, 1);
+		}
+	} else {
+		struct page *p;
+
+		for_each_page(page, size, p) {
+			FSB_BUG_ON(!PageLocked(p));
+			FSB_BUG_ON(PageBlocks(p));
+
+			if (PageBlocks(p)) {
+				if (!__try_to_free_blocks(p, 1))
+					return 0;
+			}
+		} end_for_each_page;
+	}
+	return 1;
+}
+
+#define CREATE_METADATA	0x01
+#define CREATE_DIRTY	0x02
+static int create_unmapped_blocks(struct page *page, gfp_t gfp_flags, unsigned int size, unsigned int flags)
+{
+	unsigned int bits = ffs(size) - 1;
+	struct fsblock *block;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(PageDirty(page));
+	FSB_BUG_ON(PageWriteback(page));
+	FSB_BUG_ON(PageBlocks(page));
+	FSB_BUG_ON(flags & CREATE_DIRTY);
+
+	if (!invalidate_aliasing_buffers(page, size))
+		return -EBUSY;
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
+		attach_page_blocks(page, block);
+		/*
+		 * Ensure ordering between setting page->block ptr and reading
+		 * PageDirty, thus giving synchronisation between this and
+		 * fsblock_set_page_dirty()
+		 */
+		smp_mb();
+		if (fsblock_subpage(block)) {
+			struct fsblock *b;
+			for_each_block(block, b)
+				attach_block_page(page, b);
+		} else
+			attach_block_page(page, block);
+	} else {
+		struct page *p;
+		int uptodate = 1;
+		FSB_BUG_ON(page->index != first_page_idx(page->index, size));
+
+		for_each_page(page, size, p) {
+			FSB_BUG_ON(!PageLocked(p));
+			FSB_BUG_ON(PageDirty(p));
+			FSB_BUG_ON(PageWriteback(p));
+			FSB_BUG_ON(PageBlocks(p));
+			attach_page_blocks(p, block);
+		} end_for_each_page;
+		smp_mb();
+		for_each_page(page, size, p) {
+			if (!PageUptodate(p))
+				uptodate = 0;
+		} end_for_each_page;
+		if (uptodate)
+			set_bit(BL_uptodate, &block->flags);
+		unlock_block(block);
+	}
+
+	assert_block(block);
+
+	return 0;
+}
+
+static struct page *create_lock_page_range(struct address_space *mapping,
+					pgoff_t pgoff, unsigned int size)
+{
+	struct page *page;
+	gfp_t gfp;
+
+	gfp = mapping_gfp_mask(mapping) & ~__GFP_FS;
+	page = find_or_create_page(mapping, pgoff, gfp);
+	if (!page)
+		return NULL;
+
+	FSB_BUG_ON(!page->mapping);
+	page_cache_release(page);
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
+					FSB_BUG_ON(!p);
+					unlock_page(p);
+				}
+				return NULL;
+			}
+			FSB_BUG_ON(!p->mapping);
+			page_cache_release(p);
+			/*
+			 * don't want a ref hanging around (see end io handlers
+			 * for pagecache). Page lock pins the pcache ref.
+			 * XXX: this is a little unclean.
+			 */
+		}
+	}
+	FSB_BUG_ON(page->index != pgoff);
+	return page;
+}
+
+static void unlock_page_range(struct page *page, unsigned int size)
+{
+	if (!size_is_superpage(size))
+		unlock_page(page);
+	else {
+		struct page *p;
+
+		FSB_BUG_ON(page->index != first_page_idx(page->index, size));
+		for_each_page(page, size, p) {
+			FSB_BUG_ON(!p);
+			unlock_page(p);
+		} end_for_each_page;
+	}
+}
+
+struct fsblock_meta *find_or_create_mblock(struct block_device *bdev, sector_t blocknr, unsigned int size)
+{
+	struct inode *bd_inode = bdev->bd_inode;
+	struct address_space *bd_mapping = bd_inode->i_mapping;
+	struct page *page;
+	struct fsblock_meta *mblock;
+	pgoff_t pgoff;
+	int ret;
+
+	pgoff = sector_pgoff(blocknr, bd_inode->i_blkbits);
+
+	mblock = find_get_mblock(bdev, blocknr, size);
+	if (mblock)
+		return mblock;
+
+	page = create_lock_page_range(bd_mapping, pgoff, size);
+	if (!page)
+		return ERR_PTR(-ENOMEM);
+
+	if (!invalidate_aliasing_blocks(page, size)) {
+		mblock = ERR_PTR(-EBUSY);
+		goto failed;
+	}
+	ret = create_unmapped_blocks(page, GFP_NOFS, size, CREATE_METADATA);
+	if (ret) {
+		mblock = ERR_PTR(ret);
+		goto failed;
+	}
+
+	mblock = page_mblocks(page);
+	/*
+	 * XXX: technically this is just the block_dev.c direct
+	 * mapping. So maybe logically in that file? (OTOH it *is*
+	 * "metadata")
+	 */
+	if (fsblock_subpage(&mblock->block)) {
+		struct fsblock_meta *ret = NULL, *mb;
+		sector_t base_block;
+		base_block = pgoff << (PAGE_CACHE_SHIFT - bd_inode->i_blkbits);
+		__for_each_mblock(mblock, size, mb) {
+			mb->block.block_nr = base_block;
+			set_bit(BL_mapped, &mb->block.flags);
+			if (mb->block.block_nr == blocknr) {
+				FSB_BUG_ON(ret);
+				ret = mb;
+			}
+			base_block++;
+		}
+		FSB_BUG_ON(!ret);
+		mblock = ret;
+	} else {
+		mblock->block.block_nr = blocknr;
+		set_bit(BL_mapped, &mblock->block.flags);
+	}
+	mblock_get(mblock);
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
+
+	FSB_BUG_ON(test_bit(BL_uptodate, &block->flags));
+	FSB_BUG_ON(test_bit(BL_error, &block->flags));
+
+	sync_io = test_bit(BL_sync_io, &block->flags);
+
+	if (unlikely(!uptodate)) {
+		set_bit(BL_error, &block->flags);
+		if (!fsblock_superpage(block))
+			SetPageError(page);
+		else {
+			struct page *p;
+			for_each_page(page, fsblock_size(block), p) {
+				SetPageError(p);
+			} end_for_each_page;
+		}
+	} else
+		set_bit(BL_uptodate, &block->flags);
+
+	if (fsblock_subpage(block)) {
+		unsigned long flags;
+		struct fsblock *b, *first = page_blocks(block->page);
+
+		local_irq_save(flags);
+		bit_spin_lock(BL_rd_lock, &first->flags);
+		clear_bit(BL_readin, &block->flags);
+		for_each_block(page_blocks(page), b) {
+			if (test_bit(BL_readin, &b->flags)) {
+				finished_readin = 0;
+				break;
+			}
+			if (!test_bit(BL_uptodate, &b->flags))
+				uptodate = 0;
+		}
+		bit_spin_unlock(BL_rd_lock, &first->flags);
+		local_irq_restore(flags);
+	} else
+		clear_bit(BL_readin, &block->flags);
+
+	if (sync_io)
+		finished_readin = 0; /* don't unlock */
+	if (!fsblock_superpage(block)) {
+		FSB_BUG_ON(PageWriteback(page));
+		if (uptodate)
+			SetPageUptodate(page);
+		if (finished_readin)
+			unlock_page(page);
+		/*
+		 * XXX: don't know whether or not to keep the page
+		 * refcount elevated or simply rely on the page lock...
+		 */
+	} else {
+		struct page *p;
+
+		for_each_page(page, fsblock_size(block), p) {
+			FSB_BUG_ON(PageDirty(p));
+			FSB_BUG_ON(PageWriteback(p));
+			if (uptodate)
+				SetPageUptodate(p);
+			if (finished_readin)
+				unlock_page(p);
+		} end_for_each_page;
+	}
+
+	if (sync_io)
+		end_block_sync_io(block);
+
+	block_put(block);
+}
+
+static void block_end_write(struct fsblock *block, int uptodate)
+{
+	int sync_io;
+	int finished_writeback = 1;
+	struct page *page = block->page;
+
+	FSB_BUG_ON(!test_bit(BL_uptodate, &block->flags));
+	FSB_BUG_ON(test_bit(BL_error, &block->flags));
+
+	sync_io = test_bit(BL_sync_io, &block->flags);
+
+	if (unlikely(!uptodate)) {
+		set_bit(BL_error, &block->flags);
+		if (!fsblock_superpage(block))
+			SetPageError(page);
+		else {
+			struct page *p;
+			for_each_page(page, fsblock_size(block), p) {
+				SetPageError(p);
+			} end_for_each_page;
+		}
+		set_bit(AS_EIO, &page->mapping->flags);
+	}
+
+	if (fsblock_subpage(block)) {
+		unsigned long flags;
+		struct fsblock *b, *first = page_blocks(block->page);
+
+		local_irq_save(flags);
+		bit_spin_lock(BL_wb_lock, &first->flags);
+		clear_bit(BL_writeback, &block->flags);
+		for_each_block(first, b) {
+			if (test_bit(BL_writeback, &b->flags)) {
+				finished_writeback = 0;
+				break;
+			}
+		}
+		bit_spin_unlock(BL_wb_lock, &first->flags);
+		local_irq_restore(flags);
+	} else
+		clear_bit(BL_writeback, &block->flags);
+
+	if (!sync_io) {
+		if (finished_writeback) {
+			if (!fsblock_superpage(block)) {
+				end_page_writeback(page);
+			} else {
+				struct page *p;
+				for_each_page(page, fsblock_size(block), p) {
+					FSB_BUG_ON(!p->mapping);
+					end_page_writeback(p);
+				} end_for_each_page;
+			}
+		}
+	} else
+		end_block_sync_io(block);
+
+	block_put(block);
+}
+
+int fsblock_strip = 1;
+
+static int block_end_bio_io(struct bio *bio, unsigned int bytes_done, int err)
+{
+	struct fsblock *block = bio->bi_private;
+	int uptodate;
+
+	if (bio->bi_size)
+		return 1;
+
+	uptodate = test_bit(BIO_UPTODATE, &bio->bi_flags);
+
+	if (err == -EOPNOTSUPP) {
+		printk(KERN_WARNING "block_end_bio_io: op not supported!\n");
+		WARN_ON(uptodate);
+	}
+
+	FSB_BUG_ON(!(test_bit(BL_readin, &block->flags) ^
+		test_bit(BL_writeback, &block->flags)));
+
+	if (test_bit(BL_readin, &block->flags))
+		block_end_read(block, uptodate);
+	else
+		block_end_write(block, uptodate);
+
+	bio_put(bio);
+
+	return 0;
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
+#if 0
+	printk("submit_block for %s [blocknr=%lu, sector=%lu, size=%u]\n",
+		(test_bit(BL_readin, &block->flags) ? "read" : "write"),
+		(unsigned long)block->block_nr,
+		(unsigned long)block->block_nr * (size >> SECTOR_SHIFT), size);
+#endif
+
+	FSB_BUG_ON(!PageLocked(page) && !PageWriteback(page));
+	FSB_BUG_ON(!mapping);
+	FSB_BUG_ON(!test_bit(BL_mapped, &block->flags));
+
+	clear_bit(BL_error, &block->flags);
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
+	block_get(block);
+	bio_get(bio);
+	submit_bio(rw, bio);
+
+	if (bio_flagged(bio, BIO_EOPNOTSUPP))
+		ret = -EOPNOTSUPP;
+
+	bio_put(bio);
+	return ret;
+}
+
+static int read_block(struct fsblock *block)
+{
+	FSB_BUG_ON(PageWriteback(block->page));
+	FSB_BUG_ON(test_bit(BL_readin, &block->flags));
+	FSB_BUG_ON(test_bit(BL_writeback, &block->flags));
+	FSB_BUG_ON(test_bit(BL_dirty, &block->flags));
+	set_bit(BL_readin, &block->flags);
+	return submit_block(block, READ);
+}
+
+static int write_block(struct fsblock *block)
+{
+	FSB_BUG_ON(!PageWriteback(block->page));
+	FSB_BUG_ON(test_bit(BL_readin, &block->flags));
+	FSB_BUG_ON(test_bit(BL_writeback, &block->flags));
+	FSB_BUG_ON(!test_bit(BL_uptodate, &block->flags));
+	set_bit(BL_writeback, &block->flags);
+	return submit_block(block, WRITE);
+}
+
+int sync_block(struct fsblock *block)
+{
+	int ret = 0;
+
+	if (test_bit(BL_dirty, &block->flags)) {
+		struct page *page = block->page;
+
+		iolock_block(block);
+		wait_on_block_writeback(block);
+		FSB_BUG_ON(PageWriteback(page)); /* because block is locked */
+		if (test_bit(BL_dirty, &block->flags)) {
+			FSB_BUG_ON(!test_bit(BL_uptodate, &block->flags));
+			clear_bit(BL_dirty, &block->flags);
+
+			if (fsblock_subpage(block)) {
+				struct fsblock *b;
+				for_each_block(page_blocks(page), b) {
+					if (test_bit(BL_dirty, &b->flags))
+						goto page_dirty;
+				}
+			}
+			if (!fsblock_superpage(block)) {
+				ret = clear_page_dirty_for_io(page);
+				FSB_BUG_ON(!ret);
+			} else {
+				struct page *p;
+				for_each_page(page, fsblock_size(block), p) {
+					clear_page_dirty_for_io(p);
+				} end_for_each_page;
+			}
+page_dirty:
+			set_block_writeback(block);
+
+			ret = write_block(block);
+			if (!ret) {
+				wait_on_block_writeback(block);
+				if (test_bit(BL_error, &block->flags))
+					ret = -EIO;
+			}
+		} else
+			iounlock_block(block);
+	}
+	return ret;
+}
+EXPORT_SYMBOL(sync_block);
+
+void mark_mblock_uptodate(struct fsblock_meta *mblock)
+{
+	struct fsblock *block = mblock_block(mblock);
+	struct page *page = block->page;
+
+	if (fsblock_superpage(block)) {
+		struct page *p;
+		for_each_page(page, fsblock_size(block), p) {
+			SetPageUptodate(p);
+		} end_for_each_page;
+	} else if (fsblock_midpage(block)) {
+		SetPageUptodate(page);
+	} /* XXX: could check for all subblocks uptodate */
+	set_bit(BL_uptodate, &block->flags);
+}
+
+int mark_mblock_dirty(struct fsblock_meta *mblock)
+{
+	struct page *page;
+	FSB_BUG_ON(!fsblock_superpage(&mblock->block) &&
+		!test_bit(BL_uptodate, &mblock->block.flags));
+
+	if (test_and_set_bit(BL_dirty, &mblock->block.flags))
+		return 0;
+
+	page = mblock_block(mblock)->page;
+	if (!fsblock_superpage(mblock_block(mblock))) {
+		__set_page_dirty_noblocks(page);
+	} else {
+		struct page *p;
+		for_each_page(page, fsblock_size(mblock_block(mblock)), p) {
+			__set_page_dirty_noblocks(p);
+		} end_for_each_page;
+	}
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
+};
+
+int mark_mblock_dirty_inode(struct fsblock_meta *mblock, struct inode *inode)
+{
+	struct address_space *mapping = inode->i_mapping;
+	struct fsblock *block = mblock_block(mblock);
+	struct mb_assoc *mba;
+	int ret;
+
+	ret = mark_mblock_dirty(mblock);
+
+	bit_spin_lock(BL_assoc_lock, &block->flags);
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
+		bit_spin_unlock(BL_assoc_lock, &block->flags);
+		sync_block(block);
+		return ret;
+	}
+	INIT_LIST_HEAD(&mba->mlist);
+	mba->mapping = mapping;
+	INIT_LIST_HEAD(&mba->blist);
+	mba->mblock = mblock;
+	if (block->private)
+		list_add(&mba->blist, ((struct mb_assoc *)block->private)->blist.prev);
+	block->private = mba;
+	spin_lock(&mapping->private_lock);
+	list_add_tail(&mba->mlist, &mapping->private_list);
+	spin_unlock(&mapping->private_lock);
+
+out:
+	bit_spin_unlock(BL_assoc_lock, &block->flags);
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
+		bit_spin_lock(BL_assoc_lock, &block->flags);
+		if (list_empty(&mba->blist))
+			block->private = NULL;
+		else {
+			if (block->private == mba)
+				block->private = list_entry(mba->blist.next,struct mb_assoc,blist);
+			list_del(&mba->blist);
+		}
+		bit_spin_unlock(BL_assoc_lock, &block->flags);
+
+		iolock_block(block);
+		wait_on_block_writeback(block);
+		if (test_bit(BL_dirty, &block->flags)) {
+			FSB_BUG_ON(!test_bit(BL_uptodate, &block->flags));
+			clear_bit(BL_dirty, &block->flags);
+			ret = write_block(block);
+			if (ret && !err)
+				err = ret;
+		} else
+			iounlock_block(block);
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
+		wait_on_block_writeback(block);
+		if (test_bit(BL_error, &block->flags)) {
+			if (!err)
+				err = -EIO;
+			set_bit(AS_EIO, &mba->mapping->flags);
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
+			if (test_bit(BL_dirty, &block->flags)) {
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
+
+		mba = list_entry(list.prev, struct mb_assoc, mlist);
+		list_del(&mba->mlist);
+
+		block = mblock_block(mba->mblock);
+		bit_spin_lock(BL_assoc_lock, &block->flags);
+		if (list_empty(&mba->blist))
+			block->private = NULL;
+		else {
+			if (block->private == mba)
+				block->private = list_entry(mba->blist.next,struct mb_assoc,blist);
+			list_del(&mba->blist);
+		}
+		bit_spin_unlock(BL_assoc_lock, &block->flags);
+
+		if (test_bit(BL_error, &block->flags))
+			set_bit(AS_EIO, &mba->mapping->flags);
+		kfree(mba);
+	}
+	return 1;
+}
+EXPORT_SYMBOL(fsblock_release);
+
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
+	meta_block = __find_get_block(bdev->bd_inode->i_mapping, blocknr);
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
+		else {
+			clear_bit(BL_dirty, &meta_block->flags);
+			wait_on_block_iolock(meta_block);
+		}
+	}
+}
+
+struct fsblock_meta *mbread(struct block_device *bdev, sector_t blocknr, unsigned int size)
+{
+	struct fsblock_meta *mblock;
+
+	mblock = find_or_create_mblock(bdev, blocknr, size);
+	if (!IS_ERR(mblock)) {
+		struct fsblock *block = &mblock->block;
+
+		if (!test_bit(BL_uptodate, &block->flags)) {
+			iolock_block(block);
+			if (!test_bit(BL_uptodate, &block->flags)) {
+				int ret;
+				FSB_BUG_ON(PageWriteback(block->page));
+				FSB_BUG_ON(test_bit(BL_dirty, &block->flags));
+				set_block_sync_io(block);
+				ret = read_block(block);
+				if (ret) {
+					/* XXX: handle errors properly */
+					block_put(block);
+					mblock = ERR_PTR(ret);
+				} else {
+					wait_on_block_sync_io(block);
+					if (!test_bit(BL_uptodate, &block->flags))
+						mblock = ERR_PTR(-EIO);
+					FSB_BUG_ON(size >= PAGE_CACHE_SIZE && !PageUptodate(block->page));
+				}
+			}
+			iounlock_block(block);
+		}
+	}
+
+	return mblock;
+}
+EXPORT_SYMBOL(mbread);
+
+/*
+ * XXX: maybe either don't have a generic version, or change the
+ * insert_mapping scheme so that it fills fsblocks rather than inserts them
+ * live into pages?
+ */
+sector_t fsblock_bmap(struct address_space *mapping, sector_t blocknr, insert_mapping_fn *insert_mapping)
+{
+	struct fsblock *block;
+	struct inode *inode = mapping->host;
+	sector_t ret;
+
+	block = __find_get_block(mapping, blocknr);
+	if (!block) {
+		pgoff_t pgoff = sector_pgoff(blocknr, inode->i_blkbits);
+		unsigned int size = 1 << inode->i_blkbits;
+		struct page *page;
+
+		page = create_lock_page_range(mapping, pgoff, size);
+		if (!page)
+			return 0;
+
+		if (create_unmapped_blocks(page, GFP_NOFS, size, CREATE_METADATA))
+			return 0;
+
+		ret = insert_mapping(mapping, pgoff, PAGE_CACHE_SIZE, 0);
+
+		block = __find_get_block(mapping, blocknr);
+		FSB_BUG_ON(!block);
+
+		unlock_page_range(page, size);
+	}
+
+	FSB_BUG_ON(test_bit(BL_new, &block->flags));
+	ret = 0;
+	if (test_bit(BL_mapped, &block->flags))
+		ret = block->block_nr;
+
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_bmap);
+
+static int relock_superpage_block(struct page **pagep, unsigned int size)
+{
+	struct page *page = *pagep;
+	pgoff_t index = page->index;
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
+	if (page != find_page(mapping, index)) {
+		unlock_page_range(*pagep, size);
+		return AOP_TRUNCATED_PAGE;
+	}
+	return 0;
+}
+
+static int block_read_helper(struct page *page, struct fsblock *block)
+{
+	FSB_BUG_ON(test_bit(BL_new, &block->flags));
+
+	if (test_bit(BL_uptodate, &block->flags))
+		return 0;
+
+	FSB_BUG_ON(PageUptodate(page));
+
+	if (!test_bit(BL_mapped, &block->flags)) {
+		unsigned int size = fsblock_size(block);
+		unsigned int offset = block_page_offset(block, size);
+		zero_user_page(page, offset, size, KM_USER0);
+		set_bit(BL_uptodate, &block->flags);
+		return 0;
+	}
+
+	if (!test_bit(BL_uptodate, &block->flags)) {
+		FSB_BUG_ON(test_bit(BL_readin, &block->flags));
+		FSB_BUG_ON(test_bit(BL_writeback, &block->flags));
+		set_bit(BL_readin, &block->flags);
+		return 1;
+	}
+	return 0;
+}
+
+int fsblock_read_page(struct page *page, insert_mapping_fn *insert_mapping)
+{
+	struct address_space *mapping = page->mapping;
+	struct inode *inode = mapping->host;
+	unsigned int size = 1 << inode->i_blkbits;
+	struct fsblock *block;
+	int ret;
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
+	}
+
+	if (!PageBlocks(page)) {
+		ret = create_unmapped_blocks(page, GFP_NOFS, size, 0);
+		if (ret)
+			goto out_unlock;
+	}
+
+	/* XXX: optimise away if page is mapped to disk */
+	ret = insert_mapping(mapping, page->index << PAGE_CACHE_SHIFT,
+						PAGE_CACHE_SIZE, 0);
+	/* XXX: SetPageError on failure? */
+	if (ret)
+		goto out_unlock;
+
+	block = page_blocks(page);
+
+	if (!fsblock_superpage(block)) {
+
+		if (fsblock_subpage(block)) {
+			int nr = 0;
+			struct fsblock *b;
+			for_each_block(block, b)
+				nr += block_read_helper(page, b);
+			if (nr == 0) {
+				/* Hole? */
+				SetPageUptodate(page);
+				goto out_unlock;
+			}
+			for_each_block(block, b) {
+				if (!test_bit(BL_readin, &b->flags))
+					continue;
+
+				ret = submit_block(b, READ);
+				if (ret)
+					goto out_unlock;
+				/*
+				 * XXX: must handle errors properly (eg. wait
+				 * for outstanding reads before unlocking the
+				 * page?
+				 */
+			}
+		} else {
+			if (block_read_helper(page, block)) {
+				ret = submit_block(block, READ);
+				if (ret)
+					goto out_unlock;
+			} else {
+				SetPageUptodate(page);
+				goto out_unlock;
+			}
+		}
+	} else {
+		struct page *p;
+
+		ret = 0;
+
+		FSB_BUG_ON(test_bit(BL_new, &block->flags));
+		FSB_BUG_ON(test_bit(BL_uptodate, &block->flags));
+		FSB_BUG_ON(test_bit(BL_dirty, &block->flags));
+
+		if (!test_bit(BL_mapped, &block->flags)) {
+			for_each_page(page, size, p) {
+				FSB_BUG_ON(PageUptodate(p));
+				zero_user_page(p, 0, PAGE_CACHE_SIZE, KM_USER0);
+				SetPageUptodate(p);
+				unlock_page(p);
+			} end_for_each_page;
+			set_bit(BL_uptodate, &block->flags);
+		} else {
+			ret = read_block(block);
+			if (ret)
+				goto out_unlock;
+		}
+	}
+	FSB_BUG_ON(ret);
+	return 0;
+
+out_unlock:
+	unlock_page_range(page, size);
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_read_page);
+
+static int block_write_helper(struct page *page, struct fsblock *block)
+{
+	FSB_BUG_ON(!test_bit(BL_mapped, &block->flags));
+
+	if (test_bit(BL_new, &block->flags)) {
+		sync_underlying_metadata(block);
+		clear_bit(BL_new, &block->flags);
+		set_bit(BL_dirty, &block->flags);
+	}
+
+	if (test_bit(BL_dirty, &block->flags)) {
+		FSB_BUG_ON(!test_bit(BL_uptodate, &block->flags));
+		clear_bit(BL_dirty, &block->flags);
+		FSB_BUG_ON(test_bit(BL_readin, &block->flags));
+		FSB_BUG_ON(test_bit(BL_writeback, &block->flags));
+		set_bit(BL_writeback, &block->flags);
+		return 1;
+		/*
+		 * XXX: Careful of ordering between clear buffer / page dirty
+		 * and set buffer / page dirty
+		 */
+	}
+	return 0;
+}
+
+/* XXX: must obey non-blocking writeout! */
+int fsblock_write_page(struct page *page, insert_mapping_fn *insert_mapping,
+				struct writeback_control *wbc)
+{
+	struct address_space *mapping = page->mapping;
+	unsigned int size = 1 << mapping->host->i_blkbits;
+	struct fsblock *block;
+	int ret;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(PageWriteback(page));
+
+	if (size_is_superpage(size)) {
+		struct page *orig_page = page;
+
+		redirty_page_for_writepage(wbc, orig_page);
+		ret = relock_superpage_block(&page, size);
+		if (ret)
+			return ret;
+		if (!clear_page_dirty_for_io(orig_page))
+			goto out_unlock;
+	}
+
+	if (!PageBlocks(page)) {
+		FSB_BUG(); /* XXX: should always have blocks here */
+		FSB_BUG_ON(!PageUptodate(page));
+		/* XXX: should rework (eg use page_mkwrite) so as to always
+		 * have blocks by this stage!!! */
+		ret = create_unmapped_blocks(page, GFP_NOFS, size, CREATE_DIRTY);
+		if (ret)
+			goto out_unlock;
+	}
+
+	ret = insert_mapping(mapping, page->index << PAGE_CACHE_SHIFT,
+						PAGE_CACHE_SIZE, 1);
+	if (ret)
+		goto out_unlock;
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
+	block = page_blocks(page);
+
+	if (!fsblock_superpage(block)) {
+
+		if (fsblock_subpage(block)) {
+			int nr = 0;
+			struct fsblock *b;
+			for_each_block(block, b)
+				nr += block_write_helper(page, b);
+			/* XXX: technically could happen (see set_page_dirty_blocks) */
+			FSB_BUG_ON(nr == 0);
+			if (nr == 0)
+				goto out_unlock;
+
+			FSB_BUG_ON(PageWriteback(page));
+			set_page_writeback(page);
+			unlock_page(page);
+			for_each_block(block, b) {
+				if (!test_bit(BL_writeback, &b->flags))
+					continue;
+				ret = submit_block(b, WRITE);
+				if (ret)
+					goto out_unlock;
+				/* XXX: error handling */
+			}
+		} else {
+			if (block_write_helper(page, block)) {
+				FSB_BUG_ON(PageWriteback(page));
+				set_page_writeback(page);
+				unlock_page(page);
+				ret = submit_block(block, WRITE);
+				if (ret)
+					goto out_unlock;
+			} else {
+				FSB_BUG(); /* XXX: see above */
+				goto out_unlock;
+			}
+		}
+	} else {
+		struct page *p;
+
+		FSB_BUG_ON(!test_bit(BL_mapped, &block->flags));
+		FSB_BUG_ON(!test_bit(BL_uptodate, &block->flags));
+		FSB_BUG_ON(!test_bit(BL_dirty, &block->flags));
+		FSB_BUG_ON(test_bit(BL_new, &block->flags));
+
+		for_each_page(page, size, p) {
+			FSB_BUG_ON(page_blocks(p) != block);
+			FSB_BUG_ON(!PageUptodate(p));
+		} end_for_each_page;
+
+		for_each_page(page, size, p) {
+			clear_page_dirty_for_io(p);
+			FSB_BUG_ON(PageWriteback(p));
+			FSB_BUG_ON(!PageUptodate(p));
+			set_page_writeback(p);
+			unlock_page(p);
+		} end_for_each_page;
+
+		/* XXX: recheck ordering here! don't want to lose dirty bits */
+
+		clear_bit(BL_dirty, &block->flags);
+		ret = write_block(block);
+		if (ret)
+			goto out_unlock;
+	}
+	FSB_BUG_ON(ret);
+	return 0;
+
+out_unlock:
+	unlock_page_range(page, size);
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_write_page);
+
+static int block_dirty_helper(struct page *page, struct fsblock *block)
+{
+	FSB_BUG_ON(!test_bit(BL_mapped, &block->flags));
+
+	if (test_bit(BL_uptodate, &block->flags))
+		return 0;
+
+	FSB_BUG_ON(PageUptodate(page));
+
+	if (test_bit(BL_new, &block->flags)) {
+		unsigned int size = fsblock_size(block);
+		unsigned int offset = block_page_offset(block, size);
+		zero_user_page(page, offset, size, KM_USER0);
+		set_bit(BL_uptodate, &block->flags);
+		sync_underlying_metadata(block);
+		clear_bit(BL_new, &block->flags);
+		set_bit(BL_dirty, &block->flags);
+		__set_page_dirty_noblocks(page);
+		return 0;
+	}
+	return 1;
+}
+
+static int fsblock_prepare_write_super(struct page *orig_page,
+				unsigned int size, unsigned from, unsigned to,
+				insert_mapping_fn *insert_mapping)
+{
+	struct address_space *mapping = orig_page->mapping;
+	struct fsblock *block;
+	struct page *page = orig_page, *p;
+	int ret;
+
+	ret = relock_superpage_block(&page, size);
+	if (ret)
+		return ret;
+
+	FSB_BUG_ON(PageBlocks(page) != PageBlocks(orig_page));
+	if (!PageBlocks(page)) {
+		FSB_BUG_ON(PageDirty(orig_page));
+		FSB_BUG_ON(PageDirty(page));
+		ret = create_unmapped_blocks(page, GFP_NOFS, size, 0);
+		if (ret)
+			goto out_unlock;
+	}
+	FSB_BUG_ON(!PageBlocks(page));
+
+	ret = insert_mapping(mapping, page->index << PAGE_CACHE_SHIFT,
+						PAGE_CACHE_SIZE, 1);
+	if (ret)
+		goto out_unlock;
+
+	block = page_blocks(page);
+
+	if (test_bit(BL_new, &block->flags)) {
+		for_each_page(page, size, p) {
+			if (!PageUptodate(p)) {
+				FSB_BUG_ON(PageDirty(p));
+				zero_user_page(p, 0, PAGE_CACHE_SIZE, KM_USER0);
+				SetPageUptodate(p);
+			}
+			__set_page_dirty_noblocks(p);
+		} end_for_each_page;
+
+		set_bit(BL_uptodate, &block->flags);
+		sync_underlying_metadata(block);
+		clear_bit(BL_new, &block->flags);
+		set_bit(BL_dirty, &block->flags);
+	} else if (!test_bit(BL_uptodate, &block->flags)) {
+		FSB_BUG_ON(test_bit(BL_dirty, &block->flags));
+
+		set_block_sync_io(block);
+		ret = read_block(block);
+		if (ret)
+			goto out_unlock;
+		wait_on_block_sync_io(block);
+		if (!test_bit(BL_uptodate, &block->flags)) {
+			ret = -EIO;
+			goto out_unlock;
+		}
+	}
+
+	return 0;
+
+out_unlock:
+	unlock_page_range(page, size);
+	lock_page(orig_page);
+	FSB_BUG_ON(!ret);
+	return ret;
+}
+
+int fsblock_prepare_write(struct page *page, unsigned from, unsigned to,
+					insert_mapping_fn *insert_mapping)
+{
+	struct address_space *mapping = page->mapping;
+	unsigned int size = 1 << mapping->host->i_blkbits;
+	struct fsblock *block;
+	int ret, nr;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(from > PAGE_CACHE_SIZE);
+	FSB_BUG_ON(to > PAGE_CACHE_SIZE);
+	FSB_BUG_ON(from > to);
+
+	if (size_is_superpage(size))
+		return fsblock_prepare_write_super(page, size, from, to, insert_mapping);
+
+	if (!PageBlocks(page)) {
+		ret = create_unmapped_blocks(page, GFP_NOFS, size, 0);
+		if (ret)
+			return ret;
+	}
+
+	ret = insert_mapping(mapping, page->index << PAGE_CACHE_SHIFT,
+						PAGE_CACHE_SIZE, 1);
+	if (ret)
+		return ret;
+
+	block = page_blocks(page);
+
+	nr = 0;
+	if (fsblock_subpage(block)) {
+		struct fsblock *b;
+		for_each_block(block, b)
+			nr += block_dirty_helper(page, b);
+	} else
+		nr += block_dirty_helper(page, block);
+	if (nr == 0)
+		SetPageUptodate(page);
+
+	if (PageUptodate(page))
+		return 0;
+
+	if (to - from == PAGE_CACHE_SIZE)
+		return 0;
+
+	/*
+	 * XXX: this is stupid, could do better with write_begin aops, or
+	 * just zero out unwritten partial blocks.
+	 */
+	if (fsblock_subpage(block)) {
+		struct fsblock *b;
+		for_each_block(block, b) {
+			if (test_bit(BL_uptodate, &b->flags))
+				continue;
+			set_block_sync_io(b);
+			ret = read_block(b);
+			if (ret)
+				break;
+		}
+
+		for_each_block(block, b) {
+			wait_on_block_sync_io(b);
+			if (!ret && !test_bit(BL_uptodate, &b->flags))
+				ret = -EIO;
+		}
+		if (ret)
+			return ret;
+	} else {
+
+		FSB_BUG_ON(test_bit(BL_uptodate, &block->flags));
+		set_block_sync_io(block);
+		ret = read_block(block);
+		if (ret)
+			return ret;
+		wait_on_block_sync_io(block);
+		if (test_bit(BL_error, &block->flags))
+			SetPageError(page);
+		if (!test_bit(BL_uptodate, &block->flags))
+			return -EIO;
+	}
+	SetPageUptodate(page);
+
+	return 0;
+}
+EXPORT_SYMBOL(fsblock_prepare_write);
+
+static int __fsblock_commit_write_super(struct page *orig_page,
+			struct fsblock *block, unsigned from, unsigned to)
+{
+	unsigned int size = fsblock_size(block);
+	struct page *page, *p;
+
+	FSB_BUG_ON(!test_bit(BL_uptodate, &block->flags));
+	set_bit(BL_dirty, &block->flags);
+	page = block->page;
+	for_each_page(page, size, p) {
+		FSB_BUG_ON(!PageUptodate(p));
+		__set_page_dirty_noblocks(p);
+	} end_for_each_page;
+	unlock_page_range(page, size);
+	lock_page(orig_page);
+
+	return 0;
+}
+
+static int __fsblock_commit_write_sub(struct page *page,
+			struct fsblock *block, unsigned from, unsigned to)
+{
+	struct fsblock *b;
+
+	for_each_block(block, b) {
+		if (to - from < PAGE_CACHE_SIZE)
+			FSB_BUG_ON(!test_bit(BL_uptodate, &b->flags));
+		else
+			set_bit(BL_uptodate, &block->flags);
+		if (!test_bit(BL_dirty, &b->flags))
+			set_bit(BL_dirty, &b->flags);
+	}
+	if (to - from < PAGE_CACHE_SIZE)
+		FSB_BUG_ON(!PageUptodate(page));
+	else
+		SetPageUptodate(page);
+	__set_page_dirty_noblocks(page);
+
+	return 0;
+}
+
+int __fsblock_commit_write(struct page *page, unsigned from, unsigned to)
+{
+	struct fsblock *block;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(from > PAGE_CACHE_SIZE);
+	FSB_BUG_ON(to > PAGE_CACHE_SIZE);
+	FSB_BUG_ON(from > to);
+	FSB_BUG_ON(!PageBlocks(page));
+
+	block = page_blocks(page);
+	FSB_BUG_ON(!test_bit(BL_mapped, &block->flags));
+
+	if (fsblock_superpage(block))
+		return __fsblock_commit_write_super(page, block, from, to);
+	if (fsblock_subpage(block))
+		return __fsblock_commit_write_sub(page, block, from, to);
+
+	if (to - from < PAGE_CACHE_SIZE) {
+		FSB_BUG_ON(!PageUptodate(page));
+		FSB_BUG_ON(!test_bit(BL_uptodate, &block->flags));
+	} else {
+		set_bit(BL_uptodate, &block->flags);
+		SetPageUptodate(page);
+	}
+
+	if (!test_bit(BL_dirty, &block->flags))
+		set_bit(BL_dirty, &block->flags);
+	__set_page_dirty_noblocks(page);
+
+	return 0;
+}
+EXPORT_SYMBOL(__fsblock_commit_write);
+
+int fsblock_commit_write(struct file *file, struct page *page, unsigned from, unsigned to)
+{
+	struct inode *inode;
+	loff_t pos = ((loff_t)page->index << PAGE_CACHE_SHIFT) + to;
+	int ret;
+
+	inode = page->mapping->host;
+	ret = __fsblock_commit_write(page, from, to);
+
+	/*
+	 * No need to use i_size_read() here, the i_size
+	 * cannot change under us because we hold i_mutex.
+	 */
+	if (!ret && pos > inode->i_size) {
+		i_size_write(inode, pos);
+		mark_inode_dirty(inode);
+	}
+        return ret;
+
+}
+EXPORT_SYMBOL(fsblock_commit_write);
+
+/* XXX: this is racy I think (must verify versus page_mkclean). Must have
+ * some operation to pin a page's metadata while dirtying it. (this will
+ * fix get_user_pages for dirty as well once callers are converted).
+ */
+int fsblock_page_mkwrite(struct vm_area_struct *vma, struct page *page)
+{
+	struct address_space *mapping;
+	const struct address_space_operations *a_ops;
+	int ret = 0;
+
+	lock_page(page);
+	mapping = page->mapping;
+	if (!mapping) {
+		/* Caller will take care of it */
+		goto out;
+	}
+	a_ops = mapping->a_ops;
+
+	/* XXX: don't instantiate blocks past isize! (same for truncate?) */
+	ret = a_ops->prepare_write(NULL, page, 0, PAGE_CACHE_SIZE);
+	if (ret == 0)
+		ret = __fsblock_commit_write(page, 0, PAGE_CACHE_SIZE);
+out:
+	unlock_page(page);
+
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_page_mkwrite);
+
+static int fsblock_truncate_page_super(struct address_space *mapping, loff_t from)
+{
+	pgoff_t index;
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
+	nr_pages = ((size - length + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT);
+	index = from >> PAGE_CACHE_SHIFT;
+	offset = from & (PAGE_CACHE_SIZE-1);
+
+	err = 0;
+	for (i = 0; i < nr_pages; i++) {
+		struct page *page;
+
+		page = grab_cache_page(mapping, index + i);
+		if (!page) {
+			err = -ENOMEM;
+			break;
+		}
+
+		err = a_ops->prepare_write(NULL, page, offset, PAGE_CACHE_SIZE);
+		if (!err) {
+			FSB_BUG_ON(!PageBlocks(page));
+			zero_user_page(page, offset, PAGE_CACHE_SIZE-offset, KM_USER0);
+			err = __fsblock_commit_write(page, offset, PAGE_CACHE_SIZE);
+		}
+
+		unlock_page(page);
+		page_cache_release(page);
+		if (err)
+			break;
+		offset = 0;
+	}
+	return err;
+}
+
+int fsblock_truncate_page(struct address_space *mapping, loff_t from)
+{
+	pgoff_t index;
+	unsigned offset;
+	struct page *page;
+	const struct address_space_operations *a_ops = mapping->a_ops;
+	unsigned int size = 1 << mapping->host->i_blkbits;
+	unsigned int length;
+	int ret;
+
+	if (size_is_superpage(size))
+		return fsblock_truncate_page_super(mapping, from);
+
+	length = from & (size - 1);
+	if (length == 0)
+		return 0;
+
+	index = from >> PAGE_CACHE_SHIFT;
+	offset = from & (PAGE_CACHE_SIZE-1);
+
+	page = grab_cache_page(mapping, index);
+	if (!page)
+		return -ENOMEM;
+
+	ret = a_ops->prepare_write(NULL, page, offset, PAGE_CACHE_SIZE);
+	if (ret == 0) {
+		zero_user_page(page, offset, PAGE_CACHE_SIZE-offset, KM_USER0);
+		/*
+		 * a_ops->commit_write would extend i_size :( Have to assume
+		 * caller uses fsblock_prepare_write.
+		 */
+		ret = __fsblock_commit_write(page, offset, PAGE_CACHE_SIZE);
+	}
+	unlock_page(page);
+	page_cache_release(page);
+	return ret;
+}
+EXPORT_SYMBOL(fsblock_truncate_page);
+
+static int can_free_block(struct fsblock *block)
+{
+	return atomic_read(&block->count) == 1 &&
+		!test_bit(BL_dirty, &block->flags) &&
+		!block->private;
+}
+
+static int __try_to_free_block(struct fsblock *block)
+{
+	int ret = 0;
+	if (can_free_block(block)) {
+		if (atomic_dec_and_test(&block->count)) {
+			if (!test_bit(BL_dirty, &block->flags)) {
+				ret = 1;
+				goto out;
+			}
+		}
+		atomic_inc(&block->count);
+	}
+out:
+	unlock_block(block);
+
+	return ret;
+}
+
+static int try_to_free_block(struct fsblock *block)
+{
+	/*
+	 * XXX: get rid of block locking from here and invalidate_block --
+	 * use page lock instead?
+	 */
+	if (trylock_block(block))
+		return __try_to_free_block(block);
+	return 0;
+}
+
+static int try_to_free_blocks_super(struct page *orig_page, int all_locked)
+{
+	unsigned int size;
+	struct fsblock *block;
+	struct page *page, *p;
+	int i;
+	int ret = 0;
+
+	FSB_BUG_ON(!PageLocked(orig_page));
+	FSB_BUG_ON(!PageBlocks(orig_page));
+
+	if (PageDirty(orig_page) || PageWriteback(orig_page))
+		return ret;
+
+	block = page_blocks(orig_page);
+	page = block->page;
+	size = fsblock_size(block);
+
+	i = 0;
+	if (!all_locked) {
+		for_each_page(page, size, p) {
+			if (p != orig_page) {
+				if (TestSetPageLocked(p))
+					goto out;
+				i++;
+				if (PageWriteback(p))
+					goto out;
+			}
+		} end_for_each_page;
+	}
+
+	assert_block(block);
+
+	if (!can_free_block(block))
+		goto out;
+	if (!try_to_free_block(block))
+		goto out;
+
+	for_each_page(page, size, p) {
+		FSB_BUG_ON(!PageLocked(p));
+		FSB_BUG_ON(!PageBlocks(p));
+		FSB_BUG_ON(PageWriteback(p));
+		clear_page_blocks(p);
+	} end_for_each_page;
+
+	free_block(block);
+
+	ret = 1;
+
+out:
+	if (i > 0) {
+		for_each_page(page, size, p) {
+			FSB_BUG_ON(PageDirty(p)); /* XXX: racy? */
+			if (p != orig_page) {
+				unlock_page(p);
+				i--;
+				if (i == 0)
+					break;
+			}
+		} end_for_each_page;
+	}
+	return ret;
+}
+
+static int __try_to_free_blocks(struct page *page, int all_locked)
+{
+	unsigned int size;
+	struct fsblock *block;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(!PageBlocks(page));
+
+	if (PageDirty(page) || PageWriteback(page))
+		return 0;
+
+	block = page_blocks(page);
+	if (fsblock_superpage(block))
+		return try_to_free_blocks_super(page, all_locked);
+
+	assert_block(block);
+	if (fsblock_subpage(block)) {
+		struct fsblock *b;
+
+		for_each_block(block, b) {
+			if (!can_free_block(b))
+				return 0;
+		}
+
+		for_each_block(block, b) {
+			/*
+			 * must decrement head block last, so that if the
+			 * find_get_page_block fails, then the blocks will
+			 * really be freed.
+			 */
+			if (b == block)
+				continue;
+			if (!try_to_free_block(b))
+				goto error;
+		}
+		if (!try_to_free_block(block))
+			goto error;
+
+		size = fsblock_size(block);
+		FSB_BUG_ON(block != page_blocks(page));
+		goto success;
+error:
+		for_each_block(block, b) {
+			if (atomic_read(&b->count) == 0)
+				atomic_inc(&b->count);
+		}
+		return 0;
+	} else {
+		if (!can_free_block(block))
+			return 0;
+		if (!try_to_free_block(block))
+			return 0;
+		size = PAGE_CACHE_SIZE;
+	}
+
+success:
+	clear_page_blocks(page);
+	free_block(block);
+	return 1;
+}
+
+int try_to_free_blocks(struct page *page)
+{
+	return __try_to_free_blocks(page, 0);
+}
+
+static void invalidate_block(struct fsblock *block)
+{
+	lock_block(block);
+	/*
+	 * XXX
+	 * FSB_BUG_ON(test_bit(BL_new, &block->flags));
+	 * -- except vmtruncate of new pages can come here
+	 *    via prepare_write failure
+	 */
+	clear_bit(BL_new, &block->flags);
+	clear_bit(BL_dirty, &block->flags);
+	clear_bit(BL_uptodate, &block->flags);
+	clear_bit(BL_mapped, &block->flags);
+	block->block_nr = -1;
+	unlock_block(block);
+	/* XXX: if metadata, then have an fs-private release? */
+}
+
+void fsblock_invalidate_page(struct page *page, unsigned long offset)
+{
+	struct fsblock *block;
+
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(PageWriteback(page));
+	FSB_BUG_ON(!PageBlocks(page));
+
+	block = page_blocks(page);
+	if (fsblock_superpage(block)) {
+		struct page *orig_page = page;
+		struct page *p;
+		unsigned int size = fsblock_size(block);
+		/* XXX: the below may not work for hole punching? */
+		if (page->index & ((size >> PAGE_CACHE_SHIFT) - 1))
+			return;
+		if (offset != 0)
+			return;
+		page = block->page;
+		/* XXX: could lock these pages? */
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
+		invalidate_block(block);
+		try_to_free_blocks(orig_page);
+		return;
+	}
+
+	if (fsblock_subpage(block)) {
+		unsigned int size = fsblock_size(block);
+		unsigned int curr;
+		struct fsblock *b;
+
+		curr = 0;
+		for_each_block(block, b) {
+			if (offset > curr)
+				continue;
+			invalidate_block(b);
+			curr += size;
+		}
+	} else {
+		if (offset == 0)
+			invalidate_block(block);
+	}
+	if (offset == 0)
+		try_to_free_blocks(page);
+}
+EXPORT_SYMBOL(fsblock_invalidate_page);
+
+static struct vm_operations_struct fsblock_file_vm_ops = {
+	.nopage		= filemap_nopage,
+	.populate	= filemap_populate,
+	.page_mkwrite	= fsblock_page_mkwrite,
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
Index: linux-2.6/include/linux/fsblock.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/fsblock.h
@@ -0,0 +1,347 @@
+#ifndef __FSBLOCK_H__
+#define __FSBLOCK_H__
+
+#include <linux/fsblock_types.h>
+#include <linux/types.h>
+#include <linux/spinlock.h>
+#include <linux/fs.h>
+#include <linux/bitops.h>
+#include <linux/page-flags.h>
+#include <linux/mm_types.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/rcupdate.h>
+#include <linux/gfp.h>
+#include <asm/atomic.h>
+
+#define MIN_SECTOR_SHIFT	9 /* 512 bytes */
+
+#define BL_bits_mask	0x000f
+
+#define BL_locked	4
+#define BL_dirty	5
+#define BL_error	6
+#define BL_uptodate	7
+
+#define BL_mapped	8
+#define BL_new		9
+#define BL_writeback	10
+#define BL_readin	11
+
+#define BL_sync_io	12	/* IO completion doesn't unlock/unwriteback */
+#define BL_metadata	13	/* Metadata. If set, page->mapping is the
+				 * blkdev inode. */
+#define BL_wb_lock	14	/* writeback lock (on first subblock in page) */
+#define BL_rd_lock	14	/* readin lock (never active with wb_lock) */
+#define BL_assoc_lock	14
+#ifdef VMAP_CACHE
+#define BL_vmap_lock	14
+#define BL_vmapped	15
+#endif
+
+/*
+ * XXX: eventually want to replace BL_pagecache_io with synchronised block
+ * and page flags manipulations (set_page_dirty of get_user_pages could be
+ * a problem? could have some extra call to pin buffers, though?).
+ */
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
+	FSB_BUG_ON(!test_bit(BL_metadata, &block->flags));
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
+#ifdef FSB_DEBUG
+	if (!test_bit(BL_metadata, &block->flags))
+		FSB_BUG_ON(block->page->mapping->host->i_blkbits != bits);
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
+	if (test_bit(BL_metadata, &block->flags))
+		return sizeof(struct fsblock_meta);
+	else
+		return sizeof(struct fsblock);
+
+}
+
+static inline struct fsblock *page_blocks_rcu(struct page *page)
+{
+	return rcu_dereference((struct fsblock *)page->private);
+}
+
+static inline struct fsblock *page_blocks(struct page *page)
+{
+	struct fsblock *block;
+	FSB_BUG_ON(!PageBlocks(page));
+	block = (struct fsblock *)page->private;
+	FSB_BUG_ON(!fsblock_superpage(block) && block->page != page);
+	/* XXX these go bang if put here
+	FSB_BUG_ON(PageUptodate(page) && !test_bit(BL_uptodate, &block->flags));
+	FSB_BUG_ON(test_bit(BL_dirty, &block->flags) && !PageDirty(page));
+	*/
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
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(PageBlocks(page));
+	FSB_BUG_ON(PagePrivate(page));
+	SetPageBlocks(page);
+	smp_wmb(); /* Rather than rcu_assign_pointer */
+	page->private = (unsigned long)block;
+	page_cache_get(page);
+}
+
+static inline void clear_page_blocks(struct page *page)
+{
+	FSB_BUG_ON(!PageLocked(page));
+	FSB_BUG_ON(!PageBlocks(page));
+	FSB_BUG_ON(PageDirty(page));
+	ClearPageBlocks(page);
+	page->private = (unsigned long)NULL;
+	page_cache_release(page);
+}
+
+
+static inline void map_fsblock(struct fsblock *block, sector_t blocknr)
+{
+	FSB_BUG_ON(test_bit(BL_mapped, &block->flags));
+	block->block_nr = blocknr;
+	set_bit(BL_mapped, &block->flags);
+#ifdef FSB_DEBUG
+	/* XXX: test for inside bdev? */
+	if (test_bit(BL_metadata, &block->flags)) {
+		FSB_BUG_ON(block->block_nr << fsblock_bits(block) >> PAGE_CACHE_SHIFT
+			!= block->page->index);
+	}
+#endif
+}
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
+		FSB_BUG_ON(test_bit(BL_metadata, &first->flags) !=	\
+			test_bit(BL_metadata, &b->flags));		\
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
+	read_lock_irq(&mapping->tree_lock);
+	page = radix_tree_lookup(&mapping->page_tree, index);
+	read_unlock_irq(&mapping->tree_lock);
+
+	return page;
+}
+
+static inline void find_pages(struct address_space *mapping, pgoff_t start, int nr_pages, struct page **pages)
+{
+	int ret;
+
+	read_lock_irq(&mapping->tree_lock);
+        ret = radix_tree_gang_lookup(&mapping->page_tree,
+				(void **)pages, start, nr_pages);
+	read_unlock_irq(&mapping->tree_lock);
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
+static inline pgoff_t sector_pgoff(sector_t blocknr, unsigned int blkbits)
+{
+	if (blkbits <= PAGE_CACHE_SHIFT)
+		return blocknr >> (PAGE_CACHE_SHIFT - blkbits);
+	else
+		return blocknr << (blkbits - PAGE_CACHE_SHIFT);
+}
+
+static inline sector_t pgoff_sector(pgoff_t pgoff, unsigned int blkbits)
+{
+	if (blkbits <= PAGE_CACHE_SHIFT)
+		return (sector_t)pgoff << (PAGE_CACHE_SHIFT - blkbits);
+	else
+		return (sector_t)pgoff >> (blkbits - PAGE_CACHE_SHIFT);
+}
+
+static inline unsigned int block_page_offset(struct fsblock *block, unsigned int size)
+{
+	unsigned int idx;
+	unsigned int size_of = sizeof_block(block);
+	idx = (unsigned long)block - (unsigned long)page_blocks(block->page);
+	return size * (idx / size_of);
+}
+
+int fsblock_set_page_dirty(struct page *page);
+
+struct fsblock_meta *find_get_mblock(struct block_device *bdev, sector_t blocknr, unsigned int size);
+
+struct fsblock_meta *find_or_create_mblock(struct block_device *bdev, sector_t blocknr, unsigned int size);
+
+struct fsblock_meta *mbread(struct block_device *bdev, sector_t blocknr, unsigned int size);
+
+
+static inline struct fsblock_meta *sb_find_get_mblock(struct super_block *sb, sector_t blocknr)
+{
+	return find_get_mblock(sb->s_bdev, blocknr, sb->s_blocksize);
+}
+
+static inline struct fsblock_meta *sb_find_or_create_mblock(struct super_block *sb, sector_t blocknr)
+{
+	return find_or_create_mblock(sb->s_bdev, blocknr, sb->s_blocksize);
+}
+
+static inline struct fsblock_meta *sb_mbread(struct super_block *sb, sector_t blocknr)
+{
+	return mbread(sb->s_bdev, blocknr, sb->s_blocksize);
+}
+
+void mark_mblock_uptodate(struct fsblock_meta *mblock);
+int mark_mblock_dirty(struct fsblock_meta *mblock);
+int mark_mblock_dirty_inode(struct fsblock_meta *mblock, struct inode *inode);
+
+int sync_block(struct fsblock *block);
+
+/* XXX: are these always for metablocks? (no, directory in pagecache?) */
+void *vmap_block(struct fsblock *block, off_t off, size_t len);
+void vunmap_block(struct fsblock *block, off_t off, size_t len, void *vaddr);
+
+void block_get(struct fsblock *block);
+#define mblock_get(b) block_get(mblock_block(b))
+void block_put(struct fsblock *block);
+#define mblock_put(b) block_put(mblock_block(b))
+
+static inline int trylock_block(struct fsblock *block)
+{
+	return likely(!test_and_set_bit(BL_locked, &block->flags));
+}
+void lock_block(struct fsblock *block);
+void unlock_block(struct fsblock *block);
+
+sector_t fsblock_bmap(struct address_space *mapping, sector_t block, insert_mapping_fn *insert_mapping);
+
+int fsblock_read_page(struct page *page, insert_mapping_fn *insert_mapping);
+int fsblock_write_page(struct page *page, insert_mapping_fn *insert_mapping,
+				struct writeback_control *wbc);
+
+int fsblock_prepare_write(struct page *page, unsigned from, unsigned to, insert_mapping_fn insert_mapping);
+int __fsblock_commit_write(struct page *page, unsigned from, unsigned to);
+int fsblock_commit_write(struct file *file, struct page *page, unsigned from, unsigned to);
+int fsblock_page_mkwrite(struct vm_area_struct *vma, struct page *page);
+int fsblock_truncate_page(struct address_space *mapping, loff_t from);
+void fsblock_invalidate_page(struct page *page, unsigned long offset);
+int fsblock_release(struct address_space *mapping, int force);
+int fsblock_sync(struct address_space *mapping);
+
+//int alloc_mapping_blocks(struct address_space *mapping, pgoff_t pgoff, gfp_t gfp_flags);
+int try_to_free_blocks(struct page *page);
+
+int fsblock_file_mmap(struct file *file, struct vm_area_struct *vma);
+
+void fsblock_init(void);
+
+#endif
Index: linux-2.6/include/linux/fsblock_types.h
===================================================================
--- /dev/null
+++ linux-2.6/include/linux/fsblock_types.h
@@ -0,0 +1,70 @@
+#ifndef __FSBLOCK_TYPES_H__
+#define __FSBLOCK_TYPES_H__
+
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/mm_types.h>
+#include <linux/rcupdate.h>
+#include <asm/atomic.h>
+
+#define FSB_DEBUG	1
+
+#ifdef FSB_DEBUG
+# define FSB_BUG()	BUG()
+# define FSB_BUG_ON(x)	BUG_ON(x)
+#else
+# define FSB_BUG()
+# define FSB_BUG_ON(x)
+#endif
+
+#define BLOCK_SUPERPAGE_SUPPORT	1
+
+/*
+ * XXX: this is a hack for filesystems that vmap the entire block regularly,
+ * and won't even work for systems with limited vmalloc space.
+ * Should make fs'es vmap in page sized chunks instead (providing some
+ * helpers too). Currently racy when vunmapping at end_io interrupt.
+ */
+#define VMAP_CACHE	1
+
+struct address_space;
+
+/*
+ * inode == page->mapping->host
+ * bsize == inode->i_blkbits
+ * bdev  == inode->i_bdev
+ */
+struct fsblock {
+	atomic_t	count;
+	union {
+		struct {
+			unsigned long	flags; /* XXX: flags could be int for better packing */
+
+			sector_t	block_nr;
+			void		*private;
+			struct page	*page;	/* Superpage block pages found via ->mapping */
+		};
+		struct rcu_head rcu_head; /* XXX: can go away if we have kmem caches for fsblocks */
+	};
+
+#ifdef VMAP_CACHE
+	void *vaddr;
+#endif
+
+#ifdef FSB_DEBUG
+	atomic_t	vmap_count;
+#endif
+};
+
+struct fsblock_meta {
+	struct fsblock block;
+
+	/* Nothing else, at the moment */
+	/* XXX: could just get rid of fsblock_meta? */
+};
+
+typedef int (insert_mapping_fn)(struct address_space *mapping,
+				loff_t off, size_t len, int create);
+
+#endif
Index: linux-2.6/init/main.c
===================================================================
--- linux-2.6.orig/init/main.c
+++ linux-2.6/init/main.c
@@ -50,6 +50,7 @@
 #include <linux/key.h>
 #include <linux/unwind.h>
 #include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/debug_locks.h>
 #include <linux/lockdep.h>
 #include <linux/pid_namespace.h>
@@ -613,6 +614,7 @@ asmlinkage void __init start_kernel(void
 	fork_init(num_physpages);
 	proc_caches_init();
 	buffer_init();
+	fsblock_init();
 	unnamed_dev_init();
 	key_init();
 	security_init();
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -199,6 +199,7 @@ static void bad_page(struct page *page)
 	dump_stack();
 	page->flags &= ~(1 << PG_lru	|
 			1 << PG_private |
+			1 << PG_blocks	|
 			1 << PG_locked	|
 			1 << PG_active	|
 			1 << PG_dirty	|
@@ -436,6 +437,7 @@ static inline int free_pages_check(struc
 		(page->flags & (
 			1 << PG_lru	|
 			1 << PG_private |
+			1 << PG_blocks	|
 			1 << PG_locked	|
 			1 << PG_active	|
 			1 << PG_slab	|
@@ -590,6 +592,7 @@ static int prep_new_page(struct page *pa
 		(page->flags & (
 			1 << PG_lru	|
 			1 << PG_private	|
+			1 << PG_blocks	|
 			1 << PG_locked	|
 			1 << PG_active	|
 			1 << PG_dirty	|
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
@@ -988,6 +989,11 @@ grow_dev_page(struct block_device *bdev,
 
 	BUG_ON(!PageLocked(page));
 
+	if (PageBlocks(page)) {
+		if (try_to_free_blocks(page))
+			return NULL;
+	}
+
 	if (page_has_buffers(page)) {
 		bh = page_buffers(page);
 		if (bh->b_size == size) {
@@ -1596,6 +1602,10 @@ static int __block_write_full_page(struc
 	last_block = (i_size_read(inode) - 1) >> inode->i_blkbits;
 
 	if (!page_has_buffers(page)) {
+		if (PageBlocks(page)) {
+			if (try_to_free_blocks(page))
+				return -EBUSY;
+		}
 		create_empty_buffers(page, blocksize,
 					(1 << BH_Dirty)|(1 << BH_Uptodate));
 	}
@@ -1757,8 +1767,13 @@ static int __block_prepare_write(struct 
 	BUG_ON(from > to);
 
 	blocksize = 1 << inode->i_blkbits;
-	if (!page_has_buffers(page))
+	if (!page_has_buffers(page)) {
+		if (PageBlocks(page)) {
+			if (try_to_free_blocks(page))
+				return -EBUSY;
+		}
 		create_empty_buffers(page, blocksize, 0);
+	}
 	head = page_buffers(page);
 
 	bbits = inode->i_blkbits;
@@ -1911,8 +1926,13 @@ int block_read_full_page(struct page *pa
 
 	BUG_ON(!PageLocked(page));
 	blocksize = 1 << inode->i_blkbits;
-	if (!page_has_buffers(page))
+	if (!page_has_buffers(page)) {
+		if (PageBlocks(page)) {
+			if (try_to_free_blocks(page))
+				return -EBUSY;
+		}
 		create_empty_buffers(page, blocksize, 0);
+	}
 	head = page_buffers(page);
 
 	iblock = (sector_t)page->index << (PAGE_CACHE_SHIFT - inode->i_blkbits);
@@ -2475,8 +2495,13 @@ int block_truncate_page(struct address_s
 	if (!page)
 		goto out;
 
-	if (!page_has_buffers(page))
+	if (!page_has_buffers(page)) {
+		if (PageBlocks(page)) {
+			if (try_to_free_blocks(page))
+				return -EBUSY;
+		}
 		create_empty_buffers(page, blocksize, 0);
+	}
 
 	/* Find the buffer that contains "offset" */
 	bh = page_buffers(page);
Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c
+++ linux-2.6/fs/splice.c
@@ -25,6 +25,7 @@
 #include <linux/swap.h>
 #include <linux/writeback.h>
 #include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
 #include <linux/uio.h>
@@ -73,7 +74,7 @@ static int page_cache_pipe_buf_steal(str
 		 */
 		wait_on_page_writeback(page);
 
-		if (PagePrivate(page))
+		if (PagePrivate(page) || PageBlocks(page))
 			try_to_release_page(page, GFP_KERNEL);
 
 		/*
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h
+++ linux-2.6/include/linux/buffer_head.h
@@ -230,6 +230,7 @@ static inline void attach_page_buffers(s
 		struct buffer_head *head)
 {
 	page_cache_get(page);
+	BUG_ON(PageBlocks(page));
 	SetPagePrivate(page);
 	set_page_private(page, (unsigned long)head);
 }
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -37,6 +37,7 @@
  * FIXME: remove all knowledge of the buffer layer from the core VM
  */
 #include <linux/buffer_head.h> /* for generic_osync_inode */
+#include <linux/fsblock.h>
 
 #include <asm/mman.h>
 
@@ -2473,9 +2474,13 @@ int try_to_release_page(struct page *pag
 	if (PageWriteback(page))
 		return 0;
 
+	BUG_ON(!(PagePrivate(page) ^ PageBlocks(page)));
 	if (mapping && mapping->a_ops->releasepage)
 		return mapping->a_ops->releasepage(page, gfp_mask);
-	return try_to_free_buffers(page);
+	if (PagePrivate(page))
+		return try_to_free_buffers(page);
+	else
+		return try_to_free_blocks(page);
 }
 
 EXPORT_SYMBOL(try_to_release_page);
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c
+++ linux-2.6/mm/swap.c
@@ -24,6 +24,7 @@
 #include <linux/module.h>
 #include <linux/mm_inline.h>
 #include <linux/buffer_head.h>	/* for try_to_release_page() */
+#include <linux/fsblock.h>
 #include <linux/module.h>
 #include <linux/percpu_counter.h>
 #include <linux/percpu.h>
@@ -412,8 +413,10 @@ void pagevec_strip(struct pagevec *pvec)
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
 
-		if (PagePrivate(page) && !TestSetPageLocked(page)) {
-			if (PagePrivate(page))
+		if ((PagePrivate(page) || PageBlocks(page)) &&
+				!TestSetPageLocked(page)) {
+			BUG_ON(PagePrivate(page) && PageBlocks(page));
+			if (PagePrivate(page) || PageBlocks(page))
 				try_to_release_page(page, 0);
 			unlock_page(page);
 		}
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -15,8 +15,8 @@
 #include <linux/highmem.h>
 #include <linux/pagevec.h>
 #include <linux/task_io_accounting_ops.h>
-#include <linux/buffer_head.h>	/* grr. try_to_release_page,
-				   do_invalidatepage */
+#include <linux/buffer_head.h>	/* try_to_release_page, do_invalidatepage */
+#include <linux/fsblock.h>
 
 
 /**
@@ -36,20 +36,28 @@
 void do_invalidatepage(struct page *page, unsigned long offset)
 {
 	void (*invalidatepage)(struct page *, unsigned long);
+
+	if (!PagePrivate(page) && !PageBlocks(page))
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
 	zero_user_page(page, partial, PAGE_CACHE_SIZE - partial, KM_USER0);
-	if (PagePrivate(page))
-		do_invalidatepage(page, partial);
+	do_invalidatepage(page, partial);
 }
 
 /*
@@ -97,13 +105,14 @@ truncate_complete_page(struct address_sp
 
 	cancel_dirty_page(page, PAGE_CACHE_SIZE);
 
-	if (PagePrivate(page))
-		do_invalidatepage(page, 0);
+	do_invalidatepage(page, 0);
 
-	ClearPageUptodate(page);
-	ClearPageMappedToDisk(page);
-	remove_from_page_cache(page);
-	page_cache_release(page);	/* pagecache ref */
+	if (!PageBlocks(page)) {
+		ClearPageUptodate(page);
+		ClearPageMappedToDisk(page);
+		remove_from_page_cache(page);
+		page_cache_release(page);	/* pagecache ref */
+	}
 }
 
 /*
@@ -122,8 +131,9 @@ invalidate_complete_page(struct address_
 	if (page->mapping != mapping)
 		return 0;
 
-	if (PagePrivate(page) && !try_to_release_page(page, 0))
-		return 0;
+	if (PagePrivate(page) || PageBlocks(page))
+		if (!try_to_release_page(page, 0))
+			return 0;
 
 	ret = remove_mapping(mapping, page);
 
@@ -176,24 +186,18 @@ void truncate_inode_pages_range(struct a
 	       pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
-			pgoff_t page_index = page->index;
 
-			if (page_index > end) {
-				next = page_index;
+			next = page->index+1;
+			if (next-1 > end)
 				break;
-			}
 
-			if (page_index > next)
-				next = page_index;
-			next++;
-			if (TestSetPageLocked(page))
+			if (PageWriteback(page))
 				continue;
-			if (PageWriteback(page)) {
+			if (!TestSetPageLocked(page)) {
+				if (!PageWriteback(page))
+					truncate_complete_page(mapping, page);
 				unlock_page(page);
-				continue;
 			}
-			truncate_complete_page(mapping, page);
-			unlock_page(page);
 		}
 		pagevec_release(&pvec);
 		cond_resched();
@@ -210,28 +214,18 @@ void truncate_inode_pages_range(struct a
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
-			if (page->index > next)
-				next = page->index;
-			next++;
 			truncate_complete_page(mapping, page);
 			unlock_page(page);
 		}
@@ -326,17 +320,18 @@ invalidate_complete_page2(struct address
 	if (page->mapping != mapping)
 		return 0;
 
-	if (PagePrivate(page) && !try_to_release_page(page, GFP_KERNEL))
-		return 0;
+	if (PagePrivate(page) || PageBlocks(page))
+		if (!try_to_release_page(page, GFP_KERNEL))
+			return 0;
 
 	write_lock_irq(&mapping->tree_lock);
 	if (PageDirty(page))
 		goto failed;
 
-	BUG_ON(PagePrivate(page));
+	BUG_ON(PagePrivate(page) || PageBlocks(page));
+	ClearPageUptodate(page);
 	__remove_from_page_cache(page);
 	write_unlock_irq(&mapping->tree_lock);
-	ClearPageUptodate(page);
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
 failed:
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
@@ -565,7 +565,7 @@ static unsigned long shrink_page_list(st
 		 * process address space (page_count == 1) it can be freed.
 		 * Otherwise, leave the page on the LRU so it is swappable.
 		 */
-		if (PagePrivate(page)) {
+		if (PagePrivate(page) || PageBlocks(page)) {
 			if (!try_to_release_page(page, sc->gfp_mask))
 				goto activate_locked;
 			if (!mapping && page_count(page) == 1)
Index: linux-2.6/fs/fs-writeback.c
===================================================================
--- linux-2.6.orig/fs/fs-writeback.c
+++ linux-2.6/fs/fs-writeback.c
@@ -22,6 +22,7 @@
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
 #include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 #include "internal.h"
 
 /**
@@ -636,9 +637,15 @@ int generic_osync_inode(struct inode *in
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
@@ -32,6 +32,7 @@
  * FIXME: remove all knowledge of the buffer layer from this file
  */
 #include <linux/buffer_head.h>
+#include <linux/fsblock.h>
 
 /*
  * New inode.c implementation.
@@ -170,7 +171,7 @@ static struct inode *alloc_inode(struct 
 
 void destroy_inode(struct inode *inode) 
 {
-	BUG_ON(inode_has_buffers(inode));
+	BUG_ON(mapping_has_private(&inode->i_data));
 	security_inode_free(inode);
 	if (inode->i_sb->s_op->destroy_inode)
 		inode->i_sb->s_op->destroy_inode(inode);
@@ -241,10 +242,14 @@ void __iget(struct inode * inode)
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
 	wait_on_inode(inode);
@@ -307,6 +312,7 @@ static int invalidate_list(struct list_h
 	for (;;) {
 		struct list_head * tmp = next;
 		struct inode * inode;
+		struct address_space * mapping;
 
 		/*
 		 * We can reschedule here without worrying about the list's
@@ -320,7 +326,12 @@ static int invalidate_list(struct list_h
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
@@ -363,13 +374,15 @@ EXPORT_SYMBOL(invalidate_inodes);
 
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
@@ -398,6 +411,7 @@ static void prune_icache(int nr_to_scan)
 	spin_lock(&inode_lock);
 	for (nr_scanned = 0; nr_scanned < nr_to_scan; nr_scanned++) {
 		struct inode *inode;
+		struct address_space *mapping;
 
 		if (list_empty(&inode_unused))
 			break;
@@ -408,10 +422,17 @@ static void prune_icache(int nr_to_scan)
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
