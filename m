Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C58496B0038
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 21:44:14 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id rd3so76193442pab.9
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 18:44:14 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id o1si7376278pdo.54.2015.02.01.18.44.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 18:44:13 -0800 (PST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so76196650pab.12
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 18:44:13 -0800 (PST)
Date: Mon, 2 Feb 2015 11:44:06 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150202024405.GD6402@blaptop>
References: <20150129020139.GB9672@blaptop>
 <20150129022241.GA2555@swordfish>
 <20150129052827.GB25462@blaptop>
 <20150129060604.GC2555@swordfish>
 <20150129063505.GA32331@blaptop>
 <20150129070835.GD2555@swordfish>
 <20150130144145.GA2840@blaptop>
 <20150201145036.GA1290@swordfish>
 <20150202013028.GB6402@blaptop>
 <20150202014800.GA6977@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150202014800.GA6977@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On Mon, Feb 02, 2015 at 10:48:00AM +0900, Sergey Senozhatsky wrote:
> Hello Minchan,
> 
> On (02/02/15 10:30), Minchan Kim wrote:
> > > >  static inline int init_done(struct zram *zram)
> > > >  {
> > > > -	return zram->meta != NULL;
> > > > +	return zram->disksize != 0;
> > > 
> > > we don't set ->disksize to 0 when create device. and I think
> > > it's better to use refcount here, but set it to 0 during device creation.
> > > (see the patch below)
> > 
> > There was a reason I didn't use refcount there.
> > I should have written down it.
> > 
> > We need something to prevent further I/O handling on other CPUs.
> > Otherwise, it's livelock. For example, new 'A' I/O rw path on CPU 1
> > can see non-zero refcount if another CPU is going on rw.
> > Then, another new 'B' I/O rw path on CPU 2 can see non-zero refcount
> > if A I/O is going on. Then, another new 'C' I/O rw path on CPU 3 can
> > see non-zero refcount if B I/O is going on. Finally, 'A' IO is done
> > on CPU 1 and next I/O 'D' on CPU 1 can see non-zero refcount because
> > 'C' on CPU 3 is going on. Infinite loop.
> 
> sure, I did think about this. and I actually didn't find any reason not
> to use ->refcount there. if user wants to reset the device, he first
> should umount it to make bdev->bd_holders check happy. and that's where
> IOs will be failed. so it makes sense to switch to ->refcount there, IMHO.

If we use zram as block device itself(not a fs or swap) and open the
block device as !FMODE_EXCL, bd_holders will be void.

Another topic: As I didn't see enough fs/block_dev.c bd_holders in zram
would be mess. I guess we need to study hotplug of device and implement
it for zram reset rather than strange own konb. It should go TODO. :(

> 
> 
> > > here and later:
> > > we can't take zram_meta_get() first and then check for init_done(zram),
> > > because ->meta can be NULL, so it fill be ->NULL->refcount.
> > 
> > True.
> > Actually, it was totally RFC I forgot adding the tag in the night but I can't
> > escape from my shame with the escuse. Thanks!
> 
> no problem at all. you were throwing solutions all week long.
> 
> > 
> > > 
> > > let's keep ->completion and ->refcount in zram and rename zram_meta_[get|put]
> > > to zram_[get|put].
> > 
> > Good idea but still want to name it as zram_meta_get/put because zram_get naming
> > might confuse struct zram's refcount rather than zram_meta. :)
> 
> no objections. but I assume we agreed to keep ->io_done completion
> and ->refcount in zram.
> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
