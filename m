Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9774E9000C6
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:45:56 -0400 (EDT)
Message-Id: <20111003134536.476978798@intel.com>
Date: Mon, 03 Oct 2011 21:42:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 03/11] writeback: add bg_threshold parameter to __bdi_update_bandwidth()
References: <20111003134228.090592370@intel.com>
Content-Disposition: inline; filename=writeback-interface-add-bg_thresh
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

No behavior change.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c         |    2 +-
 include/linux/writeback.h |    1 +
 mm/page-writeback.c       |   11 +++++++----
 3 files changed, 9 insertions(+), 5 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-10-03 20:44:55.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-10-03 20:46:17.000000000 +0800
@@ -779,6 +779,7 @@ static void global_update_bandwidth(unsi
 
 void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 			    unsigned long thresh,
+			    unsigned long bg_thresh,
 			    unsigned long dirty,
 			    unsigned long bdi_thresh,
 			    unsigned long bdi_dirty,
@@ -815,6 +816,7 @@ snapshot:
 
 static void bdi_update_bandwidth(struct backing_dev_info *bdi,
 				 unsigned long thresh,
+				 unsigned long bg_thresh,
 				 unsigned long dirty,
 				 unsigned long bdi_thresh,
 				 unsigned long bdi_dirty,
@@ -823,8 +825,8 @@ static void bdi_update_bandwidth(struct 
 	if (time_is_after_eq_jiffies(bdi->bw_time_stamp + BANDWIDTH_INTERVAL))
 		return;
 	spin_lock(&bdi->wb.list_lock);
-	__bdi_update_bandwidth(bdi, thresh, dirty, bdi_thresh, bdi_dirty,
-			       start_time);
+	__bdi_update_bandwidth(bdi, thresh, bg_thresh, dirty,
+			       bdi_thresh, bdi_dirty, start_time);
 	spin_unlock(&bdi->wb.list_lock);
 }
 
@@ -912,8 +914,9 @@ static void balance_dirty_pages(struct a
 		if (!bdi->dirty_exceeded)
 			bdi->dirty_exceeded = 1;
 
-		bdi_update_bandwidth(bdi, dirty_thresh, nr_dirty,
-				     bdi_thresh, bdi_dirty, start_time);
+		bdi_update_bandwidth(bdi, dirty_thresh, background_thresh,
+				     nr_dirty, bdi_thresh, bdi_dirty,
+				     start_time);
 
 		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
 		 * Unstable writes are a feature of certain networked
--- linux-next.orig/fs/fs-writeback.c	2011-10-03 20:44:51.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2011-10-03 20:45:27.000000000 +0800
@@ -675,7 +675,7 @@ static inline bool over_bground_thresh(v
 static void wb_update_bandwidth(struct bdi_writeback *wb,
 				unsigned long start_time)
 {
-	__bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, start_time);
+	__bdi_update_bandwidth(wb->bdi, 0, 0, 0, 0, 0, start_time);
 }
 
 /*
--- linux-next.orig/include/linux/writeback.h	2011-10-03 20:44:51.000000000 +0800
+++ linux-next/include/linux/writeback.h	2011-10-03 20:45:27.000000000 +0800
@@ -143,6 +143,7 @@ unsigned long bdi_dirty_limit(struct bac
 
 void __bdi_update_bandwidth(struct backing_dev_info *bdi,
 			    unsigned long thresh,
+			    unsigned long bg_thresh,
 			    unsigned long dirty,
 			    unsigned long bdi_thresh,
 			    unsigned long bdi_dirty,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
