Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1156B015E
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 09:14:24 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id uo15so655156pbc.9
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 06:14:24 -0800 (PST)
Received: from psmtp.com ([74.125.245.181])
        by mx.google.com with SMTP id z1si2769788pbw.129.2013.11.07.06.14.22
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 06:14:23 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] mm: create a separate slab for page->ptl allocation
Date: Thu,  7 Nov 2013 16:14:04 +0200
Message-Id: <1383833644-27091-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1383833644-27091-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1383833644-27091-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

If DEBUG_SPINLOCK and DEBUG_LOCK_ALLOC are enabled spinlock_t on x86_64
is 72 bytes. For page->ptl they will be allocated from kmalloc-96 slab,
so we loose 24 on each. An average system can easily allocate few tens
thousands of page->ptl and overhead is significant.

Let's create a separate slab for page->ptl allocation to solve this.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 9 +++++++++
 init/main.c        | 2 +-
 mm/memory.c        | 7 +++++++
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1cedd000cf29..0548eb201e05 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1318,6 +1318,7 @@ static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long a
 
 #if USE_SPLIT_PTE_PTLOCKS
 #if BLOATED_SPINLOCKS
+void __init ptlock_cache_init(void);
 extern bool ptlock_alloc(struct page *page);
 extern void ptlock_free(struct page *page);
 
@@ -1326,6 +1327,7 @@ static inline spinlock_t *ptlock_ptr(struct page *page)
 	return page->ptl;
 }
 #else /* BLOATED_SPINLOCKS */
+static inline void ptlock_cache_init(void) {}
 static inline bool ptlock_alloc(struct page *page)
 {
 	return true;
@@ -1378,10 +1380,17 @@ static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)
 {
 	return &mm->page_table_lock;
 }
+static inline void ptlock_cache_init(void) {}
 static inline bool ptlock_init(struct page *page) { return true; }
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
index febc511e078a..01573fdfa186 100644
--- a/init/main.c
+++ b/init/main.c
@@ -476,7 +476,7 @@ static void __init mm_init(void)
 	mem_init();
 	kmem_cache_init();
 	percpu_init_late();
-	pgtable_cache_init();
+	pgtable_init();
 	vmalloc_init();
 }
 
diff --git a/mm/memory.c b/mm/memory.c
index f6cd03e4dec6..8e764473d0ff 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4272,6 +4272,13 @@ void copy_user_huge_page(struct page *dst, struct page *src,
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
 #if USE_SPLIT_PTE_PTLOCKS && BLOATED_SPINLOCKS
+static struct kmem_cache *page_ptl_cachep;
+void __init ptlock_cache_init(void)
+{
+	page_ptl_cachep = kmem_cache_create("page->ptl", sizeof(spinlock_t), 0,
+			SLAB_PANIC, NULL);
+}
+
 bool ptlock_alloc(struct page *page)
 {
 	spinlock_t *ptl;
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
