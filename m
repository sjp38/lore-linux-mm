Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF586B0037
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 21:06:57 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lf10so9801697pab.22
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 18:06:57 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id py5si741066pdb.246.2014.09.24.18.06.55
        for <linux-mm@kvack.org>;
        Wed, 24 Sep 2014 18:06:56 -0700 (PDT)
Date: Thu, 25 Sep 2014 10:07:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 4/5] zram: add swap full hint
Message-ID: <20140925010738.GC17364@bbox>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
 <1411344191-2842-5-git-send-email-minchan@kernel.org>
 <20140922141118.de46ae5e54099cf2b39c8c5b@linux-foundation.org>
 <20140923045602.GC8325@bbox>
 <20140923141755.b7854bae484cfe434797be02@linux-foundation.org>
 <5422DEDE.1060004@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5422DEDE.1060004@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

On Wed, Sep 24, 2014 at 05:10:22PM +0200, Jerome Marchand wrote:
> On 09/23/2014 11:17 PM, Andrew Morton wrote:
> > On Tue, 23 Sep 2014 13:56:02 +0900 Minchan Kim <minchan@kernel.org> wrote:
> > 
> >>>
> >>>> +#define ZRAM_FULLNESS_PERCENT 80
> >>>
> >>> We've had problems in the past where 1% is just too large an increment
> >>> for large systems.
> >>
> >> So, do you want fullness_bytes like dirty_bytes?
> > 
> > Firstly I'd like you to think about whether we're ever likely to have
> > similar granularity problems with this tunable.  If not then forget
> > about it.
> > 
> > If yes then we should do something.  I don't like the "bytes" thing
> > much because it requires that the operator know the pool size
> > beforehand, and any time that changes, the "bytes" needs hanging too. 
> > Ratios are nice but percent is too coarse.  Maybe kernel should start
> > using "ppm" for ratios, parts per million.  hrm.
> 
> An other possibility is to use decimal fractions. AFAIK, lustre fs uses
> them already for its procfs entries.

Looks good to me. If anyone doesn't have better idea or objection,
I want to approach this way.

Thanks for the hint!

> 
> > 
> >>>> @@ -711,6 +732,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
> >>>>  	down_write(&zram->init_lock);
> >>>>  
> >>>>  	zram->limit_pages = 0;
> >>>> +	atomic_set(&zram->alloc_fail, 0);
> >>>>  
> >>>>  	if (!init_done(zram)) {
> >>>>  		up_write(&zram->init_lock);
> >>>> @@ -944,6 +966,34 @@ static int zram_slot_free_notify(struct block_device *bdev,
> >>>>  	return 0;
> >>>>  }
> >>>>  
> >>>> +static int zram_full(struct block_device *bdev, void *arg)
> >>>
> >>> This could return a bool.  That implies that zram_swap_hint should
> >>> return bool too, but as we haven't been told what the zram_swap_hint
> >>> return value does, I'm a bit stumped.
> >>
> >> Hmm, currently, SWAP_FREE doesn't use return and SWAP_FULL uses return
> >> as bool so in the end, we can change it as bool but I want to remain it
> >> as int for the future. At least, we might use it as propagating error
> >> in future. Instead, I will use *arg to return the result instead of
> >> return val. But I'm not strong so if you want to remove return val,
> >> I will do it. For clarifictaion, please tell me again if you want.
> > 
> > I'm easy, as long as it makes sense, is understandable by people other
> > than he-who-wrote-it and doesn't use argument names such as "arg".
> > 
> > 
> 
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
