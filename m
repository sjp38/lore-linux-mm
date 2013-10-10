Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3A29C000C
	for <linux-mm@kvack.org>; Thu, 10 Oct 2013 14:06:38 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so2957448pdi.5
        for <linux-mm@kvack.org>; Thu, 10 Oct 2013 11:06:37 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 34/34] mm: dynamically allocate page->ptl if it cannot be embedded to struct page
Date: Thu, 10 Oct 2013 21:05:59 +0300
Message-Id: <1381428359-14843-35-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381428359-14843-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If split page table lock is in use, we embed the lock into struct page
of table's page. We have to disable split lock, if spinlock_t is too big
be to be embedded, like when DEBUG_SPINLOCK or DEBUG_LOCK_ALLOC enabled.

This patch add support for dynamic allocation of split page table lock
if we can't embed it to struct page.

page->ptl is unsigned long now and we use it as spinlock_t if
sizeof(spinlock_t) <= sizeof(long), otherwise it's pointer to
spinlock_t.

The spinlock_t allocated in pgtable_page_ctor() for PTE table and in
pgtable_pmd_page_ctor() for PMD table. All other helpers converted to
support dynamically allocated page->ptl.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/split_page_table_lock | 90 ++++++++++++++++++++++++++++++++++
 arch/x86/xen/mmu.c                     |  2 +-
 include/linux/mm.h                     | 72 +++++++++++++++++++--------
 include/linux/mm_types.h               |  5 +-
 mm/Kconfig                             |  2 -
 mm/memory.c                            | 19 +++++++
 6 files changed, 166 insertions(+), 24 deletions(-)
 create mode 100644 Documentation/vm/split_page_table_lock

diff --git a/Documentation/vm/split_page_table_lock b/Documentation/vm/split_page_table_lock
new file mode 100644
index 0000000000..e2f617b732
--- /dev/null
+++ b/Documentation/vm/split_page_table_lock
@@ -0,0 +1,90 @@
+Split page table lock
+=====================
+
+Originally, mm->page_table_lock spinlock protected all page tables of the
+mm_struct. But this approach leads to poor page fault scalability of
+multi-threaded applications due high contention on the lock. To improve
+scalability, split page table lock was introduced.
+
+With split page table lock we have separate per-table lock to serialize
+access to the table. At the moment we use split lock for PTE and PMD
+tables. Access to higher level tables protected by mm->page_table_lock.
+
+There are helpers to lock/unlock a table and other accessor functions:
+ - pte_offset_map_lock()
+	maps pte and takes PTE table lock, returns pointer to the taken
+	lock;
+ - pte_unmap_unlock()
+	unlocks and unmaps PTE table;
+ - pte_alloc_map_lock()
+	allocates PTE table if needed and take the lock, returns pointer
+	to taken lock or NULL if allocation failed;
+ - pte_lockptr()
+	returns pointer to PTE table lock;
+ - pmd_lock()
+	takes PMD table lock, returns pointer to taken lock;
+ - pmd_lockptr()
+	returns pointer to PMD table lock;
+
+Split page table lock for PTE tables is enabled compile-time if
+CONFIG_SPLIT_PTLOCK_CPUS (usually 4) is less or equal to NR_CPUS.
+If split lock is disabled, all tables guaded by mm->page_table_lock.
+
+Split page table lock for PMD tables is enabled, if it's enabled for PTE
+tables and the architecture supports it (see below).
+
+Hugetlb and split page table lock
+---------------------------------
+
+Hugetlb can support several page sizes. We use split lock only for PMD
+level, but not for PUD.
+
+Hugetlb-specific helpers:
+ - huge_pte_lock()
+	takes pmd split lock for PMD_SIZE page, mm->page_table_lock
+	otherwise;
+ - huge_pte_lockptr()
+	returns pointer to table lock;
+
+Support of split page table lock by an architecture
+---------------------------------------------------
+
+There's no need in special enabling of PTE split page table lock:
+everything required is done by pgtable_page_ctor() and pgtable_page_dtor(),
+which must be called on PTE table allocation / freeing.
+
+PMD split lock only makes sense if you have more than two page table
+levels.
+
+PMD split lock enabling requires pgtable_pmd_page_ctor() call on PMD table
+allocation and pgtable_pmd_page_dtor() on freeing.
+
+Allocation usually happens in pmd_alloc_one(), freeing in pmd_free(), but
+make sure you cover all PMD table allocation / freeing paths: i.e X86_PAE
+preallocate few PMDs on pgd_alloc().
+
+With everything in place you can set CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK.
+
+NOTE: pgtable_page_ctor() and pgtable_pmd_page_ctor() can fail -- it must
+be handled properly.
+
+page->ptl
+---------
+
+page->ptl is used to access split page table lock, where 'page' is struct
+page of page containing the table. It shares storage with page->private
+(and few other fields in union).
+
+To avoid increasing size of struct page and have best performance, we use a
+trick:
+ - if spinlock_t fits into long, we use page->ptr as spinlock, so we
+   can avoid indirect access and save a cache line.
+ - if size of spinlock_t is bigger then size of long, we use page->ptl as
+   pointer to spinlock_t and allocate it dynamically. This allows to use
+   split lock with enabled DEBUG_SPINLOCK or DEBUG_LOCK_ALLOC, but costs
+   one more cache line for indirect access;
+
+The spinlock_t allocated in pgtable_page_ctor() for PTE table and in
+pgtable_pmd_page_ctor() for PMD table.
+
+Please, never access page->ptl directly -- use appropriate helper.
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index 455c873ce0..49c962fe7e 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -797,7 +797,7 @@ static spinlock_t *xen_pte_lock(struct page *page, struct mm_struct *mm)
 	spinlock_t *ptl = NULL;
 
 #if USE_SPLIT_PTE_PTLOCKS
