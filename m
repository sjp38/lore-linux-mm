Subject: [RFC/PATCH] powerpc: tlb flush batch use lazy MMU mode
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Tue, 10 Apr 2007 17:09:37 +1000
Message-Id: <1176188977.8061.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>

The current tlb flush code on powerpc 64 bits has a subtle race since we
lost the page table lock due to the possible faulting in of new PTEs
after a previous one has been removed but before the corresponding hash
entry has been evicted, which can leads to all sort of fatal problems.

This patch reworks the batch code completely. It doesn't use the mmu_gather
stuff anymore. Instead, we use the lazy mmu hooks that were added by the
paravirt code. They have the nice property that the enter/leave lazy mmu
mode pair is always fully contained by the PTE lock for a given range
of PTEs. Thus we can guarantee that all batches are flushed on a given
CPU before it drops that lock.

We also generalize batching for any PTE update that require a flush.

Batching is now enabled on a CPU by arch_enter_lazy_mmu_mode() and
disabled by arch_leave_lazy_mmu_mode(). The code epects that this is
always contained within a PTE lock section so no preemption can happen
and no PTE insertion in that range from another CPU. When batching
is enabled on a CPU, every PTE updates that need a hash flush will
use the batch for that flush.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

This is a first cut at the patch, I haven't had time to test it at all
yet so it's likely to not boot at all :-) Let me know what you think
if the approach.


Index: linux-cell/arch/powerpc/kernel/process.c
===================================================================
--- linux-cell.orig/arch/powerpc/kernel/process.c	2007-04-10 16:38:40.000000000 +1000
+++ linux-cell/arch/powerpc/kernel/process.c	2007-04-10 16:38:49.000000000 +1000
@@ -305,9 +305,7 @@ struct task_struct *__switch_to(struct t
 		set_dabr(new->thread.dabr);
 		__get_cpu_var(current_dabr) = new->thread.dabr;
 	}
-
-	flush_tlb_pending();
-#endif
+#endif /* CONFIG_PPC64 */
 
 	new_thread = &new->thread;
 	old_thread = &current->thread;
Index: linux-cell/arch/powerpc/kernel/smp.c
===================================================================
--- linux-cell.orig/arch/powerpc/kernel/smp.c	2007-04-10 16:38:20.000000000 +1000
+++ linux-cell/arch/powerpc/kernel/smp.c	2007-04-10 16:38:23.000000000 +1000
@@ -428,10 +428,6 @@ void generic_mach_cpu_die(void)
 	smp_wmb();
 	while (__get_cpu_var(cpu_state) != CPU_UP_PREPARE)
 		cpu_relax();
-
-#ifdef CONFIG_PPC64
-	flush_tlb_pending();
-#endif
 	cpu_set(cpu, cpu_online_map);
 	local_irq_enable();
 }
