Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 2588E6B0070
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 11:32:03 -0500 (EST)
Message-ID: <50ABB06A.9000402@redhat.com>
Date: Tue, 20 Nov 2012 11:31:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH, v2] mm, numa: Turn 4K pte NUMA faults into effective
 hugepage ones
References: <1353291284-2998-1-git-send-email-mingo@kernel.org> <20121119162909.GL8218@suse.de> <20121119191339.GA11701@gmail.com> <20121119211804.GM8218@suse.de> <20121119223604.GA13470@gmail.com> <CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com> <20121120071704.GA14199@gmail.com> <20121120152933.GA17996@gmail.com> <20121120160918.GA18167@gmail.com>
In-Reply-To: <20121120160918.GA18167@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On 11/20/2012 11:09 AM, Ingo Molnar wrote:

> Subject: mm, numa: Turn 4K pte NUMA faults into effective hugepage ones
> From: Ingo Molnar <mingo@kernel.org>
> Date: Tue Nov 20 15:48:26 CET 2012
>
> Reduce the 4K page fault count by looking around and processing
> nearby pages if possible.

This is essentially what autonuma does with PMD level NUMA
faults, so we know this idea works.

Performance measurements will show us how much of an impact
it makes, since I don't think we have never done apples to apples
comparisons with just this thing toggled :)

The patch looks good for me, just a nit-pick on the comment
to do_numa_page().

Other than that:

Acked-by: Rik van Riel <riel@redhat.com>

> Index: linux/mm/memory.c
> ===================================================================
> --- linux.orig/mm/memory.c
> +++ linux/mm/memory.c
> @@ -3455,64 +3455,93 @@ static int do_nonlinear_fault(struct mm_
>   	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
>   }
>
> -static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +static int __do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>   			unsigned long address, pte_t *ptep, pmd_t *pmd,
> -			unsigned int flags, pte_t entry)
> +			unsigned int flags, pte_t entry, spinlock_t *ptl)
>   {
> -	struct page *page = NULL;
> -	int node, page_nid = -1;
> -	int last_cpu = -1;
> -	spinlock_t *ptl;
> -
> -	ptl = pte_lockptr(mm, pmd);
> -	spin_lock(ptl);
> -	if (unlikely(!pte_same(*ptep, entry)))
> -		goto out_unlock;
> +	struct page *page;
> +	int new_node;
>
>   	page = vm_normal_page(vma, address, entry);
>   	if (page) {
> -		get_page(page);
> -		page_nid = page_to_nid(page);
> -		last_cpu = page_last_cpu(page);
> -		node = mpol_misplaced(page, vma, address);
> -		if (node != -1 && node != page_nid)
> +		int page_nid = page_to_nid(page);
> +		int last_cpu = page_last_cpu(page);
> +
> +		task_numa_fault(page_nid, last_cpu, 1);
> +
> +		new_node = mpol_misplaced(page, vma, address);
> +		if (new_node != -1 && new_node != page_nid)
>   			goto migrate;
>   	}
>
> -out_pte_upgrade_unlock:
> +out_pte_upgrade:
>   	flush_cache_page(vma, address, pte_pfn(entry));
> -
>   	ptep_modify_prot_start(mm, address, ptep);
>   	entry = pte_modify(entry, vma->vm_page_prot);
> +	if (pte_dirty(entry))
> +		entry = pte_mkwrite(entry);
>   	ptep_modify_prot_commit(mm, address, ptep, entry);
> -
>   	/* No TLB flush needed because we upgraded the PTE */
> -
>   	update_mmu_cache(vma, address, ptep);
> -
> -out_unlock:
> -	pte_unmap_unlock(ptep, ptl);
> -
> -	if (page) {
> -		task_numa_fault(page_nid, last_cpu, 1);
> -		put_page(page);
> -	}
>   out:
>   	return 0;
>
>   migrate:
> +	get_page(page);
>   	pte_unmap_unlock(ptep, ptl);
>
> -	if (migrate_misplaced_page(page, node)) {
> +	migrate_misplaced_page(page, new_node); /* Drops the page reference */
> +
> +	/* Re-check after migration: */
> +
> +	ptl = pte_lockptr(mm, pmd);
> +	spin_lock(ptl);
> +	entry = ACCESS_ONCE(*ptep);
> +
> +	if (!pte_numa(vma, entry))
>   		goto out;
> -	}
> -	page = NULL;
>
> -	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
> -	if (!pte_same(*ptep, entry))
> -		goto out_unlock;
> +	goto out_pte_upgrade;
> +}
> +
> +/*
> + * Add a simple loop to also fetch ptes within the same pmd:
> + */

That's not a very useful comment. How about something like:

   /*
    * Also fault over nearby ptes from within the same pmd and vma,
    * in order to minimize the overhead from page fault exceptions
    * and TLB flushes.
    */

> +static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +			unsigned long addr0, pte_t *ptep0, pmd_t *pmd,
> +			unsigned int flags, pte_t entry0)
> +{
> +	unsigned long addr0_pmd;
> +	unsigned long addr_start;
> +	unsigned long addr;
> +	spinlock_t *ptl;
> +	pte_t *ptep;
> +
> +	addr0_pmd = addr0 & PMD_MASK;
> +	addr_start = max(addr0_pmd, vma->vm_start);
>
> -	goto out_pte_upgrade_unlock;
> +	ptep = pte_offset_map(pmd, addr_start);
> +	ptl = pte_lockptr(mm, pmd);
> +	spin_lock(ptl);
> +
> +	for (addr = addr_start; addr < vma->vm_end; addr += PAGE_SIZE, ptep++) {
> + 		pte_t entry;
> +
> +		entry = ACCESS_ONCE(*ptep);
> +
> +		if ((addr & PMD_MASK) != addr0_pmd)
> +			break;
> +		if (!pte_present(entry))
> +			continue;
> +		if (!pte_numa(vma, entry))
> +			continue;
> +
> +		__do_numa_page(mm, vma, addr, ptep, pmd, flags, entry, ptl);
> +	}
> +
> +	pte_unmap_unlock(ptep, ptl);
> +	
> +	return 0;
>   }
>
>   /*
>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
