Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA2616B0010
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:47:01 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id y90-v6so13823960ota.12
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:47:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r4-v6si2596733oie.338.2018.05.31.06.47.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 06:47:00 -0700 (PDT)
Date: Thu, 31 May 2018 09:46:59 -0400
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 11/18] xfs: don't clear imap_valid for a non-uptodate
 buffers
Message-ID: <20180531134658.GE2997@bfoster.bfoster>
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
> ---

Reviewed-by: Brian Foster <bfoster@redhat.com>

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
