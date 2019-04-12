Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F5F9C10F14
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:55:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 062CA2171F
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:55:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dKgwuHoq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 062CA2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 984926B000C; Fri, 12 Apr 2019 15:55:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95C596B000D; Fri, 12 Apr 2019 15:55:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8717E6B0010; Fri, 12 Apr 2019 15:55:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4BD6B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 15:55:24 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id k127so7699644ywe.23
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:55:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IogFOnjAab5csjva7rqwjA7mZNbNEKE9pYPTMEoR1qA=;
        b=CipZhR7ouyimvD6b+KhB6Qf953SBw/qIOon+5tT218WL+zkyiEboZI424a3/BC9HRT
         8eYT+RlJ3iwvtqPH1QwV8FzQX00fSL9F/JloKOgqjZ2sdtiUu+RiJobtmHKyVmqIRcnL
         NbKb32CUxjfod0w1SpCTDUNbuTCao0hqtB9KNPzztY2Qmn+GJtpX/dPVHUwoozIogbN6
         7eNbvwaGc0P32cKF/X8HKHXSP0OmvFBn7KTpw9qYerRPp5c5VEn51PQcifzpD51mcY4v
         qFWLE2Uq8ZPp91ORsnRez2r6mWzDBThjExbtYADXkYvjtR3RhpfOOnBj/3D8Km7uGJ78
         ngqw==
X-Gm-Message-State: APjAAAVH4mp+FMO2/uT/RlKxiCYB9e+SHpFIIOVUNQrmO5okNfr6QX31
	LT1N6goKfrYRhyyOJivn9iYa+t1IfveWtS5Y/ZwkhCJNkrA/QJKZ8w6VsQkeoxGz+UEgm72QuKH
	zzoovdK0zNB19bAnNBCvIRgoilklyILTHlbQ//AkzoATZWu2kV8QMPeCk9DF/z0srlA==
X-Received: by 2002:a0d:e743:: with SMTP id q64mr48065837ywe.437.1555098924028;
        Fri, 12 Apr 2019 12:55:24 -0700 (PDT)
X-Received: by 2002:a0d:e743:: with SMTP id q64mr48065719ywe.437.1555098921924;
        Fri, 12 Apr 2019 12:55:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555098921; cv=none;
        d=google.com; s=arc-20160816;
        b=kEsH/+OFlXRNhLPkhgXOj61HUA6QIcM8ZA30W8Oayv2h7oCpPI+YHt4GApUWHMkI6T
         rdFlceZAJ/4S79W7KdBavEMmpXYZEtsBFpsUTZxmS4USzEBl0k9OkVbGxv0Yxd9HZSDW
         u4apeQOr9EBdHpbsoBEjEMBxibXIBbscqtyi/HTM0i4a2MvMHyVFEKjB9cOKS6Q3uXR/
         eY193R3KftZZwHTPxrYF36MVRlnl9lVpXTgkuiZF0L4/x4sr0cYp9Qpzbjx7LUolU0BV
         ZbysAtVZsuVItQ8RG5XggNf9E97jGZivUWMJac4TT8yw/2OvLu9ZOPd41+C2hmXDcfcV
         9icw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IogFOnjAab5csjva7rqwjA7mZNbNEKE9pYPTMEoR1qA=;
        b=wGdz+9QQINqyZqU3wRGAqkpAfnNeQTGBSqckSaJ0bPvvIC65f06p/iR9X840bdBk23
         l/lfboJxDpioNPIRNUGdKJXt6/HmFCojJIKE/vpFCuMpxeDIBe6T9l2G43Np4tfMh6bX
         VGqtovWPrv3WwI2e0QkAL8ZiV4/jgzNKaFfM3/fOP8fRob188nvf5IPs7K36j97FYNIS
         KvpZjLPoxpCJ9fw8ziEayBFqQ4pRQaM0U5TVlIQIKJETolNrzKImgUx/JhBj5luwga/h
         /o0YkBb0QzjhQw18JDCUvJMO51iN6fVKAz5nMTEN6aLdm4S6oOiyUb/t+g1ZA9qswpfC
         OMaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dKgwuHoq;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r17sor11248946ybg.65.2019.04.12.12.55.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 12:55:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dKgwuHoq;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IogFOnjAab5csjva7rqwjA7mZNbNEKE9pYPTMEoR1qA=;
        b=dKgwuHoqhb4ECYQMvXEsERVMj/X7Jt82CXIAY9mAPKPUMnth1Wi2xWlnUQslWf19ua
         aVFT3tDfUuMDOiryJkOTKYOvOmlo0NEmiFPxRspervi12qc5IO7FJF9keKeDp9ccin1P
         ccKGBkkAwUWMuVQxQUWqe9iPWkAl5c0cIqv+tE0vSfYRse/fUUBYpFuRkGZMo90/UYXK
         YVIwC/BF+qD+MI8LkyixCklis0HluVnExtdxy512CB2zVeHCqdpFNxdc7Ihz1bdsISzu
         HV8eHDJ9ZaZ2+eaymqGe6+w8rRj8fqr4t3b207na+YAU+9hiSwKqW6w4qsxELKrXfvWS
         HWYQ==
