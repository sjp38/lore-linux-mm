Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C56AA6B021B
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 22:23:28 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3O2NP9Y014878
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 24 Apr 2010 11:23:26 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E6B245DE7A
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:23:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 49D7545DE4D
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:23:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A2991DB8037
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:23:25 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C5F1B1DB803E
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 11:23:24 +0900 (JST)
Date: Sat, 24 Apr 2010 11:19:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 1/5] memcg: disable irq at page cgroup lock
Message-Id: <20100424111923.97565bcd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <xr93k4rxx6sd.fsf@ninji.mtv.corp.google.com>
References: <1268609202-15581-2-git-send-email-arighi@develer.com>
	<20100318133527.420b2f25.kamezawa.hiroyu@jp.fujitsu.com>
	<20100318162855.GG18054@balbir.in.ibm.com>
	<20100319102332.f1d81c8d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100319024039.GH18054@balbir.in.ibm.com>
	<20100319120049.3dbf8440.kamezawa.hiroyu@jp.fujitsu.com>
	<xr931veiplpr.fsf@ninji.mtv.corp.google.com>
	<20100414140523.GC13535@redhat.com>
	<xr9339yxyepc.fsf@ninji.mtv.corp.google.com>
	<20100415114022.ef01b704.nishimura@mxp.nes.nec.co.jp>
	<g2u49b004811004142148i3db9fefaje1f20760426e0c7e@mail.gmail.com>
	<20100415152104.62593f37.nishimura@mxp.nes.nec.co.jp>
	<20100415155432.cf1861d9.kamezawa.hiroyu@jp.fujitsu.com>
	<xr93k4rxx6sd.fsf@ninji.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Vivek Goyal <vgoyal@redhat.com>, balbir@linux.vnet.ibm.com, Andrea Righi <arighi@develer.com>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010 13:17:38 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Wed, Apr 14, 2010 at 11:54 PM, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 15 Apr 2010 15:21:04 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> >> > The only reason to use trylock in this case is to prevent deadlock
