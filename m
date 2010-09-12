Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 975066B008A
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:02 -0400 (EDT)
Message-Id: <20100912155204.451611340@intel.com>
Date: Sun, 12 Sep 2010 23:49:57 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 12/17] writeback: scale IO chunk size up to device bandwidth
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=writeback-128M-MAX_WRITEBACK_PAGES.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Theodore Tso <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Originally, MAX_WRITEBACK_PAGES was hard-coded to 1024 because of a
concern of not holding I_SYNC for too long.  (At least, that was the
comment previously.)  This doesn't make sense now because the only
time we wait for I_SYNC is if we are calling sync or fsync, and in
that case we need to write out all of the data anyway.  Previously
there may have been other code paths that waited on I_SYNC, but not
any more.					    -- Theodore Ts'o

According to Christoph, the current writeback size is way too small,
and XFS had a hack that bumped out nr_to_write to four times the value
sent by the VM to be able to saturate medium-sized RAID arrays.  This
value was also problematic for ext4 as well, as it caused large files
to be come interleaved on disk by in 8 megabyte chunks (we bumped up
the nr_to_write by a factor of two).

So remove the MAX_WRITEBACK_PAGES constraint totally. The writeback pages
will adapt to as large as the storage device can write within 1 second.

For a typical hard disk, the resulted chunk size will be 32MB or 64MB.

http://bugzilla.kernel.org/show_bug.cgi?id=13930

CC: Theodore Ts'o <tytso@mit.edu>
CC: Dave Chinner <david@fromorbit.com>
CC: Chris Mason <chris.mason@oracle.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-09-07 23:26:17.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-09-07 23:26:37.000000000 +0800
@@ -568,15 +568,6 @@ static void __writeback_inodes_sb(struct
 	spin_unlock(&inode_lock);
 }
 
-/*
- * The maximum number of pages to writeout in a single bdi flush/kupdate
- * operation.  We do this so we don't hold I_SYNC against an inode for
- * enormous amounts of time, which would block a userspace task which has
- * been forced to throttle against that inode.  Also, the code reevaluates
- * the dirty each time it has written this many pages.
- */
-#define MAX_WRITEBACK_PAGES     1024
-
 static inline bool over_bground_thresh(void)
 {
 	unsigned long background_thresh, dirty_thresh;
@@ -588,6 +579,18 @@ static inline bool over_bground_thresh(v
 }
 
 /*
+ * Give each inode a nr_to_write that can complete within 1 second.
+ */
+static unsigned long bdi_writeback_chunk_size(struct backing_dev_info *bdi)
+{
+	unsigned long pages;
+
+	pages = max(bdi->write_bandwidth, 4 << 20) >> PAGE_CACHE_SHIFT;
+
+	return rounddown_pow_of_two(pages);
+}
+
+/*
  * Explicit flushing or periodic writeback of "old" data.
  *
  * Define "old": the first time one of an inode's pages is dirtied, we mark the
@@ -645,8 +648,8 @@ static long wb_writeback(struct bdi_writ
 			break;
 
 		wbc.more_io = 0;
-		wbc.per_file_limit = MAX_WRITEBACK_PAGES;
-		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
+		wbc.per_file_limit = bdi_writeback_chunk_size(wb->bdi);
+		wbc.nr_to_write = wbc.per_file_limit;
 		wbc.pages_skipped = 0;
 
 		trace_wbc_writeback_start(&wbc, wb->bdi);
@@ -657,8 +660,8 @@ static long wb_writeback(struct bdi_writ
 		trace_wbc_writeback_written(&wbc, wb->bdi);
 		bdi_update_write_bandwidth(wb->bdi, &bw_time, &bw_written);
 
-		work->nr_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
-		wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
+		work->nr_pages	-= wbc.per_file_limit - wbc.nr_to_write;
+		wrote		+= wbc.per_file_limit - wbc.nr_to_write;
 
 		/*
 		 * If we consumed everything, see if we have more
@@ -673,7 +676,7 @@ static long wb_writeback(struct bdi_writ
 		/*
 		 * Did we write something? Try for more
 		 */
-		if (wbc.nr_to_write < MAX_WRITEBACK_PAGES)
+		if (wbc.nr_to_write < wbc.per_file_limit)
 			continue;
 		/*
 		 * Nothing written. Wait for some inode to


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
