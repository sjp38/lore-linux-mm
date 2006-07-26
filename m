Date: Wed, 26 Jul 2006 08:39:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/2] mm: lockless pagecache
Message-ID: <20060726063941.GB32107@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Combine page_cache_get_speculative with lockless radix tree lookups to
introduce lockless page cache lookups (ie. no mapping->tree_lock on
the read-side).

The only atomicity changes this introduces is that the gang pagecache
lookup functions now behave as if they are implemented with multiple
find_get_page calls, rather than operating on a snapshot of the pages.
In practice, this atomicity guarantee is not used anyway, and it is
difficult to see how it could be. Gang pagecache lookups are designed
to replace individual lookups, so these semantics are natural.

Swapcache can no longer use find_get_page, because it has a different
method of encoding swapcache position into the page. Introduce a new
find_get_swap_page for it.

Signed-off-by: Nick Piggin <npiggin@suse.de>

 include/linux/swap.h |    1
 mm/filemap.c         |  161 +++++++++++++++++++++++++++++++++++++--------------
 mm/page-writeback.c  |    8 --
 mm/readahead.c       |    7 --
 mm/swap_state.c      |   27 +++++++-
 mm/swapfile.c        |    2
 6 files changed, 150 insertions(+), 56 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -613,11 +613,22 @@ struct page *find_trylock_page(struct ad
 {
 	struct page *page;
 
-	read_lock_irq(&mapping->tree_lock);
+	rcu_read_lock();
+repeat:
 	page = radix_tree_lookup(&mapping->page_tree, offset);
-	if (page && TestSetPageLocked(page))
-		page = NULL;
-	read_unlock_irq(&mapping->tree_lock);
+	if (page) {
+		page = page_cache_get_speculative(page);
+		if (unlikely(!page))
+			goto repeat;
+		/* Has the page been truncated? */
+		if (unlikely(page->mapping != mapping
+				|| page->index != offset)) {
+			page_cache_release(page);
+			goto repeat;
+		}
+	}
+	rcu_read_unlock();
+
 	return page;
 }
 EXPORT_SYMBOL(find_trylock_page);
@@ -637,26 +648,25 @@ struct page *find_lock_page(struct addre
 {
 	struct page *page;
 
-	read_lock_irq(&mapping->tree_lock);
 repeat:
+	rcu_read_lock();
 	page = radix_tree_lookup(&mapping->page_tree, offset);
 	if (page) {
-		page_cache_get(page);
-		if (TestSetPageLocked(page)) {
-			read_unlock_irq(&mapping->tree_lock);
-			__lock_page(page);
-			read_lock_irq(&mapping->tree_lock);
-
-			/* Has the page been truncated while we slept? */
-			if (unlikely(page->mapping != mapping ||
-				     page->index != offset)) {
-				unlock_page(page);
-				page_cache_release(page);
-				goto repeat;
-			}
+		page = page_cache_get_speculative(page);
+		rcu_read_unlock();
+		if (unlikely(!page))
+			goto repeat;
+		lock_page(page);
+		/* Has the page been truncated? */
+		if (unlikely(page->mapping != mapping
+				|| page->index != offset)) {
+			unlock_page(page);
+			page_cache_release(page);
+			goto repeat;
 		}
-	}
-	read_unlock_irq(&mapping->tree_lock);
+	} else
+		rcu_read_unlock();
+
 	return page;
 }
 EXPORT_SYMBOL(find_lock_page);
@@ -724,16 +734,40 @@ EXPORT_SYMBOL(find_or_create_page);
 unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 			    unsigned int nr_pages, struct page **pages)
 {
+
 	unsigned int i;
-	unsigned int ret;
+	unsigned int nr_found;
 
-	read_lock_irq(&mapping->tree_lock);
-	ret = radix_tree_gang_lookup(&mapping->page_tree,
+	rcu_read_lock();
+repeat:
+	nr_found = radix_tree_gang_lookup(&mapping->page_tree,
 				(void **)pages, start, nr_pages);
-	for (i = 0; i < ret; i++)
-		page_cache_get(pages[i]);
-	read_unlock_irq(&mapping->tree_lock);
-	return ret;
+	for (i = 0; i < nr_found; i++) {
+		struct page *page;
+		page = page_cache_get_speculative(pages[i]);
+		if (unlikely(!page)) {
+bail:
+			/*
+			 * must return at least 1 page, so caller continues
+			 * calling in.
+			 */
+			if (i == 0)
+				goto repeat;
+			break;
+		}
+
+		/* Has the page been truncated? */
+		if (unlikely(page->mapping != mapping
+				|| page->index < start)) {
+			page_cache_release(page);
+			goto bail;
+		}
+
+		/* ensure we don't pick up pages that have moved behind us */
+		start = page->index+1;
+	}
+	rcu_read_unlock();
+	return i;
 }
 
 /**
@@ -752,19 +786,35 @@ unsigned find_get_pages_contig(struct ad
 			       unsigned int nr_pages, struct page **pages)
 {
 	unsigned int i;
-	unsigned int ret;
+	unsigned int nr_found;
 
-	read_lock_irq(&mapping->tree_lock);
-	ret = radix_tree_gang_lookup(&mapping->page_tree,
+	rcu_read_lock();
+repeat:
+	nr_found = radix_tree_gang_lookup(&mapping->page_tree,
 				(void **)pages, index, nr_pages);
-	for (i = 0; i < ret; i++) {
-		if (pages[i]->mapping == NULL || pages[i]->index != index)
+	for (i = 0; i < nr_found; i++) {
+		struct page *page;
+		page = page_cache_get_speculative(pages[i]);
+		if (unlikely(!page)) {
+bail:
+			/*
+			 * must return at least 1 page, so caller continues
+			 * calling in.
+			 */
+			if (i == 0)
+				goto repeat;
 			break;
+		}
 
-		page_cache_get(pages[i]);
+		/* Has the page been truncated? */
+		if (unlikely(page->mapping != mapping
+				|| page->index != index)) {
+			page_cache_release(page);
+			goto bail;
+		}
 		index++;
 	}
