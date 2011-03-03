Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 60AF98D003D
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:56 -0500 (EST)
Message-Id: <20110303074950.704987840@intel.com>
Date: Thu, 03 Mar 2011 14:45:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 16/27] writeback: smoothed global/bdi dirty pages
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=writeback-smooth-dirty.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Maintain a smoothed version of dirty pages for use in the throttle
bandwidth calculations.

default_backing_dev_info.avg_dirty holds the smoothed global dirty
pages.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    2 +
 mm/backing-dev.c            |    3 +
 mm/page-writeback.c         |   62 ++++++++++++++++++++++++++++++++++
 3 files changed, 67 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2011-03-03 14:44:07.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-03 14:44:10.000000000 +0800
@@ -472,6 +472,64 @@ unsigned long bdi_dirty_limit(struct bac
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
+		avg += (old - avg) >> 3;
+		goto update;
+	}
+
+	/*
+	 * dirty pages are departing downwards, follow down
+	 */
+	if (avg > old && old >= dirty) {
+		avg -= (avg - old) >> 3;
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
+	 *       .         .         .         .      (flucuated)
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
@@ -537,6 +595,10 @@ void bdi_update_bandwidth(struct backing
 		goto unlock;
 
 	__bdi_update_write_bandwidth(bdi, elapsed, written);
+	if (thresh) {
+		bdi_update_dirty_smooth(bdi, bdi_dirty);
+		bdi_update_dirty_smooth(&default_backing_dev_info, dirty);
+	}
 
 snapshot:
 	bdi->written_stamp = written;
--- linux-next.orig/include/linux/backing-dev.h	2011-03-03 14:44:07.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2011-03-03 14:44:10.000000000 +0800
@@ -79,6 +79,8 @@ struct backing_dev_info {
 	unsigned long written_stamp;
 	unsigned long write_bandwidth;
 	unsigned long avg_bandwidth;
+	unsigned long avg_dirty;
+	unsigned long old_dirty;
 
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
--- linux-next.orig/mm/backing-dev.c	2011-03-03 14:44:07.000000000 +0800
+++ linux-next/mm/backing-dev.c	2011-03-03 14:44:10.000000000 +0800
@@ -675,6 +675,9 @@ int bdi_init(struct backing_dev_info *bd
 	bdi->write_bandwidth = INIT_BW;
 	bdi->avg_bandwidth = INIT_BW;
 
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
