Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A90BC04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:39:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFB132168B
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:39:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZfCTHd4n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFB132168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F6F66B0006; Fri, 17 May 2019 10:39:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8A6176B0007; Fri, 17 May 2019 10:39:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 794B56B0008; Fri, 17 May 2019 10:39:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8196B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:39:05 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id a197so1503541vsd.21
        for <linux-mm@kvack.org>; Fri, 17 May 2019 07:39:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=ddYknnyy251jUXjF119a2VyFqAoO0MJ7lwXqU8aG9CY=;
        b=YVCgx23P+dJku8lZn3iNkIFB0Ob/Vgyg57/N1pbp5QBkP/kCMF/PSiG3A89UoQheuX
         q7c52L57hV+3Q2yhJEGggUIOiadqrW+voY3Ylbf0w2hB3edqapLtEOPCxziTxAVUqrJW
         qgVA5HHmlIoLo2jAID47EnSpeHleDECICK1n82u3yfGZtiN9K7iaWDhH06RwKGsW2Q73
         KYP6B8q/Em9PmQ19DbDWa5qyrv1Yll55aPozwbqYD1hcZk7txgfy2BQt7l5mPpj1TVjJ
         uRDerxrU4g/PQIWq7S/ZgGGJvKpEfZRTZUXe8jxdbBvnCHklKWlrA+u1w7aNDaIZThg4
         g0EA==
X-Gm-Message-State: APjAAAUKNfKRplyQfZD/3yqzegy+R6Xcz/n1+RSGfV+ApIe/fHakcOp7
	ZZMIWv4j18L0bu8Xod7TnyW/4yqTKR0dFUBtvNOr9E6kC27WcXIFSCI9qj8FegRVeFSujo36CQg
	JcRArbWrYjByCBd20M23IbmMCFgk+fwP8qFCf1PlZ2FKa6ubEWw49eGt3GPl8hMiXTA==
X-Received: by 2002:a67:f7d2:: with SMTP id a18mr16949702vsp.5.1558103944990;
        Fri, 17 May 2019 07:39:04 -0700 (PDT)
X-Received: by 2002:a67:f7d2:: with SMTP id a18mr16949669vsp.5.1558103944386;
        Fri, 17 May 2019 07:39:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558103944; cv=none;
        d=google.com; s=arc-20160816;
        b=CFe1RUvD5tveJAO5hBisuES8fomgrtn5fE7qVu7DoULPA6BwySwxtvOk9QZ3sFwVox
         X1SNssOHeTRx/IWgde+Db4zfu1SzdJmp4O6BfuWhRTivlm4e7/8oGTKOLi5WbcNVGeq/
         82mQJdK4pMRhDzsfjNFuT55DmZdBcgqEIeZF6IBjqKFTyMRRwJ6CO0VfBZta/1FIKTTS
         OVDuKZnVaSx3S1PR2ONdTojqYW9WiyzJl6cDW4zjJwMeZJ1oKcrY9DirQWDDRocW8chw
         nYyH8ETi9z/ivuzVVQwMLw8HPMOSZaFfbWyw4XgZ1Ynw4Z0gO8orvVRlwZMfSSr0YwSy
         UsRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ddYknnyy251jUXjF119a2VyFqAoO0MJ7lwXqU8aG9CY=;
        b=gvO4u1X+tl5iOaGaCabCTnB5dsNbPVRztXTlD1jK3ctpyt6+Dgu11zVNcWaZZke2ay
         appahnMV+V901N+1E/S3ZNazGEQQgG+tjuJ+pmlcMKQp7133hg2lXB8fbFlPqMGAWuQn
         LW2ZA5XiZgPtbdEAdPmchQxOmmdYrsn8avMloUykYtYJixFY1gF4E0CNIEo47qzauBZT
         6RsJaCW1hRbxsPGZRZu2/cMsXFFhy0hA1XRE2ETfN0ipBL1KGUNPGh4mjE0hwIvoCcrE
         wBjw5sNd0VZo4IfdjbnZJenlL2EdbBy9ijHvjwZQF7JSmjPKBd+yBK9sRZ4CDA2aJY+d
         K4eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZfCTHd4n;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h4sor3122299vkh.29.2019.05.17.07.39.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 07:39:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ZfCTHd4n;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=ddYknnyy251jUXjF119a2VyFqAoO0MJ7lwXqU8aG9CY=;
        b=ZfCTHd4njmwJ6LmyMIrWpboajTklaeBflvOkckUG57zSTiCO9V6zZ/F4wxPdk/qNUQ
         PVYMluJEt88jyugSzqc0nG7UZR7DLvqpFQzEFftB05/78KyrZltNrXCTTPfD64+BZVrD
         petSewDBThIM52+IEcDFxCTrwU4XGvwQzXx2OnY7RGaGl7FzEu9k9MeOMqSnQQ9BAkCW
         oGVCwrkpIb4glulSXJTh+pRPJrqZboKu7VuIf2urRTJSx9c6Q/Pq/jAHZhhJ81Od6+24
         +t1zJKIIPbGUXy6ajnaWTV/1OoHtLOlwMLRNj475X7xcV2GizLUQNcqPSE4CshTe69LP
         g0xQ==
X-Google-Smtp-Source: APXvYqzmJFfH7vnjyDXwEt0PEao3F5jTjrlEKGaCN9GO7PVaS+H8433b6AZMGQxWDooobwXiz1H5CeN39cIPFc6Nv50=
X-Received: by 2002:a1f:ae4b:: with SMTP id x72mr2631730vke.29.1558103943898;
 Fri, 17 May 2019 07:39:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190514143537.10435-1-glider@google.com> <20190514143537.10435-2-glider@google.com>
 <201905161824.63B0DF0E@keescook>
In-Reply-To: <201905161824.63B0DF0E@keescook>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 17 May 2019 16:38:51 +0200
Message-ID: <CAG_fn=U-8XiBVRDhr9QxLj0Yj+1ud41KvmUqEt9Gih9MAznuPw@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 3:26 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Tue, May 14, 2019 at 04:35:34PM +0200, Alexander Potapenko wrote:
> > [...]
> > diff --git a/mm/slab.h b/mm/slab.h
> > index 43ac818b8592..24ae887359b8 100644
> > --- a/mm/slab.h
> > +++ b/mm/slab.h
> > @@ -524,4 +524,20 @@ static inline int cache_random_seq_create(struct k=
mem_cache *cachep,
> > [...]
> > +static inline bool slab_want_init_on_free(struct kmem_cache *c)
> > +{
> > +     if (static_branch_unlikely(&init_on_free))
> > +             return !(c->ctor);
>
> BTW, why is this checking for c->ctor here? Shouldn't it not matter for
> the free case?
It does matter, see e.g. the handling of __OBJECT_POISON in slub.c
If we just return true here, the kernel crashes.
> > +     else
> > +             return false;
> > +}
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

