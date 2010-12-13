From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 33/35] nfs: adapt congestion threshold to dirty threshold
Date: Mon, 13 Dec 2010 22:47:19 +0800
Message-ID: <20101213150330.318752820@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA35-0002g2-Kw
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:10:48 +0100
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 58D996B0096
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:09:53 -0500 (EST)
Content-Disposition: inline; filename=nfs-congestion-thresh.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Trond Myklebust <Trond.Myklebust@netapp.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

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
 fs/nfs/write.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

--- linux-next.orig/fs/nfs/write.c	2010-12-13 21:46:22.000000000 +0800
+++ linux-next/fs/nfs/write.c	2010-12-13 21:46:22.000000000 +0800
@@ -1698,6 +1698,9 @@ out:
 
 int __init nfs_init_writepagecache(void)
 {
+	unsigned long background_thresh;
+	unsigned long dirty_thresh;
+
 	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
 					     sizeof(struct nfs_write_data),
 					     0, SLAB_HWCACHE_ALIGN,
@@ -1735,6 +1738,16 @@ int __init nfs_init_writepagecache(void)
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
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
