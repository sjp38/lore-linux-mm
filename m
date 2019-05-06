Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B81AC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:15:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36EBA2054F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 14:15:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RwIwMiF8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36EBA2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1A7E6B0007; Mon,  6 May 2019 10:15:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCAAC6B0008; Mon,  6 May 2019 10:15:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6B8D6B000A; Mon,  6 May 2019 10:15:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6CCA76B0007
	for <linux-mm@kvack.org>; Mon,  6 May 2019 10:15:33 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id p12so7235854plk.4
        for <linux-mm@kvack.org>; Mon, 06 May 2019 07:15:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OW9r981uG4q4mCEE3eviMpvcgNrP8ztSBy/V22TuEyU=;
        b=a7IJ1xGkBPwIA+KLVzdTvz/Tq4QvGe7NuZnAlfR+ikMhUsVTGdAz7OZYUwAQvqLOHp
         IlC/r9v+wZTWh/DZj0NesIq531VkMaYzf/KdxrwFGHJh5jtJ4ib9zq3jRMfFMhqBtBgN
         /YEYR8zjEvDaoPDdZnLb1PpSfmKdQrZFTZhaKE/UIGgsbTSP7WNYjWj1drWOUrLR3Q9H
         i2gKSjmGDHb50FRLIjBENT3zqdzLb8m2kWaZpbZA75Ww1ZYmSgkTKnKIqxRRSyoduRmR
         /k+ccGkYgSgDw8/cYWq4liXBYIKJpSLk7Rw3yEQK9Tnj7q18W0mWm0L9Oigg/7PWbYdV
         i3xA==
X-Gm-Message-State: APjAAAUW/tx0e8GDudkFdjBXl6M7o6WMEoFGYx+TLSMiMUES3nGuhOHL
	nTSpsul+2ScBx0uxjsCM7TQ7YYD6noPx+8ap1X0ZbP6bKE8cy1IG0D+pnKKY5cWn4t2cEd60Ov1
	SPLaN8jGa6oUDHS0jgFx6U6G5F5Fz0XzQdtMttES3qDZmgI250NIQukE8IxswGNVWXA==
X-Received: by 2002:aa7:87d7:: with SMTP id i23mr17597478pfo.211.1557152133108;
        Mon, 06 May 2019 07:15:33 -0700 (PDT)
X-Received: by 2002:aa7:87d7:: with SMTP id i23mr17597389pfo.211.1557152132335;
        Mon, 06 May 2019 07:15:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557152132; cv=none;
        d=google.com; s=arc-20160816;
        b=bEOVg9t25x3jdraye3La473pw5faLLsWgK/hadtwPXrg8PAC9p9T46K3XnmodLF4PU
         hQA5DCU4RJnXfcFFBqIlAH0i/QBDdxLhVBxlbW+EBXDfJHMY9fN8ms0sBSN5RZFZDaCR
         fJun2A8U9mHtGpVrkOTGxHsOOV4aoB1Cc9i4lUDgoMEngbhDy7achDLQ+4b5aJUvMuJ+
         q9ZtlN431HfK2KvLRpPjl0gJwjyMDEr3xaTwWvfpR7lL0SYHiX94WvSzvNNpRrk0WUoz
         CWk2aP/iDiP+jexBlFzLZHrgYzkXpDPi/JxhrpIjB00jwwUWxd9VrJq5Uj0bmBFxTKwE
         0+rQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OW9r981uG4q4mCEE3eviMpvcgNrP8ztSBy/V22TuEyU=;
        b=iRBJukGwFxSDpuT9Ws/qG8gWAROGsisOSUEJIoXGprYqRiNjSocXXQrF6mlWGy+C/7
         +78vbmruSho2llGoYSddkkD1I/YKyA2XrhC7RZZIHWNI15kMLQD3nTMSiyPDyCdyvZml
         NKipq7KU7BcUSh6R0ZSLhoyioTrzkEsvyWCzF6/ghh0ciZswKMHNuiIW78F4kfHzLLXA
         sT5orp+8m60O8gctn9ch2zkfbsYEI8rLLNd+ZjF0A/HyuLE0BET7kqTo3doBRoLDNp9z
         l7lPiDdvxMYF8+hEmP4oHgdDZABFVLY+8Ws/F9AwTTfH0lSKYcd4O9jfEyo1dZagJFCT
         +HKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RwIwMiF8;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor12392175plq.28.2019.05.06.07.15.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 07:15:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RwIwMiF8;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OW9r981uG4q4mCEE3eviMpvcgNrP8ztSBy/V22TuEyU=;
        b=RwIwMiF88+Wz2lyiiiRFLD0DtzmtPhSYctT7DECXSVGGsMCqqEywraKb1VVIDK0D+6
         e05K/iAAJcE9yRHQNbEvq9ePWUxNo3jMQ16tSsOGtmWiuiuGjYTIKZn3RWyGJN1L7rxH
         JWCib8njn+v5Gl74GjdEjnavoToExJWkPKuLN2usGUeeVQU1cj6afqv3AP+Szx9d1YbR
         /iYb1mW4rEJXqf/1doCy1zenFphH/aiHoOYrBoxPgEK3EUfKzOGpHL63KMDfpfhEfnGD
         SAWo20WeW5Qs/kAhFHEaSxMs4rZb4+Da05bz1k2JR3ScMW8GRukA/aJ+BvUhLbhKhimD
         bg2g==
