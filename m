Date: Wed, 14 May 2008 06:37:36 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 2/2] fix SMP data race in pagetable setup vs walking
Message-ID: <20080514043736.GE23578@wotan.suse.de>
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de> <alpine.LFD.1.10.0805050828120.32269@woody.linux-foundation.org> <20080506095138.GE10141@wotan.suse.de> <alpine.LFD.1.10.0805060750430.32269@woody.linux-foundation.org> <20080513080143.GB19870@wotan.suse.de> <alpine.LFD.1.10.0805130844000.3019@woody.linux-foundation.org> <20080514003417.GA24516@wotan.suse.de> <alpine.LFD.1.10.0805131753150.3019@woody.linux-foundation.org> <20080514043511.GD23578@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080514043511.GD23578@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Paul McKenney <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

There is a possible data race in the page table walking code. After the split
ptlock patches, it actually seems to have been introduced to the core code, but
even before that I think it would have impacted some architectures (powerpc
and sparc64, at least, walk the page tables without taking locks eg. see
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

There are also similar races in higher levels of the page tables. They
obviously don't involve the spinlock, but could see uninitialized memory.

Arch code and hardware pagetable walkers that walk the pagetables without
locks could see similar uninitialized memory problems, regardless of whether
split ptes are enabled or not.

I prefer to put the barriers in core code, because that's where the higher
level logic happens, but the page table accessors are per-arch, and open-coding
them everywhere I don't think is an option. I'll put the read-side barriers
in alpha arch code for now (other architectures perform data-dependent loads
in order).

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 include/asm-alpha/pgtable.h |   18 ++++++++++++++++--
 mm/memory.c                 |   21 +++++++++++++++++++++
 2 files changed, 37 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -311,6 +311,21 @@ int __pte_alloc(struct mm_struct *mm, pm
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
+	 * seen in-order. See the alpha page table accessors for the
+	 * smp_read_barrier_depends() barriers in page table walking code.
+	 */
+	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */
+
 	spin_lock(&mm->page_table_lock);
 	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
 		mm->nr_ptes++;
@@ -329,6 +344,8 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 	if (!new)
 		return -ENOMEM;
 
+	smp_wmb(); /* See comment in __pte_alloc */
+
 	spin_lock(&init_mm.page_table_lock);
 	if (!pmd_present(*pmd)) {	/* Has another populated it ? */
 		pmd_populate_kernel(&init_mm, pmd, new);
@@ -2616,6 +2633,8 @@ int __pud_alloc(struct mm_struct *mm, pg
 	if (!new)
 		return -ENOMEM;
 
+	smp_wmb(); /* See comment in __pte_alloc */
+
 	spin_lock(&mm->page_table_lock);
 	if (pgd_present(*pgd))		/* Another has populated it */
 		pud_free(mm, new);
@@ -2637,6 +2656,8 @@ int __pmd_alloc(struct mm_struct *mm, pu
 	if (!new)
 		return -ENOMEM;
 
+	smp_wmb(); /* See comment in __pte_alloc */
+
 	spin_lock(&mm->page_table_lock);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */
Index: linux-2.6/include/asm-alpha/pgtable.h
===================================================================
--- linux-2.6.orig/include/asm-alpha/pgtable.h
+++ linux-2.6/include/asm-alpha/pgtable.h
@@ -287,17 +287,34 @@ extern inline pte_t pte_mkspecial(pte_t 
 #define pgd_index(address)	(((address) >> PGDIR_SHIFT) & (PTRS_PER_PGD-1))
 #define pgd_offset(mm, address)	((mm)->pgd+pgd_index(address))
 
+/*
+ * The smp_read_barrier_depends() in the following functions are required to
+ * order the load of *dir (the pointer in the top level page table) with any
+ * subsequent load of the returned pmd_t *ret (ret is data dependent on *dir).
+ *
+ * If this ordering is not enforced, the CPU might load an older value of
+ * *ret, which may be uninitialized data. See mm/memory.c:__pte_alloc for
+ * more details.
+ *
+ * Note that we never change the mm->pgd pointer after the task is running, so
+ * pgd_offset does not require such a barrier.
+ */
+
 /* Find an entry in the second-level page table.. */
 extern inline pmd_t * pmd_offset(pgd_t * dir, unsigned long address)
 {
-	return (pmd_t *) pgd_page_vaddr(*dir) + ((address >> PMD_SHIFT) & (PTRS_PER_PAGE - 1));
+	pmd_t *ret = (pmd_t *) pgd_page_vaddr(*dir) + ((address >> PMD_SHIFT) & (PTRS_PER_PAGE - 1));
+	smp_read_barrier_depends(); /* see above */
+	return ret;
 }
 
 /* Find an entry in the third-level page table.. */
 extern inline pte_t * pte_offset_kernel(pmd_t * dir, unsigned long address)
 {
-	return (pte_t *) pmd_page_vaddr(*dir)
+	pte_t *ret = (pte_t *) pmd_page_vaddr(*dir)
 		+ ((address >> PAGE_SHIFT) & (PTRS_PER_PAGE - 1));
+	smp_read_barrier_depends(); /* see above */
+	return ret;
 }
 
 #define pte_offset_map(dir,addr)	pte_offset_kernel((dir),(addr))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
