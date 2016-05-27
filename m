Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 048B76B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 00:11:38 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id sq19so170717060igc.0
        for <linux-mm@kvack.org>; Thu, 26 May 2016 21:11:37 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id b63si22874904ioj.123.2016.05.26.21.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 May 2016 21:11:37 -0700 (PDT)
Date: Thu, 26 May 2016 21:11:28 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH] xfs: fail ->bmap for reflink inodes
Message-ID: <20160527041127.GA5053@birch.djwong.org>
References: <1464267724-31423-1-git-send-email-hch@lst.de>
 <1464267724-31423-2-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1464267724-31423-2-git-send-email-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-mm@kvack.org, xfs@oss.sgi.com

On Thu, May 26, 2016 at 03:02:04PM +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/xfs/xfs_aops.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index a955552..d053a9e 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -1829,6 +1829,17 @@ xfs_vm_bmap(
>  
>  	trace_xfs_vm_bmap(XFS_I(inode));
>  	xfs_ilock(ip, XFS_IOLOCK_SHARED);
> +
> +	/*
> +	 * The swap code (ab-)uses ->bmap to get a block mapping and then
> +	 * bypasseN? the file system for actual I/O.  We really can't allow
> +	 * that on reflinks inodes, so we have to skip out here.  And yes,
> +	 * 0 is the magic code for a bmap error..
> +	 */
> +	if (xfs_is_reflink_inode(ip)) {
> +		xfs_iunlock(ip, XFS_IOLOCK_SHARED);
> +		return 0;
> +	}

/me adds to the reflink patchpile, thanks.

Just poking at mm/swapfile.c it looks like iomap might work well
as a replacement for repeated bmap() calls, once the iomap vfs
bits get in.

--D

>  	filemap_write_and_wait(mapping);
>  	xfs_iunlock(ip, XFS_IOLOCK_SHARED);
>  	return generic_block_bmap(mapping, block, xfs_get_blocks);
> -- 
> 2.1.4
> 

> _______________________________________________
> xfs mailing list
> xfs@oss.sgi.com
> http://oss.sgi.com/mailman/listinfo/xfs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
