Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 774A06B0070
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 23:21:18 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so33862552pac.13
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 20:21:18 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id gn3si8232317pbb.186.2015.01.28.20.21.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 20:21:17 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id rd3so33841029pab.3
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 20:21:17 -0800 (PST)
Date: Thu, 29 Jan 2015 13:21:15 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2] zram: free meta table in zram_meta_free
Message-ID: <20150129042115.GB2555@swordfish>
References: <1421711028-5553-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421711028-5553-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (01/20/15 07:43), Ganesh Mahendran wrote:
> zram_meta_alloc() and zram_meta_free() are a pair.
> In zram_meta_alloc(), meta table is allocated. So it it better to free
> it in zram_meta_free().
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>


Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

	-ss

> ---
> v2: use zram->disksize to get num of pages - Sergey
> ---
>  drivers/block/zram/zram_drv.c |   33 ++++++++++++++++-----------------
>  1 file changed, 16 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 9250b3f..aa5a4c5 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -307,8 +307,21 @@ static inline int valid_io_request(struct zram *zram,
>  	return 1;
>  }
>  
> -static void zram_meta_free(struct zram_meta *meta)
> +static void zram_meta_free(struct zram_meta *meta, u64 disksize)
>  {
> +	size_t num_pages = disksize >> PAGE_SHIFT;
> +	size_t index;
> +
> +	/* Free all pages that are still in this zram device */
> +	for (index = 0; index < num_pages; index++) {
> +		unsigned long handle = meta->table[index].handle;
> +
> +		if (!handle)
> +			continue;
> +
> +		zs_free(meta->mem_pool, handle);
> +	}
> +
>  	zs_destroy_pool(meta->mem_pool);
>  	vfree(meta->table);
>  	kfree(meta);
> @@ -706,9 +719,6 @@ static void zram_bio_discard(struct zram *zram, u32 index,
>  
>  static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  {
> -	size_t index;
> -	struct zram_meta *meta;
> -
>  	down_write(&zram->init_lock);
>  
>  	zram->limit_pages = 0;
> @@ -718,20 +728,9 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  		return;
>  	}
>  
> -	meta = zram->meta;
> -	/* Free all pages that are still in this zram device */
> -	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
> -		unsigned long handle = meta->table[index].handle;
> -		if (!handle)
> -			continue;
> -
> -		zs_free(meta->mem_pool, handle);
> -	}
> -
>  	zcomp_destroy(zram->comp);
>  	zram->max_comp_streams = 1;
> -
> -	zram_meta_free(zram->meta);
> +	zram_meta_free(zram->meta, zram->disksize);
>  	zram->meta = NULL;
>  	/* Reset stats */
>  	memset(&zram->stats, 0, sizeof(zram->stats));
> @@ -803,7 +802,7 @@ out_destroy_comp:
>  	up_write(&zram->init_lock);
>  	zcomp_destroy(comp);
>  out_free_meta:
> -	zram_meta_free(meta);
> +	zram_meta_free(meta, disksize);
>  	return err;
>  }
>  
> -- 
> 1.7.9.5
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
