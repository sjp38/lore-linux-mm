Date: Mon, 29 Jul 2002 21:39:37 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] nru replacement for 2.5.29
Message-ID: <Pine.LNX.4.44L.0207292136040.3086-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

here is an intermediate stage between use-once and the full
page aging approach used in 2.4-rmap.

Process memory is given a slight priority over unmapped page
cache pages, referenced process pages are given another round
on the active list while unmapped page cache pages are always
moved to the inactive list and only re-used if they are
referenced while on the inactive list.

For streaming IO we do drop_behind() like done in 2.4-rmap,
FreeBSD, NetBSD, OpenBSD, Mach and several other OSes ;)

I haven't done any benchmarks with this patch yet and hope
you will have fun ...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".



# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.476   -> 1.477
#	include/linux/swap.h	1.48    -> 1.49
#	      mm/readahead.c	1.13    -> 1.14
#	         mm/vmscan.c	1.85    -> 1.86
#	        mm/filemap.c	1.114   -> 1.115
#	           mm/swap.c	1.17    -> 1.18
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/07/29	riel@imladris.surriel.com	1.477
# second chance replacement
# --------------------------------------------
#
diff -Nru a/include/linux/swap.h b/include/linux/swap.h
--- a/include/linux/swap.h	Mon Jul 29 21:36:01 2002
+++ b/include/linux/swap.h	Mon Jul 29 21:36:01 2002
@@ -161,6 +161,7 @@
 extern void FASTCALL(lru_cache_del(struct page *));

 extern void FASTCALL(activate_page(struct page *));
+extern void FASTCALL(deactivate_page(struct page *));

 extern void swap_setup(void);

diff -Nru a/mm/filemap.c b/mm/filemap.c
--- a/mm/filemap.c	Mon Jul 29 21:36:01 2002
+++ b/mm/filemap.c	Mon Jul 29 21:36:01 2002
@@ -848,20 +848,11 @@

 /*
  * Mark a page as having seen activity.
- *
- * inactive,unreferenced	->	inactive,referenced
- * inactive,referenced		->	active,unreferenced
- * active,unreferenced		->	active,referenced
  */
 void mark_page_accessed(struct page *page)
 {
-	if (!PageActive(page) && PageReferenced(page)) {
-		activate_page(page);
-		ClearPageReferenced(page);
-		return;
-	} else if (!PageReferenced(page)) {
+	if (!PageReferenced(page))
 		SetPageReferenced(page);
-	}
 }

 /*
diff -Nru a/mm/readahead.c b/mm/readahead.c
--- a/mm/readahead.c	Mon Jul 29 21:36:01 2002
+++ b/mm/readahead.c	Mon Jul 29 21:36:01 2002
@@ -204,6 +204,39 @@
 }

 /*
+ * Since we're less likely to use the pages we've already read than
+ * the pages we're about to read we move the pages from the past
+ * window to the inactive list.
+ */
+static void
+drop_behind(struct file *file, unsigned long offset, pgoff_t size)
+{
+	unsigned long page_idx, lower_limit = 0;
+	struct address_space *mapping;
+	struct page *page;
+
+	/* We're re-using already present data or just started reading. */
+	if (size == -1UL || offset == 0)
+		return;
+
+	mapping = file->f_dentry->d_inode->i_mapping;
+
+	if (offset > size)
+		lower_limit = offset - size;
+
+	read_lock(&mapping->page_lock);
+	for (page_idx = offset; page_idx > lower_limit; page_idx--) {
+		page = radix_tree_lookup(&mapping->page_tree, page_idx);
+
+		if (!page || (!PageActive(page) && !PageReferenced(page)))
+			break;
+
+		deactivate_page(page);
+	}
+	read_unlock(&mapping->page_lock);
+}
+
+/*
  * page_cache_readahead is the main function.  If performs the adaptive
  * readahead window size management and submits the readahead I/O.
  */
@@ -286,6 +319,11 @@
 			ra->prev_page = ra->start;
 			ra->ahead_start = 0;
 			ra->ahead_size = 0;
+			/*
+			 * Drop the pages from the old window into the
+			 * inactive list.
+			 */
+			drop_behind(file, offset, ra->size);
 			/*
 			 * Control now returns, probably to sleep until I/O
 			 * completes against the first ahead page.
diff -Nru a/mm/swap.c b/mm/swap.c
--- a/mm/swap.c	Mon Jul 29 21:36:01 2002
+++ b/mm/swap.c	Mon Jul 29 21:36:01 2002
@@ -53,6 +53,24 @@
 }

 /**
+ * deactivate_page - move an active page to the inactive list.
+ * @page: page to deactivate
+ */
+void deactivate_page(struct page * page)
+{
+	spin_lock(&pagemap_lru_lock);
+	if (PageLRU(page) && PageActive(page)) {
+		del_page_from_active_list(page);
+		add_page_to_inactive_list(page);
+		KERNEL_STAT_INC(pgdeactivate);
+	}
+	spin_unlock(&pagemap_lru_lock);
+
+	if (PageReferenced(page))
+		ClearPageReferenced(page);
+}
+
+/**
  * lru_cache_add: add a page to the page lists
  * @page: the page to add
  */
@@ -60,7 +78,7 @@
 {
 	if (!TestSetPageLRU(page)) {
 		spin_lock(&pagemap_lru_lock);
-		add_page_to_inactive_list(page);
+		add_page_to_active_list(page);
 		spin_unlock(&pagemap_lru_lock);
 	}
 }
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Mon Jul 29 21:36:01 2002
+++ b/mm/vmscan.c	Mon Jul 29 21:36:01 2002
@@ -138,7 +138,7 @@
 		 * the active list.
 		 */
 		pte_chain_lock(page);
-		if (page_referenced(page) && page_mapping_inuse(page)) {
+		if (page_referenced(page)) {
 			del_page_from_inactive_list(page);
 			add_page_to_active_list(page);
 			pte_chain_unlock(page);
@@ -346,7 +346,7 @@
 		KERNEL_STAT_INC(pgscan);

 		pte_chain_lock(page);
-		if (page->pte.chain && page_referenced(page)) {
+		if (page_referenced(page) && page_mapping_inuse(page)) {
 			list_del(&page->lru);
 			list_add(&page->lru, &active_list);
 			pte_chain_unlock(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
