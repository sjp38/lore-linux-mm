Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 4123A6B0128
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 01:34:35 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4B41C3EE081
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:34:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 29C2A45DEB5
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:34:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 06C6B45DEB2
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:34:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EE7D31DB8042
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:34:32 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 941961DB803C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 14:34:32 +0900 (JST)
Message-ID: <4FE94968.6010500@jp.fujitsu.com>
Date: Tue, 26 Jun 2012 14:32:24 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch 3/3] mm, memcg: introduce own oom handler to iterate
 only over its own threads
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206251847180.24838@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206251847180.24838@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

(2012/06/26 10:47), David Rientjes wrote:
> The global oom killer is serialized by the zonelist being used in the
> page allocation.  Concurrent oom kills are thus a rare event and only
> occur in systems using mempolicies and with a large number of nodes.
>
> Memory controller oom kills, however, can frequently be concurrent since
> there is no serialization once the oom killer is called for oom
> conditions in several different memcgs in parallel.
>
> This creates a massive contention on tasklist_lock since the oom killer
> requires the readside for the tasklist iteration.  If several memcgs are
> calling the oom killer, this lock can be held for a substantial amount of
> time, especially if threads continue to enter it as other threads are
> exiting.
>
> Since the exit path grabs the writeside of the lock with irqs disabled in
> a few different places, this can cause a soft lockup on cpus as a result
> of tasklist_lock starvation.
>
> The kernel lacks unfair writelocks, and successful calls to the oom
> killer usually result in at least one thread entering the exit path, so
> an alternative solution is needed.
>
> This patch introduces a seperate oom handler for memcgs so that they do
> not require tasklist_lock for as much time.  Instead, it iterates only
> over the threads attached to the oom memcg and grabs a reference to the
> selected thread before calling oom_kill_process() to ensure it doesn't
> prematurely exit.
>
> This still requires tasklist_lock for the tasklist dump, iterating
> children of the selected process, and killing all other threads on the
> system sharing the same memory as the selected victim.  So while this
> isn't a complete solution to tasklist_lock starvation, it significantly
> reduces the amount of time that it is held.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

