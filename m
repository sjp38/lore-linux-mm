Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2CC6B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 09:03:21 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p04E3Bax014135
	for <linux-mm@kvack.org>; Tue, 4 Jan 2011 19:33:11 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p04E3A473166324
	for <linux-mm@kvack.org>; Tue, 4 Jan 2011 19:33:11 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p04E3Amx006928
	for <linux-mm@kvack.org>; Wed, 5 Jan 2011 01:03:10 +1100
Date: Tue, 4 Jan 2011 09:29:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch v3] memcg: add oom killer delay
Message-ID: <20110104035956.GA3120@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com>
 <20101221235924.b5c1aecc.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1012220031010.24462@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1012221443540.2612@chino.kir.corp.google.com>
 <20101227095225.2cf907a3.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1012272103370.27164@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1012272228350.17843@chino.kir.corp.google.com>
 <20110104104130.a3faf0d5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110104104130.a3faf0d5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2011-01-04 10:41:30]:

> On Mon, 27 Dec 2010 22:29:05 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
> 
> > Completely disabling the oom killer for a memcg is problematic if
> > userspace is unable to address the condition itself, usually because it
> > is unresponsive.  This scenario creates a memcg deadlock: tasks are
> > sitting in TASK_KILLABLE waiting for the limit to be increased, a task to
> > exit or move, or the oom killer reenabled and userspace is unable to do
> > so.
> > 
> > An additional possible use case is to defer oom killing within a memcg
> > for a set period of time, probably to prevent unnecessary kills due to
> > temporary memory spikes, before allowing the kernel to handle the
> > condition.
> > 
> > This patch adds an oom killer delay so that a memcg may be configured to
> > wait at least a pre-defined number of milliseconds before calling the oom
> > killer.  If the oom condition persists for this number of milliseconds,
> > the oom killer will be called the next time the memory controller
> > attempts to charge a page (and memory.oom_control is set to 0).  This
> > allows userspace to have a short period of time to respond to the
> > condition before deferring to the kernel to kill a task.
> > 
> > Admins may set the oom killer delay using the new interface:
> > 
> > 	# echo 60000 > memory.oom_delay_millisecs
> > 
> > This will defer oom killing to the kernel only after 60 seconds has
> > elapsed.  When setting memory.oom_delay, all pending delays have their
> > charge retried and, if necessary, the new delay is then effected.
> > 
> > The delay is cleared the first time the memcg is oom to avoid unnecessary
> > waiting when userspace is unresponsive for future oom conditions.  It may
> > be set again using the above interface to enforce a delay on the next
> > oom.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Changelog please.
> 
> 
> > ---
> >  Documentation/cgroups/memory.txt |   26 +++++++++++++++++++++
> >  mm/memcontrol.c                  |   46 ++++++++++++++++++++++++++++++++++---
> >  2 files changed, 68 insertions(+), 4 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > index 7781857..e426733 100644
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -68,6 +68,7 @@ Brief summary of control files.
> >  				 (See sysctl's vm.swappiness)
> >   memory.move_charge_at_immigrate # set/show controls of moving charges
> >   memory.oom_control		 # set/show oom controls.
> > + memory.oom_delay_millisecs	 # set/show millisecs to wait before oom kill
> >  
> >  1. History
> >  
> > @@ -640,6 +641,31 @@ At reading, current status of OOM is shown.
> >  	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
> >  				 be stopped.)
> >  
> > +It is also possible to configure an oom killer timeout to prevent the
> > +possibility that the memcg will deadlock looking for memory if userspace
> > +has disabled the oom killer with oom_control but cannot act to fix the
> > +condition itself (usually because userspace has become unresponsive).
> > +
> > +To set an oom killer timeout for a memcg, write the number of milliseconds
> > +to wait before killing a task to memory.oom_delay_millisecs:
> > +
> > +	# echo 60000 > memory.oom_delay_millisecs	# 60 seconds before kill
> > +
> > +This timeout is reset the first time the memcg is oom to prevent needlessly
> > +waiting for the next oom when userspace is truly unresponsive.  It may be
> > +set again using the above interface to defer killing a task the next time
> > +the memcg is oom.
> > +
> > +Disabling the oom killer for a memcg with memory.oom_control takes
> > +precedence over memory.oom_delay_millisecs, so it must be set to 0
> > +(default) to allow the oom kill after the delay has expired.
> > +
> > +This value is inherited from the memcg's parent on creation.
> > +
> > +There is no delay if memory.oom_delay_millisecs is set to 0 (default).
> > +This tunable's upper bound is 60 minutes.
> 
> Why upper-bounds is 60 minutes ? Do we have to have a limit ?
> Hmm, I feel 60minutes is too short. I like 32 or 31 bit limit.
>

I agree
 
