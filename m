From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 30/35] nfs: heuristics to avoid commit
Date: Mon, 13 Dec 2010 22:47:16 +0800
Message-ID: <20101213150329.953837345@intel.com>
References: <20101213144646.341970461@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PSA1i-0001rV-JA
	for glkm-linux-mm-2@m.gmane.org; Mon, 13 Dec 2010 16:09:22 +0100
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 878526B009C
	for <linux-mm@kvack.org>; Mon, 13 Dec 2010 10:08:50 -0500 (EST)
Content-Disposition: inline; filename=writeback-nfs-should-commit.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

The heuristics introduced by commit 420e3646 ("NFS: Reduce the number of
unnecessary COMMIT calls") do not work well for large inodes being
actively written to.

Refine the criterion to
- it has gone quiet (all data transfered to server)
- has accumulated >= 4MB data to commit (so it will be large IO)
- too few active commits (hence active IO) in the server

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c |   31 ++++++++++++++++++++++++++-----
 1 file changed, 26 insertions(+), 5 deletions(-)

--- linux-next.orig/fs/nfs/write.c	2010-12-13 21:46:21.000000000 +0800
+++ linux-next/fs/nfs/write.c	2010-12-13 21:46:21.000000000 +0800
@@ -1518,17 +1518,38 @@ out_mark_dirty:
 	return res;
 }
 
-static int nfs_commit_unstable_pages(struct inode *inode, struct writeback_control *wbc)
+static bool nfs_should_commit(struct inode *inode,
+			      struct writeback_control *wbc)
 {
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
+	unsigned long npages = nfsi->npages;
+	unsigned long to_commit = nfsi->ncommit;
+	unsigned long in_commit = atomic_long_read(&nfss->in_commit);
+
+	/* no more active writes */
+	if (to_commit == npages)
+		return true;
+
+	/* big enough */
+	if (to_commit >= MIN_WRITEBACK_PAGES)
+		return true;
+
+	/* active commits drop low: kick more IO for the server disk */
+	if (to_commit > in_commit / 2)
+		return true;
+
+	return false;
+}
+
+static int nfs_commit_unstable_pages(struct inode *inode,
+				     struct writeback_control *wbc)
+{
 	int flags = FLUSH_SYNC;
 	int ret = 0;
 
 	if (wbc->sync_mode == WB_SYNC_NONE) {
-		/* Don't commit yet if this is a non-blocking flush and there
-		 * are a lot of outstanding writes for this mapping.
-		 */
-		if (nfsi->ncommit <= (nfsi->npages >> 1))
+		if (!nfs_should_commit(inode, wbc))
 			goto out_mark_dirty;
 
 		/* don't wait for the COMMIT response */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
