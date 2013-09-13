Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 7A9886B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 09:36:32 -0400 (EDT)
Date: Fri, 13 Sep 2013 15:36:20 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 8/9] mm: implement split page table lock for PMD level
Message-ID: <20130913133620.GE21832@twins.programming.kicks-ass.net>
References: <20130910074748.GA2971@gmail.com>
 <1379077576-2472-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1379077576-2472-9-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1379077576-2472-9-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Sep 13, 2013 at 04:06:15PM +0300, Kirill A. Shutemov wrote:
> +#if USE_SPLIT_PMD_PTLOCKS
> +
> +static inline void pgtable_pmd_page_ctor(struct page *page)
> +{
> +	spin_lock_init(&page->ptl);
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	page->pmd_huge_pte = NULL;
> +#endif
> +}
> +
> +static inline void pgtable_pmd_page_dtor(struct page *page)
> +{
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	VM_BUG_ON(page->pmd_huge_pte);
> +#endif
> +}
> +
> +#define pmd_huge_pte(mm, pmd) (virt_to_page(pmd)->pmd_huge_pte)
> +
> +#else

So on -rt we have the problem that spinlock_t is rather huge (its a
rtmutex) so instead of blowing up the pageframe like that we treat
page->pte as a pointer and allocate the spinlock.

Since allocations could fail the above ctor path gets 'interesting'.

It would be good if new code could assume the ctor could fail so we
don't have to replicate that horror-show.


---
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 3 Jul 2009 08:44:54 -0500
Subject: mm: shrink the page frame to !-rt size

He below is a boot-tested hack to shrink the page frame size back to
normal.

Should be a net win since there should be many less PTE-pages than
page-frames.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/mm.h       |   46 +++++++++++++++++++++++++++++++++++++++-------
 include/linux/mm_types.h |    4 ++++
 mm/memory.c              |   32 ++++++++++++++++++++++++++++++++
 3 files changed, 75 insertions(+), 7 deletions(-)

--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1241,27 +1241,59 @@ static inline pmd_t *pmd_alloc(struct mm
  * overflow into the next struct page (as it might with DEBUG_SPINLOCK).
  * When freeing, reset page->mapping so free_pages_check won't complain.
  */
+#ifndef CONFIG_PREEMPT_RT_FULL
+
 #define __pte_lockptr(page)	&((page)->ptl)
-#define pte_lock_init(_page)	do {					\
-	spin_lock_init(__pte_lockptr(_page));				\
-} while (0)
+
+static inline struct page *pte_lock_init(struct page *page)
+{
+	spin_lock_init(__pte_lockptr(page));
+	return page;
+}
+
 #define pte_lock_deinit(page)	((page)->mapping = NULL)
+
+#else /* !PREEMPT_RT_FULL */
+
+/*
+ * On PREEMPT_RT_FULL the spinlock_t's are too large to embed in the
+ * page frame, hence it only has a pointer and we need to dynamically
+ * allocate the lock when we allocate PTE-pages.
+ *
+ * This is an overall win, since only a small fraction of the pages
+ * will be PTE pages under normal circumstances.
+ */
+
+#define __pte_lockptr(page)	((page)->ptl)
+
+extern struct page *pte_lock_init(struct page *page);
+extern void pte_lock_deinit(struct page *page);
+
+#endif /* PREEMPT_RT_FULL */
+
 #define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
 #else	/* !USE_SPLIT_PTLOCKS */
 /*
  * We use mm->page_table_lock to guard all pagetable pages of the mm.
  */
-#define pte_lock_init(page)	do {} while (0)
+static inline struct page *pte_lock_init(struct page *page) { return page; }
 #define pte_lock_deinit(page)	do {} while (0)
 #define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
 #endif /* USE_SPLIT_PTLOCKS */
 
-static inline void pgtable_page_ctor(struct page *page)
+static inline struct page *__pgtable_page_ctor(struct page *page)
 {
-	pte_lock_init(page);
-	inc_zone_page_state(page, NR_PAGETABLE);
+	page = pte_lock_init(page);
+	if (page)
+		inc_zone_page_state(page, NR_PAGETABLE);
+	return page;
 }
 
+#define pgtable_page_ctor(page)				\
+do {							\
+	page = __pgtable_page_ctor(page);		\
+} while (0)
+
 static inline void pgtable_page_dtor(struct page *page)
 {
 	pte_lock_deinit(page);
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -142,7 +142,11 @@ struct page {
 						 * system if PG_buddy is set.
 						 */
 #if USE_SPLIT_PTLOCKS
+# ifndef CONFIG_PREEMPT_RT_FULL
 		spinlock_t ptl;
+# else
+		spinlock_t *ptl;
+# endif
 #endif
 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
 		struct page *first_page;	/* Compound tail pages */
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4328,3 +4328,35 @@ void copy_user_huge_page(struct page *ds
 	}
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
+
+#if defined(CONFIG_PREEMPT_RT_FULL) && (USE_SPLIT_PTLOCKS > 0)
+/*
+ * Heinous hack, relies on the caller doing something like:
+ *
+ *   pte = alloc_pages(PGALLOC_GFP, 0);
+ *   if (pte)
+ *     pgtable_page_ctor(pte);
+ *   return pte;
+ *
+ * This ensures we release the page and return NULL when the
+ * lock allocation fails.
+ */
+struct page *pte_lock_init(struct page *page)
+{
+	page->ptl = kmalloc(sizeof(spinlock_t), GFP_KERNEL);
+	if (page->ptl) {
+		spin_lock_init(__pte_lockptr(page));
+	} else {
+		__free_page(page);
+		page = NULL;
+	}
+	return page;
+}
+
+void pte_lock_deinit(struct page *page)
+{
+	kfree(page->ptl);
+	page->mapping = NULL;
+}
+
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
