Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C82E36B0072
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:26:44 -0400 (EDT)
Date: Tue, 02 Oct 2012 18:26:42 -0400 (EDT)
Message-Id: <20121002.182642.49574627747120711.davem@davemloft.net>
Subject: [PATCH 3/8] sparc64: Eliminate PTE table memory wastage.
From: David Miller <davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org


We've split up the PTE tables so that they take up half a page instead
of a full page.  This is in order to facilitate transparent huge page
support, which works much better if our PMDs cover 4MB instead of 8MB.

What we do is have a one-behind cache for PTE table allocations in the
mm struct.

This logic triggers only on allocations.  For example, we don't try to
keep track of free'd up page table blocks in the style that the s390
port does.

We never allocate from this cache from interrupts, so we can access it
safely using only preemption protection.

There were only two slightly annoying aspects to this change:

1) Changing pgtable_t to be a "pte_t *".  There's all of this special
   logic in the TLB free paths that needed adjustments, as did the
   PMD populate interfaces.

2) init_new_context() needs to zap the pointer, since the mm struct
   just gets copied from the parent on fork.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/include/asm/mmu_64.h     |    1 +
 arch/sparc/include/asm/page_64.h    |    2 +-
 arch/sparc/include/asm/pgalloc_64.h |   54 ++++---------------
 arch/sparc/mm/init_64.c             |  101 +++++++++++++++++++++++++++++++++++
 arch/sparc/mm/tsb.c                 |    9 ++++
 5 files changed, 123 insertions(+), 44 deletions(-)

diff --git a/arch/sparc/include/asm/mmu_64.h b/arch/sparc/include/asm/mmu_64.h
index b4d685d..0acfb46 100644
--- a/arch/sparc/include/asm/mmu_64.h
+++ b/arch/sparc/include/asm/mmu_64.h
@@ -100,6 +100,7 @@ typedef struct {
 	spinlock_t		lock;
 	unsigned long		sparc64_ctx_val;
 	unsigned long		huge_pte_count;
+	struct page		*pgtable_page;
 	struct tsb_config	tsb_block[MM_NUM_TSBS];
 	struct hv_tsb_descr	tsb_descr[MM_NUM_TSBS];
 } mm_context_t;
diff --git a/arch/sparc/include/asm/page_64.h b/arch/sparc/include/asm/page_64.h
index 08bb5f7..fc2b229 100644
--- a/arch/sparc/include/asm/page_64.h
+++ b/arch/sparc/include/asm/page_64.h
@@ -92,7 +92,7 @@ typedef unsigned long pgprot_t;
 
 #endif /* (STRICT_MM_TYPECHECKS) */
 
-typedef struct page *pgtable_t;
+typedef pte_t *pgtable_t;
 
 #define TASK_UNMAPPED_BASE	(test_thread_flag(TIF_32BIT) ? \
 				 (_AC(0x0000000070000000,UL)) : \
diff --git a/arch/sparc/include/asm/pgalloc_64.h b/arch/sparc/include/asm/pgalloc_64.h
index 40b2d7a..0ebca93 100644
--- a/arch/sparc/include/asm/pgalloc_64.h
+++ b/arch/sparc/include/asm/pgalloc_64.h
@@ -38,51 +38,20 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 	kmem_cache_free(pgtable_cache, pmd);
 }
 
-static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
-					  unsigned long address)
-{
-	return (pte_t *)__get_free_page(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO);
-}
-
-static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
-					unsigned long address)
-{
-	struct page *page;
-	pte_t *pte;
-
-	pte = pte_alloc_one_kernel(mm, address);
-	if (!pte)
-		return NULL;
-	page = virt_to_page(pte);
-	pgtable_page_ctor(page);
-	return page;
-}
-
-static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
-{
-	free_page((unsigned long)pte);
-}
-
-static inline void pte_free(struct mm_struct *mm, pgtable_t ptepage)
-{
-	pgtable_page_dtor(ptepage);
-	__free_page(ptepage);
-}
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+				   unsigned long address);
+extern pgtable_t pte_alloc_one(struct mm_struct *mm,
+			       unsigned long address);
+extern void pte_free_kernel(struct mm_struct *mm, pte_t *pte);
+extern void pte_free(struct mm_struct *mm, pgtable_t ptepage);
 
 #define pmd_populate_kernel(MM, PMD, PTE)	pmd_set(PMD, PTE)
-#define pmd_populate(MM,PMD,PTE_PAGE)		\
-	pmd_populate_kernel(MM,PMD,page_address(PTE_PAGE))
-#define pmd_pgtable(pmd) pmd_page(pmd)
+#define pmd_populate(MM, PMD, PTE)		pmd_set(PMD, PTE)
+#define pmd_pgtable(PMD)			((pte_t *)__pmd_page(PMD))
 
 #define check_pgt_cache()	do { } while (0)
 
