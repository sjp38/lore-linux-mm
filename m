Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 88B206B0035
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 03:56:33 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id y10so8165001pdj.3
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 00:56:32 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id mt6si24892517pdb.212.2014.09.24.00.56.31
        for <linux-mm@kvack.org>;
        Wed, 24 Sep 2014 00:56:32 -0700 (PDT)
Date: Wed, 24 Sep 2014 16:57:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 4/5] zram: add swap full hint
Message-ID: <20140924075712.GA3181@bbox>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
 <1411344191-2842-5-git-send-email-minchan@kernel.org>
 <20140922141118.de46ae5e54099cf2b39c8c5b@linux-foundation.org>
 <20140923045602.GC8325@bbox>
 <20140923141755.b7854bae484cfe434797be02@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20140923141755.b7854bae484cfe434797be02@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

On Tue, Sep 23, 2014 at 02:17:55PM -0700, Andrew Morton wrote:
> On Tue, 23 Sep 2014 13:56:02 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > > 
> > > > +#define ZRAM_FULLNESS_PERCENT 80
> > > 
> > > We've had problems in the past where 1% is just too large an increment
> > > for large systems.
> > 
> > So, do you want fullness_bytes like dirty_bytes?
> 
> Firstly I'd like you to think about whether we're ever likely to have
> similar granularity problems with this tunable.  If not then forget
> about it.

When I think the usecase for zram-swap, it is used for small memory
but not sure because these days, mobile phone DRAM size tend to be
big(ex, 3G) and they want to use zRAM for swap due to wear-leveling
of nand. When I consier the trend, they might set zram-swap to about
500M in future. In that case, 1% is 5M and given zram comp ratio(ie,
max 5:1), it could be 25M which is never small for the application.
So, IMO, we need more fine-grained knob.

> 
> If yes then we should do something.  I don't like the "bytes" thing
> much because it requires that the operator know the pool size
> beforehand, and any time that changes, the "bytes" needs hanging too. 
> Ratios are nice but percent is too coarse.  Maybe kernel should start
> using "ppm" for ratios, parts per million.  hrm.

Okay, I will consider it more in next spin.

> 
> > > > @@ -711,6 +732,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> > > >  	down_write(&zram->init_lock);
> > > >  
> > > >  	zram->limit_pages = 0;
> > > > +	atomic_set(&zram->alloc_fail, 0);
> > > >  
> > > >  	if (!init_done(zram)) {
> > > >  		up_write(&zram->init_lock);
> > > > @@ -944,6 +966,34 @@ static int zram_slot_free_notify(struct block_device *bdev,
> > > >  	return 0;
> > > >  }
> > > >  
> > > > +static int zram_full(struct block_device *bdev, void *arg)
> > > 
> > > This could return a bool.  That implies that zram_swap_hint should
> > > return bool too, but as we haven't been told what the zram_swap_hint
> > > return value does, I'm a bit stumped.
> > 
> > Hmm, currently, SWAP_FREE doesn't use return and SWAP_FULL uses return
> > as bool so in the end, we can change it as bool but I want to remain it
> > as int for the future. At least, we might use it as propagating error
> > in future. Instead, I will use *arg to return the result instead of
> > return val. But I'm not strong so if you want to remove return val,
> > I will do it. For clarifictaion, please tell me again if you want.
> 
> I'm easy, as long as it makes sense, is understandable by people other
> than he-who-wrote-it and doesn't use argument names such as "arg".

Yeb.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
