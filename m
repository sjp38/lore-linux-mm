Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 972676B0038
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 22:41:08 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so76686459pab.11
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 19:41:08 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id a10si22225168pdm.27.2015.02.01.19.41.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 19:41:07 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id et14so76790233pad.4
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 19:41:07 -0800 (PST)
Date: Mon, 2 Feb 2015 12:41:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150202034100.GF6402@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

Separate another issue from my patch.

On Mon, Feb 02, 2015 at 11:44:06AM +0900, Minchan Kim wrote:
> On Mon, Feb 02, 2015 at 10:48:00AM +0900, Sergey Senozhatsky wrote:
> > Hello Minchan,
> > 
> > On (02/02/15 10:30), Minchan Kim wrote:
> > > > >  static inline int init_done(struct zram *zram)
> > > > >  {
> > > > > -	return zram->meta != NULL;
> > > > > +	return zram->disksize != 0;
> > > > 
> > > > we don't set ->disksize to 0 when create device. and I think
> > > > it's better to use refcount here, but set it to 0 during device creation.
> > > > (see the patch below)
> > > 
> > > There was a reason I didn't use refcount there.
> > > I should have written down it.
> > > 
> > > We need something to prevent further I/O handling on other CPUs.
> > > Otherwise, it's livelock. For example, new 'A' I/O rw path on CPU 1
> > > can see non-zero refcount if another CPU is going on rw.
> > > Then, another new 'B' I/O rw path on CPU 2 can see non-zero refcount
> > > if A I/O is going on. Then, another new 'C' I/O rw path on CPU 3 can
> > > see non-zero refcount if B I/O is going on. Finally, 'A' IO is done
> > > on CPU 1 and next I/O 'D' on CPU 1 can see non-zero refcount because
> > > 'C' on CPU 3 is going on. Infinite loop.
> > 
> > sure, I did think about this. and I actually didn't find any reason not
> > to use ->refcount there. if user wants to reset the device, he first
> > should umount it to make bdev->bd_holders check happy. and that's where
> > IOs will be failed. so it makes sense to switch to ->refcount there, IMHO.
> 
> If we use zram as block device itself(not a fs or swap) and open the
> block device as !FMODE_EXCL, bd_holders will be void.
> 
> Another topic: As I didn't see enough fs/block_dev.c bd_holders in zram
> would be mess. I guess we need to study hotplug of device and implement
> it for zram reset rather than strange own konb. It should go TODO. :(

Actually, I thought bd_mutex use from custom driver was terrible idea
so we should walk around with device hotplug but as I look through
another drivers, they have used the lock for a long time.
Maybe it's okay to use it in zram?
If so, Ganesh's patch is no problem to me although I didn't' review it in detail.
One thing I want to point out is that it would be better to change bd_holders
with bd_openers to filter out because dd test opens block device as !EXCL
so bd_holders will be void.

What do you think about it?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
