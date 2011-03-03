Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7FAB98D0043
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:57 -0500 (EST)
Message-Id: <20110303074950.195446002@intel.com>
Date: Thu, 03 Mar 2011 14:45:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 12/27] nfs: lower writeback threshold proportionally to dirty threshold
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=nfs-congestion-thresh.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Trond Myklebust <Trond.Myklebust@netapp.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

nfs_congestion_kb is to control the max allowed writeback and in-commit
pages. It's not reasonable for them to outnumber dirty and to-commit
pages. So each of them should not take more than 1/4 dirty threshold.

Considering that nfs_init_writepagecache() is called on fresh boot,
at the time dirty_thresh is much higher than the real dirty limit after
lots of user space memory consumptions, use 1/8 instead.

We might update nfs_congestion_kb when global dirty limit is changed
at runtime, but whatever, do it simple first.

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c      |   13 +++++++++++++
 mm/page-writeback.c |    1 +
 2 files changed, 14 insertions(+)

--- linux-next.orig/fs/nfs/write.c	2011-03-03 14:04:01.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-03-03 14:04:01.000000000 +0800
@@ -1651,6 +1651,9 @@ out:
 
 int __init nfs_init_writepagecache(void)
 {
+	unsigned long background_thresh;
+	unsigned long dirty_thresh;
+
 	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
 					     sizeof(struct nfs_write_data),
 					     0, SLAB_HWCACHE_ALIGN,
@@ -1688,6 +1691,16 @@ int __init nfs_init_writepagecache(void)
 	if (nfs_congestion_kb > 256*1024)
 		nfs_congestion_kb = 256*1024;
 
+	/*
+	 * Limit to 1/8 dirty threshold, so that writeback+in_commit pages
+	 * won't overnumber dirty+to_commit pages.
+	 */
+	global_dirty_limits(&background_thresh, &dirty_thresh);
+	dirty_thresh <<= PAGE_SHIFT - 10;
+
+	if (nfs_congestion_kb > dirty_thresh / 8)
+		nfs_congestion_kb = dirty_thresh / 8;
+
 	return 0;
 }
 
--- linux-next.orig/mm/page-writeback.c	2011-03-03 14:04:01.000000000 +0800
+++ linux-next/mm/page-writeback.c	2011-03-03 14:04:01.000000000 +0800
@@ -431,6 +431,7 @@ void global_dirty_limits(unsigned long *
 	*pbackground = background;
 	*pdirty = dirty;
 }
+EXPORT_SYMBOL_GPL(global_dirty_limits);
 
 /**
  * bdi_dirty_limit - @bdi's share of dirty throttling threshold


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
