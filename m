Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 869BFC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 15:00:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4097A20663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 15:00:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DK/n2Vrq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4097A20663
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCF268E000F; Wed, 26 Jun 2019 11:00:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B80288E0002; Wed, 26 Jun 2019 11:00:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A47968E000F; Wed, 26 Jun 2019 11:00:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8158C8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 11:00:57 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id g189so539309vsc.19
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:00:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=zoBpYP6DnaC2e4XaW1/B4gA/As2GEKNd5dW1F1ry1DA=;
        b=OJ7D5vUKcbfZnsuBwRbFPLjD6wIgxvx/ozO/FQLX5TXEaS5rLMuJfcf5Y1R3NHYClC
         q8JHvDZkUJHZKo6/85K3ePdyoqpTImoOkC60g0DJryfx8Au3KBxFe5GkYkKTjFfUSpAy
         tv2fWV0OZ5WgDgfNgPlZu/wBDI5+6MNeKo83q7VyJ2rFSO8C3ZYQHwaE6Oo/sve5g1C7
         YZq5Ks8HBEmaw7/SCh2DVC8SJBt34JvA8BnHr4BMfscbvw0WoOhnwj4V+yF+4UqsfiNw
         RDoWwUQEQz1cdTXNGDcDLfjNYbqtp3uzGVKhrWHBdXjqdsucVbFxU5PkKyJArKl75fHF
         fBMA==
X-Gm-Message-State: APjAAAUN7SsDk3G2cOpFl8sVFanchpslCzwRCa30t3zKZL5vU7DS0xNV
	Hwp1ZoZZ4ULkTexQQWy7g5Ah1HvlBPPiaT8uRqW70b5xNhxT0e/m5lRW/KvpiIjlzON56L9I7sQ
	U3bl5/269s+6wvoi7pQ3YMXNtU5vEjfgN8eM5r44sdyu5v0leyZfTSL20YYhv72vtjw==
X-Received: by 2002:a67:ff0a:: with SMTP id v10mr3303380vsp.1.1561561257166;
        Wed, 26 Jun 2019 08:00:57 -0700 (PDT)
X-Received: by 2002:a67:ff0a:: with SMTP id v10mr3303332vsp.1.1561561256439;
        Wed, 26 Jun 2019 08:00:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561561256; cv=none;
        d=google.com; s=arc-20160816;
        b=hRLLovHBig/tYdho1215c3jpObGM9jSHpfGf6ME//WqW4zpp/qM1kwfYIE8hciU7X1
         7HTikZf7HROoRqp88kUTVaPuP4aY2CtB8xEUnAid5fWSQXeTtjvgKQJenXdbJphR4zZo
         yVr9N9zSopsJSzunxPMIIk6KnbSxaT2T/VC/uYjhfosRfhiZYm3FOaMGKejBj0pOMnKg
         XJGTo95Qz7tiV3bFKWXQz29AoZbsOAU6wtWlk2zVzQBaUSYqh2itjDXc4r2k0tzdUPcL
         RVxf+Ny9UMHXOkfCiW/HfxBciadm1QYDa+RdeGsJ8z5RMs396RfLnSPHt9gFVUgXmclP
         Xu2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=zoBpYP6DnaC2e4XaW1/B4gA/As2GEKNd5dW1F1ry1DA=;
        b=Su+0T4e2OuBVCWUxBTFePMzPfrmowMyjeP1XcumI/DI0PKERn3jSn2lQqSHYr6TR3V
         3LkV5mDHB8gZaSyw0gplDsIxjsGMSooiGFPc7XXzmqFr+7Z0J/Ok+0KUi9sKWZF+tMUt
         +4gv92JidtCGsg8rfPWy9oTapaQVpG19vtynFcCLwOFq+yZbrhYh2ItR9nVx6AkSnjyw
         crmhakB0grL9KSS5Zrqk8Bbf4d8zGDV/O1v4cmxxAvIHweDCVnWAPSMZQE43uIejlEcZ
         pAVbtMLk18aEUecKl9YsoAxWQfW9W2BGf87OufHJAFYvacKD+tNHdo9sMIn9pg4yna6o
         IpiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="DK/n2Vrq";
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j8sor9220271uad.24.2019.06.26.08.00.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 08:00:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="DK/n2Vrq";
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=zoBpYP6DnaC2e4XaW1/B4gA/As2GEKNd5dW1F1ry1DA=;
        b=DK/n2VrqOoEDzclYHyq2tl89y1S1BefzXcCfPYtMbncmdAEousuPD4nlrlFXjn1yAf
         0UZ2zw7aNcVImRdErGoO1CbC7dXKUVSHtuP/yzBJwyIo0zemDC+R1hWnWRVjgVrAnU/G
         cvK2xJ+dmRwfI/NlGzWTm84i2qOlJR71o3B40rbm5P6vctgPwQKEgs1Tg5/t6YaLCHdC
         NspZwHSWueky8RI+rBqgzac4hPLgVsWXreGq8arKJv49UONak6A2T0SZgr27vzlXESkF
         A2h4u/1rIlOtZdFXckVdzyVlUD6I+t5bFeMa4UmxkyNAZS24W5IdZKhDlhFU8RIuBuk/
         acXQ==
