Message-ID: <3CB3A44C.C9884437@zip.com.au>
Date: Tue, 09 Apr 2002 19:32:44 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH][RC] radix-tree pagecache for 2.5
References: <20020409104753.A490@infradead.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> 
> I think I have a first release candidate of the radix-tree pagecache for
> the 2.5 tree.

Hi, Christoph.

There are a few places where I believe a write_lock is needed
rather than a read_lock.  Places where we hold the lock seemingly
for read, then later on go and modify the tree, or the mapping's
inode lists.

I'll rediff against -pre3, test with the following incremental
patch on the quad and if it survives, pass on to Linus.

I'll add a FIXME at the mempool allocation site too.  512
ratnodes is maybe 300k.  We need to justify pinning that
amount of memory...  And work out a means of scaling the
pool according to the number of pages in the system...



--- 2.5.8-pre2/mm/vmscan.c~dallocbase-07-new_ratcache_fixes	Tue Apr  9 15:39:06 2002
+++ 2.5.8-pre2-akpm/mm/vmscan.c	Tue Apr  9 15:39:06 2002
@@ -483,10 +483,10 @@ static int shrink_cache(int nr_pages, zo
 		 * This is the non-racy check for busy page.
 		 */
 		if (mapping) {
-			read_lock(&mapping->page_lock);
+			write_lock(&mapping->page_lock);
 			if (is_page_cache_freeable(page))
 				goto page_freeable;
-			read_unlock(&mapping->page_lock);
+			write_unlock(&mapping->page_lock);
 		}
 		UnlockPage(page);
 page_mapped:
@@ -507,7 +507,7 @@ page_freeable:
 		 * the page is freeable* so not in use by anybody.
 		 */
 		if (PageDirty(page)) {
-			read_unlock(&mapping->page_lock);
+			write_unlock(&mapping->page_lock);
 			UnlockPage(page);
 			continue;
 		}
@@ -515,12 +515,12 @@ page_freeable:
 		/* point of no return */
 		if (likely(!PageSwapCache(page))) {
 			__remove_inode_page(page);
-			read_unlock(&mapping->page_lock);
+			write_unlock(&mapping->page_lock);
 		} else {
 			swp_entry_t swap;
 			swap.val = page->index;
 			__delete_from_swap_cache(page);
-			read_unlock(&mapping->page_lock);
+			write_unlock(&mapping->page_lock);
 			swap_free(swap);
 		}
 
--- 2.5.8-pre2/mm/filemap.c~dallocbase-07-new_ratcache_fixes	Tue Apr  9 15:39:06 2002
+++ 2.5.8-pre2-akpm/mm/filemap.c	Tue Apr  9 15:39:06 2002
@@ -59,7 +59,7 @@ spinlock_t pagemap_lru_lock __cacheline_
 /*
  * Remove a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
- * is safe.
+ * is safe.  The caller must hold a write_lock on the mapping's page_lock.
  */
 void __remove_inode_page(struct page *page)
 {
@@ -574,6 +574,7 @@ int filemap_fdatawait(struct address_spa
 /*
  * This adds a page to the page cache, starting out as locked,
  * owned by us, but unreferenced, not uptodate and with no errors.
+ * The caller must hold a write_lock on the mapping->page_lock.
  */
 static int __add_to_page_cache(struct page *page,
 		struct address_space *mapping, unsigned long offset)
@@ -874,19 +875,19 @@ struct page * find_or_create_page(struct
 	if (!page) {
 		struct page *newpage = alloc_page(gfp_mask);
 		if (newpage) {
-			read_lock(&mapping->page_lock);
+			write_lock(&mapping->page_lock);
 			page = __find_lock_page(mapping, index);
 			if (likely(!page)) {
 				page = newpage;
 				if (__add_to_page_cache(page, mapping, index)) {
-					read_unlock(&mapping->page_lock);
+					write_unlock(&mapping->page_lock);
 					page_cache_release(page);
 					page = NULL;
 					goto out;
 				}
 				newpage = NULL;
 			}
-			read_unlock(&mapping->page_lock);
+			write_unlock(&mapping->page_lock);
 			if (newpage == NULL)
 				lru_cache_add(page);
 			else 
@@ -1280,13 +1281,13 @@ void do_generic_file_read(struct file * 
 		 * Try to find the data in the page cache..
 		 */
 
-		read_lock(&mapping->page_lock);
+		write_lock(&mapping->page_lock);
 		page = radix_tree_lookup(&mapping->page_tree, index);
 		if (!page)
 			goto no_cached_page;
 found_page:
 		page_cache_get(page);
-		read_unlock(&mapping->page_lock);
+		write_unlock(&mapping->page_lock);
 
 		if (!Page_Uptodate(page))
 			goto page_not_up_to_date;
@@ -1380,7 +1381,7 @@ no_cached_page:
 		 * We get here with the page cache lock held.
 		 */
 		if (!cached_page) {
-			read_unlock(&mapping->page_lock);
+			write_unlock(&mapping->page_lock);
 			cached_page = page_cache_alloc(mapping);
 			if (!cached_page) {
 				desc->error = -ENOMEM;
@@ -1391,7 +1392,7 @@ no_cached_page:
 			 * Somebody may have added the page while we
 			 * dropped the page cache lock. Check for that.
 			 */
-			read_lock(&mapping->page_lock);
+			write_lock(&mapping->page_lock);
 			page = radix_tree_lookup(&mapping->page_tree, index);
 			if (page)
 				goto found_page;
@@ -1401,12 +1402,12 @@ no_cached_page:
 		 * Ok, add the new page to the hash-queues...
 		 */
 		if (__add_to_page_cache(cached_page, mapping, index) < 0) {
-			read_unlock(&mapping->page_lock);
+			write_unlock(&mapping->page_lock);
 			desc->error = -ENOMEM;
 			break;
 		}
 		page = cached_page;
-		read_unlock(&mapping->page_lock);
+		write_unlock(&mapping->page_lock);
 		lru_cache_add(page);		
 		cached_page = NULL;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
