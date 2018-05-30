Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7764E6B0006
	for <linux-mm@kvack.org>; Wed, 30 May 2018 12:58:09 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id c10-v6so15793719iob.11
        for <linux-mm@kvack.org>; Wed, 30 May 2018 09:58:09 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id i4-v6si30574777ioi.161.2018.05.30.09.58.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 09:58:08 -0700 (PDT)
Date: Wed, 30 May 2018 09:58:04 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 05/18] xfs: move locking into
 xfs_bmap_punch_delalloc_range
Message-ID: <20180530165804.GI837@magnolia>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-6-hch@lst.de>
 <20180530133551.GE112411@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530133551.GE112411@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 09:35:52AM -0400, Brian Foster wrote:
> On Wed, May 30, 2018 at 12:00:00PM +0200, Christoph Hellwig wrote:
> > Both callers want the same looking, so do it only once.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  fs/xfs/xfs_aops.c      | 2 --
> >  fs/xfs/xfs_bmap_util.c | 7 ++++---
> >  fs/xfs/xfs_iomap.c     | 3 ---
> >  3 files changed, 4 insertions(+), 8 deletions(-)
> > 
> > diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> > index f2333e351e07..5dd09e83c81c 100644
> > --- a/fs/xfs/xfs_aops.c
> > +++ b/fs/xfs/xfs_aops.c
> > @@ -761,10 +761,8 @@ xfs_aops_discard_page(
> >  		"page discard on page "PTR_FMT", inode 0x%llx, offset %llu.",
> >  			page, ip->i_ino, offset);
> >  
> > -	xfs_ilock(ip, XFS_ILOCK_EXCL);
> >  	error = xfs_bmap_punch_delalloc_range(ip, start_fsb,
> >  			PAGE_SIZE / i_blocksize(inode));
> > -	xfs_iunlock(ip, XFS_ILOCK_EXCL);
> >  	if (error && !XFS_FORCED_SHUTDOWN(mp))
> >  		xfs_alert(mp, "page discard unable to remove delalloc mapping.");
> >  out_invalidate:
> > diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
> > index f2b87873612d..86a7ee425bfc 100644
> > --- a/fs/xfs/xfs_bmap_util.c
> > +++ b/fs/xfs/xfs_bmap_util.c
> > @@ -712,12 +712,11 @@ xfs_bmap_punch_delalloc_range(
> >  	struct xfs_iext_cursor	icur;
> >  	int			error = 0;
> >  
> > -	ASSERT(xfs_isilocked(ip, XFS_ILOCK_EXCL));
> > -
> > +	xfs_ilock(ip, XFS_ILOCK_EXCL);
> >  	if (!(ifp->if_flags & XFS_IFEXTENTS)) {
> >  		error = xfs_iread_extents(NULL, ip, XFS_DATA_FORK);
> >  		if (error)
> > -			return error;
> > +			goto out_unlock;
> >  	}
> >  
> >  	if (!xfs_iext_lookup_extent_before(ip, ifp, &end_fsb, &icur, &got))
> 
> There's a return 0 just below here that needs the exit label treatment.
> Otherwise looks Ok.

Will fix that in my tree for testing.  Brian, will you RVB the fixed up
patch?

--D

> Brian
> 
> > @@ -738,6 +737,8 @@ xfs_bmap_punch_delalloc_range(
> >  		}
> >  	}
> >  
> > +out_unlock:
> > +	xfs_iunlock(ip, XFS_ILOCK_EXCL);
> >  	return error;
> >  }
> >  
> > diff --git a/fs/xfs/xfs_iomap.c b/fs/xfs/xfs_iomap.c
> > index da6d1995e460..f949f0dd7382 100644
> > --- a/fs/xfs/xfs_iomap.c
> > +++ b/fs/xfs/xfs_iomap.c
> > @@ -1203,11 +1203,8 @@ xfs_file_iomap_end_delalloc(
> >  		truncate_pagecache_range(VFS_I(ip), XFS_FSB_TO_B(mp, start_fsb),
> >  					 XFS_FSB_TO_B(mp, end_fsb) - 1);
> >  
> > -		xfs_ilock(ip, XFS_ILOCK_EXCL);
> >  		error = xfs_bmap_punch_delalloc_range(ip, start_fsb,
> >  					       end_fsb - start_fsb);
> > -		xfs_iunlock(ip, XFS_ILOCK_EXCL);
> > -
> >  		if (error && !XFS_FORCED_SHUTDOWN(mp)) {
> >  			xfs_alert(mp, "%s: unable to clean up ino %lld",
> >  				__func__, ip->i_ino);
> > -- 
> > 2.17.0
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
