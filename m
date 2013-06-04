Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id E284C6B007D
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 05:17:52 -0400 (EDT)
Date: Tue, 4 Jun 2013 11:17:49 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-ID: <20130604091749.GB31242@dhcp22.suse.cz>
References: <20130530150539.GA18155@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305301338430.20389@chino.kir.corp.google.com>
 <20130531081052.GA32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305310316210.27716@chino.kir.corp.google.com>
 <20130531112116.GC32491@dhcp22.suse.cz>
 <alpine.DEB.2.02.1305311224330.3434@chino.kir.corp.google.com>
 <20130601061151.GC15576@cmpxchg.org>
 <20130603153432.GC18588@dhcp22.suse.cz>
 <20130603164839.GG15576@cmpxchg.org>
 <20130603183018.GJ15576@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603183018.GJ15576@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon 03-06-13 14:30:18, Johannes Weiner wrote:
> On Mon, Jun 03, 2013 at 12:48:39PM -0400, Johannes Weiner wrote:
> > On Mon, Jun 03, 2013 at 05:34:32PM +0200, Michal Hocko wrote:
[...]
> > > I am just afraid about all the other archs that do not support (from
> > > quick grep it looks like: blackfin, c6x, h8300, metag, mn10300,
> > > openrisc, score and tile). What would be an alternative for them?
> > > #ifdefs for the old code (something like ARCH_HAS_FAULT_OOM_RETRY)? This
> > > would be acceptable for me.
> > 
> > blackfin is NOMMU but I guess the others should be converted to the
> > proper OOM protocol anyway and not just kill the faulting task.  I can
> > update them in the next version of the patch (series).
> 
> It's no longer necessary since I remove the arch-specific flag
> setting, but I converted them anyway while I was at it.  Will send
> them as a separate patch.

I am still not sure doing this unconditionally is the right way. Say
that a new arch will be added. How the poor implementer knows that memcg
oom handling requires an arch specific code to work properly?

So while I obviously do not have anything agains your conversion of
other archs that are in the tree currently I think we need something
like CONFIG_OLD_VERSION_MEMCG_OOM which depends on ARCH_HAS_FAULT_OOM_RETRY.

