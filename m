Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 4BCFE6B00A7
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 12:23:14 -0500 (EST)
Message-ID: <4F145C17.1060009@ah.jp.nec.com>
Date: Mon, 16 Jan 2012 12:19:19 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Sat, Jan 14, 2012 at 06:19:56PM +0100, Andrea Arcangeli wrote:
> On Thu, Jan 12, 2012 at 02:34:54PM -0500, Naoya Horiguchi wrote:
...
> > index 36b3d98..b7811df 100644
> > --- 3.2-rc5.orig/mm/huge_memory.c
> > +++ 3.2-rc5/mm/huge_memory.c
> > @@ -1001,29 +1001,21 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> >  {
> >  	int ret = 0;
> >  
> > -	spin_lock(&tlb->mm->page_table_lock);
> > -	if (likely(pmd_trans_huge(*pmd))) {
> > -		if (unlikely(pmd_trans_splitting(*pmd))) {
> > -			spin_unlock(&tlb->mm->page_table_lock);
> > -			wait_split_huge_page(vma->anon_vma,
> > -					     pmd);
> > -		} else {
> > -			struct page *page;
> > -			pgtable_t pgtable;
> > -			pgtable = get_pmd_huge_pte(tlb->mm);
> > -			page = pmd_page(*pmd);
> > -			pmd_clear(pmd);
> > -			page_remove_rmap(page);
> > -			VM_BUG_ON(page_mapcount(page) < 0);
> > -			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> > -			VM_BUG_ON(!PageHead(page));
> > -			spin_unlock(&tlb->mm->page_table_lock);
> > -			tlb_remove_page(tlb, page);
> > -			pte_free(tlb->mm, pgtable);
> > -			ret = 1;
> > -		}
> > -	} else
> > +	if (likely(pmd_trans_huge_stable(pmd, vma))) {
> > +		struct page *page;
> > +		pgtable_t pgtable;
> > +		pgtable = get_pmd_huge_pte(tlb->mm);
> > +		page = pmd_page(*pmd);
> > +		pmd_clear(pmd);
> > +		page_remove_rmap(page);
> > +		VM_BUG_ON(page_mapcount(page) < 0);
> > +		add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> > +		VM_BUG_ON(!PageHead(page));
> >  		spin_unlock(&tlb->mm->page_table_lock);
> > +		tlb_remove_page(tlb, page);
> > +		pte_free(tlb->mm, pgtable);
> > +		ret = 1;
> > +	}
> 
> This has been micro slowed down. I think you should use
> pmd_trans_huge_stable only in places where pmd_trans_huge cannot be
> set. I would back out the above as it's a micro-regression.

I guess this micro-regression happens because I failed to correctly replace
likely()/unlikey() applied to pmd_trans_huge() and pmd_trans_splitting().
I should have keep them in pmd_trans_huge_stable() instead of applying
likely() on pmd_trans_huge_stable().

> Maybe what you could do if you want to clean it up further is to make
> a static inline in huge_mm of pmd_trans_huge_stable that only checks
> pmd_trans_huge and then calls __pmd_trans_huge_stable, and use
> __pmd_trans_huge_stable above.

OK, I agree.

> > @@ -1034,21 +1026,14 @@ int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> >  {
> >  	int ret = 0;
> >  
> > -	spin_lock(&vma->vm_mm->page_table_lock);
> > -	if (likely(pmd_trans_huge(*pmd))) {
> > -		ret = !pmd_trans_splitting(*pmd);
> > -		spin_unlock(&vma->vm_mm->page_table_lock);
> > -		if (unlikely(!ret))
> > -			wait_split_huge_page(vma->anon_vma, pmd);
> > -		else {
> > -			/*
> > -			 * All logical pages in the range are present
> > -			 * if backed by a huge page.
> > -			 */
> > -			memset(vec, 1, (end - addr) >> PAGE_SHIFT);
> > -		}
> > -	} else
> > +	if (likely(pmd_trans_huge_stable(pmd, vma))) {
> > +		/*
> > +		 * All logical pages in the range are present
> > +		 * if backed by a huge page.
> > +		 */
> >  		spin_unlock(&vma->vm_mm->page_table_lock);
> > +		memset(vec, 1, (end - addr) >> PAGE_SHIFT);
> > +	}
> >  
> >  	return ret;
> >  }
> 
> same slowdown here. Here even __pmd_trans_huge_stable wouldn't be
> enough to optimize it as it'd still generate more .text with two
> spin_unlock (one in __pmd_trans_huge_stable and one retained above)
> instead of just 1 in the original version.

Yes, additional spin_unlock() raises the binary size of mincore_huge_pmd().
But replacing with __pmd_trans_huge_stable() which unifies duplicate codes
reduces the binary size too. I think the amount of size reduction is larger
than that of size growth of additional spin_unlock().

> I'd avoid the cleanup for
> the above ultra optimized version.

Anyway if you don't like this replacement, I'll leave it as it is.

> > @@ -1078,21 +1063,12 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
> >  		goto out;
> >  	}
> >  
> > -	spin_lock(&mm->page_table_lock);
> > -	if (likely(pmd_trans_huge(*old_pmd))) {
> > -		if (pmd_trans_splitting(*old_pmd)) {
> > -			spin_unlock(&mm->page_table_lock);
> > -			wait_split_huge_page(vma->anon_vma, old_pmd);
> > -			ret = -1;
> > -		} else {
> > -			pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
> > -			VM_BUG_ON(!pmd_none(*new_pmd));
> > -			set_pmd_at(mm, new_addr, new_pmd, pmd);
> > -			spin_unlock(&mm->page_table_lock);
> > -			ret = 1;
> > -		}
> > -	} else {
> > +	if (likely(pmd_trans_huge_stable(old_pmd, vma))) {
> > +		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
> > +		VM_BUG_ON(!pmd_none(*new_pmd));
> > +		set_pmd_at(mm, new_addr, new_pmd, pmd);
> >  		spin_unlock(&mm->page_table_lock);
> > +		ret = 1;
> >  	}
> 
> Same slowdown here, needs __pmd_trans_huge_stable as usual, but you
> are now forcing mremap to call split_huge_page even if it's not needed
> (i.e. after wait_split_huge_page).

I didn't think the behavior changes but this can be performance regression
of additional if-check. As you commented below, we had better go to change
the return value of wait_split_huge_page path in __pmd_trans_huge_stable().

> I'd like no-regression cleanups so
> I'd reverse the above and avoid changing already ultra-optimized code
> paths.

I agree.

> >  out:
> >  	return ret;
> > @@ -1104,27 +1080,48 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> >  	struct mm_struct *mm = vma->vm_mm;
> >  	int ret = 0;
> >  
> > -	spin_lock(&mm->page_table_lock);
> > -	if (likely(pmd_trans_huge(*pmd))) {
> > -		if (unlikely(pmd_trans_splitting(*pmd))) {
> > -			spin_unlock(&mm->page_table_lock);
> > -			wait_split_huge_page(vma->anon_vma, pmd);
> > -		} else {
> > -			pmd_t entry;
> > +	if (likely(pmd_trans_huge_stable(pmd, vma))) {
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
> >  		spin_unlock(&vma->vm_mm->page_table_lock);
> > +		flush_tlb_range(vma, addr, addr + HPAGE_PMD_SIZE);
> > +		ret = 1;
> > +	}
> >  
> >  	return ret;
> 
> Needs __pmd_trans_huge_stable. Ok to cleanup with that (no regression
> in this case with the __ version).
> 
> > diff --git 3.2-rc5.orig/mm/mremap.c 3.2-rc5/mm/mremap.c
> > index d6959cb..d534668 100644
> > --- 3.2-rc5.orig/mm/mremap.c
> > +++ 3.2-rc5/mm/mremap.c
> > @@ -155,9 +155,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
> >  			if (err > 0) {
> >  				need_flush = true;
> >  				continue;
> > -			} else if (!err) {
> > -				split_huge_page_pmd(vma->vm_mm, old_pmd);
> >  			}
> > +			split_huge_page_pmd(vma->vm_mm, old_pmd);
> >  			VM_BUG_ON(pmd_trans_huge(*old_pmd));
> >  		}
> >  		if (pmd_none(*new_pmd) && __pte_alloc(new_vma->vm_mm, new_vma,
> 
> regression. If you really want to optimize this and cleanup you could
> make __pmd_trans_huge_stable return -1 if wait_split_huge_page path
> was taken, then you just change the other checks to == 1 and behave
> the same if it's 0 or -1, except in move_huge_pmd where you'll return
> -1 if __pmd_trans_huge_stable returned -1 to retain the above
> optimizaton.

All right.

> Maybe it's not much of an optimization anyway because we trade one
> branch for another, and both should be in l1 cache (though the retval
> is even guaranteed in a register not only in l1 cache so it's even
> better to check that for a branch), but to me is more about keeping
> the code strict which kinds of self-documents it, because conceptually
> calling split_huge_page_pmd if wait_split_huge_page was called is
> superflous (even if at runtime it won't make any difference).

OK, I cancel this change.

> Thanks for cleaning up this, especially where pmd_trans_huge_stable is
> perfect fit, this is a nice cleanup.

Thank you for your valuable feedbacks!

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
