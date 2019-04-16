Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72FAEC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 20:37:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 065E420821
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 20:37:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="oIazGa6n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 065E420821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B31B6B0003; Tue, 16 Apr 2019 16:37:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8632F6B0006; Tue, 16 Apr 2019 16:37:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72BB86B0007; Tue, 16 Apr 2019 16:37:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 48D456B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 16:37:58 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id u18so11459581otq.5
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 13:37:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=kESGNo57Cjdjom3sqIgs25kzW/oD38ix2MJXU54+Oao=;
        b=EA1FFHK0mONJV91JFuoORCV3lCb0OwjxxseFAwEBNRTJ1+epCVVJh4E4PT7K/TGSXj
         Eo39wbHi2xBYa9as4/TFeLlbeAwXwPaIgtWnG4247GBrzIjVJ7THvkFrG3VR0mA3A80g
         zp0996q0zMRI+MOzrrdzL+HP+itBOylfaMaZY0LEdj+64W9kT9CsTXAZ6PPB8UFh6njl
         ceqNpUvVeVwu8uYo1F6lYuSMH/JybkNaGz+30flY15j+FaugXU1e3Acb4Jmr2rKjjZC1
         65rN+uicyh/20nbq43b4NWjfLMtGeo2G36u2/mSLKhV+96UAJ3vF7puLAFbaoIXO5yg8
         Gdaw==
X-Gm-Message-State: APjAAAVmlgUbSj/9/joUmlwrH2hzDx0AXMcCJNmo9L+37mJq8VGRAD56
	BWRGXUMp6Zd3G+5NZkhY5rF04hZnANW7hNCBScJ5GKZZTavQ6rs4/96XD0dCfSpwGU+IB9U+a6z
	A1BUMklL9IyjiaTAKI78uTtCkpAPCAIhZ+eAYojurD1ABVSXgMNp2q6ObDgEflmmEpQ==
X-Received: by 2002:aca:bcc1:: with SMTP id m184mr24901859oif.158.1555447077763;
        Tue, 16 Apr 2019 13:37:57 -0700 (PDT)
X-Received: by 2002:aca:bcc1:: with SMTP id m184mr24901830oif.158.1555447076945;
        Tue, 16 Apr 2019 13:37:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555447076; cv=none;
        d=google.com; s=arc-20160816;
        b=SUq9F7YEhKfa2C1/g8aegNzERd19Y1ANwUDuNRwzQO5t1L2otmXMBPOeJzN/Cx8u17
         qai6QIJeiykN9ndMSdirK5p6h4lK0UgL0kjA6uTOu6sWgDbJyU+enR2Xm2V2kPugsYRj
         6dpXZM5pscks1ZDOAt8CSug9QcUWYUuWs1KlpJfyz9SvdlQbgHfUCAmUyBRAHPWMF5hD
         7zRI+c2cPu2B13m0iyaMZQiyT6mf8vX/O/hF8ZVEjJHgfVdYVYwZUbdp1cSCbZsDo61x
         5XwQKzcaZI5uDxle1PEHzzNe204bd8GbMasMWqaEUEddaXZ++2sWdQG1yxAO3f0l1wrm
         0SaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=kESGNo57Cjdjom3sqIgs25kzW/oD38ix2MJXU54+Oao=;
        b=mawf+jxUwSvX/SkHjLVAqXj9Rd/cHDHtOPzlCTJg2bU0Bw/NWSwlaqNCWfTm4bUCDe
         arSJMrDBJBHKHytJLgwrZ9oz5L4vT7hiMs/I3EmijWwQ1hFeMXEuzYKTy0BKpG0EQEuU
         JyTQYXrYOSM7aLt+LiJAhvxTjXsDfAs6+i4zBjFPsF/mhpRTv8B78Zx1Bmm75mNLn3Si
         YdHHD9MILhRRpw562lO1q/bsZDMj8TI8Vv/vA2JTGo/N/Gp4JTEt04URGi41pbsX2Qcj
         /4gs74Y4ZIi4tuIoLOBFhCbQN4O4wcSjnG0WcamTdWUwGkgp3Mhsi2XJ8W8dy8E45niK
         hsMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=oIazGa6n;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f129sor29324092oia.25.2019.04.16.13.37.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 13:37:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=oIazGa6n;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kESGNo57Cjdjom3sqIgs25kzW/oD38ix2MJXU54+Oao=;
        b=oIazGa6nnJVvoYkG7mNV2WNlpGJfqHsF0E0RN3GayPHtNU3/pwAL+PIyUc0GKQe4vf
         ohvhxF2zTTwKwYsvDfrhsFQ81AdN/wM0le+6KiaNb+VC3u9FmuRlkgRlIhdKYRxjH+p9
         0Bol3sQctYe19VTBZbD3tvdQD76Z1bi6GTflqo1yuWCFtGSrZfAwHy+eiTrsqRvQQ1/T
         Ugjt+WIIkpRfp1tY6yV86d1XVRjSRxiweFY3eAmXuv0rC5K1oyE0yLiayNTVsAVBud4Z
         iQkOxxfgl1VFvfhXqbH6IIg9gfY7b6RAwzXep7wNiaU/P0RJjLLlrNxJgdfq/nbnSF8j
         JSMA==
