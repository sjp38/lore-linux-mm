Date: Tue, 9 May 2000 21:14:08 +0100 (BST)
From: Dave Jones <dave@denial.force9.co.uk>
Subject: [PATCH] remove_inode_page rewrite.
Message-ID: <Pine.LNX.4.21.0005092051120.911-100000@neo.local>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
 I'm not entirely convinced that remove_inode_page() is
SMP safe.  The diff below rewrites it so that it doesn't
repeatedly take/drop the pagecache_lock.

I believe that while after CPU0 drops the pagecache_lock, and starts
removing one page, CPU1 fails to lock the same page (as CPU0 grabbed it 
with the trylock) and moves to the next page in the list, succeeds,
removes it, and then rescans from the top.

With the current locking I believe it's then possible for CPU1 to
lock that page (again in the TryLockPage(page) call) just before CPU0
calls page_cache_release(page)

This patch probably kills us latency-wise, but looks a lot more
sane in my eyes.

 Any comments ?

-- 
Dave.

--- filemap.c~	Tue May  9 19:37:13 2000
+++ filemap.c	Tue May  9 19:37:41 2000
@@ -91,44 +91,50 @@
  * Remove a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
  * is safe.
+ * Caller must also be holding pagecache_lock
  */
 void remove_inode_page(struct page *page)
 {
 	if (!PageLocked(page))
 		PAGE_BUG(page);
 
-	spin_lock(&pagecache_lock);
 	remove_page_from_inode_queue(page);
 	remove_page_from_hash_queue(page);
 	page->mapping = NULL;
-	spin_unlock(&pagecache_lock);
 }
 
+
 void invalidate_inode_pages(struct inode * inode)
 {
 	struct list_head *head, *curr;
 	struct page * page;
 
- repeat:
-	head = &inode->i_mapping->pages;
 	spin_lock(&pagecache_lock);
+
+	head = &inode->i_mapping->pages;
+
+	if (head == head->next)
+		goto empty_list;
+
 	curr = head->next;
 
-	while (curr != head) {
+	do {
 		page = list_entry(curr, struct page, list);
 		curr = curr->next;
 
 		/* We cannot invalidate a locked page */
 		if (TryLockPage(page))
 			continue;
-		spin_unlock(&pagecache_lock);
 
 		lru_cache_del(page);
 		remove_inode_page(page);
 		UnlockPage(page);
 		page_cache_release(page);
-		goto repeat;
-	}
+		head = &inode->i_mapping->pages;
+
+	} while (curr != head); 
+
+empty_list:
 	spin_unlock(&pagecache_lock);
 }
 
@@ -180,7 +186,9 @@
 			 * page cache and creates a buffer-cache alias
 			 * to it causing all sorts of fun problems ...
 			 */
+			spin_lock(&pagecache_lock);
 			remove_inode_page(page);
+			spin_unlock(&pagecache_lock);
 
 			UnlockPage(page);
 			page_cache_release(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
