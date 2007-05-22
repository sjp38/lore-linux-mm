Date: Tue, 22 May 2007 22:52:13 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: [PATCH/RFC] Rework ptep_set_access_flags and fix sun4c
In-Reply-To: <1179815339.32247.799.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.61.0705222247010.5890@mtfhpc.demon.co.uk>
References: <Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
 <20070509231937.ea254c26.akpm@linux-foundation.org>
 <1178778583.14928.210.camel@localhost.localdomain>
 <20070510.001234.126579706.davem@davemloft.net>
 <Pine.LNX.4.64.0705142018090.18453@blonde.wat.veritas.com>
 <1179176845.32247.107.camel@localhost.localdomain>
 <1179212184.32247.163.camel@localhost.localdomain>
 <1179757647.6254.235.camel@localhost.localdomain>
 <1179815339.32247.799.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "Tom \"spot\" Callaway" <tcallawa@redhat.com>, Hugh Dickins <hugh@veritas.com>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Benjamin,

I have just tested this patch on my Sun4c Sparcstation 1 using my 2.6.20.9 
test kernel without any problems.

Thank you for the work.

Regards
 	Mark Fortescue.

On Tue, 22 May 2007, Benjamin Herrenschmidt wrote:

> This patch reworks ptep_set_access_flags() and the callers so that the
> comparison to the old PTE is done inside that function, which then
> returns wether an update_mmu_cache() is needed. That allows fixing
> the sun4c situation where update_mmu_cache() needs to be forced,
> always.
>
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>
> Ok, so that's only compile tested on sparc32 and powerpc 32 bits, boot
> tested on powerpc64 and not tested on others (I could use some help
> testing x86, x86_64 and s390 who also have their own implementations).
>
> Index: linux-work/include/asm-generic/pgtable.h
> ===================================================================
> --- linux-work.orig/include/asm-generic/pgtable.h	2007-05-22 15:04:45.000000000 +1000
> +++ linux-work/include/asm-generic/pgtable.h	2007-05-22 15:32:21.000000000 +1000
> @@ -27,13 +27,20 @@ do {				  					\
>  * Largely same as above, but only sets the access flags (dirty,
>  * accessed, and writable). Furthermore, we know it always gets set
>  * to a "more permissive" setting, which allows most architectures
> - * to optimize this.
> + * to optimize this. We return wether the PTE actually changed, which
> + * in turn instructs the caller to do things like update__mmu_cache.
> + * This used to be done in the caller, but sparc needs minor faults to
> + * force that call on sun4c so we changed this macro slightly
>  */
> #define ptep_set_access_flags(__vma, __address, __ptep, __entry, __dirty) \
> -do {				  					  \
> -	set_pte_at((__vma)->vm_mm, (__address), __ptep, __entry);	  \
> -	flush_tlb_page(__vma, __address);				  \
> -} while (0)
> +({									  \
> +	int __changed = !pte_same(*(__ptep), __entry);			  \
> +	if (__changed) {						  \
> +		set_pte_at((__vma)->vm_mm, (__address), __ptep, __entry); \
> +		flush_tlb_page(__vma, __address);			  \
> +	}								  \
> +	__changed;							  \
> +})
> #endif
>
> #ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
> Index: linux-work/include/asm-powerpc/pgtable-ppc64.h
> ===================================================================
> --- linux-work.orig/include/asm-powerpc/pgtable-ppc64.h	2007-05-22 15:04:45.000000000 +1000
> +++ linux-work/include/asm-powerpc/pgtable-ppc64.h	2007-05-22 15:27:21.000000000 +1000
> @@ -413,10 +413,14 @@ static inline void __ptep_set_access_fla
> 	:"cc");
> }
> #define  ptep_set_access_flags(__vma, __address, __ptep, __entry, __dirty) \
> -	do {								   \
> -		__ptep_set_access_flags(__ptep, __entry, __dirty);	   \
> -		flush_tlb_page_nohash(__vma, __address);	       	   \
> -	} while(0)
> +({									   \
> +	int __changed = !pte_same(*(__ptep), __entry);			   \
> +	if (__changed) {						   \
> +		__ptep_set_access_flags(__ptep, __entry, __dirty);    	   \
> +		flush_tlb_page_nohash(__vma, __address);		   \
> +	}								   \
> +	__changed;							   \
> +})
>
> /*
>  * Macro to mark a page protection value as "uncacheable".
> Index: linux-work/mm/memory.c
> ===================================================================
> --- linux-work.orig/mm/memory.c	2007-05-22 15:04:45.000000000 +1000
> +++ linux-work/mm/memory.c	2007-05-22 15:38:19.000000000 +1000
> @@ -1691,9 +1691,10 @@ static int do_wp_page(struct mm_struct *
> 		flush_cache_page(vma, address, pte_pfn(orig_pte));
> 		entry = pte_mkyoung(orig_pte);
> 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> -		ptep_set_access_flags(vma, address, page_table, entry, 1);
> -		update_mmu_cache(vma, address, entry);
> -		lazy_mmu_prot_update(entry);
> +		if (ptep_set_access_flags(vma, address, page_table, entry,1)) {
> +			update_mmu_cache(vma, address, entry);
> +			lazy_mmu_prot_update(entry);
> +		}
> 		ret |= VM_FAULT_WRITE;
> 		goto unlock;
> 	}
> @@ -2525,10 +2526,9 @@ static inline int handle_pte_fault(struc
> 		pte_t *pte, pmd_t *pmd, int write_access)
> {
> 	pte_t entry;
> -	pte_t old_entry;
> 	spinlock_t *ptl;
>
> -	old_entry = entry = *pte;
> +	entry = *pte;
> 	if (!pte_present(entry)) {
> 		if (pte_none(entry)) {
> 			if (vma->vm_ops) {
> @@ -2561,8 +2561,7 @@ static inline int handle_pte_fault(struc
> 		entry = pte_mkdirty(entry);
> 	}
> 	entry = pte_mkyoung(entry);
> -	if (!pte_same(old_entry, entry)) {
> -		ptep_set_access_flags(vma, address, pte, entry, write_access);
> +	if (ptep_set_access_flags(vma, address, pte, entry, write_access)) {
> 		update_mmu_cache(vma, address, entry);
> 		lazy_mmu_prot_update(entry);
> 	} else {
> Index: linux-work/include/asm-powerpc/pgtable-ppc32.h
> ===================================================================
> --- linux-work.orig/include/asm-powerpc/pgtable-ppc32.h	2007-05-22 15:04:45.000000000 +1000
> +++ linux-work/include/asm-powerpc/pgtable-ppc32.h	2007-05-22 15:26:07.000000000 +1000
> @@ -673,10 +673,14 @@ static inline void __ptep_set_access_fla
> }
>
> #define  ptep_set_access_flags(__vma, __address, __ptep, __entry, __dirty) \
> -	do {								   \
> -		__ptep_set_access_flags(__ptep, __entry, __dirty);	   \
> -		flush_tlb_page_nohash(__vma, __address);	       	   \
> -	} while(0)
> +({									   \
> +	int __changed = !pte_same(*(__ptep), __entry);			   \
> +	if (__changed) {						   \
> +		__ptep_set_access_flags(__ptep, __entry, __dirty);    	   \
> +		flush_tlb_page_nohash(__vma, __address);		   \
> +	}								   \
> +	__changed;							   \
> +})
>
> /*
>  * Macro to mark a page protection value as "uncacheable".
> Index: linux-work/include/asm-i386/pgtable.h
> ===================================================================
> --- linux-work.orig/include/asm-i386/pgtable.h	2007-05-22 15:06:17.000000000 +1000
> +++ linux-work/include/asm-i386/pgtable.h	2007-05-22 15:16:11.000000000 +1000
> @@ -285,13 +285,15 @@ static inline pte_t native_local_ptep_ge
>  */
> #define  __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
> #define ptep_set_access_flags(vma, address, ptep, entry, dirty)		\
> -do {									\
> -	if (dirty) {							\
> +({									\
> +	int __changed = !pte_same(*(__ptep), __entry);			\
> +	if (__changed && dirty) {					\
> 		(ptep)->pte_low = (entry).pte_low;			\
> 		pte_update_defer((vma)->vm_mm, (address), (ptep));	\
> 		flush_tlb_page(vma, address);				\
> 	}								\
> -} while (0)
> +	__changed;							\
> +})
>
> #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
> #define ptep_test_and_clear_dirty(vma, addr, ptep) ({			\
> Index: linux-work/include/asm-ppc/pgtable.h
> ===================================================================
> --- linux-work.orig/include/asm-ppc/pgtable.h	2007-05-22 15:25:58.000000000 +1000
> +++ linux-work/include/asm-ppc/pgtable.h	2007-05-22 15:26:08.000000000 +1000
> @@ -694,10 +694,14 @@ static inline void __ptep_set_access_fla
> }
>
> #define  ptep_set_access_flags(__vma, __address, __ptep, __entry, __dirty) \
> -	do {								   \
> -		__ptep_set_access_flags(__ptep, __entry, __dirty);	   \
> -		flush_tlb_page_nohash(__vma, __address);	       	   \
> -	} while(0)
> +({									   \
> +	int __changed = !pte_same(*(__ptep), __entry);			   \
> +	if (__changed) {						   \
> +		__ptep_set_access_flags(__ptep, __entry, __dirty);    	   \
> +		flush_tlb_page_nohash(__vma, __address);		   \
> +	}								   \
> +	__changed;							   \
> +})
>
> /*
>  * Macro to mark a page protection value as "uncacheable".
> Index: linux-work/include/asm-s390/pgtable.h
> ===================================================================
> --- linux-work.orig/include/asm-s390/pgtable.h	2007-05-22 15:16:48.000000000 +1000
> +++ linux-work/include/asm-s390/pgtable.h	2007-05-22 15:20:16.000000000 +1000
> @@ -744,7 +744,12 @@ ptep_establish(struct vm_area_struct *vm
> }
>
> #define ptep_set_access_flags(__vma, __address, __ptep, __entry, __dirty) \
> -	ptep_establish(__vma, __address, __ptep, __entry)
> +({									  \
> +	int __changed = !pte_same(*(__ptep), __entry);			  \
> +	if (__changed)							  \
> +		ptep_establish(__vma, __address, __ptep, __entry);	  \
> +	__changed;							  \
> +})
>
> /*
>  * Test and clear dirty bit in storage key.
> Index: linux-work/include/asm-sparc/pgtable.h
> ===================================================================
> --- linux-work.orig/include/asm-sparc/pgtable.h	2007-05-22 15:30:48.000000000 +1000
> +++ linux-work/include/asm-sparc/pgtable.h	2007-05-22 15:35:56.000000000 +1000
> @@ -446,6 +446,17 @@ extern int io_remap_pfn_range(struct vm_
> #define GET_IOSPACE(pfn)		(pfn >> (BITS_PER_LONG - 4))
> #define GET_PFN(pfn)			(pfn & 0x0fffffffUL)
>
> +#define __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
> +#define ptep_set_access_flags(__vma, __address, __ptep, __entry, __dirty) \
> +({									  \
> +	int __changed = !pte_same(*(__ptep), __entry);			  \
> +	if (__changed) {						  \
> +		set_pte_at((__vma)->vm_mm, (__address), __ptep, __entry); \
> +		flush_tlb_page(__vma, __address);			  \
> +	}								  \
> +	(sparc_cpu_model == sun4c) || __changed;			  \
> +})
> +
> #include <asm-generic/pgtable.h>
>
> #endif /* !(__ASSEMBLY__) */
> Index: linux-work/include/asm-x86_64/pgtable.h
> ===================================================================
> --- linux-work.orig/include/asm-x86_64/pgtable.h	2007-05-22 15:20:40.000000000 +1000
> +++ linux-work/include/asm-x86_64/pgtable.h	2007-05-22 15:21:52.000000000 +1000
> @@ -395,12 +395,14 @@ static inline pte_t pte_modify(pte_t pte
>  * bit at the same time. */
> #define  __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
> #define ptep_set_access_flags(__vma, __address, __ptep, __entry, __dirty) \
> -	do {								  \
> -		if (__dirty) {						  \
> -			set_pte(__ptep, __entry);			  \
> -			flush_tlb_page(__vma, __address);		  \
> -		}							  \
> -	} while (0)
> +({									  \
> +	int __changed = !pte_same(*(__ptep), __entry);			  \
> +	if (__changed && __dirty) {					  \
> +		set_pte(__ptep, __entry);			  	  \
> +		flush_tlb_page(__vma, __address);		  	  \
> +	}								  \
> +	__changed;							  \
> +})
>
> /* Encode and de-code a swap entry */
> #define __swp_type(x)			(((x).val >> 1) & 0x3f)
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
