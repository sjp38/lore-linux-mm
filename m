Date: Sat, 10 Nov 2007 06:43:43 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/2] mm: page trylock rename
Message-ID: <20071110054343.GA17803@wotan.suse.de>
References: <20071110051222.GA16018@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071110051222.GA16018@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Here's a little something to make up for the occasional extra cacheline
write in add_to_page_cache. Saves an atomic operation and 2 memory barriers
for every add_to_page_cache().

I suspect lockdepifying the page lock will also barf without this, too...

---
Setting and clearing the page locked when inserting it into swapcache /
pagecache when it has no other references can use non-atomic page flags
operatoins because no other CPU may be operating on it at this time.

Also, remove comments in add_to_swap_cache that suggest the contrary, and
rename it to add_to_swap_cache_lru(), better matching the filemap code,
and which meaks it more clear that the page has no other references yet.

Also, the comments in add_to_page_cache aren't really correct. It is not
just called for new pages, but for tmpfs pages as well. They are locked
when called, so it is OK for atomic bitflag access, but we can't do
non-atomic access. Split this into add_to_page_cache_locked, for tmpfs.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -426,29 +426,28 @@ int filemap_write_and_wait_range(struct 
 }
 
 /**
- * add_to_page_cache - add newly allocated pagecache pages
+ * add_to_page_cache_locked - add a locked page to pagecache
  * @page:	page to add
  * @mapping:	the page's address_space
  * @offset:	page index
  * @gfp_mask:	page allocation mode
  *
- * This function is used to add newly allocated pagecache pages;
- * the page is new, so we can just run set_page_locked() against it.
- * The other page state flags were set by rmqueue().
- *
+ * This function is used to add a page to the pagecache. It must be locked.
  * This function does not add the page to the LRU.  The caller must do that.
  */
-int add_to_page_cache(struct page *page, struct address_space *mapping,
+int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		pgoff_t offset, gfp_t gfp_mask)
 {
-	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	int error;
+
+	VM_BUG_ON(!PageLocked(page));
 
+	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
 	if (error == 0) {
 		write_lock_irq(&mapping->tree_lock);
 		error = radix_tree_insert(&mapping->page_tree, offset, page);
 		if (!error) {
 			page_cache_get(page);
-			set_page_locked(page);
 			page->mapping = mapping;
 			page->index = offset;
 			mapping->nrpages++;
@@ -459,7 +458,7 @@ int add_to_page_cache(struct page *page,
 	}
 	return error;
 }
-EXPORT_SYMBOL(add_to_page_cache);
+EXPORT_SYMBOL(add_to_page_cache_locked);
 
 int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 				pgoff_t offset, gfp_t gfp_mask)
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -95,7 +95,7 @@ static int __add_to_swap_cache(struct pa
 	return error;
 }
 
-static int add_to_swap_cache(struct page *page, swp_entry_t entry)
+static int add_to_swap_cache_lru(struct page *page, swp_entry_t entry)
 {
 	int error;
 
@@ -104,19 +104,18 @@ static int add_to_swap_cache(struct page
 		INC_CACHE_INFO(noent_race);
 		return -ENOENT;
 	}
-	set_page_locked(page);
+	__set_page_locked(page);
 	error = __add_to_swap_cache(page, entry, GFP_KERNEL);
-	/*
-	 * Anon pages are already on the LRU, we don't run lru_cache_add here.
-	 */
 	if (error) {
-		clear_page_locked(page);
+		__clear_page_locked(page);
 		swap_free(entry);
 		if (error == -EEXIST)
 			INC_CACHE_INFO(exist_race);
 		return error;
 	}
 	INC_CACHE_INFO(add_total);
+	lru_cache_add_active(page);
+
 	return 0;
 }
 
@@ -235,7 +234,7 @@ int move_to_swap_cache(struct page *page
 int move_from_swap_cache(struct page *page, unsigned long index,
 		struct address_space *mapping)
 {
-	int err = add_to_page_cache(page, mapping, index, GFP_ATOMIC);
+	int err = add_to_page_cache_locked(page, mapping, index, GFP_ATOMIC);
 	if (!err) {
 		delete_from_swap_cache(page);
 		/* shift page from clean_pages to dirty_pages list */
@@ -353,12 +352,11 @@ struct page *read_swap_cache_async(swp_e
 		 * the just freed swap entry for an existing page.
 		 * May fail (-ENOMEM) if radix-tree node allocation failed.
 		 */
-		err = add_to_swap_cache(new_page, entry);
+		err = add_to_swap_cache_lru(new_page, entry);
 		if (!err) {
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_active(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -133,13 +133,6 @@ static inline struct page *read_mapping_
 	return read_cache_page(mapping, index, filler, data);
 }
 
-int add_to_page_cache(struct page *page, struct address_space *mapping,
-				pgoff_t index, gfp_t gfp_mask);
-int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
-				pgoff_t index, gfp_t gfp_mask);
-extern void remove_from_page_cache(struct page *page);
-extern void __remove_from_page_cache(struct page *page);
-
 /*
  * Return byte-offset into filesystem object for page.
  */
@@ -160,14 +153,17 @@ extern void FASTCALL(__lock_page(struct 
 extern void FASTCALL(__lock_page_nosync(struct page *page));
 extern void FASTCALL(unlock_page(struct page *page));
 
-static inline void set_page_locked(struct page *page)
+static inline void __set_page_locked(struct page *page)
 {
-	set_bit(PG_locked, &page->flags);
+	/* concurrent access would cause data loss with non-atomic bitop */
+	VM_BUG_ON(page_count(page) != 1);
+	__set_bit(PG_locked, &page->flags);
 }
 
-static inline void clear_page_locked(struct page *page)
+static inline void __clear_page_locked(struct page *page)
 {
-	clear_bit(PG_locked, &page->flags);
+	VM_BUG_ON(page_count(page) != 1);
+	__clear_bit(PG_locked, &page->flags);
 }
 
 static inline int trylock_page(struct page *page)
@@ -226,6 +222,32 @@ static inline void wait_on_page_writebac
 
 extern void end_page_writeback(struct page *page);
 
+
+int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
+				pgoff_t index, gfp_t gfp_mask);
+int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
+				pgoff_t index, gfp_t gfp_mask);
+extern void remove_from_page_cache(struct page *page);
+extern void __remove_from_page_cache(struct page *page);
+
+/*
+ * Like add_to_page_cache_locked, but used to add newly allocated pages: the
+ * page is new, so we can just run __set_page_locked() against it.
+ */
+static inline int add_to_page_cache(struct page *page, struct address_space *mapping,
+		pgoff_t offset, gfp_t gfp_mask)
+{
+	int error;
+
+	__set_page_locked(page);
+	error = add_to_page_cache_locked(page, mapping, offset, gfp_mask);
+	if (unlikely(error))
+		__clear_page_locked(page);
+
+	return error;
+}
+
+
 /*
  * Fault a userspace page into pagetables.  Return non-zero on a fault.
  *

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
