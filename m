Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 082B06B0010
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:49:46 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k62-v6so8413313oiy.1
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:49:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n43-v6si1705043otd.218.2018.05.31.06.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 06:49:45 -0700 (PDT)
Date: Thu, 31 May 2018 09:49:43 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 17/18] xfs: do not set the page uptodate in
 xfs_writepage_map
Message-ID: <20180531134943.GK2997@bfoster.bfoster>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-18-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-18-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 12:00:12PM +0200, Christoph Hellwig wrote:
> We already track the page uptodate status based on the buffer uptodate
> status, which is updated whenever reading or zeroing blocks.
> 
> This code has been there since commit a ptool commit in 2002, which
> claims to:
> 
>     "merge" the 2.4 fsx fix for block size < page size to 2.5.  This needed
>     major changes to actually fit.
> 
> and isn't present in other writepage implementations.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---

Reviewed-by: Brian Foster <bfoster@redhat.com>

>  fs/xfs/xfs_aops.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index ac417ef326a9..84f88cecd2f1 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -786,7 +786,6 @@ xfs_writepage_map(
>  	ssize_t			len = i_blocksize(inode);
>  	int			error = 0;
>  	int			count = 0;
> -	bool			uptodate = true;
>  	loff_t			file_offset;	/* file offset of page */
>  	unsigned		poffset;	/* offset into page */
>  
> @@ -813,7 +812,6 @@ xfs_writepage_map(
>  		if (!buffer_uptodate(bh)) {
>  			if (PageUptodate(page))
>  				ASSERT(buffer_mapped(bh));
> -			uptodate = false;
>  			continue;
>  		}
>  
> @@ -847,9 +845,6 @@ xfs_writepage_map(
>  		count++;
>  	}
>  
> -	if (uptodate && poffset == PAGE_SIZE)
> -		SetPageUptodate(page);
> -
>  	ASSERT(wpc->ioend || list_empty(&submit_list));
>  
>  out:
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
