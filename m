Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 762116B0005
	for <linux-mm@kvack.org>; Tue, 22 May 2018 03:28:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x23-v6so10659689pfm.7
        for <linux-mm@kvack.org>; Tue, 22 May 2018 00:28:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k1-v6si15415417pld.416.2018.05.22.00.28.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 May 2018 00:28:45 -0700 (PDT)
Date: Tue, 22 May 2018 09:28:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] Print the memcg's name when system-wide OOM happened
Message-ID: <20180522072841.GG20020@dhcp22.suse.cz>
References: <1526870386-2439-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1526870386-2439-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607 <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian <yuzhoujian@didichuxing.com>

On Mon 21-05-18 03:39:46, ufo19890607 wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> The dump_header does not print the memcg's name when the system
> oom happened. So users cannot locate the certain container which
> contains the task that has been killed by the oom killer.
> 
> System oom report will print the memcg's name after this patch,
> so users can get the memcg's path from the oom report and check
> the certain container more quickly.
> 
> Changes since v3:
> - rename the helper's name to mem_cgroup_print_oom_memcg_name.
> - add the rcu lock held to the helper.
> - remove the print info of memcg's name in mem_cgroup_print_oom_info.
> 
> Changes since v2:
> - add the mem_cgroup_print_memcg_name helper to print the memcg's
>   name which contains the task that will be killed by the oom-killer.
> 
> Changes since v1:
> - replace adding mem_cgroup_print_oom_info with printing the memcg's
>   name only.

This has still the part which is misleading in the global oom context.
So no, it seems that a helper will not do much good. Unless we can
squeeze everything into a single like like David proposed
(http://lkml.kernel.org/r/alpine.DEB.2.21.1805211405300.41872@chino.kir.corp.google.com)
we should simply open code the relevant part of in the global oom path.

> Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>
> ---
>  include/linux/memcontrol.h |  9 +++++++++
>  mm/memcontrol.c            | 27 +++++++++++++++++++--------
>  mm/oom_kill.c              |  1 +
>  3 files changed, 29 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d99b71bc2c66..5fc58beae368 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -464,6 +464,9 @@ void mem_cgroup_handle_over_high(void);
>  
>  unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg);
>  
> +void mem_cgroup_print_oom_memcg_name(struct mem_cgroup *memcg,
> +				struct task_struct *p);
> +
>  void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
>  				struct task_struct *p);
>  
> @@ -858,6 +861,12 @@ static inline unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
>  	return 0;
>  }
>  
> +static inline void
> +mem_cgroup_print_oom_memcg_name(struct mem_cgroup *memcg,
> +					struct task_struct *p)
> +{
> +}
> +
>  static inline void
>  mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2bd3df3d101a..138a11edfacb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1118,19 +1118,15 @@ static const char *const memcg1_stat_names[] = {
>  };
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))
> +
>  /**
> - * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
> + * mem_cgroup_print_oom_memcg_name: Print the memcg's name which contains the
> + * task that will be killed by the oom-killer.
>   * @memcg: The memory cgroup that went over limit
>   * @p: Task that is going to be killed
> - *
> - * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
> - * enabled
>   */
> -void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> +void mem_cgroup_print_oom_memcg_name(struct mem_cgroup *memcg, struct task_struct *p)
>  {
> -	struct mem_cgroup *iter;
> -	unsigned int i;
> -
>  	rcu_read_lock();
>  
>  	if (p) {
> @@ -1145,7 +1141,22 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  	pr_cont("\n");
>  
>  	rcu_read_unlock();
> +}
> +
> +/**
> + * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
> + * @memcg: The memory cgroup that went over limit
> + * @p: Task that is going to be killed
> + *
> + * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
> + * enabled
> + */
> +void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> +{
> +	struct mem_cgroup *iter;
> +	unsigned int i;
>  
> +	mem_cgroup_print_oom_memcg_name(memcg, p);
>  	pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
>  		K((u64)page_counter_read(&memcg->memory)),
>  		K((u64)memcg->memory.limit), memcg->memory.failcnt);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 8ba6cb88cf58..3e0b725fb877 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -433,6 +433,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>  	if (is_memcg_oom(oc))
>  		mem_cgroup_print_oom_info(oc->memcg, p);
>  	else {
> +		mem_cgroup_print_oom_memcg_name(oc->memcg, p);
>  		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
>  		if (is_dump_unreclaim_slabs())
>  			dump_unreclaimable_slab();
> -- 
> 2.14.1

-- 
Michal Hocko
SUSE Labs
