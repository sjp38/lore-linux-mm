Date: Fri, 28 Apr 2006 08:31:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/7] page migration: synchronize from and to lists
In-Reply-To: <20060428164619.4b8bc28c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0604280830020.32339@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
 <20060428060323.30257.90761.sendpatchset@schroedinger.engr.sgi.com>
 <20060428164619.4b8bc28c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, lee.schermerhorn@hp.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 28 Apr 2006, KAMEZAWA Hiroyuki wrote:

> you should rotate "to" list in this case, I think.		

Hmmm.... Seems that the whole list scanning needs an overhaul. What do 
you thinkg about this?


Rework main loop in migrate_pages()

Take pages off the "to" and "from" list in a consistent way so that 1-1
relationships between pages on both lists can be maintained.

This also means that pages are not on any list while migration is attempted.
Instead of "move_to_lru" we only need "to_lru".

Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-28 06:56:36.856624280 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-28 08:26:29.893711598 -0700
@@ -82,9 +82,8 @@
 	return 0;
 }
 
-static inline void move_to_lru(struct page *page)
+static inline void to_lru(struct page *page)
 {
-	list_del(&page->lru);
 	if (PageActive(page)) {
 		/*
 		 * lru_cache_add_active checks that
@@ -92,9 +91,9 @@
 		 */
 		ClearPageActive(page);
 		lru_cache_add_active(page);
-	} else {
+	} else
 		lru_cache_add(page);
-	}
+
 	put_page(page);
 }
 
@@ -110,7 +109,8 @@
 	int count = 0;
 
 	list_for_each_entry_safe(page, page2, l, lru) {
-		move_to_lru(page);
+		list_del(&page->lru);
+		to_lru(page);
 		count++;
 	}
 	return count;
@@ -532,36 +532,42 @@
  * Return: Number of pages not migrated when "to" ran empty.
  */
 int migrate_pages(struct list_head *from, struct list_head *to,
-		  struct list_head *moved, struct list_head *failed)
+		  struct list_head *done, struct list_head *failed)
 {
-	int retry;
 	int nr_failed = 0;
 	int pass = 0;
-	struct page *page;
-	struct page *page2;
 	int swapwrite = current->flags & PF_SWAPWRITE;
-	int rc;
+	int retry;
+	struct list_head retry_to;
+	struct list_head retry_from;
+	struct list_head unused;
 
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;
 
+	INIT_LIST_HEAD(&unused);
 redo:
 	retry = 0;
+	INIT_LIST_HEAD(&retry_from);
+	INIT_LIST_HEAD(&retry_to);
 
-	list_for_each_entry_safe(page, page2, from, lru) {
-		struct page *newpage = NULL;
+	while (!list_empty(from) && !list_empty(to)) {
+		int rc = 0;
+		struct page *page;
+		struct page *newpage;
 		struct address_space *mapping;
 
 		cond_resched();
 
-		rc = 0;
+		page = lru_to_page(from);
+		list_del(&page->lru);
+		newpage = lru_to_page(to);
+		list_del(&newpage->lru);
+
 		if (page_count(page) == 1)
 			/* page was freed from under us. So we are done. */
 			goto next;
 
-		if (list_empty(to))
-			break;
-
 		/*
 		 * Skip locked pages during the first two passes to give the
 		 * functions holding the lock time to release the page. Later we
@@ -585,7 +591,6 @@
 		else if (PageWriteback(page))
 				goto unlock_page;
 
-		newpage = lru_to_page(to);
 		lock_page(newpage);
 		/* Prepare mapping for the new page.*/
 		newpage->index = page->index;
@@ -610,32 +615,33 @@
 		unlock_page(page);
 
 next:
-		if (rc) {
-			if (newpage) {
-				newpage->mapping = NULL;
-				list_move_tail(&newpage->lru, to);
-			}
+		if (likely(rc == 0)) {
+			/* Successful migration. */
+			to_lru(newpage);
+			list_add(&page->lru, done);
+		} else {
 
-			if (rc == -EAGAIN)
+			newpage->mapping = NULL;
+			if (rc == -EAGAIN) {
 				/* Soft failure */
 				retry++;
-
-			else {
+				list_add(&newpage->lru, &retry_to);
+				list_add(&page->lru, &retry_from);
+			} else {
 				/* Permanent failure */
-				list_move(&page->lru, failed);
 				nr_failed++;
+				list_add(&newpage->lru, &unused);
+				list_add(&page->lru, failed);
 			}
-		} else {
-			if (newpage)
-				/* Successful migration. Return page to LRU */
-				move_to_lru(newpage);
-
-			list_move(&page->lru, moved);
 		}
 	}
+	list_splice(&retry_to, to);
+	list_splice(&retry_from, from);
+
 	if (retry && pass++ < 10)
 		goto redo;
 
+	list_splice(&unused, to);
 	if (!swapwrite)
 		current->flags &= ~PF_SWAPWRITE;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
