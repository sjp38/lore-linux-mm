Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58D3CC31E57
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 11:58:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DF7B2084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 11:58:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="m/nic/1g"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DF7B2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 991EB8E0003; Mon, 17 Jun 2019 07:58:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 942618E0001; Mon, 17 Jun 2019 07:58:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8310F8E0003; Mon, 17 Jun 2019 07:58:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6398B8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:58:10 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id z19so11913333ioi.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 04:58:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ueOYS1wFyeCCBxDCVsPVG5+an3vWjzFueCDlI0BJDTQ=;
        b=TChSmxP7VGsqDsFZFAXQrO0npA3GUbzOyzPk8v/E218XFeH7EWsDuzZ8e7aVcr9rgm
         1jmnh5UzwU/lLseP2N8Ou65KsJBZnwEyydV3p3yjQQ0JoyomUaF/FTCdpBSwyx9V6D1t
         YHGMR7eJP2TjI3Y1ARqHij8XDNffR3oLXYY+HK0esmpnUxZm3D08hQIrc41VU/Jy3dnK
         Zm6BqaXF3Zn8S0sKt6gAEVi2+cJkbIX2Z6yNwNRbadhCeiYF1Kdc1E4Z/v1n+XrOS7oJ
         mXNjxCeIam6o5WF9FuJYCJ0pnsqCyBl4d6p56RUJk3o8OYlbp9NyFVeA7T2O8h/UMoZY
         dyGA==
X-Gm-Message-State: APjAAAWk2+cLyuhGSL/ryqLlJaOfkLaHHGqIoJ8/MiRpDYcP/rjb84Lh
	u7LGZJH4GCYkRiwBTxGOLsaPoAuKyogSobciCyRcm5wS4WJiZvzBghaLNr21oOf9AFcI3NQI66o
	/NYTzYbg0ilentRbNm8ug/OBUCdCZALqayE+3vD/0X6mtv52PF3gDuZzCyHJcRA4j9A==
X-Received: by 2002:a6b:6b14:: with SMTP id g20mr1033944ioc.28.1560772690101;
        Mon, 17 Jun 2019 04:58:10 -0700 (PDT)
X-Received: by 2002:a6b:6b14:: with SMTP id g20mr1033893ioc.28.1560772689300;
        Mon, 17 Jun 2019 04:58:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560772689; cv=none;
        d=google.com; s=arc-20160816;
        b=xB+/+OH+alMX7VnVVnPF1wAtejZOVesQZZNITohdKngwSpc+T6Af5LRYU/6k92tOXn
         MeF/GdHpLZu1z9lY/MnbgdgKfvqPGLp9n7ZuIfrBCC0Ai7pgBqXCMcrjm6zNSjWytrN7
         mf/Odmnrr6OyN3PrGEyR9Tjf+1k8+avioiyLN1eRFvxnF2LnX83Biq9GNAT8b1ugYyqp
         NREvUeK8CooAN5xjyEBr0rY5gVMl07zKjvIevjHi29602TQ5pAMp6IDxVmxbcOMUo/LZ
         t9WeOoEavqmCcuWJlbBoi1xKquyYheckQ/6SRKHmcQ7ChEUbPnSfKZOqbZadQwq70v1+
         yDSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ueOYS1wFyeCCBxDCVsPVG5+an3vWjzFueCDlI0BJDTQ=;
        b=qmKCCZ4lyWg6iAHH/54ZMfd+zo7+bQWwDor87CpYTHUXXWyms4iWT7yiEfQsSVSRfK
         E9/eBEf0GXhrhFfChvrhjKunXiMo7mW/Kq9/MbwB7FF9tLMAb77GgrhgtqhpajPW7yVz
         vhvh6/ps8IOPUZaeD96zHhdplyYHmdQfebLylSOI0aZT2HsjIdTbUUBBpO/Ox8x+PQ2Z
         hjKQfUdgFZSZCkvHhNbGNcQ/uXEa27kqPmUGrGQwg6vHbjuTZW3CnfQV+Qx1v1Z2fzmy
         W0y5Mwcq7XYweF2VeXrNNKAtgvdhmDN14Yh2vynjWkrt9FjvHAuvSLwin9FynNnP+FcL
         ziPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="m/nic/1g";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9sor8446704ios.17.2019.06.17.04.58.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 04:58:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="m/nic/1g";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ueOYS1wFyeCCBxDCVsPVG5+an3vWjzFueCDlI0BJDTQ=;
        b=m/nic/1gMsqRM3aXpp3S0P7cl9f86+N1HuW0xsCIUi26svfLi1qjvD8/zHDJfv4CtC
         agTG9FTFwES2e6fKPNgesel4PIaXyheHVvmzttqU9n3CyDEI5yYSs0KzLEhRXDmkIDiU
         BoHvb5PH7lF6fHNpMMcZCbfokLgEMLHe9fSGVjgWlkE+tshkqtTNJW8XqsM7EiTbmZYV
         zY9Uiv1rua98ZWBS7vxyFk1D1Qek2WDw0hPW2R1nacVvqRmslLdyg7GzuKjnyjdUSKAy
         n8cKtLfeAZ7oUirrutBaSPmjmPh9zhy8sGDCjUK9FZlC0Yr3nw5q6M2O+M/R+2cooSGO
         gHDQ==
