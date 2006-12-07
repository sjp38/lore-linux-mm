Message-Id: <20061207162737.892046000@chello.nl>
References: <20061207161800.426936000@chello.nl>
Date: Thu, 07 Dec 2006 17:18:15 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 15/16] mm: lock_page_ref
Content-Disposition: inline; filename=lock_page_ref.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Change the PG_nonewref operations into locking primitives and place them
so that they provide page level serialization with regard to the page_tree
operations. (basically replace the tree_lock with a per page lock).

The normal page lock has sufficiently different (and overlapping) scope and
protection rules that this second lock is needed.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/buffer.c             |    6 ++-
 include/linux/pagemap.h |   76 ++++++++++++++++++++++++++++++++----------------
 mm/filemap.c            |   14 +++++---
 mm/migrate.c            |   12 +++----
 mm/page-writeback.c     |   27 +++++++++++------
 mm/swap_state.c         |   14 +++++---
 mm/swapfile.c           |    6 ++-
 mm/truncate.c           |    9 +++--
 mm/vmscan.c             |   14 ++++----
 9 files changed, 112 insertions(+), 66 deletions(-)

Index: linux-2.6-rt/include/linux/pagemap.h
===================================================================
--- linux-2.6-rt.orig/include/linux/pagemap.h	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/include/linux/pagemap.h	2006-12-02 22:25:18.000000000 +0100
@@ -75,55 +75,81 @@ static inline wait_queue_head_t *page_wa
 extern int __sleep_on_page(void *);
 
 #ifndef CONFIG_PREEMPT_RT
-static inline void set_page_no_new_refs(struct page *page)
+static inline void lock_page_ref(struct page *page)
 {
-	VM_BUG_ON(PageNoNewRefs(page));
 	preempt_disable();
-	SetPageNoNewRefs(page);
+	bit_spin_lock(PG_nonewrefs, &page->flags);
 	smp_wmb();
 }
 
-static inline void end_page_no_new_refs(struct page *page)
+static inline void unlock_page_ref(struct page *page)
 {
-	VM_BUG_ON(!PageNoNewRefs(page));
-	smp_wmb();
-	ClearPageNoNewRefs(page);
+	bit_spin_unlock(PG_nonewrefs, &page->flags);
 	preempt_enable();
 }
 
-static inline void wait_on_new_refs(struct page *page)
+static inline void wait_on_unlock_page_ref(struct page *page)
 {
-	while (unlikely(PageNoNewRefs(page)))
+	while (unlikely(test_bit(PG_nonewrefs, &page->flags)))
 		cpu_relax();
 }
 #else
-static inline void set_page_no_new_refs(struct page *page)
+/*
+ * open coded sleeping bit lock, yay!
+ */
+static inline void wait_on_unlock_page_ref(struct page *page)
 {
-	VM_BUG_ON(PageNoNewRefs(page));
-	SetPageNoNewRefs(page);
+	might_sleep();
+	if (unlikely(PageNoNewRefs(page))) {
+		DEFINE_WAIT_BIT(wait, &page->flags, PG_nonewrefs);
+		__wait_on_bit(page_waitqueue(page), &wait, __sleep_on_page,
+				TASK_UNINTERRUPTIBLE);
+	}
+}
+
+static inline void lock_page_ref(struct page *page)
+{
+	while (test_and_set_bit(PG_nonewrefs, &page->flags))
+		wait_on_unlock_page_ref(page);
+	__acquire(bitlock);
 	smp_wmb();
 }
 
-static inline void end_page_no_new_refs(struct page *page)
+static inline void unlock_page_ref(struct page *page)
 {
 	VM_BUG_ON(!PageNoNewRefs(page));
-	smp_wmb();
+	smp_mb__before_clear_bit();
 	ClearPageNoNewRefs(page);
 	smp_mb__after_clear_bit();
 	__wake_up_bit(page_waitqueue(page), &page->flags, PG_nonewrefs);
-}
-
-static inline void wait_on_new_refs(struct page *page)
-{
-	might_sleep();
-	if (unlikely(PageNoNewRefs(page))) {
-		DEFINE_WAIT_BIT(wait, &page->flags, PG_nonewrefs);
-		__wait_on_bit(page_waitqueue(page), &wait, __sleep_on_page,
-				TASK_UNINTERRUPTIBLE);
-	}
+	__release(bitlock);
 }
 #endif
 