-static inline void pgtable_free(void *table, bool is_page)
-{
-	if (is_page)
-		free_page((unsigned long)table);
-	else
-		kmem_cache_free(pgtable_cache, table);
-}
+extern void pgtable_free(void *table, bool is_page);
 
 #ifdef CONFIG_SMP
 
@@ -113,11 +82,10 @@ static inline void pgtable_free_tlb(struct mmu_gather *tlb, void *table, bool is
 }
 #endif /* !CONFIG_SMP */
 
-static inline void __pte_free_tlb(struct mmu_gather *tlb, struct page *ptepage,
+static inline void __pte_free_tlb(struct mmu_gather *tlb, pte_t *pte,
 				  unsigned long address)
 {
-	pgtable_page_dtor(ptepage);
-	pgtable_free_tlb(tlb, page_address(ptepage), true);
+	pgtable_free_tlb(tlb, pte, true);
 }
 
 #define __pmd_free_tlb(tlb, pmd, addr)		      \
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 696bb09..cd96c03 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2471,3 +2471,104 @@ void __flush_tlb_all(void)
 	__asm__ __volatile__("wrpr	%0, 0, %%pstate"
 			     : : "r" (pstate));
 }
+
+static pte_t *get_from_cache(struct mm_struct *mm)
+{
+	struct page *page;
+	pte_t *ret;
+
+	preempt_disable();
+	page = mm->context.pgtable_page;
+	ret = NULL;
+	if (page) {
+		void *p = page_address(page);
+
+		mm->context.pgtable_page = NULL;
+
+		ret = (pte_t *) (p + (PAGE_SIZE / 2));
+	}
+	preempt_enable();
+
+	return ret;
+}
+
+static struct page *__alloc_for_cache(struct mm_struct *mm)
+{
+	struct page *page = alloc_page(GFP_KERNEL | __GFP_NOTRACK |
+				       __GFP_REPEAT | __GFP_ZERO);
+
+	if (page) {
+		preempt_disable();
+		if (!mm->context.pgtable_page) {
+			atomic_set(&page->_count, 2);
+			mm->context.pgtable_page = page;
+		}
+		preempt_enable();
+	}
+	return page;
+}
+
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+			    unsigned long address)
+{
+	struct page *page;
+	pte_t *pte;
+
+	pte = get_from_cache(mm);
+	if (pte)
+		return pte;
+
+	page = __alloc_for_cache(mm);
+	if (page)
+		pte = (pte_t *) page_address(page);
+
+	return pte;
+}
+
+pgtable_t pte_alloc_one(struct mm_struct *mm,
+			unsigned long address)
+{
+	struct page *page;
+	pte_t *pte;
+
+	pte = get_from_cache(mm);
+	if (pte)
+		return pte;
+
+	page = __alloc_for_cache(mm);
+	if (page) {
+		pgtable_page_ctor(page);
+		pte = (pte_t *) page_address(page);
+	}
+
+	return pte;
+}
+
+void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
+{
+	struct page *page = virt_to_page(pte);
+	if (put_page_testzero(page))
+		free_hot_cold_page(page, 0);
+}
+
+static void __pte_free(pgtable_t pte)
+{
+	struct page *page = virt_to_page(pte);
+	if (put_page_testzero(page)) {
+		pgtable_page_dtor(page);
+		free_hot_cold_page(page, 0);
+	}
+}
+
+void pte_free(struct mm_struct *mm, pgtable_t pte)
+{
+	__pte_free(pte);
+}
+
+void pgtable_free(void *table, bool is_page)
+{
+	if (is_page)
+		__pte_free(table);
+	else
+		kmem_cache_free(pgtable_cache, table);
+}
diff --git a/arch/sparc/mm/tsb.c b/arch/sparc/mm/tsb.c
index e6b04a4..760621a 100644
--- a/arch/sparc/mm/tsb.c
+++ b/arch/sparc/mm/tsb.c
@@ -452,6 +452,8 @@ int init_new_context(struct task_struct *tsk, struct mm_struct *mm)
 	mm->context.huge_pte_count = 0;
 #endif
 
+	mm->context.pgtable_page = NULL;
+
 	/* copy_mm() copies over the parent's mm_struct before calling
 	 * us, so we need to zero out the TSB pointer or else tsb_grow()
 	 * will be confused and think there is an older TSB to free up.
@@ -490,10 +492,17 @@ static void tsb_destroy_one(struct tsb_config *tp)
 void destroy_context(struct mm_struct *mm)
 {
 	unsigned long flags, i;
+	struct page *page;
 
 	for (i = 0; i < MM_NUM_TSBS; i++)
 		tsb_destroy_one(&mm->context.tsb_block[i]);
 
+	page = mm->context.pgtable_page;
+	if (page && put_page_testzero(page)) {
+		pgtable_page_dtor(page);
+		free_hot_cold_page(page, 0);
+	}
+
 	spin_lock_irqsave(&ctx_alloc_lock, flags);
 
 	if (CTX_VALID(mm->context)) {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
