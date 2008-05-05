Date: Mon, 5 May 2008 14:12:40 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/2] fix SMP data race in pagetable setup vs walking
Message-ID: <20080505121240.GD5018@wotan.suse.de>
References: <20080505112021.GC5018@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080505112021.GC5018@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

I only converted x86 and powerpc. I think comments in x86 are good because
that is more or less the reference implementation and is where many VM
developers would look to understand mm/ code. Commenting all page table
walking in all other architectures is kind of beyond my skill or patience,
and maintainers might consider this weird "alpha thingy" is below them ;)
But they are quite free to add smp_read_barrier_depends to their own code.

Still would like more acks on this before it is applied.

--

There is a possible data race in the page table walking code. After the split
ptlock patches, it actually seems to have been introduced to the core code, but
even before that I think it would have impacted some architectures (powerpc and
sparc64, at least, walk the page tables without taking locks eg. see
find_linux_pte()).

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

Fortunately, on x86 (except OOSTORE), nothing needs to be done, because stores
are in order, and so are loads.

I prefer to put the barriers in core code, because that's where the higher
level logic happens, but the page table accessors are per-arch, and open-coding
them everywhere I don't think is an option.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/asm-x86/pgtable_32.h
===================================================================
--- linux-2.6.orig/include/asm-x86/pgtable_32.h
+++ linux-2.6/include/asm-x86/pgtable_32.h
@@ -133,7 +133,12 @@ extern int pmd_bad(pmd_t pmd);
  * pgd_offset() returns a (pgd_t *)
  * pgd_index() is used get the offset into the pgd page's array of pgd_t's;
  */