Index: linux-cell/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-cell.orig/arch/powerpc/mm/hugetlbpage.c	2007-04-10 16:39:31.000000000 +1000
+++ linux-cell/arch/powerpc/mm/hugetlbpage.c	2007-04-10 16:52:57.000000000 +1000
@@ -316,12 +316,11 @@ void set_huge_pte_at(struct mm_struct *m
 {
 	if (pte_present(*ptep)) {
 		/* We open-code pte_clear because we need to pass the right
-		 * argument to hpte_update (huge / !huge)
+		 * argument to hpte_need_flush (huge / !huge). Might not be
+		 * necessary anymore if we make hpte_need_flush() get the
+		 * page size from the slices
 		 */
-		unsigned long old = pte_update(ptep, ~0UL);
-		if (old & _PAGE_HASHPTE)
-			hpte_update(mm, addr & HPAGE_MASK, ptep, old, 1);
-		flush_tlb_pending();
+		pte_update(mm, addr & HPAGE_MASK, ptep, ~0UL, 1);
 	}
 	*ptep = __pte(pte_val(pte) & ~_PAGE_HPTEFLAGS);
 }
@@ -329,12 +328,7 @@ void set_huge_pte_at(struct mm_struct *m
 pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 			      pte_t *ptep)
 {
-	unsigned long old = pte_update(ptep, ~0UL);
-
-	if (old & _PAGE_HASHPTE)
-		hpte_update(mm, addr & HPAGE_MASK, ptep, old, 1);
-	*ptep = __pte(0);
-
+	unsigned long old = pte_update(mm, addr, ptep, ~0UL, 1);
 	return __pte(old);
 }
 
Index: linux-cell/arch/powerpc/mm/tlb_64.c
===================================================================
--- linux-cell.orig/arch/powerpc/mm/tlb_64.c	2007-04-10 16:25:53.000000000 +1000
+++ linux-cell/arch/powerpc/mm/tlb_64.c	2007-04-10 16:56:37.000000000 +1000
@@ -120,17 +120,20 @@ void pgtable_free_tlb(struct mmu_gather 
 }
 
 /*
- * Update the MMU hash table to correspond with a change to
- * a Linux PTE.  If wrprot is true, it is permissible to
- * change the existing HPTE to read-only rather than removing it
- * (if we remove it we should clear the _PTE_HPTEFLAGS bits).
+ * A linux PTE was changed and the corresponding hash table entry
+ * neesd to be flushed. This function will either perform the flush
+ * immediately or will batch it up if the current CPU has an active
+ * batch on it.
+ *
+ * Must be called from within some kind of spinlock/non-preempt region...
  */
-void hpte_update(struct mm_struct *mm, unsigned long addr,
-		 pte_t *ptep, unsigned long pte, int huge)
+void hpte_need_flush(struct mm_struct *mm, unsigned long addr,
+		     pte_t *ptep, unsigned long pte, int huge)
 {
 	struct ppc64_tlb_batch *batch = &__get_cpu_var(ppc64_tlb_batch);
-	unsigned long vsid;
+	unsigned long vsid, vaddr;
 	unsigned int psize;
+	real_pte_t rpte;
 	int i;
 
 	i = batch->index;
@@ -151,6 +154,26 @@ void hpte_update(struct mm_struct *mm, u
 	} else
 		psize = pte_pagesize_index(pte);
 
+	/* Build full vaddr */
+	if (!is_kernel_addr(addr)) {
+		vsid = get_vsid(mm->context.id, addr);
+		WARN_ON(vsid == 0);
+	} else
+		vsid = get_kernel_vsid(addr);
+	vaddr = (vsid << 28 ) | (addr & 0x0fffffff);
+	rpte = __real_pte(__pte(pte), ptep);
+
+	/*
+	 * Check if we have an active batch on this CPU. If not, just
+	 * flush now and return. For now, we don global invalidates
+	 * in that case, might be worth testing the mm cpu mask though
+	 * and decide to use local invalidates instead...
+	 */
+	if (!batch->active) {
+		flush_hash_page(vaddr, rpte, psize, 0);
+		return;
+	}
+
 	/*
 	 * This can happen when we are in the middle of a TLB batch and
 	 * we encounter memory pressure (eg copy_page_range when it tries
@@ -162,47 +185,42 @@ void hpte_update(struct mm_struct *mm, u
 	 * batch
 	 */
 	if (i != 0 && (mm != batch->mm || batch->psize != psize)) {
-		flush_tlb_pending();
+		__flush_tlb_pending(batch);
 		i = 0;
 	}
 	if (i == 0) {
 		batch->mm = mm;
 		batch->psize = psize;
 	}
-	if (!is_kernel_addr(addr)) {
-		vsid = get_vsid(mm->context.id, addr);
-		WARN_ON(vsid == 0);
-	} else
-		vsid = get_kernel_vsid(addr);
-	batch->vaddr[i] = (vsid << 28 ) | (addr & 0x0fffffff);
-	batch->pte[i] = __real_pte(__pte(pte), ptep);
+	batch->pte[i] = rpte;
+	batch->vaddr[i] = vaddr;
 	batch->index = ++i;
 	if (i >= PPC64_TLB_BATCH_NR)
-		flush_tlb_pending();
+		__flush_tlb_pending(batch);
 }
 
+/*
+ * This function is called when terminating an mmu batch or when a batch
+ * is full. It will perform the flush of all the entries currently stored
+ * in a batch.
+ *
+ * Must be called from within some kind of spinlock/non-preempt region...
+ */
 void __flush_tlb_pending(struct ppc64_tlb_batch *batch)
 {
-	int i;
-	int cpu;
 	cpumask_t tmp;
-	int local = 0;
+	int i, local = 0;
 
-	BUG_ON(in_interrupt());
-
-	cpu = get_cpu();
 	i = batch->index;
-	tmp = cpumask_of_cpu(cpu);
+	tmp = cpumask_of_cpu(smp_processor_id());
 	if (cpus_equal(batch->mm->cpu_vm_mask, tmp))
 		local = 1;
-
 	if (i == 1)
 		flush_hash_page(batch->vaddr[0], batch->pte[0],
 				batch->psize, local);
 	else
 		flush_hash_range(i, local);
 	batch->index = 0;
-	put_cpu();
 }
 
 void pte_free_finish(void)
Index: linux-cell/include/asm-powerpc/pgtable.h
===================================================================
--- linux-cell.orig/include/asm-powerpc/pgtable.h	2007-04-10 16:16:14.000000000 +1000
+++ linux-cell/include/asm-powerpc/pgtable.h	2007-04-10 16:54:53.000000000 +1000
@@ -272,7 +272,10 @@ static inline pte_t pte_mkhuge(pte_t pte
 	return pte; }
 
 /* Atomic PTE updates */
-static inline unsigned long pte_update(pte_t *p, unsigned long clr)
+static inline unsigned long pte_update(struct mm_struct *mm,
+				       unsigned long addr,
+				       pte_t *ptep, unsigned long clr,
+				       int huge)
 {
 	unsigned long old, tmp;
 
@@ -283,20 +286,15 @@ static inline unsigned long pte_update(p
 	andc	%1,%0,%4 \n\
 	stdcx.	%1,0,%3 \n\
 	bne-	1b"
-	: "=&r" (old), "=&r" (tmp), "=m" (*p)
-	: "r" (p), "r" (clr), "m" (*p), "i" (_PAGE_BUSY)
+	: "=&r" (old), "=&r" (tmp), "=m" (*ptep)
+	: "r" (ptep), "r" (clr), "m" (*ptep), "i" (_PAGE_BUSY)
 	: "cc" );
+
+	if (old & _PAGE_HASHPTE)
+		hpte_need_flush(mm, addr, ptep, old, huge);
 	return old;
 }
 
-/* PTE updating functions, this function puts the PTE in the
- * batch, doesn't actually triggers the hash flush immediately,
- * you need to call flush_tlb_pending() to do that.
- * Pass -1 for "normal" size (4K or 64K)
- */
-extern void hpte_update(struct mm_struct *mm, unsigned long addr,
-			pte_t *ptep, unsigned long pte, int huge);
-
 static inline int __ptep_test_and_clear_young(struct mm_struct *mm,
 					      unsigned long addr, pte_t *ptep)
 {
@@ -304,11 +302,7 @@ static inline int __ptep_test_and_clear_
 
        	if ((pte_val(*ptep) & (_PAGE_ACCESSED | _PAGE_HASHPTE)) == 0)
 		return 0;
-	old = pte_update(ptep, _PAGE_ACCESSED);
-	if (old & _PAGE_HASHPTE) {
-		hpte_update(mm, addr, ptep, old, 0);
-		flush_tlb_pending();
-	}
+	old = pte_update(mm, addr, ptep, _PAGE_ACCESSED, 0);
 	return (old & _PAGE_ACCESSED) != 0;
 }
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
@@ -331,9 +325,7 @@ static inline int __ptep_test_and_clear_
 
        	if ((pte_val(*ptep) & _PAGE_DIRTY) == 0)
 		return 0;
-	old = pte_update(ptep, _PAGE_DIRTY);
-	if (old & _PAGE_HASHPTE)
-		hpte_update(mm, addr, ptep, old, 0);
+	old = pte_update(mm, addr, ptep, _PAGE_DIRTY, 0);
 	return (old & _PAGE_DIRTY) != 0;
 }
 #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_DIRTY