-	ptl = __pte_lockptr(page);
+	ptl = ptlock_ptr(page);
 	spin_lock_nest_lock(ptl, &mm->page_table_lock);
 #endif
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f6467032a9..658e8b317f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1233,32 +1233,64 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
 #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
 
 #if USE_SPLIT_PTE_PTLOCKS
-/*
- * We tuck a spinlock to guard each pagetable page into its struct page,
- * at page->private, with BUILD_BUG_ON to make sure that this will not
- * overflow into the next struct page (as it might with DEBUG_SPINLOCK).
- * When freeing, reset page->mapping so free_pages_check won't complain.
- */
-#define __pte_lockptr(page)	&((page)->ptl)
-#define pte_lock_init(_page)	do {					\
-	spin_lock_init(__pte_lockptr(_page));				\
-} while (0)
-#define pte_lock_deinit(page)	((page)->mapping = NULL)
-#define pte_lockptr(mm, pmd)	({(void)(mm); __pte_lockptr(pmd_page(*(pmd)));})
+bool __ptlock_alloc(struct page *page);
+void __ptlock_free(struct page *page);
+static inline bool ptlock_alloc(struct page *page)
+{
+	if (sizeof(spinlock_t) > sizeof(page->ptl))
+		return __ptlock_alloc(page);
+	return true;
+}
+static inline void ptlock_free(struct page *page)
+{
+	if (sizeof(spinlock_t) > sizeof(page->ptl))
+		__ptlock_free(page);
+}
+
+static inline spinlock_t *ptlock_ptr(struct page *page)
+{
+	if (sizeof(spinlock_t) > sizeof(page->ptl))
+		return (spinlock_t *) page->ptl;
+	else
+		return (spinlock_t *) &page->ptl;
+}
+
+static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)
+{
+	return ptlock_ptr(pmd_page(*pmd));
+}
+
+static inline bool ptlock_init(struct page *page)
+{
+	if (!ptlock_alloc(page))
+		return false;
+	spin_lock_init(ptlock_ptr(page));
+	return true;
+}
+
+/* Reset page->mapping so free_pages_check won't complain. */
+static inline void pte_lock_deinit(struct page *page)
+{
+	page->mapping = NULL;
+	ptlock_free(page);
+}
+
 #else	/* !USE_SPLIT_PTE_PTLOCKS */
 /*
  * We use mm->page_table_lock to guard all pagetable pages of the mm.
  */
