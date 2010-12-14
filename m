Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C23616B008A
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 10:53:16 -0500 (EST)
Date: Tue, 14 Dec 2010 23:53:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 31/35] nfs: dont change wbc->nr_to_write in
 write_inode()
Message-ID: <20101214155307.GB8959@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150330.076517282@intel.com>
 <1292274104.8795.23.camel@heimdal.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1292274104.8795.23.camel@heimdal.trondhjem.org>
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2010 at 05:01:44AM +0800, Trond Myklebust wrote:
> On Mon, 2010-12-13 at 22:47 +0800, Wu Fengguang wrote:
> > plain text document attachment
> > (writeback-nfs-commit-remove-nr_to_write.patch)
> > It's introduced in commit 420e3646 ("NFS: Reduce the number of
> > unnecessary COMMIT calls") and seems not necessary.
> > 
> > CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  fs/nfs/write.c |    9 +--------
> >  1 file changed, 1 insertion(+), 8 deletions(-)
> > 
> > --- linux-next.orig/fs/nfs/write.c	2010-12-13 21:46:21.000000000 +0800
> > +++ linux-next/fs/nfs/write.c	2010-12-13 21:46:22.000000000 +0800
> > @@ -1557,15 +1557,8 @@ static int nfs_commit_unstable_pages(str
> >  	}
> >  
> >  	ret = nfs_commit_inode(inode, flags);
> > -	if (ret >= 0) {
> > -		if (wbc->sync_mode == WB_SYNC_NONE) {
> > -			if (ret < wbc->nr_to_write)
> > -				wbc->nr_to_write -= ret;
> > -			else
> > -				wbc->nr_to_write = 0;
> > -		}
> > +	if (ret >= 0)
> >  		return 0;
> > -	}
> >  out_mark_dirty:
> >  	__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> >  	return ret;
> 
> It is there in order to tell the VM that it has succeeded in freeing up
> a certain number of pages. Otherwise, we end up cycling forever in
> writeback_sb_inodes() & friends with the latter not realising that they
> have made progress.

Yeah it seems reasonable, thanks for the explanation.  I'll drop it.

The decrease of nr_to_write seems a partial solution. It will return
control to wb_writeback(), however the function may still busy loop
for long time without doing anything, when all the unstable pages are
in-commit pages.

Strictly speaking, over_bground_thresh() should only check the number
of to-commit pages, because the flusher can only commit the to-commit
pages, and can do nothing but wait for the server to response to
in-commit pages. A clean solution would involve breaking up the
current NR_UNSTABLE_NFS into two counters. But you may not like the
side effect that more dirty pages will then be cached in NFS client,
as the background flusher will quit more earlier :)

As a simple fix, I have a patch to avoid such possible busy loop.

Thanks,
Fengguang
---

Subject: writeback: sleep for 10ms when nothing is written
Date: Fri Dec 03 18:31:59 CST 2010

It seems more safe to take a sleep when nothing was done.

NFS background writeback could possibly busy loop in wb_writeback()
when the NFS client has sent and commit all data. It relies on the
NFS server and network condition to get the commit feedback to knock
down the NR_UNSTABLE_NFS number.

CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/fs-writeback.c |    5 +++++
 1 file changed, 5 insertions(+)

--- linux-next.orig/fs/fs-writeback.c	2010-12-03 18:29:14.000000000 +0800
+++ linux-next/fs/fs-writeback.c	2010-12-03 18:31:56.000000000 +0800
@@ -741,6 +741,11 @@ static long wb_writeback(struct bdi_writ
 		 * become available for writeback. Otherwise
 		 * we'll just busyloop.
 		 */
+		if (list_empty(&wb->b_more_io)) {
+			__set_current_state(TASK_UNINTERRUPTIBLE);
+			io_schedule_timeout(max(HZ/100, 1));
+			continue;
+		}
 		spin_lock(&inode_lock);
 		if (!list_empty(&wb->b_more_io))  {
 			inode = wb_inode(wb->b_more_io.prev);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
