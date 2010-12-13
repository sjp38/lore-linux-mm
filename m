From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 29/47] writeback: smoothed bdi dirty pages
Date: Mon, 13 Dec 2010 14:43:18 +0800
Message-ID: <20101213064840.539654900@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2FQ-0005r0-Ux
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:51:01 +0100
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 680B06B00A2
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:42 -0500 (EST)
Content-Disposition: inline; filename=writeback-smoothed-bdi_dirty.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

This basically does

-	task_bw = linear_function(task_weight, bdi_dirty, bdi->throttle_bandwidth)
+	task_bw = linear_function(task_weight, avg_dirty, bdi->throttle_bandwidth)

So that the fluctuations of bdi_dirty can be filtered by half.

The main problem is, bdi_dirty regularly drops low suddenly for dozens
of megabytes in NFS on the completion of COMMIT requests.  The same
problem, though less severe, exists for btrfs, xfs and maybe some types
of storages. avg_dirty can help filter out such downwards spikes.

Upwards spikes are also possible, and if does happen, should better be
fixed in the FS code.  To avoid exceeding the dirty limits, once
bdi_dirty exceeds avg_dirty, the higher value will instantly be used as
the feedback to the control system. So the control system cannot filter
out upwards spikes for the sake of safety.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    2 +
 mm/page-writeback.c         |   44 ++++++++++++++++++++++++++++++----
 2 files changed, 42 insertions(+), 4 deletions(-)

--- linux-next.orig/include/linux/backing-dev.h	2010-12-09 12:08:16.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2010-12-09 12:08:18.000000000 +0800
@@ -79,6 +79,8 @@ struct backing_dev_info {
 	unsigned long written_stamp;
 	unsigned long write_bandwidth;
 	unsigned long throttle_bandwidth;
+	unsigned long avg_dirty;
+	unsigned long old_dirty;
 
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
--- linux-next.orig/mm/page-writeback.c	2010-12-09 12:08:16.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-09 12:08:18.000000000 +0800
@@ -528,6 +528,36 @@ out:
 	return 1 + int_sqrt(dirty_thresh - dirty_pages);
 }
 
+static void __bdi_update_dirty_smooth(struct backing_dev_info *bdi,
+				      unsigned long dirty,
+				      unsigned long thresh)
+{
+	unsigned long avg = bdi->avg_dirty;
+	unsigned long old = bdi->old_dirty;
+
+	/* skip call from the flusher */
+	if (!thresh)
+		return;
+
+	if (avg > thresh) {
+		avg = dirty;
+		goto update;
+	}
+
+	if (dirty <= avg && dirty >= old)
+		goto out;
+
+	if (dirty >= avg && dirty <= old)
+		goto out;
+
+	avg = (avg * 15 + dirty) / 16;
+
+update:
+	bdi->avg_dirty = avg;
+out:
+	bdi->old_dirty = dirty;
+}
+
 /*
  * The bdi throttle bandwidth is introduced for resisting bdi_dirty from
  * getting too close to task_thresh. It allows scaling up to 1000+ concurrent
@@ -608,8 +638,9 @@ void bdi_update_bandwidth(struct backing
 	if (elapsed <= HZ/10)
 		goto unlock;
 
+	__bdi_update_dirty_smooth(bdi, bdi_dirty, bdi_thresh);
 	__bdi_update_write_bandwidth(bdi, elapsed, written);
-	__bdi_update_throttle_bandwidth(bdi, bdi_dirty, bdi_thresh);
+	__bdi_update_throttle_bandwidth(bdi, bdi->avg_dirty, bdi_thresh);
 
 snapshot:
 	bdi->written_stamp = written;
@@ -631,6 +662,7 @@ static void balance_dirty_pages(struct a
 	long nr_reclaimable;
 	long nr_dirty;
 	long bdi_dirty;  /* = file_dirty + writeback + unstable_nfs */
+	long avg_dirty;  /* smoothed bdi_dirty */
 	long bdi_prev_dirty = 0;
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
@@ -708,7 +740,11 @@ static void balance_dirty_pages(struct a
 
 		bdi_update_bandwidth(bdi, start_time, bdi_dirty, bdi_thresh);
 
-		if (bdi_dirty >= task_thresh || nr_dirty > dirty_thresh) {
+		avg_dirty = bdi->avg_dirty;
+		if (avg_dirty < bdi_dirty || avg_dirty > task_thresh)
+			avg_dirty = bdi_dirty;
+
+		if (avg_dirty >= task_thresh || nr_dirty > dirty_thresh) {
 			pause = MAX_PAUSE;
 			goto pause;
 		}
@@ -721,10 +757,10 @@ static void balance_dirty_pages(struct a
 		 * time when there are lots of dirtiers.
 		 */
 		bw = bdi->throttle_bandwidth;
-		bw = bw * (bdi_thresh - bdi_dirty);
+		bw = bw * (bdi_thresh - avg_dirty);
 		do_div(bw, bdi_thresh / BDI_SOFT_DIRTY_LIMIT + 1);
 
-		bw = bw * (task_thresh - bdi_dirty);
+		bw = bw * (task_thresh - avg_dirty);
 		do_div(bw, bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
 
 		period = HZ * pages_dirtied / ((unsigned long)bw + 1) + 1;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
