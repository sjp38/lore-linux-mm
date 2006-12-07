Message-Id: <20061207162736.184390000@chello.nl>
References: <20061207161800.426936000@chello.nl>
Date: Thu, 07 Dec 2006 17:18:10 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 10/16] mm: remove find_tylock_page
Content-Disposition: inline; filename=kill-find_trylock_page.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

its the last read_lock user of tree_lock, and since its unused remove
it rather than convert it.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/pagemap.h |    2 --
 mm/filemap.c            |   20 --------------------
 2 files changed, 22 deletions(-)

Index: linux-2.6-rt/mm/filemap.c
===================================================================
--- linux-2.6-rt.orig/mm/filemap.c	2006-11-30 17:24:49.000000000 +0100
+++ linux-2.6-rt/mm/filemap.c	2006-11-30 17:25:29.000000000 +0100
@@ -613,26 +613,6 @@ repeat:
 EXPORT_SYMBOL(find_get_page);
 
 /**
- * find_trylock_page - find and lock a page
- * @mapping: the address_space to search
- * @offset: the page index
- *
- * Same as find_get_page(), but trylock it instead of incrementing the count.
- */
-struct page *find_trylock_page(struct address_space *mapping, unsigned long offset)
-{
-	struct page *page;
-
-	read_lock_irq(&mapping->tree_lock);
-	page = radix_tree_lookup(&mapping->page_tree, offset);
-	if (page && TestSetPageLocked(page))
-		page = NULL;
-	read_unlock_irq(&mapping->tree_lock);
-	return page;
-}
-EXPORT_SYMBOL(find_trylock_page);
-
-/**
  * find_lock_page - locate, pin and lock a pagecache page
  * @mapping: the address_space to search
  * @offset: the page index
Index: linux-2.6-rt/include/linux/pagemap.h
===================================================================
--- linux-2.6-rt.orig/include/linux/pagemap.h	2006-11-30 17:24:59.000000000 +0100
+++ linux-2.6-rt/include/linux/pagemap.h	2006-11-30 17:27:38.000000000 +0100
@@ -251,8 +251,6 @@ extern struct page * find_get_page(struc
 				unsigned long index);
 extern struct page * find_lock_page(struct address_space *mapping,
 				unsigned long index);
-extern __deprecated_for_modules struct page * find_trylock_page(
-			struct address_space *mapping, unsigned long index);
 extern struct page * find_or_create_page(struct address_space *mapping,
 				unsigned long index, gfp_t gfp_mask);
 unsigned find_get_pages(struct address_space *mapping, pgoff_t start,

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
