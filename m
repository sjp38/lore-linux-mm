Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1B9DC282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:23:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52DEF21872
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 15:23:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DHgWugbd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52DEF21872
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD2626B0274; Fri, 12 Apr 2019 11:23:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D824A6B0276; Fri, 12 Apr 2019 11:23:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C982B6B0277; Fri, 12 Apr 2019 11:23:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id A3C656B0274
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 11:23:28 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id x7so1345922uap.3
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 08:23:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=jdh+W4Qf+xTtMx1pbPDAwIHjsRVYZ/Q+sKKFxSr1S5U=;
        b=j8Pb6jDeKV9amHqcjWPxrEZs3HZW57LDYrKiyyQa2flPMS1dalXfTJ+1/7KtipCnlj
         2PFqAGI/uZiBUX41tv5AqS8b6/ysYjj/JmS/opq+kCbC1Y7WxNXHvqa6TTaIVZiP+SRu
         UppbU6ewcYLXxWa5MTQieJmKpZpI6cvM6rJKwJRgO3QFzAFl40iwJWUUU1E7DKh+RIse
         cuI8OFabHFeLIckI49WMC8Fzd59QOupgWhmq69oyh3Hu56ZbMCaH+sXFSaAP6WZziXt7
         6ktIl7hy36xb69L8rZJWuAc5ABUvHs8avmVWSiSCFiYCYOcQndbgve7cboD3nxMRZtHk
         AhMg==
X-Gm-Message-State: APjAAAVnOYjEdS5UcBmLc3cthsMLzn9mCuEObTegYtQXVY1Hb9a8Mc8n
	/wCgNYERueO9krbj09oVKi2KaiAwLr9qutc9+VQBiqJmHco1LNWrYQLULAPGwUV2TMOGBVirziU
	Ie20pRqFzZNnIG5uTwFvPRZIo+2G5Re4g7E3BvGPdJRLv0+w6jUKcFcm6+nDS/ikb5g==
X-Received: by 2002:a67:8494:: with SMTP id g142mr31033393vsd.28.1555082608228;
        Fri, 12 Apr 2019 08:23:28 -0700 (PDT)
X-Received: by 2002:a67:8494:: with SMTP id g142mr31033351vsd.28.1555082607611;
        Fri, 12 Apr 2019 08:23:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555082607; cv=none;
        d=google.com; s=arc-20160816;
        b=Wq4Yby7widnVWcURizupD5O3LSGkf3yESdwFiNCKZ1CeswwQqCR7/0oh1ioVimIMOl
         1pRr86dVVj7RVlIKoJuY7wwxotL612dQWD/iSOO2OBXKG6cmWEJWdqGLRNl9iu4vwiRz
         nHvJNIIHxrT/RPBUd2jbnGjucb1vv73JWUnmwrFDCDK/S+GdoMRqxIabhVOYw2LvHG9q
         xf7R0BMRaRLcrGSZ9MhC8RjmklvNRWqbwMRosbhtZGns1iG5+twf5gh4+QX6rBc8qcPk
         AwVrnu5YAA5/VyiP+uq6iibiMLOqgvN8Gv3e3jPnMafwN1KrnvtnuQd8F3nsDvwh4vax
         XOSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=jdh+W4Qf+xTtMx1pbPDAwIHjsRVYZ/Q+sKKFxSr1S5U=;
        b=umQame6vaEvrcyNSxApBlpaqZL0gYmiITjiBqyzmwVMLiUrCNzQM3jk17uHLMFNkzq
         zAa0WChADrlKi48ya0mXvOyYx1i6qOQJ04h1huMfGCZGeiMqQK6JxjmtZVCkjDa5K/ZY
         AHuVpXz7kIVVcMnvp6vEZjDUWTumiB6TKlLjDoxxPXEDEgoyMZGELHFqpeN7HFYfADBG
         ZlLN5owyA2G7roHie2Yrs23kx99mSSlg6bKPA0L69FKUwsNyWcZB5y4f16t1JZ8ij/29
         xu8vJvYtlquFCZI5HeK/tKnmxXrX4g7jgJyjLEpy/EdH1Gw5k9crwoUvVLUBvEPDNy0I
         wkUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DHgWugbd;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u12sor24347432uan.19.2019.04.12.08.23.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 08:23:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DHgWugbd;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=jdh+W4Qf+xTtMx1pbPDAwIHjsRVYZ/Q+sKKFxSr1S5U=;
        b=DHgWugbdN7k8WF/sQearF4OyKrHJdb5hf50SuyoxB3kU/CiRboqwFfj2wYdrBEhOTa
         bI3ytacddW8ZGOLF+aM2ibYnS3aqftIz5fpa41wBBQY/lBeVoi9bxZArS87hTj5B+oQa
         e6YoadgctME8FYDxlYQOjT5AsWvouGFv25+11SSQIoT5I4KjHOOT2+HT5+JIY8EBVFhG
         iupA/WSB5wrUMAA7M1H2+wYKxJinGjv7qT8bnQNElyD0B4SM4ImVe4ISU0C/uqyR/CZr
         q0UG48A2lGzFcQvi61xWlCTu+FscZU1RDZGJaqdlGcZSvo2FkJdbV3WgMe+55P4SdjDW
         yB7A==
