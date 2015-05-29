Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id A80A66B0073
	for <linux-mm@kvack.org>; Fri, 29 May 2015 10:54:28 -0400 (EDT)
Received: by pdbki1 with SMTP id ki1so55410462pdb.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 07:54:28 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id fl4si8767831pab.108.2015.05.29.07.54.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 07:54:27 -0700 (PDT)
Received: by pdea3 with SMTP id a3so55253410pde.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 07:54:27 -0700 (PDT)
Date: Fri, 29 May 2015 23:54:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: clear disk io accounting when reset zram device
Message-ID: <20150529145418.GG11609@blaptop>
References: <"000001d099be$fae6cc90$f0b465b0$@yang"@samsung.com>
 <20150529034141.GA1157@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150529034141.GA1157@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Weijie Yang <weijie.yang@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, ngupta@vflare.org, 'Weijie Yang' <weijie.yang.kh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello guys,

On Fri, May 29, 2015 at 12:41:41PM +0900, Sergey Senozhatsky wrote:
> On (05/29/15 11:23), Weijie Yang wrote:
> > This patch clears zram disk io accounting when reset the zram device,
> > if don't do this, the residual io accounting stat will affect the
> > diskstat in the next zram active cycle.

Thanks for the fix.

> > 
> 
> thanks. my bad.
> 
> Acked-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Acked-by: Minchan Kim <minchan@kernel.org>

I give my acked-by because it's surely fix so there is no reason to
hesitate.

In future, I hope to change it like below.

I think the problem is caused from weired feature "reset" of zram.
Until a while ago, we didn't have hot_add/del feature so we should
use custom reset function but now we have hot/add feature.
So reset is logically same feature(ie, reset = hot_remove+hot_add
but remains same device id).

If we reuse zram_remove/add for reset, finally it calls del_gendisk
which will do part_stat_set_all for us so we didn't have this kinds
of problems.

It needs more churns and some tweaks of zram_[remove|add] but
it's more clean and consistent between reset and hot_remove.

Just my two cents.

> 
> 	-ss
> 
> > Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> > ---
> >  drivers/block/zram/zram_drv.c |    2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
> > index 8dcbced..6e134f4 100644
> > --- a/drivers/block/zram/zram_drv.c
> > +++ b/drivers/block/zram/zram_drv.c
> > @@ -805,7 +805,9 @@ static void zram_reset_device(struct zram *zram)
> >  	memset(&zram->stats, 0, sizeof(zram->stats));
> >  	zram->disksize = 0;
> >  	zram->max_comp_streams = 1;
> > +
> >  	set_capacity(zram->disk, 0);
> > +	part_stat_set_all(&zram->disk->part0, 0);
> >  
> >  	up_write(&zram->init_lock);
> >  	/* I/O operation under all of CPU are done so let's free */
> > -- 
> > 1.7.10.4
> > 
> > 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
