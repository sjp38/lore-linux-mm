Date: Fri, 1 Feb 2008 16:09:52 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 2/4] mmu_notifier: Callbacks to invalidate address
	ranges
Message-ID: <20080201220952.GA3875@sgi.com>
References: <20080201050439.009441434@sgi.com> <20080201050623.344041545@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080201050623.344041545@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

Christoph,

The following code in do_wp_page is a problem.

We are getting this callout when we transition the pte from a read-only
to read-write.  Jack and I can not see a reason we would need that
callout.  It is causing problems for xpmem in that a write fault goes
to get_user_pages which gets back to do_wp_page that does the callout.

XPMEM only allows either faulting or invalidating to occur for an mm.
As you can see, the case above needs it to be in both states.

Thanks,
Robin


> @@ -1630,6 +1646,8 @@ gotten:
>  		goto oom;
>  	cow_user_page(new_page, old_page, address, vma);
>  
> +	mmu_notifier(invalidate_range_begin, mm, address,
> +				address + PAGE_SIZE, 0);
>  	/*
>  	 * Re-check the pte - we dropped the lock
>  	 */
> @@ -1668,6 +1686,8 @@ gotten:
>  		page_cache_release(old_page);
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
> +	mmu_notifier(invalidate_range_end, mm,
> +				address, address + PAGE_SIZE, 0);
>  	if (dirty_page) {
>  		if (vma->vm_file)
>  			file_update_time(vma->vm_file);
> Index: linux-2.6/mm/mmap.c
> ===================================================================
> --- linux-2.6.orig/mm/mmap.c	2008-01-31 20:58:05.000000000 -0800
> +++ linux-2.6/mm/mmap.c	2008-01-31 20:59:14.000000000 -0800
> @@ -1744,11 +1744,13 @@ static void unmap_region(struct mm_struc
>  	lru_add_drain();
>  	tlb = tlb_gather_mmu(mm, 0);
>  	update_hiwater_rss(mm);
> +	mmu_notifier(invalidate_range_begin, mm, start, end, 0);
>  	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
>  	vm_unacct_memory(nr_accounted);
>  	free_pgtables(&tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
>  				 next? next->vm_start: 0);
>  	tlb_finish_mmu(tlb, start, end);
> +	mmu_notifier(invalidate_range_end, mm, start, end, 0);
>  }
>  
>  /*
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c	2008-01-31 20:56:03.000000000 -0800
> +++ linux-2.6/mm/hugetlb.c	2008-01-31 20:59:14.000000000 -0800
> @@ -14,6 +14,7 @@
>  #include <linux/mempolicy.h>
>  #include <linux/cpuset.h>
>  #include <linux/mutex.h>
> +#include <linux/mmu_notifier.h>
>  
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
> @@ -743,6 +744,7 @@ void __unmap_hugepage_range(struct vm_ar
>  	BUG_ON(start & ~HPAGE_MASK);
>  	BUG_ON(end & ~HPAGE_MASK);
>  
> +	mmu_notifier(invalidate_range_begin, mm, start, end, 1);
>  	spin_lock(&mm->page_table_lock);
>  	for (address = start; address < end; address += HPAGE_SIZE) {
>  		ptep = huge_pte_offset(mm, address);
> @@ -763,6 +765,7 @@ void __unmap_hugepage_range(struct vm_ar
>  	}
>  	spin_unlock(&mm->page_table_lock);
>  	flush_tlb_range(vma, start, end);
> +	mmu_notifier(invalidate_range_end, mm, start, end, 1);
>  	list_for_each_entry_safe(page, tmp, &page_list, lru) {
>  		list_del(&page->lru);
>  		put_page(page);
> Index: linux-2.6/mm/filemap_xip.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap_xip.c	2008-01-31 20:56:03.000000000 -0800
> +++ linux-2.6/mm/filemap_xip.c	2008-01-31 20:59:14.000000000 -0800
> @@ -13,6 +13,7 @@
>  #include <linux/module.h>
>  #include <linux/uio.h>
>  #include <linux/rmap.h>
> +#include <linux/mmu_notifier.h>
>  #include <linux/sched.h>
>  #include <asm/tlbflush.h>
>  
> @@ -189,6 +190,8 @@ __xip_unmap (struct address_space * mapp
>  		address = vma->vm_start +
>  			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
>  		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> +		mmu_notifier(invalidate_range_begin, mm, address,
> +					address + PAGE_SIZE, 1);
>  		pte = page_check_address(page, mm, address, &ptl);
>  		if (pte) {
>  			/* Nuke the page table entry. */
> @@ -200,6 +203,8 @@ __xip_unmap (struct address_space * mapp
>  			pte_unmap_unlock(pte, ptl);
>  			page_cache_release(page);
>  		}
> +		mmu_notifier(invalidate_range_end, mm,
> +				address, address + PAGE_SIZE, 1);
>  	}
>  	spin_unlock(&mapping->i_mmap_lock);
>  }
> Index: linux-2.6/mm/mremap.c
> ===================================================================
> --- linux-2.6.orig/mm/mremap.c	2008-01-31 20:56:03.000000000 -0800
> +++ linux-2.6/mm/mremap.c	2008-01-31 20:59:14.000000000 -0800
> @@ -18,6 +18,7 @@
>  #include <linux/highmem.h>
>  #include <linux/security.h>
>  #include <linux/syscalls.h>
> +#include <linux/mmu_notifier.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/cacheflush.h>
> @@ -124,12 +125,15 @@ unsigned long move_page_tables(struct vm
>  		unsigned long old_addr, struct vm_area_struct *new_vma,
>  		unsigned long new_addr, unsigned long len)
>  {
> -	unsigned long extent, next, old_end;
> +	unsigned long extent, next, old_start, old_end;
>  	pmd_t *old_pmd, *new_pmd;
>  
> +	old_start = old_addr;
>  	old_end = old_addr + len;
>  	flush_cache_range(vma, old_addr, old_end);
>  
> +	mmu_notifier(invalidate_range_begin, vma->vm_mm,
> +					old_addr, old_end, 0);
>  	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
>  		cond_resched();
>  		next = (old_addr + PMD_SIZE) & PMD_MASK;
> @@ -150,6 +154,7 @@ unsigned long move_page_tables(struct vm
>  		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
>  				new_vma, new_pmd, new_addr);
>  	}
> +	mmu_notifier(invalidate_range_end, vma->vm_mm, old_start, old_end, 0);
>  
>  	return len + old_addr - old_end;	/* how much done */
>  }
> 
> -- 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
