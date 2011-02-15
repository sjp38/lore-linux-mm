Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5388D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 10:39:49 -0500 (EST)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate7.uk.ibm.com (8.13.1/8.13.1) with ESMTP id p1FFdjnj027763
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 15:39:45 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1FFdgvS1900558
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 15:39:51 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1FFdaod008141
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 08:39:36 -0700
Date: Tue, 15 Feb 2011 16:39:48 +0100
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH 00/21] mm: Preemptibility -v6
Message-ID: <20110215163948.429be561@mschwide.boeblingen.de.ibm.com>
In-Reply-To: <20110215150017.498fda48@mschwide.boeblingen.de.ibm.com>
References: <20101126143843.801484792@chello.nl>
	<alpine.LSU.2.00.1101172301340.2899@sister.anvils>
	<1295457039.28776.137.camel@laptop>
	<20110215150017.498fda48@mschwide.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@kernel.dk>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>

On Tue, 15 Feb 2011 15:00:17 +0100
Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> On Wed, 19 Jan 2011 18:10:39 +0100
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > Martin, while doing the below DEFINE_PER_CPU removal I saw you had a
> > bunch of RCU table removal thingies in arch/s390/mm/pgtable.c, could
> > s390 use the generic bits like sparc and powerpc (see patch 16)?
> 
> That should do it. 229 deletions vs. 74 insertions, not bad. And the
> tlb flushing code actually got simpler. Even better :-)

Darn, forgot "quilt refresh". The last patch I've sent is the old,
broken one. This one is better..

--
Subject: [PATCH] s390: use generic RCP page-table freeing

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

Now that we have a generic implementation for RCU based page table
freeing, use it for s390 as well. It saves a couple of lines.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/Kconfig               |    1 
 arch/s390/include/asm/pgalloc.h |   19 +--
 arch/s390/include/asm/tlb.h     |   91 ++++++++----------
 arch/s390/mm/pgtable.c          |  192 +++++-----------------------------------
 4 files changed, 74 insertions(+), 229 deletions(-)

--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -87,6 +87,7 @@ config S390
 	select HAVE_KERNEL_LZO
 	select HAVE_GET_USER_PAGES_FAST
 	select HAVE_ARCH_MUTEX_CPU_RELAX
+	select HAVE_RCU_TABLE_FREE
 	select ARCH_INLINE_SPIN_TRYLOCK
 	select ARCH_INLINE_SPIN_TRYLOCK_BH
 	select ARCH_INLINE_SPIN_LOCK
--- a/arch/s390/include/asm/pgalloc.h
+++ b/arch/s390/include/asm/pgalloc.h
@@ -20,12 +20,11 @@
 #define check_pgt_cache()	do {} while (0)
 
 unsigned long *crst_table_alloc(struct mm_struct *, int);
-void crst_table_free(struct mm_struct *, unsigned long *);
-void crst_table_free_rcu(struct mm_struct *, unsigned long *);
+void crst_table_free(unsigned long *);
 
 unsigned long *page_table_alloc(struct mm_struct *);
-void page_table_free(struct mm_struct *, unsigned long *);
-void page_table_free_rcu(struct mm_struct *, unsigned long *);
+void page_table_free(unsigned long *);
+
 void disable_noexec(struct mm_struct *, struct task_struct *);
 
 static inline void clear_table(unsigned long *s, unsigned long val, size_t n)
@@ -95,7 +94,7 @@ static inline pud_t *pud_alloc_one(struc
 		crst_table_init(table, _REGION3_ENTRY_EMPTY);
 	return (pud_t *) table;
 }
