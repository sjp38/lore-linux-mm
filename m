From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 21/47] writeback: prevent divide error on tiny HZ
Date: Mon, 13 Dec 2010 14:43:10 +0800
Message-ID: <20101213064839.531946766@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2EV-0005VA-OK
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:50:04 +0100
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7550E6B009A
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:40 -0500 (EST)
Content-Disposition: inline; filename=writeback-bandwidth-HZ-fix.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

As suggested by Andrew and Peter:

I do recall hearing of people who set HZ very low, perhaps because their
huge machines were seeing performance problems when the timer tick went
off.  Probably there's no need to do that any more.

But still, we shouldn't hard-wire the (HZ >= 100) assumption if we don't
absolutely need to, and I don't think it is absolutely needed here.

People who do cpu bring-up on very slow FPGAs also lower HZ as far as
possible.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2010-12-08 22:44:28.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-12-08 22:44:28.000000000 +0800
@@ -527,6 +527,7 @@ void bdi_update_write_bandwidth(struct b
 				unsigned long *bw_time,
 				s64 *bw_written)
 {
+	const unsigned long unit_time = max(HZ/100, 1);
 	unsigned long written;
 	unsigned long elapsed;
 	unsigned long bw;
@@ -536,7 +537,7 @@ void bdi_update_write_bandwidth(struct b
 		goto snapshot;
 
 	elapsed = jiffies - *bw_time;
-	if (elapsed < HZ/100)
+	if (elapsed < unit_time)
 		return;
 
 	/*
@@ -550,7 +551,7 @@ void bdi_update_write_bandwidth(struct b
 
 	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]) - *bw_written;
 	bw = (HZ * PAGE_CACHE_SIZE * written + elapsed/2) / elapsed;
-	w = min(elapsed / (HZ/100), 128UL);
+	w = min(elapsed / unit_time, 128UL);
 	bdi->write_bandwidth = (bdi->write_bandwidth * (1024-w) + bw * w) >> 10;
 	bdi->write_bandwidth_update_time = jiffies;
 snapshot:


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