-#define pte_lock_init(page)	do {} while (0)
-#define pte_lock_deinit(page)	do {} while (0)
-#define pte_lockptr(mm, pmd)	({(void)(pmd); &(mm)->page_table_lock;})
+static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)
+{
+	return &mm->page_table_lock;
+}
+static inline bool ptlock_init(struct page *page) { return true; }
+static inline void pte_lock_deinit(struct page *page) {}
 #endif /* USE_SPLIT_PTE_PTLOCKS */
 
 static inline bool pgtable_page_ctor(struct page *page)
 {
-	pte_lock_init(page);
 	inc_zone_page_state(page, NR_PAGETABLE);
-	return true;
+	return ptlock_init(page);
 }
 
 static inline void pgtable_page_dtor(struct page *page)
@@ -1299,16 +1331,15 @@ static inline void pgtable_page_dtor(struct page *page)
 
 static inline spinlock_t *pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
 {
-	return &virt_to_page(pmd)->ptl;
+	return ptlock_ptr(virt_to_page(pmd));
 }
 
 static inline bool pgtable_pmd_page_ctor(struct page *page)
 {
-	spin_lock_init(&page->ptl);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	page->pmd_huge_pte = NULL;
 #endif
-	return true;
+	return ptlock_init(page);
 }
 
 static inline void pgtable_pmd_page_dtor(struct page *page)
@@ -1316,6 +1347,7 @@ static inline void pgtable_pmd_page_dtor(struct page *page)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	VM_BUG_ON(page->pmd_huge_pte);
 #endif
+	ptlock_free(page);
 }
 
 #define pmd_huge_pte(mm, pmd) (virt_to_page(pmd)->pmd_huge_pte)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index bacc15f078..257ac12fac 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -147,7 +147,10 @@ struct page {
 						 * system if PG_buddy is set.
 						 */
 #if USE_SPLIT_PTE_PTLOCKS
-		spinlock_t ptl;
+		unsigned long ptl; /* It's spinlock_t if it fits to long,
+				    * otherwise it's pointer to dynamicaly
+				    * allocated spinlock_t.
+				    */
 #endif
 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
 		struct page *first_page;	/* Compound tail pages */
diff --git a/mm/Kconfig b/mm/Kconfig
index d19f7d380b..9e8c8ae3b6 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -211,8 +211,6 @@ config SPLIT_PTLOCK_CPUS
 	int
 	default "999999" if ARM && !CPU_CACHE_VIPT
 	default "999999" if PARISC && !PA20
-	default "999999" if DEBUG_SPINLOCK || DEBUG_LOCK_ALLOC
-	default "999999" if !64BIT && GENERIC_LOCKBREAK
 	default "4"
 
 config ARCH_ENABLE_SPLIT_PMD_PTLOCK
diff --git a/mm/memory.c b/mm/memory.c
index 1200d6230c..7e11f745bc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4330,3 +4330,22 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 	}
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
+
+#if USE_SPLIT_PTE_PTLOCKS
+bool __ptlock_alloc(struct page *page)
+{
+	spinlock_t *ptl;
+
+	ptl = kmalloc(sizeof(spinlock_t), GFP_KERNEL);
+	if (!ptl)
+		return false;
+	page->ptl = (unsigned long)ptl;
+	return true;
+}
+
+void __ptlock_free(struct page *page)
+{
+	if (sizeof(spinlock_t) > sizeof(page->ptl))
+		kfree((spinlock_t *)page->ptl);
+}
+#endif
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
