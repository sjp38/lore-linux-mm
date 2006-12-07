Message-Id: <20061207162738.372283000@chello.nl>
References: <20061207161800.426936000@chello.nl>
Date: Thu, 07 Dec 2006 17:18:16 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 16/16] mm: concurrent pagecache write side
Content-Disposition: inline; filename=mm-concurrent-pagecache.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Remove the tree_lock, change address_space::nrpages to atomic_ulong_t
because its not protected any longer and use the concurrent radix tree API to
protect the modifying radix tree operations.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/buffer.c         |    6 ++++--
 fs/inode.c          |    1 -
 include/linux/fs.h  |   11 +++++------
 mm/filemap.c        |   11 +++++++----
 mm/migrate.c        |    9 +++++----
 mm/page-writeback.c |   35 +++++++++++++++++++++++------------
 mm/swap_state.c     |   13 ++++++++-----
 mm/swapfile.c       |    2 --
 mm/truncate.c       |    3 ---
 mm/vmscan.c         |    4 ----
 10 files changed, 52 insertions(+), 43 deletions(-)

Index: linux-2.6-rt/fs/buffer.c
===================================================================
--- linux-2.6-rt.orig/fs/buffer.c	2006-12-02 22:42:24.000000000 +0100
+++ linux-2.6-rt/fs/buffer.c	2006-12-02 22:42:25.000000000 +0100
@@ -720,15 +720,17 @@ int __set_page_dirty_buffers(struct page
 
 	if (!TestSetPageDirty(page)) {
 		lock_page_ref_irq(page);
-		spin_lock(&mapping->tree_lock);
 		if (page->mapping) {	/* Race with truncate? */
+			DECLARE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
+
 			if (mapping_cap_account_dirty(mapping))
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
+			radix_tree_lock(&ctx);
 			radix_tree_tag_set(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
+			radix_tree_unlock(&ctx);
 		}
-		spin_unlock(&mapping->tree_lock);
 		unlock_page_ref_irq(page);
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 		return 1;
Index: linux-2.6-rt/fs/inode.c
===================================================================
--- linux-2.6-rt.orig/fs/inode.c	2006-12-02 22:41:33.000000000 +0100
+++ linux-2.6-rt/fs/inode.c	2006-12-02 22:42:25.000000000 +0100
@@ -193,7 +193,6 @@ void inode_init_once(struct inode *inode
 	mutex_init(&inode->i_mutex);
 	init_rwsem(&inode->i_alloc_sem);
 	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
-	spin_lock_init(&inode->i_data.tree_lock);
 	spin_lock_init(&inode->i_data.i_mmap_lock);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
Index: linux-2.6-rt/include/linux/fs.h
===================================================================
--- linux-2.6-rt.orig/include/linux/fs.h	2006-12-02 22:41:23.000000000 +0100
+++ linux-2.6-rt/include/linux/fs.h	2006-12-02 22:42:25.000000000 +0100
@@ -430,13 +430,12 @@ struct backing_dev_info;
 struct address_space {
 	struct inode		*host;		/* owner: inode, block_device */
 	struct radix_tree_root	page_tree;	/* radix tree of all pages */
-	spinlock_t		tree_lock;	/* and rwlock protecting it */
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
 	spinlock_t		i_mmap_lock;	/* protect tree, count, list */
 	unsigned int		truncate_count;	/* Cover race condition with truncate */
-	unsigned long		__nrpages;	/* number of total pages */
+	atomic_ulong_t		__nrpages;	/* number of total pages */
 	pgoff_t			writeback_index;/* writeback starts here */
 	const struct address_space_operations *a_ops;	/* methods */
 	unsigned long		flags;		/* error bits/gfp mask */
@@ -453,22 +452,22 @@ struct address_space {
 
 static inline void mapping_nrpages_init(struct address_space *mapping)
 {
-	mapping->__nrpages = 0;
+	mapping->__nrpages = (atomic_ulong_t)ATOMIC_ULONG_INIT(0);
 }
 
 static inline unsigned long mapping_nrpages(struct address_space *mapping)
 {
-	return mapping->__nrpages;
+	return atomic_ulong_read(&mapping->__nrpages);
 }
 
 static inline void mapping_nrpages_inc(struct address_space *mapping)
 {
-	mapping->__nrpages++;
+	atomic_ulong_inc(&mapping->__nrpages);
 }
 
 static inline void mapping_nrpages_dec(struct address_space *mapping)
 {
-	mapping->__nrpages--;
+	atomic_ulong_dec(&mapping->__nrpages);
 }
 
 struct block_device {
Index: linux-2.6-rt/mm/filemap.c
===================================================================
--- linux-2.6-rt.orig/mm/filemap.c	2006-12-02 22:42:24.000000000 +0100
+++ linux-2.6-rt/mm/filemap.c	2006-12-02 22:42:25.000000000 +0100
@@ -115,8 +115,11 @@ generic_file_direct_IO(int rw, struct ki
 void __remove_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
+	DECLARE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
 
+	radix_tree_lock(&ctx);
 	radix_tree_delete(&mapping->page_tree, page->index);
+	radix_tree_unlock(&ctx);
 	page->mapping = NULL;
 	mapping_nrpages_dec(mapping);
 	__dec_zone_page_state(page, NR_FILE_PAGES);
@@ -129,9 +132,7 @@ void remove_from_page_cache(struct page 
 	BUG_ON(!PageLocked(page));
 
 	lock_page_ref_irq(page);
-	spin_lock(&mapping->tree_lock);
 	__remove_from_page_cache(page);
-	spin_unlock(&mapping->tree_lock);
 	unlock_page_ref_irq(page);
 }
 
@@ -442,9 +443,12 @@ int add_to_page_cache(struct page *page,
 	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 
 	if (error == 0) {
+		DECLARE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
+
 		lock_page_ref_irq(page);
-		spin_lock(&mapping->tree_lock);
+		radix_tree_lock(&ctx);
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
+		radix_tree_unlock(&ctx);
 		if (!error) {
 			page_cache_get(page);
 			SetPageLocked(page);
@@ -453,7 +457,6 @@ int add_to_page_cache(struct page *page,
 			mapping_nrpages_inc(mapping);
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
-		spin_unlock(&mapping->tree_lock);
 		unlock_page_ref_irq(page);
 		radix_tree_preload_end();
 	}
Index: linux-2.6-rt/mm/migrate.c
===================================================================
--- linux-2.6-rt.orig/mm/migrate.c	2006-12-02 22:42:24.000000000 +0100
+++ linux-2.6-rt/mm/migrate.c	2006-12-02 22:42:25.000000000 +0100
@@ -295,6 +295,7 @@ static int migrate_page_move_mapping(str
 		struct page *newpage, struct page *page)
 {
 	void **pslot;
+	struct radix_tree_context ctx;
 
 	if (!mapping) {
 		/* Anonymous page */
@@ -303,15 +304,15 @@ static int migrate_page_move_mapping(str
 		return 0;
 	}
 
+	init_radix_tree_context(&context, &mapping->page_tree);
 	lock_page_ref_irq(page);
-	spin_lock(&mapping->tree_lock);
-
+	radix_tree_lock(&ctx);
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
 
 	if (page_count(page) != 2 + !!PagePrivate(page) ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
-		spin_unlock(&mapping->tree_lock);
+		radix_tree_unlock(&ctx);
 		unlock_page_ref_irq(page);
 		return -EAGAIN;
 	}
@@ -329,7 +330,7 @@ static int migrate_page_move_mapping(str
 
 	radix_tree_replace_slot(pslot, newpage);
 	page->mapping = NULL;
-  	spin_unlock(&mapping->tree_lock);
+	radix_tree_unlock(&ctx);
 	unlock_page_ref_irq(page);
 
 	/*
Index: linux-2.6-rt/mm/page-writeback.c
===================================================================
--- linux-2.6-rt.orig/mm/page-writeback.c	2006-12-02 22:42:24.000000000 +0100
+++ linux-2.6-rt/mm/page-writeback.c	2006-12-02 22:42:25.000000000 +0100
@@ -763,17 +763,19 @@ int __set_page_dirty_nobuffers(struct pa
 
 		if (mapping) {
 			lock_page_ref_irq(page);
-			spin_lock(&mapping->tree_lock);
 			mapping2 = page_mapping(page);
 			if (mapping2) { /* Race with truncate? */
+				DECLARE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
+
 				BUG_ON(mapping2 != mapping);
 				if (mapping_cap_account_dirty(mapping))
 					__inc_zone_page_state(page,
 								NR_FILE_DIRTY);
+				radix_tree_lock(&ctx);
 				radix_tree_tag_set(&mapping->page_tree,
 					page_index(page), PAGECACHE_TAG_DIRTY);
+				radix_tree_unlock(&ctx);
 			}
-			spin_unlock(&mapping->tree_lock);
 			unlock_page_ref_irq(page);
 			if (mapping->host) {
 				/* !PageAnon && !swapper_space */
@@ -855,12 +857,14 @@ int test_clear_page_dirty(struct page *p
 
 	if (mapping) {
 		lock_page_ref_irqsave(page, flags);
-		spin_lock(&mapping->tree_lock);
 		if (TestClearPageDirty(page)) {
+			DECLARE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
+
+			radix_tree_lock(&ctx);
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
-			spin_unlock(&mapping->tree_lock);
+			radix_tree_unlock(&ctx);
 			unlock_page_ref_irqrestore(page, flags);
 			/*
 			 * We can continue to use `mapping' here because the
@@ -872,7 +876,6 @@ int test_clear_page_dirty(struct page *p
 			}
 			return 1;
 		}
-		spin_unlock(&mapping->tree_lock);
 		unlock_page_ref_irqrestore(page, flags);
 		return 0;
 	}
@@ -921,13 +924,16 @@ int test_clear_page_writeback(struct pag
 		unsigned long flags;
 
 		lock_page_ref_irqsave(page, flags);
-		spin_lock(&mapping->tree_lock);
 		ret = TestClearPageWriteback(page);
-		if (ret)
+		if (ret) {
+			DECLARE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
+
+			radix_tree_lock(&ctx);
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-		spin_unlock(&mapping->tree_lock);
+			radix_tree_unlock(&ctx);
+		}
 		unlock_page_ref_irqrestore(page, flags);
 	} else {
 		ret = TestClearPageWriteback(page);
@@ -942,19 +948,24 @@ int test_set_page_writeback(struct page 
 
 	if (mapping) {
 		unsigned long flags;
+		DECLARE_RADIX_TREE_CONTEXT(ctx, &mapping->page_tree);
 
 		lock_page_ref_irqsave(page, flags);
-		spin_lock(&mapping->tree_lock);
 		ret = TestSetPageWriteback(page);
-		if (!ret)
+		if (!ret) {
+			radix_tree_lock(&ctx);
 			radix_tree_tag_set(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-		if (!PageDirty(page))
+			radix_tree_unlock(&ctx);
+		}
+		if (!PageDirty(page)) {
+			radix_tree_lock(&ctx);
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
-		spin_unlock(&mapping->tree_lock);
+			radix_tree_unlock(&ctx);
+		}
 		unlock_page_ref_irqrestore(page, flags);
 	} else {
 		ret = TestSetPageWriteback(page);
Index: linux-2.6-rt/mm/swap_state.c
===================================================================
--- linux-2.6-rt.orig/mm/swap_state.c	2006-12-02 22:42:24.000000000 +0100
+++ linux-2.6-rt/mm/swap_state.c	2006-12-02 22:43:25.000000000 +0100
@@ -38,7 +38,6 @@ static struct backing_dev_info swap_back
 
 struct address_space swapper_space = {
 	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
-	.tree_lock	= __SPIN_LOCK_UNLOCKED(swapper_space.tree_lock),
 	.a_ops		= &swap_aops,
 	.i_mmap_nonlinear = LIST_HEAD_INIT(swapper_space.i_mmap_nonlinear),
 	.backing_dev_info = &swap_backing_dev_info,
@@ -78,10 +77,13 @@ static int __add_to_swap_cache(struct pa
 	BUG_ON(PagePrivate(page));
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
+		DECLARE_RADIX_TREE_CONTEXT(ctx, &swapper_space.page_tree);
+
 		lock_page_ref_irq(page);
-		spin_lock(&swapper_space.tree_lock);
+		radix_tree_lock(&ctx);
 		error = radix_tree_insert(&swapper_space.page_tree,
 						entry.val, page);
+		radix_tree_unlock(&ctx);
 		if (!error) {
 			page_cache_get(page);
 			SetPageLocked(page);
@@ -90,7 +92,6 @@ static int __add_to_swap_cache(struct pa
 			mapping_nrpages_inc(&swapper_space);
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
-		spin_unlock(&swapper_space.tree_lock);
 		unlock_page_ref_irq(page);
 		radix_tree_preload_end();
 	}
@@ -125,12 +126,16 @@ static int add_to_swap_cache(struct page
  */
 void __delete_from_swap_cache(struct page *page)
 {
+	DECLARE_RADIX_TREE_CONTEXT(ctx, &swapper_space.page_tree);
+
 	BUG_ON(!PageLocked(page));
 	BUG_ON(!PageSwapCache(page));
 	BUG_ON(PageWriteback(page));
 	BUG_ON(PagePrivate(page));
 
+	radix_tree_lock(&ctx);
 	radix_tree_delete(&swapper_space.page_tree, page_private(page));
+	radix_tree_unlock(&ctx);
 	set_page_private(page, 0);
 	ClearPageSwapCache(page);
 	mapping_nrpages_dec(&swapper_space);
@@ -203,9 +208,7 @@ void delete_from_swap_cache(struct page 
 	entry.val = page_private(page);
 
 	lock_page_ref_irq(page);
-	spin_lock(&swapper_space.tree_lock);
 	__delete_from_swap_cache(page);
-	spin_unlock(&swapper_space.tree_lock);
 	unlock_page_ref_irq(page);
 
 	swap_free(entry);
Index: linux-2.6-rt/mm/swapfile.c
===================================================================
--- linux-2.6-rt.orig/mm/swapfile.c	2006-12-02 22:42:24.000000000 +0100
+++ linux-2.6-rt/mm/swapfile.c	2006-12-02 22:42:25.000000000 +0100
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
Index: linux-2.6-rt/mm/truncate.c
===================================================================
--- linux-2.6-rt.orig/mm/truncate.c	2006-12-02 22:42:24.000000000 +0100
+++ linux-2.6-rt/mm/truncate.c	2006-12-02 22:42:25.000000000 +0100
@@ -305,19 +305,16 @@ invalidate_complete_page2(struct address
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
Index: linux-2.6-rt/mm/vmscan.c
===================================================================
--- linux-2.6-rt.orig/mm/vmscan.c	2006-12-02 22:42:24.000000000 +0100
+++ linux-2.6-rt/mm/vmscan.c	2006-12-02 22:42:25.000000000 +0100
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

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
