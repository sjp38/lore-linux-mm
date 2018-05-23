Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 23FB26B0008
	for <linux-mm@kvack.org>; Wed, 23 May 2018 12:17:35 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h70-v6so14331873oib.21
        for <linux-mm@kvack.org>; Wed, 23 May 2018 09:17:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b131-v6si6291859oia.317.2018.05.23.09.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 09:17:13 -0700 (PDT)
Date: Wed, 23 May 2018 12:17:11 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 19/34] xfs: simplify xfs_bmap_punch_delalloc_range
Message-ID: <20180523161710.GA33498@bfoster.bfoster>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-20-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144357.18985-20-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 04:43:42PM +0200, Christoph Hellwig wrote:
> Instead of using xfs_bmapi_read to find delalloc extents and then punch
> them out using xfs_bunmapi, opencode the loop to iterate over the extents
> and call xfs_bmap_del_extent_delay directly.  This both simplifies the
> code and reduces the number of extent tree lookups required.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/xfs/xfs_bmap_util.c | 78 ++++++++++++++----------------------------
>  1 file changed, 25 insertions(+), 53 deletions(-)
> 
> diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
> index 06badcbadeb4..c009bdf9fdce 100644
> --- a/fs/xfs/xfs_bmap_util.c
> +++ b/fs/xfs/xfs_bmap_util.c
...
> @@ -708,63 +706,37 @@ xfs_bmap_punch_delalloc_range(
>  	xfs_fileoff_t		start_fsb,
>  	xfs_fileoff_t		length)
>  {
> -	xfs_fileoff_t		remaining = length;
> +	struct xfs_ifork	*ifp = &ip->i_df;
> +	struct xfs_bmbt_irec	got, del;
> +	struct xfs_iext_cursor	icur;
>  	int			error = 0;
>  
>  	ASSERT(xfs_isilocked(ip, XFS_ILOCK_EXCL));
>  
> -	do {
> -		int		done;
> -		xfs_bmbt_irec_t	imap;
> -		int		nimaps = 1;
> -		xfs_fsblock_t	firstblock;
> -		struct xfs_defer_ops dfops;
> +	if (!(ifp->if_flags & XFS_IFEXTENTS)) {
> +		error = xfs_iread_extents(NULL, ip, XFS_DATA_FORK);
> +		if (error)
> +			return error;
> +	}
>  
> -		/*
> -		 * Map the range first and check that it is a delalloc extent
> -		 * before trying to unmap the range. Otherwise we will be
> -		 * trying to remove a real extent (which requires a
> -		 * transaction) or a hole, which is probably a bad idea...
> -		 */
> -		error = xfs_bmapi_read(ip, start_fsb, 1, &imap, &nimaps,
> -				       XFS_BMAPI_ENTIRE);
> +	if (!xfs_iext_lookup_extent(ip, ifp, start_fsb, &icur, &got))
> +		return 0;
>  
> -		if (error) {
> -			/* something screwed, just bail */
> -			if (!XFS_FORCED_SHUTDOWN(ip->i_mount)) {
> -				xfs_alert(ip->i_mount,
> -			"Failed delalloc mapping lookup ino %lld fsb %lld.",
> -						ip->i_ino, start_fsb);
> -			}
> +	do {
> +		if (got.br_startoff >= start_fsb + length)
>  			break;
> -		}
> -		if (!nimaps) {
> -			/* nothing there */
> -			goto next_block;
> -		}
> -		if (imap.br_startblock != DELAYSTARTBLOCK) {
> -			/* been converted, ignore */
> -			goto next_block;
> -		}
> -		WARN_ON(imap.br_blockcount == 0);
> +		if (!isnullstartblock(got.br_startblock))
> +			continue;
>  
> -		/*
> -		 * Note: while we initialise the firstblock/dfops pair, they
> -		 * should never be used because blocks should never be
> -		 * allocated or freed for a delalloc extent and hence we need
> -		 * don't cancel or finish them after the xfs_bunmapi() call.
> -		 */
> -		xfs_defer_init(&dfops, &firstblock);
> -		error = xfs_bunmapi(NULL, ip, start_fsb, 1, 0, 1, &firstblock,
> -					&dfops, &done);
> +		del = got;
> +		xfs_trim_extent(&del, start_fsb, length);
> +		error = xfs_bmap_del_extent_delay(ip, XFS_DATA_FORK, &icur,
> +				&got, &del);
>  		if (error)
>  			break;
> -
> -		ASSERT(!xfs_defer_has_unfinished_work(&dfops));
> -next_block:
> -		start_fsb++;
> -		remaining--;
> -	} while(remaining > 0);
> +		if (!xfs_iext_get_extent(ifp, &icur, &got))
> +			break;

Mostly looks Ok, but I'm not following what this get_extent() call is
for..? It also doesn't look like it would always do the right thing with
sub-page blocks. Consider a page with a couple discontig delalloc blocks
that happen to be the first extents in the file. The first
xfs_bmap_del_extent_delay() would do:

	xfs_iext_remove(ip, icur, state);
	xfs_iext_prev(ifp, icur);

... which I think sets cur->pos to -1, causes the get_extent() to fail
and thus fails to remove the subsequent delalloc blocks. Hm?

Brian

> +	} while (xfs_iext_next_extent(ifp, &icur, &got));
>  
>  	return error;
>  }
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
