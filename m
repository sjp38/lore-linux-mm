Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C579B6B0256
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 02:08:02 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so166401955pad.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:08:02 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id g7si29049492pat.209.2015.09.14.23.08.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 23:08:02 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so166401625pad.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 23:08:01 -0700 (PDT)
Date: Tue, 15 Sep 2015 15:08:46 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/3] zram: make max_zpage_size configurable
Message-ID: <20150915060846.GA454@swordfish>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
 <20150914155036.7c90a8e313cb0ed4d4857934@gmail.com>
 <CALZtOND74zjQCoVc+X4PBdZE1vKHGpt_nauU0JnyMC0c-u1bsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtOND74zjQCoVc+X4PBdZE1vKHGpt_nauU0JnyMC0c-u1bsg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Vitaly Wool <vitalywool@gmail.com>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On (09/15/15 01:42), Dan Streetman wrote:
> Well, zram explicitly expects to be able to store PAGE_SIZE'd objects:
> 
> if (unlikely(clen > max_zpage_size))
>     clen = PAGE_SIZE;
> handle = zs_malloc(meta->mem_pool, clen);
> 
> so the max_zpage_size doesn't prevent zram from trying to store the
> page in zsmalloc/zbud/whatever; instead, if the compressed page is
> larger than max_zpage_size, it just stores it uncompressed (as a side
> note, I'm not quite sure what the benefit of not storing in compressed
> form any pages that compress to between 3/4 and 1 page is...I suppose
> the decompression time is skipped, but it also wastes space...i would
> just make max_zpage_size == PAGE_SIZE).

correct, to avoid decompression of something that doesn't really
save any memory. compressed buffer may be very close to PAGE_SIZE,
so it sort of makes sense. I agree, that (3/4, 1 page] looks like
a magically picked range, though.

> 
> but zbud can't store a PAGE_SIZE'd object.  so the behavior would
> change.  The current behavior is:
> 
> compressed page <= max_zpage_size : stored compressed
> compressed page > max_zpage_size : stored uncompressed
> 
> new behavior:
> 
> compressed page <= max_zpage_size : stored compressed
> compressed page > max_zpage_size : zram write fails

yes. and per my observation, `compressed page > max_zpage_size'
happens "quite often".

	-ss

> to do this right, I think you have to change zbud to be able to store
> PAGE_SIZE'd objects.  That should be doable, I think you can just the
> page->lru to store it in the zbud lru, and use a page flag to indicate
> it's uncompressed, full PAGE_SIZE page, or something like that.  But
> without the ability to store full pages, zbud won't work well with
> zram.
> 
> >
> > So, let's have max_zpage_size configurable as a module parameter.
> >
> > Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> > ---
> >  drivers/block/zram/zram_drv.c | 13 +++++++++++++
> >  drivers/block/zram/zram_drv.h | 16 ----------------
> >  2 files changed, 13 insertions(+), 16 deletions(-)
> >
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index 9fa15bb..6d9f1d1 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -42,6 +42,7 @@ static const char *default_compressor = "lzo";
> >
> >  /* Module params (documentation at end) */
> >  static unsigned int num_devices = 1;
> > +static size_t max_zpage_size = PAGE_SIZE / 4 * 3;
> >
> >  static inline void deprecated_attr_warn(const char *name)
> >  {
> > @@ -1411,6 +1412,16 @@ static int __init zram_init(void)
> >                 return ret;
> >         }
> >
> > +       /*
> > +        * max_zpage_size must be less than or equal to:
> > +        * ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
> > +        * always return failure.
> > +        */
> > +       if (max_zpage_size > PAGE_SIZE) {
> > +               pr_err("Invalid max_zpage_size %ld\n", max_zpage_size);
> > +               return -EINVAL;
> > +       }
> > +
> >         zram_major = register_blkdev(0, "zram");
> >         if (zram_major <= 0) {
> >                 pr_err("Unable to get major number\n");
> > @@ -1444,6 +1455,8 @@ module_exit(zram_exit);
> >
> >  module_param(num_devices, uint, 0);
> >  MODULE_PARM_DESC(num_devices, "Number of pre-created zram devices");
> > +module_param(max_zpage_size, ulong, 0);
> > +MODULE_PARM_DESC(max_zpage_size, "Threshold for storing compressed pages");
> >
> >  MODULE_LICENSE("Dual BSD/GPL");
> >  MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
> > diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
> > index 8e92339..3a29c33 100644
> > --- a/drivers/block/zram/zram_drv.h
> > +++ b/drivers/block/zram/zram_drv.h
> > @@ -20,22 +20,6 @@
> >
> >  #include "zcomp.h"
> >
> > -/*-- Configurable parameters */
> > -
> > -/*
> > - * Pages that compress to size greater than this are stored
> > - * uncompressed in memory.
> > - */
> > -static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
> > -
> > -/*
> > - * NOTE: max_zpage_size must be less than or equal to:
> > - *   ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
> > - * always return failure.
> > - */
> > -
> > -/*-- End of configurable params */
> > -
> >  #define SECTOR_SHIFT           9
> >  #define SECTORS_PER_PAGE_SHIFT (PAGE_SHIFT - SECTOR_SHIFT)
> >  #define SECTORS_PER_PAGE       (1 << SECTORS_PER_PAGE_SHIFT)
> > --
> > 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
