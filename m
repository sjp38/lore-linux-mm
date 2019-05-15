Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BEBCC04AB4
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 00:16:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4737B20881
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 00:16:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ii41x4BP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4737B20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD67F6B000A; Tue, 14 May 2019 20:16:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B88D96B000C; Tue, 14 May 2019 20:16:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9D8B6B000D; Tue, 14 May 2019 20:16:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83CC76B000A
	for <linux-mm@kvack.org>; Tue, 14 May 2019 20:16:32 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id k10so855400ywb.18
        for <linux-mm@kvack.org>; Tue, 14 May 2019 17:16:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=n6UubTu1HxL5JVqa4cIS4IiqN2UOsI0+Vavy5s5bkSQ=;
        b=cgRRWs+tzY2ddXyqvv2RJ7Ur8NauGANQ1MEUaFSEp/Fh1O5qiIwRiLgjTU+Wl47If6
         Aa6uROv5v8h/IB/63NBQu8SSS2W+sI1+hvE8r8ICoITuKScwoXJXA7YVHxlJB16yxGlo
         nqJ17ZH9fyH1fQb0cKTM7nAfzp3GKX3jT5T7LG9X8MqWggjhbBJWCY8ZtfM3mZYxAZGL
         ekANKWdK56gJY4TsmEGdw99+HpjKX9FPSrY0kEqwj+l1kF2T23SMvKnSElkNmwjfoq55
         dmXZ+Z+8mw9ixAHsPNf5Yt9M1sD5LeOY5YM3kCyvw/29l1cPIXOH82oYkNdHWLJdlARC
         NcWQ==
X-Gm-Message-State: APjAAAX9YSuvbViwXxq2FxpJrOdQ6Bhn3VEdLJK1mpqSPZ7ikypO+Fub
	b/9bt4jiKRjzX7o+qm1sR7ReMovbeQKArC849WlGehqxV3UtdFHW46u3G8QTMzHeHbE8nD0z5ad
	r1g5ArRkKOdi6tjrs6bpbEXQZCnT7/TBIyupw8394kpR6qkEgoV78xrfctU7pavwf6A==
X-Received: by 2002:a25:4cc2:: with SMTP id z185mr14525627yba.311.1557879392259;
        Tue, 14 May 2019 17:16:32 -0700 (PDT)
X-Received: by 2002:a25:4cc2:: with SMTP id z185mr14525608yba.311.1557879391684;
        Tue, 14 May 2019 17:16:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557879391; cv=none;
        d=google.com; s=arc-20160816;
        b=mjal+QTX35WHuIxrTI12kYUe2M355NSh+4Ezhb6SMY34G44CpB3vVHBI8DJxL+1zHM
         LeXlbccbwoXgHUU3ba0jihe0R1bPDHEX2QgoB3ljnQufIBT8t+7siq/Ejmm6wf5IA5PO
         UuTs122xaaw8aD9cP/qWP0NXZ8/Gcds3K1VdJBJXMntCH9ZUhBepe113CmMFJiaZRIpr
         n67C54bS4KqjD0r7EfsPLwnM6iAaLW/8KB8vU9ZJALZSuXnD/hVzsCyhSAlbRjDguQYQ
         PDJnCIJ48z26c/VApUxEZTCtM52dFVOQCycvp4TzW58um11xQgrgksngfuG6hFFxSD8M
         f3+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=n6UubTu1HxL5JVqa4cIS4IiqN2UOsI0+Vavy5s5bkSQ=;
        b=ED3+bCcLTBuQ8wihNwy8M6/TfigSRE1d1cJ1zVKHt3LSobGWNFiA6yMUkWd8Odnymf
         lh2GL4T+7+AzTmVaeUN6cUm6JEJBLOfm8MrpTtCV1a0zvViATijJqLW3/rw7i72LDk0J
         OoGMB0+0Kgkdu8uzfJgR+03EeuZqA3Sm/MUekCTlh7Rgqc4q2uIo/Fz3hPNoe8UgATTQ
         BaGAkh2hgKxcDnhzA0n4oU0wIvymDl62qwxzu7MopKCWmB4hgNIm2TRS4Z8Du8oi1pCg
         XmRb2P4PfKk7BzyGkdQDfV7cpaPKEH+QlO9NLAXZ64A1KIV2I/orFARcaKNS87gmBX+P
         lMyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ii41x4BP;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 200sor150927ybn.6.2019.05.14.17.16.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 17:16:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ii41x4BP;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=n6UubTu1HxL5JVqa4cIS4IiqN2UOsI0+Vavy5s5bkSQ=;
        b=Ii41x4BPQ69+lEiDQCtrEuc+lF56MxJAe2Nu9E3XbvbR4rUAzOZNAXuAlZRNS6P1H0
         g1yyCvGfKBvZs2+YsXBIRXAAt9TKkYkQT8esPIAPxIMrzkMFFDmkcCGxuibr51tDIoEf
         hOvtu0p5Qti7QFT1qMeD2cxKaHTYxfMIvR16MTXd+gcnStMT2TE8onV6SNVb465wsnXH
         wJp8kOMWTtX8IzL1/yOc8GesomdBPegBNpb3c6rVynA4KMxgNmF6NSTnPBOPUCewSG7b
         unooTfA0p8UWmIEaIJ3dtmy1DpodFr7a94oCGmib2FAfj7Xgdla1FlVXjyqxjZB9wq8E
         /Ang==
