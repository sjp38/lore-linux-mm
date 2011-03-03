Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EF10C8D0052
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:59 -0500 (EST)
Message-Id: <20110303074952.128185713@intel.com>
Date: Thu, 03 Mar 2011 14:45:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 26/27] writeback: scale IO chunk size up to device bandwidth
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=writeback-128M-MAX_WRITEBACK_PAGES.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Theodore Tso <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

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

XFS is observed to do IO completions in a batch, and the batch size is
equal to the write chunk size. To avoid dirty pages to suddenly drop
out of balance_dirty_pages()'s dirty control scope and create large
fluctuations, the chunk size is also limited to half the control scope.

http://bugzilla.kernel.org/show_bug.cgi?id=13930

CC: Theodore Ts'o <tytso@mit.edu>
CC: Dave Chinner <david@fromorbit.com>
CC: Chris Mason <chris.mason@oracle.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |   61 ++++++++++++++++++++++++--------------------
 1 file changed, 34 insertions(+), 27 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2011-03-02 17:24:06.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-03-02 17:24:10.000000000 +0800
@@ -594,15 +594,6 @@ static void __writeback_inodes_sb(struct
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
@@ -614,6 +605,39 @@ static inline bool over_bground_thresh(v
 }
 
 /*
+ * Give each inode a nr_to_write that can complete within 1 second.
+ */
+static unsigned long writeback_chunk_size(struct backing_dev_info *bdi,
+					  int sync_mode)
+{
+	unsigned long pages;
+
+	/*
+	 * WB_SYNC_ALL mode does livelock avoidance by syncing dirty
+	 * inodes/pages in one big loop. Setting wbc.nr_to_write=LONG_MAX
+	 * here avoids calling into writeback_inodes_wb() more than once.
+	 *
+	 * The intended call sequence for WB_SYNC_ALL writeback is:
+	 *
+	 *      wb_writeback()
+	 *          __writeback_inodes_sb()     <== called only once
+	 *              write_cache_pages()     <== called once for each inode
+	 *                  (quickly) tag currently dirty pages
+	 *                  (maybe slowly) sync all tagged pages
+	 */
+	if (sync_mode == WB_SYNC_ALL)
+		return LONG_MAX;
+
+	pages = min(bdi->avg_bandwidth,
+		    bdi->dirty_threshold / DIRTY_SCOPE);
+
+	if (pages <= MIN_WRITEBACK_PAGES)
+		return MIN_WRITEBACK_PAGES;
+
+	return rounddown_pow_of_two(pages);
+}
+
+/*
  * Explicit flushing or periodic writeback of "old" data.
  *
  * Define "old": the first time one of an inode's pages is dirtied, we mark the
@@ -653,24 +677,6 @@ static long wb_writeback(struct bdi_writ
 		wbc.range_end = LLONG_MAX;
 	}
 
-	/*
-	 * WB_SYNC_ALL mode does livelock avoidance by syncing dirty
-	 * inodes/pages in one big loop. Setting wbc.nr_to_write=LONG_MAX
-	 * here avoids calling into writeback_inodes_wb() more than once.
-	 *
-	 * The intended call sequence for WB_SYNC_ALL writeback is:
-	 *
-	 *      wb_writeback()
-	 *          __writeback_inodes_sb()     <== called only once
-	 *              write_cache_pages()     <== called once for each inode
-	 *                   (quickly) tag currently dirty pages
-	 *                   (maybe slowly) sync all tagged pages
-	 */
-	if (wbc.sync_mode == WB_SYNC_NONE)
-		write_chunk = MAX_WRITEBACK_PAGES;
-	else
-		write_chunk = LONG_MAX;
-
 	wbc.wb_start = jiffies; /* livelock avoidance */
 	bdi_update_write_bandwidth(wb->bdi, wbc.wb_start);
 	for (;;) {
@@ -698,6 +704,7 @@ static long wb_writeback(struct bdi_writ
 			break;
 
 		wbc.more_io = 0;
+		write_chunk = writeback_chunk_size(wb->bdi, wbc.sync_mode);
 		wbc.nr_to_write = write_chunk;
 		wbc.per_file_limit = write_chunk;
 		wbc.pages_skipped = 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
