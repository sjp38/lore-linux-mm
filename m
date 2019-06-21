Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A234EC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 09:18:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65DAB20665
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 09:18:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eJHRiZPt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65DAB20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E881F6B0005; Fri, 21 Jun 2019 05:18:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E38BE8E0002; Fri, 21 Jun 2019 05:18:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D26BD8E0001; Fri, 21 Jun 2019 05:18:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id AAA276B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 05:18:18 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id d1so713236uak.23
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 02:18:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=NOA7F+74ao7xItWlpCMzlTnVq8LgdylLejX+BF9m8ic=;
        b=QJH0zDDlrTbXWiaYFcab2yjNtJUv/0LT3MW7ehA2AIsvpX7AArVRGQ7JV3JSu42LzK
         vEE9aqgRDidy4ZtZzPvZEaiR4JqerQb8fwD6adm46E7CFsZtPDFWKxeNzlzzLUtMkZ51
         AFJrVTuIvf33md+nhhTXB2xzAgiW7+SMclw2zFCZvc8h2Ma3ge/rbS30IJhrWAGKnifM
         pvG1V/E46/2HWu2pql/FRRKsGN4ZO68IpPnxtBUzvjZO6tGVoWHt1EZ5FimCeQedTbor
         tubSHiV0tZzUgYLsrPpDyrAQ/vdETTdC/khrZxmi4Y/8wkOZVhX/851GEnXZmlYJXNPd
         ksfA==
X-Gm-Message-State: APjAAAXSgPGkk41/xkSF9qCQrrF0rYL9UbE2onBy7nlFKwPFjvZqbVrz
	DVefDGHspNKO3xSyDtzK6XGSl3nODNPQ/+yNDU88sSYQ5px1pq9Fq5nw/cAobjpGqyZ1PIIeM1Y
	Vu+YgLfbVrZAojnCZykMXsnbpSQ53M63jOAwyBOe8iMgzdjwuuJ3MjV3dyT2MnSd8VA==
X-Received: by 2002:a9f:326e:: with SMTP id y43mr14376861uad.4.1561108698332;
        Fri, 21 Jun 2019 02:18:18 -0700 (PDT)
X-Received: by 2002:a9f:326e:: with SMTP id y43mr14376828uad.4.1561108697806;
        Fri, 21 Jun 2019 02:18:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561108697; cv=none;
        d=google.com; s=arc-20160816;
        b=XdRsxHLeQz9eCDXjuCiKWviUma5POSgmokxspC3n15igFLZxQMhpT2xIu0O8Oip+uD
         RG7seUBc2UKO9I1idXsJymRt590r9b+Dbgf1FzafsS3PhDlSr1b8Gk5IYpyiZr8J3jnN
         LZShagxESvAVcpcq05ot4eaoZXmKAx7MFCqCItdgibApiF+Kg/c0PVHd1hTNl2SXwB/f
         PnFT6DLzJOBnW4iU32qCuAc7e7hi/cQcJFVUqspnbO9/dHqc/nqQCJ3dLZYfqFqH/D/J
         OSi2qIdofEPJdkena2IHPaLNTVeAhaOBe15Z+6Iby76Mi+apZSLxViXpCRJxzZ+RRv5+
         zHSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=NOA7F+74ao7xItWlpCMzlTnVq8LgdylLejX+BF9m8ic=;
        b=RWgcpp4h9E3dFb5HFn6sn76c9CMgN1dUf4ItlEX04axp6uGuyHsMtkXf1DYmc1/SvI
         mIUx87OhaoHcKgu+ikXQXQjrfk6UaYFzqXzjOu3XR/I4/CaOTRLXH8Y31ZCVgKKLkZM7
         wn746uocPxRHRnhuy58esqtfIYCvrjDZ2NYUhrjuGsqdpnrlp3Itsz31MLG2ntuMXke8
         YHmUBusH1+bMTn88g5Okf0u1alAYdGYQJZodMmOUN+zvu4iMXWcjgYla7fX7gQh8GwpS
         I9MuGm0xwymVpgad9aihZ/Do86532wdqrrDZ338lW9xzgiJKPjwFyn7QjkE9g17dyVKP
         Cllw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eJHRiZPt;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y1sor1077351vsi.53.2019.06.21.02.18.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 02:18:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=eJHRiZPt;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=NOA7F+74ao7xItWlpCMzlTnVq8LgdylLejX+BF9m8ic=;
        b=eJHRiZPtw/d7axvsQeCGaSQlLwSR3EzO3fA4AyvotmmVB+jkv8BvAOub0dpbDsecU8
         XHWlhZlAu3ccxEtYssD63iqhae7pZHrR3prAg5R2v8zh3O37uGqvndnkscxUbANPolGX
         bkgYFVR+TtJRuYEFR91PWHKZdLtmLSB3ulWq/ifj4a0ccjQ/BrLqeIjtyHLy6fsKuO5r
         2N5VWOBB8S0POJaHSQZDQkhZNCbCwPfHvdqAi6JvKvbls39a1fwHpCB95DmBjGzD3XOY
         zPceflY9rG1zjrdnY4mxSeTATcwQwVtTAT4hhiaEXS6v1zKQoJAyqc4t/yidcw24sfFk
         ymNA==
