Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1D89C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:04:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A06920684
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 21:04:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PJbXoVJo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A06920684
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0630E6B0003; Tue, 16 Apr 2019 17:04:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0125C6B0006; Tue, 16 Apr 2019 17:04:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E42F96B0007; Tue, 16 Apr 2019 17:04:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE4D36B0003
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 17:04:23 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id 62so16510469ybg.11
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:04:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=3mVw4sWA6qDIPaMdJZuToeLHe5IRdk9KdNBGER2kWPw=;
        b=l+WrlJyMqKErTYYylVFG/+wDvfaS1Ok7TL7Gx/6ppspyDChOrmFLDDgc+WvqZiCgB4
         D6iR1lB5uu5eGZ251aRRoooSNf987+apBtz98gjOFAFzdrjt1+JYYH+/ag/c0xdpO2t7
         /OU2u+wLspyTD9YB9aCOrAHV6uqZ+MBt9501Y8Nu0QopR40v03sABGrHgYJ/zS8bTm3v
         NLgc8Lq9T0xu+cIdPd+UDS5xozFTLliA5J8vVuOWrd+YIMn739K5pbRlQtQh5VRZbj07
         eC5fHMGL6v+tYGJ9s7p9IjuCVYe108Psq72q7zN1XTk1aOkFmIIG3Q3NlBWGy6j448Wy
         0cew==
X-Gm-Message-State: APjAAAUAQGbRIiwPyzVw+RPWOCD/Fl4x64w0opdYuBjrnz4ExwjHxYTB
	H6GLCVMA+y2blWB6bke1Leh7mQL6yGfHbcLzt+FknOQ0sabhD8SuebY9+I5cfWvtIDyZCEaUPcl
	+LCuzh7k7UsXcXlMzrXlY1D6Oaqk5YI04u/Jnmh0noJgao9Jt9pWbNmwhE7dLWbrC4w==
X-Received: by 2002:a25:a28c:: with SMTP id c12mr37552036ybi.52.1555448663404;
        Tue, 16 Apr 2019 14:04:23 -0700 (PDT)
