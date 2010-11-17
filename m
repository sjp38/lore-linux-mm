From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 09/13] writeback: reduce per-bdi dirty threshold ramp up time
Date: Wed, 17 Nov 2010 12:27:29 +0800
Message-ID: <20101117042850.361893350@intel.com>
References: <20101117042720.033773013@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PIZgU-0001lI-QS
	for glkm-linux-mm-2@m.gmane.org; Wed, 17 Nov 2010 05:31:51 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4F1CA6B010B
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:31:40 -0500 (EST)
Content-Disposition: inline; filename=writeback-speedup-per-bdi-threshold-ramp-up.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Richard Kennedy <richard@rsk.demon.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Reduce the dampening for the control system, yielding faster
convergence.

Currently it converges at a snail's pace for slow devices (in order of
minutes).  For really fast storage, the convergence speed should be fine.

It makes sense to make it reasonably fast for typical desktops.

After patch, it converges in ~10 seconds for 60MB/s writes and 4GB mem.
So expect ~1s for a fast 600MB/s storage under 4GB mem, or ~4s under
16GB mem, which seems reasonable.

$ while true; do grep BdiDirtyThresh /debug/bdi/8:0/stats; sleep 1; done
BdiDirtyThresh:            0 kB
BdiDirtyThresh:       118748 kB
BdiDirtyThresh:       214280 kB
BdiDirtyThresh:       303868 kB
BdiDirtyThresh:       376528 kB
BdiDirtyThresh:       411180 kB
BdiDirtyThresh:       448636 kB
BdiDirtyThresh:       472260 kB
BdiDirtyThresh:       490924 kB
BdiDirtyThresh:       499596 kB
BdiDirtyThresh:       507068 kB
...
DirtyThresh:          530392 kB

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Richard Kennedy <richard@rsk.demon.co.uk>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next.orig/mm/page-writeback.c	2010-11-15 13:08:16.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-11-15 13:08:28.000000000 +0800
@@ -125,7 +125,7 @@ static int calc_period_shift(void)
 	else
 		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
 				100;
-	return 2 + ilog2(dirty_total - 1);
+	return ilog2(dirty_total - 1) - 1;
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
