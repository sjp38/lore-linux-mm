Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 465DC6B0055
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 04:04:51 -0400 (EDT)
Date: Thu, 24 Sep 2009 17:00:02 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 5/8] memcg: migrate charge of mapped page
Message-Id: <20090924170002.c7441b52.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090924162226.5c703903.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
	<20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
	<20090924144808.6a0d5140.nishimura@mxp.nes.nec.co.jp>
	<20090924162226.5c703903.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 24 Sep 2009 16:22:26 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 24 Sep 2009 14:48:08 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This patch is the core part of this charge migration feature.
> > It adds functions to migrate charge of pages mapped by the task.
> > 
> > Implementation:
> > - define struct migrate_charge and a valuable of it(mc) to remember the count
> >   of pre-charges and other information.
> > - At can_attach(), parse the page table of the task and count the number of
> >   mapped pages which are charged to the source mem_cgroup, and call
> >   __mem_cgroup_try_charge() repeatedly and count up mc->precharge.
> > - At attach(), parse the page table again, find a target page as we did in
> >   can_attach(), and call mem_cgroup_move_account() about the page.
> > - Cancel all charges if mc->precharge > 0 on failure or at the end of charge
> >   migration.
> > 
> 
> At first, thank you for hearing my request :)
> 
> 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  mm/memcontrol.c |  270 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> >  1 files changed, 268 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 30499d9..fbcc195 100644
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
> > @@ -274,6 +276,18 @@ enum charge_type {
> >  #define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
> >  #define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
> >  
> > +/*
> > + * Variables for charge migration at task move.
> > + * mc and its members are protected by cgroup_lock
> > + */
> > +struct migrate_charge {
> > +	struct task_struct *tsk;
> > +	struct mem_cgroup *from;
> > +	struct mem_cgroup *to;
> > +	unsigned long precharge;
> > +};
> > +static struct migrate_charge *mc;
> > +
> 
> I associate migrate with "page migration".
> Then, hmm, recharge or move_charge or some other good word, I like.
> 
O.K.
Will change.

> BTW, why "mc" is a global vairable ?
> 
Just because __mem_cgroup_try_charge() will use it in next patch.

> IIUC, this all migration is done under cgroup_lock, mc can be
> global variable...right ?
> 
Yes.

> But ah..ok, this is a similar thing around cpuset's migration..
> When you removing RFC, I'd like to see some performance cost
> information around this recharge..
> 
> 
> 
> >  static void mem_cgroup_get(struct mem_cgroup *mem);
> >  static void mem_cgroup_put(struct mem_cgroup *mem);
> >  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> > @@ -1362,7 +1376,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  	if (soft_fail_res) {
> >  		mem_over_soft_limit =
> >  			mem_cgroup_from_res_counter(soft_fail_res, res);
> > -		if (mem_cgroup_soft_limit_check(mem_over_soft_limit))
> > +		if (page && mem_cgroup_soft_limit_check(mem_over_soft_limit))
> >  			mem_cgroup_update_tree(mem_over_soft_limit, page);
> >  	}
> >  done:
> > @@ -3197,10 +3211,167 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
> >  	return ret;
> >  }
> >  
> > +/* Handlers for charge migration at task move. */
> > +/**
> > + * is_target_pte_for_migration - check a pte whether it is target for migration
> > + * @vma: the vma the pte to be checked belongs
> > + * @addr: the address corresponding to the pte to be checked
> > + * @ptent: the pte to be checked
> > + * @target: the pointer the target page will be stored(can be NULL)
> > + *
> > + * Returns
> > + *   0(MIGRATION_TARGET_NONE): if the pte is not a target for charge migration.
> > + *   1(MIGRATION_TARGET_PAGE): if the page corresponding to this pte is a target
> > + *     for charge migration. if @target is not NULL, the page is stored in
> > + *     target->page with extra refcnt got(Callers should handle it).
> 
> Will these type incrase more ? If not, bool value is enough.
> 
Yes.
Please see [7/8] :)

> 
> 
> > + *
> > + * Called with pte lock held.
> > + */
> > +union migration_target {
> > +	struct page	*page;
> > +};
> > +
> > +enum migration_target_type {
> > +	MIGRATION_TARGET_NONE,	/* not used */
> > +	MIGRATION_TARGET_PAGE,
> > +};
> > +
> > +static int is_target_pte_for_migration(struct vm_area_struct *vma,
> > +		unsigned long addr, pte_t ptent, union migration_target *target)
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
> > +	if (!get_page_unless_zero(page))
> > +		return 0;
> 
> Is this necessary ? We're udner page table lock.
> Then, no one can unmap this.
> 
I get the page just because to keep consistency after [7/8].
[7/8] calls find_get_page(&swapper_space, ent.val).

> > +
> > +	pc = lookup_page_cgroup(page);
> > +	lock_page_cgroup(pc);
> 
> Hmm...we may even avoid this lock. sounds tricy but we're
> under page_table_lock, no one can numap this.
> 
> 
But I think it's not good behavior to check PageCgroupUsed() and pc->mem_cgroup below.
And I'll handle not mapped pages(swap cache) too in later patch.

