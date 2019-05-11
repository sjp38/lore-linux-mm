Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF7E4C04A6B
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:34:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75C5D217F9
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:34:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="tTNlxcTh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75C5D217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DEF66B000C; Fri, 10 May 2019 20:34:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26AB26B000D; Fri, 10 May 2019 20:34:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 158636B000E; Fri, 10 May 2019 20:34:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id E31266B000C
	for <linux-mm@kvack.org>; Fri, 10 May 2019 20:34:13 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id c4so12935899ywd.0
        for <linux-mm@kvack.org>; Fri, 10 May 2019 17:34:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6aa0q7WG5h/EM4n6FJkJ2OIYCOEeU8+C70t2TMHaifc=;
        b=WcxJu4C7b/+WACX0tqKCV1BkNUkzwDlFCcfGtA9tH7BW6fHIb8gtdZBP9IwxrQISd+
         th9ueiglMPDDneeowkMfV3x9Yu/4TUcg7c4CsgCkmu8VtOHR6OB5IdpYKXpagSWcaYEM
         uZZXKz5TEPyU0AJ0dUKbrNrbCUzhWYWBbNqqVGFaZHJz1gcm9LxmNMKKXA4caauagIX8
         tRTQVPfHOvZJjBOiNSN1FtDPKHtTRisNtBQBUnDG7JdDYbUbBVgwCc1Qn8XTIMvs1wrh
         6QD9i0zqoGiUR2UoMMlRuhHtGoVZ4UNLWcZPVfo4UXAX41zwmXZn4JVTQWokCVItFpb/
         2YVA==
X-Gm-Message-State: APjAAAUd8+WYj/PTyXWDXQDRkCTOsJZcwixy15PI0GFuChNS//UbpOWX
	+1nNcSGLc/zJrhtUQrF2eDn+rU9tDFHt8tHbH0CuqBodMnfDUq7zDID4rcCBzaTxpB2TL2y6Vp/
	A+Pdg/EhYcrd6COoAYCYyt0RHz+SjV97C46Uc5PHSt5MtgO/7WGgtsWOYKjP3qZIp1Q==
X-Received: by 2002:a81:25c8:: with SMTP id l191mr7970760ywl.467.1557534853659;
        Fri, 10 May 2019 17:34:13 -0700 (PDT)
X-Received: by 2002:a81:25c8:: with SMTP id l191mr7970735ywl.467.1557534853000;
        Fri, 10 May 2019 17:34:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557534852; cv=none;
        d=google.com; s=arc-20160816;
        b=C4npi0GmETUa7UgmLyJGZU9PTuXnx6WB6wZ0lUWpmKH8dGR+gzejj0KhN2V5auK3dr
         pZyUrELSnW9Yx7XizWuBE6EWSG21ZLNsf7nB3Eu7+P3axytqb3ARDxHWDBk+R3hZrCEK
         v6V/sQ5oh53rvKEhE8lpwEkziA/fi621IGbRD1imPh8/9j3SCBxUHoLHi347UG2sh0tH
         OBWwP4uAozIHdGPuBIFtdoyWy15crhbe8NUVdWuM0458C+vQNSJXbm7i2qYX5jF6D4ys
         0ZYgzMSp5U8uOf8X5s08km3xkDmqXjR4Shx3NezPogn4pDKH8BhIpVSLfEeXFtc0y8+Y
         KkZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6aa0q7WG5h/EM4n6FJkJ2OIYCOEeU8+C70t2TMHaifc=;
        b=hNdfCWWcf9oiOwm/FPp7A1O4KNDI47dOj80rZuUydd0rAhxOjJwkn72Yye+OtDZY7t
         +SqKsHWWiCD1UMIgz2e8YY7VFjx3aWEir/jwXEu3zELPNMLlxKcC2GyGPXswo2vqV5S9
         mFWhQTVB7LdRvJoyZA4o5Jp5m/cm/as4j7UNPOzzQIc+S1lMPNQcOU3KECMyXmcEauzS
         3LB8AtwYZ0Dx/bILsqIbmz1ZmJdOzA/Le4fYy7qUn04M97tiK9saC8zpAdGoAqNRz47Z
         09Gb4Xbx9fbVZ4bNXRUZNu/zx/l2MB0XS1DYBC/wX6ThmtRPF2hXohGiz0/4KEW39/Yg
         bpSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tTNlxcTh;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 202sor3500965yww.162.2019.05.10.17.34.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 17:34:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=tTNlxcTh;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6aa0q7WG5h/EM4n6FJkJ2OIYCOEeU8+C70t2TMHaifc=;
        b=tTNlxcThtToN/Nlc8GtlstxxM/Wmqp0ke/D7llmpkO9BheoPKLqsCWO2W70mI1LE/X
         qFyrT+kM390DPkFHCmBjRQBUeTIQJuTkRXrzBR9X0qo2AuPXetMl4u1B5yUZVUf5Nuoz
         3qyKxC770wUP01hrh9hvSx7A8blYlRy3agfZgDbVzS6bON9ZG4AgbjLaBWCE0KuVr3/m
         5r4W8O/U19PxfYM0X3GVeYngqPVEDH5pSem7zKtjqxFFBSiynQAgCnUycoYwIKap534s
         hP7TBCQdbewslJrJvMlpv2yR1wYQA9HPeo0DvlRMg9j1pBejJf0XVxamSzbp3gvn77LI
         5lCg==
