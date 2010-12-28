Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5F56B0087
	for <linux-mm@kvack.org>; Tue, 28 Dec 2010 00:22:23 -0500 (EST)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id oBS5MKlh021898
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 21:22:20 -0800
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by hpaq2.eem.corp.google.com with ESMTP id oBS5LfFY012236
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 21:22:18 -0800
Received: by pxi9 with SMTP id 9so2799716pxi.37
        for <linux-mm@kvack.org>; Mon, 27 Dec 2010 21:22:15 -0800 (PST)
Date: Mon, 27 Dec 2010 21:22:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] memcg: add oom killer delay
In-Reply-To: <20101227095225.2cf907a3.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1012272103370.27164@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com> <20101221235924.b5c1aecc.akpm@linux-foundation.org> <alpine.DEB.2.00.1012220031010.24462@chino.kir.corp.google.com> <alpine.DEB.2.00.1012221443540.2612@chino.kir.corp.google.com>
 <20101227095225.2cf907a3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Dec 2010, KAMEZAWA Hiroyuki wrote:

> I dislike this feature but if someone other than goole want this, I'll ack.
> some comments below.
> 

I don't really understand that; if you think the future is useful for the 
described use-case with minimal impact to memcg, then I'd hope you would 
ack it without needing to build a coalition of companies to ask for the 
feature to be merged.

We're going to use it regardless of whether it's merged upstream, but I 
think there's other use cases where it could potentially be helpful: for 
example, to avoid a quick oom kill when there's a temporary spike in 
memory usage over time without modifying the memcg's limit.  It seems 
plausible that a user would want to defer oom killing only if a memcg is 
oom for a certain amount of time.  That's distinct and in addition to our 
use case, which is to not rely solely on userspace to solve these memcg 
deadlocks when it fails to respond appropriately and in a timely manner.

> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
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
> > @@ -640,6 +641,22 @@ At reading, current status of OOM is shown.
> >  	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
> >  				 be stopped.)
> >  
> > +It is also possible to configure an oom killer timeout to prevent the
> > +possibility that the memcg will livelock looking for memory if userspace
> 
> It's not livelock. It's just 'stop'. No cpu consumption at all even if oom is
> disabled.
> 

I did s/livelock/deadlock.

> > +has disabled the oom killer with oom_control but cannot act to fix the
> > +condition itself (usually because userspace has become unresponsive).
> > +
> > +To set an oom killer timeout for a memcg, write the number of milliseconds
> > +to wait before killing a task to memory.oom_delay_millisecs:
> > +
> > +	# echo 60000 > memory.oom_delay_millisecs	# 60 seconds before kill
> > +
> 
> I wonder whether this should be call as oom_delay you mention this feature as
> 'timeout' a few times before here. I like 'timeout' rather than 'delay'.
> And from this ducument, They are unclear that
>   1. what happens when it used with oom_disable.
>   2. what kind of timer is this. Is it a one-shot timer ?
>   3. how work with hierarchy ?
> 

These are three very good questions regarding my (currently lack of 
adequate) documentation and I'll add the answers to v3.  I'd prefer to 
keep the name oom_delay_millisecs, however, since "delay" means oom 
killing will be deferred rather than "timeout," which means oom killing 
has taken too long and expired.

> My suggestion for 1. is:
> Please return -EBUSY or some if oom_disable=true and allow set timeout only when
> oom_disable=false. Using both of two interface at the same time is too complex.
> 

I added documentation that states that memory.oom_delay_millisecs is only 
effective if memory.oom_control == 0.  I think configuring both should be 
allowed and memory.oom_control == 1 takes precedence anytime it is set; if 
it is cleared later, then any existing memory.oom_delay_millisecs becomes 
effective.

> > +This timeout is reset the next time the memcg successfully charges memory
> > +to a task.
> > +
> > +There is no delay if memory.oom_delay_millisecs is set to 0 (default).
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
> > +	bool oom_delay_expired;
> >  	atomic_t	oom_lock;
> >  	atomic_t	refcnt;
> >  
> >  	unsigned int	swappiness;
> >  	/* OOM-Killer disable */
> >  	int		oom_kill_disable;
> > +	/* number of ticks to stall before calling oom killer */
> > +	int		oom_delay;
> >  
> >  	/* set when res.limit == memsw.limit */
> >  	bool		memsw_is_minimum;
> > @@ -1524,6 +1528,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *mem)
> >  
> >  static void memcg_oom_recover(struct mem_cgroup *mem)
> >  {
> > +	mem->oom_delay_expired = false;
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
> > +		if (mem->oom_delay && !mem->oom_delay_expired) {
> > +			need_to_kill = false;
> > +			need_to_delay = true;
> > +		}
> > +	}
> 
> Hmm. When threads T1 and T2 enters this routine, it seems broken.
> 
> Case 1)
> 	T1                        T2
>      lock_oom.
>      locked=true                lock_oom.
>      oom_notify()               locked = false.    
>      wait for msecs.            wait until wakeup.
>      ......
>      unlock_oom.
>      wakes up.
>      wake up all threads.
>      oom_delay_expired=true.    wakes up.
>                                 oom_delay_expired=false.
>                                
>      2nd call of oom.
>      lock_oom.
>      locked=true.
>      oom_notify.
>      wait for msecs.
>   
> Then, oom_notify is duplicated and no OOM happens.
> memcg_wakeup_oom() wakes up all threads. So, I guess you should avoid to call
> that. But hmm...I think there are other pitfalls.
> 
> 
> Assume a hierachy as this.
> 
>   A
>  / \
>  B  C
> 
> A.memory.use_hierarchy= 1 and (A,B,C) are under hierarchical control.
> 
> At first, oom_disable is allowed to be set only against A. By setting
> oom_disable to A, OOM in B and C are disabled, too. For that purpose,
> mem_cgroup_oom_lock/unlock is provided.
> 
> With your patch, even if oom_delay is set to A, B and C will never delay.
> Please fix.
> 

I think what might be clearer is if we made memory.oom_delay_millisecs to 
be a one-shot timer as you mentioned previously.  So once a memcg is oom, 
the task that grabs the oom_lock sleeps for the delay and then it is 
cleared.  Later threads that are oom and grab oom_lock will immediately 
call the oom killer.  Then, if userspace truly is dead, oom killing won't 
be delayed in the future and the kernel can take immediate action.  And if 
userspace is alive, it can reset memory.oom_delay_millisecs.

What do you think about that functionality instead?

> Have a good new year.
> 

Same to you, Kame!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
