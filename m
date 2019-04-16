Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F32D8C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:34:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72E5D206BA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 19:34:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MzP4vtEY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72E5D206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A6ED6B0003; Tue, 16 Apr 2019 15:34:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 056D46B0006; Tue, 16 Apr 2019 15:34:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E87746B0007; Tue, 16 Apr 2019 15:34:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id C054D6B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 15:34:04 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id x9so16348291ybj.7
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 12:34:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2pcrWK7hCpkY/y4maWmP20jsXAzKSTIpeBj4ebY6vg8=;
        b=uGPBrDviHo77RZrfYy5si0O1UjmI9Rxc/BuKicjbVytriuP0wcnplHv115Po3g2WIs
         eCwd6N3Zt2nDBFgMt/lzWMEJHuYxeXhZbHZW6eClQa9VVsJyv1dhztdd3OAFv7DOcyYt
         HOqHV6l8h717YeC+o1mBvUxMQJ1xHRRINxmrYH2vEZBGs2/PZV9uEXKEVKXZUWkNEYbO
         P9C5m159Lmvc8u2Hnb2azTJRvdULmH20pprZHKJLXt0xQ7WTIw+8fQdTGefgGWBPJzdo
         NSisIa83iO1gxBRXcZb4MjGQzf0HadQOFHx+2sKmo6hp7QU/HBrOyN0YexekQFzm+sry
         VKcA==
X-Gm-Message-State: APjAAAXVKl43hc7F1uAlnBAORw6eWx8hHAMSypvT5y7CaRQmysRJ0Q6s
	an6TY4bNpzMDouF2DX//5fifIhpmfrQXOKL+s+6gLDBF/d7TmE1tUEBfOfVXJ1aWcHsMlKkE5d/
	gMdS6rFaUgK8gDJj8cNhg+Upvs3Ju/exAzYDubVRiczhGfd94DBf8vQq1Vxi0PZe/kA==
X-Received: by 2002:a81:34c:: with SMTP id 73mr66055664ywd.231.1555443244407;
        Tue, 16 Apr 2019 12:34:04 -0700 (PDT)
X-Received: by 2002:a81:34c:: with SMTP id 73mr66055598ywd.231.1555443243656;
        Tue, 16 Apr 2019 12:34:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555443243; cv=none;
        d=google.com; s=arc-20160816;
        b=EZa14FkJFn4lB7MGFk2Xe5x07J+Vqw2lZMTu6DJg13vqFLkzZHZtJoIJ8iPAYrE9Wg
         /1BP47p2QzTtBUQ0WoJ2+jdfPHV2xtdEcdH2z1AB9HyJjWqmkvqfqQkMlm9L/p+bvOXn
         BSxIhe8lnS/LPtqnKO7qJw8wAwfo3bmVMw1duetItszrtV9WhnuJkVN6jCOzvqLUJoTb
         sML2o/WXsfiBT2fc8SOvWnh/ryeagOpeA4aB60ji9W82dmKzO2WiU4YjI6og+vdtTG4h
         Z9Fc7q/h0g9klgIUxY4xe7lhuhkMbIqSqMtR2/Mp9NN8ac8LeObDN4ULjnoo7vcXwjF4
         aIaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2pcrWK7hCpkY/y4maWmP20jsXAzKSTIpeBj4ebY6vg8=;
        b=sc0kxcBrk1uUdJQp1ovC9yCii+ElbBjn4iW7am4hD6wtipMRalkBi8kZ+oU5IgYFGq
         PNVmn7t0WflkVwS3xm94AORkA9o3KsBzdbWsx/Ukk2IRfMOPhK2jUV4trh972UFtztSW
         EFHQWO9GbFmDeqho5Pi7id/XAQwlGT6RUVnIBMaGNkOwy8OUbvSWLJGlKnbH4LMLal73
         /5kzPw0K++upU/QM7yTK9a/dIzQEZc8l0iD2qzD0kr03XL8MZfkb6rFJAa+kre//owou
         I9CEnogh2ajxL04wZPUrLaAMho1B3sGXzl+go3j0K0dIWSiVBFdAtE/5QoEkG3UuY49i
         ty/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MzP4vtEY;
       spf=pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i203sor19766339ywa.146.2019.04.16.12.34.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 12:34:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MzP4vtEY;
       spf=pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2pcrWK7hCpkY/y4maWmP20jsXAzKSTIpeBj4ebY6vg8=;
        b=MzP4vtEY4aNAYMlO1dqgSCu8GyyvIWJL/MdR0YHpQaZfCAfz6Q8K0BtCBMGIcKAlu/
         haijVwv4XhteRRR+Nc/SUc7SLdmaLxEPfbwF0H2USDIQZ9ZgCzS4NmG3Om9+EduKt9EQ
         M5iL+4p8OubZAnwhnXf9axXFlLTvlc2f8QTUz4sSlunAP2af+iFWvka3s4rJnFvuI8bO
         7CEkS5GwzHLehLh0fGnRuVSBsiZAq0jb+xomqitM8p/9eIz/rCMtQ3oMQqqXZaYGzvyY
         MmjzMvqO0Twb4I3ZBJeLUIQlBtyNVDSQKpy0WwgpkAEvr+fmCYHEP4h4FDcNkJciQMp5
         JmpQ==
