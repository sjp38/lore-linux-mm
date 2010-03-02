Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 581106B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 19:02:02 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o23020kw015684
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Mar 2010 09:02:00 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F3EB145DE54
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:01:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D083745DE50
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:01:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AA93CE3800A
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:01:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 40F92E78003
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 09:01:59 +0900 (JST)
Date: Wed, 3 Mar 2010 08:58:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom kill behavior.
Message-Id: <20100303085824.1b260683.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100302171142.GD16532@balbir.in.ibm.com>
References: <20100302115834.c0045175.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302171142.GD16532@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010 22:41:42 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-02 11:58:34]:
> 
> > Brief Summary (for Andrew)
> > 
> >  - Nishimura reported my fix (one year ago)
> >    a636b327f731143ccc544b966cfd8de6cb6d72c6
> >    doesn't work well in some extreme situation.
> > 
> >  - David Rientjes said mem_cgroup_oom_called() is completely
> >    ugly and broken and.....
> >    And he tries to remove that in his patch set.
> > 
> > Then, I wrote this as bugfix onto mmotm. This patch implements
> >  - per-memcg OOM lock as per-zone OOM lock
> >  - avoid to return -ENOMEM via mamcg's page fault path.
> >    ENOMEM causes unnecessary page_fault_out_of_memory().
> >    (Even if memcg hangs, there is no change from current behavior)
> >  - in addtion to MEMDIE thread, KILLED proceses go bypath memcg.
> > 
> > I'm glad if this goes into 2.6.34 timeline (as bugfix). But I'm
> > afraid this seems too big as bugfix...
> > 
> > My plans for 2.6.35 are
> >  - oom-notifier for memcg (based on memcg threshold notifier) 
> >  - oom-freezer (disable oom-kill) for memcg
> >  - better handling in extreme situation.
> > And now, Andrea Righi works for dirty_ratio for memcg. We'll have
> > something better in 2.6.35 kernels.
> > 
> > This patch will HUNK with David's set. Then, if this hunks in mmotm,
> > I'll rework.
> >
> 
> Hi, Kamezawa-San,
> 
> Some review comments below.
>  
> > Tested on x86-64. Nishimura-san, could you test ?
> > 
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > In current page-fault code,
> > 
> > 	handle_mm_fault()
> > 		-> ...
> > 		-> mem_cgroup_charge()
> > 		-> map page or handle error.
> > 	-> check return code.
> > 
> > If page fault's return code is VM_FAULT_OOM, page_fault_out_of_memory()
> > is called. But if it's caused by memcg, OOM should have been already
> > invoked.
> > Then, I added a patch: a636b327f731143ccc544b966cfd8de6cb6d72c6
> > 
> > That patch records last_oom_jiffies for memcg's sub-hierarchy and
> > prevents page_fault_out_of_memory from being invoked in near future.
> > 
> > But Nishimura-san reported that check by jiffies is not enough
> > when the system is terribly heavy. 
> > 
> > This patch changes memcg's oom logic as.
> >  * If memcg causes OOM-kill, continue to retry.
> >  * remove jiffies check which is used now.
> 
> I like this very much!
> 
> >  * add memcg-oom-lock which works like perzone oom lock.
> >  * If current is killed(as a process), bypass charge.
> > 
> > Something more sophisticated can be added but this pactch does
> > fundamental things.
> > TODO:
> >  - add oom notifier
> >  - add permemcg disable-oom-kill flag and freezer at oom.
> >  - more chances for wake up oom waiter (when changing memory limit etc..)
> > 
> > Changelog;
> >  - fixed per-memcg oom lock.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h |    6 --
> >  mm/memcontrol.c            |  109 +++++++++++++++++++++++++++++++++------------
> >  mm/oom_kill.c              |    8 ---
> >  3 files changed, 82 insertions(+), 41 deletions(-)
> > 
> > Index: mmotm-2.6.33-Feb11/include/linux/memcontrol.h
> > ===================================================================
> > --- mmotm-2.6.33-Feb11.orig/include/linux/memcontrol.h
> > +++ mmotm-2.6.33-Feb11/include/linux/memcontrol.h
> > @@ -124,7 +124,6 @@ static inline bool mem_cgroup_disabled(v
> >  	return false;
> >  }
> > 
> > -extern bool mem_cgroup_oom_called(struct task_struct *task);
> >  void mem_cgroup_update_file_mapped(struct page *page, int val);
> >  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
> >  						gfp_t gfp_mask, int nid,
> > @@ -258,11 +257,6 @@ static inline bool mem_cgroup_disabled(v
> >  	return true;
> >  }
> > 
> > -static inline bool mem_cgroup_oom_called(struct task_struct *task)
> > -{
> > -	return false;
> > -}
> > -
> >  static inline int
> >  mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
> >  {
> > Index: mmotm-2.6.33-Feb11/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb11.orig/mm/memcontrol.c
> > +++ mmotm-2.6.33-Feb11/mm/memcontrol.c
> > @@ -200,7 +200,7 @@ struct mem_cgroup {
> >  	 * Should the accounting and control be hierarchical, per subtree?
> >  	 */
> >  	bool use_hierarchy;
> > -	unsigned long	last_oom_jiffies;
> > +	atomic_t	oom_lock;
> >  	atomic_t	refcnt;
> > 
> >  	unsigned int	swappiness;
> > @@ -1234,32 +1234,77 @@ static int mem_cgroup_hierarchical_recla
> >  	return total;
> >  }
> > 
> > -bool mem_cgroup_oom_called(struct task_struct *task)
> > +static int mem_cgroup_oom_lock_cb(struct mem_cgroup *mem, void *data)
> >  {
> > -	bool ret = false;
> > -	struct mem_cgroup *mem;
> > -	struct mm_struct *mm;
> > +	int *val = (int *)data;
> > +	int x;
> > 
> > -	rcu_read_lock();
> > -	mm = task->mm;
> > -	if (!mm)
> > -		mm = &init_mm;
> > -	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > -	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
> > -		ret = true;
> > -	rcu_read_unlock();
> > -	return ret;
> > +	x = atomic_inc_return(&mem->oom_lock);
> > +	if (x > *val)
> > +		*val = x;a
> 
> Use the max_t function here?
>         x = max_t(int, x, *val);
> 
Sure.


> > +	return 0;
> > +}
> > +/*
> > + * Check OOM-Killer is already running under our hierarchy.
> > + * If someone is running, return false.
> > + */
> > +static bool mem_cgroup_oom_lock(struct mem_cgroup *mem)
> > +{
> > +	int check = 0;
> > +
> > +	mem_cgroup_walk_tree(mem, &check, mem_cgroup_oom_lock_cb);
> > +
> > +	if (check == 1)
> > +		return true;
> > +	return false;
> >  }
> > 
> > -static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
> > +static int mem_cgroup_oom_unlock_cb(struct mem_cgroup *mem, void *data)
> >  {
> > -	mem->last_oom_jiffies = jiffies;
> > +	atomic_dec(&mem->oom_lock);
> >  	return 0;
> >  }
> > 
> > -static void record_last_oom(struct mem_cgroup *mem)
> > +static void mem_cgroup_oom_unlock(struct mem_cgroup *mem)
> >  {
> > -	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
> > +	mem_cgroup_walk_tree(mem, NULL,	mem_cgroup_oom_unlock_cb);
> > +}
> > +
> > +static DEFINE_MUTEX(memcg_oom_mutex);
> > +static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
> > +
> > +/*
> > + * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> > + */
> > +bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> > +{
> > +	DEFINE_WAIT(wait);
> > +	bool locked;
> > +
> > +	prepare_to_wait(&memcg_oom_waitq, &wait, TASK_INTERRUPTIBLE);
> > +	/* At first, try to OOM lock hierarchy under mem.*/
> > +	mutex_lock(&memcg_oom_mutex);
> > +	locked = mem_cgroup_oom_lock(mem);
> > +	mutex_unlock(&memcg_oom_mutex);
> > +
> > +	if (locked) {
> > +		finish_wait(&memcg_oom_waitq, &wait);
> > +		mem_cgroup_out_of_memory(mem, mask);
> > +	} else {
> > +		schedule();
> > +		finish_wait(&memcg_oom_waitq, &wait);
> > +	}
> > +	mutex_lock(&memcg_oom_mutex);
> > +	mem_cgroup_oom_unlock(mem);
> > +	/* TODO: more fine grained waitq ? */
> > +	wake_up_all(&memcg_oom_waitq);
> 
> I was wondering if we should really wake up all? Shouldn't this be per
> memcg? The waitq that is, since the check is per memcg, the wakeup
> should also be per memcg.
> 
The difficulty of per-memcg waitq is because of hierarchy.

Assume following hierarhcy A and its children 01 and 02.

	A/            <==== under OOM #2
	  01          <==== under OOM #1
	  02

And the OOM happens in following sequence.
   1.  01 goes to OOM (#1)
   2.  A  goes to OOM (#2)

Because oom-kill in group 01 can fix both oom under A and 01,
oom-kill under A and oom-kill under 01 should be mutual exclusive.

When OOM under 01 wakes up, we have no way to wake up waiters on A.
That's the reason I used system-wide waitq.

I think there is no big problem. But I hope someone finds a new magic
for doing logically correct things. Then, I added a TODO.
I'll add some comments.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
