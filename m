Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 864ADC04AB3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 13:23:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0988A21479
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 13:23:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="B8KVmFpY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0988A21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D9C96B0003; Thu,  9 May 2019 09:23:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58C996B0006; Thu,  9 May 2019 09:23:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 452096B000A; Thu,  9 May 2019 09:23:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1BFF76B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 09:23:41 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id k65so973127vkh.6
        for <linux-mm@kvack.org>; Thu, 09 May 2019 06:23:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=sff58sBqd6I3jr2LoJpmtNzqy1jhnIaSBJFG4nsnerE=;
        b=LzEq67tm6/T2bVYDWEg76lZdcfqanPTGLA9LH341cLqaL+FAjAHK4VQtXEFeNjL6BE
         AFZRKgAQ9L61KBWuFosokzHaPF101Sfu9Z7i2yBkm7IIUf1OYCg+ONwV9uOD8CyGRLs3
         5CUN025SrAZexlQukmwCNBIbvy1FhZmPiuLC32U0vu+A/VVdgkUfxqoSPfz/uAE5AwLX
         aW0mTzwroVNciaKHXpNbhjWIzl86DyGfqsdoYBx6rInVo1ORVa7K+jf4bCLcfCNaG1BO
         IT7HNKeOc1Dfw5qBCY2lL8b+UXbze36OCdGLGVXNHZ85gceOErUXvp2Qam3KEgP6Rm7P
         OIBw==
X-Gm-Message-State: APjAAAVzAWh0yqYjlskkAaKg6okfzr2lVEXvAjMUXzTYSmuEuLzpn91a
	zzu3LiA1ExWMJBvV2YuXkK+/pulKUFDfIyOmsyrUSUugaNr8dUQqw22ex/4r1LBTeSY6HcN8tj6
	V0NOmItnLZ/+FZgW1KEuKd+6vq/RBjtcMJtbg0XFkX2+6NdlZ91x1apGVBp3K49dj9Q==
X-Received: by 2002:a1f:8cca:: with SMTP id o193mr1669605vkd.11.1557408220695;
        Thu, 09 May 2019 06:23:40 -0700 (PDT)
X-Received: by 2002:a1f:8cca:: with SMTP id o193mr1669528vkd.11.1557408219587;
        Thu, 09 May 2019 06:23:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557408219; cv=none;
        d=google.com; s=arc-20160816;
        b=mXu6OiSXKR/+dwAkbIbh1RytV4IqibxGoiow2IwCN98A8PIoPH3yEaubweBGUWB2dx
         3khVGaVz95odNAZ4CnmyYMOgBiG8sKl0Nm7oCwDVYGubHujRMadxXOwaBKoTixri2Jxv
         RJ5l4rz5jbId0plpfFGFIM51kjn0qVsE3u3U0cJeF1eDn61+JIyaJ/aWtAeLF9+bkD5u
         J1SI04XKEHEkKmlfHboFBLeoR4i37ctHvb0tMfaP4YhR5ORCYODE2miVAS7muQajoMBw
         RXW4YkN85wpeeenZnvQt08SiQIl0MGGFzSpJkPTm8MUGO+MZUXZvw6+UzPQzY6A16cja
         LBFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=sff58sBqd6I3jr2LoJpmtNzqy1jhnIaSBJFG4nsnerE=;
        b=so3qDFsKdUU5WKS6Tn47uF9b8GVjtfJ15dFiS13P7+gWBO1i1wZs8zgqO3lk6jZ0CM
         T8cEOu7lIfQI+EHF8m7LF7+qkJEXYRdnorzQ/iQ07JMHkYwDrZshUVFnPlLXYvXM7k2A
         LatmGq/Ai8PmFhNGikIZ73OhoVj5RSFvqNAGSN9EROqsV/9pOkpG+AiI7d3CVpduu3JL
         6dFQiywuMbL2tKSyj+M9T0IJFaCmvpP+MlfodCn396ybs/JRnljaZ3g8df+9hJmPGYhH
         c5MVxyCWf5hUaDzKUZLsrSzZYvoykhLBslCIR8HY5bf/3qb6S1z46FqLn9rxiE0Fxiao
         JHSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=B8KVmFpY;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g20sor981720vsq.122.2019.05.09.06.23.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 06:23:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=B8KVmFpY;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=sff58sBqd6I3jr2LoJpmtNzqy1jhnIaSBJFG4nsnerE=;
        b=B8KVmFpYir3rnGiAmtbgvsOw3dAWOQSkdZJUYG8fS5wXW80tGeFcMS4JftdHCYf7RR
         cDRIZtR8K5J268kAxu4OAWuxKySPy+9UpAcpWshQlpBVWX0GKbokVQ4WVwHnGohtrNM8
         6P+KeAUmebTGRqhnEjTmpruGfm4SKQJzZsEbArjpju6Sh9ejzvD67gSqXFNu/OpJko4u
         a96bv2j3YgkaJ+zcoJy6czXaap8XM7C9eHsCadPG208r6U1LH04GjvIarBzxyBpH6b00
         JagTxOBnoo0lssjXVRA3qvqhb2MOtjD4aZrbW0thhi1/ZJJlrN6xhujGn3AChqmUWtg7
         2ZZA==
