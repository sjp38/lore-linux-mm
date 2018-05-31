Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C11866B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 02:52:28 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a7-v6so16509615wrq.13
        for <linux-mm@kvack.org>; Wed, 30 May 2018 23:52:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c46-v6si334138edc.226.2018.05.30.23.52.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 May 2018 23:52:27 -0700 (PDT)
Date: Thu, 31 May 2018 08:52:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6] Refactor part of the oom report in dump_header
Message-ID: <20180531065226.GA15659@dhcp22.suse.cz>
References: <1527413551-5982-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1527413551-5982-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607 <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 27-05-18 10:32:31, ufo19890607 wrote:
> The dump_header does not print the memcg's name when the system
> oom happened, so users cannot locate the certain container which
> contains the task that has been killed by the oom killer.
> 
> I follow the advices of David Rientjes and Michal Hocko, and refactor
> part of the oom report in a backwards compatible way. After this patch,
> users can get the memcg's path from the oom report and check the certain
> container more quickly.
> 
> Below is the part of the oom report in the dmesg
> ...
> [  142.158316] panic cpuset=/ mems_allowed=0-1
> [  142.158983] CPU: 15 PID: 8682 Comm: panic Not tainted 4.17.0-rc6+ #13
> [  142.159659] Hardware name: Inspur SA5212M4/YZMB-00370-107, BIOS 4.1.10 11/14/2016
> [  142.160342] Call Trace:
> [  142.161037]  dump_stack+0x78/0xb3
> [  142.161734]  dump_header+0x7d/0x334
> [  142.162433]  oom_kill_process+0x228/0x490
> [  142.163126]  ? oom_badness+0x2a/0x130
> [  142.163821]  out_of_memory+0xf0/0x280
> [  142.164532]  __alloc_pages_slowpath+0x711/0xa07
> [  142.165241]  __alloc_pages_nodemask+0x23f/0x260
> [  142.165947]  alloc_pages_vma+0x73/0x180
> [  142.166665]  do_anonymous_page+0xed/0x4e0
> [  142.167388]  __handle_mm_fault+0xbd2/0xe00
> [  142.168114]  handle_mm_fault+0x116/0x250
> [  142.168841]  __do_page_fault+0x233/0x4d0
> [  142.169567]  do_page_fault+0x32/0x130
> [  142.170303]  ? page_fault+0x8/0x30
> [  142.171036]  page_fault+0x1e/0x30
> [  142.171764] RIP: 0033:0x7f403000a860
> [  142.172517] RSP: 002b:00007ffc9f745c28 EFLAGS: 00010206
> [  142.173268] RAX: 00007f3f6fd7d000 RBX: 0000000000000000 RCX: 00007f3f7f5cd000
> [  142.174040] RDX: 00007f3fafd7d000 RSI: 0000000000000000 RDI: 00007f3f6fd7d000
> [  142.174806] RBP: 00007ffc9f745c50 R08: ffffffffffffffff R09: 0000000000000000
> [  142.175623] R10: 0000000000000022 R11: 0000000000000246 R12: 0000000000400490
> [  142.176542] R13: 00007ffc9f745d30 R14: 0000000000000000 R15: 0000000000000000
> [  142.177709] oom-kill: constrain=CONSTRAINT_NONE nodemask=(null) origin_memcg= kill_memcg=/test/test1/test2 task=panic pid= 8622 uid=    0
> ...
> 
> Changes since v5:
> - add an array of const char for each constraint.
> - replace all of the pr_cont with a single line print of the pr_info.
> - put enum oom_constraint into the memcontrol.c file for printing oom constraint.
> 
> Changes since v4:
> - rename the helper's name to mem_cgroup_print_oom_context.
> - rename the mem_cgroup_print_oom_info to mem_cgroup_print_oom_meminfo.
> - add the constrain info in the dump_header.
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
> 
> Signed-off-by: ufo19890607 <ufo19890607@gmail.com>
> ---
>  include/linux/memcontrol.h | 29 +++++++++++++++++++++---
>  mm/memcontrol.c            | 55 ++++++++++++++++++++++++++++++++--------------
>  mm/oom_kill.c              | 12 +++-------
>  3 files changed, 67 insertions(+), 29 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index d99b71bc2c66..1c7d5da1c827 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -62,6 +62,20 @@ struct mem_cgroup_reclaim_cookie {
>  	unsigned int generation;
>  };
>  
> +enum oom_constraint {
> +	CONSTRAINT_NONE,
> +	CONSTRAINT_CPUSET,
> +	CONSTRAINT_MEMORY_POLICY,
> +	CONSTRAINT_MEMCG,
> +};
> +
> +static const char * const oom_constraint_text[] = {
> +	[CONSTRAINT_NONE] = "CONSTRAINT_NONE",
> +	[CONSTRAINT_CPUSET] = "CONSTRAINT_CPUSET",
> +	[CONSTRAINT_MEMORY_POLICY] = "CONSTRAINT_MEMORY_POLICY",
> +	[CONSTRAINT_MEMCG] = "CONSTRAINT_MEMCG",
> +};
> +
>  #ifdef CONFIG_MEMCG
>  
>  #define MEM_CGROUP_ID_SHIFT	16
> @@ -464,8 +478,11 @@ void mem_cgroup_handle_over_high(void);
>  
>  unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg);
>  
> -void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> -				struct task_struct *p);
> +void mem_cgroup_print_oom_context(struct mem_cgroup *memcg,
> +		struct task_struct *p, enum oom_constraint constraint,
> +		nodemask_t *nodemask);
> +
> +void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg);
>  
>  static inline void mem_cgroup_oom_enable(void)
>  {
> @@ -859,7 +876,13 @@ static inline unsigned long mem_cgroup_get_limit(struct mem_cgroup *memcg)
>  }
>  
>  static inline void
> -mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> +mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p,
> +			enum oom_constraint constraint, nodemask_t *nodemask)
> +{
> +}
> +
> +static inline void
> +mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
>  {
>  }
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2bd3df3d101a..6c05fd3291e6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1118,33 +1118,54 @@ static const char *const memcg1_stat_names[] = {
>  };
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))
> -/**
> - * mem_cgroup_print_oom_info: Print OOM information relevant to memory controller.
> - * @memcg: The memory cgroup that went over limit
> +/*
> + * mem_cgroup_print_oom_context: Print OOM context information relevant to
> + * memory controller, which includes allocation constraint, nodemask, origin
> + * memcg that has reached its limit, kill memcg that contains the killed
> + * process, killed process's command, pid and uid.
> + * @memcg: The origin memory cgroup that went over limit
>   * @p: Task that is going to be killed
> + * @constraint: The allocation constraint
> + * @nodemask: The allocation nodemask
>   *
>   * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
>   * enabled
>   */
> -void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> +void mem_cgroup_print_oom_context(struct mem_cgroup *memcg, struct task_struct *p,
> +			enum oom_constraint constraint, nodemask_t *nodemask)
>  {
> -	struct mem_cgroup *iter;
> -	unsigned int i;
> +	static char origin_memcg_name[PATH_MAX], kill_memcg_name[PATH_MAX];
> +	struct cgroup *origin_cgrp, *kill_cgrp;
>  
>  	rcu_read_lock();
> -
> -	if (p) {
> -		pr_info("Task in ");
> -		pr_cont_cgroup_path(task_cgroup(p, memory_cgrp_id));
> -		pr_cont(" killed as a result of limit of ");
> -	} else {
> -		pr_info("Memory limit reached of cgroup ");
> +	if (memcg) {
> +		origin_cgrp = memcg->css.cgroup;
> +		cgroup_path(origin_cgrp, origin_memcg_name, PATH_MAX);
>  	}
> -
> -	pr_cont_cgroup_path(memcg->css.cgroup);
> -	pr_cont("\n");
> -
> +	kill_cgrp = task_cgroup(p, memory_cgrp_id);
> +	cgroup_path(kill_cgrp, kill_memcg_name, PATH_MAX);
> +
> +	if (p)
> +		pr_info("oom-kill: constrain=%s, nodemask=%*pbl, origin_memcg=%s, kill_memcg=%s, task=%s, pid=%5d, uid=%5d\n",
> +			oom_constraint_text[constraint], nodemask_pr_args(nodemask),
> +			origin_memcg_name, kill_memcg_name, p->comm, p->pid,
> +			from_kuid(&init_user_ns, task_uid(p)));
> +	else
> +		pr_info("oom-kill: constrain=%s, nodemask=%*pbl, origin_memcg=%s, kill_memcg=%s\n",
> +			oom_constraint_text[constraint], nodemask_pr_args(nodemask),
> +			origin_memcg_name, kill_memcg_name);
>  	rcu_read_unlock();

Btw. this is buggy as well. origin_memcg_name will be the previous memcg
oom killed memcg name in the follow up global oom killer context. You
would need to *origin_memcg_name = 0 for !memcg case.

Anyway, I guess we do not really have a strong case to justify the
additional memory just to get rid of pr_cont which would be much
simpler. Interleaving messages will be still possible but we would
really need to see this happening to do something about that.
-- 
Michal Hocko
SUSE Labs
