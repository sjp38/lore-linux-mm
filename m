Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A6ECC46460
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:40:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E606C2147A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 14:40:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZcTWXERQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E606C2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7453D6B0005; Tue, 14 May 2019 10:40:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F6F16B0007; Tue, 14 May 2019 10:40:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BD8A6B0008; Tue, 14 May 2019 10:40:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3796B6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 10:40:10 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id k78so7873953vkk.17
        for <linux-mm@kvack.org>; Tue, 14 May 2019 07:40:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Y9elDrG5a0+F5kcEhLlKdiEIdllXd8Jo5lrH+iv1S3k=;
        b=V8c8UzoYPGJehO0JthSBPqbTESy5ZMjCI2lyguc9GnKKD7KU7SWjkrQwfhcZOckwgU
         WO/dyTyNklcUMAmJjQRS200AX95nR/LTm5jLDTGDVQTr8g4AYSJ6cRd5kaCN7JJE0O1B
         oDtCjwPKqNud+hZEptU93FLvg2LX42QYAGHHyYlLz32U7jIhf5liU7rTNl+LITjxODmO
         d3jKezVUWicPVHA3b4z5UjOyprC87EKQ86HV318tnJG/4+Q20O7Wpqpihswc9YktbCkH
         0Kurg/mLOCxI0NdXYKlf//TfoaGdf78giwUeGS/4WpChx46DvsErHh9oMlapBgOqv8XK
         OnKA==
X-Gm-Message-State: APjAAAXP3Jl5gK5n2EbFmWroFBPd+CwZ51R7dEL790ruw2xRiF8jUZVr
	91Hhu7ZB0FRsxJIMTvoG2kulqve9wZ5H+iKRA41L21alKUegtmW5piEkJQTOV+Jcd+MpGlRlc3z
	ODwBSu6/X1TctVL58NlYeRYhKXe1I6vJGbyklu4maarcfyyM0wpAzMAbAQ4p2S+0pDA==
X-Received: by 2002:a67:ecd0:: with SMTP id i16mr16581439vsp.162.1557844809916;
        Tue, 14 May 2019 07:40:09 -0700 (PDT)
X-Received: by 2002:a67:ecd0:: with SMTP id i16mr16581388vsp.162.1557844808901;
        Tue, 14 May 2019 07:40:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557844808; cv=none;
        d=google.com; s=arc-20160816;
        b=XNnLrBqCveJy8bnl+GoVwy2v7xsPC20ROKdcjwsdTVBkJCd/PJlPEecz3gIfpdn91c
         rjzKzw4z6JPXBShowfItovh2+nVFtj4yWvMSX2rNDDdt3B0HPaSrDyxC97N2xBY1Ze2F
         F5wVfKC/2PdAVahEakqCX34CM+IGXXyGUOWL0ivf6TTPDva+VaHjxxLUE95WIWTRUv9g
         1EBBKHwUUtuavKO8R6sg8w7ZfFgBHUMCiEl+WUvBBRW1DIT9euaBqX+o5mOsmnkf94HX
         3UhnfZWPjLlks78C/BMZcIPROohxjbG2VobhcapyyhFZzzCOi2aRHNSsnnMS/DfILnoZ
         GGKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Y9elDrG5a0+F5kcEhLlKdiEIdllXd8Jo5lrH+iv1S3k=;
        b=qI6oV1xj/gIV0T/b2La9voqX7zI8s2BQbGclVz41ycg8SoqW0q6HTztaUhfCUaQxDN
         ku8cRQgtQYAwZBXnxMLZIeaVCigAzqba6PvHTfJ1AFRiI5fsk1BciYOMuwVebQve8o2r
         S20CgyoCvwXAnq1wl8FVeIeuXMNBvVs8xZJ6ArZZbeRbWREAzVGHeRAYvIv8G+eMuwYG
         G0y8hSv5c02yccnT2dQxwPIGRSo/P7yCdWLNU482NxD2nk+OSoB82p6muJMnOtIWuTIU
         v4oAdq0SneA2ey/3AhbCc+CtcRt9Lz7GICWkazkYYViutoB5xZ4c+RI1Ouqu1FqZ9eI3
         y27g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZcTWXERQ;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n26sor8266275vso.13.2019.05.14.07.40.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 07:40:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZcTWXERQ;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Y9elDrG5a0+F5kcEhLlKdiEIdllXd8Jo5lrH+iv1S3k=;
        b=ZcTWXERQUjmj2QwQIbFGnj39+bcTt8zmjam78wn6i6h9/7xg03z2XYlSaQ8cHpeoCY
         guUpxGO0cXM4i2c3G8deAceAikaEUKjij0nW0aHk4HyQ+gRoOelIUeP+VgwPnXzWnRkV
         LkNT5Q8yQBe06a7btM3bVgqu8jUv5sKwOuRGGkvZXq1KRk78gmWImqoFlpJ0vgATk6nW
         sCnuzQvpXQjR+IQfrwj7QM2uvkCP01Pu3pnQEjrOJpFSXo7i26PkoZoJZougihhaqUNr
         irl7wVGn63hxTHymxdj4CK9PYN2aelLMvjHDwmReblXxIKZm/glwKfnRwqQqGOIwztK+
         5MdA==
