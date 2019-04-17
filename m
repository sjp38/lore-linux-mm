Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B695C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:04:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8F4B2173C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:04:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rJV/eGTF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8F4B2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5915F6B000A; Wed, 17 Apr 2019 13:04:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 540BE6B000C; Wed, 17 Apr 2019 13:04:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42FA26B000D; Wed, 17 Apr 2019 13:04:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1C7F66B000A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:04:47 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id v4so10733808vka.10
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:04:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=ZebXcbPeVNYkkX9yJaiZl3S9wzSgvNBK3FgGu78AaCE=;
        b=evuRjhTKjeWiRhAZ9pAWHwOHfag6yQfikfD0C13tLotNIdjilmeJWDDZJy0868jitN
         zxEF+2z6Up5gydmfGaEn2n/ShdjT73dewN9U+zDooc1keJjVLCxbxgSx6/abksbh/gRO
         Iz0wkwuTYdz/9ClANUrId/mrpqC9a9vSgJ7C9D6Nf17B8YetCHboPTaxBnsPYPwE4ilf
         0Peh7+2kxwVvDMgGVvO7VY6reMRfAG9lps6bOigedD+narIJisKKPIehdpzBjHghLjyJ
         Bv6ToIJlg/xW5pfz20BFGL0ynrRzpRYhUOkE6E6HAX5l5mAYmFtOSFOUVFSypdwEXGX0
         oRjg==
X-Gm-Message-State: APjAAAWvboAd9/OFD9CiCqcUbCp48vZitGTFiqu1LNZRjiTVGT6Z+vsn
	pY+LAvHQ0DW4IRSdof6lbkrS9PC/2Pl4niB3yr2ylIoUpsRqsy+2yCOkFLRKx3h7I84o95M3zHM
	nglKgNNHHLsA0MniZxiuqWVV6AlIpLYVbWqGKY7dKYbnCvAP8RYU00tQq+mPRYCWSGg==
X-Received: by 2002:ab0:b90:: with SMTP id c16mr1704971uak.55.1555520686728;
        Wed, 17 Apr 2019 10:04:46 -0700 (PDT)
X-Received: by 2002:ab0:b90:: with SMTP id c16mr1704929uak.55.1555520685955;
        Wed, 17 Apr 2019 10:04:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555520685; cv=none;
        d=google.com; s=arc-20160816;
        b=sLpEuzbPpHBsdSpZK2vhc6/CTUveYvlMo6gepJznHOSXCi8m48SV/RKlCC/CUULlW4
         tRSzkq+nCjcmMCbP0eeeFyTP4Z9D6K7IkdVTusUho1/1L+2qwyM7aj27wAVHC/BF3AjR
         5XMq6E18REVf0tNAoaOKJiuMJiDxaFt9QFlZHPeKc50QumXJ4o4zbz/tC6nukVNSRUHq
         Q4PtHFwfcC68SMpcFZ5j0wGXCBJTaR1CuPxSxJQvgq0QSYdhd+IuYeKzc5kI8AMQkLjz
         MHS7XEiGFe5XqURHv85fLdABLtEAupdnSVz3XW80EfeT0iLW4LZqQwk/xI12mGiFJdM/
         Boyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ZebXcbPeVNYkkX9yJaiZl3S9wzSgvNBK3FgGu78AaCE=;
        b=PdkQ/2xbIc7Zc9S05aliweNpUHALgGJsSRx5nwIpamHCEj9BG0Bano65Ma5qFGQL0A
         9H73dQVj/9OgowwOLeRC9slxhFN33Z1IC6tgtazWebKgCb4Dg3RelW2wXI5ixBCbSh8I
         E9QuyTNk/ft+SHZppukPHktGgM814Ld6jwjMzIxULBPJUhgLHOwIcDdK97i6bLlcqS0C
         LIWjCOq9HXyQPy7h+S673f67d98oiUOJey64l6GHsdEw1xUAUIHILrXHff/Exji3aF5m
         jTTpFDRrGYybJJf9OaNMMy6CrhJtq8nVv89WmU4wL3s+PDBHn27uxWiiI+PJBSSA5/hk
         VqlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="rJV/eGTF";
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t13sor33736084vsm.11.2019.04.17.10.04.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 10:04:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="rJV/eGTF";
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=ZebXcbPeVNYkkX9yJaiZl3S9wzSgvNBK3FgGu78AaCE=;
        b=rJV/eGTFo1+fnGJmSyo4+xil5449L1OKBtDHkZ9nA3qiNq/Tt3wAMSZVVB2nvWiZly
         gp6+0PW2FCUXoi8rhrIoooa6Gv2tuBOp5vJ3EeO5HTRgD5zLxGJlidxN20m6vAG/WN7s
         1Jqi0odOTjHP2OvlaqMWHYrRB6shoWrFgistYzQvOgnAkd6ZgNZgzuJDRKuIT7pCmPtj
         QkNL4g+/YKQiqP/8Uqp3SswOGp2RMhvDLv84OI+RHJdYNZ9UoFZf/5JrFQ7QlXwYo9VS
         tFYKa9K/W2pUyIcO3JQeJz++dnP9W5+hKQz+vP7wwi/BIowHFzXS8ZDW8Lcwm5WzjSBT
         czSQ==
