Message-Id: <20070418201605.755579934@chello.nl>
References: <20070418201248.468050288@chello.nl>
Date: Wed, 18 Apr 2007 22:12:51 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 3/6] mm: lock_page_ref
Content-Disposition: inline; filename=lock_page_ref.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: npiggin@suse.de, akpm@linux-foundation.org, clameter@sgi.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Change the PG_nonewref operations into locking primitives and place them
so that they provide page level serialization with regard to the page_tree
operations. (basically replace the tree_lock with a per page lock).

The normal page lock has sufficiently different (and overlapping) scope and
protection rules that this second lock is needed.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/buffer.c             |    6 ++++--
 include/linux/pagemap.h |   44 ++++++++++++++++++++++++++++++++------------
 mm/filemap.c            |   14 ++++++++------
 mm/migrate.c            |   12 ++++++------
 mm/page-writeback.c     |   18 ++++++++++++------
 mm/swap_state.c         |   14 ++++++++------
 mm/swapfile.c           |    6 ++++--
 mm/truncate.c           |    9 ++++++---
 mm/vmscan.c             |   14 +++++++-------
 9 files changed, 87 insertions(+), 50 deletions(-)

Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2007-04-13 12:26:07.000000000 +0200
+++ linux-2.6/include/linux/pagemap.h	2007-04-13 12:26:43.000000000 +0200
@@ -13,6 +13,7 @@
 #include <linux/gfp.h>
 #include <linux/page-flags.h>
 #include <linux/hardirq.h> /* for in_interrupt() */
+#include <linux/bit_spinlock.h>
 
 /*
  * Bits in mapping->flags.  The lower __GFP_BITS_SHIFT bits are the page
@@ -53,6 +54,47 @@ static inline void mapping_set_gfp_mask(
 #define page_cache_release(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);
 
+static inline void lock_page_ref(struct page *page)
+{
+	bit_spin_lock(PG_nonewrefs, &page->flags);
+	smp_wmb();
+}
+
+static inline void unlock_page_ref(struct page *page)
+{
+	bit_spin_unlock(PG_nonewrefs, &page->flags);
+}
+
+static inline void wait_on_page_ref(struct page *page)
+{
+	while (unlikely(test_bit(PG_nonewrefs, &page->flags)))
+		cpu_relax();
+}
+
+#define lock_page_ref_irq(page)					\
+	do {							\
+		local_irq_disable();				\
+		lock_page_ref(page);				\
+	} while (0)
+
+#define unlock_page_ref_irq(page)				\
+	do {							\
+		unlock_page_ref(page);				\
+		local_irq_enable();				\
+	} while (0)
+
+#define lock_page_ref_irqsave(page, flags)			\
+	do {							\
+		local_irq_save(flags);				\
+		lock_page_ref(page);				\
+	} while (0)
+
+#define unlock_page_ref_irqrestore(page, flags)			\
+	do {							\
+		unlock_page_ref(page);				\
+		local_irq_restore(flags);			\
+	} while (0)
+
 /*
  * speculatively take a reference to a page.
  * If the page is free (_count == 0), then _count is untouched, and 0
@@ -128,8 +170,7 @@ static inline int page_cache_get_specula
 	 * page refcount has been raised. See below comment.
 	 */
 
