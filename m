Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 52001900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 05:07:11 -0400 (EDT)
Message-Id: <20110413090415.763161169@intel.com>
Date: Wed, 13 Apr 2011 16:59:41 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 4/4] writeback: reduce per-bdi dirty threshold ramp up time
References: <20110413085937.981293444@intel.com>
Content-Disposition: inline; filename=writeback-speedup-per-bdi-threshold-ramp-up.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Richard Kennedy <richard@rsk.demon.co.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

Reduce the dampening for the control system, yielding faster
convergence. The change is a bit conservative, as smaller values may
lead to noticeable bdi threshold fluctuates in low memory JBOD setup.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Richard Kennedy <richard@rsk.demon.co.uk>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next.orig/mm/page-writeback.c	2011-03-02 14:52:19.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-02 15:00:17.000000000 +0800
@@ -145,7 +145,7 @@ static int calc_period_shift(void)
 	else
 		dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) /
 				100;
-	return 2 + ilog2(dirty_total - 1);
+	return ilog2(dirty_total - 1);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
