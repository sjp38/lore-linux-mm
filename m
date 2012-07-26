Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 8F5D06B0044
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 11:48:03 -0400 (EDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 26 Jul 2012 16:48:01 +0100
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1507.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6QFlxcN2854968
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 16:47:59 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6QFlwVa006844
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 09:47:58 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 2/2] s390/tlb: race of lazy TLB flush vs. recreation of TLB entries
Date: Thu, 26 Jul 2012 17:47:14 +0200
Message-Id: <1343317634-13197-3-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1343317634-13197-1-git-send-email-schwidefsky@de.ibm.com>
References: <1343317634-13197-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, Zachary Amsden <zach@vmware.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>

Git commit 050eef364ad70059 "[S390] fix tlb flushing vs. concurrent
/proc accesses" introduced the attach counter to avoid using the
mm_users value to decide between IPTE for every PTE and lazy TLB
flushing with IDTE. That fixed the problem with mm_users but it
introduced another subtle race, fortunately one that is very hard
to hit.
The background is the requirement of the architecture that a valid
PTE may not be changed while it can be used concurrently by another
cpu. Ergo the decision between IPTE and lazy TLB flushing needs to
be done while the PTE is still valid. Now if the virtual cpu is
temporarily stopped after the decision to use lazy TLB flushing but
before the invalid bit of the PTE has been set, another cpu can attach
the mm, find that flush_mm is set, do the IDTE, return to userspace,
and recreate a TLB that uses the PTE in question. When the first,
stopped cpu continues it will change the PTE while it is attached on
another cpu. The first cpu will do another IDTE shortly after the
modification of the PTE which makes the race window quite short.

To fix this the attach of an mm needs to be delayed until the PTE
modification is complete. To do that the lazy mmu mode hooks are
used and some compare-and-swap magic on the attach counter.

Reviewed-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/include/asm/hugetlb.h     |   24 ++++++++-----------
 arch/s390/include/asm/mmu_context.h |   13 ++++++++---
 arch/s390/include/asm/pgtable.h     |   43 ++++++++++++++++++++++-------------
 arch/s390/include/asm/tlb.h         |    3 ++-
 arch/s390/include/asm/tlbflush.h    |    8 +++----
 arch/s390/mm/pgtable.c              |    6 ++---
 6 files changed, 55 insertions(+), 42 deletions(-)

diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index 799ed0f..2d6e6e3 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -66,16 +66,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return pte;
 }
 
