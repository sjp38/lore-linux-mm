Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20D1BC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:10:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4F5C21655
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:10:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dr9Z+fBW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4F5C21655
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BC4E8E0006; Fri, 21 Jun 2019 10:10:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56DA88E0001; Fri, 21 Jun 2019 10:10:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45CA28E0006; Fri, 21 Jun 2019 10:10:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 222728E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:10:34 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id d143so2491304vkf.10
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:10:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=wrdEXo/dZqG2VBBEHjkm9umzSYOAuCCoFiPBOZwieBA=;
        b=mw2vaYaR0StmtCTA8xPMiCij+oviIZmUcfLAsOkEujFfSwkAVlZqDOWlcfXRmNwfPl
         p/xSwnrAXpQ03KjQZCpbCWSUcCZF6MONuS8ki4boJt6z/lavsbGC0f2KQ2WcoEkjDXzk
         S77pPyXF1/RZBm5u8yx+91G4IfBl35HrTP2eSRsisBfDj5upxddJsR+s2WqsyjmGEFic
         InUkuxLC+lPvg4wC1z5JyDLfdsZhinc8R8Wo983qdoVUPIjB2jtiCdlYvWTOh9r5Uq/j
         ymyK8hBiTbPJJCUt57oN05m34emZv3CUWjbPKQjm/LK/Pr6BHOs8DrcWKZ3GlvBMbHEB
         TsQQ==
X-Gm-Message-State: APjAAAXoiGMTiV7dpTXuozJLUt31UKTeiTh2LB2/rYbE6rykXudHT8u6
	F39H080PNc6gAkXta5s6q9ffhIQYn/xC8Vz2Bf9uSvOrw32p9hKVK8OGdLDvtun4mvdSpxZMk/p
	IFpevxCQ24N4ARf0OBCsA1nUd8ho9nosMGb3QgGavQa0+FrVMuIPSerUOPNynOCqS0w==
X-Received: by 2002:a67:fc19:: with SMTP id o25mr9263943vsq.106.1561126233759;
        Fri, 21 Jun 2019 07:10:33 -0700 (PDT)
X-Received: by 2002:a67:fc19:: with SMTP id o25mr9263900vsq.106.1561126233064;
        Fri, 21 Jun 2019 07:10:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561126233; cv=none;
        d=google.com; s=arc-20160816;
        b=neCjhcOL0swBVY4EibzJGSgISYIV319knMeDoG7CZGQSXG6g2PW70qgLfSRrIvxraJ
         FqzJSU6IHrSk+KT82YVwFwn0X5P/X8DReaQ1gCy2Q1zp93kAj5pKrbLHZqRLjLccBRJ7
         o6JWGxByd73x7JGKF/wkEvGi9gN/J3OTY5BI+Ffh/Fg7plKXcfAGUaEOMoBZ4pjLlsiP
         nTqmLpOIAj6YtdcJCl4ZKBaIvV/5up3bG0jlt9e356LUF/vQQUOf8apId+XZP+87qRo3
         X3bWD0pYOwI3d89uoHRQgDsHR0IU2gDNwaugMTycqk/IldrVgvPIsQUC8vssw8STqsL6
         SLTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=wrdEXo/dZqG2VBBEHjkm9umzSYOAuCCoFiPBOZwieBA=;
        b=ciDifBBC0j3zqh8Evsst3MTIvrYrk7V+HjNeKzO3cy2O9ZshjhchlAZgw5BriUAM0L
         pcHOLdlOSboev3jfx/DXglp86BUvFl8LOGaO7o5WC29djqmD0Yb791VBCUzk8djc8bxZ
         eN+vutvMm+xfL2gScwC782GedWpHgKyzcPIHKoTgQwSV3PjoqR2MHFJZnAoy+8A2t2yt
         wgqL7QtcvYI7GD3hVdOZ2S+eaLI8XSs6YENEwaMU2xJ1RwzRnLZqkD65PEpucRJpnn9v
         8g8mA3mlicPCvlpFk0ByREGJnBjo0Bzh06MV0trMyj+C88F0ue4oxhkpP82dvXh8gt/1
         rYGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dr9Z+fBW;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y16sor1683052uar.63.2019.06.21.07.10.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 07:10:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dr9Z+fBW;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=wrdEXo/dZqG2VBBEHjkm9umzSYOAuCCoFiPBOZwieBA=;
        b=dr9Z+fBW/EL/AboE8tYKHBbokfp7cBhVBj2BeXnlM1sNnJU1yZlEYPW1v7VnYnKD9g
         ZoirrFWGixiGN+pWwZxclknn52BNiexn12gfKsWELbai6du00S32lG11y9VkdYvjJre6
         hn/PQ0y4vh8xEAQ1969NI/lVFAr2MpC9p8hAxiUHZ5yCuKRR8s6NSS0qWzbKa/tZdcKY
         pFoj6FwVdsVghIlnlg1Y1yX0tRba/aWQxKlaLcDk9nClMescS+5hR0AA6vC4P4W5/8EF
         XWVv9SmWCE9OsKTIGo8j8/Mer2OwCmb7jpFGnELQrvt9PuGOfEALHhGoUGNk2mgspI9o
         i4ag==
