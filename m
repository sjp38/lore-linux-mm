Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9EA5A6B008C
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:02 -0400 (EDT)
Message-Id: <20100912155203.970578882@intel.com>
Date: Sun, 12 Sep 2010 23:49:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 09/17] writeback: bdi write bandwidth estimation
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=writeback-bandwidth-estimation-in-flusher.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Li Shaohua <shaohua.li@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

The estimation value will start from 100MB/s and adapt to the real
bandwidth in seconds.  It's pretty accurate for common filesystems.

As the first use case, it replaces the static 100MB/s value used for
'bw' calculation in balance_dirty_pages().

The overheads won't be high because the bdi bandwidth udpate only occurs
in >10ms intervals.

Initially it's only estimated in balance_dirty_pages() because this is
the most reliable place to get reasonable large bandwidth -- the bdi is
normally fully utilized when bdi_thresh is reached.

Then Shaohua recommends to also do it in the flusher thread, to keep the
value updated when there are only periodic/background writeback and no
tasks throttled.

The estimation cannot be done purely in the flusher thread because it's
not sufficient for NFS. NFS writeback won't block at get_request_wait(),
so tend to complete quickly. Another problem is, slow devices may take
dozens of seconds to write the initial 64MB chunk (write_bandwidth
starts with 100MB/s, this translates to 64MB nr_to_write). So it may
take more than 1 minute to adapt to the smallish bandwidth if the
bandwidth is only updated in the flusher thread.

CC: Li Shaohua <shaohua.li@intel.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c           |    4 ++++
 include/linux/backing-dev.h |    1 +
 include/linux/writeback.h   |    3 +++
 mm/backing-dev.c            |    1 +
 mm/page-writeback.c         |   33 ++++++++++++++++++++++++++++++++-
 5 files changed, 41 insertions(+), 1 deletion(-)

--- linux-next.orig/include/linux/backing-dev.h	2010-09-09 16:02:43.000000000 +0800
+++ linux-next/include/linux/backing-dev.h	2010-09-09 16:02:45.000000000 +0800
@@ -76,6 +76,7 @@ struct backing_dev_info {
 
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
+	int write_bandwidth;
 
 	unsigned int min_ratio;
 	unsigned int max_ratio, max_prop_frac;
--- linux-next.orig/mm/backing-dev.c	2010-09-09 16:02:43.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-09-09 16:02:45.000000000 +0800
@@ -658,6 +658,7 @@ int bdi_init(struct backing_dev_info *bd
 			goto err;
 	}
 
+	bdi->write_bandwidth = 100 << 20;
 	bdi->dirty_exceeded = 0;
 	err = prop_local_init_percpu(&bdi->completions);
 
--- linux-next.orig/fs/fs-writeback.c	2010-09-09 14:13:21.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-09-09 16:02:46.000000000 +0800
@@ -603,6 +603,8 @@ static long wb_writeback(struct bdi_writ
 		.range_cyclic		= work->range_cyclic,
 	};
 	unsigned long oldest_jif;
+	unsigned long bw_time;
+	s64 bw_written = 0;
 	long wrote = 0;
 	struct inode *inode;
 
@@ -616,6 +618,7 @@ static long wb_writeback(struct bdi_writ
 		wbc.range_end = LLONG_MAX;
 	}
 
+	bdi_update_write_bandwidth(wb->bdi, &bw_time, &bw_written);
 	wbc.wb_start = jiffies; /* livelock avoidance */
 	for (;;) {
 		/*
@@ -641,6 +644,7 @@ static long wb_writeback(struct bdi_writ
 		else
 			writeback_inodes_wb(wb, &wbc);
 		trace_wbc_writeback_written(&wbc, wb->bdi);
+		bdi_update_write_bandwidth(wb->bdi, &bw_time, &bw_written);
 
 		work->nr_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
 		wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
--- linux-next.orig/mm/page-writeback.c	2010-09-09 16:02:43.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-09-09 16:04:23.000000000 +0800
@@ -449,6 +449,32 @@ unsigned long bdi_dirty_limit(struct bac
 	return bdi_dirty;
 }
 
+void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
+				unsigned long *bw_time,
+				s64 *bw_written)
+{
+	unsigned long pages;
+	unsigned long time;
+	unsigned long bw;
+	unsigned long w;
+
+	if (*bw_written == 0)
+		goto start_over;
+
+	time = jiffies - *bw_time;
+	if (time < HZ/100)
+		return;
+
+	pages = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]) - *bw_written;
+	bw = HZ * PAGE_CACHE_SIZE * pages / time;
+	w = clamp_t(unsigned long, time / (HZ/100), 1, 128);
+
+	bdi->write_bandwidth = (bdi->write_bandwidth * (1024-w) + bw * w) >> 10;
+start_over:
+	*bw_written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
+	*bw_time = jiffies;
+}
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -471,6 +497,8 @@ static void balance_dirty_pages(struct a
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	long numerator, denominator;
+	unsigned long bw_time;
+	s64 bw_written = 0;
 
 	for (;;) {
 		/*
@@ -536,10 +564,12 @@ static void balance_dirty_pages(struct a
 			bdi_thresh - bdi_thresh / DIRTY_SOFT_THROTTLE_RATIO)
 			goto check_exceeded;
 
+		bdi_update_write_bandwidth(bdi, &bw_time, &bw_written);
+
 		gap = bdi_thresh > (bdi_nr_reclaimable + bdi_nr_writeback) ?
 		      bdi_thresh - (bdi_nr_reclaimable + bdi_nr_writeback) : 0;
 
-		bw = (100 << 20) * gap /
+		bw = bdi->write_bandwidth * gap /
 				(bdi_thresh / DIRTY_SOFT_THROTTLE_RATIO + 1);
 
 		pause = HZ * (pages_dirtied << PAGE_CACHE_SHIFT) / (bw + 1);
@@ -562,6 +592,7 @@ static void balance_dirty_pages(struct a
 		if (signal_pending(current))
 			break;
 
+		bdi_update_write_bandwidth(bdi, &bw_time, &bw_written);
 check_exceeded:
 		/*
 		 * The bdi thresh is somehow "soft" limit derived from the
--- linux-next.orig/include/linux/writeback.h	2010-09-09 15:51:38.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-09-09 16:02:46.000000000 +0800
@@ -136,6 +136,9 @@ int dirty_writeback_centisecs_handler(st
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
 unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
 			       unsigned long dirty);
+void bdi_update_write_bandwidth(struct backing_dev_info *bdi,
+				unsigned long *bw_time,
+				s64 *bw_written);
 
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
