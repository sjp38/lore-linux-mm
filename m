Message-Id: <200405222203.i4MM3Zr12318@mail.osdl.org>
Subject: [patch 06/57] __set_page_dirty_nobuffers race fix
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:03:03 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>


Running __mark_inode_dirty() against a swapcache page is illegal and will
oops.

I see a race in set_page_dirty() wherein it can be called with a PageSwapCache
page, but if the page is removed from swapcache after
__set_page_dirty_nobuffers() drops tree_lock(), we have the situation where
PageSwapCache() is false, but local variable `mapping' points at swapcache.

Handle that by checking for non-null mapping->host.  We don't care about the
page state at this point - we're only interested in the inode.



There is a converse case: what if a page is added to swapcache as we are
running set_page_dirty() against it?

In this case the page gets its PG_dirty flag set but it is not tagged as dirty
in the swapper_space radix tree.  The swap writeout code will handle this OK
and test_clear_page_dirty()'s call to
radix_tree_tag_clear(PAGECACHE_TAG_DIRTY) will silently have no effect.  The
only downside is that future radix-tree-based writearound won't notice that
such pages are dirty and swap IO scheduling will be a teensy bit worse.


The patch also fixes the (silly) testing of local variable `mapping' to see if
the page was truncated.  We should test page_mapping() for that.


---

 25-akpm/mm/page-writeback.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff -puN mm/page-writeback.c~__set_page_dirty_nobuffers-race-fix mm/page-writeback.c
--- 25/mm/page-writeback.c~__set_page_dirty_nobuffers-race-fix	2004-05-22 14:56:22.007745840 -0700
+++ 25-akpm/mm/page-writeback.c	2004-05-22 14:56:22.011745232 -0700
@@ -547,13 +547,16 @@ EXPORT_SYMBOL(write_one_page);
  * For address_spaces which do not use buffers.  Just tag the page as dirty in
  * its radix tree.
  *
- * __set_page_dirty_nobuffers() may return -ENOSPC.  But if it does, the page
- * is still safe, as long as it actually manages to find some blocks at
- * writeback time.
- *
  * This is also used when a single buffer is being dirtied: we want to set the
  * page dirty in that case, but not all the buffers.  This is a "bottom-up"
  * dirtying, whereas __set_page_dirty_buffers() is a "top-down" dirtying.
+ *
+ * Most callers have locked the page, which pins the address_space in memory.
+ * But zap_pte_range() does not lock the page, however in that case the
+ * mapping is pinned by the vma's ->vm_file reference.
+ *
+ * We take care to handle the case where the page was truncated from the
+ * mapping by re-checking page_mapping() insode tree_lock.
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
@@ -565,7 +568,7 @@ int __set_page_dirty_nobuffers(struct pa
 		if (mapping) {
 			spin_lock_irq(&mapping->tree_lock);
 			mapping = page_mapping(page);
-			if (mapping) {	/* Race with truncate? */
+			if (page_mapping(page)) { /* Race with truncate? */
 				BUG_ON(page_mapping(page) != mapping);
 				if (!mapping->backing_dev_info->memory_backed)
 					inc_page_state(nr_dirty);
@@ -573,9 +576,11 @@ int __set_page_dirty_nobuffers(struct pa
 					page_index(page), PAGECACHE_TAG_DIRTY);
 			}
 			spin_unlock_irq(&mapping->tree_lock);
-			if (!PageSwapCache(page))
+			if (mapping->host) {
+				/* !PageAnon && !swapper_space */
 				__mark_inode_dirty(mapping->host,
 							I_DIRTY_PAGES);
+			}
 		}
 	}
 	return ret;

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