X-Google-Smtp-Source: APXvYqzV+X//RAjmEdX/1LhxUFJSBZDJ8YuwVfHmpMyjQL0u0/UdaqtrKVuZ7H23X6BGjtPvNdxJYGe9v7h+/LMYF4M=
X-Received: by 2002:a67:7241:: with SMTP id n62mr16465896vsc.217.1557844808216;
 Tue, 14 May 2019 07:40:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190508153736.256401-1-glider@google.com> <20190508153736.256401-4-glider@google.com>
 <CAGXu5jJS=KgLwetdmDAUq9+KhUFTd=jnCES3BZJm+qBwUBmLjQ@mail.gmail.com>
 <CAG_fn=VbJXHsqAeBD+g6zJ8WVTko4Ev2xytXrcJ-ztEWm7kOOA@mail.gmail.com> <CAFqt6zY1oY4YTfAd4RdV0-V8iUfK65LTHsdmxrSWs7KRnWrrCg@mail.gmail.com>
In-Reply-To: <CAFqt6zY1oY4YTfAd4RdV0-V8iUfK65LTHsdmxrSWs7KRnWrrCg@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 14 May 2019 16:39:56 +0200
Message-ID: <CAG_fn=XzWcF=_L1zEU6Gd++u00N=j9GptVLvYOj0_kF0HRu+ig@mail.gmail.com>
Subject: Re: [PATCH 3/4] gfp: mm: introduce __GFP_NOINIT
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Christoph Lameter <cl@linux.com>, Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, May 11, 2019 at 9:28 AM
To: Alexander Potapenko
Cc: Kees Cook, Andrew Morton, Christoph Lameter, Laura Abbott,
Linux-MM, linux-security-module, Kernel Hardening, Masahiro Yamada,
James Morris, Serge E. Hallyn, Nick Desaulniers, Kostya Serebryany,
Dmitry Vyukov, Sandeep Patil, Randy Dunlap, Jann Horn, Mark Rutland,
Matthew Wilcox

