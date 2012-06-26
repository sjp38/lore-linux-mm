Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id EC0196B00C4
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:48:27 -0400 (EDT)
Date: Tue, 26 Jun 2012 10:48:24 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [rfc][patch 2/3] mm, oom: introduce helper function to process
 threads during scan
Message-ID: <20120626084824.GB9566@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1206251846450.24838@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206251846450.24838@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 25-06-12 18:47:49, David Rientjes wrote:
> This patch introduces a helper function to process each thread during the
> iteration over the tasklist.  A new return type, enum oom_scan_t, is
> defined to determine the future behavior of the iteration:
> 
>  - OOM_SCAN_OK: continue scanning the thread and find its badness,
> 
>  - OOM_SCAN_CONTINUE: do not consider this thread for oom kill, it's
>    ineligible,
> 
>  - OOM_SCAN_ABORT: abort the iteration and return, or
> 
>  - OOM_SCAN_SELECT: always select this thread with the highest badness
>    possible.

I like it but could you add this as a doc for the enum?

> There is no functional change with this patch.  This new helper function
> will be used in the next patch in the memory controller.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/oom_kill.c |  111 +++++++++++++++++++++++++++++++++------------------------
>  1 file changed, 65 insertions(+), 46 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -288,6 +288,59 @@ static enum oom_constraint constrained_alloc(struct zonelist *zonelist,
>  }
>  #endif
>  
> +enum oom_scan_t {
> +	OOM_SCAN_OK,
> +	OOM_SCAN_CONTINUE,
> +	OOM_SCAN_ABORT,
> +	OOM_SCAN_SELECT,
> +};
> +
> +static enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
> +		struct mem_cgroup *memcg, unsigned long totalpages,
> +		const nodemask_t *nodemask, bool force_kill)
> +{
> +	if (task->exit_state)
> +		return OOM_SCAN_CONTINUE;
> +	if (oom_unkillable_task(task, memcg, nodemask))
> +		return OOM_SCAN_CONTINUE;
> +
> +	/*
> +	 * This task already has access to memory reserves and is being killed.
> +	 * Don't allow any other task to have access to the reserves.
> +	 */
> +	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> +		if (unlikely(frozen(task)))
> +			__thaw_task(task);
> +		if (!force_kill)
> +			return OOM_SCAN_ABORT;
> +	}
> +	if (!task->mm)
> +		return OOM_SCAN_CONTINUE;
> +
> +	if (task->flags & PF_EXITING) {
> +		/*
> +		 * If task is current and is in the process of releasing memory,
> +		 * allow the "kill" to set TIF_MEMDIE, which will allow it to
> +		 * access memory reserves.  Otherwise, it may stall forever.
> +		 *
> +		 * The iteration isn't broken here, however, in case other
> +		 * threads are found to have already been oom killed.
> +		 */
> +		if (task == current)
> +			return OOM_SCAN_SELECT;
> +		else if (!force_kill) {
> +			/*
> +			 * If this task is not being ptraced on exit, then wait
> +			 * for it to finish before killing some other task
> +			 * unnecessarily.
> +			 */
> +			if (!(task->group_leader->ptrace & PT_TRACE_EXIT))
> +				return OOM_SCAN_ABORT;
> +		}
> +	}
> +	return OOM_SCAN_OK;
> +}
> +
>  /*
>   * Simple selection loop. We chose the process with the highest
>   * number of 'points'. We expect the caller will lock the tasklist.
> @@ -305,53 +358,19 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  	do_each_thread(g, p) {
>  		unsigned int points;
>  
> -		if (p->exit_state)
> -			continue;
> -		if (oom_unkillable_task(p, memcg, nodemask))
> -			continue;
> -
> -		/*
> -		 * This task already has access to memory reserves and is
> -		 * being killed. Don't allow any other task access to the
> -		 * memory reserve.
> -		 *
> -		 * Note: this may have a chance of deadlock if it gets
> -		 * blocked waiting for another task which itself is waiting
> -		 * for memory. Is there a better alternative?
> -		 */
> -		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
> -			if (unlikely(frozen(p)))
> -				__thaw_task(p);
> -			if (!force_kill)
> -				return ERR_PTR(-1UL);
> -		}
> -		if (!p->mm)
> +		switch (oom_scan_process_thread(p, memcg, totalpages, nodemask,
> +						force_kill)) {
> +		case OOM_SCAN_SELECT:
> +			chosen = p;
> +			chosen_points = ULONG_MAX;
> +			/* fall through */
> +		case OOM_SCAN_CONTINUE:
>  			continue;
> -
> -		if (p->flags & PF_EXITING) {
> -			/*
> -			 * If p is the current task and is in the process of
> -			 * releasing memory, we allow the "kill" to set
> -			 * TIF_MEMDIE, which will allow it to gain access to
> -			 * memory reserves.  Otherwise, it may stall forever.
> -			 *
> -			 * The loop isn't broken here, however, in case other
> -			 * threads are found to have already been oom killed.
> -			 */
> -			if (p == current) {
> -				chosen = p;
> -				chosen_points = ULONG_MAX;
> -			} else if (!force_kill) {
> -				/*
> -				 * If this task is not being ptraced on exit,
> -				 * then wait for it to finish before killing
> -				 * some other task unnecessarily.
> -				 */
> -				if (!(p->group_leader->ptrace & PT_TRACE_EXIT))
> -					return ERR_PTR(-1UL);
> -			}
> -		}
> -
> +		case OOM_SCAN_ABORT:
> +			return ERR_PTR(-1UL);
> +		case OOM_SCAN_OK:
> +			break;
> +		};
>  		points = oom_badness(p, memcg, nodemask, totalpages);
>  		if (points > chosen_points) {
>  			chosen = p;
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

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
