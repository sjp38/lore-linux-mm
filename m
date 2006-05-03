Message-ID: <4458CCDC.5060607@bull.net>
Date: Wed, 03 May 2006 17:31:40 +0200
From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
MIME-Version: 1.0
Subject: RFC: RCU protected page table walking
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Zoltan.Menyhart@free.fr
List-ID: <linux-mm.kvack.org>

On a TLB miss, we have got a

    TLB = ... -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]

chain to walk.
Some architectures do it in HW (microcode), some others in SW.
This page table walking is not atomic, not even on an x86.

Let's consider the following scenario:


CPU #1:                      CPU #2:                 CPU #3

Starts walking
Got the ph. addr. of page Y
in internal reg. X
                             free_pgtables():
                             sets free page Y
                                                     Allocates page Y
Accesses page Y via reg. X


As CPU #1 is still keeping the same ph. address, it fetches an item
from a page that is no more its page.

Even if this security window is small, it does exist.
We cannot base our security just on "quick" page table walking.
(How much quick it has to be?)
The probability to hit this bug grows higher on a NUMA machine with lots of CPUs.

If the HW page table walker cannot, the low level assembly routines do not take
any lock, then only some "careful programming" in the PUD / PMD / PTE page removal
code can help.

I propose an RCU based protection mechanism.
Some minor modifications will be necessary in the architecture dependent parts.
I can only give an example for IA64.
I did not spend much effort on optimizing the real freeing routine called
"do_free_pte_mpd_pud_pages()" because (among other reasons, see the comments),
basically, I wanted to present my RCU based concept.

Thanks,

Zoltan Menyhart

Signed-Off-By: Zoltan.Menyhart@bull.net


--- linux-2.6.16.9-save/mm/memory.c	2006-04-21 09:59:16.000000000 +0200
+++ linux-2.6.16.9/mm/memory.c	2006-05-03 16:29:46.000000000 +0200
@@ -264,9 +264,129 @@ void free_pgd_range(struct mmu_gather **
 		flush_tlb_pgtables((*tlb)->mm, start, end);
 }
 