-	while (unlikely(PageNoNewRefs(page)))
-		cpu_relax();
+	wait_on_page_ref(page);
 
 	/*
 	 * smp_rmb is to ensure the load of page->flags (for PageNoNewRefs())
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2007-04-13 12:26:41.000000000 +0200
+++ linux-2.6/mm/filemap.c	2007-04-13 12:26:43.000000000 +0200
@@ -128,9 +128,11 @@ void remove_from_page_cache(struct page 
 
 	BUG_ON(!PageLocked(page));
 
-	spin_lock_irq(&mapping->tree_lock);
+	lock_page_ref_irq(page);
+	spin_lock(&mapping->tree_lock);
 	__remove_from_page_cache(page);
-	spin_unlock_irq(&mapping->tree_lock);
+	spin_unlock(&mapping->tree_lock);
+	unlock_page_ref_irq(page);
 }
 
 static int sync_page(void *word)
@@ -440,8 +442,8 @@ int add_to_page_cache(struct page *page,
 	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 
 	if (error == 0) {
-		set_page_nonewrefs(page);
-		spin_lock_irq(&mapping->tree_lock);
+		lock_page_ref_irq(page);
+		spin_lock(&mapping->tree_lock);
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
 		if (!error) {
 			page_cache_get(page);
@@ -451,8 +453,8 @@ int add_to_page_cache(struct page *page,
 			mapping_nrpages_inc(mapping);
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
-		spin_unlock_irq(&mapping->tree_lock);
-		clear_page_nonewrefs(page);
+		spin_unlock(&mapping->tree_lock);
+		unlock_page_ref_irq(page);
 		radix_tree_preload_end();
 	}
 	return error;
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2007-04-13 12:26:07.000000000 +0200
+++ linux-2.6/mm/migrate.c	2007-04-13 12:26:43.000000000 +0200
@@ -303,16 +303,16 @@ static int migrate_page_move_mapping(str
 		return 0;
 	}
 
-	set_page_nonewrefs(page);
-	spin_lock_irq(&mapping->tree_lock);
+	lock_page_ref_irq(page);
+	spin_lock(&mapping->tree_lock);
 
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
 
 	if (page_count(page) != 2 + !!PagePrivate(page) ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
-		spin_unlock_irq(&mapping->tree_lock);
-		clear_page_nonewrefs(page);
+		spin_unlock(&mapping->tree_lock);
+		unlock_page_ref_irq(page);
 		return -EAGAIN;
 	}
 
@@ -329,8 +329,8 @@ static int migrate_page_move_mapping(str
 
 	radix_tree_replace_slot(pslot, newpage);
 	page->mapping = NULL;
-  	spin_unlock_irq(&mapping->tree_lock);
-	clear_page_nonewrefs(page);
+  	spin_unlock(&mapping->tree_lock);
+	unlock_page_ref_irq(page);
 
 	/*
 	 * Drop cache reference from old page.
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c	2007-04-13 12:26:41.000000000 +0200
+++ linux-2.6/mm/swap_state.c	2007-04-13 12:26:43.000000000 +0200
@@ -79,8 +79,8 @@ static int __add_to_swap_cache(struct pa
 	BUG_ON(PagePrivate(page));
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
-		set_page_nonewrefs(page);
-		spin_lock_irq(&swapper_space.tree_lock);
+		lock_page_ref_irq(page);
+		spin_lock(&swapper_space.tree_lock);
 		error = radix_tree_insert(&swapper_space.page_tree,
 						entry.val, page);
 		if (!error) {
@@ -90,8 +90,8 @@ static int __add_to_swap_cache(struct pa
 			mapping_nrpages_inc(&swapper_space);
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 		}
-		spin_unlock_irq(&swapper_space.tree_lock);
-		clear_page_nonewrefs(page);
+		spin_unlock(&swapper_space.tree_lock);
+		unlock_page_ref_irq(page);
 		radix_tree_preload_end();
 	}
 	return error;
@@ -202,9 +202,11 @@ void delete_from_swap_cache(struct page 
 
 	entry.val = page_private(page);
 
-	spin_lock_irq(&swapper_space.tree_lock);
+	lock_page_ref_irq(page);
+	spin_lock(&swapper_space.tree_lock);
 	__delete_from_swap_cache(page);
-	spin_unlock_irq(&swapper_space.tree_lock);
+	spin_unlock(&swapper_space.tree_lock);
+	unlock_page_ref_irq(page);
 
 	swap_free(entry);
 	page_cache_release(page);
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2007-04-13 12:26:07.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2007-04-13 12:26:43.000000000 +0200
@@ -390,8 +390,8 @@ int remove_mapping(struct address_space 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
-	set_page_nonewrefs(page);
-	spin_lock_irq(&mapping->tree_lock);
+	lock_page_ref_irq(page);
+	spin_lock(&mapping->tree_lock);
 	/*
 	 * The non racy check for a busy page.
 	 *
@@ -426,22 +426,22 @@ int remove_mapping(struct address_space 
 	if (PageSwapCache(page)) {
 		swp_entry_t swap = { .val = page_private(page) };
 		__delete_from_swap_cache(page);
-		spin_unlock_irq(&mapping->tree_lock);
+		spin_unlock(&mapping->tree_lock);
 		swap_free(swap);
 		goto free_it;
 	}
 
 	__remove_from_page_cache(page);
-	spin_unlock_irq(&mapping->tree_lock);
+	spin_unlock(&mapping->tree_lock);
 
 free_it:
-	__clear_page_nonewrefs(page);
+	unlock_page_ref_irq(page);
 	__put_page(page); /* The pagecache ref */
 	return 1;
 
 cannot_free:
