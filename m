Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id A62866B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 02:14:41 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 201-v6so8331381itj.4
        for <linux-mm@kvack.org>; Tue, 29 May 2018 23:14:41 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z129-v6si3703462iof.282.2018.05.29.23.14.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 23:14:40 -0700 (PDT)
Date: Tue, 29 May 2018 23:14:36 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 17/34] xfs: use iomap_bmap
Message-ID: <20180530061436.GE30110@magnolia>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-18-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144357.18985-18-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 04:43:40PM +0200, Christoph Hellwig wrote:
> Switch to the iomap based bmap implementation to get rid of one of the
> last users of xfs_get_blocks.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/xfs/xfs_aops.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 80de476cecf8..56e405572909 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -1378,10 +1378,9 @@ xfs_vm_bmap(
>  	struct address_space	*mapping,
>  	sector_t		block)
>  {
> -	struct inode		*inode = (struct inode *)mapping->host;
> -	struct xfs_inode	*ip = XFS_I(inode);
> +	struct xfs_inode	*ip = XFS_I(mapping->host);
>  
> -	trace_xfs_vm_bmap(XFS_I(inode));
> +	trace_xfs_vm_bmap(ip);
>  
>  	/*
>  	 * The swap code (ab-)uses ->bmap to get a block mapping and then
> @@ -1394,9 +1393,7 @@ xfs_vm_bmap(
>  	 */
>  	if (xfs_is_reflink_inode(ip) || XFS_IS_REALTIME_INODE(ip))
>  		return 0;
> -
> -	filemap_write_and_wait(mapping);
> -	return generic_block_bmap(mapping, block, xfs_get_blocks);
> +	return iomap_bmap(mapping, block, &xfs_iomap_ops);
>  }
>  
>  STATIC int
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
