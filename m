Date: Mon, 2 Dec 2002 18:28:03 -0500
From: Christoph Hellwig <hch@sgi.com>
Subject: [PATCH] undo __find_pagecache_page braindamage in -rmap15
Message-ID: <20021202182803.A25833@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@conectiva.com.br
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Just revert back to the mainline versions of that stuff (which are the
same except of the naming).

Note that the changes are not only useless but also unintuitive, the
old name explained exactly what this function does, and the pagecache
is superflous as all find_*_page functions operate on the pagecache..


--- 1.15/Changelog.rmap	Tue Nov 26 14:26:20 2002
+++ edited/Changelog.rmap	Mon Dec  2 17:09:05 2002
@@ -12,9 +12,10 @@
   - backport speedups from 2.5
   - pte-highmem
 
+  - undo __find_pagecache_page braindamage		  (Christoph Hellwig)
 rmap 15a:
   - more agressive freeing for higher order allocations   (me)
-  - export __find_pagecache_page, find_get_page define    (me, Cristoph, Arjan)
+  - export __find_pagecache_page, find_get_page define    (me, Christoph, Arjan)
   - make memory statistics SMP safe again                 (me)
   - make page aging slow down again when needed           (Andrew Morton)
   - first stab at fine-tuning arjan's O(1) VM             (me)
===== include/linux/pagemap.h 1.20 vs edited =====
--- 1.20/include/linux/pagemap.h	Fri Nov 29 02:18:13 2002
+++ edited/include/linux/pagemap.h	Mon Dec  2 17:02:43 2002
@@ -70,6 +70,10 @@
 
 #define page_hash(mapping,index) (page_hash_table+_page_hashfn(mapping,index))
 
