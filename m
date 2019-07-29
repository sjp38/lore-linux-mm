Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC3C9C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 10:28:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8ABA2206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 10:28:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Im51TH56"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ABA2206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18F6D8E0003; Mon, 29 Jul 2019 06:28:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11B6F8E0002; Mon, 29 Jul 2019 06:28:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F25B88E0003; Mon, 29 Jul 2019 06:28:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id D0F008E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 06:28:39 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id v3so67124114ios.4
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 03:28:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3itDB/HMkkFV+oaY7RHK7Sdf6jogzMFoz/vY9dJmj0k=;
        b=SWBJr5laCKAeYOV4aqC0PcoJFcNgzc6qUC907/kQGsaiBjBx6ju5NuOnWOfDZy0Pat
         oTv1r0YkSkMZBAV3+E3qi0NCEnfRsroUjkyKt4EuNKZ/EgCJM9AMCOOdAdUEGmAY9fcn
         3BSQ+1zIdzdBI96OAY0i5ltVPDjn/PX2YpV9x8L2thFGyXPCxvpfv4l7y9k7krZou5hi
         2p5D0ZT/tXtvXmvrXPvPxhVeDY0WGyRyPxvdskpXswkwViTDy1X/YTN6+Y7ABQiCeKG8
         NVn6u5IUuvE4mwlqUMzUGn2I5zzESrs+RKUq38zBtvvVg6G5dRK9Oa3qhqdNSvQhzm5p
         lWWw==
X-Gm-Message-State: APjAAAXzaB+WrFekMURKEVSm5Erm3qwzha/AD5SD21NeSv1s7f0WXd++
	PvOgk8grrkzhfQ6wiXJl85VQJSfS/IsIGBeJwLRDMqQYCrVhq7SQXIwnqPlB3R4QtGcLneNgbu2
	mAJ5NHfse+8dL9GMrj5Dx0Ij1GoRcHnpFBUBZiKzOUs8SR3L1hNkr8nxYjRLMj+eriQ==
X-Received: by 2002:a6b:ee15:: with SMTP id i21mr1479791ioh.281.1564396119559;
        Mon, 29 Jul 2019 03:28:39 -0700 (PDT)
X-Received: by 2002:a6b:ee15:: with SMTP id i21mr1479745ioh.281.1564396118793;
        Mon, 29 Jul 2019 03:28:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564396118; cv=none;
        d=google.com; s=arc-20160816;
        b=0aIlVDOs1zGNXc8WIxFFuPtR0HjcRMeso3n+NE6vECuokBzVVcROLwDUeyNFmCY0FB
         un3QXbFWl4qzfu6P2iMt/3Iqb+MJ4Q6Pje7VVg65GFCJZ8elMt9W9ZL+alppNLuUpqco
         QubfPdLyoh2OaKMw/rpQ7122u2c9AqvD6td4KxnzkO9P7N8GSAui/XhHyjN5Y/rB/EJG
         y12MeISdaeGDAVfiVK2fk6xL9+S6vTRX2nyOZTNsnZMRYwjMQnjvt2H8C6Wjas39+ycu
         +eX9y3ZWQr+fAGlAm+es8RUsS4ChCP3LwsA/28EwBTs4lmwssRZiFkKXrEIXZ3xGo/TN
         3SLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3itDB/HMkkFV+oaY7RHK7Sdf6jogzMFoz/vY9dJmj0k=;
        b=wdrtdvitPJhFsyuWNxcZ5YuGpWNwVuCMlbAiJzsUsxh1io7YpT8lF8+vOydkX0wQ3I
         DQQPAheyUXpeEHS0Z3VkJ1+DaVLwyrNSTrmrfLY+ItcrI2tBZu3ULrjRp7KTYnuWRY/B
         N5D1DKaj5BfvRIVqGRdlfwrP5Wmmw1ozAapIA7CrpCH8oI0flWdHkPuVT0Iub0FAoK56
         +GToOXLEjp/ms8QesZOP+iJw91wux2KH081gbAbcoQ3ZntSoxNiJk0tVVIoKxy2xFpxn
         cwBKCFhp0a5HLPpGmNj0L6zx2Rm7WVt8BQySJV4Xn4uVePeTbiICGrs2ZNHty0MCkEgE
         Mi5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Im51TH56;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r11sor40720139ioh.122.2019.07.29.03.28.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 03:28:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Im51TH56;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3itDB/HMkkFV+oaY7RHK7Sdf6jogzMFoz/vY9dJmj0k=;
        b=Im51TH56n54KvWyYxvDrvWK4co+NRRCLM1n8PpJKvTbhIMuazfmPeLXTGRK1LHGFvo
         tzdNuJwBO0S3rJZoKaw331bx+ruek+6GDvHOmJCshMCHsThGNhmWIM3u7Cpps5R8aBiq
         qBD6V3AjReB0LlM7zbIPf2Gsuy8eroPuiA/pt8Yg7tl1W37u4EgsHL//trwlxzE+5wY/
         Nol2buHtyvKzr+TNncgYBndpCehFk32raYmbOJesvJJv/POy2VsVJr7YBOuWDfm5+8oS
         Mk6oWMr1/7KnFw7SG3nqGdVK2ZBv4GicCEzOy2gUhGIkFIWKeAZprUldcPW15yqN3sLC
         pb3A==