X-Google-Smtp-Source: APXvYqxy3IhU/rOjP2fyBjRPZUkaZUbky9eDqfe6MtHtfDwZF6hRPVx7wnGZGKhTXQzlwxe+tVvEAxBZD4iiJfiEfs4=
X-Received: by 2002:a0d:dd4c:: with SMTP id g73mr63071918ywe.145.1555443243096;
 Tue, 16 Apr 2019 12:34:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190215185151.GG7897@sirena.org.uk> <20190226155948.299aa894a5576e61dda3e5aa@linux-foundation.org>
 <CAPcyv4ivjC8fNkfjdFyaYCAjGh7wtvFQnoPpOcR=VNZ=c6d6Rg@mail.gmail.com>
 <20190228151438.fc44921e66f2f5d393c8d7b4@linux-foundation.org>
 <CAPcyv4hDmmK-L=0txw7L9O8YgvAQxZfVFiSoB4LARRnGQ3UC7Q@mail.gmail.com>
 <026b5082-32f2-e813-5396-e4a148c813ea@collabora.com> <20190301124100.62a02e2f622ff6b5f178a7c3@linux-foundation.org>
 <3fafb552-ae75-6f63-453c-0d0e57d818f3@collabora.com> <CAPcyv4hMNiiM11ULjbOnOf=9N=yCABCRsAYLpjXs+98bRoRpCA@mail.gmail.com>
 <36faea07-139c-b97d-3585-f7d6d362abc3@collabora.com> <20190306140529.GG3549@rapoport-lnx>
 <21d138a5-13e4-9e83-d7fe-e0639a8d180a@collabora.com> <CAPcyv4jBjUScKExK09VkL8XKibNcbw11ET4WNUWUWbPXeT9DFQ@mail.gmail.com>
 <CAGXu5jLAPKBE-EdfXkg2AK5P=qZktW6ow4kN5Yzc0WU2rtG8LQ@mail.gmail.com>
 <CABXOdTdVvFn=Nbd_Anhz7zR1H-9QeGByF3HFg4ZFt58R8=H6zA@mail.gmail.com>
 <CAGXu5j+Sw2FyMc8L+8hTpEKbOsySFGrCmFtVP5gt9y2pJhYVUw@mail.gmail.com>
 <CABXOdTcXWf9iReoocaj9rZ7z17zt-62iPDuvQQSrQRtMeeZNiA@mail.gmail.com>
 <CAPcyv4i8xhA6B5e=YBq2Z5kooyUpYZ8Bv9qov-mvqm4Uz=KLWQ@mail.gmail.com>
 <CABXOdTc5=J7ZFgbiwahVind-SNt7+G_-TVO=v-Y5SBVPLdUFog@mail.gmail.com> <CAPcyv4gxk9xbsP3YSKzxu5Yp9FTefyxHc6xC33GwZ3Zf9_eeKA@mail.gmail.com>
