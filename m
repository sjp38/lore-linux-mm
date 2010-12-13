From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 12/47] writeback: make reasonable gap between the dirty/background thresholds
Date: Mon, 13 Dec 2010 14:43:01 +0800
Message-ID: <20101213064838.403158401@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2EY-0005VT-Ct
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:50:06 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 629526B0095
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:40 -0500 (EST)
Content-Disposition: inline; filename=writeback-fix-oversize-background-thresh.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

The change is virtually a no-op for the majority users that use the
default 10/20 background/dirty ratios. For others don't know why they
are setting background ratio close enough to dirty ratio. Someone must
set background ratio equal to dirty ratio, but no one seems to notice or
complain that it's then silently halved under the hood..

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-08 22:44:25.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-08 22:44:25.000000000 +0800
@@ -403,8 +403,15 @@ void global_dirty_limits(unsigned long *
 	else
 		background = (dirty_background_ratio * available_memory) / 100;
 
-	if (background >= dirty)
-		background = dirty / 2;
+	/*
+	 * Ensure at least 1/4 gap between background and dirty thresholds, so
+	 * that when dirty throttling starts at (background + dirty)/2, it's at
+	 * the entrance of bdi soft throttle threshold, so as to avoid being
+	 * hard throttled.
+	 */
+	if (background > dirty - dirty * 2 / BDI_SOFT_DIRTY_LIMIT)
+		background = dirty - dirty * 2 / BDI_SOFT_DIRTY_LIMIT;
+
 	tsk = current;
 	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
 		background += background / 4;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
