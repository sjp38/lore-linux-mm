Date: Thu, 27 Apr 2006 23:03:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060428060323.30257.90761.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 5/7] page migration: synchronize from and to lists
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

page migration: synchronize from and to lists to migrate_pages()

Handle pages from the "from" and "to" lists in such a way that the nth page
from "from" is moved to the nth page from "to". That way page placement
for each page can be controlled separately.

Also do some cleanups by removing a useless test on "to" and
reformatting some if statements.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-27 21:32:46.933165848 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-27 21:32:50.417322988 -0700
@@ -466,6 +466,9 @@
  * The second list contains new pages that the pages isolated
  * can be moved to.
  *
+ * Pages in both lists have a 1-1 correspondence. The nth page
+ * on "from" will be moved to the nth page on "to".
+ *
  * The function returns after 10 attempts or if no pages
  * are movable anymore because to has become empty
  * or no retryable pages exist anymore.
@@ -500,7 +503,7 @@
 			/* page was freed from under us. So we are done. */
 			goto next;
 
-		if (to && list_empty(to))
+		if (list_empty(to))
 			break;
 
 		/*
@@ -522,10 +525,9 @@
 		 */
 		if (pass > 0)
 			wait_on_page_writeback(page);
-		else {
-			if (PageWriteback(page))
+
+		else if (PageWriteback(page))
 				goto unlock_page;
-		}
 
 		newpage = lru_to_page(to);
 		lock_page(newpage);
@@ -594,19 +596,25 @@
 
 next:
 		if (rc) {
-			newpage->mapping = NULL;
+			if (newpage) {
+				newpage->mapping = NULL;
+				list_move_tail(&newpage->lru, to);
+			}
+
 			if (rc == -EAGAIN)
+				/* Soft failure */
 				retry++;
+
 			else {
 				/* Permanent failure */
 				list_move(&page->lru, failed);
 				nr_failed++;
 			}
 		} else {
-			if (newpage) {
+			if (newpage)
 				/* Successful migration. Return page to LRU */
 				move_to_lru(newpage);
-			}
+
 			list_move(&page->lru, moved);
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