> 
> > +
> > +
> >  11. TODO
> >  
> >  1. Add support for accounting huge pages (as a separate controller)
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index e6aadd6..951a22c 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -229,6 +229,8 @@ struct mem_cgroup {
> >  	unsigned int	swappiness;
> >  	/* OOM-Killer disable */
> >  	int		oom_kill_disable;
> > +	/* number of ticks to stall before calling oom killer */
> > +	int		oom_delay;
> >  
> >  	/* set when res.limit == memsw.limit */
> >  	bool		memsw_is_minimum;
> > @@ -1415,10 +1417,11 @@ static void memcg_oom_recover(struct mem_cgroup *mem)
> >  /*
> >   * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> >   */
> > -bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> > +static bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> >  {
> >  	struct oom_wait_info owait;
> >  	bool locked, need_to_kill;
> > +	long timeout = MAX_SCHEDULE_TIMEOUT;
> >  
> >  	owait.mem = mem;
> >  	owait.wait.flags = 0;
> > @@ -1437,15 +1440,21 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> >  	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> >  	if (!locked || mem->oom_kill_disable)
> >  		need_to_kill = false;
> > -	if (locked)
> > +	if (locked) {
> > +		if (mem->oom_delay) {
> > +			need_to_kill = false;
> > +			timeout = mem->oom_delay;
> > +			mem->oom_delay = 0;
> > +		}
> >  		mem_cgroup_oom_notify(mem);
> > +	}
> >  	mutex_unlock(&memcg_oom_mutex);
> >  
> >  	if (need_to_kill) {
> >  		finish_wait(&memcg_oom_waitq, &owait.wait);
> >  		mem_cgroup_out_of_memory(mem, mask);
> >  	} else {
> > -		schedule();
> > +		schedule_timeout(timeout);
> >  		finish_wait(&memcg_oom_waitq, &owait.wait);
> >  	}
> >  	mutex_lock(&memcg_oom_mutex);
> > @@ -1456,7 +1465,8 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> >  	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
> >  		return false;
> >  	/* Give chance to dying process */
> > -	schedule_timeout(1);
> > +	if (timeout != MAX_SCHEDULE_TIMEOUT)
> 
> != ?
> 
> This seems to change existing behavior.
>

Ideally it should be "==", if oom_delay was never set, we want to
schedule_timeout(1). BTW, the sched* makes me wonder by how much we
increase the ctxsw rate, but I guess in the OOM path, we should not
bother much. I'll do some testing around this.
 
> > +		schedule_timeout(1);
> >  	return true;
> >  }
> >  
> > @@ -3863,6 +3873,28 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
> >  	return 0;
> >  }
> >  
> > +static u64 mem_cgroup_oom_delay_millisecs_read(struct cgroup *cgrp,
> > +					struct cftype *cft)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	return jiffies_to_msecs(memcg->oom_delay);
> > +}
> > +
> > +static int mem_cgroup_oom_delay_millisecs_write(struct cgroup *cgrp,
> > +					struct cftype *cft, u64 val)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	/* Sanity check -- don't wait longer than an hour */
> > +	if (val > (60 * 60 * 1000))
> > +		return -EINVAL;
> > +
> > +	memcg->oom_delay = msecs_to_jiffies(val);
> > +	memcg_oom_recover(memcg);
> > +	return 0;
> > +}
> > +
> 
> Please allow this to the root of sub-hierarchy and no children....(*)
> (please check how mem_cgroup_oom_lock/unlock() works under use_hierarchy=1)
> 

Kamezawa-San, not sure if your comment is clear, are you suggesting

Since memcg is the root of a hierarchy, we need to use hierarchical
locking before changing the value of the root oom_delay?

> >  static struct cftype mem_cgroup_files[] = {
> >  	{
> >  		.name = "usage_in_bytes",
> > @@ -3926,6 +3958,11 @@ static struct cftype mem_cgroup_files[] = {
> >  		.unregister_event = mem_cgroup_oom_unregister_event,
> >  		.private = MEMFILE_PRIVATE(_OOM_TYPE, OOM_CONTROL),
> >  	},
> > +	{
> > +		.name = "oom_delay_millisecs",
> > +		.read_u64 = mem_cgroup_oom_delay_millisecs_read,
> > +		.write_u64 = mem_cgroup_oom_delay_millisecs_write,
> > +	},
> >  };
> >  
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > @@ -4164,6 +4201,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  		parent = mem_cgroup_from_cont(cont->parent);
> >  		mem->use_hierarchy = parent->use_hierarchy;
> >  		mem->oom_kill_disable = parent->oom_kill_disable;
> > +		mem->oom_delay = parent->oom_delay;
> 
> Becasue of (*), oom_kill_disable can be copied here.
> If you want to inherit this, you should do (*) or update all hierarchy value.
>

Not sure I understand this either. I would ideally like to see these
copied if use_hierarchy is set.
 
> 
> Thanks,
> -Kame
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