X-Google-Smtp-Source: APXvYqwXpG8BpCaAhxMLZu1bQsUf0ZlBvmb6V18GIGFeDsrDFmUXX3NvR6sEHYqBkd0VzopGg8Iw+LuwYseyH2LTLrI=
X-Received: by 2002:a25:ad11:: with SMTP id y17mr18143295ybi.393.1557879391180;
 Tue, 14 May 2019 17:16:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190514213940.2405198-1-guro@fb.com> <20190514213940.2405198-8-guro@fb.com>
In-Reply-To: <20190514213940.2405198-8-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 14 May 2019 17:16:19 -0700
Message-ID: <CALvZod5sPsvUCLS1Ud0sW=n+UoJb=DR5LbmMJKRhUeUoi+=64w@mail.gmail.com>
Subject: Re: [PATCH v4 7/7] mm: fix /proc/kpagecgroup interface for slab pages
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Kernel Team <kernel-team@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>, 
	Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Roman Gushchin <guro@fb.com>
Date: Tue, May 14, 2019 at 2:54 PM
To: Andrew Morton, Shakeel Butt
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
<kernel-team@fb.com>, Johannes Weiner, Michal Hocko, Rik van Riel,
Christoph Lameter, Vladimir Davydov, <cgroups@vger.kernel.org>, Roman
Gushchin

> Switching to an indirect scheme of getting mem_cgroup pointer for
> !root slab pages broke /proc/kpagecgroup interface for them.
>
> Let's fix it by learning page_cgroup_ino() how to get memcg
> pointer for slab pages.
>
> Reported-by: Shakeel Butt <shakeelb@google.com>
> Signed-off-by: Roman Gushchin <guro@fb.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  mm/memcontrol.c  |  5 ++++-
>  mm/slab.h        | 25 +++++++++++++++++++++++++
>  mm/slab_common.c |  1 +
>  3 files changed, 30 insertions(+), 1 deletion(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0655639433ed..9b2413c2e9ea 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -494,7 +494,10 @@ ino_t page_cgroup_ino(struct page *page)
>         unsigned long ino = 0;
>
>         rcu_read_lock();
> -       memcg = READ_ONCE(page->mem_cgroup);
> +       if (PageHead(page) && PageSlab(page))
> +               memcg = memcg_from_slab_page(page);
> +       else
> +               memcg = READ_ONCE(page->mem_cgroup);
>         while (memcg && !(memcg->css.flags & CSS_ONLINE))
>                 memcg = parent_mem_cgroup(memcg);
>         if (memcg)
> diff --git a/mm/slab.h b/mm/slab.h
> index 7ba50e526d82..50fa534c0fc0 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -256,6 +256,26 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
>         return s->memcg_params.root_cache;
>  }
>
> +/*
> + * Expects a pointer to a slab page. Please note, that PageSlab() check
> + * isn't sufficient, as it returns true also for tail compound slab pages,
> + * which do not have slab_cache pointer set.
> + * So this function assumes that the page can pass PageHead() and PageSlab()
> + * checks.
> + */
> +static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
> +{
> +       struct kmem_cache *s;
> +
> +       WARN_ON_ONCE(!rcu_read_lock_held());
> +
> +       s = READ_ONCE(page->slab_cache);
> +       if (s && !is_root_cache(s))
> +               return rcu_dereference(s->memcg_params.memcg);
> +
> +       return NULL;
> +}
> +
>  /*
>   * Charge the slab page belonging to the non-root kmem_cache.
>   * Can be called for non-root kmem_caches only.
> @@ -353,6 +373,11 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
>         return s;
>  }
>
> +static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
> +{
> +       return NULL;
> +}
> +
>  static inline int memcg_charge_slab(struct page *page, gfp_t gfp, int order,
>                                     struct kmem_cache *s)
>  {
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 354762394162..9d2a3d6245dc 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -254,6 +254,7 @@ static void memcg_unlink_cache(struct kmem_cache *s)
>                 list_del(&s->memcg_params.kmem_caches_node);
>                 mem_cgroup_put(rcu_dereference_protected(s->memcg_params.memcg,
>                         lockdep_is_held(&slab_mutex)));
> +               rcu_assign_pointer(s->memcg_params.memcg, NULL);
>         }
>  }
>  #else
> --
> 2.20.1
>