X-Google-Smtp-Source: APXvYqwvdKfdOU/Puij/ewHHIjRLANHiRnK0wNbl587o8cYzRBguTmd3pQ1xEOH6/4iciXEf7xUAeLY/+Nsji7D0F6k=
X-Received: by 2002:a6b:4101:: with SMTP id n1mr74832605ioa.138.1564396117841;
 Mon, 29 Jul 2019 03:28:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190725055503.19507-1-dja@axtens.net> <20190725055503.19507-2-dja@axtens.net>
 <CACT4Y+Yw74otyk9gASfUyAW_bbOr8H5Cjk__F7iptrxRWmS9=A@mail.gmail.com> <87blxdgn9k.fsf@dja-thinkpad.axtens.net>
In-Reply-To: <87blxdgn9k.fsf@dja-thinkpad.axtens.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 29 Jul 2019 12:28:26 +0200
Message-ID: <CACT4Y+YSNdQdUbQS4K8NxuQf7AmbK1SXx0ZdLtM3cfcY6Dpv2A@mail.gmail.com>
Subject: Re: [PATCH 1/3] kasan: support backing vmalloc space with real shadow memory
To: Daniel Axtens <dja@axtens.net>
Cc: kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 12:15 PM Daniel Axtens <dja@axtens.net> wrote:
>
> Hi Dmitry,
>
> Thanks for the feedback!
>
> >> +       addr = shadow_alloc_start;
> >> +       do {
> >> +               pgdp = pgd_offset_k(addr);
> >> +               p4dp = p4d_alloc(&init_mm, pgdp, addr);
> >
> > Page table allocations will be protected by mm->page_table_lock, right?
>
> Yes, each of those alloc functions take the lock if they end up in the
> slow-path that does the actual allocation (e.g. __p4d_alloc()).
>
> >> +               pudp = pud_alloc(&init_mm, p4dp, addr);
> >> +               pmdp = pmd_alloc(&init_mm, pudp, addr);
> >> +               ptep = pte_alloc_kernel(pmdp, addr);
> >> +
> >> +               /*
> >> +                * we can validly get here if pte is not none: it means we
> >> +                * allocated this page earlier to use part of it for another
> >> +                * allocation
> >> +                */
> >> +               if (pte_none(*ptep)) {
> >> +                       backing = __get_free_page(GFP_KERNEL);
> >> +                       backing_pte = pfn_pte(PFN_DOWN(__pa(backing)),
> >> +                                             PAGE_KERNEL);
> >> +                       set_pte_at(&init_mm, addr, ptep, backing_pte);
> >> +               }
> >> +       } while (addr += PAGE_SIZE, addr != shadow_alloc_end);
> >> +
> >> +       requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
> >> +       kasan_unpoison_shadow(area->addr, requested_size);
> >> +       kasan_poison_shadow(area->addr + requested_size,
> >> +                           area->size - requested_size,
> >> +                           KASAN_VMALLOC_INVALID);
> >
> >
> > Do I read this correctly that if kernel code does vmalloc(64), they
> > will have exactly 64 bytes available rather than full page? To make
> > sure: vmalloc does not guarantee that the available size is rounded up
> > to page size? I suspect we will see a throw out of new bugs related to
> > OOBs on vmalloc memory. So I want to make sure that these will be
> > indeed bugs that we agree need to be fixed.
> > I am sure there will be bugs where the size is controlled by
> > user-space, so these are bad bugs under any circumstances. But there
> > will also probably be OOBs, where people will try to "prove" that
> > that's fine and will work (just based on our previous experiences :)).
>
> So the implementation of vmalloc will always round it up. The
> description of the function reads, in part:
>
>  * Allocate enough pages to cover @size from the page level
>  * allocator and map them into contiguous kernel virtual space.
>
> So in short it's not quite clear - you could argue that you have a
> guarantee that you get full pages, but you could also argue that you've
> specifically asked for @size bytes and @size bytes only.
>
> So far it seems that users are well behaved in terms of using the amount
> of memory they ask for, but you'll get a better idea than me very
> quickly as I only tested with trinity. :)

Ack.
Let's try and see then. There is always an easy fix -- round up size
explicitly before vmalloc, which will make the code more explicit and
clear. I can hardly see any potential downsides for rounding up the
size explicitly.

> I also handle vmap - for vmap there's no way to specify sub-page
> allocations so you get as many pages as you ask for.
>
> > On impl side: kasan_unpoison_shadow seems to be capable of handling
> > non-KASAN_SHADOW_SCALE_SIZE-aligned sizes exactly in the way we want.
> > So I think it's better to do:
> >
> >        kasan_unpoison_shadow(area->addr, requested_size);
> >        requested_size = round_up(requested_size, KASAN_SHADOW_SCALE_SIZE);
> >        kasan_poison_shadow(area->addr + requested_size,
> >                            area->size - requested_size,
> >                            KASAN_VMALLOC_INVALID);
>
> Will do for v2.
>
> Regards,
> Daniel
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/87blxdgn9k.fsf%40dja-thinkpad.axtens.net.

