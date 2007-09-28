Date: Fri, 28 Sep 2007 17:55:36 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: document tree_lock->zone.lock lockorder
Message-ID: <20070928155536.GC12538@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

If you won't take the patch to move allocation out from under tree_lock,
please apply this update to lock ordering comments.

zone->lock is quite an "inner" lock and mostly constrained to page alloc
as well, so like slab locks, it probably isn't something that is critically
important to document here. However unlike slab locks, zone lock could be
used more widely in future, and page_alloc.c might possibly have more
business to do tricky things with pagecache than does slab. So... I don't
think it hurts to document it.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -63,6 +63,7 @@ generic_file_direct_IO(int rw, struct ki
  *    ->private_lock		(__free_pte->__set_page_dirty_buffers)
  *      ->swap_lock		(exclusive_swap_page, others)
  *        ->mapping->tree_lock
+ *          ->zone.lock
  *
  *  ->i_mutex
  *    ->i_mmap_lock		(truncate->unmap_mapping_range)
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -36,6 +36,7 @@
  *                 mapping->tree_lock (widely used, in set_page_dirty,
  *                           in arch-dependent flush_dcache_mmap_lock,
  *                           within inode_lock in __sync_single_inode)
+ *                   zone->lock (within radix tree node alloc)
  */
 
 #include <linux/mm.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
