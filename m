Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 213CEC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 13:44:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A248D20675
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 13:44:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mCRvGiMC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A248D20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10DEE6B0005; Mon,  6 May 2019 09:44:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BF8E6B0006; Mon,  6 May 2019 09:44:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC7C76B0007; Mon,  6 May 2019 09:44:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id CD1096B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 09:44:28 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id b63so8676923itc.0
        for <linux-mm@kvack.org>; Mon, 06 May 2019 06:44:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=P1AsWbEhRa0wHsK8aH/Xd0AjHqgvO+evP2tETj4R/Hs=;
        b=Kh3riInSFNxRd9IHdvhZHJMHqg5eUxKGWRk9u/rwsQ4ZSJQXoVgSCXsE4W2cu+HNXb
         yHRHvqLckzEeZnUqjMKM8eAu+YJazNQ3DuSy0m35NenPb5lZ9FeCrYMVBhsoDim8F88n
         ZsYP7GGvIb0L2Xh6rBbJsC+lDxC0K2Dv5/w/i1SIfyUYdwZ+yAdOKKSk3HlbKACImPxI
         q761GItGrxhn8iT/ccaAoyokQzJPsuoscFuh8OZieThPeMAOfGi1gGoQ041ZI+KCtiaW
         d88HCL/hRPh5No2FkiRPW+zSDziuSDxGL7LYM1T0AJt+7NhQB+KN6k80qQAAirKKxmcX
         zG2g==
X-Gm-Message-State: APjAAAW57VXD2Ux6d18rWO0Ny6hg99y+aD9Ag2JJDm4vVAPkzt8P7E7e
	E0V/JVcYpqUbiLjYKe7YG88GkjOoy+szvNoffWXIfIj13TTcnNhWJPHHSvwFqWtH+0H5dUpWX8N
	CF/T5SXpRL4ne31zyJUwF7wVMNDUfZIN/TcVIdyr4kH/7U69BJJf92EDU1AQtCLMhBQ==
X-Received: by 2002:a24:7595:: with SMTP id y143mr4104171itc.42.1557150268559;
        Mon, 06 May 2019 06:44:28 -0700 (PDT)
X-Received: by 2002:a24:7595:: with SMTP id y143mr4104122itc.42.1557150267709;
        Mon, 06 May 2019 06:44:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557150267; cv=none;
        d=google.com; s=arc-20160816;
        b=yN3KviPsvf4yFS4wCtSQmYNCkzw3U1mO9Z0JCdwdHmMvt22vu+lcApgmYvIMSL6QfU
         p3+J2V1bim1GbQlUvtJ5VHwdLFZhvBYw89O8DO9xbY4zCn1BsLK0X8OQ2ZfMEL3FJG1w
         47lor7jnLVnc5F4yqCHC0kXex3LGqJSzRZLJ+HYZ3LUos4JZDpuR4E9gSHTds9/x7csL
         NWY0u5lTS5XdzLi6+BN9h/itovZzRqjzPIya6olaBEgHrMYDAQj3xx6gCGNQx7OLzzJ4
         oblauMCVs6JyqhxIWkGf22fDWaTuZaTR+jbk1Aw4rm7wmbvhYgnqsQTjDKj39xRzJgRk
         tFzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=P1AsWbEhRa0wHsK8aH/Xd0AjHqgvO+evP2tETj4R/Hs=;
        b=NQQy9YlgQ3AGscufN/dbDlF1NPv+O/yBuEdDwKgVox+b7gUEFr6rkYDSL/dbEOrrVg
         mP74HU+vsdJfjVP34rhHWC6gScVS/D0htT1DDEOf+jqHRJDHROSO1iH2e0/GmUw68oiO
         To20x9EKCBwn4Kl05zPwn58s0rK0ITCwZ6nKNGTEh7h0ievArr3z1k+KmFXUlroF/2jH
         p5x7H5T6+nMhAljBmpjp+WrRvWpA9ndGiZJe+JJdgjNCftUVF01pxZdD/aLf66yHIwSC
         JwiaecEChRIuD8e8+IQXpDDmCTR8ncpfQqNPzl53cchwEf2BIUD2eHVQmnWj89nhkpSS
         uqEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mCRvGiMC;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i200sor13988625iti.18.2019.05.06.06.44.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 06:44:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mCRvGiMC;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=P1AsWbEhRa0wHsK8aH/Xd0AjHqgvO+evP2tETj4R/Hs=;
        b=mCRvGiMCWNKbNQEDEHJPLjAQLrUoFSSCHXZ4fTSXpN0g/fIsZshRPm9ndJR5eUZFeS
         cUUVjH5+H0srhJLB97pYS1dAESJ7tlFO12o1QmSKRMylSSrMX7eSkAQZPeAl3j+/4jot
         Z0rf7bLAB+FWXtNFndWhjKloQyKtxfQf5Kq8g+VAeVRm9B5go9fsjfeA1Dd6Ooje6hgH
         357+7liJijJSnEfmpI/7ugnjlRqi6Wms+2k2fk5xNGdbQ6jmPTdGnzA1IYZPJTlgFqN0
         Ndu9I5tb/O92PbPFqb8n8H87QKDs4WxDWcu0C7SbNnCwtFrTK4+5MXiNHqnk7vlAYn6T
         l3OQ==
