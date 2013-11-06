Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 03FDE6B00C6
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 04:31:49 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kq14so10238554pab.35
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 01:31:49 -0800 (PST)
Received: from psmtp.com ([74.125.245.106])
        by mx.google.com with SMTP id ba2si15820800pbc.268.2013.11.06.01.31.45
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 01:31:46 -0800 (PST)
Date: Wed, 6 Nov 2013 10:31:31 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: create a separate slab for page->ptl allocation
Message-ID: <20131106093131.GU28601@twins.programming.kicks-ass.net>
References: <1382442839-7458-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20131105150145.734a5dd5b5d455800ebfa0d3@linux-foundation.org>
 <20131105224217.GC20167@shutemov.name>
 <20131105155619.021f32eba1ca8f15a73ed4c9@linux-foundation.org>
 <20131105231310.GE20167@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131105231310.GE20167@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Wed, Nov 06, 2013 at 01:13:11AM +0200, Kirill A. Shutemov wrote:
> I would like to get rid of __ptlock_alloc()/__ptlock_free() too, but I
> don't see a way within C: we need to know sizeof(spinlock_t) on
> preprocessor stage.
> 
> We can have a hack on kbuild level: write small helper program to find out
> sizeof(spinlock_t) before start building and turn it into define.
> But it's overkill from my POV. And cross-compilation will be a fun.

Ah, I just remembered, we have such a thing!

---
Subject: mm: Properly separate the bloated ptl from the regular case

Use kernel/bounds.c to convert build-time spinlock_t size into a
preprocessor symbol and apply that to properly separate the page::ptl
situation.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 include/linux/mm.h       | 24 +++++++++++++-----------
 include/linux/mm_types.h |  9 +++++----
 kernel/bounds.c          |  2 ++
 mm/memory.c              | 11 +++++------
 4 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d0339741b6ce..6ab26704671b 100644
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
index 5bee515c4505..f706743b63bb 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -155,10 +155,11 @@ struct page {
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
index e8ca97b5c386..5982437eca2c 100644
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
index 6f7bdee617e2..8356eac27d0a 100644
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
