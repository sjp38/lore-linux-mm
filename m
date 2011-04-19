Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1E5F1900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:55:09 -0400 (EDT)
Date: Tue, 19 Apr 2011 11:55:04 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/6] NFS: return -EAGAIN when skipped commit in
 nfs_commit_unstable_pages()
Message-ID: <20110419035504.GB25194@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.902141228@intel.com>
 <1303183747.5417.11.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1303183747.5417.11.camel@lade.trondhjem.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Trond,

On Tue, Apr 19, 2011 at 11:29:07AM +0800, Trond Myklebust wrote:
> On Tue, 2011-04-19 at 11:00 +0800, Wu Fengguang wrote:
> > plain text document attachment (nfs-fix-write_inode-retval.patch)
> > It's probably not sane to return success while redirtying the inode at
> > the same time in ->write_inode().
> > 
> > CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> >  fs/nfs/write.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > --- linux-next.orig/fs/nfs/write.c	2011-04-19 10:18:16.000000000 +0800
> > +++ linux-next/fs/nfs/write.c	2011-04-19 10:18:32.000000000 +0800
> > @@ -1519,7 +1519,7 @@ static int nfs_commit_unstable_pages(str
> >  {
> >  	struct nfs_inode *nfsi = NFS_I(inode);
> >  	int flags = FLUSH_SYNC;
> > -	int ret = 0;
> > +	int ret = -EAGAIN;
> >  
> >  	if (wbc->sync_mode == WB_SYNC_NONE) {
> >  		/* Don't commit yet if this is a non-blocking flush and there
> > 
> > 
> 
> Hi Fengguang,
> 
> I don't understand the purpose of this patch...
> 
> Currently, the value of 'ret' only affects the case where the commit
> exits early due to this being a non-blocking flush where we have not yet
> written back enough pages to make it worth our while to send a commit.
> 
> In essence, this really only matters for the cases where someone calls
> 'write_inode_now' (not used by anybody calling into the NFS client) and
> 'sync_inode', which is only called by nfs_wb_all (with sync_mode =
> WB_SYNC_ALL).
> 
> So can you please elaborate on the possible use cases for this change?

Yeah it has no real impact for current kernel. The "fix" is just to
make it behave more aligned to my expectation.

It did lead to a sync() hung bug with the v1 patch 4/6 in this series,
where I do the below code and expected "write_inode() == 0" to be
"done with the inode".  But only to find that it's not the case for NFS..

Thanks,
Fengguang
---

@@ -389,6 +389,8 @@ writeback_single_inode(struct inode *ino
                int err = write_inode(inode, wbc);
                if (ret == 0)
                        ret = err;
+               if (!err)
+                       wbc->inodes_written++;
        }
       
        spin_lock(&inode_lock);
@@ -664,6 +667,8 @@ static long wb_writeback(struct bdi_writ
                 */
                if (wbc.nr_to_write < MAX_WRITEBACK_PAGES)
                        continue;
+               if (wbc.inodes_written)
+                       continue;
               
                /*
                 * Nothing written and no more inodes for IO, bail

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
