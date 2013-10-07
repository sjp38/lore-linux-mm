Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C09086B005C
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 09:54:42 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so7222598pad.7
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 06:54:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 10/11] mm: implement split page table lock for PMD level
Date: Mon,  7 Oct 2013 16:54:12 +0300
Message-Id: <1381154053-4848-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The basic idea is the same as with PTE level: the lock is embedded into
struct page of table's page.

We can't use mm->pmd_huge_pte to store pgtables for THP, since we don't
take mm->page_table_lock anymore. Let's reuse page->lru of table's page
for that.

pgtable_pmd_page_ctor() returns true, if initialization is successful
and false otherwise. Current implementation never fails, but assumption
that constructor can fail will help to port it to -rt where spinlock_t
is rather huge and cannot be embedded into struct page -- dynamic
allocation is required.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Alex Thorlton <athorlton@sgi.com>
---
 include/linux/mm.h       | 32 ++++++++++++++++++++++++++++++++
 include/linux/mm_types.h |  7 ++++++-
 kernel/fork.c            |  4 ++--
 mm/Kconfig               |  3 +++
 4 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b96aac9622..75735f6171 100644
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
index 149ad17ceb..bacc15f078 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -24,6 +24,8 @@
 struct address_space;
 
 #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
+#define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
+		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK))
 
 /*
  * Each physical page in the system has a struct page associated with
@@ -130,6 +132,9 @@ struct page {
 
 		struct list_head list;	/* slobs list of pages */
 		struct slab *slab_page; /* slab fields */
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
+		pgtable_t pmd_huge_pte; /* protected by page->ptl */
+#endif
 	};
 
 	/* Remainder is not double word aligned */
@@ -406,7 +411,7 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
 #endif
 #ifdef CONFIG_CPUMASK_OFFSTACK
diff --git a/kernel/fork.c b/kernel/fork.c
index 5c8a19482a..683f0374c0 100644
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
index 6f5be0dac9..d19f7d380b 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -215,6 +215,9 @@ config SPLIT_PTLOCK_CPUS
 	default "999999" if !64BIT && GENERIC_LOCKBREAK
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