X-Google-Smtp-Source: APXvYqwqW1Oquf8DAl74l6krQGTZ6Q5Lm130MtNSPSwLB1iofEZlAVrSXg8AEP36V6GqFHDuK+CN6QVFaD2IWmXNX+I=
X-Received: by 2002:a67:7241:: with SMTP id n62mr2198744vsc.217.1557408218840;
 Thu, 09 May 2019 06:23:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190508153736.256401-1-glider@google.com> <20190508153736.256401-4-glider@google.com>
 <CAGXu5jJS=KgLwetdmDAUq9+KhUFTd=jnCES3BZJm+qBwUBmLjQ@mail.gmail.com>
In-Reply-To: <CAGXu5jJS=KgLwetdmDAUq9+KhUFTd=jnCES3BZJm+qBwUBmLjQ@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 9 May 2019 15:23:26 +0200
Message-ID: <CAG_fn=VbJXHsqAeBD+g6zJ8WVTko4Ev2xytXrcJ-ztEWm7kOOA@mail.gmail.com>
Subject: Re: [PATCH 3/4] gfp: mm: introduce __GFP_NOINIT
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Laura Abbott <labbott@redhat.com>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Kees Cook <keescook@chromium.org>
Date: Wed, May 8, 2019 at 9:16 PM
To: Alexander Potapenko
Cc: Andrew Morton, Christoph Lameter, Kees Cook, Laura Abbott,
Linux-MM, linux-security-module, Kernel Hardening, Masahiro Yamada,
James Morris, Serge E. Hallyn, Nick Desaulniers, Kostya Serebryany,
Dmitry Vyukov, Sandeep Patil, Randy Dunlap, Jann Horn, Mark Rutland

