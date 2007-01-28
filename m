Message-Id: <20070128132436.178008000@programming.kicks-ass.net>
References: <20070128131343.628722000@programming.kicks-ass.net>
Date: Sun, 28 Jan 2007 14:13:51 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 08/14] mm: remove find_tylock_page
Content-Disposition: inline; filename=kill-find_trylock_page.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

its the last read_lock user of tree_lock, and since its unused remove
it rather than convert it.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/pagemap.h |    2 --
 mm/filemap.c            |   20 --------------------
 2 files changed, 22 deletions(-)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2007-01-22 20:11:09.000000000 +0100
+++ linux-2.6/mm/filemap.c	2007-01-22 20:11:13.000000000 +0100
@@ -624,26 +624,6 @@ repeat:
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
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2007-01-22 20:11:07.000000000 +0100
+++ linux-2.6/include/linux/pagemap.h	2007-01-22 20:11:13.000000000 +0100
@@ -202,8 +202,6 @@ extern struct page * find_get_page(struc
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
