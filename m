Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 21EA26B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 01:57:32 -0500 (EST)
Date: Thu, 18 Nov 2010 14:57:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] writeback: prevent bandwidth calculation overflow
Message-ID: <20101118065725.GB8458@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 32bit kernel, bdi->write_bandwidth can express at most 4GB/s.

However the current calculation code can overflow when disk bandwidth
reaches 800MB/s.  Fix it by using "long long" and swapping the order of
multiplication/division. And further, change its unit to pages/second
rather than bytes/second. That allows up to 16TB/s bandwidth in 32bit
kernel.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/backing-dev.c    |    4 ++--
 mm/page-writeback.c |   13 ++++++-------
 2 files changed, 8 insertions(+), 9 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-11-18 12:42:58.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-11-18 14:30:10.000000000 +0800
@@ -494,7 +494,7 @@ void bdi_update_write_bandwidth(struct b
 	unsigned long written;
 	unsigned long elapsed;
 	unsigned long bw;
-	unsigned long w;
+	unsigned long long w;
 
 	if (*bw_written == 0)
 		goto snapshot;
@@ -513,7 +513,7 @@ void bdi_update_write_bandwidth(struct b
 		goto snapshot;
 
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]) - *bw_written;
-	bw = (HZ * PAGE_CACHE_SIZE * written + elapsed/2) / elapsed;
+	bw = (HZ * written + elapsed/2) / elapsed;
 	w = min(elapsed / unit_time, 128UL);
 	bdi->write_bandwidth = (bdi->write_bandwidth * (1024-w) + bw * w) >> 10;
 	bdi->write_bandwidth_update_time = jiffies;
@@ -602,8 +602,7 @@ static void balance_dirty_pages(struct a
 		 * of dirty pages have been cleaned during our pause time.
 		 */
 		if (nr_dirty < dirty_thresh &&
-		    bdi_prev_dirty - bdi_dirty >
-		    bdi->write_bandwidth >> (PAGE_CACHE_SHIFT + 2))
+		    bdi_prev_dirty - bdi_dirty > bdi->write_bandwidth / 4)
 			break;
 		bdi_prev_dirty = bdi_dirty;
 
@@ -620,13 +619,13 @@ static void balance_dirty_pages(struct a
 		 * time when there are lots of dirtiers.
 		 */
 		bw = bdi->write_bandwidth;
-		bw = bw * (bdi_thresh - bdi_dirty);
 		bw = bw / (bdi_thresh / BDI_SOFT_DIRTY_LIMIT + 1);
+		bw = bw * (bdi_thresh - bdi_dirty);
 
-		bw = bw * (task_thresh - bdi_dirty);
 		bw = bw / (bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);
+		bw = bw * (task_thresh - bdi_dirty);
 
-		pause = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1);
+		pause = HZ * pages_dirtied / (bw + 1);
 		pause = clamp_val(pause, 1, HZ/10);
 
 pause:
--- linux-next.orig/mm/backing-dev.c	2010-11-18 14:24:45.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-11-18 14:27:00.000000000 +0800
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
