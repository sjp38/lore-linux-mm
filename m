Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 874F4C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:33:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12C8520828
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 02:33:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XaCH/Dvd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12C8520828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 69D986B000A; Tue,  4 Jun 2019 22:33:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64DCB6B000D; Tue,  4 Jun 2019 22:33:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 562B96B0010; Tue,  4 Jun 2019 22:33:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 349576B000A
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 22:33:44 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id 188so706104ith.4
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 19:33:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=xIsyZFQQsGq7W0W6okN60t5FpnPQJ7npRyxNhSfdoEw=;
        b=T3gTjh/5wz7/8PEYfbdVkrao6FA3F/qG/fB4Xv40PxK9KXmt7HsEaUxba0MeTrvV1v
         0WaYcGBL8EXJiMwtD0tVfYuHq7ktjs5zsRr/icSKmXtgtYfSJ5BTXVfRK10x7Up7+sWJ
         e05I9waaRWjdtfACC/fwnSjVtKv41R3ebRff2H1lFNMElZCrvsEfUlZF4jDB5LNsKRf3
         AgcZOcAPlDxBOXoebuJlAwMrEAplepSIFbGgVOdBcp5jomZe3J79AnHeBSGti4JsUT4J
         W8OqtHc5QgGMPQio6biO1qzp0NhI5p6rSXKU3EC4O7Cdn26FjBwZv7mLJwkNkl4h64j1
         hjtA==
X-Gm-Message-State: APjAAAW4rVOwoHEgg8vuWFMGd2lka00z7O0wD4lynU+x8hDN3G/U5RNt
	wo9+16BL9B49vTt7g68LIaPUXCL9YUGQBJN5bEq6Vk6GamBmhLWHqZ3tYQvF/DBfsBV1j2CkftG
	8Pn+/sy3qMIkYVm1r3D0CTqgL2EsxWd2uBb9odR4iFE9LT9EuqX55F/HbVdpdy5R6xg==
X-Received: by 2002:a5e:9241:: with SMTP id z1mr9481164iop.39.1559702023863;
        Tue, 04 Jun 2019 19:33:43 -0700 (PDT)
