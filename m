Date: Thu, 5 Apr 2001 17:32:52 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] swap_state.c thinko
In-Reply-To: <Pine.LNX.4.30.0104051310470.1767-100000@today.toronto.redhat.com>
Message-ID: <Pine.LNX.4.31.0104051727490.1149-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Rik van Riel <riel@conectiva.com.br>, arjanv@redhat.com, alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 5 Apr 2001, Ben LaHaise wrote:
>
> You're right.  Here's the hopefully correct version.

I'd prefer something more along these lines: it gets rid of
free_page_and_swap_cache() altogether, along with "is_page_shared()",
realizing that "is_page_shared()" was only validly used on swap-cache
pages anyway and thus getting rid of the generic tests it had for other
kinds of pages.

It also fixes the swap sharing criteria to properly accept the case of a
page that has buffers but no other usage (which it pretty much always will
have, if it was truly read in from disk).

As far as I can tell, the lack of buffer-testing meant that we almost
_never_ just re-used the cache page directly on a read-swapin followed by
a write to the page.  Can that really be true? That should be the common
case, and would have made the swap cache much less effective than it
should be.

Anybody see any thinko's here?

		Linus


------
diff -u --recursive --new-file v2.4.3/linux/arch/sparc/mm/generic.c linux/arch/sparc/mm/generic.c
--- v2.4.3/linux/arch/sparc/mm/generic.c	Wed Aug  9 13:49:55 2000
+++ linux/arch/sparc/mm/generic.c	Thu Apr  5 14:38:29 2001
@@ -21,11 +21,7 @@
 		struct page *ptpage = pte_page(page);
 		if ((!VALID_PAGE(ptpage)) || PageReserved(ptpage))
 			return;
-		/*
-		 * free_page() used to be able to clear swap cache
-		 * entries.  We may now have to do it manually.
-		 */
-		free_page_and_swap_cache(ptpage);
+		page_cache_release(page);
 		return;
 	}
 	swap_free(pte_to_swp_entry(page));
diff -u --recursive --new-file v2.4.3/linux/arch/sparc64/mm/generic.c linux/arch/sparc64/mm/generic.c
--- v2.4.3/linux/arch/sparc64/mm/generic.c	Mon Mar 26 15:42:57 2001
+++ linux/arch/sparc64/mm/generic.c	Thu Apr  5 14:38:45 2001
@@ -21,11 +21,7 @@
 		struct page *ptpage = pte_page(page);
 		if ((!VALID_PAGE(ptpage)) || PageReserved(ptpage))
 			return;
-		/*
-		 * free_page() used to be able to clear swap cache
-		 * entries.  We may now have to do it manually.
-		 */
-		free_page_and_swap_cache(ptpage);
+		page_cache_release(ptpage);
 		return;
 	}
 	swap_free(pte_to_swp_entry(page));
diff -u --recursive --new-file v2.4.3/linux/include/linux/swap.h linux/include/linux/swap.h
--- v2.4.3/linux/include/linux/swap.h	Mon Mar 26 15:48:11 2001
+++ linux/include/linux/swap.h	Thu Apr  5 15:44:52 2001
@@ -134,7 +134,6 @@
 extern void __delete_from_swap_cache(struct page *page);
 extern void delete_from_swap_cache(struct page *page);
 extern void delete_from_swap_cache_nolock(struct page *page);
-extern void free_page_and_swap_cache(struct page *page);

 /* linux/mm/swapfile.c */
 extern unsigned int nr_swapfiles;
@@ -166,23 +165,6 @@
 extern unsigned long swap_cache_find_total;
 extern unsigned long swap_cache_find_success;
 #endif
-
-/*
- * Work out if there are any other processes sharing this page, ignoring
- * any page reference coming from the swap cache, or from outstanding
- * swap IO on this page.  (The page cache _does_ count as another valid
- * reference to the page, however.)
- */
-static inline int is_page_shared(struct page *page)
-{
-	unsigned int count;
-	if (PageReserved(page))
-		return 1;
-	count = page_count(page);
-	if (PageSwapCache(page))
-		count += swap_count(page) - 2 - !!page->buffers;
-	return  count > 1;
-}

 extern spinlock_t pagemap_lru_lock;

diff -u --recursive --new-file v2.4.3/linux/mm/memory.c linux/mm/memory.c
--- v2.4.3/linux/mm/memory.c	Mon Mar 26 11:02:24 2001
+++ linux/mm/memory.c	Thu Apr  5 16:41:17 2001
@@ -274,7 +274,7 @@
 		 */
 		if (pte_dirty(pte) && page->mapping)
 			set_page_dirty(page);
-		free_page_and_swap_cache(page);
+		page_cache_release(page);
 		return 1;
 	}
 	swap_free(pte_to_swp_entry(pte));
