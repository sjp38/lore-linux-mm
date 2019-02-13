Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FB46C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:07:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF8CF2147C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:07:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nXb5qnNn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF8CF2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B4F18E0004; Wed, 13 Feb 2019 08:07:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 664EB8E0001; Wed, 13 Feb 2019 08:07:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 554308E0004; Wed, 13 Feb 2019 08:07:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1545A8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:07:41 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id ay11so1642708plb.20
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:07:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JYrfSHAT7eT7lR6t+0pt9fGRo4rQyrecCsCJETIVA34=;
        b=rRLYUvyegI6P1xuGjtXCvSruC2TQzMWCjwoBedfJPA0AseaPmlvt7CSFiCJCGxGEzd
         f8BFfmpnIVa4ZboYyPFPyA1CDSy5KtT//d8/Z1oIrBuMvqClS0CmOO1ckydvj1mWisEa
         FySyWcolAiJEgWCBZy9SOgymc7HxSnOVauO2pU2GVO15Bsexy9OsNLJV9+cPC1KZZ06k
         dMqFpb+4fFDuSWMg+nihtIzQQAcNOlmc0Dnor9Hn3GL4NU88JVhDb2vtv2k5dXthvs6W
         CqJd7EFxswnlujGmsGgphNr5jD3QISSFX5uKS9wc008vsYjgR66w114DcMU14qo9x3ZJ
         kwUg==
X-Gm-Message-State: AHQUAuaQxgFc9FjstuAAW8cYE5LMxLMFLJxhbQxgL1UnD80SCI42r7JY
	jrpRGYNqytDHaL8svkRUX0D5Pl8ScL3VpxajpTlk5a1RP0tintofALj0NEvLfOTrbA+XvurDxhK
	XOAwYz8hiSOlN3F3s0PxnWInjFw3tlk/4baDFzQ2TV+J0k+wL+cUqFly1U1UScrR6yO24Ogq4z0
	NdpAfj47OW4g5hzqv5NVvehy3KCaw45/YJnn2hRev6Uo2RzIbWSTbLwZaMqv5Uf+n3ubfDdkEdm
	lCaizPxPAp/x+Sh8KvmmVlKYum/w+RiCGka6ST0mQ1VNFvzxsbLtgIoxitpbXw3o0HmHF5c5iyy
	DmQFgn2FAhlw7FBT4vK30cHHnl54FO25l0ZpObT6SFjofJEOcIpchApGjmlCWQgAujxyt8gQpP5
	O
X-Received: by 2002:aa7:8199:: with SMTP id g25mr472689pfi.46.1550063260751;
        Wed, 13 Feb 2019 05:07:40 -0800 (PST)
X-Received: by 2002:aa7:8199:: with SMTP id g25mr472636pfi.46.1550063259919;
        Wed, 13 Feb 2019 05:07:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550063259; cv=none;
        d=google.com; s=arc-20160816;
        b=B34YB/NnZc7PG/Ce3WDHDKWPsV7c1IyDaEvwsObBHUSh2RWToi9XjDkcMXK1VAse4F
         UV2sN3tNcx4Fkc4f9EJDj509E5kgl7zYEK4ADGZfpDOS7f0e34n26NBwNmfw6itfsTJ8
         4i7f/oYOOwthvXQ8mV9jFrmWjuZ3eIcwcibok9d2SDfOyGwubdY5/eFe799RjpkmYITc
         DO56k+2zpuDaw448taAzCqpbEZPo9Uu1FbLQRLWYsBCNGiHjMxkazUmBN3rFptVC/FhY
         F8CSbLv97IJuQeLNHdQcIP92iMI8WYVvjnKPF9VbJhiAev0tOym2WmNBJKUkQUiihYgM
         LQbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JYrfSHAT7eT7lR6t+0pt9fGRo4rQyrecCsCJETIVA34=;
        b=IZUXuJv1uDXQfBdAVP3wombNzdQILjivkOpw4EkBAS1puRWOuXr96WeSLdAQkYWR/b
         w0KBzlbU4mqS7XKma6u7je6delIznsKeTGXjzDhFN8qE1fkW18mgHOMTPpk9YOOtlS1q
         VKMM7XcAUe53WhSnusE1A9noo1rHC0bDLqccGxA206j/onahCLNlWRAtBUyeCLpKhLOO
         UkJk2i1fgdFwwzroXSoDwE9Uj5/4HeDo83gbtp1C7Fjj86uLZ05x/2zYbkfIGjhvyeEe
         Sd9SKvaM0amm0e99FZarNV7vnfvQ1vMjNZKIx8nauBaaVRO2C1lByLHTH7Or2XjdXtSw
         +vBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nXb5qnNn;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor23097456pla.7.2019.02.13.05.07.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:07:39 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nXb5qnNn;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JYrfSHAT7eT7lR6t+0pt9fGRo4rQyrecCsCJETIVA34=;
        b=nXb5qnNnL35PnkCzwYA0t9qk3LeIUvzdFzqUgc3HfNw6XKujX0N9F4PMEc1J0smFwp
         baGeDtRtz/EmAIEsOpxxEdCjj2dkvRhWSbaek5tEdaoBJnzWHg1xmsuqiBsrDh7A5bu4
         X1Aka85RpZ0/DW0blmyF3+PdN3inqu79qIvyUq6QZ4I5flwQcXdwwvOjHk6jMzKzub19
         c7QwmFwO5g5s5xd/EI7vqwQlxJqpjucUyqCdCgTuIydMu8mFozKYOcAp19iEufp1I1G0
         /iEvJgOOr53xkFCh9x9Tifk9yF6e/Ksb8VOy2cyHj7AE35+lpqj3pap2cb3Z2ZoPtMLG
         fQ+A==
