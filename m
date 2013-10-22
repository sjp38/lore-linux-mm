Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6D81E6B03C0
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 07:54:07 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so9633364pab.13
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 04:54:07 -0700 (PDT)
Received: from psmtp.com ([74.125.245.151])
        by mx.google.com with SMTP id if1si12019095pad.146.2013.10.22.04.54.05
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 04:54:06 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: create a separate slab for page->ptl allocation
Date: Tue, 22 Oct 2013 14:53:59 +0300
Message-Id: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If DEBUG_SPINLOCK and DEBUG_LOCK_ALLOC are enabled spinlock_t on x86_64
is 72 bytes. For page->ptl they will be allocated from kmalloc-96 slab,
so we loose 24 on each. An average system can easily allocate few tens
thousands of page->ptl and overhead is significant.

Let's create a separate slab for page->ptl allocation to solve this.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |  8 ++++++++
 init/main.c        |  2 +-
 mm/memory.c        | 12 ++++++++++--
 3 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9a4a873b2f..2de5da0a41 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1233,6 +1233,7 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
 #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
 
 #if USE_SPLIT_PTE_PTLOCKS
+void __init ptlock_cache_init(void);
 bool __ptlock_alloc(struct page *page);
 void __ptlock_free(struct page *page);
 static inline bool ptlock_alloc(struct page *page)
@@ -1285,6 +1286,7 @@ static inline void pte_lock_deinit(struct page *page)
 }
 
 #else	/* !USE_SPLIT_PTE_PTLOCKS */
+static inline void ptlock_cache_init(void) {}
 /*
  * We use mm->page_table_lock to guard all pagetable pages of the mm.
  */
@@ -1296,6 +1298,12 @@ static inline bool ptlock_init(struct page *page) { return true; }
 static inline void pte_lock_deinit(struct page *page) {}
 #endif /* USE_SPLIT_PTE_PTLOCKS */
 
+static inline void pgtable_init(void)
+{
+	ptlock_cache_init();
+	pgtable_cache_init();
+}
+
 static inline bool pgtable_page_ctor(struct page *page)
 {
 	inc_zone_page_state(page, NR_PAGETABLE);
diff --git a/init/main.c b/init/main.c
index af310afbef..c71b505392 100644
--- a/init/main.c
+++ b/init/main.c
@@ -466,7 +466,7 @@ static void __init mm_init(void)
 	mem_init();
 	kmem_cache_init();
 	percpu_init_late();
-	pgtable_cache_init();
+	pgtable_init();
 	vmalloc_init();
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index 7e11f745bc..d7e583e270 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4332,11 +4332,19 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
 #if USE_SPLIT_PTE_PTLOCKS
+struct kmem_cache *page_ptl_cachep;
+void __init ptlock_cache_init(void)
+{
+	if (sizeof(spinlock_t) > sizeof(long))
+		page_ptl_cachep = kmem_cache_create("page->ptl",
+				sizeof(spinlock_t), 0, SLAB_PANIC, NULL);
+}
+
 bool __ptlock_alloc(struct page *page)
 {
 	spinlock_t *ptl;
 
-	ptl = kmalloc(sizeof(spinlock_t), GFP_KERNEL);
+	ptl = kmem_cache_alloc(page_ptl_cachep, GFP_KERNEL);
 	if (!ptl)
 		return false;
 	page->ptl = (unsigned long)ptl;
@@ -4346,6 +4354,6 @@ bool __ptlock_alloc(struct page *page)
 void __ptlock_free(struct page *page)
 {
 	if (sizeof(spinlock_t) > sizeof(page->ptl))
-		kfree((spinlock_t *)page->ptl);
+		kmem_cache_free(page_ptl_cachep, (spinlock_t *)page->ptl);
 }
 #endif
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
