Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com>
	<yttya5ghhtr.fsf@vexeta.dc.fi.udc.es> <shsd7msemwu.fsf@charged.uio.no>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Trond Myklebust's message of "12 May 2000 00:34:41 +0200"
Date: 12 May 2000 00:54:49 +0200
Message-ID: <yttbt2chf46.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "trond" == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:
>> Linus, I agree with you here, but we do a get_page 5 lines
>> before, I think that if I do a get_page I should do a put_page
>> to liberate it.  But I can be wrong, and then I would like to
>> know if in the future, it could be posible to do a get_page and
>> liberate it with a page_cache_release?  That was my point.
>> Sorry for the bad wording.

trond> That part of the code is broken. We do not want to wait on locked
trond> pages in invalidate_inode_pages(): that's the whole reason for its
trond> existence. truncate_inode_pages() is the waiting version.

Then you want only invalidate the non_locked pages: do you like:
What do you think of the following patch them?

Comments.

Later.


--- pre7-9/mm/filemap.c	Thu May 11 02:24:03 2000
+++ remove_inode/mm/filemap.c	Fri May 12 00:51:51 2000
@@ -67,7 +67,7 @@
 		PAGE_BUG(page);
 }
 
-static void remove_page_from_hash_queue(struct page * page)
+static inline void remove_page_from_hash_queue(struct page * page)
 {
 	if(page->pprev_hash) {
 		if(page->next_hash)
@@ -92,44 +92,55 @@
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
+        int count = ITERATIONS;
 
- repeat:
-	head = &inode->i_mapping->pages;
-	spin_lock(&pagecache_lock);
-	curr = head->next;
-
-	while (curr != head) {
-		page = list_entry(curr, struct page, list);
-		curr = curr->next;
-
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
+        while (count == ITERATIONS) {
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
+                spin_unlock(&pagemap_lru_lock);
+                spin_unlock(&pagecache_lock);
+        }
 }
 
 /*
@@ -160,8 +171,8 @@
 		/* page wholly truncated - free it */
 		if (offset >= start) {
 			if (TryLockPage(page)) {
-				spin_unlock(&pagecache_lock);
 				get_page(page);
+				spin_unlock(&pagecache_lock);
 				wait_on_page(page);
 				put_page(page);
 				goto repeat;
@@ -323,9 +334,7 @@
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
 



-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
