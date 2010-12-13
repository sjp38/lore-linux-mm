From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 43/47] nfs: dont change wbc->nr_to_write in write_inode()
Date: Mon, 13 Dec 2010 14:43:32 +0800
Message-ID: <20101213064842.310150037@intel.com>
References: <20101213064249.648862451@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PS2G1-00063A-Fh
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 07:51:37 +0100
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2D4F96B00B6
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 01:49:46 -0500 (EST)
Content-Disposition: inline; filename=writeback-nfs-commit-remove-nr_to_write.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Trond Myklebust <Trond.Myklebust@netapp.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

It's introduced in commit 420e3646 ("NFS: Reduce the number of
unnecessary COMMIT calls") and seems not necessary.

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c |    9 +--------
 1 file changed, 1 insertion(+), 8 deletions(-)

--- linux-next.orig/fs/nfs/write.c	2010-12-09 12:20:20.000000000 +0800
+++ linux-next/fs/nfs/write.c	2010-12-09 12:20:30.000000000 +0800
@@ -1557,15 +1557,8 @@ static int nfs_commit_unstable_pages(str
 	}
 
 	ret = nfs_commit_inode(inode, flags);
-	if (ret >= 0) {
-		if (wbc->sync_mode == WB_SYNC_NONE) {
-			if (ret < wbc->nr_to_write)
-				wbc->nr_to_write -= ret;
-			else
-				wbc->nr_to_write = 0;
-		}
+	if (ret >= 0)
 		return 0;
-	}
 out_mark_dirty:
 	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 	return ret;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
