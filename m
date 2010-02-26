Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D59C46B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 23:54:19 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1Q4sGYU009801
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 26 Feb 2010 13:54:16 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 13B1745DE52
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 13:54:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E1D7345DE50
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 13:54:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BFE2EE78006
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 13:54:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D00CE38002
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 13:54:15 +0900 (JST)
Date: Fri, 26 Feb 2010 13:50:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/2] memcg: oom kill handling improvement
Message-Id: <20100226135045.d04b429a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100226131552.07475f9c.nishimura@mxp.nes.nec.co.jp>
References: <20100224165921.cb091a4f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100226131552.07475f9c.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 26 Feb 2010 13:15:52 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 24 Feb 2010 16:59:21 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > These are dump of patches just for showing concept, what I want to do.
> > But not tested. please see if you have free time. (you can ignore ;)
> > 
> > Anyway, this will HUNK to the latest mmotm, Kirill's work is merged.
> > 
> > This is not related to David's work. I don't hesitate to rebase mine
> > to the mmotm if his one is merged, it's easy.
> > But I'm not sure his one goes to mm soon. 
> > 
> > 1st patch is for better handling oom-kill under memcg.
> It's bigger than I expected, but it basically looks good to me.
> 
> > 2nd patch is oom-notifier and oom-kill-disable for memcg knob.
> > 
> This feature is very atractive.
> 
> 
> One comment to this patch for now.
> 
> > +/*
> > + * Check there are ongoing oom-kill in this hierarchy or not.
> > + * If now under oom-kill, wait for some event to restart job.
> > + */
> > +static bool memcg_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> > +{
> > +	int oom_count = 0;
> > +	DEFINE_WAIT(wait);
> > +	/*
> > +	 * Considering hierarchy (below)
> > +	 * /A
> > +	 *   /01
> > +	 *   /02
> > +	 * If 01 or 02 is under oom-kill, oom-kill in A should wait.
> > +	 * If "A" is under oom-kill, oom-kill in 01 and 02 should wait.
> > +	 * (task in 01/02 can be killed.)
> > +	 * But if 01 is under oom-kill, 02's oom-kill is independent from it.
> > +	 */
> > +	prepare_to_wait(&memcg_oom_waitq, &wait, TASK_INTERRUPTIBLE);
> > +	mem_cgroup_walk_tree(mem, &oom_count, set_memcg_oom_cb);
> > +	/* Am I the 1st oom killer in this sub hierarchy ? */
> > +	if (oom_count == 1) {
> > +		finish_wait(&memcg_oom_waitq, &wait);
> > +		mem_cgroup_out_of_memory(mem, mask);
> > +		mem_cgroup_walk_tree(mem, NULL, unset_memcg_oom_cb);
> I think we need call memcg_oom_wake() here. Some contexts might have slept already,
> but other callers of memcg_oom_wake() calle it after checking memcg_under_oom(),
> so if we don't wake them up here, they continue to sleep, IIUC.
> 
Yes, it's problem.

My 1st expectation is "If some process is killed, uncharge will be called."
So, I didn't add memcg_oom_wake() here.

But in this patch, it's broken because I clear flag.
Maybe it's better to have 2 flags as
	- a flag for "there are waiters".
	- a flag for "in OOM"

Or clear "there are waiters" flag when we really call wakeup.

Please let me 2nd trial.

Thanks,
-Kame

> 
> Thanks,
> Daisuke Nishimura.
> 
> > I'm sorry that I'll be absent tomorrow.
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > This is updated version of oom handling improvement om memcg.
> > But all codes are totaly renewed. This may not be sophisiticated well but
> > enough for showing idea.
> > 
> > This patch does following things.
> >   * set "memcg is under OOM" if somone gets into OOM under a memcg.
> >     like zone's OOM lock, tree-of-memcg is marked as under OOM.
> >     By this. simlutabeous OOM kill in a tree will not happen.
> > 
> >   * When other threads try to reclaim memory or call oom-kill, it
> >     checks its own target memcg is under oom or not. If someone
> >     calls oom-killer already, the thread will be queued to waitq.
> > 
> >   * At some event which makes room for new memory, threads on waitq
> >     are waken up.
> >     ** A page (or chunk of pages) are unchraged.
> >     ** A task is moved.
> >     ** limit is enlarged.
> > 
> > And this patch also allows to check "current's memcg is changed or not"
> > while charging.
> > 
> > Considering what admin/daemon can do when it notice OOM,
> >   * kill a process
> >   * move a process (to other cgroup which has free area)
> >   * remove a file (on tmpfs or some)
> >   * enlarge limit
> > I think all chances for wakeing up waiters are covered by these.
> > 
> > After this patch, memcg's accounting will not fail in usual path.
> > If all tasks are OOM_DISABLE, memcg may hang. But admin can have
> > several options described in above. So, oom notifier+freeze should be
> > implemented.
> > 
> > TODO: maybe not difficult.
> >   * Add oom notifier. (can reuse memory.threashold ?)
> >   * Add a switch for oom-freeze rather than oom-kill.
> > 
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Balbir Singh <balbir@in.ibm.com>
> > Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  include/linux/memcontrol.h |    6 -
> >  mm/memcontrol.c            |  208 +++++++++++++++++++++++++++++++++++----------
> >  mm/oom_kill.c              |   11 --
> >  3 files changed, 167 insertions(+), 58 deletions(-)
> > 
> > Index: mmotm-2.6.33-Feb11/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb11.orig/mm/memcontrol.c
> > +++ mmotm-2.6.33-Feb11/mm/memcontrol.c
> > @@ -200,7 +200,6 @@ struct mem_cgroup {
> >  	 * Should the accounting and control be hierarchical, per subtree?
> >  	 */
> >  	bool use_hierarchy;
> > -	unsigned long	last_oom_jiffies;
> >  	atomic_t	refcnt;
> >  
> >  	unsigned int	swappiness;
> > @@ -223,6 +222,8 @@ struct mem_cgroup {
> >  	 */
> >  	unsigned long 	move_charge_at_immigrate;
> >  
> > +	/* counting ongoing OOM requests under sub hierarchy */
> > +	atomic_t oom_count;
> >  	/*
> >  	 * percpu counter.
> >  	 */
> > @@ -1096,6 +1097,89 @@ done:
> >  }
> >  
> >  /*
> > + * set/under memcg_oom counting is done under mutex.
> > + */
> > +static DEFINE_MUTEX(memcg_oom_mutex);
> > +static DECLARE_WAIT_QUEUE_HEAD(memcg_oom_waitq);
> > +
> > +static int set_memcg_oom_cb(struct mem_cgroup *mem, void *data)
> > +{
> > +	int *max_count = (int*)data;
> > +	int count = atomic_inc_return(&mem->oom_count);
> > +	if (*max_count < count)
> > +		*max_count = count;
> > +	return 0;
> > +}
> > +
> > +static int unset_memcg_oom_cb(struct mem_cgroup *mem, void *data)
> > +{
> > +	atomic_set(&mem->oom_count, 0);
> > +	return 0;
> > +}
> > +
> > +static bool memcg_under_oom(struct mem_cgroup *mem)
> > +{
> > +	if (atomic_read(&mem->oom_count))
> > +		return true;
> > +	return false;
> > +}
> > +
> > +static void memcg_oom_wait(struct mem_cgroup *mem)
> > +{
> > +	DEFINE_WAIT(wait);
> > +
> > +	prepare_to_wait(&memcg_oom_waitq, &wait, TASK_INTERRUPTIBLE);
> > +	if (memcg_under_oom(mem))
> > +		schedule();
> > +	finish_wait(&memcg_oom_waitq, &wait);
> > +}
> > +
> > +static void memcg_oom_wake(void)
> > +{
> > +	/* This may wake up unnecessary tasks..but it's not big problem */
> > +	wake_up_all(&memcg_oom_waitq);
> > +}
> > +/*
> > + * Check there are ongoing oom-kill in this hierarchy or not.
> > + * If now under oom-kill, wait for some event to restart job.
> > + */
> > +static bool memcg_handle_oom(struct mem_cgroup *mem, gfp_t mask)
> > +{
> > +	int oom_count = 0;
> > +	DEFINE_WAIT(wait);
> > +	/*
> > +	 * Considering hierarchy (below)
> > +	 * /A
> > +	 *   /01
> > +	 *   /02
> > +	 * If 01 or 02 is under oom-kill, oom-kill in A should wait.
> > +	 * If "A" is under oom-kill, oom-kill in 01 and 02 should wait.
> > +	 * (task in 01/02 can be killed.)
> > +	 * But if 01 is under oom-kill, 02's oom-kill is independent from it.
> > +	 */
> > +	prepare_to_wait(&memcg_oom_waitq, &wait, TASK_INTERRUPTIBLE);
> > +	mem_cgroup_walk_tree(mem, &oom_count, set_memcg_oom_cb);
> > +	/* Am I the 1st oom killer in this sub hierarchy ? */
> > +	if (oom_count == 1) {
> > +		finish_wait(&memcg_oom_waitq, &wait);
> > +		mem_cgroup_out_of_memory(mem, mask);
> > +		mem_cgroup_walk_tree(mem, NULL, unset_memcg_oom_cb);
> > +	} else {
> > +		/*
> > +		 * Wakeup is called when
> > +		 * 1. pages are uncharged. (by killed, or removal of a file)
> > +		 * 2. limit is enlarged.
> > +		 * 3. a task is moved.
> > +		 */
> > +		schedule();
> > +		finish_wait(&memcg_oom_waitq, &wait);
> > +	}
> > +	if (test_thread_flag(TIF_MEMDIE))
> > +		return false;
> > +	return true;
> > +}
> > +
> > +/*
> >   * This function returns the number of memcg under hierarchy tree. Returns
> >   * 1(self count) if no children.
> >   */
> > @@ -1234,34 +1318,6 @@ static int mem_cgroup_hierarchical_recla
> >  	return total;
> >  }
> >  
> > -bool mem_cgroup_oom_called(struct task_struct *task)
> > -{
> > -	bool ret = false;
> > -	struct mem_cgroup *mem;
> > -	struct mm_struct *mm;
> > -
> > -	rcu_read_lock();
> > -	mm = task->mm;
> > -	if (!mm)
> > -		mm = &init_mm;
> > -	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> > -	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
> > -		ret = true;
> > -	rcu_read_unlock();
> > -	return ret;
> > -}
> > -
> > -static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
> > -{
> > -	mem->last_oom_jiffies = jiffies;
> > -	return 0;
> > -}
> > -
> > -static void record_last_oom(struct mem_cgroup *mem)
> > -{
> > -	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
> > -}
> > -
> >  /*
> >   * Currently used to update mapped file statistics, but the routine can be
> >   * generalized to update other statistics as well.
> > @@ -1419,6 +1475,7 @@ static int __cpuinit memcg_stock_cpu_cal
> >  	return NOTIFY_OK;
> >  }
> >  
> > +
> >  /*
> >   * Unlike exported interface, "oom" parameter is added. if oom==true,
> >   * oom-killer can be invoked.
> > @@ -1427,17 +1484,21 @@ static int __mem_cgroup_try_charge(struc
> >  			gfp_t gfp_mask, struct mem_cgroup **memcg,
> >  			bool oom, struct page *page)
> >  {
> > -	struct mem_cgroup *mem, *mem_over_limit;
> > -	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > +	struct mem_cgroup *mem, *mem_over_limit, *recorded;
> > +	int nr_retries, csize;
> >  	struct res_counter *fail_res;
> > -	int csize = CHARGE_SIZE;
> > +
> > +start:
> > +	nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > +	recorded = *memcg;
> > +	csize = CHARGE_SIZE;
> > +	mem = NULL;
> >  
> >  	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
> >  		/* Don't account this! */
> >  		*memcg = NULL;
> >  		return 0;
> >  	}
> > -
> >  	/*
> >  	 * We always charge the cgroup the mm_struct belongs to.
> >  	 * The mm_struct's mem_cgroup changes on task migration if the
> > @@ -1489,6 +1550,12 @@ static int __mem_cgroup_try_charge(struc
> >  		}
> >  		if (!(gfp_mask & __GFP_WAIT))
> >  			goto nomem;
> > +		/* already in OOM ? */
> > +		if (memcg_under_oom(mem_over_limit)) {
> > +			/* Don't add too much pressure to the host */
> > +			memcg_oom_wait(mem_over_limit);
> > +			goto retry;
> > +		}
> >  
> >  		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
> >  						gfp_mask, flags);
> > @@ -1549,11 +1616,15 @@ static int __mem_cgroup_try_charge(struc
> >  		}
> >  
> >  		if (!nr_retries--) {
> > -			if (oom) {
> > -				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
> > -				record_last_oom(mem_over_limit);
> > -			}
> > -			goto nomem;
> > +
> > +			if (!oom)
> > +				goto nomem;
> > +			/* returnes false if current is killed */
> > +			if (memcg_handle_oom(mem_over_limit, gfp_mask))
> > +				goto retry;
> > +			/* For smooth oom-kill of current, return 0 */
> > +			css_put(&mem->css);
> > +			return 0;
> >  		}
> >  	}
> >  	if (csize > PAGE_SIZE)
> > @@ -1572,6 +1643,15 @@ done:
> >  nomem:
> >  	css_put(&mem->css);
> >  	return -ENOMEM;
> > +
> > +retry:
> > +	/*
> > +	 * current's mem_cgroup can be moved while we're waiting for
> > +	 * memory reclaim or OOM-Kill.
> > +	 */
> > +	*memcg = recorded;
> > +	css_put(&mem->css);
> > +	goto start;
> >  }
> >  
> >  /*
> > @@ -1589,6 +1669,9 @@ static void __mem_cgroup_cancel_charge(s
> >  		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
> >  		WARN_ON_ONCE(count > INT_MAX);
> >  		__css_put(&mem->css, (int)count);
> > +
> > +		if (memcg_under_oom(mem))
> > +			memcg_oom_wake();
> >  	}
> >  	/* we don't need css_put for root */
> >  }
> > @@ -2061,6 +2144,10 @@ direct_uncharge:
> >  	res_counter_uncharge(&mem->res, PAGE_SIZE);
> >  	if (uncharge_memsw)
> >  		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > +	/* Slow path to check OOM waiters */
> > +	if (!current->memcg_batch.do_batch || batch->memcg != mem)
> > +		if (memcg_under_oom(mem))
> > +			memcg_oom_wake();
> >  	return;
> >  }
> >  
> > @@ -2200,6 +2287,9 @@ void mem_cgroup_uncharge_end(void)
> >  		res_counter_uncharge(&batch->memcg->res, batch->bytes);
> >  	if (batch->memsw_bytes)
> >  		res_counter_uncharge(&batch->memcg->memsw, batch->memsw_bytes);
> > +
> > +	if (memcg_under_oom(batch->memcg))
> > +		memcg_oom_wake();
> >  	/* forget this pointer (for sanity check) */
> >  	batch->memcg = NULL;
> >  }
> > @@ -2408,8 +2498,7 @@ void mem_cgroup_end_migration(struct mem
> >  
> >  /*
> >   * A call to try to shrink memory usage on charge failure at shmem's swapin.
> > - * Calling hierarchical_reclaim is not enough because we should update
> > - * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global OOM.
> > + * Calling hierarchical_reclaim is not enough because we have to hand oom-kill.
> >   * Moreover considering hierarchy, we should reclaim from the mem_over_limit,
> >   * not from the memcg which this page would be charged to.
> >   * try_charge_swapin does all of these works properly.
> > @@ -2440,7 +2529,8 @@ static int mem_cgroup_resize_limit(struc
> >  	u64 memswlimit;
> >  	int ret = 0;
> >  	int children = mem_cgroup_count_children(memcg);
> > -	u64 curusage, oldusage;
> > +	u64 curusage, oldusage, curlimit;
> > +	int enlarge = 0;
> >  
> >  	/*
> >  	 * For keeping hierarchical_reclaim simple, how long we should retry
> > @@ -2451,6 +2541,7 @@ static int mem_cgroup_resize_limit(struc
> >  
> >  	oldusage = res_counter_read_u64(&memcg->res, RES_USAGE);
> >  
> > +
> >  	while (retry_count) {
> >  		if (signal_pending(current)) {
> >  			ret = -EINTR;
> > @@ -2468,6 +2559,9 @@ static int mem_cgroup_resize_limit(struc
> >  			mutex_unlock(&set_limit_mutex);
> >  			break;
> >  		}
> > +		curlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> > +		if (curlimit < val)
> > +			enlarge = 1;
> >  		ret = res_counter_set_limit(&memcg->res, val);
> >  		if (!ret) {
> >  			if (memswlimit == val)
> > @@ -2477,8 +2571,20 @@ static int mem_cgroup_resize_limit(struc
> >  		}
> >  		mutex_unlock(&set_limit_mutex);
> >  
> > -		if (!ret)
> > +		if (!ret) {
> > +			/*
> > +			 * If we enlarge limit of memcg under OOM,
> > +			 * wake up waiters.
> > +			 */
> > +			if (enlarge && memcg_under_oom(memcg))
> > +				memcg_oom_wake();
> > +			break;
> > +		}
> > +		/* Under OOM ? If so, don't add more pressure. */
> > +		if (memcg_under_oom(memcg)) {
> > +			ret = -EBUSY;
> >  			break;
> > +		}
> >  
> >  		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
> >  						MEM_CGROUP_RECLAIM_SHRINK);
> > @@ -2497,9 +2603,10 @@ static int mem_cgroup_resize_memsw_limit
> >  					unsigned long long val)
> >  {
> >  	int retry_count;
> > -	u64 memlimit, oldusage, curusage;
> > +	u64 memlimit, oldusage, curusage, curlimit;
> >  	int children = mem_cgroup_count_children(memcg);
> >  	int ret = -EBUSY;
> > +	int enlarge;
> >  
> >  	/* see mem_cgroup_resize_res_limit */
> >   	retry_count = children * MEM_CGROUP_RECLAIM_RETRIES;
> > @@ -2521,6 +2628,9 @@ static int mem_cgroup_resize_memsw_limit
> >  			mutex_unlock(&set_limit_mutex);
> >  			break;
> >  		}
> > +		curlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> > +		if (curlimit < val)
> > +			enlarge = 1;
> >  		ret = res_counter_set_limit(&memcg->memsw, val);
> >  		if (!ret) {
> >  			if (memlimit == val)
> > @@ -2530,8 +2640,15 @@ static int mem_cgroup_resize_memsw_limit
> >  		}
> >  		mutex_unlock(&set_limit_mutex);
> >  
> > -		if (!ret)
> > +		if (!ret) {
> > +			if (enlarge && memcg_under_oom(memcg))
> > +				memcg_oom_wake();
> >  			break;
> > +		}
> > +		if (memcg_under_oom(memcg)) {
> > +			ret = -EBUSY;
> > +			continue;
> > +		}
> >  
> >  		mem_cgroup_hierarchical_reclaim(memcg, NULL, GFP_KERNEL,
> >  						MEM_CGROUP_RECLAIM_NOSWAP |
> > @@ -3859,6 +3976,9 @@ one_by_one:
> >  			ret = -EINTR;
> >  			break;
> >  		}
> > +		/* Undo precharges if there is ongoing OOM */
> > +		if (memcg_under_oom(mem))
> > +			return -ENOMEM;
> >  		if (!batch_count--) {
> >  			batch_count = PRECHARGE_COUNT_AT_ONCE;
> >  			cond_resched();
> > Index: mmotm-2.6.33-Feb11/mm/oom_kill.c
> > ===================================================================
> > --- mmotm-2.6.33-Feb11.orig/mm/oom_kill.c
> > +++ mmotm-2.6.33-Feb11/mm/oom_kill.c
> > @@ -487,6 +487,9 @@ retry:
> >  		goto retry;
> >  out:
> >  	read_unlock(&tasklist_lock);
> > +	/* give a chance to die for selected process */
> > +	if (!test_thread_flag(TIF_MEMDIE))
> > +		schedule_timeout_uninterruptible(1);
> >  }
> >  #endif
> >  
> > @@ -601,13 +604,6 @@ void pagefault_out_of_memory(void)
> >  		/* Got some memory back in the last second. */
> >  		return;
> >  
> > -	/*
> > -	 * If this is from memcg, oom-killer is already invoked.
> > -	 * and not worth to go system-wide-oom.
> > -	 */
> > -	if (mem_cgroup_oom_called(current))
> > -		goto rest_and_return;
> > -
> >  	if (sysctl_panic_on_oom)
> >  		panic("out of memory from page fault. panic_on_oom is selected.\n");
> >  
> > @@ -619,7 +615,6 @@ void pagefault_out_of_memory(void)
> >  	 * Give "p" a good chance of killing itself before we
> >  	 * retry to allocate memory.
> >  	 */
> > -rest_and_return:
> >  	if (!test_thread_flag(TIF_MEMDIE))
> >  		schedule_timeout_uninterruptible(1);
> >  }
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
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