X-Google-Smtp-Source: APXvYqyCAp+VQw/r048K2N6bWKC4EYhz4lXsNpaIgi83lC6VOJMItghhg+7oeLR9324inGD3DBO850mP2Vct/VPY3hk=
X-Received: by 2002:a25:41c1:: with SMTP id o184mr21217258yba.183.1555098921146;
 Fri, 12 Apr 2019 12:55:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190412151507.2769-1-hannes@cmpxchg.org> <20190412151507.2769-4-hannes@cmpxchg.org>
In-Reply-To: <20190412151507.2769-4-hannes@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 12 Apr 2019 12:55:10 -0700
Message-ID: <CALvZod4xu10+E41YyaamigysZAnDcdA09f5m-hGd72LeJ9VmEg@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm: memcontrol: fix recursive statistics correctness
 & scalabilty
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team@fb.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 8:15 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> Right now, when somebody needs to know the recursive memory statistics
> and events of a cgroup subtree, they need to walk the entire subtree
> and sum up the counters manually.
>
> There are two issues with this:
>
> 1. When a cgroup gets deleted, its stats are lost. The state counters
> should all be 0 at that point, of course, but the events are not. When
> this happens, the event counters, which are supposed to be monotonic,
> can go backwards in the parent cgroups.
>

We also faced this exact same issue as well and had the similar solution.

> 2. During regular operation, we always have a certain number of lazily
> freed cgroups sitting around that have been deleted, have no tasks,
> but have a few cache pages remaining. These groups' statistics do not
> change until we eventually hit memory pressure, but somebody watching,
> say, memory.stat on an ancestor has to iterate those every time.
>
> This patch addresses both issues by introducing recursive counters at
> each level that are propagated from the write side when stats change.
>
> Upward propagation happens when the per-cpu caches spill over into the
> local atomic counter. This is the same thing we do during charge and
> uncharge, except that the latter uses atomic RMWs, which are more
> expensive; stat changes happen at around the same rate. In a sparse
> file test (page faults and reclaim at maximum CPU speed) with 5 cgroup
> nesting levels, perf shows __mod_memcg_page state at ~1%.
>

