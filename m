Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 79014900088
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:10:22 -0400 (EDT)
Message-Id: <20110419030532.902141228@intel.com>
Date: Tue, 19 Apr 2011 11:00:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 6/6] NFS: return -EAGAIN when skipped commit in nfs_commit_unstable_pages()
References: <20110419030003.108796967@intel.com>
Content-Disposition: inline; filename=nfs-fix-write_inode-retval.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

It's probably not sane to return success while redirtying the inode at
the same time in ->write_inode().

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next.orig/fs/nfs/write.c	2011-04-19 10:18:16.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-04-19 10:18:32.000000000 +0800
@@ -1519,7 +1519,7 @@ static int nfs_commit_unstable_pages(str
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int flags = FLUSH_SYNC;
-	int ret = 0;
+	int ret = -EAGAIN;
 
 	if (wbc->sync_mode == WB_SYNC_NONE) {
 		/* Don't commit yet if this is a non-blocking flush and there


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
