Message-Id: <20070128132435.066077000@programming.kicks-ass.net>
References: <20070128131343.628722000@programming.kicks-ass.net>
Date: Sun, 28 Jan 2007 14:13:48 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 05/14] mm: lockless pagecache lookups
Content-Disposition: inline; filename=mm-lockless-pagecache-lookups.patch
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>
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
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/filemap.c        |  133 +++++++++++++++++++++++++++++++++++++---------------
 mm/page-writeback.c |    5 -
 mm/readahead.c      |    6 --
 3 files changed, 101 insertions(+), 43 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2007-01-22 20:10:30.000000000 +0100
+++ linux-2.6/mm/filemap.c	2007-01-22 20:11:03.000000000 +0100
@@ -596,15 +596,31 @@ void fastcall __lock_page_nosync(struct 
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
@@ -644,26 +660,19 @@ struct page *find_lock_page(struct addre
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
@@ -733,13 +742,39 @@ unsigned find_get_pages(struct address_s
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
 
@@ -760,19 +795,44 @@ unsigned find_get_pages_contig(struct ad
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
 
 /**
@@ -793,6 +853,7 @@ unsigned find_get_pages_tag(struct addre
 	unsigned int ret;
 
 	read_lock_irq(&mapping->tree_lock);
+	/* TODO: implement lookup_tag_slot and make this lockless */
 	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
 				(void **)pages, *index, nr_pages, tag);
 	for (i = 0; i < ret; i++)
Index: linux-2.6/mm/readahead.c
===================================================================
--- linux-2.6.orig/mm/readahead.c	2007-01-13 21:04:13.000000000 +0100
+++ linux-2.6/mm/readahead.c	2007-01-22 20:11:03.000000000 +0100
@@ -281,27 +281,25 @@ __do_page_cache_readahead(struct address
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
--- linux-2.6.orig/mm/page-writeback.c	2007-01-22 17:29:38.000000000 +0100
+++ linux-2.6/mm/page-writeback.c	2007-01-22 20:11:03.000000000 +0100
@@ -959,12 +959,11 @@ EXPORT_SYMBOL(test_set_page_writeback);
  */
 int mapping_tagged(struct address_space *mapping, int tag)
 {
-	unsigned long flags;
 	int ret;
 
-	read_lock_irqsave(&mapping->tree_lock, flags);
+	rcu_read_lock();
 	ret = radix_tree_tagged(&mapping->page_tree, tag);
-	read_unlock_irqrestore(&mapping->tree_lock, flags);
+	rcu_read_unlock();
 	return ret;
 }
 EXPORT_SYMBOL(mapping_tagged);

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
