Date: Tue, 29 Apr 2008 07:00:54 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc] data race in page table setup/walking?
Message-ID: <20080429050054.GC21795@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hi,

I *think* there is a possible data race in the page table walking code. After
the split ptlock patches, it actually seems to have been introduced to the core
code, but even before that I think it would have impacted some architectures.

The race is as follows:
The pte page is allocated, zeroed, and its struct page gets its spinlock
initialized. The mm-wide ptl is then taken, and then the pte page is inserted
into the pagetables.

At this point, the spinlock is not guaranteed to have ordered the previous
stores to initialize the pte page with the subsequent store to put it in the
page tables. So another Linux page table walker might be walking down (without
any locks, because we have split-leaf-ptls), and find that new pte we've
inserted. It might try to take the spinlock before the store from the other
CPU initializes it. And subsequently it might read a pte_t out before stores
from the other CPU have cleared the memory.

There seem to be similar races in higher levels of the page tables, but they
obviously don't involve the spinlock, but one could see uninitialized memory.

Arch code and hardware pagetable walkers that walk the pagetables without
locks could see similar uninitialized memory problems (regardless of whether
we have split ptes or not).

Fortunately, on x86 (except stupid OOSTORE), nothing needs to be done, because
stores are in order, and so are loads. Even on OOSTORE we wouldn't have to take
the smp_wmb hit, if only we have a smp_wmb_before/after_spin_lock function.

This isn't a complete patch yet, but a demonstration of the problem, and an
RFC really as to the form of the solution. I prefer to put the barriers in
core code, because that's where the higher level logic happens, but the page
table accessors are per-arch, and open-coding them everywhere I don't think
is an option.

So anyway... comments, please? Am I dreaming the whole thing up? I suspect
that if I'm not, then powerpc at least might have been impacted by the race,
but as far as I know of, they haven't seen stability problems around there...
Might just be terribly rare, though. I'd like to try to make a test program
to reproduce the problem if I can get access to a box...

Thanks,
Nick

Index: linux-2.6/include/asm-x86/pgtable_32.h
===================================================================
--- linux-2.6.orig/include/asm-x86/pgtable_32.h
+++ linux-2.6/include/asm-x86/pgtable_32.h
@@ -179,7 +179,10 @@ static inline int pud_large(pud_t pud) {
 #define pte_index(address)					\
 	(((address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
 #define pte_offset_kernel(dir, address)				\
-	((pte_t *)pmd_page_vaddr(*(dir)) +  pte_index((address)))
+{(								\
+	(pte_t *)pmd_page_vaddr(*(dir)) +  pte_index((address));\
+	smp_read_barrier_depends();				\
+})
 
 #define pmd_page(pmd) (pfn_to_page(pmd_val((pmd)) >> PAGE_SHIFT))
 
@@ -188,16 +191,32 @@ static inline int pud_large(pud_t pud) {
 
 #if defined(CONFIG_HIGHPTE)
 #define pte_offset_map(dir, address)					\
-	((pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE0) +		\
-	 pte_index((address)))
+{(									\
+	pte_t *ret = (pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE0) + \
+		 pte_index((address));					\
+	smp_read_barrier_depends();					\
+	ret;								\
+)}
+
 #define pte_offset_map_nested(dir, address)				\
-	((pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE1) +		\
-	 pte_index((address)))
+{(									\
+	pte_t *ret = (pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE1) + \
+		 pte_index((address));					\
+	smp_read_barrier_depends();					\
+	ret;								\
+)}
+
 #define pte_unmap(pte) kunmap_atomic((pte), KM_PTE0)
 #define pte_unmap_nested(pte) kunmap_atomic((pte), KM_PTE1)
 #else
 #define pte_offset_map(dir, address)					\
-	((pte_t *)page_address(pmd_page(*(dir))) + pte_index((address)))
+{(									\
+	pte_t *ret = (pte_t *)page_address(pmd_page(*(dir))) +		\
+		pte_index((address));					\
+	smp_read_barrier_depends();					\
+	ret;								\
+)}
+
 #define pte_offset_map_nested(dir, address) pte_offset_map((dir), (address))
 #define pte_unmap(pte) do { } while (0)
 #define pte_unmap_nested(pte) do { } while (0)
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -311,6 +311,13 @@ int __pte_alloc(struct mm_struct *mm, pm
 	if (!new)
 		return -ENOMEM;
 
+	/*
+	 * Ensure all pte setup (eg. pte page lock and page clearing) are
+	 * visible before the pte is made visible to other CPUs by being
+	 * put into page tables.
+	 */
+	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */
+
 	spin_lock(&mm->page_table_lock);
 	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
 		mm->nr_ptes++;
@@ -329,6 +336,8 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	if (!new)
 		return -ENOMEM;
 
+	smp_wmb(); /* See comment in __pte_alloc */
+
 	spin_lock(&init_mm.page_table_lock);
 	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
 		pmd_populate_kernel(&init_mm, pmd, new);
@@ -2546,6 +2555,8 @@ int __pud_alloc(struct mm_struct *mm, pg
 	if (!new)
 		return -ENOMEM;
 
+	smp_wmb(); /* See comment in __pte_alloc */
+
 	spin_lock(&mm->page_table_lock);
 	if (pgd_present(*pgd))		/* Another has populated it */
 		pud_free(mm, new);
@@ -2567,6 +2578,8 @@ int __pmd_alloc(struct mm_struct *mm, pu
 	if (!new)
 		return -ENOMEM;
 
+	smp_wmb(); /* See comment in __pte_alloc */
+
 	spin_lock(&mm->page_table_lock);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
