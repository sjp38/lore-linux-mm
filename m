Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id BADB66B6D53
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 07:45:21 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c18-v6so3828945oiy.3
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 04:45:21 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g84-v6si13583498oif.285.2018.09.04.04.45.20
        for <linux-mm@kvack.org>;
        Tue, 04 Sep 2018 04:45:20 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 4/5] mm/memory: Move mmu_gather and TLB invalidation code into its own file
Date: Tue,  4 Sep 2018 12:45:32 +0100
Message-Id: <1536061533-16188-5-git-send-email-will.deacon@arm.com>
In-Reply-To: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
References: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: peterz@infradead.org, npiggin@gmail.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com

From: Peter Zijlstra <peterz@infradead.org>

In preparation for maintaining the mmu_gather code as its own entity,
move the implementation out of memory.c and into its own file.

Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 include/asm-generic/tlb.h |   1 +
 mm/Makefile               |   6 +-
 mm/memory.c               | 249 --------------------------------------------
 mm/mmu_gather.c           | 259 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 263 insertions(+), 252 deletions(-)
 create mode 100644 mm/mmu_gather.c

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 9791e98122a0..6be86c1c5c58 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -138,6 +138,7 @@ void arch_tlb_gather_mmu(struct mmu_gather *tlb,
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 			 unsigned long start, unsigned long end, bool force);
+void tlb_flush_mmu_free(struct mmu_gather *tlb);
 extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
 				   int page_size);
 
diff --git a/mm/Makefile b/mm/Makefile
index 8716bdabe1e6..7c48e0d3d8ab 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -23,9 +23,9 @@ KCOV_INSTRUMENT_vmstat.o := n
 
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= gup.o highmem.o memory.o mincore.o \
-			   mlock.o mmap.o mprotect.o mremap.o msync.o \
-			   page_vma_mapped.o pagewalk.o pgtable-generic.o \
-			   rmap.o vmalloc.o
+			   mlock.o mmap.o mmu_gather.o mprotect.o mremap.o \
+			   msync.o page_vma_mapped.o pagewalk.o \
+			   pgtable-generic.o rmap.o vmalloc.o
 
 
 ifdef CONFIG_CROSS_MEMORY_ATTACH
diff --git a/mm/memory.c b/mm/memory.c
index 9135f48e8d84..21a5e6e4758b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -186,255 +186,6 @@ static void check_sync_rss_stat(struct task_struct *task)
 
 #endif /* SPLIT_RSS_COUNTING */
 
