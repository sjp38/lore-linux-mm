Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C5EE96B02E1
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 04:34:50 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m13so26901627pgd.12
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 01:34:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m5si21571453pln.123.2017.04.25.01.34.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Apr 2017 01:34:50 -0700 (PDT)
Date: Tue, 25 Apr 2017 10:34:46 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 2/4] fs/block_dev: always invalidate cleancache in
 invalidate_bdev()
Message-ID: <20170425083446.GC2793@quack2.suse.cz>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
 <20170424164135.22350-1-aryabinin@virtuozzo.com>
 <20170424164135.22350-3-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424164135.22350-3-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, stable@vger.kernel.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Nikolay Borisov <n.borisov.lkml@gmail.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon 24-04-17 19:41:33, Andrey Ryabinin wrote:
> invalidate_bdev() calls cleancache_invalidate_inode() iff ->nrpages != 0
> which doen't make any sense.
> Make sure that invalidate_bdev() always calls cleancache_invalidate_inode()
> regardless of mapping->nrpages value.
> 
> Fixes: c515e1fd361c ("mm/fs: add hooks to support cleancache")
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: <stable@vger.kernel.org>

Looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/block_dev.c | 11 +++++------
>  1 file changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/block_dev.c b/fs/block_dev.c
> index 065d7c5..f625dce 100644
> --- a/fs/block_dev.c
> +++ b/fs/block_dev.c
> @@ -104,12 +104,11 @@ void invalidate_bdev(struct block_device *bdev)
>  {
>  	struct address_space *mapping = bdev->bd_inode->i_mapping;
>  
> -	if (mapping->nrpages == 0)
> -		return;
> -
> -	invalidate_bh_lrus();
> -	lru_add_drain_all();	/* make sure all lru add caches are flushed */
> -	invalidate_mapping_pages(mapping, 0, -1);
> +	if (mapping->nrpages) {
> +		invalidate_bh_lrus();
> +		lru_add_drain_all();	/* make sure all lru add caches are flushed */
> +		invalidate_mapping_pages(mapping, 0, -1);
> +	}
>  	/* 99% of the time, we don't need to flush the cleancache on the bdev.
>  	 * But, for the strange corners, lets be cautious
>  	 */
> -- 
> 2.10.2
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
