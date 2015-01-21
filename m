Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB596B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 09:21:20 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so18776985pac.13
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 06:21:20 -0800 (PST)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id g8si3900717pdk.182.2015.01.21.06.21.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 06:21:19 -0800 (PST)
Received: by mail-pd0-f182.google.com with SMTP id z10so10600972pdj.13
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 06:21:18 -0800 (PST)
Date: Wed, 21 Jan 2015 23:21:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v1 01/10] zram: avoid calling of zram_meta_free under
 init_lock
Message-ID: <20150121142115.GA986@swordfish>
References: <1421820866-26521-1-git-send-email-minchan@kernel.org>
 <1421820866-26521-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421820866-26521-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Nitin Gupta <ngupta@vflare.org>, Juneho Choi <juno.choi@lge.com>, Gunho Lee <gunho.lee@lge.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (01/21/15 15:14), Minchan Kim wrote:
> We don't need to call zram_meta_free under init_lock.
> What we need to prevent race is setting NULL into zram->meta
> (ie, init_done). This patch does it.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/block/zram/zram_drv.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 9250b3f..7e03d86 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -719,6 +719,8 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  	}
>  
>  	meta = zram->meta;
> +	zram->meta = NULL;
> +
>  	/* Free all pages that are still in this zram device */
>  	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
>  		unsigned long handle = meta->table[index].handle;
> @@ -731,8 +733,6 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  	zcomp_destroy(zram->comp);
>  	zram->max_comp_streams = 1;
>  
> -	zram_meta_free(zram->meta);
> -	zram->meta = NULL;
>  	/* Reset stats */
>  	memset(&zram->stats, 0, sizeof(zram->stats));
>  
> @@ -741,6 +741,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  		set_capacity(zram->disk, 0);
>  
>  	up_write(&zram->init_lock);
> +	zram_meta_free(meta);

Hello,

since we detached ->meta from zram, this one doesn't really need
->init_lock protection:

	/* Free all pages that are still in this zram device */
	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
		unsigned long handle = meta->table[index].handle;
		if (!handle)
			continue;

		zs_free(meta->mem_pool, handle);
	}


	-ss

>  	/*
>  	 * Revalidate disk out of the init_lock to avoid lockdep splat.
> -- 
> 1.9.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
