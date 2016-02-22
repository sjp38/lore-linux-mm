Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 809556B0009
	for <linux-mm@kvack.org>; Sun, 21 Feb 2016 19:04:22 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hb3so66752478igb.0
        for <linux-mm@kvack.org>; Sun, 21 Feb 2016 16:04:22 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id s84si37178509ioi.32.2016.02.21.16.04.20
        for <linux-mm@kvack.org>;
        Sun, 21 Feb 2016 16:04:21 -0800 (PST)
Date: Mon, 22 Feb 2016 09:04:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC][PATCH v2 2/3] zram: use zs_get_huge_class_size_watermark()
Message-ID: <20160222000436.GA21710@bbox>
References: <1456061274-20059-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1456061274-20059-3-git-send-email-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
In-Reply-To: <1456061274-20059-3-git-send-email-sergey.senozhatsky@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Sun, Feb 21, 2016 at 10:27:53PM +0900, Sergey Senozhatsky wrote:
> From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> 
> zram should stop enforcing its own 'bad' object size watermark,
> and start using zs_get_huge_class_size_watermark(). zsmalloc
> really knows better.
> 
> Drop `max_zpage_size' and use zs_get_huge_class_size_watermark()
> instead.

max_zpage_size was there since zram's grandpa(ie, ramzswap).
AFAIR, at that time, it works to forward incompressible
(e.g, PAGE_SIZE/2) page to backing swap if it presents.
If it doesn't have any backing swap and it's incompressbile
(e.g, PAGE_SIZE*3/4), it stores it as uncompressed page
to avoid *decompress* overhead later. And Nitin want to make
it as tunable parameter. I agree the approach because I don't
want to make coupling between zram and allocator as far as
possible.

If huge class is pain, it's allocator problem, not zram stuff.
I think we should try to remove such problem in zsmalloc layer,
firstly.

Having said that, I agree your claim that uncompressible pages
are pain. I want to handle the problem as multiple-swap apparoach.
Now, zram is very popular and I expect we will use multiple
swap(i.e., zram swap + eMMC swap) shortly. For that case, we could
forward uncompressible page to the eMMC swap with simple tweaking
of swap subsystem if zram returns error once it found it's
incompressible page.

For that, we should introduce new knob in zram layer like Nitin
did and make it configurable so we could solve the problem of
single zram-swap system as well as multiple swap system.


> 
> Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> ---
>  drivers/block/zram/zram_drv.c | 2 +-
>  drivers/block/zram/zram_drv.h | 6 ------
>  2 files changed, 1 insertion(+), 7 deletions(-)
> 
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 46055db..2621564 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -714,7 +714,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
>  		goto out;
>  	}
>  	src = zstrm->buffer;
> -	if (unlikely(clen > max_zpage_size)) {
> +	if (unlikely(clen > zs_get_huge_class_size_watermark())) {
>  		clen = PAGE_SIZE;
>  		if (is_partial_io(bvec))
>  			src = uncmem;
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index 8e92339..8879161 100644
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -23,12 +23,6 @@
>  /*-- Configurable parameters */
>  
>  /*
> - * Pages that compress to size greater than this are stored
> - * uncompressed in memory.
> - */
> -static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
> -
> -/*
>   * NOTE: max_zpage_size must be less than or equal to:
>   *   ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
>   * always return failure.
> -- 
> 2.7.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
