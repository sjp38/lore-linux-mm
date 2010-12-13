From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 01/47] writeback: enabling gate limit for light dirtied bdi
Date: Mon, 13 Dec 2010 14:42:50 +0800
Message-ID: <20101213064837.030583750@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2EE-0005P4-D9
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:49:46 +0100
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 869946B008C
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:39 -0500 (EST)
Content-Disposition: inline; filename=writeback-min-bdi-dirty-limit.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

I noticed that my NFSROOT test system goes slow responding when there
is heavy dd to a local disk. Traces show that the NFSROOT's bdi limit
is near 0 and many tasks in the system are repeatedly stuck in
balance_dirty_pages().

There are two generic problems:

- light dirtiers at one device (more often than not the rootfs) get
  heavily impacted by heavy dirtiers on another independent device

- the light dirtied device does heavy throttling because bdi limit=0,
  and the heavy throttling may in turn withhold its bdi limit in 0 as
  it cannot dirty fast enough to grow up the bdi's proportional weight.

Fix it by introducing some "low pass" gate, which is a small (<=32MB)
value reserved by others and can be safely "stole" from the current
global dirty margin.  It does not need to be big to help the bdi gain
its initial weight.

Acked-by: Rik van Riel <riel@redhat.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/writeback.h |    3 ++-
 mm/backing-dev.c          |    2 +-
 mm/page-writeback.c       |   29 ++++++++++++++++++++++++++---
 3 files changed, 29 insertions(+), 5 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-08 23:28:19.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-08 23:30:45.000000000 +0800
@@ -443,13 +443,26 @@ void global_dirty_limits(unsigned long *
  *
  * The bdi's share of dirty limit will be adapting to its throughput and
  * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if set.
- */
-unsigned long bdi_dirty_limit(struct backing_dev_info *bdi, unsigned long dirty)
+ *
+ * There is a chicken and egg problem: when bdi A (eg. /pub) is heavy dirtied
+ * and bdi B (eg. /) is light dirtied hence has 0 dirty limit, tasks writing to
+ * B always get heavily throttled and bdi B's dirty limit might never be able
+ * to grow up from 0. So we do tricks to reserve some global margin and honour
+ * it to the bdi's that run low.
+ */
+unsigned long bdi_dirty_limit(struct backing_dev_info *bdi,
+			      unsigned long dirty,
+			      unsigned long dirty_pages)
 {
 	u64 bdi_dirty;
 	long numerator, denominator;
 
 	/*
+	 * Provide a global safety margin of ~1%, or up to 32MB for a 20GB box.
+	 */
+	dirty -= min(dirty / 128, 32768UL >> (PAGE_SHIFT-10));
+
+	/*
 	 * Calculate this BDI's share of the dirty ratio.
 	 */
 	bdi_writeout_fraction(bdi, &numerator, &denominator);
@@ -459,6 +472,15 @@ unsigned long bdi_dirty_limit(struct bac
 	do_div(bdi_dirty, denominator);
 
 	bdi_dirty += (dirty * bdi->min_ratio) / 100;
+
+	/*
+	 * If we can dirty N more pages globally, honour N/2 to the bdi that
+	 * runs low, so as to help it ramp up.
+	 */
+	if (unlikely(bdi_dirty < (dirty - dirty_pages) / 2 &&
+		     dirty > dirty_pages))
+		bdi_dirty = (dirty - dirty_pages) / 2;
+
 	if (bdi_dirty > (dirty * bdi->max_ratio) / 100)
 		bdi_dirty = dirty * bdi->max_ratio / 100;
 
@@ -508,7 +530,8 @@ static void balance_dirty_pages(struct a
 				(background_thresh + dirty_thresh) / 2)
 			break;
 
-		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
+		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh,
+					     nr_reclaimable + nr_writeback);
 		bdi_thresh = task_dirty_limit(current, bdi_thresh);
 
 		/*
--- linux-next.orig/mm/backing-dev.c	2010-12-08 23:28:19.000000000 +0800
+++ linux-next/mm/backing-dev.c	2010-12-08 23:28:43.000000000 +0800
@@ -83,7 +83,7 @@ static int bdi_debug_stats_show(struct s
 	spin_unlock(&inode_lock);
 
 	global_dirty_limits(&background_thresh, &dirty_thresh);
-	bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
+	bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh, dirty_thresh);
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	seq_printf(m,
--- linux-next.orig/include/linux/writeback.h	2010-12-08 23:28:19.000000000 +0800
+++ linux-next/include/linux/writeback.h	2010-12-08 23:28:43.000000000 +0800
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
