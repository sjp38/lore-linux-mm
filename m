Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 52D426B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 04:50:35 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC][PATCH] memcg: avoid THP split in task migration
Date: Wed, 29 Feb 2012 04:50:20 -0500
Message-Id: <1330509020-6901-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120229092859.a0411859.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

Hi,

On Wed, Feb 29, 2012 at 09:28:59AM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 28 Feb 2012 16:12:32 -0500
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
...
> > @@ -5378,16 +5420,38 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
> >  	struct vm_area_struct *vma = walk->private;
> >  	pte_t *pte;
> >  	spinlock_t *ptl;
> > +	int type;
> > +	union mc_target target;
> > +	struct page *page;
> > +	struct page_cgroup *pc;
> > +
> > +	if (pmd_trans_huge_lock(pmd, vma) == 1) {
> > +		if (!mc.precharge)
> > +			return 0;
> > +		type = is_target_huge_pmd_for_mc(vma, addr, *pmd, &target);
> > +		if (type == MC_TARGET_PAGE) {
> > +			page = target.page;
> > +			if (!isolate_lru_page(page)) {
> > +				pc = lookup_page_cgroup(page);
>
> Here is a diffuclut point. Please see mem_cgroup_split_huge_fixup(). It splits
> updates memcg's status of splitted pages under lru_lock and compound_lock
> but not under mm->page_table_lock.

OK, I rethink locking.
mem_cgroup_move_account() also states that the caller should hold compound_lock(),
so I should follow that.

> Looking into split_huge_page()
>
> 	split_huge_page()  # take anon_vma lock
> 		__split_huge_page()
> 			__split_huge_page_refcount() # take lru_lock, compound_lock.
> 				mem_cgroup_split_huge_fixup()
> 			__split_huge_page_map() # take page table lock.

I'm afraid this callchain is not correct.
Page table lock seems to be taken before we enter the main split work.

    split_huge_page
        take anon_vma lock
        __split_huge_page
            __split_huge_page_splitting
                lock page_table_lock     <--- *1
                page_check_address_pmd
                unlock page_table_lock
            __split_huge_page_refcount
                lock lru_lock
                compound_lock
                mem_cgroup_split_huge_fixup
                compound_unlock
                unlock lru_lock
            __split_huge_page_map
                lock page_table_lock
                ... some work
                unlock page_table_lock
        unlock anon_vma lock

> I'm not fully sure but IIUC, pmd_trans_huge_lock() just guarantees a huge page "map"
> never goes out. To avoid page splitting itself, compound_lock() is required, I think.
>
> So, the lock here should be
>
> 	page = target.page;
> 	isolate_lru_page(page);
> 	flags = compound_lock_irqsave(page);

I think the race between task migration and thp split does not happen
because of 2 reasons:

  - when we enter the if-block, there is no concurrent thp splitting
    (note that pmd_trans_huge_lock() returns 1 only if the thp is not
     under splitting,)

  - if another thread runs into split_huge_page() just after we entered
    this if-block, the thread waits for page table lock to be unlocked
    in __split_huge_page_splitting() (shown *1 above.) At this point,
    the thp has not been split yet.

But I think it's OK to add compound_lock to meet the requisition of
mem_cgroup_move_account().

>
>
> > +				if (!mem_cgroup_move_account(page, HPAGE_PMD_NR,
> > +							     pc, mc.from, mc.to,
> > +							     false)) {
> > +					mc.precharge -= HPAGE_PMD_NR;
> > +					mc.moved_charge += HPAGE_PMD_NR;
> > +				}
>
> Here is PageTransHuge() is checked in mem_cgroup_move_account() and if !PageTransHuge(),
> the function returns -EBUSY.

If the above explanation is correct, PageTransHuge() should always be
true here, so BUG_ON(!PageTransHuge()) looks suitable for me.

> I'm not sure but....it's not worth to retry (but add a comment as FIXME later!)

I agree.
For regular size pages, retrying means that we run out of mc.precharge
before addr reaches to end.
But mem_cgroup_move_charge_pte_range() runs over a pmd in a single call and
addr reaches to end only one call of mem_cgroup_move_account() for thp.
So it makes no sense to retry.

> 	compound_unlock_irqrestore(page);
>
> I may miss something, please check carefully, again.

OK.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
