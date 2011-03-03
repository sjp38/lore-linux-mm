Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 707F18D0042
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:57 -0500 (EST)
Message-Id: <20110303074949.543938784@intel.com>
Date: Thu, 03 Mar 2011 14:45:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 07/27] btrfs: wait on too many nr_async_bios
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=btrfs-nr_async_bios-wait.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Tests show that btrfs is repeatedly moving _all_ PG_dirty pages into
PG_writeback state. It's desirable to have some limit on the number of
writeback pages.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/btrfs/disk-io.c |    7 +++++++
 1 file changed, 7 insertions(+)

before patch:
	http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/btrfs-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-08-21-30/vmstat-dirty-300.png

after patch:
	http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/btrfs-1dd-1M-8p-2952M-2.6.37-rc5+-2010-12-08-21-14/vmstat-dirty-300.png

--- linux-next.orig/fs/btrfs/disk-io.c	2011-03-03 14:03:39.000000000 +0800
+++ linux-next/fs/btrfs/disk-io.c	2011-03-03 14:03:40.000000000 +0800
@@ -616,6 +616,7 @@ int btrfs_wq_submit_bio(struct btrfs_fs_
 			extent_submit_bio_hook_t *submit_bio_done)
 {
 	struct async_submit_bio *async;
+	int limit;
 
 	async = kmalloc(sizeof(*async), GFP_NOFS);
 	if (!async)
@@ -643,6 +644,12 @@ int btrfs_wq_submit_bio(struct btrfs_fs_
 
 	btrfs_queue_worker(&fs_info->workers, &async->work);
 
+	limit = btrfs_async_submit_limit(fs_info);
+
+	if (atomic_read(&fs_info->nr_async_bios) > limit)
+		wait_event(fs_info->async_submit_wait,
+			   (atomic_read(&fs_info->nr_async_bios) < limit));
+
 	while (atomic_read(&fs_info->async_submit_draining) &&
 	      atomic_read(&fs_info->nr_async_submits)) {
 		wait_event(fs_info->async_submit_wait,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