> On Thu, May 9, 2019 at 6:53 PM Alexander Potapenko <glider@google.com> wr=
ote:
> >
> > From: Kees Cook <keescook@chromium.org>
> > Date: Wed, May 8, 2019 at 9:16 PM
> > To: Alexander Potapenko
> > Cc: Andrew Morton, Christoph Lameter, Kees Cook, Laura Abbott,
> > Linux-MM, linux-security-module, Kernel Hardening, Masahiro Yamada,
> > James Morris, Serge E. Hallyn, Nick Desaulniers, Kostya Serebryany,
> > Dmitry Vyukov, Sandeep Patil, Randy Dunlap, Jann Horn, Mark Rutland
> >
> > > On Wed, May 8, 2019 at 8:38 AM Alexander Potapenko <glider@google.com=
> wrote:
> > > > When passed to an allocator (either pagealloc or SL[AOU]B), __GFP_N=
OINIT
> > > > tells it to not initialize the requested memory if the init_on_allo=
c
> > > > boot option is enabled. This can be useful in the cases newly alloc=
ated
> > > > memory is going to be initialized by the caller right away.
> > > >
> > > > __GFP_NOINIT doesn't affect init_on_free behavior, except for SLOB,
> > > > where init_on_free implies init_on_alloc.
> > > >
> > > > __GFP_NOINIT basically defeats the hardening against information le=
aks
> > > > provided by init_on_alloc, so one should use it with caution.
> > > >
> > > > This patch also adds __GFP_NOINIT to alloc_pages() calls in SL[AOU]=
B.
> > > > Doing so is safe, because the heap allocators initialize the pages =
they
> > > > receive before passing memory to the callers.
> > > >
> > > > Slowdown for the initialization features compared to init_on_free=
=3D0,
> > > > init_on_alloc=3D0:
> > > >
> > > > hackbench, init_on_free=3D1:  +6.84% sys time (st.err 0.74%)
> > > > hackbench, init_on_alloc=3D1: +7.25% sys time (st.err 0.72%)
> > > >
> > > > Linux build with -j12, init_on_free=3D1:  +8.52% wall time (st.err =
0.42%)
> > > > Linux build with -j12, init_on_free=3D1:  +24.31% sys time (st.err =
0.47%)
> > > > Linux build with -j12, init_on_alloc=3D1: -0.16% wall time (st.err =
0.40%)
> > > > Linux build with -j12, init_on_alloc=3D1: +1.24% sys time (st.err 0=
.39%)
> > > >
> > > > The slowdown for init_on_free=3D0, init_on_alloc=3D0 compared to th=
e
> > > > baseline is within the standard error.
> > > >
>
> Not sure, but I think this patch will clash with Matthew's posted patch s=
eries
> *Remove 'order' argument from many mm functions*.
Not sure I can do much with that before those patches reach mainline.
Once they do, I'll update my patches.
Please let me know if there's a better way to resolve such conflicts.
> > > > Signed-off-by: Alexander Potapenko <glider@google.com>
> > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> > > > Cc: James Morris <jmorris@namei.org>
> > > > Cc: "Serge E. Hallyn" <serge@hallyn.com>
> > > > Cc: Nick Desaulniers <ndesaulniers@google.com>
> > > > Cc: Kostya Serebryany <kcc@google.com>
> > > > Cc: Dmitry Vyukov <dvyukov@google.com>
> > > > Cc: Kees Cook <keescook@chromium.org>
> > > > Cc: Sandeep Patil <sspatil@android.com>
> > > > Cc: Laura Abbott <labbott@redhat.com>
> > > > Cc: Randy Dunlap <rdunlap@infradead.org>
> > > > Cc: Jann Horn <jannh@google.com>
> > > > Cc: Mark Rutland <mark.rutland@arm.com>
> > > > Cc: linux-mm@kvack.org
> > > > Cc: linux-security-module@vger.kernel.org
> > > > Cc: kernel-hardening@lists.openwall.com
> > > > ---
> > > >  include/linux/gfp.h | 6 +++++-
> > > >  include/linux/mm.h  | 2 +-
> > > >  kernel/kexec_core.c | 2 +-
> > > >  mm/slab.c           | 2 +-
> > > >  mm/slob.c           | 3 ++-
> > > >  mm/slub.c           | 1 +
> > > >  6 files changed, 11 insertions(+), 5 deletions(-)
> > > >
> > > > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > > > index fdab7de7490d..66d7f5604fe2 100644
> > > > --- a/include/linux/gfp.h
> > > > +++ b/include/linux/gfp.h
> > > > @@ -44,6 +44,7 @@ struct vm_area_struct;
> > > >  #else
> > > >  #define ___GFP_NOLOCKDEP       0
> > > >  #endif
> > > > +#define ___GFP_NOINIT          0x1000000u
> > >
> > > I mentioned this in the other patch, but I think this needs to be
> > > moved ahead of GFP_NOLOCKDEP and adjust the values for GFP_NOLOCKDEP
> > > and to leave the IS_ENABLED() test in __GFP_BITS_SHIFT alone.
> > Do we really need this blinking GFP_NOLOCKDEP bit at all?
> > This approach doesn't scale, we can't even have a second feature that
> > has a bit depending on the config settings.
> > Cannot we just fix the number of bits instead?
> >
> > > >  /* If the above are modified, __GFP_BITS_SHIFT may need updating *=
/
> > > >
> > > >  /*
> > > > @@ -208,16 +209,19 @@ struct vm_area_struct;
> > > >   * %__GFP_COMP address compound page metadata.
> > > >   *
> > > >   * %__GFP_ZERO returns a zeroed page on success.
> > > > + *
> > > > + * %__GFP_NOINIT requests non-initialized memory from the underlyi=
ng allocator.
> > > >   */
> > > >  #define __GFP_NOWARN   ((__force gfp_t)___GFP_NOWARN)
> > > >  #define __GFP_COMP     ((__force gfp_t)___GFP_COMP)
> > > >  #define __GFP_ZERO     ((__force gfp_t)___GFP_ZERO)
> > > > +#define __GFP_NOINIT   ((__force gfp_t)___GFP_NOINIT)
> > > >
> > > >  /* Disable lockdep for GFP context tracking */
> > > >  #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
> > > >
> > > >  /* Room for N __GFP_FOO bits */
> > > > -#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
> > > > +#define __GFP_BITS_SHIFT (25)
> > >
> > > AIUI, this will break non-CONFIG_LOCKDEP kernels: it should just be:
> > >
> > > -#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
> > > +#define __GFP_BITS_SHIFT (24 + IS_ENABLED(CONFIG_LOCKDEP))
> > >
> > > >  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) -=
 1))
> > > >
> > > >  /**
> > > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > > index ee1a1092679c..8ab152750eb4 100644
> > > > --- a/include/linux/mm.h
> > > > +++ b/include/linux/mm.h
> > > > @@ -2618,7 +2618,7 @@ DECLARE_STATIC_KEY_FALSE(init_on_alloc);
> > > >  static inline bool want_init_on_alloc(gfp_t flags)
> > > >  {
> > > >         if (static_branch_unlikely(&init_on_alloc))
> > > > -               return true;
> > > > +               return !(flags & __GFP_NOINIT);
> > > >         return flags & __GFP_ZERO;
> > >
> > > What do you think about renaming __GFP_NOINIT to __GFP_NO_AUTOINIT or=
 something?
> > >
> > > Regardless, yes, this is nice.
> > >
> > > --
> > > Kees Cook
> >
> >
> >
> > --
> > Alexander Potapenko
> > Software Engineer
> >
> > Google Germany GmbH
> > Erika-Mann-Stra=C3=9Fe, 33
> > 80636 M=C3=BCnchen
> >
> > Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
> > Registergericht und -nummer: Hamburg, HRB 86891
> > Sitz der Gesellschaft: Hamburg
> >



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

