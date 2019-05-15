Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A298C46470
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 10:07:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D88E2084A
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 10:07:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VfTOzfQH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D88E2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A70E6B0005; Wed, 15 May 2019 06:07:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 931A06B0006; Wed, 15 May 2019 06:07:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D27C6B0007; Wed, 15 May 2019 06:07:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9BE6B0005
	for <linux-mm@kvack.org>; Wed, 15 May 2019 06:07:13 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id m26so487798lfp.18
        for <linux-mm@kvack.org>; Wed, 15 May 2019 03:07:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=mscevK37/4nnD6iDAhQMYOtk0/NBE7+GVVa+J+i/xbw=;
        b=B0MMtyZw9AFr1nKcAtAoZRLXGVSGYWxB+gc6pAmn7EsPpe8gpFYQg/hQSW60EXsiTZ
         BfaRSHajQmKjGWHbq6qR7g6vCZbjWx5ALYc7H9gP8r3haUmq5XHkVYQsj+txJu0D9718
         q7n90XHUex9ShpcxC4tMsK/8x1w0lxxRBoH0vKDi+hv+N4Vtb3+Bxm2RoSZrDzFR3rpE
         7JqAuu9Qwv70Ni/um3lHk9VcE2krIwQI0NW2+GUQcatouRcbogTTm0Z2N7XAsRJhnTtR
         e+icKGEnma7fcCRgnKqGoHT3eKs9B7QD3Mooy2SbElVP08GsmGtkS7SMK4L9Cc2/Db3d
         oNfQ==
X-Gm-Message-State: APjAAAV0GZwAt/B/nw19I6T9TsYP6+Z9Qpbkn3wuuy78xdGol4fiSXSX
	YC1LHuCJYPw7KtY7dlY7VWbmzEms619b1DXPtxlDc80VVq5NBK3wqYXu/I8vbALdULcSEtONVdU
	kjzMj+exxBzw0SNhZBLkxX8Aw6nU3rcIEf5OC3zInW1Aio+ra1useabqhkfN6nkDIkA==
X-Received: by 2002:a2e:1296:: with SMTP id 22mr19996876ljs.11.1557914832101;
        Wed, 15 May 2019 03:07:12 -0700 (PDT)
X-Received: by 2002:a2e:1296:: with SMTP id 22mr19996819ljs.11.1557914830943;
        Wed, 15 May 2019 03:07:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557914830; cv=none;
        d=google.com; s=arc-20160816;
        b=O52/zmLDn47AY+OaAL51EV5skDADBMCoUlpSa4tzXMJ3fkAw6kMhC6DSENUKKcBgQo
         //iHlZYw5hLdrOOnOEwz7PzwNPmnvpDPFu9UnhHhe1OJVHyEGaDksGC07UNBnRglRui2
         VTtTlS+XSqN0pVku5U/kTAAujwH6za7//FVqGDaDkxiXkXkwQFx0F/xtpY6CK57e3CjO
         zuIlQjkPYKdLCUHn410QoJHOZdvlDWTrAhTdMZxS/h5jOdapzrSXstIxbcADZu+MSMY+
         /Dy6N1tVZiKJbyLEdZc/MNO2Bxoua15RWjkpRBMyjvcB7UaXCytrGYIKpIl3FWUh++c3
         DnfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=mscevK37/4nnD6iDAhQMYOtk0/NBE7+GVVa+J+i/xbw=;
        b=cqw8doxp6c7s4oD/9hHNyR83y1DNos6ww2jdBsbmnJvjk//YZ9effWQzyow8dDfC9I
         WudW8QnthWcG/zrTtA2sj/dLbYJ5myZgzahnPSO+IGGR1Qulxt0eEQ9CBe+dA3fvRVrX
         OGRPu4rSBiNAFE8CasYWQ9mLlCVG29sxMnk4+A8U2/emUXNo83XJhVRpwVB/FYdoPTvw
         O8HRuF94NXovIhxroHzqZevs2WF8Zb5/qpLj2pix5JgCHKaMnm0ZfyahatOceI+O1xxW
         eXGoAdSbN4u3u2H0hn8Czk8RBdUFw8CugmTwi1ox0v/3xx4DwJ3XW31Psu19tTq8IeX0
         gtcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VfTOzfQH;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i16sor1030633ljj.1.2019.05.15.03.07.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 03:07:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VfTOzfQH;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=mscevK37/4nnD6iDAhQMYOtk0/NBE7+GVVa+J+i/xbw=;
        b=VfTOzfQHAEh1LniZ7/hjqkQRXVW6w0NiARMgkQz8fdmWPYx+YFlHjKrWW9SFetMWs3
         G9DBebsTzY+TzQqgaUZXHhuaJrAvPguyvG5rKygzDGVFRgykAzD9rO3eppEFQXrUDl0t
         KiCIAIs50XeDjdechjn9tNOpCIzTltid3TPjj4d5um53TgSRkcuBRE+Vm8tHVDQSZq3j
         4F5qTovSxa830D/kbxTzCF5Od4cASnkmz5b2FS8aG6wMt7X9c6XUSbGzNiMGEIJ+3WjJ
         66h2W9OJYMa8ypZNTZ+p2ZcKlrFs73YpMOW0vtYnMkyh9XXQW7DWfejdxzaJMmnDynAB
         L+Eg==
