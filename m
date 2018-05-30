Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 54B026B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 02:22:46 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id o24-v6so13143692ioa.20
        for <linux-mm@kvack.org>; Tue, 29 May 2018 23:22:46 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x141-v6si1103884itb.33.2018.05.29.23.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 23:22:45 -0700 (PDT)
Date: Tue, 29 May 2018 23:22:41 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 18/34] xfs: use iomap for blocksize == PAGE_SIZE readpage
 and readpages
Message-ID: <20180530062241.GG30110@magnolia>
References: <20180523144357.18985-1-hch@lst.de>
 <20180523144357.18985-19-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180523144357.18985-19-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 23, 2018 at 04:43:41PM +0200, Christoph Hellwig wrote:
> For file systems with a block size that equals the page size we never do
> partial reads, so we can use the buffer_head-less iomap versions of
> readpage and readpages without conflicting with the buffer_head structures
> create later in write_begin.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/xfs/xfs_aops.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 56e405572909..c631c457b444 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -1402,6 +1402,8 @@ xfs_vm_readpage(
>  	struct page		*page)
>  {
>  	trace_xfs_vm_readpage(page->mapping->host, 1);
> +	if (i_blocksize(page->mapping->host) == PAGE_SIZE)
> +		return iomap_readpage(page, &xfs_iomap_ops);
>  	return mpage_readpage(page, xfs_get_blocks);
>  }
>  
> @@ -1413,6 +1415,8 @@ xfs_vm_readpages(
>  	unsigned		nr_pages)
>  {
>  	trace_xfs_vm_readpages(mapping->host, nr_pages);
> +	if (i_blocksize(mapping->host) == PAGE_SIZE)
> +		return iomap_readpages(mapping, pages, nr_pages, &xfs_iomap_ops);
>  	return mpage_readpages(mapping, pages, nr_pages, xfs_get_blocks);
>  }
>  
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