> >> > when running in a context that may have preempted or interrupted a
> >> > routine that already holds the bit locked. A In the
> >> > __remove_from_page_cache() irqs are disabled, but that does not imply
> >> > that a routine holding the spinlock has been preempted. A When the bit
> >> > is locked, preemption is disabled. A The only way to interrupt a holder
> >> > of the bit for an interrupt to occur (I/O, timer, etc). A So I think
> >> > that in_interrupt() is sufficient. A Am I missing something?
> >> >
> >> IIUC, it's would be enough to prevent deadlock where one CPU tries to acquire
> >> the same page cgroup lock. But there is still some possibility where 2 CPUs
> >> can cause dead lock each other(please see the commit e767e056).
> >> IOW, my point is "don't call lock_page_cgroup() under mapping->tree_lock".
> >>
> > Hmm, maybe worth to try. We may be able to set/clear all DIRTY/WRITBACK bit
> > on page_cgroup without mapping->tree_lock.
> > In such case, of course, the page itself should be locked by lock_page().
> >
> > But.Hmm..for example.
> >
> > account_page_dirtied() is the best place to mark page_cgroup dirty. But
> > it's called under mapping->tree_lock.
> >
> > Another thinking:
> > I wonder we may have to change our approach for dirty page acccounting.
> >
> > Please see task_dirty_inc(). It's for per task dirty limiting.
> > And you'll notice soon that there is no task_dirty_dec().
> 
> Hello Kame-san,
> 
> This is an interesting idea.  If this applies to memcg dirty accounting,
> then would it also apply to system-wide dirty accounting?  I don't think
> so, but I wanted to float the idea.  It looks like this proportions.c
> code is good is at comparing the rates of events (for example: per-task
> dirty page events).  However, in the case of system-wide dirty
> accounting we also want to consider the amount of dirty memory, not just
> the rate at which it is being dirtied.
> 
> Cgroup dirty page accounting imposes the following additional accounting
> complexities:
> * hierarchical accounting
> * page migration between cgroups
> 
> For per-memcg dirty accounting, are you thinking that each mem_cgroup
> would have a struct prop_local_single to represent a memcg's dirty
> memory usage relative to a system wide prop_descriptor?
> 
> My concern is that we will still need an efficient way to determine the
> mem_cgroup associated with a page under a variety of conditions (page
> fault path for new mappings, softirq for dirty page writeback).
> 
> Currently -rc4 and -mmotm use a non-irq safe lock_page_cgroup() to
> protect a page's cgroup membership.  I think this will cause problems as
> we add more per-cgroup stats (dirty page counts, etc) that are adjusted
> in irq handlers.  Proposed approaches include:
> 1. use try-style locking.  this can lead to fuzzy counters, which some
>    do not like.  Over time these fuzzy counter may drift.
> 
> 2. mask irq when calling lock_page_cgroup().  This has some performance
>    cost, though it may be small (see below).
> 
> 3. because a page's cgroup membership rarely changes, use RCU locking.
>    This is fast, but may be more complex than we want.
> 
> The performance of simple irqsave locking or more advanced RCU locking
> is similar to current locking (non-irqsave/non-rcu) for several
> workloads (kernel build, dd).  Using a micro-benchmark some differences
> are seen:
> * irqsave is 1% slower than mmotm non-irqsave/non-rcu locking.
> * RCU locking is 4% faster than mmotm non-irqsave/non-rcu locking.
> * RCU locking is 5% faster than irqsave locking.
> 
> I think we need some changes to per-memcg dirty page accounting updates
> from irq handlers.  If we want to focus micro benchmark performance,
> then RCU locking seems like the correct approach.  Otherwise, irqsave
> locking seems adequate.  I'm thinking that for now we should start
> simple and use irqsave.  Comments?
> 
> Here's the data I collected...
> 
> config      kernel_build[1]   dd[2]   read-fault[3]
> ===================================================
> 2.6.34-rc4  4:18.64, 4:56.06(+-0.190%)
> MEMCG=n                       0.276(+-1.298%), 0.532(+-0.808%), 2.659(+-0.869%)
>                                       3753.6(+-0.105%)
> 
> 2.6.34-rc4  4:19.60, 4:58.29(+-0.184%)
> MEMCG=y                       0.288(+-0.663%), 0.599(+-1.857%), 2.841(+-1.020%)
> root cgroup                           4172.3(+-0.074%)
> 
> 2.6.34-rc4  5:02.41, 4:58.56(+-0.116%)
> MEMCG=y                       0.288(+-0.978%), 0.571(+-1.005%), 2.898(+-1.052%)
> non-root cgroup                       4162.8(+-0.317%)
> 
> 2.6.34-rc4  4:21.02, 4:57.27(+-0.152%)
> MEMCG=y                       0.289(+-0.809%), 0.574(+-1.013%), 2.856(+-0.909%)
> mmotm                                 4159.0(+-0.280%)
> root cgroup
> 
> 2.6.34-rc4  5:01.13, 4:56.84(+-0.074%)
> MEMCG=y                       0.299(+-1.512%), 0.577(+-1.158%), 2.864(+-1.012%)
> mmotm                                 4202.3(+-0.149%)
> non-root cgroup
> 
> 2.6.34-rc4  4:19.44, 4:57.30(+-0.151%)
> MEMCG=y                       0.293(+-0.885%), 0.578(+-0.967%), 2.878(+-1.026%)
> mmotm                                 4219.1(+-0.007%)
> irqsave locking
> root cgroup
> 
> 2.6.34-rc4  5:01.07, 4:58.62(+-0.796%)
> MEMCG=y                       0.305(+-1.752%), 0.579(+-1.035%), 2.893(+-1.111%)
> mmotm                                 4254.3(+-0.095%)
> irqsave locking
> non-root cgroup
> 
> 2.6.34-rc4  4:19.53, 4:58.74(+-0.840%)
> MEMCG=y                       0.291(+-0.394%), 0.577(+-1.219%), 2.868(+-1.033%)
> mmotm                                 4004.4(+-0.059%)
> RCU locking
> root cgroup
> 
> 2.6.34-rc4  5:00.99, 4:57.04(+-0.069%)
> MEMCG=y                       0.289(+-1.027%), 0.575(+-1.069%), 2.858(+-1.102%)
> mmotm                                 4004.0(+-0.096%)
> RCU locking
> non-root cgroup
> 
> [1] kernel build is listed as two numbers, first build is cache cold,
>     and average of three non-first builds (with warm cache).  src and
>     output are in 2G tmpfs.
> 
> [2] dd creates 10x files in tmpfs of various sizes (100M,200M,1000M) using:
>     "dd if=/dev/zero bs=$((1<<20)) count=..."
> 
> [3] micro benchmark measures cycles (rdtsc) per read fault of mmap-ed
>     file warm in the page cache.
> 
> [4] MEMCG= is an abberviation for CONFIG_CGROUP_MEM_RES_CTLR=
> 
> [5] mmotm is dated 2010-04-15-14-42
> 
> [6] irqsave locking converts all [un]lock_page_cgroup() to use
>     local_irq_save/restore().
>     (local commit a7f01d96417b10058a2128751fe4062e8a3ecc53).  This was
>     previously proposed on linux-kernel and linux-mm.
> 
> [7] RCU locking patch is shown below.
>     (local commit 231a4fec6ccdef9e630e184c0e0527c884eac57d)
> 
> For reference, here's the RCU locking patch for 2010-04-15-14-42 mmotm,
> which patches 2.6.34-rc4.
> 
>   Use RCU to avoid lock_page_cgroup() in most situations.
> 
>   When locking, disable irq to allow for accounting from irq handlers.
> 

I think the direction itself is good. But, about FILE_MAPPED, it's out of
control of radix-tree. So, we need lock_page_cgroup/unlock_page_cgroup
always for avoiding race with charge/uncharge.

