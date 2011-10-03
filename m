Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BE3879000D5
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 09:45:55 -0400 (EDT)
Message-Id: <20111003134537.165506230@intel.com>
Date: Mon, 03 Oct 2011 21:42:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 08/11] writeback: limit max dirty pause time
References: <20111003134228.090592370@intel.com>
Content-Disposition: inline; filename=max-pause
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Apply two policies to scale down the max pause time for

1) small number of concurrent dirtiers
2) small memory system (comparing to storage bandwidth)

MAX_PAUSE=200ms may only be suitable for high end servers with lots of
concurrent dirtiers, where the large pause time can reduce much overheads.

Otherwise, smaller pause time is desirable whenever possible, so as to
get good responsiveness and smooth user experiences. It's actually
required for good disk utilization in the case when all the dirty pages
can be synced to disk within MAX_PAUSE=200ms.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   44 ++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 42 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-10-03 21:05:43.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-10-03 21:05:46.000000000 +0800
@@ -939,6 +939,43 @@ static unsigned long dirty_poll_interval
 	return 1;
 }
 
+static unsigned long bdi_max_pause(struct backing_dev_info *bdi,
+				   unsigned long bdi_dirty)
+{
+	unsigned long bw = bdi->avg_write_bandwidth;
+	unsigned long hi = ilog2(bw);
+	unsigned long lo = ilog2(bdi->dirty_ratelimit);
+	unsigned long t;
+
+	/* target for 20ms max pause on 1-dd case */
+	t = HZ / 50;
+
+	/*
+	 * Scale up pause time for concurrent dirtiers in order to reduce CPU
+	 * overheads.
+	 *
+	 * (N * 20ms) on 2^N concurrent tasks.
+	 */
+	if (hi > lo)
+		t += (hi - lo) * (20 * HZ) / 1024;
+
+	/*
+	 * Limit pause time for small memory systems. If sleeping for too long
+	 * time, a small pool of dirty/writeback pages may go empty and disk go
+	 * idle.
+	 *
+	 * 8 serves as the safety ratio.
+	 */
+	if (bdi_dirty)
+		t = min(t, bdi_dirty * HZ / (8 * bw + 1));
+
+	/*
+	 * The pause time will be settled within range (max_pause/4, max_pause).
+	 * Apply a minimal value of 4 to get a non-zero max_pause/4.
+	 */
+	return clamp_val(t, 4, MAX_PAUSE);
+}
+
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
@@ -958,6 +995,7 @@ static void balance_dirty_pages(struct a
 	unsigned long dirty_thresh;
 	unsigned long bdi_thresh;
 	long pause = 0;
+	long max_pause;
 	bool dirty_exceeded = false;
 	unsigned long task_ratelimit;
 	unsigned long dirty_ratelimit;
@@ -1035,18 +1073,20 @@ static void balance_dirty_pages(struct a
 				     nr_dirty, bdi_thresh, bdi_dirty,
 				     start_time);
 
+		max_pause = bdi_max_pause(bdi, bdi_dirty);
+
 		dirty_ratelimit = bdi->dirty_ratelimit;
 		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
 					       background_thresh, nr_dirty,
 					       bdi_thresh, bdi_dirty);
 		if (unlikely(pos_ratio == 0)) {
-			pause = MAX_PAUSE;
+			pause = max_pause;
 			goto pause;
 		}
 		task_ratelimit = (u64)dirty_ratelimit *
 					pos_ratio >> RATELIMIT_CALC_SHIFT;
 		pause = (HZ * pages_dirtied) / (task_ratelimit | 1);
-		pause = min_t(long, pause, MAX_PAUSE);
+		pause = min(pause, max_pause);
 
 pause:
 		__set_current_state(TASK_UNINTERRUPTIBLE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
