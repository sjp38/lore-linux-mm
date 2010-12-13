From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 02/35] writeback: safety margin for bdi stat error
Date: Mon, 13 Dec 2010 22:46:48 +0800
Message-ID: <20101213150326.604451840@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA2K-0002BN-QR
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:10:01 +0100
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6A05A6B009C
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:08:51 -0500 (EST)
Content-Disposition: inline; filename=writeback-bdi-error.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

In a simple dd test on a 8p system with "mem=256M", I find all light
dirtier tasks on the root fs are get heavily throttled. That happens
because the global limit is exceeded. It's unbelievable at first sight,
because the test fs doing the heavy dd is under its bdi limit.  After
doing some tracing, it's discovered that

        bdi_dirty < bdi_dirty_limit() < global_dirty_limit() < nr_dirty

So the root cause is, the bdi_dirty is well under the global nr_dirty
due to accounting errors. This can be fixed by using bdi_stat_sum(),
however that's costly on large NUMA machines. So do a less costly fix
of lowering the bdi limit, so that the accounting errors won't lead to
the absurd situation "global limit exceeded but bdi limit not exceeded".

This provides guarantee when there is only 1 heavily dirtied bdi, and
works by opportunity for 2+ heavy dirtied bdi's (hopefully they won't
reach big error _and_ exceed their bdi limit at the same time).

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-13 21:46:10.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-13 21:46:11.000000000 +0800
@@ -434,10 +434,16 @@ void global_dirty_limits(unsigned long *
 	*pdirty = dirty;
 }
 
-/*
+/**
  * bdi_dirty_limit - @bdi's share of dirty throttling threshold
+ * @bdi: the backing_dev_info to query
+ * @dirty: global dirty limit in pages
+ * @dirty_pages: current number of dirty pages
  *
- * Allocate high/low dirty limits to fast/slow devices, in order to prevent
+ * Returns @bdi's dirty limit in pages. The term "dirty" in the context of
+ * dirty balancing includes all PG_dirty, PG_writeback and NFS unstable pages.
+ *
+ * It allocates high/low dirty limits to fast/slow devices, in order to prevent
  * - starving fast devices
  * - piling up dirty pages (that will take long time to sync) on slow devices
  *
@@ -458,6 +464,14 @@ unsigned long bdi_dirty_limit(struct bac
 	long numerator, denominator;
 
 	/*
+	 * try to prevent "global limit exceeded but bdi limit not exceeded"
+	 */
+	if (likely(dirty > bdi_stat_error(bdi)))
+		dirty -= bdi_stat_error(bdi);
+	else
+		return 0;
+
+	/*
 	 * Provide a global safety margin of ~1%, or up to 32MB for a 20GB box.
 	 */
 	dirty -= min(dirty / 128, 32768UL >> (PAGE_SHIFT-10));


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
