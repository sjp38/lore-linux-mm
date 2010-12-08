Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D95826B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 10:31:51 -0500 (EST)
Date: Wed, 8 Dec 2010 23:31:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2] writeback: enabling-gate for light dirtied bdi
Message-ID: <20101208153145.GA19218@localhost>
References: <20101205064430.GA15027@localhost>
 <20101207165111.d79735c1.akpm@linux-foundation.org>
 <20101208043004.GB15322@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20101208043004.GB15322@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> +	 * Provide a global safety margin of ~1%, or up to 32MB for a 20GB box.
> +	 */
> +	dirty -= min(dirty / 128, 32768ULL >> (PAGE_SHIFT-10));

/home/wfg/cc/linux-next/mm/page-writeback.c: In function a??bdi_dirty_limita??:
/home/wfg/cc/linux-next/mm/page-writeback.c:464:133: warning: comparison of distinct pointer types lacks a cast

Sorry, here is the fixed version.

---
Subject: writeback: enabling gate limit for light dirtied bdi
Date: Wed Dec 01 20:22:15 CST 2010

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
