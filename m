Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 127786B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 07:27:42 -0500 (EST)
Date: Fri, 26 Feb 2010 21:30:15 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [RFC][PATCH 1/2] memcg: oom kill handling improvement
Message-Id: <20100226213015.e099478e.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20100226161752.32e5350d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100224165921.cb091a4f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100226131552.07475f9c.nishimura@mxp.nes.nec.co.jp>
	<20100226142339.7a67f1a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20100226144752.19734ff0.nishimura@mxp.nes.nec.co.jp>
	<20100226161752.32e5350d.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 26 Feb 2010 16:17:52 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 26 Feb 2010 14:47:52 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Fri, 26 Feb 2010 14:23:39 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > > > > 1st patch is for better handling oom-kill under memcg.
> > > > It's bigger than I expected, but it basically looks good to me.
> > > > 
> > > 
> > > BTW, do you think we need quick fix ? I can't think of a very easy/small fix
> > > which is very correct...
> > To be honest, yes.
> 
> Okay. following is a candidate we can have. This will be incomplete until
> we have oom notifier for memcg but may be better than miss-firing
> page_fault_out_of_memory. Nishimura-san, how do you think this ?
> (Added Andrew to CC.)
> 
Thank you very much for your patch.
I agree it's enough for quick fix, and it seems to work.

> ==
> 
> From: KAMEZAWA Hiroyuk <kamezawa.hiroyu@jp.fujitsu.com>
> 
> In current page-fault code,
> 
> 	handle_mm_fault()
> 		-> ...
> 		-> mem_cgroup_charge()
> 		-> map page or handle error.
> 	-> check return code.
> 
> If page fault's return code is VM_FAULT_OOM, page_fault_out_of_memory()
> is called. But if it's caused by memcg, OOM should have been already
> invoked.
> Then, I added a patch: a636b327f731143ccc544b966cfd8de6cb6d72c6
> 
> That patch records last_oom_jiffies for memcg's sub-hierarchy and
> prevents page_fault_out_of_memory from being invoked in near future.
> 
> But Nishimura-san reported that check by jiffies is not enough
> when the system is terribly heavy. 
> 
> This patch changes memcg's oom logic as.
>  * If memcg causes OOM-kill, continue to retry.
>  * memcg hangs when there are no task to be killed.
IIUC, this behavior is the same as current behavior. mem_cgroup_out_of_memory()
hangs if all of the tasks in the cgroup are OOM_DISABLE'ed.

