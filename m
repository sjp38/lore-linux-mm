Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CAD736B0098
	for <linux-mm@kvack.org>; Sat, 25 Dec 2010 14:33:49 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp03.in.ibm.com (8.14.4/8.13.1) with ESMTP id oBPJXgov007285
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 01:03:42 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBPJXgch4255818
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 01:03:42 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBPJXgWP012513
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 06:33:42 +1100
Date: Sat, 25 Dec 2010 16:17:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-ID: <20101225104713.GC4763@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com> [2010-12-21 23:27:25]:

> Completely disabling the oom killer for a memcg is problematic if
> userspace is unable to address the condition itself, usually because
> userspace is unresponsive.  This scenario creates a memcg livelock:
> tasks are continuously trying to allocate memory and nothing is getting
> killed, so memory freeing is impossible since reclaim has failed, and
> all work stalls with no remedy in sight.
> 
> This patch adds an oom killer delay so that a memcg may be configured to
> wait at least a pre-defined number of milliseconds before calling the
> oom killer.  If the oom condition persists for this number of
> milliseconds, the oom killer will be called the next time the memory
> controller attempts to charge a page (and memory.oom_control is set to
> 0).  This allows userspace to have a short period of time to respond to
> the condition before timing out and deferring to the kernel to kill a
> task.
> 
> Admins may set the oom killer timeout using the new interface:
> 
> 	# echo 60000 > memory.oom_delay
> 
> This will defer oom killing to the kernel only after 60 seconds has
> elapsed.  When setting memory.oom_delay, all pending timeouts are
> restarted.

I think Paul mentioned this problem and solution (I think already in
use at google) some time back. Is x miliseconds a per oom kill decision
timer or is it global?

> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Documentation/cgroups/memory.txt |   15 ++++++++++
>  mm/memcontrol.c                  |   56 +++++++++++++++++++++++++++++++++----
>  2 files changed, 65 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -68,6 +68,7 @@ Brief summary of control files.
>  				 (See sysctl's vm.swappiness)
>   memory.move_charge_at_immigrate # set/show controls of moving charges
>   memory.oom_control		 # set/show oom controls.
> + memory.oom_delay		 # set/show millisecs to wait before oom kill
> 
>  1. History
> 
> @@ -640,6 +641,20 @@ At reading, current status of OOM is shown.
>  	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
>  				 be stopped.)
> 
> +It is also possible to configure an oom killer timeout to prevent the
> +possibility that the memcg will livelock looking for memory if userspace
> +has disabled the oom killer with oom_control but cannot act to fix the
> +condition itself (usually because userspace has become unresponsive).
> +
> +To set an oom killer timeout for a memcg, write the number of milliseconds
> +to wait before killing a task to memory.oom_delay:
> +
> +	# echo 60000 > memory.oom_delay	# wait 60 seconds, then oom kill
> +
> +This timeout is reset the next time the memcg successfully charges memory
> +to a task.
> +
> +
>  11. TODO
> 
>  1. Add support for accounting huge pages (as a separate controller)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -233,12 +233,16 @@ struct mem_cgroup {
>  	 * Should the accounting and control be hierarchical, per subtree?
>  	 */
>  	bool use_hierarchy;
> +	/* oom_delay has expired and still out of memory? */
> +	bool oom_kill_delay_expired;
>  	atomic_t	oom_lock;
>  	atomic_t	refcnt;
> 
>  	unsigned int	swappiness;
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
> +	/* min number of ticks to wait before calling oom killer */
> +	int		oom_kill_delay;
> 
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
> @@ -1524,6 +1528,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *mem)
> 
>  static void memcg_oom_recover(struct mem_cgroup *mem)
>  {
> +	mem->oom_kill_delay_expired = false;
>  	if (mem && atomic_read(&mem->oom_lock))
>  		memcg_wakeup_oom(mem);
>  }
> @@ -1531,17 +1536,18 @@ static void memcg_oom_recover(struct mem_cgroup *mem)
>  /*
>   * try to call OOM killer. returns false if we should exit memory-reclaim loop.
>   */
> -bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> +static bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>  {
>  	struct oom_wait_info owait;
> -	bool locked, need_to_kill;
> +	bool locked;
> +	bool need_to_kill = true;
> +	bool need_to_delay = false;
> 
>  	owait.mem = mem;
>  	owait.wait.flags = 0;
>  	owait.wait.func = memcg_oom_wake_function;
>  	owait.wait.private = current;
>  	INIT_LIST_HEAD(&owait.wait.task_list);
> -	need_to_kill = true;
>  	/* At first, try to OOM lock hierarchy under mem.*/
>  	mutex_lock(&memcg_oom_mutex);
>  	locked = mem_cgroup_oom_lock(mem);
> @@ -1553,26 +1559,34 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>  	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
>  	if (!locked || mem->oom_kill_disable)
>  		need_to_kill = false;
> -	if (locked)
> +	if (locked) {
>  		mem_cgroup_oom_notify(mem);
> +		if (mem->oom_kill_delay && !mem->oom_kill_delay_expired) {
> +			need_to_kill = false;
> +			need_to_delay = true;
> +		}
> +	}
>  	mutex_unlock(&memcg_oom_mutex);
> 
>  	if (need_to_kill) {
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
>  		mem_cgroup_out_of_memory(mem, mask);
>  	} else {
> -		schedule();
> +		schedule_timeout(need_to_delay ? mem->oom_kill_delay :
> +						 MAX_SCHEDULE_TIMEOUT);
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
>  	}
>  	mutex_lock(&memcg_oom_mutex);
>  	mem_cgroup_oom_unlock(mem);
>  	memcg_wakeup_oom(mem);
> +	mem->oom_kill_delay_expired = need_to_delay;
>  	mutex_unlock(&memcg_oom_mutex);
> 
>  	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
>  		return false;
>  	/* Give chance to dying process */
> -	schedule_timeout(1);
> +	if (!need_to_delay)
> +		schedule_timeout(1);
>  	return true;
>  }

