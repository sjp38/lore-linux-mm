Subject: [PATCH]: Removal of add_to_page_cache_locked
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 04 May 2000 17:50:26 +0200
Message-ID: <yttog6ml3gd.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi Linus,

   In your last patch (pre7-4) I have noticed:

You have introduced the function: add_to_page_cache_locked, You call
it from add_to_swap_cache, with this new function, there is no callers
of add_to_page_cache,  I have changed the code to all the callers of
__add_to_page_cache lock the page before call it.

The only difference between your code and mine is that you mark the
page uptodate in add_to_swap_cache and I don't mark it.  If you want I
can't change that.

The lock_page in ipc/shm.c::shm_swap_core was introduced too late,
after the call to prepare_highmem_swapout, and we need to lock the
page before call that function.  We will lock the newpage in
prepare_highmem_swapout and the second lock_page will deadlock.

Any comments?

Later, Juan.




diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-4/include/linux/pagemap.h testing/include/linux/pagemap.h
--- pre7-4/include/linux/pagemap.h	Thu May  4 11:02:18 2000
+++ testing/include/linux/pagemap.h	Thu May  4 16:55:06 2000
@@ -80,7 +80,6 @@
 extern void __add_page_to_hash_queue(struct page * page, struct page **p);
 
 extern void add_to_page_cache(struct page * page, struct address_space *mapping, unsigned long index);
-extern void add_to_page_cache_locked(struct page * page, struct address_space *mapping, unsigned long index);
 
 extern inline void add_page_to_hash_queue(struct page * page, struct inode * inode, unsigned long index)
 {
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-4/ipc/shm.c testing/ipc/shm.c
--- pre7-4/ipc/shm.c	Thu May  4 11:02:18 2000
+++ testing/ipc/shm.c	Thu May  4 17:03:18 2000
@@ -1446,6 +1446,7 @@
 	if (page_count(page_map) != 1)
 		return RETRY;
 
+	lock_page(page_map);
 	if (!(page_map = prepare_highmem_swapout(page_map)))
 		return FAILED;
 	SHM_ENTRY (shp, idx) = swp_entry_to_pte(swap_entry);
@@ -1455,7 +1456,6 @@
 	   reading a not yet uptodate block from disk.
 	   NOTE: we just accounted the swap space reference for this
 	   swap cache page at __get_swap_page() time. */
-	lock_page(page_map);
 	add_to_swap_cache(*outpage = page_map, swap_entry);
 	return OKAY;
 }
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-4/mm/filemap.c testing/mm/filemap.c
--- pre7-4/mm/filemap.c	Thu May  4 11:02:18 2000
+++ testing/mm/filemap.c	Thu May  4 17:14:43 2000
@@ -486,28 +486,9 @@
 }
 
 /*
- * Add a page to the inode page cache.
- *
- * The caller must have locked the page and 
- * set all the page flags correctly..
- */
-void add_to_page_cache_locked(struct page * page, struct address_space *mapping, unsigned long index)
-{
-	if (!PageLocked(page))
-		BUG();
-
-	get_page(page);
-	spin_lock(&pagecache_lock);
-	page->index = index;
-	add_page_to_inode_queue(mapping, page);
-	__add_page_to_hash_queue(page, page_hash(mapping, index));
-	lru_cache_add(page);
-	spin_unlock(&pagecache_lock);
-}
-
-/*
- * This adds a page to the page cache, starting out as locked,
- * owned by us, referenced, but not uptodate and with no errors.
+ * This adds a page to the page cache, the page should be locked by
+ * the caller, owned by us, referenced, but not uptodate and with no
+ * errors.  
  */
 static inline void __add_to_page_cache(struct page * page,
 	struct address_space *mapping, unsigned long offset,
@@ -516,11 +497,11 @@
 	struct page *alias;
 	unsigned long flags;
 
-	if (PageLocked(page))
+	if (!PageLocked(page))
 		BUG();
 
 	flags = page->flags & ~((1 << PG_uptodate) | (1 << PG_error) | (1 << PG_dirty));
-	page->flags = flags | (1 << PG_locked) | (1 << PG_referenced);
+	page->flags = flags | (1 << PG_referenced);
 	get_page(page);
 	page->index = offset;
 	add_page_to_inode_queue(mapping, page);
@@ -549,7 +530,7 @@
 	alias = __find_page_nolock(mapping, offset, *hash);
 
 	err = 1;
-	if (!alias) {
+	if (!alias && !TryLockPage(page)) {
 		__add_to_page_cache(page,mapping,offset,hash);
 		err = 0;
 	}
@@ -1163,6 +1144,8 @@
 		 * Ok, add the new page to the hash-queues...
 		 */
 		page = cached_page;
+                if (TryLockPage(page))
+                        BUG();
 		__add_to_page_cache(page, mapping, index, hash);
 		spin_unlock(&pagecache_lock);
 		cached_page = NULL;
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* pre7-4/mm/swap_state.c testing/mm/swap_state.c
--- pre7-4/mm/swap_state.c	Thu May  4 11:02:18 2000
+++ testing/mm/swap_state.c	Thu May  4 17:00:00 2000
@@ -47,8 +47,6 @@
 
 void add_to_swap_cache(struct page *page, swp_entry_t entry)
 {
-	unsigned long flags;
-
 #ifdef SWAP_CACHE_INFO
 	swap_cache_add_total++;
 #endif
@@ -58,9 +56,7 @@
 		BUG();
 	if (page->mapping)
 		BUG();
-	flags = page->flags & ~((1 << PG_error) | (1 << PG_dirty));
-	page->flags = flags | (1 << PG_referenced) | (1 << PG_uptodate);
-	add_to_page_cache_locked(page, &swapper_space, entry.val);
+	add_to_page_cache(page, &swapper_space, entry.val);
 }
 
 static inline void remove_from_swap_cache(struct page *page)




-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
