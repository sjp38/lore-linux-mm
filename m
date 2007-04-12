From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070412103320.5564.17805.sendpatchset@linux.site>
In-Reply-To: <20070412103151.5564.16127.sendpatchset@linux.site>
References: <20070412103151.5564.16127.sendpatchset@linux.site>
Subject: [patch 8/9] mm: spinlock tree_lock
Date: Thu, 12 Apr 2007 14:46:10 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

mapping->tree_lock has no read lockers. convert the lock from an rwlock
to a spinlock.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -729,7 +729,7 @@ int __set_page_dirty_buffers(struct page
 	if (TestSetPageDirty(page))
 		return 0;
 
-	write_lock_irq(&mapping->tree_lock);
+	spin_lock_irq(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
 		if (mapping_cap_account_dirty(mapping)) {
 			__inc_zone_page_state(page, NR_FILE_DIRTY);
@@ -738,7 +738,7 @@ int __set_page_dirty_buffers(struct page
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
-	write_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	return 1;
 }
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c
+++ linux-2.6/fs/inode.c
@@ -193,7 +193,7 @@ void inode_init_once(struct inode *inode
 	mutex_init(&inode->i_mutex);
 	init_rwsem(&inode->i_alloc_sem);
 	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
-	rwlock_init(&inode->i_data.tree_lock);
+	spin_lock_init(&inode->i_data.tree_lock);
 	spin_lock_init(&inode->i_data.i_mmap_lock);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -434,7 +434,7 @@ struct backing_dev_info;
 struct address_space {
 	struct inode		*host;		/* owner: inode, block_device */
 	struct radix_tree_root	page_tree;	/* radix tree of all pages */
-	rwlock_t		tree_lock;	/* and rwlock protecting it */
+	spinlock_t		tree_lock;	/* and lock protecting it */
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -110,7 +110,7 @@ generic_file_direct_IO(int rw, struct ki
 /*
  * Remove a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
- * is safe.  The caller must hold a write_lock on the mapping's tree_lock.
+ * is safe.  The caller must hold the mapping's tree_lock.
  */
 void __remove_from_page_cache(struct page *page)
 {
@@ -128,9 +128,9 @@ void remove_from_page_cache(struct page 
 
 	BUG_ON(!PageLocked(page));
 
-	write_lock_irq(&mapping->tree_lock);
+	spin_lock_irq(&mapping->tree_lock);
 	__remove_from_page_cache(page);
-	write_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 }
 
 static int sync_page(void *word)
@@ -441,7 +441,7 @@ int add_to_page_cache(struct page *page,
 
 	if (error == 0) {
 		set_page_nonewrefs(page);
-		write_lock_irq(&mapping->tree_lock);
+		spin_lock_irq(&mapping->tree_lock);
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
 		if (!error) {
 			page_cache_get(page);
@@ -451,7 +451,7 @@ int add_to_page_cache(struct page *page,
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 		clear_page_nonewrefs(page);
 		radix_tree_preload_end();
 	}
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -38,7 +38,7 @@ static struct backing_dev_info swap_back
 
 struct address_space swapper_space = {
 	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
-	.tree_lock	= __RW_LOCK_UNLOCKED(swapper_space.tree_lock),
+	.tree_lock	= __SPIN_LOCK_UNLOCKED(swapper_space.tree_lock),
 	.a_ops		= &swap_aops,
 	.i_mmap_nonlinear = LIST_HEAD_INIT(swapper_space.i_mmap_nonlinear),
 	.backing_dev_info = &swap_backing_dev_info,
@@ -80,7 +80,7 @@ static int __add_to_swap_cache(struct pa
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
 		set_page_nonewrefs(page);
-		write_lock_irq(&swapper_space.tree_lock);
+		spin_lock_irq(&swapper_space.tree_lock);
 		error = radix_tree_insert(&swapper_space.page_tree,
 						entry.val, page);
 		if (!error) {
@@ -90,7 +90,7 @@ static int __add_to_swap_cache(struct pa
 			total_swapcache_pages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
-		write_unlock_irq(&swapper_space.tree_lock);
+		spin_unlock_irq(&swapper_space.tree_lock);
 		clear_page_nonewrefs(page);
 		radix_tree_preload_end();
 	}
@@ -202,9 +202,9 @@ void delete_from_swap_cache(struct page 
 
 	entry.val = page_private(page);
 
-	write_lock_irq(&swapper_space.tree_lock);
+	spin_lock_irq(&swapper_space.tree_lock);
 	__delete_from_swap_cache(page);
-	write_unlock_irq(&swapper_space.tree_lock);
+	spin_unlock_irq(&swapper_space.tree_lock);
 
 	swap_free(entry);
 	page_cache_release(page);
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -367,13 +367,13 @@ int remove_exclusive_swap_page(struct pa
 	retval = 0;
 	if (p->swap_map[swp_offset(entry)] == 1) {
 		/* Recheck the page count with the swapcache lock held.. */
-		write_lock_irq(&swapper_space.tree_lock);
+		spin_lock_irq(&swapper_space.tree_lock);
 		if ((page_count(page) == 2) && !PageWriteback(page)) {
 			__delete_from_swap_cache(page);
 			SetPageDirty(page);
 			retval = 1;
 		}
-		write_unlock_irq(&swapper_space.tree_lock);
+		spin_unlock_irq(&swapper_space.tree_lock);
 	}
 	spin_unlock(&swap_lock);
 
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c
+++ linux-2.6/mm/truncate.c
@@ -328,18 +328,18 @@ invalidate_complete_page2(struct address
 	if (PagePrivate(page) && !try_to_release_page(page, GFP_KERNEL))
 		return 0;
 
-	write_lock_irq(&mapping->tree_lock);
+	spin_lock_irq(&mapping->tree_lock);
 	if (PageDirty(page))
 		goto failed;
 
 	BUG_ON(PagePrivate(page));
 	__remove_from_page_cache(page);
-	write_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 	ClearPageUptodate(page);
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
 failed:
-	write_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 	return 0;
 }
 
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -391,7 +391,7 @@ int remove_mapping(struct address_space 
 	BUG_ON(mapping != page_mapping(page));
 
 	set_page_nonewrefs(page);
-	write_lock_irq(&mapping->tree_lock);
+	spin_lock_irq(&mapping->tree_lock);
 	/*
 	 * The non racy check for a busy page.
 	 *
@@ -426,13 +426,13 @@ int remove_mapping(struct address_space 
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
 		__delete_from_swap_cache(page);
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 		swap_free(swap);
 		goto free_it;
 	}
 
 	__remove_from_page_cache(page);
-	write_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 
 free_it:
 	__clear_page_nonewrefs(page);
@@ -440,7 +440,7 @@ free_it:
 	return 1;
 
 cannot_free:
-	write_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 	clear_page_nonewrefs(page);
 	return 0;
 }
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -765,7 +765,7 @@ int __set_page_dirty_no_writeback(struct
  * mapping is pinned by the vma's ->vm_file reference.
  *
  * We take care to handle the case where the page was truncated from the
- * mapping by re-checking page_mapping() insode tree_lock.
+ * mapping by re-checking page_mapping() inside tree_lock.
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
@@ -776,7 +776,7 @@ int __set_page_dirty_nobuffers(struct pa
 		if (!mapping)
 			return 1;
 
-		write_lock_irq(&mapping->tree_lock);
+		spin_lock_irq(&mapping->tree_lock);
 		mapping2 = page_mapping(page);
 		if (mapping2) { /* Race with truncate? */
 			BUG_ON(mapping2 != mapping);
@@ -787,7 +787,7 @@ int __set_page_dirty_nobuffers(struct pa
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
 			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
@@ -919,33 +919,32 @@ EXPORT_SYMBOL(clear_page_dirty_for_io);
 int test_clear_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
-	int ret;
 
 	if (mapping) {
 		unsigned long flags;
+		int ret;
 
-		write_lock_irqsave(&mapping->tree_lock, flags);
+		spin_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestClearPageWriteback(page);
 		if (ret)
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-		write_unlock_irqrestore(&mapping->tree_lock, flags);
-	} else {
-		ret = TestClearPageWriteback(page);
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		return ret;
 	}
-	return ret;
+	return TestClearPageWriteback(page);
 }
 
 int test_set_page_writeback(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
-	int ret;
 
 	if (mapping) {
 		unsigned long flags;
+		int ret;
 
-		write_lock_irqsave(&mapping->tree_lock, flags);
+		spin_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestSetPageWriteback(page);
 		if (!ret)
 			radix_tree_tag_set(&mapping->page_tree,
@@ -955,11 +954,10 @@ int test_set_page_writeback(struct page 
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
-		write_unlock_irqrestore(&mapping->tree_lock, flags);
-	} else {
-		ret = TestSetPageWriteback(page);
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		return ret;
 	}
-	return ret;
+	return TestSetPageWriteback(page);
 
 }
 EXPORT_SYMBOL(test_set_page_writeback);
Index: linux-2.6/include/asm-arm/cacheflush.h
===================================================================
--- linux-2.6.orig/include/asm-arm/cacheflush.h
+++ linux-2.6/include/asm-arm/cacheflush.h
@@ -405,9 +405,9 @@ static inline void flush_anon_page(struc
 }
 
 #define flush_dcache_mmap_lock(mapping) \
-	write_lock_irq(&(mapping)->tree_lock)
+	spin_lock_irq(&(mapping)->tree_lock)
 #define flush_dcache_mmap_unlock(mapping) \
-	write_unlock_irq(&(mapping)->tree_lock)
+	spin_unlock_irq(&(mapping)->tree_lock)
 
 #define flush_icache_user_range(vma,page,addr,len) \
 	flush_dcache_page(page)
Index: linux-2.6/include/asm-parisc/cacheflush.h
===================================================================
--- linux-2.6.orig/include/asm-parisc/cacheflush.h
+++ linux-2.6/include/asm-parisc/cacheflush.h
@@ -45,9 +45,9 @@ void flush_cache_mm(struct mm_struct *mm
 extern void flush_dcache_page(struct page *page);
 
 #define flush_dcache_mmap_lock(mapping) \
-	write_lock_irq(&(mapping)->tree_lock)
+	spin_lock_irq(&(mapping)->tree_lock)
 #define flush_dcache_mmap_unlock(mapping) \
-	write_unlock_irq(&(mapping)->tree_lock)
+	spin_unlock_irq(&(mapping)->tree_lock)
 
 #define flush_icache_page(vma,page)	do { 		\
 	flush_kernel_dcache_page(page);			\
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -304,14 +304,14 @@ static int migrate_page_move_mapping(str
 	}
 
 	set_page_nonewrefs(page);
-	write_lock_irq(&mapping->tree_lock);
+	spin_lock_irq(&mapping->tree_lock);
 
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
 
 	if (page_count(page) != 2 + !!PagePrivate(page) ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 		clear_page_nonewrefs(page);
 		return -EAGAIN;
 	}
@@ -329,7 +329,7 @@ static int migrate_page_move_mapping(str
 
 	radix_tree_replace_slot(pslot, newpage);
 	page->mapping = NULL;
-  	write_unlock_irq(&mapping->tree_lock);
+  	spin_unlock_irq(&mapping->tree_lock);
 	clear_page_nonewrefs(page);
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
