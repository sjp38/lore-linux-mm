Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6DF158D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 19:10:42 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 07BC93EE0C0
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:10:39 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CE0A445DE71
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:10:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D3FB545DE66
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:10:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C7D1FE1800A
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:10:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 89404E18003
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:10:36 +0900 (JST)
Date: Thu, 10 Feb 2011 09:04:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: add oom killer delay
Message-Id: <20110210090428.6c8a7c21.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1102071623040.10488@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1102091417410.5697@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org

On Wed, 9 Feb 2011 14:19:50 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> Completely disabling the oom killer for a memcg is problematic if
> userspace is unable to address the condition itself, usually because it
> is unresponsive.  This scenario creates a memcg deadlock: tasks are
> sitting in TASK_KILLABLE waiting for the limit to be increased, a task to
> exit or move, or the oom killer reenabled and userspace is unable to do
> so.
> 
> An additional possible use case is to defer oom killing within a memcg
> for a set period of time, probably to prevent unnecessary kills due to
> temporary memory spikes, before allowing the kernel to handle the
> condition.
> 
> This patch adds an oom killer delay so that a memcg may be configured to
> wait at least a pre-defined number of milliseconds before calling the oom
> killer.  If the oom condition persists for this number of milliseconds,
> the oom killer will be called the next time the memory controller
> attempts to charge a page (and memory.oom_control is set to 0).  This
> allows userspace to have a short period of time to respond to the
> condition before deferring to the kernel to kill a task.
> 
> Admins may set the oom killer delay using the new interface:
> 
> 	# echo 60000 > memory.oom_delay_millisecs
> 
> This will defer oom killing to the kernel only after 60 seconds has
> elapsed by putting the task to sleep for 60 seconds.  When setting
> memory.oom_delay_millisecs, all pending delays have their charges retried
> and, if necessary, the new delay is then enforced.
> 
> The delay is cleared the first time the memcg is oom to avoid unnecessary
> waiting when userspace is unresponsive for future oom conditions.  It may
> be set again using the above interface to enforce a delay on the next
> oom.
> 
> When a memory.oom_delay_millisecs is set for a cgroup, it is propagated
> to all children memcg as well and is inherited when a new memcg is
> created.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hm. But I'm not sure how this will be used.