-	spin_unlock_irq(&mapping->tree_lock);
-	clear_page_nonewrefs(page);
+	spin_unlock(&mapping->tree_lock);
+	unlock_page_ref_irq(page);
 	return 0;
 }
 
Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c	2007-04-13 12:26:41.000000000 +0200
+++ linux-2.6/fs/buffer.c	2007-04-13 12:26:43.000000000 +0200
@@ -729,7 +729,8 @@ int __set_page_dirty_buffers(struct page
 	if (TestSetPageDirty(page))
 		return 0;
 
-	spin_lock_irq(&mapping->tree_lock);
+	lock_page_ref_irq(page);
+	spin_lock(&mapping->tree_lock);
 	if (page->mapping) {	/* Race with truncate? */
 		if (mapping_cap_account_dirty(mapping)) {
 			__inc_zone_page_state(page, NR_FILE_DIRTY);
@@ -738,7 +739,8 @@ int __set_page_dirty_buffers(struct page
 		radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 	}
-	spin_unlock_irq(&mapping->tree_lock);
+	spin_unlock(&mapping->tree_lock);
+	unlock_page_ref_irq(page);
 	__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 	return 1;
 }
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-04-13 12:26:07.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2007-04-13 12:26:43.000000000 +0200
@@ -776,7 +776,8 @@ int __set_page_dirty_nobuffers(struct pa
 		if (!mapping)
 			return 1;
 
-		spin_lock_irq(&mapping->tree_lock);
+		lock_page_ref_irq(page);
+		spin_lock(&mapping->tree_lock);
 		mapping2 = page_mapping(page);
 		if (mapping2) { /* Race with truncate? */
 			BUG_ON(mapping2 != mapping);
@@ -787,7 +788,8 @@ int __set_page_dirty_nobuffers(struct pa
 			radix_tree_tag_set(&mapping->page_tree,
 				page_index(page), PAGECACHE_TAG_DIRTY);
 		}
-		spin_unlock_irq(&mapping->tree_lock);
+		spin_unlock(&mapping->tree_lock);
+		unlock_page_ref_irq(page);
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
 			__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
@@ -924,13 +926,15 @@ int test_clear_page_writeback(struct pag
 		unsigned long flags;
 		int ret;
 
-		spin_lock_irqsave(&mapping->tree_lock, flags);
+		lock_page_ref_irqsave(page, flags);
+		spin_lock(&mapping->tree_lock);
 		ret = TestClearPageWriteback(page);
 		if (ret)
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		spin_unlock(&mapping->tree_lock);
+		unlock_page_ref_irqrestore(page, flags);
 		return ret;
 	}
 	return TestClearPageWriteback(page);
@@ -944,7 +948,8 @@ int test_set_page_writeback(struct page 
 		unsigned long flags;
 		int ret;
 
-		spin_lock_irqsave(&mapping->tree_lock, flags);
+		lock_page_ref_irqsave(page, flags);
+		spin_lock(&mapping->tree_lock);
 		ret = TestSetPageWriteback(page);
 		if (!ret)
 			radix_tree_tag_set(&mapping->page_tree,
@@ -954,7 +959,8 @@ int test_set_page_writeback(struct page 
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
-		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		spin_unlock(&mapping->tree_lock);
+		unlock_page_ref_irqrestore(page, flags);
 		return ret;
 	}
 	return TestSetPageWriteback(page);
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c	2007-04-13 12:26:07.000000000 +0200
+++ linux-2.6/mm/swapfile.c	2007-04-13 12:26:43.000000000 +0200
@@ -367,13 +367,15 @@ int remove_exclusive_swap_page(struct pa
 	retval = 0;
 	if (p->swap_map[swp_offset(entry)] == 1) {
 		/* Recheck the page count with the swapcache lock held.. */
-		spin_lock_irq(&swapper_space.tree_lock);
+		lock_page_ref_irq(page);
+		spin_lock(&swapper_space.tree_lock);
 		if ((page_count(page) == 2) && !PageWriteback(page)) {
 			__delete_from_swap_cache(page);
 			SetPageDirty(page);
 			retval = 1;
 		}
-		spin_unlock_irq(&swapper_space.tree_lock);
+		spin_unlock(&swapper_space.tree_lock);
+		unlock_page_ref_irq(page);
 	}
 	spin_unlock(&swap_lock);
 
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c	2007-04-13 12:26:41.000000000 +0200
+++ linux-2.6/mm/truncate.c	2007-04-13 12:26:43.000000000 +0200
@@ -328,18 +328,21 @@ invalidate_complete_page2(struct address
 	if (PagePrivate(page) && !try_to_release_page(page, GFP_KERNEL))
 		return 0;
 
-	spin_lock_irq(&mapping->tree_lock);
+	lock_page_ref_irq(page);
+	spin_lock(&mapping->tree_lock);
 	if (PageDirty(page))
 		goto failed;
 
 	BUG_ON(PagePrivate(page));
 	__remove_from_page_cache(page);
-	spin_unlock_irq(&mapping->tree_lock);
+	spin_unlock(&mapping->tree_lock);
+	unlock_page_ref_irq(page);
 	ClearPageUptodate(page);
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
 failed:
-	spin_unlock_irq(&mapping->tree_lock);
+	spin_unlock(&mapping->tree_lock);
+	unlock_page_ref_irq(page);
 	return 0;
 }
 
Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2007-04-13 12:26:07.000000000 +0200
+++ linux-2.6/include/linux/page-flags.h	2007-04-13 12:26:49.000000000 +0200
@@ -273,25 +273,4 @@ static inline void set_page_writeback(st
 	test_set_page_writeback(page);
 }
 
-static inline void set_page_nonewrefs(struct page *page)
-{
-	preempt_disable();
-	SetPageNoNewRefs(page);
-	smp_wmb();
-}
-
-static inline void __clear_page_nonewrefs(struct page *page)
-{
-	smp_wmb();
-	__ClearPageNoNewRefs(page);
-	preempt_enable();
-}
-
-static inline void clear_page_nonewrefs(struct page *page)
-{
-	smp_wmb();
-	ClearPageNoNewRefs(page);
-	preempt_enable();
-}
-
 #endif	/* PAGE_FLAGS_H */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