-#define pud_free(mm, pud) crst_table_free(mm, (unsigned long *) pud)
+#define pud_free(mm, pud) crst_table_free((unsigned long *) pud)
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long vmaddr)
 {
@@ -104,7 +103,7 @@ static inline pmd_t *pmd_alloc_one(struc
 		crst_table_init(table, _SEGMENT_ENTRY_EMPTY);
 	return (pmd_t *) table;
 }
-#define pmd_free(mm, pmd) crst_table_free(mm, (unsigned long *) pmd)
+#define pmd_free(mm, pmd) crst_table_free((unsigned long *) pmd)
 
 static inline void pgd_populate_kernel(struct mm_struct *mm,
 				       pgd_t *pgd, pud_t *pud)
@@ -148,7 +147,7 @@ static inline pgd_t *pgd_alloc(struct mm
 	return (pgd_t *)
 		crst_table_alloc(mm, user_mode == SECONDARY_SPACE_MODE);
 }
-#define pgd_free(mm, pgd) crst_table_free(mm, (unsigned long *) pgd)
+#define pgd_free(mm, pgd) crst_table_free((unsigned long *) pgd)
 
 static inline void pmd_populate_kernel(struct mm_struct *mm,
 				       pmd_t *pmd, pte_t *pte)
@@ -175,9 +174,7 @@ static inline void pmd_populate(struct m
 #define pte_alloc_one_kernel(mm, vmaddr) ((pte_t *) page_table_alloc(mm))
 #define pte_alloc_one(mm, vmaddr) ((pte_t *) page_table_alloc(mm))
 
-#define pte_free_kernel(mm, pte) page_table_free(mm, (unsigned long *) pte)
-#define pte_free(mm, pte) page_table_free(mm, (unsigned long *) pte)
-
-extern void rcu_table_freelist_finish(void);
+#define pte_free_kernel(mm, pte) page_table_free((unsigned long *) pte)
+#define pte_free(mm, pte) page_table_free((unsigned long *) pte)
 
 #endif /* _S390_PGALLOC_H */
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -29,50 +29,42 @@
 #include <asm/smp.h>
 #include <asm/tlbflush.h>
 
+struct mmu_table_batch {
+	struct rcu_head rcu;
+	unsigned int nr;
+	void *tables[0];
+};
+
+#define MAX_TABLE_BATCH \
+	((PAGE_SIZE - sizeof(struct mmu_table_batch)) / sizeof(void *))
+
+void tlb_table_flush(struct mmu_gather *);
+void tlb_remove_table(struct mmu_gather *, void *);
+
 struct mmu_gather {
 	struct mm_struct *mm;
 	unsigned int fullmm;
-	unsigned int nr_ptes;
-	unsigned int nr_pxds;
-	unsigned int max;
-	void **array;
-	void *local[8];
+	struct mmu_table_batch *batch;
+	/* need_flush is used only for page tables */
+	unsigned int need_flush : 1;
 };
 
-static inline void __tlb_alloc_page(struct mmu_gather *tlb)
-{
-	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
-
-	if (addr) {
-		tlb->array = (void *) addr;
-		tlb->max = PAGE_SIZE / sizeof(void *);
-	}
-}
-
 static inline void tlb_gather_mmu(struct mmu_gather *tlb,
 				  struct mm_struct *mm,
 				  unsigned int full_mm_flush)
 {
 	tlb->mm = mm;
-	tlb->max = ARRAY_SIZE(tlb->local);
-	tlb->array = tlb->local;
 	tlb->fullmm = full_mm_flush;
 	if (tlb->fullmm)
 		__tlb_flush_mm(mm);
-	else
-		__tlb_alloc_page(tlb);
-	tlb->nr_ptes = 0;
-	tlb->nr_pxds = tlb->max;
+	tlb->batch = NULL;
+	tlb->need_flush = 0;
 }
 
 static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 {
-	if (!tlb->fullmm && (tlb->nr_ptes > 0 || tlb->nr_pxds < tlb->max))
-		__tlb_flush_mm(tlb->mm);
-	while (tlb->nr_ptes > 0)
-		page_table_free_rcu(tlb->mm, tlb->array[--tlb->nr_ptes]);
-	while (tlb->nr_pxds < tlb->max)
-		crst_table_free_rcu(tlb->mm, tlb->array[tlb->nr_pxds++]);
+	if (tlb->need_flush)
+		tlb_table_flush(tlb);
 }
 
 static inline void tlb_finish_mmu(struct mmu_gather *tlb,
@@ -80,13 +72,8 @@ static inline void tlb_finish_mmu(struct
 {
 	tlb_flush_mmu(tlb);
 
-	rcu_table_freelist_finish();
-
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
-
-	if (tlb->array != tlb->local)
-		free_pages((unsigned long) tlb->array, 0);
 }
 
 /*
@@ -113,12 +100,11 @@ static inline void tlb_remove_page(struc
 static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
 				unsigned long address)
 {
-	if (!tlb->fullmm) {
-		tlb->array[tlb->nr_ptes++] = pte;
-		if (tlb->nr_ptes >= tlb->nr_pxds)
-			tlb_flush_mmu(tlb);
-	} else
-		page_table_free(tlb->mm, (unsigned long *) pte);
+	if (!tlb->fullmm)
+		/* Use LSB to distinguish crst table vs. page table */
+		tlb_remove_table(tlb, (void *) pte + 1);
+	else
+		page_table_free((unsigned long *) pte);
 }
 
 /*
@@ -134,12 +120,10 @@ static inline void pmd_free_tlb(struct m
 #ifdef __s390x__
 	if (tlb->mm->context.asce_limit <= (1UL << 31))
 		return;
-	if (!tlb->fullmm) {
-		tlb->array[--tlb->nr_pxds] = pmd;
-		if (tlb->nr_ptes >= tlb->nr_pxds)
-			tlb_flush_mmu(tlb);
-	} else
-		crst_table_free(tlb->mm, (unsigned long *) pmd);
+	if (!tlb->fullmm)
+		tlb_remove_table(tlb, pmd);
+	else
+		crst_table_free((unsigned long *) pmd);
 #endif
 }
 
@@ -156,15 +140,22 @@ static inline void pud_free_tlb(struct m
 #ifdef __s390x__
 	if (tlb->mm->context.asce_limit <= (1UL << 42))
 		return;
-	if (!tlb->fullmm) {
-		tlb->array[--tlb->nr_pxds] = pud;
-		if (tlb->nr_ptes >= tlb->nr_pxds)
-			tlb_flush_mmu(tlb);
-	} else
-		crst_table_free(tlb->mm, (unsigned long *) pud);
+	if (!tlb->fullmm)
+		tlb_remove_table(tlb, pud);
+	else
+		crst_table_free((unsigned long *) pud);
 #endif
 }
 
+static inline void __tlb_remove_table(void *table)
+{
+	/* Use LSB to distinguish crst table vs. page table */
+	if ((unsigned long) table & 1)
+		page_table_free(table - 1);
+	else
+		crst_table_free(table);
+}
+
 #define tlb_start_vma(tlb, vma)			do { } while (0)
 #define tlb_end_vma(tlb, vma)			do { } while (0)
 #define tlb_remove_tlb_entry(tlb, ptep, addr)	do { } while (0)
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -24,92 +24,17 @@
 #include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
 
-struct rcu_table_freelist {
-	struct rcu_head rcu;
-	struct mm_struct *mm;
-	unsigned int pgt_index;
-	unsigned int crst_index;
-	unsigned long *table[0];
-};
-
-#define RCU_FREELIST_SIZE \
-	((PAGE_SIZE - sizeof(struct rcu_table_freelist)) \
-	  / sizeof(unsigned long))
-
-static DEFINE_PER_CPU(struct rcu_table_freelist *, rcu_table_freelist);
-
-static void __page_table_free(struct mm_struct *mm, unsigned long *table);
-static void __crst_table_free(struct mm_struct *mm, unsigned long *table);
-
-static struct rcu_table_freelist *rcu_table_freelist_get(struct mm_struct *mm)
-{
-	struct rcu_table_freelist **batchp = &__get_cpu_var(rcu_table_freelist);
-	struct rcu_table_freelist *batch = *batchp;
-
-	if (batch)
-		return batch;
-	batch = (struct rcu_table_freelist *) __get_free_page(GFP_ATOMIC);
-	if (batch) {
-		batch->mm = mm;
-		batch->pgt_index = 0;
-		batch->crst_index = RCU_FREELIST_SIZE;
-		*batchp = batch;
-	}
-	return batch;
-}
-
-static void rcu_table_freelist_callback(struct rcu_head *head)
-{
-	struct rcu_table_freelist *batch =
-		container_of(head, struct rcu_table_freelist, rcu);
-
-	while (batch->pgt_index > 0)
-		__page_table_free(batch->mm, batch->table[--batch->pgt_index]);
-	while (batch->crst_index < RCU_FREELIST_SIZE)
-		__crst_table_free(batch->mm, batch->table[batch->crst_index++]);
-	free_page((unsigned long) batch);
-}
-
-void rcu_table_freelist_finish(void)
-{
-	struct rcu_table_freelist *batch = __get_cpu_var(rcu_table_freelist);
-
-	if (!batch)
-		return;
-	call_rcu(&batch->rcu, rcu_table_freelist_callback);
-	__get_cpu_var(rcu_table_freelist) = NULL;
-}
-
-static void smp_sync(void *arg)
-{
-}
 
 #ifndef CONFIG_64BIT
 #define ALLOC_ORDER	1
 #define TABLES_PER_PAGE	4
 #define FRAG_MASK	15UL
 #define SECOND_HALVES	10UL
-
-void clear_table_pgstes(unsigned long *table)
-{
-	clear_table(table, _PAGE_TYPE_EMPTY, PAGE_SIZE/4);
-	memset(table + 256, 0, PAGE_SIZE/4);
-	clear_table(table + 512, _PAGE_TYPE_EMPTY, PAGE_SIZE/4);
-	memset(table + 768, 0, PAGE_SIZE/4);
-}
-
 #else
 #define ALLOC_ORDER	2
 #define TABLES_PER_PAGE	2
 #define FRAG_MASK	3UL
 #define SECOND_HALVES	2UL
-
-void clear_table_pgstes(unsigned long *table)
-{
-	clear_table(table, _PAGE_TYPE_EMPTY, PAGE_SIZE/2);
-	memset(table + 256, 0, PAGE_SIZE/2);
-}
-
 #endif
 
 unsigned long VMALLOC_START = VMALLOC_END - VMALLOC_SIZE;
@@ -138,6 +63,7 @@ unsigned long *crst_table_alloc(struct m
 			return NULL;
 		}
 		page->index = page_to_phys(shadow);
+		page->private = (unsigned long) mm;
 	}
 	spin_lock_bh(&mm->context.list_lock);
 	list_add(&page->lru, &mm->context.crst_list);
@@ -145,47 +71,19 @@ unsigned long *crst_table_alloc(struct m
 	return (unsigned long *) page_to_phys(page);
 }
 
-static void __crst_table_free(struct mm_struct *mm, unsigned long *table)
-{
-	unsigned long *shadow = get_shadow_table(table);
-
-	if (shadow)
-		free_pages((unsigned long) shadow, ALLOC_ORDER);
-	free_pages((unsigned long) table, ALLOC_ORDER);
-}
-
-void crst_table_free(struct mm_struct *mm, unsigned long *table)
-{
-	struct page *page = virt_to_page(table);
-
-	spin_lock_bh(&mm->context.list_lock);
-	list_del(&page->lru);
-	spin_unlock_bh(&mm->context.list_lock);
-	__crst_table_free(mm, table);
-}
-
-void crst_table_free_rcu(struct mm_struct *mm, unsigned long *table)
+void crst_table_free(unsigned long *table)
 {
-	struct rcu_table_freelist *batch;
 	struct page *page = virt_to_page(table);
+	struct mm_struct *mm = (struct mm_struct *) page->private;
+	unsigned long *shadow = get_shadow_table(table);
 
 	spin_lock_bh(&mm->context.list_lock);
 	list_del(&page->lru);
+	page->private = 0;
 	spin_unlock_bh(&mm->context.list_lock);
-	if (atomic_read(&mm->mm_users) < 2 &&
-	    cpumask_equal(mm_cpumask(mm), cpumask_of(smp_processor_id()))) {
-		__crst_table_free(mm, table);
-		return;
-	}
-	batch = rcu_table_freelist_get(mm);
-	if (!batch) {
-		smp_call_function(smp_sync, NULL, 1);
-		__crst_table_free(mm, table);
-		return;
-	}
-	batch->table[--batch->crst_index] = table;
-	if (batch->pgt_index >= batch->crst_index)
-		rcu_table_freelist_finish();
+	if (shadow)
+		free_pages((unsigned long) shadow, ALLOC_ORDER);
+	free_pages((unsigned long) table, ALLOC_ORDER);
 }
 
 #ifdef CONFIG_64BIT
@@ -223,7 +121,7 @@ repeat:
 	}
 	spin_unlock_bh(&mm->page_table_lock);
 	if (table)
