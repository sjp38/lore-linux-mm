Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF8036B0005
	for <linux-mm@kvack.org>; Wed, 30 May 2018 13:34:41 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g5-v6so16106114ioc.4
        for <linux-mm@kvack.org>; Wed, 30 May 2018 10:34:41 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b129-v6si16342690ith.108.2018.05.30.10.34.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 10:34:40 -0700 (PDT)
Date: Wed, 30 May 2018 10:34:37 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 11/18] xfs: don't clear imap_valid for a non-uptodate
 buffers
Message-ID: <20180530173437.GO837@magnolia>
References: <20180530100013.31358-1-hch@lst.de>
 <20180530100013.31358-12-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180530100013.31358-12-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 30, 2018 at 12:00:06PM +0200, Christoph Hellwig wrote:
> Finding a buffer that isn't uptodate doesn't invalidate the mapping for
> any given block.  The last_sector check will already take care of starting
> another ioend as soon as we find any non-update buffer, and if the current
> mapping doesn't include the next uptodate buffer the xfs_imap_valid check
> will take care of it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  fs/xfs/xfs_aops.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index cef2bc3cf98b..7dc13b0aae60 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -849,15 +849,12 @@ xfs_writepage_map(
>  			break;
>  
>  		/*
> -		 * Block does not contain valid data, skip it, mark the current
> -		 * map as invalid because we have a discontiguity. This ensures
> -		 * we put subsequent writeable buffers into a new ioend.
> +		 * Block does not contain valid data, skip it.
>  		 */
>  		if (!buffer_uptodate(bh)) {
>  			if (PageUptodate(page))
>  				ASSERT(buffer_mapped(bh));
>  			uptodate = false;
> -			wpc->imap_valid = false;
>  			continue;
>  		}
>  
> -- 
> 2.17.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
