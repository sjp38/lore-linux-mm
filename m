Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94485C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 15:43:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CF24208E3
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 15:42:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sV9oh2RA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CF24208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F9196B0003; Tue, 25 Jun 2019 11:42:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A9B78E0005; Tue, 25 Jun 2019 11:42:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 649C48E0003; Tue, 25 Jun 2019 11:42:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD036B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:42:59 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id b85so7870940vke.22
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 08:42:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=sUfwNQBOi/BNFV+4gDSnqcbmOZ2eF/S7imxNo+MJGuw=;
        b=S0AB51ES9uJvLwe3Bx9iQwDPEt/BTobRskfyNBbNbUbYDE5TP1nTrRO+252kgMYMtc
         z8aDp3apt2BbaVXlOhpU63oGRcJUsI3/t6KeLBbK05wXIbQD+gpg8JG44H0tqB34aQtn
         zEsr8g3tK6U/d6kIK98mAVMNtljT/Jz06NT9/TzkRY+TXbR2EsLRWKuWIE2xcwcq/laG
         0BzQ4ZsBXpg+z/Eltnl1A9DqHsqkTEHuYVdAnZ/Bxa4ohdcDxpN/BuApyLDh8x3fXv/u
         LVc3o8uDwkpovQXitx9l32jNHRpXBeIDoAJYaoOg4irvA+GuVj3RtGp1mFqpgbvxMZkZ
         So7Q==
X-Gm-Message-State: APjAAAXDBveqqyRs6nrs0Y40U6YHH2wuNuqF1lKUd6TjcoFN/GEpRnt1
	LAG7h0hwk7Zmr746crgUIbgZZl4ObsaUcYwGTxLsy18B0QA+rl2f4KD1xAzhNPY0qNN74HUFZLM
	+rzYkzygccS9FTxWfDIjt/+vYvmdSOTErsFSSaMyfRTJdd1+XLe4FkwgxN6aX9v7Jsw==
X-Received: by 2002:a67:8709:: with SMTP id j9mr5736324vsd.35.1561477378874;
        Tue, 25 Jun 2019 08:42:58 -0700 (PDT)
X-Received: by 2002:a67:8709:: with SMTP id j9mr5736291vsd.35.1561477378254;
        Tue, 25 Jun 2019 08:42:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561477378; cv=none;
        d=google.com; s=arc-20160816;
        b=zYrAl6RSh1f+ngg7oVddCh/zL99UNXZewbgnM3sXOGXZXX9bqjPY3z0yw/n0MjEsWB
         MvRSu6XM89I60GQVWB6msKsqz7jWMDzf9hwnQhYeGONeM/MLRsKe6b/dx/J4tLbbpqLF
         aOBmLvyUYnIlgwxv+o1oo/FXK39Pq8wrHWZt1PcWa19u00kaGErpsqU0LBRwj5YGUY9Q
         VK9W4dnNhIzLtryBCYf9KRS6OtJnt7A2v7tyeIcbhRru/4Rfw0shYtdzVt/wFQfF88KS
         VuIzxd5SylPiCsKbV9KvH4IO9hwV75IZ/EltrfFa/WFtuSR4BZbnegt3H2eZD1HA/Pxc
         teUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=sUfwNQBOi/BNFV+4gDSnqcbmOZ2eF/S7imxNo+MJGuw=;
        b=fqDgAcIx2WRvBcBGCSXoRE4i+KLYbd61EQgQ+tJ9SAqbBI0xTflp+6BFVmGQpkeS7E
         GLn3xg1W5/acXgIH9ohcdQj2LqMygW0t+p5cc5U/3yYG8MMt2VJT4WhOtMN1sT1xNiFq
         aPBy+I+SNHdb8B4CusIXKCc5jaqkpyWdTS+cloBlbf5FBVLID8C1dMHzzVGX6hFMkjl3
         eo3FWeEjkdOUKJLRRI0H3d5OpSpCaso/yCgWjdFmumbP2+E/cV6ntycSOGy0ctaOPSeP
         uds3aiBL9fgOM4r0GQRCdgSoSTjatJFJOpNSdx84qWBdGSFDHmW0Ttt22K6UzjLmblxq
         Spdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sV9oh2RA;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d82sor7489147vsc.40.2019.06.25.08.42.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 08:42:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sV9oh2RA;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=sUfwNQBOi/BNFV+4gDSnqcbmOZ2eF/S7imxNo+MJGuw=;
        b=sV9oh2RASS5zpqZVHKKGJxJRy8QFppvn8NhWda7yYLYazc+1NfrJf9c8Q7Ksdh2qVh
         GbInfrz3Q/R804KazPTI6pqZiuW+qA7fYZ6cfuv0A/uIX2cuoIagmY+grmarNxXB3KIV
         CV0UsAeEvPzhkSV1srYnweXyIbNpXJ4VT7ftbANfQK0824ixV9yBnxvk00lmyNtZwFVE
         aCBREhp7Yk+TKyPI2y64zwDJXfSy5yR3jAV9OXrsTlc7KSLZBfy51GL7RUozIDDGh89J
         fltXE72SZLR3f6f6wZtvwP5llYax4JMBuGoS0RwTp8VL7XajJkixwkdta5C6Eqz7NIxH
         8tjg==
