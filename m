Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C3B788D003D
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:57 -0500 (EST)
Message-Id: <20110303074949.040208949@intel.com>
Date: Thu, 03 Mar 2011 14:45:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 03/27] writeback: skip balance_dirty_pages() for in-memory fs
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=writeback-trace-global-dirty-states-fix.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

This avoids unnecessary checks and dirty throttling on tmpfs/ramfs.

It can also prevent

[  388.126563] BUG: unable to handle kernel NULL pointer dereference at 0000000000000050

in the balance_dirty_pages tracepoint, which will call

	dev_name(mapping->backing_dev_info->dev)

but shmem_backing_dev_info.dev is NULL.

Summary notes about the tmpfs/ramfs behavior changes:

As for 2.6.36 and older kernels, the tmpfs writes will sleep inside
balance_dirty_pages() as long as we are over the (dirty+background)/2
global throttle threshold.  This is because both the dirty pages and
threshold will be 0 for tmpfs/ramfs. Hence this test will always
evaluate to TRUE:

                dirty_exceeded =
                        (bdi_nr_reclaimable + bdi_nr_writeback >= bdi_thresh)
                        || (nr_reclaimable + nr_writeback >= dirty_thresh);

For 2.6.37, someone complained that the current logic does not allow the
users to set vm.dirty_ratio=0.  So commit 4cbec4c8b9 changed the test to

                dirty_exceeded =
                        (bdi_nr_reclaimable + bdi_nr_writeback > bdi_thresh)
                        || (nr_reclaimable + nr_writeback > dirty_thresh);

So 2.6.37 will behave differently for tmpfs/ramfs: it will never get
throttled unless the global dirty threshold is exceeded (which is very
unlikely to happen; once happen, will block many tasks).

I'd say that the 2.6.36 behavior is very bad for tmpfs/ramfs. It means
for a busy writing server, tmpfs write()s may get livelocked! The
"inadvertent" throttling can hardly bring help to any workload because
of its "either no throttling, or get throttled to death" property.

So based on 2.6.37, this patch won't bring more noticeable changes.

CC: Hugh Dickins <hughd@google.com>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/page-writeback.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

--- linux-next.orig/mm/page-writeback.c	2011-03-03 14:43:37.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-03 14:43:51.000000000 +0800
@@ -244,13 +244,8 @@ void task_dirty_inc(struct task_struct *
 static void bdi_writeout_fraction(struct backing_dev_info *bdi,
 		long *numerator, long *denominator)
 {
-	if (bdi_cap_writeback_dirty(bdi)) {
-		prop_fraction_percpu(&vm_completions, &bdi->completions,
+	prop_fraction_percpu(&vm_completions, &bdi->completions,
 				numerator, denominator);
-	} else {
-		*numerator = 0;
-		*denominator = 1;
-	}
 }
 
 static inline void task_dirties_fraction(struct task_struct *tsk,
@@ -495,6 +490,9 @@ static void balance_dirty_pages(struct a
 	bool dirty_exceeded = false;
 	struct backing_dev_info *bdi = mapping->backing_dev_info;
 
+	if (!bdi_cap_account_dirty(bdi))
+		return;
+
 	for (;;) {
 		struct writeback_control wbc = {
 			.sync_mode	= WB_SYNC_NONE,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
