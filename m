Date: Sun, 9 Apr 2000 01:02:05 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
In-Reply-To: <200004082139.OAA06375@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.21.0004090005020.18345-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 8 Apr 2000, Kanoj Sarcar wrote:

>shrink_mmap
>--------------						__find_get_page
>get pagemap_lru_lock					----------------
>LockPage					
>drop pagemap_lru_lock
>Fail if page_count(page) > 1
>get pagecache_lock
>get_page
>Fail if page_count(page) != 2
>if PageSwapCache, drop pagecache_lock
>							get pagecache_lock
>							Finds page in swapcache,
>								does get_page
>							drop pagecache_lock
>	and __delete_from_swap_cache,
>	which releases PageLock.
>							LockPage succeeds,
>							erronesouly believes he
>							has swapcache page.
>
>Did I miss some interlocking step that would prevent this from happening?

Oh, very good point indeed, I don't think you are missing anything. Thanks
for showing me that!

It seems to me the only reason we was dropping the lock earlier for the
swap cache was to be able to use the remove_inode_page and so avoding
having to export a secondary remove_inode_page that doesn't grab the
page_cache_lock. It looks the only reason was an implementation issue.

So IMHVO it would be nicer to change the locking in shrink_mmap() instead
of putting the page-cache check in the swap cache lookup fast path. Swap
cache and page cache are sharing the same locking rules w.r.t. the
hashtable. That was the only exception as far I can tell and removing it
would give us a cleaner design IMHO.

What do you think about something like this?

diff -urN swap-entry-2/include/linux/mm.h swap-entry-3/include/linux/mm.h
--- swap-entry-2/include/linux/mm.h	Sat Apr  8 19:16:28 2000
+++ swap-entry-3/include/linux/mm.h	Sun Apr  9 00:18:43 2000
@@ -449,6 +449,7 @@
 struct zone_t;
 /* filemap.c */
 extern void remove_inode_page(struct page *);
+extern void __remove_inode_page(struct page *);
 extern unsigned long page_unuse(struct page *);
 extern int shrink_mmap(int, int, zone_t *);
 extern void truncate_inode_pages(struct address_space *, loff_t);
diff -urN swap-entry-2/include/linux/swap.h swap-entry-3/include/linux/swap.h
--- swap-entry-2/include/linux/swap.h	Sat Apr  8 18:08:37 2000
+++ swap-entry-3/include/linux/swap.h	Sun Apr  9 00:47:42 2000
@@ -105,6 +105,7 @@
 /*
  * Make these inline later once they are working properly.
  */
+extern void shrink_swap_cache(struct page *);
 extern void unlink_from_swap_cache(struct page *);
 extern void __delete_from_swap_cache(struct page *page);
 extern void delete_from_swap_cache(struct page *page);
diff -urN swap-entry-2/mm/filemap.c swap-entry-3/mm/filemap.c
--- swap-entry-2/mm/filemap.c	Sat Apr  8 04:46:04 2000
+++ swap-entry-3/mm/filemap.c	Sun Apr  9 00:39:23 2000
@@ -77,6 +77,13 @@
 	atomic_dec(&page_cache_size);
 }
 
+inline void __remove_inode_page(struct page *page)
+{
+	remove_page_from_inode_queue(page);
+	remove_page_from_hash_queue(page);
+	page->mapping = NULL;
+}
+
 /*
  * Remove a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
@@ -88,9 +95,7 @@
 		PAGE_BUG(page);
 
 	spin_lock(&pagecache_lock);
-	remove_page_from_inode_queue(page);
-	remove_page_from_hash_queue(page);
-	page->mapping = NULL;
+	__remove_inode_page(page);
 	spin_unlock(&pagecache_lock);
 }
 
@@ -298,8 +303,8 @@
 		 * were to be marked referenced..
 		 */
 		if (PageSwapCache(page)) {
+			shrink_swap_cache(page);
 			spin_unlock(&pagecache_lock);
-			__delete_from_swap_cache(page);
 			/* the page is local to us now */
 			page->flags &= ~(1UL << PG_swap_entry);
 			goto made_inode_progress;
diff -urN swap-entry-2/mm/swap_state.c swap-entry-3/mm/swap_state.c
--- swap-entry-2/mm/swap_state.c	Sat Apr  8 17:29:46 2000
+++ swap-entry-3/mm/swap_state.c	Sun Apr  9 00:39:17 2000
@@ -55,6 +55,19 @@
 	return ret;
 }
 
+static inline void __remove_from_swap_cache(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+
+	if (mapping != &swapper_space)
+		BUG();
+	if (!PageSwapCache(page) || !PageLocked(page))
+		PAGE_BUG(page);
+
+	PageClearSwapCache(page);
+	__remove_inode_page(page);
+}
+
 static inline void remove_from_swap_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
@@ -76,6 +89,20 @@
 	lru_cache_del(page);
 	remove_from_swap_cache(page);
 	__free_page(page);
+}
+
+/* called by shrink_mmap() with the page_cache_lock held */
+void shrink_swap_cache(struct page *page)
+{
+	swp_entry_t entry;
+
+	entry.val = page->index;
+
+#ifdef SWAP_CACHE_INFO
+	swap_cache_del_total++;
+#endif
+	__remove_from_swap_cache(page);
+	swap_free(entry);
 }
 
 /*


The other option is to keep the checks in the lookup swap cache fast path.

Comments?

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