> On Wed, May 8, 2019 at 8:38 AM Alexander Potapenko <glider@google.com> wr=
ote:
> > When passed to an allocator (either pagealloc or SL[AOU]B), __GFP_NOINI=
T
> > tells it to not initialize the requested memory if the init_on_alloc
> > boot option is enabled. This can be useful in the cases newly allocated
> > memory is going to be initialized by the caller right away.
> >
> > __GFP_NOINIT doesn't affect init_on_free behavior, except for SLOB,
> > where init_on_free implies init_on_alloc.
> >
> > __GFP_NOINIT basically defeats the hardening against information leaks
> > provided by init_on_alloc, so one should use it with caution.
> >
> > This patch also adds __GFP_NOINIT to alloc_pages() calls in SL[AOU]B.
> > Doing so is safe, because the heap allocators initialize the pages they
> > receive before passing memory to the callers.
> >
> > Slowdown for the initialization features compared to init_on_free=3D0,
> > init_on_alloc=3D0:
> >
> > hackbench, init_on_free=3D1:  +6.84% sys time (st.err 0.74%)
> > hackbench, init_on_alloc=3D1: +7.25% sys time (st.err 0.72%)
> >
> > Linux build with -j12, init_on_free=3D1:  +8.52% wall time (st.err 0.42=
%)
> > Linux build with -j12, init_on_free=3D1:  +24.31% sys time (st.err 0.47=
%)
> > Linux build with -j12, init_on_alloc=3D1: -0.16% wall time (st.err 0.40=
%)
> > Linux build with -j12, init_on_alloc=3D1: +1.24% sys time (st.err 0.39%=
)
> >
> > The slowdown for init_on_free=3D0, init_on_alloc=3D0 compared to the
> > baseline is within the standard error.
> >
> > Signed-off-by: Alexander Potapenko <glider@google.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> > Cc: James Morris <jmorris@namei.org>
> > Cc: "Serge E. Hallyn" <serge@hallyn.com>
> > Cc: Nick Desaulniers <ndesaulniers@google.com>
> > Cc: Kostya Serebryany <kcc@google.com>
> > Cc: Dmitry Vyukov <dvyukov@google.com>
> > Cc: Kees Cook <keescook@chromium.org>
> > Cc: Sandeep Patil <sspatil@android.com>
> > Cc: Laura Abbott <labbott@redhat.com>
> > Cc: Randy Dunlap <rdunlap@infradead.org>
> > Cc: Jann Horn <jannh@google.com>
> > Cc: Mark Rutland <mark.rutland@arm.com>
> > Cc: linux-mm@kvack.org
> > Cc: linux-security-module@vger.kernel.org
> > Cc: kernel-hardening@lists.openwall.com
> > ---
> >  include/linux/gfp.h | 6 +++++-
> >  include/linux/mm.h  | 2 +-
> >  kernel/kexec_core.c | 2 +-
> >  mm/slab.c           | 2 +-
> >  mm/slob.c           | 3 ++-
> >  mm/slub.c           | 1 +
> >  6 files changed, 11 insertions(+), 5 deletions(-)
> >
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index fdab7de7490d..66d7f5604fe2 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -44,6 +44,7 @@ struct vm_area_struct;
> >  #else
> >  #define ___GFP_NOLOCKDEP       0
> >  #endif
> > +#define ___GFP_NOINIT          0x1000000u
>
> I mentioned this in the other patch, but I think this needs to be
> moved ahead of GFP_NOLOCKDEP and adjust the values for GFP_NOLOCKDEP
> and to leave the IS_ENABLED() test in __GFP_BITS_SHIFT alone.
Do we really need this blinking GFP_NOLOCKDEP bit at all?
This approach doesn't scale, we can't even have a second feature that
has a bit depending on the config settings.
Cannot we just fix the number of bits instead?

> >  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
> >
> >  /*
> > @@ -208,16 +209,19 @@ struct vm_area_struct;
> >   * %__GFP_COMP address compound page metadata.
> >   *
> >   * %__GFP_ZERO returns a zeroed page on success.
> > + *
> > + * %__GFP_NOINIT requests non-initialized memory from the underlying a=
llocator.
> >   */
> >  #define __GFP_NOWARN   ((__force gfp_t)___GFP_NOWARN)
> >  #define __GFP_COMP     ((__force gfp_t)___GFP_COMP)
> >  #define __GFP_ZERO     ((__force gfp_t)___GFP_ZERO)
> > +#define __GFP_NOINIT   ((__force gfp_t)___GFP_NOINIT)
> >
> >  /* Disable lockdep for GFP context tracking */
> >  #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
> >
> >  /* Room for N __GFP_FOO bits */
> > -#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
> > +#define __GFP_BITS_SHIFT (25)
>
> AIUI, this will break non-CONFIG_LOCKDEP kernels: it should just be:
>
> -#define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
> +#define __GFP_BITS_SHIFT (24 + IS_ENABLED(CONFIG_LOCKDEP))
>
> >  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
> >
> >  /**
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index ee1a1092679c..8ab152750eb4 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -2618,7 +2618,7 @@ DECLARE_STATIC_KEY_FALSE(init_on_alloc);
> >  static inline bool want_init_on_alloc(gfp_t flags)
> >  {
> >         if (static_branch_unlikely(&init_on_alloc))
> > -               return true;
> > +               return !(flags & __GFP_NOINIT);
> >         return flags & __GFP_ZERO;
>
> What do you think about renaming __GFP_NOINIT to __GFP_NO_AUTOINIT or som=
ething?
>
> Regardless, yes, this is nice.
>
> --
> Kees Cook



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