X-Google-Smtp-Source: APXvYqxOM1Qhb4bYwyr4BHkaaqPHuZq394nkXxdn6QI/Fj8/wCimkp9o3YMPWPV8de9K2LGJFGbIpbZSCKxhz9J77fk=
X-Received: by 2002:ab0:3d2:: with SMTP id 76mr2748402uau.12.1561561255636;
 Wed, 26 Jun 2019 08:00:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190626121943.131390-1-glider@google.com> <20190626121943.131390-2-glider@google.com>
 <20190626144943.GY17798@dhcp22.suse.cz>
In-Reply-To: <20190626144943.GY17798@dhcp22.suse.cz>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 26 Jun 2019 17:00:43 +0200
Message-ID: <CAG_fn=Xf5yEuz7JyOt-gmNx1uSM6mmM57_jFxCi+9VPZ4PSwJQ@mail.gmail.com>
Subject: Re: [PATCH v8 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Nick Desaulniers <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>, Qian Cai <cai@lca.pw>, 
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

On Wed, Jun 26, 2019 at 4:49 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 26-06-19 14:19:42, Alexander Potapenko wrote:
> [...]
> > diff --git a/mm/dmapool.c b/mm/dmapool.c
> > index 8c94c89a6f7e..fe5d33060415 100644
> > --- a/mm/dmapool.c
> > +++ b/mm/dmapool.c
> [...]
> > @@ -428,6 +428,8 @@ void dma_pool_free(struct dma_pool *pool, void *vad=
dr, dma_addr_t dma)
> >       }
> >
> >       offset =3D vaddr - page->vaddr;
> > +     if (want_init_on_free())
> > +             memset(vaddr, 0, pool->size);
>
> any reason why this is not in DMAPOOL_DEBUG else branch? Why would you
> want to both zero on free and poison on free?
This makes sense, thanks.

> >  #ifdef       DMAPOOL_DEBUG
> >       if ((dma - page->dma) !=3D offset) {
> >               spin_unlock_irqrestore(&pool->lock, flags);
>
> [...]
>
> > @@ -1142,6 +1200,8 @@ static __always_inline bool free_pages_prepare(st=
ruct page *page,
> >       }
> >       arch_free_page(page, order);
> >       kernel_poison_pages(page, 1 << order, 0);
> > +     if (want_init_on_free())
> > +             kernel_init_free_pages(page, 1 << order);
>
> same here. If you don't want to make this exclusive then you have to
> zero before poisoning otherwise you are going to blow up on the poison
> check, right?
Note that we disable initialization if page poisoning is on.
As I mentioned on another thread we can eventually merge this code
with page poisoning, but right now it's better to make the user decide
which of the features they want instead of letting them guess how the
combination of the two is going to work.
> >       if (debug_pagealloc_enabled())
> >               kernel_map_pages(page, 1 << order, 0);
> >
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

