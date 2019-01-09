Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A149DC43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 05:44:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AFDF206BA
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 05:44:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="T+BtHPWA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AFDF206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAB8F8E009D; Wed,  9 Jan 2019 00:44:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E59798E0038; Wed,  9 Jan 2019 00:44:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D22778E009D; Wed,  9 Jan 2019 00:44:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F3EE8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 00:44:44 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id t17so3324822ywc.23
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 21:44:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6nHgzPv8OHHMQOhvL9odj368V6gyeIizn/EW268BFmo=;
        b=BZQBAc+1ZZfIqht0WHnVfxd5Lnj72QjlVkncNEKrOYHI3JFZEy9pPYsivSsPt5E/WV
         BfrvUhF5kVEU9Zk+uVeyZCNYo0w8O28j4ljfcclm6PctlNWFlW+o70kJuYc3XkT0kpzV
         oIpu6pH+u3Rtha/S+IGTudACPr9cx9FLx+gWITXtDtJsjDv3n0pVuBm1uSIkQ2mTgUe1
         QLIKmkIqsBT/y598WAZH0Y82L4TmTTn+mM1djq1sxi8neTcceQJHbf8RyO108Ln6lKBt
         Xeu1s+68fVBomWDgr0Fxw3Z6CqWyt34oF98IIdkT5YngDssxJJwLvPkoQ2LO4lmWQM6+
         vniA==
X-Gm-Message-State: AJcUukd9Hh/ZALWzUDYMFMQNu52caMsmuvUDKUb9btMVnzmgKvneZOE3
	6u75Of6TOUFuEy1TKi8i56qD67gZ0pxz5HpHudbTuliyyut9iSSd/jcNdS7F4fPOY+pmeQ/0+0B
	L266494BZfIjSVbL+k8DStsHtJp/NagZhVgsFaBoG+VHARMJZ3lbWW6/Gc/nllKu7+XCdNO6T+X
	Or8S6Wki3AiyDe4ZLY4/IGktVoQmpgQgAJfemJoDatnhWfD2xoD/EAnxovGARSxdF3QmOdAdJQN
	zzkHv0i+rFbHgQcUCgrlTXtzpkP4rCArRhKlgAyQDxgo3+FlXGb0aHPUnwQTmGVtmEfOA5AA2SI
	lL6L9Y2o8dw0SPDd/Mcu37LpGDoknVTr1y7c/XCLuAseWUQpgWQQOFz2CHB6v75f356VQgz9X4u
	E
X-Received: by 2002:a81:b61a:: with SMTP id u26mr4310934ywh.428.1547012684293;
        Tue, 08 Jan 2019 21:44:44 -0800 (PST)
X-Received: by 2002:a81:b61a:: with SMTP id u26mr4310921ywh.428.1547012683648;
        Tue, 08 Jan 2019 21:44:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547012683; cv=none;
        d=google.com; s=arc-20160816;
        b=cYo9ndhvdeZcia+d0G0bKpokSAr5PwYd5Cs0gqlTMVMF+vwvFdKGIbMf0Nxqcwpl9I
         NjiDyz+4HuV12WfVVD5NTyIwpegv4zsv9HdDKc5aBok+Wpbq+tl2D4T+XkiofoMAL8jA
         YKzG3/+C2xSaVsJrCXeuIbTSQ9FNi3UFEP1CAFkNvkJ4ugK7DGQtwQHGHPmSjZ66Lq7w
         am5dyMEuP7pqS7qZ0RqSLxV7D2YjKwSiJlLYPq+JGDNQkeJ+J6m+Htz2v6j+wkz6x3Ss
         u1lqxFqcSuDH1KqbV/OetjvulCERp49L7LTjlHDPFbtTC8u5og6jHdiPSRhvBWLcZe43
         o47A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6nHgzPv8OHHMQOhvL9odj368V6gyeIizn/EW268BFmo=;
        b=TXU7nIluqv3nBPAfh4M5nZG9P9PJkx5O4cwxoHnxzfT5AyGeKa3UIVRx+oRqq9k4JM
         inzxoxS7JaQsO6tHkIIbgMBJOctVDX3+HudFvAhdSa1lJJftLwYcOMVxgV+B1waS3/h2
         CXoty+c/3YcRKGI88xzMKI2+V+nQeaAI8asLtkATsU15me0WazwBpfxHqlpw22evqdqW
         Cwt5DY2Po+FV329Wq8WtDowRdCW8rMs63br0SMLLra1ZgDZq0UnIwMt/nErGxi22NB0N
         x3zdxlovR66rDsrbHi9+fLREiMnP8HOaKYYdPRP7Yj3dOdwkF0MPMMzgeJ0L3P5X9qpe
         fmVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=T+BtHPWA;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v19sor24360952ybb.88.2019.01.08.21.44.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 21:44:43 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=T+BtHPWA;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6nHgzPv8OHHMQOhvL9odj368V6gyeIizn/EW268BFmo=;
        b=T+BtHPWAN7zFhlQJ3Vh7wdCJ+9Db2lsKHltj0bZCAebH1WiEy/bGepN15kGNiU6469
         ma5r8vkSiWbBVxLwouI02LIchw3YoIyHYBRZwkB5Mi09ldoK0U4m4ykkg5iORhBPlrPh
         g1WBZrFyVRuFCEyVU3B6VRzFk0aUui5Hr22SMVyzXMDfAkmF4CdNPksyjrJumw0d4q4D
         93Ro/R63gHWvIeT4IwK7z2HTr+0dokmPc2Cwsj47wUMBzNlbRFkDi5tOyOnI90QT9+Wi
         m9V53rJfzirHyQAUR3sIjq1htXAy4TLE2wChDX4H9psoaB26huD3zIy+8n0ZD0i+c+H+
         0rEA==
