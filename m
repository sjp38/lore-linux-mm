Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8A2FB6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 10:12:49 -0500 (EST)
Date: Thu, 18 Nov 2010 15:12:21 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 30 of 66] transparent hugepage core
Message-ID: <20101118151221.GT8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <a7507af3a1dcae5c52a4.1288798085@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <a7507af3a1dcae5c52a4.1288798085@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 03, 2010 at 04:28:05PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Lately I've been working to make KVM use hugepages transparently
> without the usual restrictions of hugetlbfs. Some of the restrictions
> I'd like to see removed:
> 
> 1) hugepages have to be swappable or the guest physical memory remains
>    locked in RAM and can't be paged out to swap
> 
> 2) if a hugepage allocation fails, regular pages should be allocated
>    instead and mixed in the same vma without any failure and without
>    userland noticing
> 
> 3) if some task quits and more hugepages become available in the
>    buddy, guest physical memory backed by regular pages should be
>    relocated on hugepages automatically in regions under
>    madvise(MADV_HUGEPAGE) (ideally event driven by waking up the
>    kernel deamon if the order=HPAGE_PMD_SHIFT-PAGE_SHIFT list becomes
>    not null)
> 
> 4) avoidance of reservation and maximization of use of hugepages whenever
>    possible. Reservation (needed to avoid runtime fatal faliures) may be ok for
>    1 machine with 1 database with 1 database cache with 1 database cache size
>    known at boot time. It's definitely not feasible with a virtualization
>    hypervisor usage like RHEV-H that runs an unknown number of virtual machines
>    with an unknown size of each virtual machine with an unknown amount of
>    pagecache that could be potentially useful in the host for guest not using
>    O_DIRECT (aka cache=off).
> 
> hugepages in the virtualization hypervisor (and also in the guest!) are
> much more important than in a regular host not using virtualization, becasue
> with NPT/EPT they decrease the tlb-miss cacheline accesses from 24 to 19 in
> case only the hypervisor uses transparent hugepages, and they decrease the
> tlb-miss cacheline accesses from 19 to 15 in case both the linux hypervisor and
> the linux guest both uses this patch (though the guest will limit the addition
> speedup to anonymous regions only for now...).  Even more important is that the
> tlb miss handler is much slower on a NPT/EPT guest than for a regular shadow
> paging or no-virtualization scenario. So maximizing the amount of virtual
> memory cached by the TLB pays off significantly more with NPT/EPT than without
> (even if there would be no significant speedup in the tlb-miss runtime).
> 
> The first (and more tedious) part of this work requires allowing the VM to
> handle anonymous hugepages mixed with regular pages transparently on regular
> anonymous vmas. This is what this patch tries to achieve in the least intrusive
> possible way. We want hugepages and hugetlb to be used in a way so that all
> applications can benefit without changes (as usual we leverage the KVM
> virtualization design: by improving the Linux VM at large, KVM gets the
> performance boost too).
> 
> The most important design choice is: always fallback to 4k allocation
> if the hugepage allocation fails! This is the _very_ opposite of some
> large pagecache patches that failed with -EIO back then if a 64k (or
> similar) allocation failed...
> 
> Second important decision (to reduce the impact of the feature on the
> existing pagetable handling code) is that at any time we can split an
> hugepage into 512 regular pages and it has to be done with an
> operation that can't fail. This way the reliability of the swapping
> isn't decreased (no need to allocate memory when we are short on
> memory to swap) and it's trivial to plug a split_huge_page* one-liner
> where needed without polluting the VM. Over time we can teach
> mprotect, mremap and friends to handle pmd_trans_huge natively without
> calling split_huge_page*. The fact it can't fail isn't just for swap:
> if split_huge_page would return -ENOMEM (instead of the current void)
> we'd need to rollback the mprotect from the middle of it (ideally
> including undoing the split_vma) which would be a big change and in
> the very wrong direction (it'd likely be simpler not to call
> split_huge_page at all and to teach mprotect and friends to handle
> hugepages instead of rolling them back from the middle). In short the
> very value of split_huge_page is that it can't fail.
> 
> The collapsing and madvise(MADV_HUGEPAGE) part will remain separated
> and incremental and it'll just be an "harmless" addition later if this
> initial part is agreed upon. It also should be noted that locking-wise
> replacing regular pages with hugepages is going to be very easy if
> compared to what I'm doing below in split_huge_page, as it will only
> happen when page_count(page) matches page_mapcount(page) if we can
> take the PG_lock and mmap_sem in write mode. collapse_huge_page will
> be a "best effort" that (unlike split_huge_page) can fail at the
> minimal sign of trouble and we can try again later. collapse_huge_page
> will be similar to how KSM works and the madvise(MADV_HUGEPAGE) will
> work similar to madvise(MADV_MERGEABLE).
> 
> The default I like is that transparent hugepages are used at page fault time.
> This can be changed with /sys/kernel/mm/transparent_hugepage/enabled. The
> control knob can be set to three values "always", "madvise", "never" which
> mean respectively that hugepages are always used, or only inside
> madvise(MADV_HUGEPAGE) regions, or never used.
> /sys/kernel/mm/transparent_hugepage/defrag instead controls if the hugepage
> allocation should defrag memory aggressively "always", only inside "madvise"
> regions, or "never".
> 
> The pmd_trans_splitting/pmd_trans_huge locking is very solid. The
> put_page (from get_user_page users that can't use mmu notifier like
> O_DIRECT) that runs against a __split_huge_page_refcount instead was a
> pain to serialize in a way that would result always in a coherent page
> count for both tail and head. I think my locking solution with a
> compound_lock taken only after the page_first is valid and is still a
> PageHead should be safe but it surely needs review from SMP race point
> of view. In short there is no current existing way to serialize the
> O_DIRECT final put_page against split_huge_page_refcount so I had to
> invent a new one (O_DIRECT loses knowledge on the mapping status by
> the time gup_fast returns so...). And I didn't want to impact all
> gup/gup_fast users for now, maybe if we change the gup interface
> substantially we can avoid this locking, I admit I didn't think too
> much about it because changing the gup unpinning interface would be
> invasive.
> 
> If we ignored O_DIRECT we could stick to the existing compound
> refcounting code, by simply adding a
> get_user_pages_fast_flags(foll_flags) where KVM (and any other mmu
> notifier user) would call it without FOLL_GET (and if FOLL_GET isn't
> set we'd just BUG_ON if nobody registered itself in the current task
> mmu notifier list yet). But O_DIRECT is fundamental for decent
> performance of virtualized I/O on fast storage so we can't avoid it to
> solve the race of put_page against split_huge_page_refcount to achieve
> a complete hugepage feature for KVM.
> 
> Swap and oom works fine (well just like with regular pages ;). MMU
> notifier is handled transparently too, with the exception of the young
> bit on the pmd, that didn't have a range check but I think KVM will be
> fine because the whole point of hugepages is that EPT/NPT will also
> use a huge pmd when they notice gup returns pages with PageCompound set,
> so they won't care of a range and there's just the pmd young bit to
> check in that case.
> 
> NOTE: in some cases if the L2 cache is small, this may slowdown and
> waste memory during COWs because 4M of memory are accessed in a single
> fault instead of 8k (the payoff is that after COW the program can run
> faster). So we might want to switch the copy_huge_page (and
> clear_huge_page too) to not temporal stores. I also extensively
> researched ways to avoid this cache trashing with a full prefault
> logic that would cow in 8k/16k/32k/64k up to 1M (I can send those
> patches that fully implemented prefault) but I concluded they're not
> worth it and they add an huge additional complexity and they remove all tlb
> benefits until the full hugepage has been faulted in, to save a little bit of
> memory and some cache during app startup, but they still don't improve
> substantially the cache-trashing during startup if the prefault happens in >4k
> chunks.  One reason is that those 4k pte entries copied are still mapped on a
> perfectly cache-colored hugepage, so the trashing is the worst one can generate
> in those copies (cow of 4k page copies aren't so well colored so they trashes
> less, but again this results in software running faster after the page fault).
> Those prefault patches allowed things like a pte where post-cow pages were
> local 4k regular anon pages and the not-yet-cowed pte entries were pointing in
> the middle of some hugepage mapped read-only. If it doesn't payoff
> substantially with todays hardware it will payoff even less in the future with
> larger l2 caches, and the prefault logic would blot the VM a lot. If one is
> emebdded transparent_hugepage can be disabled during boot with sysfs or with
> the boot commandline parameter transparent_hugepage=0 (or
> transparent_hugepage=2 to restrict hugepages inside madvise regions) that will
> ensure not a single hugepage is allocated at boot time. It is simple enough to
> just disable transparent hugepage globally and let transparent hugepages be
> allocated selectively by applications in the MADV_HUGEPAGE region (both at page
> fault time, and if enabled with the collapse_huge_page too through the kernel
> daemon).
> 
> This patch supports only hugepages mapped in the pmd, archs that have
> smaller hugepages will not fit in this patch alone. Also some archs like power
> have certain tlb limits that prevents mixing different page size in the same
> regions so they will not fit in this framework that requires "graceful
> fallback" to basic PAGE_SIZE in case of physical memory fragmentation.
> hugetlbfs remains a perfect fit for those because its software limits happen to
> match the hardware limits. hugetlbfs also remains a perfect fit for hugepage
> sizes like 1GByte that cannot be hoped to be found not fragmented after a
> certain system uptime and that would be very expensive to defragment with
> relocation, so requiring reservation. hugetlbfs is the "reservation way", the
> point of transparent hugepages is not to have any reservation at all and
> maximizing the use of cache and hugepages at all times automatically.
> 
> Some performance result:
> 
> vmx andrea # LD_PRELOAD=/usr/lib64/libhugetlbfs.so HUGETLB_MORECORE=yes HUGETLB_PATH=/mnt/huge/ ./largep
> ages3
> memset page fault 1566023
> memset tlb miss 453854
> memset second tlb miss 453321
> random access tlb miss 41635
> random access second tlb miss 41658
> vmx andrea # LD_PRELOAD=/usr/lib64/libhugetlbfs.so HUGETLB_MORECORE=yes HUGETLB_PATH=/mnt/huge/ ./largepages3
> memset page fault 1566471
> memset tlb miss 453375
> memset second tlb miss 453320
> random access tlb miss 41636
> random access second tlb miss 41637
> vmx andrea # ./largepages3
> memset page fault 1566642
> memset tlb miss 453417
> memset second tlb miss 453313
> random access tlb miss 41630
> random access second tlb miss 41647
> vmx andrea # ./largepages3
> memset page fault 1566872
> memset tlb miss 453418
> memset second tlb miss 453315
> random access tlb miss 41618
> random access second tlb miss 41659
> vmx andrea # echo 0 > /proc/sys/vm/transparent_hugepage
> vmx andrea # ./largepages3
> memset page fault 2182476
> memset tlb miss 460305
> memset second tlb miss 460179
> random access tlb miss 44483
> random access second tlb miss 44186
> vmx andrea # ./largepages3
> memset page fault 2182791
> memset tlb miss 460742
> memset second tlb miss 459962
> random access tlb miss 43981
> random access second tlb miss 43988
> 
> ============
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <sys/time.h>
> 
> #define SIZE (3UL*1024*1024*1024)
> 
> int main()
> {
> 	char *p = malloc(SIZE), *p2;
> 	struct timeval before, after;
> 
> 	gettimeofday(&before, NULL);
> 	memset(p, 0, SIZE);
> 	gettimeofday(&after, NULL);
> 	printf("memset page fault %Lu\n",
> 	       (after.tv_sec-before.tv_sec)*1000000UL +
> 	       after.tv_usec-before.tv_usec);
> 
> 	gettimeofday(&before, NULL);
> 	memset(p, 0, SIZE);
> 	gettimeofday(&after, NULL);
> 	printf("memset tlb miss %Lu\n",
> 	       (after.tv_sec-before.tv_sec)*1000000UL +
> 	       after.tv_usec-before.tv_usec);
> 
> 	gettimeofday(&before, NULL);
> 	memset(p, 0, SIZE);
> 	gettimeofday(&after, NULL);
> 	printf("memset second tlb miss %Lu\n",
> 	       (after.tv_sec-before.tv_sec)*1000000UL +
> 	       after.tv_usec-before.tv_usec);
> 
> 	gettimeofday(&before, NULL);
> 	for (p2 = p; p2 < p+SIZE; p2 += 4096)
> 		*p2 = 0;
> 	gettimeofday(&after, NULL);
> 	printf("random access tlb miss %Lu\n",
> 	       (after.tv_sec-before.tv_sec)*1000000UL +
> 	       after.tv_usec-before.tv_usec);
> 
> 	gettimeofday(&before, NULL);
> 	for (p2 = p; p2 < p+SIZE; p2 += 4096)
> 		*p2 = 0;
> 	gettimeofday(&after, NULL);
> 	printf("random access second tlb miss %Lu\n",
> 	       (after.tv_sec-before.tv_sec)*1000000UL +
> 	       after.tv_usec-before.tv_usec);
> 
> 	return 0;
> }
> ============
> 

