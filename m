Date: Mon, 18 Jun 2001 22:01:11 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: v2.4.6-pre3 swap cache race
Message-ID: <Pine.LNX.4.33.0106182200320.17350-100000@toomuch.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

diff -urN v2.4.6-pre3/mm/filemap.c swaprace/mm/filemap.c
--- v2.4.6-pre3/mm/filemap.c	Mon Jun 18 21:51:03 2001
+++ swaprace/mm/filemap.c	Mon Jun 18 21:59:57 2001
@@ -714,16 +714,16 @@
  * The SwapCache check is protected by the pagecache lock.
  */
 struct page * __find_get_swapcache_page(struct address_space *mapping,
-			      unsigned long offset, struct page **hash)
+			      unsigned long index, struct page **hash)
 {
 	struct page *page;

 	/*
 	 * We need the LRU lock to protect against page_launder().
 	 */
-
+try_again:
 	spin_lock(&pagecache_lock);
-	page = __find_page_nolock(mapping, offset, *hash);
+	page = __find_page_nolock(mapping, index, *hash);
 	if (page) {
 		spin_lock(&pagemap_lru_lock);
 		if (PageSwapCache(page))
@@ -733,6 +733,16 @@
 		spin_unlock(&pagemap_lru_lock);
 	}
 	spin_unlock(&pagecache_lock);
+
+	if (page) {
+		lock_page(page);
+		if (!PageSwapCache(page) || page->mapping != mapping ||
+		    page->index != index) {
+			UnlockPage(page);
+			goto try_again;
+		}
+		UnlockPage(page);
+	}

 	return page;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
