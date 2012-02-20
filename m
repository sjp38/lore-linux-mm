Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 8DD976B0083
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 06:39:01 -0500 (EST)
Received: by dadv6 with SMTP id v6so6965953dad.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 03:39:00 -0800 (PST)
Date: Mon, 20 Feb 2012 03:38:27 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
In-Reply-To: <1329722927-12108-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.00.1202200329420.4225@eggly.anvils>
References: <1329722927-12108-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Mon, 20 Feb 2012, Naoya Horiguchi wrote:
> On Sun, Feb 19, 2012 at 01:21:02PM -0800, Hugh Dickins wrote:
> > On Wed, 8 Feb 2012, Naoya Horiguchi wrote:
> > > Currently when we check if we can handle thp as it is or we need to
> > > split it into regular sized pages, we hold page table lock prior to
> > > check whether a given pmd is mapping thp or not. Because of this,
> > > when it's not "huge pmd" we suffer from unnecessary lock/unlock overhead.
> > > To remove it, this patch introduces a optimized check function and
> > > replace several similar logics with it.
> > > 
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Cc: David Rientjes <rientjes@google.com>
> > > 
> > > Changes since v4:
> > >   - Rethink returned value of __pmd_trans_huge_lock()
> > 
> > [snip]
> > 
> > > --- 3.3-rc2.orig/mm/mremap.c
> > > +++ 3.3-rc2/mm/mremap.c
> > > @@ -155,8 +155,6 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
> > >  			if (err > 0) {
> > >  				need_flush = true;
> > >  				continue;
> > > -			} else if (!err) {
> > > -				split_huge_page_pmd(vma->vm_mm, old_pmd);
> > >  			}
> > >  			VM_BUG_ON(pmd_trans_huge(*old_pmd));
> > >  		}
> 
> Thanks for reporting, 
> 
> > Is that what you intended to do there?
> 
> No. This is a bug.
> 
> > I just hit that VM_BUG_ON on rc3-next-20120217.
> 
> I found that when extend != HPAGE_PMD_SIZE, thp is not split so
> it hits the VM_BUG_ON.
> The following patch cancels the change in returned value in v4->v5
> and I confirmed this fixes the problem in my simple test.
> Andrew, could you add it on top of this optimization patch?
> 
> Naoya
> ----------------------------------------------------
> From 3c49816cab7d8cb072d9dffb97242e40f5124230 Mon Sep 17 00:00:00 2001
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Mon, 20 Feb 2012 01:48:12 -0500
> Subject: [PATCH] fix mremap bug of failing to split thp
> 
> The patch "thp: optimize away unnecessary page table locking" introduced
> a bug to move_page_tables(), where we fail to split thp when move_huge_pmd()
> is not called. To fix it, this patch reverts the return value changes and
> readd if (!err) block.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

That fixes the case I hit, thank you.  Though I did have to apply
the task_mmu.c part by hand, there are differences on neighbouring
lines.

Jiri, your "Regression: Bad page map in process xyz" is actually
on linux-next, isn't it?  I wonder if this patch will fix yours too
(you were using zypper, I was updating with yast2).

Hugh

> ---
>  fs/proc/task_mmu.c |    6 +++---
>  mm/huge_memory.c   |   13 ++++++-------
>  mm/mremap.c        |    2 ++
>  3 files changed, 11 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 7810281..2d12325 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -394,7 +394,7 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	pte_t *pte;
>  	spinlock_t *ptl;
>  
> -	if (pmd_trans_huge_lock(pmd, vma)) {
> +	if (pmd_trans_huge_lock(pmd, vma) == 1) {
>  		smaps_pte_entry(pmd_to_pte_t(pmd), addr, HPAGE_PMD_SIZE, walk);
>  		spin_unlock(&walk->mm->page_table_lock);
>  		mss->anonymous_thp += HPAGE_PMD_SIZE;
> @@ -696,7 +696,7 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	/* find the first VMA at or above 'addr' */
>  	vma = find_vma(walk->mm, addr);
>  
> -	if (pmd_trans_huge_lock(pmd, vma)) {
> +	if (pmd_trans_huge_lock(pmd, vma) == 1) {
>  		for (; addr != end; addr += PAGE_SIZE) {
>  			unsigned long offset = (addr & ~PAGEMAP_WALK_MASK)
>  				>> PAGE_SHIFT;
> @@ -973,7 +973,7 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
>  
>  	md = walk->private;
>  
> -	if (pmd_trans_huge_lock(pmd, md->vma)) {
> +	if (pmd_trans_huge_lock(pmd, md->vma) == 1) {
>  		pte_t huge_pte = pmd_to_pte_t(pmd);
>  		struct page *page;
>  
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index bbf57b5..f342bb2 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1030,7 +1030,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  {
>  	int ret = 0;
>  
> -	if (__pmd_trans_huge_lock(pmd, vma)) {
> +	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
>  		struct page *page;
>  		pgtable_t pgtable;
>  		pgtable = get_pmd_huge_pte(tlb->mm);
> @@ -1056,7 +1056,7 @@ int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  {
>  	int ret = 0;
>  
> -	if (__pmd_trans_huge_lock(pmd, vma)) {
> +	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
>  		/*
>  		 * All logical pages in the range are present
>  		 * if backed by a huge page.
> @@ -1094,12 +1094,11 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
>  		goto out;
>  	}
>  
> -	if (__pmd_trans_huge_lock(old_pmd, vma)) {
> +	if ((ret = __pmd_trans_huge_lock(old_pmd, vma)) == 1) {
>  		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
>  		VM_BUG_ON(!pmd_none(*new_pmd));
>  		set_pmd_at(mm, new_addr, new_pmd, pmd);
>  		spin_unlock(&mm->page_table_lock);
> -		ret = 1;
>  	}
>  out:
>  	return ret;
> @@ -1111,7 +1110,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	struct mm_struct *mm = vma->vm_mm;
>  	int ret = 0;
>  
> -	if (__pmd_trans_huge_lock(pmd, vma)) {
> +	if (__pmd_trans_huge_lock(pmd, vma) == 1) {
>  		pmd_t entry;
>  		entry = pmdp_get_and_clear(mm, addr, pmd);
>  		entry = pmd_modify(entry, newprot);
> @@ -1125,7 +1124,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  
>  /*
>   * Returns 1 if a given pmd maps a stable (not under splitting) thp.
> - * Returns 0 otherwise.
> + * Returns -1 if it maps a thp under splitting. Returns 0 otherwise.
>   *
>   * Note that if it returns 1, this routine returns without unlocking page
>   * table locks. So callers must unlock them.
> @@ -1137,7 +1136,7 @@ int __pmd_trans_huge_lock(pmd_t *pmd, struct vm_area_struct *vma)
>  		if (unlikely(pmd_trans_splitting(*pmd))) {
>  			spin_unlock(&vma->vm_mm->page_table_lock);
>  			wait_split_huge_page(vma->anon_vma, pmd);
> -			return 0;
> +			return -1;
>  		} else {
>  			/* Thp mapped by 'pmd' is stable, so we can
>  			 * handle it as it is. */
> diff --git a/mm/mremap.c b/mm/mremap.c
> index 22458b9..87bb839 100644
> --- a/mm/mremap.c
> +++ b/mm/mremap.c
> @@ -155,6 +155,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  			if (err > 0) {
>  				need_flush = true;
>  				continue;
> +			} else if (!err) {
> +				split_huge_page_pmd(vma->vm_mm, old_pmd);
>  			}
>  			VM_BUG_ON(pmd_trans_huge(*old_pmd));
>  		}
> -- 
> 1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