X-Google-Smtp-Source: APXvYqzbnOslz7WeYrsEitO9Tc3kH0tdnMuzW6L6fk3geG8DMcoHJIJERFGCopoR0I6stuauCLJ+mpIFXamNirb6J8k=
X-Received: by 2002:ab0:2399:: with SMTP id b25mr29928095uan.129.1555082607026;
 Fri, 12 Apr 2019 08:23:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190412124501.132678-1-glider@google.com> <1555078584.26196.50.camel@lca.pw>
In-Reply-To: <1555078584.26196.50.camel@lca.pw>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 12 Apr 2019 17:23:15 +0200
Message-ID: <CAG_fn=UrF6+yvXrok0Ca3dP2WZK7EOqE0NB24sR9WgMb=UuR-Q@mail.gmail.com>
Subject: Re: [PATCH] mm: security: introduce CONFIG_INIT_HEAP_ALL
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitriy Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, 
	Sandeep Patil <sspatil@android.com>, Laura Abbott <labbott@redhat.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 4:16 PM Qian Cai <cai@lca.pw> wrote:
>
> On Fri, 2019-04-12 at 14:45 +0200, Alexander Potapenko wrote:
> > This config option adds the possibility to initialize newly allocated
> > pages and heap objects with zeroes. This is needed to prevent possible
> > information leaks and make the control-flow bugs that depend on
> > uninitialized values more deterministic.
> >
> > Initialization is done at allocation time at the places where checks fo=
r
> > __GFP_ZERO are performed. We don't initialize slab caches with
> > constructors or SLAB_TYPESAFE_BY_RCU to preserve their semantics.
> >
> > For kernel testing purposes filling allocations with a nonzero pattern
> > would be more suitable, but may require platform-specific code. To have
> > a simple baseline we've decided to start with zero-initialization.
> >
> > No performance optimizations are done at the moment to reduce double
> > initialization of memory regions.
>
> Sounds like this has already existed in some degree, i.e.,
>
> CONFIG_PAGE_POISONING_ZERO
Note that CONFIG_PAGE_POISONING[_ZERO] initializes freed pages,
whereas the proposed patch initializes newly allocated pages.
It's debatable whether initializing pages on kmalloc()/alloc_pages()
is better or worse than doing so in kfree()/free_pages() from the
security perspective.
But the approach proposed in the patch makes it possible to use a
special GFP flag to request uninitialized memory from the underlying
allocator, so that we don't wipe it twice.
This will be harder to do in the functions that free memory, because
they don't accept GFP flags.




--
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

