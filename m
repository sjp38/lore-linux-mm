From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 25/47] writeback: make it easier to break from a dirty exceeded bdi
Date: Mon, 13 Dec 2010 14:43:14 +0800
Message-ID: <20101213064840.028400662@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2Eq-0005cn-L1
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:50:25 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0BA1E6B009E
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:40 -0500 (EST)
Content-Disposition: inline; filename=writeback-bdi-throttle-break-fix.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

The break is designed mainly to help the single task case.

For the 1-dd case, it looks better to lower the break threshold to
125ms data. After all, it's not easy for the dirty pages to drop by
250ms worth of data when you only slept 200ms (note: the max pause time
has been doubled for reducing overheads when there are lots of
concurrent dirtiers).

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-09 12:19:22.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-09 12:26:56.000000000 +0800
@@ -652,13 +652,13 @@ static void balance_dirty_pages(struct a
 		 *	bdi_dirty = nr_dirty
 		 *		  = (background_thresh + dirty_thresh) / 2
 		 *		  >> bdi_thresh
-		 * Then the task could be blocked for a dozen second to flush
-		 * all the exceeded (bdi_dirty - bdi_thresh) pages. So offer a
-		 * complementary way to break out of the loop when 250ms worth
+		 * Then the task could be blocked for many seconds to flush all
+		 * the exceeded (bdi_dirty - bdi_thresh) pages. So offer a
+		 * complementary way to break out of the loop when 125ms worth
 		 * of dirty pages have been cleaned during our pause time.
 		 */
-		if (nr_dirty < dirty_thresh &&
-		    bdi_prev_dirty - bdi_dirty > (long)bdi->write_bandwidth / 4)
+		if (nr_dirty <= dirty_thresh &&
+		    bdi_prev_dirty - bdi_dirty > (long)bdi->write_bandwidth / 8)
 			break;
 		bdi_prev_dirty = bdi_dirty;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
