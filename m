Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 29B936B015C
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 09:14:13 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id x10so642360pdj.23
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 06:14:12 -0800 (PST)
Received: from psmtp.com ([74.125.245.161])
        by mx.google.com with SMTP id pl8si2777698pbb.194.2013.11.07.06.14.10
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 06:14:11 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] mm: Properly separate the bloated ptl from the regular case
Date: Thu,  7 Nov 2013 16:14:03 +0200
Message-Id: <1383833644-27091-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: Peter Zijlstra <peterz@infradead.org>

Use kernel/bounds.c to convert build-time spinlock_t size check into
a preprocessor symbol and apply that to properly separate the page::ptl
situation.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h       | 24 +++++++++++++-----------
 include/linux/mm_types.h |  9 +++++----
 kernel/bounds.c          |  2 ++
 mm/memory.c              | 11 +++++------
 4 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d0339741b6ce..1cedd000cf29 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1317,27 +1317,29 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
 #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
 
 #if USE_SPLIT_PTE_PTLOCKS
-bool __ptlock_alloc(struct page *page);
-void __ptlock_free(struct page *page);
+#if BLOATED_SPINLOCKS
+extern bool ptlock_alloc(struct page *page);
+extern void ptlock_free(struct page *page);
+
+static inline spinlock_t *ptlock_ptr(struct page *page)
+{
+	return page->ptl;
+}
+#else /* BLOATED_SPINLOCKS */
 static inline bool ptlock_alloc(struct page *page)
 {
-	if (sizeof(spinlock_t) > sizeof(page->ptl))
-		return __ptlock_alloc(page);
 	return true;
 }
+
 static inline void ptlock_free(struct page *page)
 {
-	if (sizeof(spinlock_t) > sizeof(page->ptl))
-		__ptlock_free(page);
 }
 
 static inline spinlock_t *ptlock_ptr(struct page *page)
 {
-	if (sizeof(spinlock_t) > sizeof(page->ptl))
-		return (spinlock_t *) page->ptl;
-	else
-		return (spinlock_t *) &page->ptl;
+	return &page->ptl;
 }
+#endif /* BLOATED_SPINLOCKS */
 
 static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)
 {
@@ -1354,7 +1356,7 @@ static inline bool ptlock_init(struct page *page)
 	 * slab code uses page->slab_cache and page->first_page (for tail
 	 * pages), which share storage with page->ptl.
 	 */
-	VM_BUG_ON(page->ptl);
+	VM_BUG_ON(*(unsigned long *)&page->ptl);
 	if (!ptlock_alloc(page))
 		return false;
 	spin_lock_init(ptlock_ptr(page));
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 752b6d4ee5dc..7ddc3d5c7776 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -156,10 +156,11 @@ struct page {
 						 * system if PG_buddy is set.
 						 */
 #if USE_SPLIT_PTE_PTLOCKS
-		unsigned long ptl; /* It's spinlock_t if it fits to long,
-				    * otherwise it's pointer to dynamicaly
-				    * allocated spinlock_t.
-				    */
+#if BLOATED_SPINLOCKS
+		spinlock_t *ptl;
+#else
+		spinlock_t ptl;
+#endif
 #endif
 		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
 		struct page *first_page;	/* Compound tail pages */
diff --git a/kernel/bounds.c b/kernel/bounds.c
index e8ca97b5c386..578782ef6ae1 100644
--- a/kernel/bounds.c
+++ b/kernel/bounds.c
@@ -11,6 +11,7 @@
 #include <linux/kbuild.h>
 #include <linux/page_cgroup.h>
 #include <linux/log2.h>
+#include <linux/spinlock.h>
 
 void foo(void)
 {
@@ -21,5 +22,6 @@ void foo(void)
 #ifdef CONFIG_SMP
 	DEFINE(NR_CPUS_BITS, ilog2(CONFIG_NR_CPUS));
 #endif
+	DEFINE(BLOATED_SPINLOCKS, sizeof(spinlock_t) > sizeof(int));
 	/* End of constants */
 }
diff --git a/mm/memory.c b/mm/memory.c
index 6f7bdee617e2..f6cd03e4dec6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4271,21 +4271,20 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
-#if USE_SPLIT_PTE_PTLOCKS
-bool __ptlock_alloc(struct page *page)
+#if USE_SPLIT_PTE_PTLOCKS && BLOATED_SPINLOCKS
+bool ptlock_alloc(struct page *page)
 {
 	spinlock_t *ptl;
 
 	ptl = kmalloc(sizeof(spinlock_t), GFP_KERNEL);
 	if (!ptl)
 		return false;
-	page->ptl = (unsigned long)ptl;
+	page->ptl = ptl;
 	return true;
 }
 
-void __ptlock_free(struct page *page)
+void ptlock_free(struct page *page)
 {
-	if (sizeof(spinlock_t) > sizeof(page->ptl))
-		kfree((spinlock_t *)page->ptl);
+	kfree(page->ptl);
 }
 #endif
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
