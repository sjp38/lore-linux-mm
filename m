Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9438C04A6B
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:33:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F9A8217D6
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:33:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tpILgy3R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F9A8217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A86F6B0006; Fri, 10 May 2019 20:33:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 133036B0008; Fri, 10 May 2019 20:33:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 006096B0006; Fri, 10 May 2019 20:33:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id C20806B0006
	for <linux-mm@kvack.org>; Fri, 10 May 2019 20:33:13 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id a70so12825207ywe.21
        for <linux-mm@kvack.org>; Fri, 10 May 2019 17:33:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=05t4yLqiGc54LnQ5ZpBdMWfaLZVhZ5+2KCRuzx7eEX8=;
        b=nJ69xrxIgdXOkCiMIYi73l9NAGteCqHaQubpd6ZBH+J7BhfTuaVROIvf9JwjMSap+0
         AWWGT7F+x2a0aDONGGxVGQIQzr3mtcAnp8IZpiZIy2COdWD5p8or26JBtwd6obV/tRVv
         7XBC/soUed1S/i7yYg61FqFbBPmCcrMl98Vzri1KDsoiwAN6ZJBWgjuOF0hsQfd4LaPv
         2OcrixrywR4FiREofhdcPbq0d0U32yq7hXHXK4hr34rWalqceDBmAZ69c9MQjhmKr778
         vJ5mmofHv1Az3ILBUeid0UDA0/9qtpEes7d/OgS/7rmW31fjvfjtajjoq7rgBTy+vmMb
         UgxQ==
X-Gm-Message-State: APjAAAUOGdI+GWICWKExc1tdh48UTUuiXCTNDI2lFTxVVYN1u5txKczY
	rYF7LWXnHdSDoE/UGBSnxe3WikyQz8OxORFPihwqzKWlkqFa7dUm0aEJV6DfVNdwoVYHCqy9Mud
	BEjY1iON+fnP+4uDMNWxMfJ4xJCsX4Wo03TRm2B8La5/+IE+EXvIe4okILjwai9OVKg==
X-Received: by 2002:a25:389:: with SMTP id 131mr7171298ybd.186.1557534793495;
        Fri, 10 May 2019 17:33:13 -0700 (PDT)
X-Received: by 2002:a25:389:: with SMTP id 131mr7171279ybd.186.1557534792776;
        Fri, 10 May 2019 17:33:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557534792; cv=none;
        d=google.com; s=arc-20160816;
        b=wqNcxXN29zvm06Wc19QTZyPGW0DzNRr5W64jH4TiUIZLy9EDGebPMg9QYim+ueImKQ
         iGntSNZLiIQ/2eXFtysB/PlAfhDv28pzE7aDAHeDb0+RkMXlk93HENlr4587WvFhLD+a
         Gs71K+xl24xqpN0s3Loogymxs6GAhf0wq6oCyj/Ym4wiNlB82uS9piMsZD0FZfWuqIq0
         /dZ33vfWhRjtbILvMRQRkc0VH3EitE9pi0jFox467NXFRsBXD5hhkTNbBP8nQrKbXqPn
         p4h/npPrqi2IIYXLt472GDBUZCwunTq3IJOtHRX6xdyxJ7B5PoY0/Eybx+rE/fyYEojy
         RMBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=05t4yLqiGc54LnQ5ZpBdMWfaLZVhZ5+2KCRuzx7eEX8=;
        b=UCom4nXgT4J7xrnNkza/mE1DEdMtKsSC/aHywbeYv7i+u3JhZILLf6RKcBxKHZsD2K
         CnYhIPb6ogwR3VKRCswh1nuGrHpUUAkzDPwWXp4f50elOp2vqRBkaNuiFIIZF4hXVZ/W
         mzfjMgnK/p+O40fY4tEglmG8pRpKNvlQOqUFDziYG21WdrJnij6tTLvEM7MQW8FOv1b2
         FKBd2VlKDu5YtmwOktwnH4HCUXbxSmeX/vj0j51aeKc3Q6rEEgkPwwtFn1GVKbu5JufZ
         JCNv6qcwN0XXFsd/RedznWFU4JX2Cq2z4tTaRjquA2ZnArzRhiGap91Ti39WLGvGHwoW
         Mrvw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tpILgy3R;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 81sor3514980ywo.97.2019.05.10.17.33.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 17:33:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tpILgy3R;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=05t4yLqiGc54LnQ5ZpBdMWfaLZVhZ5+2KCRuzx7eEX8=;
        b=tpILgy3RmXvC0yltT+cnRg1Pt1urKSjgHZLDaAd0PFyHRCWS4ofNZsI7qMNoOaArmC
         5eKPcc494ECjICs6c7N2ZDyJcGcp93BmshTYiPOVGXv8V7UzwFhUfFxWMkhVbO00LHhy
         n3sMBrBwUt5l6RZAo2YzV4AY3QtVIIxJVicfetorlD/1+7AGVdBqlR2eqed1oAE0BNMA
         G2L9CYcxCr4hcN1+VX2NHAGNdwXfa6YCQVXtnT4MiL3CEPIuKYI483EJiMac15JgntHW
         WLT5IFS3yVf46q2+amrQnPkVbVJ895ldIK7jtzvFe0VsLOd4XmYWhdy4AZVRQXSgY4KQ
         HcMQ==
