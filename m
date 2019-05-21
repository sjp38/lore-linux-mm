Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F32A7C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:18:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A74132173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 14:18:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="NTJztX72"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A74132173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 397846B0003; Tue, 21 May 2019 10:18:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 322DC6B0006; Tue, 21 May 2019 10:18:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C1B56B0007; Tue, 21 May 2019 10:18:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id E54506B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 10:18:50 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id q6so4268319vsn.11
        for <linux-mm@kvack.org>; Tue, 21 May 2019 07:18:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=qtX9Hg9OdKmNACjDNc2C4CJaIyLblfI3YJJML4Ge4iM=;
        b=BXbCSDb9j2OJEURfuZsm2bskuOGvQHSs3bbcO3hJ0uz5B59y0ohBgVZzBtchJ8aKky
         GTEoXzHzUeZfdP2QpYj/97wy/wW3PdnRe6xit5vGI3o7zd3PuFKRd4hAfNRcVtwM/itz
         qni2FsTyMniq6yKMC4Wo1jB7X3HprqRvVamcIsyxgkldd7k6H/E0UUVP9Iv/M+xhPkcW
         6xzYXl65ob5NWP3rRRoR6oRoM1QrwHwDMY+qP+czPpAgacE8iwjhJ84uPo3kSnw1b6EM
         wpx/Qgslr5P0kR+Sn4lrIxGU9ZR0aiZg2bsXOA5+kH71YC7fmugZycjeUI33ddsL/ZiJ
         z8Vg==
X-Gm-Message-State: APjAAAWq4HC8MVhCZAqSv02KbN7TImCcVdHIuM8Sa4FxCS+OBGdCp1ge
	MynZ70qtFeWIFEBeo5fkkwEZVFpEszj4i6SiAcv+qflZN6oy9+EknbKD4qR+lYsqFFz/pIuu+6K
	ykj3/x8vMIbPmtopcl7E+dTUfb6w4c/BWmRwLFgaRETAHAtVVdOwyQMBlt2ZSImjaxg==
X-Received: by 2002:a67:e9cd:: with SMTP id q13mr13096384vso.129.1558448330516;
        Tue, 21 May 2019 07:18:50 -0700 (PDT)
X-Received: by 2002:a67:e9cd:: with SMTP id q13mr13096343vso.129.1558448329678;
        Tue, 21 May 2019 07:18:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558448329; cv=none;
        d=google.com; s=arc-20160816;
        b=qG5tcEVq2xsn10qIPpV8WhjtRAZFKgOXyKbo0a48KF89dc1M5sxXy9QTQInS0RDwMj
         rhsksIMkUKbLNfEJkbFEYM25pqiMDUTBB9WCO124z70jyjEQZFmDNPNi9rLq74SrJRoS
         fvGvwQDELsFTn24884uFg0i2rUmJyxKNelxrZMNq0UpOpC9ZntwvH+S3JHycqSGLQ5XK
         SUhaINeHrYEnf/Jjk4JngVHlXoISTqkP6uVU4JYhBT9tjjvIc5c2stFcPOWCO6YKhfn2
         a7JmhzgLGlLFtyv9KYFt/LJbfd27QVbLjgrpV7lmiOqWNtqQ+xxULOaxVKDjhF8D2Xe9
         qjmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=qtX9Hg9OdKmNACjDNc2C4CJaIyLblfI3YJJML4Ge4iM=;
        b=c9/GnCiQPjBuliAQdPLs3vkT6f6Z9IWovI6EKGHnHY93wjy50rLyg2ZhozTomXTrZz
         UjBgfMAXJSRh5NmGnmhgyZXgicYJLyjNjBNxV49atppTq8QXhmKBCSp0VQ1OPAM0NSPO
         kb+WVl6SeYiEpB4hwQ6gApJ6C4cIsdt/f6Mke0zMJ6OzhDIl8fbFq/dE8UtxS9GNUW2x
         Et+7eZFZ8v2yFm6uaaIgkCzEgs8NMSZmlMIdaFXj+87b83SEQLZcBalqsJBsSaabZD6K
         pFF7RTaU3J0XpChqCkASjp7P6R/CqYLU8wBH2Pek09NaU0UBnB6YJBYS1dlmZjD5rSFi
         O1xg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NTJztX72;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d206sor618344vsc.106.2019.05.21.07.18.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 07:18:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=NTJztX72;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=qtX9Hg9OdKmNACjDNc2C4CJaIyLblfI3YJJML4Ge4iM=;
        b=NTJztX72UA9iNvFngsBwxBL+hTK1rrcc6O8IJk9ixFH6J0FNp+KDxT2l5NAaWCrUYD
         LvZeaWVrXsPRyJNTE85kXQuuwnnSpoMidAeqsK1cy/eapyZIpM2Q6lWpgQB6gWR9T7TY
         d/tg1j2PhleWIfSNzUEqq0OKSSZ7niWgXj2xrErR4yEu52O7uBJMZ12GX+PZ27NGJm0w
         8puc+SYingWJmZFwyKXeF8B1nyUvy6aQ+1j3X6Dz+MeeTw9epsRiWJ1zDDd02Ovj1Rqt
         oLGs11YfWQOi2X7+m43sXBbI6GNJJDJsq/dvx1E3ZwyRK+72xuKM8wLHYmkt2u6eeV2H
         g5Mg==
