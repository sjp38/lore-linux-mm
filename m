Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A1EF96B004D
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 06:36:08 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so2417937pdj.23
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 03:36:08 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ob10si5002070pbb.247.2013.12.20.03.36.06
        for <linux-mm@kvack.org>;
        Fri, 20 Dec 2013 03:36:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: do not allocate page->ptl dynamically, if spinlock_t fits to long
Date: Fri, 20 Dec 2013 13:35:58 +0200
Message-Id: <1387539358-7302-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

In struct page we have enough space to fit long-size page->ptl
there, but we use dynamically-allocated page->ptl if
size(spinlock_t) > sizeof(int). It hurts 64-bit architectures with
CONFIG_GENERIC_LOCKBREAK, where sizeof(spinlock_t) == 8, but it
easily fits into struct page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Hugh Dickins <hughd@google.com>
---
 include/linux/lockref.h  | 2 +-
 include/linux/mm.h       | 6 +++---
 include/linux/mm_types.h | 3 ++-
 kernel/bounds.c          | 2 +-
 mm/memory.c              | 2 +-
 5 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/lockref.h b/include/linux/lockref.h
index c8929c3832db..4bfde0e99ed5 100644
--- a/include/linux/lockref.h
+++ b/include/linux/lockref.h
@@ -19,7 +19,7 @@
 
 #define USE_CMPXCHG_LOCKREF \
 	(IS_ENABLED(CONFIG_ARCH_USE_CMPXCHG_LOCKREF) && \
-	 IS_ENABLED(CONFIG_SMP) && !BLOATED_SPINLOCKS)
+	 IS_ENABLED(CONFIG_SMP) && SPINLOCK_SIZE <= 4)
 
 struct lockref {
 	union {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1cedd000cf29..35527173cf50 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1317,7 +1317,7 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
 #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
 
 #if USE_SPLIT_PTE_PTLOCKS
-#if BLOATED_SPINLOCKS
+#if ALLOC_SPLIT_PTLOCKS
 extern bool ptlock_alloc(struct page *page);
 extern void ptlock_free(struct page *page);
 
@@ -1325,7 +1325,7 @@ static inline spinlock_t *ptlock_ptr(struct page *page)
 {
 	return page->ptl;
 }
-#else /* BLOATED_SPINLOCKS */
+#else /* ALLOC_SPLIT_PTLOCKS */
 static inline bool ptlock_alloc(struct page *page)
 {
 	return true;
@@ -1339,7 +1339,7 @@ static inline spinlock_t *ptlock_ptr(struct page *page)
 {
 	return &page->ptl;
 }
-#endif /* BLOATED_SPINLOCKS */
+#endif /* ALLOC_SPLIT_PTLOCKS */
 
 static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)
 {
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index bd299418a934..494b328c2a61 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -26,6 +26,7 @@ struct address_space;
 #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 #define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
 		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK))
+#define ALLOC_SPLIT_PTLOCKS	(SPINLOCK_SIZE > BITS_PER_LONG/8)
 
 /*
  * Each physical page in the system has a struct page associated with
@@ -155,7 +156,7 @@ struct page {
 						 * system if PG_buddy is set.
 						 */
 #if USE_SPLIT_PTE_PTLOCKS
-#if BLOATED_SPINLOCKS
+#if ALLOC_SPLIT_PTLOCKS
 		spinlock_t *ptl;
 #else
 		spinlock_t ptl;
diff --git a/kernel/bounds.c b/kernel/bounds.c
index 5253204afdca..9fd4246b04b8 100644
--- a/kernel/bounds.c
+++ b/kernel/bounds.c
@@ -22,6 +22,6 @@ void foo(void)
 #ifdef CONFIG_SMP
 	DEFINE(NR_CPUS_BITS, ilog2(CONFIG_NR_CPUS));
 #endif
-	DEFINE(BLOATED_SPINLOCKS, sizeof(spinlock_t) > sizeof(int));
+	DEFINE(SPINLOCK_SIZE, sizeof(spinlock_t));
 	/* End of constants */
 }
diff --git a/mm/memory.c b/mm/memory.c
index 5d9025f3b3e1..b6e211b779d0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4271,7 +4271,7 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
-#if USE_SPLIT_PTE_PTLOCKS && BLOATED_SPINLOCKS
+#if ALLOC_SPLIT_PTLOCKS
 bool ptlock_alloc(struct page *page)
 {
 	spinlock_t *ptl;
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