+extern struct page * __find_get_page(struct address_space *mapping,
+				unsigned long index, struct page **hash);
+#define find_get_page(mapping, index) \
+	__find_get_page(mapping, index, page_hash(mapping, index))
 extern struct page * __find_lock_page (struct address_space * mapping,
 				unsigned long index, struct page **hash);
 extern struct page * find_or_create_page(struct address_space *mapping,
@@ -87,14 +91,6 @@
 
 extern void ___wait_on_page(struct page *);
 extern int wait_on_page_timeout(struct page *page, int timeout);
-
-
-extern struct page * __find_pagecache_page(struct address_space *mapping,
-				unsigned long index, struct page **hash);
-#define find_pagecache_page(mapping, index) \
-	__find_pagecache_page(mapping, index, page_hash(mapping, index))
-#define find_get_page(mapping, index) \
-	__find_pagecache_page(mapping, index, page_hash(mapping, index))
 
 static inline void wait_on_page(struct page * page)
 {
===== kernel/ksyms.c 1.65 vs edited =====
--- 1.65/kernel/ksyms.c	Fri Nov 29 02:18:17 2002
+++ edited/kernel/ksyms.c	Mon Dec  2 16:58:07 2002
@@ -260,6 +260,7 @@
 EXPORT_SYMBOL(__pollwait);
 EXPORT_SYMBOL(poll_freewait);
 EXPORT_SYMBOL(ROOT_DEV);
+EXPORT_SYMBOL(__find_get_page);
 EXPORT_SYMBOL(__find_lock_page);
 EXPORT_SYMBOL(find_or_create_page);
 EXPORT_SYMBOL(grab_cache_page_nowait);
===== mm/filemap.c 1.78 vs edited =====
--- 1.78/mm/filemap.c	Fri Nov 29 03:13:05 2002
+++ edited/mm/filemap.c	Mon Dec  2 16:59:47 2002
@@ -937,6 +937,26 @@
 		__lock_page(page);
 }
 
+/*
+ * a rather lightweight function, finding and getting a reference to a
+ * hashed page atomically.
+ */
+struct page * __find_get_page(struct address_space *mapping,
+			      unsigned long offset, struct page **hash)
+{
+	struct page *page;
+
+	/*
+	 * We scan the hash list read-only. Addition to and removal from
+	 * the hash-list needs a held write-lock.
+	 */
+	spin_lock(&pagecache_lock);
+	page = __find_page_nolock(mapping, offset, *hash);
+	if (page)
+		page_cache_get(page);
+	spin_unlock(&pagecache_lock);
+	return page;
+}
 
 /*
  * Same as above, but trylock it instead of incrementing the count.
@@ -1086,29 +1106,7 @@
 }
 
 /*
- * Look up a page in the pagecache and return that page with
- * a reference helt
- */
-struct page * __find_pagecache_page(struct address_space *mapping,
-			      unsigned long offset, struct page **hash)
-{
-	struct page *page;
-
-	/*
-	 * We scan the hash list read-only. Addition to and removal from
-	 * the hash-list needs a held write-lock.
-	 */
-	spin_lock(&pagecache_lock);
-	page = __find_page_nolock(mapping, offset, *hash);
-	if (page)
-		page_cache_get(page);
-	spin_unlock(&pagecache_lock);
-	return page;
-}
-
-EXPORT_SYMBOL_GPL(__find_pagecache_page);
-
-/* Same as grab_cache_page, but do not wait if the page is unavailable.
+ * Same as grab_cache_page, but do not wait if the page is unavailable.
  * This is intended for speculative data generators, where the data can
  * be regenerated if the page couldn't be grabbed.  This routine should
  * be safe to call while holding the lock for another page.
@@ -1118,7 +1116,7 @@
 	struct page *page, **hash;
 
 	hash = page_hash(mapping, index);
-	page = __find_pagecache_page(mapping, index, hash);
+	page = __find_get_page(mapping, index, hash);
 
 	if ( page ) {
 		if ( !TryLockPage(page) ) {
@@ -2048,7 +2046,7 @@
 	 */
 	hash = page_hash(mapping, pgoff);
 retry_find:
-	page = __find_pagecache_page(mapping, pgoff, hash);
+	page = __find_get_page(mapping, pgoff, hash);
 	if (!page)
 		goto no_cached_page;
 
@@ -2911,7 +2909,7 @@
 	struct page *page, *cached_page = NULL;
 	int err;
 repeat:
-	page = __find_pagecache_page(mapping, index, hash);
+	page = __find_get_page(mapping, index, hash);
 	if (!page) {
 		if (!cached_page) {
 			cached_page = page_cache_alloc(mapping);
===== mm/shmem.c 1.46 vs edited =====
--- 1.46/mm/shmem.c	Fri Nov 29 03:13:06 2002
+++ edited/mm/shmem.c	Mon Dec  2 16:59:58 2002
@@ -547,7 +547,7 @@
 	 * cache and swap cache.  We need to recheck the page cache
 	 * under the protection of the info->lock spinlock. */
 
-	page = find_pagecache_page(mapping, idx);
+	page = find_get_page(mapping, idx);
 	if (page) {
 		if (TryLockPage(page))
 			goto wait_retry;
===== mm/swap_state.c 1.20 vs edited =====
--- 1.20/mm/swap_state.c	Fri Nov 29 02:18:24 2002
+++ edited/mm/swap_state.c	Mon Dec  2 17:00:47 2002
@@ -196,7 +196,7 @@
 {
 	struct page *found;
 
-	found = find_pagecache_page(&swapper_space, entry.val);
+	found = find_get_page(&swapper_space, entry.val);
 	/*
 	 * Unsafe to assert PageSwapCache and mapping on page found:
 	 * if SMP nothing prevents swapoff from deleting this page from
@@ -224,10 +224,10 @@
 		/*
 		 * First check the swap cache.  Since this is normally
 		 * called after lookup_swap_cache() failed, re-calling
-		 * that would confuse statistics: use find_pagecache_page()
+		 * that would confuse statistics: use find_get_page()
 		 * directly.
 		 */
-		found_page = find_pagecache_page(&swapper_space, entry.val);
+		found_page = find_get_page(&swapper_space, entry.val);
 		if (found_page)
 			break;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
