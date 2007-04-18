Message-Id: <20070418201605.909543876@chello.nl>
References: <20070418201248.468050288@chello.nl>
Date: Wed, 18 Apr 2007 22:12:52 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 4/6] mm: concurrent pagecache write side
Content-Disposition: inline; filename=mm-concurrent-pagecache.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: npiggin@suse.de, akpm@linux-foundation.org, clameter@sgi.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Remove the tree_lock, change address_space::nrpages to atomic_long_t because
its not protected any longer and use the concurrent radix tree API to protect
the modifying radix tree operations.

The tree_lock is actually renamed to priv_lock and its only remaining user will
be the __flush_dcache_page logic on arm an parisc. Another potential user would
be the per address_space node mask allocation Christoph is working on.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/buffer.c                     |    6 ++++--
 fs/inode.c                      |    2 +-
 include/asm-arm/cacheflush.h    |    4 ++--
 include/asm-parisc/cacheflush.h |    4 ++--
 include/linux/fs.h              |   12 ++++++------
 mm/filemap.c                    |   13 +++++++------
 mm/migrate.c                    |    9 +++++----
 mm/page-writeback.c             |   28 +++++++++++++++++++---------
 mm/swap_state.c                 |   13 ++++++++-----
 mm/swapfile.c                   |    2 --
 mm/truncate.c                   |    3 ---
 mm/vmscan.c                     |    4 ----
 12 files changed, 54 insertions(+), 46 deletions(-)

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2007-04-13 12:26:43.000000000 +0200
+++ linux-2.6/fs/buffer.c	2007-04-13 12:27:11.000000000 +0200
@@ -730,16 +730,18 @@ int __set_page_dirty_buffers(struct page
 		return 0;
 
 	lock_page_ref_irq(page);
-	spin_lock(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
+		DEFINE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
+
 		if (mapping_cap_account_dirty(mapping)) {
 			__inc_zone_page_state(page, NR_FILE_DIRTY);
 			task_io_account_write(PAGE_CACHE_SIZE);
 		}
-		radix_tree_tag_set(&mapping->page_tree,
+		radix_tree_lock(&ctx);
+		radix_tree_tag_set(ctx.tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
+		radix_tree_unlock(&ctx);
 	}
-	spin_unlock(&mapping->tree_lock);
 	unlock_page_ref_irq(page);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	return 1;
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c	2007-04-13 12:26:41.000000000 +0200
+++ linux-2.6/fs/inode.c	2007-04-13 12:27:05.000000000 +0200
@@ -193,7 +193,7 @@ void inode_init_once(struct inode *inode
 	mutex_init(&inode->i_mutex);
 	init_rwsem(&inode->i_alloc_sem);
 	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
-	spin_lock_init(&inode->i_data.tree_lock);
+	spin_lock_init(&inode->i_data.priv_lock);
 	spin_lock_init(&inode->i_data.i_mmap_lock);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h	2007-04-13 12:26:41.000000000 +0200
+++ linux-2.6/include/linux/fs.h	2007-04-13 12:27:05.000000000 +0200
@@ -434,13 +434,13 @@ struct backing_dev_info;
 struct address_space {
 	struct inode		*host;		/* owner: inode, block_device */
 	struct radix_tree_root	page_tree;	/* radix tree of all pages */
-	spinlock_t		tree_lock;	/* and lock protecting it */
+	spinlock_t		priv_lock;	/* spinlock protecting various stuffs */
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
 	unsigned int		truncate_count;	/* Cover race condition with truncate */
-	unsigned long		__nrpages;	/* number of total pages */
+	atomic_long_t		__nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
@@ -457,22 +457,22 @@ struct address_space {
 
 static inline void mapping_nrpages_init(struct address_space *mapping)
 {
-	mapping->__nrpages = 0;
+	mapping->__nrpages = (atomic_long_t)ATOMIC_LONG_INIT(0);
 }
 
 static inline unsigned long mapping_nrpages(struct address_space *mapping)
 {
-	return mapping->__nrpages;
+	return (unsigned long)atomic_long_read(&mapping->__nrpages);
 }
 
 static inline void mapping_nrpages_inc(struct address_space *mapping)
 {
-	mapping->__nrpages++;
+	atomic_long_inc(&mapping->__nrpages);
 }
 
 static inline void mapping_nrpages_dec(struct address_space *mapping)
 {
-	mapping->__nrpages--;
+	atomic_long_dec(&mapping->__nrpages);
 }
 
 struct block_device {
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2007-04-13 12:26:43.000000000 +0200
+++ linux-2.6/mm/filemap.c	2007-04-13 12:27:11.000000000 +0200
@@ -115,8 +115,11 @@ generic_file_direct_IO(int rw, struct ki
 void __remove_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
+	DEFINE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
 
-	radix_tree_delete(&mapping->page_tree, page->index);
+	radix_tree_lock(&ctx);
+	radix_tree_delete(ctx.tree, page->index);
+	radix_tree_unlock(&ctx);
 	page->mapping = NULL;
 	mapping_nrpages_dec(mapping);
 	__dec_zone_page_state(page, NR_FILE_PAGES);
@@ -124,14 +127,10 @@ void __remove_from_page_cache(struct pag
 
 void remove_from_page_cache(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
-
 	BUG_ON(!PageLocked(page));
 
 	lock_page_ref_irq(page);
-	spin_lock(&mapping->tree_lock);
 	__remove_from_page_cache(page);
-	spin_unlock(&mapping->tree_lock);
 	unlock_page_ref_irq(page);
 }
 
@@ -442,9 +441,12 @@ int add_to_page_cache(struct page *page,
 	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 
 	if (error == 0) {
+		DEFINE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
+
 		lock_page_ref_irq(page);
-		spin_lock(&mapping->tree_lock);
-		error = radix_tree_insert(&mapping->page_tree, offset, page);
+		radix_tree_lock(&ctx);
+		error = radix_tree_insert(ctx.tree, offset, page);
+		radix_tree_unlock(&ctx);
 		if (!error) {
 			page_cache_get(page);
 			SetPageLocked(page);
@@ -453,7 +455,6 @@ int add_to_page_cache(struct page *page,
 			mapping_nrpages_inc(mapping);
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
-		spin_unlock(&mapping->tree_lock);
 		unlock_page_ref_irq(page);
 		radix_tree_preload_end();
 	}
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2007-04-13 12:26:43.000000000 +0200
+++ linux-2.6/mm/migrate.c	2007-04-13 12:27:11.000000000 +0200
@@ -295,6 +295,7 @@ static int migrate_page_move_mapping(str
 		struct page *newpage, struct page *page)
 {
 	void **pslot;
+	struct radix_tree_context ctx;
 
 	if (!mapping) {
 		/* Anonymous page */
@@ -303,15 +304,14 @@ static int migrate_page_move_mapping(str
 		return 0;
 	}
 
+	init_radix_tree_context(&ctx, &mapping->page_tree);
 	lock_page_ref_irq(page);
-	spin_lock(&mapping->tree_lock);
-
-	pslot = radix_tree_lookup_slot(&mapping->page_tree,
- 					page_index(page));
+	radix_tree_lock(&ctx);
+	pslot = radix_tree_lookup_slot(ctx.tree, page_index(page));
 
 	if (page_count(page) != 2 + !!PagePrivate(page) ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
-		spin_unlock(&mapping->tree_lock);
+		radix_tree_unlock(&ctx);
 		unlock_page_ref_irq(page);
 		return -EAGAIN;
 	}
@@ -329,7 +329,7 @@ static int migrate_page_move_mapping(str
 
 	radix_tree_replace_slot(pslot, newpage);
 	page->mapping = NULL;
-  	spin_unlock(&mapping->tree_lock);
+	radix_tree_unlock(&ctx);
 	unlock_page_ref_irq(page);
 
 	/*
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-04-13 12:26:43.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2007-04-13 12:27:11.000000000 +0200
@@ -777,18 +777,20 @@ int __set_page_dirty_nobuffers(struct pa
 			return 1;
 
 		lock_page_ref_irq(page);
-		spin_lock(&mapping->tree_lock);
 		mapping2 = page_mapping(page);
 		if (mapping2) { /* Race with truncate? */
+			DEFINE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
+
 			BUG_ON(mapping2 != mapping);
 			if (mapping_cap_account_dirty(mapping)) {
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
 				task_io_account_write(PAGE_CACHE_SIZE);
 			}
-			radix_tree_tag_set(&mapping->page_tree,
+			radix_tree_lock(&ctx);
+			radix_tree_tag_set(ctx.tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
+			radix_tree_unlock(&ctx);
 		}
-		spin_unlock(&mapping->tree_lock);
 		unlock_page_ref_irq(page);
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
@@ -927,13 +929,15 @@ int test_clear_page_writeback(struct pag
 		int ret;
 
 		lock_page_ref_irqsave(page, flags);
-		spin_lock(&mapping->tree_lock);
 		ret = TestClearPageWriteback(page);
-		if (ret)
-			radix_tree_tag_clear(&mapping->page_tree,
-						page_index(page),
+		if (ret) {
+			DEFINE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
+
+			radix_tree_lock(&ctx);
+			radix_tree_tag_clear(ctx.tree, page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-		spin_unlock(&mapping->tree_lock);
+			radix_tree_unlock(&ctx);
+		}
 		unlock_page_ref_irqrestore(page, flags);
 		return ret;
 	}
@@ -947,19 +951,22 @@ int test_set_page_writeback(struct page 
 	if (mapping) {
 		unsigned long flags;
 		int ret;
+		DEFINE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
 
 		lock_page_ref_irqsave(page, flags);
-		spin_lock(&mapping->tree_lock);
 		ret = TestSetPageWriteback(page);
-		if (!ret)
-			radix_tree_tag_set(&mapping->page_tree,
-						page_index(page),
+		if (!ret) {
+			radix_tree_lock(&ctx);
+			radix_tree_tag_set(ctx.tree, page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-		if (!PageDirty(page))
-			radix_tree_tag_clear(&mapping->page_tree,
-						page_index(page),
+			radix_tree_unlock(&ctx);
+		}
+		if (!PageDirty(page)) {
+			radix_tree_lock(&ctx);
+			radix_tree_tag_clear(ctx.tree, page_index(page),
 						PAGECACHE_TAG_DIRTY);
-		spin_unlock(&mapping->tree_lock);
+			radix_tree_unlock(&ctx);
+		}
 		unlock_page_ref_irqrestore(page, flags);
 		return ret;
 	}
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c	2007-04-13 12:26:43.000000000 +0200
+++ linux-2.6/mm/swap_state.c	2007-04-13 12:27:11.000000000 +0200
@@ -38,7 +38,6 @@ static struct backing_dev_info swap_back
 
 struct address_space swapper_space = {
 	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
-	.tree_lock	= __SPIN_LOCK_UNLOCKED(swapper_space.tree_lock),
 	.a_ops		= &swap_aops,
 	.i_mmap_nonlinear = LIST_HEAD_INIT(swapper_space.i_mmap_nonlinear),
 	.backing_dev_info = &swap_backing_dev_info,
@@ -79,10 +78,12 @@ static int __add_to_swap_cache(struct pa
 	BUG_ON(PagePrivate(page));
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
+		DEFINE_RADIX_TREE_CONTEXT(ctx, &swapper_space.page_tree);
+
 		lock_page_ref_irq(page);
-		spin_lock(&swapper_space.tree_lock);
-		error = radix_tree_insert(&swapper_space.page_tree,
-						entry.val, page);
+		radix_tree_lock(&ctx);
+		error = radix_tree_insert(ctx.tree, entry.val, page);
+		radix_tree_unlock(&ctx);
 		if (!error) {
 			page_cache_get(page);
 			SetPageSwapCache(page);
@@ -90,7 +91,6 @@ static int __add_to_swap_cache(struct pa
 			mapping_nrpages_inc(&swapper_space);
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
-		spin_unlock(&swapper_space.tree_lock);
 		unlock_page_ref_irq(page);
 		radix_tree_preload_end();
 	}
@@ -125,12 +125,16 @@ static int add_to_swap_cache(struct page
  */
 void __delete_from_swap_cache(struct page *page)
 {
+	DEFINE_RADIX_TREE_CONTEXT(ctx, &swapper_space.page_tree);
+
 	BUG_ON(!PageLocked(page));
 	BUG_ON(!PageSwapCache(page));
 	BUG_ON(PageWriteback(page));
 	BUG_ON(PagePrivate(page));
 
-	radix_tree_delete(&swapper_space.page_tree, page_private(page));
+	radix_tree_lock(&ctx);
+	radix_tree_delete(ctx.tree, page_private(page));
+	radix_tree_unlock(&ctx);
 	set_page_private(page, 0);
 	ClearPageSwapCache(page);
 	mapping_nrpages_dec(&swapper_space);
@@ -203,9 +207,7 @@ void delete_from_swap_cache(struct page 
 	entry.val = page_private(page);
 
 	lock_page_ref_irq(page);
-	spin_lock(&swapper_space.tree_lock);
 	__delete_from_swap_cache(page);
-	spin_unlock(&swapper_space.tree_lock);
 	unlock_page_ref_irq(page);
 
 	swap_free(entry);
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c	2007-04-13 12:26:43.000000000 +0200
+++ linux-2.6/mm/swapfile.c	2007-04-13 12:27:05.000000000 +0200
@@ -368,13 +368,11 @@ int remove_exclusive_swap_page(struct pa
 	if (p->swap_map[swp_offset(entry)] == 1) {
 		/* Recheck the page count with the swapcache lock held.. */
 		lock_page_ref_irq(page);
-		spin_lock(&swapper_space.tree_lock);
 		if ((page_count(page) == 2) && !PageWriteback(page)) {
 			__delete_from_swap_cache(page);
 			SetPageDirty(page);
 			retval = 1;
 		}
-		spin_unlock(&swapper_space.tree_lock);
 		unlock_page_ref_irq(page);
 	}
 	spin_unlock(&swap_lock);
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c	2007-04-13 12:26:43.000000000 +0200
+++ linux-2.6/mm/truncate.c	2007-04-13 12:27:05.000000000 +0200
@@ -329,19 +329,16 @@ invalidate_complete_page2(struct address
 		return 0;
 
 	lock_page_ref_irq(page);
-	spin_lock(&mapping->tree_lock);
 	if (PageDirty(page))
 		goto failed;
 
 	BUG_ON(PagePrivate(page));
 	__remove_from_page_cache(page);
-	spin_unlock(&mapping->tree_lock);
 	unlock_page_ref_irq(page);
 	ClearPageUptodate(page);
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
 failed:
-	spin_unlock(&mapping->tree_lock);
 	unlock_page_ref_irq(page);
 	return 0;
 }
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-04-13 12:26:43.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2007-04-13 12:27:05.000000000 +0200
@@ -391,7 +391,6 @@ int remove_mapping(struct address_space 
 	BUG_ON(mapping != page_mapping(page));
 
 	lock_page_ref_irq(page);
-	spin_lock(&mapping->tree_lock);
 	/*
 	 * The non racy check for a busy page.
 	 *
@@ -426,13 +425,11 @@ int remove_mapping(struct address_space 
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
 		__delete_from_swap_cache(page);
-		spin_unlock(&mapping->tree_lock);
 		swap_free(swap);
 		goto free_it;
 	}
 
 	__remove_from_page_cache(page);
-	spin_unlock(&mapping->tree_lock);
 
 free_it:
 	unlock_page_ref_irq(page);
@@ -440,7 +437,6 @@ free_it:
 	return 1;
 
 cannot_free:
-	spin_unlock(&mapping->tree_lock);
 	unlock_page_ref_irq(page);
 	return 0;
 }
Index: linux-2.6/include/asm-arm/cacheflush.h
===================================================================
--- linux-2.6.orig/include/asm-arm/cacheflush.h	2007-04-13 12:26:07.000000000 +0200
+++ linux-2.6/include/asm-arm/cacheflush.h	2007-04-13 12:27:05.000000000 +0200
@@ -405,9 +405,9 @@ static inline void flush_anon_page(struc
 }
 
 #define flush_dcache_mmap_lock(mapping) \
-	spin_lock_irq(&(mapping)->tree_lock)
+	spin_lock_irq(&(mapping)->priv_lock)
 #define flush_dcache_mmap_unlock(mapping) \
-	spin_unlock_irq(&(mapping)->tree_lock)
+	spin_unlock_irq(&(mapping)->priv_lock)
 
 #define flush_icache_user_range(vma,page,addr,len) \
 	flush_dcache_page(page)
Index: linux-2.6/include/asm-parisc/cacheflush.h
===================================================================
--- linux-2.6.orig/include/asm-parisc/cacheflush.h	2007-04-13 12:26:07.000000000 +0200
+++ linux-2.6/include/asm-parisc/cacheflush.h	2007-04-13 12:27:05.000000000 +0200
@@ -45,9 +45,9 @@ void flush_cache_mm(struct mm_struct *mm
 extern void flush_dcache_page(struct page *page);
 
 #define flush_dcache_mmap_lock(mapping) \
-	spin_lock_irq(&(mapping)->tree_lock)
+	spin_lock_irq(&(mapping)->priv_lock)
 #define flush_dcache_mmap_unlock(mapping) \
-	spin_unlock_irq(&(mapping)->tree_lock)
+	spin_unlock_irq(&(mapping)->priv_lock)
 
 #define flush_icache_page(vma,page)	do { 		\
 	flush_kernel_dcache_page(page);			\

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