X-Google-Smtp-Source: APXvYqyOINj8pYwe8/fYWKy7ldMuXS6N4CTb8JVK/ENXznnn8FSbnUbfvDwebsRKohu4YhwgVY4D0h3ZXjEurUCWfuY=
X-Received: by 2002:a6b:fb0f:: with SMTP id h15mr2795600iog.266.1560772688590;
 Mon, 17 Jun 2019 04:58:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190613081357.1360-1-walter-zh.wu@mediatek.com>
 <da7591c9-660d-d380-d59e-6d70b39eaa6b@virtuozzo.com> <1560447999.15814.15.camel@mtksdccf07>
 <1560479520.15814.34.camel@mtksdccf07> <1560744017.15814.49.camel@mtksdccf07>
In-Reply-To: <1560744017.15814.49.camel@mtksdccf07>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 17 Jun 2019 13:57:57 +0200
Message-ID: <CACT4Y+Y3uS59rXf92ByQuFK_G4v0H8NNnCY1tCbr4V+PaZF3ag@mail.gmail.com>
Subject: Re: [PATCH v3] kasan: add memory corruption identification for
 software tag-based mode
To: Walter Wu <walter-zh.wu@mediatek.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Arnd Bergmann <arnd@arndb.de>, 
	Vasily Gorbik <gor@linux.ibm.com>, Andrey Konovalov <andreyknvl@google.com>, 
	"Jason A . Donenfeld" <Jason@zx2c4.com>, Miles Chen <miles.chen@mediatek.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	linux-mediatek@lists.infradead.org, wsd_upstream <wsd_upstream@mediatek.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 6:00 AM Walter Wu <walter-zh.wu@mediatek.com> wrote:
>
> On Fri, 2019-06-14 at 10:32 +0800, Walter Wu wrote:
> > On Fri, 2019-06-14 at 01:46 +0800, Walter Wu wrote:
> > > On Thu, 2019-06-13 at 15:27 +0300, Andrey Ryabinin wrote:
> > > >
> > > > On 6/13/19 11:13 AM, Walter Wu wrote:
> > > > > This patch adds memory corruption identification at bug report for
> > > > > software tag-based mode, the report show whether it is "use-after-free"
> > > > > or "out-of-bound" error instead of "invalid-access" error.This will make
> > > > > it easier for programmers to see the memory corruption problem.
> > > > >
> > > > > Now we extend the quarantine to support both generic and tag-based kasan.
> > > > > For tag-based kasan, the quarantine stores only freed object information
> > > > > to check if an object is freed recently. When tag-based kasan reports an
> > > > > error, we can check if the tagged addr is in the quarantine and make a
> > > > > good guess if the object is more like "use-after-free" or "out-of-bound".
> > > > >
> > > >
> > > >
> > > > We already have all the information and don't need the quarantine to make such guess.
> > > > Basically if shadow of the first byte of object has the same tag as tag in pointer than it's out-of-bounds,
> > > > otherwise it's use-after-free.
> > > >
> > > > In pseudo-code it's something like this:
> > > >
> > > > u8 object_tag = *(u8 *)kasan_mem_to_shadow(nearest_object(cacche, page, access_addr));
> > > >
> > > > if (access_addr_tag == object_tag && object_tag != KASAN_TAG_INVALID)
> > > >   // out-of-bounds
> > > > else
> > > >   // use-after-free
> > >
> > > Thanks your explanation.
> > > I see, we can use it to decide corruption type.
> > > But some use-after-free issues, it may not have accurate free-backtrace.
> > > Unfortunately in that situation, free-backtrace is the most important.
> > > please see below example
> > >
> > > In generic KASAN, it gets accurate free-backrace(ptr1).
> > > In tag-based KASAN, it gets wrong free-backtrace(ptr2). It will make
> > > programmer misjudge, so they may not believe tag-based KASAN.
> > > So We provide this patch, we hope tag-based KASAN bug report is the same
> > > accurate with generic KASAN.
> > >
> > > ---
> > >     ptr1 = kmalloc(size, GFP_KERNEL);
> > >     ptr1_free(ptr1);
> > >
> > >     ptr2 = kmalloc(size, GFP_KERNEL);
> > >     ptr2_free(ptr2);
> > >
> > >     ptr1[size] = 'x';  //corruption here
> > >
> > >
> > > static noinline void ptr1_free(char* ptr)
> > > {
> > >     kfree(ptr);
> > > }
> > > static noinline void ptr2_free(char* ptr)
> > > {
> > >     kfree(ptr);
> > > }
> > > ---
> > >
> > We think of another question about deciding by that shadow of the first
> > byte.
> > In tag-based KASAN, it is immediately released after calling kfree(), so
> > the slub is easy to be used by another pointer, then it will change
> > shadow memory to the tag of new pointer, it will not be the
> > KASAN_TAG_INVALID, so there are many false negative cases, especially in
> > small size allocation.
> >
> > Our patch is to solve those problems. so please consider it, thanks.
> >
> Hi, Andrey and Dmitry,
>
> I am sorry to bother you.
> Would you tell me what you think about this patch?
> We want to use tag-based KASAN, so we hope its bug report is clear and
> correct as generic KASAN.
>
> Thanks your review.
> Walter

Hi Walter,

I will probably be busy till the next week. Sorry for delays.

