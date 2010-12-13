From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 26/47] writeback: start background writeback earlier
Date: Mon, 13 Dec 2010 14:43:15 +0800
Message-ID: <20101213064840.154570271@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2Eb-0005Xg-5T
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:50:09 +0100
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9320E6B008A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:40 -0500 (EST)
Content-Disposition: inline; filename=writeback-kick-background-early.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

It's possible for some one to suddenly eat lots of memory,
leading to sudden drop of global dirty limit. So a dirtier
task may get hard throttled immediately without some previous
balance_dirty_pages() call to invoke background writeback.

In this case we need to check for background writeback earlier in the
loop to avoid stucking the application for very long time. This was not
a problem before the IO-less balance_dirty_pages() because it will try
to write something and then break out of the loop regardless of the
global limit.

Another scheme this check will help is, the dirty limit is too close to
the background threshold, so that someone manages to jump directly into
the pause threshold (background+dirty)/2.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    3 +++
 1 file changed, 3 insertions(+)

--- linux-next.orig/mm/page-writeback.c	2010-12-08 23:54:36.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-08 23:56:55.000000000 +0800
@@ -662,6 +662,9 @@ static void balance_dirty_pages(struct a
 			break;
 		bdi_prev_dirty = bdi_dirty;
 
+		if (unlikely(!writeback_in_progress(bdi)))
+			bdi_start_background_writeback(bdi);
+
 		bdi_update_bandwidth(bdi, start_time, bdi_dirty, bdi_thresh);
 
 		if (bdi_dirty >= task_thresh) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
