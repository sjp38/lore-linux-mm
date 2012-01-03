Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id E39926B006C
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 15:09:41 -0500 (EST)
Message-ID: <4F036041.4090605@ah.jp.nec.com>
Date: Tue, 03 Jan 2012 15:08:33 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] thp: optimize away unnecessary page table locking
References: <1324506228-18327-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1324506228-18327-3-git-send-email-n-horiguchi@ah.jp.nec.com> <4EFD3739.7070609@gmail.com>
In-Reply-To: <4EFD3739.7070609@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Thu, Dec 29, 2011 at 10:59:53PM -0500, KOSAKI Motohiro wrote:
...
> > @@ -689,26 +681,19 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> >   	/* find the first VMA at or above 'addr' */
> >   	vma = find_vma(walk->mm, addr);
> > 
> > -	spin_lock(&walk->mm->page_table_lock);
> > -	if (pmd_trans_huge(*pmd)) {
> > -		if (pmd_trans_splitting(*pmd)) {
> > -			spin_unlock(&walk->mm->page_table_lock);
> > -			wait_split_huge_page(vma->anon_vma, pmd);
> > -		} else {
> > -			for (; addr != end; addr += PAGE_SIZE) {
> > -				int offset = (addr&  ~PAGEMAP_WALK_MASK)
> > -					>>  PAGE_SHIFT;
> > -				pfn = thp_pte_to_pagemap_entry(*(pte_t *)pmd,
> > -							       offset);
> > -				err = add_to_pagemap(addr, pfn, pm);
> > -				if (err)
> > -					break;
> > -			}
> > -			spin_unlock(&walk->mm->page_table_lock);
> > -			return err;
> > +	/* David comment */
> 
> This commnet doesn't explain anything.

Sorry, I forgot to remove.

...
> > diff --git 3.2-rc5.orig/mm/huge_memory.c 3.2-rc5/mm/huge_memory.c
> > index 36b3d98..b73c744 100644
> > --- 3.2-rc5.orig/mm/huge_memory.c
> > +++ 3.2-rc5/mm/huge_memory.c
...
> > @@ -1104,27 +1080,45 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> >   	struct mm_struct *mm = vma->vm_mm;
> >   	int ret = 0;
> > 
> > -	spin_lock(&mm->page_table_lock);
> > -	if (likely(pmd_trans_huge(*pmd))) {
> > -		if (unlikely(pmd_trans_splitting(*pmd))) {
> > -			spin_unlock(&mm->page_table_lock);
> > -			wait_split_huge_page(vma->anon_vma, pmd);
> > -		} else {
> > -			pmd_t entry;
> > +	if (likely(check_and_wait_split_huge_pmd(pmd, vma))) {
> > +		pmd_t entry;
> > 
> > -			entry = pmdp_get_and_clear(mm, addr, pmd);
> > -			entry = pmd_modify(entry, newprot);
> > -			set_pmd_at(mm, addr, pmd, entry);
> > -			spin_unlock(&vma->vm_mm->page_table_lock);
> > -			flush_tlb_range(vma, addr, addr + HPAGE_PMD_SIZE);
> > -			ret = 1;
> > -		}
> > -	} else
> > +		entry = pmdp_get_and_clear(mm, addr, pmd);
> > +		entry = pmd_modify(entry, newprot);
> > +		set_pmd_at(mm, addr, pmd, entry);
> >   		spin_unlock(&vma->vm_mm->page_table_lock);
> > +		flush_tlb_range(vma, addr, addr + HPAGE_PMD_SIZE);
> > +		ret = 1;
> > +	}
> > 
> >   	return ret;
> >   }
> > 
> > +/*
> > + * Returns 1 if a given pmd is mapping a thp and stable (not under splitting.)
> > + * Returns 0 otherwise. Note that if it returns 1, this routine returns without
> > + * unlocking page table locks. So callers must unlock them.
> > + */
> > +int check_and_wait_split_huge_pmd(pmd_t *pmd, struct vm_area_struct *vma)
> 
> We always should avoid a name of "check". It doesn't explain what the
> function does.

How about pmd_trans_huge_stable()?

> 
> > +{
> 
> VM_BUG_ON(!rwsem_is_locked(vma->mm)) here?

OK, I will add VM_BUG_ON(!rwsem_is_locked(vma->mm->mmap_sem)),
which helps us make sure that new user of this function holds mmap_sem.

> > +	if (!pmd_trans_huge(*pmd))
> > +		return 0;
> > +
> > +	spin_lock(&vma->vm_mm->page_table_lock);
> > +	if (likely(pmd_trans_huge(*pmd))) {
> > +		if (pmd_trans_splitting(*pmd)) {
> > +			spin_unlock(&vma->vm_mm->page_table_lock);
> > +			wait_split_huge_page(vma->anon_vma, pmd);
> > +		} else {
> > +			/* Thp mapped by 'pmd' is stable, so we can
> > +			 * handle it as it is. */
> > +			return 1;
> > +		}
> > +	}
> > +	spin_unlock(&vma->vm_mm->page_table_lock);
> > +	return 0;
> > +}
> > +
> >   pmd_t *page_check_address_pmd(struct page *page,
> >   			      struct mm_struct *mm,
> >   			      unsigned long address,
> > diff --git 3.2-rc5.orig/mm/mremap.c 3.2-rc5/mm/mremap.c
> > index d6959cb..d534668 100644
> > --- 3.2-rc5.orig/mm/mremap.c
> > +++ 3.2-rc5/mm/mremap.c
> > @@ -155,9 +155,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
> >   			if (err>  0) {
> >   				need_flush = true;
> >   				continue;
> > -			} else if (!err) {
> > -				split_huge_page_pmd(vma->vm_mm, old_pmd);
> >   			}
> > +			split_huge_page_pmd(vma->vm_mm, old_pmd);
> 
> unrelated hunk?

All users (except one) of the logic which I want to replace with
check_and_wait_split_huge_pmd() expect it to return:
  1: when pmd maps thp and is not under splitting,
  0: when pmd maps thp and is under splitting,
  0: when pmd doesn't map thp.

But only move_huge_pmd() expects differently:
  1: when pmd maps thp and is not under splitting,
 -1: when pmd maps thp and is under splitting,
  0: when pmd doesn't map thp.

move_huge_pmd() is used only around the above hunk, so I chose to change
the caller. It makes no behavioral change because split_huge_page_pmd()
does nothing when old_pmd doesn't map thp.
Is it better to separate changing return value into another patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