In-Reply-To: <CAPcyv4gxk9xbsP3YSKzxu5Yp9FTefyxHc6xC33GwZ3Zf9_eeKA@mail.gmail.com>
From: Guenter Roeck <groeck@google.com>
Date: Tue, 16 Apr 2019 12:33:51 -0700
Message-ID: <CABXOdTd-cqHM_feAO1tvwn4Z=kM6WHKYAbDJ7LGfMvRPRPG7GA@mail.gmail.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Dan Williams <dan.j.williams@intel.com>
Cc: Kees Cook <keescook@chromium.org>, kernelci@groups.io, 
	Guillaume Tucker <guillaume.tucker@collabora.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Mark Brown <broonie@kernel.org>, Tomeu Vizoso <tomeu.vizoso@collabora.com>, 
	Matt Hart <matthew.hart@linaro.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Kevin Hilman <khilman@baylibre.com>, 
	Enric Balletbo i Serra <enric.balletbo@collabora.com>, Nicholas Piggin <npiggin@gmail.com>, 
	Dominik Brodowski <linux@dominikbrodowski.net>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Adrian Reber <adrian@lisas.de>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Linux MM <linux-mm@kvack.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, 
	Richard Guy Briggs <rgb@redhat.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, info@kernelci.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 11:54 AM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Thu, Apr 11, 2019 at 1:54 PM Guenter Roeck <groeck@google.com> wrote:
> [..]
> > > > Boot tests report
> > > >
> > > > Qemu test results:
> > > >     total: 345 pass: 345 fail: 0
> > > >
> > > > This is on top of next-20190410 with CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
> > > > and the known crashes fixed.
> > >
> > > In addition to CONFIG_SHUFFLE_PAGE_ALLOCATOR=y you also need the
> > > kernel command line option "page_alloc.shuffle=1"
> > >
> > > ...so I doubt you are running with shuffling enabled. Another way to
> > > double check is:
> > >
> > >    cat /sys/module/page_alloc/parameters/shuffle
> >
> > Yes, you are right. Because, with it enabled, I see:
> >
> > Kernel command line: rdinit=/sbin/init page_alloc.shuffle=1 panic=-1
> > console=ttyAMA0,115200 page_alloc.shuffle=1
> > ------------[ cut here ]------------
> > WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:303
> > page_alloc_shuffle+0x12c/0x1ac
> > static_key_enable(): static key 'page_alloc_shuffle_key+0x0/0x4' used
> > before call to jump_label_init()
>
> This looks to be specific to ARM never having had to deal with
> DEFINE_STATIC_KEY_TRUE in the past.
>

This affects almost all architectures, not just arm, presumably
because parse_args() is called before jump_label_init() in
start_kernel(). I did not bother to report back with further details
after someone stated that qemu doesn't support omap2, and the context
seemed to suggest that running any other tests would not add any
value.

> I am able to avoid this warning by simply not enabling JUMP_LABEL
> support in my build.
>

Fine with me, as long as CONFIG_SHUFFLE_PAGE_ALLOCATOR=y is not
enabled by default, or if it is made dependent on !JUMP_LABEL.

Guenter

