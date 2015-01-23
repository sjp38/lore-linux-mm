Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D4A2E6B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 09:24:02 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so4317946pad.4
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 06:24:02 -0800 (PST)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id e5si2005464pat.191.2015.01.23.06.24.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 06:24:02 -0800 (PST)
Received: by mail-pd0-f175.google.com with SMTP id fl12so8808166pdb.6
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 06:24:01 -0800 (PST)
Date: Fri, 23 Jan 2015 23:24:35 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH 1/2] zram: free meta out of init_lock
Message-ID: <20150123142435.GA2320@swordfish>
References: <1421992707-32658-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421992707-32658-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (01/23/15 14:58), Minchan Kim wrote:
> We don't need to call zram_meta_free, zcomp_destroy and zs_free
> under init_lock. What we need to prevent race with init_lock
> in reset is setting NULL into zram->meta (ie, init_done).
> This patch does it.
> 
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  drivers/block/zram/zram_drv.c | 28 ++++++++++++++++------------
>  1 file changed, 16 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 9250b3f54a8f..0299d82275e7 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -708,6 +708,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  {
>  	size_t index;
>  	struct zram_meta *meta;
> +	struct zcomp *comp;
>  
>  	down_write(&zram->init_lock);
>  
> @@ -719,20 +720,10 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  	}
>  
>  	meta = zram->meta;
> -	/* Free all pages that are still in this zram device */
> -	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
> -		unsigned long handle = meta->table[index].handle;
> -		if (!handle)
> -			continue;
> -
> -		zs_free(meta->mem_pool, handle);
> -	}
> -
> -	zcomp_destroy(zram->comp);

I'm not so sure about moving zcomp destruction. if we would have detached it
from zram, then yes. otherwise, think of zram ->destoy vs ->init race.

suppose,
CPU1 waits for down_write() init lock in disksize_store() with new comp already allocated;
CPU0 detaches ->meta and releases write init lock;
CPU1 grabs the lock and does zram->comp = comp;
CPU0 reaches the point of zcomp_destroy(zram->comp);


I'd probably prefer to keep zcomp destruction on its current place. I
see a little real value in introducing zcomp detaching and moving
destruction out of init_lock.

	-ss

> +	comp = zram->comp;
> +	zram->meta = NULL;
>  	zram->max_comp_streams = 1;
>  
> -	zram_meta_free(zram->meta);
> -	zram->meta = NULL;
>  	/* Reset stats */
>  	memset(&zram->stats, 0, sizeof(zram->stats));
>  
> @@ -742,6 +733,19 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
>  
>  	up_write(&zram->init_lock);
>  
> +	/* Free all pages that are still in this zram device */
> +	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
> +		unsigned long handle = meta->table[index].handle;
> +
> +		if (!handle)
> +			continue;
> +
> +		zs_free(meta->mem_pool, handle);
> +	}
> +
> +	zcomp_destroy(comp);
> +	zram_meta_free(meta);
> +
>  	/*
>  	 * Revalidate disk out of the init_lock to avoid lockdep splat.
>  	 * It's okay because disk's capacity is protected by init_lock
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
