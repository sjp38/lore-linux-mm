From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061004123055.5637.56407.sendpatchset@linux.site>
In-Reply-To: <20061004123018.5637.93004.sendpatchset@linux.site>
References: <20061004123018.5637.93004.sendpatchset@linux.site>
Subject: [patch 4/4] mm: lockless pagecache lookups
Date: Wed,  4 Oct 2006 16:37:34 +0200 (CEST)
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

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -577,22 +577,15 @@ EXPORT_SYMBOL(unlock_page);
 
 /*
  * Probing page existence.
- */
-int __probe_page(struct address_space *mapping, pgoff_t offset)
-{
-	return !! radix_tree_lookup(&mapping->page_tree, offset);
-}
-
-/*
- * Here we just do not bother to grab the page, it's meaningless anyway.
+ * We do not bother to take a ref to the page, it's meaningless anyway.
  */
 int probe_page(struct address_space *mapping, pgoff_t offset)
 {
 	int exists;
 
-	read_lock_irq(&mapping->tree_lock);
-	exists = __probe_page(mapping, offset);
-	read_unlock_irq(&mapping->tree_lock);
+	rcu_read_lock();
+	exists = !!radix_tree_lookup(&mapping->page_tree, offset);
+	rcu_read_unlock();
 
 	return exists;
 }
@@ -666,15 +659,31 @@ void fastcall __lock_page_nosync(struct 
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
@@ -714,26 +723,19 @@ struct page *find_lock_page(struct addre
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
@@ -803,13 +805,39 @@ unsigned find_get_pages(struct address_s
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
@@ -831,19 +859,44 @@ unsigned find_get_pages_contig(struct ad
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
 
@@ -865,6 +918,7 @@ unsigned find_get_pages_tag(struct addre
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
@@ -1358,14 +1356,14 @@ static pgoff_t find_segtail(struct addre
 	read_lock_irq(&mapping->tree_lock);
 	ra_index = radix_tree_scan_hole(&mapping->page_tree, index, max_scan);
 #ifdef DEBUG_READAHEAD_RADIXTREE
-	BUG_ON(!__probe_page(mapping, index));
+	BUG_ON(!probe_page(mapping, index));
 	WARN_ON(ra_index < index);
-	if (ra_index != index && !__probe_page(mapping, ra_index - 1))
+	if (ra_index != index && !probe_page(mapping, ra_index - 1))
 		printk(KERN_ERR "radix_tree_scan_hole(index=%lu ra_index=%lu "
 				"max_scan=%lu nrpages=%lu) fooled!\n",
 				index, ra_index, max_scan, mapping->nrpages);
 	if (ra_index != ~0UL && ra_index - index < max_scan)
-		WARN_ON(__probe_page(mapping, ra_index));
+		WARN_ON(probe_page(mapping, ra_index));
 #endif
 	read_unlock_irq(&mapping->tree_lock);
 
@@ -1390,13 +1388,10 @@ static pgoff_t find_segtail_backward(str
 	 * Poor man's radix_tree_scan_data_backward() implementation.
 	 * Acceptable because max_scan won't be large.
 	 */
-	read_lock_irq(&mapping->tree_lock);
-	for (; origin - index < max_scan;)
-		if (__probe_page(mapping, --index)) {
-			read_unlock_irq(&mapping->tree_lock);
+	for (; origin - index < max_scan;) {
+		if (probe_page(mapping, --index))
 			return index + 1;
-		}
-	read_unlock_irq(&mapping->tree_lock);
+	}
 
 	return 0;
 }
@@ -1453,9 +1448,9 @@ static unsigned long query_page_cache_se
 #ifdef DEBUG_READAHEAD_RADIXTREE
 	WARN_ON(index > offset - 1);
 	if (index != offset - 1)
-		WARN_ON(!__probe_page(mapping, index + 1));
+		WARN_ON(!probe_page(mapping, index + 1));
 	if (index && offset - 1 - index < ra_max)
-		WARN_ON(__probe_page(mapping, index));
+		WARN_ON(probe_page(mapping, index));
 #endif
 
 	*remain = (offset - 1) - index;
@@ -1485,7 +1480,7 @@ static unsigned long query_page_cache_se
 						100 / (readahead_ratio | 1);
 
 	for (count += ra_max; count < nr_lookback; count += ra_max)
-		if (!__probe_page(mapping, offset - count))
+		if (!probe_page(mapping, offset - count))
 			break;
 
 out_unlock:
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -965,17 +965,15 @@ void writeback_congestion_end(void)
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
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -173,7 +173,6 @@ static inline struct page *page_cache_al
 
 typedef int filler_t(void *, struct page *);
 
-extern int __probe_page(struct address_space *mapping, pgoff_t offset);
 extern int probe_page(struct address_space *mapping, pgoff_t offset);
 extern struct page * find_get_page(struct address_space *mapping,
 				unsigned long index);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