X-Google-Smtp-Source: ALg8bN7WC9YarGVhTwVTk4rmmMzeT1JUxVUtrATiopraERlgM5IN/iq9S9pbXWCiF6mNWSpgMszQDXsj1t05ClcxXUw=
X-Received: by 2002:a25:26c8:: with SMTP id m191mr4384247ybm.377.1547012683115;
 Tue, 08 Jan 2019 21:44:43 -0800 (PST)
MIME-Version: 1.0
References: <20190109040107.4110-1-riel@surriel.com> <CALvZod6=-kdUk23i7eOr5AO-_2Fk_BmJiL3QjSJ4S4QOs0xKkw@mail.gmail.com>
In-Reply-To: <CALvZod6=-kdUk23i7eOr5AO-_2Fk_BmJiL3QjSJ4S4QOs0xKkw@mail.gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 8 Jan 2019 21:44:32 -0800
Message-ID:
 <CALvZod5+QFLtn4D+xn2REy3sHUR5z3EsJQPGrfzWobK5wmRnjg@mail.gmail.com>
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
Message-ID: <20190109054432.mV7_TCg9jmGcO4cxR6ji67E-qjdTahomLGMEvM3-uXM@z>

On Tue, Jan 8, 2019 at 9:36 PM Shakeel Butt <shakeelb@google.com> wrote:
>
> On Tue, Jan 8, 2019 at 8:01 PM Rik van Riel <riel@surriel.com> wrote:
> >
> > There is an imbalance between when slab_pre_alloc_hook calls
> > memcg_kmem_get_cache and when slab_post_alloc_hook calls
> > memcg_kmem_put_cache.
> >
>
> Can you explain how there is an imbalance? If the returned kmem cache
> from memcg_kmem_get_cache() is the memcg kmem cache then the refcnt of
> memcg is elevated and the memcg_kmem_put_cache() will correctly
> decrement the refcnt of the memcg.
>
> > This can cause a memcg kmem cache to be destroyed right as
> > an object from that cache is being allocated,

Also please note that the memcg kmem caches are destroyed (if empty)
on memcg offline. The css_tryget_online() within
memcg_kmem_get_cache() will fail.

See kernel/cgroup/cgroup.c
* 2. When the percpu_ref is confirmed to be visible as killed on all CPUs
 *    and thus css_tryget_online() is guaranteed to fail, the css can be
 *    offlined by invoking offline_css().  After offlining, the base ref is
 *    put.  Implemented in css_killed_work_fn().

> > which is probably
> > not good. It could lead to things like a memcg allocating new
> > kmalloc slabs instead of using freed space in old ones, maybe
> > memory leaks, and maybe oopses as a memcg kmalloc slab is getting
> > destroyed on one CPU while another CPU is trying to do an allocation
> > from that same memcg.
> >
> > The obvious fix would be to use the same condition for calling
> > memcg_kmem_put_cache that we also use to decide whether to call
> > memcg_kmem_get_cache.
> >
> > I am not sure how long this bug has been around, since the last
> > changeset to touch that code - 452647784b2f ("mm: memcontrol: cleanup
> >  kmem charge functions") - merely moved the bug from one location to
> > another. I am still tagging that changeset, because the fix should
> > automatically apply that far back.
> >
> > Signed-off-by: Rik van Riel <riel@surriel.com>
> > Fixes: 452647784b2f ("mm: memcontrol: cleanup kmem charge functions")
> > Cc: kernel-team@fb.com
> > Cc: linux-mm@kvack.org
> > Cc: stable@vger.kernel.org
> > Cc: Alexey Dobriyan <adobriyan@gmail.com>
> > Cc: Christoph Lameter <cl@linux.com>
> > Cc: Pekka Enberg <penberg@kernel.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Tejun Heo <tj@kernel.org>
> > ---
> >  mm/slab.h | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/mm/slab.h b/mm/slab.h
> > index 4190c24ef0e9..ab3d95bef8a0 100644
> > --- a/mm/slab.h
> > +++ b/mm/slab.h
> > @@ -444,7 +444,8 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
> >                 p[i] = kasan_slab_alloc(s, object, flags);
> >         }
> >
> > -       if (memcg_kmem_enabled())
> > +       if (memcg_kmem_enabled() &&
> > +           ((flags & __GFP_ACCOUNT) || (s->flags & SLAB_ACCOUNT)))
>
> I don't think these extra checks are needed. They are safe but not needed.
>
> >                 memcg_kmem_put_cache(s);
> >  }
> >
> > --
> > 2.17.1
> >
>
> thanks,
> Shakeel

