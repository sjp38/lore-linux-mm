Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5726B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 13:32:23 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id q17so57521557lbn.3
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:32:23 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id c9si13674058wme.91.2016.05.27.10.32.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 10:32:21 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id z87so1299710wmh.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 10:32:21 -0700 (PDT)
Subject: Re: [PATCH] xfs: fail ->bmap for reflink inodes
References: <1464267724-31423-1-git-send-email-hch@lst.de>
 <1464267724-31423-2-git-send-email-hch@lst.de>
From: Avi Kivity <avi@scylladb.com>
Message-ID: <71afd256-5dfe-2ff9-ac25-b7519dadd5f9@scylladb.com>
Date: Fri, 27 May 2016 20:32:18 +0300
MIME-Version: 1.0
In-Reply-To: <1464267724-31423-2-git-send-email-hch@lst.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, darrick.wong@oracle.com
Cc: linux-mm@kvack.org, xfs@oss.sgi.com

On 05/26/2016 04:02 PM, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   fs/xfs/xfs_aops.c | 11 +++++++++++
>   1 file changed, 11 insertions(+)
>
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index a955552..d053a9e 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -1829,6 +1829,17 @@ xfs_vm_bmap(
>   
>   	trace_xfs_vm_bmap(XFS_I(inode));
>   	xfs_ilock(ip, XFS_IOLOCK_SHARED);
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
>   	filemap_write_and_wait(mapping);
>   	xfs_iunlock(ip, XFS_IOLOCK_SHARED);
>   	return generic_block_bmap(mapping, block, xfs_get_blocks);

Don't you also have to prevent a swapfile from being reflinked after 
it's bmapped?  Or is that already taken care of?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