X-Google-Smtp-Source: APXvYqyb7yvHeW31D12W8LiitVPLIWGPYW4IhrUJNiLBezo1KSWCoZYFt6VDxj1NZBxELlrkYl5LjfVh05DgeVuuTbY=
X-Received: by 2002:a81:ac46:: with SMTP id z6mr7661904ywj.255.1557534852462;
 Fri, 10 May 2019 17:34:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190508202458.550808-1-guro@fb.com> <20190508202458.550808-7-guro@fb.com>
In-Reply-To: <20190508202458.550808-7-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 10 May 2019 17:34:01 -0700
Message-ID: <CALvZod5KhrjYv0WDMBJyB3qzcEqK6zbT=_jUN16G6Jq8YKJJYg@mail.gmail.com>
Subject: Re: [PATCH v3 6/7] mm: reparent slab memory on cgroup removal
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
Date: Wed, May 8, 2019 at 1:41 PM
To: Andrew Morton, Shakeel Butt
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>,
<kernel-team@fb.com>, Johannes Weiner, Michal Hocko, Rik van Riel,
Christoph Lameter, Vladimir Davydov, <cgroups@vger.kernel.org>, Roman
Gushchin

> Let's reparent memcg slab memory on memcg offlining. This allows us
> to release the memory cgroup without waiting for the last outstanding
> kernel object (e.g. dentry used by another application).
>
> So instead of reparenting all accounted slab pages, let's do reparent
> a relatively small amount of kmem_caches. Reparenting is performed as
> a part of the deactivation process.
>
> Since the parent cgroup is already charged, everything we need to do
> is to splice the list of kmem_caches to the parent's kmem_caches list,
> swap the memcg pointer and drop the css refcounter for each kmem_cache
> and adjust the parent's css refcounter. Quite simple.
>
> Please, note that kmem_cache->memcg_params.memcg isn't a stable
> pointer anymore. It's safe to read it under rcu_read_lock() or
> with slab_mutex held.
>
> We can race with the slab allocation and deallocation paths. It's not
> a big problem: parent's charge and slab global stats are always
> correct, and we don't care anymore about the child usage and global
> stats. The child cgroup is already offline, so we don't use or show it
> anywhere.
>
> Local slab stats (NR_SLAB_RECLAIMABLE and NR_SLAB_UNRECLAIMABLE)
> aren't used anywhere except count_shadow_nodes(). But even there it
> won't break anything: after reparenting "nodes" will be 0 on child
> level (because we're already reparenting shrinker lists), and on
> parent level page stats always were 0, and this patch won't change
> anything.
>
> Signed-off-by: Roman Gushchin <guro@fb.com>
> ---
>  include/linux/slab.h |  4 ++--
>  mm/memcontrol.c      | 14 ++++++++------
>  mm/slab.h            | 14 +++++++++-----
>  mm/slab_common.c     | 23 ++++++++++++++++++++---
>  4 files changed, 39 insertions(+), 16 deletions(-)
>
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 1b54e5f83342..109cab2ad9b4 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -152,7 +152,7 @@ void kmem_cache_destroy(struct kmem_cache *);
>  int kmem_cache_shrink(struct kmem_cache *);
>
>  void memcg_create_kmem_cache(struct mem_cgroup *, struct kmem_cache *);
> -void memcg_deactivate_kmem_caches(struct mem_cgroup *);
> +void memcg_deactivate_kmem_caches(struct mem_cgroup *, struct mem_cgroup *);
>
>  /*
>   * Please use this macro to create slab caches. Simply specify the
> @@ -638,7 +638,7 @@ struct memcg_cache_params {
>                         bool dying;
>                 };
>                 struct {
> -                       struct mem_cgroup *memcg;
> +                       struct mem_cgroup __rcu *memcg;
>                         struct list_head children_node;
>                         struct list_head kmem_caches_node;
>                         struct percpu_ref refcnt;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9b27988c8969..6e4d9ed16069 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3220,15 +3220,15 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
>          */
>         memcg->kmem_state = KMEM_ALLOCATED;
>
> -       memcg_deactivate_kmem_caches(memcg);
> -
> -       kmemcg_id = memcg->kmemcg_id;
> -       BUG_ON(kmemcg_id < 0);
> -
>         parent = parent_mem_cgroup(memcg);
>         if (!parent)
>                 parent = root_mem_cgroup;
>
> +       memcg_deactivate_kmem_caches(memcg, parent);
> +
> +       kmemcg_id = memcg->kmemcg_id;
> +       BUG_ON(kmemcg_id < 0);
> +
>         /*
>          * Change kmemcg_id of this cgroup and all its descendants to the
>          * parent's id, and then move all entries from this cgroup's list_lrus
> @@ -3261,7 +3261,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
>         if (memcg->kmem_state == KMEM_ALLOCATED) {
>                 WARN_ON(!list_empty(&memcg->kmem_caches));
>                 static_branch_dec(&memcg_kmem_enabled_key);
> -               WARN_ON(page_counter_read(&memcg->kmem));
>         }
>  }
>  #else
> @@ -4673,6 +4672,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>
>         /* The following stuff does not apply to the root */
>         if (!parent) {
> +#ifdef CONFIG_MEMCG_KMEM
> +               INIT_LIST_HEAD(&memcg->kmem_caches);
> +#endif
>                 root_mem_cgroup = memcg;
>                 return &memcg->css;
>         }
> diff --git a/mm/slab.h b/mm/slab.h
> index 2acc68a7e0a0..acdc1810639d 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -264,10 +264,11 @@ static __always_inline int memcg_charge_slab(struct page *page,
>         struct lruvec *lruvec;
>         int ret;
>
> -       memcg = s->memcg_params.memcg;
> +       rcu_read_lock();
> +       memcg = rcu_dereference(s->memcg_params.memcg);
>         ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);

You can not do memcg_kmem_charge_memcg() within rcu_read_lock(). You
need to css_tryget_online(), though I don't know what to do on
failure? ENOMEM or retry with parent?

>         if (ret)
> -               return ret;
> +               goto out;
>
>         lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
>         mod_lruvec_state(lruvec, cache_vmstat_idx(s), 1 << order);
> @@ -275,8 +276,9 @@ static __always_inline int memcg_charge_slab(struct page *page,
>         /* transer try_charge() page references to kmem_cache */
>         percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
>         css_put_many(&memcg->css, 1 << order);
> -
> -       return 0;
> +out:
> +       rcu_read_unlock();
> +       return ret;
>  }
>
>  static __always_inline void memcg_uncharge_slab(struct page *page, int order,
> @@ -285,10 +287,12 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
>         struct mem_cgroup *memcg;
>         struct lruvec *lruvec;
>
> -       memcg = s->memcg_params.memcg;
> +       rcu_read_lock();
> +       memcg = rcu_dereference(s->memcg_params.memcg);
>         lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
>         mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
>         memcg_kmem_uncharge_memcg(page, order, memcg);
> +       rcu_read_unlock();
>
>         percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);
>  }
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 995920222127..36673a43ed31 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -236,7 +236,7 @@ void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg)
>                 list_add(&s->root_caches_node, &slab_root_caches);
>         } else {
>                 css_get(&memcg->css);
> -               s->memcg_params.memcg = memcg;
> +               rcu_assign_pointer(s->memcg_params.memcg, memcg);
>                 list_add(&s->memcg_params.children_node,
>                          &s->memcg_params.root_cache->memcg_params.children);
>                 list_add(&s->memcg_params.kmem_caches_node,
> @@ -251,7 +251,8 @@ static void memcg_unlink_cache(struct kmem_cache *s)
>         } else {
>                 list_del(&s->memcg_params.children_node);
>                 list_del(&s->memcg_params.kmem_caches_node);
> -               css_put(&s->memcg_params.memcg->css);
> +               mem_cgroup_put(rcu_dereference_protected(s->memcg_params.memcg,
> +                       lockdep_is_held(&slab_mutex)));
>         }
>  }
>  #else
> @@ -772,11 +773,13 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
>         call_rcu(&s->memcg_params.rcu_head, kmemcg_schedule_work_after_rcu);
>  }
>
> -void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
> +void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg,
> +                                 struct mem_cgroup *parent)
>  {
>         int idx;
>         struct memcg_cache_array *arr;
>         struct kmem_cache *s, *c;
> +       unsigned int nr_reparented;
>
>         idx = memcg_cache_id(memcg);
>
> @@ -794,6 +797,20 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
>                 kmemcg_cache_deactivate(c);
>                 arr->entries[idx] = NULL;
>         }
> +       if (memcg != parent) {

When will be the above condition false? Do we need it?


> +               nr_reparented = 0;
> +               list_for_each_entry(s, &memcg->kmem_caches,
> +                                   memcg_params.kmem_caches_node) {
> +                       rcu_assign_pointer(s->memcg_params.memcg, parent);
> +                       css_put(&memcg->css);
> +                       nr_reparented++;
> +               }
> +               if (nr_reparented) {
> +                       list_splice_init(&memcg->kmem_caches,
> +                                        &parent->kmem_caches);
> +                       css_get_many(&parent->css, nr_reparented);
> +               }
> +       }
>         mutex_unlock(&slab_mutex);
>
>         put_online_mems();
> --
> 2.20.1
>

