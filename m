Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 029A66B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 18:34:00 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mz12so3508206bkb.16
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 15:34:00 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id tz2si12940138bkb.283.2013.11.27.15.33.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 15:33:59 -0800 (PST)
Date: Wed, 27 Nov 2013 18:33:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [merged]
 mm-memcg-handle-non-error-oom-situations-more-gracefully.patch removed from
 -mm tree
Message-ID: <20131127233353.GH3556@cmpxchg.org>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org>
 <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 27, 2013 at 03:08:30PM -0800, David Rientjes wrote:
> On Thu, 17 Oct 2013, akpm@linux-foundation.org wrote:
> 
> > diff -puN mm/memcontrol.c~mm-memcg-handle-non-error-oom-situations-more-gracefully mm/memcontrol.c
> > --- a/mm/memcontrol.c~mm-memcg-handle-non-error-oom-situations-more-gracefully
> > +++ a/mm/memcontrol.c
> > @@ -2161,110 +2161,59 @@ static void memcg_oom_recover(struct mem
> >  		memcg_wakeup_oom(memcg);
> >  }
> >  
> > -/*
> > - * try to call OOM killer
> > - */
> >  static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> >  {
> > -	bool locked;
> > -	int wakeups;
> > -
> >  	if (!current->memcg_oom.may_oom)
> >  		return;
> > -
> > -	current->memcg_oom.in_memcg_oom = 1;
> > -
> >  	/*
> > -	 * As with any blocking lock, a contender needs to start
> > -	 * listening for wakeups before attempting the trylock,
> > -	 * otherwise it can miss the wakeup from the unlock and sleep
> > -	 * indefinitely.  This is just open-coded because our locking
> > -	 * is so particular to memcg hierarchies.
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
> >  	 */
> > -	wakeups = atomic_read(&memcg->oom_wakeups);
> > -	mem_cgroup_mark_under_oom(memcg);
> > -
> > -	locked = mem_cgroup_oom_trylock(memcg);
> > -
> > -	if (locked)
> > -		mem_cgroup_oom_notify(memcg);
> > -
> > -	if (locked && !memcg->oom_kill_disable) {
> > -		mem_cgroup_unmark_under_oom(memcg);
> > -		mem_cgroup_out_of_memory(memcg, mask, order);
> > -		mem_cgroup_oom_unlock(memcg);
> > -		/*
> > -		 * There is no guarantee that an OOM-lock contender
> > -		 * sees the wakeups triggered by the OOM kill
> > -		 * uncharges.  Wake any sleepers explicitely.
> > -		 */
> > -		memcg_oom_recover(memcg);
> > -	} else {
> > -		/*
> > -		 * A system call can just return -ENOMEM, but if this
> > -		 * is a page fault and somebody else is handling the
> > -		 * OOM already, we need to sleep on the OOM waitqueue
> > -		 * for this memcg until the situation is resolved.
> > -		 * Which can take some time because it might be
> > -		 * handled by a userspace task.
> > -		 *
> > -		 * However, this is the charge context, which means
> > -		 * that we may sit on a large call stack and hold
> > -		 * various filesystem locks, the mmap_sem etc. and we
> > -		 * don't want the OOM handler to deadlock on them
> > -		 * while we sit here and wait.  Store the current OOM
> > -		 * context in the task_struct, then return -ENOMEM.
> > -		 * At the end of the page fault handler, with the
> > -		 * stack unwound, pagefault_out_of_memory() will check
> > -		 * back with us by calling
> > -		 * mem_cgroup_oom_synchronize(), possibly putting the
> > -		 * task to sleep.
> > -		 */
> > -		current->memcg_oom.oom_locked = locked;
> > -		current->memcg_oom.wakeups = wakeups;
> > -		css_get(&memcg->css);
> > -		current->memcg_oom.wait_on_memcg = memcg;
> > -	}
> > +	css_get(&memcg->css);
> > +	current->memcg_oom.memcg = memcg;
> > +	current->memcg_oom.gfp_mask = mask;
> > +	current->memcg_oom.order = order;
> >  }
> >  
> >  /**
> >   * mem_cgroup_oom_synchronize - complete memcg OOM handling
> > + * @handle: actually kill/wait or just clean up the OOM state
> >   *
> > - * This has to be called at the end of a page fault if the the memcg
> > - * OOM handler was enabled and the fault is returning %VM_FAULT_OOM.
> > + * This has to be called at the end of a page fault if the memcg OOM
> > + * handler was enabled.
> >   *
> > - * Memcg supports userspace OOM handling, so failed allocations must
> > + * Memcg supports userspace OOM handling where failed allocations must
> >   * sleep on a waitqueue until the userspace task resolves the
> >   * situation.  Sleeping directly in the charge context with all kinds
> >   * of locks held is not a good idea, instead we remember an OOM state
> >   * in the task and mem_cgroup_oom_synchronize() has to be called at
> > - * the end of the page fault to put the task to sleep and clean up the
> > - * OOM state.
> > + * the end of the page fault to complete the OOM handling.
> >   *
> >   * Returns %true if an ongoing memcg OOM situation was detected and
> > - * finalized, %false otherwise.
> > + * completed, %false otherwise.
> >   */
> > -bool mem_cgroup_oom_synchronize(void)
> > +bool mem_cgroup_oom_synchronize(bool handle)
> >  {
> > +	struct mem_cgroup *memcg = current->memcg_oom.memcg;
> >  	struct oom_wait_info owait;
> > -	struct mem_cgroup *memcg;
> > +	bool locked;
> >  
> >  	/* OOM is global, do not handle */
> > -	if (!current->memcg_oom.in_memcg_oom)
> > -		return false;
> > -
> > -	/*
> > -	 * We invoked the OOM killer but there is a chance that a kill
> > -	 * did not free up any charges.  Everybody else might already
> > -	 * be sleeping, so restart the fault and keep the rampage
> > -	 * going until some charges are released.
> > -	 */
> > -	memcg = current->memcg_oom.wait_on_memcg;
> >  	if (!memcg)
> > -		goto out;
> > +		return false;
> >  
> > -	if (test_thread_flag(TIF_MEMDIE) || fatal_signal_pending(current))
> > -		goto out_memcg;
> > +	if (!handle)
> > +		goto cleanup;
> >  
> >  	owait.memcg = memcg;
> >  	owait.wait.flags = 0;
> > @@ -2273,13 +2222,25 @@ bool mem_cgroup_oom_synchronize(void)
> >  	INIT_LIST_HEAD(&owait.wait.task_list);
> >  
> >  	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> > -	/* Only sleep if we didn't miss any wakeups since OOM */
> > -	if (atomic_read(&memcg->oom_wakeups) == current->memcg_oom.wakeups)
> > +	mem_cgroup_mark_under_oom(memcg);
> > +
> > +	locked = mem_cgroup_oom_trylock(memcg);
> > +
> > +	if (locked)
> > +		mem_cgroup_oom_notify(memcg);
> > +
> > +	if (locked && !memcg->oom_kill_disable) {
> > +		mem_cgroup_unmark_under_oom(memcg);
> > +		finish_wait(&memcg_oom_waitq, &owait.wait);
> > +		mem_cgroup_out_of_memory(memcg, current->memcg_oom.gfp_mask,
> > +					 current->memcg_oom.order);
> > +	} else {
> >  		schedule();
> > -	finish_wait(&memcg_oom_waitq, &owait.wait);
> > -out_memcg:
> > -	mem_cgroup_unmark_under_oom(memcg);
> > -	if (current->memcg_oom.oom_locked) {
> > +		mem_cgroup_unmark_under_oom(memcg);
> > +		finish_wait(&memcg_oom_waitq, &owait.wait);
> > +	}
> > +
> > +	if (locked) {
> >  		mem_cgroup_oom_unlock(memcg);
> >  		/*
> >  		 * There is no guarantee that an OOM-lock contender
> > @@ -2288,10 +2249,9 @@ out_memcg:
> >  		 */
> >  		memcg_oom_recover(memcg);
> >  	}
> > +cleanup:
> > +	current->memcg_oom.memcg = NULL;
> >  	css_put(&memcg->css);
> > -	current->memcg_oom.wait_on_memcg = NULL;
> > -out:
> > -	current->memcg_oom.in_memcg_oom = 0;
> >  	return true;
> >  }
> >  
> > @@ -2705,6 +2665,9 @@ static int __mem_cgroup_try_charge(struc
> >  		     || fatal_signal_pending(current)))
> >  		goto bypass;
> >  
> > +	if (unlikely(task_in_memcg_oom(current)))
> > +		goto bypass;
> > +
> >  	/*
> >  	 * We always charge the cgroup the mm_struct belongs to.
> >  	 * The mm_struct's mem_cgroup changes on task migration if the
> 
> First, apologies that I didn't look at all these changes earlier even 
> though I was cc'd.
> 
> The memcg oom killer has incurred a serious regression since the 3.12-rc6 
> kernel where this was merged as 4942642080ea ("mm: memcg: handle non-error 
> OOM situations more gracefully").  It cc'd stable@kernel.org although it 
> doesn't appear to have been picked up yet, and I'm hoping that we can 
> avoid having it merged in a stable kernel until we get this fixed.
> 
> This patch, specifically the above, allows memcgs to bypass their limits 
> by charging the root memcg in oom conditions.
> 
> If I create a memcg, cg1, with memory.limit_in_bytes == 128MB and start a
> memory allocator in it to induce oom, the memcg limit is trivially broken:
> 
> membench invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
> membench cpuset=/ mems_allowed=0-3
> CPU: 9 PID: 11388 Comm: membench Not tainted 3.13-rc1
>  ffffc90015ec6000 ffff880671c3dc18 ffffffff8154a1e3 0000000000000007
>  ffff880674c215d0 ffff880671c3dc98 ffffffff81548b45 ffff880671c3dc58
>  ffffffff81151de7 0000000000000001 0000000000000292 ffff880800000000
> Call Trace:
>  [<ffffffff8154a1e3>] dump_stack+0x46/0x58
>  [<ffffffff81548b45>] dump_header+0x7a/0x1bb
>  [<ffffffff81151de7>] ? find_lock_task_mm+0x27/0x70
>  [<ffffffff812e8b76>] ? ___ratelimit+0x96/0x110
>  [<ffffffff811521c4>] oom_kill_process+0x1c4/0x330
>  [<ffffffff81099ee5>] ? has_ns_capability_noaudit+0x15/0x20
>  [<ffffffff811a916a>] mem_cgroup_oom_synchronize+0x50a/0x570
>  [<ffffffff811a8660>] ? __mem_cgroup_try_charge_swapin+0x70/0x70
>  [<ffffffff81152968>] pagefault_out_of_memory+0x18/0x90
>  [<ffffffff81547b86>] mm_fault_error+0xb7/0x15a
>  [<ffffffff81553efb>] __do_page_fault+0x42b/0x500
>  [<ffffffff810c667d>] ? set_next_entity+0xad/0xd0
>  [<ffffffff810c670b>] ? pick_next_task_fair+0x6b/0x170
>  [<ffffffff8154d08e>] ? __schedule+0x38e/0x780
>  [<ffffffff81553fde>] do_page_fault+0xe/0x10
>  [<ffffffff815509e2>] page_fault+0x22/0x30
> Task in /cg1 killed as a result of limit of /cg1
> memory: usage 131072kB, limit 131072kB, failcnt 1053
> memory+swap: usage 0kB, limit 18014398509481983kB, failcnt 0
> kmem: usage 0kB, limit 18014398509481983kB, failcnt 0
> Memory cgroup stats for /cg1: cache:84KB rss:130988KB rss_huge:116736KB mapped_file:72KB writeback:0KB inactive_anon:0KB active_anon:130976KB inactive_file:4KB active_file:0KB unevictable:0KB
> [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
> [ 7761]     0  7761     1106      483       5        0             0 bash
> [11388]    99 11388   270773    33031      83        0             0 membench
> Memory cgroup out of memory: Kill process 11388 (membench) score 1010 or sacrifice child
> Killed process 11388 (membench) total-vm:1083092kB, anon-rss:130824kB, file-rss:1300kB
> 
> The score of 1010 shown for pid 11388 (membench) should never happen in 
> the oom killer, the maximum value should always be 1000 in any oom 
> context.  This indicates that the process has allocated more memory than 
> is available to the memcg.  The rss value, 33031 pages, shows that it has 
> allocated >129MB of memory in a memcg limited to 128MB.
> 
> The entire premise of memcg is to prevent processes attached to it to not 
> be able to allocate more memory than allowed and this trivially breaks 
> that premise in oom conditions.

We already allow a task to allocate beyond the limit if it's selected
by the OOM killer, so that it can exit faster.

My patch added that a task can bypass the limit when it decided to
trigger the OOM killer, so that it can get to the OOM kill faster.

So I don't think my patch has broken "the entire premise of memcgs".
At the same time, it also does not really rely on that bypass, we
should be able to remove it.

This patch series was not supposed to go into the last merge window, I
already told stable to hold off on these until further notice.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 13b9d0f..5f9e467 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2675,7 +2675,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 		goto bypass;
 
 	if (unlikely(task_in_memcg_oom(current)))
-		goto bypass;
+		goto nomem;
 
 	/*
 	 * We always charge the cgroup the mm_struct belongs to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
