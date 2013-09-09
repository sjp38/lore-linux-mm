Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 96CF76B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 08:57:01 -0400 (EDT)
Date: Mon, 9 Sep 2013 14:56:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 0/7] improve memcg oom killer robustness v2
Message-ID: <20130909125659.GD22212@dhcp22.suse.cz>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
 <20130803170831.GB23319@cmpxchg.org>
 <20130830215852.3E5D3D66@pobox.sk>
 <20130902123802.5B8E8CB1@pobox.sk>
 <20130903204850.GA1412@cmpxchg.org>
 <20130904101852.58E70042@pobox.sk>
 <20130905115430.GB856@cmpxchg.org>
 <20130905124352.GB13666@dhcp22.suse.cz>
 <20130905161817.GD856@cmpxchg.org>
 <20130909123625.GC22212@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130909123625.GC22212@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>
Cc: azurIt <azurit@pobox.sk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

[Adding Glauber - the full patch is here https://lkml.org/lkml/2013/9/5/319]

On Mon 09-09-13 14:36:25, Michal Hocko wrote:
> On Thu 05-09-13 12:18:17, Johannes Weiner wrote:
> [...]
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Subject: [patch] mm: memcg: do not trap chargers with full callstack on OOM
> > 
> [...]
> > 
> > To fix this, never do any OOM handling directly in the charge context.
> > When an OOM situation is detected, let the task remember the memcg and
> > then handle the OOM (kill or wait) only after the page fault stack is
> > unwound and about to return to userspace.
> 
> OK, this is indeed nicer because the oom setup is trivial and the
> handling is not split into two parts and everything happens close to
> out_of_memory where it is expected.

Hmm, wait a second. I have completely forgot about the kmem charging
path during the review.

So while previously memcg_charge_kmem could have oom killed a
task if the it couldn't charge to the u-limit after it managed
to charge k-limit, now it would simply fail because there is no
mem_cgroup_{enable,disable}_oom around __mem_cgroup_try_charge it relies
on. The allocation will fail in the end but I am not sure whether the
missing oom is an issue or not for existing use cases.

My original objection about oom triggered from kmem paths was that oom
is not kmem aware so the oom decisions might be totally bogus. But we
still have that:

        /*
         * Conditions under which we can wait for the oom_killer. Those are
         * the same conditions tested by the core page allocator
         */
        may_oom = (gfp & __GFP_FS) && !(gfp & __GFP_NORETRY);

        _memcg = memcg;
        ret = __mem_cgroup_try_charge(NULL, gfp, size >> PAGE_SHIFT,
                                      &_memcg, may_oom);

I do not mind having may_oom = false unconditionally in that path but I
would like to hear fromm Glauber first.

> > Reported-by: Reported-by: azurIt <azurit@pobox.sk>
> > Debugged-by: Michal Hocko <mhocko@suse.cz>
> > Not-yet-Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>
> 
> Thanks!
> 
> > ---
> >  include/linux/memcontrol.h | 17 ++++++++
> >  include/linux/sched.h      |  2 +
> >  mm/memcontrol.c            | 96 +++++++++++++++++++++++++++++++---------------
> >  mm/memory.c                | 11 +++++-
> >  mm/oom_kill.c              |  2 +
> >  5 files changed, 96 insertions(+), 32 deletions(-)
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index b344b3a..325da07 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -132,6 +132,13 @@ static inline void mem_cgroup_disable_oom(void)
> >  	current->memcg_oom.may_oom = 0;
> >  }
> >  
> > +static inline bool task_in_memcg_oom(struct task_struct *p)
> > +{
> > +	return p->memcg_oom.memcg;
> > +}
> > +
> > +bool mem_cgroup_oom_synchronize(bool wait);
> > +
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >  extern int do_swap_account;
> >  #endif
> > @@ -353,6 +360,16 @@ static inline void mem_cgroup_disable_oom(void)
> >  {
> >  }
> >  
> > +static inline bool task_in_memcg_oom(struct task_struct *p)
> > +{
> > +	return false;
> > +}
> > +
> > +static inline bool mem_cgroup_oom_synchronize(bool wait)
> > +{
> > +	return false;
> > +}
> > +
> >  static inline void mem_cgroup_inc_page_stat(struct page *page,
> >  					    enum mem_cgroup_page_stat_item idx)
> >  {
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > index 21834a9..fb1f145 100644
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1569,6 +1569,8 @@ struct task_struct {
> >  		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
> >  	} memcg_batch;
> >  	struct memcg_oom_info {
> > +		struct mem_cgroup *memcg;
> > +		gfp_t gfp_mask;
> >  		unsigned int may_oom:1;
> >  	} memcg_oom;
> >  #endif
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 36bb58f..56643fe 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1858,14 +1858,59 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
> >  		memcg_wakeup_oom(memcg);
> >  }
> >  
> > -/*
> > - * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> > +static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask)
> > +{
> > +	if (!current->memcg_oom.may_oom)
> > +		return;
> > +	/*
> > +	 * We are in the middle of the charge context here, so we
> > +	 * don't want to block when potentially sitting on a callstack
> > +	 * that holds all kinds of filesystem and mm locks.
> > +	 *
> > +	 * Also, the caller may handle a failed allocation gracefully
> > +	 * (like optional page cache readahead) and so an OOM killer
> > +	 * invocation might not even be necessary.
> > +	 *
> > +	 * That's why we don't do anything here except remember the
> > +	 * OOM context and then deal with it at the end of the page
> > +	 * fault when the stack is unwound, the locks are released,
> > +	 * and when we know whether the fault was overall successful.
> > +	 */
> > +	css_get(&memcg->css);
> > +	current->memcg_oom.memcg = memcg;
> > +	current->memcg_oom.gfp_mask = mask;
> > +}
> > +
> > +/**
> > + * mem_cgroup_oom_synchronize - complete memcg OOM handling
> > + * @handle: actually kill/wait or just clean up the OOM state
> > + *
> > + * This has to be called at the end of a page fault if the memcg OOM
> > + * handler was enabled.
> > + *
> > + * Memcg supports userspace OOM handling where failed allocations must
> > + * sleep on a waitqueue until the userspace task resolves the
> > + * situation.  Sleeping directly in the charge context with all kinds
> > + * of locks held is not a good idea, instead we remember an OOM state
> > + * in the task and mem_cgroup_oom_synchronize() has to be called at
> > + * the end of the page fault to complete the OOM handling.
> > + *
> > + * Returns %true if an ongoing memcg OOM situation was detected and
> > + * completed, %false otherwise.
> >   */
> > -bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
> > +bool mem_cgroup_oom_synchronize(bool handle)
> >  {
> > +	struct mem_cgroup *memcg = current->memcg_oom.memcg;
> >  	struct oom_wait_info owait;
> >  	bool locked;
> >  
> > +	/* OOM is global, do not handle */
> > +	if (!memcg)
> > +		return false;
> > +
> > +	if (!handle)
> > +		goto cleanup;
> > +
> >  	owait.mem = memcg;
> >  	owait.wait.flags = 0;
> >  	owait.wait.func = memcg_oom_wake_function;
> > @@ -1894,7 +1939,7 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
> >  	if (locked && !memcg->oom_kill_disable) {
> >  		mem_cgroup_unmark_under_oom(memcg);
> >  		finish_wait(&memcg_oom_waitq, &owait.wait);
> > -		mem_cgroup_out_of_memory(memcg, mask);
> > +		mem_cgroup_out_of_memory(memcg, current->memcg_oom.gfp_mask);
> >  	} else {
> >  		schedule();
> >  		mem_cgroup_unmark_under_oom(memcg);
> > @@ -1910,11 +1955,9 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
> >  		 */
> >  		memcg_oom_recover(memcg);
> >  	}
> > -
> > -	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
> > -		return false;
> > -	/* Give chance to dying process */
> > -	schedule_timeout_uninterruptible(1);
> > +cleanup:
> > +	current->memcg_oom.memcg = NULL;
> > +	css_put(&memcg->css);
> >  	return true;
> >  }
> >  
> > @@ -2204,11 +2247,10 @@ enum {
> >  	CHARGE_RETRY,		/* need to retry but retry is not bad */
> >  	CHARGE_NOMEM,		/* we can't do more. return -ENOMEM */
> >  	CHARGE_WOULDBLOCK,	/* GFP_WAIT wasn't set and no enough res. */
> > -	CHARGE_OOM_DIE,		/* the current is killed because of OOM */
> >  };
> >  
> >  static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> > -				unsigned int nr_pages, bool oom_check)
> > +				unsigned int nr_pages, bool invoke_oom)
> >  {
> >  	unsigned long csize = nr_pages * PAGE_SIZE;
> >  	struct mem_cgroup *mem_over_limit;
> > @@ -2266,14 +2308,10 @@ static int mem_cgroup_do_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
> >  	if (mem_cgroup_wait_acct_move(mem_over_limit))
> >  		return CHARGE_RETRY;
> >  
> > -	/* If we don't need to call oom-killer at el, return immediately */
> > -	if (!oom_check || !current->memcg_oom.may_oom)
> > -		return CHARGE_NOMEM;
> > -	/* check OOM */
> > -	if (!mem_cgroup_handle_oom(mem_over_limit, gfp_mask))
> > -		return CHARGE_OOM_DIE;
> > +	if (invoke_oom)
> > +		mem_cgroup_oom(mem_over_limit, gfp_mask);
> >  
> > -	return CHARGE_RETRY;
> > +	return CHARGE_NOMEM;
> >  }
> >  
> >  /*
> > @@ -2301,6 +2339,12 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  		goto bypass;
> >  
> >  	/*
> > +	 * Task already OOMed, just get out of here.
> > +	 */
> > +	if (unlikely(current->memcg_oom.memcg))
> > +		goto nomem;
> > +
> > +	/*
> >  	 * We always charge the cgroup the mm_struct belongs to.
> >  	 * The mm_struct's mem_cgroup changes on task migration if the
> >  	 * thread group leader migrates. It's possible that mm is not
> > @@ -2358,7 +2402,7 @@ again:
> >  	}
> >  
> >  	do {
> > -		bool oom_check;
> > +		bool invoke_oom = oom && !nr_oom_retries;
> >  
> >  		/* If killed, bypass charge */
> >  		if (fatal_signal_pending(current)) {
> > @@ -2366,13 +2410,7 @@ again:
> >  			goto bypass;
> >  		}
> >  
> > -		oom_check = false;
> > -		if (oom && !nr_oom_retries) {
> > -			oom_check = true;
> > -			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > -		}
> > -
> > -		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, oom_check);
> > +		ret = mem_cgroup_do_charge(memcg, gfp_mask, batch, invoke_oom);
> >  		switch (ret) {
> >  		case CHARGE_OK:
> >  			break;
> > @@ -2385,16 +2423,12 @@ again:
> >  			css_put(&memcg->css);
> >  			goto nomem;
> >  		case CHARGE_NOMEM: /* OOM routine works */
> > -			if (!oom) {
> > +			if (!oom || invoke_oom) {
> >  				css_put(&memcg->css);
> >  				goto nomem;
> >  			}
> > -			/* If oom, we never return -ENOMEM */
> >  			nr_oom_retries--;
> >  			break;
> > -		case CHARGE_OOM_DIE: /* Killed by OOM Killer */
> > -			css_put(&memcg->css);
> > -			goto bypass;
> >  		}
> >  	} while (ret != CHARGE_OK);
> >  
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 7b66056..20c43a0 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -3517,8 +3517,17 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> >  
> >  	ret = __handle_mm_fault(mm, vma, address, flags);
> >  
> > -	if (flags & FAULT_FLAG_USER)
> > +	if (flags & FAULT_FLAG_USER) {
> >  		mem_cgroup_disable_oom();
> > +		/*
> > +		 * The task may have entered a memcg OOM situation but
> > +		 * if the allocation error was handled gracefully (no
> > +		 * VM_FAULT_OOM), there is no need to kill anything.
> > +		 * Just clean up the OOM state peacefully.
> > +		 */
> > +		if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
> > +			mem_cgroup_oom_synchronize(false);
> > +	}
> >  
> >  	return ret;
> >  }
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 069b64e..3bf664c 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -785,6 +785,8 @@ out:
> >   */
> >  void pagefault_out_of_memory(void)
> >  {
> > +	if (mem_cgroup_oom_synchronize(true))
> > +		return;
> >  	if (try_set_system_oom()) {
> >  		out_of_memory(NULL, 0, 0, NULL);
> >  		clear_system_oom();
> > -- 
> > 1.8.4
> > 
> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
