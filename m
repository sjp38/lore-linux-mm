Date: Tue, 29 Apr 2008 13:36:41 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc] data race in page table setup/walking?
In-Reply-To: <20080429050054.GC21795@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0804291333540.22025@blonde.site>
References: <20080429050054.GC21795@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Apr 2008, Nick Piggin wrote:
> I *think* there is a possible data race in the page table walking code. After
> the split ptlock patches, it actually seems to have been introduced to the core
> code, but even before that I think it would have impacted some architectures.
> 
> The race is as follows:
> The pte page is allocated, zeroed, and its struct page gets its spinlock
> initialized. The mm-wide ptl is then taken, and then the pte page is inserted
> into the pagetables.
> 
> At this point, the spinlock is not guaranteed to have ordered the previous
> stores to initialize the pte page with the subsequent store to put it in the
> page tables. So another Linux page table walker might be walking down (without
> any locks, because we have split-leaf-ptls), and find that new pte we've
> inserted. It might try to take the spinlock before the store from the other
> CPU initializes it. And subsequently it might read a pte_t out before stores
> from the other CPU have cleared the memory.
> 
> There seem to be similar races in higher levels of the page tables, but they
> obviously don't involve the spinlock, but one could see uninitialized memory.

It's sad, but I have to believe you're right.  I'm slightly more barrier-
aware now than I was back when doing split ptlock (largely thanks to your
persistence); and looking back at it, I cannot now imagine how it could
be correct to remove a lock from that walkdown without adding barriers.

Ugh.  It's just so irritating to introduce these blockages against
such a remote possibility (but there again, that's what so much of
kernel code has to be about).  Is there any other way of handling it?

> 
> Arch code and hardware pagetable walkers that walk the pagetables without
> locks could see similar uninitialized memory problems (regardless of whether
> we have split ptes or not).

The hardware walkers, hmm.  Well, I guess each arch has its own rules
to protect against those, and all you can do is provide a macro for
each to fill in.   You assume smp_read_barrier_depends versus smp_wmb
below: sure of those, or is it worth providing particular new stubs?

> 
> Fortunately, on x86 (except stupid OOSTORE), nothing needs to be done, because
> stores are in order, and so are loads. Even on OOSTORE we wouldn't have to take
> the smp_wmb hit, if only we have a smp_wmb_before/after_spin_lock function.
> 
> This isn't a complete patch yet, but a demonstration of the problem, and an
> RFC really as to the form of the solution. I prefer to put the barriers in
> core code, because that's where the higher level logic happens, but the page
> table accessors are per-arch, and open-coding them everywhere I don't think
> is an option.

If there's no better way (I think not), this looks about right to me;
though I leave all the hard thought to you ;)

While I'm in the confessional, something else you probably need to
worry about there: handle_pte_fault's "entry = *pte" without holding
the lock; several cases are self-righting, but there's pte_unmap_same
for a couple of cases where we need to make sure of the right decision
- presently it's only worrying about the PAE case, when it might have
got the top of one pte with the bottom of another, but now you need
some barrier thinking?  Oh, perhaps this is already safely covered
by your pte_offset_map.

The pte_offset_kernel one (aside from the trivial of needing a ret):
I'm not convinced that needs to be changed at all.  I still believe,
as I believed at split ptlock time, that the kernel walkdowns need
no locking (or barriers) of their own: that it's a separate kernel
bug if a kernel subsystem is making speculative accesses to addresses
it cannot be sure have been allocated.  Counter-examples?

Ah, but perhaps naughty userspace (depending on architecture) could
make those speculative accesses into kernel address space, and have
a chance of striking lucky with the hardware walker, without proper
barriers at the kernel end?

> 
> So anyway... comments, please? Am I dreaming the whole thing up? I suspect
> that if I'm not, then powerpc at least might have been impacted by the race,
> but as far as I know of, they haven't seen stability problems around there...
> Might just be terribly rare, though. I'd like to try to make a test program
> to reproduce the problem if I can get access to a box...

Please do, if you're feeling ingenious: it's tiresome adding overhead
without being able to show it's really achieved something.

