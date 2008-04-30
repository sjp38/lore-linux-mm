Message-ID: <4818B262.5020909@goop.org>
Date: Wed, 30 Apr 2008 10:54:42 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC/PATH 1/2] MM: Make Page Tables Relocatable -- conditional
 flush
References: <20080429134254.635FEDC683@localhost>
In-Reply-To: <20080429134254.635FEDC683@localhost>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ross,

> These Patches make page tables relocatable for numa, memory
> defragmentation, and memory hotblug.  The potential need to rewalk the
> page tables before making any changes causes a 1.6% peformance
> degredation in the lmbench page miss micro benchmark.

So you mean the check to see if there's a migration currently in
progress?  Surely that's a single test+branch?

> 
> Page table relocation is critical for several projects.
> 
> 1) Numa system process relcoation.  Currently, when a process is migrated
> from one node to another the page tables are left behind.  This means 
> increased latency and inter-node traffic on all page faults.  Migrating the
> page tables with the process will be a performance win.

I would have thought cross-node TLB misses would be a bigger factor.

> 2) Memory hotplug.  Currently memory hotplug cannot move page tables out of
> the memory that is about to be removed.  This code is a first step to 
> being able to move page tables out of memory that is going to be unplugged.
> 
> 3) Memory defragmentation. Currently page tables are the largest chunk
> of non-moveable memory (needs verification).  By making page tables
> relocatable, we can decrease the number of memory fragments and allow for
> higher order allocations.  This is important for supporting huge pages 
> that can greatly improve performance in some circumstances.
 
I've read through this patch a couple of times so far, but I still
don't quite get it.  The "why" rationale is good, but it would be nice
to have a high-level "how" paragraph which explains the overall
principle of operation.  (OK, I think I see how all this fits
together now.)

>From looking at it, a few points to note:

- It only tries to move usermode pagetables.  For the most part (at
  least on x86) the kernel pagetables are fairly static (and
  effectively statically allocated), but vmalloc does allocate new
  kernel pagetable memory.
  
  As a consequence, it doesn't need to worry about tlb-flushing global
  pages or unlocked updates to init_mm.

- It would be nice to explain the "delimbo" terminology.  I got it in
  the end, but it took me a while to work out what you meant.

Open questions in my mind:

- How does it deal with migrating the accessed/dirty bits in ptes if
  cpus can be using old versions of the pte for a while after the
  copy?  Losing dirty updates can lose data, so explicitly addressing
  this point in code and/or comments is important.

- Is this deeply incompatible with shared ptes?

- It assumes that each pagetable level is a page in size.  This isn't
  even true on x86 (32-bit PAE pgds are not), and definitely not true
  on other architectures.  It would make sense to skip migrating
  non-page-sized pagetable levels, but the code could/should check for
  it.

- Does it work on 2 and 3-level pagetable systems?  Ideally the clever
  folding stuff would make it all fall out naturally, but somehow that
  never seems to end up working.

- Could you use the existing tlb batching machinery rather than
  MMF_NEED_FLUSH?  They seem to overlap somewhat.

- What architectures does this support?  You change a lot of arch
  files, but it looks to me like you've only implemented this for
  x86-64.  Is that right?  A lot of this patch won't apply to x86 at
  the moment because of the pagetable unifications I've been doing.
  Will you be able to adapt it to the unified pagetable code?  Will it
  support all x86 variants in the process?

- How much have you tested it?

> Currently the high level memory relocation code only supports 1 above.
> The low level routines can be used to migrate any page table to any
> new page.  However, 1 seems to be the best case for correctness
> testing and is also the easiest place to hook into existing code, so
> that is what is currently supported.
>
> The low level page table relocation routines are generic and will be easy
> to use for 2 and 3.

> 
> Signed-off-by:rossb@google.com
> 
> -----
> 
> Major changes from the previous version include more comments and
> replacing the semaphore that serialized access to the relocation code
> with an integer count of the number of times it has been reentered.  The
> later lead to an improvement from a 3% performace loss to a 1.6% perfromance
> loss vs no relocation code (There was also a version change from 2.6.23 to
> 2.6.25-rc9 since the last benchmark, so some of the performance difference
> may be related to other changes.)
> 
> Please discuss the code and approach to handling unstable page tables.
> 


> --- /home/rossb/local/linux-2.6.25-rc9/arch/x86/kernel/smp_32.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/arch/x86/kernel/smp_32.c	2008-04-14 09:00:18.000000000 -0700
> @@ -332,6 +332,8 @@ void smp_invalidate_interrupt(struct pt_
>  		if (per_cpu(cpu_tlbstate, cpu).state == TLBSTATE_OK) {
>  			if (flush_va == TLB_FLUSH_ALL)
>  				local_flush_tlb();
> +			else if (f->flush_va == TLB_RELOAD_ALL)
> +				local_reload_tlb_mm(f->flush_mm);
>  			else
>  				__flush_tlb_one(flush_va);
>  		} else
> @@ -408,10 +410,35 @@ void flush_tlb_current_task(void)
>  	preempt_enable();
>  }
>  
> +void reload_tlb_mm(struct mm_struct *mm)
> +{
> +	cpumask_t cpu_mask;
> +
> +	clear_bit(MMF_NEED_RELOAD, &mm->flags);
> +	clear_bit(MMF_NEED_FLUSH, &mm->flags);
> +
> +	preempt_disable();
> +	cpu_mask = mm->cpu_vm_mask;
> +	cpu_clear(smp_processor_id(), cpu_mask);
> +
> +	if (current->active_mm == mm) {
> +		if (current->mm)
> +			local_reload_tlb_mm(mm);
> +		else
> +			leave_mm(smp_processor_id());
> +	}
> +	if (!cpus_empty(cpu_mask))
> +		flush_tlb_others(cpu_mask, mm, TLB_RELOAD_ALL);
> +
> +	preempt_enable();
> +
> +}
> +
>  void flush_tlb_mm (struct mm_struct * mm)
>  {
>  	cpumask_t cpu_mask;
>  
> +	clear_bit(MMF_NEED_FLUSH, mm->flags);
>  	preempt_disable();
>  	cpu_mask = mm->cpu_vm_mask;
>  	cpu_clear(smp_processor_id(), cpu_mask);
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/x86/kernel/smp_64.c 2.6.25-rc9/arch/x86/kernel/smp_64.c
> --- /home/rossb/local/linux-2.6.25-rc9/arch/x86/kernel/smp_64.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/arch/x86/kernel/smp_64.c	2008-04-14 09:00:18.000000000 -0700
> @@ -155,6 +155,8 @@ asmlinkage void smp_invalidate_interrupt
>  		if (read_pda(mmu_state) == TLBSTATE_OK) {
>  			if (f->flush_va == TLB_FLUSH_ALL)
>  				local_flush_tlb();
> +			else if (f->flush_va == TLB_RELOAD_ALL)
> +				local_reload_tlb_mm(f->flush_mm);
>  			else
>  				__flush_tlb_one(f->flush_va);
>  		} else
> @@ -228,10 +230,36 @@ void flush_tlb_current_task(void)
>  	preempt_enable();
>  }
>  
> +void reload_tlb_mm(struct mm_struct *mm)
> +{
> +	cpumask_t cpu_mask;
> +
> +	clear_bit(MMF_NEED_RELOAD, &mm->flags);
> +	clear_bit(MMF_NEED_FLUSH, &mm->flags);
> +
> +	preempt_disable();
> +	cpu_mask = mm->cpu_vm_mask;
> +	cpu_clear(smp_processor_id(), cpu_mask);
> +
> +	if (current->active_mm == mm) {
> +		if (current->mm)
> +			local_reload_tlb_mm(mm);
> +		else
> +			leave_mm(smp_processor_id());
> +	}
> +	if (!cpus_empty(cpu_mask))
> +		flush_tlb_others(cpu_mask, mm, TLB_RELOAD_ALL);
> +
> +	preempt_enable();
> +
> +}

