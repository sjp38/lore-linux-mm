Message-Id: <20061207162736.640234000@chello.nl>
References: <20061207161800.426936000@chello.nl>
Date: Thu, 07 Dec 2006 17:18:11 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 11/16] mm: change tree_lock into a spinlock
Content-Disposition: inline; filename=tree_lock-to-spinlock.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

with all the read_lock uses of the tree_lock gone, change it into
a spinlock.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/buffer.c                     |    4 ++--
 fs/inode.c                      |    2 +-
 include/asm-arm/cacheflush.h    |    4 ++--
 include/asm-parisc/cacheflush.h |    4 ++--
 include/linux/fs.h              |    2 +-
 mm/filemap.c                    |    8 ++++----
 mm/migrate.c                    |    6 +++---
 mm/page-writeback.c             |   18 +++++++++---------
 mm/swap_state.c                 |   10 +++++-----
 mm/swapfile.c                   |    4 ++--
 mm/truncate.c                   |    6 +++---
 mm/vmscan.c                     |    8 ++++----
 12 files changed, 38 insertions(+), 38 deletions(-)

Index: linux-2.6-rt/fs/buffer.c
===================================================================
--- linux-2.6-rt.orig/fs/buffer.c	2006-11-30 17:44:58.000000000 +0100
+++ linux-2.6-rt/fs/buffer.c	2006-11-30 17:45:17.000000000 +0100
@@ -719,7 +719,7 @@ int __set_page_dirty_buffers(struct page
 	spin_unlock(&mapping->private_lock);
 
 	if (!TestSetPageDirty(page)) {
-		write_lock_irq(&mapping->tree_lock);
+		spin_lock_irq(&mapping->tree_lock);
 		if (page->mapping) {	/* Race with truncate? */
 			if (mapping_cap_account_dirty(mapping))
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
@@ -727,7 +727,7 @@ int __set_page_dirty_buffers(struct page
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
 		}
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 		return 1;
 	}
Index: linux-2.6-rt/include/asm-arm/cacheflush.h
===================================================================
--- linux-2.6-rt.orig/include/asm-arm/cacheflush.h	2006-11-30 17:44:58.000000000 +0100
+++ linux-2.6-rt/include/asm-arm/cacheflush.h	2006-11-30 17:45:17.000000000 +0100
@@ -354,9 +354,9 @@ extern void flush_ptrace_access(struct v
 extern void flush_dcache_page(struct page *);
 
 #define flush_dcache_mmap_lock(mapping) \
-	write_lock_irq(&(mapping)->tree_lock)
+	spin_lock_irq(&(mapping)->tree_lock)
 #define flush_dcache_mmap_unlock(mapping) \
-	write_unlock_irq(&(mapping)->tree_lock)
+	spin_unlock_irq(&(mapping)->tree_lock)
 
 #define flush_icache_user_range(vma,page,addr,len) \
 	flush_dcache_page(page)
Index: linux-2.6-rt/include/asm-parisc/cacheflush.h
===================================================================
--- linux-2.6-rt.orig/include/asm-parisc/cacheflush.h	2006-11-30 17:44:58.000000000 +0100
+++ linux-2.6-rt/include/asm-parisc/cacheflush.h	2006-11-30 17:45:17.000000000 +0100
@@ -57,9 +57,9 @@ flush_user_icache_range(unsigned long st
 extern void flush_dcache_page(struct page *page);
 
 #define flush_dcache_mmap_lock(mapping) \
-	write_lock_irq(&(mapping)->tree_lock)
+	spin_lock_irq(&(mapping)->tree_lock)
 #define flush_dcache_mmap_unlock(mapping) \
-	write_unlock_irq(&(mapping)->tree_lock)
+	spin_unlock_irq(&(mapping)->tree_lock)
 
 #define flush_icache_page(vma,page)	do { flush_kernel_dcache_page(page); flush_kernel_icache_page(page_address(page)); } while (0)
 
Index: linux-2.6-rt/include/linux/fs.h
===================================================================
--- linux-2.6-rt.orig/include/linux/fs.h	2006-11-30 17:44:58.000000000 +0100
+++ linux-2.6-rt/include/linux/fs.h	2006-11-30 17:45:17.000000000 +0100
@@ -430,7 +430,7 @@ struct backing_dev_info;
 struct address_space {
 	struct inode		*host;		/* owner: inode, block_device */
 	struct radix_tree_root	page_tree;	/* radix tree of all pages */
-	rwlock_t		tree_lock;	/* and rwlock protecting it */
+	spinlock_t		tree_lock;	/* and rwlock protecting it */
 	unsigned int		i_mmap_writable;/* count VM_SHARED mappings */
 	struct prio_tree_root	i_mmap;		/* tree of private and shared mappings */
 	struct list_head	i_mmap_nonlinear;/*list VM_NONLINEAR mappings */
Index: linux-2.6-rt/mm/filemap.c
===================================================================
--- linux-2.6-rt.orig/mm/filemap.c	2006-11-30 17:45:17.000000000 +0100
+++ linux-2.6-rt/mm/filemap.c	2006-11-30 17:45:17.000000000 +0100
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
 		set_page_no_new_refs(page);
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
 		end_page_no_new_refs(page);
 		radix_tree_preload_end();
 	}
Index: linux-2.6-rt/mm/migrate.c
===================================================================
--- linux-2.6-rt.orig/mm/migrate.c	2006-11-30 17:44:58.000000000 +0100
+++ linux-2.6-rt/mm/migrate.c	2006-11-30 17:45:17.000000000 +0100
@@ -304,14 +304,14 @@ static int migrate_page_move_mapping(str
 	}
 
 	set_page_no_new_refs(page);
-	write_lock_irq(&mapping->tree_lock);
+	spin_lock_irq(&mapping->tree_lock);
 
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
 
 	if (page_count(page) != 2 + !!PagePrivate(page) ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
-		write_unlock_irq(&mapping->tree_lock);
+		spin_unlock_irq(&mapping->tree_lock);
 		end_page_no_new_refs(page);
 		return -EAGAIN;
 	}
@@ -329,7 +329,7 @@ static int migrate_page_move_mapping(str
 
 	radix_tree_replace_slot(pslot, newpage);
 	page->mapping = NULL;
-  	write_unlock_irq(&mapping->tree_lock);
+  	spin_unlock_irq(&mapping->tree_lock);
 	end_page_no_new_refs(page);
 
 	/*
Index: linux-2.6-rt/mm/page-writeback.c
===================================================================
--- linux-2.6-rt.orig/mm/page-writeback.c	2006-11-30 17:44:58.000000000 +0100
+++ linux-2.6-rt/mm/page-writeback.c	2006-11-30 17:45:17.000000000 +0100
@@ -762,7 +762,7 @@ int __set_page_dirty_nobuffers(struct pa
 		struct address_space *mapping2;
 
 		if (mapping) {
-			write_lock_irq(&mapping->tree_lock);
+			spin_lock_irq(&mapping->tree_lock);
 			mapping2 = page_mapping(page);
 			if (mapping2) { /* Race with truncate? */
 				BUG_ON(mapping2 != mapping);
@@ -772,7 +772,7 @@ int __set_page_dirty_nobuffers(struct pa
 				radix_tree_tag_set(&mapping->page_tree,
 					page_index(page), PAGECACHE_TAG_DIRTY);
 			}
-			write_unlock_irq(&mapping->tree_lock);
+			spin_unlock_irq(&mapping->tree_lock);
 			if (mapping->host) {
 				/* !PageAnon && !swapper_space */
 				__mark_inode_dirty(mapping->host,
@@ -852,12 +852,12 @@ int test_clear_page_dirty(struct page *p
 	unsigned long flags;
 
 	if (mapping) {
-		write_lock_irqsave(&mapping->tree_lock, flags);
+		spin_lock_irqsave(&mapping->tree_lock, flags);
 		if (TestClearPageDirty(page)) {
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
-			write_unlock_irqrestore(&mapping->tree_lock, flags);
+			spin_unlock_irqrestore(&mapping->tree_lock, flags);
 			/*
 			 * We can continue to use `mapping' here because the
 			 * page is locked, which pins the address_space
@@ -868,7 +868,7 @@ int test_clear_page_dirty(struct page *p
 			}
 			return 1;
 		}
-		write_unlock_irqrestore(&mapping->tree_lock, flags);
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 		return 0;
 	}
 	return TestClearPageDirty(page);
@@ -915,13 +915,13 @@ int test_clear_page_writeback(struct pag
 	if (mapping) {
 		unsigned long flags;
 
-		write_lock_irqsave(&mapping->tree_lock, flags);
+		spin_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestClearPageWriteback(page);
 		if (ret)
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-		write_unlock_irqrestore(&mapping->tree_lock, flags);
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
 		ret = TestClearPageWriteback(page);
 	}
@@ -936,7 +936,7 @@ int test_set_page_writeback(struct page 
 	if (mapping) {
 		unsigned long flags;
 
-		write_lock_irqsave(&mapping->tree_lock, flags);
+		spin_lock_irqsave(&mapping->tree_lock, flags);
 		ret = TestSetPageWriteback(page);
 		if (!ret)
 			radix_tree_tag_set(&mapping->page_tree,
@@ -946,7 +946,7 @@ int test_set_page_writeback(struct page 
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
-		write_unlock_irqrestore(&mapping->tree_lock, flags);
+		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
 		ret = TestSetPageWriteback(page);
 	}
Index: linux-2.6-rt/mm/swap_state.c
===================================================================
--- linux-2.6-rt.orig/mm/swap_state.c	2006-11-30 17:44:58.000000000 +0100
+++ linux-2.6-rt/mm/swap_state.c	2006-11-30 17:45:17.000000000 +0100
@@ -38,7 +38,7 @@ static struct backing_dev_info swap_back
 
 struct address_space swapper_space = {
 	.page_tree	= RADIX_TREE_INIT(GFP_ATOMIC|__GFP_NOWARN),
-	.tree_lock	= __RW_LOCK_UNLOCKED(swapper_space.tree_lock),
+	.tree_lock	= __SPIN_LOCK_UNLOCKED(swapper_space.tree_lock),
 	.a_ops		= &swap_aops,
 	.i_mmap_nonlinear = LIST_HEAD_INIT(swapper_space.i_mmap_nonlinear),
 	.backing_dev_info = &swap_backing_dev_info,
@@ -79,7 +79,7 @@ static int __add_to_swap_cache(struct pa
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
 		set_page_no_new_refs(page);
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
 		end_page_no_new_refs(page);
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
Index: linux-2.6-rt/mm/swapfile.c
===================================================================
--- linux-2.6-rt.orig/mm/swapfile.c	2006-11-30 17:44:58.000000000 +0100
+++ linux-2.6-rt/mm/swapfile.c	2006-11-30 17:45:17.000000000 +0100
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
 
Index: linux-2.6-rt/mm/truncate.c
===================================================================
--- linux-2.6-rt.orig/mm/truncate.c	2006-11-30 17:44:58.000000000 +0100
+++ linux-2.6-rt/mm/truncate.c	2006-11-30 17:45:17.000000000 +0100
@@ -304,18 +304,18 @@ invalidate_complete_page2(struct address
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
 
Index: linux-2.6-rt/mm/vmscan.c
===================================================================
--- linux-2.6-rt.orig/mm/vmscan.c	2006-11-30 17:44:58.000000000 +0100
+++ linux-2.6-rt/mm/vmscan.c	2006-11-30 17:45:17.000000000 +0100
@@ -391,7 +391,7 @@ int remove_mapping(struct address_space 
 	BUG_ON(mapping != page_mapping(page));
 
 	set_page_no_new_refs(page);
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
 	end_page_no_new_refs(page);
@@ -440,7 +440,7 @@ free_it:
 	return 1;
 
 cannot_free:
-	write_unlock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 	end_page_no_new_refs(page);
 	return 0;
 }
Index: linux-2.6-rt/fs/inode.c
===================================================================
--- linux-2.6-rt.orig/fs/inode.c	2006-11-30 18:00:49.000000000 +0100
+++ linux-2.6-rt/fs/inode.c	2006-11-30 18:01:08.000000000 +0100
@@ -193,7 +193,7 @@ void inode_init_once(struct inode *inode
 	mutex_init(&inode->i_mutex);
 	init_rwsem(&inode->i_alloc_sem);
 	INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOMIC);
-	rwlock_init(&inode->i_data.tree_lock);
+	spin_lock_init(&inode->i_data.tree_lock);
 	spin_lock_init(&inode->i_data.i_mmap_lock);
 	INIT_LIST_HEAD(&inode->i_data.private_list);
 	spin_lock_init(&inode->i_data.private_lock);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
