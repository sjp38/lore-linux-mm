Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E07BEC04AAB
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 13:50:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95D2920675
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 13:50:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DRQ6yKsX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95D2920675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 304C76B0005; Mon,  6 May 2019 09:50:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B7556B0006; Mon,  6 May 2019 09:50:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A4466B0007; Mon,  6 May 2019 09:50:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D975F6B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 09:50:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l16so2993186pfb.23
        for <linux-mm@kvack.org>; Mon, 06 May 2019 06:50:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bQJbdD3DpYVGAJMB4xHT/wsaNr2EFZ6QKX73vdaXiy8=;
        b=SajkXIe3vEUkeMompqdunN+Gev+Z5taKgp+zEOZMVg2BJDC79AguUq89fwsCFkaZJP
         FWP0cK8kjGEGo/gfc5TzWecyJ0rLOAT/gFoADeloMtK0+mST9GQY4g4xPn4mm4mm7rW8
         eqad3ozQUCf8cwhDWnZXKGkDyaYMJG+l5v0/7Vaf1COGZzsZaSOdJ5n/U020bXEmEH25
         MKNo5mpTJ1B2aT61f7yqJ3MGL2K8LoFLxSpehPCvdi7gOxLkhWx1RfpEPNyHYCleEdwo
         FMAoW35CHI1i/BAmTuQICI+FqTEo7bM5GTInB3WqpOH+CV07vmLAXM7j9L3LIYvx1OYF
         9qqA==
X-Gm-Message-State: APjAAAX6jZghbeyyPce1Hhd8esfZwqDsyxPycNNTxFbOXMt6SOGfJNQ6
	ZD1vYAhZ9048Pzwo9JvNvB7gO2QTYoOPZrLUSSrMS0DLkZSQYAD0CcWeBW9VRPy5pfYMj0zp11g
	KvY4e/yUQgwpJsUOfcxbtSprtzQviBG8fuVPFt9Pbl6oE0oxRF7Sqn2pvgz7GsK5LTQ==
X-Received: by 2002:a17:902:768c:: with SMTP id m12mr20810241pll.82.1557150638397;
        Mon, 06 May 2019 06:50:38 -0700 (PDT)
X-Received: by 2002:a17:902:768c:: with SMTP id m12mr20810142pll.82.1557150637562;
        Mon, 06 May 2019 06:50:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557150637; cv=none;
        d=google.com; s=arc-20160816;
        b=qGi7ctiqJQrv8jBpPo47tQiCFE0sd9i/nLhHmdWjS4Z3wvxT7pcMmiAVX63TyIGifK
         ggiGycFbaJV1lnnl0v16jxKxE0zIDZjLeDHX1+Zig/7xm8G+zWrIE42EODfTK/BWkN/S
         s3tDrCUIBc6sppa1NCQyL3sCyzLMeR+R7kQStrYa2wO1rQ4h892wR8u0P0JlBYgJHVpn
         VlHmsD20YiXIF4SUOrPx5GHVgWqR/9eFtcYasQHs/akYWY1jMjLPkPjTOMLkqFveci2s
         hx/gKLGtw2OJ/JEuSUjtS5XBwClA/QK6LI5/QS7eB24XwGcTBOapyB6TES0vbGIXnKux
         DAzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bQJbdD3DpYVGAJMB4xHT/wsaNr2EFZ6QKX73vdaXiy8=;
        b=ac7YP2aH3r3FFQbZGXC9lsawXEwFj6m9ILckwS6tfIx+ZK8itM4ZlGmXXLDJCkeVsr
         aO9hLx3PBefp2zWypblMUf9PftBg74XmKdsXYWlwxH+TJTJ+I6/XBGDJCv1RoGK0ZDMQ
         FE3ee+RZwdbr0lNGUaJceOAvn5UsiNaqwDvVH+ZBvfvephzG9e5WZeLxbVifjuidnRuQ
         xEdQ24ouKBGqvN5EGD6G/gyd2xOwoJesTCs3yjI9tmWp23We/R+ew/CSh/OQvWHpa3nB
         RWHf4Of9vQIJRz6/mzArmlLQgkPY2KRPYvfhS3F/FdXcsAj9KBWc8l4/zH7lyuqDBKuy
         A0lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DRQ6yKsX;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b39sor12077251pla.41.2019.05.06.06.50.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 06:50:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DRQ6yKsX;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bQJbdD3DpYVGAJMB4xHT/wsaNr2EFZ6QKX73vdaXiy8=;
        b=DRQ6yKsX6G++7lU4Zg5s3BYR0P9dOtDVRdgDq4OTKtqnFzdHr5mrU+eAH8m/xaAqq9
         GjaGvUS7mkeRr5xpwetie72lE61cQQyZApscmN4YS70y1VIT4NWv/M48lKerfm627Th7
         gjcuK1BYAbSf4nXxfiio5m7d5spLpXCCTDKGcC2aVAdeBFYRKrP8Z7bE2tG9DZ2rIsGu
         CwljSWmdU9qHLtd/Gz+syQE0KKMpSKrEQoJTqd9Mdkk5tKa5G5tK8eI5XA5KcbzqPu4t
         Lq4Z4U34+8CqteCsW5OMIEDaAHJ5orfzvcPcniCK32BPqiOxrEh1Ln7swqpgKcat4g3N
         37Bg==