@@ -815,6 +815,24 @@
 }

 /*
+ * Work out if there are any other processes sharing this
+ * swap cache page. Never mind the buffers.
+ */
+static inline int exclusive_swap_page(struct page *page)
+{
+	unsigned int count;
+
+	if (!PageLocked(page))
+		BUG();
+	if (!PageSwapCache(page))
+		return 0;
+	count = page_count(page) - !!page->buffers;	/*  2: us + swap cache */
+	count += swap_count(page);			/* +1: just swap cache */
+	return count == 3;				/* =3: total */
+}
+
+
+/*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
  * and decrementing the shared-page counter for the old page.
@@ -853,19 +871,21 @@
 	 *   marked dirty).
 	 */
 	switch (page_count(old_page)) {
+	int can_reuse;
+	case 3:
+		if (!old_page->buffers)
+			break;
+		/* FallThrough */
 	case 2:
-		/*
-		 * Lock the page so that no one can look it up from
-		 * the swap cache, grab a reference and start using it.
-		 * Can not do lock_page, holding page_table_lock.
-		 */
-		if (!PageSwapCache(old_page) || TryLockPage(old_page))
+		if (!PageSwapCache(old_page))
 			break;
-		if (is_page_shared(old_page)) {
-			UnlockPage(old_page);
+		if (TryLockPage(old_page))
 			break;
-		}
+		/* Recheck swapcachedness once the page is locked */
+		can_reuse = exclusive_swap_page(old_page);
 		UnlockPage(old_page);
+		if (!can_reuse)
+			break;
 		/* FallThrough */
 	case 1:
 		if (PageReserved(old_page))
@@ -903,8 +923,7 @@
 	return -1;
 }

-static void vmtruncate_list(struct vm_area_struct *mpnt,
-			    unsigned long pgoff, unsigned long partial)
+static void vmtruncate_list(struct vm_area_struct *mpnt, unsigned long pgoff)
 {
 	do {
 		struct mm_struct *mm = mpnt->vm_mm;
@@ -947,7 +966,7 @@
  */
 void vmtruncate(struct inode * inode, loff_t offset)
 {
-	unsigned long partial, pgoff;
+	unsigned long pgoff;
 	struct address_space *mapping = inode->i_mapping;
 	unsigned long limit;

@@ -959,19 +978,15 @@
 		goto out_unlock;

 	pgoff = (offset + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	partial = (unsigned long)offset & (PAGE_CACHE_SIZE - 1);
-
 	if (mapping->i_mmap != NULL)
-		vmtruncate_list(mapping->i_mmap, pgoff, partial);
+		vmtruncate_list(mapping->i_mmap, pgoff);
 	if (mapping->i_mmap_shared != NULL)
-		vmtruncate_list(mapping->i_mmap_shared, pgoff, partial);
+		vmtruncate_list(mapping->i_mmap_shared, pgoff);

 out_unlock:
 	spin_unlock(&mapping->i_shared_lock);
 	truncate_inode_pages(mapping, offset);
-	if (inode->i_op && inode->i_op->truncate)
-		inode->i_op->truncate(inode);
-	return;
+	goto out_truncate;

 do_expand:
 	limit = current->rlim[RLIMIT_FSIZE].rlim_cur;
@@ -986,8 +1001,13 @@
 		}
 	}
 	inode->i_size = offset;
-	if (inode->i_op && inode->i_op->truncate)
+
+out_truncate:
+	if (inode->i_op && inode->i_op->truncate) {
+		lock_kernel();
 		inode->i_op->truncate(inode);
+		unlock_kernel();
+	}
 out:
 	return;
 }
@@ -1077,7 +1097,7 @@
 	pte = mk_pte(page, vma->vm_page_prot);

 	swap_free(entry);
-	if (write_access && !is_page_shared(page))
+	if (write_access && exclusive_swap_page(page))
 		pte = pte_mkwrite(pte_mkdirty(pte));
 	UnlockPage(page);

diff -u --recursive --new-file v2.4.3/linux/mm/swap_state.c linux/mm/swap_state.c
--- v2.4.3/linux/mm/swap_state.c	Fri Dec 29 15:04:27 2000
+++ linux/mm/swap_state.c	Thu Apr  5 14:35:08 2001
@@ -17,8 +17,22 @@

 #include <asm/pgtable.h>

+/*
+ * We may have stale swap cache pages in memory: notice
+ * them here and get rid of the unnecessary final write.
+ */
 static int swap_writepage(struct page *page)
 {
+	/* One for the page cache, one for this user, one for page->buffers */
+	if (page_count(page) > 2 + !!page->buffers)
+		goto in_use;
+	if (swap_count(page) > 1)
+		goto in_use;
+
+	/* We could remove it here, but page_launder will do it anyway */
+	return 0;
+
+in_use:
 	rw_swap_page(WRITE, page, 0);
 	return 0;
 }
@@ -129,26 +143,6 @@
 	delete_from_swap_cache_nolock(page);
 	UnlockPage(page);
 }
-
-/*
- * Perform a free_page(), also freeing any swap cache associated with
- * this page if it is the last user of the page. Can not do a lock_page,
- * as we are holding the page_table_lock spinlock.
- */
-void free_page_and_swap_cache(struct page *page)
-{
-	/*
-	 * If we are the only user, then try to free up the swap cache.
-	 */
-	if (PageSwapCache(page) && !TryLockPage(page)) {
-		if (!is_page_shared(page)) {
-			delete_from_swap_cache_nolock(page);
-		}
-		UnlockPage(page);
-	}
-	page_cache_release(page);
-}
-

 /*
  * Lookup a swap entry in the swap cache. A found page will be returned

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
