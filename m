Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1EDF28D003B
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 03:17:56 -0500 (EST)
Message-Id: <20110303074949.935848193@intel.com>
Date: Thu, 03 Mar 2011 14:45:15 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/27] nfs: limit the commit size to reduce fluctuations
References: <20110303064505.718671603@intel.com>
Content-Disposition: inline; filename=nfs-more-smooth-commit.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Trond Myklebust <Trond.Myklebust@netapp.com>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Limit the commit size to 1/8 dirty control scope, so that the arrival of
one commit will not knock the overall dirty pages off the scope.

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

After patch, there are still drop offs from the control scope,

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/balance_dirty_pages-pages.png

due to bursty arrival of commits:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/nfs-commit.png

--- linux-next.orig/fs/nfs/write.c	2011-03-02 20:39:01.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-03-02 20:39:01.000000000 +0800
@@ -1492,9 +1492,10 @@ static int nfs_commit_unstable_pages(str
 
 	if (wbc->sync_mode == WB_SYNC_NONE) {
 		/* Don't commit yet if this is a non-blocking flush and there
-		 * are a lot of outstanding writes for this mapping.
+		 * are a lot of outstanding writes for this mapping, until
+		 * collected enough pages to commit.
 		 */
-		if (nfsi->ncommit <= (nfsi->npages >> 1))
+		if (nfsi->ncommit <= nfsi->npages / 32 /* DIRTY_MARGIN */)
 			goto out_mark_dirty;
 
 		/* don't wait for the COMMIT response */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
