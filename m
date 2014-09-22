Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id A1D686B0035
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 17:11:20 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id eu11so3573182pac.10
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 14:11:20 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id kt6si17530561pdb.47.2014.09.22.14.11.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 14:11:19 -0700 (PDT)
Date: Mon, 22 Sep 2014 14:11:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v1 4/5] zram: add swap full hint
Message-Id: <20140922141118.de46ae5e54099cf2b39c8c5b@linux-foundation.org>
In-Reply-To: <1411344191-2842-5-git-send-email-minchan@kernel.org>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
	<1411344191-2842-5-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

On Mon, 22 Sep 2014 09:03:10 +0900 Minchan Kim <minchan@kernel.org> wrote:

> This patch implement SWAP_FULL handler in zram so that VM can
> know whether zram is full or not and use it to stop anonymous
> page reclaim.
> 
> How to judge fullness is below,
> 
> fullness = (100 * used space / total space)
> 
> It means the higher fullness is, the slower we reach zram full.
> Now, default of fullness is 80 so that it biased more momory
> consumption rather than early OOM kill.

It's unclear to me why this is being done.  What's wrong with "use it
until it's full then stop", which is what I assume the current code
does?  Why add this stuff?  What goes wrong with the current code and
how does this fix it?

ie: better explanation and justification in the chagnelogs, please.

> Above logic works only when used space of zram hit over the limit
> but zram also pretend to be full once 32 consecutive allocation
> fail happens. It's safe guard to prevent system hang caused by
> fragment uncertainty.

So allocation requests are of variable size, yes?  If so, the above
statement should read "32 consecutive allocation attempts for regions
or size 2 or more slots".  Because a failure of a single-slot
allocation attempt is an immediate failure.

The 32-in-a-row thing sounds like a hack.  Why can't we do this
deterministically?  If one request for four slots fails then the next
one will as well, so why bother retrying?

> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -43,6 +43,20 @@ static const char *default_compressor = "lzo";
>  /* Module params (documentation at end) */
>  static unsigned int num_devices = 1;
>  
> +/*
> + * If (100 * used_pages / total_pages) >= ZRAM_FULLNESS_PERCENT),
> + * we regards it as zram-full. It means that the higher
> + * ZRAM_FULLNESS_PERCENT is, the slower we reach zram full.
> + */

I just don't understand this patch :( To me, the above implies that the
user who sets 80% has elected to never use 20% of the zram capacity. 
Why on earth would anyone do that?  This chagnelog doesn't tell me.

> +#define ZRAM_FULLNESS_PERCENT 80

We've had problems in the past where 1% is just too large an increment
for large systems.

> @@ -597,10 +613,15 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  	}
>  
>  	alloced_pages = zs_get_total_pages(meta->mem_pool);
> -	if (zram->limit_pages && alloced_pages > zram->limit_pages) {
> -		zs_free(meta->mem_pool, handle);
> -		ret = -ENOMEM;
> -		goto out;
> +	if (zram->limit_pages) {
> +		if (alloced_pages > zram->limit_pages) {

This is all a bit racy, isn't it?  pool->pages_allocated and
zram->limit_pages could be changing under our feet.

> +			zs_free(meta->mem_pool, handle);
> +			atomic_inc(&zram->alloc_fail);
> +			ret = -ENOMEM;
> +			goto out;
> +		} else {
> +			atomic_set(&zram->alloc_fail, 0);
> +		}
 	}
 
 	update_used_max(zram, alloced_pages);

> @@ -711,6 +732,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  	down_write(&zram->init_lock);
>  
>  	zram->limit_pages = 0;
> +	atomic_set(&zram->alloc_fail, 0);
>  
>  	if (!init_done(zram)) {
>  		up_write(&zram->init_lock);
> @@ -944,6 +966,34 @@ static int zram_slot_free_notify(struct block_device *bdev,
>  	return 0;
>  }
>  
> +static int zram_full(struct block_device *bdev, void *arg)

This could return a bool.  That implies that zram_swap_hint should
return bool too, but as we haven't been told what the zram_swap_hint
return value does, I'm a bit stumped.

And why include the unusefully-named "void *arg"?  It doesn't get used here.

> +{
> +	struct zram *zram;
> +	struct zram_meta *meta;
> +	unsigned long total_pages, compr_pages;
> +
> +	zram = bdev->bd_disk->private_data;
> +	if (!zram->limit_pages)
> +		return 0;
> +
> +	meta = zram->meta;
> +	total_pages = zs_get_total_pages(meta->mem_pool);
> +
> +	if (total_pages >= zram->limit_pages) {
> +
> +		compr_pages = atomic64_read(&zram->stats.compr_data_size)
> +					>> PAGE_SHIFT;
> +		if ((100 * compr_pages / total_pages)
> +			>= ZRAM_FULLNESS_PERCENT)
> +			return 1;
> +	}
> +
> +	if (atomic_read(&zram->alloc_fail) > ALLOC_FAIL_MAX)
> +		return 1;
> +
> +	return 0;
> +}
> +
>  static int zram_swap_hint(struct block_device *bdev,
>  				unsigned int hint, void *arg)
>  {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