> > +	if (PageCgroupUsed(pc) && pc->mem_cgroup == mc->from) {
> > +		ret = MIGRATION_TARGET_PAGE;
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
> > +static int migrate_charge_do_precharge(void)
> > +{
> > +	int ret = -ENOMEM;
> > +	struct mem_cgroup *mem = mc->to;
> 
> 
> 
> > +
> > +	ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem, false, NULL);
> > +	if (ret || !mem)
> > +		return -ENOMEM;
> > +
> > +	mc->precharge++;
> > +	return ret;
> > +}
> > +
> > +static int migrate_charge_prepare_pte_range(pmd_t *pmd,
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
> > +		if (is_target_pte_for_migration(vma, addr, *pte, NULL))
> > +			count++;
> > +	pte_unmap_unlock(pte - 1, ptl);
> > +
> > +	while (count-- && !ret)
> > +		ret = migrate_charge_do_precharge();
> > +
> > +	return ret;
> > +}
> > +
> > +static int migrate_charge_prepare(void)
> > +{
> > +	int ret = 0;
> > +	struct mm_struct *mm;
> > +	struct vm_area_struct *vma;
> > +
> > +	mm = get_task_mm(mc->tsk);
> > +	if (!mm)
> > +		return 0;
> > +
> > +	down_read(&mm->mmap_sem);
> > +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +		struct mm_walk migrate_charge_prepare_walk = {
> > +			.pmd_entry = migrate_charge_prepare_pte_range,
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
> > +						&migrate_charge_prepare_walk);
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
> > +static void mem_cgroup_clear_migrate_charge(void)
> > +{
> > +	VM_BUG_ON(!mc);
> > +
> > +	while (mc->precharge--)
> > +		__mem_cgroup_cancel_charge(mc->to);
> > +	kfree(mc);
> > +	mc = NULL;
> > +}
> > +
> >  static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
> >  					struct task_struct *p)
> >  {
> > -	return 0;
> > +	int ret;
> > +	struct mem_cgroup *from = mem_cgroup_from_task(p);
> > +
> > +	VM_BUG_ON(mc);
> > +
> > +	if (from == mem)
> > +		return 0;
> > +
> please VM_BUG_ON(!mc);
> 
hmm?
I think we should not have mc here, and I added VM_BUG_ON(mc) above.

> > +	mc = kmalloc(sizeof(struct migrate_charge), GFP_KERNEL);
> > +	if (!mc)
> > +		return -ENOMEM;
> > +
> > +	mc->tsk = p;
> > +	mc->from = from;
> > +	mc->to = mem;
> > +	mc->precharge = 0;
> > +
> > +	ret = migrate_charge_prepare();
> > +
> > +	if (ret)
> > +		mem_cgroup_clear_migrate_charge();
> > +	return ret;
> >  }
> >  
> >  static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
> > @@ -3220,10 +3391,105 @@ static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
> >  				struct task_struct *p,
> >  				bool threadgroup)
> >  {
> > +	if (mc)
> > +		mem_cgroup_clear_migrate_charge();
> > +}
> > +
> > +static int migrate_charge_pte_range(pmd_t *pmd,
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
> > +		union migration_target target;
> > +		int type;
> > +		struct page *page;
> > +		struct page_cgroup *pc;
> > +
> > +		if (!mc->precharge)
> > +			break;
> > +
> > +		type = is_target_pte_for_migration(vma, addr, ptent, &target);
> > +		switch (type) {
> > +		case MIGRATION_TARGET_PAGE:
> > +			page = target.page;
> > +			if (isolate_lru_page(page))
> > +				goto put;
> > +			pc = lookup_page_cgroup(page);
> > +			if (!mem_cgroup_move_account(pc, mc->from, mc->to)) {
> > +				css_put(&mc->to->css);
> > +				mc->precharge--;
> > +			}
> > +			putback_lru_page(page);
> > +put:			/* is_target_pte_for_migration() gets the page */
> > +			put_page(page);
> > +			break;
> > +		default:
> > +			continue;
> > +		}
> > +	}
> > +	pte_unmap_unlock(pte - 1, ptl);
> > +
> > +	if (addr != end) {
> > +		/*
> > +		 * We have consumed all precharges we got in can_attach().
> > +		 * We try precharge one by one, but don't do any additional
> > +		 * precharges nor charge migration if we have failed in
> > +		 * precharge once in attach() phase.
> > +		 */
> > +		ret = migrate_charge_do_precharge();
> > +		if (!ret)
> > +			goto retry;
> 
> I think this is a nice handling.
> 
Thanks :)

> 
> 
> > +	}
> > +
> > +	return ret;
> >  }
> >  
> >  static void mem_cgroup_migrate_charge(void)
> >  {
> > +	struct mm_struct *mm;
> > +	struct vm_area_struct *vma;
> > +
> > +	if (!mc)
> > +		return;
> > +
> > +	mm = get_task_mm(mc->tsk);
> > +	if (!mm)
> > +		goto out;
> > +
> > +	lru_add_drain_all();
> > +	down_read(&mm->mmap_sem);
> > +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +		int ret;
> > +		struct mm_walk migrate_charge_walk = {
> > +			.pmd_entry = migrate_charge_pte_range,
> > +			.mm = mm,
> > +			.private = vma,
> > +		};
> > +		if (is_vm_hugetlb_page(vma))
> > +			continue;
> > +		ret = walk_page_range(vma->vm_start, vma->vm_end,
> > +							&migrate_charge_walk);
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
> > +out:
> > +	mem_cgroup_clear_migrate_charge();
> >  }
> >  
> >  static void mem_cgroup_move_task(struct cgroup_subsys *ss,
> > -- 
> 
> Hmm, I don't complain to this patch itself but cgroup_lock() will be the
> last wall to be overcomed for production use...
> 
> Can't we just prevent rmdir/mkdir on a hierarchy and move a task ?
> fork() etc..can be stopped by this and cpuset's code is not very good.
>  
I agree.

I must consider more about it.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