-		crst_table_free(mm, table);
+		crst_table_free(table);
 	if (mm->context.asce_limit < limit)
 		goto repeat;
 	update_mm(mm, current);
@@ -257,7 +155,7 @@ void crst_table_downgrade(struct mm_stru
 		}
 		mm->pgd = (pgd_t *) (pgd_val(*pgd) & _REGION_ENTRY_ORIGIN);
 		mm->task_size = mm->context.asce_limit;
-		crst_table_free(mm, (unsigned long *) pgd);
+		crst_table_free((unsigned long *) pgd);
 	}
 	update_mm(mm, current);
 }
@@ -288,11 +186,7 @@ unsigned long *page_table_alloc(struct m
 			return NULL;
 		pgtable_page_ctor(page);
 		page->flags &= ~FRAG_MASK;
-		table = (unsigned long *) page_to_phys(page);
-		if (mm->context.has_pgste)
-			clear_table_pgstes(table);
-		else
-			clear_table(table, _PAGE_TYPE_EMPTY, PAGE_SIZE);
+		page->private = (unsigned long) mm;
 		spin_lock_bh(&mm->context.list_lock);
 		list_add(&page->lru, &mm->context.pgtable_list);
 	}
@@ -305,42 +199,34 @@ unsigned long *page_table_alloc(struct m
 	if ((page->flags & FRAG_MASK) == ((1UL << TABLES_PER_PAGE) - 1))
 		list_move_tail(&page->lru, &mm->context.pgtable_list);
 	spin_unlock_bh(&mm->context.list_lock);
+	clear_table(table, _PAGE_TYPE_EMPTY, PTRS_PER_PTE * sizeof(long));
+	if (mm->context.noexec)
+		clear_table(table + 256, _PAGE_TYPE_EMPTY,
+			    PTRS_PER_PTE * sizeof(long));
+	else if (mm->context.has_pgste)
+		clear_table(table + 256, 0, PTRS_PER_PTE * sizeof(long));
 	return table;
 }
 
