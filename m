From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 22/47] writeback: prevent bandwidth calculation overflow
Date: Mon, 13 Dec 2010 14:43:11 +0800
Message-ID: <20101213064839.658200254@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2Ed-0005Yf-NA
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:50:12 +0100
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D8D006B0093
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:40 -0500 (EST)
Content-Disposition: inline; filename=writeback-prevent-bw-overflow.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On 32bit kernel, bdi->write_bandwidth can express at most 4GB/s.

However the current calculation code can overflow when disk bandwidth
reaches 800MB/s.  Fix it by using "long long" and div64_u64() in the
calculations.

And further change its unit from bytes/second to pages/second.
That allows up to 16TB/s bandwidth in 32bit kernel.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/backing-dev.h |    5 +++--
 mm/backing-dev.c            |    4 ++--
 mm/page-writeback.c         |   14 +++++++-------
 3 files changed, 12 insertions(+), 11 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-08 22:44:28.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-08 22:44:29.000000000 +0800
@@ -531,7 +531,7 @@ void bdi_update_write_bandwidth(struct b
 	unsigned long written;
 	unsigned long elapsed;
 	unsigned long bw;
-	unsigned long w;
+	unsigned long long w;
 
 	if (*bw_written == 0)
 		goto snapshot;
@@ -550,9 +550,10 @@ void bdi_update_write_bandwidth(struct b
 		goto snapshot;
 
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]) - *bw_written;
-	bw = (HZ * PAGE_CACHE_SIZE * written + elapsed/2) / elapsed;
+	bw = (HZ * written + elapsed / 2) / elapsed;
 	w = min(elapsed / unit_time, 128UL);
-	bdi->write_bandwidth = (bdi->write_bandwidth * (1024-w) + bw * w) >> 10;
+	bdi->write_bandwidth = (bdi->write_bandwidth * (1024-w) +
+				bw * w + 1023) >> 10;
 	bdi->write_bandwidth_update_time = jiffies;
 snapshot:
 	*bw_written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
@@ -577,7 +578,7 @@ static void balance_dirty_pages(struct a
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
 	unsigned long task_thresh;
-	unsigned long bw;
+	unsigned long long bw;
 	unsigned long pause = 0;
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
@@ -640,8 +641,7 @@ static void balance_dirty_pages(struct a
 		 * of dirty pages have been cleaned during our pause time.
 		 */
 		if (nr_dirty < dirty_thresh &&
-		    bdi_prev_dirty - bdi_dirty >
-		    bdi->write_bandwidth >> (PAGE_CACHE_SHIFT + 2))
+		    bdi_prev_dirty - bdi_dirty > (long)bdi->write_bandwidth / 4)
 			break;
 		bdi_prev_dirty = bdi_dirty;
 
@@ -664,7 +664,7 @@ static void balance_dirty_pages(struct a
 		bw = bw * (task_thresh - bdi_dirty);
 		do_div(bw, bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
 
-		pause = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1);
+		pause = HZ * pages_dirtied / ((unsigned long)bw + 1);
 		pause = clamp_val(pause, 1, HZ/10);
 
 pause:
--- linux-next.orig/mm/backing-dev.c	2010-12-08 22:44:24.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-12-08 22:44:29.000000000 +0800
@@ -103,7 +103,7 @@ static int bdi_debug_stats_show(struct s
 		   (unsigned long) K(bdi_stat(bdi, BDI_RECLAIMABLE)),
 		   K(bdi_thresh), K(dirty_thresh), K(background_thresh),
 		   (unsigned long) K(bdi_stat(bdi, BDI_WRITTEN)),
-		   (unsigned long) bdi->write_bandwidth >> 10,
+		   (unsigned long) K(bdi->write_bandwidth),
 		   nr_dirty, nr_io, nr_more_io,
 		   !list_empty(&bdi->bdi_list), bdi->state);
 #undef K
@@ -662,7 +662,7 @@ int bdi_init(struct backing_dev_info *bd
 			goto err;
 	}
 
-	bdi->write_bandwidth = 100 << 20;
+	bdi->write_bandwidth = (100 << 20) / PAGE_CACHE_SIZE;
 	bdi->dirty_exceeded = 0;
 	err = prop_local_init_percpu(&bdi->completions);
 
--- linux-next.orig/include/linux/backing-dev.h	2010-12-08 22:44:24.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2010-12-08 22:44:29.000000000 +0800
@@ -74,9 +74,10 @@ struct backing_dev_info {
 
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
 
-	struct prop_local_percpu completions;
+	unsigned long write_bandwidth;
 	unsigned long write_bandwidth_update_time;
-	int write_bandwidth;
+
+	struct prop_local_percpu completions;
 	int dirty_exceeded;
 
 	unsigned int min_ratio;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