This seems good. Thank you!

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>   include/linux/memcontrol.h |    9 ++-----
>   include/linux/oom.h        |   16 ++++++++++++
>   mm/memcontrol.c            |   62 +++++++++++++++++++++++++++++++++++++++++++-
>   mm/oom_kill.c              |   48 +++++++++++-----------------------
>   4 files changed, 94 insertions(+), 41 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -180,7 +180,8 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
>   unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>   						gfp_t gfp_mask,
>   						unsigned long *total_scanned);
> -u64 mem_cgroup_get_limit(struct mem_cgroup *memcg);
> +extern void __mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> +				       int order);
>
>   void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
>   #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> @@ -364,12 +365,6 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>   	return 0;
>   }
>
> -static inline
> -u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
> -{
> -	return 0;
> -}
> -
>   static inline void mem_cgroup_split_huge_fixup(struct page *head)
>   {
>   }
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -40,17 +40,33 @@ enum oom_constraint {
>   	CONSTRAINT_MEMCG,
>   };
>
> +enum oom_scan_t {
> +	OOM_SCAN_OK,
> +	OOM_SCAN_CONTINUE,
> +	OOM_SCAN_ABORT,
> +	OOM_SCAN_SELECT,
> +};
> +
>   extern void compare_swap_oom_score_adj(int old_val, int new_val);
>   extern int test_set_oom_score_adj(int new_val);
>
>   extern unsigned long oom_badness(struct task_struct *p,
>   		struct mem_cgroup *memcg, const nodemask_t *nodemask,
>   		unsigned long totalpages);
> +extern void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> +			     unsigned int points, unsigned long totalpages,
> +			     struct mem_cgroup *memcg, nodemask_t *nodemask,
> +			     const char *message);
> +
>   extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
>   extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
>
> +extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
> +		unsigned long totalpages, const nodemask_t *nodemask,
> +		bool force_kill);
>   extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>   				     int order);
> +
>   extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>   		int order, nodemask_t *mask, bool force_kill);
>   extern int register_oom_notifier(struct notifier_block *nb);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1454,7 +1454,7 @@ static int mem_cgroup_count_children(struct mem_cgroup *memcg)
>   /*
>    * Return the memory (and swap, if configured) limit for a memcg.
>    */
> -u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
> +static u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
>   {
>   	u64 limit;
>   	u64 memsw;
> @@ -1470,6 +1470,66 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
>   	return min(limit, memsw);
>   }
>
> +void __mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> +				int order)
> +{
> +	struct mem_cgroup *iter;
> +	unsigned long chosen_points = 0;
> +	unsigned long totalpages;
> +	unsigned int points = 0;
> +	struct task_struct *chosen = NULL;
> +	struct task_struct *task;
> +
> +	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
> +	for_each_mem_cgroup_tree(iter, memcg) {
> +		struct cgroup *cgroup = iter->css.cgroup;
> +		struct cgroup_iter it;
> +
> +		cgroup_iter_start(cgroup, &it);
> +		while ((task = cgroup_iter_next(cgroup, &it))) {
> +			switch (oom_scan_process_thread(task, totalpages, NULL,
> +							false)) {
> +			case OOM_SCAN_SELECT:
> +				if (chosen)
> +					put_task_struct(chosen);
> +				chosen = task;
> +				chosen_points = ULONG_MAX;
> +				get_task_struct(chosen);
> +				/* fall through */
> +			case OOM_SCAN_CONTINUE:
> +				continue;
> +			case OOM_SCAN_ABORT:
> +				cgroup_iter_end(cgroup, &it);
> +				if (chosen)
> +					put_task_struct(chosen);
> +				return;
> +			case OOM_SCAN_OK:
> +				break;
> +			};
> +			points = oom_badness(task, memcg, NULL, totalpages);
> +			if (points > chosen_points) {
> +				if (chosen)
> +					put_task_struct(chosen);
> +				chosen = task;
> +				chosen_points = points;
> +				get_task_struct(chosen);
> +			}
> +		}
> +		cgroup_iter_end(cgroup, &it);
> +		if (!memcg->use_hierarchy)
> +			break;
> +	}
> +
> +	if (!chosen)
> +		return;
> +	points = chosen_points * 1000 / totalpages;
> +	read_lock(&tasklist_lock);
> +	oom_kill_process(chosen, gfp_mask, order, points, totalpages, memcg,
> +			 NULL, "Memory cgroup out of memory");
> +	read_unlock(&tasklist_lock);
> +	put_task_struct(chosen);
> +}
> +
>   static unsigned long mem_cgroup_reclaim(struct mem_cgroup *memcg,
>   					gfp_t gfp_mask,
>   					unsigned long flags)
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -288,20 +288,13 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
>   }
>   #endif
>
> -enum oom_scan_t {
> -	OOM_SCAN_OK,
> -	OOM_SCAN_CONTINUE,
> -	OOM_SCAN_ABORT,
> -	OOM_SCAN_SELECT,
> -};
> -
> -static enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
> -		struct mem_cgroup *memcg, unsigned long totalpages,
> -		const nodemask_t *nodemask, bool force_kill)
> +enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
> +		unsigned long totalpages, const nodemask_t *nodemask,
> +		bool force_kill)
>   {
>   	if (task->exit_state)
>   		return OOM_SCAN_CONTINUE;
> -	if (oom_unkillable_task(task, memcg, nodemask))
> +	if (oom_unkillable_task(task, NULL, nodemask))
>   		return OOM_SCAN_CONTINUE;
>
>   	/*
> @@ -348,8 +341,8 @@ static enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
>    * (not docbooked, we don't want this one cluttering up the manual)
>    */
>   static struct task_struct *select_bad_process(unsigned int *ppoints,
> -		unsigned long totalpages, struct mem_cgroup *memcg,
> -		const nodemask_t *nodemask, bool force_kill)
> +		unsigned long totalpages, const nodemask_t *nodemask,
> +		bool force_kill)
>   {
>   	struct task_struct *g, *p;
>   	struct task_struct *chosen = NULL;
> @@ -358,7 +351,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>   	do_each_thread(g, p) {
>   		unsigned int points;
>
> -		switch (oom_scan_process_thread(p, memcg, totalpages, nodemask,
> +		switch (oom_scan_process_thread(p, totalpages, nodemask,
>   						force_kill)) {
>   		case OOM_SCAN_SELECT:
>   			chosen = p;
> @@ -371,7 +364,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>   		case OOM_SCAN_OK:
>   			break;
>   		};
> -		points = oom_badness(p, memcg, nodemask, totalpages);
> +		points = oom_badness(p, NULL, nodemask, totalpages);
>   		if (points > chosen_points) {
>   			chosen = p;
>   			chosen_points = points;
> @@ -442,10 +435,10 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>   }
>
>   #define K(x) ((x) << (PAGE_SHIFT-10))
> -static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> -			     unsigned int points, unsigned long totalpages,
> -			     struct mem_cgroup *memcg, nodemask_t *nodemask,
> -			     const char *message)
> +void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
> +		      unsigned int points, unsigned long totalpages,
> +		      struct mem_cgroup *memcg, nodemask_t *nodemask,
> +		      const char *message)
>   {
>   	struct task_struct *victim = p;
>   	struct task_struct *child;
> @@ -563,10 +556,6 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
>   void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>   			      int order)
>   {
> -	unsigned long limit;
> -	unsigned int points = 0;
> -	struct task_struct *p;
> -
>   	/*
>   	 * If current has a pending SIGKILL, then automatically select it.  The
>   	 * goal is to allow it to allocate so that it may quickly exit and free
> @@ -578,13 +567,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>   	}
>
>   	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
> -	limit = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
> -	read_lock(&tasklist_lock);
> -	p = select_bad_process(&points, limit, memcg, NULL, false);
> -	if (p && PTR_ERR(p) != -1UL)
> -		oom_kill_process(p, gfp_mask, order, points, limit, memcg, NULL,
> -				 "Memory cgroup out of memory");
> -	read_unlock(&tasklist_lock);
> +	__mem_cgroup_out_of_memory(memcg, gfp_mask, order);
>   }
>   #endif
>
> @@ -709,7 +692,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>   	struct task_struct *p;
>   	unsigned long totalpages;
>   	unsigned long freed = 0;
> -	unsigned int points;
> +	unsigned int uninitialized_var(points);
>   	enum oom_constraint constraint = CONSTRAINT_NONE;
>   	int killed = 0;
>
> @@ -747,8 +730,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>   		goto out;
>   	}
>
> -	p = select_bad_process(&points, totalpages, NULL, mpol_mask,
> -			       force_kill);
> +	p = select_bad_process(&points, totalpages, mpol_mask, force_kill);
>   	/* Found nothing?!?! Either we hang forever, or we panic. */
>   	if (!p) {
>   		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
