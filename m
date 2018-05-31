Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id E30F56B000D
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:46:54 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id r58-v6so13454193otr.0
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:46:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q63-v6si12083756oia.430.2018.05.31.06.46.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 06:46:54 -0700 (PDT)
Date: Thu, 31 May 2018 09:46:52 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 10/18] xfs: simplify xfs_map_blocks by using
 xfs_iext_lookup_extent directly
Message-ID: <20180531134651.GD2997@bfoster.bfoster>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-11-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-11-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 12:00:05PM +0200, Christoph Hellwig wrote:
> xfs_bmapi_read adds zero value in xfs_map_blocks.  Replace it with a
> direct call to the low-level extent lookup function.
> 
> Note that we now always pass a 0 length to the trace points as we ask
> for an unspecified len.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

Reviewed-by: Brian Foster <bfoster@redhat.com>

>  fs/xfs/xfs_aops.c | 19 +++++--------------
>  1 file changed, 5 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 587493e9c8a1..cef2bc3cf98b 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -387,7 +387,6 @@ xfs_map_blocks(
>  	int			whichfork = XFS_DATA_FORK;
>  	struct xfs_iext_cursor	icur;
>  	int			error = 0;
> -	int			nimaps = 1;
>  
>  	if (XFS_FORCED_SHUTDOWN(mp))
>  		return -EIO;
> @@ -429,24 +428,16 @@ xfs_map_blocks(
>  		goto allocate_blocks;
>  	}
>  
> -	error = xfs_bmapi_read(ip, offset_fsb, end_fsb - offset_fsb,
> -				imap, &nimaps, XFS_BMAPI_ENTIRE);
> +	if (!xfs_iext_lookup_extent(ip, &ip->i_df, offset_fsb, &icur, imap))
> +		imap->br_startoff = end_fsb;	/* fake a hole past EOF */
>  	xfs_iunlock(ip, XFS_ILOCK_SHARED);
> -	if (error)
> -		return error;
>  
> -	if (!nimaps) {
> -		/*
> -		 * Lookup returns no match? Beyond eof? regardless,
> -		 * return it as a hole so we don't write it
> -		 */
> +	if (imap->br_startoff > offset_fsb) {
> +		/* landed in a hole or beyond EOF */
> +		imap->br_blockcount = imap->br_startoff - offset_fsb;
>  		imap->br_startoff = offset_fsb;
> -		imap->br_blockcount = end_fsb - offset_fsb;
>  		imap->br_startblock = HOLESTARTBLOCK;
>  		*type = XFS_IO_HOLE;
> -	} else if (imap->br_startblock == HOLESTARTBLOCK) {
> -		/* landed in a hole */
> -		*type = XFS_IO_HOLE;
>  	} else {
>  		if (isnullstartblock(imap->br_startblock)) {
>  			/* got a delalloc extent */
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
