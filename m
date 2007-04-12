From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070412103308.5564.94633.sendpatchset@linux.site>
In-Reply-To: <20070412103151.5564.16127.sendpatchset@linux.site>
References: <20070412103151.5564.16127.sendpatchset@linux.site>
Subject: [patch 7/9] mm: lockless pagecache lookups
Date: Thu, 12 Apr 2007 14:45:58 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
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
@@ -594,15 +594,35 @@ void fastcall __lock_page_nosync(struct 
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
+		/*
+		 * Has the page moved?
+		 * This is part of the lockless pagecache protocol. See
+		 * include/linux/pagemap.h for details.
+		 */
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
@@ -623,25 +643,16 @@ struct page *find_lock_page(struct addre
 	struct page *page;
 
 repeat:
-	read_lock_irq(&mapping->tree_lock);
-	page = radix_tree_lookup(&mapping->page_tree, offset);
+	page = find_get_page(mapping, offset);
 	if (page) {
-		page_cache_get(page);
-		if (TestSetPageLocked(page)) {
-			read_unlock_irq(&mapping->tree_lock);
-			__lock_page(page);
-
-			/* Has the page been truncated while we slept? */
-			if (unlikely(page->mapping != mapping)) {
-				unlock_page(page);
-				page_cache_release(page);
-				goto repeat;
-			}
-			goto out;
+		lock_page(page);
+		/* Has the page been truncated? */
+		if (unlikely(page->mapping != mapping)) {
+			unlock_page(page);
+			page_cache_release(page);
+			goto repeat;
 		}
 	}
-	read_unlock_irq(&mapping->tree_lock);
-out:
 	return page;
 }
 EXPORT_SYMBOL(find_lock_page);
@@ -711,13 +722,39 @@ unsigned find_get_pages(struct address_s
 {
 	unsigned int i;
 	unsigned int ret;
+	unsigned int nr_found;
+
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
 
-	read_lock_irq(&mapping->tree_lock);
-	ret = radix_tree_gang_lookup(&mapping->page_tree,
-				(void **)pages, start, nr_pages);
-	for (i = 0; i < ret; i++)
-		page_cache_get(pages[i]);
-	read_unlock_irq(&mapping->tree_lock);
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
 
@@ -738,19 +775,44 @@ unsigned find_get_pages_contig(struct ad
 {
 	unsigned int i;
 	unsigned int ret;
+	unsigned int nr_found;
+
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
 
-	read_lock_irq(&mapping->tree_lock);
-	ret = radix_tree_gang_lookup(&mapping->page_tree,
-				(void **)pages, index, nr_pages);
-	for (i = 0; i < ret; i++) {
-		if (pages[i]->mapping == NULL || pages[i]->index != index)
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
@@ -769,15 +831,43 @@ unsigned find_get_pages_tag(struct addre
 {
 	unsigned int i;
 	unsigned int ret;
+	unsigned int nr_found;
+
+	rcu_read_lock();
+restart:
+	nr_found = radix_tree_gang_lookup_tag_slot(&mapping->page_tree,
+				(void ***)pages, *index, nr_pages, tag);
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
 
-	read_lock_irq(&mapping->tree_lock);
-	ret = radix_tree_gang_lookup_tag(&mapping->page_tree,
-				(void **)pages, *index, nr_pages, tag);
-	for (i = 0; i < ret; i++)
-		page_cache_get(pages[i]);
 	if (ret)
 		*index = pages[ret - 1]->index + 1;
-	read_unlock_irq(&mapping->tree_lock);
+
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
