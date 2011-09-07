Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 31F866B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 09:32:39 -0400 (EDT)
Date: Wed, 7 Sep 2011 21:32:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 00/18] IO-less dirty throttling v11
Message-ID: <20110907133211.GA28442@localhost>
References: <20110904015305.367445271@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110904015305.367445271@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Trond Myklebust <Trond.Myklebust@netapp.com>

> Finally, the complete IO-less balance_dirty_pages(). NFS is observed to perform
> better or worse depending on the memory size. Otherwise the added patches can
> address all known regressions.

I find that the NFS performance regressions on large memory system can
be fixed by this patch. It tries to make the progress more smooth by
reasonably reducing the commit size.

Thanks,
Fengguang
---
Subject: nfs: limit the commit size to reduce fluctuations
Date: Thu Dec 16 13:22:43 CST 2010

Limit the commit size to half the dirty control scope, so that the
arrival of one commit will not knock the overall dirty pages off the
scope.

Also limit the commit size to one second worth of data. This will
obviously help make the pipeline run more smoothly.

Also change "<=" to "<": if an inode has only one dirty page in the end,
it should be committed. I wonder why the "<=" didn't cause a bug...

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/nfs/write.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

After patch, there are still drop offs from the control scope,

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/balance_dirty_pages-pages.png

due to bursty arrival of commits:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/nfs-commit.png

--- linux-next.orig/fs/nfs/write.c	2011-09-07 21:29:15.000000000 +0800
+++ linux-next/fs/nfs/write.c	2011-09-07 21:29:32.000000000 +0800
@@ -1543,10 +1543,14 @@ static int nfs_commit_unstable_pages(str
 	int ret = 0;
 
 	if (wbc->sync_mode == WB_SYNC_NONE) {
+		unsigned long bw = MIN_WRITEBACK_PAGES +
+			NFS_SERVER(inode)->backing_dev_info.avg_write_bandwidth;
+
 		/* Don't commit yet if this is a non-blocking flush and there
-		 * are a lot of outstanding writes for this mapping.
+		 * are a lot of outstanding writes for this mapping, until
+		 * collected enough pages to commit.
 		 */
-		if (nfsi->ncommit <= (nfsi->npages >> 1))
+		if (nfsi->ncommit < min(nfsi->npages / DIRTY_SCOPE, bw))
 			goto out_mark_dirty;
 
 		/* don't wait for the COMMIT response */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