All that seems fine to me. Nits in part that are simply not worth
calling out. In principal, I Agree With This :)

> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> * * *
> adapt to mm_counter in -mm
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> The interface changed slightly.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Acked-by: Rik van Riel <riel@redhat.com>
> ---
> * * *
> transparent hugepage bootparam
> 
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Allow transparent_hugepage=always|never|madvise at boot.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -286,6 +286,11 @@ static inline pmd_t pmd_mkwrite(pmd_t pm
>  	return pmd_set_flags(pmd, _PAGE_RW);
>  }
>  
> +static inline pmd_t pmd_mknotpresent(pmd_t pmd)
> +{
> +	return pmd_clear_flags(pmd, _PAGE_PRESENT);
> +}
> +
>  #endif /* !__ASSEMBLY__ */
>  
>  #endif /* _ASM_X86_PGTABLE_64_H */
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -108,6 +108,9 @@ struct vm_area_struct;
>  				 __GFP_HARDWALL | __GFP_HIGHMEM | \
>  				 __GFP_MOVABLE)
>  #define GFP_IOFS	(__GFP_IO | __GFP_FS)
> +#define GFP_TRANSHUGE	(GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> +			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN | \
> +			 __GFP_NO_KSWAPD)
>  
>  #ifdef CONFIG_NUMA
>  #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> new file mode 100644
> --- /dev/null
> +++ b/include/linux/huge_mm.h
> @@ -0,0 +1,126 @@
> +#ifndef _LINUX_HUGE_MM_H
> +#define _LINUX_HUGE_MM_H
> +
> +extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
> +				      struct vm_area_struct *vma,
> +				      unsigned long address, pmd_t *pmd,
> +				      unsigned int flags);
> +extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> +			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
> +			 struct vm_area_struct *vma);
> +extern int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +			       unsigned long address, pmd_t *pmd,
> +			       pmd_t orig_pmd);
> +extern pgtable_t get_pmd_huge_pte(struct mm_struct *mm);
> +extern struct page *follow_trans_huge_pmd(struct mm_struct *mm,
> +					  unsigned long addr,
> +					  pmd_t *pmd,
> +					  unsigned int flags);
> +extern int zap_huge_pmd(struct mmu_gather *tlb,
> +			struct vm_area_struct *vma,
> +			pmd_t *pmd);
> +
> +enum transparent_hugepage_flag {
> +	TRANSPARENT_HUGEPAGE_FLAG,
> +	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> +	TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
> +	TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
> +#ifdef CONFIG_DEBUG_VM
> +	TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
> +#endif
> +};
> +
> +enum page_check_address_pmd_flag {
> +	PAGE_CHECK_ADDRESS_PMD_FLAG,
> +	PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG,
> +	PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG,
> +};
> +extern pmd_t *page_check_address_pmd(struct page *page,
> +				     struct mm_struct *mm,
> +				     unsigned long address,
> +				     enum page_check_address_pmd_flag flag);
> +
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +#define HPAGE_PMD_SHIFT HPAGE_SHIFT
> +#define HPAGE_PMD_MASK HPAGE_MASK
> +#define HPAGE_PMD_SIZE HPAGE_SIZE
> +
> +#define transparent_hugepage_enabled(__vma)				\
> +	(transparent_hugepage_flags & (1<<TRANSPARENT_HUGEPAGE_FLAG) ||	\
> +	 (transparent_hugepage_flags &					\
> +	  (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG) &&			\
> +	  (__vma)->vm_flags & VM_HUGEPAGE))
> +#define transparent_hugepage_defrag(__vma)				\
> +	((transparent_hugepage_flags &					\
> +	  (1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)) ||			\
> +	 (transparent_hugepage_flags &					\
> +	  (1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG) &&		\
> +	  (__vma)->vm_flags & VM_HUGEPAGE))
> +#ifdef CONFIG_DEBUG_VM
> +#define transparent_hugepage_debug_cow()				\
> +	(transparent_hugepage_flags &					\
> +	 (1<<TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG))
> +#else /* CONFIG_DEBUG_VM */
> +#define transparent_hugepage_debug_cow() 0
> +#endif /* CONFIG_DEBUG_VM */
> +
> +extern unsigned long transparent_hugepage_flags;
> +extern int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> +			  pmd_t *dst_pmd, pmd_t *src_pmd,
> +			  struct vm_area_struct *vma,
> +			  unsigned long addr, unsigned long end);
> +extern int handle_pte_fault(struct mm_struct *mm,
> +			    struct vm_area_struct *vma, unsigned long address,
> +			    pte_t *pte, pmd_t *pmd, unsigned int flags);
> +extern int split_huge_page(struct page *page);
> +extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
> +#define split_huge_page_pmd(__mm, __pmd)				\
> +	do {								\
> +		pmd_t *____pmd = (__pmd);				\
> +		if (unlikely(pmd_trans_huge(*____pmd)))			\
> +			__split_huge_page_pmd(__mm, ____pmd);		\
> +	}  while (0)
> +#define wait_split_huge_page(__anon_vma, __pmd)				\
> +	do {								\
> +		pmd_t *____pmd = (__pmd);				\
> +		spin_unlock_wait(&(__anon_vma)->root->lock);		\
> +		/*							\
> +		 * spin_unlock_wait() is just a loop in C and so the	\
> +		 * CPU can reorder anything around it.			\
> +		 */							\
> +		smp_mb();						\

Just a note as I see nothing wrong with this but that's a good spot. The
unlock isn't a memory barrier. Out of curiousity, does it really need to be
a full barrier or would a write barrier have been enough?

> +		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
> +		       pmd_trans_huge(*____pmd));			\
> +	} while (0)
> +#define HPAGE_PMD_ORDER (HPAGE_PMD_SHIFT-PAGE_SHIFT)
> +#define HPAGE_PMD_NR (1<<HPAGE_PMD_ORDER)
> +#if HPAGE_PMD_ORDER > MAX_ORDER
> +#error "hugepages can't be allocated by the buddy allocator"
> +#endif
> +
> +extern unsigned long vma_address(struct page *page, struct vm_area_struct *vma);
> +static inline int PageTransHuge(struct page *page)
> +{
> +	VM_BUG_ON(PageTail(page));
> +	return PageHead(page);
> +}

