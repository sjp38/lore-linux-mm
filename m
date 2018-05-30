Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF0056B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 13:44:44 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id o22-v6so14883923ioh.23
        for <linux-mm@kvack.org>; Wed, 30 May 2018 10:44:44 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t206-v6si6037854iod.120.2018.05.30.10.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 10:44:43 -0700 (PDT)
Date: Wed, 30 May 2018 10:44:39 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 12/18] xfs: remove the imap_valid flag
Message-ID: <20180530174439.GP837@magnolia>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-13-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-13-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 12:00:07PM +0200, Christoph Hellwig wrote:
> Simplify the way we check for a valid imap - we know we have a valid
> mapping after xfs_map_blocks returned successfully, and we know we can
> call xfs_imap_valid on any imap, as it will always fail on a
> zero-initialized map.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/xfs/xfs_aops.c | 11 ++---------
>  1 file changed, 2 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 7dc13b0aae60..910b410e5a90 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -42,7 +42,6 @@
>   */
>  struct xfs_writepage_ctx {
>  	struct xfs_bmbt_irec    imap;
> -	bool			imap_valid;
>  	unsigned int		io_type;
>  	struct xfs_ioend	*ioend;
>  	sector_t		last_block;
> @@ -858,10 +857,6 @@ xfs_writepage_map(
>  			continue;
>  		}
>  
> -		/* Check to see if current map spans this file offset */
> -		if (wpc->imap_valid)
> -			wpc->imap_valid = xfs_imap_valid(inode, &wpc->imap,
> -							 file_offset);
>  		/*
>  		 * If we don't have a valid map, now it's time to get a new one
>  		 * for this offset.  This will convert delayed allocations
> @@ -869,16 +864,14 @@ xfs_writepage_map(
>  		 * a valid map, it means we landed in a hole and we skip the
>  		 * block.
>  		 */
> -		if (!wpc->imap_valid) {
> +		if (!xfs_imap_valid(inode, &wpc->imap, file_offset)) {
>  			error = xfs_map_blocks(inode, file_offset, &wpc->imap,
>  					     &wpc->io_type);
>  			if (error)
>  				goto out;
> -			wpc->imap_valid = xfs_imap_valid(inode, &wpc->imap,
> -							 file_offset);
>  		}
>  
> -		if (!wpc->imap_valid || wpc->io_type == XFS_IO_HOLE) {
> +		if (wpc->io_type == XFS_IO_HOLE) {
>  			/*
>  			 * set_page_dirty dirties all buffers in a page, independent
>  			 * of their state.  The dirty state however is entirely
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