-#ifdef HAVE_GENERIC_MMU_GATHER
-
-static bool tlb_next_batch(struct mmu_gather *tlb)
-{
-	struct mmu_gather_batch *batch;
-
-	batch = tlb->active;
-	if (batch->next) {
-		tlb->active = batch->next;
-		return true;
-	}
-
-	if (tlb->batch_count == MAX_GATHER_BATCH_COUNT)
-		return false;
-
-	batch = (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
-	if (!batch)
-		return false;
-
-	tlb->batch_count++;
-	batch->next = NULL;
-	batch->nr   = 0;
-	batch->max  = MAX_GATHER_BATCH;
-
-	tlb->active->next = batch;
-	tlb->active = batch;
-
-	return true;
-}
-
-void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-				unsigned long start, unsigned long end)
-{
-	tlb->mm = mm;
-
-	/* Is it from 0 to ~0? */
-	tlb->fullmm     = !(start | (end+1));
-	tlb->need_flush_all = 0;
-	tlb->local.next = NULL;
-	tlb->local.nr   = 0;
-	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
-	tlb->active     = &tlb->local;
-	tlb->batch_count = 0;
-
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb->batch = NULL;
-#endif
-	tlb->page_size = 0;
-
-	__tlb_reset_range(tlb);
-}
-
-static void tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-	struct mmu_gather_batch *batch;
-
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb_table_flush(tlb);
-#endif
-	for (batch = &tlb->local; batch && batch->nr; batch = batch->next) {
-		free_pages_and_swap_cache(batch->pages, batch->nr);
-		batch->nr = 0;
-	}
-	tlb->active = &tlb->local;
-}
-
-void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	tlb_flush_mmu_tlbonly(tlb);
-	tlb_flush_mmu_free(tlb);
-}
-
-/* tlb_finish_mmu
- *	Called at the end of the shootdown operation to free up any resources
- *	that were required.
- */
-void arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end, bool force)
-{
-	struct mmu_gather_batch *batch, *next;
-
-	if (force) {
-		__tlb_reset_range(tlb);
-		__tlb_adjust_range(tlb, start, end - start);
-	}
-
-	tlb_flush_mmu(tlb);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	for (batch = tlb->local.next; batch; batch = next) {
-		next = batch->next;
-		free_pages((unsigned long)batch, 0);
-	}
-	tlb->local.next = NULL;
-}
-
-/* __tlb_remove_page
- *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)), while
- *	handling the additional races in SMP caused by other CPUs caching valid
- *	mappings in their TLBs. Returns the number of free page slots left.
- *	When out of page slots we must call tlb_flush_mmu().
- *returns true if the caller should flush.
- */
-bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_size)
-{
-	struct mmu_gather_batch *batch;
-
-	VM_BUG_ON(!tlb->end);
-	VM_WARN_ON(tlb->page_size != page_size);
-
-	batch = tlb->active;
-	/*
-	 * Add the page and check if we are full. If so
-	 * force a flush.
-	 */
-	batch->pages[batch->nr++] = page;
-	if (batch->nr == batch->max) {
-		if (!tlb_next_batch(tlb))
-			return true;
-		batch = tlb->active;
-	}
-	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
-
-	return false;
-}
-
-#endif /* HAVE_GENERIC_MMU_GATHER */
-
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-
-/*
- * See the comment near struct mmu_table_batch.
- */
-
-/*
- * If we want tlb_remove_table() to imply TLB invalidates.
- */
-static inline void tlb_table_invalidate(struct mmu_gather *tlb)
-{
-#ifdef CONFIG_HAVE_RCU_TABLE_INVALIDATE
-	/*
-	 * Invalidate page-table caches used by hardware walkers. Then we still
-	 * need to RCU-sched wait while freeing the pages because software
-	 * walkers can still be in-flight.
-	 */
-	tlb_flush_mmu_tlbonly(tlb);
-#endif
-}
-
-static void tlb_remove_table_smp_sync(void *arg)
-{
-	/* Simply deliver the interrupt */
-}
-
-static void tlb_remove_table_one(void *table)
-{
-	/*
-	 * This isn't an RCU grace period and hence the page-tables cannot be
-	 * assumed to be actually RCU-freed.
-	 *
-	 * It is however sufficient for software page-table walkers that rely on
-	 * IRQ disabling. See the comment near struct mmu_table_batch.
-	 */
-	smp_call_function(tlb_remove_table_smp_sync, NULL, 1);
-	__tlb_remove_table(table);
-}
-
-static void tlb_remove_table_rcu(struct rcu_head *head)
-{
-	struct mmu_table_batch *batch;
-	int i;
-
-	batch = container_of(head, struct mmu_table_batch, rcu);
-
-	for (i = 0; i < batch->nr; i++)
-		__tlb_remove_table(batch->tables[i]);
-
-	free_page((unsigned long)batch);
-}
-
-void tlb_table_flush(struct mmu_gather *tlb)
-{
-	struct mmu_table_batch **batch = &tlb->batch;
-
-	if (*batch) {
-		tlb_table_invalidate(tlb);
-		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
-		*batch = NULL;
-	}
-}
-
-void tlb_remove_table(struct mmu_gather *tlb, void *table)
-{
-	struct mmu_table_batch **batch = &tlb->batch;
-
-	if (*batch == NULL) {
-		*batch = (struct mmu_table_batch *)__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
-		if (*batch == NULL) {
-			tlb_table_invalidate(tlb);
-			tlb_remove_table_one(table);
-			return;
-		}
-		(*batch)->nr = 0;
-	}
-
-	(*batch)->tables[(*batch)->nr++] = table;
-	if ((*batch)->nr == MAX_TABLE_BATCH)
-		tlb_table_flush(tlb);
-}
-
-#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
-
-/**
- * tlb_gather_mmu - initialize an mmu_gather structure for page-table tear-down
- * @tlb: the mmu_gather structure to initialize
- * @mm: the mm_struct of the target address space
- * @start: start of the region that will be removed from the page-table
- * @end: end of the region that will be removed from the page-table
- *
- * Called to initialize an (on-stack) mmu_gather structure for page-table
- * tear-down from @mm. The @start and @end are set to 0 and -1
- * respectively when @mm is without users and we're going to destroy
- * the full address space (exit/execve).
- */
-void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
-{
-	arch_tlb_gather_mmu(tlb, mm, start, end);
-	inc_tlb_flush_pending(tlb->mm);
-}
-
-void tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end)
-{
-	/*
-	 * If there are parallel threads are doing PTE changes on same range
-	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
-	 * flush by batching, a thread has stable TLB entry can fail to flush
-	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
-	 * forcefully if we detect parallel PTE batching threads.
-	 */
-	bool force = mm_tlb_flush_nested(tlb->mm);
-
-	arch_tlb_finish_mmu(tlb, start, end, force);
-	dec_tlb_flush_pending(tlb->mm);
-}
-
 /*
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
new file mode 100644
index 000000000000..d41b63d9cdaa
--- /dev/null
+++ b/mm/mmu_gather.c
@@ -0,0 +1,259 @@
+#include <linux/gfp.h>
+#include <linux/kernel.h>
+#include <linux/mmdebug.h>
+#include <linux/mm_types.h>
+#include <linux/rcupdate.h>
+#include <linux/smp.h>
+#include <linux/swap.h>
+
+#include <asm/pgalloc.h>
+#include <asm/tlb.h>
+
+#ifdef HAVE_GENERIC_MMU_GATHER
+
+static bool tlb_next_batch(struct mmu_gather *tlb)
+{
+	struct mmu_gather_batch *batch;
+
+	batch = tlb->active;
+	if (batch->next) {
+		tlb->active = batch->next;
+		return true;
+	}
+
+	if (tlb->batch_count == MAX_GATHER_BATCH_COUNT)
+		return false;
+
+	batch = (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
+	if (!batch)
+		return false;
+
+	tlb->batch_count++;
+	batch->next = NULL;
+	batch->nr   = 0;
+	batch->max  = MAX_GATHER_BATCH;
+
+	tlb->active->next = batch;
+	tlb->active = batch;
+
+	return true;
+}
+
+void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+				unsigned long start, unsigned long end)
+{
+	tlb->mm = mm;
+
+	/* Is it from 0 to ~0? */
+	tlb->fullmm     = !(start | (end+1));
+	tlb->need_flush_all = 0;
+	tlb->local.next = NULL;
+	tlb->local.nr   = 0;
+	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
+	tlb->active     = &tlb->local;
+	tlb->batch_count = 0;
+
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb->batch = NULL;
+#endif
+	tlb->page_size = 0;
+
+	__tlb_reset_range(tlb);
+}
+
+void tlb_flush_mmu_free(struct mmu_gather *tlb)
+{
+	struct mmu_gather_batch *batch;
+
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb_table_flush(tlb);
+#endif
+	for (batch = &tlb->local; batch && batch->nr; batch = batch->next) {
+		free_pages_and_swap_cache(batch->pages, batch->nr);
+		batch->nr = 0;
+	}
+	tlb->active = &tlb->local;
+}
+
+void tlb_flush_mmu(struct mmu_gather *tlb)
+{
+	tlb_flush_mmu_tlbonly(tlb);
+	tlb_flush_mmu_free(tlb);
+}
+
+/* tlb_finish_mmu
+ *	Called at the end of the shootdown operation to free up any resources
+ *	that were required.
+ */
+void arch_tlb_finish_mmu(struct mmu_gather *tlb,
+		unsigned long start, unsigned long end, bool force)
+{
+	struct mmu_gather_batch *batch, *next;
+
+	if (force) {
+		__tlb_reset_range(tlb);
+		__tlb_adjust_range(tlb, start, end - start);
+	}
+
+	tlb_flush_mmu(tlb);
+
+	/* keep the page table cache within bounds */
+	check_pgt_cache();
+
+	for (batch = tlb->local.next; batch; batch = next) {
+		next = batch->next;
+		free_pages((unsigned long)batch, 0);
+	}
+	tlb->local.next = NULL;
+}
+
+/* __tlb_remove_page
+ *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)), while
+ *	handling the additional races in SMP caused by other CPUs caching valid
+ *	mappings in their TLBs. Returns the number of free page slots left.
+ *	When out of page slots we must call tlb_flush_mmu().
+ *returns true if the caller should flush.
+ */
+bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_size)
+{
+	struct mmu_gather_batch *batch;
+
+	VM_BUG_ON(!tlb->end);
+	VM_WARN_ON(tlb->page_size != page_size);
+
+	batch = tlb->active;
+	/*
+	 * Add the page and check if we are full. If so
+	 * force a flush.
+	 */
+	batch->pages[batch->nr++] = page;
+	if (batch->nr == batch->max) {
+		if (!tlb_next_batch(tlb))
+			return true;
+		batch = tlb->active;
+	}
+	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
+
+	return false;
+}
+
+#endif /* HAVE_GENERIC_MMU_GATHER */
+
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+
+/*
+ * See the comment near struct mmu_table_batch.
+ */
+
+/*
+ * If we want tlb_remove_table() to imply TLB invalidates.
+ */
+static inline void tlb_table_invalidate(struct mmu_gather *tlb)
+{
+#ifdef CONFIG_HAVE_RCU_TABLE_INVALIDATE
+	/*
+	 * Invalidate page-table caches used by hardware walkers. Then we still
+	 * need to RCU-sched wait while freeing the pages because software
+	 * walkers can still be in-flight.
+	 */
+	tlb_flush_mmu_tlbonly(tlb);
+#endif
+}
+
+static void tlb_remove_table_smp_sync(void *arg)
+{
+	/* Simply deliver the interrupt */
+}
+
+static void tlb_remove_table_one(void *table)
+{
+	/*
+	 * This isn't an RCU grace period and hence the page-tables cannot be
+	 * assumed to be actually RCU-freed.
+	 *
+	 * It is however sufficient for software page-table walkers that rely on
+	 * IRQ disabling. See the comment near struct mmu_table_batch.
+	 */
+	smp_call_function(tlb_remove_table_smp_sync, NULL, 1);
+	__tlb_remove_table(table);
+}
+
+static void tlb_remove_table_rcu(struct rcu_head *head)
+{
+	struct mmu_table_batch *batch;
+	int i;
+
+	batch = container_of(head, struct mmu_table_batch, rcu);
+
+	for (i = 0; i < batch->nr; i++)
+		__tlb_remove_table(batch->tables[i]);
+
+	free_page((unsigned long)batch);
+}
+
+void tlb_table_flush(struct mmu_gather *tlb)
+{
+	struct mmu_table_batch **batch = &tlb->batch;
+
+	if (*batch) {
+		tlb_table_invalidate(tlb);
+		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
+		*batch = NULL;
+	}
+}
+
+void tlb_remove_table(struct mmu_gather *tlb, void *table)
+{
+	struct mmu_table_batch **batch = &tlb->batch;
+
+	if (*batch == NULL) {
+		*batch = (struct mmu_table_batch *)__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
+		if (*batch == NULL) {
+			tlb_table_invalidate(tlb);
+			tlb_remove_table_one(table);
+			return;
+		}
+		(*batch)->nr = 0;
+	}
+
+	(*batch)->tables[(*batch)->nr++] = table;
+	if ((*batch)->nr == MAX_TABLE_BATCH)
+		tlb_table_flush(tlb);
+}
+
+#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
+
+/**
+ * tlb_gather_mmu - initialize an mmu_gather structure for page-table tear-down
+ * @tlb: the mmu_gather structure to initialize
+ * @mm: the mm_struct of the target address space
+ * @start: start of the region that will be removed from the page-table
+ * @end: end of the region that will be removed from the page-table
+ *
+ * Called to initialize an (on-stack) mmu_gather structure for page-table
+ * tear-down from @mm. The @start and @end are set to 0 and -1
+ * respectively when @mm is without users and we're going to destroy
+ * the full address space (exit/execve).
+ */
+void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
+			unsigned long start, unsigned long end)
+{
+	arch_tlb_gather_mmu(tlb, mm, start, end);
+	inc_tlb_flush_pending(tlb->mm);
+}
+
+void tlb_finish_mmu(struct mmu_gather *tlb,
+		unsigned long start, unsigned long end)
+{
+	/*
+	 * If there are parallel threads are doing PTE changes on same range
+	 * under non-exclusive lock(e.g., mmap_sem read-side) but defer TLB
+	 * flush by batching, a thread has stable TLB entry can fail to flush
+	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
+	 * forcefully if we detect parallel PTE batching threads.
+	 */
+	bool force = mm_tlb_flush_nested(tlb->mm);
+
+	arch_tlb_finish_mmu(tlb, start, end, force);
+	dec_tlb_flush_pending(tlb->mm);
+}
-- 
2.1.4
