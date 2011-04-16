Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 166C9900088
	for <linux-mm@kvack.org>; Sat, 16 Apr 2011 10:03:34 -0400 (EDT)
Message-Id: <20110416134333.176703613@intel.com>
Date: Sat, 16 Apr 2011 21:25:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 06/12] writeback: enforce 1/4 gap between the dirty/background thresholds
References: <20110416132546.765212221@intel.com>
Content-Disposition: inline; filename=writeback-fix-oversize-background-thresh.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

The change is virtually a no-op for the majority users that use the
default 10/20 background/dirty ratios. For others don't know why they
are setting background ratio close enough to dirty ratio. Someone must
set background ratio equal to dirty ratio, but no one seems to notice or
complain that it's then silently halved under the hood..

The other solution is to return -EIO when setting a too large background
threshold or a too small dirty threshold. However that could possibly
break some disordered usage scenario, eg.

	echo 10 > /proc/sys/vm/dirty_ratio
	echo  5 > /proc/sys/vm/dirty_background_ratio

The first echo will fail because the background ratio is still 10.
Such order dependent behavior seems disgusting for end users.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-04-13 17:18:13.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-04-13 17:18:13.000000000 +0800
@@ -422,8 +422,14 @@ void global_dirty_limits(unsigned long *
 	else
 		background = (dirty_background_ratio * available_memory) / 100;
 
-	if (background >= dirty)
-		background = dirty / 2;
+	/*
+	 * Ensure at least 1/4 gap between background and dirty thresholds, so
+	 * that when dirty throttling starts at (background + dirty)/2, it's
+	 * below or at the entrance of the soft dirty throttle scope.
+	 */
+	if (background > dirty - dirty / DIRTY_FULL_SCOPE)
+		background = dirty - dirty / DIRTY_FULL_SCOPE;
+
 	tsk = current;
 	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
 		background += background / 4;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
