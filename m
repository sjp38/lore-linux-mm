Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C2936B0007
	for <linux-mm@kvack.org>; Wed, 30 May 2018 12:40:57 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m24-v6so15920833ioh.5
        for <linux-mm@kvack.org>; Wed, 30 May 2018 09:40:57 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 5-v6si15117884itj.69.2018.05.30.09.40.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 09:40:56 -0700 (PDT)
Date: Wed, 30 May 2018 09:40:52 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 04/18] xfs: simplify xfs_aops_discard_page
Message-ID: <20180530164052.GG837@magnolia>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-5-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-5-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 11:59:59AM +0200, Christoph Hellwig wrote:
> Instead of looking at the buffer heads to see if a block is delalloc just
> call xfs_bmap_punch_delalloc_range on the whole page - this will leave
> any non-delalloc block intact and handle the iteration for us.  As a side
> effect one more place stops caring about buffer heads and we can remove the
> xfs_check_page_type function entirely.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/xfs/xfs_aops.c | 85 +++++------------------------------------------
>  1 file changed, 9 insertions(+), 76 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index c631c457b444..f2333e351e07 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -711,49 +711,6 @@ xfs_map_at_offset(
>  	clear_buffer_unwritten(bh);
>  }
>  
> -/*
> - * Test if a given page contains at least one buffer of a given @type.
> - * If @check_all_buffers is true, then we walk all the buffers in the page to
> - * try to find one of the type passed in. If it is not set, then the caller only
> - * needs to check the first buffer on the page for a match.
> - */
> -STATIC bool
> -xfs_check_page_type(
> -	struct page		*page,
> -	unsigned int		type,
> -	bool			check_all_buffers)
> -{
> -	struct buffer_head	*bh;
> -	struct buffer_head	*head;
> -
> -	if (PageWriteback(page))
> -		return false;
> -	if (!page->mapping)
> -		return false;
> -	if (!page_has_buffers(page))
> -		return false;
> -
> -	bh = head = page_buffers(page);
> -	do {
> -		if (buffer_unwritten(bh)) {
> -			if (type == XFS_IO_UNWRITTEN)
> -				return true;
> -		} else if (buffer_delay(bh)) {
> -			if (type == XFS_IO_DELALLOC)
> -				return true;
> -		} else if (buffer_dirty(bh) && buffer_mapped(bh)) {
> -			if (type == XFS_IO_OVERWRITE)
> -				return true;
> -		}
> -
> -		/* If we are only checking the first buffer, we are done now. */
> -		if (!check_all_buffers)
> -			break;
> -	} while ((bh = bh->b_this_page) != head);
> -
> -	return false;
> -}
> -
>  STATIC void
>  xfs_vm_invalidatepage(
>  	struct page		*page,
> @@ -785,9 +742,6 @@ xfs_vm_invalidatepage(
>   * transaction. Indeed - if we get ENOSPC errors, we have to be able to do this
>   * truncation without a transaction as there is no space left for block
>   * reservation (typically why we see a ENOSPC in writeback).
> - *
> - * This is not a performance critical path, so for now just do the punching a
> - * buffer head at a time.
>   */
>  STATIC void
>  xfs_aops_discard_page(
> @@ -795,47 +749,26 @@ xfs_aops_discard_page(
>  {
>  	struct inode		*inode = page->mapping->host;
>  	struct xfs_inode	*ip = XFS_I(inode);
> -	struct buffer_head	*bh, *head;
> +	struct xfs_mount	*mp = ip->i_mount;
>  	loff_t			offset = page_offset(page);
> +	xfs_fileoff_t		start_fsb = XFS_B_TO_FSBT(mp, offset);
> +	int			error;
>  
> -	if (!xfs_check_page_type(page, XFS_IO_DELALLOC, true))
> -		goto out_invalidate;
> -
> -	if (XFS_FORCED_SHUTDOWN(ip->i_mount))
> +	if (XFS_FORCED_SHUTDOWN(mp))
>  		goto out_invalidate;
>  
> -	xfs_alert(ip->i_mount,
> +	xfs_alert(mp,
>  		"page discard on page "PTR_FMT", inode 0x%llx, offset %llu.",
>  			page, ip->i_ino, offset);
>  
>  	xfs_ilock(ip, XFS_ILOCK_EXCL);
> -	bh = head = page_buffers(page);
> -	do {
> -		int		error;
> -		xfs_fileoff_t	start_fsb;
> -
> -		if (!buffer_delay(bh))
> -			goto next_buffer;
> -
> -		start_fsb = XFS_B_TO_FSBT(ip->i_mount, offset);
> -		error = xfs_bmap_punch_delalloc_range(ip, start_fsb, 1);
> -		if (error) {
> -			/* something screwed, just bail */
> -			if (!XFS_FORCED_SHUTDOWN(ip->i_mount)) {
> -				xfs_alert(ip->i_mount,
> -			"page discard unable to remove delalloc mapping.");
> -			}
> -			break;
> -		}
> -next_buffer:
> -		offset += i_blocksize(inode);
> -
> -	} while ((bh = bh->b_this_page) != head);
> -
> +	error = xfs_bmap_punch_delalloc_range(ip, start_fsb,
> +			PAGE_SIZE / i_blocksize(inode));
>  	xfs_iunlock(ip, XFS_ILOCK_EXCL);
> +	if (error && !XFS_FORCED_SHUTDOWN(mp))
> +		xfs_alert(mp, "page discard unable to remove delalloc mapping.");
>  out_invalidate:
>  	xfs_vm_invalidatepage(page, 0, PAGE_SIZE);
> -	return;
>  }
>  
>  static int
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
