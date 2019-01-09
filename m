Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58546C43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 05:37:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1156420821
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 05:37:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gRbk6JCm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1156420821
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CCC98E009D; Wed,  9 Jan 2019 00:37:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97DA48E0038; Wed,  9 Jan 2019 00:37:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8454C8E009D; Wed,  9 Jan 2019 00:37:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5056B8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 00:37:05 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id l83so3138261ybl.3
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 21:37:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vwQxFHxz+8PmQyG66B5Bjl07PiypQuWXpFzP5iBeaM8=;
        b=BWNjKj55fN6PscUCbhdvLnA/jmBHyvDiceAQeyIG3Nv1MMmwwdgBgm8iEQwbst8LuE
         sa0gDdSf7Qs7y5LAqXzhYQ1qsgTSjYT4aFd5Q9M3aopOYcvo/6YD/KLkjhZFv4D2A7vF
         GCGX4rZFKrKU/h44mk+2/0hY1+NLd37xg9kPXHSpMUR38aHMDjC5X68W9Gs/Sm8lQE24
         IJs2MFPuVK5SSmAlKZeSO8UOFJZl6LQ6MSD0IzJJt8M1n2g3afeYk5RxoC9h6TupVb7u
         iJGLymA/mKK5cxe8iWqZapy+nJ81+6csunXYfrNBDC5u3ONAYwy8db3mzcN1ZZ+sefuv
         ukEw==
X-Gm-Message-State: AJcUukcuIcj0ziHT/hdqfRxTZ8R36oSJEGa7tHZugXz6UduNPbk8ocDE
	OyLUnqhZ+YrFJ8NunsR1OlqY6hMe4htMrWoRKZ7rXpfNgAy0j87/uhuVQMoEFo+6kTNiI6ja8FN
	LpxfE9EcEHCzk0vVc6FuUnt9cPCnbUJB6n9GDWpFVDpLvfcGltpByibflUjXCJuSKVlSb50w29C
	29xgmCautEFarObHTr6I6anF9Q3YQNjq9FnlhzWj4QF0yJcRT6i94XmaDCdHE773MpWfhsACgPO
	qndsKbSkaEcN6B6PyMrcUbl4bq8G/EpbcQfIiHRSnKKz1s8/a1toEzcnRANCV+q/LPj0N0VwVx9
	MRJYKpSwgxGw1GJsnxR2LWQ8pg9dQnZ2JuPuh9ca+udpZxnxo+rqsTYsjP6KGT+JtXq56DJbDXk
	H
X-Received: by 2002:a25:f205:: with SMTP id i5mr4377963ybe.513.1547012224952;
        Tue, 08 Jan 2019 21:37:04 -0800 (PST)
X-Received: by 2002:a25:f205:: with SMTP id i5mr4377939ybe.513.1547012224171;
        Tue, 08 Jan 2019 21:37:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547012224; cv=none;
        d=google.com; s=arc-20160816;
        b=KPey7biMv3ZuI37DORsuKMbH4nEGHnDbt+kCb7M1kmJaZo7K+3g02m7dpB7M6Knu5B
         rxxQ7pYdKqq6/dAp6eFlhgmzgTeVJMJo+J6iPuuyFw4Rw63d+daD3Kbfd/vEyuJuF4ud
         s7G0aU9QCIM6ZhnRrIQC5BTSiEXsMvl2f2Z1CCDA0t8/ns6kx0T37WxR1bD2aW/6jL8c
         s5wh0ue3qhAAaB4TQ/WLD3aPHKXPlqNkqYV8uzM4P3PrN5srJsgkOGWROddUxfQt5eHR
         2ekO8qrWxI3p3JN7rBJ4vLN2nm3GCCGkYCzuL6uFu49YAOm5TduTdZzQ66O0txtxjxrd
         JU4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vwQxFHxz+8PmQyG66B5Bjl07PiypQuWXpFzP5iBeaM8=;
        b=EvdZd8pQCNfM+MMwvmJb65hFJZcEM4jM6i3pmXKBoPbCglyv2+gfi3CTdiFRi3V2ao
         IcMSGySqDkFocH3AWQ+TveoHBLq1W2aR179k4rRANt7Tf+KYQtULfhF4WIKtxMa1r57R
         BFVJjiOPPLDHtDprT/R3WvnLxkULJevD4Bl1CC0PnAHyq9LVEza5ocuMD1Ijb0DPXZNO
         wgdk1fYGUealb0fkEm5StWEvJ0Bi3uMhn8CvqhGXuO1oLelmazzwPyj0u7eYWtFKM5Gz
         XcOImQrgR/yJC1IzIeUYdrZUNj+iBAMiXwftv+duJ0sTHXx+yqGawtwSqqSC2CfZWrUX
         yn3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gRbk6JCm;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 137sor9566624ywt.40.2019.01.08.21.37.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 21:37:04 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gRbk6JCm;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vwQxFHxz+8PmQyG66B5Bjl07PiypQuWXpFzP5iBeaM8=;
        b=gRbk6JCmU2CIyHjhyHknRGFjIUVAKs8xvIdigwAVIuSKyCvxBfKWmEVjYCcWtobprT
         CFjC+9Ysm2Sfi+DZMJXPWo/LbwpFsCQwO7e6qGJRBeaO93PU6iaYHnw5x1UZnSeAD2gK
         8qhsPxU2Yt26YHYZNGhCTkdYvFn8i/7MCumbpFWJxnozabI+0tD5qT543MX104MNw1Qj
         LXMeGwoPePRaiii4eIRn3hoHYT/lBwz/3Jkfx/rheYyfrwh22/9QBPdxhQg4rPIcxWo9
         /Ug7ua5VVJP59LjSnuhLi8I02u5nIcio6baD8MHHu/SLdbQyFb8a23b+CQ/Y3YvV4V0j
         2Xjw==