X-Google-Smtp-Source: APXvYqzqg8t1QDEkbNyfsK/W1VqD88Ql/nMpu8XxA4P/KzF3MqAprZpmoXOLhhKwyv4sl6SAbJEuFpA2Dy9Pzjj0TyQ=
X-Received: by 2002:a81:2204:: with SMTP id i4mr7167446ywi.349.1557534792229;
 Fri, 10 May 2019 17:33:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190508202458.550808-1-guro@fb.com> <20190508202458.550808-3-guro@fb.com>
In-Reply-To: <20190508202458.550808-3-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 10 May 2019 17:33:01 -0700
Message-ID: <CALvZod7oxh+5z7xWGnrs4zTpM2fHGfqsWcx7+KU8r9vMp38TWw@mail.gmail.com>
Subject: Re: [PATCH v3 2/7] mm: generalize postponed non-root kmem_cache deactivation
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
Date: Wed, May 8, 2019 at 1:30 PM
To: Andrew Morton, Shakeel Butt
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
<kernel-team@fb.com>, Johannes Weiner, Michal Hocko, Rik van Riel,
Christoph Lameter, Vladimir Davydov, <cgroups@vger.kernel.org>, Roman
Gushchin

> Currently SLUB uses a work scheduled after an RCU grace period
> to deactivate a non-root kmem_cache. This mechanism can be reused
> for kmem_caches reparenting, but requires some generalization.
>
> Let's decouple all infrastructure (rcu callback, work callback)
> from the SLUB-specific code, so it can be used with SLAB as well.
>
> Also, let's rename some functions to make the code look simpler.
> All SLAB/SLUB-specific functions start with "__". Remove "deact_"
> prefix from the corresponding struct fields.
>
> Here is the graph of a new calling scheme:
> kmemcg_cache_deactivate()
>   __kmemcg_cache_deactivate()                  SLAB/SLUB-specific
>   kmemcg_schedule_work_after_rcu()             rcu
>     kmemcg_after_rcu_workfn()                  work
>       kmemcg_cache_deactivate_after_rcu()
>         __kmemcg_cache_deactivate_after_rcu()  SLAB/SLUB-specific
>
> instead of:
> __kmemcg_cache_deactivate()                    SLAB/SLUB-specific
>   slab_deactivate_memcg_cache_rcu_sched()      SLUB-only
>     kmemcg_deactivate_rcufn                    SLUB-only, rcu
>       kmemcg_deactivate_workfn                 SLUB-only, work
>         kmemcg_cache_deact_after_rcu()         SLUB-only
>
> Signed-off-by: Roman Gushchin <guro@fb.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  include/linux/slab.h |  6 ++---
>  mm/slab.c            |  4 +++
>  mm/slab.h            |  3 ++-
>  mm/slab_common.c     | 62 ++++++++++++++++++++------------------------
>  mm/slub.c            |  8 +-----
>  5 files changed, 38 insertions(+), 45 deletions(-)
>
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 9449b19c5f10..47923c173f30 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -642,10 +642,10 @@ struct memcg_cache_params {
>                         struct list_head children_node;
>                         struct list_head kmem_caches_node;
>
> -                       void (*deact_fn)(struct kmem_cache *);
> +                       void (*work_fn)(struct kmem_cache *);
>                         union {
> -                               struct rcu_head deact_rcu_head;
> -                               struct work_struct deact_work;
> +                               struct rcu_head rcu_head;
> +                               struct work_struct work;
>                         };
>                 };
>         };
> diff --git a/mm/slab.c b/mm/slab.c
> index f6eff59e018e..83000e46b870 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2281,6 +2281,10 @@ void __kmemcg_cache_deactivate(struct kmem_cache *cachep)
>  {
>         __kmem_cache_shrink(cachep);
>  }
> +
> +void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
> +{
> +}
>  #endif
>
>  int __kmem_cache_shutdown(struct kmem_cache *cachep)
> diff --git a/mm/slab.h b/mm/slab.h
> index 6a562ca72bca..4a261c97c138 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -172,6 +172,7 @@ int __kmem_cache_shutdown(struct kmem_cache *);
>  void __kmem_cache_release(struct kmem_cache *);
>  int __kmem_cache_shrink(struct kmem_cache *);
>  void __kmemcg_cache_deactivate(struct kmem_cache *s);
> +void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s);
>  void slab_kmem_cache_release(struct kmem_cache *);
>
>  struct seq_file;
> @@ -291,7 +292,7 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
>  extern void slab_init_memcg_params(struct kmem_cache *);
>  extern void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg);
>  extern void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
> -                               void (*deact_fn)(struct kmem_cache *));
> +                               void (*work_fn)(struct kmem_cache *));
>
>  #else /* CONFIG_MEMCG_KMEM */
>
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 6e00bdf8618d..4e5b4292a763 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -691,17 +691,18 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
>         put_online_cpus();
>  }
>
> -static void kmemcg_deactivate_workfn(struct work_struct *work)
> +static void kmemcg_after_rcu_workfn(struct work_struct *work)
>  {
>         struct kmem_cache *s = container_of(work, struct kmem_cache,
> -                                           memcg_params.deact_work);
> +                                           memcg_params.work);
>
>         get_online_cpus();
>         get_online_mems();
>
>         mutex_lock(&slab_mutex);
>
> -       s->memcg_params.deact_fn(s);
> +       s->memcg_params.work_fn(s);
> +       s->memcg_params.work_fn = NULL;
>
>         mutex_unlock(&slab_mutex);
>
> @@ -712,37 +713,28 @@ static void kmemcg_deactivate_workfn(struct work_struct *work)
>         css_put(&s->memcg_params.memcg->css);
>  }
>
> -static void kmemcg_deactivate_rcufn(struct rcu_head *head)
> +/*
> + * We need to grab blocking locks.  Bounce to ->work.  The
> + * work item shares the space with the RCU head and can't be
> + * initialized eariler.
> +*/
> +static void kmemcg_schedule_work_after_rcu(struct rcu_head *head)
>  {
>         struct kmem_cache *s = container_of(head, struct kmem_cache,
> -                                           memcg_params.deact_rcu_head);
> +                                           memcg_params.rcu_head);
>
> -       /*
> -        * We need to grab blocking locks.  Bounce to ->deact_work.  The
> -        * work item shares the space with the RCU head and can't be
> -        * initialized eariler.
> -        */
> -       INIT_WORK(&s->memcg_params.deact_work, kmemcg_deactivate_workfn);
> -       queue_work(memcg_kmem_cache_wq, &s->memcg_params.deact_work);
> +       INIT_WORK(&s->memcg_params.work, kmemcg_after_rcu_workfn);
> +       queue_work(memcg_kmem_cache_wq, &s->memcg_params.work);
>  }
>
> -/**
> - * slab_deactivate_memcg_cache_rcu_sched - schedule deactivation after a
> - *                                        sched RCU grace period
> - * @s: target kmem_cache
> - * @deact_fn: deactivation function to call
> - *
> - * Schedule @deact_fn to be invoked with online cpus, mems and slab_mutex
> - * held after a sched RCU grace period.  The slab is guaranteed to stay
> - * alive until @deact_fn is finished.  This is to be used from
> - * __kmemcg_cache_deactivate().
> - */
> -void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
> -                                          void (*deact_fn)(struct kmem_cache *))
> +static void kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
>  {
> -       if (WARN_ON_ONCE(is_root_cache(s)) ||
> -           WARN_ON_ONCE(s->memcg_params.deact_fn))
> -               return;
> +       __kmemcg_cache_deactivate_after_rcu(s);
> +}
> +
> +static void kmemcg_cache_deactivate(struct kmem_cache *s)
> +{
> +       __kmemcg_cache_deactivate(s);
>
>         if (s->memcg_params.root_cache->memcg_params.dying)
>                 return;
> @@ -750,8 +742,9 @@ void slab_deactivate_memcg_cache_rcu_sched(struct kmem_cache *s,
>         /* pin memcg so that @s doesn't get destroyed in the middle */
>         css_get(&s->memcg_params.memcg->css);
>
> -       s->memcg_params.deact_fn = deact_fn;
> -       call_rcu(&s->memcg_params.deact_rcu_head, kmemcg_deactivate_rcufn);
> +       WARN_ON_ONCE(s->memcg_params.work_fn);
> +       s->memcg_params.work_fn = kmemcg_cache_deactivate_after_rcu;
> +       call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);
>  }
>
>  void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
> @@ -773,7 +766,7 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
>                 if (!c)
>                         continue;
>
> -               __kmemcg_cache_deactivate(c);
> +               kmemcg_cache_deactivate(c);
>                 arr->entries[idx] = NULL;
>         }
>         mutex_unlock(&slab_mutex);
> @@ -866,11 +859,12 @@ static void flush_memcg_workqueue(struct kmem_cache *s)
>         mutex_unlock(&slab_mutex);
>
>         /*
> -        * SLUB deactivates the kmem_caches through call_rcu. Make
> +        * SLAB and SLUB deactivate the kmem_caches through call_rcu. Make
>          * sure all registered rcu callbacks have been invoked.
>          */
> -       if (IS_ENABLED(CONFIG_SLUB))
> -               rcu_barrier();
> +#ifndef CONFIG_SLOB
> +       rcu_barrier();
> +#endif
>
>         /*
>          * SLAB and SLUB create memcg kmem_caches through workqueue and SLUB
> diff --git a/mm/slub.c b/mm/slub.c
> index 16f7e4f5a141..43c34d54ad86 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -4028,7 +4028,7 @@ int __kmem_cache_shrink(struct kmem_cache *s)
>  }
>
>  #ifdef CONFIG_MEMCG
> -static void kmemcg_cache_deact_after_rcu(struct kmem_cache *s)
> +void __kmemcg_cache_deactivate_after_rcu(struct kmem_cache *s)
>  {
>         /*
>          * Called with all the locks held after a sched RCU grace period.
> @@ -4054,12 +4054,6 @@ void __kmemcg_cache_deactivate(struct kmem_cache *s)
>          */
>         slub_set_cpu_partial(s, 0);
>         s->min_partial = 0;
> -
> -       /*
> -        * s->cpu_partial is checked locklessly (see put_cpu_partial), so
> -        * we have to make sure the change is visible before shrinking.
> -        */
> -       slab_deactivate_memcg_cache_rcu_sched(s, kmemcg_cache_deact_after_rcu);
>  }
>  #endif /* CONFIG_MEMCG */
>
> --
> 2.20.1
>