> > Modules linked in:
> > CPU: 0 PID: 0 Comm: swapper Not tainted
> > 5.1.0-rc4-next-20190410-00003-g3367c36ce744 #1
> > Hardware name: ARM Integrator/CP (Device Tree)
> > [<c0011c68>] (unwind_backtrace) from [<c000ec48>] (show_stack+0x10/0x18)
> > [<c000ec48>] (show_stack) from [<c07e9710>] (dump_stack+0x18/0x24)
> > [<c07e9710>] (dump_stack) from [<c001bb1c>] (__warn+0xe0/0x108)
> > [<c001bb1c>] (__warn) from [<c001bb88>] (warn_slowpath_fmt+0x44/0x6c)
> > [<c001bb88>] (warn_slowpath_fmt) from [<c0b0c4a8>]
> > (page_alloc_shuffle+0x12c/0x1ac)
> > [<c0b0c4a8>] (page_alloc_shuffle) from [<c0b0c550>] (shuffle_store+0x28/0x48)
> > [<c0b0c550>] (shuffle_store) from [<c003e6a0>] (parse_args+0x1f4/0x350)
> > [<c003e6a0>] (parse_args) from [<c0ac3c00>] (start_kernel+0x1c0/0x488)
> > [<c0ac3c00>] (start_kernel) from [<00000000>] (  (null))
> >
> > I'll re-run the test, but I suspect it will drown in warnings.
>
> I slogged through getting a Beagle Bone Black up and running with a
> Yocto build and it is not failing. I have tried apply the patches on
> top of v5.1-rc5 as well as re-testing next-20190215 label, no
> reproduction. The shuffle appears to avoid anything sensitive by
> default, below are the shuffle actions that were taken relative to
> iomem. Can someone with a failure reproduction please send me more
> details about their configuration? It would also help to get a failing
> boot log with the pr_debug() statements in mm/shuffle.c enabled to see
> if the failure is correlated with any unexpected shuffle actions.
>
> 80000000-9fffffff : System RAM
>   80008000-809fffff : Kernel code
>   80b00000-812be523 : Kernel data
>
> [    0.086469] __shuffle_zone: swap: 0x81800 -> 0x99800
> [    0.086558] __shuffle_zone: swap: 0x82000 -> 0x88800
> [    0.086575] __shuffle_zone: swap: 0x82800 -> 0x89800
> [    0.086591] __shuffle_zone: swap: 0x83000 -> 0x89000
> [    0.086606] __shuffle_zone: swap: 0x83800 -> 0x8a800
> [    0.086621] __shuffle_zone: swap: 0x84000 -> 0x93800
> [    0.086636] __shuffle_zone: swap: 0x84800 -> 0x83000
> [    0.086651] __shuffle_zone: swap: 0x85000 -> 0x8f000
> [    0.086666] __shuffle_zone: swap: 0x85800 -> 0x88000
> [    0.086689] __shuffle_zone: swap: 0x86000 -> 0x84000
> [    0.086704] __shuffle_zone: swap: 0x86800 -> 0x8c800
> [    0.086719] __shuffle_zone: swap: 0x87000 -> 0x93000
> [    0.086735] __shuffle_zone: swap: 0x87800 -> 0x94000
> [    0.086751] __shuffle_zone: swap: 0x88000 -> 0x90800
> [    0.086766] __shuffle_zone: swap: 0x88800 -> 0x9d000
> [    0.086781] __shuffle_zone: swap: 0x89000 -> 0x82800
> [    0.086796] __shuffle_zone: swap: 0x89800 -> 0x95800
> [    0.086811] __shuffle_zone: swap: 0x8a000 -> 0x98000
> [    0.086826] __shuffle_zone: swap: 0x8a800 -> 0x89000
> [    0.086842] __shuffle_zone: swap: 0x8b000 -> 0x81800
> [    0.086857] __shuffle_zone: swap: 0x8b800 -> 0x88800
> [    0.086872] __shuffle_zone: swap: 0x8c000 -> 0x8a000
> [    0.086891] __shuffle_zone: swap: 0x8c800 -> 0x84800
> [    0.086906] __shuffle_zone: swap: 0x8d000 -> 0x95000
> [    0.086921] __shuffle_zone: swap: 0x8d800 -> 0x8d000
> [    0.086935] __shuffle_zone: swap: 0x8e000 -> 0x8e800
> [    0.086950] __shuffle_zone: swap: 0x8e800 -> 0x99000
> [    0.086964] __shuffle_zone: swap: 0x8f000 -> 0x8d000
> [    0.086979] __shuffle_zone: swap: 0x90000 -> 0x91000
> [    0.086994] __shuffle_zone: swap: 0x90800 -> 0x83000
> [    0.087009] __shuffle_zone: swap: 0x91000 -> 0x91800
> [    0.087025] __shuffle_zone: swap: 0x91800 -> 0x8d800
> [    0.087040] __shuffle_zone: swap: 0x92000 -> 0x86800
> [    0.087054] __shuffle_zone: swap: 0x92800 -> 0x92000
> [    0.087070] __shuffle_zone: swap: 0x93000 -> 0x91000
> [    0.087088] __shuffle_zone: swap: 0x93800 -> 0x85000
> [    0.087103] __shuffle_zone: swap: 0x94000 -> 0x8b800
> [    0.087117] __shuffle_zone: swap: 0x94800 -> 0x96000
> [    0.087132] __shuffle_zone: swap: 0x95000 -> 0x91000
> [    0.087147] __shuffle_zone: swap: 0x95800 -> 0x8e000
> [    0.087161] __shuffle_zone: swap: 0x96000 -> 0x95800
> [    0.087179] __shuffle_zone: swap: 0x96800 -> 0x8c800
> [    0.087193] __shuffle_zone: swap: 0x97000 -> 0x89000
> [    0.087208] __shuffle_zone: swap: 0x97800 -> 0x85000
> [    0.087224] __shuffle_zone: swap: 0x98000 -> 0x85000
> [    0.087239] __shuffle_zone: swap: 0x98800 -> 0x93000
> [    0.087255] __shuffle_zone: swap: 0x99000 -> 0x94800
> [    0.087269] __shuffle_zone: swap: 0x99800 -> 0x94000

