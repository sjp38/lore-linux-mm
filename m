Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 116D0900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 02:36:38 -0400 (EDT)
From: Andrea Righi <andrea@betterlinux.com>
Subject: [PATCH v2] fadvise: move active pages to inactive list with POSIX_FADV_DONTNEED
Date: Thu, 23 Jun 2011 08:36:21 +0200
Message-Id: <1308810981-5286-1-git-send-email-andrea@betterlinux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Jerry James <jamesjer@betterlinux.com>, Marcus Sorensen <marcus@bluehost.com>, Matt Heaton <matt@bluehost.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

There were some reported problems in the past about trashing page cache
when a backup software (i.e., rsync) touches a huge amount of pages (see
for example [1]).

This problem has been almost fixed by the Minchan Kim's patch [2] and a
proper use of fadvise() in the backup software. For example this patch
set [3] has been proposed for inclusion in rsync.

However, there can be still other similar trashing problems: when the
backup software reads all the source files, some of them may be part of
the actual working set of the system. When a
posix_fadvise(POSIX_FADV_DONTNEED) is performed _all_ pages are evicted
from pagecache, both the working set and the use-once pages touched only
by the backup software.

With the following solution when posix_fadvise(POSIX_FADV_DONTNEED) is
called for an active page instead of removing it from the page cache it
is added to the tail of the inactive list. Otherwise, if it's already in
the inactive list the page is removed from the page cache.

In this way if the backup was the only user of a page, that page will
be immediately removed from the page cache by calling
posix_fadvise(POSIX_FADV_DONTNEED). If the page was also touched by
other processes it'll be moved to the inactive list, having another
chance of being re-added to the working set, or simply reclaimed when
memory is needed.

Testcase:

  - create a 1GB file called "zero"
  - run md5sum zero to read all the pages in page cache (this is to
    simulate the user activity on this file)
  - run "rsync zero zero_copy" (rsync is patched with [3])
  - re-run md5sum zero (user activity on the working set) and measure
    the time to complete this command

The test has been performed using 3.0.0-rc4 vanilla and with this patch
applied (3.0.0-rc4-fadvise).

Results:
                  avg elapsed time      block:block_bio_queue
 3.0.0-rc4                  4.127s                      8,214
 3.0.0-rc4-fadvise          2.146s                          0

In the first case the file is evicted from page cache completely and we
must re-read it from the disk. In the second case the file is still in
page cache (in the inactive list) and we don't need any other additional
I/O operation.

[1] http://marc.info/?l=rsync&m=128885034930933&w=2
[2] https://lkml.org/lkml/2011/2/20/57
[3] http://lists.samba.org/archive/rsync/2010-November/025827.html

ChangeLog v1 -> v2:
 - fix comment in invalidate_mapping_pages()

Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Andrea Righi <andrea@betterlinux.com>
---
 mm/swap.c     |    9 +++++----
 mm/truncate.c |   10 +++++++---
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/mm/swap.c b/mm/swap.c
index 3a442f1..fc8bb76 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -411,10 +411,11 @@ void add_page_to_unevictable_list(struct page *page)
  *
  * 1. active, mapped page -> none
  * 2. active, dirty/writeback page -> inactive, head, PG_reclaim
- * 3. inactive, mapped page -> none
- * 4. inactive, dirty/writeback page -> inactive, head, PG_reclaim
- * 5. inactive, clean -> inactive, tail
- * 6. Others -> none
+ * 3. active, clean -> inactive, tail
+ * 4. inactive, mapped page -> none
+ * 5. inactive, dirty/writeback page -> inactive, head, PG_reclaim
+ * 6. inactive, clean -> inactive, tail
+ * 7. Others -> none
  *
  * In 4, why it moves inactive's head, the VM expects the page would
  * be write it out by flusher threads as this is much more effective
diff --git a/mm/truncate.c b/mm/truncate.c
index 3a29a61..a36af48 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -357,11 +357,15 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			if (lock_failed)
 				continue;
 
-			ret = invalidate_inode_page(page);
+			if (PageActive(page))
+				ret = 0;
+			else
+				ret = invalidate_inode_page(page);
 			unlock_page(page);
 			/*
-			 * Invalidation is a hint that the page is no longer
-			 * of interest and try to speed up its reclaim.
+			 * Invalidation of an inactive page is a hint that the
+			 * page is no longer of interest and try to speed up
+			 * its reclaim.
 			 */
 			if (!ret)
 				deactivate_page(page);
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