X-Google-Smtp-Source: APXvYqw7V/mV/hj3PlwGwhy1yqqT1RCIXP0GlYeYGAGC/wQ5FjmPA0iCHxGxRX93xqLwhW1UoKdyhYlKGvcxoTNbSkM=
X-Received: by 2002:aca:aa57:: with SMTP id t84mr25917903oie.149.1555447076327;
 Tue, 16 Apr 2019 13:37:56 -0700 (PDT)
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
 <CABXOdTc5=J7ZFgbiwahVind-SNt7+G_-TVO=v-Y5SBVPLdUFog@mail.gmail.com>
 <CAPcyv4gxk9xbsP3YSKzxu5Yp9FTefyxHc6xC33GwZ3Zf9_eeKA@mail.gmail.com> <CABXOdTd-cqHM_feAO1tvwn4Z=kM6WHKYAbDJ7LGfMvRPRPG7GA@mail.gmail.com>
In-Reply-To: <CABXOdTd-cqHM_feAO1tvwn4Z=kM6WHKYAbDJ7LGfMvRPRPG7GA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 16 Apr 2019 13:37:45 -0700
Message-ID: <CAPcyv4hyOtJsnM6qqey7ADY=7brzVQ5TH3URrofmsQ57t1=WbQ@mail.gmail.com>
Subject: Re: next/master boot bisection: next-20190215 on beaglebone-black
To: Guenter Roeck <groeck@google.com>
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

On Tue, Apr 16, 2019 at 12:34 PM Guenter Roeck <groeck@google.com> wrote:
>
> On Tue, Apr 16, 2019 at 11:54 AM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Thu, Apr 11, 2019 at 1:54 PM Guenter Roeck <groeck@google.com> wrote:
> > [..]
> > > > > Boot tests report
> > > > >
> > > > > Qemu test results:
> > > > >     total: 345 pass: 345 fail: 0
> > > > >
> > > > > This is on top of next-20190410 with CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
> > > > > and the known crashes fixed.
> > > >
> > > > In addition to CONFIG_SHUFFLE_PAGE_ALLOCATOR=y you also need the
> > > > kernel command line option "page_alloc.shuffle=1"
> > > >
> > > > ...so I doubt you are running with shuffling enabled. Another way to
> > > > double check is:
> > > >
> > > >    cat /sys/module/page_alloc/parameters/shuffle
> > >
> > > Yes, you are right. Because, with it enabled, I see:
> > >
> > > Kernel command line: rdinit=/sbin/init page_alloc.shuffle=1 panic=-1
> > > console=ttyAMA0,115200 page_alloc.shuffle=1
> > > ------------[ cut here ]------------
> > > WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:303
> > > page_alloc_shuffle+0x12c/0x1ac
> > > static_key_enable(): static key 'page_alloc_shuffle_key+0x0/0x4' used
> > > before call to jump_label_init()
> >
> > This looks to be specific to ARM never having had to deal with
> > DEFINE_STATIC_KEY_TRUE in the past.
> >
>
> This affects almost all architectures, not just arm, presumably
> because parse_args() is called before jump_label_init() in
> start_kernel().

Hmm, you're right, but this should effect *every* architecture not
just ARM. Why is it not screaming at me on x86?

> I did not bother to report back with further details
> after someone stated that qemu doesn't support omap2, and the context
> seemed to suggest that running any other tests would not add any
> value.
>
> > I am able to avoid this warning by simply not enabling JUMP_LABEL
> > support in my build.
> >
>
> Fine with me, as long as CONFIG_SHUFFLE_PAGE_ALLOCATOR=y is not
> enabled by default, or if it is made dependent on !JUMP_LABEL.

Ah, no, the problem is that jump_label_init() is called by
setup_arch() on x86, and smp_prepare_boot_cpu() on powerpc, but not
until after parse_args() on ARM.

Given it appears to be safe to call jump_label_init() early how about
something like the following?

diff --git a/init/main.c b/init/main.c
index 598e278b46f7..7d4025d665eb 100644
--- a/init/main.c
+++ b/init/main.c
@@ -582,6 +582,8 @@ asmlinkage __visible void __init start_kernel(void)
        page_alloc_init();

        pr_notice("Kernel command line: %s\n", boot_command_line);
+       /* parameters may set static keys */
+       jump_label_init();
        parse_early_param();
        after_dashes = parse_args("Booting kernel",
                                  static_command_line, __start___param,
@@ -591,8 +593,6 @@ asmlinkage __visible void __init start_kernel(void)
                parse_args("Setting init args", after_dashes, NULL, 0, -1, -1,
                           NULL, set_init_arg);

-       jump_label_init();
-
        /*
         * These use large bootmem allocations and must precede
         * kmem_cache_init()