X-Google-Smtp-Source: APXvYqz/CH5RLWc9rguyLew76C+m4hWG0I8vzrW686B60RxUfjgG1yOUxMREVPBIXgPDhj1lf7iqdrOvdYXQfkzWbqM=
X-Received: by 2002:ab0:308c:: with SMTP id h12mr6056804ual.72.1561126232440;
 Fri, 21 Jun 2019 07:10:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190617151050.92663-1-glider@google.com> <20190617151050.92663-2-glider@google.com>
 <20190621070905.GA3429@dhcp22.suse.cz> <CAG_fn=UFj0Lzy3FgMV_JBKtxCiwE03HVxnR8=f9a7=4nrUFXSw@mail.gmail.com>
In-Reply-To: <CAG_fn=UFj0Lzy3FgMV_JBKtxCiwE03HVxnR8=f9a7=4nrUFXSw@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 21 Jun 2019 16:10:19 +0200
Message-ID: <CAG_fn=W90HNeZ0UcUctnbUBzJ=_b+gxMGdUoDyO3JPoyy4dGSg@mail.gmail.com>
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

On Fri, Jun 21, 2019 at 10:57 AM Alexander Potapenko <glider@google.com> wr=
ote:
>
> On Fri, Jun 21, 2019 at 9:09 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 17-06-19 17:10:49, Alexander Potapenko wrote:
> > > The new options are needed to prevent possible information leaks and
> > > make control-flow bugs that depend on uninitialized values more
> > > deterministic.
> > >
> > > init_on_alloc=3D1 makes the kernel initialize newly allocated pages a=
nd heap
> > > objects with zeroes. Initialization is done at allocation time at the
> > > places where checks for __GFP_ZERO are performed.
> > >
> > > init_on_free=3D1 makes the kernel initialize freed pages and heap obj=
ects
> > > with zeroes upon their deletion. This helps to ensure sensitive data
> > > doesn't leak via use-after-free accesses.
> > >
> > > Both init_on_alloc=3D1 and init_on_free=3D1 guarantee that the alloca=
tor
> > > returns zeroed memory. The two exceptions are slab caches with
> > > constructors and SLAB_TYPESAFE_BY_RCU flag. Those are never
> > > zero-initialized to preserve their semantics.
> > >
> > > Both init_on_alloc and init_on_free default to zero, but those defaul=
ts
> > > can be overridden with CONFIG_INIT_ON_ALLOC_DEFAULT_ON and
> > > CONFIG_INIT_ON_FREE_DEFAULT_ON.
> > >
> > > Slowdown for the new features compared to init_on_free=3D0,
> > > init_on_alloc=3D0:
> > >
> > > hackbench, init_on_free=3D1:  +7.62% sys time (st.err 0.74%)
> > > hackbench, init_on_alloc=3D1: +7.75% sys time (st.err 2.14%)
> > >
> > > Linux build with -j12, init_on_free=3D1:  +8.38% wall time (st.err 0.=
39%)
> > > Linux build with -j12, init_on_free=3D1:  +24.42% sys time (st.err 0.=
52%)
> > > Linux build with -j12, init_on_alloc=3D1: -0.13% wall time (st.err 0.=
42%)
> > > Linux build with -j12, init_on_alloc=3D1: +0.57% sys time (st.err 0.4=
0%)
> > >
> > > The slowdown for init_on_free=3D0, init_on_alloc=3D0 compared to the
> > > baseline is within the standard error.
> > >
> > > The new features are also going to pave the way for hardware memory
> > > tagging (e.g. arm64's MTE), which will require both on_alloc and on_f=
ree
> > > hooks to set the tags for heap objects. With MTE, tagging will have t=
he
> > > same cost as memory initialization.
> > >
> > > Although init_on_free is rather costly, there are paranoid use-cases =
where
> > > in-memory data lifetime is desired to be minimized. There are various
> > > arguments for/against the realism of the associated threat models, bu=
t
> > > given that we'll need the infrastructre for MTE anyway, and there are
> > > people who want wipe-on-free behavior no matter what the performance =
cost,
> > > it seems reasonable to include it in this series.
> >
> > Thanks for reworking the original implemenation. This looks much better=
!
> >
> > > Signed-off-by: Alexander Potapenko <glider@google.com>
> > > Acked-by: Kees Cook <keescook@chromium.org>
> > > To: Andrew Morton <akpm@linux-foundation.org>
> > > To: Christoph Lameter <cl@linux.com>
> > > To: Kees Cook <keescook@chromium.org>
> > > Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: James Morris <jmorris@namei.org>
> > > Cc: "Serge E. Hallyn" <serge@hallyn.com>
> > > Cc: Nick Desaulniers <ndesaulniers@google.com>
> > > Cc: Kostya Serebryany <kcc@google.com>
> > > Cc: Dmitry Vyukov <dvyukov@google.com>
> > > Cc: Sandeep Patil <sspatil@android.com>
> > > Cc: Laura Abbott <labbott@redhat.com>
> > > Cc: Randy Dunlap <rdunlap@infradead.org>
> > > Cc: Jann Horn <jannh@google.com>
> > > Cc: Mark Rutland <mark.rutland@arm.com>
> > > Cc: Marco Elver <elver@google.com>
> > > Cc: linux-mm@kvack.org
> > > Cc: linux-security-module@vger.kernel.org
> > > Cc: kernel-hardening@lists.openwall.com
> >
> > Acked-by: Michal Hocko <mhocko@suse.cz> # page allocator parts.
> >
> > kmalloc based parts look good to me as well but I am not sure I fill
> > qualified to give my ack there without much more digging and I do not
> > have much time for that now.
> >
> > [...]
> > > diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> > > index fd5c95ff9251..2f75dd0d0d81 100644
> > > --- a/kernel/kexec_core.c
> > > +++ b/kernel/kexec_core.c
> > > @@ -315,7 +315,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_=
mask, unsigned int order)
> > >               arch_kexec_post_alloc_pages(page_address(pages), count,
> > >                                           gfp_mask);
> > >
> > > -             if (gfp_mask & __GFP_ZERO)
> > > +             if (want_init_on_alloc(gfp_mask))
> > >                       for (i =3D 0; i < count; i++)
> > >                               clear_highpage(pages + i);
> > >       }
> >
> > I am not really sure I follow here. Why do we want to handle
> > want_init_on_alloc here? The allocated memory comes from the page
> > allocator and so it will get zeroed there. arch_kexec_post_alloc_pages
> > might touch the content there but is there any actual risk of any kind
> > of leak?
> You're right, we don't want to initialize this memory if init_on_alloc is=
 on.