X-Google-Smtp-Source: APXvYqyq++NbMOADSqcuCndB8YwWAw8htvvh4qqGDhAqxC5mnRCZl3FTp2S7oPZzjTciowd41OY1QaLvEK3AiS3oH/o=
X-Received: by 2002:a2e:960e:: with SMTP id v14mr4236733ljh.31.1557914830398;
 Wed, 15 May 2019 03:07:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190508153736.256401-1-glider@google.com> <20190508153736.256401-4-glider@google.com>
 <CAGXu5jJS=KgLwetdmDAUq9+KhUFTd=jnCES3BZJm+qBwUBmLjQ@mail.gmail.com>
 <CAG_fn=VbJXHsqAeBD+g6zJ8WVTko4Ev2xytXrcJ-ztEWm7kOOA@mail.gmail.com>
 <CAFqt6zY1oY4YTfAd4RdV0-V8iUfK65LTHsdmxrSWs7KRnWrrCg@mail.gmail.com> <CAG_fn=XzWcF=_L1zEU6Gd++u00N=j9GptVLvYOj0_kF0HRu+ig@mail.gmail.com>
In-Reply-To: <CAG_fn=XzWcF=_L1zEU6Gd++u00N=j9GptVLvYOj0_kF0HRu+ig@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 15 May 2019 15:36:57 +0530
Message-ID: <CAFqt6zYvftTKDbpc-PyHw_uNvAnYuswevAe=F12ACFrBP1N6xA@mail.gmail.com>
Subject: Re: [PATCH 3/4] gfp: mm: introduce __GFP_NOINIT
To: Alexander Potapenko <glider@google.com>
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

