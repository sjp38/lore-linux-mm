Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A2D0C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:37:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AEF72089E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 14:37:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="krUEz3jU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AEF72089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBF438E0002; Fri, 21 Jun 2019 10:37:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6E768E0001; Fri, 21 Jun 2019 10:37:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5E968E0002; Fri, 21 Jun 2019 10:37:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4C908E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 10:37:24 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id 184so2255690vsm.21
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 07:37:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=CRsZKa850d7hy2Fg7kcjRq2q649+iIRBsH7xdd7VMHk=;
        b=q244/i27l+YskmCDJmxONSYxCv1LsPzBb3mLn0lmQQJw1WdZdUyLPXItdulupm2myq
         /hunRFz38zkgLw9z8aEVv02LENKgxfQI9JbBuPhC0vghqr7RHUI6+LnEWWhqCzDHWwY9
         uMC0AgfzsipFhq/PdZyYmcWenwEsKB8djxsMa1gtNR7hvOal+/4kpUO6XVvO6RcEZ5QS
         xMtFKCwvQCXkABX2AoraJmz750INTOg6PdaWZUjl/veAJczmCB70oYNq0T1/YC/dT70+
         Jiof00YXJX8/YqT6LXDL5aH1JUBQiFJd9+kPMmtQNKIpnkgB4zfBoGjb6axBp/eOsPIY
         THLA==
X-Gm-Message-State: APjAAAUA4SmkxcfeRjkcgSe1D53MLcoW4objFTURhvIjUtp5YzZ4N3/u
	bmoNTJPz6zGECtbFgvJagbBmRXHlwNAV7HtAuXP1OpQBKmDhHvpfO5B/dFEfbOrPCWC/2wiDpAz
	OaSXy0LsUbq3cgKty0ga6I8R/OeMX/NrSYH4NeV9fX9LMU2hb8lYa84qwECK97fAQrQ==
X-Received: by 2002:a9f:326e:: with SMTP id y43mr15187824uad.4.1561127844343;
        Fri, 21 Jun 2019 07:37:24 -0700 (PDT)
X-Received: by 2002:a9f:326e:: with SMTP id y43mr15187778uad.4.1561127843513;
        Fri, 21 Jun 2019 07:37:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561127843; cv=none;
        d=google.com; s=arc-20160816;
        b=Q15rLxAdMonfJr3dTN5Ig7HfoeCGmYrPF1jjsiPYAw+da5csbrbFEpDt2Q1mvdtMXG
         OX8bPULz5VpDf3QiFk9hcpXq3axK0EA6ZusbXZ37GBQdO0BCmKYs71HtPN+/EWccbTnZ
         XX9wVaazuDgnGsxy53xat1qfJn2vOXXLb2i2dxu1P5/Bcb8DwFTCBLYGHSLpq8an+Bwq
         /RI9ekM3qS1XXDHjhtBBXJIXaQV53vxC5DrzSoEPJpchamjs18CCcYTednoELTfL++QZ
         cSDSsyr8knfSbwlL1npw1JEHHhWOkl+dd9RekPx02+bswbzOO/Ky974hJKHmXsJ1j+X4
         3BqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=CRsZKa850d7hy2Fg7kcjRq2q649+iIRBsH7xdd7VMHk=;
        b=Ocahc55nMMDLzWaQeixf6DyO2Cy4ROK6yKscvP5kbEkZzs9M37WsjRBz18JMCahuXX
         UaXd38d8h0IbcsoHfbTVbibqXwl8YQ5jAGxlhrNluqlVJFrR+iombqz7rnOWZqfR9MP0
         AYI484ocZtnYuq+nsbaGEayMURJUzO6JwR1T9OiJEsgDcsrvGxfSPaVW8TEGyGsFndr3
         JalJd4X2eXrHW9QxTubQLjO1OAp1pGtgtWdJ6+eqhZc7EoPwvO0czgax0ROHuOI3ZNBS
         AqH7mM7sjA+ctilzDmdOGOAEdOYKG0FYk5T1RZB3X6S5v0oU0ZZiHwYT5Tj0Ij13wOlq
         GU2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=krUEz3jU;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o4sor998480vko.53.2019.06.21.07.37.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 07:37:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=krUEz3jU;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=CRsZKa850d7hy2Fg7kcjRq2q649+iIRBsH7xdd7VMHk=;
        b=krUEz3jU5PDEs/c+y0vBtzgq6AFBae0v8SSlcMMS/hmJNHLzMQL83zvltWuywWMrmp
         il/scSnj+2Ivb9k/0MUKDwG5H8G94payV/kNpVWZGUwF9HI0qsHAoTTCtNgPSjT1amoW
         t/xIUvgHCrBLBdHz2IcXtQQkX/ioF7maLpTQHiJYn6nhdefKPoApx1v464zVabU1GZJ1
         aImXO+fQ1VTBBSq2STNMAC5PLpwVD39s9jZYcZoEF0CrHSrTXQBU3JsAm7J6CO9KyyrJ
         O+cq0pdgRfdAvOH7q4sn0X6D7qxonOPLIOAtlI2cQlnDKMtjM8V4LLd65XTNAnaOqus0
         Q7JQ==
