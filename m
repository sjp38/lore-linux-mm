Subject: PATCH: Rewrite of truncate_inode_pages (try2)
References: <yttsnvk28jy.fsf@vexeta.dc.fi.udc.es>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: "Juan J. Quintela"'s message of "14 May 2000 22:14:41 +0200"
Date: 18 May 2000 00:34:56 +0200
Message-ID: <yttem70x0tr.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi Linus
        I just repost my patch to truncate_inode_pages.  The version
        in vanilla pre9-2 does busy waiting in partial pages, this one
        didn't do busy waiting and put the locking code common for
        partial and non partial pages.  

        Linus, if you don't like it, could you tell me what is the
        problem?

Thanks, Later.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude work/mm/filemap.c testing/mm/filemap.c
--- work/mm/filemap.c	Fri May 12 23:46:46 2000
+++ testing/mm/filemap.c	Sun May 14 22:08:45 2000
@@ -146,9 +146,39 @@
 	spin_unlock(&pagecache_lock);
 }
 
-/*
+static inline void truncate_partial_page(struct page *page, unsigned partial)
+{
+	memclear_highpage_flush(page, partial, PAGE_CACHE_SIZE-partial);
+				
+	if (page->buffers)
+		block_flushpage(page, partial);
+
+}
+
+static inline void truncate_complete_page(struct page *page)
+{
+	if (!page->buffers || block_flushpage(page, 0))
+		lru_cache_del(page);
+	
+	/*
+	 * We remove the page from the page cache _after_ we have
+	 * destroyed all buffer-cache references to it. Otherwise some
+	 * other process might think this inode page is not in the
+	 * page cache and creates a buffer-cache alias to it causing
+	 * all sorts of fun problems ...  
+	 */
+	remove_inode_page(page);
+	page_cache_release(page);
+}
+
+/**
+ * truncate_inode_pages - truncate *all* the pages from an offset
+ * @mapping: mapping to truncate
+ * @lstart: offset from with to truncate
+ *
  * Truncate the page cache at a set offset, removing the pages
  * that are beyond that offset (and zeroing out partial pages).
+ * If any page is locked we wait for it to become unlocked.
  */
 void truncate_inode_pages(struct address_space * mapping, loff_t lstart)
 {
@@ -168,11 +198,10 @@
 
 		page = list_entry(curr, struct page, list);
 		curr = curr->next;
-
 		offset = page->index;
 
-		/* page wholly truncated - free it */
-		if (offset >= start) {
+		/* Is one of the pages to truncate? */
+		if ((offset >= start) || (partial && (offset + 1) == start)) {
 			if (TryLockPage(page)) {
 				page_cache_get(page);
 				spin_unlock(&pagecache_lock);
@@ -183,22 +212,14 @@
 			page_cache_get(page);
 			spin_unlock(&pagecache_lock);
 
-			if (!page->buffers || block_flushpage(page, 0))
-				lru_cache_del(page);
-
-			/*
-			 * We remove the page from the page cache
-			 * _after_ we have destroyed all buffer-cache
-			 * references to it. Otherwise some other process
-			 * might think this inode page is not in the
-			 * page cache and creates a buffer-cache alias
-			 * to it causing all sorts of fun problems ...
-			 */
-			remove_inode_page(page);
+			if (partial && (offset + 1) == start) {
+				truncate_partial_page(page, partial);
+				partial = 0;
+			} else 
+				truncate_complete_page(page);
 
 			UnlockPage(page);
 			page_cache_release(page);
-			page_cache_release(page);
 
 			/*
 			 * We have done things without the pagecache lock,
@@ -209,37 +230,6 @@
 			 */
 			goto repeat;
 		}
-		/*
-		 * there is only one partial page possible.
-		 */
-		if (!partial)
-			continue;
-
-		/* and it's the one preceeding the first wholly truncated page */
-		if ((offset + 1) != start)
-			continue;
-
-		/* partial truncate, clear end of page */
-		if (TryLockPage(page)) {
-			spin_unlock(&pagecache_lock);
-			goto repeat;
-		}
-		page_cache_get(page);
-		spin_unlock(&pagecache_lock);
-
-		memclear_highpage_flush(page, partial, PAGE_CACHE_SIZE-partial);
-		if (page->buffers)
-			block_flushpage(page, partial);
-
-		partial = 0;
-
-		/*
-		 * we have dropped the spinlock so we have to
-		 * restart.
-		 */
-		UnlockPage(page);
-		page_cache_release(page);
-		goto repeat;
 	}
 	spin_unlock(&pagecache_lock);
 }


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