> We need something along the lines of:
>   if (!static_branch_unlikely(&init_on_alloc))
>     if (gfp_mask & __GFP_ZERO)
>       // clear the pages
>
> Another option would be to disable initialization in alloc_pages() using =
a flag.
> >
> > > diff --git a/mm/dmapool.c b/mm/dmapool.c
> > > index 8c94c89a6f7e..e164012d3491 100644
> > > --- a/mm/dmapool.c
> > > +++ b/mm/dmapool.c
> > > @@ -378,7 +378,7 @@ void *dma_pool_alloc(struct dma_pool *pool, gfp_t=
 mem_flags,
> > >  #endif
> > >       spin_unlock_irqrestore(&pool->lock, flags);
> > >
> > > -     if (mem_flags & __GFP_ZERO)
> > > +     if (want_init_on_alloc(mem_flags))
> > >               memset(retval, 0, pool->size);
> > >
> > >       return retval;
> >
> > Don't you miss dma_pool_free and want_init_on_free?
> Agreed.
> I'll fix this and add tests for DMA pools as well.
This doesn't seem to be easy though. One needs a real DMA-capable
device to allocate using DMA pools.
On the other hand, what happens to a DMA pool when it's destroyed,
isn't it wiped by pagealloc?

I'm inclined towards not touching mm/dmapool.c in this patch series,
as it is probably orthogonal to the idea of hardening the
heap/pagealloc.
> > --
> > Michal Hocko
> > SUSE Labs
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



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

