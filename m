Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1518A6B0038
	for <linux-mm@kvack.org>; Sun,  1 Feb 2015 23:28:56 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so77275434pab.0
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 20:28:55 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id ow6si22250380pdb.83.2015.02.01.20.28.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 01 Feb 2015 20:28:55 -0800 (PST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so77118520pab.11
        for <linux-mm@kvack.org>; Sun, 01 Feb 2015 20:28:54 -0800 (PST)
Date: Mon, 2 Feb 2015 13:28:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150202042847.GG6402@blaptop>
References: <20150129052827.GB25462@blaptop>
 <20150129060604.GC2555@swordfish>
 <20150129063505.GA32331@blaptop>
 <20150129070835.GD2555@swordfish>
 <20150130144145.GA2840@blaptop>
 <20150201145036.GA1290@swordfish>
 <20150202013028.GB6402@blaptop>
 <20150202014800.GA6977@swordfish>
 <20150202024405.GD6402@blaptop>
 <20150202040124.GE6977@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150202040124.GE6977@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>

On Mon, Feb 02, 2015 at 01:01:24PM +0900, Sergey Senozhatsky wrote:
> On (02/02/15 11:44), Minchan Kim wrote:
> > > sure, I did think about this. and I actually didn't find any reason not
> > > to use ->refcount there. if user wants to reset the device, he first
> > > should umount it to make bdev->bd_holders check happy. and that's where
> > > IOs will be failed. so it makes sense to switch to ->refcount there, IMHO.
> > 
> > If we use zram as block device itself(not a fs or swap) and open the
> > block device as !FMODE_EXCL, bd_holders will be void.
> > 
> 
> hm.
> I don't mind to use ->disksize there, but personally I'd maybe prefer
> to use ->refcount, which just looks less hacky. zram's most common use
> cases are coming from ram swap device or ram device with fs. so it looks
> a bit like we care about some corner case here.

Maybe, but I always test zram with dd so it's not a corner case for me. :)

> 
> just my opinion, no objections against ->disksize != 0.

Thanks. It's a draft for v2. Please review.

BTW, you pointed out race between bdev_open/close and reset and
it's cleary bug although it's rare in real practice.
So, I want to fix it earlier than this patch and mark it as -stable
if we can fix it easily like Ganesh's work.
If it gets landing, we could make this patch rebased on it.
