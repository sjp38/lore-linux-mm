Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 33EC16B00AC
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 01:44:36 -0500 (EST)
Date: Sun, 5 Dec 2010 14:44:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH] writeback: enabling-gate for light dirtied bdi
Message-ID: <20101205064430.GA15027@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I noticed that my NFSROOT test system goes slow responding when there
is heavy dd to a local disk. Traces show that the NFSROOT's bdi_limit
is near 0 and many tasks in the system are repeatedly stuck in
balance_dirty_pages().

There are two related problems:

- light dirtiers at one device (more often than not the rootfs) get
  heavily impacted by heavy dirtiers on another independent device

- the light dirtied device does heavy throttling because bdi_limit=0,
  and the heavy throttling may in turn withhold its bdi_limit in 0 as
  it cannot dirty fast enough to grow up the bdi's proportional weight.

Fix it by introducing some "low pass" gate, which is a small (<=8MB)
value reserved by others and can be safely "stole" from the current
global dirty margin.  It does not need to be big to help the bdi gain
its initial weight.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---

Peter, I suspect this will do good for 2.6.37. Please help review, thanks!

 include/linux/writeback.h |    3 ++-
 mm/backing-dev.c          |    2 +-
 mm/page-writeback.c       |   23 +++++++++++++++++++++--
 3 files changed, 24 insertions(+), 4 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-05 14:29:24.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-05 14:31:39.000000000 +0800
@@ -444,7 +444,9 @@ void global_dirty_limits(unsigned long *
  * The bdi's share of dirty limit will be adapting to its throughput and
  * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if set.
  */
-unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
+unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
+			      unsigned long dirty,
+			      unsigned long dirty_pages)
 {
 	u64 bdi_dirty;
 	long numerator, denominator;
@@ -459,6 +461,22 @@ unsigned long bdi_dirty_limit(struct bac
 	do_div(bdi_dirty, denominator);
 
 	bdi_dirty += (dirty * bdi->min_ratio) / 100;
+
+	/*
+	 * There is a chicken and egg problem: when bdi A (eg. /pub) is heavy
+	 * dirtied and bdi B (eg. /) is light dirtied hence has 0 dirty limit,
+	 * tasks writing to B always get heavily throttled and bdi B's dirty
+	 * limit may never be able to grow up from 0.
+	 *
+	 * So if we can dirty N more pages globally, honour N/2 to the bdi that
+	 * runs low. To provide such a global margin, we slightly decrease all
+	 * heavy dirtied bdi's limit.
+	 */
+	if (bdi_dirty < (dirty - dirty_pages) / 2 && dirty > dirty_pages)
+		bdi_dirty = (dirty - dirty_pages) / 2;
+	else
+		bdi_dirty -= min(bdi_dirty / 128, 8192ULL >> (PAGE_SHIFT-10));
+
 	if (bdi_dirty > (dirty * bdi->max_ratio) / 100)
 		bdi_dirty = dirty * bdi->max_ratio / 100;
 
@@ -508,7 +526,8 @@ static void balance_dirty_pages(struct a
 				(background_thresh + dirty_thresh) / 2)
 			break;
 
-		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
+		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh,
+					     nr_reclaimable + nr_writeback);
 		bdi_thresh = task_dirty_limit(current, bdi_thresh);
 
 		/*
--- linux-next.orig/mm/backing-dev.c	2010-12-05 14:29:23.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-12-05 14:30:00.000000000 +0800
@@ -83,7 +83,7 @@ static int bdi_debug_stats_show(struct s
 	spin_unlock(&inode_lock);
 
 	global_dirty_limits(&background_thresh, &dirty_thresh);
-	bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
+	bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh, dirty_thresh);
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	seq_printf(m,
--- linux-next.orig/include/linux/writeback.h	2010-12-05 14:29:24.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-12-05 14:30:00.000000000 +0800
@@ -126,7 +126,8 @@ int dirty_writeback_centisecs_handler(st
 
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty);
 unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
-			       unsigned long dirty);
+			       unsigned long dirty,
+			       unsigned long dirty_pages);
 
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