I think we need additional statistics for tracking oom kills due to
timer expiry.


> 
> @@ -2007,6 +2021,7 @@ again:
>  		refill_stock(mem, csize - PAGE_SIZE);
>  	css_put(&mem->css);
>  done:
> +	mem->oom_kill_delay_expired = false;
>  	*memcg = mem;
>  	return 0;
>  nomem:
> @@ -4053,6 +4068,29 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>  	return 0;
>  }
> 
> +static u64 mem_cgroup_oom_delay_read(struct cgroup *cgrp, struct cftype *cft)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +
> +	return jiffies_to_msecs(memcg->oom_kill_delay);
> +}
> +
> +static int mem_cgroup_oom_delay_write(struct cgroup *cgrp, struct cftype *cft,
> +				      u64 val)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +
> +	/* Sanity check -- don't wait longer than an hour */
> +	if (val > (60 * 60 * 1000))
> +		return -EINVAL;

Why do this and not document it? These sort of things get exremely
confusing. I would prefer not to have it without a resonable use case
or very good documentation, explaining why we need an upper bound.

> +
> +	cgroup_lock();
> +	memcg->oom_kill_delay = msecs_to_jiffies(val);
> +	memcg_oom_recover(memcg);
> +	cgroup_unlock();
> +	return 0;
> +}
> +
>  static struct cftype mem_cgroup_files[] = {
>  	{
>  		.name = "usage_in_bytes",
> @@ -4116,6 +4154,11 @@ static struct cftype mem_cgroup_files[] = {
>  		.unregister_event = mem_cgroup_oom_unregister_event,
>  		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
>  	},
> +	{
> +		.name = "oom_delay",
> +		.read_u64 = mem_cgroup_oom_delay_read,
> +		.write_u64 = mem_cgroup_oom_delay_write,
> +	},
>  };
> 
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> @@ -4357,6 +4400,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		mem->use_hierarchy = parent->use_hierarchy;
>  		mem->oom_kill_disable = parent->oom_kill_disable;
> +		mem->oom_kill_delay = parent->oom_kill_delay;
>  	}
> 
>  	if (parent && parent->use_hierarchy) {

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