>  * remove jiffies check which is used now.
> 
> TODO:
>  * add oom notifier for informing management daemon.
>  * more clever sleep logic for avoiding to use much CPU.
> 
> Signed-off-by: KAMEZAWA Hiroyuk <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memcontrol.h |    6 ----
>  mm/memcontrol.c            |   56 ++++++++++++++++-----------------------------
>  mm/oom_kill.c              |   28 ++++++++++++----------
>  3 files changed, 37 insertions(+), 53 deletions(-)
> 
> Index: mmotm-2.6.33-Feb11/include/linux/memcontrol.h
> ===================================================================
> --- mmotm-2.6.33-Feb11.orig/include/linux/memcontrol.h
> +++ mmotm-2.6.33-Feb11/include/linux/memcontrol.h
> @@ -124,7 +124,6 @@ static inline bool mem_cgroup_disabled(v
>  	return false;
>  }
>  
> -extern bool mem_cgroup_oom_called(struct task_struct *task);
>  void mem_cgroup_update_file_mapped(struct page *page, int val);
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask, int nid,
> @@ -258,11 +257,6 @@ static inline bool mem_cgroup_disabled(v
>  	return true;
>  }
>  
> -static inline bool mem_cgroup_oom_called(struct task_struct *task)
> -{
> -	return false;
> -}
> -
>  static inline int
>  mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
>  {
> Index: mmotm-2.6.33-Feb11/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.33-Feb11.orig/mm/memcontrol.c
> +++ mmotm-2.6.33-Feb11/mm/memcontrol.c
> @@ -200,7 +200,6 @@ struct mem_cgroup {
>  	 * Should the accounting and control be hierarchical, per subtree?
>  	 */
>  	bool use_hierarchy;
> -	unsigned long	last_oom_jiffies;
>  	atomic_t	refcnt;
>  
>  	unsigned int	swappiness;
> @@ -1234,34 +1233,6 @@ static int mem_cgroup_hierarchical_recla
>  	return total;
>  }
>  
> -bool mem_cgroup_oom_called(struct task_struct *task)
> -{
> -	bool ret = false;
> -	struct mem_cgroup *mem;
> -	struct mm_struct *mm;
> -
> -	rcu_read_lock();
> -	mm = task->mm;
> -	if (!mm)
> -		mm = &init_mm;
> -	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> -	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
> -		ret = true;
> -	rcu_read_unlock();
> -	return ret;
> -}
> -
> -static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
> -{
> -	mem->last_oom_jiffies = jiffies;
> -	return 0;
> -}
> -
> -static void record_last_oom(struct mem_cgroup *mem)
> -{
> -	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
> -}
> -
>  /*
>   * Currently used to update mapped file statistics, but the routine can be
>   * generalized to update other statistics as well.
> @@ -1549,11 +1520,27 @@ static int __mem_cgroup_try_charge(struc
>  		}
>  
>  		if (!nr_retries--) {
> -			if (oom) {
> -				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
> -				record_last_oom(mem_over_limit);
> +			if (!oom)
> +				goto nomem;
> +			mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
> +			/*
> +			 * If killed someone, we can retry. If killed myself,
> +			 * allow to go ahead in force.
> +			 *
> +			 * Note: There may be a case we can never kill any
> +			 * processes under us.(by OOM_DISABLE) But, in that
> +			 * case, if we return -ENOMEM, pagefault_out_of_memory
> +			 * will kill someone innocent, out of this memcg.
> +			 * So, what we can do is just try harder..
> +			 */
> +			if (test_thread_flag(TIF_MEMDIE)) {
Is "if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))" better
to accept SIGKILL ?

> +				css_put(&mem->css);
> +				*memcg = NULL;
> +				return 0;
>  			}
> -			goto nomem;
> +			/* give chance to run */
> +			schedule_timeout(1);
> +			nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>  		}
>  	}
>  	if (csize > PAGE_SIZE)
> @@ -2408,8 +2395,7 @@ void mem_cgroup_end_migration(struct mem
>  
>  /*
>   * A call to try to shrink memory usage on charge failure at shmem's swapin.
> - * Calling hierarchical_reclaim is not enough because we should update
> - * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global OOM.
> + * Calling hierarchical_reclaim is not enough. We may have to call OOM.
>   * Moreover considering hierarchy, we should reclaim from the mem_over_limit,
>   * not from the memcg which this page would be charged to.
>   * try_charge_swapin does all of these works properly.
> Index: mmotm-2.6.33-Feb11/mm/oom_kill.c
> ===================================================================
> --- mmotm-2.6.33-Feb11.orig/mm/oom_kill.c
> +++ mmotm-2.6.33-Feb11/mm/oom_kill.c
> @@ -466,27 +466,39 @@ static int oom_kill_process(struct task_
>  }
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR
> +/*
> + * When select_bad_process() can't find proper process and we failed to
> + * kill current, returns 0 as faiulre of OOM-kill. Otherwise, returns 1.
> + */
hmm, what function does this comment describe ?
mem_cgroup_out_of_memory() returns void.


Thanks,
Daisuke Nishimura.

>  void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>  {
>  	unsigned long points = 0;
>  	struct task_struct *p;
> +	int not_found = 0;
>  
>  	if (sysctl_panic_on_oom == 2)
>  		panic("out of memory(memcg). panic_on_oom is selected.\n");
>  	read_lock(&tasklist_lock);
>  retry:
> +	not_found = 0;
>  	p = select_bad_process(&points, mem);
>  	if (PTR_ERR(p) == -1UL)
>  		goto out;
> -
> -	if (!p)
> +	if (!p) {
> +		not_found = 1;
>  		p = current;
> +		printk(KERN_ERR "It seems there are no killable processes "
> +			"under memcg in OOM. Try to kill current\n");
> +	}
>  
>  	if (oom_kill_process(p, gfp_mask, 0, points, mem,
> -				"Memory cgroup out of memory"))
> -		goto retry;
> +				"Memory cgroup out of memory")) {
> +		if (!not_found) /* some race with OOM_DISABLE etc ? */
> +			goto retry;
> +	}
>  out:
>  	read_unlock(&tasklist_lock);
> +	/* Even if we don't kill any, give chance to try to recalim more */
>  }
>  #endif
>  
> @@ -601,13 +613,6 @@ void pagefault_out_of_memory(void)
>  		/* Got some memory back in the last second. */
>  		return;
>  
> -	/*
> -	 * If this is from memcg, oom-killer is already invoked.
> -	 * and not worth to go system-wide-oom.
> -	 */
> -	if (mem_cgroup_oom_called(current))
> -		goto rest_and_return;
> -
>  	if (sysctl_panic_on_oom)
>  		panic("out of memory from page fault. panic_on_oom is selected.\n");
>  
> @@ -619,7 +624,6 @@ void pagefault_out_of_memory(void)
>  	 * Give "p" a good chance of killing itself before we
>  	 * retry to allocate memory.
>  	 */
> -rest_and_return:
>  	if (!test_thread_flag(TIF_MEMDIE))
>  		schedule_timeout_uninterruptible(1);
>  }
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
