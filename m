Subject: PATCH: rewrite of invalidate_inode_pages
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 11 May 2000 23:40:12 +0200
Message-ID: <ytt4s84ix4z.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi
        this patch does a rewrite of invalidate_inode_pages, the
improvements over the actual are:

- we don't do busy waiting (original version did)
- we define a new macro __lru_cache_del (old lru_cache_del without
  doing the locking)
- we define the function __remove_inode_page() (old remove_inode_page
  without sanity checks) they are done for the caller.
- we take the two locks (pagecache_lock and pagemap_lru_lock),  at the 
  begining and we do all the operations without more locking.
- we change one page_cache_release to put_page in truncate_inode_pages
  (people find lost when they see a get_page without the correspondent
  put_page, and put_page and page_cache_release are synonimops)
- It removes a small window for races in truncate_inode_pages for
  calling get_page after droping the spinlock.
- The number of ITERATIONS before droping the locks is to limit
  latency (it could be better other number).

This patch was discussed/made between Dave Jones, Rik van Riel, Arjan
van de Ven and me in the IRC channel #kernelnewbies (server
irc.openprojects.net). 


Comments anyone?  (the nfs/smb people are the ones that call that
function, comments form them are very apreciated).


Later, Juan.

diff -u -urN --exclude-from=exclude pre7-9/include/linux/swap.h remove_inode/include/linux/swap.h
--- pre7-9/include/linux/swap.h	Thu May 11 02:24:03 2000
+++ remove_inode/include/linux/swap.h	Thu May 11 18:00:27 2000
@@ -171,13 +171,18 @@
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
 
+#define	__lru_cache_del(page)			\
+do {						\
+	list_del(&(page)->lru);			\
+	nr_lru_pages--;				\
+} while (0)
+
 #define	lru_cache_del(page)			\
 do {						\
 	if (!PageLocked(page))			\
 		BUG();				\
 	spin_lock(&pagemap_lru_lock);		\
-	list_del(&(page)->lru);			\
-	nr_lru_pages--;				\
+	__lru_cache_del(page);			\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
 
diff -u -urN --exclude-from=exclude pre7-9/mm/filemap.c remove_inode/mm/filemap.c
--- pre7-9/mm/filemap.c	Thu May 11 02:24:03 2000
+++ remove_inode/mm/filemap.c	Thu May 11 20:13:24 2000
@@ -67,7 +67,7 @@
 		PAGE_BUG(page);
 }
 
-static void remove_page_from_hash_queue(struct page * page)
+static inline void remove_page_from_hash_queue(struct page * page)
 {
 	if(page->pprev_hash) {
 		if(page->next_hash)
@@ -92,44 +92,71 @@
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.
  */
+static inline void __remove_inode_page(struct page *page)
+{
+	remove_page_from_inode_queue(page);
+	remove_page_from_hash_queue(page);
+	page->mapping = NULL;
+}
+
 void remove_inode_page(struct page *page)
 {
 	if (!PageLocked(page))
 		PAGE_BUG(page);
 
 	spin_lock(&pagecache_lock);
-	remove_page_from_inode_queue(page);
-	remove_page_from_hash_queue(page);
-	page->mapping = NULL;
+        __remove_inode_page(page);
 	spin_unlock(&pagecache_lock);
 }
 
+#define ITERATIONS 100
+
 void invalidate_inode_pages(struct inode * inode)
 {
 	struct list_head *head, *curr;
 	struct page * page;
+        int count;
 
- repeat:
 	head = &inode->i_mapping->pages;
-	spin_lock(&pagecache_lock);
-	curr = head->next;
-
-	while (curr != head) {
-		page = list_entry(curr, struct page, list);
-		curr = curr->next;
 
-		/* We cannot invalidate a locked page */
-		if (TryLockPage(page))
-			continue;
-		spin_unlock(&pagecache_lock);
-
-		lru_cache_del(page);
-		remove_inode_page(page);
-		UnlockPage(page);
-		page_cache_release(page);
-		goto repeat;
-	}
-	spin_unlock(&pagecache_lock);
+        while (head != head->next) {
+                spin_lock(&pagecache_lock);
+                spin_lock(&pagemap_lru_lock);
+                head = &inode->i_mapping->pages;
+                curr = head->next;
+                count = 0;
+
+                while ((curr != head) && (count++ < ITERATIONS)) {
+                        page = list_entry(curr, struct page, list);
+                        curr = curr->next;
+
+                        /* We cannot invalidate a locked page */
+                        if (TryLockPage(page))
+                                continue;
+
+                        __lru_cache_del(page);
+                        __remove_inode_page(page);
+                        UnlockPage(page);
+                        page_cache_release(page);
+                }
+
+                /* At this stage we have passed through the list
+                 * once, and there may still be locked pages. */
+
+                if (head->next!=head) {
+                        page = list_entry(head->next, struct page, list);
+                        get_page(page);
+                        spin_unlock(&pagemap_lru_lock);
+                        spin_unlock(&pagecache_lock);
+                        /* We need to block */
+                        lock_page(page);
+                        UnlockPage(page);
+                        put_page(page);
+                } else {                                         
+                        spin_unlock(&pagemap_lru_lock);
+                        spin_unlock(&pagecache_lock);
+                }
+        }
 }
 
 /*
@@ -160,8 +187,8 @@
 		/* page wholly truncated - free it */
 		if (offset >= start) {
 			if (TryLockPage(page)) {
-				spin_unlock(&pagecache_lock);
 				get_page(page);
+				spin_unlock(&pagecache_lock);
 				wait_on_page(page);
 				put_page(page);
 				goto repeat;
@@ -184,7 +211,7 @@
 
 			UnlockPage(page);
 			page_cache_release(page);
-			page_cache_release(page);
+			put_page(page);
 
 			/*
 			 * We have done things without the pagecache lock,
@@ -323,9 +350,7 @@
 		/* is it a page-cache page? */
 		if (page->mapping) {
 			if (!PageDirty(page) && !pgcache_under_min()) {
-				remove_page_from_inode_queue(page);
-				remove_page_from_hash_queue(page);
-				page->mapping = NULL;
+                                __remove_inode_page(page);
 				spin_unlock(&pagecache_lock);
 				goto made_inode_progress;
 			}

-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
