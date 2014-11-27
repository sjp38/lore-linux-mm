Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A9CD46B0069
	for <linux-mm@kvack.org>; Wed, 26 Nov 2014 19:26:27 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id a1so5127644wgh.39
        for <linux-mm@kvack.org>; Wed, 26 Nov 2014 16:26:27 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id a5si9137477wjy.155.2014.11.26.16.26.26
        for <linux-mm@kvack.org>;
        Wed, 26 Nov 2014 16:26:26 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [RFC 2/2] OOM, PM: make OOM detection in the freezer path raceless
Date: Thu, 27 Nov 2014 01:47:42 +0100
Message-ID: <6460796.RIZxga0pMR@vostro.rjw.lan>
In-Reply-To: <1416345006-8284-2-git-send-email-mhocko@suse.cz>
References: <20141118210833.GE23640@dhcp22.suse.cz> <1416345006-8284-1-git-send-email-mhocko@suse.cz> <1416345006-8284-2-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-pm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>

On Tuesday, November 18, 2014 10:10:06 PM Michal Hocko wrote:
> 5695be142e20 (OOM, PM: OOM killed task shouldn't escape PM suspend)
> has left a race window when OOM killer manages to note_oom_kill after
> freeze_processes checks the counter. The race window is quite small and
> really unlikely and partial solution deemed sufficient at the time of
> submission.
> 
> Tejun wasn't happy about this partial solution though and insisted on a
> full solution. That requires the full OOM and freezer's task freezing
> exclusion, though. This is done by this patch which introduces oom_sem
> RW lock and turns oom_killer_disable() into a full OOM barrier.
> 
> oom_killer_disabled is now checked at out_of_memory level which takes
> the lock for reading. This also means that the page fault path is
> covered now as well although it was assumed to be safe before. As per
> Tejun, "We used to have freezing points deep in file system code which
> may be reacheable from page fault." so it would be better and more
> robust to not rely on freezing points here. Same applies to the memcg
> OOM killer.
> 
> out_of_memory tells the caller whether the OOM was allowed to
> trigger and the callers are supposed to handle the situation. The page
> allocation path simply fails the allocation same as before. The page
> fault path will be retrying the fault until the freezer fails and Sysrq
> OOM trigger will simply complain to the log.
> 
> oom_killer_disable takes oom_sem for writing and after it disables
> further OOM killer invocations it checks for any OOM victims which
> are still alive (because they haven't woken up to handle the pending
> signal). Victims are counted via {un}mark_tsk_oom_victim. The
> last victim signals the completion via oom_victims_wait on which
> oom_killer_disable() waits if it sees non zero oom_victims.
> This is safe against both mark_tsk_oom_victim which cannot be called
> after oom_killer_disabled is set and unmark_tsk_oom_victim signals the
> completion only for the last oom_victim when oom is disabled and
> oom_killer_disable waits for completion only of there was at least one
> victim at the time it disabled the oom.
> 
> As oom_killer_disable is a full OOM barrier now we can postpone it to
> later after all freezable tasks are frozen during PM freezer. This
> reduces the time when OOM is put out order and so reduces chances of
> misbehavior due to unexpected allocation failures.
> 
> TODO:
> Android lowmemory killer abuses mark_tsk_oom_victim in lowmem_scan
> and it has to learn about oom_disable logic as well.
> 
> Suggested-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

This appears to do the right thing to me, although I admit I haven't checked
the details very carefully.

Tejun?

> ---
>  drivers/tty/sysrq.c    |  6 ++--
>  include/linux/oom.h    | 26 ++++++++------
>  kernel/power/process.c | 60 +++++++++-----------------------
>  mm/memcontrol.c        |  4 ++-
>  mm/oom_kill.c          | 94 +++++++++++++++++++++++++++++++++++++++++---------
>  mm/page_alloc.c        | 32 ++++++++---------
>  6 files changed, 132 insertions(+), 90 deletions(-)
> 
> diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
> index 42bad18c66c9..6818589c1004 100644
> --- a/drivers/tty/sysrq.c
> +++ b/drivers/tty/sysrq.c
> @@ -355,8 +355,10 @@ static struct sysrq_key_op sysrq_term_op = {
>  
>  static void moom_callback(struct work_struct *ignored)
>  {
> -	out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL), GFP_KERNEL,
> -		      0, NULL, true);
> +	if (!out_of_memory(node_zonelist(first_memory_node, GFP_KERNEL),
> +			   GFP_KERNEL, 0, NULL, true)) {
> +		printk(KERN_INFO "OOM request ignored because killer is disabled\n");
> +	}
>  }
>  
>  static DECLARE_WORK(moom_work, moom_callback);
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 8f7e74f8ab3a..d802575c9307 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -72,22 +72,26 @@ extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
>  		unsigned long totalpages, const nodemask_t *nodemask,
>  		bool force_kill);
>  
> -extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> +extern bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		int order, nodemask_t *mask, bool force_kill);
>  extern int register_oom_notifier(struct notifier_block *nb);
>  extern int unregister_oom_notifier(struct notifier_block *nb);
>  
> -extern bool oom_killer_disabled;
> -
> -static inline void oom_killer_disable(void)
> -{
> -	oom_killer_disabled = true;
> -}
> +/**
> + * oom_killer_disable - disable OOM killer
> + *
> + * Forces all page allocations to fail rather than trigger OOM killer.
> + * Will block and wait until all OOM victims are dead.
> + *
> + * Returns true if successfull and false if the OOM killer cannot be
> + * disabled.
> + */
> +extern bool oom_killer_disable(void);
>  
> -static inline void oom_killer_enable(void)
> -{
> -	oom_killer_disabled = false;
> -}
> +/**
> + * oom_killer_enable - enable OOM killer
> + */
> +extern void oom_killer_enable(void);
>  
>  static inline bool oom_gfp_allowed(gfp_t gfp_mask)
>  {
> diff --git a/kernel/power/process.c b/kernel/power/process.c
> index 5a6ec8678b9a..a4306e39f35c 100644
> --- a/kernel/power/process.c
> +++ b/kernel/power/process.c
> @@ -108,30 +108,6 @@ static int try_to_freeze_tasks(bool user_only)
>  	return todo ? -EBUSY : 0;
>  }
>  
> -static bool __check_frozen_processes(void)
> -{
> -	struct task_struct *g, *p;
> -
> -	for_each_process_thread(g, p)
> -		if (p != current && !freezer_should_skip(p) && !frozen(p))
> -			return false;
> -
> -	return true;
> -}
> -
> -/*
> - * Returns true if all freezable tasks (except for current) are frozen already
> - */
> -static bool check_frozen_processes(void)
> -{
> -	bool ret;
> -
> -	read_lock(&tasklist_lock);
> -	ret = __check_frozen_processes();
> -	read_unlock(&tasklist_lock);
> -	return ret;
> -}
> -
>  /**
>   * freeze_processes - Signal user space processes to enter the refrigerator.
>   * The current thread will not be frozen.  The same process that calls
> @@ -142,7 +118,6 @@ static bool check_frozen_processes(void)
>  int freeze_processes(void)
>  {
>  	int error;
> -	int oom_kills_saved;
>  
>  	error = __usermodehelper_disable(UMH_FREEZING);
>  	if (error)
> @@ -157,27 +132,11 @@ int freeze_processes(void)
>  	pm_wakeup_clear();
>  	printk("Freezing user space processes ... ");
>  	pm_freezing = true;
> -	oom_kills_saved = oom_kills_count();
>  	error = try_to_freeze_tasks(true);
>  	if (!error) {
>  		__usermodehelper_set_disable_depth(UMH_DISABLED);
> -		oom_killer_disable();
> -
> -		/*
> -		 * There might have been an OOM kill while we were
> -		 * freezing tasks and the killed task might be still
> -		 * on the way out so we have to double check for race.
> -		 */
> -		if (oom_kills_count() != oom_kills_saved &&
> -		    !check_frozen_processes()) {
> -			__usermodehelper_set_disable_depth(UMH_ENABLED);
> -			printk("OOM in progress.");
> -			error = -EBUSY;
> -		} else {
> -			printk("done.");
> -		}
> +		printk("done.\n");
>  	}
> -	printk("\n");
>  	BUG_ON(in_atomic());
>  
>  	if (error)
> @@ -206,6 +165,18 @@ int freeze_kernel_threads(void)
>  	printk("\n");
>  	BUG_ON(in_atomic());
>  
> +	/*
> +	 * Now that everything freezable is handled we need to disbale
> +	 * the OOM killer to disallow any further interference with
> +	 * killable tasks.
> +	 */
> +	printk("Disabling OOM killer ... ");
> +	if (!oom_killer_disable()) {
> +		printk("failed.\n");
> +		error = -EAGAIN;
> +	} else
> +		printk("done.\n");
> +
>  	if (error)
>  		thaw_kernel_threads();
>  	return error;
> @@ -222,8 +193,6 @@ void thaw_processes(void)
>  	pm_freezing = false;
>  	pm_nosig_freezing = false;
>  
> -	oom_killer_enable();
> -
>  	printk("Restarting tasks ... ");
>  
>  	__usermodehelper_set_disable_depth(UMH_FREEZING);
> @@ -251,6 +220,9 @@ void thaw_kernel_threads(void)
>  {
>  	struct task_struct *g, *p;
>  
> +	printk("Enabling OOM killer again.\n");
> +	oom_killer_enable();
> +
>  	pm_nosig_freezing = false;
>  	printk("Restarting kernel threads ... ");
>  
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 302e0fc6d121..34bcbb053132 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2128,6 +2128,8 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
>  	current->memcg_oom.order = order;
>  }
>  
> +extern bool oom_killer_disabled;
> +
>  /**
>   * mem_cgroup_oom_synchronize - complete memcg OOM handling
>   * @handle: actually kill/wait or just clean up the OOM state
> @@ -2155,7 +2157,7 @@ bool mem_cgroup_oom_synchronize(bool handle)
>  	if (!memcg)
>  		return false;
>  
> -	if (!handle)
> +	if (!handle || oom_killer_disabled)
>  		goto cleanup;
>  
>  	owait.memcg = memcg;
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 8b6e14136f4f..b3ccd92bc6dc 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -405,30 +405,63 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>  }
>  
>  /*
> - * Number of OOM killer invocations (including memcg OOM killer).
> - * Primarily used by PM freezer to check for potential races with
> - * OOM killed frozen task.
> + * Number of OOM victims in flight
>   */
> -static atomic_t oom_kills = ATOMIC_INIT(0);
> +static atomic_t oom_victims = ATOMIC_INIT(0);
> +static DECLARE_COMPLETION(oom_victims_wait);
>  
> -int oom_kills_count(void)
> +bool oom_killer_disabled __read_mostly;
> +static DECLARE_RWSEM(oom_sem);
> +
> +void mark_tsk_oom_victim(struct task_struct *tsk)
>  {
> -	return atomic_read(&oom_kills);
> +	BUG_ON(oom_killer_disabled);
> +	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> +		return;
> +	atomic_inc(&oom_victims);
>  }
>  
> -void note_oom_kill(void)
> +void unmark_tsk_oom_victim(struct task_struct *tsk)
>  {
> -	atomic_inc(&oom_kills);
> +	int count;
> +
> +	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
> +		return;
> +
> +	down_read(&oom_sem);
> +	/*
> +	 * There is no need to signal the lasst oom_victim if there
> +	 * is nobody who cares.
> +	 */
> +	if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
> +		complete(&oom_victims_wait);
> +	up_read(&oom_sem);
>  }
>  
> -void mark_tsk_oom_victim(struct task_struct *tsk)
> +bool oom_killer_disable(void)
>  {
> -	set_tsk_thread_flag(tsk, TIF_MEMDIE);
> +	/*
> +	 * Make sure to not race with an ongoing OOM killer
> +	 * and that the current is not the victim.
> +	 */
> +	down_write(&oom_sem);
> +	if (!test_tsk_thread_flag(current, TIF_MEMDIE))
> +		oom_killer_disabled = true;
> +
> +	count = atomic_read(&oom_victims);
> +	up_write(&oom_sem);
> +
> +	if (count && oom_killer_disabled)
> +		wait_for_completion(&oom_victims_wait);
> +
> +	return oom_killer_disabled;
>  }
>  
> -void unmark_tsk_oom_victim(struct task_struct *tsk)
> +void oom_killer_enable(void)
>  {
> -	clear_thread_flag(TIF_MEMDIE);
> +	down_write(&oom_sem);
> +	oom_killer_disabled = false;
> +	up_write(&oom_sem);
>  }
>  
>  #define K(x) ((x) << (PAGE_SHIFT-10))
> @@ -626,7 +659,7 @@ void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_mask)
>  }
>  
>  /**
> - * out_of_memory - kill the "best" process when we run out of memory
> + * __out_of_memory - kill the "best" process when we run out of memory
>   * @zonelist: zonelist pointer
>   * @gfp_mask: memory allocation flags
>   * @order: amount of memory being requested as a power of 2
> @@ -638,7 +671,7 @@ void oom_zonelist_unlock(struct zonelist *zonelist, gfp_t gfp_mask)
>   * OR try to be smart about which process to kill. Note that we
>   * don't have to be perfect here, we just have to be good.
>   */
> -void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> +static void __out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		int order, nodemask_t *nodemask, bool force_kill)
>  {
>  	const nodemask_t *mpol_mask;
> @@ -703,6 +736,31 @@ out:
>  		schedule_timeout_killable(1);
>  }
>  
> +/** out_of_memory -  tries to invoke OOM killer.
> + * @zonelist: zonelist pointer
> + * @gfp_mask: memory allocation flags
> + * @order: amount of memory being requested as a power of 2
> + * @nodemask: nodemask passed to page allocator
> + * @force_kill: true if a task must be killed, even if others are exiting
> + *
> + * invokes __out_of_memory if the OOM is not disabled by oom_killer_disable()
> + * when it returns false. Otherwise returns true.
> + */
> +bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
> +		int order, nodemask_t *nodemask, bool force_kill)
> +{
> +	bool ret = false;
> +
> +	down_read(&oom_sem);
> +	if (!oom_killer_disabled) {
> +		__out_of_memory(zonelist, gfp_mask, order, nodemask, force_kill);
> +		ret = true;
> +	}
> +	up_read(&oom_sem);
> +
> +	return ret;
> +}
> +
>  /*
>   * The pagefault handler calls here because it is out of memory, so kill a
>   * memory-hogging task.  If any populated zone has ZONE_OOM_LOCKED set, a
> @@ -712,12 +770,16 @@ void pagefault_out_of_memory(void)
>  {
>  	struct zonelist *zonelist;
>  
> +	down_read(&oom_sem);
>  	if (mem_cgroup_oom_synchronize(true))
> -		return;
> +		goto unlock;
>  
>  	zonelist = node_zonelist(first_memory_node, GFP_KERNEL);
>  	if (oom_zonelist_trylock(zonelist, GFP_KERNEL)) {
> -		out_of_memory(NULL, 0, 0, NULL, false);
> +		if (!oom_killer_disabled)
> +			__out_of_memory(NULL, 0, 0, NULL, false);
>  		oom_zonelist_unlock(zonelist, GFP_KERNEL);
>  	}
> +unlock:
> +	up_read(&oom_sem);
>  }
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9cd36b822444..d44d69aa7b70 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -242,8 +242,6 @@ void set_pageblock_migratetype(struct page *page, int migratetype)
>  					PB_migrate, PB_migrate_end);
>  }
>  
> -bool oom_killer_disabled __read_mostly;
> -
>  #ifdef CONFIG_DEBUG_VM
>  static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
>  {
> @@ -2241,10 +2239,11 @@ static inline struct page *
>  __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	struct zonelist *zonelist, enum zone_type high_zoneidx,
>  	nodemask_t *nodemask, struct zone *preferred_zone,
> -	int classzone_idx, int migratetype)
> +	int classzone_idx, int migratetype, bool *oom_failed)
>  {
>  	struct page *page;
>  
> +	*oom_failed = false;
>  	/* Acquire the per-zone oom lock for each zone */
>  	if (!oom_zonelist_trylock(zonelist, gfp_mask)) {
>  		schedule_timeout_uninterruptible(1);
> @@ -2252,14 +2251,6 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  	}
>  
>  	/*
> -	 * PM-freezer should be notified that there might be an OOM killer on
> -	 * its way to kill and wake somebody up. This is too early and we might
> -	 * end up not killing anything but false positives are acceptable.
> -	 * See freeze_processes.
> -	 */
> -	note_oom_kill();
> -
> -	/*
>  	 * Go through the zonelist yet one more time, keep very high watermark
>  	 * here, this is only to catch a parallel oom killing, we must fail if
>  	 * we're still under heavy pressure.
> @@ -2289,8 +2280,8 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  			goto out;
>  	}
>  	/* Exhausted what can be done so it's blamo time */
> -	out_of_memory(zonelist, gfp_mask, order, nodemask, false);
> -
> +	if (!out_of_memory(zonelist, gfp_mask, order, nodemask, false))
> +		*oom_failed = true;
>  out:
>  	oom_zonelist_unlock(zonelist, gfp_mask);
>  	return page;
> @@ -2716,8 +2707,8 @@ rebalance:
>  	 */
>  	if (!did_some_progress) {
>  		if (oom_gfp_allowed(gfp_mask)) {
> -			if (oom_killer_disabled)
> -				goto nopage;
> +			bool oom_failed;
> +
>  			/* Coredumps can quickly deplete all memory reserves */
>  			if ((current->flags & PF_DUMPCORE) &&
>  			    !(gfp_mask & __GFP_NOFAIL))
> @@ -2725,10 +2716,19 @@ rebalance:
>  			page = __alloc_pages_may_oom(gfp_mask, order,
>  					zonelist, high_zoneidx,
>  					nodemask, preferred_zone,
> -					classzone_idx, migratetype);
> +					classzone_idx, migratetype,
> +					&oom_failed);
> +
>  			if (page)
>  				goto got_pg;
>  
> +			/*
> +			 * OOM killer might be disabled and then we have to
> +			 * fail the allocation
> +			 */
> +			if (oom_failed)
> +				goto nopage;
> +
>  			if (!(gfp_mask & __GFP_NOFAIL)) {
>  				/*
>  				 * The oom killer is not called for high-order
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
