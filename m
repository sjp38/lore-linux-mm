Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 185306B005A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 10:34:25 -0400 (EDT)
Date: Fri, 13 Jul 2012 16:34:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 5/5] mm, memcg: move all oom handling to memcontrol.c
Message-ID: <20120713143422.GB4511@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206291406270.6040@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206291406270.6040@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

[Sorry for the late reply]

On Fri 29-06-12 14:07:01, David Rientjes wrote:
> By globally defining check_panic_on_oom(), the memcg oom handler can be
> moved entirely to mm/memcontrol.c.  This removes the ugly #ifdef in the
> oom killer and cleans up the code.
> 
> Signed-off-by: David Rientjes <rientjes@google.com> 

Yes, I like it.
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/memcontrol.h |    2 --
>  include/linux/oom.h        |    3 +++
>  mm/memcontrol.c            |   15 +++++++++++++--
>  mm/oom_kill.c              |   23 ++---------------------
>  4 files changed, 18 insertions(+), 25 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -180,8 +180,6 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask,
>  						unsigned long *total_scanned);
> -extern void __mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> -				       int order);
>  
>  void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -61,6 +61,9 @@ extern void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
>  extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
>  
> +extern void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
> +			       int order, const nodemask_t *nodemask);
> +
>  extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
>  		unsigned long totalpages, const nodemask_t *nodemask,
>  		bool force_kill);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1469,8 +1469,8 @@ static u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
>  	return min(limit, memsw);
>  }
>  
> -void __mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> -				int order)
> +void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> +			      int order)
>  {
>  	struct mem_cgroup *iter;
>  	unsigned long chosen_points = 0;
> @@ -1478,6 +1478,17 @@ void __mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	unsigned int points = 0;
>  	struct task_struct *chosen = NULL;
>  
> +	/*
> +	 * If current has a pending SIGKILL, then automatically select it.  The
> +	 * goal is to allow it to allocate so that it may quickly exit and free
> +	 * its memory.
> +	 */
> +	if (fatal_signal_pending(current)) {
> +		set_thread_flag(TIF_MEMDIE);
> +		return;
> +	}
> +
> +	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
>  	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
>  	for_each_mem_cgroup_tree(iter, memcg) {
>  		struct cgroup *cgroup = iter->css.cgroup;
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -554,8 +554,8 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  /*
>   * Determines whether the kernel must panic because of the panic_on_oom sysctl.
>   */
> -static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
> -				int order, const nodemask_t *nodemask)
> +void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
> +			int order, const nodemask_t *nodemask)
>  {
>  	if (likely(!sysctl_panic_on_oom))
>  		return;
> @@ -573,25 +573,6 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
>  		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
>  }
>  
> -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
> -void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
> -			      int order)
> -{
> -	/*
> -	 * If current has a pending SIGKILL, then automatically select it.  The
> -	 * goal is to allow it to allocate so that it may quickly exit and free
> -	 * its memory.
> -	 */
> -	if (fatal_signal_pending(current)) {
> -		set_thread_flag(TIF_MEMDIE);
> -		return;
> -	}
> -
> -	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
> -	__mem_cgroup_out_of_memory(memcg, gfp_mask, order);
> -}
> -#endif
> -
>  static BLOCKING_NOTIFIER_HEAD(oom_notify_list);
>  
>  int register_oom_notifier(struct notifier_block *nb)

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
