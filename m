Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59E4DC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 11:40:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8BFD218A3
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 11:40:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FWENStUR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8BFD218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50AF56B0003; Wed,  3 Jul 2019 07:40:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E2828E0003; Wed,  3 Jul 2019 07:40:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F9698E0001; Wed,  3 Jul 2019 07:40:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E9B196B0003
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 07:40:39 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id x2so951342wru.22
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 04:40:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=zHeU17lmmKwn4HqZvPfxORCzKm21XY5rEHkO8j8X2vA=;
        b=d6Kav93HZ4wWNWHAg7ke3XTDciAeq9/WTItHmgvDo+eMmcVy7lC3kKFsXKZ0UF2uNn
         7eWgfrPT14AkfzH2QZTM1hGVcYRpFDVHqHpFo3zgjSIg8lem//dT4iGpsjosySNagTKH
         m9u1kcLKolhpmLmpGNIE+rt0aJlq9s67OmxhYTyu++oFPDeFe+5HypHBa2uy8z8N3u0X
         DBa+IgGepXEgYXQ1QYiGGXykTh5Ub/e6YgNh0QAyOcUo0buMhAdFaJzYj7VabxXRXotj
         4gh2J7oi3Qg9B/sjp/C3LOVLT42eiGIsmF5G43m124NSupazsbo4wCDYb68ARQhoJtH9
         BBaw==
X-Gm-Message-State: APjAAAXHpQiPPw6GiFMQcO8GtDxEnGEiEh9fHhAB01fnC9jmmXKEoOKk
	npVM+Db4DKNHL2XB2w86bVrXNNgqQX4EFQcKmWIkbRgTgFJHLVT2f9YkjuSZcx7hl7t2T1B/IFn
	P3GvCv15EkbLlDf1jc8hBU6IjruPxAddg3ZWmVHdLjSHoMUHkIhDYzx0j+nY0DIOZrA==
X-Received: by 2002:adf:fb8d:: with SMTP id a13mr28903481wrr.273.1562154039495;
        Wed, 03 Jul 2019 04:40:39 -0700 (PDT)
X-Received: by 2002:adf:fb8d:: with SMTP id a13mr28903434wrr.273.1562154038575;
        Wed, 03 Jul 2019 04:40:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562154038; cv=none;
        d=google.com; s=arc-20160816;
        b=lhTZlnh2PKBwwQ+JyEJYoL737dJBGdGc+yJERHM84OM/6xbal9EOpiIDhFizIy4h+l
         rTMJQb9qRs5rcPdoz7ndgnkA19EXUvAy1fXD9cfBdRvVEWYVq1A6p0rykkSdMIBZvHYk
         w6NvJR84BlVAyUHVhw8DwwpgyWF9v9WV4yYAgSe+OEZHgSWqh0XvPWyf0Ka6r/1v9K6f
         vV+kBC8VOFza+wvDxecVt01j3/4Dep6h6zlTe5XuDvTPL+mEjl+eQcNYx2R5dvGKF7iN
         4LFr6BgrqhkmbvgP5whO+zMEB791USv3+qAeBerf+AlcPR/DBYr0Zd6Tl1fih0BKDa4m
         l4Ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=zHeU17lmmKwn4HqZvPfxORCzKm21XY5rEHkO8j8X2vA=;
        b=GXPDpABPES9sdJutqGA3Ee+zKbqg0r0nmT/g2IamzBaOAUjDrp+kHIwTXXZ7tPtFwD
         xF2P+kWKltfEyEohNNVY/07lnToTNCaZ6pfscof4SUI5v6RQkkLeDFI9ANjvOFRPwP8u
         MSqhS/B1eT5zamb3foOvYp//d41Sh84vkYKw908qzkoTcB9MBc1NSO/Qu4g1iPUSPGft
         L+9tiOS7s45B9t2V6unOx+WlT8Bw/XZBZ4v6tkrA23hdF+gW+BHOmK4FBIKg2b0QJGhi
         nfA7HoJc3+Z5Anf+Nyr2N7DPNFgaQi+YVVO69x8hoeENhcKE+NCmMysmTutEPicvB9jH
         JKNw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FWENStUR;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v17sor1636969wrw.44.2019.07.03.04.40.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 04:40:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FWENStUR;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=zHeU17lmmKwn4HqZvPfxORCzKm21XY5rEHkO8j8X2vA=;
        b=FWENStURUf6QH7xHmCVgopjHfyiKu/4SooEMN/M3xfHJoiRlaDcJryuPhpcSa0QXJc
         L2OGx1unh2jzwLITaBnnjL+GuoJtraiLxKV6yuuwcCe9pvwq9hZx4z0p8rb1dKW1pVTO
         3Q4wN347G+HW/3WVDHqpEhiUXAqyeTgLhRTdEIjcxCWtcWipzbrlrk/VUbqy14PnRWq1
         dwEL4HkXik9GgnBAfxtna96yVwHmS8enJF7i9gJaHU+sghXXOMe6qAYrz7Ybqjl/ZHGh
         xuwM9y8QeTH/YAWTdB9V5MSkTN3NZwzYfhkIeupxk5QgP3HNq4qblB4rqUBIrxxGkVov
         hbWQ==
