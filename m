Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 528516B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 04:54:24 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c4so4798013eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 01:54:22 -0800 (PST)
Date: Tue, 13 Nov 2012 10:54:17 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 05/19] mm: numa: pte_numa() and pmd_numa()
Message-ID: <20121113095417.GB21522@gmail.com>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-6-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352193295-26815-6-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Implement pte_numa and pmd_numa.
> 
> We must atomically set the numa bit and clear the present bit to
> define a pte_numa or pmd_numa.
> 
> Once a pte or pmd has been set as pte_numa or pmd_numa, the next time
> a thread touches a virtual address in the corresponding virtual range,
> a NUMA hinting page fault will trigger. The NUMA hinting page fault
> will clear the NUMA bit and set the present bit again to resolve the
> page fault.
> 
> The expectation is that a NUMA hinting page fault is used as part
> of a placement policy that decides if a page should remain on the
> current node or migrated to a different node.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  arch/x86/include/asm/pgtable.h |   65 ++++++++++++++++++++++++++++++++++++++--
>  include/asm-generic/pgtable.h  |   12 ++++++++
>  2 files changed, 75 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index a1f780d..e075d57 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -404,7 +404,8 @@ static inline int pte_same(pte_t a, pte_t b)
>  
>  static inline int pte_present(pte_t a)
>  {
> -	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
> +	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE |
> +			       _PAGE_NUMA);
>  }
>  
>  static inline int pte_hidden(pte_t pte)
> @@ -420,7 +421,63 @@ static inline int pmd_present(pmd_t pmd)
>  	 * the _PAGE_PSE flag will remain set at all times while the
>  	 * _PAGE_PRESENT bit is clear).
>  	 */
> -	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE);
> +	return pmd_flags(pmd) & (_PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE |
> +				 _PAGE_NUMA);
> +}
> +
> +#ifdef CONFIG_BALANCE_NUMA
> +/*
> + * _PAGE_NUMA works identical to _PAGE_PROTNONE (it's actually the
> + * same bit too). It's set only when _PAGE_PRESET is not set and it's
> + * never set if _PAGE_PRESENT is set.
> + *
> + * pte/pmd_present() returns true if pte/pmd_numa returns true. Page
> + * fault triggers on those regions if pte/pmd_numa returns true
> + * (because _PAGE_PRESENT is not set).
> + */
> +static inline int pte_numa(pte_t pte)
> +{
> +	return (pte_flags(pte) &
> +		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
> +}
> +
> +static inline int pmd_numa(pmd_t pmd)
> +{
> +	return (pmd_flags(pmd) &
> +		(_PAGE_NUMA|_PAGE_PRESENT)) == _PAGE_NUMA;
> +}
> +#endif
> +
> +/*
> + * pte/pmd_mknuma sets the _PAGE_ACCESSED bitflag automatically
> + * because they're called by the NUMA hinting minor page fault. If we
> + * wouldn't set the _PAGE_ACCESSED bitflag here, the TLB miss handler
> + * would be forced to set it later while filling the TLB after we
> + * return to userland. That would trigger a second write to memory
> + * that we optimize away by setting _PAGE_ACCESSED here.
> + */
> +static inline pte_t pte_mknonnuma(pte_t pte)
> +{
> +	pte = pte_clear_flags(pte, _PAGE_NUMA);
> +	return pte_set_flags(pte, _PAGE_PRESENT|_PAGE_ACCESSED);
> +}
> +
> +static inline pmd_t pmd_mknonnuma(pmd_t pmd)
> +{
> +	pmd = pmd_clear_flags(pmd, _PAGE_NUMA);
> +	return pmd_set_flags(pmd, _PAGE_PRESENT|_PAGE_ACCESSED);
> +}
> +
> +static inline pte_t pte_mknuma(pte_t pte)
> +{
> +	pte = pte_set_flags(pte, _PAGE_NUMA);
> +	return pte_clear_flags(pte, _PAGE_PRESENT);
> +}
> +
> +static inline pmd_t pmd_mknuma(pmd_t pmd)
> +{
> +	pmd = pmd_set_flags(pmd, _PAGE_NUMA);
> +	return pmd_clear_flags(pmd, _PAGE_PRESENT);
>  }
>  
>  static inline int pmd_none(pmd_t pmd)
> @@ -479,6 +536,10 @@ static inline pte_t *pte_offset_kernel(pmd_t *pmd, unsigned long address)
>  
>  static inline int pmd_bad(pmd_t pmd)
>  {
> +#ifdef CONFIG_BALANCE_NUMA
> +	if (pmd_numa(pmd))
> +		return 0;
> +#endif
>  	return (pmd_flags(pmd) & ~_PAGE_USER) != _KERNPG_TABLE;
>  }
>  
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index b36ce40..896667e 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -554,6 +554,18 @@ static inline int pmd_trans_unstable(pmd_t *pmd)
>  #endif
>  }
>  
> +#ifndef CONFIG_BALANCE_NUMA
> +static inline int pte_numa(pte_t pte)
> +{
> +	return 0;
> +}
> +
> +static inline int pmd_numa(pmd_t pmd)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_BALANCE_NUMA */
> +

Hm, this overcomplicates things quite a bit and adds arch 
specific code, and there's no explanation given for that 
approach that I can see?

Basically, what's wrong with the generic approach that numa/core 
has:

 __weak bool pte_numa(struct vm_area_struct *vma, pte_t pte)

[see the full function below.]

Then we can reuse existing protection-changing functionality and 
keep it all tidy.

an architecture that wants to do something special could 
possibly override it in the future - but we want to keep the 
generic logic in generic code.

Thanks,

	Ingo

------------>
__weak bool pte_numa(struct vm_area_struct *vma, pte_t pte)
{
	/*
	 * For NUMA page faults, we use PROT_NONE ptes in VMAs with
	 * "normal" vma->vm_page_prot protections.  Genuine PROT_NONE
	 * VMAs should never get here, because the fault handling code
	 * will notice that the VMA has no read or write permissions.
	 *
	 * This means we cannot get 'special' PROT_NONE faults from genuine
	 * PROT_NONE maps, nor from PROT_WRITE file maps that do dirty
	 * tracking.
	 *
	 * Neither case is really interesting for our current use though so we
	 * don't care.
	 */
	if (pte_same(pte, pte_modify(pte, vma->vm_page_prot)))
		return false;

	return pte_same(pte, pte_modify(pte, vma_prot_none(vma)));
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
