Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DC0CC6B004F
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 02:27:38 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8H6RjQT023268
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 17 Sep 2009 15:27:45 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3341245DE51
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:27:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BA1845DE4C
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:27:45 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BECCCE08007
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:27:44 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 713E6E08002
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 15:27:44 +0900 (JST)
Date: Thu, 17 Sep 2009 15:25:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/8] memcg: migrate charge of anon
Message-Id: <20090917152540.10b10028.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090917145657.4ccc8d27.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917112656.908b44fa.nishimura@mxp.nes.nec.co.jp>
	<20090917135737.04c3b65f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090917145657.4ccc8d27.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Sep 2009 14:56:57 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > +	/*
> > > +	 * We should put back all pages which remain on "list".
> > > +	 * This means try_charge above has failed.
> > > +	 * Pages which have been moved to mc->list would be put back at
> > > +	 * clear_migrate_charge.
> > > +	 */
> > > +	if (!list_empty(&list))
> > > +		list_for_each_entry_safe(page, tmp, &list, lru) {
> > > +			list_del(&page->lru);
> > > +			putback_lru_page(page);
> > > +			put_page(page);
> > 
> > I wonder this put_page() is not necessary.
> > 
> get_page_unless_zero(page) is called above.
> putback_lru_page() will only decrease the refcount got by isolate_lru_page().
> 
ok. I misunderstood.


> > > +		}
> > > +
> > > +	return ret;
> > > +}
> > > +
> > > +static int migrate_charge_prepare(void)
> > > +{
> > > +	int ret = 0;
> > > +	struct mm_struct *mm;
> > > +	struct vm_area_struct *vma;
> > > +
> > > +	mm = get_task_mm(mc->tsk);
> > > +	if (!mm)
> > > +		return 0;
> > > +
> > > +	down_read(&mm->mmap_sem);
> > > +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > > +		struct mm_walk migrate_charge_walk = {
> > > +			.pmd_entry = migrate_charge_prepare_pte_range,
> > > +			.mm = mm,
> > > +			.private = vma,
> > > +		};
> > > +		if (signal_pending(current)) {
> > > +			ret = -EINTR;
> > > +			break;
> > > +		}
> > > +		if (is_vm_hugetlb_page(vma))
> > > +			continue;
> > > +		/* We migrate charge of private pages for now */
> > > +		if (vma->vm_flags & (VM_SHARED | VM_MAYSHARE))
> > > +			continue;
> > > +		if (mc->to->migrate_charge) {
> > > +			ret = walk_page_range(vma->vm_start, vma->vm_end,
> > > +							&migrate_charge_walk);
> > > +			if (ret)
> > > +				break;
> > > +		}
> > > +	}
> > > +	up_read(&mm->mmap_sem);
> > > +
> > > +	mmput(mm);
> > 
> > Hmm, Does this means a thread which  is moved can continue its work and
> > newly allocated pages will remain in old group ?
> > 
> Yes.
> Pages allocated between can_attach() and cgroup_task_migrate() will be
> charged to old group.
> But, IIUC, we should release mmap_sem because attach() of cpuset tries to down_write
> mmap_sem(update_tasks_nodemask -> cpuset_change_nodemask -> mpol_rebind_mm). 
> 
agreed.


> > 
> > > +	return ret;
> > > +}
> > > +
> > > +static void mem_cgroup_clear_migrate_charge(void)
> > > +{
> > > +	struct page *page, *tmp;
> > > +
> > > +	VM_BUG_ON(!mc);
> > > +
> > > +	if (!list_empty(&mc->list))
> > 
> > I think list_for_each_entry_safe() handles empty case.
> > 
> 
> #define list_for_each_entry_safe(pos, n, head, member)                  \
>         for (pos = list_entry((head)->next, typeof(*pos), member),      \
>                 n = list_entry(pos->member.next, typeof(*pos), member); \
>              &pos->member != (head);                                    \
>              pos = n, n = list_entry(n->member.next, typeof(*n), member))
> 
> hmm, "pos = list_entry((head)->next, typeof(*pos), member)" points to proper pointer
> in list_empty(i.e. head->next == head) case ?
I think so.

> "mc->list" is struct list_head, not struct page.
> 
yes.
	pos = list_entry((mc->list)->next, struct page, lru);
	here, mc->list->next == &mc->list if empty.

Then, pos is "struct page" but points to &mc->list - some bytes.
Then, pos->member == &mc->list == head.

But this point is a nitpick. plz do as you want.
if (!list_empty(mc->list)) show us mc->list can be empty.


> > > +	mem_cgroup_clear_migrate_charge();
> > >  }
> > >  
> > 
> > Okay, them, if other subsystem fails "can_attach()", migrated charges are not
> > moved back to original group. Right ?
> > 
> We haven't migrated charges at can_attach() stage. It only does try_charge to
> the new group.
> If can_attach() of other subsystem fails, we only cancel the result of try_charge.
> 
> > 
> > 
> > My biggest concern in this implementation is this "isolate" pages too much.
> > Could you modify the whole routine as...
> > 
> > struct migrate_charge {
> > 	struct task_struct *tsk;
> > 	struct mem_cgroup *from;
> > 	struct mem_cgroup *to;
> > 	struct list_head list;
> > 	long charged;
> > 	long committed;
> > };
> > 	- mem_cgroup_can_migrate_charge() ....
> > 			count pages and do "charge", no page isolation.
> > 			and remember the number of charges as mc->charged++;
> > 	- mem_cgroup_migrate_charge()
> > 		- scan vmas/page table again. And isolate pages in fine grain.
> > 		  (256 pages per scan..or some small number)
> > 		- migrate pages if success mc->committed++
> > 
> > 	  after move, uncharge (mc->charged - mc->commited)
> > 
> hmm, I selected current implementation just to prevent parsing page table twice.
> But if you prefer the parse-again direction, I'll try it.
> It will fix most of the problems that current implementation has.
> 
What I afraid of is a corner case, migrating "very big" process, and
INACITVE/ACTIVE lru of a zone goes down to be nearly empty, OOM.

If you look into other callers of isolate_lru_page(), the number of
pages isolated per iteration is limited to some value.
(Almost all callers use array for limiting/batching.)

Thanks,
-Kame







> 
> Thanks,
> Daisuke Nishimura.
> 
> > Maybe you can find better one. But isolating all pages of process at once is a
> > big hammber for vm, OOM.
> > 
> > Thanks,
> > -Kame
> > 
> > 
> > 
> > >  static void mem_cgroup_move_task(struct cgroup_subsys *ss,
> > > 
> > 
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
