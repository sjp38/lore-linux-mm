Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 093386B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 18:42:58 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r133so158659654pgr.6
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:42:58 -0700 (PDT)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id p4si4618954pga.958.2017.08.14.15.42.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 15:42:56 -0700 (PDT)
Received: by mail-pg0-x231.google.com with SMTP id u185so55709182pgb.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 15:42:56 -0700 (PDT)
Date: Mon, 14 Aug 2017 15:42:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v5 2/4] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20170814183213.12319-3-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1708141532300.63207@chino.kir.corp.google.com>
References: <20170814183213.12319-1-guro@fb.com> <20170814183213.12319-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 14 Aug 2017, Roman Gushchin wrote:

> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 8a266e2be5a6..b7ec3bd441be 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -39,6 +39,7 @@ struct oom_control {
>  	unsigned long totalpages;
>  	struct task_struct *chosen;
>  	unsigned long chosen_points;
> +	struct mem_cgroup *chosen_memcg;
>  };
>  
>  extern struct mutex oom_lock;
> @@ -79,6 +80,8 @@ extern void oom_killer_enable(void);
>  
>  extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>  
> +extern int oom_evaluate_task(struct task_struct *task, void *arg);
> +
>  /* sysctls */
>  extern int sysctl_oom_dump_tasks;
>  extern int sysctl_oom_kill_allocating_task;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index df6f63ee95d6..0b81dc55c6ac 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2639,6 +2639,181 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
>  	return ret;
>  }
>  
> +static long memcg_oom_badness(struct mem_cgroup *memcg,
> +			      const nodemask_t *nodemask)
> +{
> +	long points = 0;
> +	int nid;
> +
> +	for_each_node_state(nid, N_MEMORY) {
> +		if (nodemask && !node_isset(nid, *nodemask))
> +			continue;
> +
> +		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> +				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> +	}
> +
> +	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
> +		(PAGE_SIZE / 1024);
> +	points += memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE);
> +	points += memcg_page_state(memcg, MEMCG_SOCK);
> +	points += memcg_page_state(memcg, MEMCG_SWAP);
> +
> +	return points;
> +}

I'm indifferent to the memcg evaluation criteria used to determine which 
memcg should be selected over others with the same priority, others may 
feel differently.

> +
> +static long oom_evaluate_memcg(struct mem_cgroup *memcg,
> +			       const nodemask_t *nodemask)
> +{
> +	struct css_task_iter it;
> +	struct task_struct *task;
> +	int elegible = 0;
> +
> +	css_task_iter_start(&memcg->css, 0, &it);
> +	while ((task = css_task_iter_next(&it))) {
> +		/*
> +		 * If there are no tasks, or all tasks have oom_score_adj set
> +		 * to OOM_SCORE_ADJ_MIN and oom_kill_all_tasks is not set,
> +		 * don't select this memory cgroup.
> +		 */
> +		if (!elegible &&
> +		    (memcg->oom_kill_all_tasks ||
> +		     task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN))
> +			elegible = 1;

I'm curious about the decision made in this conditional and how 
oom_kill_memcg_member() ignores task->signal->oom_score_adj.  It means 
that memory.oom_kill_all_tasks overrides /proc/pid/oom_score_adj if it 
should otherwise be disabled.

It's undocumented in the changelog, but I'm questioning whether it's the 
right decision.  Doesn't it make sense to kill all tasks that are not oom 
disabled, and allow the user to still protect certain processes by their 
/proc/pid/oom_score_adj setting?  Otherwise, there's no way to do that 
protection without a sibling memcg and its own reservation of memory.  I'm 
thinking about a process that governs jobs inside the memcg and if there 
is an oom kill, it wants to do logging and any cleanup necessary before 
exiting itself.  It seems like a powerful combination if coupled with oom 
notification.

Also, s/elegible/eligible/

Otherwise, looks good!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
