Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010asp105.postini.com [74.125.245.225])
	by kanga.kvack.org (Postfix) with SMTP id 57C3B6B004D
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 23:27:30 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 2/2] memcg: avoid THP split in task migration
Date: Thu,  8 Mar 2012 23:25:28 -0500
Message-Id: <1331267128-4673-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120309101658.8b36ce4f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

Hi KAMEZAWA-san,

> On Fri,  2 Mar 2012 15:13:09 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
...
> > +
> > +	page = pmd_page(pmd);
> > +	VM_BUG_ON(!page || !PageHead(page));
> > +	if (!move_anon() || page_mapcount(page) != 1)
> > +		return 0;
>
> Could you add this ?
> ==
> static bool move_check_shared_map(struct page *page)
> {
>   /*
>    * Handling of shared pages between processes is a big trouble in memcg.
>    * Now, we never move shared-mapped pages between memcg at 'task' moving because
>    * we have no hint which task the page is really belongs to. For example,
>    * When a task does "fork()-> move to the child other group -> exec()", the charges
>    * should be stay in the original cgroup.
>    * So, check mapcount to determine we can move or not.
>    */
>    return page_mapcount(page) != 1;
> }
> ==

Thank you.

We check mapcount only for anonymous pages, so we had better also describe
that viewpoint?  And this function returns whether the target page of moving
charge is shared or not, so a name like is_mctgt_shared() looks better to me.
Moreover, this function explains why we have current implementation, rather
than why return value is mapcount != 1, so I put the comment above function
declaration like this:

  /*
   * Handling of shared pages between processes is a big trouble in memcg.
   * Now, we never move shared anonymous pages between memcg at 'task'
   * moving because we have no hint which task the page is really belongs to.
   * For example, when a task does "fork() -> move to the child other group
   * -> exec()", the charges should be stay in the original cgroup.
   * So, check if a given page is shared or not to determine to move charge.
   */
  static bool is_mctgt_shared(struct page *page)
  {
     return page_mapcount(page) != 1;
  }

As for the difference between anon page and filemapped page, I have no idea
about current charge moving policy. Is this explained anywhere? (sorry to
question before researching by myself ...)


> We may be able to support madvise(MOVE_MEMCG) or fadvise(MOVE_MEMCG), if necessary.

Is this mean moving charge policy can depend on users?
I feel that's strange because I don't think resouce management should be
under users' control.

>
> > +	pc = lookup_page_cgroup(page);
> > +	if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
> > +		ret = MC_TARGET_PAGE;
> > +		if (target) {
> > +			get_page(page);
> > +			target->page = page;
>
> Here, get_page() is used rather than get_page_unless_zero() because of
> __pmd_trans_huge_lock() is held ?

Yes, and page should be thp head page, so never have 0 refcount.
So I thought get_page() which has VM_BUG_ON(count<=0) is preferable.

>
> > +		}
> > +	}
> > +	return ret;
> > +}
> > +#else
> > +static inline int is_target_thp_for_mc(struct vm_area_struct *vma,
> > +		unsigned long addr, pmd_t pmd, union mc_target *target)
> > +{
> > +	return 0;
> > +}
> > +#endif
> > +
> >  static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
> >  					unsigned long addr, unsigned long end,
> >  					struct mm_walk *walk)
> > @@ -5219,7 +5254,14 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
> >  	pte_t *pte;
> >  	spinlock_t *ptl;
> >
> > -	split_huge_page_pmd(walk->mm, pmd);
> > +	if (pmd_trans_huge_lock(pmd, vma) == 1) {
> > +		if (is_target_thp_for_mc(vma, addr, *pmd, NULL)
> > +		    == MC_TARGET_PAGE)
> > +			mc.precharge += HPAGE_PMD_NR;
> > +		spin_unlock(&vma->vm_mm->page_table_lock);
> > +		cond_resched();
> > +		return 0;
> > +	}
>
> Maybe hard to read ;) I think is_target_thp_for_mc includes too much '_'
> and short words...
>
> Hmm, how about renaming "is_target_thp_for_mc"  as "pmd_move_target()" or some.
> (Ah yes, other handler's name should be fixed, too.)

As I wrote in the reply to Andrew, I want to go with get_mctgt_type[_thp]
if possible.

> >
> >  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> >  	for (; addr != end; pte++, addr += PAGE_SIZE)
> > @@ -5378,16 +5420,51 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
> >  	struct vm_area_struct *vma = walk->private;
> >  	pte_t *pte;
> >  	spinlock_t *ptl;
> > +	int type;
> > +	union mc_target target;
> > +	struct page *page;
> > +	struct page_cgroup *pc;
> > +
> > +	/*
> > +	 * We don't take compound_lock() here but no race with splitting thp
> > +	 * happens because:
> > +	 *  - if pmd_trans_huge_lock() returns 1, the relevant thp is not
> > +	 *    under splitting, which means there's no concurrent thp split,
> > +	 *  - if another thread runs into split_huge_page() just after we
> > +	 *    entered this if-block, the thread must wait for page table lock
> > +	 *    to be unlocked in __split_huge_page_splitting(), where the main
> > +	 *    part of thp split is not executed yet.
> > +	 */
>
> ok.
>
>
> > +	if (pmd_trans_huge_lock(pmd, vma) == 1) {
> > +		if (!mc.precharge) {
> > +			spin_unlock(&vma->vm_mm->page_table_lock);
> > +			cond_resched();
>
> Hm. Original code calls cond_resched() after 'scanning' the full pmd, 1024 entries.
> With THP, it just handles 1 entry. cond_resched() will not be required.

I agree.

> > +			return 0;
> > +		}
> > +		type = is_target_thp_for_mc(vma, addr, *pmd, &target);
> > +		if (type == MC_TARGET_PAGE) {
> > +			page = target.page;
> > +			if (!isolate_lru_page(page)) {
> > +				pc = lookup_page_cgroup(page);
> > +				if (!mem_cgroup_move_account(page, HPAGE_PMD_NR,
> > +							     pc, mc.from, mc.to,
> > +							     false)) {
> > +					mc.precharge -= HPAGE_PMD_NR;
> > +					mc.moved_charge += HPAGE_PMD_NR;
> > +				}
> > +				putback_lru_page(page);
> > +			}
> > +			put_page(page);
> > +		}
> > +		spin_unlock(&vma->vm_mm->page_table_lock);
> > +		cond_resched();
>
> ditto.
>
>
> > +		return 0;
> > +	}
> >
> > -	split_huge_page_pmd(walk->mm, pmd);
> >  retry:
> >  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> >  	for (; addr != end; addr += PAGE_SIZE) {
> >  		pte_t ptent = *(pte++);
> > -		union mc_target target;
> > -		int type;
> > -		struct page *page;
> > -		struct page_cgroup *pc;
> >  		swp_entry_t ent;
> >
> >  		if (!mc.precharge)
>
>
> Thank you for your efforts!

Thanks for taking time for the review.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