X-Google-Smtp-Source: APXvYqyth700R2P9Z5YeZllE6N3/x5jl7uGJWDZ5uk7e3eN4YreSXsUzJgfEggRBiI07XM09qPD6JHxtPpvj0M/RPNs=
X-Received: by 2002:a67:eeda:: with SMTP id o26mr50920891vsp.209.1555520685261;
 Wed, 17 Apr 2019 10:04:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190412124501.132678-1-glider@google.com> <0100016a26c711be-b99971ca-49f5-482c-9028-962ee471f733-000000@email.amazonses.com>
 <CAG_fn=U6aWfBXdkcWs0_1pqggAC16Yg8Q6rxLiVeiO83q1hOCw@mail.gmail.com>
 <0100016a26fc7605-a9c76ac4-387c-47a3-8c53-a8d208eb0925-000000@email.amazonses.com>
 <CAG_fn=XW=-=SiAjToBNGDBdr1iZFA-9Ri_a4tF40448yPTbU4w@mail.gmail.com>
In-Reply-To: <CAG_fn=XW=-=SiAjToBNGDBdr1iZFA-9Ri_a4tF40448yPTbU4w@mail.gmail.com>
From: Alexander Potapenko <glider@google.com>
Date: Wed, 17 Apr 2019 19:04:33 +0200
Message-ID: <CAG_fn=UMww4b8+NuBZ82pq4DS19tQx=h_3E6C2s3fkLLGD7fMg@mail.gmail.com>
Subject: Re: [PATCH] mm: security: introduce CONFIG_INIT_HEAP_ALL
To: Christopher Lameter <cl@linux.com>
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

On Wed, Apr 17, 2019 at 1:03 PM Alexander Potapenko <glider@google.com> wro=
te:
>
> On Tue, Apr 16, 2019 at 6:30 PM Christopher Lameter <cl@linux.com> wrote:
> >
> > On Tue, 16 Apr 2019, Alexander Potapenko wrote:
> >
> > > > Hmmm... But we already have debugging options that poison objects a=
nd
> > > > pages?
> > > Laura Abbott mentioned in one of the previous threads
> > > (https://marc.info/?l=3Dkernel-hardening&m=3D155474181528491&w=3D2) t=
hat:
> > >
> > > """
> > > I've looked at doing something similar in the past (failing to find
> > > the thread this morning...) and while this will work, it has pretty
> > > serious performance issues. It's not actually the poisoning which
> > > is expensive but that turning on debugging removes the cpu slab
> > > which has significant performance penalties.
> >
> > Ok you could rework that logic to be able to keep the per cpu slabs?
> I'll look into that. There's a lot going on with checking those
> poisoned bytes, although we don't need that for hardening.
>
> What do you think about the proposed approach to page initialization?
> We could separate that part from slab poisoning.
>
> > Also if you do the zeroing then you need to do it in the hotpath. And t=
his
> > patch introduces new instructions to that hotpath for checking and
> > executing the zeroing.
> Right now the patch doesn't slow down the default case when
> CONFIG_INIT_HEAP_ALL=3Dn, as GFP_INIT_ALWAYS_ON is 0.
> In the case heap initialization is enabled we could probably omit the
> gfp_flags check, as it'll be always zero in the case there's a
> constructor or RCU flag is set.
> So we'll have two branches instead of one in the case CONFIG_INIT_HEAP_AL=
L=3Dy.
>
Ok, I think we could do the same without extra branches.
Right now I'm working on a patch that uses static branches in the
function that checks GFP flags:

static inline bool want_init_memory(gfp_t flags)
{
        if (static_branch_unlikely(&init_allocations))
                return true;
        return flags & __GFP_ZERO;
}

and does the following in slab_alloc_node():

        if (unlikely(want_init_memory(gfpflags)) && object)
                s->poison_fn(s, object);
, where s->poison_fn is either memset(object, 0, s->object_size) for
normal SLAB caches or a no-op for SLAB caches that have ctors
(I _think_ I don't have to special-case SLAB_TYPESAFE_BY_RCU).

With init_allocations disabled this doesn't affect the kernel
performance (hackbench shows negative slowdown within the standard
deviation). Most certainly the indirect call is performed not too
often.
With init_allocations enabled this yields ~7% slowdown on hackbench. I
believe most of that is caused by double initialization, which we can
eliminate by passing an extra GFP flag to the page allocator.

>
> --
> Alexander Potapenko
> Software Engineer
>
> Google Germany GmbH
> Erika-Mann-Stra=C3=9Fe, 33
> 80636 M=C3=BCnchen
>
> Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
> Registergericht und -nummer: Hamburg, HRB 86891
> Sitz der Gesellschaft: Hamburg



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