@@ -352,9 +344,7 @@ static inline void ptep_set_wrprotect(st
 
        	if ((pte_val(*ptep) & _PAGE_RW) == 0)
        		return;
-	old = pte_update(ptep, _PAGE_RW);
-	if (old & _PAGE_HASHPTE)
-		hpte_update(mm, addr, ptep, old, 0);
+	old = pte_update(mm, addr, ptep, _PAGE_RW, 0);
 }
 
 /*
@@ -378,7 +368,6 @@ static inline void ptep_set_wrprotect(st
 ({									\
 	int __dirty = __ptep_test_and_clear_dirty((__vma)->vm_mm, __address, \
 						  __ptep); 		\
-	flush_tlb_page(__vma, __address);				\
 	__dirty;							\
 })
 
@@ -386,20 +375,14 @@ static inline void ptep_set_wrprotect(st
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 				       unsigned long addr, pte_t *ptep)
 {
-	unsigned long old = pte_update(ptep, ~0UL);
-
-	if (old & _PAGE_HASHPTE)
-		hpte_update(mm, addr, ptep, old, 0);
+	unsigned long old = pte_update(mm, addr, ptep, ~0UL, 0);
 	return __pte(old);
 }
 
 static inline void pte_clear(struct mm_struct *mm, unsigned long addr,
 			     pte_t * ptep)
 {
-	unsigned long old = pte_update(ptep, ~0UL);
-
-	if (old & _PAGE_HASHPTE)
-		hpte_update(mm, addr, ptep, old, 0);
+	pte_update(mm, addr, ptep, ~0UL, 0);
 }
 
 /*
@@ -408,10 +391,8 @@ static inline void pte_clear(struct mm_s
 static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 			      pte_t *ptep, pte_t pte)
 {
-	if (pte_present(*ptep)) {
+	if (pte_present(*ptep))
 		pte_clear(mm, addr, ptep);
-		flush_tlb_pending();
-	}
 	pte = __pte(pte_val(pte) & ~_PAGE_HPTEFLAGS);
 	*ptep = pte;
 }
@@ -522,6 +503,7 @@ void pgtable_cache_init(void);
 	return pt;
 }
 
+
 #include <asm-generic/pgtable.h>
 
 #endif /* __ASSEMBLY__ */