+
+/*
+ * RCU protected page table walking.
+ * ---------------------------------
+ *
+ * Page table walking need protection, otherwise:
+ * - A first CPU, having reached somewhere in this chain walking, it has got
+ *   the physical address of the next page in the chain in an internal register.
+ * - In the mean time, a second CPU executing "free_pgtables()", frees the page
+ *   the first CPU is about to touch.
+ * - Someone re-uses the same page for something else.
+ * - The first CPU fetches an item from a page of someone else.
+ *
+ * PTE, PMD and PUD page usage perfectly fits into the RCU approach:
+ * - Page table walking is the read side
+ * - Allocating and un-mapping these pages is the update side
+ * - Really freeing these pages is the reclaim side
+ * PTE, PMD and PUD pages will be "put aside" by the un-mapping code until all
+ * pre-existing read-side critical sections on all CPUs have completed.
+ *
+ * Page table walking is (logically) carried out as follows:
+ *
+ *	rcu_read_lock_bh();
+ *	pud_p = rcu_dereference( pgd_p[i] );
+ *	pmd_p = rcu_dereference( pud_p[j] );
+ *	pte_p = rcu_dereference( pmd_p[k] );
+ *	...
+ *	pte = *pte_p;
+ *	...
+ *	rcu_read_unlock_bh();
+ *
+ * PTE, PMD and PUD page allocation, initialization and hooking them to their
+ * respective parent pages are carried out under some lock protection.
+ * Releasing this lock provides the required memory fencing semantics =>
+ * there is no need for explicit "rcu_assign_pointer()" usage.
+ *
+ * The "p??_free()" subroutines invoked by "free_pgtables()" indirectly, do not
+ * actually set free the PTE, PMD and PUD pages.
+ * Instead, they "put aside" them in order to give a grace period for the read
+ * sides. "free_pgtables()" kicks off an RCU activated service to reclaim the
+ * PTE, PMD and PUD pages later.
+ *
+ * Notes:
+ * - The life span of the PTE, PMD and PUD pages is rather long:
+ *   they are freed when the usage of the memory area ceases, provided no other
+ *   map (using the same PTE, PMD and PUD pages) is valid.
+ * - The number of the PTE, PMD and PUD pages is much more smaller that that of
+ *   the leaf pages.
+ * Therefore freeing them is not really performance critical.
+ */
+
+#if defined(CONFIG_SMP)
+
+/*
+ * A singly linked ring of the PTE, PMD and PUD pages, which are going to be
+ * reclaimed, is  anchored by the "pages" field.
+ * This ring is formed by use of "->lru.next".
+ * Note that "next" points at the next page structure, not at the list head.
+ */
+struct rcu_free_pte_mpd_pud_pages {
+	struct rcu_head	rcu;
+	struct page	*pages;
+};
+
+#endif
+
+/*
+ * The actual freeing service for the PTE, PMD and PUD pages.
+ *
+ * This is not a performance critical routine:
+ * - these pages are freed much less frequently than the leaf pages are
+ * - the number of these pages are much less than that of the leaf pages
+ */
+void do_free_pte_mpd_pud_pages(struct page * const first_page)
+{
+	struct page *p = first_page;
+	struct page *next;
+
+	do {
+		next = (struct page *)(p->lru.next);
+		free_page((unsigned long) page_address(p));
+//		pgtable_quicklist_free(page_address(p));
+	} while ((p = next) != first_page);
+}
+
+#if defined(CONFIG_SMP)
+
+/*
+ * This is the RCU reclaim end of freeing PTE, PMD and PUD pages on SMP systems.
+ */
+void rcu_free_pte_mpd_pud_pages(struct rcu_head *rcup)
+{
+	const struct rcu_free_pte_mpd_pud_pages * const rp =
+		container_of(rcup, struct rcu_free_pte_mpd_pud_pages, rcu);
+
+	do_free_pte_mpd_pud_pages(rp->pages);
+	kfree(rcup);
+}
+
+#endif	// #if defined(CONFIG_SMP)
+
+/*
+ * Here comes the comment explaining what "free_pgtables()" does,
+ * why, how, etc. :-)
+ *
+ * This is the RCU update end of freeing the PTE, PMD and PUD pages:
+ * The "p??_free()" subroutines do not actually set free these pages,
+ * instead, they add them onto the list "current->pages_rcu_free".
+ * For a multi-threaded process on SMP systems, the PTE, PMD and PUD pages
+ * will be set free via a "call_rcu_bh()"-activated service.
+ * The currently active reader ends are guaranteed to find their good old
+ * PTE, PMD and PUD pages at their actual physical addresses.
+ * (For kernel processes this protection is not available - you should not
+ * unmap an in-use kernel memory zone.)
+ */
 void free_pgtables(struct mmu_gather **tlb, struct vm_area_struct *vma,
 		unsigned long floor, unsigned long ceiling)
 {
+	struct mm_struct * const mm = vma->vm_mm;
+#if defined(CONFIG_SMP)
+	struct rcu_free_pte_mpd_pud_pages *rp;
+#endif
+
 	while (vma) {
 		struct vm_area_struct *next = vma->vm_next;
 		unsigned long addr = vma->vm_start;
@@ -297,6 +417,62 @@ void free_pgtables(struct mmu_gather **t
 		}
 		vma = next;
 	}
+#if defined(CONFIG_SMP)
+	/*
+	 * For a multi-threaded process on SMP systems, the PTE, PMD and PUD
+	 * pages will be set free via a "call_rcu_bh()"-activated service.
+	 * If this is the last thread => no need for this protection.
+	 * (For kernel processes, with "mm == &init_mm", this protection is not
+	 * available - you should not unmap an in-use kernel memory zone.)
+	 * Note that reading "mm_users" below is unsafe.
+	 * If the other threads exit in the mean time, than we call the RCU
+	 * service and we waste our time in vain.
+	 */
+	if (atomic_read(&mm->mm_users) <= 1 || unlikely(mm == &init_mm)){
+		if (current->pages_rcu_free != NULL){
+			do_free_pte_mpd_pud_pages(current->pages_rcu_free);
+			current->pages_rcu_free = NULL;
+		}
+		/* May happen to a multi-threaded process only: */
+		if (unlikely(mm->pages_rcu_free != NULL)){
+			do_free_pte_mpd_pud_pages(mm->pages_rcu_free);
+			mm->pages_rcu_free = NULL;
+		}
+		return;
+	}
+	/*
+	 * We get here for the multi-threaded processes only, with
+	 * (most likely) more than 1 active threads.
+	 */
+	if (likely(mm->pages_rcu_free == NULL)){
+		if (current->pages_rcu_free == NULL)
+			return;
+		mm->pages_rcu_free = current->pages_rcu_free;
+		current->pages_rcu_free = NULL;
+	} else if (current->pages_rcu_free != NULL){
+		/*
+		 * Merge the two rings. "->lru.prev" is just a temporary storage.
+		 */
+		mm->pages_rcu_free->lru.prev = current->pages_rcu_free->lru.next;
+		current->pages_rcu_free->lru.next = mm->pages_rcu_free->lru.next;
+		mm->pages_rcu_free->lru.next = mm->pages_rcu_free->lru.prev;
+		current->pages_rcu_free = NULL;
+	}
+	/*
+	 * If there is no more memory, then try to free these pages later.
+	 * At the very latest, "exit_mmap()" will be able to do it.
+	 */
+	if (unlikely((rp = kmalloc(sizeof(*rp), GFP_KERNEL)) == NULL))
+		return;
+	rp->pages = mm->pages_rcu_free;
+	mm->pages_rcu_free = NULL;
+	call_rcu_bh(&rp->rcu, rcu_free_pte_mpd_pud_pages);
+#else	// #if defined(CONFIG_SMP)
+	if (current->pages_rcu_free != NULL){
+		do_free_pte_mpd_pud_pages(current->pages_rcu_free);
+		current->pages_rcu_free = NULL;
+	}
+#endif	// #if defined(CONFIG_SMP)
 }
 
 int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
