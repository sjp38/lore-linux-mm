Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59DC66B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:42:38 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id he1so32912377pac.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 07:42:38 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id xi11si9942346pac.134.2016.06.15.07.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 07:42:37 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id c74so1943436pfb.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 07:42:37 -0700 (PDT)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] zram: add zpool support v2
Date: Wed, 15 Jun 2016 22:42:06 +0800
Message-Id: <cover.1466000844.git.geliangtang@gmail.com>
In-Reply-To: <CAMJBoFPA_7G4nEeaPzL6uAvewpvgAYMmJ-A2FwfDSYVyOBfShA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Vitaly Wool <vitalywool@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 13, 2016 at 11:11:00AM +0200, Vitaly Wool wrote:
> Den 8 juni 2016 6:33 em skrev "Dan Streetman" <ddstreet@ieee.org>:
> >
> > On Wed, Jun 8, 2016 at 5:39 AM, Geliang Tang <geliangtang@gmail.com>
> wrote:
> > > This patch adds zpool support for zram, it will allow us to use both
> > > the zpool api and directly zsmalloc api in zram.
> >
> > besides the problems below, this was discussed a while ago and I
> > believe Minchan is still against it, as nobody has so far shown what
> > the benefit to zram would be; zram doesn't need the predictability, or
> > evictability, of zbud or z3fold.
> 
> > Right.
> >
> > Geliang, I cannot ack without any *detail* that what's the problem of
> > zram/zsmalloc, why we can't fix it in zsmalloc itself.
> > The zbud and zsmalloc is otally different design to aim different goal
> > determinism vs efficiency so you can choose what you want between
> > zswap
> > and zram rather than mixing the features.
>
> I'd also probably Cc Vitaly Wool on this
>
> Well, I believe I have something to say here. z3fold is generally faster
> than zsmalloc which makes it a better choice for zram sometimes, e.g. when
> zram device is used for swap. Also,  z3fold and zbud do not require MMU so
> zram over these can be used on small Linux powered MMU-less IoT devices, as
> opposed to the traditional zram over zsmalloc. Otherwise I do agree with
> Dan.
> 
> >
> > It doesn't make sense for zram to conditionally use zpool; either it
> > uses it and thus has 'select ZPOOL' in its Kconfig entry, or it
> > doesn't use it at all.
> >
> > > +#endif
> >
> > first, no.  this obviously makes using zpool in zram completely pointless.
> >
> > second, did you test this?  the pool you're passing is the zpool, not
> > the zs_pool.  quite bad things will happen when this code runs.  There
> > is no way to get the zs_pool from the zpool object (that's the point
> > of abstraction, of course).
> >
> > The fact zpool doesn't have these apis (currently) is one of the
> > reasons against changing zram to use zpool.
> >

Thank you all for your reply. I updated the patch and I hope this is better.

Geliang Tang (1):
  zram: update zram to use zpool

 drivers/block/zram/Kconfig    |  3 ++-
 drivers/block/zram/zram_drv.c | 59 ++++++++++++++++++++++---------------------
 drivers/block/zram/zram_drv.h |  4 +--
 mm/zsmalloc.c                 | 12 +++++----
 4 files changed, 41 insertions(+), 37 deletions(-)

-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