X-Google-Smtp-Source: APXvYqwbKSvVTOpuC9GERGa4zYi/56mC1YqRSuljrXhiTGgFzKxKxPy7xquJMcd52Z/Xw9GWuZtYyS77z4awlmXBnWo=
X-Received: by 2002:a17:902:7783:: with SMTP id o3mr32208910pll.159.1557150636780;
 Mon, 06 May 2019 06:50:36 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com> <2e827b5c484be14044933049fec180cd6acb054b.1556630205.git.andreyknvl@google.com>
 <3108d33e-8e18-a73e-5e1a-f0db64f02ab3@amd.com>
In-Reply-To: <3108d33e-8e18-a73e-5e1a-f0db64f02ab3@amd.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 6 May 2019 15:50:25 +0200
Message-ID: <CAAeHK+zDScw-aYpQFVG=JKartDqCF+ZWnq3-6PuaYgMiBphcJA@mail.gmail.com>
Subject: Re: [PATCH v14 11/17] drm/amdgpu, arm64: untag user pointers
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, 
	"linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, 
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, 
	"Koenig, Christian" <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 8:03 PM Kuehling, Felix <Felix.Kuehling@amd.com> wrote:
>
> On 2019-04-30 9:25 a.m., Andrey Konovalov wrote:
> > [CAUTION: External Email]
> >
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > amdgpu_ttm_tt_get_user_pages() uses provided user pointers for vma
> > lookups, which can only by done with untagged pointers. This patch
> > untag user pointers when they are being set in
> > amdgpu_ttm_tt_set_userptr().
> >
> > In amdgpu_gem_userptr_ioctl() and amdgpu_amdkfd_gpuvm.c/init_user_pages()
> > an MMU notifier is set up with a (tagged) userspace pointer. The untagged
> > address should be used so that MMU notifiers for the untagged address get
> > correctly matched up with the right BO. This patch untag user pointers in
> > amdgpu_gem_userptr_ioctl() for the GEM case and in
> > amdgpu_amdkfd_gpuvm_alloc_memory_of_gpu() for the KFD case.
> >
> > Suggested-by: Kuehling, Felix <Felix.Kuehling@amd.com>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >   drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c | 2 +-
> >   drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          | 2 ++
> >   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c          | 2 +-
> >   3 files changed, 4 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
> > index 1921dec3df7a..20cac44ed449 100644
> > --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
> > +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
> > @@ -1121,7 +1121,7 @@ int amdgpu_amdkfd_gpuvm_alloc_memory_of_gpu(
> >                  alloc_flags = 0;
> >                  if (!offset || !*offset)
> >                          return -EINVAL;
> > -               user_addr = *offset;
> > +               user_addr = untagged_addr(*offset);
> >          } else if (flags & ALLOC_MEM_FLAGS_DOORBELL) {
> >                  domain = AMDGPU_GEM_DOMAIN_GTT;
> >                  alloc_domain = AMDGPU_GEM_DOMAIN_CPU;
> > diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
> > index d21dd2f369da..985cb82b2aa6 100644
> > --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
> > +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
> > @@ -286,6 +286,8 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
> >          uint32_t handle;
> >          int r;
> >
> > +       args->addr = untagged_addr(args->addr);
> > +
> >          if (offset_in_page(args->addr | args->size))
> >                  return -EINVAL;
> >
> > diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> > index 73e71e61dc99..1d30e97ac2c4 100644
> > --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> > +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> > @@ -1248,7 +1248,7 @@ int amdgpu_ttm_tt_set_userptr(struct ttm_tt *ttm, uint64_t addr,
> >          if (gtt == NULL)
> >                  return -EINVAL;
> >
> > -       gtt->userptr = addr;
> > +       gtt->userptr = untagged_addr(addr);
>
> Doing this here seems unnecessary. You already untagged the address in
> both callers of this function. Untagging in the two callers ensures that
> the userptr and MMU notifier are in sync, using the same untagged
> address. Doing it again here is redundant.

 Will fix in v15, thanks!

>
> Regards,
>    Felix
>
>
> >          gtt->userflags = flags;
> >
> >          if (gtt->usertask)
> > --
> > 2.21.0.593.g511ec345e18-goog
> >

