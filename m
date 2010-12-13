From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 20/35] writeback: scale IO chunk size up to device bandwidth
Date: Mon, 13 Dec 2010 22:47:06 +0800
Message-ID: <20101213150328.761825472@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA2D-00027T-DN
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:09:53 +0100
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D63A56B00A6
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:08:50 -0500 (EST)
Content-Disposition: inline; filename=writeback-128M-MAX_WRITEBACK_PAGES.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Theodore Tso <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

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
 fs/fs-writeback.c         |   60 +++++++++++++++++++-----------------
 include/linux/writeback.h |    5 +++
 2 files changed, 38 insertions(+), 27 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-12-13 21:46:17.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-12-13 21:46:17.000000000 +0800
@@ -600,15 +600,6 @@ static void __writeback_inodes_sb(struct
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
@@ -620,6 +611,38 @@ static inline bool over_bground_thresh(v
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
+	pages = bdi->write_bandwidth;
+
+	if (pages < MIN_WRITEBACK_PAGES)
+		return MIN_WRITEBACK_PAGES;
+
+	return rounddown_pow_of_two(pages);
+}
+
+/*
  * Explicit flushing or periodic writeback of "old" data.
  *
  * Define "old": the first time one of an inode's pages is dirtied, we mark the
@@ -659,24 +682,6 @@ static long wb_writeback(struct bdi_writ
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
 
@@ -705,6 +710,7 @@ static long wb_writeback(struct bdi_writ
 			break;
 
 		wbc.more_io = 0;
+		write_chunk = writeback_chunk_size(wb->bdi, wbc.sync_mode);
 		wbc.nr_to_write = write_chunk;
 		wbc.per_file_limit = write_chunk;
 		wbc.pages_skipped = 0;
--- linux-next.orig/include/linux/writeback.h	2010-12-13 21:46:17.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-12-13 21:46:17.000000000 +0800
@@ -22,6 +22,11 @@ extern spinlock_t inode_lock;
 #define TASK_SOFT_DIRTY_LIMIT	(BDI_SOFT_DIRTY_LIMIT * 2)
 
 /*
+ * 4MB minimal write chunk size
+ */
+#define MIN_WRITEBACK_PAGES     (4096 >> (PAGE_CACHE_SHIFT - 10))
+
+/*
  * fs/fs-writeback.c
  */
 enum writeback_sync_modes {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
