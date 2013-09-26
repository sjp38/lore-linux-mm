Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 424566B0036
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 10:16:04 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so1219709pdj.3
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:16:03 -0700 (PDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so1192693pbc.29
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 07:16:01 -0700 (PDT)
Message-Id: <20130926141551.554966674@kernel.org>
Date: Thu, 26 Sep 2013 22:14:29 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [RFC 1/4] cleancache: make put_page async possible
References: <20130926141428.392345308@kernel.org>
Content-Disposition: inline; filename=cleancache-async-put_page.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, dan.magenheimer@oracle.com

Previously put_page must store page in sync way. This patch makes it possible
that put_page stores page in async way. To store page in async way, put_page
just increases the page reference, stores the page in other context, and
finally free the page at proper time.

In the page reclaim code path, put_page is called with page reference 0. Since
I need increase page reference, some page reference checks are relieved.

Signed-off-by: Shaohua Li <shli@kernel.org>
---
 include/linux/mm.h      |    5 -----
 include/linux/pagemap.h |    1 -
 mm/filemap.c            |    7 ++++++-
 mm/vmscan.c             |   21 ++++++++++++++++-----
 4 files changed, 22 insertions(+), 12 deletions(-)

Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2013-09-26 21:12:15.479396069 +0800
+++ linux/include/linux/mm.h	2013-09-26 21:12:15.471392582 +0800
@@ -414,11 +414,6 @@ static inline void get_page(struct page
 	if (unlikely(PageTail(page)))
 		if (likely(__get_page_tail(page)))
 			return;
-	/*
-	 * Getting a normal page or the head of a compound page
-	 * requires to already have an elevated page->_count.
-	 */
-	VM_BUG_ON(atomic_read(&page->_count) <= 0);
 	atomic_inc(&page->_count);
 }
 
Index: linux/include/linux/pagemap.h
===================================================================
--- linux.orig/include/linux/pagemap.h	2013-09-26 21:12:15.479396069 +0800
+++ linux/include/linux/pagemap.h	2013-09-26 21:12:15.475394311 +0800
@@ -210,7 +210,6 @@ static inline int page_freeze_refs(struc
 
 static inline void page_unfreeze_refs(struct page *page, int count)
 {
-	VM_BUG_ON(page_count(page) != 0);
 	VM_BUG_ON(count == 0);
 
 	atomic_set(&page->_count, count);
Index: linux/mm/filemap.c
===================================================================
--- linux.orig/mm/filemap.c	2013-09-26 21:12:15.479396069 +0800
+++ linux/mm/filemap.c	2013-09-26 21:12:15.475394311 +0800
@@ -117,17 +117,22 @@ void __delete_from_page_cache(struct pag
 	struct address_space *mapping = page->mapping;
 
 	trace_mm_filemap_delete_from_page_cache(page);
+
+	radix_tree_delete(&mapping->page_tree, page->index);
+
 	/*
 	 * if we're uptodate, flush out into the cleancache, otherwise
 	 * invalidate any existing cleancache entries.  We can't leave
 	 * stale data around in the cleancache once our page is gone
+	 * Do this after page is removed from radix tree. put_page might
+	 * increase refcnt, we don't want to break speculative get page
+	 * protocol.
 	 */
 	if (PageUptodate(page) && PageMappedToDisk(page))
 		cleancache_put_page(page);
 	else
 		cleancache_invalidate_page(mapping, page);
 
-	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
 	mapping->nrpages--;
Index: linux/mm/vmscan.c
===================================================================
--- linux.orig/mm/vmscan.c	2013-09-26 21:12:15.479396069 +0800
+++ linux/mm/vmscan.c	2013-09-26 21:12:15.475394311 +0800
@@ -570,8 +570,7 @@ cannot_free:
 /*
  * Attempt to detach a locked page from its ->mapping.  If it is dirty or if
  * someone else has a ref on the page, abort and return 0.  If it was
- * successfully detached, return 1.  Assumes the caller has a single ref on
- * this page.
+ * successfully detached, return 1.
  */
 int remove_mapping(struct address_space *mapping, struct page *page)
 {
@@ -581,7 +580,7 @@ int remove_mapping(struct address_space
 		 * drops the pagecache ref for us without requiring another
 		 * atomic operation.
 		 */
-		page_unfreeze_refs(page, 1);
+		page_unfreeze_refs(page, 1 + page_count(page));
 		return 1;
 	}
 	return 0;
@@ -782,7 +781,7 @@ static unsigned long shrink_page_list(st
 		struct page *page;
 		int may_enter_fs;
 		enum page_references references = PAGEREF_RECLAIM_CLEAN;
-		bool dirty, writeback;
+		bool dirty, writeback, free_page = true;
 
 		cond_resched();
 
@@ -1049,16 +1048,28 @@ static unsigned long shrink_page_list(st
 			goto keep_locked;
 
 		/*
+		 * there is a case cleancache eats this page, it will free this
+		 * page after the page is unlocked
+		 */
+		free_page = page_count(page) == 0;
+
+		/*
 		 * At this point, we have no other references and there is
 		 * no way to pick any more up (removed from LRU, removed
 		 * from pagecache). Can use non-atomic bitops now (and
 		 * we obviously don't have to worry about waking up a process
 		 * waiting on the page lock, because there are no references.
 		 */
-		__clear_page_locked(page);
+		if (free_page)
+			__clear_page_locked(page);
+		else
+			unlock_page(page);
 free_it:
 		nr_reclaimed++;
 
+		if (!free_page)
+			continue;
+
 		/*
 		 * Is there need to periodically free_page_list? It would
 		 * appear not as the counts should be low

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
