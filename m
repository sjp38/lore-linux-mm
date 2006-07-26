Date: Wed, 26 Jul 2006 09:46:29 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] update some mm/ comments
Message-ID: <20060726074629.GC16531@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Comments about the comments, anyone?

---
Let's try to keep mm/ comments more useful and up to date. This is a start.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h
+++ linux-2.6/include/linux/page-flags.h
@@ -13,24 +13,25 @@
  * PG_reserved is set for special pages, which can never be swapped out. Some
  * of them might not even exist (eg empty_bad_page)...
  *
- * The PG_private bitflag is set if page->private contains a valid value.
+ * The PG_private bitflag is set on pagecache pages if they contain filesystem
+ * specific data (which is normally at page->private). It can be used by
+ * private allocations for its own usage.
+ *
+ * During initiation of disk I/O, PG_locked is set. This bit is set before I/O
+ * and cleared when writeback _starts_ or when read _completes_. PG_writeback
+ * is set before writeback starts and cleared when it finishes.
  *
- * During disk I/O, PG_locked is used. This bit is set before I/O and
- * reset when I/O completes. page_waitqueue(page) is a wait queue of all tasks
- * waiting for the I/O on this page to complete.
+ * PG_locked also pins a page in pagecache, and blocks truncation of the file
+ * while it is held.
+ *
+ * page_waitqueue(page) is a wait queue of all tasks waiting for the page
+ * to become unlocked.
  *
  * PG_uptodate tells whether the page's contents is valid.  When a read
  * completes, the page becomes uptodate, unless a disk I/O error happened.
  *
- * For choosing which pages to swap out, inode pages carry a PG_referenced bit,
- * which is set any time the system accesses that page through the (mapping,
- * index) hash table.  This referenced bit, together with the referenced bit
- * in the page tables, is used to manipulate page->age and move the page across
- * the active, inactive_dirty and inactive_clean lists.
- *
- * Note that the referenced bit, the page->lru list_head and the active,
- * inactive_dirty and inactive_clean lists are protected by the
- * zone->lru_lock, and *NOT* by the usual PG_locked bit!
+ * PG_referenced, PG_reclaim are used for page reclaim for anonymous and
+ * file-backed pagecache (see mm/vmscan.c).
  *
  * PG_error is set to indicate that an I/O error occurred on this page.
  *
@@ -42,6 +43,10 @@
  * space, they need to be kmapped separately for doing IO on the pages.  The
  * struct page (these bits with information) are always mapped into kernel
  * address space...
+ *
+ * PG_buddy is set to indicate that the page is free and in the buddy system
+ * (see mm/page_alloc.c).
+ *
  */
 
 /*
@@ -74,7 +79,7 @@
 #define PG_checked		 8	/* kill me in 2.5.<early>. */
 #define PG_arch_1		 9
 #define PG_reserved		10
-#define PG_private		11	/* Has something at ->private */
+#define PG_private		11	/* If pagecache, has fs-private data */
 
 #define PG_writeback		12	/* Page is under writeback */
 #define PG_nosave		13	/* Used for system suspend/resume */
@@ -83,7 +88,7 @@
 
 #define PG_mappedtodisk		16	/* Has blocks allocated on-disk */
 #define PG_reclaim		17	/* To be reclaimed asap */
-#define PG_nosave_free		18	/* Free, should not be written */
+#define PG_nosave_free		18	/* Used for system suspend/resume */
 #define PG_buddy		19	/* Page is free, on buddy lists */
 
 
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -582,8 +582,8 @@ EXPORT_SYMBOL(__lock_page);
  * @mapping: the address_space to search
  * @offset: the page index
  *
