Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DA6A46B0047
	for <linux-mm@kvack.org>; Mon,  9 Feb 2009 22:36:56 -0500 (EST)
Received: from toip3.srvr.bell.ca ([209.226.175.86])
          by tomts16-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20090210033655.WRSR1809.tomts16-srv.bellnexxia.net@toip3.srvr.bell.ca>
          for <linux-mm@kvack.org>; Mon, 9 Feb 2009 22:36:55 -0500
Date: Mon, 9 Feb 2009 22:36:53 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [PATCH] mm fix page writeback accounting to fix oom condition
	under heavy I/O
Message-ID: <20090210033652.GA28435@Krystal>
References: <20090120122855.GF30821@kernel.dk> <20090120232748.GA10605@Krystal> <20090123220009.34DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <20090123220009.34DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jens Axboe <jens.axboe@oracle.com>, akpm@linux-foundation.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, thomas.pi@arcor.dea, Yuriy Lalym <ylalym@gmail.com>
Cc: ltt-dev@lists.casi.polymtl.ca, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Related to :
http://bugzilla.kernel.org/show_bug.cgi?id=12309

Very annoying I/O latencies (20-30 seconds) are occuring under heavy I/O since
~2.6.18.

Yuriy Lalym noticed that the oom killer was eventually called. So I took a look
at /proc/meminfo and noticed that under my test case (fio job created from a
LTTng block I/O trace, reproducing dd writing to a 20GB file and ssh sessions
being opened), the Inactive(file) value increased, and the total memory consumed
increased until only 80kB (out of 16GB) were left.

So I first used cgroups to limit the memory usable by fio (or dd). This seems to
fix the problem.

Thomas noted that there seems to be a problem with pages being passed to the
block I/O elevator not being counted as dirty. I looked at
clear_page_dirty_for_io and noticed that page_mkclean clears the dirty bit and
then set_page_dirty(page) is called on the page. This calls
mm/page-writeback.c:set_page_dirty(). I assume that the
mapping->a_ops->set_page_dirty is NULL, so it calls
buffer.c:__set_page_dirty_buffers(). This calls set_buffer_dirty(bh).

So we come back in clear_page_dirty_for_io where we decrement the dirty
accounting. This is a problem, because we assume that the block layer will
re-increment it when it gets the page, but because the buffer is marked as
dirty, this won't happen.

So this patch fixes this behavior by only decrementing the page accounting
_after_ the block I/O writepage has been done.

The effect on my workload is that the memory stops being completely filled by
page cache under heavy I/O. The vfs_cache_pressure value seems to work again.

However, this does not fully solve the high latency issue : when there are
enough vfs pages in cache that the pages are being written directly to disk
rather than left in the page cache, the CFQ I/O scheduler does not seem to be
able to correctly prioritize I/O requests. I think this might be because when
this high pressure point is reached, all tasks are blocked in the same way when
they try to add pages to the page cache, independently of their I/O priority.
Any idea on how to fix this is welcome.

Related commits :
commit 7658cc289288b8ae7dd2c2224549a048431222b3
Author: Linus Torvalds <torvalds@macmini.osdl.org>
Date:   Fri Dec 29 10:00:58 2006 -0800
    VM: Fix nasty and subtle race in shared mmap'ed page writeback

commit 8c08540f8755c451d8b96ea14cfe796bc3cd712d
Author: Andrew Morton <akpm@osdl.org>
Date:   Sun Dec 10 02:19:24 2006 -0800
    [PATCH] clean up __set_page_dirty_nobuffers()

Both were merged Dec 2006, which is between kernel v2.6.19 and v2.6.20-rc3.

This patch applies on 2.6.29-rc3.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Jens Axboe <jens.axboe@oracle.com>
CC: akpm@linux-foundation.org
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: Ingo Molnar <mingo@elte.hu>
CC: thomas.pi@arcor.dea
CC: Yuriy Lalym <ylalym@gmail.com>
---
 mm/page-writeback.c |   33 +++++++++++++++++++++++++--------
 1 file changed, 25 insertions(+), 8 deletions(-)

Index: linux-2.6-lttng/mm/page-writeback.c
===================================================================
--- linux-2.6-lttng.orig/mm/page-writeback.c	2009-02-09 20:18:41.000000000 -0500
+++ linux-2.6-lttng/mm/page-writeback.c	2009-02-09 20:42:39.000000000 -0500
@@ -945,6 +945,7 @@ int write_cache_pages(struct address_spa
 	int cycled;
 	int range_whole = 0;
 	long nr_to_write = wbc->nr_to_write;
+	int lazyaccounting;
 
 	if (wbc->nonblocking && bdi_write_congested(bdi)) {
 		wbc->encountered_congestion = 1;
@@ -1028,10 +1029,18 @@ continue_unlock:
 			}
 
 			BUG_ON(PageWriteback(page));
-			if (!clear_page_dirty_for_io(page))
+			lazyaccounting = clear_page_dirty_for_io(page);
+			if (!lazyaccounting)
 				goto continue_unlock;
 
 			ret = (*writepage)(page, wbc, data);
+
+			if (lazyaccounting == 2) {
+				dec_zone_page_state(page, NR_FILE_DIRTY);
+				dec_bdi_stat(mapping->backing_dev_info,
+						BDI_RECLAIMABLE);
+			}
+
 			if (unlikely(ret)) {
 				if (ret == AOP_WRITEPAGE_ACTIVATE) {
 					unlock_page(page);
@@ -1149,6 +1158,7 @@ int write_one_page(struct page *page, in
 {
 	struct address_space *mapping = page->mapping;
 	int ret = 0;
+	int lazyaccounting;
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = 1,
@@ -1159,7 +1169,8 @@ int write_one_page(struct page *page, in
 	if (wait)
 		wait_on_page_writeback(page);
 
-	if (clear_page_dirty_for_io(page)) {
+	lazyaccounting = clear_page_dirty_for_io(page);
+	if (lazyaccounting) {
 		page_cache_get(page);
 		ret = mapping->a_ops->writepage(page, &wbc);
 		if (ret == 0 && wait) {
@@ -1167,6 +1178,11 @@ int write_one_page(struct page *page, in
 			if (PageError(page))
 				ret = -EIO;
 		}
+		if (lazyaccounting == 2) {
+			dec_zone_page_state(page, NR_FILE_DIRTY);
+			dec_bdi_stat(mapping->backing_dev_info,
+					BDI_RECLAIMABLE);
+		}
 		page_cache_release(page);
 	} else {
 		unlock_page(page);
@@ -1312,6 +1328,11 @@ EXPORT_SYMBOL(set_page_dirty_lock);
  *
  * This incoherency between the page's dirty flag and radix-tree tag is
  * unfortunate, but it only exists while the page is locked.
+ *
+ * Return values :
+ * 0 : page is not dirty
+ * 1 : page is dirty, no lazy accounting update still have to be performed
+ * 2 : page is direct *and* lazy accounting update must still be performed
  */
 int clear_page_dirty_for_io(struct page *page)
 {
@@ -1358,12 +1379,8 @@ int clear_page_dirty_for_io(struct page 
 		 * the desired exclusion. See mm/memory.c:do_wp_page()
 		 * for more comments.
 		 */
-		if (TestClearPageDirty(page)) {
-			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_bdi_stat(mapping->backing_dev_info,
-					BDI_RECLAIMABLE);
-			return 1;
-		}
+		if (TestClearPageDirty(page))
+			return 2;
 		return 0;
 	}
 	return TestClearPageDirty(page);

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