X-Google-Smtp-Source: ALg8bN69HzwcjQgfkTDmg9mJXNVwwm85Eeo0s32ItOAKgn1RGoRtq2+sreNKXEGKTRMIl4fv8vrRuuhE1TopsLiEz0M=
X-Received: by 2002:a81:29d5:: with SMTP id p204mr4406394ywp.285.1547012223494;
 Tue, 08 Jan 2019 21:37:03 -0800 (PST)
MIME-Version: 1.0
References: <20190109040107.4110-1-riel@surriel.com>
In-Reply-To: <20190109040107.4110-1-riel@surriel.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 8 Jan 2019 21:36:52 -0800
Message-ID:
 <CALvZod6=-kdUk23i7eOr5AO-_2Fk_BmJiL3QjSJ4S4QOs0xKkw@mail.gmail.com>
Subject: Re: [PATCH] mm,slab,memcg: call memcg kmem put cache with same
 condition as get
To: Rik van Riel <riel@surriel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com, 
	Linux MM <linux-mm@kvack.org>, stable@vger.kernel.org, 
	Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109053652.v8bvX-Hp3r2vcsAsalJ1fon4ZhP20Nuesb-Vc8NMfxY@z>

On Tue, Jan 8, 2019 at 8:01 PM Rik van Riel <riel@surriel.com> wrote:
>
> There is an imbalance between when slab_pre_alloc_hook calls
> memcg_kmem_get_cache and when slab_post_alloc_hook calls
> memcg_kmem_put_cache.
>

Can you explain how there is an imbalance? If the returned kmem cache
from memcg_kmem_get_cache() is the memcg kmem cache then the refcnt of
memcg is elevated and the memcg_kmem_put_cache() will correctly
decrement the refcnt of the memcg.

> This can cause a memcg kmem cache to be destroyed right as
> an object from that cache is being allocated, which is probably
> not good. It could lead to things like a memcg allocating new
> kmalloc slabs instead of using freed space in old ones, maybe
> memory leaks, and maybe oopses as a memcg kmalloc slab is getting
> destroyed on one CPU while another CPU is trying to do an allocation
> from that same memcg.
>
> The obvious fix would be to use the same condition for calling
> memcg_kmem_put_cache that we also use to decide whether to call
> memcg_kmem_get_cache.
>
> I am not sure how long this bug has been around, since the last
> changeset to touch that code - 452647784b2f ("mm: memcontrol: cleanup
>  kmem charge functions") - merely moved the bug from one location to
> another. I am still tagging that changeset, because the fix should
> automatically apply that far back.
>
> Signed-off-by: Rik van Riel <riel@surriel.com>
> Fixes: 452647784b2f ("mm: memcontrol: cleanup kmem charge functions")
> Cc: kernel-team@fb.com
> Cc: linux-mm@kvack.org
> Cc: stable@vger.kernel.org
> Cc: Alexey Dobriyan <adobriyan@gmail.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> ---
>  mm/slab.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/mm/slab.h b/mm/slab.h
> index 4190c24ef0e9..ab3d95bef8a0 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -444,7 +444,8 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
>                 p[i] = kasan_slab_alloc(s, object, flags);
>         }
>
> -       if (memcg_kmem_enabled())
> +       if (memcg_kmem_enabled() &&
> +           ((flags & __GFP_ACCOUNT) || (s->flags & SLAB_ACCOUNT)))

I don't think these extra checks are needed. They are safe but not needed.

>                 memcg_kmem_put_cache(s);
>  }
>
> --
> 2.17.1
>

thanks,
Shakeel