X-Google-Smtp-Source: AHgI3IammU4XKdw1jiSYG4IdVnZylWrkf8QLpFe83hXNhh7/4s8wn2T5j1LteGVq1mGw7MwIhKQcRSG+a2RfJ/pgPDg=
X-Received: by 2002:a17:902:4124:: with SMTP id e33mr460245pld.236.1550063259161;
 Wed, 13 Feb 2019 05:07:39 -0800 (PST)
MIME-Version: 1.0
References: <cover.1549921721.git.andreyknvl@google.com> <cd825aa4897b0fc37d3316838993881daccbe9f5.1549921721.git.andreyknvl@google.com>
 <f57831be-c57a-4a9e-992e-1f193866467b@arm.com>
In-Reply-To: <f57831be-c57a-4a9e-992e-1f193866467b@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 13 Feb 2019 14:07:28 +0100
Message-ID: <CAAeHK+y7q7BGYCnCNe1PDd+9jcmn7+F5EWxZ_hS+Ae7a2SBuew@mail.gmail.com>
Subject: Re: [PATCH 2/5] kasan, kmemleak: pass tagged pointers to kmemleak
To: Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Qian Cai <cai@lca.pw>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 4:57 PM Vincenzo Frascino
<vincenzo.frascino@arm.com> wrote:
>
> On 11/02/2019 21:59, Andrey Konovalov wrote:
> > Right now we call kmemleak hooks before assigning tags to pointers in
> > KASAN hooks. As a result, when an objects gets allocated, kmemleak sees
> > a differently tagged pointer, compared to the one it sees when the object
> > gets freed. Fix it by calling KASAN hooks before kmemleak's ones.
> >
>
> Nit: Could you please add comments to the the code? It should prevent that the
> code gets refactored in future, reintroducing the same issue.

Sure, I'll send v2 with comments, thanks!

>
> > Reported-by: Qian Cai <cai@lca.pw>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  mm/slab.h        | 6 ++----
> >  mm/slab_common.c | 2 +-
> >  mm/slub.c        | 3 ++-
> >  3 files changed, 5 insertions(+), 6 deletions(-)
> >
> > diff --git a/mm/slab.h b/mm/slab.h
> > index 4190c24ef0e9..638ea1b25d39 100644
> > --- a/mm/slab.h
> > +++ b/mm/slab.h
> > @@ -437,11 +437,9 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
> >
> >       flags &= gfp_allowed_mask;
> >       for (i = 0; i < size; i++) {
> > -             void *object = p[i];
> > -
> > -             kmemleak_alloc_recursive(object, s->object_size, 1,
> > +             p[i] = kasan_slab_alloc(s, p[i], flags);
> > +             kmemleak_alloc_recursive(p[i], s->object_size, 1,
> >                                        s->flags, flags);
> > -             p[i] = kasan_slab_alloc(s, object, flags);
> >       }
> >
> >       if (memcg_kmem_enabled())
> > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > index 81732d05e74a..fe524c8d0246 100644
> > --- a/mm/slab_common.c
> > +++ b/mm/slab_common.c
> > @@ -1228,8 +1228,8 @@ void *kmalloc_order(size_t size, gfp_t flags, unsigned int order)
> >       flags |= __GFP_COMP;
> >       page = alloc_pages(flags, order);
> >       ret = page ? page_address(page) : NULL;
> > -     kmemleak_alloc(ret, size, 1, flags);
> >       ret = kasan_kmalloc_large(ret, size, flags);
> > +     kmemleak_alloc(ret, size, 1, flags);
> >       return ret;
> >  }
> >  EXPORT_SYMBOL(kmalloc_order);
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 1e3d0ec4e200..4a3d7686902f 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1374,8 +1374,9 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node,
> >   */
> >  static inline void *kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
> >  {
> > +     ptr = kasan_kmalloc_large(ptr, size, flags);
> >       kmemleak_alloc(ptr, size, 1, flags);
> > -     return kasan_kmalloc_large(ptr, size, flags);
> > +     return ptr;
> >  }
> >
> >  static __always_inline void kfree_hook(void *x)
> >
>
> --
> Regards,
> Vincenzo
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/f57831be-c57a-4a9e-992e-1f193866467b%40arm.com.
> For more options, visit https://groups.google.com/d/optout.

