From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 07/13] writeback: explicit low bound for vm.dirty_ratio
Date: Fri, 06 Aug 2010 00:10:58 +0800
Message-ID: <20100805162433.673243074@intel.com>
References: <20100805161051.501816677@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Oh3Jo-0002sQ-8g
	for glkm-linux-mm-2@m.gmane.org; Thu, 05 Aug 2010 18:29:20 +0200
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 41BCD6B02B0
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 12:28:36 -0400 (EDT)
Content-Disposition: inline; filename=min-dirty-ratio.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <axboe@kernel.dk>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Force a user visible low bound of 5% for the vm.dirty_ratio interface.

Currently global_dirty_limits() applies a low bound of 5% for
vm_dirty_ratio.  This is not very user visible -- if the user sets
vm.dirty_ratio=1, the operation seems to succeed but will be rounded up
to 5% when used.

Another problem is inconsistency: calc_period_shift() uses the plain
vm_dirty_ratio value, which may be a problem when vm.dirty_ratio is set
to < 5 by the user.

CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 kernel/sysctl.c     |    3 ++-
 mm/page-writeback.c |   10 ++--------
 2 files changed, 4 insertions(+), 9 deletions(-)

--- linux-next.orig/kernel/sysctl.c	2010-08-05 22:48:34.000000000 +0800
+++ linux-next/kernel/sysctl.c	2010-08-05 22:48:47.000000000 +0800
@@ -126,6 +126,7 @@ static int ten_thousand = 10000;
 
 /* this is needed for the proc_doulongvec_minmax of vm_dirty_bytes */
 static unsigned long dirty_bytes_min = 2 * PAGE_SIZE;
+static int dirty_ratio_min = 5;
 
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
@@ -1031,7 +1032,7 @@ static struct ctl_table vm_table[] = {
 		.maxlen		= sizeof(vm_dirty_ratio),
 		.mode		= 0644,
 		.proc_handler	= dirty_ratio_handler,
-		.extra1		= &zero,
+		.extra1		= &dirty_ratio_min,
 		.extra2		= &one_hundred,
 	},
 	{
--- linux-next.orig/mm/page-writeback.c	2010-08-05 22:48:42.000000000 +0800
+++ linux-next/mm/page-writeback.c	2010-08-05 22:48:47.000000000 +0800
@@ -415,14 +415,8 @@ void global_dirty_limits(unsigned long *
 
 	if (vm_dirty_bytes)
 		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
-	else {
-		int dirty_ratio;
-
-		dirty_ratio = vm_dirty_ratio;
-		if (dirty_ratio < 5)
-			dirty_ratio = 5;
-		dirty = (dirty_ratio * available_memory) / 100;
-	}
+	else
+		dirty = (vm_dirty_ratio * available_memory) / 100;
 
 	if (dirty_background_bytes)
 		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