X-Received: by 2002:a5e:9241:: with SMTP id z1mr9481132iop.39.1559702022766;
        Tue, 04 Jun 2019 19:33:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559702022; cv=none;
        d=google.com; s=arc-20160816;
        b=FY0V6ef80JjP0nmm3vqDgthYEvCWyFl+5SnKiUWREKelfMKjjVbu8/HO00mS67mAc1
         W01TggzWDeqC5aBNU07pltSPAo8UCkWoZQci7dkkADsbtjft0IhziCfnAOwVLquNLFC8
         Woa7opXivP4nKPaikB0Wq0CXaAeSZZeBcNgTKB3zzE2l5Me7veaY/gPVgoG1sh4CbbDg
         x2bZO7TzoerClCiWN4N3/vRB5J/NnbyXm/HgARKsMmcVpaGTVOj8IAiung8gBv/raxTn
         pEWY4CEfX0lAMqST0Vu2wRCds/ezLt6GNu//xpeFpN7n7JzY3p9aeB8CPSAcx4aOJ9OR
         sPRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=xIsyZFQQsGq7W0W6okN60t5FpnPQJ7npRyxNhSfdoEw=;
        b=i4NF2BqU+qJZyBTgigcauciO2HGbhiIDMPY8BJsyE8uih6YdiLLOviEm/fHd6H9Zun
         Y1iLASInu7JixroWefJAE810P3/u4OGvk7yC4Mi+Io/C0Yk+gH+0YItFxq1z95Px3IhI
         6BgZ7g+000dt4qqFAtxtTcAgaqkZQHcQEBTz8XSP0200uydnBmLX5iyOh3ED0FR0zOGh
         kFHaQ9+9LUgCOXSATA5dZJ5gLGbU79hf8OYJfuos8IaYi6niMp2NOp1EOg/ceM/QguK2
         g7aWltK96y6Pw32F5wOMnZBtAbUsSOtEBbIkrm06hfM+femRNlTn9Fd+CQQ8uLduX1LB
         kdHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XaCH/Dvd";
       spf=pass (google.com: domain of teawater@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=teawater@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 203sor9184265itl.24.2019.06.04.19.33.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 19:33:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of teawater@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="XaCH/Dvd";
       spf=pass (google.com: domain of teawater@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=teawater@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=xIsyZFQQsGq7W0W6okN60t5FpnPQJ7npRyxNhSfdoEw=;
        b=XaCH/DvdV5q+8alkB1RVT/031pYdLmM7R8qrP6ujiLnLmW5O1y0gMv19tXHGiHOt5S
         dguGV0XTX7jB+Gl14o7FyKkfg6CSrvxXhSb0WturgSGh0o8qcGd6QpYfUfv6fyZ8P52E
         EbTyx95y/+ytds2haifPpk6FJiOJcb13dV4MdIxeeTURYEtBgCO36/dMx5wFKwvppkfF
         DT4JHE0NpldhEOOkxTlTv1VU8ADfeLJYN4UsXSdOa7nuaW0lrb/Bs8xUHwAvzgcXSQPk
         w7YCaFJRenDjnI6tWWUYF3gqvY2OThIfyrHgK07YxHib8vXHNoDeoPCiV8Ml2ncDUszq
         1wFA==
X-Google-Smtp-Source: APXvYqzERY5Il5izEpw+YW2XjEZnTeK7zVOC6brycGSRPyTiw4nuCk2qh4+BVP0zby3xESS212f4gdQYyFzUx7lsEQo=
X-Received: by 2002:a24:7f14:: with SMTP id r20mr22717066itc.8.1559702022237;
 Tue, 04 Jun 2019 19:33:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190602094607.41840-1-teawaterz@linux.alibaba.com>
 <20190602094607.41840-2-teawaterz@linux.alibaba.com> <CALvZod7WX0_Eu8eDLSwze=Kf07d6ysAM5DdSqqtkscVikPpSWQ@mail.gmail.com>
In-Reply-To: <CALvZod7WX0_Eu8eDLSwze=Kf07d6ysAM5DdSqqtkscVikPpSWQ@mail.gmail.com>
From: Hui Zhu <teawater@gmail.com>
Date: Wed, 5 Jun 2019 10:33:05 +0800
Message-ID: <CANFwon2-1uhuMKTdHb8F8DpdXsARM8Ng5DkK_Ss_e_TCEx9Q7Q@mail.gmail.com>
Subject: Re: [PATCH V2 2/2] zswap: Add module parameter malloc_movable_if_support
To: Shakeel Butt <shakeelb@google.com>
Cc: Hui Zhu <teawaterz@linux.alibaba.com>, Dan Streetman <ddstreet@ieee.org>, 
	Minchan Kim <minchan@kernel.org>, "ngupta@vflare.org" <ngupta@vflare.org>, 
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Shakeel Butt <shakeelb@google.com> =E4=BA=8E2019=E5=B9=B46=E6=9C=885=E6=97=
=A5=E5=91=A8=E4=B8=89 =E4=B8=8A=E5=8D=881:12=E5=86=99=E9=81=93=EF=BC=9A
>
> On Sun, Jun 2, 2019 at 2:47 AM Hui Zhu <teawaterz@linux.alibaba.com> wrot=
e:
> >
> > This is the second version that was updated according to the comments
> > from Sergey Senozhatsky in https://lkml.org/lkml/2019/5/29/73
> >
> > zswap compresses swap pages into a dynamically allocated RAM-based
> > memory pool.  The memory pool should be zbud, z3fold or zsmalloc.
> > All of them will allocate unmovable pages.  It will increase the
> > number of unmovable page blocks that will bad for anti-fragment.
> >
> > zsmalloc support page migration if request movable page:
> >         handle =3D zs_malloc(zram->mem_pool, comp_len,
> >                 GFP_NOIO | __GFP_HIGHMEM |
> >                 __GFP_MOVABLE);
> >
> > And commit "zpool: Add malloc_support_movable to zpool_driver" add
> > zpool_malloc_support_movable check malloc_support_movable to make
> > sure if a zpool support allocate movable memory.
> >
> > This commit adds module parameter malloc_movable_if_support to enable
> > or disable zpool allocate block with gfp __GFP_HIGHMEM | __GFP_MOVABLE
> > if it support allocate movable memory (disabled by default).
> >
> > Following part is test log in a pc that has 8G memory and 2G swap.
> >
> > When it disabled:
> >  echo lz4 > /sys/module/zswap/parameters/compressor
> >  echo zsmalloc > /sys/module/zswap/parameters/zpool
> >  echo 1 > /sys/module/zswap/parameters/enabled
> >  swapon /swapfile
> >  cd /home/teawater/kernel/vm-scalability/
> > /home/teawater/kernel/vm-scalability# export unit_size=3D$((9 * 1024 * =
1024 * 1024))
> > /home/teawater/kernel/vm-scalability# ./case-anon-w-seq
> > 2717908992 bytes / 3977932 usecs =3D 667233 KB/s
> > 2717908992 bytes / 4160702 usecs =3D 637923 KB/s
> > 2717908992 bytes / 4354611 usecs =3D 609516 KB/s
> > 293359 usecs to free memory
> > 340304 usecs to free memory
> > 205781 usecs to free memory
> > 2717908992 bytes / 5588016 usecs =3D 474982 KB/s
> > 166124 usecs to free memory
> > /home/teawater/kernel/vm-scalability# cat /proc/pagetypeinfo
> > Page block order: 9
> > Pages per block:  512
> >
> > Free pages count per migrate type at order       0      1      2      3=
      4      5      6      7      8      9     10
