Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CF4CC04AB4
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 00:10:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFFCC20879
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 00:10:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ndpzg0dE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFFCC20879
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 488396B0007; Tue, 14 May 2019 20:10:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4383A6B0008; Tue, 14 May 2019 20:10:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 327E86B000A; Tue, 14 May 2019 20:10:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 121B16B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 20:10:47 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id 23so728216ybe.16
        for <linux-mm@kvack.org>; Tue, 14 May 2019 17:10:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=zluGg5sjuOMtZTmyGxNI8yHBaHDgl+Ebuu+Qwfri6HM=;
        b=T8noiEt5c57ntroC9DvpEP/Ad6vN4DwoUItBQFBl6KKTf9AYmtxY1vidO30RtmvsUo
         Ht3wuXBFMuZf43Htz5QnBWMv/sw15v4fE7pvUHeJpxwczvH5NmftC3p6ubIwY4qw/art
         p9SYmwDTAx9z83q3tqP6HmXZXLr7w2aJ1YHZscB+nMlCyFoIbeEtUz+WlL5pl1lo5ZgH
         dmWXvH/lItFAuRcjQa+zMWt1Z+qd5QSNJGoN98vP6vrAUlCuduOwGsUldvocs5pjlvpE
         4ZQesnH+Ve1JFWsDsplldZKJUJKUrb2g1V+zohY481UUHx3VfW+CwLaVDe41kc54IBpv
         ytMA==
X-Gm-Message-State: APjAAAXSYT3Qxr51vAvkRCf9orat77QH8RDN/vSSHd0bMGLZFgf2NYkN
	Bdr+XojfntkFowhrs1d+TajwSuvurrGc6KcJx3y6pmw23JgxZuN0Lu2VQUZmIKyTkkBe7CPKKvQ
	hd6WmnUzYK4ouz/ShkCrEX67KoTP6VDPduxXHmGRte0Q5LVk7GAfUobSkXyMqUQ2E3A==
X-Received: by 2002:a81:9307:: with SMTP id k7mr17884402ywg.226.1557879046804;
        Tue, 14 May 2019 17:10:46 -0700 (PDT)
X-Received: by 2002:a81:9307:: with SMTP id k7mr17884385ywg.226.1557879046048;
        Tue, 14 May 2019 17:10:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557879046; cv=none;
        d=google.com; s=arc-20160816;
        b=JXlTIAjCOHi/vCXtutLDNRVlrpjSKVmByoiKm9CX/U3cF/nGtEGHXJQb9Q7pRkb7To
         etdacAFdEq07KLnQg3rOOpkk8NGarG0/HSbSDjsVPNSJg2RontQCxhGY0c1ihcrlCFiL
         GG12JytwbLdZhVcn8cAI1UilX4Holt78lARcJ+gV2NDiR99jCbLm3yTqiKVBM/pVUS8u
         KLV8TIXo3Bf6rrdFpOHVQ9bQytg7EuvluMi3sTMgGHDgPEQcgG3wsGMUi023zcb4Z9QX
         GrRGO41sUev013qZOpHoYUG6SW6KuSKj/AaRdWvTgBswUlzWLazyUjiYBJaMPLk0NwxI
         rquw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=zluGg5sjuOMtZTmyGxNI8yHBaHDgl+Ebuu+Qwfri6HM=;
        b=UQ1jHNTd/yRL5xYFlMuxdnyTt5tVglgBtm2Jh187WDUQvbD2hcnRRpIMtvUMG7QsKu
         Sf5SVHRDpXylxEcPcSJrP73ERoNeJkP6GKtJLXaonoelimxxU8FPt2uUr+K6vMSJER9L
         PigUC1w8C+h6VfKCPvY6iZhhGvCihc2PKtn8oWlTnsG5EjdAGXBWm1/hPfTR8gfPgR4N
         BJTjOizgThZEqFeqgTcC3uvlQdF5muyy6CxeCdfTILEigtySXnK/4cEEZGBFgCKtvoaO
         9cGnyDd3WwgDa24mjb/GGaZvprCkmia0Sf8I3hA+VC5rTA5odFfZ5dWfHHGTZJRXE5pF
         ofdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ndpzg0dE;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i63sor141460ybg.17.2019.05.14.17.10.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 17:10:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ndpzg0dE;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zluGg5sjuOMtZTmyGxNI8yHBaHDgl+Ebuu+Qwfri6HM=;
        b=Ndpzg0dE7l03zW4C131CKF+aIrpux3suRr9luBsGFoEWNvGZEvjNF20XDLVbdtRf8i
         p5v/+ywAJZT+/jRdIxabY3/fsgh0ea7zgeqb8NBhAdEkX67lwdpDqlmEVUdlD1voY4UK
         NmLUZ4XKWLdCBhmVIfu3Xeke6WlVc5IG5Sfc5zECji65SttNMRyc4GB575gAEU/azkLB
         cOKnJlLy1yNOFt2K8MSVOFqJgI+kCL1bkg2IBdnJuXTmPKNgzi8Ij77xZAwpxFBuyqA1
         mgOrhgguz8obPjJBlX4X6oJCUZNQTV8SMURUr1xwHFoTeYdjZDLgxOHNC+sD6WK/JekI
         8A/w==
X-Google-Smtp-Source: APXvYqzEdusEfpnz9l5C8hPn5ut+WFR02WVznTKN6Nq4aV4/q18VioOpAKoW7WFWF+VamGbgyLdd0YruwBtkDF1KKYU=
X-Received: by 2002:a25:4147:: with SMTP id o68mr19108358yba.148.1557879045478;
 Tue, 14 May 2019 17:10:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190514213940.2405198-1-guro@fb.com> <20190514213940.2405198-7-guro@fb.com>
In-Reply-To: <20190514213940.2405198-7-guro@fb.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 14 May 2019 17:10:34 -0700
Message-ID: <CALvZod7FDwnxFLs_0+AfaU+5vCCSSX6wbjOZv+01hrCUoPKsWg@mail.gmail.com>
Subject: Re: [PATCH v4 6/7] mm: reparent slab memory on cgroup removal
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

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  include/linux/slab.h |  4 ++--
>  mm/memcontrol.c      | 14 ++++++++------
>  mm/slab.h            | 21 ++++++++++++++++-----
>  mm/slab_common.c     | 21 ++++++++++++++++++---
>  4 files changed, 44 insertions(+), 16 deletions(-)
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
> index 413cef3d8369..0655639433ed 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3224,15 +3224,15 @@ static void memcg_offline_kmem(struct mem_cgroup *memcg)
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
> @@ -3265,7 +3265,6 @@ static void memcg_free_kmem(struct mem_cgroup *memcg)
>         if (memcg->kmem_state == KMEM_ALLOCATED) {
>                 WARN_ON(!list_empty(&memcg->kmem_caches));
>                 static_branch_dec(&memcg_kmem_enabled_key);
> -               WARN_ON(page_counter_read(&memcg->kmem));
>         }
>  }
>  #else
> @@ -4677,6 +4676,9 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
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
> index b86744c58702..7ba50e526d82 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -268,10 +268,18 @@ static __always_inline int memcg_charge_slab(struct page *page,
>         struct lruvec *lruvec;
>         int ret;
>
> -       memcg = s->memcg_params.memcg;
> +       rcu_read_lock();
> +       memcg = rcu_dereference(s->memcg_params.memcg);
> +       while (memcg && !css_tryget_online(&memcg->css))
> +               memcg = parent_mem_cgroup(memcg);
> +       rcu_read_unlock();
> +
> +       if (unlikely(!memcg))
> +               return true;
> +
>         ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
>         if (ret)
> -               return ret;
> +               goto out;
>
>         lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
>         mod_lruvec_state(lruvec, cache_vmstat_idx(s), 1 << order);
> @@ -279,8 +287,9 @@ static __always_inline int memcg_charge_slab(struct page *page,
>         /* transer try_charge() page references to kmem_cache */
>         percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
>         css_put_many(&memcg->css, 1 << order);
> -
> -       return 0;
> +out:
> +       css_put(&memcg->css);
> +       return ret;
>  }
>
>  /*
> @@ -293,10 +302,12 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
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
> index 1ee967b4805e..354762394162 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -237,7 +237,7 @@ void memcg_link_cache(struct kmem_cache *s, struct mem_cgroup *memcg)
>                 list_add(&s->root_caches_node, &slab_root_caches);
>         } else {
>                 css_get(&memcg->css);
> -               s->memcg_params.memcg = memcg;
> +               rcu_assign_pointer(s->memcg_params.memcg, memcg);
>                 list_add(&s->memcg_params.children_node,
>                          &s->memcg_params.root_cache->memcg_params.children);
>                 list_add(&s->memcg_params.kmem_caches_node,
> @@ -252,7 +252,8 @@ static void memcg_unlink_cache(struct kmem_cache *s)
>         } else {
>                 list_del(&s->memcg_params.children_node);
>                 list_del(&s->memcg_params.kmem_caches_node);
> -               css_put(&s->memcg_params.memcg->css);
> +               mem_cgroup_put(rcu_dereference_protected(s->memcg_params.memcg,
> +                       lockdep_is_held(&slab_mutex)));
>         }
>  }
>  #else
> @@ -776,11 +777,13 @@ static void kmemcg_cache_deactivate(struct kmem_cache *s)
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
> @@ -798,6 +801,18 @@ void memcg_deactivate_kmem_caches(struct mem_cgroup *memcg)
>                 kmemcg_cache_deactivate(c);
>                 arr->entries[idx] = NULL;
>         }
> +       nr_reparented = 0;
> +       list_for_each_entry(s, &memcg->kmem_caches,
> +                           memcg_params.kmem_caches_node) {
> +               rcu_assign_pointer(s->memcg_params.memcg, parent);
> +               css_put(&memcg->css);
> +               nr_reparented++;
> +       }
> +       if (nr_reparented) {
> +               list_splice_init(&memcg->kmem_caches,
> +                                &parent->kmem_caches);
> +               css_get_many(&parent->css, nr_reparented);
> +       }
>         mutex_unlock(&slab_mutex);
>
>         put_online_mems();
> --
> 2.20.1
>

