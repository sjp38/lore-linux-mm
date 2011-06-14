Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 268ED6B00E8
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 06:59:35 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id p5EAxW5W010634
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:59:32 -0700
Received: from pxi16 (pxi16.prod.google.com [10.243.27.16])
	by kpbe15.cbf.corp.google.com with ESMTP id p5EAxU7T009580
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:59:31 -0700
Received: by pxi16 with SMTP id 16so3089398pxi.32
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 03:59:30 -0700 (PDT)
Date: Tue, 14 Jun 2011 03:59:19 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 12/12] mm: a few small updates for radix-swap
In-Reply-To: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106140357350.29206@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Remove PageSwapBacked (!page_is_file_cache) cases from
add_to_page_cache_locked() and add_to_page_cache_lru():
those pages now go through shmem_add_to_page_cache().

Remove a comment on maximum tmpfs size from fsstack_copy_inode_size(),
and add a comment on swap entries to invalidate_mapping_pages().

And mincore_page() uses find_get_page() on what might be shmem or a
tmpfs file: allow for a radix_tree_exceptional_entry(), and proceed to
find_get_page() on swapper_space if so (oh, swapper_space needs #ifdef).

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 fs/stack.c    |    5 +----
 mm/filemap.c  |   21 +++------------------
 mm/mincore.c  |   10 ++++++----
 mm/truncate.c |    8 ++++++++
 4 files changed, 18 insertions(+), 26 deletions(-)

--- linux.orig/fs/stack.c	2011-06-14 01:22:10.768120780 -0700
+++ linux/fs/stack.c	2011-06-14 01:23:26.088494288 -0700
@@ -29,10 +29,7 @@ void fsstack_copy_inode_size(struct inod
 	 *
 	 * We don't actually know what locking is used at the lower level;
 	 * but if it's a filesystem that supports quotas, it will be using
-	 * i_lock as in inode_add_bytes().  tmpfs uses other locking, and
-	 * its 32-bit is (just) able to exceed 2TB i_size with the aid of
-	 * holes; but its i_blocks cannot carry into the upper long without
-	 * almost 2TB swap - let's ignore that case.
+	 * i_lock as in inode_add_bytes().
 	 */
 	if (sizeof(i_blocks) > sizeof(long))
 		spin_lock(&src->i_lock);
--- linux.orig/mm/filemap.c	2011-06-14 01:22:10.768120780 -0700
+++ linux/mm/filemap.c	2011-06-14 01:23:26.088494288 -0700
@@ -33,7 +33,6 @@
 #include <linux/cpuset.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
-#include <linux/mm_inline.h> /* for page_is_file_cache() */
 #include <linux/cleancache.h>
 #include "internal.h"
 
@@ -465,6 +464,7 @@ int add_to_page_cache_locked(struct page
 	int error;
 
 	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(PageSwapBacked(page));
 
 	error = mem_cgroup_cache_charge(page, current->mm,
 					gfp_mask & GFP_RECLAIM_MASK);
@@ -482,8 +482,6 @@ int add_to_page_cache_locked(struct page
 		if (likely(!error)) {
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
-			if (PageSwapBacked(page))
-				__inc_zone_page_state(page, NR_SHMEM);
 			spin_unlock_irq(&mapping->tree_lock);
 		} else {
 			page->mapping = NULL;
@@ -505,22 +503,9 @@ int add_to_page_cache_lru(struct page *p
 {
 	int ret;
 
-	/*
-	 * Splice_read and readahead add shmem/tmpfs pages into the page cache
-	 * before shmem_readpage has a chance to mark them as SwapBacked: they
-	 * need to go on the anon lru below, and mem_cgroup_cache_charge
-	 * (called in add_to_page_cache) needs to know where they're going too.
-	 */
-	if (mapping_cap_swap_backed(mapping))
-		SetPageSwapBacked(page);
-
 	ret = add_to_page_cache(page, mapping, offset, gfp_mask);
-	if (ret == 0) {
-		if (page_is_file_cache(page))
-			lru_cache_add_file(page);
-		else
-			lru_cache_add_anon(page);
-	}
+	if (ret == 0)
+		lru_cache_add_file(page);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
--- linux.orig/mm/mincore.c	2011-06-14 01:22:10.768120780 -0700
+++ linux/mm/mincore.c	2011-06-14 01:23:26.088494288 -0700
@@ -69,13 +69,15 @@ static unsigned char mincore_page(struct
 	 * file will not get a swp_entry_t in its pte, but rather it is like
 	 * any other file mapping (ie. marked !present and faulted in with
 	 * tmpfs's .fault). So swapped out tmpfs mappings are tested here.
-	 *
-	 * However when tmpfs moves the page from pagecache and into swapcache,
-	 * it is still in core, but the find_get_page below won't find it.
-	 * No big deal, but make a note of it.
 	 */
 	page = find_get_page(mapping, pgoff);
 	if (page) {
+#ifdef CONFIG_SWAP
+		if (radix_tree_exceptional_entry(page)) {
+			swp_entry_t swap = radix_to_swp_entry(page);
+			page = find_get_page(&swapper_space, swap.val);
+		}
+#endif
 		present = PageUptodate(page);
 		page_cache_release(page);
 	}
--- linux.orig/mm/truncate.c	2011-06-14 01:22:10.768120780 -0700
+++ linux/mm/truncate.c	2011-06-14 01:23:26.092494303 -0700
@@ -331,6 +331,14 @@ unsigned long invalidate_mapping_pages(s
 	unsigned long count = 0;
 	int i;
 
+	/*
+	 * Note: this function may get called on a shmem/tmpfs mapping:
+	 * pagevec_lookup() might then return 0 prematurely (because it
+	 * got a gangful of swap entries); but it's hardly worth worrying
+	 * about - it can rarely have anything to free from such a mapping
+	 * (most pages are dirty), and already skips over any difficulties.
+	 */
+
 	pagevec_init(&pvec, 0);
 	while (index <= end && pagevec_lookup(&pvec, mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