-	read_unlock_irq(&mapping->tree_lock);
+	rcu_read_unlock();
 	return i;
 }
 
@@ -783,17 +833,40 @@ unsigned find_get_pages_tag(struct addre
 			int tag, unsigned int nr_pages, struct page **pages)
 {
 	unsigned int i;
-	unsigned int ret;
+	unsigned int nr_found;
+	pgoff_t start = *index;
 
-	read_lock_irq(&mapping->tree_lock);
-	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
-				(void **)pages, *index, nr_pages, tag);
-	for (i = 0; i < ret; i++)
-		page_cache_get(pages[i]);
-	if (ret)
-		*index = pages[ret - 1]->index + 1;
-	read_unlock_irq(&mapping->tree_lock);
-	return ret;
+	rcu_read_lock();
+repeat:
+	nr_found = radix_tree_gang_lookup_tag(&mapping->page_tree,
+				(void **)pages, start, nr_pages, tag);
+	for (i = 0; i < nr_found; i++) {
+		struct page *page;
+		page = page_cache_get_speculative(pages[i]);
+		if (unlikely(!page)) {
+bail:
+			/*
+			 * must return at least 1 page, so caller continues
+			 * calling in.
+			 */
+			if (i == 0)
+				goto repeat;
+			break;
+		}
+
+		/* Has the page been truncated? */
+		if (unlikely(page->mapping != mapping
+				|| page->index < start)) {
+			page_cache_release(page);
+			goto bail;
+		}
+
+		/* ensure we don't pick up pages that have moved behind us */
+		start = page->index+1;
+	}
+	rcu_read_unlock();
+	*index = start;
+	return i;
 }
 
 /**
Index: linux-2.6/mm/readahead.c
===================================================================
--- linux-2.6.orig/mm/readahead.c
+++ linux-2.6/mm/readahead.c
@@ -282,27 +282,26 @@ __do_page_cache_readahead(struct address
 	/*
 	 * Preallocate as many pages as we will need.
 	 */
