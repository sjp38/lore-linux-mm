Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f172.google.com (mail-io0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 21C126B0261
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 03:37:17 -0400 (EDT)
Received: by ioii196 with SMTP id i196so192577904ioi.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 00:37:17 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id 28si12070402iod.44.2015.09.15.00.37.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 00:37:16 -0700 (PDT)
Received: by padhk3 with SMTP id hk3so168784165pad.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 00:37:16 -0700 (PDT)
Date: Tue, 15 Sep 2015 16:38:01 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/3] zram: make max_zpage_size configurable
Message-ID: <20150915073801.GA480@swordfish>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
 <20150914155036.7c90a8e313cb0ed4d4857934@gmail.com>
 <20150915010043.GB1860@swordfish>
 <CAMJBoFPynFJpu57Gftm6bbyGfdSK67y-HbvoQPwyuHS6+0tOyQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAMJBoFPynFJpu57Gftm6bbyGfdSK67y-HbvoQPwyuHS6+0tOyQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, minchan@kernel.org, linux-mm@kvack.org, sergey.senozhatsky@gmail.com, linux-kernel@vger.kernel.org, ddstreet@ieee.org

On (09/15/15 09:18), Vitaly Wool wrote:
>    > On (09/14/15 15:50), Vitaly Wool wrote:
>    > > It makes sense to have control over what compression ratios are
>    > > ok to store pages uncompressed and what not.
>    >
>    > um... I don't want this to be exported. this is very 'zram-internal'.
>    >
>    > besides, you remove the exsiting default value
>    > - static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
>    >
>    > so now people must provide this module param in order to make zram
>    > work the way it used to work for years?
>    >
> 
>    I do not remove it, I move it :) May I ask to review the patch again
>    please?

Oh, yep, missed that.

Please read Dan Streetman's reply. I agree with what he said/suggested.


And can you please switch your email client to 'plain text' mode only?
haven't checked, but I suspect that some of vger lists block !plain_text
emails. ... apart from the fact that it's hard to read such emails in
mutt, etc.

	-ss

>    >
>    > > Moreover, if we end up using zbud allocator for zram, any attempt to
>    > > allocate a whole page will fail, so we may want to avoid this as much
>    > > as possible.
>    >
>    > so how does it help?
>    >
>    > > So, let's have max_zpage_size configurable as a module parameter.
>    > >
>    > > Signed-off-by: Vitaly Wool <[2]vitalywool@gmail.com>
>    > > ---
>    > >  drivers/block/zram/zram_drv.c | 13 +++++++++++++
>    > >  drivers/block/zram/zram_drv.h | 16 ----------------
>    > >  2 files changed, 13 insertions(+), 16 deletions(-)
>    > >
>    > > diff --git a/drivers/block/zram/zram_drv.c
>    b/drivers/block/zram/zram_drv.c
>    > > index 9fa15bb..6d9f1d1 100644
>    > > --- a/drivers/block/zram/zram_drv.c
>    > > +++ b/drivers/block/zram/zram_drv.c
>    > > @@ -42,6 +42,7 @@ static const char *default_compressor = "lzo";
>    > >
>    > >  /* Module params (documentation at end) */
>    > >  static unsigned int num_devices = 1;
>    > > +static size_t max_zpage_size = PAGE_SIZE / 4 * 3;
>    > >
>    > >  static inline void deprecated_attr_warn(const char *name)
>    > >  {
>    > > @@ -1411,6 +1412,16 @@ static int __init zram_init(void)
>    > >               return ret;
>    > >       }
>    > >
>    > > +     /*
>    > > +      * max_zpage_size must be less than or equal to:
>    > > +      * ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
>    > > +      * always return failure.
>    > > +      */
>    > > +     if (max_zpage_size > PAGE_SIZE) {
>    > > +             pr_err("Invalid max_zpage_size %ld\n", max_zpage_size);
>    >
>    > and how do people find out ZS_MAX_ALLOC_SIZE? this error message does
>    not
>    > help.
>    >
>    > > +             return -EINVAL;
>    > > +     }
>    > > +
>    > >       zram_major = register_blkdev(0, "zram");
>    > >       if (zram_major <= 0) {
>    > >               pr_err("Unable to get major number\n");
>    > > @@ -1444,6 +1455,8 @@ module_exit(zram_exit);
>    > >
>    > >  module_param(num_devices, uint, 0);
>    > >  MODULE_PARM_DESC(num_devices, "Number of pre-created zram devices");
>    > > +module_param(max_zpage_size, ulong, 0);
>    > > +MODULE_PARM_DESC(max_zpage_size, "Threshold for storing compressed
>    pages");
>    >
>    > unclear description.
>    >
>    >
>    > >
>    > >  MODULE_LICENSE("Dual BSD/GPL");
>    > >  MODULE_AUTHOR("Nitin Gupta <[3]ngupta@vflare.org>");
>    > > diff --git a/drivers/block/zram/zram_drv.h
>    b/drivers/block/zram/zram_drv.h
>    > > index 8e92339..3a29c33 100644
>    > > --- a/drivers/block/zram/zram_drv.h
>    > > +++ b/drivers/block/zram/zram_drv.h
>    > > @@ -20,22 +20,6 @@
>    > >
>    > >  #include "zcomp.h"
>    > >
>    > > -/*-- Configurable parameters */
>    > > -
>    > > -/*
>    > > - * Pages that compress to size greater than this are stored
>    > > - * uncompressed in memory.
>    > > - */
>    > > -static const size_t max_zpage_size = PAGE_SIZE / 4 * 3;
>    > > -
>    > > -/*
>    > > - * NOTE: max_zpage_size must be less than or equal to:
>    > > - *   ZS_MAX_ALLOC_SIZE. Otherwise, zs_malloc() would
>    > > - * always return failure.
>    > > - */
>    > > -
>    > > -/*-- End of configurable params */
>    > > -
>    > >  #define SECTOR_SHIFT         9
>    > >  #define SECTORS_PER_PAGE_SHIFT       (PAGE_SHIFT - SECTOR_SHIFT)
>    > >  #define SECTORS_PER_PAGE     (1 << SECTORS_PER_PAGE_SHIFT)
>    > > --
>    > > 1.9.1
>    > >
>    > > --
>    > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
>    > > the body to [4]majordomo@kvack.org.  For more info on Linux MM,
>    > > see: [5]http://www.linux-mm.org/ .
>    > > Don't email: <a href=mailto:"[6]dont@kvack.org"> [7]email@kvack.org
>    </a>
>    > >
> 
> References
> 
>    Visible links
>    1. mailto:sergey.senozhatsky.work@gmail.com
>    2. mailto:vitalywool@gmail.com
>    3. mailto:ngupta@vflare.org
>    4. mailto:majordomo@kvack.org
>    5. http://www.linux-mm.org/
>    6. mailto:dont@kvack.org
>    7. mailto:email@kvack.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