-static void __page_table_free(struct mm_struct *mm, unsigned long *table)
+void page_table_free(unsigned long *table)
 {
-	struct page *page;
-	unsigned long bits;
-
-	bits = ((unsigned long) table) & 15;
-	table = (unsigned long *)(((unsigned long) table) ^ bits);
-	page = pfn_to_page(__pa(table) >> PAGE_SHIFT);
-	page->flags ^= bits;
-	if (!(page->flags & FRAG_MASK)) {
-		pgtable_page_dtor(page);
-		__free_page(page);
-	}
-}
-
-void page_table_free(struct mm_struct *mm, unsigned long *table)
-{
-	struct page *page;
+	struct page *page = virt_to_page(table);
+	struct mm_struct *mm = (struct mm_struct *) page->private;
 	unsigned long bits;
 
 	bits = (mm->context.noexec || mm->context.has_pgste) ? 3UL : 1UL;
 	bits <<= (__pa(table) & (PAGE_SIZE - 1)) / 256 / sizeof(unsigned long);
-	page = pfn_to_page(__pa(table) >> PAGE_SHIFT);
 	spin_lock_bh(&mm->context.list_lock);
 	page->flags ^= bits;
 	if (page->flags & FRAG_MASK) {
 		/* Page now has some free pgtable fragments. */
-		if (!list_empty(&page->lru))
-			list_move(&page->lru, &mm->context.pgtable_list);
+		list_move(&page->lru, &mm->context.pgtable_list);
 		page = NULL;
-	} else
+	} else {
 		/* All fragments of the 4K page have been freed. */
 		list_del(&page->lru);
+		page->private = 0;
+	}
 	spin_unlock_bh(&mm->context.list_lock);
 	if (page) {
 		pgtable_page_dtor(page);
@@ -348,36 +234,6 @@ void page_table_free(struct mm_struct *m
 	}
 }
 
