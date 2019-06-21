Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25C96C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:31:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E3745208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 13:31:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FGwg6y4t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E3745208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DA656B0005; Fri, 21 Jun 2019 09:31:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58A4D8E0003; Fri, 21 Jun 2019 09:31:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 450938E0001; Fri, 21 Jun 2019 09:31:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1DA996B0005
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 09:31:47 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id j186so2195621vsc.11
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 06:31:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=xxwRR3iqWJYzBJGmHu7dsEOV5WDLCvCciENrha/Bmm4=;
        b=p4apnImhS0YT7UyVD5EPEklrZF6wHTYtsLMi4QKXXyWbe5Bpa5aTXWWJDzB68yr6OX
         7WN68LhcGJYuUcHCwxySOgsqT4qB8HVv0A95tCxED90YY63gL8IfHoMJYy4JhRHTcQrq
         QKa44AIYe22ArDg6oYXUJKIrfP3MCndqpN0RrHs69PlcLSwV3V6CdZPxzqS+OyIzJiXP
         cc1DE2io34lGhXkOlCWtlgFrIFDSR6SHADFDsl0tKTZD1/XQpF2xzmq2FfX61Gswckk/
         +EXvHQq3uOvR8/9EsJD4C/pCdqCh2DtP2no9HhdNZnmR4bV+OE5aCCbR0j9iCknzVZE6
         rM2w==
X-Gm-Message-State: APjAAAUNMYvqnHVyN8A+AFw+ztEIULe4tAKXDf//tKmFBbfqyFs9Ea5K
	fQFA2rfXbByxtWHiiYix21l6VtwFWQF9cemNqROATUE9bcQSJiHI4PVOX2U3RzVAM35p8Fcb1Gr
	WE+zUcWfNMVoF6qwzfkaiewRtm4BkWNoA8VMUpcXe3/mDBsUxMpOkjogbSOxacSbQ0g==
X-Received: by 2002:a67:d611:: with SMTP id n17mr26849883vsj.156.1561123906709;
        Fri, 21 Jun 2019 06:31:46 -0700 (PDT)
X-Received: by 2002:a67:d611:: with SMTP id n17mr26849837vsj.156.1561123906041;
        Fri, 21 Jun 2019 06:31:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561123906; cv=none;
        d=google.com; s=arc-20160816;
        b=JnPttrwX1EyERvhW9eP/qc3gR0stOs9czH1ejZSb8bnfVjqwtvG/gPr+x8+g8B1Rlr
         QFixARm2iXhJ7LE7jH99MVEfYLYtoT0IrfrUUFBxnK/X7BJ7DKGDbNADMrOUdVp/87wP
         RaOq6e2q1ZnHlFS9oBquw9t5jwb8cCE85KP2hLWgqk6XamMR4qGz2bIelz4R1Y3vLHho
         jQe4zAoxBQNNkgK0yuvShkIPUAED/PmVIEzHWpj0ogIfHA2LztIU2oU5yG28UjmnMmzF
         HoS+q4rmIPg5eaj/+aBZi/WJqvlS4p+hIV6QaOoukm75+N7ZyMN2pvHNq5FjzbXAU52d
         nAUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=xxwRR3iqWJYzBJGmHu7dsEOV5WDLCvCciENrha/Bmm4=;
        b=qWxeU2OeZe88WtjPrAT9LV8WwxkEwsr7qOXCVeZYHAALXTFic1BLAZRiMg6A+OpFUj
         GZox7+MqCc/vFCpcs7BdNgsPR0/f+6OLbwmc1LZWQ253j53a09cz9xJrKPLRgfcv8TXn
         LwV+dkonJ/zBvzJ6V4Q6Ow6U6xS4Qp+ouEm5OrYe3uemU+QV0vkuI/df7ef4+vFCEHn1
         mBanxcOaKyZK4gvubCiMKG2l9JEyRLzrF+Fp0dh459no+9JLntcJDdzy4Fx0xb02ofJg
         QMnPedS22V1C3h6RlHeAnjQ/ZeW9H4PGtM2frQFN9ISOxZlMhsaIUh0picywgWB2JD6Z
         duLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FGwg6y4t;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a18sor1436296vsl.61.2019.06.21.06.31.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 06:31:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FGwg6y4t;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=xxwRR3iqWJYzBJGmHu7dsEOV5WDLCvCciENrha/Bmm4=;
        b=FGwg6y4tEufdq6RAhV0WTf04zK/j/S2XarThF7HqWhORPY+P3zwonTzns8twxYIjSP
         AXe8aBdrpRV8x6csSbn1wYvxG4jPeXqT1JM/p10rrAaCoY2oHgeU2K1YfhldWF7kEuo8
         jjFGGO63zFe/2PifMPG0GA7ahxFipfxrwCtQ4CfZB6D3ebhKcygGNDtAG+qASjBgVafY
         Tu35YEa2pLUa8Uz3DDexgxERxTRADUBiQ7l4ro4GwkM5ze29gg3CYA34kF55/JFYcMbw
         uDbLN7Xn7YGw5AaFVWC8VBk0djfQqD+i+1pQnDWydmho9dC1eCiaNirLdTIkVHHSm8xy
         RTog==
