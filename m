Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29973C04E84
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:11:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E039A216F4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 14:11:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="EhjgdN7e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E039A216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 932406B0006; Fri, 17 May 2019 10:11:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E3056B0008; Fri, 17 May 2019 10:11:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D1076B000A; Fri, 17 May 2019 10:11:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5350C6B0006
	for <linux-mm@kvack.org>; Fri, 17 May 2019 10:11:46 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id h6so978721uab.0
        for <linux-mm@kvack.org>; Fri, 17 May 2019 07:11:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=yPJC3km5fQmSqwkKg0IjAisXnGkZMwPlofzvwmFfzTw=;
        b=Mb665q8e5hbh1BlcyX4s//e8G7Z0dGvI5W63vOlkoW/uwlmtOVP/SfafWxQkc5ZNnF
         F2r2njzQS4tqq91I8uEI987bTVj1IxMTZIl3OwVyZTZrxyW22mWCEeO4fAulXUdWaRM/
         ASzIGAIgfu4EV+r3iay12gE0IHMQEEVCk2sF2ozYaDjuzZaSEmpPXQiKBrcp4pKy1tTt
         uaY/roTFbKE3j+rahCLUjXsdjkMPSJ2+18TLhgAUKgMEGhaZt5enjVN4LP8YBUz+ng/P
         HfHJ8rOowUeXl8CaBJV7Xqlw7P6eFhcstGtQnDgsKPdoX28PCLyHyfjjIkE+BDeZBeGR
         Dy0w==
X-Gm-Message-State: APjAAAUsrXfLWO255/P+ZiMB1drbUO54AGMTmKAU99j1gZxSyI7Lvh3v
	v7luL0zInI4zQxx+mXYpjs25RjRa5tsCoe+EjzYMVCw9kCt/er6BPX0Qi2aQGX7bK+aFGbvxums
	b5M1m64iCzvx3YDr2lxPmOH9skRzmlc2FoUgf/jmXjscNr676WrGBsOnB5VuAgtV7zw==
X-Received: by 2002:a1f:fc44:: with SMTP id a65mr2471109vki.91.1558102306008;
        Fri, 17 May 2019 07:11:46 -0700 (PDT)
X-Received: by 2002:a1f:fc44:: with SMTP id a65mr2471040vki.91.1558102304811;
        Fri, 17 May 2019 07:11:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558102304; cv=none;
        d=google.com; s=arc-20160816;
        b=KB9DT0odNLZZOJ5zfYdTeWdt67lU3nmODk9CnsAOxFhLET89UWl2QfQADIP69decJP
         qGnZeq2DO7WktDDHnVrWzPUCk2wKc50nu9WIilxSHLZkzzj/uBfMMCZdsU49XKEisCX3
         38TbYjK5Dn7FuX9oYsUP5VHg1PuUFWJmr9c0bCjKynuh0qU0/ZuNuaTFvZVTPjWdvgUL
         73t5TCe0S8PMV97ulL98sRRNR2tqsWrUdKM1Nn++esliWFBmNuK9m6xNoxcxxhAPzZaI
         CN6dXx8PcpXN3ThpGxEkZS26DRzVZ/JMxuRDBI7Y2U9c3vXumzF7wGYolmtIeRyZNIPi
         1+iA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=yPJC3km5fQmSqwkKg0IjAisXnGkZMwPlofzvwmFfzTw=;
        b=oMJsMfXJwjhaFqIkqCRNNOzQVZMTk/iqwB6fgtfJn8Nw1QaS+nSYdILUU0a3vwU+JJ
         FB5g8KOgLYqlJNqS3mVYo/EtPVz3z71Ro/NjXky5MjLtDASq23ahtJbnEuK+4AbP/SNJ
         iQN0x294CynDaGtXoB/ZudV2CPI0kHNRhzU4bOSDvsawTD0WdqVQ9hE92i5swOhXCipV
         Lqd2vvMepllN5zhE+cYiRt/tZKWqTqJEJ9G/a0qK9vmEOoQ4FdWqX5FTEVAq64HXR10R
         7+/2Rx75mzfTo0yzy7HhkEV31jq/fHuJxESoY7ClWxw0jAbQCd24xnVJEbGWaqs78H2R
         aesg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EhjgdN7e;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z1sor13097023uap.55.2019.05.17.07.11.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 07:11:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EhjgdN7e;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=yPJC3km5fQmSqwkKg0IjAisXnGkZMwPlofzvwmFfzTw=;
        b=EhjgdN7emCfeHXsoZMJ6Wj40u+K0XLKFFOKVL9cg3V+WH/c2YCU/n4ecYmVtHgKjHJ
         dtcKp1uarWS6UvEpwooJa4R7FNsW2kXMw4xOacmOPwlyZidzuxlrR+0uvSHkNLn5yUII
         +XP3M436OKMrLZSqSNxWKTmBL+mve4IC0pu2mPDyLlKaIRWUa/MqVE/uQn0Eu9tNH0Ab
         H1TItWp/mTaqBicBRuNPZ/zsD8Yl8IgYY4D/Eg47qVFNmJqUR9MFTMapElXkIPIIVeNF
         RfmK79DUWvsHRfjG9l+OaVKWPE9M65hLfms3E9J6bR595KANlWKWG/AscHpg+TRC5Ga6
         EJRg==
X-Google-Smtp-Source: APXvYqzNwEP3/rmvtRb4XJJMVsKuA4IxchtkUNa8GybLvlIZbRD9HfA6ovC4X627LbY06pBrs3DVvrUPTJ2RagiavLQ=
X-Received: by 2002:ab0:1d8e:: with SMTP id l14mr6084453uak.72.1558102303960;
 Fri, 17 May 2019 07:11:43 -0700 (PDT)
MIME-Version: 1.0
References: <20190514143537.10435-1-glider@google.com> <20190514143537.10435-2-glider@google.com>
 <20190517140446.GA8846@dhcp22.suse.cz>
In-Reply-To: <20190517140446.GA8846@dhcp22.suse.cz>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 17 May 2019 16:11:32 +0200
Message-ID: <CAG_fn=W4k=mijnUpF98Hu6P8bFMHU81FHs4Swm+xv1k0wOGFFQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kees Cook <keescook@chromium.org>, 
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

On Fri, May 17, 2019 at 4:04 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 14-05-19 16:35:34, Alexander Potapenko wrote:
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
>
> Why do we need both? The later is more robust because even free memory
> cannot be sniffed and the overhead might be shifted from the allocation
> context (e.g. to RCU) but why cannot we stick to a single model?
init_on_free appears to be slower because of cache effects. It's
several % in the best case vs. <1% for init_on_alloc.

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

