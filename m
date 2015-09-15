Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8C54A6B0253
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 01:43:26 -0400 (EDT)
Received: by ioii196 with SMTP id i196so190704214ioi.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 22:43:26 -0700 (PDT)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id j202si11829809ioj.32.2015.09.14.22.43.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 22:43:25 -0700 (PDT)
Received: by ioii196 with SMTP id i196so190704110ioi.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 22:43:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150914155036.7c90a8e313cb0ed4d4857934@gmail.com>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com> <20150914155036.7c90a8e313cb0ed4d4857934@gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 15 Sep 2015 01:42:46 -0400
Message-ID: <CALZtOND74zjQCoVc+X4PBdZE1vKHGpt_nauU0JnyMC0c-u1bsg@mail.gmail.com>
Subject: Re: [PATCH 1/3] zram: make max_zpage_size configurable
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Sep 14, 2015 at 9:50 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
> It makes sense to have control over what compression ratios are
> ok to store pages uncompressed and what not. Moreover, if we end
> up using zbud allocator for zram, any attempt to allocate a whole
> page will fail, so we may want to avoid this as much as possible.

Well, zram explicitly expects to be able to store PAGE_SIZE'd objects:

if (unlikely(clen > max_zpage_size))
    clen = PAGE_SIZE;
handle = zs_malloc(meta->mem_pool, clen);

so the max_zpage_size doesn't prevent zram from trying to store the
page in zsmalloc/zbud/whatever; instead, if the compressed page is
larger than max_zpage_size, it just stores it uncompressed (as a side
note, I'm not quite sure what the benefit of not storing in compressed
form any pages that compress to between 3/4 and 1 page is...I suppose
the decompression time is skipped, but it also wastes space...i would
just make max_zpage_size == PAGE_SIZE).

but zbud can't store a PAGE_SIZE'd object.  so the behavior would
change.  The current behavior is:

compressed page <= max_zpage_size : stored compressed
compressed page > max_zpage_size : stored uncompressed

new behavior:

compressed page <= max_zpage_size : stored compressed
compressed page > max_zpage_size : zram write fails

to do this right, I think you have to change zbud to be able to store
PAGE_SIZE'd objects.  That should be doable, I think you can just the
page->lru to store it in the zbud lru, and use a page flag to indicate
it's uncompressed, full PAGE_SIZE page, or something like that.  But
without the ability to store full pages, zbud won't work well with
zram.

>
> So, let's have max_zpage_size configurable as a module parameter.
>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> ---
>  drivers/block/zram/zram_drv.c | 13 +++++++++++++
>  drivers/block/zram/zram_drv.h | 16 ----------------
>  2 files changed, 13 insertions(+), 16 deletions(-)
>
> diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> index 9fa15bb..6d9f1d1 100644
> --- a/drivers/block/zram/zram_drv.c
> +++ b/drivers/block/zram/zram_drv.c
> @@ -42,6 +42,7 @@ static const char *default_compressor = "lzo";
>
>  /* Module params (documentation at end) */
>  static unsigned int num_devices = 1;
> +static size_t max_zpage_size = PAGE_SIZE / 4 * 3;
>
>  static inline void deprecated_attr_warn(const char *name)
>  {
> @@ -1411,6 +1412,16 @@ static int __init zram_init(void)
>                 return ret;
>         }
>
> +       /*
> +        * max_zpage_size must be less than or equal to:
> +        * ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
> +        * always return failure.
> +        */
> +       if (max_zpage_size > PAGE_SIZE) {
> +               pr_err("Invalid max_zpage_size %ld\n", max_zpage_size);
> +               return -EINVAL;
> +       }
> +
>         zram_major = register_blkdev(0, "zram");
>         if (zram_major <= 0) {
>                 pr_err("Unable to get major number\n");
> @@ -1444,6 +1455,8 @@ module_exit(zram_exit);
>
>  module_param(num_devices, uint, 0);
>  MODULE_PARM_DESC(num_devices, "Number of pre-created zram devices");
> +module_param(max_zpage_size, ulong, 0);
> +MODULE_PARM_DESC(max_zpage_size, "Threshold for storing compressed pages");
>
>  MODULE_LICENSE("Dual BSD/GPL");
>  MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
> diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> index 8e92339..3a29c33 100644
> --- a/drivers/block/zram/zram_drv.h
> +++ b/drivers/block/zram/zram_drv.h
> @@ -20,22 +20,6 @@
>
>  #include "zcomp.h"
>
> -/*-- Configurable parameters */
> -
> -/*
> - * Pages that compress to size greater than this are stored
> - * uncompressed in memory.
> - */
> -static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
> -
> -/*
> - * NOTE: max_zpage_size must be less than or equal to:
> - *   ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
> - * always return failure.
> - */
> -
> -/*-- End of configurable params */
> -
>  #define SECTOR_SHIFT           9
>  #define SECTORS_PER_PAGE_SHIFT (PAGE_SHIFT - SECTOR_SHIFT)
>  #define SECTORS_PER_PAGE       (1 << SECTORS_PER_PAGE_SHIFT)
> --
> 1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