X-Google-Smtp-Source: APXvYqyWDp8mHq4mu+m9PaBcR4hr0UfLsUgs2S/OxvEKrdiWi6A7iqRf42KWhYp4nRTNFO6VlU1AYWwzebl0ku93GlI=
X-Received: by 2002:a17:902:7783:: with SMTP id o3mr32385898pll.159.1557152131315;
 Mon, 06 May 2019 07:15:31 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com> <7d3b28689d47c0fa1b80628f248dbf78548da25f.1556630205.git.andreyknvl@google.com>
 <20190503165646.GK55449@arrakis.emea.arm.com>
In-Reply-To: <20190503165646.GK55449@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 6 May 2019 16:15:20 +0200
Message-ID: <CAAeHK+yya4OR7GfSJPc59+trq3fS9Qh_1WK2hB1aoHdR0C_t8Q@mail.gmail.com>
Subject: Re: [PATCH v14 10/17] fs, arm64: untag user pointers in fs/userfaultfd.c
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com, Felix <Felix.Kuehling@amd.com>, 
	Deucher@google.com, Alexander <Alexander.Deucher@amd.com>, Koenig@google.com, 
	Christian <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
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

On Fri, May 3, 2019 at 6:56 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Tue, Apr 30, 2019 at 03:25:06PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > userfaultfd_register() and userfaultfd_unregister() use provided user
> > pointers for vma lookups, which can only by done with untagged pointers.
> >
> > Untag user pointers in these functions.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  fs/userfaultfd.c | 5 +++++
> >  1 file changed, 5 insertions(+)
> >
> > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > index f5de1e726356..fdee0db0e847 100644
> > --- a/fs/userfaultfd.c
> > +++ b/fs/userfaultfd.c
> > @@ -1325,6 +1325,9 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> >               goto out;
> >       }
> >
> > +     uffdio_register.range.start =
> > +             untagged_addr(uffdio_register.range.start);
> > +
> >       ret = validate_range(mm, uffdio_register.range.start,
> >                            uffdio_register.range.len);
> >       if (ret)
> > @@ -1514,6 +1517,8 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
> >       if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
> >               goto out;
> >
> > +     uffdio_unregister.start = untagged_addr(uffdio_unregister.start);
> > +
> >       ret = validate_range(mm, uffdio_unregister.start,
> >                            uffdio_unregister.len);
> >       if (ret)
>
> Wouldn't it be easier to do this in validate_range()? There are a few
> more calls in this file, though I didn't check whether a tagged address
> would cause issues.

Yes, I think it makes more sense, will do in v15, thanks!

>
> --
> Catalin

