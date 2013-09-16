Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 7C5076B00AE
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 07:26:03 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 8/9] mm: implement split page table lock for PMD level
Date: Mon, 16 Sep 2013 14:25:39 +0300
Message-Id: <1379330740-5602-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379330740-5602-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The basic idea is the same as with PTE level: the lock is embedded into
struct page of table's page.

We can't use mm->pmd_huge_pte to store pgtables for THP, since we don't
take mm->page_table_lock anymore. Let's reuse page->lru of table's page
for that.

hugetlbfs hasn't converted to split locking: disable split locking if
hugetlbfs enabled.

pgtable_pmd_page_ctor() returns true, if initialization is successful
and false otherwise. Current implementation never fails, but assumption
that constructor can fail will help to port it to -rt where spinlock_t
is rather huge and cannot be embedded into struct page -- dynamic
allocation is required.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h       | 32 ++++++++++++++++++++++++++++++++
 include/linux/mm_types.h |  8 +++++++-
 kernel/fork.c            |  4 ++--
 mm/Kconfig               |  3 +++
 4 files changed, 44 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b96aac9..75735f6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1294,13 +1294,45 @@ static inline void pgtable_page_dtor(struct page *page)
 	((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
 		NULL: pte_offset_kernel(pmd, address))
 
+#if USE_SPLIT_PMD_PTLOCKS
+
+static inline spinlock_t *pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
+{
+	return &virt_to_page(pmd)->ptl;
+}
+
+static inline bool pgtable_pmd_page_ctor(struct page *page)
+{
+	spin_lock_init(&page->ptl);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	page->pmd_huge_pte = NULL;
+#endif
+	return true;
+}
+
+static inline void pgtable_pmd_page_dtor(struct page *page)
+{
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	VM_BUG_ON(page->pmd_huge_pte);
+#endif
+}
+
+#define pmd_huge_pte(mm, pmd) (virt_to_page(pmd)->pmd_huge_pte)
+
+#else
+
 static inline spinlock_t *pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
 {
 	return &mm->page_table_lock;
 }
 
+static inline bool pgtable_pmd_page_ctor(struct page *page) { return true; }
+static inline void pgtable_pmd_page_dtor(struct page *page) {}
+
 #define pmd_huge_pte(mm, pmd) ((mm)->pmd_huge_pte)
 
+#endif
+
 static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 {
 	spinlock_t *ptl = pmd_lockptr(mm, pmd);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index b17a909..94206cb 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -24,6 +24,9 @@
 struct address_space;
 
 #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
+/* hugetlb hasn't converted to split locking yet */
+#define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
+		CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK && !CONFIG_HUGETLB_PAGE)
 
 /*
  * Each physical page in the system has a struct page associated with
@@ -130,6 +133,9 @@ struct page {
 
 		struct list_head list;	/* slobs list of pages */
 		struct slab *slab_page; /* slab fields */
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
+		pgtable_t pmd_huge_pte; /* protected by page->ptl */
+#endif
 	};
 
 	/* Remainder is not double word aligned */
@@ -405,7 +411,7 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
 #ifdef CONFIG_CPUMASK_OFFSTACK
diff --git a/kernel/fork.c b/kernel/fork.c
index 4c8b986..1670af7 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -560,7 +560,7 @@ static void check_mm(struct mm_struct *mm)
 					  "mm:%p idx:%d val:%ld\n", mm, i, x);
 	}
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	VM_BUG_ON(mm->pmd_huge_pte);
 #endif
 }
@@ -814,7 +814,7 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 	memcpy(mm, oldmm, sizeof(*mm));
 	mm_init_cpumask(mm);
 
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
 #endif
 #ifdef CONFIG_NUMA_BALANCING
diff --git a/mm/Kconfig b/mm/Kconfig
index 026771a..89d56e3 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -214,6 +214,9 @@ config SPLIT_PTLOCK_CPUS
 	default "999999" if DEBUG_SPINLOCK || DEBUG_LOCK_ALLOC
 	default "4"
 
+config ARCH_ENABLE_SPLIT_PMD_PTLOCK
+	boolean
+
 #
 # support for memory balloon compaction
 config BALLOON_COMPACTION
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
