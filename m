Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B82516B004D
	for <linux-mm@kvack.org>; Sun,  8 Nov 2009 19:36:57 -0500 (EST)
Date: Mon, 9 Nov 2009 09:31:05 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 6/8] memcg: recharge charges of anonymous page
Message-Id: <20091109093105.ef5596d6.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091106153526.19b70518.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091106141448.6548687a.nishimura@mxp.nes.nec.co.jp>
	<20091106153526.19b70518.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009 15:35:26 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 6 Nov 2009 14:14:48 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This patch is the core part of this recharge-at-task-move feature.
> > It implements functions to recharge charges of anonymous pages mapped only by
> > the target task.
> > 
> > Implementation:
> > - define struct recharge_struct and a valuable of it(recharge) to remember
> >   the count of pre-charges and other information.
> > - At can_attach(), parse the page table of the task and count the number of
> >   mapped pages which are charged to the source mem_cgroup, and call
> >   __mem_cgroup_try_charge() repeatedly and count up recharge.precharge.
> > - At attach(), parse the page table again, find a target page as we did in
> >   can_attach(), and call mem_cgroup_move_account() about the page.
> > - Cancel all charges if recharge.precharge > 0 on failure or at the end of
> >   task move.
> > 
> 
> Changelog ?
> 
> 
will add.

> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  Documentation/cgroups/memory.txt |   36 +++++-
> >  mm/memcontrol.c                  |  275 +++++++++++++++++++++++++++++++++++++-
> >  2 files changed, 306 insertions(+), 5 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > index b871f25..54281ff 100644
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -262,10 +262,12 @@ some of the pages cached in the cgroup (page cache pages).
> >  4.2 Task migration
> >  
> >  When a task migrates from one cgroup to another, it's charge is not
> > -carried forward. The pages allocated from the original cgroup still
> > +carried forward by default. The pages allocated from the original cgroup still
> >  remain charged to it, the charge is dropped when the page is freed or
> >  reclaimed.
> >  
> > +Note: You can move charges of a task along with task migration. See 8.
> > +
> >  4.3 Removing a cgroup
> >  
> >  A cgroup can be removed by rmdir, but as discussed in sections 4.1 and 4.2, a
> > @@ -414,7 +416,37 @@ NOTE1: Soft limits take effect over a long period of time, since they involve
> >  NOTE2: It is recommended to set the soft limit always below the hard limit,
> >         otherwise the hard limit will take precedence.
> >  
> > -8. TODO
> > +8. Recharge at task move
> > +
> > +Users can move charges associated with a task along with task move, that is,
> > +uncharge from the old cgroup and charge to the new cgroup.
> > +
> > +8.1 Interface
> > +
> > +This feature is disabled by default. It can be enabled(and disabled again) by
> > +writing to memory.recharge_at_immigrate of the destination cgroup.
> > +
> > +If you want to enable it
> > +
> > +# echo 1 > memory.recharget_at_immigrate
> > +
> > +Note: A value more than 1 will be supported in futer. See 8.2.
> > +
> > +And if you want disable it again
> > +
> > +# echo 0 > memory.recharget_at_immigrate
> > +
> > +8.2 Type of charges which can be recharged
> > +
> > +We recharge a charge which meets the following conditions.
> > +
> > +a. It must be charged to the old cgroup.
> > +b. A charge of an anonymous page used by the target task. The page must be used
> > +   only by the target task.
> > +
> > +Note: More type of pages(e.g. file cache, shmem,) will be supported in future.
> > +
> > +9. TODO
> >  
> >  1. Add support for accounting huge pages (as a separate controller)
> >  2. Make per-cgroup scanner reclaim not-shared pages first
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index afa1179..f4b7116 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -21,6 +21,8 @@
> >  #include <linux/memcontrol.h>
> >  #include <linux/cgroup.h>
> >  #include <linux/mm.h>
> > +#include <linux/migrate.h>
> > +#include <linux/hugetlb.h>
> >  #include <linux/pagemap.h>
> >  #include <linux/smp.h>
> >  #include <linux/page-flags.h>
> > @@ -239,6 +241,18 @@ struct mem_cgroup {
> >  };
> >  
> >  /*
> > + * A data structure and a valiable for recharging charges at task move.
> > + * "recharge" and its members are protected by cgroup_lock
> > + */
> > +struct recharge_struct {
> > +	struct mem_cgroup *from;
> > +	struct mem_cgroup *to;
> > +	struct task_struct *target;	/* the target task being moved */
> > +	unsigned long precharge;
> > +};
> > +static struct recharge_struct recharge;
> > +
> > +/*
> >   * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
> >   * limit reclaim to prevent infinite loops, if they ever occur.
> >   */
> > @@ -1496,7 +1510,7 @@ charged:
> >  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
> >  	 * if they exceeds softlimit.
> >  	 */
> > -	if (mem_cgroup_soft_limit_check(mem))
> > +	if (page && mem_cgroup_soft_limit_check(mem))
> >  		mem_cgroup_update_tree(mem, page);
> >  done:
> >  	return 0;
> > @@ -3416,10 +3430,170 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
> >  }
> >  
> >  /* Handlers for recharge at task move. */
> > +/**
> > + * is_target_pte_for_recharge - check a pte whether it is valid for recharge
> > + * @vma: the vma the pte to be checked belongs
> > + * @addr: the address corresponding to the pte to be checked
> > + * @ptent: the pte to be checked
> > + * @target: the pointer the target page will be stored(can be NULL)
> > + *
> > + * Returns
> > + *   0(RECHARGE_TARGET_NONE): if the pte is not a target for recharge.
> > + *   1(RECHARGE_TARGET_PAGE): if the page corresponding to this pte is a target
> > + *     for recharge. if @target is not NULL, the page is stored in target->page
> > + *     with extra refcnt got(Callers should handle it).
> > + *
> > + * Called with pte lock held.
> > + */
> > +/* We add a new member later. */
> > +union recharge_target {
> > +	struct page	*page;
> > +};
> > +
> > +/* We add a new type later. */
> > +enum recharge_target_type {
> > +	RECHARGE_TARGET_NONE,	/* not used */
> > +	RECHARGE_TARGET_PAGE,
> > +};
> > +
> > +static int is_target_pte_for_recharge(struct vm_area_struct *vma,
> > +		unsigned long addr, pte_t ptent, union recharge_target *target)
> > +{
> > +	struct page *page;
> > +	struct page_cgroup *pc;
> > +	int ret = 0;
> > +
> > +	if (!pte_present(ptent))
> > +		return 0;
> > +
> > +	page = vm_normal_page(vma, addr, ptent);
> > +	if (!page || !page_mapped(page))
> > +		return 0;
> > +	/* TODO: We don't recharge file(including shmem/tmpfs) pages for now. */
> > +	if (!PageAnon(page))
> > +		return 0;
> > +	/*
> > +	 * TODO: We don't recharge shared(used by multiple processes) pages
> > +	 * for now.
> > +	 */
> > +	if (page_mapcount(page) > 1)
> > +		return 0;
> > +	if (!get_page_unless_zero(page))
> > +		return 0;
> > +
> > +	pc = lookup_page_cgroup(page);
> > +	lock_page_cgroup(pc);
> > +	if (PageCgroupUsed(pc) && pc->mem_cgroup == recharge.from) {
> > +		ret = RECHARGE_TARGET_PAGE;
> > +		if (target)
> > +			target->page = page;
> > +	}
> > +	unlock_page_cgroup(pc);
> > +
> > +	if (!ret || !target)
> > +		put_page(page);
> > +
> > +	return ret;
> > +}
> > +
> > +static int mem_cgroup_recharge_do_precharge(void)
> > +{
> > +	int ret = -ENOMEM;
> > +	struct mem_cgroup *mem = recharge.to;
> > +
> > +	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false, NULL);
> > +	if (ret || !mem)
> > +		return -ENOMEM;
> > +
> > +	recharge.precharge++;
> > +	return ret;
> > +}
> > +
> > +static int mem_cgroup_recharge_prepare_pte_range(pmd_t *pmd,
> > +					unsigned long addr, unsigned long end,
> > +					struct mm_walk *walk)
> > +{
> > +	int ret = 0;
> > +	unsigned long count = 0;
> > +	struct vm_area_struct *vma = walk->private;
> > +	pte_t *pte;
> > +	spinlock_t *ptl;
> > +
> > +	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > +	for (; addr != end; pte++, addr += PAGE_SIZE)
> > +		if (is_target_pte_for_recharge(vma, addr, *pte, NULL))
> > +			count++;
> > +	pte_unmap_unlock(pte - 1, ptl);
> > +
> > +	while (count-- && !ret)
> > +		ret = mem_cgroup_recharge_do_precharge();
> > +
> > +	return ret;
> > +}
> > +
> > +static int mem_cgroup_recharge_prepare(void)
> > +{
> > +	int ret = 0;
> > +	struct mm_struct *mm;
> > +	struct vm_area_struct *vma;
> > +
> > +	mm = get_task_mm(recharge.target);
> > +	if (!mm)
> > +		return 0;
> > +
> > +	down_read(&mm->mmap_sem);
> > +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +		struct mm_walk mem_cgroup_recharge_prepare_walk = {
> > +			.pmd_entry = mem_cgroup_recharge_prepare_pte_range,
> > +			.mm = mm,
> > +			.private = vma,
> > +		};
> > +		if (signal_pending(current)) {
> > +			ret = -EINTR;
> > +			break;
> > +		}
> > +		if (is_vm_hugetlb_page(vma))
> > +			continue;
> > +		ret = walk_page_range(vma->vm_start, vma->vm_end,
> > +					&mem_cgroup_recharge_prepare_walk);
> > +		if (ret)
> > +			break;
> > +		cond_resched();
> > +	}
> > +	up_read(&mm->mmap_sem);
> > +
> > +	mmput(mm);
> > +	return ret;
> > +}
> > +
> > +static void mem_cgroup_clear_recharge(void)
> > +{
> > +	while (recharge.precharge--)
> > +		mem_cgroup_cancel_charge(recharge.to);
> > +	recharge.from = NULL;
> > +	recharge.to = NULL;
> > +	recharge.target = NULL;
> > +}
> > +
> >  static int mem_cgroup_can_recharge(struct mem_cgroup *mem,
> >  					struct task_struct *p)
> >  {
> > -	return 0;
> > +	int ret;
> > +	struct mem_cgroup *from = mem_cgroup_from_task(p);
> > +
> > +	if (from == mem)
> > +		return 0;
> > +
> > +	recharge.from = from;
> > +	recharge.to = mem;
> > +	recharge.target = p;
> > +	recharge.precharge = 0;
> > +
> > +	ret = mem_cgroup_recharge_prepare();
> > +
> > +	if (ret)
> > +		mem_cgroup_clear_recharge();
> > +	return ret;
> >  }
> >  
> 
> Hmm...Hmm...looks nicer. But can I have another suggestion ?
> 
> ==
> static int mem_cgroup_can_recharge(struct mem_cgroup *mem,
> 				struct task_struct *p)
> {
> 	unsigned long rss;
> 	struct mm_struct *mm;
> 
> 	mm = get_task_mm(p);
> 	if (!mm)
> 		return;
> 
> 	rss = get_mm_counter(mm, anon_rss);
> 	precharge(rss);
> 	mmput(mm);
> }
> ==
> Do you think anonymous memory are so shared at "move" as that
> we need page table scan ?
> 
The reason why I scanned page table twice was to move "swap" charge.
There was no counter for swap per process.
Yes, the counter is just being added (by you :)).
It cannot be used for shmem's swaps, but I won't handle them for now and
we can recharge them in attach() phase(by best-effort) anyway.
I'll just count the mm_counter in can_attach() phase.

