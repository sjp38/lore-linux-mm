Date: Thu, 31 Jan 2008 12:18:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifiers #v5
In-Reply-To: <20080131171806.GN7185@v2.random>
Message-ID: <Pine.LNX.4.64.0801311207540.25477@schroedinger.engr.sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131171806.GN7185@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2008, Andrea Arcangeli wrote:

> My suggestion is to add the invalidate_range_start/end incrementally
> with this, and to keep all the xpmem mmu notifiers in a separate
> incremental patch (those are going to require many more changes to
> perfect). They've very different things. GRU is simpler, will require
> less changes and it should be taken care of sooner than XPMEM. KVM
> requirements are a subset of GRU thanks to the page pin so I can
> ignore KVM requirements as a whole and I only focus on GRU for the
> time being.

KVM requires get_user_pages. This makes them currently different.

> Invalidates inside PT lock will avoid the page faults to happen in
> parallel of my invalidates, no dependency on the page pin, mremap

You are aware that the pt lock is split for systems with >4 CPUS? You can 
use the pte_lock only to serialize access to individual ptes.

> pagefault against the main linux page fault, given we already have all
> needed serialization out of the PT lock. XPMEM is forced to do that

pt lock cannot serialize with invalidate_range since it is split. A range 
requires locking for a series of ptes not only individual ones.

> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -46,6 +46,7 @@
>  	__young = ptep_test_and_clear_young(__vma, __address, __ptep);	\
>  	if (__young)							\
>  		flush_tlb_page(__vma, __address);			\
> +	__young |= mmu_notifier_age_page((__vma)->vm_mm, __address);	\
>  	__young;							\
>  })
>  #endif

That may be okay. Have you checked all the arches that can provide their 
own implementation of this macro? This is only going to work on arches 
that use the generic implementation.

 > @@ -86,6 +87,7 @@ do {									\
>  	pte_t __pte;							\
>  	__pte = ptep_get_and_clear((__vma)->vm_mm, __address, __ptep);	\
>  	flush_tlb_page(__vma, __address);				\
> +	mmu_notifier(invalidate_page, (__vma)->vm_mm, __address);	\
>  	__pte;								\
>  })
>  #endif

This will require a callback on every(!) removal of a pte. A range 
invalidate does not do any good since the callbacks are performed anyways. 
Probably needlessly.

In addition you have the same issues with arches providing their own macro 
here.

> diff --git a/include/asm-s390/pgtable.h b/include/asm-s390/pgtable.h
> --- a/include/asm-s390/pgtable.h
> +++ b/include/asm-s390/pgtable.h
> @@ -712,6 +712,7 @@ static inline pte_t ptep_clear_flush(str
>  {
>  	pte_t pte = *ptep;
>  	ptep_invalidate(address, ptep);
> +	mmu_notifier(invalidate_page, vma->vm_mm, address);
>  	return pte;
>  }
>  

Ahh you found an additional arch. How about x86 code? There is one 
override of these functions there as well.

> +	/*
> +	 * invalidate_page[s] is called in atomic context
> +	 * after any pte has been updated and before
> +	 * dropping the PT lock required to update any Linux pte.
> +	 * Once the PT lock will be released the pte will have its
> +	 * final value to export through the secondary MMU.
> +	 * Before this is invoked any secondary MMU is still ok
> +	 * to read/write to the page previously pointed by the
> +	 * Linux pte because the old page hasn't been freed yet.
> +	 * If required set_page_dirty has to be called internally
> +	 * to this method.
> +	 */
> +	void (*invalidate_page)(struct mmu_notifier *mn,
> +				struct mm_struct *mm,
> +				unsigned long address);


> +	void (*invalidate_pages)(struct mmu_notifier *mn,
> +				 struct mm_struct *mm,
> +				 unsigned long start, unsigned long end);

What is the point of invalidate_pages? It cannot be serialized properly 
and you do the invalidate_page() calles regardless. Is is some sort of 
optimization?

> +struct mmu_notifier_head {};
> +
> +#define mmu_notifier_register(mn, mm) do {} while(0)
> +#define mmu_notifier_unregister(mn, mm) do {} while (0)
> +#define mmu_notifier_release(mm) do {} while (0)
> +#define mmu_notifier_age_page(mm, address) ({ 0; })
> +#define mmu_notifier_head_init(mmh) do {} while (0)

Macros. We want functions there to be able to validate the parameters even 
if !CONFIG_MMU_NOTIFIER.

> +
> +/*
> + * Notifiers that use the parameters that they were passed so that the
> + * compiler does not complain about unused variables but does proper
> + * parameter checks even if !CONFIG_MMU_NOTIFIER.
> + * Macros generate no code.
> + */
> +#define mmu_notifier(function, mm, args...)			       \
> +	do {							       \
> +		if (0) {					       \
> +			struct mmu_notifier *__mn;		       \
> +								       \
> +			__mn = (struct mmu_notifier *)(0x00ff);	       \
> +			__mn->ops->function(__mn, mm, args);	       \
> +		};						       \
> +	} while (0)
> +
> +#endif /* CONFIG_MMU_NOTIFIER */

Ok here you took the variant that checks parameters.

> @@ -1249,6 +1250,7 @@ static int remap_pte_range(struct mm_str
>  {
>  	pte_t *pte;
>  	spinlock_t *ptl;
> +	unsigned long start = addr;
>  
>  	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
>  	if (!pte)
> @@ -1260,6 +1262,7 @@ static int remap_pte_range(struct mm_str
>  		pfn++;
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	arch_leave_lazy_mmu_mode();
> +	mmu_notifier(invalidate_pages, mm, start, addr);
>  	pte_unmap_unlock(pte - 1, ptl);
>  	return 0;

You are under the wrong impression that you can use the pte lock to 
serialize general access to ptes! Nope. ptelock only serialize access to 
individual ptes. This is broken.

> +	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
> +		hlist_for_each_entry_safe(mn, n, tmp,
> +					  &mm->mmu_notifier.head, hlist) {
> +			hlist_del(&mn->hlist);

hlist_del_init?

> @@ -71,6 +72,7 @@ static void change_pte_range(struct mm_s
>  
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	arch_leave_lazy_mmu_mode();
> +	mmu_notifier(invalidate_pages, mm, start, addr);
>  	pte_unmap_unlock(pte - 1, ptl);
>  }

Again broken serialization.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