X-Google-Smtp-Source: APXvYqxtIeR8nA5JywTAnCOPtXDwpBCuWFRhO7ubkHThaKB+JU1b6TEzqRXDk+CV9/2hiiiDVvk6BOQmArl1wouIcyQ=
X-Received: by 2002:a1f:dcc5:: with SMTP id t188mr9877753vkg.29.1561127842845;
 Fri, 21 Jun 2019 07:37:22 -0700 (PDT)
MIME-Version: 1.0
References: <1561063566-16335-1-git-send-email-cai@lca.pw> <201906201801.9CFC9225@keescook>
 <CAG_fn=VRehbrhvNRg0igZ==YvONug_nAYMqyrOXh3kO2+JaszQ@mail.gmail.com> <1561119983.5154.33.camel@lca.pw>
In-Reply-To: <1561119983.5154.33.camel@lca.pw>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 21 Jun 2019 16:37:10 +0200
Message-ID: <CAG_fn=WGdFZNrUCeMtbx4wbHhxWqM2s7Vq_GvnMC-9WJZ_mioQ@mail.gmail.com>
Subject: Re: [PATCH -next v2] mm/page_alloc: fix a false memory corruption
To: Qian Cai <cai@lca.pw>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 2:26 PM Qian Cai <cai@lca.pw> wrote:
>
> On Fri, 2019-06-21 at 12:39 +0200, Alexander Potapenko wrote:
> > On Fri, Jun 21, 2019 at 3:01 AM Kees Cook <keescook@chromium.org> wrote=
:
> > >
> > > On Thu, Jun 20, 2019 at 04:46:06PM -0400, Qian Cai wrote:
> > > > The linux-next commit "mm: security: introduce init_on_alloc=3D1 an=
d
> > > > init_on_free=3D1 boot options" [1] introduced a false positive when
> > > > init_on_free=3D1 and page_poison=3Don, due to the page_poison expec=
ts the
> > > > pattern 0xaa when allocating pages which were overwritten by
> > > > init_on_free=3D1 with 0.
> > > >
> > > > Fix it by switching the order between kernel_init_free_pages() and
> > > > kernel_poison_pages() in free_pages_prepare().
> > >
> > > Cool; this seems like the right approach. Alexander, what do you thin=
k?
> >
> > Can using init_on_free together with page_poison bring any value at all=
?
> > Isn't it better to decide at boot time which of the two features we're
> > going to enable?
>
> I think the typical use case is people are using init_on_free=3D1, and th=
en decide
> to debug something by enabling page_poison=3Don. Definitely, don't want
> init_on_free=3D1 to disable page_poison as the later has additional check=
ing in
> the allocation time to make sure that poison pattern set in the free time=
 is
> still there.
In addition to information lifetime reduction the idea of init_on_free
is to ensure the newly allocated objects have predictable contents.
Therefore it's handy (although not strictly necessary) to keep them
zero-initialized regardless of other boot-time flags.
Right now free_pages_prezeroed() relies on that, though this can be changed=
.

On the other hand, since page_poison already initializes freed memory,
we can probably make want_init_on_free() return false in that case to
avoid extra initialization.

Side note: if we make it possible to switch betwen 0x00 and 0xAA in
init_on_free mode, we can merge it with page_poison, performing the
initialization depending on a boot-time flag and doing heavyweight
checks under a separate config.

> >
> > > Reviewed-by: Kees Cook <keescook@chromium.org>
> > >
> > > -Kees
> > >
> > > >
> > > > [1] https://patchwork.kernel.org/patch/10999465/
> > > >
> > > > Signed-off-by: Qian Cai <cai@lca.pw>
> > > > ---
> > > >
> > > > v2: After further debugging, the issue after switching order is lik=
ely a
> > > >     separate issue as clear_page() should not cause issues with fut=
ure
> > > >     accesses.
> > > >
> > > >  mm/page_alloc.c | 3 ++-
> > > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > >
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 54dacf35d200..32bbd30c5f85 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -1172,9 +1172,10 @@ static __always_inline bool
> > > > free_pages_prepare(struct page *page,
> > > >                                          PAGE_SIZE << order);
> > > >       }
> > > >       arch_free_page(page, order);
> > > > -     kernel_poison_pages(page, 1 << order, 0);
> > > >       if (want_init_on_free())
> > > >               kernel_init_free_pages(page, 1 << order);
> > > > +
> > > > +     kernel_poison_pages(page, 1 << order, 0);
> > > >       if (debug_pagealloc_enabled())
> > > >               kernel_map_pages(page, 1 << order, 0);
> > > >
> > > > --
> > > > 1.8.3.1
> > > >
> > >
> > > --
> > > Kees Cook
> >
> >
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