> If typical sequence is
> ==
> 	fork()
> 		-> exec()
> 
> 	move child
> ==
> No problem will happen.
> 
> >  static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> > @@ -3442,11 +3616,104 @@ static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
> >  				struct task_struct *p,
> >  				bool threadgroup)
> >  {
> > +	struct mem_cgroup *mem = mem_cgroup_from_cont(cgroup);
> > +
> >  	mutex_unlock(&memcg_tasklist);
> > +	if (mem->recharge_at_immigrate && thread_group_leader(p))
> > +		mem_cgroup_clear_recharge();
> > +}
> > +
> > +static int mem_cgroup_recharge_pte_range(pmd_t *pmd,
> > +				unsigned long addr, unsigned long end,
> > +				struct mm_walk *walk)
> > +{
> > +	int ret = 0;
> > +	struct vm_area_struct *vma = walk->private;
> > +	pte_t *pte;
> > +	spinlock_t *ptl;
> > +
> > +retry:
> > +	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> > +	for (; addr != end; addr += PAGE_SIZE) {
> > +		pte_t ptent = *(pte++);
> > +		union recharge_target target;
> > +		int type;
> > +		struct page *page;
> > +		struct page_cgroup *pc;
> > +
> > +		if (!recharge.precharge)
> > +			break;
> > +
> > +		type = is_target_pte_for_recharge(vma, addr, ptent, &target);
> > +		switch (type) {
> > +		case RECHARGE_TARGET_PAGE:
> > +			page = target.page;
> > +			if (isolate_lru_page(page))
> > +				goto put;
> > +			pc = lookup_page_cgroup(page);
> > +			if (!mem_cgroup_move_account(pc,
> > +						recharge.from, recharge.to)) {
> > +				css_put(&recharge.to->css);
> > +				recharge.precharge--;
> > +			}
> > +			putback_lru_page(page);
> > +put:			/* is_target_pte_for_recharge() gets the page */
> > +			put_page(page);
> > +			break;
> > +		default:
> > +			continue;
> 
> continue for what ?
> 
Nothing :)
Just move to the next step in this for-loop. I think it's a leftover of my
old code...

> And we forget "failed to move" pte. This "move" is best-effort service.
> Right ?
> 
"if (!recharge.precharge)" above and "if (addr != end)" bellow will do that.

> > +		}
> > +	}
> > +	pte_unmap_unlock(pte - 1, ptl);
> > +
> > +	if (addr != end) {
> > +		/*
> > +		 * We have consumed all precharges we got in can_attach().
> > +		 * We try precharge one by one, but don't do any additional
> > +		 * precharges nor recharges to recharge.to if we have failed in
> > +		 * precharge once in attach() phase.
> > +		 */
> > +		ret = mem_cgroup_recharge_do_precharge();
> > +		if (!ret)
> > +			goto retry;
> > +	}
> > +
> > +	return ret;
> >  }
> >  
> 
> 
> 
> >  static void mem_cgroup_recharge(void)
> >  {
> > +	struct mm_struct *mm;
> > +	struct vm_area_struct *vma;
> > +
> > +	mm = get_task_mm(recharge.target);
> > +	if (!mm)
> > +		return;
> > +
> > +	lru_add_drain_all();
> > +	down_read(&mm->mmap_sem);
> > +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +		int ret;
> > +		struct mm_walk mem_cgroup_recharge_walk = {
> > +			.pmd_entry = mem_cgroup_recharge_pte_range,
> > +			.mm = mm,
> > +			.private = vma,
> > +		};
> > +		if (is_vm_hugetlb_page(vma))
> > +			continue;
> > +		ret = walk_page_range(vma->vm_start, vma->vm_end,
> > +						&mem_cgroup_recharge_walk);
> 
> At _this_ point, check VM_SHARED and skip scan is a sane operation.
> Could you add checks ?
> 
will do.

> 
> > +		if (ret)
> > +			/*
> > +			 * means we have consumed all precharges and failed in
> > +			 * doing additional precharge. Just abandon here.
> > +			 */
> > +			break;
> > +		cond_resched();
> > +	}
> > +	up_read(&mm->mmap_sem);
> > +
> > +	mmput(mm);
> >  }
> >  
> >  static void mem_cgroup_move_task(struct cgroup_subsys *ss,
> > @@ -3458,8 +3725,10 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
> >  	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> >  
> >  	mutex_unlock(&memcg_tasklist);
> > -	if (mem->recharge_at_immigrate && thread_group_leader(p))
> > +	if (mem->recharge_at_immigrate && thread_group_leader(p)) {
> >  		mem_cgroup_recharge();
> > +		mem_cgroup_clear_recharge();
> > +	}
> 
> Is it guranteed that thread_group_leader(p) is true if this is true at
> can_attach() ?
> If no,
> 	if (.....) {
> 		mem_cgroup_recharge()
> 	}
> 	mem_cgroup_cleare_recharge()
> 
> is better.
> 
will change.

Thank you for your review.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