-	read_lock_irq(&mapping->tree_lock);
 	for (page_idx = 0; page_idx < nr_to_read; page_idx++) {
 		pgoff_t page_offset = offset + page_idx;
 		
 		if (page_offset > end_index)
 			break;
 
+		/* Don't need mapping->tree_lock - lookup can be racy */
+		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->page_tree, page_offset);
+		rcu_read_unlock();
 		if (page)
 			continue;
 
-		read_unlock_irq(&mapping->tree_lock);
 		page = page_cache_alloc_cold(mapping);
-		read_lock_irq(&mapping->tree_lock);
 		if (!page)
 			break;
 		page->index = page_offset;
 		list_add(&page->lru, &page_pool);
 		ret++;
 	}
-	read_unlock_irq(&mapping->tree_lock);
 
 	/*
 	 * Now start the IO.  We ignore I/O errors - if the page is not
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -803,17 +803,15 @@ int test_set_page_writeback(struct page 
 EXPORT_SYMBOL(test_set_page_writeback);
 
 /*
- * Return true if any of the pages in the mapping are marged with the
+ * Return true if any of the pages in the mapping are marked with the
  * passed tag.
  */
 int mapping_tagged(struct address_space *mapping, int tag)
 {
-	unsigned long flags;
 	int ret;
-
-	read_lock_irqsave(&mapping->tree_lock, flags);
+	rcu_read_lock();
 	ret = radix_tree_tagged(&mapping->page_tree, tag);
-	read_unlock_irqrestore(&mapping->tree_lock, flags);
+	rcu_read_unlock();
 	return ret;
 }
 EXPORT_SYMBOL(mapping_tagged);
Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h
+++ linux-2.6/include/linux/swap.h
@@ -226,6 +226,7 @@ extern int move_from_swap_cache(struct p
 		struct address_space *);
 extern void free_page_and_swap_cache(struct page *);
 extern void free_pages_and_swap_cache(struct page **, int);
+extern struct page * find_get_swap_page(swp_entry_t);
 extern struct page * lookup_swap_cache(swp_entry_t);
 extern struct page * read_swap_cache_async(swp_entry_t, struct vm_area_struct *vma,
 					   unsigned long addr);
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -293,6 +293,29 @@ void free_pages_and_swap_cache(struct pa
 	}
 }
 
+struct page *find_get_swap_page(swp_entry_t entry)
+{
+	struct page *page;
+
+	rcu_read_lock();
+repeat:
+	page = radix_tree_lookup(&swapper_space.page_tree, entry.val);
+	if (page) {
+		page = page_cache_get_speculative(page);
+		if (unlikely(!page))
+			goto repeat;
+		/* Has the page been truncated? */
+		if (unlikely(!PageSwapCache(page)
+				|| page_private(page) != entry.val)) {
+			page_cache_release(page);
+			goto repeat;
+		}
+	}
+	rcu_read_unlock();
+
+	return page;
+}
+
 /*
  * Lookup a swap entry in the swap cache. A found page will be returned
  * unlocked and with its refcount incremented - we rely on the kernel
@@ -303,7 +326,7 @@ struct page * lookup_swap_cache(swp_entr
 {
 	struct page *page;
 
-	page = find_get_page(&swapper_space, entry.val);
+	page = find_get_swap_page(entry);
 
 	if (page)
 		INC_CACHE_INFO(find_success);
@@ -330,7 +353,7 @@ struct page *read_swap_cache_async(swp_e
 		 * called after lookup_swap_cache() failed, re-calling
 		 * that would confuse statistics.
 		 */
-		found_page = find_get_page(&swapper_space, entry.val);
+		found_page = find_get_swap_page(entry);
 		if (found_page)
 			break;
 
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -400,7 +400,7 @@ void free_swap_and_cache(swp_entry_t ent
 	p = swap_info_get(entry);
 	if (p) {
 		if (swap_entry_free(p, swp_offset(entry)) == 1) {
-			page = find_get_page(&swapper_space, entry.val);
+			page = find_get_swap_page(entry);
 			if (page && unlikely(TestSetPageLocked(page))) {
 				page_cache_release(page);
 				page = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
