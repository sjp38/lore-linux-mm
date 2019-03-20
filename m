Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE7B5C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:12:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C68D2184D
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 06:12:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gU1537TU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C68D2184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EFD346B0003; Wed, 20 Mar 2019 02:12:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EACD36B0007; Wed, 20 Mar 2019 02:12:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D77AD6B0008; Wed, 20 Mar 2019 02:12:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 833286B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:12:02 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d5so469623edl.22
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 23:12:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4pdlG2bv9u4nYOvNAww82/yTZQGVLCVPxU/0vGtTzfY=;
        b=TJYrSHTOiLzOR8CtB1rkECAd6yCjICSbP3kAcNTQ6s942CjManQQB7IDuslawFPLLU
         CE5YB6L5/q2n1M661O+4bm+Hbk3txNs0x/STRtkdaa7InjSHyuo7kHL9Af0BZ4/+MV4t
         RtrjXYy69VMI8B6PqVqSGFEgzseAyNunNnATdwTGLsewTkq1s9OFiPNedJ7m2BSMveOG
         d0EkUIshvgMiR1lrxKgMx66FHuGgfpvjvxO/KAWP4dTNgkvKAfzZaU9/7UxQp1H9M7/8
         g7mtTqTy0mVKHwwzi2MgOTA1NmpM21HHZ6mNHSEcOnNvimGPVwUkC9xnCOWdWSL07BHX
         sHGQ==
X-Gm-Message-State: APjAAAUHxkbk0P/fO2Oi3CjR/yP5MEdAFwa7blO3udELZ5EoNh//FhlC
	RmW6j8a5lJfKsuKKVqdK6uMDCN9QzKVdc9J2HkQLpWLuvTG5Ul0vnnyCYh9B2122+/G8euHEGJ8
	AG6hW4mFoNnRhGCVP2SliGpyDFZDOHa6KO0zb5/Y+3q63tPPm+HCMkVOkMlYj2PLt5w==
X-Received: by 2002:a17:906:7621:: with SMTP id c1mr16329452ejn.47.1553062322070;
        Tue, 19 Mar 2019 23:12:02 -0700 (PDT)
X-Received: by 2002:a17:906:7621:: with SMTP id c1mr16329415ejn.47.1553062320908;
        Tue, 19 Mar 2019 23:12:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553062320; cv=none;
        d=google.com; s=arc-20160816;
        b=xsMPtxJ1+/djajgl9Gze+pgnPrN11JlbOw0kRcmSzQMaN0MglCGIbPb44vC6tzfr0P
         ivT59sXi+0iDo2d/DZuQcyHKGqb3btHVfpg7x9XKMvYAqco6Xc2R7+M5ZuwaZWJhhm6U
         fDiRbRqCr1h2b+vTQTD4YF+x90nJS5ZG/N9GZosxu+vCgwh7mPt5kU7qStPkgS95Oypt
         uvZCpkx1+U6cx25avdbJ69i4qOjP6ZYRCc8oj7j/aQv+yATSqB4ap5oOxppUkZReKrne
         n4gBKzC5lwMPgMWlJcLsBLlVZzO58Q7hdoNf221pvavI4A0/+Z4BFTNRrN68rtAj8Bo/
         xREA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4pdlG2bv9u4nYOvNAww82/yTZQGVLCVPxU/0vGtTzfY=;
        b=iQqKM1CDK0rd+6J5h5NzPLAolEtqmGfupeUj0olYIIAE64dGQcGArgwxSew8wXGeUN
         +WWtCXg0EO70VNQnYyX780p4fiae0ae8R5vothkmtCdo3/tZdh1rUfjYP6f17FX18A22
         ERRaBEdAjYTRHxYpYW6f9NWJQIEF7FpbSeMZ98gadw36LX1eM2BoFA0zdx/GERwEx6u7
         Z9BvRi+psVhWz8fiPS7wgRI0XEl6yQAqHDalBLkVc72VhtHTpFiUUD4n9D9EytIvKtS4
         ytXDN9wFfPrB+RvTZ4BaxycLboPFMie8ONIvFAEshNrspK0CTiHfLSkCQr4LlkogGDBu
         EJ9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gU1537TU;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x18sor243268eji.26.2019.03.19.23.12.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 23:12:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gU1537TU;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4pdlG2bv9u4nYOvNAww82/yTZQGVLCVPxU/0vGtTzfY=;
        b=gU1537TUVu0o6jkweFiV2wl7WckWWr8pX4dWC1xPJY7esUNmzZgZzdQLVjY6C0Ym1X
         PsRi1lQqwkloaITQdnENmfgt9GmqfKRFDczzaeeI8iMXodJ4NTcIngHasnMpa1VBHnQU
         VDwYSCkbIiut4IzAUnQrwa0XwQtI/krkYb65uYcTJRIlQHrc8WBlG7zeThAa1JpZ2Y5X
         ao2DT3HSfD+ExBw9gEPZldC1ZRqwjVAaOQYNQY2UlrYu1D+mhBtuN/WAgg5kV+NZHHYD
         WPRko/Z0qSdPtqzLu0h2P903DRuwoTCBxuxRA8yNagv8B7jzhZGR1veI2GZGW80AMSme
         Np3g==
