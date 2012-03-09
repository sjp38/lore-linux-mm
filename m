Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 07F9A6B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 19:30:10 -0500 (EST)
Date: Thu, 8 Mar 2012 16:30:08 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 2/2] memcg: avoid THP split in task migration
Message-Id: <20120308163008.664dcdaf.akpm@linux-foundation.org>
In-Reply-To: <1330719189-20047-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1330719189-20047-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1330719189-20047-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Fri,  2 Mar 2012 15:13:09 -0500
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently we can't do task migration among memory cgroups without THP split,
> which means processes heavily using THP experience large overhead in task
> migration. This patch introduce the code for moving charge of THP and makes
> THP more valuable.

Some review input from Kame and Andrea would be good, please.

> diff --git linux-next-20120228.orig/mm/memcontrol.c linux-next-20120228/mm/memcontrol.c
> index c83aeb5..b6d1bab 100644
> --- linux-next-20120228.orig/mm/memcontrol.c
> +++ linux-next-20120228/mm/memcontrol.c
> @@ -5211,6 +5211,41 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
>  	return ret;
>  }
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +/*
> + * We don't consider swapping or file mapped pages because THP does not
> + * support them for now.
> + * Caller should make sure that pmd_trans_huge(pmd) is true.
> + */
> +static int is_target_thp_for_mc(struct vm_area_struct *vma,
> +		unsigned long addr, pmd_t pmd, union mc_target *target)
> +{
> +	struct page *page = NULL;
> +	struct page_cgroup *pc;
> +	int ret = 0;

This should be MC_TARGET_NONE.  And this function should have a return
type of "enum mc_target_type".  And local variable `ret' should have
type "enum mc_target_type" as well.

Also, the name "is_target_thp_for_mc" doesn't make sense: an "is_foo"
function should return a boolean result, but this function doesn't do
that.

> +	page = pmd_page(pmd);
> +	VM_BUG_ON(!page || !PageHead(page));
> +	if (!move_anon() || page_mapcount(page) != 1)

More page_mapcount tricks, and we just fixed a bug in the other one and
Hugh got upset.

Can we please at least document what we're doing here?  This reader
forgot, and cannot reremember.

> +		return 0;

MC_TARGET_NONE.

> +	pc = lookup_page_cgroup(page);
> +	if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
> +		ret = MC_TARGET_PAGE;
> +		if (target) {
> +			get_page(page);
> +			target->page = page;
> +		}
> +	}
> +	return ret;
> +}
> +#else
> +static inline int is_target_thp_for_mc(struct vm_area_struct *vma,
> +		unsigned long addr, pmd_t pmd, union mc_target *target)
> +{
> +	return 0;

MC_TARGET_NONE.

> +}
> +#endif
> +
>  static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
>  					unsigned long addr, unsigned long end,
>  					struct mm_walk *walk)
> @@ -5219,7 +5254,14 @@ static int mem_cgroup_count_precharge_pte_range(pmd_t *pmd,
>  	pte_t *pte;
>  	spinlock_t *ptl;
>  
> -	split_huge_page_pmd(walk->mm, pmd);
> +	if (pmd_trans_huge_lock(pmd, vma) == 1) {
> +		if (is_target_thp_for_mc(vma, addr, *pmd, NULL)
> +		    == MC_TARGET_PAGE)
> +			mc.precharge += HPAGE_PMD_NR;

That code layout is rather an eyesore :(

This:

		if (is_target_thp_for_mc(vma, addr, *pmd, NULL) == MC_TARGET_PAGE)
			mc.precharge += HPAGE_PMD_NR;

is probably better, but still an eyesore.  See if we can come up with a
shorter name than "is_target_thp_for_mc" and all will be fixed!

> +		spin_unlock(&vma->vm_mm->page_table_lock);
> +		cond_resched();
> +		return 0;
> +	}
>  
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	for (; addr != end; pte++, addr += PAGE_SIZE)
> @@ -5378,16 +5420,51 @@ static int mem_cgroup_move_charge_pte_range(pmd_t *pmd,
>  	struct vm_area_struct *vma = walk->private;
>  	pte_t *pte;
>  	spinlock_t *ptl;
> +	int type;

"enum mc_target_type".  Also choose a more specific name?  Perhaps
`target_type'.

> +	union mc_target target;
> +	struct page *page;
> +	struct page_cgroup *pc;
> +
> +	/*
> +	 * We don't take compound_lock() here but no race with splitting thp
> +	 * happens because:
> +	 *  - if pmd_trans_huge_lock() returns 1, the relevant thp is not
> +	 *    under splitting, which means there's no concurrent thp split,
> +	 *  - if another thread runs into split_huge_page() just after we
> +	 *    entered this if-block, the thread must wait for page table lock
> +	 *    to be unlocked in __split_huge_page_splitting(), where the main
> +	 *    part of thp split is not executed yet.
> +	 */
> +	if (pmd_trans_huge_lock(pmd, vma) == 1) {
> +		if (!mc.precharge) {
> +			spin_unlock(&vma->vm_mm->page_table_lock);
> +			cond_resched();
> +			return 0;
> +		}
> +		type = is_target_thp_for_mc(vma, addr, *pmd, &target);
> +		if (type == MC_TARGET_PAGE) {
> +			page = target.page;
> +			if (!isolate_lru_page(page)) {
> +				pc = lookup_page_cgroup(page);
> +				if (!mem_cgroup_move_account(page, HPAGE_PMD_NR,
> +							     pc, mc.from, mc.to,
> +							     false)) {
> +					mc.precharge -= HPAGE_PMD_NR;
> +					mc.moved_charge += HPAGE_PMD_NR;
> +				}
> +				putback_lru_page(page);
> +			}
> +			put_page(page);
> +		}
> +		spin_unlock(&vma->vm_mm->page_table_lock);
> +		cond_resched();
> +		return 0;
> +	}

cond_resched() is an ugly thing.  Are we sure that it is needed here?

> -	split_huge_page_pmd(walk->mm, pmd);
>  retry:
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	for (; addr != end; addr += PAGE_SIZE) {
>  		pte_t ptent = *(pte++);
> -		union mc_target target;
> -		int type;
> -		struct page *page;
> -		struct page_cgroup *pc;
>  		swp_entry_t ent;
>  
>  		if (!mc.precharge)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