And you don't need to call "begin/end reassignment" at page migration.
(I'll post a patch for modifing codes around page-migration. It has BUG now.)

But you have to call begin/end reassignment at force_empty. It does account move.

Thanks,
-Kame


> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ee3b52f..cd46474 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -280,6 +280,12 @@ static bool move_file(void)
>  }
>  
>  /*
> + * If accounting changes are underway, then access to the mem_cgroup field
> + * within struct page_cgroup requires locking.
> + */
> +static bool mem_cgroup_account_move_ongoing;
> +
> +/*
>   * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
>   * limit reclaim to prevent infinite loops, if they ever occur.
>   */
> @@ -1436,12 +1442,25 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>  {
>  	struct mem_cgroup *mem;
>  	struct page_cgroup *pc;
> +	bool locked = false;
> +	unsigned long flags = 0;
>  
>  	pc = lookup_page_cgroup(page);
>  	if (unlikely(!pc))
>  		return;
>  
> -	lock_page_cgroup(pc);
> +	/*
> +	 * Unless a page's cgroup reassignment is possible, then avoid grabbing
> +	 * the lock used to protect the cgroup assignment.
> +	 */
> +	rcu_read_lock();
> +	smp_rmb();
> +	if (unlikely(mem_cgroup_account_move_ongoing)) {
> +		local_irq_save(flags);
> +		lock_page_cgroup(pc);
> +		locked = true;
> +	}
> +
>  	mem = pc->mem_cgroup;
>  	if (!mem || !PageCgroupUsed(pc))
>  		goto done;
> @@ -1449,6 +1468,7 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>  	/*
>  	 * Preemption is already disabled. We can use __this_cpu_xxx
>  	 */
> +	VM_BUG_ON(preemptible());
>  	if (val > 0) {
>  		__this_cpu_inc(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
>  		SetPageCgroupFileMapped(pc);
> @@ -1458,7 +1478,11 @@ void mem_cgroup_update_file_mapped(struct page *page, int val)
>  	}
>  
>  done:
> -	unlock_page_cgroup(pc);
> +	if (unlikely(locked)) {
> +		unlock_page_cgroup(pc);
> +		local_irq_restore(flags);
> +	}
> +	rcu_read_unlock();
>  }
>  
>  /*
> @@ -2498,6 +2522,28 @@ static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
>  #endif
>  
>  /*
> + * Reassignment of mem_cgroup is possible, so locking is required.  Make sure
> + * that locks are used when accessing mem_cgroup.
> + * mem_cgroup_end_page_cgroup_reassignment() balances this function.
> + */
> +static void mem_cgroup_begin_page_cgroup_reassignment(void)
> +{
> +	VM_BUG_ON(mem_cgroup_account_move_ongoing);
> +	mem_cgroup_account_move_ongoing = true;
> +	synchronize_rcu();
> +}
> +
> +/*
> + * Once page cgroup membership changes complete, this routine indicates that
> + * access to mem_cgroup does not require locks.
> + */
> +static void mem_cgroup_end_page_cgroup_reassignment(void)
> +{
> +	VM_BUG_ON(! mem_cgroup_end_page_cgroup_reassignment);
> +	mem_cgroup_account_move_ongoing = false;
> +}
> +
> +/*
>   * Before starting migration, account PAGE_SIZE to mem_cgroup that the old
>   * page belongs to.
>   */
> @@ -2524,6 +2570,10 @@ int mem_cgroup_prepare_migration(struct page *page, struct mem_cgroup **ptr)
>  		css_put(&mem->css);
>  	}
>  	*ptr = mem;
> +
> +	if (!ret)
> +		mem_cgroup_begin_page_cgroup_reassignment();
> +
>  	return ret;
>  }
>  
> @@ -2536,7 +2586,8 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  	enum charge_type ctype;
>  
>  	if (!mem)
> -		return;
> +		goto unlock;
> +
>  	cgroup_exclude_rmdir(&mem->css);
>  	/* at migration success, oldpage->mapping is NULL. */
>  	if (oldpage->mapping) {
> @@ -2583,6 +2634,9 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
>  	 * In that case, we need to call pre_destroy() again. check it here.
>  	 */
>  	cgroup_release_and_wakeup_rmdir(&mem->css);
> +
> +unlock:
> +	mem_cgroup_end_page_cgroup_reassignment();
>  }
>  
>  /*
> @@ -4406,6 +4460,8 @@ static void mem_cgroup_clear_mc(void)
>  	mc.to = NULL;
>  	mc.moving_task = NULL;
>  	wake_up_all(&mc.waitq);
> +
> +	mem_cgroup_end_page_cgroup_reassignment();
>  }
>  
>  static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> @@ -4440,6 +4496,8 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
>  			mc.moved_swap = 0;
>  			mc.moving_task = current;
>  
> +			mem_cgroup_begin_page_cgroup_reassignment();
> +
>  			ret = mem_cgroup_precharge_mc(mm);
>  			if (ret)
>  				mem_cgroup_clear_mc();
> 
> --
> Greg
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