On Tue, May 14, 2019 at 8:10 PM Alexander Potapenko <glider@google.com> wro=
te:
>
> From: Souptick Joarder <jrdr.linux@gmail.com>
> Date: Sat, May 11, 2019 at 9:28 AM
> To: Alexander Potapenko
> Cc: Kees Cook, Andrew Morton, Christoph Lameter, Laura Abbott,
> Linux-MM, linux-security-module, Kernel Hardening, Masahiro Yamada,
> James Morris, Serge E. Hallyn, Nick Desaulniers, Kostya Serebryany,
> Dmitry Vyukov, Sandeep Patil, Randy Dunlap, Jann Horn, Mark Rutland,
> Matthew Wilcox
>
> > On Thu, May 9, 2019 at 6:53 PM Alexander Potapenko <glider@google.com> =
wrote:
> > >
> > > From: Kees Cook <keescook@chromium.org>
> > > Date: Wed, May 8, 2019 at 9:16 PM
> > > To: Alexander Potapenko
> > > Cc: Andrew Morton, Christoph Lameter, Kees Cook, Laura Abbott,
> > > Linux-MM, linux-security-module, Kernel Hardening, Masahiro Yamada,
> > > James Morris, Serge E. Hallyn, Nick Desaulniers, Kostya Serebryany,
> > > Dmitry Vyukov, Sandeep Patil, Randy Dunlap, Jann Horn, Mark Rutland
> > >
> > > > On Wed, May 8, 2019 at 8:38 AM Alexander Potapenko <glider@google.c=
om> wrote:
> > > > > When passed to an allocator (either pagealloc or SL[AOU]B), __GFP=
_NOINIT
> > > > > tells it to not initialize the requested memory if the init_on_al=
loc
> > > > > boot option is enabled. This can be useful in the cases newly all=
ocated
> > > > > memory is going to be initialized by the caller right away.
> > > > >
> > > > > __GFP_NOINIT doesn't affect init_on_free behavior, except for SLO=
B,
> > > > > where init_on_free implies init_on_alloc.
> > > > >
> > > > > __GFP_NOINIT basically defeats the hardening against information =
leaks
> > > > > provided by init_on_alloc, so one should use it with caution.
> > > > >
> > > > > This patch also adds __GFP_NOINIT to alloc_pages() calls in SL[AO=
U]B.
> > > > > Doing so is safe, because the heap allocators initialize the page=
s they
> > > > > receive before passing memory to the callers.
> > > > >
> > > > > Slowdown for the initialization features compared to init_on_free=
=3D0,
> > > > > init_on_alloc=3D0:
> > > > >
> > > > > hackbench, init_on_free=3D1:  +6.84% sys time (st.err 0.74%)
> > > > > hackbench, init_on_alloc=3D1: +7.25% sys time (st.err 0.72%)
> > > > >
> > > > > Linux build with -j12, init_on_free=3D1:  +8.52% wall time (st.er=
r 0.42%)
> > > > > Linux build with -j12, init_on_free=3D1:  +24.31% sys time (st.er=
r 0.47%)
> > > > > Linux build with -j12, init_on_alloc=3D1: -0.16% wall time (st.er=
r 0.40%)
> > > > > Linux build with -j12, init_on_alloc=3D1: +1.24% sys time (st.err=
 0.39%)
> > > > >
> > > > > The slowdown for init_on_free=3D0, init_on_alloc=3D0 compared to =
the
> > > > > baseline is within the standard error.
> > > > >
> >
> > Not sure, but I think this patch will clash with Matthew's posted patch=
 series
> > *Remove 'order' argument from many mm functions*.
> Not sure I can do much with that before those patches reach mainline.
> Once they do, I'll update my patches.
> Please let me know if there's a better way to resolve such conflicts.

I just thought to highlight about a possible conflict. Nothing else :)
IMO, if other patch series merge into -next tree before this,
then this series can be updated against -next.

... And I am sure others will have a better suggestion.