(Unrelated to this patchset) I think there should also a way to get
the exact memcg stats. As the machines are getting bigger (more cpus
and larger basic page size) the accuracy of stats are getting worse.
Internally we have an additional interface memory.stat_exact for that.
However I am not sure in the upstream kernel will an additional
interface is better or something like /proc/sys/vm/stat_refresh which
sync all per-cpu stats.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  include/linux/memcontrol.h |  54 +++++++++-
>  mm/memcontrol.c            | 205 ++++++++++++++++++-------------------
>  2 files changed, 150 insertions(+), 109 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index cae7d1b11eea..36bdfe8e5965 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -128,6 +128,7 @@ struct mem_cgroup_per_node {
>
>         struct lruvec_stat __percpu *lruvec_stat_cpu;
>         atomic_long_t           lruvec_stat[NR_VM_NODE_STAT_ITEMS];
> +       atomic_long_t           lruvec_stat_local[NR_VM_NODE_STAT_ITEMS];
>
>         unsigned long           lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
>
> @@ -279,8 +280,12 @@ struct mem_cgroup {
>         MEMCG_PADDING(_pad2_);
>
>         atomic_long_t           vmstats[MEMCG_NR_STAT];
> +       atomic_long_t           vmstats_local[MEMCG_NR_STAT];
> +
>         atomic_long_t           vmevents[NR_VM_EVENT_ITEMS];
> -       atomic_long_t memory_events[MEMCG_NR_MEMORY_EVENTS];
> +       atomic_long_t           vmevents_local[NR_VM_EVENT_ITEMS];
> +
> +       atomic_long_t           memory_events[MEMCG_NR_MEMORY_EVENTS];
>
>         unsigned long           socket_pressure;
>
> @@ -565,6 +570,20 @@ struct mem_cgroup *lock_page_memcg(struct page *page);
>  void __unlock_page_memcg(struct mem_cgroup *memcg);
>  void unlock_page_memcg(struct page *page);
>
> +/*
> + * idx can be of type enum memcg_stat_item or node_stat_item.
> + * Keep in sync with memcg_exact_page_state().
> + */
> +static inline unsigned long memcg_page_state(struct mem_cgroup *memcg, int idx)
> +{
> +       long x = atomic_long_read(&memcg->vmstats[idx]);
> +#ifdef CONFIG_SMP
> +       if (x < 0)
> +               x = 0;
> +#endif
> +       return x;
> +}
> +
>  /*
>   * idx can be of type enum memcg_stat_item or node_stat_item.
>   * Keep in sync with memcg_exact_page_state().
> @@ -572,7 +591,7 @@ void unlock_page_memcg(struct page *page);
>  static inline unsigned long memcg_page_state_local(struct mem_cgroup *memcg,
>                                                    int idx)
>  {
> -       long x = atomic_long_read(&memcg->vmstats[idx]);
> +       long x = atomic_long_read(&memcg->vmstats_local[idx]);
>  #ifdef CONFIG_SMP
>         if (x < 0)
>                 x = 0;
> @@ -624,6 +643,24 @@ static inline void mod_memcg_page_state(struct page *page,
>                 mod_memcg_state(page->mem_cgroup, idx, val);
>  }
>
> +static inline unsigned long lruvec_page_state(struct lruvec *lruvec,
> +                                             enum node_stat_item idx)
> +{
> +       struct mem_cgroup_per_node *pn;
> +       long x;
> +
> +       if (mem_cgroup_disabled())
> +               return node_page_state(lruvec_pgdat(lruvec), idx);
> +
> +       pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
> +       x = atomic_long_read(&pn->lruvec_stat[idx]);
> +#ifdef CONFIG_SMP
> +       if (x < 0)
> +               x = 0;
> +#endif
> +       return x;
> +}
> +
>  static inline unsigned long lruvec_page_state_local(struct lruvec *lruvec,
>                                                     enum node_stat_item idx)
>  {
> @@ -634,7 +671,7 @@ static inline unsigned long lruvec_page_state_local(struct lruvec *lruvec,
>                 return node_page_state(lruvec_pgdat(lruvec), idx);
>
>         pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
> -       x = atomic_long_read(&pn->lruvec_stat[idx]);
> +       x = atomic_long_read(&pn->lruvec_stat_local[idx]);
>  #ifdef CONFIG_SMP
>         if (x < 0)
>                 x = 0;
> @@ -991,6 +1028,11 @@ static inline void mem_cgroup_print_oom_group(struct mem_cgroup *memcg)
>  {
>  }
>
> +static inline unsigned long memcg_page_state(struct mem_cgroup *memcg, int idx)
> +{
> +       return 0;
> +}
> +
>  static inline unsigned long memcg_page_state_local(struct mem_cgroup *memcg,
>                                                    int idx)
>  {
> @@ -1021,6 +1063,12 @@ static inline void mod_memcg_page_state(struct page *page,
>  {
>  }
>
> +static inline unsigned long lruvec_page_state(struct lruvec *lruvec,
> +                                             enum node_stat_item idx)
> +{
> +       return node_page_state(lruvec_pgdat(lruvec), idx);
> +}
> +
>  static inline unsigned long lruvec_page_state_local(struct lruvec *lruvec,
>                                                     enum node_stat_item idx)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3535270ebeec..2eb2d4ef9b34 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -702,12 +702,27 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
>
>         x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
>         if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
> -               atomic_long_add(x, &memcg->vmstats[idx]);
> +               struct mem_cgroup *mi;
> +
> +               atomic_long_add(x, &memcg->vmstats_local[idx]);
> +               for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
> +                       atomic_long_add(x, &mi->vmstats[idx]);
>                 x = 0;
>         }
>         __this_cpu_write(memcg->vmstats_percpu->stat[idx], x);
>  }
>
> +static struct mem_cgroup_per_node *
> +parent_nodeinfo(struct mem_cgroup_per_node *pn, int nid)
> +{
> +       struct mem_cgroup *parent;
> +
> +       parent = parent_mem_cgroup(pn->memcg);
> +       if (!parent)
> +               return NULL;
> +       return mem_cgroup_nodeinfo(parent, nid);
> +}
> +
>  /**
>   * __mod_lruvec_state - update lruvec memory statistics
>   * @lruvec: the lruvec
> @@ -721,24 +736,31 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
>  void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
>                         int val)
>  {
> +       pg_data_t *pgdat = lruvec_pgdat(lruvec);
>         struct mem_cgroup_per_node *pn;
> +       struct mem_cgroup *memcg;
>         long x;
>
>         /* Update node */
> -       __mod_node_page_state(lruvec_pgdat(lruvec), idx, val);
> +       __mod_node_page_state(pgdat, idx, val);
>
>         if (mem_cgroup_disabled())
>                 return;
>
>         pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
> +       memcg = pn->memcg;
>
>         /* Update memcg */
> -       __mod_memcg_state(pn->memcg, idx, val);
> +       __mod_memcg_state(memcg, idx, val);
>
>         /* Update lruvec */
>         x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
>         if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
> -               atomic_long_add(x, &pn->lruvec_stat[idx]);
> +               struct mem_cgroup_per_node *pi;
> +
> +               atomic_long_add(x, &pn->lruvec_stat_local[idx]);
> +               for (pi = pn; pi; pi = parent_nodeinfo(pi, pgdat->node_id))
> +                       atomic_long_add(x, &pi->lruvec_stat[idx]);
>                 x = 0;
>         }
>         __this_cpu_write(pn->lruvec_stat_cpu->count[idx], x);
> @@ -760,18 +782,26 @@ void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
>
>         x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
>         if (unlikely(x > MEMCG_CHARGE_BATCH)) {
> -               atomic_long_add(x, &memcg->vmevents[idx]);
> +               struct mem_cgroup *mi;
> +
> +               atomic_long_add(x, &memcg->vmevents_local[idx]);
> +               for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
> +                       atomic_long_add(x, &mi->vmevents[idx]);
>                 x = 0;
>         }
>         __this_cpu_write(memcg->vmstats_percpu->events[idx], x);
>  }
>
> -static unsigned long memcg_events_local(struct mem_cgroup *memcg,
> -                                       int event)
> +static unsigned long memcg_events(struct mem_cgroup *memcg, int event)
>  {
>         return atomic_long_read(&memcg->vmevents[event]);
>  }
>
> +static unsigned long memcg_events_local(struct mem_cgroup *memcg, int event)
> +{
> +       return atomic_long_read(&memcg->vmevents_local[event]);
> +}
> +
>  static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
>                                          struct page *page,
>                                          bool compound, int nr_pages)
> @@ -2162,7 +2192,7 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
>  static int memcg_hotplug_cpu_dead(unsigned int cpu)
>  {
>         struct memcg_stock_pcp *stock;
> -       struct mem_cgroup *memcg;
> +       struct mem_cgroup *memcg, *mi;
>
>         stock = &per_cpu(memcg_stock, cpu);
>         drain_stock(stock);
> @@ -2175,8 +2205,11 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
>                         long x;
>
>                         x = this_cpu_xchg(memcg->vmstats_percpu->stat[i], 0);
> -                       if (x)
> -                               atomic_long_add(x, &memcg->vmstats[i]);
> +                       if (x) {
> +                               atomic_long_add(x, &memcg->vmstats_local[i]);
> +                               for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
> +                                       atomic_long_add(x, &memcg->vmstats[i]);
> +                       }
>
>                         if (i >= NR_VM_NODE_STAT_ITEMS)
>                                 continue;
> @@ -2186,8 +2219,12 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
>
>                                 pn = mem_cgroup_nodeinfo(memcg, nid);
>                                 x = this_cpu_xchg(pn->lruvec_stat_cpu->count[i], 0);
> -                               if (x)
> -                                       atomic_long_add(x, &pn->lruvec_stat[i]);
> +                               if (x) {
> +                                       atomic_long_add(x, &pn->lruvec_stat_local[i]);
> +                                       do {
> +                                               atomic_long_add(x, &pn->lruvec_stat[i]);
> +                                       } while ((pn = parent_nodeinfo(pn, nid)));
> +                               }
>                         }
>                 }
>
> @@ -2195,8 +2232,11 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
>                         long x;
>
>                         x = this_cpu_xchg(memcg->vmstats_percpu->events[i], 0);
> -                       if (x)
> -                               atomic_long_add(x, &memcg->vmevents[i]);
> +                       if (x) {
> +                               atomic_long_add(x, &memcg->vmevents_local[i]);
> +                               for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
> +                                       atomic_long_add(x, &memcg->vmevents[i]);
> +                       }
>                 }
>         }
>
> @@ -3036,54 +3076,15 @@ static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
>         return retval;
>  }
>
> -struct accumulated_vmstats {
> -       unsigned long vmstats[MEMCG_NR_STAT];
> -       unsigned long vmevents[NR_VM_EVENT_ITEMS];
> -       unsigned long lru_pages[NR_LRU_LISTS];
> -
> -       /* overrides for v1 */
> -       const unsigned int *vmstats_array;
> -       const unsigned int *vmevents_array;
> -
> -       int vmstats_size;
> -       int vmevents_size;
> -};
> -
> -static void accumulate_vmstats(struct mem_cgroup *memcg,
> -                              struct accumulated_vmstats *acc)
> -{
> -       struct mem_cgroup *mi;
> -       int i;
> -
> -       for_each_mem_cgroup_tree(mi, memcg) {
> -               for (i = 0; i < acc->vmstats_size; i++)
> -                       acc->vmstats[i] += memcg_page_state_local(mi,
> -                               acc->vmstats_array ? acc->vmstats_array[i] : i);
> -
> -               for (i = 0; i < acc->vmevents_size; i++)
> -                       acc->vmevents[i] += memcg_events_local(mi,
> -                               acc->vmevents_array
> -                               ? acc->vmevents_array[i] : i);
> -
> -               for (i = 0; i < NR_LRU_LISTS; i++)
> -                       acc->lru_pages[i] += memcg_page_state_local(mi,
> -                                                             NR_LRU_BASE + i);
> -       }
> -}
> -
>  static unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>  {
> -       unsigned long val = 0;
> +       unsigned long val;
>
>         if (mem_cgroup_is_root(memcg)) {
> -               struct mem_cgroup *iter;
> -
> -               for_each_mem_cgroup_tree(iter, memcg) {
> -                       val += memcg_page_state_local(iter, MEMCG_CACHE);
> -                       val += memcg_page_state_local(iter, MEMCG_RSS);
> -                       if (swap)
> -                               val += memcg_page_state_local(iter, MEMCG_SWAP);
> -               }
> +               val = memcg_page_state(memcg, MEMCG_CACHE) +
> +                       memcg_page_state(memcg, MEMCG_RSS);
> +               if (swap)
> +                       val += memcg_page_state(memcg, MEMCG_SWAP);
>         } else {
>                 if (!swap)
>                         val = page_counter_read(&memcg->memory);
> @@ -3514,7 +3515,6 @@ static int memcg_stat_show(struct seq_file *m, void *v)
>         unsigned long memory, memsw;
>         struct mem_cgroup *mi;
>         unsigned int i;
> -       struct accumulated_vmstats acc;
>
>         BUILD_BUG_ON(ARRAY_SIZE(memcg1_stat_names) != ARRAY_SIZE(memcg1_stats));
>         BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
> @@ -3548,27 +3548,21 @@ static int memcg_stat_show(struct seq_file *m, void *v)
>                 seq_printf(m, "hierarchical_memsw_limit %llu\n",
>                            (u64)memsw * PAGE_SIZE);
>
> -       memset(&acc, 0, sizeof(acc));
> -       acc.vmstats_size = ARRAY_SIZE(memcg1_stats);
> -       acc.vmstats_array = memcg1_stats;
> -       acc.vmevents_size = ARRAY_SIZE(memcg1_events);
> -       acc.vmevents_array = memcg1_events;
> -       accumulate_vmstats(memcg, &acc);
> -
>         for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
>                 if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
>                         continue;
>                 seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
> -                          (u64)acc.vmstats[i] * PAGE_SIZE);
> +                          (u64)memcg_page_state(memcg, i) * PAGE_SIZE);
>         }
>
>         for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
>                 seq_printf(m, "total_%s %llu\n", memcg1_event_names[i],
> -                          (u64)acc.vmevents[i]);
> +                          (u64)memcg_events(memcg, i));
>
>         for (i = 0; i < NR_LRU_LISTS; i++)
>                 seq_printf(m, "total_%s %llu\n", mem_cgroup_lru_names[i],
> -                          (u64)acc.lru_pages[i] * PAGE_SIZE);
> +                          (u64)memcg_page_state(memcg, NR_LRU_BASE + i) *
> +                          PAGE_SIZE);
>
>  #ifdef CONFIG_DEBUG_VM
>         {
> @@ -5661,7 +5655,6 @@ static int memory_events_show(struct seq_file *m, void *v)
>  static int memory_stat_show(struct seq_file *m, void *v)
>  {
>         struct mem_cgroup *memcg = mem_cgroup_from_seq(m);
> -       struct accumulated_vmstats acc;
>         int i;
>
>         /*
> @@ -5675,31 +5668,27 @@ static int memory_stat_show(struct seq_file *m, void *v)
>          * Current memory state:
>          */
>
> -       memset(&acc, 0, sizeof(acc));
> -       acc.vmstats_size = MEMCG_NR_STAT;
> -       acc.vmevents_size = NR_VM_EVENT_ITEMS;
> -       accumulate_vmstats(memcg, &acc);
> -
>         seq_printf(m, "anon %llu\n",
> -                  (u64)acc.vmstats[MEMCG_RSS] * PAGE_SIZE);
> +                  (u64)memcg_page_state(memcg, MEMCG_RSS) * PAGE_SIZE);
>         seq_printf(m, "file %llu\n",
> -                  (u64)acc.vmstats[MEMCG_CACHE] * PAGE_SIZE);
> +                  (u64)memcg_page_state(memcg, MEMCG_CACHE) * PAGE_SIZE);
>         seq_printf(m, "kernel_stack %llu\n",
> -                  (u64)acc.vmstats[MEMCG_KERNEL_STACK_KB] * 1024);
> +                  (u64)memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) * 1024);
>         seq_printf(m, "slab %llu\n",
> -                  (u64)(acc.vmstats[NR_SLAB_RECLAIMABLE] +
> -                        acc.vmstats[NR_SLAB_UNRECLAIMABLE]) * PAGE_SIZE);
> +                  (u64)(memcg_page_state(memcg, NR_SLAB_RECLAIMABLE) +
> +                        memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE)) *
> +                  PAGE_SIZE);
>         seq_printf(m, "sock %llu\n",
> -                  (u64)acc.vmstats[MEMCG_SOCK] * PAGE_SIZE);
> +                  (u64)memcg_page_state(memcg, MEMCG_SOCK) * PAGE_SIZE);
>
>         seq_printf(m, "shmem %llu\n",
> -                  (u64)acc.vmstats[NR_SHMEM] * PAGE_SIZE);
> +                  (u64)memcg_page_state(memcg, NR_SHMEM) * PAGE_SIZE);
>         seq_printf(m, "file_mapped %llu\n",
> -                  (u64)acc.vmstats[NR_FILE_MAPPED] * PAGE_SIZE);
> +                  (u64)memcg_page_state(memcg, NR_FILE_MAPPED) * PAGE_SIZE);
>         seq_printf(m, "file_dirty %llu\n",
> -                  (u64)acc.vmstats[NR_FILE_DIRTY] * PAGE_SIZE);
> +                  (u64)memcg_page_state(memcg, NR_FILE_DIRTY) * PAGE_SIZE);
>         seq_printf(m, "file_writeback %llu\n",
> -                  (u64)acc.vmstats[NR_WRITEBACK] * PAGE_SIZE);
> +                  (u64)memcg_page_state(memcg, NR_WRITEBACK) * PAGE_SIZE);
>
>         /*
>          * TODO: We should eventually replace our own MEMCG_RSS_HUGE counter
> @@ -5708,43 +5697,47 @@ static int memory_stat_show(struct seq_file *m, void *v)
>          * where the page->mem_cgroup is set up and stable.
>          */
>         seq_printf(m, "anon_thp %llu\n",
> -                  (u64)acc.vmstats[MEMCG_RSS_HUGE] * PAGE_SIZE);
> +                  (u64)memcg_page_state(memcg, MEMCG_RSS_HUGE) * PAGE_SIZE);
>
>         for (i = 0; i < NR_LRU_LISTS; i++)
>                 seq_printf(m, "%s %llu\n", mem_cgroup_lru_names[i],
> -                          (u64)acc.lru_pages[i] * PAGE_SIZE);
> +                          (u64)memcg_page_state(memcg, NR_LRU_BASE + i) *
> +                          PAGE_SIZE);
>
>         seq_printf(m, "slab_reclaimable %llu\n",
> -                  (u64)acc.vmstats[NR_SLAB_RECLAIMABLE] * PAGE_SIZE);
> +                  (u64)memcg_page_state(memcg, NR_SLAB_RECLAIMABLE) *
> +                  PAGE_SIZE);
>         seq_printf(m, "slab_unreclaimable %llu\n",
> -                  (u64)acc.vmstats[NR_SLAB_UNRECLAIMABLE] * PAGE_SIZE);
> +                  (u64)memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE) *
> +                  PAGE_SIZE);
>
>         /* Accumulated memory events */
>
> -       seq_printf(m, "pgfault %lu\n", acc.vmevents[PGFAULT]);
> -       seq_printf(m, "pgmajfault %lu\n", acc.vmevents[PGMAJFAULT]);
> +       seq_printf(m, "pgfault %lu\n", memcg_events(memcg, PGFAULT));
> +       seq_printf(m, "pgmajfault %lu\n", memcg_events(memcg, PGMAJFAULT));
>
>         seq_printf(m, "workingset_refault %lu\n",
> -                  acc.vmstats[WORKINGSET_REFAULT]);
> +                  memcg_page_state(memcg, WORKINGSET_REFAULT));
>         seq_printf(m, "workingset_activate %lu\n",
> -                  acc.vmstats[WORKINGSET_ACTIVATE]);
> +                  memcg_page_state(memcg, WORKINGSET_ACTIVATE));
>         seq_printf(m, "workingset_nodereclaim %lu\n",
> -                  acc.vmstats[WORKINGSET_NODERECLAIM]);
> -
> -       seq_printf(m, "pgrefill %lu\n", acc.vmevents[PGREFILL]);
> -       seq_printf(m, "pgscan %lu\n", acc.vmevents[PGSCAN_KSWAPD] +
> -                  acc.vmevents[PGSCAN_DIRECT]);
> -       seq_printf(m, "pgsteal %lu\n", acc.vmevents[PGSTEAL_KSWAPD] +
> -                  acc.vmevents[PGSTEAL_DIRECT]);
> -       seq_printf(m, "pgactivate %lu\n", acc.vmevents[PGACTIVATE]);
> -       seq_printf(m, "pgdeactivate %lu\n", acc.vmevents[PGDEACTIVATE]);
> -       seq_printf(m, "pglazyfree %lu\n", acc.vmevents[PGLAZYFREE]);
> -       seq_printf(m, "pglazyfreed %lu\n", acc.vmevents[PGLAZYFREED]);
> +                  memcg_page_state(memcg, WORKINGSET_NODERECLAIM));
> +
> +       seq_printf(m, "pgrefill %lu\n", memcg_events(memcg, PGREFILL));
> +       seq_printf(m, "pgscan %lu\n", memcg_events(memcg, PGSCAN_KSWAPD) +
> +                  memcg_events(memcg, PGSCAN_DIRECT));
> +       seq_printf(m, "pgsteal %lu\n", memcg_events(memcg, PGSTEAL_KSWAPD) +
> +                  memcg_events(memcg, PGSTEAL_DIRECT));
> +       seq_printf(m, "pgactivate %lu\n", memcg_events(memcg, PGACTIVATE));
> +       seq_printf(m, "pgdeactivate %lu\n", memcg_events(memcg, PGDEACTIVATE));
> +       seq_printf(m, "pglazyfree %lu\n", memcg_events(memcg, PGLAZYFREE));
> +       seq_printf(m, "pglazyfreed %lu\n", memcg_events(memcg, PGLAZYFREED));
>
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> -       seq_printf(m, "thp_fault_alloc %lu\n", acc.vmevents[THP_FAULT_ALLOC]);
> +       seq_printf(m, "thp_fault_alloc %lu\n",
> +                  memcg_events(memcg, THP_FAULT_ALLOC));
>         seq_printf(m, "thp_collapse_alloc %lu\n",
> -                  acc.vmevents[THP_COLLAPSE_ALLOC]);
> +                  memcg_events(memcg, THP_COLLAPSE_ALLOC));
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>
>         return 0;
> --
> 2.21.0
>

