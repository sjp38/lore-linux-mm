From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 1/5] writeback: introduce wbc.for_sync to cover the two sync stages
Date: Thu, 29 Jul 2010 19:51:43 +0800
Message-ID: <20100729121423.184456417@intel.com>
References: <20100729115142.102255590@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1OeS91-0006Mg-U6
	for glkm-linux-mm-2@m.gmane.org; Thu, 29 Jul 2010 14:23:28 +0200
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DC8696B02A6
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 08:23:20 -0400 (EDT)
Content-Disposition: inline; filename=writeback-for-sync.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-Id: linux-mm.kvack.org

The sync() is performed in two stages: the WB_SYNC_NONE sync and
the WB_SYNC_ALL sync. It is necessary to tag both stages with
wbc.for_sync, so as to prevent either of them being livelocked.

The basic livelock scheme will be based on the sync_after timestamp.
Inodes dirtied after that won't be queued for IO. The timestamp could be
recorded as early as the sync() time, this patch lazily sets it in
writeback_inodes_sb()/sync_inodes_sb(). This will stop livelock, but
may do more work than necessary.

Note that writeback_inodes_sb() is called by not only sync(), they
are treated the same because the other callers need the same livelock
prevention.

CC: Jan Kara <jack@suse.cz>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c         |   21 ++++++++++++---------
 include/linux/writeback.h |    1 +
 2 files changed, 13 insertions(+), 9 deletions(-)

--- linux-next.orig/fs/fs-writeback.c	2010-07-28 17:05:17.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-07-28 21:21:31.000000000 +0800
@@ -36,6 +36,8 @@ struct wb_writeback_work {
 	long nr_pages;
 	struct super_block *sb;
 	enum writeback_sync_modes sync_mode;
+	unsigned long sync_after;
+	unsigned int for_sync:1;
 	unsigned int for_kupdate:1;
 	unsigned int range_cyclic:1;
 	unsigned int for_background:1;
@@ -1086,20 +1090,17 @@ static void wait_sb_inodes(struct super_
  */
 void writeback_inodes_sb(struct super_block *sb)
 {
-	unsigned long nr_dirty = global_page_state(NR_FILE_DIRTY);
-	unsigned long nr_unstable = global_page_state(NR_UNSTABLE_NFS);
 	DECLARE_COMPLETION_ONSTACK(done);
 	struct wb_writeback_work work = {
 		.sb		= sb,
 		.sync_mode	= WB_SYNC_NONE,
+		.for_sync	= 1,
+		.sync_after	= jiffies,
 		.done		= &done,
 	};
 
 	WARN_ON(!rwsem_is_locked(&sb->s_umount));
 
-	work.nr_pages = nr_dirty + nr_unstable +
-			(inodes_stat.nr_inodes - inodes_stat.nr_unused);
-
 	bdi_queue_work(sb->s_bdi, &work);
 	wait_for_completion(&done);
 }
@@ -1137,6 +1138,8 @@ void sync_inodes_sb(struct super_block *
 	struct wb_writeback_work work = {
 		.sb		= sb,
 		.sync_mode	= WB_SYNC_ALL,
+		.for_sync	= 1,
+		.sync_after	= jiffies,
 		.nr_pages	= LONG_MAX,
 		.range_cyclic	= 0,
 		.done		= &done,
--- linux-next.orig/include/linux/writeback.h	2010-07-28 17:05:17.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-07-28 21:24:54.000000000 +0800
@@ -48,6 +48,7 @@ struct writeback_control {
 	unsigned encountered_congestion:1; /* An output: a queue is full */
 	unsigned for_kupdate:1;		/* A kupdate writeback */
 	unsigned for_background:1;	/* A background writeback */
+	unsigned for_sync:1;		/* A writeback for sync */
 	unsigned for_reclaim:1;		/* Invoked from the page allocator */
 	unsigned range_cyclic:1;	/* range_start is cyclic */
 };


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
