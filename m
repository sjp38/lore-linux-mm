Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B485E6B00A0
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 15:35:28 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id oBQKZPh8022464
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 12:35:25 -0800
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by hpaq11.eem.corp.google.com with ESMTP id oBQKZLZG028709
	for <linux-mm@kvack.org>; Sun, 26 Dec 2010 12:35:23 -0800
Received: by pvg7 with SMTP id 7so2510219pvg.22
        for <linux-mm@kvack.org>; Sun, 26 Dec 2010 12:35:21 -0800 (PST)
Date: Sun, 26 Dec 2010 12:35:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20101225104713.GC4763@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1012261225340.3107@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com> <20101225104713.GC4763@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Dec 2010, Balbir Singh wrote:

> > Completely disabling the oom killer for a memcg is problematic if
> > userspace is unable to address the condition itself, usually because
> > userspace is unresponsive.  This scenario creates a memcg livelock:
> > tasks are continuously trying to allocate memory and nothing is getting
> > killed, so memory freeing is impossible since reclaim has failed, and
> > all work stalls with no remedy in sight.
> > 
> > This patch adds an oom killer delay so that a memcg may be configured to
> > wait at least a pre-defined number of milliseconds before calling the
> > oom killer.  If the oom condition persists for this number of
> > milliseconds, the oom killer will be called the next time the memory
> > controller attempts to charge a page (and memory.oom_control is set to
> > 0).  This allows userspace to have a short period of time to respond to
> > the condition before timing out and deferring to the kernel to kill a
> > task.
> > 
> > Admins may set the oom killer timeout using the new interface:
> > 
> > 	# echo 60000 > memory.oom_delay
> > 
> > This will defer oom killing to the kernel only after 60 seconds has
> > elapsed.  When setting memory.oom_delay, all pending timeouts are
> > restarted.
> 
> I think Paul mentioned this problem and solution (I think already in
> use at google) some time back. Is x miliseconds a per oom kill decision
> timer or is it global?
> 

It's global for that memcg and works for all oom kills in that memcg until 
changed by userspace.  The example given in the changelog of 60 seconds 
would be for a use-case where we're only concerned about deadlock because 
nothing can allocate memory, the oom killer is disabled, and userspace 
fails to act for whatever reason.  It's necessary because of how memcg 
handles oom disabling compared to OOM_DISABLE: if al tasks are OOM_DISABLE 
for a system-wide oom then the machine panics whereas memcg will simply 
deadlock for memory.oom_control == 0.

 [ Your email is in response to the first version of the patch that 
   doesn't have the changes requested by Andrew, but this response will 
   be in terms of how it is implemented in v2. ]

> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  Documentation/cgroups/memory.txt |   15 ++++++++++
> >  mm/memcontrol.c                  |   56 +++++++++++++++++++++++++++++++++----
> >  2 files changed, 65 insertions(+), 6 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -68,6 +68,7 @@ Brief summary of control files.
> >  				 (See sysctl's vm.swappiness)
> >   memory.move_charge_at_immigrate # set/show controls of moving charges
> >   memory.oom_control		 # set/show oom controls.
> > + memory.oom_delay		 # set/show millisecs to wait before oom kill
> > 
> >  1. History
> > 
> > @@ -640,6 +641,20 @@ At reading, current status of OOM is shown.
> >  	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
> >  				 be stopped.)
> > 
> > +It is also possible to configure an oom killer timeout to prevent the
> > +possibility that the memcg will livelock looking for memory if userspace
> > +has disabled the oom killer with oom_control but cannot act to fix the
> > +condition itself (usually because userspace has become unresponsive).
> > +
> > +To set an oom killer timeout for a memcg, write the number of milliseconds
> > +to wait before killing a task to memory.oom_delay:
> > +
> > +	# echo 60000 > memory.oom_delay	# wait 60 seconds, then oom kill
> > +
> > +This timeout is reset the next time the memcg successfully charges memory
> > +to a task.
> > +
> > +
> >  11. TODO
> > 
> >  1. Add support for accounting huge pages (as a separate controller)
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -233,12 +233,16 @@ struct mem_cgroup {
> >  	 * Should the accounting and control be hierarchical, per subtree?
> >  	 */
> >  	bool use_hierarchy;
> > +	/* oom_delay has expired and still out of memory? */
> > +	bool oom_kill_delay_expired;
> >  	atomic_t	oom_lock;
> >  	atomic_t	refcnt;
> > 
> >  	unsigned int	swappiness;
> >  	/* OOM-Killer disable */
> >  	int		oom_kill_disable;
> > +	/* min number of ticks to wait before calling oom killer */
> > +	int		oom_kill_delay;
> > 
> >  	/* set when res.limit == memsw.limit */
> >  	bool		memsw_is_minimum;
> > @@ -1524,6 +1528,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *mem)
> > 
> >  static void memcg_oom_recover(struct mem_cgroup *mem)
> >  {
> > +	mem->oom_kill_delay_expired = false;
> >  	if (mem && atomic_read(&mem->oom_lock))
> >  		memcg_wakeup_oom(mem);
> >  }
> > @@ -1531,17 +1536,18 @@ static void memcg_oom_recover(struct mem_cgroup *mem)
> >  /*
> >   * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> >   */
> > -bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> > +static bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> >  {
> >  	struct oom_wait_info owait;
> > -	bool locked, need_to_kill;
> > +	bool locked;
> > +	bool need_to_kill = true;
> > +	bool need_to_delay = false;
> > 
> >  	owait.mem = mem;
> >  	owait.wait.flags = 0;
> >  	owait.wait.func = memcg_oom_wake_function;
> >  	owait.wait.private = current;
> >  	INIT_LIST_HEAD(&owait.wait.task_list);
> > -	need_to_kill = true;
> >  	/* At first, try to OOM lock hierarchy under mem.*/
> >  	mutex_lock(&memcg_oom_mutex);
> >  	locked = mem_cgroup_oom_lock(mem);
> > @@ -1553,26 +1559,34 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> >  	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> >  	if (!locked || mem->oom_kill_disable)
> >  		need_to_kill = false;
> > -	if (locked)
> > +	if (locked) {
> >  		mem_cgroup_oom_notify(mem);
> > +		if (mem->oom_kill_delay && !mem->oom_kill_delay_expired) {
> > +			need_to_kill = false;
> > +			need_to_delay = true;
> > +		}
> > +	}
> >  	mutex_unlock(&memcg_oom_mutex);
> > 
> >  	if (need_to_kill) {
> >  		finish_wait(&memcg_oom_waitq, &owait.wait);
> >  		mem_cgroup_out_of_memory(mem, mask);
> >  	} else {
> > -		schedule();
> > +		schedule_timeout(need_to_delay ? mem->oom_kill_delay :
> > +						 MAX_SCHEDULE_TIMEOUT);
> >  		finish_wait(&memcg_oom_waitq, &owait.wait);
> >  	}
> >  	mutex_lock(&memcg_oom_mutex);
> >  	mem_cgroup_oom_unlock(mem);
> >  	memcg_wakeup_oom(mem);
> > +	mem->oom_kill_delay_expired = need_to_delay;
> >  	mutex_unlock(&memcg_oom_mutex);
> > 
> >  	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
> >  		return false;
> >  	/* Give chance to dying process */
> > -	schedule_timeout(1);
> > +	if (!need_to_delay)
> > +		schedule_timeout(1);
> >  	return true;
> >  }
> 
> I think we need additional statistics for tracking oom kills due to
> timer expiry.
> 

I can add an export for how many times memory.oom_delay_millisecs expired 
and allowed an oom kill if you'd like.  If you have a special use case for 
that, please let me know and I'll put it in the changelog.

> > @@ -2007,6 +2021,7 @@ again:
> >  		refill_stock(mem, csize - PAGE_SIZE);
> >  	css_put(&mem->css);
> >  done:
> > +	mem->oom_kill_delay_expired = false;
> >  	*memcg = mem;
> >  	return 0;
> >  nomem:
> > @@ -4053,6 +4068,29 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
> >  	return 0;
> >  }
> > 
> > +static u64 mem_cgroup_oom_delay_read(struct cgroup *cgrp, struct cftype *cft)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	return jiffies_to_msecs(memcg->oom_kill_delay);
> > +}
> > +
> > +static int mem_cgroup_oom_delay_write(struct cgroup *cgrp, struct cftype *cft,
> > +				      u64 val)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +
> > +	/* Sanity check -- don't wait longer than an hour */
> > +	if (val > (60 * 60 * 1000))
> > +		return -EINVAL;
> 
> Why do this and not document it? These sort of things get exremely
> confusing. I would prefer not to have it without a resonable use case
> or very good documentation, explaining why we need an upper bound.
> 

The upper-bound is necessary, although not at 60 minutes, because 
mem_cgroup_oom_delay_write() takes a u64 and memcg->oom_delay_millisecs is 
an int.  I don't think it makes sense for a memcg to deadlock and fail all 
memory allocations for over an hour, so it's a pretty arbitrary value.  
I'll document it in the change to Documentation/cgroups/memory.txt.

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