+#define lock_page_ref_irq(page)				\
+do {							\
+	local_irq_disable_nort();			\
+	lock_page_ref(page);				\
+} while (0)
+
+#define unlock_page_ref_irq(page)			\
+do {							\
+	unlock_page_ref(page);				\
+	local_irq_enable_nort();			\
+} while (0)
+
+#define lock_page_ref_irqsave(page, flags)		\
+do {							\
+	local_irq_save_nort(flags);			\
+	lock_page_ref(page);				\
+} while (0)
+
+#define unlock_page_ref_irqrestore(page, flags)		\
+do {							\
+	unlock_page_ref(page);				\
+	local_irq_restore_nort(flags);			\
+} while (0)
+
 /*
  * speculatively take a reference to a page.
  * If the page is free (_count == 0), then _count is untouched, and 0
@@ -199,7 +225,7 @@ static inline int page_cache_get_specula
 	 * page refcount has been raised. See below comment.
 	 */
 
-	wait_on_new_refs(page);
+	wait_on_unlock_page_ref(page);
 
 	/*
 	 * smp_rmb is to ensure the load of page->flags (for PageNoNewRefs())
Index: linux-2.6-rt/mm/filemap.c
===================================================================
--- linux-2.6-rt.orig/mm/filemap.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/mm/filemap.c	2006-12-02 22:25:04.000000000 +0100
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
-		set_page_no_new_refs(page);
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
-		end_page_no_new_refs(page);
+		spin_unlock(&mapping->tree_lock);
+		unlock_page_ref_irq(page);
 		radix_tree_preload_end();
 	}
 	return error;
Index: linux-2.6-rt/mm/migrate.c
===================================================================
--- linux-2.6-rt.orig/mm/migrate.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/mm/migrate.c	2006-12-02 22:25:04.000000000 +0100
@@ -303,16 +303,16 @@ static int migrate_page_move_mapping(str
 		return 0;
 	}
 
-	set_page_no_new_refs(page);
-	spin_lock_irq(&mapping->tree_lock);
+	lock_page_ref_irq(page);
+	spin_lock(&mapping->tree_lock);
 
 	pslot = radix_tree_lookup_slot(&mapping->page_tree,
  					page_index(page));
 
 	if (page_count(page) != 2 + !!PagePrivate(page) ||
 			(struct page *)radix_tree_deref_slot(pslot) != page) {
-		spin_unlock_irq(&mapping->tree_lock);
-		end_page_no_new_refs(page);
+		spin_unlock(&mapping->tree_lock);
+		unlock_page_ref_irq(page);
 		return -EAGAIN;
 	}
 
@@ -329,8 +329,8 @@ static int migrate_page_move_mapping(str
 
 	radix_tree_replace_slot(pslot, newpage);
 	page->mapping = NULL;
-  	spin_unlock_irq(&mapping->tree_lock);
-	end_page_no_new_refs(page);
+  	spin_unlock(&mapping->tree_lock);
+	unlock_page_ref_irq(page);
 
 	/*
 	 * Drop cache reference from old page.
Index: linux-2.6-rt/mm/swap_state.c
===================================================================
--- linux-2.6-rt.orig/mm/swap_state.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/mm/swap_state.c	2006-12-02 22:25:04.000000000 +0100
@@ -78,8 +78,8 @@ static int __add_to_swap_cache(struct pa
 	BUG_ON(PagePrivate(page));
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
-		set_page_no_new_refs(page);
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
-		end_page_no_new_refs(page);
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
Index: linux-2.6-rt/mm/vmscan.c
===================================================================
--- linux-2.6-rt.orig/mm/vmscan.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/mm/vmscan.c	2006-12-02 22:25:04.000000000 +0100
@@ -390,8 +390,8 @@ int remove_mapping(struct address_space 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(mapping != page_mapping(page));
 
-	set_page_no_new_refs(page);
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
-	end_page_no_new_refs(page);
+	unlock_page_ref_irq(page);
 	__put_page(page); /* The pagecache ref */
 	return 1;
 
 cannot_free:
-	spin_unlock_irq(&mapping->tree_lock);
-	end_page_no_new_refs(page);
+	spin_unlock(&mapping->tree_lock);
+	unlock_page_ref_irq(page);
 	return 0;
 }
 