X-Google-Smtp-Source: APXvYqw4s3sYsNizBmCtzQpw8k78tkfYpE3dYnEnwrtdq2L+zw7BXTL3xh1CoycHraoMSTwIPbxeB+18b/h0kSxWd1g=
X-Received: by 2002:adf:f64a:: with SMTP id x10mr20291629wrp.287.1562154037981;
 Wed, 03 Jul 2019 04:40:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190628093131.199499-1-glider@google.com> <20190628093131.199499-2-glider@google.com>
 <20190702155915.ab5e7053e5c0d49e84c6ed67@linux-foundation.org>
In-Reply-To: <20190702155915.ab5e7053e5c0d49e84c6ed67@linux-foundation.org>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 3 Jul 2019 13:40:26 +0200
Message-ID: <CAG_fn=XYRpeBgLpbwhaF=JfNHa-styydOKq8_SA3vsdMcXNgzw@mail.gmail.com>
Subject: Re: [PATCH v10 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@suse.com>, 
	James Morris <jamorris@linux.microsoft.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Hocko <mhocko@kernel.org>, 
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

On Wed, Jul 3, 2019 at 12:59 AM Andrew Morton <akpm@linux-foundation.org> w=
rote:
>
> On Fri, 28 Jun 2019 11:31:30 +0200 Alexander Potapenko <glider@google.com=
> wrote:
>
> > The new options are needed to prevent possible information leaks and
> > make control-flow bugs that depend on uninitialized values more
> > deterministic.
> >
> > This is expected to be on-by-default on Android and Chrome OS. And it
> > gives the opportunity for anyone else to use it under distros too via
> > the boot args. (The init_on_free feature is regularly requested by
> > folks where memory forensics is included in their threat models.)
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
> >
> > Both init_on_alloc=3D1 and init_on_free=3D1 guarantee that the allocato=
r
> > returns zeroed memory. The two exceptions are slab caches with
> > constructors and SLAB_TYPESAFE_BY_RCU flag. Those are never
> > zero-initialized to preserve their semantics.
> >
> > Both init_on_alloc and init_on_free default to zero, but those defaults
> > can be overridden with CONFIG_INIT_ON_ALLOC_DEFAULT_ON and
> > CONFIG_INIT_ON_FREE_DEFAULT_ON.
> >
> > If either SLUB poisoning or page poisoning is enabled, those options
> > take precedence over init_on_alloc and init_on_free: initialization is
> > only applied to unpoisoned allocations.
> >
> > Slowdown for the new features compared to init_on_free=3D0,
> > init_on_alloc=3D0:
> >
> > hackbench, init_on_free=3D1:  +7.62% sys time (st.err 0.74%)
> > hackbench, init_on_alloc=3D1: +7.75% sys time (st.err 2.14%)
> >
> > Linux build with -j12, init_on_free=3D1:  +8.38% wall time (st.err 0.39=
%)
> > Linux build with -j12, init_on_free=3D1:  +24.42% sys time (st.err 0.52=
%)
> > Linux build with -j12, init_on_alloc=3D1: -0.13% wall time (st.err 0.42=
%)
> > Linux build with -j12, init_on_alloc=3D1: +0.57% sys time (st.err 0.40%=
)
> >
> > The slowdown for init_on_free=3D0, init_on_alloc=3D0 compared to the
> > baseline is within the standard error.
> >
> > The new features are also going to pave the way for hardware memory
> > tagging (e.g. arm64's MTE), which will require both on_alloc and on_fre=
e
> > hooks to set the tags for heap objects. With MTE, tagging will have the
> > same cost as memory initialization.
> >
> > Although init_on_free is rather costly, there are paranoid use-cases wh=
ere
> > in-memory data lifetime is desired to be minimized. There are various
> > arguments for/against the realism of the associated threat models, but
> > given that we'll need the infrastructure for MTE anyway, and there are
> > people who want wipe-on-free behavior no matter what the performance co=
st,
> > it seems reasonable to include it in this series.
> >
> > ...
> >
> >  v10:
> >   - added Acked-by: tags
> >   - converted pr_warn() to pr_info()
>
> There are unchangelogged alterations between v9 and v10.  The
> replacement of IS_ENABLED(CONFIG_PAGE_POISONING)) with
> page_poisoning_enabled().
In the case I send another version of the patch, do I need to
retroactively add them to the changelog?
>
> --- a/mm/page_alloc.c~mm-security-introduce-init_on_alloc=3D1-and-init_on=
_free=3D1-boot-options-v10
> +++ a/mm/page_alloc.c
> @@ -157,8 +157,8 @@ static int __init early_init_on_alloc(ch
>         if (!buf)
>                 return -EINVAL;
>         ret =3D kstrtobool(buf, &bool_result);
> -       if (bool_result && IS_ENABLED(CONFIG_PAGE_POISONING))
> -               pr_warn("mem auto-init: CONFIG_PAGE_POISONING is on, will=
 take precedence over init_on_alloc\n");
> +       if (bool_result && page_poisoning_enabled())
> +               pr_info("mem auto-init: CONFIG_PAGE_POISONING is on, will=
 take precedence over init_on_alloc\n");
>         if (bool_result)
>                 static_branch_enable(&init_on_alloc);
>         else
> @@ -175,8 +175,8 @@ static int __init early_init_on_free(cha
>         if (!buf)
>                 return -EINVAL;
>         ret =3D kstrtobool(buf, &bool_result);
> -       if (bool_result && IS_ENABLED(CONFIG_PAGE_POISONING))
> -               pr_warn("mem auto-init: CONFIG_PAGE_POISONING is on, will=
 take precedence over init_on_free\n");
> +       if (bool_result && page_poisoning_enabled())
> +               pr_info("mem auto-init: CONFIG_PAGE_POISONING is on, will=
 take precedence over init_on_free\n");
>         if (bool_result)
>                 static_branch_enable(&init_on_free);
>         else
> --- a/mm/slub.c~mm-security-introduce-init_on_alloc=3D1-and-init_on_free=
=3D1-boot-options-v10
> +++ a/mm/slub.c
> @@ -1281,9 +1281,8 @@ check_slabs:
>  out:
>         if ((static_branch_unlikely(&init_on_alloc) ||
>              static_branch_unlikely(&init_on_free)) &&
> -           (slub_debug & SLAB_POISON)) {
> -               pr_warn("mem auto-init: SLAB_POISON will take precedence =
over init_on_alloc/init_on_free\n");
> -       }
> +           (slub_debug & SLAB_POISON))
> +               pr_info("mem auto-init: SLAB_POISON will take precedence =
over init_on_alloc/init_on_free\n");
>         return 1;
>  }
>
> _
>


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