Index: linux-cell/include/asm-powerpc/tlbflush.h
===================================================================
--- linux-cell.orig/include/asm-powerpc/tlbflush.h	2007-04-10 16:18:39.000000000 +1000
+++ linux-cell/include/asm-powerpc/tlbflush.h	2007-04-10 16:55:23.000000000 +1000
@@ -28,25 +28,41 @@ struct mm_struct;
 #define PPC64_TLB_BATCH_NR 192
 
 struct ppc64_tlb_batch {
-	unsigned long index;
-	struct mm_struct *mm;
-	real_pte_t pte[PPC64_TLB_BATCH_NR];
-	unsigned long vaddr[PPC64_TLB_BATCH_NR];
-	unsigned int psize;
+	int			active;
+	unsigned long		index;
+	struct mm_struct	*mm;
+	real_pte_t		pte[PPC64_TLB_BATCH_NR];
+	unsigned long		vaddr[PPC64_TLB_BATCH_NR];
+	unsigned int		psize;
 };
 DECLARE_PER_CPU(struct ppc64_tlb_batch, ppc64_tlb_batch);
 
 extern void __flush_tlb_pending(struct ppc64_tlb_batch *batch);
 
-static inline void flush_tlb_pending(void)
+extern void hpte_need_flush(struct mm_struct *mm, unsigned long addr,
+			    pte_t *ptep, unsigned long pte, int huge);
+
+#define __HAVE_ARCH_ENTER_LAZY_MMU_MODE
+
+static inline void arch_enter_lazy_mmu_mode(void)
 {
-	struct ppc64_tlb_batch *batch = &get_cpu_var(ppc64_tlb_batch);
+	struct ppc64_tlb_batch *batch = &__get_cpu_var(ppc64_tlb_batch);
+
+	batch->active = 1;
+}
+
+static inline void arch_leave_lazy_mmu_mode(void)
+{
+	struct ppc64_tlb_batch *batch = &__get_cpu_var(ppc64_tlb_batch);
 
 	if (batch->index)
 		__flush_tlb_pending(batch);
-	put_cpu_var(ppc64_tlb_batch);
+	batch->active = 0;
 }
 
+#define arch_flush_lazy_mmu_mode()      do {} while (0)
+
+
 extern void flush_hash_page(unsigned long va, real_pte_t pte, int psize,
 			    int local);
 extern void flush_hash_range(unsigned long number, int local);
@@ -88,15 +104,12 @@ extern void update_mmu_cache(struct vm_a
 
 static inline void flush_tlb_mm(struct mm_struct *mm)
 {
-	flush_tlb_pending();
 }
 
 static inline void flush_tlb_page(struct vm_area_struct *vma,
 				unsigned long vmaddr)
 {
-#ifdef CONFIG_PPC64
-	flush_tlb_pending();
-#else
+#ifndef CONFIG_PPC64
 	_tlbie(vmaddr);
 #endif
 }
@@ -112,13 +125,11 @@ static inline void flush_tlb_page_nohash
 static inline void flush_tlb_range(struct vm_area_struct *vma,
 		unsigned long start, unsigned long end)
 {
-	flush_tlb_pending();
 }
 
 static inline void flush_tlb_kernel_range(unsigned long start,
 		unsigned long end)
 {
-	flush_tlb_pending();
 }
 
 #else	/* 6xx, 7xx, 7xxx cpus */
Index: linux-cell/include/asm-powerpc/tlb.h
===================================================================
--- linux-cell.orig/include/asm-powerpc/tlb.h	2007-04-10 16:55:49.000000000 +1000
+++ linux-cell/include/asm-powerpc/tlb.h	2007-04-10 16:55:53.000000000 +1000
@@ -38,7 +38,6 @@ extern void pte_free_finish(void);
 
 static inline void tlb_flush(struct mmu_gather *tlb)
 {
-	flush_tlb_pending();
 	pte_free_finish();
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