[...]
> > > > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > > > index e692a02..cf60aef 100644
> > > > --- a/include/linux/sched.h
> > > > +++ b/include/linux/sched.h
> > > > @@ -1282,6 +1282,8 @@ struct task_struct {
> > > >  				 * execve */
> > > >  	unsigned in_iowait:1;
> > > >  
> > > > +	unsigned in_userfault:1;
> > > > +
> > > 
> > > [This is more a nit pick but before I forget while I am reading through
> > > the rest of the patch.]
> > > 
> > > OK there is a lot of room around those bit fields but as this is only
> > > for memcg and you are enlarging the structure by the pointer then you
> > > can reuse bottom bit of memcg pointer.
> > 
> > I just didn't want to put anything in the arch code that looks too
> > memcgish, even though it's the only user right now.  But granted, it
> > will also probably remain the only user for a while.
> 
> I tried a couple of variants, including using the lowest memcg bit,
> but it all turned into more ugliness.  So that .in_userfault is still
> there in v2, but it's now set in handle_mm_fault() in a generic manner
> depending on a fault flag, please reconsider if you can live with it.

Sure thing.

[...]
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [PATCH] memcg: do not sleep on OOM waitqueue with full charge context
> 
> The memcg OOM handling is incredibly fragile because once a memcg goes
> OOM, one task (kernel or userspace) is responsible for resolving the
> situation.  Every other task that gets caught trying to charge memory
> gets stuck in a waitqueue while potentially holding various filesystem
> and mm locks on which the OOM handling task may now deadlock.
> 
> Do two things:
> 
> 1. When OOMing in a system call (buffered IO and friends), invoke the
>    OOM killer but do not trap other tasks and just return -ENOMEM for
>    everyone.  Userspace should be able to handle this... right?
> 
> 2. When OOMing in a page fault, invoke the OOM killer but do not trap
>    other chargers directly in the charging code.  Instead, remember
>    the OOMing memcg in the task struct and then fully unwind the page
>    fault stack first.  Then synchronize the memcg OOM from
>    pagefault_out_of_memory().
> 
> While reworking the OOM routine, also remove a needless OOM waitqueue
> wakeup when invoking the killer.  Only uncharges and limit increases,
> things that actually change the memory situation, should do wakeups.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/memcontrol.h |   6 +++
>  include/linux/mm.h         |   1 +
>  include/linux/sched.h      |   6 +++
>  mm/ksm.c                   |   2 +-
>  mm/memcontrol.c            | 117 +++++++++++++++++++++++----------------------
>  mm/memory.c                |  40 +++++++++++-----
>  mm/oom_kill.c              |   7 ++-
>  7 files changed, 108 insertions(+), 71 deletions(-)
> 
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index de22292..97cf32b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
[...]
> @@ -2179,56 +2181,72 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
>  }
>  
>  /*
> - * try to call OOM killer. returns false if we should exit memory-reclaim loop.
> + * try to call OOM killer
>   */
> -static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask,
> -				  int order)
> +static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
>  {
> -	struct oom_wait_info owait;
> -	bool locked, need_to_kill;
> -
> -	owait.memcg = memcg;
> -	owait.wait.flags = 0;
> -	owait.wait.func = memcg_oom_wake_function;
> -	owait.wait.private = current;
> -	INIT_LIST_HEAD(&owait.wait.task_list);
> -	need_to_kill = true;
> -	mem_cgroup_mark_under_oom(memcg);
> +	bool locked, need_to_kill = true;
>  
>  	/* At first, try to OOM lock hierarchy under memcg.*/
>  	spin_lock(&memcg_oom_lock);
>  	locked = mem_cgroup_oom_lock(memcg);
> -	/*
> -	 * Even if signal_pending(), we can't quit charge() loop without
> -	 * accounting. So, UNINTERRUPTIBLE is appropriate. But SIGKILL
> -	 * under OOM is always welcomed, use TASK_KILLABLE here.
> -	 */
> -	prepare_to_wait(&memcg_oom_waitq, &owait.wait, TASK_KILLABLE);
> -	if (!locked || memcg->oom_kill_disable)
> +	if (!locked || memcg->oom_kill_disable) {
>  		need_to_kill = false;
> +		if (current->in_userfault) {
> +			/*
> +			 * We start sleeping on the OOM waitqueue only
> +			 * after unwinding the page fault stack, so
> +			 * make sure we detect wakeups that happen
> +			 * between now and then.
> +			 */
> +			mem_cgroup_mark_under_oom(memcg);
> +			current->memcg_oom.wakeups =
> +				atomic_read(&memcg->oom_wakeups);
> +			css_get(&memcg->css);
> +			current->memcg_oom.memcg = memcg;
> +		}
> +	}
>  	if (locked)
>  		mem_cgroup_oom_notify(memcg);
>  	spin_unlock(&memcg_oom_lock);
>  
> -	if (need_to_kill) {
> -		finish_wait(&memcg_oom_waitq, &owait.wait);
> +	if (need_to_kill)
>  		mem_cgroup_out_of_memory(memcg, mask, order);

Now that I am looking at this again I've realized that this
is not correct. The task which triggers memcg OOM will not
have memcg_oom.memcg set so it would trigger a global OOM in
pagefault_out_of_memory. Either we should return CHARGE_RETRY (and
propagate it via mem_cgroup_do_charge) for need_to_kill or set up
current->memcg_oom also for need_to_kill.

Or am I missing something?

> -	} else {
> -		schedule();
> -		finish_wait(&memcg_oom_waitq, &owait.wait);
> -	}
> -	spin_lock(&memcg_oom_lock);
> -	if (locked)
> +
> +	if (locked) {
> +		spin_lock(&memcg_oom_lock);
>  		mem_cgroup_oom_unlock(memcg);
> -	memcg_wakeup_oom(memcg);
> -	spin_unlock(&memcg_oom_lock);
> +		spin_unlock(&memcg_oom_lock);
> +	}
> +}
[...]
> diff --git a/mm/memory.c b/mm/memory.c
> index 6dc1882..ff5e2d7 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1815,7 +1815,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  			while (!(page = follow_page_mask(vma, start,
>  						foll_flags, &page_mask))) {
>  				int ret;
> -				unsigned int fault_flags = 0;
> +				unsigned int fault_flags = FAULT_FLAG_KERNEL;
>  
>  				/* For mlock, just skip the stack guard page. */
>  				if (foll_flags & FOLL_MLOCK) {

This is also a bit tricky. Say there is an unlikely situation when a
task fails to charge because of memcg OOM, it couldn't lock the oom
so it ended up with current->memcg_oom set and __get_user_pages will
turn VM_FAULT_OOM into ENOMEM but memcg_oom is still there. Then the
following global OOM condition gets confused (well the oom will be
triggered by somebody else so it shouldn't end up in the endless loop
but still...), doesn't it?

So maybe we need a handle_mm_fault variant called outside of the page
fault path which clears the things up.

> @@ -3760,22 +3761,14 @@ unlock:
>  /*
>   * By the time we get here, we already hold the mm semaphore
>   */
> -int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> -		unsigned long address, unsigned int flags)
> +static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> +			     unsigned long address, unsigned int flags)

Is this reusable? Who would call this helper or is it just for the code
readability? I would probably prefer a smaller patch but I do not have a
strong opinion on this.

>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
>  	pmd_t *pmd;
>  	pte_t *pte;
>  
> -	__set_current_state(TASK_RUNNING);
> -
> -	count_vm_event(PGFAULT);
> -	mem_cgroup_count_vm_event(mm, PGFAULT);
> -
> -	/* do counter updates before entering really critical section. */
> -	check_sync_rss_stat(current);
> -
>  	if (unlikely(is_vm_hugetlb_page(vma)))
>  		return hugetlb_fault(mm, vma, address, flags);
>  
> @@ -3856,6 +3849,31 @@ retry:
>  	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
>  }
>  
> +int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> +		    unsigned long address, unsigned int flags)
> +{
> +	int in_userfault = !(flags & FAULT_FLAG_KERNEL);
> +	int ret;
> +
> +	__set_current_state(TASK_RUNNING);
> +
> +	count_vm_event(PGFAULT);
> +	mem_cgroup_count_vm_event(mm, PGFAULT);
> +
> +	/* do counter updates before entering really critical section. */
> +	check_sync_rss_stat(current);
> +
> +	if (in_userfault)
> +		current->in_userfault = 1;

If this is just memcg thing (although you envision future usage outside
of memcg) then would it make more sense to use a memcg helper here which
would be noop for !CONFIG_MEMCG and disabled for mem_cgroup_disabled.

> +
> +	ret = __handle_mm_fault(mm, vma, address, flags);
> +
> +	if (in_userfault)
> +		current->in_userfault = 0;
> +
> +	return ret;
> +}
> +
>  #ifndef __PAGETABLE_PUD_FOLDED
>  /*
>   * Allocate page upper directory.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