> 
> Thanks,
> Nick
> 
> Index: linux-2.6/include/asm-x86/pgtable_32.h
> ===================================================================
> --- linux-2.6.orig/include/asm-x86/pgtable_32.h
> +++ linux-2.6/include/asm-x86/pgtable_32.h
> @@ -179,7 +179,10 @@ static inline int pud_large(pud_t pud) {
>  #define pte_index(address)					\
>  	(((address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
>  #define pte_offset_kernel(dir, address)				\
> -	((pte_t *)pmd_page_vaddr(*(dir)) +  pte_index((address)))
> +{(								\
> +	(pte_t *)pmd_page_vaddr(*(dir)) +  pte_index((address));\
> +	smp_read_barrier_depends();				\
> +})
>  
>  #define pmd_page(pmd) (pfn_to_page(pmd_val((pmd)) >> PAGE_SHIFT))
>  
> @@ -188,16 +191,32 @@ static inline int pud_large(pud_t pud) {
>  
>  #if defined(CONFIG_HIGHPTE)
>  #define pte_offset_map(dir, address)					\
> -	((pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE0) +		\
> -	 pte_index((address)))
> +{(									\
> +	pte_t *ret = (pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE0) + \
> +		 pte_index((address));					\
> +	smp_read_barrier_depends();					\
> +	ret;								\
> +)}
> +
>  #define pte_offset_map_nested(dir, address)				\
> -	((pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE1) +		\
> -	 pte_index((address)))
> +{(									\
> +	pte_t *ret = (pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE1) + \
> +		 pte_index((address));					\
> +	smp_read_barrier_depends();					\
> +	ret;								\
> +)}
> +
>  #define pte_unmap(pte) kunmap_atomic((pte), KM_PTE0)
>  #define pte_unmap_nested(pte) kunmap_atomic((pte), KM_PTE1)
>  #else
>  #define pte_offset_map(dir, address)					\
> -	((pte_t *)page_address(pmd_page(*(dir))) + pte_index((address)))
> +{(									\
> +	pte_t *ret = (pte_t *)page_address(pmd_page(*(dir))) +		\
> +		pte_index((address));					\
> +	smp_read_barrier_depends();					\
> +	ret;								\
> +)}
> +
>  #define pte_offset_map_nested(dir, address) pte_offset_map((dir), (address))
>  #define pte_unmap(pte) do { } while (0)
>  #define pte_unmap_nested(pte) do { } while (0)
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -311,6 +311,13 @@ int __pte_alloc(struct mm_struct *mm, pm
>  	if (!new)
>  		return -ENOMEM;
>  
> +	/*
> +	 * Ensure all pte setup (eg. pte page lock and page clearing) are
> +	 * visible before the pte is made visible to other CPUs by being
> +	 * put into page tables.
> +	 */
> +	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */
> +
>  	spin_lock(&mm->page_table_lock);
>  	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
>  		mm->nr_ptes++;
> @@ -329,6 +336,8 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
>  	if (!new)
>  		return -ENOMEM;
>  
> +	smp_wmb(); /* See comment in __pte_alloc */
> +
>  	spin_lock(&init_mm.page_table_lock);
>  	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
>  		pmd_populate_kernel(&init_mm, pmd, new);
> @@ -2546,6 +2555,8 @@ int __pud_alloc(struct mm_struct *mm, pg
>  	if (!new)
>  		return -ENOMEM;
>  
> +	smp_wmb(); /* See comment in __pte_alloc */
> +
>  	spin_lock(&mm->page_table_lock);
>  	if (pgd_present(*pgd))		/* Another has populated it */
>  		pud_free(mm, new);
> @@ -2567,6 +2578,8 @@ int __pmd_alloc(struct mm_struct *mm, pu
>  	if (!new)
>  		return -ENOMEM;
>  
> +	smp_wmb(); /* See comment in __pte_alloc */
> +
>  	spin_lock(&mm->page_table_lock);
>  #ifndef __ARCH_HAS_4LEVEL_HACK
>  	if (pud_present(*pud))		/* Another has populated it */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