X-Google-Smtp-Source: APXvYqz4ubpGAUQW5X716FmcRb3LnIsD2xYaEgIzH6WD93F84jZXHe35n3xS1tcNjCPAMDJ7M8Qv3X2wcVNl8mLjy68=
X-Received: by 2002:a17:906:60d7:: with SMTP id f23mr15946849ejk.177.1553062320583;
 Tue, 19 Mar 2019 23:12:00 -0700 (PDT)
MIME-Version: 1.0
References: <1552561599-23662-1-git-send-email-huangzhaoyang@gmail.com> <alpine.DEB.2.21.1903191809420.18028@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1903191809420.18028@chino.kir.corp.google.com>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Wed, 20 Mar 2019 14:11:49 +0800
Message-ID: <CAGWkznH3Be5MSJi7_=Eoauf1=yZHaCTR4HL-gQH7_TORNEtzeQ@mail.gmail.com>
Subject: Re: [PATCH] driver : staging : ion: optimization for decreasing
 memory fragmentaion
To: David Rientjes <rientjes@google.com>
Cc: Chintan Pandya <cpandya@codeaurora.org>, Joe Perches <joe@perches.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 9:10 AM David Rientjes <rientjes@google.com> wrote:
>
> On Thu, 14 Mar 2019, Zhaoyang Huang wrote:
>
> > From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> >
> > Two action for this patch:
> > 1. set a batch size for system heap's shrinker, which can have it buffer
> > reasonable page blocks in pool for future allocation.
> > 2. reverse the order sequence when free page blocks, the purpose is also
> > to have system heap keep as more big blocks as it can.
> >
> > By testing on an android system with 2G RAM, the changes with setting
> > batch = 48MB can help reduce the fragmentation obviously and improve
> > big block allocation speed for 15%.
> >
> > Signed-off-by: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> > ---
> >  drivers/staging/android/ion/ion_heap.c        | 12 +++++++++++-
> >  drivers/staging/android/ion/ion_system_heap.c |  2 +-
> >  2 files changed, 12 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
> > index 31db510..9e9caf2 100644
> > --- a/drivers/staging/android/ion/ion_heap.c
> > +++ b/drivers/staging/android/ion/ion_heap.c
> > @@ -16,6 +16,8 @@
> >  #include <linux/vmalloc.h>
> >  #include "ion.h"
> >
> > +unsigned long ion_heap_batch = 0;
>
> static?
ok
>
> > +
> >  void *ion_heap_map_kernel(struct ion_heap *heap,
> >                         struct ion_buffer *buffer)
> >  {
> > @@ -303,7 +305,15 @@ int ion_heap_init_shrinker(struct ion_heap *heap)
> >       heap->shrinker.count_objects = ion_heap_shrink_count;
> >       heap->shrinker.scan_objects = ion_heap_shrink_scan;
> >       heap->shrinker.seeks = DEFAULT_SEEKS;
> > -     heap->shrinker.batch = 0;
> > +     heap->shrinker.batch = ion_heap_batch;
> >
> >       return register_shrinker(&heap->shrinker);
> >  }
> > +
> > +static int __init ion_system_heap_batch_init(char *arg)
> > +{
> > +      ion_heap_batch = memparse(arg, NULL);
> > +
>
> No bounds checking?  What are the legitimate upper and lower bounds here?
Actruly, ion_heap_batch will work during shrink_slab, which shown bellow.
We can find that it is hard that to set batch_size as a constant value
as total ram size is different to each system. Furthermore, it is also
no need to set a percentage thing, "total_scan >= freeable" will work
as another threshold of slab size.
...
while (total_scan >= batch_size ||
       total_scan >= freeable) {
    unsigned long nr_to_scan = min(batch_size, total_scan);
    ret = shrinker->scan_objects(shrinker, shrinkctl);
...
shrinkctl->nr_to_scan = nr_to_scan;
shrinkctl->nr_scanned = nr_to_scan;
ret = shrinker->scan_objects(shrinker, shrinkctl);
>
> > +     return 0;
> > +}
> > +early_param("ion_batch", ion_system_heap_batch_init);
> > diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
> > index 701eb9f..d249f8d 100644
> > --- a/drivers/staging/android/ion/ion_system_heap.c
> > +++ b/drivers/staging/android/ion/ion_system_heap.c
> > @@ -182,7 +182,7 @@ static int ion_system_heap_shrink(struct ion_heap *heap, gfp_t gfp_mask,
> >       if (!nr_to_scan)
> >               only_scan = 1;
> >
> > -     for (i = 0; i < NUM_ORDERS; i++) {
> > +     for (i = NUM_ORDERS - 1; i >= 0; i--) {
> >               pool = sys_heap->pools[i];
> >
> >               if (only_scan) {
>
> Can we get a Documentation update on how we can use ion_batch and what the
> appropriate settings are (and in what circumstances)?
ok, I will explain it here firstly.
ion_heap_batch will work as the batch_size during shink_slab, which
help the heap buffer some of the page blocks for further allocation.
My test is based on a android system with 2G RAM. We find that
multimedia related cases is the chief consumer of the ion system heap
and cause memory fragmentation after a period of running. By
configuring ion_heap_batch as 48M(3 x camera peak consuming value) and
revert the shrink order, we can almost eliminate such scenario during
the test and improve the allocating speed up to 15%.
For common policy, the batch size should depend on the practical
scenario. The peak value can be got via sysfs or kernel log.

