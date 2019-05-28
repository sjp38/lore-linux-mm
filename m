Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80CEDC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 16:00:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FA4521670
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 16:00:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TnfZ9voF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FA4521670
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFE736B0276; Tue, 28 May 2019 12:00:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AAF8D6B0279; Tue, 28 May 2019 12:00:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99EE26B027A; Tue, 28 May 2019 12:00:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 785DE6B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 12:00:18 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id g203so19262619ywe.21
        for <linux-mm@kvack.org>; Tue, 28 May 2019 09:00:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JLUVuSgF9TjSX5+CGhWzvF7FPKQJgaj78mLOqHozZi0=;
        b=dBU3Vic6lV06HglgEF56BEmr5siKIIhPgKmcidO6WsQmxZPthAmyrigqUdVVb+kTM7
         JczlEaiC1FiuTN4jgrF6xsJ9VH26cgBMWIXPf5aaG4WYvFCGvKSTLSEIv4L17LwVbLN7
         fkkFUGEj9bGHCGnIwKscfFuW1bqtit8qks/fHRl9WcgFp8D8ZWyMayLSxIAb3kfzIXSs
         sxlLpwPBnBsKG3EkMiMQTpjLPKd+YQgnfXx0+vTIrYJu6Twk/6Dz3hCdi22XHTrk6Qq7
         CfqGB2r6bnI7JWnX9n+oEfPOgNn+jQtkUJrA18Im+uJggk7ACEXZu7j8OXpyHoSzJUuL
         0M4Q==
X-Gm-Message-State: APjAAAVrOllA4QsBSPj+MmLRQA4CUFEiOo0ZEh4vL4RjPWo6Y8yOProC
	ZAGgsUdd4G78/ImPnaQapMEr3xfwb+9zEoOnuwnAhsgrGoXijOh44uz0QYgD2rkHxr9KNtejLZi
	7B1A4D6UJEHCGWfWK1/X3pejjgaN8C6EY3qiicnrL6ZgGT15Rbb26rA1+b92NyXCLSg==
X-Received: by 2002:a25:97c6:: with SMTP id j6mr6519738ybo.513.1559059218205;
        Tue, 28 May 2019 09:00:18 -0700 (PDT)
X-Received: by 2002:a25:97c6:: with SMTP id j6mr6519683ybo.513.1559059217145;
        Tue, 28 May 2019 09:00:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559059217; cv=none;
        d=google.com; s=arc-20160816;
        b=j9X9sxUugXFX/NQjpjA4PmlXkuT+7VGVgsHPEBW+rJJK6IUhW9TEm+7KKi08M7ifHh
         vv8fDKUWb3L595zXeLk4cbZWMH4iWmaGBtvoPsqxqYMtNDkJoL1GJEnVyOqiyy5sITl5
         8+PwZmeACq1KS3ruHX/fKf2u53PyJF6HErvtrTo8lMNmdsVcPiQt2n04x1r43FcbZAk8
         KYTgnt+KPHNfb8WnwzIwzhE28xA0vnu5dKDPqKeVedtRNuO1O4FykRFNhp/+PsO1UiHw
         YRhjFdkdOuwbTqMyx/u70plJN6VUoSArfKbOQUTPzpHEqWf1u4k2QzrlhAadIWGjpvSz
         STIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JLUVuSgF9TjSX5+CGhWzvF7FPKQJgaj78mLOqHozZi0=;
        b=ipj+InNyKgtqJZ7VVh36IewmDnm1fObtVtzDIEdAbnWTD6emEBR5Sw12wZbIpCCD3p
         j9h2KzMhrN/fFbq3vLXn3SiG8rY2oy/Twi+XiHSnaKHpiq4ZyGqDwFXId9ZSCw9YDrhf
         zhsM/+6yV3nAYIayz5cSjss/WF+WYAVGoUtZDku8wrojQL7gMIcHw2B9p7cD3vFdlbRQ
         DwcT6SEPFNsnnE+9U7nYSh/mTTuFwhLwjlEQ9M33C6Az4UDO0Ux93vOZ50yOb/8cv/Rd
         +gKdl0MrDdI9NQHzgquaiKMbQwx1hcPfidtrCJG5yJTbgC/oKLcXgTGaWfPFi45yqwkW
         W1pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TnfZ9voF;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor6592385ybt.7.2019.05.28.09.00.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 09:00:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TnfZ9voF;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JLUVuSgF9TjSX5+CGhWzvF7FPKQJgaj78mLOqHozZi0=;
        b=TnfZ9voFC+OqE2g5xxm1QKCI2DDBjvYQSAgvxI4qkdsPcW0JQezwjEc1yPU3DZudph
         YARd2JI9JLP4WutMgK+tuLzPSDCsdRK13FpIl/OnBo6HjpB/NRXK3agdIAvk+mnKKEXI
         FGTaR/tc9Jg/2r4Gwh1OfZb81l6h6BsFa7Nc1auJc5GGgNaimWHwrJqaElcGueXy4Kpo
         dtjwxtfTv7L04dyLcHAmNGALrv4rrfnGn87SiU8o7SiRAKuDogZcdDmMuvtVaoVoHEjw
         OUZbnBsqbDLGTEDpFmtLZqHtp2Y3mZrPcAbBX0UIpA+NX7xsOhvY6MXcoU3CuuuW5dnH
         dcFQ==
