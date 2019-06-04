Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22D37C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 15:06:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE56520717
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 15:06:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kUgOTHyi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE56520717
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C3226B0010; Tue,  4 Jun 2019 11:06:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1741E6B0269; Tue,  4 Jun 2019 11:06:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03BFF6B026B; Tue,  4 Jun 2019 11:06:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id D51BD6B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 11:06:52 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id 184so5873875vsm.21
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 08:06:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=W49hJTPyGHTeCq1eaPKrKSt8wWOXsDB44kzR8MDEcNQ=;
        b=Ighl+Zsm8HaEAhqsEbfOkWfpow4TQHIQdfsZ62nIA67H+RfNEQ/MO7Z143tA6fHtQc
         WtygtUaUzBNTyYgdirXoHOovFCfVbwgVdx5yazEN9GCo+5fT1AzqmUeU67wilYaoTaI6
         roriUKFdPQd3m/xAqbwW5w3FZc2mRyv76nJkvvZuYZjnFRQiLB7cRC8iFoFoyNOrnedw
         rswKyxePLKJIdgCTVeBuMLgAWTKki+hPzieftxDphoNqTQSyZVANcnQN3BpBJeYAgVn5
         dP/onMwFAa253SV7IN2JWTaEAf7tleHimFAle/XbfWDLYs9kzWhOVDgxmd3fgvP8Si3h
         gnrw==
X-Gm-Message-State: APjAAAVCAym+tLnKv6jd/MmJUoM6Vitav4E7ewbWOlqvSr6t+vAmd0IW
	zDzVG7na2ASriDvMHIJ9IiUHjjttd0zGeR7gGkd9Afb8ClPZFT+nz9FU1bt88UW/xMXsmvRGbvP
	mEJgrGGP31bK+0wDS8OBMbskVrjID6JAe8H2L+5rD247A7KGZUz8BCtm1Teb1hThLRg==
X-Received: by 2002:a67:e905:: with SMTP id c5mr15868247vso.97.1559660812523;
        Tue, 04 Jun 2019 08:06:52 -0700 (PDT)
X-Received: by 2002:a67:e905:: with SMTP id c5mr15868186vso.97.1559660811430;
        Tue, 04 Jun 2019 08:06:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559660811; cv=none;
        d=google.com; s=arc-20160816;
        b=S4BUQ78EGSk+e7FtTab3dK4kguuRRqUv3s9T0RHwszJDlLHRWqGQN6z1TNq/0Qgsod
         B4GN4tGxB/TsxASqTlvfi3YGctGlnD392nz4QW4smPkyt7NSe+rWOOmBXKbowPje1SB3
         gpKJAnPfs5s1RT5ZiaxqR11fsZII54t1xq3PaEKpYWGmCaHX7/kSYO8HJk2BXGtrRJxx
         1zEiTIjPhHoebu6pC7PW+GmHWop22xRAJ8hT5s+s9RR0LiRZalPSxaYXHs1k08ti6m6e
         4PDpPkbgeDaoNvHoyz9NLFrk1zDUfJJ5P5/2tEMyPk3EIL62jls6C6oI6HgmHB7G+s/L
         Wmuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=W49hJTPyGHTeCq1eaPKrKSt8wWOXsDB44kzR8MDEcNQ=;
        b=aiboBT83tFMTSj9oJiT4uO7PmMJAZNsSMasxjMyrIo65zbyezT2xMeFSXqaoX5A3B8
         XnaSd7lcsbY5J/LXy06QSyKjJSX6MBRCaRG4eC6hTqfeW/M+iRyitrh+sGuJDAbWKvht
         QEOEXOGNSdj2yR1CjslU0ZtSB9vQtaj7beHlT1+zPzMVUzEWx69kdnv59xj1jjUtng7p
         VKZ5vzyF89jy2Og0sERWZCUiAwDKcMkSWz8LcRH4QtsY4Hvq7lDFhUqr3+YSeULIdYMO
         nzZfCXgsrKkzfAgD+v6CzifrL/rcNnzJXUWl5WAsA0W1Yldki2fHREum25Ctm4jPN7R3
         zXSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kUgOTHyi;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f5sor2574882vsq.43.2019.06.04.08.06.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 08:06:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kUgOTHyi;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=W49hJTPyGHTeCq1eaPKrKSt8wWOXsDB44kzR8MDEcNQ=;
        b=kUgOTHyiy4gjZrqjJd6XCiluIRCTk1Ty+Lu9WMWtf6nWiXvg7Gl2wZEMyDWXBXnWVJ
         EXijX6fvjXfPgxbIX1H/0d63FLBK6Vu6/jMcQwCHS+kGn255u3FNrSAkBtjdgi77VeMT
         75RbP/MxlLHCTrlWiQVVNp9bagAKrSFm14QyTkBmxXnI2D+A28XXDgdY0wIbrU2YrNPc
         yiZw0Vr2Vze2Q097L2N6agpIg2MekCTKjzfXkSGUSZsh2/k3cPgiUBIeG31VVGeUlwd/
         7qU2B0ya0GDmxgCfNNr4vaG/AE8OhAI28Zsr4UyW/dcaeJouMareTr8dWZS14jhNtuYL
         2Osw==
