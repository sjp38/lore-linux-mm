Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC1F6B000A
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 08:08:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p5-v6so110394edh.16
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 05:08:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6-v6si3238436edb.59.2018.07.10.05.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 05:08:18 -0700 (PDT)
Date: Tue, 10 Jul 2018 14:08:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 2/2] Add oom victim's memcg to the oom context
 information
Message-ID: <20180710120816.GJ14284@dhcp22.suse.cz>
References: <1531217988-33940-1-git-send-email-ufo19890607@gmail.com>
 <1531217988-33940-2-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1531217988-33940-2-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

On Tue 10-07-18 18:19:48, ufo19890607@gmail.com wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> The current oom report doesn't display victim's memcg context during the
> global OOM situation. While this information is not strictly needed, it
> can be really helpful for containerized environments to locate which
> container has lost a process. Now that we have a single line for the oom
> context, we can trivially add both the oom memcg (this can be either
> global_oom or a specific memcg which hits its hard limits) and task_memcg
> which is the victim's memcg.
> 
> Below is the single line output in the oom report after this patch.
> - global oom context information:
> oom-kill:constraint=<constraint>,nodemask=<nodemask>,global_oom,task_memcg=<memcg>,task=<comm>,pid=<pid>,uid=<uid>
> - memcg oom context information:
> oom-kill:constraint=<constraint>,nodemask=<nodemask>,oom_memcg=<memcg>,task_memcg=<memcg>,task=<comm>,pid=<pid>,uid=<uid>

The cpuset information is missing which is a bit confusing because your
previous patch is mentioning it. I thought we have agreed that cpuset
goes first and memcg after that. I do not insist of course but that
ordering would make much more sense to me because it fits better to
constraint and nodemask parameters.

> Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>

Once that is fixed, feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h | 14 +++++++++++---
>  mm/memcontrol.c            | 36 ++++++++++++++++++++++--------------
>  mm/oom_kill.c              |  3 ++-
>  3 files changed, 35 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 6c6fb116e925..96a73f989101 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -491,8 +491,10 @@ void mem_cgroup_handle_over_high(void);
>  
>  unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg);
>  
> -void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> -				struct task_struct *p);
> +void mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
> +		struct task_struct *p);
> +
> +void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg);
>  
>  static inline void mem_cgroup_oom_enable(void)
>  {
> @@ -903,7 +905,13 @@ static inline unsigned long mem_cgroup_get_max(struct mem_cgroup *memcg)
>  }
>  
>  static inline void
> -mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> +mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
> +				struct task_struct *p)
> +{
> +}
> +
> +static inline void
> +mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
>  {
>  }
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e6f0d5ef320a..18deea974cfd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1119,32 +1119,40 @@ static const char *const memcg1_stat_names[] = {
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))
>  /**
> - * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
> - * @memcg: The memory cgroup that went over limit
> + * mem_cgroup_print_oom_context: Print OOM context information relevant to
> + * memory controller.
> + * @memcg: The origin memory cgroup that went over limit
>   * @p: Task that is going to be killed
>   *
>   * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
>   * enabled
>   */
> -void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> +void mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p)
>  {
> -	struct mem_cgroup *iter;
> -	unsigned int i;
> +	struct cgroup *origin_cgrp, *kill_cgrp;
>  
>  	rcu_read_lock();
> -
> +	if (memcg) {
> +		pr_cont(",oom_memcg=");
> +		pr_cont_cgroup_path(memcg->css.cgroup);
> +	} else
> +		pr_cont(",global_oom");
>  	if (p) {
> -		pr_info("Task in ");
> +		pr_cont(",task_memcg=");
>  		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
> -		pr_cont(" killed as a result of limit of ");
> -	} else {
> -		pr_info("Memory limit reached of cgroup ");
>  	}
> -
> -	pr_cont_cgroup_path(memcg->css.cgroup);
> -	pr_cont("\n");
> -
>  	rcu_read_unlock();
> +}
> +
> +/**
> + * mem_cgroup_print_oom_meminfo: Print OOM memory information relevant to
> + * memory controller.
> + * @memcg: The memory cgroup that went over limit
> + */
> +void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
> +{
> +	struct mem_cgroup *iter;
> +	unsigned int i;
>  
>  	pr_info("memory: usage %llukB, limit %llukB, failcnt %lu\n",
>  		K((u64)page_counter_read(&memcg->memory)),
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 531b2c86d4db..9e80f6c2eb2e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -433,11 +433,12 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>  	pr_info("oom-kill:constraint=%s,nodemask=%*pbl",
>  			oom_constraint_text[oc->constraint],
>  			nodemask_pr_args(oc->nodemask));
> +	mem_cgroup_print_oom_context(oc->memcg, p);
>  	cpuset_print_current_mems_allowed();
>  	pr_cont(",task=%s,pid=%5d,uid=%5d\n", p->comm, p->pid,
>  		from_kuid(&init_user_ns, task_uid(p)));
>  	if (is_memcg_oom(oc))
> -		mem_cgroup_print_oom_info(oc->memcg, p);
> +		mem_cgroup_print_oom_meminfo(oc->memcg);
>  	else {
>  		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
>  		if (is_dump_unreclaim_slabs())
> -- 
> 2.14.1
> 

-- 
Michal Hocko
SUSE Labs