- * A rather lightweight function, finding and getting a reference to a
- * hashed page atomically.
+ * Is there a pagecache struct page at the given (mapping, offset) tuple?
+ * If yes, increment its refcount and return it; if no, return NULL.
  */
 struct page * find_get_page(struct address_space *mapping, unsigned long offset)
 {
@@ -972,7 +972,7 @@ page_not_up_to_date:
 		/* Get exclusive access to the page ... */
 		lock_page(page);
 
-		/* Did it get unhashed before we got the lock? */
+		/* Did it get truncated before we got the lock? */
 		if (!page->mapping) {
 			unlock_page(page);
 			page_cache_release(page);
@@ -1490,7 +1490,7 @@ page_not_uptodate:
 	}
 	lock_page(page);
 
-	/* Did it get unhashed while we waited for it? */
+	/* Did it get truncated while we waited for it? */
 	if (!page->mapping) {
 		unlock_page(page);
 		page_cache_release(page);
@@ -1612,7 +1612,7 @@ no_cached_page:
 page_not_uptodate:
 	lock_page(page);
 
-	/* Did it get unhashed while we waited for it? */
+	/* Did it get truncated while we waited for it? */
 	if (!page->mapping) {
 		unlock_page(page);
 		goto err;
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -218,7 +218,8 @@ struct inode;
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
  * moment. Note that we have no way to track which tasks are using
- * a page.
+ * a page, though if it is a pagecache page, rmap structures can tell us
+ * who is mapping it.
  */
 struct page {
 	unsigned long flags;		/* Atomic flags, some possibly
@@ -292,8 +293,7 @@ struct page {
  */
 
 /*
- * Drop a ref, return true if the logical refcount fell to zero (the page has
- * no users)
+ * Drop a ref, return true if the refcount fell to zero (the page has no users)
  */
 static inline int put_page_testzero(struct page *page)
 {
@@ -348,43 +348,55 @@ void split_page(struct page *page, unsig
  * For the non-reserved pages, page_count(page) denotes a reference count.
  *   page_count() == 0 means the page is free. page->lru is then used for
  *   freelist management in the buddy allocator.
- *   page_count() == 1 means the page is used for exactly one purpose
- *   (e.g. a private data page of one process).
+ *   page_count() > 0  means the page has been allocated.
  *
- * A page may be used for kmalloc() or anyone else who does a
- * __get_free_page(). In this case the page_count() is at least 1, and
- * all other fields are unused but should be 0 or NULL. The
- * management of this page is the responsibility of the one who uses
- * it.
+ * Pages are allocated by the slab allocator in order to provide memory
+ * to kmalloc and kmem_cache_alloc. In this case, the management of the
+ * page, and the fields in 'struct page' are the responsibility of mm/slab.c
+ * unless a particular usage is carefully commented. (the responsibility of
+ * freeing the kmalloc memory is the caller's, of course).
+ *
+ * A page may be used by anyone else who does a __get_free_page().
+ * In this case, page_count still tracks the references, and should only
+ * be used through the normal accessor functions. The top bits of page->flags
+ * and page->virtual store page management information, but all other fields
+ * are unused and could be used privately, carefully. The management of this
+ * page is the responsibility of the one who allocated it, and those who have
+ * subsequently been given references to it.
  *
- * The other pages (we may call them "process pages") are completely
+ * The other pages (we may call them "pagecache pages") are completely
  * managed by the Linux memory manager: I/O, buffers, swapping etc.
  * The following discussion applies only to them.
  *
- * A page may belong to an inode's memory mapping. In this case,
- * page->mapping is the pointer to the inode, and page->index is the
- * file offset of the page, in units of PAGE_CACHE_SIZE.
+ * A pagecache page contains an opaque `private' member, which belongs to the
+ * page's address_space. Usually, this is the address of a circular list of
+ * the page's disk buffers. PG_private must be set to tell the VM to call
+ * into the filesystem to release these pages.
+ *
+ * A page may belong to an inode's memory mapping. In this case, page->mapping
+ * is the pointer to the inode, and page->index is the file offset of the page,
+ * in units of PAGE_CACHE_SIZE.
+ *
+ * If pagecache pages are not associated with an inode, they are said to be
+ * anonymous pages. These may become associated with the swapcache, and in that
+ * case PG_swapcache is set, and page->private is an offset into the swapcache.
+ *
+ * In either case (swapcache or inode backed), the pagecache itself holds one
+ * reference to the page. Setting PG_private should also increment the
+ * refcount. The each user mapping also has a reference to the page.
+ *
+ * The pagecache pages are stored in a per-mapping radix tree, which is
+ * rooted at mapping->page_tree, and indexed by offset.
+ * Where 2.4 and early 2.6 kernels kept dirty/clean pages in per-address_space
+ * lists, we instead now tag pages as dirty/writeback in the radix tree.
  *
- * A page contains an opaque `private' member, which belongs to the
- * page's address_space.  Usually, this is the address of a circular
- * list of the page's disk buffers.
- *
- * For pages belonging to inodes, the page_count() is the number of
- * attaches, plus 1 if `private' contains something, plus one for
- * the page cache itself.
- *
- * Instead of keeping dirty/clean pages in per address-space lists, we instead
- * now tag pages as dirty/under writeback in the radix tree.
- *
- * There is also a per-mapping radix tree mapping index to the page
- * in memory if present. The tree is rooted at mapping->root.  
- *
- * All process pages can do I/O:
+ * All pagecache pages may be subject to I/O:
  * - inode pages may need to be read from disk,
  * - inode pages which have been modified and are MAP_SHARED may need
- *   to be written to disk,
- * - private pages which have been modified may need to be swapped out
- *   to swap space and (later) to be read back into memory.
+ *   to be written back to the inode on disk,
+ * - anonymous pages (including MAP_PRIVATE file mappings) which have been
+ *   modified may need to be swapped out to swap space and (later) to be read
+ *   back into memory.
  */
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