X-Google-Smtp-Source: APXvYqwKOTGXRYs34MOtbc1g3kDsxubZ5iCKp4Y0aBRDYqNVHnTecFwIZa7kAkIjkyfwnIPq354glnHuQC3BMacUY0c=
X-Received: by 2002:a67:e401:: with SMTP id d1mr1438945vsf.103.1558448328921;
 Tue, 21 May 2019 07:18:48 -0700 (PDT)
MIME-Version: 1.0
References: <20190514143537.10435-1-glider@google.com> <20190514143537.10435-4-glider@google.com>
 <20190517125916.GF1825@dhcp22.suse.cz> <CAG_fn=VG6vrCdpEv0g73M-Au4wW07w8g0uydEiHA96QOfcCVhA@mail.gmail.com>
 <20190517132542.GJ6836@dhcp22.suse.cz> <CAG_fn=Ve88z2ezFjV6CthufMUhJ-ePNMT2=3m6J3nHWh9iSgsg@mail.gmail.com>
 <20190517140108.GK6836@dhcp22.suse.cz> <201905170925.6FD47DDFFF@keescook> <20190517171105.GT6836@dhcp22.suse.cz>
In-Reply-To: <20190517171105.GT6836@dhcp22.suse.cz>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 21 May 2019 16:18:37 +0200
Message-ID: <CAG_fn=W9Y7=RZREi5S8z-sAMg2GfPsWqrHo+UawXWiRbhrNd0Q@mail.gmail.com>
Subject: Re: [PATCH v2 3/4] gfp: mm: introduce __GFP_NO_AUTOINIT
To: Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Souptick Joarder <jrdr.linux@gmail.com>, 
	Matthew Wilcox <willy@infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 7:11 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 17-05-19 09:27:54, Kees Cook wrote:
> > On Fri, May 17, 2019 at 04:01:08PM +0200, Michal Hocko wrote:
> > > On Fri 17-05-19 15:37:14, Alexander Potapenko wrote:
> > > > > > > Freeing a memory is an opt-in feature and the slab allocator =
can already
> > > > > > > tell many (with constructor or GFP_ZERO) do not need it.
> > > > > > Sorry, I didn't understand this piece. Could you please elabora=
te?
> > > > >
> > > > > The allocator can assume that caches with a constructor will init=
ialize
> > > > > the object so additional zeroying is not needed. GFP_ZERO should =
be self
> > > > > explanatory.
> > > > Ah, I see. We already do that, see the want_init_on_alloc()
> > > > implementation here: https://patchwork.kernel.org/patch/10943087/
> > > > > > > So can we go without this gfp thing and see whether somebody =
actually
> > > > > > > finds a performance problem with the feature enabled and thin=
k about
> > > > > > > what can we do about it rather than add this maint. nightmare=
 from the
> > > > > > > very beginning?
> > > > > >
> > > > > > There were two reasons to introduce this flag initially.
> > > > > > The first was double initialization of pages allocated for SLUB=
.
> > > > >
> > > > > Could you elaborate please?
> > > > When the kernel allocates an object from SLUB, and SLUB happens to =
be
> > > > short on free pages, it requests some from the page allocator.
> > > > Those pages are initialized by the page allocator
> > >
> > > ... when the feature is enabled ...
> > >
> > > > and split into objects. Finally SLUB initializes one of the availab=
le
> > > > objects and returns it back to the kernel.
> > > > Therefore the object is initialized twice for the first time (when =
it
> > > > comes directly from the page allocator).
> > > > This cost is however amortized by SLUB reusing the object after it'=
s been freed.
> > >
> > > OK, I see what you mean now. Is there any way to special case the pag=
e
> > > allocation for this feature? E.g. your implementation tries to make t=
his
> > > zeroying special but why cannot you simply do this
> > >
> > >
> > > struct page *
> > > ____alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int pref=
erred_nid,
> > >                                                     nodemask_t *nodem=
ask)
> > > {
> > >     //current implementation
> > > }
> > >
> > > struct page *
> > > __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int prefer=
red_nid,
> > >                                                     nodemask_t *nodem=
ask)
> > > {
> > >     if (your_feature_enabled)
> > >             gfp_mask |=3D __GFP_ZERO;
> > >     return ____alloc_pages_nodemask(gfp_mask, order, preferred_nid,
> > >                                     nodemask);
> > > }
> > >
> > > and use ____alloc_pages_nodemask from the slab or other internal
> > > allocators?
Given that calling alloc_pages() with __GFP_NO_AUTOINIT doesn't
visibly improve the chosen benchmarks,
and the next patch in the series ("net: apply __GFP_NO_AUTOINIT to
AF_UNIX sk_buff allocations") only improves hackbench,
shall we maybe drop both patches altogether?
> > If an additional allocator function is preferred over a new GFP flag, t=
hen
> > I don't see any reason not to do this. (Though adding more "__"s seems
> > a bit unfriendly to code-documentation.) What might be better naming?
>
> The naminig is the last thing I would be worried about. Let's focus on
> the most simplistic implementation first. And means, can we really make
> it as simple as above? At least on the page allocator level.
>
> > This would mean that the skb changes later in the series would use the
> > "no auto init" version of the allocator too, then.
>
> No, this would be an internal function to MM. I would really like to
> optimize once there are numbers from _real_ workloads to base those
> optimizations.
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