X-Google-Smtp-Source: APXvYqwd4qZYIVgmr5b8Xmp9jXK08gGTYRL0mOMr/IXslodesRYa3VNJ2znEn4tLbyfGSeteJkHHrP0+paaz0A9sgxc=
X-Received: by 2002:a67:2ec8:: with SMTP id u191mr15058824vsu.39.1561108697273;
 Fri, 21 Jun 2019 02:18:17 -0700 (PDT)
MIME-Version: 1.0
References: <20190617151050.92663-1-glider@google.com> <20190617151050.92663-2-glider@google.com>
 <20190621070905.GA3429@dhcp22.suse.cz> <CAG_fn=UFj0Lzy3FgMV_JBKtxCiwE03HVxnR8=f9a7=4nrUFXSw@mail.gmail.com>
 <20190621091159.GD3429@dhcp22.suse.cz>
In-Reply-To: <20190621091159.GD3429@dhcp22.suse.cz>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 21 Jun 2019 11:18:06 +0200
Message-ID: <CAG_fn=Vhn4x_wVcftQUC4wh4JOgy8budA4+jj=dnRpPwqEz2TA@mail.gmail.com>
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

On Fri, Jun 21, 2019 at 11:12 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 21-06-19 10:57:35, Alexander Potapenko wrote:
> > On Fri, Jun 21, 2019 at 9:09 AM Michal Hocko <mhocko@kernel.org> wrote:
> [...]
> > > > diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> > > > index fd5c95ff9251..2f75dd0d0d81 100644
> > > > --- a/kernel/kexec_core.c
> > > > +++ b/kernel/kexec_core.c
> > > > @@ -315,7 +315,7 @@ static struct page *kimage_alloc_pages(gfp_t gf=
p_mask, unsigned int order)
> > > >               arch_kexec_post_alloc_pages(page_address(pages), coun=
t,
> > > >                                           gfp_mask);
> > > >
> > > > -             if (gfp_mask & __GFP_ZERO)
> > > > +             if (want_init_on_alloc(gfp_mask))
> > > >                       for (i =3D 0; i < count; i++)
> > > >                               clear_highpage(pages + i);
> > > >       }
> > >
> > > I am not really sure I follow here. Why do we want to handle
> > > want_init_on_alloc here? The allocated memory comes from the page
> > > allocator and so it will get zeroed there. arch_kexec_post_alloc_page=
s
> > > might touch the content there but is there any actual risk of any kin=
d
> > > of leak?
> > You're right, we don't want to initialize this memory if init_on_alloc =
is on.
> > We need something along the lines of:
> >   if (!static_branch_unlikely(&init_on_alloc))
> >     if (gfp_mask & __GFP_ZERO)
> >       // clear the pages
> >
> > Another option would be to disable initialization in alloc_pages() usin=
g a flag.
>
> Or we can simply not care and keen the code the way it is. First of all
> it seems that nobody actually does use __GFP_ZERO unless I have missed
> soemthing
>         - kimage_alloc_pages(KEXEC_CONTROL_MEMORY_GFP, order); # GFP_KERN=
EL | __GFP_NORETRY
>         - kimage_alloc_pages(gfp_mask, 0);
>                 - kimage_alloc_page(image, GFP_KERNEL, KIMAGE_NO_DEST);
>                 - kimage_alloc_page(image, GFP_HIGHUSER, maddr);
>
> but even if we actually had a user do we care about double intialization
> for something kexec related? It is not any hot path AFAIR.
Yes, sounds good. Spraying the code with too many checks for
init_on_alloc doesn't really look nice.

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

