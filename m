Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id EE12D6B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 15:22:26 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC][PATCH] memcg: avoid THP split in task migration
Date: Thu,  1 Mar 2012 15:22:16 -0500
Message-Id: <1330633336-10707-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120301023314.GF28383@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

Hi Andrea,

On Thu, Mar 01, 2012 at 03:33:14AM +0100, Andrea Arcangeli wrote:
> Hi Naoya,
>
> On Tue, Feb 28, 2012 at 04:12:32PM -0500, Naoya Horiguchi wrote:
> > Currently we can't do task migration among memory cgroups without THP split,
> > which means processes heavily using THP experience large overhead in task
> > migration. This patch introduce the code for moving charge of THP and makes
> > THP more valuable.
>
> Nice.
>
> > diff --git linux-next-20120228.orig/mm/memcontrol.c linux-next-20120228/mm/memcontrol.c
> > index c83aeb5..e97c041 100644
> > --- linux-next-20120228.orig/mm/memcontrol.c
> > +++ linux-next-20120228/mm/memcontrol.c
> > @@ -5211,6 +5211,42 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
> >  	return ret;
> >  }
> >
> > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +/*
> > + * We don't consider swapping or file mapped pages because THP does not
> > + * support them for now.
> > + */
> > +static int is_target_huge_pmd_for_mc(struct vm_area_struct *vma,
> > +		unsigned long addr, pmd_t pmd, union mc_target *target)
> > +{
> > +	struct page *page = NULL;
> > +	struct page_cgroup *pc;
> > +	int ret = 0;
> > +
> > +	if (pmd_present(pmd))
> > +		page = pmd_page(pmd);
> > +	if (!page)
> > +		return 0;
>
> It can't be present and null at the same time.
>
> No need to check pmd_present if you already checked pmd_trans_huge. In
> fact checking pmd_present is a bug. For a little time the pmd won't be
> present if it's set as splitting. (that short clearing of pmd_present
> during pmd splitting is to deal with a vendor CPU errata without
> having to flush the smp TLB twice)

I understand. This is a little-known optimization.

> Following Kame's suggestion is correct, an unconditional pmd_page is
> correct here:
>
>     page = pmd_page(pmd);

I agree. I'll take up the suggestion.

> We might actually decide to change pmd_present to return true if
> pmd_trans_splitting is set to avoid the risk of using an erratic
> pmd_present on a pmd_trans_huge pmd, but it's not really necessary if
> you never check pmd_present when a pmd is (or can be) a
> pmd_trans_huge.

OK.

> The safe check for pmd is only pmd_none, never pmd_present (as in
> __pte_alloc/pte_alloc_map/...).
>
> > +	VM_BUG_ON(!PageHead(page));
> > +	get_page(page);
>
> Other review mentioned we can do get_page only when it succeeds, but I
> think we can drop the whole get_page and simplify it further see the
> end.

See below.

> > @@ -5219,7 +5255,13 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
> >  	pte_t *pte;
> >  	spinlock_t *ptl;
> >
> > -	split_huge_page_pmd(walk->mm, pmd);
> > +	if (pmd_trans_huge_lock(pmd, vma) == 1) {
> > +		if (is_target_huge_pmd_for_mc(vma, addr, *pmd, NULL))
> > +			mc.precharge += HPAGE_PMD_NR;
>
> Your use of HPAGE_PMD_NR looks fine, that path will be eliminated at
> build time if THP is off. This is the nice way to write code that is
> already optimal for THP=off without making special cases or #ifdefs.
>
> Other review suggests changing HPAGE_PMD_NR as BUILD_BUG, that sounds
> good idea too, but in this (correct) usage of HPAGE_PMD_NR it wouldn't
> make a difference because of the whole branch is correctly eliminated
> at build time. In short changing it to BUILD_BUG will simply make sure
> the whole pmd_trans_huge_lock == 1 branch is eliminated at build
> time. It looks good change too but it's orthogonal so I'd leave it for
> a separate patch.

In my trial, without changing HPAGE_PMD_NR as BUILD_BUG a build did not
pass with !CONFIG_TRANSPARENT_HUGEPAGE as Hillf said.
Evaluating HPAGE_PMD_NR seems to be prior to eliminating whole
pmd_trans_huge_lock == 1 branch, so I think this change is necessary.
And I agree to add this change with a separate patch.

> > +		spin_unlock(&walk->mm->page_table_lock);
>
> Agree with other review, vma looks cleaner.

I fixed it.

> > +		cond_resched();
> > +		return 0;
> > +	}
> >
> >  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> >  	for (; addr != end; pte++, addr += PAGE_SIZE)
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
>
> Agree with Hillf.

ditto.

> > +		type = is_target_huge_pmd_for_mc(vma, addr, *pmd, &target);
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
>
> Like you mentioned, a race with split_huge_page_refcount (and hence
> mem_cgroup_split_huge_fixup) is not possible because of
> pmd_trans_huge_lock succeeding.
>
> However the mmap_sem checked by pmd_trans_huge_lock is there just
> because we deal with pmds and so pagetables (and we aren't doing a
> lockless lookup like gup_fast). But it's not true that a concurrent
> split_huge_page would _not_ prevented by the mmap_sem. The swapout
> path will still split hugepages under you even if you hold the
> mmap_sem (even in write mode).

You're right. I also confirmed that add_to_swap() is called without
downing mmap_sem. Moreover, migrate_page() and hwpoison_user_mappings()
are also the same examples.

> The mmap_sem (either read or write) only prevents a concurrent
> collapsing/creation of hugepages (but that's irrelevant here). It
> won't stop split_huge_page.
>
> So - back to our issue - you're safe against split_huge_page not
> running here thanks to the pmd_trans_huge_lock.

OK. I will add the comment here about why this race does not happen.

> There's one tricky locking bit here, that is isolate_lru_page, that
> takes the lru_lock.
>
> So the lock order is the page_table_lock first and the lru_lock
> second, and so there must not be another place that takes the lru_lock
> first and the page_table_lock second. In general it's good idea to
> exercise locking code with lockdep prove locking enabled just in case.

This lock ordering is also described at the head of mm/rmap.c,
and should be obeyed.
And I do (and will) enable lockdep for more dependable testing.

> > +				putback_lru_page(page);
> > +			}
> > +			put_page(page);
>
> I wonder if you need a get_page at all in is_target_huge_pmd_for_mc if
> you drop the above put_page instead. How can this page go away from
> under us, if we've been holding the page_table_lock the whole time?
> You can probably drop both get_page above and put_page above.

I wrote this get/put_page() based on existing code for regular size pages.
In my guess, for regular size pages, someone like memory hotplug can call
put_page() without holding page_table_lock, so the original coder may added
this get/put_page() to protect from it. And if it is applicable to thp
(current memory hotplug code does not call split_huge_page() explicitly,
so I think it is,) this get/put_page() makes us more safe.

> > +		}
> > +		spin_unlock(&walk->mm->page_table_lock);
> > +		cond_resched();
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
> I read the other two great reviews done so far in parallel with the
> code, and I ended up replying here to the code as I was reading it,
> hope it wasn't too confusing.

Thank you very much for suggestive comments.
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