X-Google-Smtp-Source: APXvYqwHhed/7BvvQixG5VPDthTxmSGfIWlDM6wzbIXnBlHakZZHPYo0Ct4HcdwUTfPpgePbGSfAwyjwjxJ2tH7mdwI=
X-Received: by 2002:a25:943:: with SMTP id u3mr25127031ybm.293.1559059216503;
 Tue, 28 May 2019 09:00:16 -0700 (PDT)
MIME-Version: 1.0
References: <20190520063534.GB19312@shao2-debian> <20190520215328.GA1186@cmpxchg.org>
 <20190521134646.GE19312@shao2-debian> <20190521151647.GB2870@cmpxchg.org>
In-Reply-To: <20190521151647.GB2870@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 28 May 2019 09:00:05 -0700
Message-ID: <CALvZod5KFJvfBfTZKWiDo_ux_OkLKK-b6sWtnYeFCY2ARiiKwQ@mail.gmail.com>
Subject: Re: [PATCH] mm: memcontrol: don't batch updates of local VM stats and events
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, kernel test robot <rong.a.chen@intel.com>, lkp@01.org, 
	LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, 
	Roman Gushchin <guro@fb.com>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 8:16 AM Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> The kernel test robot noticed a 26% will-it-scale pagefault regression
> from commit 42a300353577 ("mm: memcontrol: fix recursive statistics
> correctness & scalabilty"). This appears to be caused by bouncing the
> additional cachelines from the new hierarchical statistics counters.
>
> We can fix this by getting rid of the batched local counters instead.
>
> Originally, there were *only* group-local counters, and they were
> fully maintained per cpu. A reader of a stats file high up in the
> cgroup tree would have to walk the entire subtree and collect each
> level's per-cpu counters to get the recursive view. This was
> prohibitively expensive, and so we switched to per-cpu batched updates
> of the local counters during a983b5ebee57 ("mm: memcontrol: fix
> excessive complexity in memory.stat reporting"), reducing the
> complexity from nr_subgroups * nr_cpus to nr_subgroups.
>
> With growing machines and cgroup trees, the tree walk itself became
> too expensive for monitoring top-level groups, and this is when the
> culprit patch added hierarchy counters on each cgroup level. When the
> per-cpu batch size would be reached, both the local and the hierarchy
> counters would get batch-updated from the per-cpu delta simultaneously.
>
> This makes local and hierarchical counter reads blazingly fast, but it
> unfortunately makes the write-side too cache line intense.
>
> Since local counter reads were never a problem - we only centralized
> them to accelerate the hierarchy walk - and use of the local counters
> are becoming rarer due to replacement with hierarchical views (ongoing
> rework in the page reclaim and workingset code), we can make those
> local counters unbatched per-cpu counters again.
>
> The scheme will then be as such:
>
>    when a memcg statistic changes, the writer will:
>    - update the local counter (per-cpu)
>    - update the batch counter (per-cpu). If the batch is full:
>    - spill the batch into the group's atomic_t
>    - spill the batch into all ancestors' atomic_ts
>    - empty out the batch counter (per-cpu)
>
>    when a local memcg counter is read, the reader will:
>    - collect the local counter from all cpus
>
>    when a hiearchy memcg counter is read, the reader will:
>    - read the atomic_t
>
> We might be able to simplify this further and make the recursive
> counters unbatched per-cpu counters as well (batch upward propagation,
> but leave per-cpu collection to the readers), but that will require a
> more in-depth analysis and testing of all the callsites. Deal with the
> immediate regression for now.
>
> Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")
> Reported-by: kernel test robot <rong.a.chen@intel.com>
> Tested-by: kernel test robot <rong.a.chen@intel.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h | 26 ++++++++++++++++--------
>  mm/memcontrol.c            | 41 ++++++++++++++++++++++++++------------
>  2 files changed, 46 insertions(+), 21 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index bc74d6a4407c..2d23ae7bd36d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -126,9 +126,12 @@ struct memcg_shrinker_map {
>  struct mem_cgroup_per_node {
>         struct lruvec           lruvec;
>
> +       /* Legacy local VM stats */
> +       struct lruvec_stat __percpu *lruvec_stat_local;
> +
> +       /* Subtree VM stats (batched updates) */
>         struct lruvec_stat __percpu *lruvec_stat_cpu;
>         atomic_long_t           lruvec_stat[NR_VM_NODE_STAT_ITEMS];
> -       atomic_long_t           lruvec_stat_local[NR_VM_NODE_STAT_ITEMS];
>
>         unsigned long           lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
>
> @@ -274,17 +277,18 @@ struct mem_cgroup {
>         atomic_t                moving_account;
>         struct task_struct      *move_lock_task;
>
> -       /* memory.stat */
> +       /* Legacy local VM stats and events */
> +       struct memcg_vmstats_percpu __percpu *vmstats_local;
> +
> +       /* Subtree VM stats and events (batched updates) */
>         struct memcg_vmstats_percpu __percpu *vmstats_percpu;
>
>         MEMCG_PADDING(_pad2_);
>
>         atomic_long_t           vmstats[MEMCG_NR_STAT];
> -       atomic_long_t           vmstats_local[MEMCG_NR_STAT];
> -
>         atomic_long_t           vmevents[NR_VM_EVENT_ITEMS];
> -       atomic_long_t           vmevents_local[NR_VM_EVENT_ITEMS];
>
> +       /* memory.events */
>         atomic_long_t           memory_events[MEMCG_NR_MEMORY_EVENTS];
>
>         unsigned long           socket_pressure;
> @@ -576,7 +580,11 @@ static inline unsigned long memcg_page_state(struct mem_cgroup *memcg, int idx)
>  static inline unsigned long memcg_page_state_local(struct mem_cgroup *memcg,
>                                                    int idx)
>  {
> -       long x = atomic_long_read(&memcg->vmstats_local[idx]);
> +       long x = 0;
> +       int cpu;
> +
> +       for_each_possible_cpu(cpu)
> +               x += per_cpu(memcg->vmstats_local->stat[idx], cpu);
>  #ifdef CONFIG_SMP
>         if (x < 0)
>                 x = 0;
> @@ -650,13 +658,15 @@ static inline unsigned long lruvec_page_state_local(struct lruvec *lruvec,
>                                                     enum node_stat_item idx)
>  {
>         struct mem_cgroup_per_node *pn;
> -       long x;
> +       long x = 0;
> +       int cpu;
>
>         if (mem_cgroup_disabled())
>                 return node_page_state(lruvec_pgdat(lruvec), idx);
>
>         pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
> -       x = atomic_long_read(&pn->lruvec_stat_local[idx]);
> +       for_each_possible_cpu(cpu)
> +               x += per_cpu(pn->lruvec_stat_local->count[idx], cpu);
>  #ifdef CONFIG_SMP
>         if (x < 0)
>                 x = 0;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e50a2db5b4ff..8d42e5c7bf37 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -700,11 +700,12 @@ void __mod_memcg_state(struct mem_cgroup *memcg, int idx, int val)
>         if (mem_cgroup_disabled())
>                 return;
>
> +       __this_cpu_add(memcg->vmstats_local->stat[idx], val);
> +
>         x = val + __this_cpu_read(memcg->vmstats_percpu->stat[idx]);
>         if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
>                 struct mem_cgroup *mi;
>
> -               atomic_long_add(x, &memcg->vmstats_local[idx]);

I was suspecting the following for-loop+atomic-add for the regression.
Why the above atomic-add is the culprit?

>                 for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
>                         atomic_long_add(x, &mi->vmstats[idx]);
>                 x = 0;
> @@ -754,11 +755,12 @@ void __mod_lruvec_state(struct lruvec *lruvec, enum node_stat_item idx,
>         __mod_memcg_state(memcg, idx, val);
>
>         /* Update lruvec */
> +       __this_cpu_add(pn->lruvec_stat_local->count[idx], val);
> +
>         x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
>         if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
>                 struct mem_cgroup_per_node *pi;
>
> -               atomic_long_add(x, &pn->lruvec_stat_local[idx]);
>                 for (pi = pn; pi; pi = parent_nodeinfo(pi, pgdat->node_id))
>                         atomic_long_add(x, &pi->lruvec_stat[idx]);
>                 x = 0;
> @@ -780,11 +782,12 @@ void __count_memcg_events(struct mem_cgroup *memcg, enum vm_event_item idx,
>         if (mem_cgroup_disabled())
>                 return;
>
> +       __this_cpu_add(memcg->vmstats_local->events[idx], count);
> +
>         x = count + __this_cpu_read(memcg->vmstats_percpu->events[idx]);
>         if (unlikely(x > MEMCG_CHARGE_BATCH)) {
>                 struct mem_cgroup *mi;
>
> -               atomic_long_add(x, &memcg->vmevents_local[idx]);
>                 for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
>                         atomic_long_add(x, &mi->vmevents[idx]);
>                 x = 0;
> @@ -799,7 +802,12 @@ static unsigned long memcg_events(struct mem_cgroup *memcg, int event)
>
>  static unsigned long memcg_events_local(struct mem_cgroup *memcg, int event)
>  {
> -       return atomic_long_read(&memcg->vmevents_local[event]);
> +       long x = 0;
> +       int cpu;
> +
> +       for_each_possible_cpu(cpu)
> +               x += per_cpu(memcg->vmstats_local->events[event], cpu);
> +       return x;
>  }
>
>  static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
> @@ -2200,11 +2208,9 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
>                         long x;
>
>                         x = this_cpu_xchg(memcg->vmstats_percpu->stat[i], 0);
> -                       if (x) {
> -                               atomic_long_add(x, &memcg->vmstats_local[i]);
> +                       if (x)
>                                 for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
>                                         atomic_long_add(x, &memcg->vmstats[i]);
> -                       }
>
>                         if (i >= NR_VM_NODE_STAT_ITEMS)
>                                 continue;
> @@ -2214,12 +2220,10 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
>
>                                 pn = mem_cgroup_nodeinfo(memcg, nid);
>                                 x = this_cpu_xchg(pn->lruvec_stat_cpu->count[i], 0);
> -                               if (x) {
> -                                       atomic_long_add(x, &pn->lruvec_stat_local[i]);
> +                               if (x)
>                                         do {
>                                                 atomic_long_add(x, &pn->lruvec_stat[i]);
>                                         } while ((pn = parent_nodeinfo(pn, nid)));
> -                               }
>                         }
>                 }
>
> @@ -2227,11 +2231,9 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
>                         long x;
>
>                         x = this_cpu_xchg(memcg->vmstats_percpu->events[i], 0);
> -                       if (x) {
> -                               atomic_long_add(x, &memcg->vmevents_local[i]);
> +                       if (x)
>                                 for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
>                                         atomic_long_add(x, &memcg->vmevents[i]);
> -                       }
>                 }
>         }
>
> @@ -4492,8 +4494,15 @@ static int alloc_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
>         if (!pn)
>                 return 1;
>
> +       pn->lruvec_stat_local = alloc_percpu(struct lruvec_stat);
> +       if (!pn->lruvec_stat_local) {
> +               kfree(pn);
> +               return 1;
> +       }
> +
>         pn->lruvec_stat_cpu = alloc_percpu(struct lruvec_stat);
>         if (!pn->lruvec_stat_cpu) {
> +               free_percpu(pn->lruvec_stat_local);
>                 kfree(pn);
>                 return 1;
>         }
> @@ -4515,6 +4524,7 @@ static void free_mem_cgroup_per_node_info(struct mem_cgroup *memcg, int node)
>                 return;
>
>         free_percpu(pn->lruvec_stat_cpu);
> +       free_percpu(pn->lruvec_stat_local);
>         kfree(pn);
>  }
>
> @@ -4525,6 +4535,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
>         for_each_node(node)
>                 free_mem_cgroup_per_node_info(memcg, node);
>         free_percpu(memcg->vmstats_percpu);
> +       free_percpu(memcg->vmstats_local);
>         kfree(memcg);
>  }
>
> @@ -4553,6 +4564,10 @@ static struct mem_cgroup *mem_cgroup_alloc(void)
>         if (memcg->id.id < 0)
>                 goto fail;
>
> +       memcg->vmstats_local = alloc_percpu(struct memcg_vmstats_percpu);
> +       if (!memcg->vmstats_local)
> +               goto fail;
> +
>         memcg->vmstats_percpu = alloc_percpu(struct memcg_vmstats_percpu);
>         if (!memcg->vmstats_percpu)
>                 goto fail;
> --
> 2.21.0
>