gfp.h seems an odd place for these. Should the flags go in page-flags.h
and maybe put vma_address() in internal.h?

Not a biggie.

> +#else /* CONFIG_TRANSPARENT_HUGEPAGE */
> +#define HPAGE_PMD_SHIFT ({ BUG(); 0; })
> +#define HPAGE_PMD_MASK ({ BUG(); 0; })
> +#define HPAGE_PMD_SIZE ({ BUG(); 0; })
> +
> +#define transparent_hugepage_enabled(__vma) 0
> +
> +#define transparent_hugepage_flags 0UL
> +static inline int split_huge_page(struct page *page)
> +{
> +	return 0;
> +}
> +#define split_huge_page_pmd(__mm, __pmd)	\
> +	do { } while (0)
> +#define wait_split_huge_page(__anon_vma, __pmd)	\
> +	do { } while (0)
> +#define PageTransHuge(page) 0
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> +
> +#endif /* _LINUX_HUGE_MM_H */
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -111,6 +111,9 @@ extern unsigned int kobjsize(const void 
>  #define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
>  #define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
>  #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
> +#if BITS_PER_LONG > 32
> +#define VM_HUGEPAGE	0x100000000UL	/* MADV_HUGEPAGE marked this vma */
> +#endif
>  
>  #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
>  #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
> @@ -240,6 +243,7 @@ struct inode;
>   * files which need it (119 of them)
>   */
>  #include <linux/page-flags.h>
> +#include <linux/huge_mm.h>
>  
>  /*
>   * Methods to modify the page usage count.
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -20,11 +20,18 @@ static inline int page_is_file_cache(str
>  }
>  
>  static inline void
> +__add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l,
> +		       struct list_head *head)
> +{
> +	list_add(&page->lru, head);
> +	__inc_zone_state(zone, NR_LRU_BASE + l);
> +	mem_cgroup_add_lru_list(page, l);
> +}
> +
> +static inline void
>  add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
>  {
> -	list_add(&page->lru, &zone->lru[l].list);
> -	__inc_zone_state(zone, NR_LRU_BASE + l);
> -	mem_cgroup_add_lru_list(page, l);
> +	__add_page_to_lru_list(zone, page, l, &zone->lru[l].list);
>  }
>  

Do these really need to be in a public header or can they move to
mm/swap.c?

>  static inline void
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -208,6 +208,8 @@ extern unsigned int nr_free_pagecache_pa
>  /* linux/mm/swap.c */
>  extern void __lru_cache_add(struct page *, enum lru_list lru);
>  extern void lru_cache_add_lru(struct page *, enum lru_list lru);
> +extern void lru_add_page_tail(struct zone* zone,
> +			      struct page *page, struct page *page_tail);
>  extern void activate_page(struct page *);
>  extern void mark_page_accessed(struct page *);
>  extern void lru_add_drain(void);
> diff --git a/mm/Makefile b/mm/Makefile
> --- a/mm/Makefile
> +++ b/mm/Makefile
> @@ -42,3 +42,4 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-f
>  obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
>  obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
>  obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
> +obj-$(CONFIG_TRANSPARENT_HUGEPAGE) += huge_memory.o
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> new file mode 100644
> --- /dev/null
> +++ b/mm/huge_memory.c
> @@ -0,0 +1,899 @@
> +/*
> + *  Copyright (C) 2009  Red Hat, Inc.
> + *
> + *  This work is licensed under the terms of the GNU GPL, version 2. See
> + *  the COPYING file in the top-level directory.
> + */
> +
> +#include <linux/mm.h>
> +#include <linux/sched.h>
> +#include <linux/highmem.h>
> +#include <linux/hugetlb.h>
> +#include <linux/mmu_notifier.h>
> +#include <linux/rmap.h>
> +#include <linux/swap.h>
> +#include <asm/tlb.h>
> +#include <asm/pgalloc.h>
> +#include "internal.h"
> +
> +unsigned long transparent_hugepage_flags __read_mostly =
> +	(1<<TRANSPARENT_HUGEPAGE_FLAG);
> +
> +#ifdef CONFIG_SYSFS
> +static ssize_t double_flag_show(struct kobject *kobj,
> +				struct kobj_attribute *attr, char *buf,
> +				enum transparent_hugepage_flag enabled,
> +				enum transparent_hugepage_flag req_madv)
> +{
> +	if (test_bit(enabled, &transparent_hugepage_flags)) {
> +		VM_BUG_ON(test_bit(req_madv, &transparent_hugepage_flags));
> +		return sprintf(buf, "[always] madvise never\n");
> +	} else if (test_bit(req_madv, &transparent_hugepage_flags))
> +		return sprintf(buf, "always [madvise] never\n");
> +	else
> +		return sprintf(buf, "always madvise [never]\n");
> +}
> +static ssize_t double_flag_store(struct kobject *kobj,
> +				 struct kobj_attribute *attr,
> +				 const char *buf, size_t count,
> +				 enum transparent_hugepage_flag enabled,
> +				 enum transparent_hugepage_flag req_madv)
> +{
> +	if (!memcmp("always", buf,
> +		    min(sizeof("always")-1, count))) {
> +		set_bit(enabled, &transparent_hugepage_flags);
> +		clear_bit(req_madv, &transparent_hugepage_flags);
> +	} else if (!memcmp("madvise", buf,
> +			   min(sizeof("madvise")-1, count))) {
> +		clear_bit(enabled, &transparent_hugepage_flags);
> +		set_bit(req_madv, &transparent_hugepage_flags);
> +	} else if (!memcmp("never", buf,
> +			   min(sizeof("never")-1, count))) {
> +		clear_bit(enabled, &transparent_hugepage_flags);
> +		clear_bit(req_madv, &transparent_hugepage_flags);
> +	} else
> +		return -EINVAL;
> +
> +	return count;
> +}
> +
> +static ssize_t enabled_show(struct kobject *kobj,
> +			    struct kobj_attribute *attr, char *buf)
> +{
> +	return double_flag_show(kobj, attr, buf,
> +				TRANSPARENT_HUGEPAGE_FLAG,
> +				TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
> +}
> +static ssize_t enabled_store(struct kobject *kobj,
> +			     struct kobj_attribute *attr,
> +			     const char *buf, size_t count)
> +{
> +	return double_flag_store(kobj, attr, buf, count,
> +				 TRANSPARENT_HUGEPAGE_FLAG,
> +				 TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG);
> +}
> +static struct kobj_attribute enabled_attr =
> +	__ATTR(enabled, 0644, enabled_show, enabled_store);
> +
> +static ssize_t single_flag_show(struct kobject *kobj,
> +				struct kobj_attribute *attr, char *buf,
> +				enum transparent_hugepage_flag flag)
> +{
> +	if (test_bit(flag, &transparent_hugepage_flags))
> +		return sprintf(buf, "[yes] no\n");
> +	else
> +		return sprintf(buf, "yes [no]\n");
> +}
> +static ssize_t single_flag_store(struct kobject *kobj,
> +				 struct kobj_attribute *attr,
> +				 const char *buf, size_t count,
> +				 enum transparent_hugepage_flag flag)
> +{
> +	if (!memcmp("yes", buf,
> +		    min(sizeof("yes")-1, count))) {
> +		set_bit(flag, &transparent_hugepage_flags);
> +	} else if (!memcmp("no", buf,
> +			   min(sizeof("no")-1, count))) {
> +		clear_bit(flag, &transparent_hugepage_flags);
> +	} else
> +		return -EINVAL;
> +
> +	return count;
> +}
> +
> +/*
> + * Currently defrag only disables __GFP_NOWAIT for allocation. A blind
> + * __GFP_REPEAT is too aggressive, it's never worth swapping tons of
> + * memory just to allocate one more hugepage.
> + */
> +static ssize_t defrag_show(struct kobject *kobj,
> +			   struct kobj_attribute *attr, char *buf)
> +{
> +	return double_flag_show(kobj, attr, buf,
> +				TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
> +				TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG);
> +}
> +static ssize_t defrag_store(struct kobject *kobj,
> +			    struct kobj_attribute *attr,
> +			    const char *buf, size_t count)
> +{
> +	return double_flag_store(kobj, attr, buf, count,
> +				 TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
> +				 TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG);
> +}
> +static struct kobj_attribute defrag_attr =
> +	__ATTR(defrag, 0644, defrag_show, defrag_store);
> +
> +#ifdef CONFIG_DEBUG_VM
> +static ssize_t debug_cow_show(struct kobject *kobj,
> +				struct kobj_attribute *attr, char *buf)
> +{
> +	return single_flag_show(kobj, attr, buf,
> +				TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG);
> +}
> +static ssize_t debug_cow_store(struct kobject *kobj,
> +			       struct kobj_attribute *attr,
> +			       const char *buf, size_t count)
> +{
> +	return single_flag_store(kobj, attr, buf, count,
> +				 TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG);
> +}
> +static struct kobj_attribute debug_cow_attr =
> +	__ATTR(debug_cow, 0644, debug_cow_show, debug_cow_store);
> +#endif /* CONFIG_DEBUG_VM */
> +
> +static struct attribute *hugepage_attr[] = {
> +	&enabled_attr.attr,
> +	&defrag_attr.attr,
> +#ifdef CONFIG_DEBUG_VM
> +	&debug_cow_attr.attr,
> +#endif
> +	NULL,
> +};
> +
> +static struct attribute_group hugepage_attr_group = {
> +	.attrs = hugepage_attr,
> +	.name = "transparent_hugepage",
> +};
> +#endif /* CONFIG_SYSFS */
> +
> +static int __init hugepage_init(void)
> +{
> +#ifdef CONFIG_SYSFS
> +	int err;
> +
> +	err = sysfs_create_group(mm_kobj, &hugepage_attr_group);
> +	if (err)
> +		printk(KERN_ERR "hugepage: register sysfs failed\n");
> +#endif
> +	return 0;
> +}
> +module_init(hugepage_init)
> +
> +static int __init setup_transparent_hugepage(char *str)
> +{
> +	int ret = 0;
> +	if (!str)
> +		goto out;
> +	if (!strcmp(str, "always")) {
> +		set_bit(TRANSPARENT_HUGEPAGE_FLAG,
> +			&transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> +			  &transparent_hugepage_flags);
> +		ret = 1;
> +	} else if (!strcmp(str, "madvise")) {
> +		clear_bit(TRANSPARENT_HUGEPAGE_FLAG,
> +			  &transparent_hugepage_flags);
> +		set_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> +			&transparent_hugepage_flags);
> +		ret = 1;
> +	} else if (!strcmp(str, "never")) {
> +		clear_bit(TRANSPARENT_HUGEPAGE_FLAG,
> +			  &transparent_hugepage_flags);
> +		clear_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> +			  &transparent_hugepage_flags);
> +		ret = 1;
> +	}
> +out:
> +	if (!ret)
> +		printk(KERN_WARNING
> +		       "transparent_hugepage= cannot parse, ignored\n");
> +	return ret;
> +}
> +__setup("transparent_hugepage=", setup_transparent_hugepage);
> +
> +static void prepare_pmd_huge_pte(pgtable_t pgtable,
> +				 struct mm_struct *mm)
> +{
> +	VM_BUG_ON(spin_can_lock(&mm->page_table_lock));
> +

assert_spin_locked() ?

> +	/* FIFO */
> +	if (!mm->pmd_huge_pte)
> +		INIT_LIST_HEAD(&pgtable->lru);
> +	else
> +		list_add(&pgtable->lru, &mm->pmd_huge_pte->lru);
> +	mm->pmd_huge_pte = pgtable;
> +}
> +
> +static inline pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
> +{
> +	if (likely(vma->vm_flags & VM_WRITE))
> +		pmd = pmd_mkwrite(pmd);
> +	return pmd;
> +}
> +
> +static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
> +					struct vm_area_struct *vma,
> +					unsigned long haddr, pmd_t *pmd,
> +					struct page *page)
> +{
> +	int ret = 0;
> +	pgtable_t pgtable;
> +
> +	VM_BUG_ON(!PageCompound(page));
> +	pgtable = pte_alloc_one(mm, haddr);
> +	if (unlikely(!pgtable)) {
> +		put_page(page);
> +		return VM_FAULT_OOM;
> +	}
> +
> +	clear_huge_page(page, haddr, HPAGE_PMD_NR);
> +	__SetPageUptodate(page);
> +
> +	spin_lock(&mm->page_table_lock);
> +	if (unlikely(!pmd_none(*pmd))) {
> +		spin_unlock(&mm->page_table_lock);
> +		put_page(page);
> +		pte_free(mm, pgtable);
> +	} else {
> +		pmd_t entry;
> +		entry = mk_pmd(page, vma->vm_page_prot);
> +		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> +		entry = pmd_mkhuge(entry);
> +		/*
> +		 * The spinlocking to take the lru_lock inside
> +		 * page_add_new_anon_rmap() acts as a full memory
> +		 * barrier to be sure clear_huge_page writes become
> +		 * visible after the set_pmd_at() write.
> +		 */
> +		page_add_new_anon_rmap(page, vma, haddr);
> +		set_pmd_at(mm, haddr, pmd, entry);
> +		prepare_pmd_huge_pte(pgtable, mm);
> +		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
> +		spin_unlock(&mm->page_table_lock);
> +	}
> +
> +	return ret;
> +}
> +
> +static inline struct page *alloc_hugepage(int defrag)
> +{
> +	return alloc_pages(GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT),
> +			   HPAGE_PMD_ORDER);
> +}
> +
> +int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +			       unsigned long address, pmd_t *pmd,
> +			       unsigned int flags)
> +{
> +	struct page *page;
> +	unsigned long haddr = address & HPAGE_PMD_MASK;
> +	pte_t *pte;
> +
> +	if (haddr >= vma->vm_start && haddr + HPAGE_PMD_SIZE <= vma->vm_end) {
> +		if (unlikely(anon_vma_prepare(vma)))
> +			return VM_FAULT_OOM;
> +		page = alloc_hugepage(transparent_hugepage_defrag(vma));
> +		if (unlikely(!page))
> +			goto out;
> +
> +		return __do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page);
> +	}
> +out:
> +	/*
> +	 * Use __pte_alloc instead of pte_alloc_map, because we can't
> +	 * run pte_offset_map on the pmd, if an huge pmd could
> +	 * materialize from under us from a different thread.
> +	 */
> +	if (unlikely(__pte_alloc(mm, vma, pmd, address)))
> +		return VM_FAULT_OOM;
> +	/* if an huge pmd materialized from under us just retry later */
> +	if (unlikely(pmd_trans_huge(*pmd)))
> +		return 0;
> +	/*
> +	 * A regular pmd is established and it can't morph into a huge pmd
> +	 * from under us anymore at this point because we hold the mmap_sem
> +	 * read mode and khugepaged takes it in write mode. So now it's
> +	 * safe to run pte_offset_map().
> +	 */
> +	pte = pte_offset_map(pmd, address);
> +	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
> +}
> +
> +int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> +		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
> +		  struct vm_area_struct *vma)
> +{
> +	struct page *src_page;
> +	pmd_t pmd;
> +	pgtable_t pgtable;
> +	int ret;
> +
> +	ret = -ENOMEM;
> +	pgtable = pte_alloc_one(dst_mm, addr);
> +	if (unlikely(!pgtable))
> +		goto out;
> +
> +	spin_lock(&dst_mm->page_table_lock);
> +	spin_lock_nested(&src_mm->page_table_lock, SINGLE_DEPTH_NESTING);
> +
> +	ret = -EAGAIN;
> +	pmd = *src_pmd;
> +	if (unlikely(!pmd_trans_huge(pmd))) {
> +		pte_free(dst_mm, pgtable);
> +		goto out_unlock;
> +	}
> +	if (unlikely(pmd_trans_splitting(pmd))) {
> +		/* split huge page running from under us */
> +		spin_unlock(&src_mm->page_table_lock);
> +		spin_unlock(&dst_mm->page_table_lock);
> +		pte_free(dst_mm, pgtable);
> +
> +		wait_split_huge_page(vma->anon_vma, src_pmd); /* src_vma */
> +		goto out;
> +	}
> +	src_page = pmd_page(pmd);
> +	VM_BUG_ON(!PageHead(src_page));
> +	get_page(src_page);
> +	page_dup_rmap(src_page);
> +	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
> +
> +	pmdp_set_wrprotect(src_mm, addr, src_pmd);
> +	pmd = pmd_mkold(pmd_wrprotect(pmd));
> +	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
> +	prepare_pmd_huge_pte(pgtable, dst_mm);
> +
> +	ret = 0;
> +out_unlock:
> +	spin_unlock(&src_mm->page_table_lock);
> +	spin_unlock(&dst_mm->page_table_lock);
> +out:
> +	return ret;
> +}
> +
> +/* no "address" argument so destroys page coloring of some arch */
> +pgtable_t get_pmd_huge_pte(struct mm_struct *mm)
> +{
> +	pgtable_t pgtable;
> +
> +	VM_BUG_ON(spin_can_lock(&mm->page_table_lock));
> +
> +	/* FIFO */
> +	pgtable = mm->pmd_huge_pte;
> +	if (list_empty(&pgtable->lru))
> +		mm->pmd_huge_pte = NULL;
> +	else {
> +		mm->pmd_huge_pte = list_entry(pgtable->lru.next,
> +					      struct page, lru);
> +		list_del(&pgtable->lru);
> +	}
> +	return pgtable;
> +}
> +
> +static int do_huge_pmd_wp_page_fallback(struct mm_struct *mm,
> +					struct vm_area_struct *vma,
> +					unsigned long address,
> +					pmd_t *pmd, pmd_t orig_pmd,
> +					struct page *page,
> +					unsigned long haddr)
> +{
> +	pgtable_t pgtable;
> +	pmd_t _pmd;
> +	int ret = 0, i;
> +	struct page **pages;
> +
> +	pages = kmalloc(sizeof(struct page *) * HPAGE_PMD_NR,
> +			GFP_KERNEL);
> +	if (unlikely(!pages)) {
> +		ret |= VM_FAULT_OOM;
> +		goto out;
> +	}
> +
> +	for (i = 0; i < HPAGE_PMD_NR; i++) {
> +		pages[i] = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
> +					  vma, address);
> +		if (unlikely(!pages[i])) {
> +			while (--i >= 0)
> +				put_page(pages[i]);
> +			kfree(pages);
> +			ret |= VM_FAULT_OOM;
> +			goto out;
> +		}
> +	}
> +
> +	for (i = 0; i < HPAGE_PMD_NR; i++) {
> +		copy_user_highpage(pages[i], page + i,
> +				   haddr + PAGE_SHIFT*i, vma);
> +		__SetPageUptodate(pages[i]);
> +		cond_resched();
> +	}
> +
> +	spin_lock(&mm->page_table_lock);
> +	if (unlikely(!pmd_same(*pmd, orig_pmd)))
> +		goto out_free_pages;
> +	VM_BUG_ON(!PageHead(page));
> +
> +	pmdp_clear_flush_notify(vma, haddr, pmd);
> +	/* leave pmd empty until pte is filled */
> +
> +	pgtable = get_pmd_huge_pte(mm);
> +	pmd_populate(mm, &_pmd, pgtable);
> +
> +	for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> +		pte_t *pte, entry;
> +		entry = mk_pte(pages[i], vma->vm_page_prot);
> +		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		page_add_new_anon_rmap(pages[i], vma, haddr);
> +		pte = pte_offset_map(&_pmd, haddr);
> +		VM_BUG_ON(!pte_none(*pte));
> +		set_pte_at(mm, haddr, pte, entry);
> +		pte_unmap(pte);
> +	}
> +	kfree(pages);
> +
> +	mm->nr_ptes++;
> +	smp_wmb(); /* make pte visible before pmd */
> +	pmd_populate(mm, pmd, pgtable);
> +	page_remove_rmap(page);
> +	spin_unlock(&mm->page_table_lock);
> +
> +	ret |= VM_FAULT_WRITE;
> +	put_page(page);
> +
> +out:
> +	return ret;
> +
> +out_free_pages:
> +	spin_unlock(&mm->page_table_lock);
> +	for (i = 0; i < HPAGE_PMD_NR; i++)
> +		put_page(pages[i]);
> +	kfree(pages);
> +	goto out;
> +}
> +
> +int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +			unsigned long address, pmd_t *pmd, pmd_t orig_pmd)
> +{
> +	int ret = 0;
> +	struct page *page, *new_page;
> +	unsigned long haddr;
> +
> +	VM_BUG_ON(!vma->anon_vma);
> +	spin_lock(&mm->page_table_lock);
> +	if (unlikely(!pmd_same(*pmd, orig_pmd)))
> +		goto out_unlock;
> +
> +	page = pmd_page(orig_pmd);
> +	VM_BUG_ON(!PageCompound(page) || !PageHead(page));
> +	haddr = address & HPAGE_PMD_MASK;
> +	if (page_mapcount(page) == 1) {
> +		pmd_t entry;
> +		entry = pmd_mkyoung(orig_pmd);
> +		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> +		if (pmdp_set_access_flags(vma, haddr, pmd, entry,  1))
> +			update_mmu_cache(vma, address, entry);
> +		ret |= VM_FAULT_WRITE;
> +		goto out_unlock;
> +	}
> +	get_page(page);
> +	spin_unlock(&mm->page_table_lock);
> +
> +	if (transparent_hugepage_enabled(vma) &&
> +	    !transparent_hugepage_debug_cow())
> +		new_page = alloc_hugepage(transparent_hugepage_defrag(vma));
> +	else
> +		new_page = NULL;
> +
> +	if (unlikely(!new_page)) {
> +		ret = do_huge_pmd_wp_page_fallback(mm, vma, address,
> +						   pmd, orig_pmd, page, haddr);
> +		put_page(page);
> +		goto out;
> +	}
> +
> +	copy_user_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
> +	__SetPageUptodate(new_page);
> +
> +	spin_lock(&mm->page_table_lock);
> +	put_page(page);
> +	if (unlikely(!pmd_same(*pmd, orig_pmd)))
> +		put_page(new_page);
> +	else {
> +		pmd_t entry;
> +		VM_BUG_ON(!PageHead(page));
> +		entry = mk_pmd(new_page, vma->vm_page_prot);
> +		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> +		entry = pmd_mkhuge(entry);
> +		pmdp_clear_flush_notify(vma, haddr, pmd);
> +		page_add_new_anon_rmap(new_page, vma, haddr);
> +		set_pmd_at(mm, haddr, pmd, entry);
> +		update_mmu_cache(vma, address, entry);
> +		page_remove_rmap(page);
> +		put_page(page);
> +		ret |= VM_FAULT_WRITE;
> +	}
> +out_unlock:
> +	spin_unlock(&mm->page_table_lock);
> +out:
> +	return ret;
> +}
> +
> +struct page *follow_trans_huge_pmd(struct mm_struct *mm,
> +				   unsigned long addr,
> +				   pmd_t *pmd,
> +				   unsigned int flags)
> +{
> +	struct page *page = NULL;
> +
> +	VM_BUG_ON(spin_can_lock(&mm->page_table_lock));
> +
> +	if (flags & FOLL_WRITE && !pmd_write(*pmd))
> +		goto out;
> +
> +	page = pmd_page(*pmd);
> +	VM_BUG_ON(!PageHead(page));
> +	if (flags & FOLL_TOUCH) {
> +		pmd_t _pmd;
> +		/*
> +		 * We should set the dirty bit only for FOLL_WRITE but
> +		 * for now the dirty bit in the pmd is meaningless.
> +		 * And if the dirty bit will become meaningful and
> +		 * we'll only set it with FOLL_WRITE, an atomic
> +		 * set_bit will be required on the pmd to set the
> +		 * young bit, instead of the current set_pmd_at.
> +		 */
> +		_pmd = pmd_mkyoung(pmd_mkdirty(*pmd));
> +		set_pmd_at(mm, addr & HPAGE_PMD_MASK, pmd, _pmd);
> +	}
> +	page += (addr & ~HPAGE_PMD_MASK) >> PAGE_SHIFT;
> +	VM_BUG_ON(!PageCompound(page));
> +	if (flags & FOLL_GET)
> +		get_page(page);
> +
> +out:
> +	return page;
> +}
> +
> +int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
> +		 pmd_t *pmd)
> +{
> +	int ret = 0;
> +
> +	spin_lock(&tlb->mm->page_table_lock);
> +	if (likely(pmd_trans_huge(*pmd))) {
> +		if (unlikely(pmd_trans_splitting(*pmd))) {
> +			spin_unlock(&tlb->mm->page_table_lock);
> +			wait_split_huge_page(vma->anon_vma,
> +					     pmd);
> +		} else {
> +			struct page *page;
> +			pgtable_t pgtable;
> +			pgtable = get_pmd_huge_pte(tlb->mm);
> +			page = pmd_page(*pmd);
> +			pmd_clear(pmd);
> +			page_remove_rmap(page);
> +			VM_BUG_ON(page_mapcount(page) < 0);
> +			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> +			VM_BUG_ON(!PageHead(page));
> +			spin_unlock(&tlb->mm->page_table_lock);
> +			tlb_remove_page(tlb, page);
> +			pte_free(tlb->mm, pgtable);
> +			ret = 1;
> +		}
> +	} else
> +		spin_unlock(&tlb->mm->page_table_lock);
> +
> +	return ret;
> +}
> +
> +pmd_t *page_check_address_pmd(struct page *page,
> +			      struct mm_struct *mm,
> +			      unsigned long address,
> +			      enum page_check_address_pmd_flag flag)
> +{
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd, *ret = NULL;
> +
> +	if (address & ~HPAGE_PMD_MASK)
> +		goto out;
> +
> +	pgd = pgd_offset(mm, address);
> +	if (!pgd_present(*pgd))
> +		goto out;
> +
> +	pud = pud_offset(pgd, address);
> +	if (!pud_present(*pud))
> +		goto out;
> +
> +	pmd = pmd_offset(pud, address);
> +	if (pmd_none(*pmd))
> +		goto out;
> +	if (pmd_page(*pmd) != page)
> +		goto out;
> +	VM_BUG_ON(flag == PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG &&
> +		  pmd_trans_splitting(*pmd));
> +	if (pmd_trans_huge(*pmd)) {
> +		VM_BUG_ON(flag == PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG &&
> +			  !pmd_trans_splitting(*pmd));
> +		ret = pmd;
> +	}
> +out:
> +	return ret;
> +}
> +
> +static int __split_huge_page_splitting(struct page *page,
> +				       struct vm_area_struct *vma,
> +				       unsigned long address)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	pmd_t *pmd;
> +	int ret = 0;
> +
> +	spin_lock(&mm->page_table_lock);
> +	pmd = page_check_address_pmd(page, mm, address,
> +				     PAGE_CHECK_ADDRESS_PMD_NOTSPLITTING_FLAG);
> +	if (pmd) {
> +		/*
> +		 * We can't temporarily set the pmd to null in order
> +		 * to split it, the pmd must remain marked huge at all
> +		 * times or the VM won't take the pmd_trans_huge paths
> +		 * and it won't wait on the anon_vma->root->lock to
> +		 * serialize against split_huge_page*.
> +		 */
> +		pmdp_splitting_flush_notify(vma, address, pmd);
> +		ret = 1;
> +	}
> +	spin_unlock(&mm->page_table_lock);
> +
> +	return ret;
> +}
> +
> +static void __split_huge_page_refcount(struct page *page)
> +{
> +	int i;
> +	unsigned long head_index = page->index;
> +	struct zone *zone = page_zone(page);
> +
> +	/* prevent PageLRU to go away from under us, and freeze lru stats */
> +	spin_lock_irq(&zone->lru_lock);
> +	compound_lock(page);
> +
> +	for (i = 1; i < HPAGE_PMD_NR; i++) {
> +		struct page *page_tail = page + i;
> +
> +		/* tail_page->_count cannot change */
> +		atomic_sub(atomic_read(&page_tail->_count), &page->_count);
> +		BUG_ON(page_count(page) <= 0);
> +		atomic_add(page_mapcount(page) + 1, &page_tail->_count);
> +		BUG_ON(atomic_read(&page_tail->_count) <= 0);
> +
> +		/* after clearing PageTail the gup refcount can be released */
> +		smp_mb();
> +
> +		page_tail->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> +		page_tail->flags |= (page->flags &
> +				     ((1L << PG_referenced) |
> +				      (1L << PG_swapbacked) |
> +				      (1L << PG_mlocked) |
> +				      (1L << PG_uptodate)));
> +		page_tail->flags |= (1L << PG_dirty);
> +
> +		/*
> +		 * 1) clear PageTail before overwriting first_page
> +		 * 2) clear PageTail before clearing PageHead for VM_BUG_ON
> +		 */
> +		smp_wmb();
> +
> +		/*
> +		 * __split_huge_page_splitting() already set the
> +		 * splitting bit in all pmd that could map this
> +		 * hugepage, that will ensure no CPU can alter the
> +		 * mapcount on the head page. The mapcount is only
> +		 * accounted in the head page and it has to be
> +		 * transferred to all tail pages in the below code. So
> +		 * for this code to be safe, the split the mapcount
> +		 * can't change. But that doesn't mean userland can't
> +		 * keep changing and reading the page contents while
> +		 * we transfer the mapcount, so the pmd splitting
> +		 * status is achieved setting a reserved bit in the
> +		 * pmd, not by clearing the present bit.
> +		*/
> +		BUG_ON(page_mapcount(page_tail));
> +		page_tail->_mapcount = page->_mapcount;
> +
> +		BUG_ON(page_tail->mapping);
> +		page_tail->mapping = page->mapping;
> +
> +		page_tail->index = ++head_index;
> +
> +		BUG_ON(!PageAnon(page_tail));
> +		BUG_ON(!PageUptodate(page_tail));
> +		BUG_ON(!PageDirty(page_tail));
> +		BUG_ON(!PageSwapBacked(page_tail));
> +
> +		lru_add_page_tail(zone, page, page_tail);
> +	}
> +
> +	ClearPageCompound(page);
> +	compound_unlock(page);
> +	spin_unlock_irq(&zone->lru_lock);
> +
> +	for (i = 1; i < HPAGE_PMD_NR; i++) {
> +		struct page *page_tail = page + i;
> +		BUG_ON(page_count(page_tail) <= 0);
> +		/*
> +		 * Tail pages may be freed if there wasn't any mapping
> +		 * like if add_to_swap() is running on a lru page that
> +		 * had its mapping zapped. And freeing these pages
> +		 * requires taking the lru_lock so we do the put_page
> +		 * of the tail pages after the split is complete.
> +		 */
> +		put_page(page_tail);
> +	}
> +
> +	/*
> +	 * Only the head page (now become a regular page) is required
> +	 * to be pinned by the caller.
> +	 */
> +	BUG_ON(page_count(page) <= 0);
> +}
> +
> +static int __split_huge_page_map(struct page *page,
> +				 struct vm_area_struct *vma,
> +				 unsigned long address)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	pmd_t *pmd, _pmd;
> +	int ret = 0, i;
> +	pgtable_t pgtable;
> +	unsigned long haddr;
> +
> +	spin_lock(&mm->page_table_lock);
> +	pmd = page_check_address_pmd(page, mm, address,
> +				     PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG);
> +	if (pmd) {
> +		pgtable = get_pmd_huge_pte(mm);
> +		pmd_populate(mm, &_pmd, pgtable);
> +
> +		for (i = 0, haddr = address; i < HPAGE_PMD_NR;
> +		     i++, haddr += PAGE_SIZE) {
> +			pte_t *pte, entry;
> +			BUG_ON(PageCompound(page+i));
> +			entry = mk_pte(page + i, vma->vm_page_prot);
> +			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +			if (!pmd_write(*pmd))
> +				entry = pte_wrprotect(entry);
> +			else
> +				BUG_ON(page_mapcount(page) != 1);
> +			if (!pmd_young(*pmd))
> +				entry = pte_mkold(entry);
> +			pte = pte_offset_map(&_pmd, haddr);
> +			BUG_ON(!pte_none(*pte));
> +			set_pte_at(mm, haddr, pte, entry);
> +			pte_unmap(pte);
> +		}
> +
> +		mm->nr_ptes++;
> +		smp_wmb(); /* make pte visible before pmd */
> +		/*
> +		 * Up to this point the pmd is present and huge and
> +		 * userland has the whole access to the hugepage
> +		 * during the split (which happens in place). If we
> +		 * overwrite the pmd with the not-huge version
> +		 * pointing to the pte here (which of course we could
> +		 * if all CPUs were bug free), userland could trigger
> +		 * a small page size TLB miss on the small sized TLB
> +		 * while the hugepage TLB entry is still established
> +		 * in the huge TLB. Some CPU doesn't like that. See
> +		 * http://support.amd.com/us/Processor_TechDocs/41322.pdf,
> +		 * Erratum 383 on page 93. Intel should be safe but is
> +		 * also warns that it's only safe if the permission
> +		 * and cache attributes of the two entries loaded in
> +		 * the two TLB is identical (which should be the case
> +		 * here). But it is generally safer to never allow
> +		 * small and huge TLB entries for the same virtual
> +		 * address to be loaded simultaneously. So instead of
> +		 * doing "pmd_populate(); flush_tlb_range();" we first
> +		 * mark the current pmd notpresent (atomically because
> +		 * here the pmd_trans_huge and pmd_trans_splitting
> +		 * must remain set at all times on the pmd until the
> +		 * split is complete for this pmd), then we flush the
> +		 * SMP TLB and finally we write the non-huge version
> +		 * of the pmd entry with pmd_populate.
> +		 */
> +		set_pmd_at(mm, address, pmd, pmd_mknotpresent(*pmd));
> +		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +		pmd_populate(mm, pmd, pgtable);
> +		ret = 1;
> +	}
> +	spin_unlock(&mm->page_table_lock);
> +
> +	return ret;
> +}
> +
> +/* must be called with anon_vma->root->lock hold */
> +static void __split_huge_page(struct page *page,
> +			      struct anon_vma *anon_vma)
> +{
> +	int mapcount, mapcount2;
> +	struct anon_vma_chain *avc;
> +
> +	BUG_ON(!PageHead(page));
> +	BUG_ON(PageTail(page));
> +
> +	mapcount = 0;
> +	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
> +		struct vm_area_struct *vma = avc->vma;
> +		unsigned long addr = vma_address(page, vma);
> +		if (addr == -EFAULT)
> +			continue;
> +		mapcount += __split_huge_page_splitting(page, vma, addr);
> +	}
> +	BUG_ON(mapcount != page_mapcount(page));
> +
> +	__split_huge_page_refcount(page);
> +
> +	mapcount2 = 0;
> +	list_for_each_entry(avc, &anon_vma->head, same_anon_vma) {
> +		struct vm_area_struct *vma = avc->vma;
> +		unsigned long addr = vma_address(page, vma);
> +		if (addr == -EFAULT)
> +			continue;
> +		mapcount2 += __split_huge_page_map(page, vma, addr);
> +	}
> +	BUG_ON(mapcount != mapcount2);
> +}
> +
> +int split_huge_page(struct page *page)
> +{
> +	struct anon_vma *anon_vma;
> +	int ret = 1;
> +
> +	BUG_ON(!PageAnon(page));
> +	anon_vma = page_lock_anon_vma(page);
> +	if (!anon_vma)
> +		goto out;
> +	ret = 0;
> +	if (!PageCompound(page))
> +		goto out_unlock;
> +
> +	BUG_ON(!PageSwapBacked(page));
> +	__split_huge_page(page, anon_vma);
> +
> +	BUG_ON(PageCompound(page));
> +out_unlock:
> +	page_unlock_anon_vma(anon_vma);
> +out:
> +	return ret;
> +}
> +
> +void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
> +{
> +	struct page *page;
> +
> +	spin_lock(&mm->page_table_lock);
> +	if (unlikely(!pmd_trans_huge(*pmd))) {
> +		spin_unlock(&mm->page_table_lock);
> +		return;
> +	}
> +	page = pmd_page(*pmd);
> +	VM_BUG_ON(!page_count(page));
> +	get_page(page);
> +	spin_unlock(&mm->page_table_lock);
> +
> +	split_huge_page(page);
> +
> +	put_page(page);
> +	BUG_ON(pmd_trans_huge(*pmd));
> +}
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -726,9 +726,9 @@ out_set_pte:
>  	return 0;
>  }
>  
> -static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> -		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
> -		unsigned long addr, unsigned long end)
> +int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> +		   pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
> +		   unsigned long addr, unsigned long end)
>  {
>  	pte_t *orig_src_pte, *orig_dst_pte;
>  	pte_t *src_pte, *dst_pte;
> @@ -802,6 +802,16 @@ static inline int copy_pmd_range(struct 
>  	src_pmd = pmd_offset(src_pud, addr);
>  	do {
>  		next = pmd_addr_end(addr, end);
> +		if (pmd_trans_huge(*src_pmd)) {
> +			int err;
> +			err = copy_huge_pmd(dst_mm, src_mm,
> +					    dst_pmd, src_pmd, addr, vma);
> +			if (err == -ENOMEM)
> +				return -ENOMEM;
> +			if (!err)
> +				continue;
> +			/* fall through */
> +		}
>  		if (pmd_none_or_clear_bad(src_pmd))
>  			continue;
>  		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
> @@ -1004,6 +1014,15 @@ static inline unsigned long zap_pmd_rang
>  	pmd = pmd_offset(pud, addr);
>  	do {
>  		next = pmd_addr_end(addr, end);
> +		if (pmd_trans_huge(*pmd)) {
> +			if (next-addr != HPAGE_PMD_SIZE)
> +				split_huge_page_pmd(vma->vm_mm, pmd);
> +			else if (zap_huge_pmd(tlb, vma, pmd)) {
> +				(*zap_work)--;
> +				continue;
> +			}
> +			/* fall through */
> +		}
>  		if (pmd_none_or_clear_bad(pmd)) {
>  			(*zap_work)--;
>  			continue;
> @@ -1280,11 +1299,27 @@ struct page *follow_page(struct vm_area_
>  	pmd = pmd_offset(pud, address);
>  	if (pmd_none(*pmd))
>  		goto no_page_table;
> -	if (pmd_huge(*pmd)) {
> +	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
>  		BUG_ON(flags & FOLL_GET);
>  		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
>  		goto out;
>  	}
> +	if (pmd_trans_huge(*pmd)) {
> +		spin_lock(&mm->page_table_lock);
> +		if (likely(pmd_trans_huge(*pmd))) {
> +			if (unlikely(pmd_trans_splitting(*pmd))) {
> +				spin_unlock(&mm->page_table_lock);
> +				wait_split_huge_page(vma->anon_vma, pmd);
> +			} else {
> +				page = follow_trans_huge_pmd(mm, address,
> +							     pmd, flags);
> +				spin_unlock(&mm->page_table_lock);
> +				goto out;
> +			}
> +		} else
> +			spin_unlock(&mm->page_table_lock);
> +		/* fall through */
> +	}
>  	if (unlikely(pmd_bad(*pmd)))
>  		goto no_page_table;
>  
> @@ -3141,9 +3176,9 @@ static int do_nonlinear_fault(struct mm_
>   * but allow concurrent faults), and pte mapped but not yet locked.
>   * We return with mmap_sem still held, but pte unmapped and unlocked.
>   */
> -static inline int handle_pte_fault(struct mm_struct *mm,
> -		struct vm_area_struct *vma, unsigned long address,
> -		pte_t *pte, pmd_t *pmd, unsigned int flags)
> +int handle_pte_fault(struct mm_struct *mm,
> +		     struct vm_area_struct *vma, unsigned long address,
> +		     pte_t *pte, pmd_t *pmd, unsigned int flags)
>  {
>  	pte_t entry;
>  	spinlock_t *ptl;
> @@ -3222,9 +3257,40 @@ int handle_mm_fault(struct mm_struct *mm
>  	pmd = pmd_alloc(mm, pud, address);
>  	if (!pmd)
>  		return VM_FAULT_OOM;
> -	pte = pte_alloc_map(mm, vma, pmd, address);
> -	if (!pte)
> +	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
> +		if (!vma->vm_ops)
> +			return do_huge_pmd_anonymous_page(mm, vma, address,
> +							  pmd, flags);
> +	} else {
> +		pmd_t orig_pmd = *pmd;
> +		barrier();

What is this barrier for?

> +		if (pmd_trans_huge(orig_pmd)) {
> +			if (flags & FAULT_FLAG_WRITE &&
> +			    !pmd_write(orig_pmd) &&
> +			    !pmd_trans_splitting(orig_pmd))
> +				return do_huge_pmd_wp_page(mm, vma, address,
> +							   pmd, orig_pmd);
> +			return 0;
> +		}
> +	}
> +
> +	/*
> +	 * Use __pte_alloc instead of pte_alloc_map, because we can't
> +	 * run pte_offset_map on the pmd, if an huge pmd could
> +	 * materialize from under us from a different thread.
> +	 */
> +	if (unlikely(__pte_alloc(mm, vma, pmd, address)))
>  		return VM_FAULT_OOM;
> +	/* if an huge pmd materialized from under us just retry later */
> +	if (unlikely(pmd_trans_huge(*pmd)))
> +		return 0;
> +	/*
> +	 * A regular pmd is established and it can't morph into a huge pmd
> +	 * from under us anymore at this point because we hold the mmap_sem
> +	 * read mode and khugepaged takes it in write mode. So now it's
> +	 * safe to run pte_offset_map().
> +	 */
> +	pte = pte_offset_map(pmd, address);
>  
>  	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
>  }
> diff --git a/mm/rmap.c b/mm/rmap.c
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -360,7 +360,7 @@ void page_unlock_anon_vma(struct anon_vm
>   * Returns virtual address or -EFAULT if page's index/offset is not
>   * within the range mapped the @vma.
>   */
> -static inline unsigned long
> +inline unsigned long
>  vma_address(struct page *page, struct vm_area_struct *vma)
>  {
>  	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> @@ -435,6 +435,8 @@ pte_t *__page_check_address(struct page 
>  	pmd = pmd_offset(pud, address);
>  	if (!pmd_present(*pmd))
>  		return NULL;
> +	if (pmd_trans_huge(*pmd))
> +		return NULL;
>  
>  	pte = pte_offset_map(pmd, address);
>  	/* Make a quick check before getting the lock */
> @@ -489,35 +491,17 @@ int page_referenced_one(struct page *pag
>  			unsigned long *vm_flags)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
> -	pte_t *pte;
> -	spinlock_t *ptl;
>  	int referenced = 0;
>  
> -	pte = page_check_address(page, mm, address, &ptl, 0);
> -	if (!pte)
> -		goto out;
> -
>  	/*
>  	 * Don't want to elevate referenced for mlocked page that gets this far,
>  	 * in order that it progresses to try_to_unmap and is moved to the
>  	 * unevictable list.
>  	 */
>  	if (vma->vm_flags & VM_LOCKED) {
> -		*mapcount = 1;	/* break early from loop */
> +		*mapcount = 0;	/* break early from loop */
>  		*vm_flags |= VM_LOCKED;
> -		goto out_unmap;
> -	}
> -
> -	if (ptep_clear_flush_young_notify(vma, address, pte)) {
> -		/*
> -		 * Don't treat a reference through a sequentially read
> -		 * mapping as such.  If the page has been used in
> -		 * another mapping, we will catch it; if this other
> -		 * mapping is already gone, the unmap path will have
> -		 * set PG_referenced or activated the page.
> -		 */
> -		if (likely(!VM_SequentialReadHint(vma)))
> -			referenced++;
> +		goto out;
>  	}
>  
>  	/* Pretend the page is referenced if the task has the
> @@ -526,9 +510,39 @@ int page_referenced_one(struct page *pag
>  			rwsem_is_locked(&mm->mmap_sem))
>  		referenced++;
>  
> -out_unmap:
> +	if (unlikely(PageTransHuge(page))) {
> +		pmd_t *pmd;
> +
> +		spin_lock(&mm->page_table_lock);
> +		pmd = page_check_address_pmd(page, mm, address,
> +					     PAGE_CHECK_ADDRESS_PMD_FLAG);
> +		if (pmd && !pmd_trans_splitting(*pmd) &&
> +		    pmdp_clear_flush_young_notify(vma, address, pmd))
> +			referenced++;
> +		spin_unlock(&mm->page_table_lock);
> +	} else {
> +		pte_t *pte;
> +		spinlock_t *ptl;
> +
> +		pte = page_check_address(page, mm, address, &ptl, 0);
> +		if (!pte)
> +			goto out;
> +
> +		if (ptep_clear_flush_young_notify(vma, address, pte)) {
> +			/*
> +			 * Don't treat a reference through a sequentially read
> +			 * mapping as such.  If the page has been used in
> +			 * another mapping, we will catch it; if this other
> +			 * mapping is already gone, the unmap path will have
> +			 * set PG_referenced or activated the page.
> +			 */
> +			if (likely(!VM_SequentialReadHint(vma)))
> +				referenced++;
> +		}
> +		pte_unmap_unlock(pte, ptl);
> +	}
> +
>  	(*mapcount)--;
> -	pte_unmap_unlock(pte, ptl);
>  
>  	if (referenced)
>  		*vm_flags |= vma->vm_flags;
> diff --git a/mm/swap.c b/mm/swap.c
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -465,6 +465,43 @@ void __pagevec_release(struct pagevec *p
>  
>  EXPORT_SYMBOL(__pagevec_release);
>  
> +/* used by __split_huge_page_refcount() */
> +void lru_add_page_tail(struct zone* zone,
> +		       struct page *page, struct page *page_tail)
> +{
> +	int active;
> +	enum lru_list lru;
> +	const int file = 0;
> +	struct list_head *head;
> +
> +	VM_BUG_ON(!PageHead(page));
> +	VM_BUG_ON(PageCompound(page_tail));
> +	VM_BUG_ON(PageLRU(page_tail));
> +	VM_BUG_ON(!spin_is_locked(&zone->lru_lock));
> +
> +	SetPageLRU(page_tail);
> +
> +	if (page_evictable(page_tail, NULL)) {
> +		if (PageActive(page)) {
> +			SetPageActive(page_tail);
> +			active = 1;
> +			lru = LRU_ACTIVE_ANON;
> +		} else {
> +			active = 0;
> +			lru = LRU_INACTIVE_ANON;
> +		}
> +		update_page_reclaim_stat(zone, page_tail, file, active);
> +		if (likely(PageLRU(page)))
> +			head = page->lru.prev;
> +		else
> +			head = &zone->lru[lru].list;
> +		__add_page_to_lru_list(zone, page_tail, lru, head);
> +	} else {
> +		SetPageUnevictable(page_tail);
> +		add_page_to_lru_list(zone, page_tail, LRU_UNEVICTABLE);
> +	}
> +}
> +
>  /*
>   * Add the passed pages to the LRU, then drop the caller's refcount
>   * on them.  Reinitialises the caller's pagevec.
> 

Other than a few minor questions, these seems very similar to what you
had before. There is a lot going on in this patch but I did not find
anything wrong.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
