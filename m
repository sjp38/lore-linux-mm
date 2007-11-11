Date: Sun, 11 Nov 2007 09:51:29 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 5/6] mm: spinlock tree_lock
Message-ID: <20071111085129.GH19816@wotan.suse.de>
References: <20071111084556.GC19816@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071111084556.GC19816@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

mapping->tree_lock has no read lockers. convert the lock from an rwlock
to a spinlock.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -704,7 +704,7 @@ static int __set_page_dirty(struct page 
 	if (TestSetPageDirty(page))
 		return 0;
 
-	write_lock_irq(&mapping->tree_lock);
+	spin_lock_irq(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 
@@ -717,7 +717,7 @@ static int __set_page_dirty(struct page 
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
-	write_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 
 	return 1;
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c
+++ linux-2.6/fs/inode.c
@@ -209,7 +209,7 @@ void inode_init_once(struct inode *inode
 	INIT_LIST_HEAD(&inode->i_dentry);
 	INIT_LIST_HEAD(&inode->i_devices);
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
@@ -497,7 +497,7 @@ struct backing_dev_info;
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
@@ -113,7 +113,7 @@ generic_file_direct_IO(int rw, struct ki
 /*
  * Remove a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
- * is safe.  The caller must hold a write_lock on the mapping's tree_lock.
+ * is safe.  The caller must hold the mapping's tree_lock.
  */
 void __remove_from_page_cache(struct page *page)
 {
@@ -132,9 +132,9 @@ void remove_from_page_cache(struct page 
 
 	BUG_ON(!PageLocked(page));
 
-	write_lock_irq(&mapping->tree_lock);
+	spin_lock_irq(&mapping->tree_lock);
 	__remove_from_page_cache(page);
-	write_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 }
 
 static int sync_page(void *word)
@@ -448,13 +448,13 @@ int add_to_page_cache_locked(struct page
 		page->mapping = mapping;
 		page->index = offset;
 
-		write_lock_irq(&mapping->tree_lock);
+		spin_lock_irq(&mapping->tree_lock);
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
 		if (likely(!error)) {
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 		radix_tree_preload_end();
 
 		if (unlikely(error)) {
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
@@ -83,14 +83,14 @@ static int __add_to_swap_cache(struct pa
 		SetPageSwapCache(page);
 		set_page_private(page, entry.val);
 
-		write_lock_irq(&swapper_space.tree_lock);
+		spin_lock_irq(&swapper_space.tree_lock);
 		error = radix_tree_insert(&swapper_space.page_tree,
 						entry.val, page);
 		if (likely(!error)) {
 			total_swapcache_pages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
-		write_unlock_irq(&swapper_space.tree_lock);
+		spin_unlock_irq(&swapper_space.tree_lock);
 		radix_tree_preload_end();
 
 		if (unlikely(error)) {
@@ -209,9 +209,9 @@ void delete_from_swap_cache(struct page 
 
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
@@ -350,18 +350,18 @@ invalidate_complete_page2(struct address
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
@@ -382,7 +382,7 @@ static int __remove_mapping(struct addre
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
-	write_lock_irq(&mapping->tree_lock);
+	spin_lock_irq(&mapping->tree_lock);
 	/*
 	 * The non racy check for a busy page.
 	 *
@@ -417,18 +417,18 @@ static int __remove_mapping(struct addre
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
 		__delete_from_swap_cache(page);
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 		swap_free(swap);
 	} else {
 		__remove_from_page_cache(page);
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 	}
 
 free_it:
 	return 1;
 
 cannot_free:
-	write_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 	return 0;
 }
 
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -1000,7 +1000,7 @@ int __set_page_dirty_nobuffers(struct pa
 		if (!mapping)
 			return 1;
 
-		write_lock_irq(&mapping->tree_lock);
+		spin_lock_irq(&mapping->tree_lock);
 		mapping2 = page_mapping(page);
 		if (mapping2) { /* Race with truncate? */
 			BUG_ON(mapping2 != mapping);
@@ -1014,7 +1014,7 @@ int __set_page_dirty_nobuffers(struct pa
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
 			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
@@ -1170,7 +1170,7 @@ int test_clear_page_writeback(struct pag
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
 
-		write_lock_irqsave(&mapping->tree_lock, flags);
+		spin_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestClearPageWriteback(page);
 		if (ret) {
 			radix_tree_tag_clear(&mapping->page_tree,
@@ -1181,7 +1181,7 @@ int test_clear_page_writeback(struct pag
 				__bdi_writeout_inc(bdi);
 			}
 		}
-		write_unlock_irqrestore(&mapping->tree_lock, flags);
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
 		ret = TestClearPageWriteback(page);
 	}
@@ -1199,7 +1199,7 @@ int test_set_page_writeback(struct page 
 		struct backing_dev_info *bdi = mapping->backing_dev_info;
 		unsigned long flags;
 
-		write_lock_irqsave(&mapping->tree_lock, flags);
+		spin_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestSetPageWriteback(page);
 		if (!ret) {
 			radix_tree_tag_set(&mapping->page_tree,
@@ -1212,7 +1212,7 @@ int test_set_page_writeback(struct page 
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
-		write_unlock_irqrestore(&mapping->tree_lock, flags);
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
 		ret = TestSetPageWriteback(page);
 	}
Index: linux-2.6/include/asm-arm/cacheflush.h
===================================================================
--- linux-2.6.orig/include/asm-arm/cacheflush.h
+++ linux-2.6/include/asm-arm/cacheflush.h
@@ -413,9 +413,9 @@ static inline void flush_anon_page(struc
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
@@ -304,7 +304,7 @@ static int migrate_page_move_mapping(str
 		return 0;
 	}
 
-	write_lock_irq(&mapping->tree_lock);
+	spin_lock_irq(&mapping->tree_lock);
 
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
@@ -312,12 +312,12 @@ static int migrate_page_move_mapping(str
 	expected_count = 2 + !!PagePrivate(page);
 	if (page_count(page) != expected_count ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
 
 	if (!page_freeze_refs(page, expected_count))
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 		return -EAGAIN;
 	}
 
@@ -354,7 +354,7 @@ static int migrate_page_move_mapping(str
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	__inc_zone_page_state(newpage, NR_FILE_PAGES);
 
-	write_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