> > > > > Signed-off-by: Alexander Potapenko <glider@google.com>
> > > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > > Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> > > > > Cc: James Morris <jmorris@namei.org>
> > > > > Cc: "Serge E. Hallyn" <serge@hallyn.com>
> > > > > Cc: Nick Desaulniers <ndesaulniers@google.com>
> > > > > Cc: Kostya Serebryany <kcc@google.com>
> > > > > Cc: Dmitry Vyukov <dvyukov@google.com>
> > > > > Cc: Kees Cook <keescook@chromium.org>
> > > > > Cc: Sandeep Patil <sspatil@android.com>
> > > > > Cc: Laura Abbott <labbott@redhat.com>
> > > > > Cc: Randy Dunlap <rdunlap@infradead.org>
> > > > > Cc: Jann Horn <jannh@google.com>
> > > > > Cc: Mark Rutland <mark.rutland@arm.com>
> > > > > Cc: linux-mm@kvack.org
> > > > > Cc: linux-security-module@vger.kernel.org
> > > > > Cc: kernel-hardening@lists.openwall.com
> > > > > ---
> > > > >  include/linux/gfp.h | 6 +++++-
> > > > >  include/linux/mm.h  | 2 +-
> > > > >  kernel/kexec_core.c | 2 +-
> > > > >  mm/slab.c           | 2 +-
> > > > >  mm/slob.c           | 3 ++-
> > > > >  mm/slub.c           | 1 +
> > > > >  6 files changed, 11 insertions(+), 5 deletions(-)
> > > > >
> > > > > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > > > > index fdab7de7490d..66d7f5604fe2 100644
> > > > > --- a/include/linux/gfp.h
> > > > > +++ b/include/linux/gfp.h
> > > > > @@ -44,6 +44,7 @@ struct vm_area_struct;
> > > > >  #else
> > > > >  #define ___GFP_NOLOCKDEP       0
> > > > >  #endif
> > > > > +#define ___GFP_NOINIT          0x1000000u
> > > >
> > > > I mentioned this in the other patch, but I think this needs to be
> > > > moved ahead of GFP_NOLOCKDEP and adjust the values for GFP_NOLOCKDE=
P
> > > > and to leave the IS_ENABLED() test in __GFP_BITS_SHIFT alone.
> > > Do we really need this blinking GFP_NOLOCKDEP bit at all?
> > > This approach doesn't scale, we can't even have a second feature that
> > > has a bit depending on the config settings.
> > > Cannot we just fix the number of bits instead?
> > >
> > > > >  /* If the above are modified, __GFP_BITS_SHIFT may need updating=
 */
> > > > >
> > > > >  /*
> > > > > @@ -208,16 +209,19 @@ struct vm_area_struct;
> > > > >   * %__GFP_COMP address compound page metadata.
> > > > >   *
> > > > >   * %__GFP_ZERO returns a zeroed page on success.
> > > > > + *
> > > > > + * %__GFP_NOINIT requests non-initialized memory from the underl=
ying allocator.
> > > > >   */
> > > > >  #define __GFP_NOWARN   ((__force gfp_t)___GFP_NOWARN)
> > > > >  #define __GFP_COMP     ((__force gfp_t)___GFP_COMP)
> > > > >  #define __GFP_ZERO     ((__force gfp_t)___GFP_ZERO)
> > > > > +#define __GFP_NOINIT   ((__force gfp_t)___GFP_NOINIT)
> > > > >
> > > > >  /* Disable lockdep for GFP context tracking */
> > > > >  #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
> > > > >
> > > > >  /* Room for N __GFP_FOO bits */
> > > > > -#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
> > > > > +#define __GFP_BITS_SHIFT (25)
> > > >
> > > > AIUI, this will break non-CONFIG_LOCKDEP kernels: it should just be=
:
> > > >
> > > > -#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
> > > > +#define __GFP_BITS_SHIFT (24 + IS_ENABLED(CONFIG_LOCKDEP))
> > > >
> > > > >  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT)=
 - 1))
> > > > >
> > > > >  /**
> > > > > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > > > > index ee1a1092679c..8ab152750eb4 100644
> > > > > --- a/include/linux/mm.h
> > > > > +++ b/include/linux/mm.h
> > > > > @@ -2618,7 +2618,7 @@ DECLARE_STATIC_KEY_FALSE(init_on_alloc);
> > > > >  static inline bool want_init_on_alloc(gfp_t flags)
> > > > >  {
> > > > >         if (static_branch_unlikely(&init_on_alloc))
> > > > > -               return true;
> > > > > +               return !(flags & __GFP_NOINIT);
> > > > >         return flags & __GFP_ZERO;
> > > >
> > > > What do you think about renaming __GFP_NOINIT to __GFP_NO_AUTOINIT =
or something?
> > > >
> > > > Regardless, yes, this is nice.
> > > >
> > > > --
> > > > Kees Cook
> > >
> > >
> > >
> > > --
> > > Alexander Potapenko
> > > Software Engineer
> > >
> > > Google Germany GmbH
> > > Erika-Mann-Stra=C3=9Fe, 33
> > > 80636 M=C3=BCnchen
> > >
> > > Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
> > > Registergericht und -nummer: Hamburg, HRB 86891
> > > Sitz der Gesellschaft: Hamburg
> > >
>
>
>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg

