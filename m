Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65130C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 08:57:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1254621530
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 08:57:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sGaOh+GQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1254621530
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9DC626B0005; Fri, 21 Jun 2019 04:57:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98C5C8E0002; Fri, 21 Jun 2019 04:57:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82DF98E0001; Fri, 21 Jun 2019 04:57:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6033B6B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 04:57:49 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id b23so1941050vsl.20
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 01:57:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=p0seZSpVgUNBPW28BWcr2U4E6EkfOYFjtnKpVitnWIY=;
        b=JjSyrHWfaM5T0pjvkWvlbBvFnkRUkXf/fEz4R/jm/8dkTSDg14JI7u1vfoMQG5E79W
         Tgse5wVpLtMSaquNw5M3IoBQ9S1uT6SKNvcPL+aivO/tqxU4/cn0852oDNXGIQUx0Y4B
         xct/BsWaYF/5bMchvLHyzb9K8gAlJ9DIIbL7tmgA7ovbfNyM1/kt9tMdyTfPu6zIDK7j
         6ewBeGQ5wl6V8FHgVbcvu1tXQzp2oRMeTEdQG96WbrCwOaUcbROIpotSWfaOnPekEutT
         NLj8bWo3zpJc/r19dJLECZh7uDZMmc0hUd0nn+Qjr51OLXIIU8QYA10oekWLVSX6I+1g
         y1Aw==
X-Gm-Message-State: APjAAAUaWMUELqfEIUvDKGFEvNddYgTw5OxVVtCWEhzCIHgW3e/+Ld84
	jmu7/sXxpMQSoAR4UHhOSJc38Gsw2jpGZypi84yd/XR/+lNrr1rLsqvM1WvQjiSw47XgqS1arJU
	dMCJIr1T+Wj939n1izDkqM/M+muzy7o8YPdvYXgGo36m3SDvVILzhnckyzA81ze01Yw==
X-Received: by 2002:a67:b919:: with SMTP id q25mr29197582vsn.18.1561107468978;
        Fri, 21 Jun 2019 01:57:48 -0700 (PDT)
X-Received: by 2002:a67:b919:: with SMTP id q25mr29197561vsn.18.1561107468242;
        Fri, 21 Jun 2019 01:57:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561107468; cv=none;
        d=google.com; s=arc-20160816;
        b=uddtwdLVGmMUyD6sg5Tn61Wr5u0/2BmRaz6M+Ybl2i7jlDhzhg+kZ0EMhvup2dgI/Z
         iR/GGJMksO56i6LD+5s9VbYTbEOSCnXpXVcrGCkAwB3H6pFRsz8Uty+183EvJuJh1QqP
         p1WSaEXRwVAg9E0YAYYChWpXEbkQy72BsaZhfivUKw7wIzXfozPNj6brSldVU16/qM5O
         +GrarQDXLphklPyTju5e6dTNSWpDuODcAyqn/mcEFpmXh0qOABdsWSeKByMhX1qiKMXe
         L5yl4ryoytTERuayMQWak2qz1Y5cw9tPGdMehGghjugjxwa5moGQmRxwMtKE8gPPE881
         /GNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=p0seZSpVgUNBPW28BWcr2U4E6EkfOYFjtnKpVitnWIY=;
        b=QUAWwP53wKp31+6s9OTP6jyYxwelIL3MSRxOrsFs0TjgA2U40MNXmm/tGcQrwv3hco
         f3vWZhYyUWdkLdS5AHa5O0LDXxRep65FrT7nmM8Arapvi/JL9UZJqcPdt+obw2o+x1QV
         sPKkeOHs1/BjBOrUsmFWI/GJ63Nvv40WaNe9z93dve9d+ScJP8CJh6glRamWPe7ySO4s
         z4SJKjvNo+Ym8rRQCTu0jFBOUI8A0xjq7nMr91el/VmVisigPklYr2VMx0iDszrprbwb
         pw7MQuv4lXUKQTFGrJLVgwWLyiULakeyX3Cd37L7s1An3OgIrX9nnkimKvPpWIpGNw0w
         4pWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sGaOh+GQ;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n1sor1215709uad.28.2019.06.21.01.57.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 01:57:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sGaOh+GQ;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=p0seZSpVgUNBPW28BWcr2U4E6EkfOYFjtnKpVitnWIY=;
        b=sGaOh+GQBP49uUyoJOZ9+Asi6u5yGz2ONKs00ljT7XJJE+2213mnLgebU2M+3Dw2ad
         gNxoHMcK9jZIXpsL9KlAeK1a7fP3c+b5AmXoRQmC5wFjy2wtGorZUbqhTyVNcC68Qkxg
         cxA9HPIOSjsGrQ1MPi3VJQWGu9w9G5oQTlkvAxyVCSy5w3xPA/tM4H20JkP1We3ufkXd
         cvQt1NGxK+jQiqh3pG3X8tCPKSPVaH1YTWoM/1CLcjAr13ShP7BJjJUgQhdRYnaW2rdp
         hoi4WHrMXYyWABEgsKSCNSS4nT7ZoZT0xiDb9kOeDpsWGZsWooJKrocGq/DiNus8tGH+
         dUWw==
X-Google-Smtp-Source: APXvYqwDXcF8Q+Kmw8HmTuNq/UhEJosCDSBhSR6JfC+oGEZCEL/m2PiH3U3TeICGfLD3w3LljE+CxBA/BEL2eL8RePs=
X-Received: by 2002:ab0:64cc:: with SMTP id j12mr7182070uaq.110.1561107467551;
 Fri, 21 Jun 2019 01:57:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190617151050.92663-1-glider@google.com> <20190617151050.92663-2-glider@google.com>
 <20190621070905.GA3429@dhcp22.suse.cz>
In-Reply-To: <20190621070905.GA3429@dhcp22.suse.cz>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 21 Jun 2019 10:57:35 +0200
Message-ID: <CAG_fn=UFj0Lzy3FgMV_JBKtxCiwE03HVxnR8=f9a7=4nrUFXSw@mail.gmail.com>
Subject: Re: [PATCH v7 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Nick Desaulniers <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 9:09 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 17-06-19 17:10:49, Alexander Potapenko wrote:
> > The new options are needed to prevent possible information leaks and
> > make control-flow bugs that depend on uninitialized values more
> > deterministic.
> >
> > init_on_alloc=3D1 makes the kernel initialize newly allocated pages and=
 heap
> > objects with zeroes. Initialization is done at allocation time at the
> > places where checks for __GFP_ZERO are performed.
> >
> > init_on_free=3D1 makes the kernel initialize freed pages and heap objec=
ts
> > with zeroes upon their deletion. This helps to ensure sensitive data
> > doesn't leak via use-after-free accesses.
> >
> > Both init_on_alloc=3D1 and init_on_free=3D1 guarantee that the allocato=
r
> > returns zeroed memory. The two exceptions are slab caches with
> > constructors and SLAB_TYPESAFE_BY_RCU flag. Those are never
> > zero-initialized to preserve their semantics.
> >
> > Both init_on_alloc and init_on_free default to zero, but those defaults
> > can be overridden with CONFIG_INIT_ON_ALLOC_DEFAULT_ON and
> > CONFIG_INIT_ON_FREE_DEFAULT_ON.
> >
> > Slowdown for the new features compared to init_on_free=3D0,
> > init_on_alloc=3D0:
> >
> > hackbench, init_on_free=3D1:  +7.62% sys time (st.err 0.74%)
> > hackbench, init_on_alloc=3D1: +7.75% sys time (st.err 2.14%)
> >
> > Linux build with -j12, init_on_free=3D1:  +8.38% wall time (st.err 0.39=
%)
> > Linux build with -j12, init_on_free=3D1:  +24.42% sys time (st.err 0.52=
%)
> > Linux build with -j12, init_on_alloc=3D1: -0.13% wall time (st.err 0.42=
%)
> > Linux build with -j12, init_on_alloc=3D1: +0.57% sys time (st.err 0.40%=
)
> >
> > The slowdown for init_on_free=3D0, init_on_alloc=3D0 compared to the
> > baseline is within the standard error.
> >
> > The new features are also going to pave the way for hardware memory
> > tagging (e.g. arm64's MTE), which will require both on_alloc and on_fre=
e
> > hooks to set the tags for heap objects. With MTE, tagging will have the
> > same cost as memory initialization.
> >
> > Although init_on_free is rather costly, there are paranoid use-cases wh=
ere
> > in-memory data lifetime is desired to be minimized. There are various
> > arguments for/against the realism of the associated threat models, but
> > given that we'll need the infrastructre for MTE anyway, and there are
> > people who want wipe-on-free behavior no matter what the performance co=
st,
> > it seems reasonable to include it in this series.
>
> Thanks for reworking the original implemenation. This looks much better!
>
> > Signed-off-by: Alexander Potapenko <glider@google.com>
> > Acked-by: Kees Cook <keescook@chromium.org>
> > To: Andrew Morton <akpm@linux-foundation.org>
> > To: Christoph Lameter <cl@linux.com>
> > To: Kees Cook <keescook@chromium.org>
> > Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: James Morris <jmorris@namei.org>
> > Cc: "Serge E. Hallyn" <serge@hallyn.com>
> > Cc: Nick Desaulniers <ndesaulniers@google.com>
> > Cc: Kostya Serebryany <kcc@google.com>
> > Cc: Dmitry Vyukov <dvyukov@google.com>
> > Cc: Sandeep Patil <sspatil@android.com>
> > Cc: Laura Abbott <labbott@redhat.com>
> > Cc: Randy Dunlap <rdunlap@infradead.org>
> > Cc: Jann Horn <jannh@google.com>
> > Cc: Mark Rutland <mark.rutland@arm.com>
> > Cc: Marco Elver <elver@google.com>
> > Cc: linux-mm@kvack.org
> > Cc: linux-security-module@vger.kernel.org
> > Cc: kernel-hardening@lists.openwall.com
>
> Acked-by: Michal Hocko <mhocko@suse.cz> # page allocator parts.
>
> kmalloc based parts look good to me as well but I am not sure I fill
> qualified to give my ack there without much more digging and I do not
> have much time for that now.
>
> [...]
> > diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> > index fd5c95ff9251..2f75dd0d0d81 100644
> > --- a/kernel/kexec_core.c
> > +++ b/kernel/kexec_core.c
> > @@ -315,7 +315,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_ma=
sk, unsigned int order)
> >               arch_kexec_post_alloc_pages(page_address(pages), count,
> >                                           gfp_mask);
> >
> > -             if (gfp_mask & __GFP_ZERO)
> > +             if (want_init_on_alloc(gfp_mask))
> >                       for (i =3D 0; i < count; i++)
> >                               clear_highpage(pages + i);
> >       }
>
> I am not really sure I follow here. Why do we want to handle
> want_init_on_alloc here? The allocated memory comes from the page
> allocator and so it will get zeroed there. arch_kexec_post_alloc_pages
> might touch the content there but is there any actual risk of any kind
> of leak?
You're right, we don't want to initialize this memory if init_on_alloc is o=
n.
We need something along the lines of:
  if (!static_branch_unlikely(&init_on_alloc))
    if (gfp_mask & __GFP_ZERO)
      // clear the pages

Another option would be to disable initialization in alloc_pages() using a =
flag.
>
> > diff --git a/mm/dmapool.c b/mm/dmapool.c
> > index 8c94c89a6f7e..e164012d3491 100644
> > --- a/mm/dmapool.c
> > +++ b/mm/dmapool.c
> > @@ -378,7 +378,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t m=
em_flags,
> >  #endif
> >       spin_unlock_irqrestore(&pool->lock, flags);
> >
> > -     if (mem_flags & __GFP_ZERO)
> > +     if (want_init_on_alloc(mem_flags))
> >               memset(retval, 0, pool->size);
> >
> >       return retval;
>
> Don't you miss dma_pool_free and want_init_on_free?
Agreed.
I'll fix this and add tests for DMA pools as well.
> --
> Michal Hocko
> SUSE Labs



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

