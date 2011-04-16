Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C757F90008B
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 10:03:34 -0400 (EDT)
Message-Id: <20110416134332.918936130@intel.com>
Date: Sat, 16 Apr 2011 21:25:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 04/12] writeback: smoothed global/bdi dirty pages
References: <20110416132546.765212221@intel.com>
Content-Disposition: inline; filename=writeback-smooth-dirty.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, larry <lantianyu1986@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Maintain a smoothed version of dirty pages for use in the throttle
bandwidth calculations.

default_backing_dev_info.avg_dirty holds the smoothed global dirty
pages.

The calculation favors smoothness rather than accuracy. It's non-sense
trying to track a much fluctuated value "accurately". And its users
don't really rely on it being accurate.

CC: larry <lantianyu1986@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    2 +
 mm/backing-dev.c            |    3 +
 mm/page-writeback.c         |   66 ++++++++++++++++++++++++++++++++++
 3 files changed, 71 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2011-04-13 17:18:12.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-13 17:18:12.000000000 +0800
@@ -471,6 +471,64 @@ unsigned long bdi_dirty_limit(struct bac
 	return bdi_dirty;
 }
 
+static void bdi_update_dirty_smooth(struct backing_dev_info *bdi,
+				    unsigned long dirty)
+{
+	unsigned long avg = bdi->avg_dirty;
+	unsigned long old = bdi->old_dirty;
+
+	if (unlikely(!avg)) {
+		avg = dirty;
+		goto update;
+	}
+
+	/*
+	 * dirty pages are departing upwards, follow up
+	 */
+	if (avg < old && old <= dirty) {
+		avg += (old - avg) >> 2;
+		goto update;
+	}
+
+	/*
+	 * dirty pages are departing downwards, follow down
+	 */
+	if (avg > old && old >= dirty) {
+		avg -= (avg - old) >> 2;
+		goto update;
+	}
+
+	/*
+	 * This can filter out one half unnecessary updates when bdi_dirty is
+	 * fluctuating around the balance point, and is most effective on XFS,
+	 * whose pattern is
+	 *                                                             .
+	 *	[.] dirty	[-] avg                       .       .
+	 *                                                   .       .
+	 *              .         .         .         .     .       .
+	 *      ---------------------------------------    .       .
+	 *            .         .         .         .     .       .
+	 *           .         .         .         .     .       .
+	 *          .         .         .         .     .       .
+	 *         .         .         .         .     .       .
+	 *        .         .         .         .
+	 *       .         .         .         .      (fluctuated)
+	 *      .         .         .         .
+	 *     .         .         .         .
+	 *
+	 * @avg will remain flat at the cost of being biased towards high. In
+	 * practice the error tend to be much smaller: thanks to more coarse
+	 * grained fluctuations, @avg becomes the real average number for the
+	 * last two rising lines of @dirty.
+	 */
+	goto out;
+
+update:
+	bdi->avg_dirty = avg;
+out:
+	bdi->old_dirty = dirty;
+}
+
 static void __bdi_update_write_bandwidth(struct backing_dev_info *bdi,
 					 unsigned long elapsed,
 					 unsigned long written)
@@ -535,6 +593,14 @@ void bdi_update_bandwidth(struct backing
 	if (elapsed <= HZ / 5)
 		goto unlock;
 
+	if (thresh &&
+	    now - default_backing_dev_info.bw_time_stamp >= HZ / 5) {
+		bdi_update_dirty_smooth(&default_backing_dev_info, dirty);
+		default_backing_dev_info.bw_time_stamp = now;
+	}
+	if (thresh) {
+		bdi_update_dirty_smooth(bdi, bdi_dirty);
+	}
 	__bdi_update_write_bandwidth(bdi, elapsed, written);
 
 snapshot:
--- linux-next.orig/include/linux/backing-dev.h	2011-04-13 17:18:12.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-04-13 17:18:12.000000000 +0800
@@ -77,6 +77,8 @@ struct backing_dev_info {
 	unsigned long written_stamp;
 	unsigned long write_bandwidth;
 	unsigned long avg_write_bandwidth;
+	unsigned long avg_dirty;
+	unsigned long old_dirty;
 
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
--- linux-next.orig/mm/backing-dev.c	2011-04-13 17:18:12.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-04-13 17:18:12.000000000 +0800
@@ -669,6 +669,9 @@ int bdi_init(struct backing_dev_info *bd
 	bdi->write_bandwidth = INIT_BW;
 	bdi->avg_write_bandwidth = INIT_BW;
 
+	bdi->avg_dirty = 0;
+	bdi->old_dirty = 0;
+
 	err = prop_local_init_percpu(&bdi->completions);
 
 	if (err) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
