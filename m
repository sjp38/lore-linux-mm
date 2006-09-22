From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060922172120.22370.4933.sendpatchset@linux.site>
In-Reply-To: <20060922172042.22370.62513.sendpatchset@linux.site>
References: <20060922172042.22370.62513.sendpatchset@linux.site>
Subject: [patch 4/9] mm: lockless pagecache lookups
Date: Fri, 22 Sep 2006 21:22:48 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
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

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -590,9 +590,9 @@ int probe_page(struct address_space *map
 {
 	int exists;
 
-	read_lock_irq(&mapping->tree_lock);
+	rcu_read_lock();
 	exists = __probe_page(mapping, offset);
-	read_unlock_irq(&mapping->tree_lock);
+	rcu_read_unlock();
 
 	return exists;
 }
@@ -666,15 +666,31 @@ void fastcall __lock_page_nosync(struct 
  * Is there a pagecache struct page at the given (mapping, offset) tuple?
  * If yes, increment its refcount and return it; if no, return NULL.
  */
-struct page * find_get_page(struct address_space *mapping, unsigned long offset)
+struct page *find_get_page(struct address_space *mapping, unsigned long offset)
 {
+	void **pagep;
 	struct page *page;
 
-	read_lock_irq(&mapping->tree_lock);
-	page = radix_tree_lookup(&mapping->page_tree, offset);
-	if (page)
-		page_cache_get(page);
-	read_unlock_irq(&mapping->tree_lock);
+	rcu_read_lock();
+repeat:
+	page = NULL;
+	pagep = radix_tree_lookup_slot(&mapping->page_tree, offset);
+	if (pagep) {
+		page = radix_tree_deref_slot(pagep);
+		if (unlikely(!page || page == RADIX_TREE_RETRY))
+			goto repeat;
+
+		if (!page_cache_get_speculative(page))
+			goto repeat;
+
+		/* Has the page moved? */
+		if (unlikely(page != *pagep)) {
+			page_cache_release(page);
+			goto repeat;
+		}
+	}
+	rcu_read_unlock();
+
 	return page;
 }
 EXPORT_SYMBOL(find_get_page);
@@ -714,26 +730,19 @@ struct page *find_lock_page(struct addre
 {
 	struct page *page;
 
-	read_lock_irq(&mapping->tree_lock);
 repeat:
-	page = radix_tree_lookup(&mapping->page_tree, offset);
+	page = find_get_page(mapping, offset);
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
+		lock_page(page);
+		/* Has the page been truncated? */
+		if (unlikely(page->mapping != mapping
+				|| page->index != offset)) {
+			unlock_page(page);
+			page_cache_release(page);
+			goto repeat;
 		}
 	}
-	read_unlock_irq(&mapping->tree_lock);
+
 	return page;
 }
 EXPORT_SYMBOL(find_lock_page);
@@ -803,13 +812,39 @@ unsigned find_get_pages(struct address_s
 {
 	unsigned int i;
 	unsigned int ret;
+	unsigned int nr_found;
 
-	read_lock_irq(&mapping->tree_lock);
-	ret = radix_tree_gang_lookup(&mapping->page_tree,
-				(void **)pages, start, nr_pages);
-	for (i = 0; i < ret; i++)
-		page_cache_get(pages[i]);
-	read_unlock_irq(&mapping->tree_lock);
+	rcu_read_lock();
+restart:
+	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
+				(void ***)pages, start, nr_pages);
+	ret = 0;
+	for (i = 0; i < nr_found; i++) {
+		struct page *page;
+repeat:
+		page = radix_tree_deref_slot((void **)pages[i]);
+		if (unlikely(!page))
+			continue;
+		/*
+		 * this can only trigger if nr_found == 1, making livelock
+		 * a non issue.
+		 */
+		if (unlikely(page == RADIX_TREE_RETRY))
+			goto restart;
+
+		if (!page_cache_get_speculative(page))
+			goto repeat;
+
+		/* Has the page moved? */
+		if (unlikely(page != *((void **)pages[i]))) {
+			page_cache_release(page);
+			goto repeat;
+		}
+
+		pages[ret] = page;
+		ret++;
+	}
+	rcu_read_unlock();
 	return ret;
 }
 EXPORT_SYMBOL(find_get_pages);
@@ -831,19 +866,44 @@ unsigned find_get_pages_contig(struct ad
 {
 	unsigned int i;
 	unsigned int ret;
+	unsigned int nr_found;
 
-	read_lock_irq(&mapping->tree_lock);
-	ret = radix_tree_gang_lookup(&mapping->page_tree,
-				(void **)pages, index, nr_pages);
-	for (i = 0; i < ret; i++) {
-		if (pages[i]->mapping == NULL || pages[i]->index != index)
+	rcu_read_lock();
+restart:
+	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
+				(void ***)pages, index, nr_pages);
+	ret = 0;
+	for (i = 0; i < nr_found; i++) {
+		struct page *page;
+repeat:
+		page = radix_tree_deref_slot((void **)pages[i]);
+		if (unlikely(!page))
+			continue;
+		/*
+		 * this can only trigger if nr_found == 1, making livelock
+		 * a non issue.
+		 */
+		if (unlikely(page == RADIX_TREE_RETRY))
+			goto restart;
+
+		if (page->mapping == NULL || page->index != index)
 			break;
 
-		page_cache_get(pages[i]);
+		if (!page_cache_get_speculative(page))
+			goto repeat;
+
+		/* Has the page moved? */
+		if (unlikely(page != *((void **)pages[i]))) {
+			page_cache_release(page);
+			goto repeat;
+		}
+
+		pages[ret] = page;
+		ret++;
 		index++;
 	}
-	read_unlock_irq(&mapping->tree_lock);
-	return i;
+	rcu_read_unlock();
+	return ret;
 }
 EXPORT_SYMBOL(find_get_pages_tag);
 
@@ -865,6 +925,7 @@ unsigned find_get_pages_tag(struct addre
 	unsigned int ret;
 
 	read_lock_irq(&mapping->tree_lock);
+	/* TODO: implement lookup_tag_slot and make this lockless */
 	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
 				(void **)pages, *index, nr_pages, tag);
 	for (i = 0; i < ret; i++)
Index: linux-2.6/mm/readahead.c
===================================================================
--- linux-2.6.orig/mm/readahead.c
+++ linux-2.6/mm/readahead.c
@@ -429,21 +429,20 @@ __do_page_cache_readahead(struct address
 	/*
 	 * Preallocate as many pages as we will need.
 	 */
-	read_lock_irq(&mapping->tree_lock);
 	for (page_idx = 0; page_idx < nr_to_read; page_idx++) {
 		pgoff_t page_offset = offset + page_idx;
 		
 		if (page_offset > end_index)
 			break;
 
+		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->page_tree, page_offset);
+		rcu_read_unlock();
 		if (page)
 			continue;
 
-		read_unlock_irq(&mapping->tree_lock);
 		page = page_cache_alloc_cold(mapping);
 		cond_resched();
-		read_lock_irq(&mapping->tree_lock);
 		if (!page)
 			break;
 		page->index = page_offset;
@@ -452,7 +451,6 @@ __do_page_cache_readahead(struct address
 			SetPageReadahead(page);
 		ret++;
 	}
-	read_unlock_irq(&mapping->tree_lock);
 
 	/*
 	 * Now start the IO.  We ignore I/O errors - if the page is not
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -967,17 +967,15 @@ void writeback_congestion_end(void)
 EXPORT_SYMBOL(writeback_congestion_end);
 
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
