Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id A96AF6B005A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 10:32:10 -0400 (EDT)
Date: Fri, 13 Jul 2012 16:32:06 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 4/5] mm, oom: reduce dependency on tasklist_lock
Message-ID: <20120713143206.GA4511@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206291406110.6040@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206291406110.6040@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri 29-06-12 14:06:59, David Rientjes wrote:
> Since exiting tasks require write_lock_irq(&tasklist_lock) several times,
> try to reduce the amount of time the readside is held for oom kills.
> This makes the interface with the memcg oom handler more consistent since
> it now never needs to take tasklist_lock unnecessarily.
> 
> The only time the oom killer now takes tasklist_lock is when iterating
> the children of the selected task, everything else is protected by
> rcu_read_lock().
> 
> This requires that a reference to the selected process, p, is grabbed
> before calling oom_kill_process().  It may release it and grab a
> reference on another one of p's threads if !p->mm, but it also guarantees
> that it will release the reference before returning.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Sorry for the late reply I didn't get to this one sooner...

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c |    2 --
>  mm/oom_kill.c   |   40 +++++++++++++++++++++++++++++-----------
>  2 files changed, 29 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1521,10 +1521,8 @@ void __mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	if (!chosen)
>  		return;
>  	points = chosen_points * 1000 / totalpages;
> -	read_lock(&tasklist_lock);
>  	oom_kill_process(chosen, gfp_mask, order, points, totalpages, memcg,
>  			 NULL, "Memory cgroup out of memory");
> -	read_unlock(&tasklist_lock);
>  	put_task_struct(chosen);
>  }
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -336,7 +336,7 @@ enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
>  
>  /*
>   * Simple selection loop. We chose the process with the highest
> - * number of 'points'. We expect the caller will lock the tasklist.
> + * number of 'points'.
>   *
>   * (not docbooked, we don't want this one cluttering up the manual)
>   */
> @@ -348,6 +348,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  	struct task_struct *chosen = NULL;
>  	unsigned long chosen_points = 0;
>  
> +	rcu_read_lock();
>  	do_each_thread(g, p) {
>  		unsigned int points;
>  
> @@ -370,6 +371,9 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  			chosen_points = points;
>  		}
>  	} while_each_thread(g, p);
> +	if (chosen)
> +		get_task_struct(chosen);
> +	rcu_read_unlock();
>  
>  	*ppoints = chosen_points * 1000 / totalpages;
>  	return chosen;
> @@ -385,8 +389,6 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>   * are not shown.
>   * State information includes task's pid, uid, tgid, vm size, rss, cpu, oom_adj
>   * value, oom_score_adj value, and name.
> - *
> - * Call with tasklist_lock read-locked.
>   */
>  static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  {
> @@ -394,6 +396,7 @@ static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemas
>  	struct task_struct *task;
>  
>  	pr_info("[ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name\n");
> +	rcu_read_lock();
>  	for_each_process(p) {
>  		if (oom_unkillable_task(p, memcg, nodemask))
>  			continue;
> @@ -415,6 +418,7 @@ static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemas
>  			task->signal->oom_score_adj, task->comm);
>  		task_unlock(task);
>  	}
> +	rcu_read_unlock();
>  }
>  
>  static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
> @@ -435,6 +439,10 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>  }
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))
> +/*
> + * Must be called while holding a reference to p, which will be released upon
> + * returning.
> + */
>  void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		      unsigned int points, unsigned long totalpages,
>  		      struct mem_cgroup *memcg, nodemask_t *nodemask,
> @@ -454,6 +462,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	 */
>  	if (p->flags & PF_EXITING) {
>  		set_tsk_thread_flag(p, TIF_MEMDIE);
> +		put_task_struct(p);
>  		return;
>  	}
>  
> @@ -471,6 +480,7 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	 * parent.  This attempts to lose the minimal amount of work done while
>  	 * still freeing memory.
>  	 */
> +	read_lock(&tasklist_lock);
>  	do {
>  		list_for_each_entry(child, &t->children, sibling) {
>  			unsigned int child_points;
> @@ -483,15 +493,26 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			child_points = oom_badness(child, memcg, nodemask,
>  								totalpages);
>  			if (child_points > victim_points) {
> +				put_task_struct(victim);
>  				victim = child;
>  				victim_points = child_points;
> +				get_task_struct(victim);
>  			}
>  		}
>  	} while_each_thread(p, t);
> +	read_unlock(&tasklist_lock);
>  
> -	victim = find_lock_task_mm(victim);
> -	if (!victim)
> +	rcu_read_lock();
> +	p = find_lock_task_mm(victim);
> +	if (!p) {
> +		rcu_read_unlock();
> +		put_task_struct(victim);
>  		return;
> +	} else if (victim != p) {
> +		get_task_struct(p);
> +		put_task_struct(victim);
> +		victim = p;
> +	}
>  
>  	/* mm cannot safely be dereferenced after task_unlock(victim) */
>  	mm = victim->mm;
> @@ -522,9 +543,11 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  			task_unlock(p);
>  			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
>  		}
> +	rcu_read_unlock();
>  
>  	set_tsk_thread_flag(victim, TIF_MEMDIE);
>  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> +	put_task_struct(victim);
>  }
>  #undef K
>  
> @@ -545,9 +568,7 @@ static void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
>  		if (constraint != CONSTRAINT_NONE)
>  			return;
>  	}
> -	read_lock(&tasklist_lock);
>  	dump_header(NULL, gfp_mask, order, NULL, nodemask);
> -	read_unlock(&tasklist_lock);
>  	panic("Out of memory: %s panic_on_oom is enabled\n",
>  		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
>  }
> @@ -720,10 +741,10 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	mpol_mask = (constraint == CONSTRAINT_MEMORY_POLICY) ? nodemask : NULL;
>  	check_panic_on_oom(constraint, gfp_mask, order, mpol_mask);
>  
> -	read_lock(&tasklist_lock);
>  	if (sysctl_oom_kill_allocating_task &&
>  	    !oom_unkillable_task(current, NULL, nodemask) &&
>  	    current->mm) {
> +		get_task_struct(current);
>  		oom_kill_process(current, gfp_mask, order, 0, totalpages, NULL,
>  				 nodemask,
>  				 "Out of memory (oom_kill_allocating_task)");
> @@ -734,7 +755,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	/* Found nothing?!?! Either we hang forever, or we panic. */
>  	if (!p) {
>  		dump_header(NULL, gfp_mask, order, NULL, mpol_mask);
> -		read_unlock(&tasklist_lock);
>  		panic("Out of memory and no killable processes...\n");
>  	}
>  	if (PTR_ERR(p) != -1UL) {
> @@ -743,8 +763,6 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		killed = 1;
>  	}
>  out:
> -	read_unlock(&tasklist_lock);
> -
>  	/*
>  	 * Give the killed threads a good chance of exiting before trying to
>  	 * allocate memory again.

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
