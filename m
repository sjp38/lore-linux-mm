Received: from adsl-64-174-89-36.dsl.sntc01.pacbell.net ([64.174.89.36] helo=zip.com.au)
	by www.linux.org.uk with esmtp (Exim 3.33 #5)
	id 17mXCt-0001YA-00
	for linux-mm@kvack.org; Wed, 04 Sep 2002 11:16:19 +0100
Message-ID: <3D75E054.B341E067@zip.com.au>
Date: Wed, 04 Sep 2002 03:28:36 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: nonblocking-vm.patch
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is the only interesting part of today's patches really.

- If the page is Dirty and its queue is not congested, do some writeback.

- If the page is dirty and its queue is congested, refile the page.

- If the page is under writeback, refile it.

- If the page is dirty, and mapped into pagetables then write the
  thing anyway (haven't tested this yet).  This is to get around the
  problem of big dirty mmaps - everything stalls on request queues.
  Oh well.

  It'll also have the effect of throttling everyone under heavy
  swapout.  Which is also not a big worry, IMO.


An optimisation of course is to get those dirty pagecache pages
away onto another list.  But even with the dopey 400-dbench workload,
50% of the pages were successfuly reclaimed.  And I don't really care
about CPU efficiency in that case - I think it's only important to 
care about CPU efficiency in situations where the VM isn't providing
any benefit (there are free pages, trivially reclaimable clean pagecache,
etc).


The way all this works is to basically partition the machine.  40%
of memory is available to the "heavy dirtier" and 60% is available to
the rest of the world.  So if the working set of the innocent processes
exceeds 60% of physical, they get evicted, swapped out, whatever.  it's
like that memory just isn't there.

Which is a reasonable and simple model, I think.   The 40% is governed by
/proc/sys/vm/dirty_async_ratio, and we could adaptively twiddle it down if
we think the heavy writer is consuming too many resources.

Any suggestions on an algorithm for that?  Other comments, improvements,
etc?

How much complexity would it add to put an inactive_dirty list in there?


--- 2.5.33/mm/vmscan.c~nonblocking-vm	Wed Sep  4 03:05:28 2002
+++ 2.5.33-akpm/mm/vmscan.c	Wed Sep  4 03:09:07 2002
@@ -25,6 +25,7 @@
 #include <linux/buffer_head.h>		/* for try_to_release_page() */
 #include <linux/mm_inline.h>
 #include <linux/pagevec.h>
+#include <linux/backing-dev.h>
 #include <linux/rmap-locking.h>
 
 #include <asm/pgalloc.h>
@@ -94,6 +95,17 @@ static inline int is_page_cache_freeable
 	return page_count(page) - !!PagePrivate(page) == 2;
 }
 
+struct vmstats {
+	int inspected;
+	int reclaimed;
+	int refiled_nonfreeable;
+	int refiled_no_mapping;
+	int refiled_nofs;
+	int refiled_congested;
+	int written_back;
+	int refiled_writeback;
+} vmstats;
+
 static /* inline */ int
 shrink_list(struct list_head *page_list, int nr_pages, unsigned int gfp_mask,
 		int priority, int *max_scan, int *prunes_needed)
@@ -112,6 +124,8 @@ shrink_list(struct list_head *page_list,
 		page = list_entry(page_list->prev, struct page, lru);
 		list_del(&page->lru);
 
+		vmstats.inspected++;
+
 		if (TestSetPageLocked(page))
 			goto keep;
 		BUG_ON(PageActive(page));
@@ -135,10 +149,8 @@ shrink_list(struct list_head *page_list,
 				(PageSwapCache(page) && (gfp_mask & __GFP_IO));
 
 		if (PageWriteback(page)) {
-			if (may_enter_fs)
-				wait_on_page_writeback(page);  /* throttling */
-			else
-				goto keep_locked;
+			vmstats.refiled_writeback++;
+			goto keep_locked;
 		}
 
 		pte_chain_lock(page);
@@ -188,19 +200,38 @@ shrink_list(struct list_head *page_list,
 		 * will write it.  So we're back to page-at-a-time writepage
 		 * in LRU order.
 		 */
-		if (PageDirty(page) && is_page_cache_freeable(page) &&
-					mapping && may_enter_fs) {
+		if (PageDirty(page)) {
 			int (*writeback)(struct page *,
 					struct writeback_control *);
 			const int cluster_size = SWAP_CLUSTER_MAX;
 			struct writeback_control wbc = {
 				.nr_to_write = cluster_size,
+				.nonblocking = 1,
 			};
 
+			if (!is_page_cache_freeable(page)) {
+				vmstats.refiled_nonfreeable++;
+				goto keep_locked;
+			}
+			if (!mapping) {
+				vmstats.refiled_no_mapping++;
+				goto keep_locked;
+			}
+			if (!may_enter_fs) {
+				vmstats.refiled_nofs++;
+				goto keep_locked;
+			}
+			if (!page->pte.direct &&
+				bdi_write_congested(mapping->backing_dev_info)){
+				vmstats.refiled_congested++;
+				goto keep_locked;
+			}
+
 			writeback = mapping->a_ops->vm_writeback;
 			if (writeback == NULL)
 				writeback = generic_vm_writeback;
 			(*writeback)(page, &wbc);
+			vmstats.written_back += cluster_size - wbc.nr_to_write;
 			*max_scan -= (cluster_size - wbc.nr_to_write);
 			goto keep;
 		}
@@ -262,6 +293,7 @@ free_ref:
 free_it:
 		unlock_page(page);
 		nr_pages--;
+		vmstats.reclaimed++;
 		if (!pagevec_add(&freed_pvec, page))
 			__pagevec_release_nonlru(&freed_pvec);
 		continue;

.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
