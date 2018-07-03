Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF1A96B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 13:19:27 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d23-v6so2658700qtj.12
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 10:19:27 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f23-v6si1604808qkf.85.2018.07.03.10.19.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 10:19:26 -0700 (PDT)
Date: Tue, 3 Jul 2018 10:19:20 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 2/2] fs: xfs: use BUG_ON if writepage call comes from
 direct reclaim
Message-ID: <20180703171920.GC5711@magnolia>
References: <1530591079-33813-1-git-send-email-yang.shi@linux.alibaba.com>
 <1530591079-33813-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530591079-33813-2-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, tytso@mit.edu, adilger.kernel@dilger.ca, dchinner@redhat.com, akpm@linux-foundation.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 03, 2018 at 12:11:19PM +0800, Yang Shi wrote:
> direct reclaim doesn't write out filesystem page, only kswapd could do
> this. So, if it is called from direct relaim, it is definitely a bug.
> 
> And, Mel Gorman mentioned "Ultimately, this will be a BUG_ON." in commit
> 94054fa3fca1fd78db02cb3d68d5627120f0a1d4 ("xfs: warn if direct reclaim
> tries to writeback pages"),
> 
> It has been many years since that commit, so it should be safe to
> elevate WARN_ON to BUG_ON now.
> 
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Darrick J. Wong <darrick.wong@oracle.com>
> Cc: Dave Chinner <dchinner@redhat.com>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> ---
>  fs/xfs/xfs_aops.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index 8eb3ba3..7efc2d2 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -1080,11 +1080,9 @@ static inline int xfs_bio_add_buffer(struct bio *bio, struct buffer_head *bh)
>  	 * allow reclaim from kswapd as the stack usage there is relatively low.
>  	 *
>  	 * This should never happen except in the case of a VM regression so
> -	 * warn about it.
> +	 * BUG about it.
>  	 */
> -	if (WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
> -			PF_MEMALLOC))
> -		goto redirty;
> +	BUG_ON((current->flags & (PF_MEMALLOC|PF_KSWAPD)) == PF_MEMALLOC);

Ugh, please do not increase the BUG() factor.  Even if this happens due
to a regression it's /much/ easier to debug if we don't halt the system.

(IOWs, I decline to take this patch.)

--D

>  
>  	/*
>  	 * Given that we do not allow direct reclaim to call us, we should
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