-void page_table_free_rcu(struct mm_struct *mm, unsigned long *table)
-{
-	struct rcu_table_freelist *batch;
-	struct page *page;
-	unsigned long bits;
-
-	if (atomic_read(&mm->mm_users) < 2 &&
-	    cpumask_equal(mm_cpumask(mm), cpumask_of(smp_processor_id()))) {
-		page_table_free(mm, table);
-		return;
-	}
-	batch = rcu_table_freelist_get(mm);
-	if (!batch) {
-		smp_call_function(smp_sync, NULL, 1);
-		page_table_free(mm, table);
-		return;
-	}
-	bits = (mm->context.noexec || mm->context.has_pgste) ? 3UL : 1UL;
-	bits <<= (__pa(table) & (PAGE_SIZE - 1)) / 256 / sizeof(unsigned long);
-	page = pfn_to_page(__pa(table) >> PAGE_SHIFT);
-	spin_lock_bh(&mm->context.list_lock);
-	/* Delayed freeing with rcu prevents reuse of pgtable fragments */
-	list_del_init(&page->lru);
-	spin_unlock_bh(&mm->context.list_lock);
-	table = (unsigned long *)(((unsigned long) table) | bits);
-	batch->table[batch->pgt_index++] = table;
-	if (batch->pgt_index >= batch->crst_index)
-		rcu_table_freelist_finish();
-}
-
 void disable_noexec(struct mm_struct *mm, struct task_struct *tsk)
 {
 	struct page *page;

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
