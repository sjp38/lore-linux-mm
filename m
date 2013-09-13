Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 5255A6B0036
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 09:06:36 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 8/9] mm: implement split page table lock for PMD level
Date: Fri, 13 Sep 2013 16:06:15 +0300
Message-Id: <1379077576-2472-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379077576-2472-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <20130910074748.GA2971@gmail.com>
 <1379077576-2472-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The basic idea is the same as with PTE level: the lock is embedded into
struct page of table's page.

Split pmd page table lock only makes sense on big machines.
Let's say >= 32 CPUs for now.

We can't use mm->pmd_huge_pte to store pgtables for THP, since we don't
take mm->page_table_lock anymore. Let's reuse page->lru of table's page
for that.

hugetlbfs hasn't converted to split locking: disable split locking if
hugetlbfs enabled.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h       | 31 +++++++++++++++++++++++++++++++
 include/linux/mm_types.h |  5 +++++
 kernel/fork.c            |  4 ++--
 mm/Kconfig               | 10 ++++++++++
 4 files changed, 48 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d2f8a50..5b3922d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1294,13 +1294,44 @@ static inline void pgtable_page_dtor(struct page *page)
 	((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
 		NULL: pte_offset_kernel(pmd, address))
 
+#if USE_SPLIT_PMD_PTLOCKS
+
+static inline spinlock_t *huge_pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
+{
+	return &virt_to_page(pmd)->ptl;
+}
+
+static inline void pgtable_pmd_page_ctor(struct page *page)
+{
+	spin_lock_init(&page->ptl);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	page->pmd_huge_pte = NULL;
+#endif
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
 static inline spinlock_t *huge_pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
 {
 	return &mm->page_table_lock;
 }
 
+static inline void pgtable_pmd_page_ctor(struct page *page) {}
+static inline void pgtable_pmd_page_dtor(struct page *page) {}
+
 #define pmd_huge_pte(mm, pmd) ((mm)->pmd_huge_pte)
 
+#endif
+
 static inline spinlock_t *huge_pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 {
 	spinlock_t *ptl = huge_pmd_lockptr(mm, pmd);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 1c64730..5706ddf 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -24,6 +24,8 @@
 struct address_space;
 
 #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTE_PTLOCK_CPUS)
+#define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
+		NR_CPUS >= CONFIG_SPLIT_PMD_PTLOCK_CPUS)
 
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
index 1977a33..ab32eda 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -214,6 +214,16 @@ config SPLIT_PTE_PTLOCK_CPUS
 	default "999999" if DEBUG_SPINLOCK || DEBUG_LOCK_ALLOC
 	default "4"
 
+config ARCH_ENABLE_SPLIT_PMD_PTLOCK
+	boolean
+
+config SPLIT_PMD_PTLOCK_CPUS
+	int
+	# hugetlb hasn't converted to split locking yet
+	default "999999" if HUGETLB_PAGE
+	default "32" if ARCH_ENABLE_SPLIT_PMD_PTLOCK
+	default "999999"
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
