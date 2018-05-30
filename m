Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD3D6B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 12:55:52 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 84-v6so17454181qkz.3
        for <linux-mm@kvack.org>; Wed, 30 May 2018 09:55:52 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id g21-v6si773318qki.316.2018.05.30.09.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 09:55:51 -0700 (PDT)
Date: Wed, 30 May 2018 09:55:46 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 03/18] xfs: simplify xfs_bmap_punch_delalloc_range
Message-ID: <20180530165546.GH837@magnolia>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-4-hch@lst.de>
 <20180530133538.GC112411@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530133538.GC112411@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 09:35:39AM -0400, Brian Foster wrote:
> On Wed, May 30, 2018 at 11:59:58AM +0200, Christoph Hellwig wrote:
> > Instead of using xfs_bmapi_read to find delalloc extents and then punch
> > them out using xfs_bunmapi, opencode the loop to iterate over the extents
> > and call xfs_bmap_del_extent_delay directly.  This both simplifies the
> > code and reduces the number of extent tree lookups required.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  fs/xfs/xfs_bmap_util.c | 84 ++++++++++++++----------------------------
> >  1 file changed, 28 insertions(+), 56 deletions(-)
> > 
> > diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
> > index 06badcbadeb4..f2b87873612d 100644
> > --- a/fs/xfs/xfs_bmap_util.c
> > +++ b/fs/xfs/xfs_bmap_util.c
> > @@ -695,12 +695,10 @@ xfs_getbmap(
> >  }
> >  
> >  /*
> > - * dead simple method of punching delalyed allocation blocks from a range in
> > - * the inode. Walks a block at a time so will be slow, but is only executed in
> > - * rare error cases so the overhead is not critical. This will always punch out
> > - * both the start and end blocks, even if the ranges only partially overlap
> > - * them, so it is up to the caller to ensure that partial blocks are not
> > - * passed in.
> > + * Dead simple method of punching delalyed allocation blocks from a range in
> > + * the inode.  This will always punch out both the start and end blocks, even
> > + * if the ranges only partially overlap them, so it is up to the caller to
> > + * ensure that partial blocks are not passed in.
> >   */
> >  int
> >  xfs_bmap_punch_delalloc_range(
> > @@ -708,63 +706,37 @@ xfs_bmap_punch_delalloc_range(
> >  	xfs_fileoff_t		start_fsb,
> >  	xfs_fileoff_t		length)
> >  {
> ...
> > +	if (!xfs_iext_lookup_extent_before(ip, ifp, &end_fsb, &icur, &got))
> > +		return 0;
> >  
> > -		/*
> > -		 * Note: while we initialise the firstblock/dfops pair, they
> > -		 * should never be used because blocks should never be
> > -		 * allocated or freed for a delalloc extent and hence we need
> > -		 * don't cancel or finish them after the xfs_bunmapi() call.
> > -		 */
> > -		xfs_defer_init(&dfops, &firstblock);
> > -		error = xfs_bunmapi(NULL, ip, start_fsb, 1, 0, 1, &firstblock,
> > -					&dfops, &done);
> > -		if (error)
> > -			break;
> > +	while (got.br_startoff + got.br_blockcount > start_fsb) {
> > +		del = got;
> > +		xfs_trim_extent(&del, start_fsb, length);
> >  
> > -		ASSERT(!xfs_defer_has_unfinished_work(&dfops));
> > -next_block:
> > -		start_fsb++;
> > -		remaining--;
> > -	} while(remaining > 0);
> > +		if (del.br_blockcount && isnullstartblock(del.br_startblock)) {
> 
> I think there's subtle behavior here that warrants a comment (and
> describes the somewhat funky logic). E.g., something like:
> 
> /*
>  * got might point to the extent after del in some cases. The next
>  * iteration will detect this and step back to the previous extent.
>  */
> 
> Alternatively, I find separating the if/else a bit more readable (see
> the appended hunk). But otherwise looks fine:
> 
> Reviewed-by: Brian Foster <bfoster@redhat.com>

/me agrees (and adds the hunk for testing),

Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> 
> > +			error = xfs_bmap_del_extent_delay(ip, XFS_DATA_FORK,
> > +					&icur, &got, &del);
> > +			if (error || !xfs_iext_get_extent(ifp, &icur, &got))
> > +				break;
> > +		} else {
> > +			if (!xfs_iext_prev_extent(ifp, &icur, &got))
> > +				break;
> > +		}
> > +	}
> >  
> >  	return error;
> >  }
> > -- 
> > 2.17.0
> 
> --- 8< ---
> 
> diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
> index f2b87873612d..0070b877ed94 100644
> --- a/fs/xfs/xfs_bmap_util.c
> +++ b/fs/xfs/xfs_bmap_util.c
> @@ -727,15 +727,22 @@ xfs_bmap_punch_delalloc_range(
>  		del = got;
>  		xfs_trim_extent(&del, start_fsb, length);
>  
> -		if (del.br_blockcount && isnullstartblock(del.br_startblock)) {
> -			error = xfs_bmap_del_extent_delay(ip, XFS_DATA_FORK,
> -					&icur, &got, &del);
> -			if (error || !xfs_iext_get_extent(ifp, &icur, &got))
> -				break;
> -		} else {
> +		/*
> +		 * A delete can push the cursor forward. Step back to the
> +		 * previous extent on non-delalloc or extents outside the
> +		 * target range.
> +		 */
> +		if (!del.br_blockcount ||
> +		    !isnullstartblock(del.br_startblock)) {
>  			if (!xfs_iext_prev_extent(ifp, &icur, &got))
>  				break;
> +			continue;
>  		}
> +
> +		error = xfs_bmap_del_extent_delay(ip, XFS_DATA_FORK, &icur,
> +						  &got, &del);
> +		if (error || !xfs_iext_get_extent(ifp, &icur, &got))
> +			break;
>  	}
>  
>  	return error;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
