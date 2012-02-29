Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 3634C6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:39:31 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC][PATCH] memcg: avoid THP split in task migration
Date: Wed, 29 Feb 2012 14:39:16 -0500
Message-Id: <1330544356-13847-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAJd=RBAVaWud3f6AUSr1PDWS_VvBgiSMobRdLyokwx3bcHqCKQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Feb 29, 2012 at 10:40:09PM +0800, Hillf Danton wrote:
> On Wed, Feb 29, 2012 at 8:28 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Tue, 28 Feb 2012 16:12:32 -0500
> > Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> >
> >> Currently we can't do task migration among memory cgroups without THP split,
> >> which means processes heavily using THP experience large overhead in task
> >> migration. This patch introduce the code for moving charge of THP and makes
> >> THP more valuable.
> >>
> >> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >> Cc: Hillf Danton <dhillf@gmail.com>
> >
> >
> > Thank you!
>
>    ++hd;

Thank you, too.

> >
> > A comment below.
> >
> >> ---
> >> mm/memcontrol.c |  76 ++++++++++++++++++++++++++++++++++++++++++++++++++----
> >> 1 files changed, 70 insertions(+), 6 deletions(-)
> >>
> >> diff --git linux-next-20120228.orig/mm/memcontrol.c linux-next-20120228/mm/memcontrol.c
> >> index c83aeb5..e97c041 100644
> >> --- linux-next-20120228.orig/mm/memcontrol.c
> >> +++ linux-next-20120228/mm/memcontrol.c
> >> @@ -5211,6 +5211,42 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
> >>    return ret;
> >> }
> >>
> >> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >> +/*
> >> + * We don't consider swapping or file mapped pages because THP does not
> >> + * support them for now.
> >> + */
> >> +static int is_target_huge_pmd_for_mc(struct vm_area_struct *vma,
>
> static int is_target_thp_for_mc(struct vm_area_struct *vma,
> or
> static int is_target_pmd_for_mc(struct vm_area_struct *vma,
> sounds better?

OK, I take the former one.
It's better than the original one because it can avoid potential
name conflict when we implement hugetlbfs variant in the future.

> >> +       unsigned long addr, pmd_t pmd, union mc_target *target)
> >> +{
> >> +   struct page *page = NULL;
> >> +   struct page_cgroup *pc;
> >> +   int ret = 0;
> >> +
> >> +   if (pmd_present(pmd))
> >> +       page = pmd_page(pmd);
> >> +   if (!page)
> >> +       return 0;
> >> +   VM_BUG_ON(!PageHead(page));
>
> With a huge and stable pmd, the above operations on page could be
> compacted into one line?
>
> 	page = pmd_page(pmd);

It's possible under the assumption that thp pmd always has present bit
set and points to the head page. I guess this assumption is true at
least for now, but I'm not sure. Is that true without any exception?
I think that if we miss something and this assumption is not the case,
VM_BUG_ON() can be helpful to know what happened in future bugfix.
But anyway, we should add a comment about the assumption if we do this
optimization.

> >> +   get_page(page);
> >> +   pc = lookup_page_cgroup(page);
> >> +   if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
> >> +       ret = MC_TARGET_PAGE;
> >> +       if (target)
>
> After checking target, looks only get_page() needed?

Do you mean something like this (combined with above optimization:)

  static int is_target_huge_pmd_for_mc(struct vm_area_struct *vma,
                  unsigned long addr, pmd_t pmd, union mc_target *target)
  {
          struct page *page = NULL;
          struct page_cgroup *pc;
          int ret = 0;

          /*
           * Here we skip pmd_present() check and NULL page check, assuming
           * that thp pmd has always present bit set and points to the head
           * page.
           */
          page = pmd_page(pmd);
          VM_BUG_ON(!page || !PageHead(page));
          pc = lookup_page_cgroup(page);
          if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
                  ret = MC_TARGET_PAGE;
                  if (target) {
                          get_page(page);
                          target->page = page;
                  }
          }
          return ret;
  }

?
I think this is possible because lookup_page_cgroup() does not depend
on refcount.

> >> +           target->page = page;
> >> +   }
> >> +   if (!ret || !target)
> >> +       put_page(page);
> >> +   return ret;
> >> +}
> >> +#else
> >> +static inline int is_target_huge_pmd_for_mc(struct vm_area_struct *vma,
> >> +       unsigned long addr, pmd_t pmd, union mc_target *target)
> >> +{
> >> +   return 0;
> >> +}
> >> +#endif
> >> +
> >> static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
> >>                    unsigned long addr, unsigned long end,
> >>                    struct mm_walk *walk)
> >> @@ -5219,7 +5255,13 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
> >>    pte_t *pte;
> >>    spinlock_t *ptl;
> >>
> >> -   split_huge_page_pmd(walk->mm, pmd);
> >> +   if (pmd_trans_huge_lock(pmd, vma) == 1) {
> >> +       if (is_target_huge_pmd_for_mc(vma, addr, *pmd, NULL))
>
> 		if (is_target_huge_pmd_for_mc(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
> looks clearer

I agree.

> >> +           mc.precharge += HPAGE_PMD_NR;
>
> As HPAGE_PMD_NR is directly used, compiler beeps if THP disabled, I guess.

Yes, HPAGE_PMD_NR need to be defined for !CONFIG_TRANSPARENT_HUGEPAGE.

> If yes, please cleanup huge_mm.h with s/BUG()/BUILD_BUG()/ and with
> both HPAGE_PMD_ORDER and HPAGE_PMD_NR also defined,
> to easy others a bit.

Thanks, I applied it.

> >> +       spin_unlock(&walk->mm->page_table_lock);
>
> 		spin_unlock(&vma->mm->page_table_lock);
> looks clearer

OK.

> >> +       cond_resched();
> >> +       return 0;
> >> +   }
> >>
> >>    pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> >>    for (; addr != end; pte++, addr += PAGE_SIZE)
> >> @@ -5378,16 +5420,38 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
> >>    struct vm_area_struct *vma = walk->private;
> >>    pte_t *pte;
> >>    spinlock_t *ptl;
> >> +   int type;
> >> +   union mc_target target;
> >> +   struct page *page;
> >> +   struct page_cgroup *pc;
> >> +
> >> +   if (pmd_trans_huge_lock(pmd, vma) == 1) {
> >> +       if (!mc.precharge)
> >> +           return 0;
>
> Bang, return without page table lock released.

Sorry, I missed it.

> >> +       type = is_target_huge_pmd_for_mc(vma, addr, *pmd, &target);
> >> +       if (type == MC_TARGET_PAGE) {
> >> +           page = target.page;
> >> +           if (!isolate_lru_page(page)) {
> >> +               pc = lookup_page_cgroup(page);
> >
> > Here is a diffuclut point. Please see mem_cgroup_split_huge_fixup(). It splits
>
> Hard and hard point IMO.

Yes.

> > updates memcg's status of splitted pages under lru_lock and compound_lock
> > but not under mm->page_table_lock.
> >
> > Looking into split_huge_page()
> >
> >    split_huge_page() # take anon_vma lock
> >        __split_huge_page()
> >            __split_huge_page_refcount() # take lru_lock, compound_lock.
> >                mem_cgroup_split_huge_fixup()
> >            __split_huge_page_map() # take page table lock.
> >
> [copied from Naoya-san's reply]
>
> > I'm afraid this callchain is not correct.
>
> s/correct/complete/
>
> > Page table lock seems to be taken before we enter the main split work.
> >
> >  split_huge_page
> >    take anon_vma lock
> >    __split_huge_page
> >      __split_huge_page_splitting
> >        lock page_table_lock   <--- *1
> >        page_check_address_pmd
> >        unlock page_table_lock
>
> Yeah, splitters are blocked.
> Plus from the *ugly* documented lock function(another
> cleanup needed), the embedded mmap_sem also blocks splitters.

Although I didn't check all callers of split_huge_page() thoroughly,
in my quick checking most of callers hold mmap_sem before kicking split.
And if all callers hold mmap_sem, we can expect to avoid the race
by mmap_sem. I'll take some times to find out the dependency on mmap_sem
of all callers finely.

As for the documentation cleanup, I am not sure what it should be.
I'm sorry if I can't keep up with you, but are you suggesting that
we should document not only the locking rule around pmd_trans_huge_lock(),
but also update whole locking rules in mm subsystem like described in
Documentation/vm/locking, or something else?

> That said, could we simply wait and see results of test cases?

OK.

Thank you for your valuable reviews.
Naoya

> -hd
>
> /* mmap_sem must be held on entry */
> static inline int pmd_trans_huge_lock(pmd_t *pmd,
> 				      struct vm_area_struct *vma)
> {
> 	VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem));
> 	if (pmd_trans_huge(*pmd))
> 		return __pmd_trans_huge_lock(pmd, vma);
> 	else
> 		return 0;
> }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