X-Google-Smtp-Source: APXvYqyNDZxWsCMEiiGgR4F3I9CPNPMghQJxWH7nmS2ow6tBDXdVdmASCVpQ1EAh1QL7BadGynC5IC5t7w0MYPoEEO8=
X-Received: by 2002:a65:610a:: with SMTP id z10mr32127312pgu.54.1557150266321;
 Mon, 06 May 2019 06:44:26 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com> <9a50ef07d927cbccd9620894bda825e551168c3d.1556630205.git.andreyknvl@google.com>
 <bfe5e11e-6dc4-352f-57eb-d527f965a2ef@amd.com>
In-Reply-To: <bfe5e11e-6dc4-352f-57eb-d527f965a2ef@amd.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 6 May 2019 15:44:15 +0200
Message-ID: <CAAeHK+wFq_NwhYtoGapcrKDnCxZUcquBuW_ZCae+8CAqtp3ndQ@mail.gmail.com>
Subject: Re: [PATCH v14 12/17] drm/radeon, arm64: untag user pointers
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
	Yishai Hadas <yishaih@mellanox.com>, "Kuehling@google.com" <Kuehling@google.com>, 
	"Deucher@google.com" <Deucher@google.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, 
	"Koenig@google.com" <Koenig@google.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
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

On Tue, Apr 30, 2019 at 7:57 PM Kuehling, Felix <Felix.Kuehling@amd.com> wrote:
>
> On 2019-04-30 9:25 a.m., Andrey Konovalov wrote:
> > [CAUTION: External Email]
> >
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > radeon_ttm_tt_pin_userptr() uses provided user pointers for vma
> > lookups, which can only by done with untagged pointers. This patch
> > untags user pointers when they are being set in
> > radeon_ttm_tt_pin_userptr().
> >
> > In amdgpu_gem_userptr_ioctl() an MMU notifier is set up with a (tagged)
> > userspace pointer. The untagged address should be used so that MMU
> > notifiers for the untagged address get correctly matched up with the right
> > BO. This patch untags user pointers in radeon_gem_userptr_ioctl().
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >   drivers/gpu/drm/radeon/radeon_gem.c | 2 ++
> >   drivers/gpu/drm/radeon/radeon_ttm.c | 2 +-
> >   2 files changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/drivers/gpu/drm/radeon/radeon_gem.c b/drivers/gpu/drm/radeon/radeon_gem.c
> > index 44617dec8183..90eb78fb5eb2 100644
> > --- a/drivers/gpu/drm/radeon/radeon_gem.c
> > +++ b/drivers/gpu/drm/radeon/radeon_gem.c
> > @@ -291,6 +291,8 @@ int radeon_gem_userptr_ioctl(struct drm_device *dev, void *data,
> >          uint32_t handle;
> >          int r;
> >
> > +       args->addr = untagged_addr(args->addr);
> > +
> >          if (offset_in_page(args->addr | args->size))
> >                  return -EINVAL;
> >
> > diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
> > index 9920a6fc11bf..dce722c494c1 100644
> > --- a/drivers/gpu/drm/radeon/radeon_ttm.c
> > +++ b/drivers/gpu/drm/radeon/radeon_ttm.c
> > @@ -742,7 +742,7 @@ int radeon_ttm_tt_set_userptr(struct ttm_tt *ttm, uint64_t addr,
> >          if (gtt == NULL)
> >                  return -EINVAL;
> >
> > -       gtt->userptr = addr;
> > +       gtt->userptr = untagged_addr(addr);
>
> Doing this here seems unnecessary, because you already untagged the
> address in the only caller of this function in radeon_gem_userptr_ioctl.
> The change there will affect both the userptr and MMU notifier setup and
> makes sure that both are in sync, using the same untagged address.

Will fix in v15, thanks!

>
> Regards,
>    Felix
>
>
> >          gtt->usermm = current->mm;
> >          gtt->userflags = flags;
> >          return 0;
> > --
> > 2.21.0.593.g511ec345e18-goog
> >