-static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
-					    unsigned long addr, pte_t *ptep)
-{
-	pte_t pte = huge_ptep_get(ptep);
-
-	mm->context.flush_mm = 1;
-	pmd_clear((pmd_t *) ptep);
-	return pte;
-}
-
 static inline void __pmd_csp(pmd_t *pmdp)
 {
 	register unsigned long reg2 asm("2") = pmd_val(*pmdp);
@@ -117,6 +107,15 @@ static inline void huge_ptep_invalidate(struct mm_struct *mm,
 		__pmd_csp(pmdp);
 }
 
+static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
+					    unsigned long addr, pte_t *ptep)
+{
+	pte_t pte = huge_ptep_get(ptep);
+
+	huge_ptep_invalidate(mm, addr, ptep);
+	return pte;
+}
+
 #define huge_ptep_set_access_flags(__vma, __addr, __ptep, __entry, __dirty) \
 ({									    \
 	int __changed = !pte_same(huge_ptep_get(__ptep), __entry);	    \
@@ -131,10 +130,7 @@ static inline void huge_ptep_invalidate(struct mm_struct *mm,
 ({									\
 	pte_t __pte = huge_ptep_get(__ptep);				\
 	if (pte_write(__pte)) {						\
-		(__mm)->context.flush_mm = 1;				\
-		if (atomic_read(&(__mm)->context.attach_count) > 1 ||	\
-		    (__mm) != current->active_mm)			\
-			huge_ptep_invalidate(__mm, __addr, __ptep);	\
+		huge_ptep_invalidate(__mm, __addr, __ptep);		\
 		set_huge_pte_at(__mm, __addr, __ptep,			\
 				huge_pte_wrprotect(__pte));		\
 	}								\
diff --git a/arch/s390/include/asm/mmu_context.h b/arch/s390/include/asm/mmu_context.h
index 5c63615..2276106 100644
--- a/arch/s390/include/asm/mmu_context.h
+++ b/arch/s390/include/asm/mmu_context.h
@@ -72,14 +72,21 @@ static inline void update_mm(struct mm_struct *mm, struct task_struct *tsk)
 static inline void switch_mm(struct mm_struct *prev, struct mm_struct *next,
 			     struct task_struct *tsk)
 {
+	int v;
+
 	cpumask_set_cpu(smp_processor_id(), mm_cpumask(next));
 	update_mm(next, tsk);
 	atomic_dec(&prev->context.attach_count);
 	WARN_ON(atomic_read(&prev->context.attach_count) < 0);
-	atomic_inc(&next->context.attach_count);
+	while (1) {
+		v = atomic_read(&next->context.attach_count);
+		if ((v & 0xffff0000) && (v & 0xffff) <= 1)
+			continue;
+		if (atomic_cmpxchg(&next->context.attach_count, v, v + 1) == v)
+			break;
+	}
 	/* Check for TLBs not flushed yet */
-	if (next->context.flush_mm)
-		__tlb_flush_mm(next);
+	__tlb_flush_mm_lazy(next);
 }
 
 #define enter_lazy_tlb(mm,tsk)	do { } while (0)
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 6bd7d74..808824d 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -405,12 +405,6 @@ extern struct page *vmemmap;
 #define __S110	PAGE_RW
 #define __S111	PAGE_RW
 
-static inline int mm_exclusive(struct mm_struct *mm)
-{
-	return likely(mm == current->active_mm &&
-		      atomic_read(&mm->context.attach_count) <= 1);
-}
-
 static inline int mm_has_pgste(struct mm_struct *mm)
 {
 #ifdef CONFIG_PGSTE
@@ -933,6 +927,29 @@ static inline void __ptep_ipte(unsigned long address, pte_t *ptep)
 	}
 }
 
+#define __HAVE_ARCH_ENTER_LAZY_MMU_MODE
+
+static inline void arch_enter_lazy_mmu_mode(struct mm_struct *mm)
+{
+	atomic_add(0x10000, &mm->context.attach_count);
+}
+
+static inline void arch_leave_lazy_mmu_mode(struct mm_struct *mm)
+{
+	atomic_sub(0x10000, &mm->context.attach_count);
+}
+
+static inline void ptep_flush_lazy(struct mm_struct *mm,
+				   unsigned long address, pte_t *ptep)
+{
+	int active = (mm == current->active_mm) ? 1 : 0;
+
+	if ((atomic_read(&mm->context.attach_count) & 0xffff) > active)
+		__ptep_ipte(address, ptep);
+	else
+		mm->context.flush_mm = 1;
+}
+
 /*
  * This is hard to understand. ptep_get_and_clear and ptep_clear_flush
  * both clear the TLB for the unmapped pte. The reason is that
@@ -953,13 +970,11 @@ static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 	pgste_t pgste;
 	pte_t pte;
 
-	mm->context.flush_mm = 1;
 	if (mm_has_pgste(mm))
 		pgste = pgste_get_lock(ptep);
 
 	pte = *ptep;
-	if (!mm_exclusive(mm))
-		__ptep_ipte(address, ptep);
+	ptep_flush_lazy(mm, address, ptep);
 	pte_val(*ptep) = _PAGE_TYPE_EMPTY;
 
 	if (mm_has_pgste(mm)) {
@@ -976,13 +991,11 @@ static inline pte_t ptep_modify_prot_start(struct mm_struct *mm,
 {
 	pte_t pte;
 
-	mm->context.flush_mm = 1;
 	if (mm_has_pgste(mm))
 		pgste_get_lock(ptep);
 
 	pte = *ptep;
-	if (!mm_exclusive(mm))
-		__ptep_ipte(address, ptep);
+	ptep_flush_lazy(mm, address, ptep);
 	return pte;
 }
 
@@ -1036,7 +1049,7 @@ static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
 
 	pte = *ptep;
 	if (!full)
-		__ptep_ipte(address, ptep);
+		ptep_flush_lazy(mm, address, ptep);
 	pte_val(*ptep) = _PAGE_TYPE_EMPTY;
 
 	if (mm_has_pgste(mm)) {
@@ -1054,12 +1067,10 @@ static inline pte_t ptep_set_wrprotect(struct mm_struct *mm,
 	pte_t pte = *ptep;
 
 	if (pte_write(pte)) {
-		mm->context.flush_mm = 1;
 		if (mm_has_pgste(mm))
 			pgste = pgste_get_lock(ptep);
 
-		if (!mm_exclusive(mm))
-			__ptep_ipte(address, ptep);
+		ptep_flush_lazy(mm, address, ptep);
 		*ptep = pte_wrprotect(pte);
 
 		if (mm_has_pgste(mm))
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 06e5acb..40cec46 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -59,13 +59,14 @@ static inline void tlb_gather_mmu(struct mmu_gather *tlb,
 
 static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
+	__tlb_flush_mm_lazy(tlb->mm);
 	tlb_table_flush(tlb);
 }
 
 static inline void tlb_finish_mmu(struct mmu_gather *tlb,
 				  unsigned long start, unsigned long end)
 {
-	tlb_table_flush(tlb);
+	tlb_flush_mmu(tlb);
 }
 
 /*
diff --git a/arch/s390/include/asm/tlbflush.h b/arch/s390/include/asm/tlbflush.h
index 9fde315..1de9f51 100644
--- a/arch/s390/include/asm/tlbflush.h
+++ b/arch/s390/include/asm/tlbflush.h
@@ -88,14 +88,12 @@ static inline void __tlb_flush_mm(struct mm_struct * mm)
 		__tlb_flush_full(mm);
 }
 
-static inline void __tlb_flush_mm_cond(struct mm_struct * mm)
+static inline void __tlb_flush_mm_lazy(struct mm_struct * mm)
 {
-	spin_lock(&mm->page_table_lock);
 	if (mm->context.flush_mm) {
 		__tlb_flush_mm(mm);
 		mm->context.flush_mm = 0;
 	}
-	spin_unlock(&mm->page_table_lock);
 }
 
 /*
@@ -122,13 +120,13 @@ static inline void __tlb_flush_mm_cond(struct mm_struct * mm)
 
 static inline void flush_tlb_mm(struct mm_struct *mm)
 {
-	__tlb_flush_mm_cond(mm);
+	__tlb_flush_mm_lazy(mm);
 }
 
 static inline void flush_tlb_range(struct vm_area_struct *vma,
 				   unsigned long start, unsigned long end)
 {
-	__tlb_flush_mm_cond(vma->vm_mm);
+	__tlb_flush_mm_lazy(vma->vm_mm);
 }
 
 static inline void flush_tlb_kernel_range(unsigned long start,
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 1cab221..cecf8c8 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -767,7 +767,6 @@ void tlb_table_flush(struct mmu_gather *tlb)
 	struct mmu_table_batch **batch = &tlb->batch;
 
 	if (*batch) {
-		__tlb_flush_mm(tlb->mm);
 		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
 		*batch = NULL;
 	}
@@ -777,11 +776,12 @@ void tlb_remove_table(struct mmu_gather *tlb, void *table)
 {
 	struct mmu_table_batch **batch = &tlb->batch;
 
+	tlb->mm->context.flush_mm = 1;
 	if (*batch == NULL) {
 		*batch = (struct mmu_table_batch *)
 			__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
 		if (*batch == NULL) {
-			__tlb_flush_mm(tlb->mm);
+			__tlb_flush_mm_lazy(tlb->mm);
 			tlb_remove_table_one(table);
 			return;
 		}
@@ -789,7 +789,7 @@ void tlb_remove_table(struct mmu_gather *tlb, void *table)
 	}
 	(*batch)->tables[(*batch)->nr++] = table;
 	if ((*batch)->nr == MAX_TABLE_BATCH)
-		tlb_table_flush(tlb);
+		tlb_flush_mmu(tlb);
 }
 
 /*
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