> > Node    0, zone      DMA, type    Unmovable      1      1      1      0=
      2      1      1      0      1      0      0
> > Node    0, zone      DMA, type      Movable      0      0      0      0=
      0      0      0      0      0      1      3
> > Node    0, zone      DMA, type  Reclaimable      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone      DMA, type   HighAtomic      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone      DMA, type          CMA      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone      DMA, type      Isolate      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone    DMA32, type    Unmovable      5     10      9      8=
      8      5      1      2      3      0      0
> > Node    0, zone    DMA32, type      Movable     15     16     14     12=
     14     10      9      6      6      5    776
> > Node    0, zone    DMA32, type  Reclaimable      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone    DMA32, type   HighAtomic      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone    DMA32, type          CMA      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone    DMA32, type      Isolate      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone   Normal, type    Unmovable   7097   6914   6473   5642=
   4373   2664   1220    319     78      4      0
> > Node    0, zone   Normal, type      Movable   2092   3216   2820   2266=
   1585    946    559    359    237    258    378
> > Node    0, zone   Normal, type  Reclaimable     47     88    122     80=
     34      9      5      4      2      1      2
> > Node    0, zone   Normal, type   HighAtomic      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone   Normal, type          CMA      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone   Normal, type      Isolate      0      0      0      0=
      0      0      0      0      0      0      0
> >
> > Number of blocks type     Unmovable      Movable  Reclaimable   HighAto=
mic          CMA      Isolate
> > Node 0, zone      DMA            1            7            0           =
 0            0            0
> > Node 0, zone    DMA32            4         1652            0           =
 0            0            0
> > Node 0, zone   Normal          834         1572           25           =
 0            0            0
> >
> > When it enabled:
> >  echo lz4 > /sys/module/zswap/parameters/compressor
> >  echo zsmalloc > /sys/module/zswap/parameters/zpool
> >  echo 1 > /sys/module/zswap/parameters/enabled
> >  echo 1 > /sys/module/zswap/parameters/malloc_movable_if_support
> >  swapon /swapfile
> >  cd /home/teawater/kernel/vm-scalability/
> > /home/teawater/kernel/vm-scalability# export unit_size=3D$((9 * 1024 * =
1024 * 1024))
> > /home/teawater/kernel/vm-scalability# ./case-anon-w-seq
> > 2717908992 bytes / 4721401 usecs =3D 562165 KB/s
> > 2717908992 bytes / 4783167 usecs =3D 554905 KB/s
> > 2717908992 bytes / 4802125 usecs =3D 552715 KB/s
> > 2717908992 bytes / 4866579 usecs =3D 545395 KB/s
> > 323605 usecs to free memory
> > 414817 usecs to free memory
> > 458576 usecs to free memory
> > 355827 usecs to free memory
> > /home/teawater/kernel/vm-scalability# cat /proc/pagetypeinfo
> > Page block order: 9
> > Pages per block:  512
> >
> > Free pages count per migrate type at order       0      1      2      3=
      4      5      6      7      8      9     10
> > Node    0, zone      DMA, type    Unmovable      1      1      1      0=
      2      1      1      0      1      0      0
> > Node    0, zone      DMA, type      Movable      0      0      0      0=
      0      0      0      0      0      1      3
> > Node    0, zone      DMA, type  Reclaimable      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone      DMA, type   HighAtomic      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone      DMA, type          CMA      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone      DMA, type      Isolate      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone    DMA32, type    Unmovable      8     10      8      7=
      7      6      5      3      2      0      0