X-Google-Smtp-Source: APXvYqzLHIJfk/IhqSGoXbjZlH6E7iaTV0wslA1Ml/4Nyhq4SwItBVki34mlaIunyOmV/cW1HTz21auucu/pZvDGzbc=
X-Received: by 2002:a67:11c1:: with SMTP id 184mr58499747vsr.217.1561477377591;
 Tue, 25 Jun 2019 08:42:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190606164845.179427-1-glider@google.com> <20190606164845.179427-2-glider@google.com>
 <201906070841.4680E54@keescook> <201906201821.8887E75@keescook>
In-Reply-To: <201906201821.8887E75@keescook>
From: Alexander Potapenko <glider@google.com>
Date: Tue, 25 Jun 2019 17:42:45 +0200
Message-ID: <CAG_fn=VceGkQPuJ45ffmy-9rRdx515z10N97FApeZR9YrXSHVA@mail.gmail.com>
Subject: Re: [PATCH v6 1/3] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Hocko <mhocko@kernel.org>, 
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

On Fri, Jun 21, 2019 at 3:37 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Fri, Jun 07, 2019 at 08:42:27AM -0700, Kees Cook wrote:
> > On Thu, Jun 06, 2019 at 06:48:43PM +0200, Alexander Potapenko wrote:
> > > [...]
> > > diff --git a/mm/slub.c b/mm/slub.c
> > > index cd04dbd2b5d0..9c4a8b9a955c 100644
> > > --- a/mm/slub.c
> > > +++ b/mm/slub.c
> > > [...]
> > > @@ -2741,8 +2758,14 @@ static __always_inline void *slab_alloc_node(s=
truct kmem_cache *s,
> > >             prefetch_freepointer(s, next_object);
> > >             stat(s, ALLOC_FASTPATH);
> > >     }
> > > +   /*
> > > +    * If the object has been wiped upon free, make sure it's fully
> > > +    * initialized by zeroing out freelist pointer.
> > > +    */
> > > +   if (unlikely(slab_want_init_on_free(s)) && object)
> > > +           *(void **)object =3D NULL;
>
> In looking at metadata again, I noticed that I don't think this is
> correct, as it needs to be using s->offset to find the location of the
> freelist pointer:
>
>         memset(object + s->offset, 0, sizeof(void *));
In the cases we support s->offset is always zero (we don't initialize
slabs with ctors or RCU), but using its value is a sane
generalization.

> > >
> > > -   if (unlikely(gfpflags & __GFP_ZERO) && object)
> > > +   if (unlikely(slab_want_init_on_alloc(gfpflags, s)) && object)
> > >             memset(object, 0, s->object_size);
>
> init_on_alloc is using "object_size" but init_on_free is using "size". I
> assume the "alloc" wipe is smaller because metadata was just written
> for the allocation?
As noted in another thread, using "size" is incorrect, because it may
overwrite the redzone after the object.
I'll send a patch to fix that.
Overwriting the metadata indeed shouldn't make sense in the allocation case=
.
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