> ---
>  Documentation/cgroups/memory.txt |   32 +++++++++++++++++++++++++
>  mm/memcontrol.c                  |   48 ++++++++++++++++++++++++++++++++++---
>  2 files changed, 76 insertions(+), 4 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -68,6 +68,7 @@ Brief summary of control files.
>  				 (See sysctl's vm.swappiness)
>   memory.move_charge_at_immigrate # set/show controls of moving charges
>   memory.oom_control		 # set/show oom controls.
> + memory.oom_delay_millisecs	 # set/show millisecs to wait before oom kill
>  
>  1. History
>  
> @@ -640,6 +641,37 @@ At reading, current status of OOM is shown.
>  	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
>  				 be stopped.)
>  
> +It is also possible to configure an oom killer timeout to prevent the
> +possibility that the memcg will deadlock looking for memory if userspace
> +has disabled the oom killer with oom_control but cannot act to fix the
> +condition itself (usually because userspace has become unresponsive).
> +
> +To set an oom killer timeout for a memcg, write the number of milliseconds
> +to wait before killing a task to memory.oom_delay_millisecs:
> +
> +	# echo 60000 > memory.oom_delay_millisecs	# 60 seconds before kill
> +
> +When this memcg is oom, it is guaranteed that this delay will be incurred
> +before the kernel kills a task.  The task chosen may either be from this
> +memcg or its child memcgs, if any.
> +
> +This timeout is reset the first time the memcg is oom to prevent needlessly
> +waiting for the next oom when userspace is truly unresponsive.  It may be
> +set again using the above interface to defer killing a task the next time
> +the memcg is oom.
> +
> +Disabling the oom killer for a memcg with memory.oom_control takes
> +precedence over memory.oom_delay_millisecs, so it must be set to 0
> +(default) to allow the oom kill after the delay has expired.
> +
> +This value is inherited from the memcg's parent on creation.  Setting a
> +delay for a memcg sets the same delay for all children, as well.
> +
> +There is no delay if memory.oom_delay_millisecs is set to 0 (default).
> +This tunable's upper bound is MAX_SCHEDULE_TIMEOUT (about 24 days on
> +32-bit and a lifetime on 64-bit).
> +
> +
>  11. TODO
>  
>  1. Add support for accounting huge pages (as a separate controller)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -239,6 +239,8 @@ struct mem_cgroup {
>  	unsigned int	swappiness;
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
> +	/* number of ticks to stall before calling oom killer */
> +	int		oom_delay;
>  
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
> @@ -1541,10 +1543,11 @@ static void memcg_oom_recover(struct mem_cgroup *mem)
>  /*
>   * try to call OOM killer. returns false if we should exit memory-reclaim loop.
>   */
> -bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> +static bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>  {
>  	struct oom_wait_info owait;
>  	bool locked, need_to_kill;
> +	long timeout = MAX_SCHEDULE_TIMEOUT;
>  
>  	owait.mem = mem;
>  	owait.wait.flags = 0;
> @@ -1563,15 +1566,21 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>  	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
>  	if (!locked || mem->oom_kill_disable)
>  		need_to_kill = false;
> -	if (locked)
> +	if (locked) {
> +		if (mem->oom_delay) {
> +			need_to_kill = false;
> +			timeout = mem->oom_delay;
> +			mem->oom_delay = 0;
> +		}
>  		mem_cgroup_oom_notify(mem);
> +	}
>  	mutex_unlock(&memcg_oom_mutex);
>  
>  	if (need_to_kill) {
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
>  		mem_cgroup_out_of_memory(mem, mask);
>  	} else {
> -		schedule();
> +		schedule_timeout(timeout);
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
>  	}
>  	mutex_lock(&memcg_oom_mutex);
> @@ -1582,7 +1591,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>  	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
>  		return false;
>  	/* Give chance to dying process */
> -	schedule_timeout(1);
> +	if (timeout == MAX_SCHEDULE_TIMEOUT)
> +		schedule_timeout(1);
>  	return true;
>  }
>  
> @@ -4168,6 +4178,30 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>  	return 0;
>  }
>  
> +static u64 mem_cgroup_oom_delay_millisecs_read(struct cgroup *cgrp,
> +					struct cftype *cft)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +
> +	return jiffies_to_msecs(memcg->oom_delay);
> +}
> +
> +static int mem_cgroup_oom_delay_millisecs_write(struct cgroup *cgrp,
> +					struct cftype *cft, u64 val)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +	struct mem_cgroup *iter;
> +
> +	if (val > MAX_SCHEDULE_TIMEOUT)
> +		return -EINVAL;
> +
> +	for_each_mem_cgroup_tree(iter, memcg) {
> +		iter->oom_delay = msecs_to_jiffies(val);
> +		memcg_oom_recover(iter);
> +	}
> +	return 0;
> +}
> +
>  static struct cftype mem_cgroup_files[] = {
>  	{
>  		.name = "usage_in_bytes",
> @@ -4231,6 +4265,11 @@ static struct cftype mem_cgroup_files[] = {
>  		.unregister_event = mem_cgroup_oom_unregister_event,
>  		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
>  	},
> +	{
> +		.name = "oom_delay_millisecs",
> +		.read_u64 = mem_cgroup_oom_delay_millisecs_read,
> +		.write_u64 = mem_cgroup_oom_delay_millisecs_write,
> +	},
>  };
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> @@ -4469,6 +4508,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		mem->use_hierarchy = parent->use_hierarchy;
>  		mem->oom_kill_disable = parent->oom_kill_disable;
> +		mem->oom_delay = parent->oom_delay;
>  	}
>  
>  	if (parent && parent->use_hierarchy) {
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