X-Received: by 2002:a25:a28c:: with SMTP id c12mr37551973ybi.52.1555448662698;
        Tue, 16 Apr 2019 14:04:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555448662; cv=none;
        d=google.com; s=arc-20160816;
        b=HEhxdNNPu9ERqd/CUgToayOhn343iw2NrIHMRPk8Krj9cyccv1Um9Bjn9F17Ow9RgQ
         xWsSPWOU6rKAWI04wTPcNSQQCGdXjZzf4igHY/xN+63zcGgRH1w92aiH6pPkUkGI0uac
         HEvmBsPTazx0cbbm2c7je2Hv/eovN/S1qZDKAhlvoKAK2Lm5mSJ/Ch9l1ekRv9udsaTH
         bUbJaS6z9DiIwQtdMFDczIcZTLzJY2XDl//vFPvqKo8bHDVEfnqXwhr8u4I5LsKLazOs
         Npt1F5PF5b3beZYmpiQLtB59JvK4knZSgjaOqEHyzECXilsR+yti11mrT8URWAfATQTd
         2G8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=3mVw4sWA6qDIPaMdJZuToeLHe5IRdk9KdNBGER2kWPw=;
        b=H0Eqg0re03EFvjZW+gLJFMStiislKEKXUXZtMG/GwL03pitvEsGfp9lgGve6AcrHN0
         VPrzlry5hRx+OfKJnG1zFeMFuuBufyCb5vxVq9+F0h8pavMoWMlPnY3uujAdtrYI5UUH
         nB0zv/1gp1OS40m7Ir2BDcUXiYKVtNW3MOsTBzyx1ZY5wWKlkWHla6Dyba+PVNOMEzZQ
         GexF1DavGPORrFlICFNFbL7VLsnVRUYXZ29Bes614OM5xJRDb3g+ap/oQY3FfSS6CXrM
         /Zhd52c61eb32ifcRNwetNJIBIwG1DiZYRFdAYka3QdGTY1PwYRRfJaH3/++uKxogHXv
         65AQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PJbXoVJo;
       spf=pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q16sor17964932ywg.214.2019.04.16.14.04.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 14:04:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PJbXoVJo;
       spf=pass (google.com: domain of groeck@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=groeck@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=3mVw4sWA6qDIPaMdJZuToeLHe5IRdk9KdNBGER2kWPw=;
        b=PJbXoVJo0Vst14Hk0/UANKstQkGniXTXSxKfoOfpuc/E37y4lgsr9Q4EiE6UDppkgX
         w38peSnbKz2uF60LQ+lJGdl0t0YG7Hn3s9tsHmcxw+ubpubQLjWB4H0Z9fetLCz3y6/O
         pI5nuojfsRxBMqnKH+uV2hDY0eu5gX8FA7rD8qI/ifSfmN7mg9BkoFaBdEqRucRfX/xL
         A2nB5oNYltr8+D4nBVprPHRAGdlBulKIp7QXEunkHiqtkqEqXC1gGgkbZEKIb7LTIdn9
         bMbNK/uGd0+4FIpTst7g2U8ieQ694BYR87LAkMrWB8qxQFd02llEWRhq5opMfKl55YhG
         18og==
X-Google-Smtp-Source: APXvYqzxkgzQTeP/U3vWXtxhWmS8C5zVvbgwjVZE+yABxDg607Eb2ntm7uFqtPB3IgvfP2dNJSKixsP0pKGCx8Y0aRQ=
X-Received: by 2002:a81:a18b:: with SMTP id y133mr65958783ywg.64.1555448662137;
 Tue, 16 Apr 2019 14:04:22 -0700 (PDT)
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
 <CAPcyv4gxk9xbsP3YSKzxu5Yp9FTefyxHc6xC33GwZ3Zf9_eeKA@mail.gmail.com>
 <CABXOdTd-cqHM_feAO1tvwn4Z=kM6WHKYAbDJ7LGfMvRPRPG7GA@mail.gmail.com> <CAPcyv4hyOtJsnM6qqey7ADY=7brzVQ5TH3URrofmsQ57t1=WbQ@mail.gmail.com>
In-Reply-To: <CAPcyv4hyOtJsnM6qqey7ADY=7brzVQ5TH3URrofmsQ57t1=WbQ@mail.gmail.com>
From: Guenter Roeck <groeck@google.com>
Date: Tue, 16 Apr 2019 14:04:10 -0700
Message-ID: <CABXOdTeu0WTv9b+0eLHC+0K+HdNQsRTAUaWyxXAbKxQyy_19PQ@mail.gmail.com>
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

On Tue, Apr 16, 2019 at 1:37 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Tue, Apr 16, 2019 at 12:34 PM Guenter Roeck <groeck@google.com> wrote:
> >
> > On Tue, Apr 16, 2019 at 11:54 AM Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > On Thu, Apr 11, 2019 at 1:54 PM Guenter Roeck <groeck@google.com> wrote:
> > > [..]
> > > > > > Boot tests report
> > > > > >
> > > > > > Qemu test results:
> > > > > >     total: 345 pass: 345 fail: 0
> > > > > >
> > > > > > This is on top of next-20190410 with CONFIG_SHUFFLE_PAGE_ALLOCATOR=y
> > > > > > and the known crashes fixed.
> > > > >
> > > > > In addition to CONFIG_SHUFFLE_PAGE_ALLOCATOR=y you also need the
> > > > > kernel command line option "page_alloc.shuffle=1"
> > > > >
> > > > > ...so I doubt you are running with shuffling enabled. Another way to
> > > > > double check is:
> > > > >
> > > > >    cat /sys/module/page_alloc/parameters/shuffle
> > > >
> > > > Yes, you are right. Because, with it enabled, I see:
> > > >
> > > > Kernel command line: rdinit=/sbin/init page_alloc.shuffle=1 panic=-1
> > > > console=ttyAMA0,115200 page_alloc.shuffle=1
> > > > ------------[ cut here ]------------
> > > > WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:303
> > > > page_alloc_shuffle+0x12c/0x1ac
> > > > static_key_enable(): static key 'page_alloc_shuffle_key+0x0/0x4' used
> > > > before call to jump_label_init()
> > >
> > > This looks to be specific to ARM never having had to deal with
> > > DEFINE_STATIC_KEY_TRUE in the past.
> > >
> >
> > This affects almost all architectures, not just arm, presumably
> > because parse_args() is called before jump_label_init() in
> > start_kernel().
>
> Hmm, you're right, but this should effect *every* architecture not
> just ARM. Why is it not screaming at me on x86?
>
Guess you figured that out yourself...

> > I did not bother to report back with further details
> > after someone stated that qemu doesn't support omap2, and the context
> > seemed to suggest that running any other tests would not add any
> > value.
> >
> > > I am able to avoid this warning by simply not enabling JUMP_LABEL
> > > support in my build.
> > >
> >
> > Fine with me, as long as CONFIG_SHUFFLE_PAGE_ALLOCATOR=y is not
> > enabled by default, or if it is made dependent on !JUMP_LABEL.
>
> Ah, no, the problem is that jump_label_init() is called by
> setup_arch() on x86, and smp_prepare_boot_cpu() on powerpc, but not
> until after parse_args() on ARM.
>
Anywhere but arm64, x86, and ppc, really.

$ git grep jump_label_init arch
arch/arm64/kernel/smp.c:        jump_label_init();
arch/powerpc/lib/feature-fixups.c:      jump_label_init();
arch/x86/kernel/setup.c:        jump_label_init();

> Given it appears to be safe to call jump_label_init() early how about
> something like the following?
>
> diff --git a/init/main.c b/init/main.c
> index 598e278b46f7..7d4025d665eb 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -582,6 +582,8 @@ asmlinkage __visible void __init start_kernel(void)
>         page_alloc_init();
>
>         pr_notice("Kernel command line: %s\n", boot_command_line);
> +       /* parameters may set static keys */
> +       jump_label_init();
>         parse_early_param();
>         after_dashes = parse_args("Booting kernel",
>                                   static_command_line, __start___param,
> @@ -591,8 +593,6 @@ asmlinkage __visible void __init start_kernel(void)
>                 parse_args("Setting init args", after_dashes, NULL, 0, -1, -1,
>                            NULL, set_init_arg);
>
> -       jump_label_init();
> -

That should work, unless there was a reason to have it that late. It
doesn't look like that was the case, but I may be missing something.

Guenter

