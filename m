From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 18/35] writeback: start background writeback earlier
Date: Mon, 13 Dec 2010 22:47:04 +0800
Message-ID: <20101213150328.526742344@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA2b-0002MM-3L
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:10:17 +0100
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DB9756B00AE
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:08:52 -0500 (EST)
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

--- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:16.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-13 21:46:17.000000000 +0800
@@ -748,6 +748,9 @@ static void balance_dirty_pages(struct a
 				    bdi_stat(bdi, BDI_WRITEBACK);
 		}
 
+		if (unlikely(!writeback_in_progress(bdi)))
+			bdi_start_background_writeback(bdi);
+
 		bdi_update_bandwidth(bdi, start_time, bdi_dirty, bdi_thresh);
 
 		/*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