--- linux-2.6.16.9-save/arch/ia64/kernel/ivt.S	2006-04-21 09:58:55.000000000 +0200
+++ linux-2.6.16.9/arch/ia64/kernel/ivt.S	2006-05-03 15:16:10.000000000 +0200
@@ -37,6 +37,28 @@
  *
  * Table is based upon EAS2.6 (Oct 1999)
  */
+/*
+ * RCU protected page table walking.
+ * ---------------------------------
+ *
+ * (For further details see "mm/memory.c".)
+ *
+ * Page table walking is (logically) carried out as follows:
+ *
+ *	rcu_read_lock_bh();
+ *	pud_p = rcu_dereference( pgd_p[i] );
+ *	pmd_p = rcu_dereference( pud_p[j] );
+ *	pte_p = rcu_dereference( pmd_p[k] );
+ *	...
+ *	pte = *pte_p;
+ *	...
+ *	rcu_read_unlock_bh();
+ *
+ * Notes:
+ *	- the RCU read lock semantics is provided by disabling the interrupts
+ *	- "rcu_dereference()" includes "smp_read_barrier_depends()" that is a
+ *	  no-op for ia64
+ */
 
 #include <linux/config.h>
 
--- linux-2.6.16.9-save/include/asm-ia64/pgalloc.h	2006-04-21 09:59:12.000000000 +0200
+++ linux-2.6.16.9/include/asm-ia64/pgalloc.h	2006-05-03 13:39:57.000000000 +0200
@@ -76,6 +76,23 @@ static inline void pgtable_quicklist_fre
 	preempt_enable();
 }
 
+/*
+ * The PTE, PMD and PUD pages are not actually set free here.
+ * Instead, they are added onto the singly linked ring anchored by
+ * "current->pages_rcu_free". This ring is formed by use of "->lru.next".
+ * Note that "next" points at the next page structure, not at the list head.
+ */
+static inline void p___free(struct page * const p)
+{
+	if (current->pages_rcu_free == NULL){
+		current->pages_rcu_free = p;
+		p->lru.next = (struct lish_head *) p;
+	} else {
+		p->lru.next = current->pages_rcu_free->lru.next;
+		current->pages_rcu_free->lru.next = (struct lish_head *) p;
+	}
+}
+
 static inline pgd_t *pgd_alloc(struct mm_struct *mm)
 {
 	return pgtable_quicklist_alloc();
@@ -100,7 +117,7 @@ static inline pud_t *pud_alloc_one(struc
 
 static inline void pud_free(pud_t * pud)
 {
-	pgtable_quicklist_free(pud);
+	p___free(virt_to_page(pud));
 }
 #define __pud_free_tlb(tlb, pud)	pud_free(pud)
 #endif /* CONFIG_PGTABLE_4 */
@@ -118,7 +135,7 @@ static inline pmd_t *pmd_alloc_one(struc
 
 static inline void pmd_free(pmd_t * pmd)
 {
-	pgtable_quicklist_free(pmd);
+	p___free(virt_to_page(pmd));
 }
 
 #define __pmd_free_tlb(tlb, pmd)	pmd_free(pmd)
@@ -149,9 +166,14 @@ static inline pte_t *pte_alloc_one_kerne
 
 static inline void pte_free(struct page *pte)
 {
-	pgtable_quicklist_free(page_address(pte));
+	p___free(pte);
 }
 
+/*
+ * The only known usage of this function is in case of a failure in
+ * "__pte_alloc_kernel()", therefore it is not included into the "careful"
+ * page freeing mechanism.
+ */
 static inline void pte_free_kernel(pte_t * pte)
 {
 	pgtable_quicklist_free(pte);
--- linux-2.6.16.9-save/include/linux/sched.h	2006-04-21 09:59:15.000000000 +0200
+++ linux-2.6.16.9/include/linux/sched.h	2006-05-02 18:31:54.000000000 +0200
@@ -313,7 +313,10 @@ struct mm_struct {
 						 * together off init_mm.mmlist, and are protected
 						 * by mmlist_lock
 						 */
-
+	struct page *pages_rcu_free;		/* free_pgtables() collects PTE, PMD and
+						 * PUD pages - protected by mmap_sem
+						 * taken for write
+						 */
 	/* Special counters, in some configurations protected by the
 	 * page_table_lock, in other configurations by being atomic.
 	 */
@@ -871,6 +874,8 @@ struct task_struct {
 #endif
 	atomic_t fs_excl;	/* holding fs exclusive resources */
 	struct rcu_head rcu;
+	struct page *pages_rcu_free;	/* free_pgtables() collects */
+					/* PTE, PMD and PUD pages */
 };
 
 static inline pid_t process_group(struct task_struct *tsk)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