Index: linux-2.6-rt/fs/buffer.c
===================================================================
--- linux-2.6-rt.orig/fs/buffer.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/fs/buffer.c	2006-12-02 22:25:04.000000000 +0100
@@ -719,7 +719,8 @@ int __set_page_dirty_buffers(struct page
 	spin_unlock(&mapping->private_lock);
 
 	if (!TestSetPageDirty(page)) {
-		spin_lock_irq(&mapping->tree_lock);
+		lock_page_ref_irq(page);
+		spin_lock(&mapping->tree_lock);
 		if (page->mapping) {	/* Race with truncate? */
 			if (mapping_cap_account_dirty(mapping))
 				__inc_zone_page_state(page, NR_FILE_DIRTY);
@@ -727,7 +728,8 @@ int __set_page_dirty_buffers(struct page
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
 		}
-		spin_unlock_irq(&mapping->tree_lock);
+		spin_unlock(&mapping->tree_lock);
+		unlock_page_ref_irq(page);
 		__mark_inode_dirty(mapping->host, I_DIRTY_PAGES);
 		return 1;
 	}
Index: linux-2.6-rt/mm/page-writeback.c
===================================================================
--- linux-2.6-rt.orig/mm/page-writeback.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/mm/page-writeback.c	2006-12-02 22:25:04.000000000 +0100
@@ -762,7 +762,8 @@ int __set_page_dirty_nobuffers(struct pa
 		struct address_space *mapping2;
 
 		if (mapping) {
-			spin_lock_irq(&mapping->tree_lock);
+			lock_page_ref_irq(page);
+			spin_lock(&mapping->tree_lock);
 			mapping2 = page_mapping(page);
 			if (mapping2) { /* Race with truncate? */
 				BUG_ON(mapping2 != mapping);
@@ -772,7 +773,8 @@ int __set_page_dirty_nobuffers(struct pa
 				radix_tree_tag_set(&mapping->page_tree,
 					page_index(page), PAGECACHE_TAG_DIRTY);
 			}
-			spin_unlock_irq(&mapping->tree_lock);
+			spin_unlock(&mapping->tree_lock);
+			unlock_page_ref_irq(page);
 			if (mapping->host) {
 				/* !PageAnon && !swapper_space */
 				__mark_inode_dirty(mapping->host,
@@ -852,12 +854,14 @@ int test_clear_page_dirty(struct page *p
 	unsigned long flags;
 
 	if (mapping) {
-		spin_lock_irqsave(&mapping->tree_lock, flags);
+		lock_page_ref_irqsave(page, flags);
+		spin_lock(&mapping->tree_lock);
 		if (TestClearPageDirty(page)) {
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
-			spin_unlock_irqrestore(&mapping->tree_lock, flags);
+			spin_unlock(&mapping->tree_lock);
+			unlock_page_ref_irqrestore(page, flags);
 			/*
 			 * We can continue to use `mapping' here because the
 			 * page is locked, which pins the address_space
@@ -868,7 +872,8 @@ int test_clear_page_dirty(struct page *p
 			}
 			return 1;
 		}
-		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		spin_unlock(&mapping->tree_lock);
+		unlock_page_ref_irqrestore(page, flags);
 		return 0;
 	}
 	return TestClearPageDirty(page);
@@ -915,13 +920,15 @@ int test_clear_page_writeback(struct pag
 	if (mapping) {
 		unsigned long flags;
 
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
 	} else {
 		ret = TestClearPageWriteback(page);
 	}
@@ -936,7 +943,8 @@ int test_set_page_writeback(struct page 
 	if (mapping) {
 		unsigned long flags;
 
-		spin_lock_irqsave(&mapping->tree_lock, flags);
+		lock_page_ref_irqsave(page, flags);
+		spin_lock(&mapping->tree_lock);
 		ret = TestSetPageWriteback(page);
 		if (!ret)
 			radix_tree_tag_set(&mapping->page_tree,
@@ -946,7 +954,8 @@ int test_set_page_writeback(struct page 
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
-		spin_unlock_irqrestore(&mapping->tree_lock, flags);
+		spin_unlock(&mapping->tree_lock);
+		unlock_page_ref_irqrestore(page, flags);
 	} else {
 		ret = TestSetPageWriteback(page);
 	}
Index: linux-2.6-rt/mm/swapfile.c
===================================================================
--- linux-2.6-rt.orig/mm/swapfile.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/mm/swapfile.c	2006-12-02 22:25:04.000000000 +0100
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
 
Index: linux-2.6-rt/mm/truncate.c
===================================================================
--- linux-2.6-rt.orig/mm/truncate.c	2006-12-02 22:23:42.000000000 +0100
+++ linux-2.6-rt/mm/truncate.c	2006-12-02 22:25:04.000000000 +0100
@@ -304,18 +304,21 @@ invalidate_complete_page2(struct address
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
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