X-Google-Smtp-Source: APXvYqxwmfAhfqMtFmOa9Nrjd+Ahc6EvQ5HIW+ekr/0AZJ0siFcoYtV8yYZRkqXE70xqE7CAFXLv5oaqUvPX5ET8s5M=
X-Received: by 2002:a67:8d8a:: with SMTP id p132mr10831738vsd.103.1561123905391;
 Fri, 21 Jun 2019 06:31:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190617151050.92663-1-glider@google.com> <20190617151050.92663-2-glider@google.com>
 <1561120576.5154.35.camel@lca.pw>
In-Reply-To: <1561120576.5154.35.camel@lca.pw>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 21 Jun 2019 15:31:33 +0200
Message-ID: <CAG_fn=XKK5+nC5LErJ+zo7dt3N-cO7zToz=bN2R891dMG_rncA@mail.gmail.com>
Subject: Re: [PATCH v7 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	Michal Hocko <mhocko@kernel.org>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Nick Desaulniers <ndesaulniers@google.com>, 
	Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
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

On Fri, Jun 21, 2019 at 2:36 PM Qian Cai <cai@lca.pw> wrote:
>
> On Mon, 2019-06-17 at 17:10 +0200, Alexander Potapenko wrote:
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index d66bc8abe0af..50a3b104a491 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -136,6 +136,48 @@ unsigned long totalcma_pages __read_mostly;
> >
> >  int percpu_pagelist_fraction;
> >  gfp_t gfp_allowed_mask __read_mostly =3D GFP_BOOT_MASK;
> > +#ifdef CONFIG_INIT_ON_ALLOC_DEFAULT_ON
> > +DEFINE_STATIC_KEY_TRUE(init_on_alloc);
> > +#else
> > +DEFINE_STATIC_KEY_FALSE(init_on_alloc);
> > +#endif
> > +#ifdef CONFIG_INIT_ON_FREE_DEFAULT_ON
> > +DEFINE_STATIC_KEY_TRUE(init_on_free);
> > +#else
> > +DEFINE_STATIC_KEY_FALSE(init_on_free);
> > +#endif
> > +
>
> There is a problem here running kernels built with clang,
>
> [    0.000000] static_key_disable(): static key 'init_on_free+0x0/0x4' us=
ed
> before call to jump_label_init()
> [    0.000000] WARNING: CPU: 0 PID: 0 at ./include/linux/jump_label.h:314
> early_init_on_free+0x1c0/0x200
> [    0.000000] Modules linked in:
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.2.0-rc5-next-201=
90620+
> #11
> [    0.000000] pstate: 60000089 (nZCv daIf -PAN -UAO)
> [    0.000000] pc : early_init_on_free+0x1c0/0x200
> [    0.000000] lr : early_init_on_free+0x1c0/0x200
> [    0.000000] sp : ffff100012c07df0
> [    0.000000] x29: ffff100012c07e20 x28: ffff1000110a01ec
> [    0.000000] x27: 0000000000000001 x26: ffff100011716f88
> [    0.000000] x25: ffff100010d367ae x24: ffff100010d367a5
> [    0.000000] x23: ffff100010d36afd x22: ffff100011716758
> [    0.000000] x21: 0000000000000000 x20: 0000000000000000
> [    0.000000] x19: 0000000000000000 x18: 000000000000002e
> [    0.000000] x17: 000000000000000f x16: 0000000000000040
> [    0.000000] x15: 0000000000000000 x14: 6d756a206f74206c
> [    0.000000] x13: 6c61632065726f66 x12: 6562206465737520
> [    0.000000] x11: 0000000000000000 x10: 0000000000000000
> [    0.000000] x9 : 0000000000000000 x8 : 0000000000000000
> [    0.000000] x7 : 73203a2928656c62 x6 : ffff1000144367ad
> [    0.000000] x5 : ffff100012c07b28 x4 : 000000000000000f
> [    0.000000] x3 : ffff1000101b36ec x2 : 0000000000000001
> [    0.000000] x1 : 0000000000000001 x0 : 000000000000005d
> [    0.000000] Call trace:
> [    0.000000]  early_init_on_free+0x1c0/0x200
> [    0.000000]  do_early_param+0xd0/0x104
> [    0.000000]  parse_args+0x204/0x54c
> [    0.000000]  parse_early_param+0x70/0x8c
> [    0.000000]  setup_arch+0xa8/0x268
> [    0.000000]  start_kernel+0x80/0x588
> [    0.000000] random: get_random_bytes called from __warn+0x164/0x208 wi=
th
> crng_init=3D0
>
> > diff --git a/mm/slub.c b/mm/slub.c
> > index cd04dbd2b5d0..9c4a8b9a955c 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1279,6 +1279,12 @@ static int __init setup_slub_debug(char *str)
> >       if (*str =3D=3D ',')
> >               slub_debug_slabs =3D str + 1;
> >  out:
> > +     if ((static_branch_unlikely(&init_on_alloc) ||
> > +          static_branch_unlikely(&init_on_free)) &&
> > +         (slub_debug & SLAB_POISON)) {
> > +             pr_warn("disabling SLAB_POISON: can't be used together wi=
th
> > memory auto-initialization\n");
> > +             slub_debug &=3D ~SLAB_POISON;
> > +     }
> >       return 1;
> >  }
>
> I don't think it is good idea to disable SLAB_POISON here as if people ha=
ve
> decided to enable SLUB_DEBUG later already, they probably care more to ma=
ke sure
> those additional checks with SLAB_POISON are still running to catch memor=
y
> corruption.
The problem is that freed buffers can't be both poisoned and zeroed at
the same time.
Do you think we need to disable memory initialization in that case instead?


--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