This is actually identical for 32 and 64 bit?  Good candidate for unification.





> --- /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/tlbflush.h	1969-12-31 16:00:00.000000000 -0800
> +++ 2.6.25-rc9/include/asm-generic/tlbflush.h	2008-04-14 09:00:18.000000000 -0700
> @@ -0,0 +1,102 @@
> +/* include/asm-generic/tlbflush.h
> + *
> + *	Generic TLB reload code and page table migration code that
> + *      depends on it.
> + *
> + * Copyright 2008 Google, Inc.
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License as
> + * published by the Free Software Foundation; version 2 of the
> + * License.
> + */
> +
> +#ifndef _ASM_GENERIC__TLBFLUSH_H
> +#define _ASM_GENERIC__TLBFLUSH_H
> +
> +#include <asm/pgalloc.h>
> +#include <asm/mmu_context.h>
> +
> +/* flush an mm that we messed with earlier, but delayed the flush
> +   assuming that we would muck with it a whole lot more. */
> +static inline void maybe_flush_tlb_mm(struct mm_struct *mm)
> +{
> +	if (test_and_clear_bit(MMF_NEED_FLUSH, &mm->flags))
> +		flush_tlb_mm(mm);
> +}
> +
> +/* possibly flag an mm as needing to be flushed. */
> +static inline int maybe_need_flush_mm(struct mm_struct *mm)
> +{
> +	if (!cpus_empty(mm->cpu_vm_mask)) {
> +		set_bit(MMF_NEED_FLUSH, &mm->flags);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +
> +
> +#ifdef ARCH_HAS_RELOAD_TLB
> +static inline void maybe_reload_tlb_mm(struct mm_struct *mm)
> +{
> +	if (test_and_clear_bit(MMF_NEED_RELOAD, &mm->flags))
> +		reload_tlb_mm(mm);
> +	else
> +		maybe_flush_tlb_mm(mm);
> +}
> +
> +static inline int maybe_need_tlb_reload_mm(struct mm_struct *mm)
> +{
> +	if (!cpus_empty(mm->cpu_vm_mask)) {
> +		set_bit(MMF_NEED_RELOAD, &mm->flags);
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static inline int migrate_top_level_page_table(struct mm_struct *mm,
> +					       struct page *dest,
> +					       struct list_head *old_pages)

Seems a bit large to be static inline in a header.  Why not just put
it in mm/migrate.c?


> +{
> +	unsigned long flags;
> +	void *dest_ptr;
> +
> +	dest_ptr = page_address(dest);
> +
> +	spin_lock_irqsave(&mm->page_table_lock, flags);
> +	memcpy(dest_ptr, mm->pgd, PAGE_SIZE);


A pgd isn't necessarily a page size.  x86-32 PAE its only 64 bytes,
though it happens to allocate a whole page for it at the moment.  I'm
pretty sure other architectures have non-page-sized pgds as well, so
you can't make this assumption in asm-generic/*.


> +
> +	/* Must be done before adding the list to the page to be
> +	 * freed. Should we take the pgd_lock through this entire
> +	 * mess, or is it ok for the pgd to be missing from the list
> +	 * for a bit?
> +	 */
> +	pgd_list_del(mm->pgd);

The pgd_list is an x86-specific notion.  And at the moment
pgd_list_add/del aren't even visible outside arch/x86/mm/pgtable.c.

> +
> +	list_add_tail(&virt_to_page(mm->pgd)->lru, old_pages);

Again, you can't rely on pgd being a page size, so you can't use
page->lru to chain it onto this list.

> +
> +	mm->pgd = (pgd_t *)dest_ptr;
> +
> +	maybe_need_tlb_reload_mm(mm);
> +
> +	spin_unlock_irqrestore(&mm->page_table_lock, flags);
> +	return 0;
> +}

Unfortunately this won't work well in x86-paravirt_ops; specifically,
under Xen it just plain won't work, and on other virtualization
systems it may just be inefficient.

The problem is that pages which are part of a pagetable must be
treated specially because the hypervisor needs to maintain a guest to
host page mapping, so pagetable entries need to be translated in some
way.  This is managed with a series of hooks to let the hypervisor
have (and change) the information it needs.

Normally this is dealt with in activate_mm and arch_exit_mmap.  These
operate on whole mm-s because its assumed that the lifetime of a pgd
is the same as the lifetime of its mm.  I guess we'd need new hooks to
manage the lifetime of pgds explicitly.  (Hm, though if you switch to
init_mm, update mm->pgd, and then re-activate it, that may just work.)

On the other hand, I've got plans to change the way Xen manages pgds
which would alleviate this problem and allow this code to work as-is,
but it would still require careful handling of the other pagetable
levels (update, which look mostly ok already).

> --- /home/rossb/local/linux-2.6.25-rc9/include/linux/sched.h	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/include/linux/sched.h	2008-04-14 09:00:18.000000000 -0700
> @@ -408,6 +408,16 @@ extern int get_dumpable(struct mm_struct
>  #define MMF_DUMP_FILTER_DEFAULT \
>  	((1 << MMF_DUMP_ANON_PRIVATE) |	(1 << MMF_DUMP_ANON_SHARED))
>  
> +/* Misc MM flags. */
> +#define MMF_NEED_FLUSH		7
> +#define MMF_NEED_RELOAD		8	/* Only meaningful on some archs. */
> +
> +#ifdef CONFIG_RELOCATE_PAGE_TABLES
> +#define MMF_NEED_REWALK		9	/* Must rewalk page tables with spin
> +					 * lock held. */

Does this get used anywhere?

> +#endif /*  CONFIG_RELOCATE_PAGE_TABLES  */
> +
> +
>  struct sighand_struct {
>  	atomic_t		count;
>  	struct k_sigaction	action[_NSIG];



> Subject: [RFC/PATH 2/2] MM: Make Page Tables Relocatable -- relocation code.
> 
> -----
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/powerpc/mm/fault.c 2.6.25-rc9/arch/powerpc/mm/fault.c
> --- /home/rossb/local/linux-2.6.25-rc9/arch/powerpc/mm/fault.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/arch/powerpc/mm/fault.c	2008-04-14 09:00:29.000000000 -0700
> @@ -299,6 +299,8 @@ good_area:
>  		if (get_pteptr(mm, address, &ptep, &pmdp)) {
>  			spinlock_t *ptl = pte_lockptr(mm, pmdp);
>  			spin_lock(ptl);
> +			delimbo_pte(&ptep, &ptl, &pmdp, mm, address);
> +
>  			if (pte_present(*ptep)) {
>  				struct page *page = pte_page(*ptep);
>  
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/powerpc/mm/hugetlbpage.c 2.6.25-rc9/arch/powerpc/mm/hugetlbpage.c
> --- /home/rossb/local/linux-2.6.25-rc9/arch/powerpc/mm/hugetlbpage.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/arch/powerpc/mm/hugetlbpage.c	2008-04-14 09:00:29.000000000 -0700
> @@ -73,6 +73,7 @@ static int __hugepte_alloc(struct mm_str
>  		return -ENOMEM;
>  
>  	spin_lock(&mm->page_table_lock);
> +	delimbo_hpd(&hpdp, mm, address);
>  	if (!hugepd_none(*hpdp))
>  		kmem_cache_free(huge_pgtable_cache, new);
>  	else
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/ppc/mm/fault.c 2.6.25-rc9/arch/ppc/mm/fault.c
> --- /home/rossb/local/linux-2.6.25-rc9/arch/ppc/mm/fault.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/arch/ppc/mm/fault.c	2008-04-14 09:00:29.000000000 -0700
> @@ -219,6 +219,7 @@ good_area:
>  		if (get_pteptr(mm, address, &ptep, &pmdp)) {
>  			spinlock_t *ptl = pte_lockptr(mm, pmdp);
>  			spin_lock(ptl);
> +			delimbo_pte(&ptep, &ptl, &pmdp, mm, address);
>  			if (pte_present(*ptep)) {
>  				struct page *page = pte_page(*ptep);
>  
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/arch/x86/mm/hugetlbpage.c 2.6.25-rc9/arch/x86/mm/hugetlbpage.c
> --- /home/rossb/local/linux-2.6.25-rc9/arch/x86/mm/hugetlbpage.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/arch/x86/mm/hugetlbpage.c	2008-04-14 09:00:29.000000000 -0700
> @@ -88,6 +88,7 @@ static void huge_pmd_share(struct mm_str
>  		goto out;
>  
>  	spin_lock(&mm->page_table_lock);
> +	delimbo_pud(&pud, mm, addr);
>  	if (pud_none(*pud))
>  		pud_populate(mm, pud, (pmd_t *)((unsigned long)spte & PAGE_MASK));
>  	else
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgalloc.h 2.6.25-rc9/include/asm-generic/pgalloc.h
> --- /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgalloc.h	1969-12-31 16:00:00.000000000 -0800
> +++ 2.6.25-rc9/include/asm-generic/pgalloc.h	2008-04-14 09:00:29.000000000 -0700
> @@ -0,0 +1,37 @@
> +#ifndef _ASM_GENERIC_PGALLOC_H
> +#define _ASM_GENERIC_PGALLOC_H
> +
> +
> +
> +/* Page Table Levels used for alloc_page_table. */
> +#define PAGE_TABLE_PGD 0
> +#define PAGE_TABLE_PUD 1
> +#define PAGE_TABLE_PMD 2
> +#define PAGE_TABLE_PTE 3

enum?


> +
> +static inline struct page *alloc_page_table_node(struct mm_struct *mm,
> +						 unsigned long addr,
> +						 int node,
> +						 int page_table_level)
> +{
> +	switch (page_table_level) {
> +	case PAGE_TABLE_PGD:
> +		return virt_to_page(pgd_alloc_node(mm, node));
> +
> +	case PAGE_TABLE_PUD:
> +		return virt_to_page(pud_alloc_one_node(mm, addr, node));
> +
> +	case PAGE_TABLE_PMD:
> +		return virt_to_page(pmd_alloc_one_node(mm, addr, node));
> +
> +	case PAGE_TABLE_PTE:
> +		return pte_alloc_one_node(mm, addr, node);
> +
> +	default:
> +		BUG();
> +		return NULL;
> +	}
> +}
> +
> +
> +#endif /* _ASM_GENERIC_PGALLOC_H */
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgtable.h 2.6.25-rc9/include/asm-generic/pgtable.h
> --- /home/rossb/local/linux-2.6.25-rc9/include/asm-generic/pgtable.h	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/include/asm-generic/pgtable.h	2008-04-15 07:27:10.000000000 -0700
> @@ -4,6 +4,8 @@
>  #ifndef __ASSEMBLY__
>  #ifdef CONFIG_MMU
>  
> +#include <linux/sched.h>
> +
>  #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
>  /*
>   * Largely same as above, but only sets the access flags (dirty,
> @@ -195,6 +197,54 @@ static inline int pmd_none_or_clear_bad(
>  	}
>  	return 0;
>  }
> +
> +
> +/* Used to rewalk the page tables if after we grab the appropriate lock,
> + * we make sure we are not looking at a page table that's just waiting
> + * to go away.
> + * These are only used in the _delimbo* functions in mm/migrate.c
> + * so it's no big deal having them static inline.  Otherwise, they
> + * would just be in there anyway.
> + * XXXXX Why not just copy this into mm/migrate.c?
> + */
> +static inline pgd_t *walk_page_table_pgd(struct mm_struct *mm,
> +					  unsigned long addr)
> +{
> +	return pgd_offset(mm, addr);
> +}
> +
> +static inline pud_t *walk_page_table_pud(struct mm_struct *mm,
> +					 unsigned long addr) {
> +	pgd_t *pgd;
> +	pgd = walk_page_table_pgd(mm, addr);
> +	BUG_ON(!pgd);
> +	return pud_offset(pgd, addr);
> +}
> +
> +static inline pmd_t *walk_page_table_pmd(struct mm_struct *mm,
> +					 unsigned long addr)
> +{
> +	pud_t *pud;
> +	pud = walk_page_table_pud(mm, addr);
> +	BUG_ON(!pud);
> +	return  pmd_offset(pud, addr);
> +}
> +
> +static inline pte_t *walk_page_table_pte(struct mm_struct *mm,
> +					 unsigned long addr)
> +{
> +	pmd_t *pmd;
> +	pmd = walk_page_table_pmd(mm, addr);
> +	BUG_ON(!pmd);
> +	return pte_offset_map(pmd, addr);
> +}
> +
> +static inline pte_t *walk_page_table_huge_pte(struct mm_struct *mm,
> +					      unsigned long addr)
> +{
> +	return (pte_t *)walk_page_table_pmd(mm, addr);
> +}

Hm, another pagetable walker.  Sure this one is necessary?  Or does it
replace one of the others?  Is it guaranteed to work on 2, 3 and 4
level pagetables?

> +
>  #endif /* CONFIG_MMU */
>  
>  /*
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/pgalloc_64.h 2.6.25-rc9/include/asm-x86/pgalloc_64.h
> --- /home/rossb/local/linux-2.6.25-rc9/include/asm-x86/pgalloc_64.h	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/include/asm-x86/pgalloc_64.h	2008-04-14 09:00:29.000000000 -0700

Unified now.

> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/linux/migrate.h 2.6.25-rc9/include/linux/migrate.h
> --- /home/rossb/local/linux-2.6.25-rc9/include/linux/migrate.h	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/include/linux/migrate.h	2008-04-14 09:00:29.000000000 -0700
> @@ -6,6 +6,10 @@
>  #include <linux/pagemap.h>
>  
>  typedef struct page *new_page_t(struct page *, unsigned long private, int **);
> +typedef struct page *new_page_table_t(struct mm_struct *,
> +				      unsigned long addr,
> +				      unsigned long private,
> +				      int **, int page_table_level);
>  
>  #ifdef CONFIG_MIGRATION
>  /* Check if a vma is migratable */
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/include/linux/mm.h 2.6.25-rc9/include/linux/mm.h
> --- /home/rossb/local/linux-2.6.25-rc9/include/linux/mm.h	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/include/linux/mm.h	2008-04-15 11:35:05.000000000 -0700
> @@ -12,6 +12,7 @@
>  #include <linux/prio_tree.h>
>  #include <linux/debug_locks.h>
>  #include <linux/mm_types.h>
> +#include <asm/pgtable.h>

Needed?

>  
>  struct mempolicy;
>  struct anon_vma;
> @@ -921,6 +922,7 @@ static inline void pgtable_page_dtor(str
>  	pte_t *__pte = pte_offset_map(pmd, address);	\
>  	*(ptlp) = __ptl;				\
>  	spin_lock(__ptl);				\
> +	delimbo_pte(&__pte, ptlp, &pmd, mm, address);	\
>  	__pte;						\
>  })
>  
> @@ -945,6 +947,116 @@ extern void free_area_init(unsigned long
>  extern void free_area_init_node(int nid, pg_data_t *pgdat,
>  	unsigned long * zones_size, unsigned long zone_start_pfn, 
>  	unsigned long *zholes_size);
> +
> +#ifdef CONFIG_RELOCATE_PAGE_TABLES
> +
> +void _delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
> +		  struct mm_struct *mm,  unsigned long addr);
> +void _delimbo_pte_nested(pte_t **pte, spinlock_t **ptl,
> +			 pmd_t **pmd, struct mm_struct *mm,
> +			 unsigned long addr, int subclass, spinlock_t *optl);
> +void _delimbo_pud(pud_t **pud, struct mm_struct *mm, unsigned long addr);
> +void _delimbo_pmd(pmd_t **pmd, struct mm_struct *mm, unsigned long addr);
> +void _delimbo_pgd(pgd_t **pgd, struct mm_struct *mm, unsigned long addr);
> +void _delimbo_huge_pte(pte_t **pte, struct mm_struct *mm, unsigned long addr);
> +
> +
> +static inline void delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
> +			  struct mm_struct *mm,
> +			  unsigned long addr)
> +{
> +	/* We don't actually have the correct spinlock here, but it's
> +	 * ok since the relocation code won't go mucking with the
> +	 * relevant level of the page table while holding the relevant
> +	 * spinlock.  This means that while all the page tables
> +	 * leading up to this one could get mucked with, the one we
> +	 * care about cannot be mucked with without us seeing that
> +	 * page_table_relocation_count has be set.
> +	 * 
> +	 * The code path is something like
> +	 * grab page table lock
> +	 * increment relocation count
> +	 * release page_table lock
> +	 *
> +	 * At this point, we might have missed the increment
> +	 * because we have the wrong lock. 
> +	 *
> +	 * Grab page table lock.
> +	 * Grab split page table lock. <-- This lock saves us.
> +	 * muck with page table.
> +	 *
> +	 * But it's ok, because even if we get interrupted after for a
> +	 * long time, the page table we care about won't be mucked
> +	 * with until after we drop the spinlock that we do have.
> +	 */
> +	if (unlikely(mm->page_table_relocation_count))
> +		_delimbo_pte(pte, ptl, pmd, mm, addr);
> +}
> +
> +static inline void delimbo_pte_nested(pte_t **pte, spinlock_t **ptl,
> +				      pmd_t **pmd, struct mm_struct *mm,
> +				      unsigned long addr, int subclass,
> +				      spinlock_t *optl)
> +{
> +	/* same as comment above about the locking issue with
> +	 * this test.
> +	 */
> +	if (unlikely(mm->page_table_relocation_count))
> +		_delimbo_pte_nested(pte, ptl, pmd, mm, addr, subclass, optl);
> +}
> +
> +
> +static inline void delimbo_pud(pud_t **pud,  struct mm_struct *mm,
> +			  unsigned long addr)
> +{
> +	/* At this point we have the page_table_lock. */
> +	if (unlikely(mm->page_table_relocation_count))
> +		_delimbo_pud(pud, mm, addr);
> +}
> +
> +static inline void delimbo_pmd(pmd_t **pmd,  struct mm_struct *mm,
> +			       unsigned long addr)
> +{
> +
> +	/* we hold the page_table_lock, so this is safe to test. */
> +	if (unlikely(mm->page_table_relocation_count))
> +		_delimbo_pmd(pmd, mm, addr);
> +}
> +
> +static inline void delimbo_pgd(pgd_t **pgd,  struct mm_struct *mm,
> +			       unsigned long addr)
> +{
> +	/* we hold the page_table_lock. */
> +	if (unlikely(mm->page_table_relocation_count))
> +		_delimbo_pgd(pgd, mm, addr);
> +}
> +
> +
> +static inline void delimbo_huge_pte(pte_t **pte,  struct mm_struct *mm,
> +				    unsigned long addr)
> +{
> +	/* We hold the page_table_lock. */
> +	if (unlikely(mm->page_table_relocation_count))
> +		_delimbo_huge_pte(pte, mm, addr);
> +}
> +
> +#else /* CONFIG_RELOCATE_PAGE_TABLES */
> +static inline void delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
> +			       struct mm_struct *mm,  unsigned long addr) {}
> +static inline void delimbo_pte_nested(pte_t **pte, spinlock_t **ptl,
> +				      pmd_t **pmd, struct mm_struct *mm,
> +				      unsigned long addr, int subclass,
> +				      spinlock_t *optl) {}
> +static inline void delimbo_pud(pud_t **pud,  struct mm_struct *mm,
> +			       unsigned long addr) {}
> +static inline void delimbo_pmd(pmd_t **pmd, struct mm_struct *mm,
> +			       unsigned long addr) {}
> +static inline void delimbo_pgd(pgd_t **pgd, struct mm_struct *mm,
> +			       unsigned long addr) {}
> +static inline void delimbo_huge_pte(pte_t **pte, struct mm_struct *mm,
> +				    unsigned long addr) {}
> +#endif /* CONFIG_RELOCATE_PAGE_TABLES */
> +
>  #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
>  /*
>   * With CONFIG_ARCH_POPULATES_NODE_MAP set, an architecture may initialise its
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/kernel/fork.c 2.6.25-rc9/kernel/fork.c
> --- /home/rossb/local/linux-2.6.25-rc9/kernel/fork.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/kernel/fork.c	2008-04-15 05:51:53.000000000 -0700
> @@ -360,6 +360,10 @@ static struct mm_struct * mm_init(struct
>  	mm->cached_hole_size = ~0UL;
>  	mm_init_cgroup(mm, p);
>  
> +#ifdef CONFIG_RELOCATE_PAGE_TABLES
> +	mm->page_table_relocation_count = 0;
> +#endif
> +
>  	if (likely(!mm_alloc_pgd(mm))) {
>  		mm->def_flags = 0;
>  		return mm;
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/Kconfig 2.6.25-rc9/mm/Kconfig
> --- /home/rossb/local/linux-2.6.25-rc9/mm/Kconfig	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/mm/Kconfig	2008-04-14 09:00:29.000000000 -0700
> @@ -143,6 +143,10 @@ config MEMORY_HOTREMOVE
>  	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>  	depends on MIGRATION
>  
> +config RELOCATE_PAGE_TABLES 
> +	def_bool y
> +	depends on X86_64 && MIGRATION
> +
>  # Heavily threaded applications may benefit from splitting the mm-wide
>  # page_table_lock, so that faults on different parts of the user address
>  # space can be handled with less contention: split it at this NR_CPUS.
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/hugetlb.c 2.6.25-rc9/mm/hugetlb.c
> --- /home/rossb/local/linux-2.6.25-rc9/mm/hugetlb.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/mm/hugetlb.c	2008-04-14 09:01:16.000000000 -0700
> @@ -762,6 +762,8 @@ int copy_hugetlb_page_range(struct mm_st
>  
>  		spin_lock(&dst->page_table_lock);
>  		spin_lock(&src->page_table_lock);
> +		delimbo_huge_pte(&src_pte, src, addr);
> +		delimbo_huge_pte(&dst_pte, dst, addr);
>  		if (!pte_none(*src_pte)) {
>  			if (cow)
>  				ptep_set_wrprotect(src, addr, src_pte);
> @@ -937,6 +939,7 @@ retry:
>  	}
>  
>  	spin_lock(&mm->page_table_lock);
> +	delimbo_huge_pte(&ptep, mm, address);
>  	size = i_size_read(mapping->host) >> HPAGE_SHIFT;
>  	if (idx >= size)
>  		goto backout;
> @@ -994,6 +997,7 @@ int hugetlb_fault(struct mm_struct *mm, 
>  	ret = 0;
>  
>  	spin_lock(&mm->page_table_lock);
> +	delimbo_huge_pte(&ptep, mm, address);
>  	/* Check for a racing update before calling hugetlb_cow */
>  	if (likely(pte_same(entry, *ptep)))
>  		if (write_access && !pte_write(entry))
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/memory.c 2.6.25-rc9/mm/memory.c
> --- /home/rossb/local/linux-2.6.25-rc9/mm/memory.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/mm/memory.c	2008-04-15 08:02:48.000000000 -0700
> @@ -312,6 +312,7 @@ int __pte_alloc(struct mm_struct *mm, pm
>  		return -ENOMEM;
>  
>  	spin_lock(&mm->page_table_lock);
> +	delimbo_pmd(&pmd, mm, address);
>  	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
>  		mm->nr_ptes++;
>  		pmd_populate(mm, pmd, new);
> @@ -330,6 +331,7 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
>  		return -ENOMEM;
>  
>  	spin_lock(&init_mm.page_table_lock);
> +	delimbo_pmd(&pmd, &init_mm, address);


I think you're never migrating anything in init_mm, so this should be a no-op, right?


>  	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
>  		pmd_populate_kernel(&init_mm, pmd, new);
>  		new = NULL;
> @@ -513,6 +515,9 @@ again:
>  	src_pte = pte_offset_map_nested(src_pmd, addr);
>  	src_ptl = pte_lockptr(src_mm, src_pmd);
>  	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
> +
> +	delimbo_pte_nested(&src_pte, &src_ptl, &src_pmd, src_mm, addr,
> +			   SINGLE_DEPTH_NESTING, dst_ptl);
>  	arch_enter_lazy_mmu_mode();
>  
>  	do {
> @@ -1488,13 +1493,15 @@ EXPORT_SYMBOL_GPL(apply_to_page_range);
>   * and do_anonymous_page and do_no_page can safely check later on).
>   */
>  static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
> -				pte_t *page_table, pte_t orig_pte)
> +				pte_t *page_table, pte_t orig_pte,
> +				unsigned long address)
>  {
>  	int same = 1;
>  #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
>  	if (sizeof(pte_t) > sizeof(unsigned long)) {
>  		spinlock_t *ptl = pte_lockptr(mm, pmd);
>  		spin_lock(ptl);
> +		delimbo_pte(&page_table, &ptl, &pmd, mm, address);
>  		same = pte_same(*page_table, orig_pte);
>  		spin_unlock(ptl);
>  	}
> @@ -2021,7 +2028,7 @@ static int do_swap_page(struct mm_struct
>  	pte_t pte;
>  	int ret = 0;
>  
> -	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
> +	if (!pte_unmap_same(mm, pmd, page_table, orig_pte, address))
>  		goto out;
>  
>  	entry = pte_to_swp_entry(orig_pte);
> @@ -2100,6 +2107,10 @@ static int do_swap_page(struct mm_struct
>  	}
>  
>  	/* No need to invalidate - it was non-present before */
> +	/* Unless of course the cpu might be looking at an old
> +	   copy of the pte. */
> +	maybe_reload_tlb_mm(mm);
> +
>  	update_mmu_cache(vma, address, pte);
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
> @@ -2151,6 +2162,10 @@ static int do_anonymous_page(struct mm_s
>  	set_pte_at(mm, address, page_table, entry);
>  
>  	/* No need to invalidate - it was non-present before */
> +	/* Unless of course the cpu might be looking at an old
> +	   copy of the pte. */
> +	maybe_reload_tlb_mm(mm);
> +
>  	update_mmu_cache(vma, address, entry);
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
> @@ -2312,6 +2327,10 @@ static int __do_fault(struct mm_struct *
>  		}
>  
>  		/* no need to invalidate: a not-present page won't be cached */
> +		/* Unless of course the cpu could be looking at an old page
> +		   table entry. */
> +		maybe_reload_tlb_mm(mm);
> +
>  		update_mmu_cache(vma, address, entry);
>  	} else {
>  		mem_cgroup_uncharge_page(page);
> @@ -2418,7 +2437,7 @@ static int do_nonlinear_fault(struct mm_
>  				(write_access ? FAULT_FLAG_WRITE : 0);
>  	pgoff_t pgoff;
>  
> -	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
> +	if (!pte_unmap_same(mm, pmd, page_table, orig_pte, address))
>  		return 0;
>  
>  	if (unlikely(!(vma->vm_flags & VM_NONLINEAR) ||
> @@ -2477,6 +2496,7 @@ static inline int handle_pte_fault(struc
>  
>  	ptl = pte_lockptr(mm, pmd);
>  	spin_lock(ptl);
> +	delimbo_pte(&pte, &ptl, &pmd, mm, address);
>  	if (unlikely(!pte_same(*pte, entry)))
>  		goto unlock;
>  	if (write_access) {
> @@ -2498,6 +2518,12 @@ static inline int handle_pte_fault(struc
>  		if (write_access)
>  			flush_tlb_page(vma, address);
>  	}
> +
> +	/* if the cpu could be looking at an old page table, we need to
> +	   flush out everything. */
> +	maybe_reload_tlb_mm(mm);
> +
> +
>  unlock:
>  	pte_unmap_unlock(pte, ptl);
>  	return 0;
> @@ -2547,6 +2573,7 @@ int __pud_alloc(struct mm_struct *mm, pg
>  		return -ENOMEM;
>  
>  	spin_lock(&mm->page_table_lock);
> +	delimbo_pgd(&pgd, mm, address);
>  	if (pgd_present(*pgd))		/* Another has populated it */
>  		pud_free(mm, new);
>  	else
> @@ -2568,6 +2595,7 @@ int __pmd_alloc(struct mm_struct *mm, pu
>  		return -ENOMEM;
>  
>  	spin_lock(&mm->page_table_lock);
> +	delimbo_pud(&pud, mm, address);
>  #ifndef __ARCH_HAS_4LEVEL_HACK
>  	if (pud_present(*pud))		/* Another has populated it */
>  		pmd_free(mm, new);
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/mempolicy.c 2.6.25-rc9/mm/mempolicy.c
> --- /home/rossb/local/linux-2.6.25-rc9/mm/mempolicy.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/mm/mempolicy.c	2008-04-14 09:00:29.000000000 -0700
> @@ -101,6 +101,12 @@
>  static struct kmem_cache *policy_cache;
>  static struct kmem_cache *sn_cache;
>  
> +#ifdef CONFIG_RELOCATE_PAGE_TABLES
> +int migrate_page_tables_mm(struct mm_struct *mm,  int source,
> +			   new_page_table_t get_new_page,
> +			   unsigned long private);
> +#endif
> +
>  /* Highest zone. An specific allocation for a zone below that is not
>     policied. */
>  enum zone_type policy_zone = 0;
> @@ -627,6 +633,20 @@ static struct page *new_node_page(struct
>  	return alloc_pages_node(node, GFP_HIGHUSER_MOVABLE, 0);
>  }
>  
> +#ifdef CONFIG_RELOCATE_PAGE_TABLES
> +static struct page *new_node_page_page_tables(struct mm_struct *mm,
> +					      unsigned long addr,
> +					      unsigned long node,
> +					      int **x,
> +					      int level)
> +{
> +	struct page *p;
> +	p = alloc_page_table_node(mm, addr, node, level);
> +	return p;
> +}
> +
> +#endif /* CONFIG_RELOCATE_PAGE_TABLES  */
> +
>  /*
>   * Migrate pages from one node to a target node.
>   * Returns error or the number of pages not migrated.
> @@ -647,6 +667,12 @@ static int migrate_to_node(struct mm_str
>  	if (!list_empty(&pagelist))
>  		err = migrate_pages(&pagelist, new_node_page, dest);
>  
> +#ifdef CONFIG_RELOCATE_PAGE_TABLES
> +	if (!err)
> +		err = migrate_page_tables_mm(mm, source,
> +					     new_node_page_page_tables, dest);

Why the indirection?  Do you expect to be passing another function in
here at some point?

> +#endif /* CONFIG_RELOCATE_PAGE_TABLES */
> +
>  	return err;
>  }
>  
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/migrate.c 2.6.25-rc9/mm/migrate.c
> --- /home/rossb/local/linux-2.6.25-rc9/mm/migrate.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/mm/migrate.c	2008-04-15 08:12:50.000000000 -0700
> @@ -30,9 +30,18 @@
>  #include <linux/vmalloc.h>
>  #include <linux/security.h>
>  #include <linux/memcontrol.h>
> +#include <linux/mm.h>
> +#include <asm/tlb.h>
> +#include <asm/tlbflush.h>
> +#include <asm/pgalloc.h>
>  
>  #include "internal.h"
>  
> +int migrate_page_tables_mm(struct mm_struct *mm, int source,
> +			   new_page_table_t get_new_page,
> +			   unsigned long private);
> +
> +
>  #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
>  
>  /*
> @@ -155,6 +164,7 @@ static void remove_migration_pte(struct 
>  
>   	ptl = pte_lockptr(mm, pmd);
>   	spin_lock(ptl);
> +	delimbo_pte(&ptep, &ptl, &pmd, mm, addr);
>  	pte = *ptep;
>  	if (!is_swap_pte(pte))
>  		goto out;
> @@ -895,9 +905,10 @@ set_status:
>  		err = migrate_pages(&pagelist, new_page_node,
>  				(unsigned long)pm);
>  	else
> -		err = -ENOENT;
> +		err = 0;
>  
>  	up_read(&mm->mmap_sem);
> +
>  	return err;
>  }
>  
> @@ -1075,3 +1086,514 @@ int migrate_vmas(struct mm_struct *mm, c
>   	}
>   	return err;
>  }
> +
> +#ifdef CONFIG_RELOCATE_PAGE_TABLES
> +
> +/*
> + * Code to relocate live page tables.  The strategy is simple.  We
> + * allow that either the kernel or the cpus could be looking at or
> + * have cached a stale page table.  We just make sure that the kernel
> + * only updates the latest version of the page tables and that we
> + * flush the page table cache anytime a cpu could be looking at a
> + * stale page table and it might matter.
> + *
> + * Since we have to worry about the kernel and cpu's separately,
> + * it's important to distinguish between what the cpu is doing internally
> + * and what the kernel is doing on a cpu.  We use cpu for the former and
> + * thread for the later.

latter

> + *
> + * This is easier than it might seems since most of the code is
> + * already there.  The kernel never updates a page table without first
> + * grabbing an appropriate spinlock.  Then it has to double
> + * check to make sure that another thread hasn't already changed things.
> + * So all we have to do is rewalk all the page tables whenever we
> + * grab the spinlock. Then the existing double check code takes care
> + * of the rest.

A number of places in the kernel update init_mm without holding any
locks.  But I guess since you restrict yourself to the usermode parts
of the pagetable, this is OK.

> + *
> + * For the cpus, it's just important to fluch the TLB cache whenever it

flush

> + * might be relevant.  To avoid unnecessary TLB cache tharshing, we only

thrashing

Why not switch to init_mm, do all the migrations on the target mm,
then switch back and get all the other cpus to do a reload/flush?
Wouldn't that achieve the same effect?

> + * flush the TLB caches when we are done with all the changes, or it could
> + * make a difference.  We already have to flush the TLB caches whenever it
> + * could make a difference, except in the cases where we are updating
> + * something the cpu wouldn't normally cache.  The only place this happens,
> + * is when we have a page was non-present.  The cpu won't cache that
> + * particular entry, but it might be caching stale page tables leading
> + * up to the non-present entry.  So we might need to flush everything
> + * where we didn't have to flush before.

So you're saying that you've copied the pte pages, updated the
pagetable to point to them, but the cpu could still have the old
pagetable state in its tlb.

How do you migrate the accessed/dirty state from the old ptes to the
new one?  Losing accessed isn't a huge problem, but losing dirty can
cause data loss.

> + *
> + * One last gotcha is that before the only way to change the top-level
> + * page table is to switch tasks.  So we had to add a reload
> + * tlb option.  This is per arch function and is not yet on all arches.
> + * For arches where we cannot reload the tlb, we cannot migrate the
> + * top level page table.
> + */
> +
> +/* This function rewalks the page tables to make sure that
> + * a thread is not looking at a stale page table entry.
> + */
> +void _delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
> +		  struct mm_struct *mm,  unsigned long addr)
> +{
> +#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
> +	spin_unlock(*ptl);
> +	spin_lock(&mm->page_table_lock);
> +#endif

Elsewhere you use
	  if (ptl != &mm->page_table_lock)
	     ...

which seems cleaner than the #if.

> +	/* We could check the page_table_relocation_count again
> +	 * to make sure that it hasn't changed, but it's not a big win
> +	 * and makes the code more complex since we have to make sure
> +	 * we get the correct spinlock.
> +	 */
> +	pte_unmap(*pte);
> +	*pmd = walk_page_table_pmd(mm, addr);
> +	*pte = pte_offset_map(*pmd, addr);
> +	*ptl = pte_lockptr(mm, *pmd);
> +#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
> +	spin_lock(*ptl);
> +	spin_unlock(&mm->page_table_lock);
> +#endif
> +}
> +
> +void _delimbo_pte_nested(pte_t **pte, spinlock_t **ptl, pmd_t **pmd,
> +			 struct mm_struct *mm, unsigned long addr,
> +			 int subclass, spinlock_t *optl)

optl == outer_ptl?

> +{
> +#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
> +	if (optl != *ptl)
> +		spin_unlock(*ptl);
> +	spin_lock(&mm->page_table_lock);
> +#endif
> +	pte_unmap_nested(*pte);
> +	*pmd = walk_page_table_pmd(mm, addr);
> +	*pte = pte_offset_map_nested(*pmd, addr);
> +	*ptl = pte_lockptr(mm, *pmd);
> +
> +#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
> +	if (optl != *ptl )
> +		spin_lock_nested(*ptl, subclass);
> +	spin_unlock(&mm->page_table_lock);
> +#endif
> +}
> +
> +
> +void _delimbo_pud(pud_t **pud, struct mm_struct *mm, unsigned long addr)
> +{
> +	*pud = walk_page_table_pud(mm, addr);
> +}
> +
> +void _delimbo_pmd(pmd_t **pmd, struct mm_struct *mm, unsigned long addr)
> +{
> +	*pmd = walk_page_table_pmd(mm, addr);
> +}
> +
> +void _delimbo_pgd(pgd_t **pgd, struct mm_struct *mm, unsigned long addr)
> +{
> +	*pgd = walk_page_table_pgd(mm, addr);
> +}
> +
> +void _delimbo_huge_pte(pte_t **pte, struct mm_struct *mm, unsigned long addr)
> +{
> +	*pte = walk_page_table_huge_pte(mm, addr);
> +}
> +
> +/*
> + * Call this function to migrate a pgd to the page dest.
> + * mm is the mm struct that this pgd is part of and
> + * addr is the address for the pgd inside of the mm.
> + * Technically this only moves one page worth of pud's
> + * starting with the pud that represents addr.

So really its migrate_pgd_entry?  It migrates a single thing that a
pgd entry points to?

> + *
> + * The page that contains the pgd will be added to the
> + * end of old_pages.  It should be freed by an rcu callback
> + * or after a synchronize_rcu.  maybe_reload_tlb_mm also needs
> + * to be called before the pages are freed.
> + *
> + * Returns the number of pages not migrated.
> + */
> +int migrate_pgd(pgd_t *pgd, struct mm_struct *mm,
> +		unsigned long addr, struct page *dest,
> +		struct list_head *old_pages)
> +{
> +	void *dest_ptr;
> +	pud_t *pud;
> +
> +	spin_lock(&mm->page_table_lock);
> +
> +	_delimbo_pgd(&pgd, mm, addr);
> +
> +	pud = pud_offset(pgd, addr);
> +	dest_ptr = page_address(dest);
> +	memcpy(dest_ptr, pud, PAGE_SIZE);

A pud isn't necessarily a page size either.  I don't think you can
assume that any pagetable level has page-sized elements, though I
guess those levels will necessarily be non-migratable.

> +
> +	list_add_tail(&(pgd_page(*pgd)->lru), old_pages);

As above: a pud isn't necessarily a page.  Also, you need to
specifically deallocate it as a pud to make sure the page is free for
generally useful again (but not until you're sure there are no
lingering users on all cpus).  I think think means you need to queue a
(type, page) tuple on your old_pages list so they can be deallocated
properly.

> +	pgd_populate(mm, pgd, dest_ptr);

Good (this will do the right thing in paravirt_ops).

> +
> +	maybe_need_flush_mm(mm);
> +
> +	spin_unlock(&mm->page_table_lock);
> +
> +	return 0;
> +
> +}
> +
> +/*
> + * Call this function to migrate a pud to the page dest.
> + * mm is the mm struct that this pud is part of and
> + * addr is the address for the pud inside of the mm.
> + * Technically this only moves one page worth of pmd's
> + * starting with the pmd that represents addr.
> + *
> + * The page that contains the pud will be added to the
> + * end of old_pages.  It should be freed by an rcu callback
> + * or after a synchronize_rcu.  maybe_reload_tlb_mm also needs
> + * to be called before the pages are freed.
> + *
> + * Returns the number of pages not migrated.
> + */
> +int migrate_pud(pud_t *pud, struct mm_struct *mm, unsigned long addr,
> +		struct page *dest, struct list_head *old_pages)
> +{
> +	void *dest_ptr;
> +	pmd_t *pmd;
> +
> +	spin_lock(&mm->page_table_lock);
> +
> +	_delimbo_pud(&pud, mm, addr);
> +	pmd = pmd_offset(pud, addr);
> +
> +	dest_ptr = page_address(dest);
> +	memcpy(dest_ptr, pmd, PAGE_SIZE);
> +
> +	list_add_tail(&(pud_page(*pud)->lru), old_pages);
> +
> +	pud_populate(mm, pud, dest_ptr);
> +	maybe_need_flush_mm(mm);
> +
> +	spin_unlock(&mm->page_table_lock);
> +
> +	return 0;
> +}

Ditto migrate_pgd.

> +
> +/*
> + * Call this function to migrate a pmd to the page dest.
> + * mm is the mm struct that this pmd is part of and
> + * addr is the address for the pud inside of the mm.
> + * Technically this only moves one page worth of pte's
> + * starting with the pte that represents addr.
> + *
> + * The page that contains the pmd will be added to the
> + * end of old_pages.  It should be freed by an rcu callback
> + * or after a synchronize_rcu.  maybe_reload_tlb_mm also needs
> + * to be called before the pages are freed.
> + *
> + * Returns the number of pages not migrated.
> + *
> + * This function cannot be called at interrupt time since
> + * it uses KM_USER0.  To modify it to be usable at interrupt
> + * time requires a change of the KM_.  It may require a
> + * KM_ of its own.  It would be safe to always use the
> + * same KM_, since it's all done inside a spinlock, so there
> + * is no chance of the KM_ getting used twice on the same cpu.
> + */
> +
> +int migrate_pmd(pmd_t *pmd, struct mm_struct *mm, unsigned long addr,
> +		struct page *dest, struct list_head *old_pages)
> +{
> +	void *dest_ptr;
> +	spinlock_t *ptl;
> +	pte_t *pte;
> +
> +	spin_lock(&mm->page_table_lock);
> +
> +	_delimbo_pmd(&pmd, mm, addr);
> +
> +	/* this could happen if the page table has been swapped out and we
> +	   were looking at the old one. */
> +	if (unlikely(!pmd_present(*pmd))) {
> +		spin_unlock(&mm->page_table_lock);
> +		return 1;
> +	}
> +
> +	ptl = pte_lockptr(mm, pmd);
> +
> +	/* We need the page lock as well. */
> +	if (ptl != &mm->page_table_lock)
> +		spin_lock(ptl);

This seems like a nicer idiom than the "#if NR_CPUS >=
CONFIG_SPLIT_PTLOCK_CPUS" you used in _delimbo_pte.

> +
> +	pte = pte_offset_map(pmd, addr);
> +
> +	dest_ptr = kmap_atomic(dest, KM_USER0);
> +	memcpy(dest_ptr, pte, PAGE_SIZE);
> +	list_add_tail(&(pmd_page(*pmd)->lru), old_pages);
> +
> +	kunmap_atomic(dest, KM_USER0);
> +	pte_unmap(pte);
> +	pte_lock_init(dest);
> +	pmd_populate(mm, pmd, dest);
> +
> +	maybe_need_flush_mm(mm);
> +
> +	if (ptl != &mm->page_table_lock)
> +		spin_unlock(ptl);
> +
> +	spin_unlock(&mm->page_table_lock);
> +
> +	return 0;
> +}
> +
> +/*
> + * There is no migrate_pte since that would be moving the page
> + * pointed to by a pte around.  That's a user page and is equivalent
> + * to swapping and doesn't need to be handled here.
> + */
> +
> +static int migrate_page_tables_pmd(pmd_t *pmd, struct mm_struct *mm,
> +				   unsigned long *address, int source,
> +				   new_page_table_t get_new_page,
> +				   unsigned long private,
> +				   struct list_head *old_pages)
> +{
> +	int pages_not_migrated = 0;
> +	int *result = NULL;
> +	struct page *old_page = virt_to_page(pmd);
> +	struct page *new_page;
> +	int not_migrated;
> +
> +	if (!pmd_present(*pmd)) {
> +		*address +=  (unsigned long)PTRS_PER_PTE * PAGE_SIZE;
> +		return 0;
> +	}
> +
> +	if (page_to_nid(old_page) == source) {
> +		new_page = get_new_page(mm, *address, private, &result,
> +					PAGE_TABLE_PTE);
> +		if (!new_page)
> +			return -ENOMEM;
> +		not_migrated = migrate_pmd(pmd, mm, *address, new_page,
> +					   old_pages);
> +		if (not_migrated)
> +			__free_page(new_page);
> +
> +		pages_not_migrated += not_migrated;
> +	}
> +
> +
> +	*address +=  (unsigned long)PTRS_PER_PTE * PAGE_SIZE;
> +
> +	return pages_not_migrated;
> +}
> +
> +static int migrate_page_tables_pud(pud_t *pud, struct mm_struct *mm,
> +				   unsigned long *address, int source,
> +				   new_page_table_t get_new_page,
> +				   unsigned long private,
> +				   struct list_head *old_pages)
> +{
> +	int pages_not_migrated = 0;
> +	int i;
> +	int *result = NULL;
> +	struct page *old_page = virt_to_page(pud);
> +	struct page *new_page;
> +	int not_migrated;
> +
> +	if (!pud_present(*pud)) {
> +		*address += (unsigned long)PTRS_PER_PMD *
> +				(unsigned long)PTRS_PER_PTE * PAGE_SIZE;
> +		return 0;
> +	}
> +
> +	if (page_to_nid(old_page) == source) {
> +		new_page = get_new_page(mm, *address, private, &result,
> +					PAGE_TABLE_PMD);
> +		if (!new_page)
> +			return -ENOMEM;
> +
> +		not_migrated = migrate_pud(pud, mm, *address, new_page,
> +					   old_pages);
> +
> +		if (not_migrated)
> +			__free_page(new_page);
> +
> +		pages_not_migrated += not_migrated;
> +	}
> +
> +	for (i = 0; i < PTRS_PER_PUD; i++) {
> +		int ret;
> +		ret = migrate_page_tables_pmd(pmd_offset(pud, *address), mm,
> +					      address, source,
> +					      get_new_page, private,
> +					      old_pages);
> +		if (ret < 0)
> +			return ret;
> +		pages_not_migrated += ret;
> +	}
> +
> +	return pages_not_migrated;
> +}
> +
> +static int migrate_page_tables_pgd(pgd_t *pgd, struct mm_struct *mm,
> +				   unsigned long *address, int source,
> +				   new_page_table_t get_new_page,
> +				   unsigned long private,
> +				   struct list_head *old_pages)
> +{
> +	int pages_not_migrated = 0;
> +	int i;
> +	int *result = NULL;
> +	struct page *old_page = virt_to_page(pgd);
> +	struct page *new_page;
> +	int not_migrated;
> +
> +	if (!pgd_present(*pgd)) {
> +		*address +=  (unsigned long)PTRS_PER_PUD *
> +				(unsigned long)PTRS_PER_PMD *
> +				(unsigned long)PTRS_PER_PTE * PAGE_SIZE;
> +		return 0;
> +	}
> +
> +	if (page_to_nid(old_page) == source) {
> +		new_page = get_new_page(mm, *address,  private, &result,
> +					PAGE_TABLE_PUD);
> +		if (!new_page)
> +			return -ENOMEM;
> +
> +		not_migrated = migrate_pgd(pgd, mm,  *address, new_page,
> +					   old_pages);
> +		if (not_migrated)
> +			__free_page(new_page);
> +
> +		pages_not_migrated += not_migrated;
> +
> +	}
> +
> +	for (i = 0; i < PTRS_PER_PUD; i++) {
> +		int ret;
> +		ret = migrate_page_tables_pud(pud_offset(pgd, *address), mm,
> +					      address, source,
> +					      get_new_page, private,
> +					      old_pages);
> +		if (ret < 0)
> +			return ret;
> +		pages_not_migrated += ret;
> +	}
> +
> +	return pages_not_migrated;
> +}
> +
> +/*
> + * Call this before calling any of the page table relocation
> + * functions.  It causes any other threads using this mm
> + * to start checking to see if someone has changed the page
> + * tables out from under it.
> + */
> +void enter_page_table_relocation_mode(struct mm_struct *mm)
> +{
> +	/* Use an int and a spinlock rather than an atomic_t
> +	 * beacuse we only check this inside the spinlock,
> +	 * so we save a bunch of lock prefixes in a fast_path
> +	 * by suffering a little here with a full block spinlock.
> +	 * should be a win overall.
> +	 *
> +	 * One gotcha.  page_table_relocation_count is
> +	 * checked with the wrong spinlock held in the case
> +	 * of split page table locks.  Since we only muck with
> +	 * the lowest level page tables while holding both the
> +	 * page_table_lock and the split page table lock,
> +	 * we are still ok.
> +	 */
> +	spin_lock(&mm->page_table_lock);
> +	BUG_ON(mm->page_table_relocation_count > INT_MAX/2);
> +	mm->page_table_relocation_count++;
> +	spin_unlock(&mm->page_table_lock);
> +}
> +
> +void leave_page_table_relocation_mode(struct mm_struct *mm)
> +{
> +	/* Make sure all the threads are no longer looking at a stale
> +	 * copy of a page table before clearing the flag that lets the
> +	 * threads know they may be looking at a stale copy of the
> +	 * page tables.  synchronize_rcu must be called before this
> +	 * function.
> +	 */
> +	spin_lock(&mm->page_table_lock);
> +	mm->page_table_relocation_count--;
> +	BUG_ON(mm->page_table_relocation_count < 0);
> +	spin_unlock(&mm->page_table_lock);
> +}
> +
> +/* Similiar to migrate pages, but migrates the page tables.
> + * This particular version moves all pages tables away from
> + * the source node to whatever get's allocated by get_new_page.
> + * It's easy to modify the code to reloate other page tables,
> + * or call the migrate_pxx functions directly to move only
> + * a few pages around.  This is meant as a start to test the
> + * migration code and to allow migration between nodes.
> + */
> +int migrate_page_tables_mm(struct mm_struct *mm, int source,
> +			   new_page_table_t get_new_page,
> +			   unsigned long private)
> +{
> +	int pages_not_migrated = 0;
> +	int i;
> +	int *result = NULL;
> +	struct page *old_page = virt_to_page(mm->pgd);
> +	struct page *new_page;
> +	unsigned long address = 0UL;
> +	int not_migrated;
> +	int ret = 0;
> +	LIST_HEAD(old_pages);
> +
> +	if (mm->pgd == NULL)
> +		return 0;
> +
> +	enter_page_table_relocation_mode(mm);
> +
> +	for (i = 0; i < PTRS_PER_PGD && address < mm->task_size; i++) {
> +		ret = migrate_page_tables_pgd(pgd_offset(mm, address), mm,
> +					      &address, source,
> +					      get_new_page, private,
> +					      &old_pages);
> +		if (ret < 0)
> +			goto out_exit;
> +
> +		pages_not_migrated += ret;
> +	}
> +
> +	if (page_to_nid(old_page) == source) {
> +		new_page = get_new_page(mm, address, private, &result,
> +					PAGE_TABLE_PGD);
> +		if (!new_page) {
> +			ret = -ENOMEM;
> +			goto out_exit;
> +		}
> +
> +		not_migrated = migrate_top_level_page_table(mm, new_page,
> +							&old_pages);
> +		if (not_migrated) {
> +			pgd_list_del(page_address(new_page));
> +			__free_page(new_page);
> +		}
> +
> +		pages_not_migrated += not_migrated;
> +	}
> +
> +	/* reload or flush the tlbs if necessary. */
> +	maybe_reload_tlb_mm(mm);
> +
> +	/* make sure all threads have stopped looking at stale pages. */
> +	synchronize_rcu();
> +
> +	while (!list_empty(&old_pages)) {
> +		old_page = list_first_entry(&old_pages, struct page, lru);
> +		list_del_init(&old_page->lru);
> +		__free_page(old_page);

You need to use the appropriate pgd/pud/pmd/pte_free() function here.
There may be other things needing to be done to the page before it can
be released back into the general kernel page pool.

> +	}
> +
> + out_exit:
> +	leave_page_table_relocation_mode(mm);
> +
> +	if (ret < 0)
> +		return ret;
> +	return pages_not_migrated;
> +}
> +
> +#endif /* CONFIG_RELOCATE_PAGE_TABLES */
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/mremap.c 2.6.25-rc9/mm/mremap.c
> --- /home/rossb/local/linux-2.6.25-rc9/mm/mremap.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/mm/mremap.c	2008-04-15 08:03:20.000000000 -0700
> @@ -98,6 +98,8 @@ static void move_ptes(struct vm_area_str
>  	new_ptl = pte_lockptr(mm, new_pmd);
>  	if (new_ptl != old_ptl)
>  		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
> +	delimbo_pte_nested(&new_pte, &new_ptl, &new_pmd, mm, new_addr,
> +			   SINGLE_DEPTH_NESTING, old_ptl);
>  	arch_enter_lazy_mmu_mode();
>  
>  	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
> diff -uprwNBb -X 2.6.25-rc9/Documentation/dontdiff /home/rossb/local/linux-2.6.25-rc9/mm/rmap.c 2.6.25-rc9/mm/rmap.c
> --- /home/rossb/local/linux-2.6.25-rc9/mm/rmap.c	2008-04-11 13:32:29.000000000 -0700
> +++ 2.6.25-rc9/mm/rmap.c	2008-04-14 09:00:29.000000000 -0700
> @@ -255,6 +255,7 @@ pte_t *page_check_address(struct page *p
>  
>  	ptl = pte_lockptr(mm, pmd);
>  	spin_lock(ptl);
> +	delimbo_pte(&pte, &ptl, &pmd, mm, address);
>  	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
>  		*ptlp = ptl;
>  		return pte;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