> > Node    0, zone    DMA32, type      Movable     23     21     18     15=
     13     14     14     10     11      6    766
> > Node    0, zone    DMA32, type  Reclaimable      0      0      0      0=
      0      0      0      0      0      0      1
> > Node    0, zone    DMA32, type   HighAtomic      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone    DMA32, type          CMA      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone    DMA32, type      Isolate      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone   Normal, type    Unmovable   2660   1295    460    102=
     11      5      3     11      2      4      0
> > Node    0, zone   Normal, type      Movable   4178   5760   5045   4137=
   3324   2306   1482    930    497    254    460
> > Node    0, zone   Normal, type  Reclaimable     50     83    114     93=
     28     12     10      6      3      3      0
> > Node    0, zone   Normal, type   HighAtomic      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone   Normal, type          CMA      0      0      0      0=
      0      0      0      0      0      0      0
> > Node    0, zone   Normal, type      Isolate      0      0      0      0=
      0      0      0      0      0      0      0
> >
> > Number of blocks type     Unmovable      Movable  Reclaimable   HighAto=
mic          CMA      Isolate
> > Node 0, zone      DMA            1            7            0           =
 0            0            0
> > Node 0, zone    DMA32            4         1650            2           =
 0            0            0
> > Node 0, zone   Normal           81         2325           25           =
 0            0            0
> >
> > You can see that the number of unmovable page blocks is decreased
> > when malloc_movable_if_support is enabled.
> >
> > Signed-off-by: Hui Zhu <teawaterz@linux.alibaba.com>
> > ---
> >  mm/zswap.c | 16 +++++++++++++---
> >  1 file changed, 13 insertions(+), 3 deletions(-)
> >
> > diff --git a/mm/zswap.c b/mm/zswap.c
> > index a4e4d36ec085..2fc45de92383 100644
> > --- a/mm/zswap.c
> > +++ b/mm/zswap.c
> > @@ -123,6 +123,13 @@ static bool zswap_same_filled_pages_enabled =3D tr=
ue;
> >  module_param_named(same_filled_pages_enabled, zswap_same_filled_pages_=
enabled,
> >                    bool, 0644);
> >
> > +/* Enable/disable zpool allocate block with gfp __GFP_HIGHMEM | __GFP_=
MOVABLE
> > + * if it support allocate movable memory (disabled by default).
> > + */
> > +static bool __read_mostly zswap_malloc_movable_if_support;
> > +module_param_cb(malloc_movable_if_support, &param_ops_bool,
> > +               &zswap_malloc_movable_if_support, 0644);
> > +
>
> Any reason for the above tunable? Do we ever want to disable movable
> for zswap+zsmalloc?

Thanks for your remind.  I will post a new version that remove this
module_param later.

Best,
Hui

>
> >  /*********************************
> >  * data structures
> >  **********************************/
> > @@ -1006,6 +1013,7 @@ static int zswap_frontswap_store(unsigned type, p=
goff_t offset,
> >         char *buf;
> >         u8 *src, *dst;
> >         struct zswap_header zhdr =3D { .swpentry =3D swp_entry(type, of=
fset) };
> > +       gfp_t gfp =3D __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_RECLA=
IM;
> >
> >         /* THP isn't supported */
> >         if (PageTransHuge(page)) {
> > @@ -1079,9 +1087,11 @@ static int zswap_frontswap_store(unsigned type, =
pgoff_t offset,
> >
> >         /* store */
> >         hlen =3D zpool_evictable(entry->pool->zpool) ? sizeof(zhdr) : 0=
;
> > -       ret =3D zpool_malloc(entry->pool->zpool, hlen + dlen,
> > -                          __GFP_NORETRY | __GFP_NOWARN | __GFP_KSWAPD_=
RECLAIM,
> > -                          &handle);
> > +       if (zswap_malloc_movable_if_support &&
> > +               zpool_malloc_support_movable(entry->pool->zpool)) {
> > +               gfp |=3D __GFP_HIGHMEM | __GFP_MOVABLE;
> > +       }
> > +       ret =3D zpool_malloc(entry->pool->zpool, hlen + dlen, gfp, &han=
dle);
> >         if (ret =3D=3D -ENOSPC) {
> >                 zswap_reject_compress_poor++;
> >                 goto put_dstmem;
> > --
> > 2.20.1 (Apple Git-117)
> >
>