-#define pgd_offset(mm, address) ((mm)->pgd + pgd_index((address)))
+#define pgd_offset(mm, address)						\
+({									\
+	pgd_t *ret = ((mm)->pgd + pgd_index((address)));		\
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
 
 /*
  * a shortcut which implies the use of the kernel's pgd, instead
@@ -160,8 +165,12 @@ static inline int pud_large(pud_t pud) {
  */
 #define pte_index(address)					\
 	(((address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
-#define pte_offset_kernel(dir, address)				\
-	((pte_t *)pmd_page_vaddr(*(dir)) +  pte_index((address)))
+#define pte_offset_kernel(dir, address)					\
+({									\
+	pte_t *ret = (pte_t *)pmd_page_vaddr(*(dir)) +  pte_index((address)); \
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
 
 #define pmd_page(pmd) (pfn_to_page(pmd_val((pmd)) >> PAGE_SHIFT))
 
@@ -170,16 +179,32 @@ static inline int pud_large(pud_t pud) {
 
 #if defined(CONFIG_HIGHPTE)
 #define pte_offset_map(dir, address)					\
-	((pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE0) +		\
-	 pte_index((address)))
+({									\
+	pte_t *ret = (pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE0) + \
+		 pte_index((address));					\
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
+
 #define pte_offset_map_nested(dir, address)				\
-	((pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE1) +		\
-	 pte_index((address)))
+({									\
+	pte_t *ret = (pte_t *)kmap_atomic_pte(pmd_page(*(dir)), KM_PTE1) + \
+		 pte_index((address));					\
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
+
 #define pte_unmap(pte) kunmap_atomic((pte), KM_PTE0)
 #define pte_unmap_nested(pte) kunmap_atomic((pte), KM_PTE1)
 #else
 #define pte_offset_map(dir, address)					\
-	((pte_t *)page_address(pmd_page(*(dir))) + pte_index((address)))
+({									\
+	pte_t *ret = (pte_t *)page_address(pmd_page(*(dir))) +		\
+		pte_index((address));					\
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
+
 #define pte_offset_map_nested(dir, address) pte_offset_map((dir), (address))
 #define pte_unmap(pte) do { } while (0)
 #define pte_unmap_nested(pte) do { } while (0)
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -311,6 +311,37 @@ int __pte_alloc(struct mm_struct *mm, pm
 	if (!new)
 		return -ENOMEM;
 
+	/*
+	 * Ensure all pte setup (eg. pte page lock and page clearing) are
+	 * visible before the pte is made visible to other CPUs by being
+	 * put into page tables.
+	 *
+	 * The other side of the story is the pointer chasing in the page
+	 * table walking code (when walking the page table without locking;
+	 * ie. most of the time). Fortunately, these data accesses consist
+	 * of a chain of data-dependent loads, meaning most CPUs (alpha
+	 * being the notable exception) will already guarantee loads are
+	 * seen in-order. x86 has a "reference" implementation of
+	 * smp_read_barrier_depends() barriers in its page table walking
+	 * code, even though that barrier is a simple noop on that architecture.
+	 * Alpha obviously also has the required barriers.
+	 *
+	 * It is debatable whether or not the smp_read_barrier_depends()
+	 * barriers are required for kernel page tables; it could be that
+	 * nowhere in the kernel do we walk those pagetables without taking
+	 * init_mm's page_table_lock. However, such walks are pretty uncommon,
+	 * and the only architecture that is even slightly impacted is
+	 * alpha, so barriers are there to be safe. The smp_wmb()'s also may
+	 * not be required in the allocation side of kernel page tables,
+	 * because it is probably a bug for a thread to concurrently be
+	 * accessing kva that is being set up at the same time -- however it
+	 * is nice to have the wmb barriers there, because they might prevent
+	 * us from reading some junk in that case. So we will get a simple
+	 * page fault in the case of such a bug, rather than a possible
+	 * undetected wander off into crazy space.
+	 */
+	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */
+
 	spin_lock(&mm->page_table_lock);
 	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
 		mm->nr_ptes++;
@@ -329,6 +360,8 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	if (!new)
 		return -ENOMEM;
 
+	smp_wmb(); /* See comment in __pte_alloc */
+
 	spin_lock(&init_mm.page_table_lock);
 	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
 		pmd_populate_kernel(&init_mm, pmd, new);
@@ -2616,6 +2649,8 @@ int __pud_alloc(struct mm_struct *mm, pg
 	if (!new)
 		return -ENOMEM;
 
+	smp_wmb(); /* See comment in __pte_alloc */
+
 	spin_lock(&mm->page_table_lock);
 	if (pgd_present(*pgd))		/* Another has populated it */
 		pud_free(mm, new);
@@ -2637,6 +2672,8 @@ int __pmd_alloc(struct mm_struct *mm, pu
 	if (!new)
 		return -ENOMEM;
 
+	smp_wmb(); /* See comment in __pte_alloc */
+
 	spin_lock(&mm->page_table_lock);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */
Index: linux-2.6/include/asm-x86/pgtable-3level.h
===================================================================
--- linux-2.6.orig/include/asm-x86/pgtable-3level.h
+++ linux-2.6/include/asm-x86/pgtable-3level.h
@@ -126,8 +126,13 @@ static inline void pud_clear(pud_t *pudp
 
 
 /* Find an entry in the second-level page table.. */
-#define pmd_offset(pud, address) ((pmd_t *)pud_page(*(pud)) +	\
-				  pmd_index(address))
+#define pmd_offset(pud, address)					\
+({									\
+	pmd_t *pmd = ((pmd_t *)pud_page(*(pud)) +			\
+				  pmd_index(address))			\
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
 
 #ifdef CONFIG_SMP
 static inline pte_t native_ptep_get_and_clear(pte_t *ptep)
Index: linux-2.6/include/asm-x86/pgtable_64.h
===================================================================
--- linux-2.6.orig/include/asm-x86/pgtable_64.h
+++ linux-2.6/include/asm-x86/pgtable_64.h
@@ -193,8 +193,20 @@ static inline unsigned long pmd_bad(pmd_
 	((unsigned long)__va((unsigned long)pgd_val((pgd)) & PTE_MASK))
 #define pgd_page(pgd)		(pfn_to_page(pgd_val((pgd)) >> PAGE_SHIFT))
 #define pgd_index(address) (((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1))
-#define pgd_offset(mm, address)	((mm)->pgd + pgd_index((address)))
-#define pgd_offset_k(address) (init_level4_pgt + pgd_index((address)))
+#define pgd_offset(mm, address)						\
+({									\
+	pgd_t *ret = ((mm)->pgd + pgd_index((address)));		\
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
+
+#define pgd_offset_k(address)						\
+({									\
+	pgd_t *ret = (init_level4_pgt + pgd_index((address)));		\
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
+
 #define pgd_present(pgd) (pgd_val(pgd) & _PAGE_PRESENT)
 static inline int pgd_large(pgd_t pgd) { return 0; }
 #define mk_kernel_pgd(address) ((pgd_t){ (address) | _KERNPG_TABLE })
@@ -206,7 +218,12 @@ static inline int pgd_large(pgd_t pgd) {
 #define pud_page(pud)	(pfn_to_page(pud_val((pud)) >> PAGE_SHIFT))
 #define pud_index(address) (((address) >> PUD_SHIFT) & (PTRS_PER_PUD - 1))
 #define pud_offset(pgd, address)					\
-	((pud_t *)pgd_page_vaddr(*(pgd)) + pud_index((address)))
+({									\
+	pud_t *ret = ((pud_t *)pgd_page_vaddr(*(pgd)) + pud_index((address))); \
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
+
 #define pud_present(pud) (pud_val((pud)) & _PAGE_PRESENT)
 
 static inline int pud_large(pud_t pte)
@@ -220,8 +237,14 @@ static inline int pud_large(pud_t pte)
 #define pmd_page(pmd)		(pfn_to_page(pmd_val((pmd)) >> PAGE_SHIFT))
 
 #define pmd_index(address) (((address) >> PMD_SHIFT) & (PTRS_PER_PMD - 1))
-#define pmd_offset(dir, address) ((pmd_t *)pud_page_vaddr(*(dir)) + \
-				  pmd_index(address))
+#define pmd_offset(dir, address)					\
+({									\
+	pmd_t *ret = ((pmd_t *)pud_page_vaddr(*(dir)) +			\
+				  pmd_index(address));			\
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
+
 #define pmd_none(x)	(!pmd_val((x)))
 #define pmd_present(x)	(pmd_val((x)) & _PAGE_PRESENT)
 #define pfn_pmd(nr, prot) (__pmd(((nr) << PAGE_SHIFT) | pgprot_val((prot))))
@@ -238,8 +261,13 @@ static inline int pud_large(pud_t pte)
 #define mk_pte(page, pgprot)	pfn_pte(page_to_pfn((page)), (pgprot))
 
 #define pte_index(address) (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
-#define pte_offset_kernel(dir, address) ((pte_t *) pmd_page_vaddr(*(dir)) + \
-					 pte_index((address)))
+#define pte_offset_kernel(dir, address)					\
+({									\
+	pte_t *ret = ((pte_t *) pmd_page_vaddr(*(dir)) +		\
+					 pte_index((address)));		\
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
 
 /* x86-64 always has all page tables mapped. */
 #define pte_offset_map(dir, address) pte_offset_kernel((dir), (address))
Index: linux-2.6/include/asm-alpha/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-alpha/pgtable.h
+++ linux-2.6/include/asm-alpha/pgtable.h
@@ -285,19 +285,28 @@ extern inline pte_t pte_mkspecial(pte_t 
 
 /* to find an entry in a page-table-directory. */
 #define pgd_index(address)	(((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
-#define pgd_offset(mm, address)	((mm)->pgd+pgd_index(address))
+#define pgd_offset(mm, address)						\
+({									\
+	pgd_t *ret = ((mm)->pgd+pgd_index(address));			\
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */	\
+	ret;								\
+})
 
 /* Find an entry in the second-level page table.. */
 extern inline pmd_t * pmd_offset(pgd_t * dir, unsigned long address)
 {
-	return (pmd_t *) pgd_page_vaddr(*dir) + ((address >> PMD_SHIFT) & (PTRS_PER_PAGE - 1));
+	pmd_t *ret = (pmd_t *) pgd_page_vaddr(*dir) + ((address >> PMD_SHIFT) & (PTRS_PER_PAGE - 1));
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */
+	return ret;
 }
 
 /* Find an entry in the third-level page table.. */
 extern inline pte_t * pte_offset_kernel(pmd_t * dir, unsigned long address)
 {
-	return (pte_t *) pmd_page_vaddr(*dir)
+	pte_t *ret = (pte_t *) pmd_page_vaddr(*dir)
 		+ ((address >> PAGE_SHIFT) & (PTRS_PER_PAGE - 1));
+	smp_read_barrier_depends(); /* see mm/memory.c:__pte_alloc */
+	return ret;
 }
 
 #define pte_offset_map(dir,addr)	pte_offset_kernel((dir),(addr))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