X-Google-Smtp-Source: APXvYqylaMBXgwiEMx6a3mBJoNMZNivsGG6/K2ImcC6RkV4tmp4KahfoqMGHmAsWa2Lj7YNjdkJ7hMGMgsAwTdzOkEI=
X-Received: by 2002:a67:1bc6:: with SMTP id b189mr267198vsb.39.1559660810775;
 Tue, 04 Jun 2019 08:06:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190529123812.43089-1-glider@google.com> <20190529123812.43089-3-glider@google.com>
 <20190531181832.e7c3888870ce9e50db9f69e6@linux-foundation.org>
 <CAG_fn=XBq-ipvZng3hEiGwyQH2rRNFbN_Cj0r+5VoJqou0vovA@mail.gmail.com>
 <201906032010.8E630B7@keescook> <CAPDLWs-JqUx+_sDtsER=keDu9o2NKYQ3mvZVXLY8deXOMZoH=g@mail.gmail.com>
In-Reply-To: <CAPDLWs-JqUx+_sDtsER=keDu9o2NKYQ3mvZVXLY8deXOMZoH=g@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 4 Jun 2019 17:06:39 +0200
Message-ID: <CAG_fn=UxfaFVZbtnO0VefKhi3iZUYn5ybe_Nvo0rCOxxA2nn-Q@mail.gmail.com>
Subject: Re: [PATCH v5 2/3] mm: init: report memory auto-initialization
 features at boot time
To: Kaiwan N Billimoria <kaiwan@kaiwantech.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, James Morris <jmorris@namei.org>, 
	Jann Horn <jannh@google.com>, Kostya Serebryany <kcc@google.com>, Laura Abbott <labbott@redhat.com>, 
	Mark Rutland <mark.rutland@arm.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	Matthew Wilcox <willy@infradead.org>, Nick Desaulniers <ndesaulniers@google.com>, 
	Randy Dunlap <rdunlap@infradead.org>, Sandeep Patil <sspatil@android.com>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Souptick Joarder <jrdr.linux@gmail.com>, Marco Elver <elver@google.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 8:01 AM Kaiwan N Billimoria
<kaiwan@kaiwantech.com> wrote:
>
> On Tue, Jun 4, 2019 at 8:44 AM Kees Cook <keescook@chromium.org> wrote:
> >
> > On Mon, Jun 03, 2019 at 11:24:49AM +0200, Alexander Potapenko wrote:
> > > On Sat, Jun 1, 2019 at 3:18 AM Andrew Morton <akpm@linux-foundation.o=
rg> wrote:
> > > >
> > > > On Wed, 29 May 2019 14:38:11 +0200 Alexander Potapenko <glider@goog=
le.com> wrote:
> > > >
> > > > > Print the currently enabled stack and heap initialization modes.
> > > > >
> > > > > The possible options for stack are:
> > > > >  - "all" for CONFIG_INIT_STACK_ALL;
> > > > >  - "byref_all" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL;
> > > > >  - "byref" for CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF;
> > > > >  - "__user" for CONFIG_GCC_PLUGIN_STRUCTLEAK_USER;
> > > > >  - "off" otherwise.
> > > > >
> > > > > Depending on the values of init_on_alloc and init_on_free boottim=
e
> > > > > options we also report "heap alloc" and "heap free" as "on"/"off"=
.
> > > >
> > > > Why?
> > > >
> > > > Please fully describe the benefit to users so that others can judge=
 the
> > > > desirability of the patch.  And so they can review it effectively, =
etc.
> > > I'm going to update the description with the following passage:
> > >
> > >     Print the currently enabled stack and heap initialization modes.
> > >
> > >     Stack initialization is enabled by a config flag, while heap
> > >     initialization is configured at boot time with defaults being set
> > >     in the config. It's more convenient for the user to have all info=
rmation
> > >     about these hardening measures in one place.
> > >
> > > Does this make sense?
> > > > Always!
> > > >
> > > > > In the init_on_free mode initializing pages at boot time may take=
 some
> > > > > time, so print a notice about that as well.
> > > >
> > > > How much time?
> > > I've seen pauses up to 1 second, not actually sure they're worth a
> > > separate line in the log.
> > > Kees, how long were the delays in your case?
> >
> > I didn't measure it, but I think it was something like 0.5 second per G=
B.
> > I noticed because normally boot flashes by. With init_on_free it pauses
> > for no apparent reason, which is why I suggested the note. (I mean *I*
> > knew why it was pausing, but it might surprise someone who sets
> > init_on_free=3D1 without really thinking about what's about to happen a=
t
> > boot.)
>
> (Pardon the gmail client)
> How about:
> - if (want_init_on_free())
> -               pr_info("Clearing system memory may take some time...\n")=
;
> +  if (want_init_on_free())
> +              pr_info("meminit: clearing system memory may take some
> time...\n");
Yes, adding a prefix may give the users better understanding of who's
clearing the memory.
We should stick to the same prefix as before though, i.e. "mem auto-init"
>
> or even
>
> + if (want_init_on_free())
> +                pr_info("meminit (init_on_free =3D=3D 1): clearing syste=
m
> memory may take some time...\n");
>
> or some combo thereof?
>
> --
> Kaiwan
> >
> > --
> > Kees Cook
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

