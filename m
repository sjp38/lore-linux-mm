Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5A5366B0087
	for <linux-mm@kvack.org>; Sun, 12 Sep 2010 11:55:02 -0400 (EDT)
Message-Id: <20100912155203.524811417@intel.com>
Date: Sun, 12 Sep 2010 23:49:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 06/17] writeback: move task dirty fraction to balance_dirty_pages()
References: <20100912154945.758129106@intel.com>
Content-Disposition: inline; filename=writeback-task-weight.patch
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

This is simple code refactor preparing for a trace event that exposes
the fraction info. It may be merged with the next patch eventually.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-09-09 16:02:27.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-09-09 16:02:30.000000000 +0800
@@ -260,14 +260,12 @@ static inline void task_dirties_fraction
  * effectively curb the growth of dirty pages. Light dirtiers with high enough
  * dirty threshold may never get throttled.
  */
-static unsigned long task_dirty_limit(struct task_struct *tsk,
-				       unsigned long bdi_dirty)
+static unsigned long task_dirty_limit(unsigned long bdi_dirty,
+				      long numerator, long denominator)
 {
-	long numerator, denominator;
 	unsigned long dirty = bdi_dirty;
 	u64 inv = dirty / DIRTY_SOFT_THROTTLE_RATIO;
 
-	task_dirties_fraction(tsk, &numerator, &denominator);
 	inv *= numerator;
 	do_div(inv, denominator);
 
@@ -472,6 +470,7 @@ static void balance_dirty_pages(struct a
 	unsigned long bw;
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
+	long numerator, denominator;
 
 	for (;;) {
 		/*
@@ -496,8 +495,10 @@ static void balance_dirty_pages(struct a
 				(background_thresh + dirty_thresh) / 2)
 			break;
 
+		task_dirties_fraction(current, &numerator, &denominator);
 		bdi_thresh = bdi_dirty_limit(bdi, dirty_thresh);
-		bdi_thresh = task_dirty_limit(current, bdi_thresh);
+		bdi_thresh = task_dirty_limit(bdi_thresh,
+					      numerator, denominator);
 
 		/*
 		 * In order to avoid the stacked BDI deadlock we need


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
