Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 65C9B6B004D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 04:55:00 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC] propagate gfp_t to page table alloc functions
Date: Mon, 23 Apr 2012 17:55:18 +0900
Message-Id: <1335171318-4838-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

As I test some code, I found a problem about deadlock by lockdep.
The reason I saw the message is __vmalloc calls map_vm_area which calls
pud/pmd_alloc without gfp_t. so although we call __vmalloc with
GFP_ATOMIC or GFP_NOIO, it ends up allocating pages with GFP_KERNEL.
The should be a BUG. This patch fixes it by passing gfp_to to low page
table allocate functions.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
NOTE!
This isn't perfect patch but I send this patch which only works for x86
to listen opinion from others. If it's best, I will fix other architectures
and resend it. Maybe the patch would become a all-in-one patch which
changes all architectures all at once. If you have better idea not to
break bisectability, please advise me.


 arch/x86/include/asm/pgalloc.h      |   15 ++++++----
 arch/x86/kernel/tboot.c             |    4 +--
 arch/x86/mm/hugetlbpage.c           |    4 +--
 arch/x86/mm/pgtable.c               |    8 +++--
 include/asm-generic/4level-fixup.h  |    7 +++--
 include/asm-generic/pgtable-nopmd.h |    2 +-
 include/asm-generic/pgtable-nopud.h |    2 +-
 include/linux/mm.h                  |   29 +++++++++++-------
 lib/ioremap.c                       |    6 ++--
 mm/memory.c                         |   36 ++++++++++++-----------
 mm/mremap.c                         |    4 +--
 mm/vmalloc.c                        |   55 +++++++++++++++++++++++++----------
 12 files changed, 106 insertions(+), 66 deletions(-)

diff --git a/arch/x86/include/asm/pgalloc.h b/arch/x86/include/asm/pgalloc.h
index b4389a4..9a6408f 100644
--- a/arch/x86/include/asm/pgalloc.h
+++ b/arch/x86/include/asm/pgalloc.h
@@ -33,7 +33,8 @@ extern gfp_t __userpte_alloc_gfp;
 extern pgd_t *pgd_alloc(struct mm_struct *);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
-extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
+extern pte_t *pte_alloc_one_kernel(struct mm_struct *,
+					unsigned long, gfp_t);
 extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);
 
 /* Should really implement gc for free page table pages. This could be
@@ -78,9 +79,11 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 #define pmd_pgtable(pmd) pmd_page(pmd)
 
 #if PAGETABLE_LEVELS > 2
-static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pmd_t *pmd_alloc_one(struct mm_struct *mm,
+			unsigned long addr, gfp_t gfp_mask)
 {
-	return (pmd_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pmd_t *)get_zeroed_page(__GFP_REPEAT |
+					(gfp_mask & ~__GFP_HIGHMEM));
 }
 
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -114,9 +117,11 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
 	set_pgd(pgd, __pgd(_PAGE_TABLE | __pa(pud)));
 }
 
-static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
+static inline pud_t *pud_alloc_one(struct mm_struct *mm,
+				unsigned long addr, gfp_t gfp_mask)
 {
-	return (pud_t *)get_zeroed_page(GFP_KERNEL|__GFP_REPEAT);
+	return (pud_t *)get_zeroed_page(__GFP_REPEAT |
+				(gfp_mask & ~__GFP_HIGHMEM));
 }
 
 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
diff --git a/arch/x86/kernel/tboot.c b/arch/x86/kernel/tboot.c
index 6410744..c0d8df1 100644
--- a/arch/x86/kernel/tboot.c
+++ b/arch/x86/kernel/tboot.c
@@ -128,10 +128,10 @@ static int map_tboot_page(unsigned long vaddr, unsigned long pfn,
 	pte_t *pte;
 
 	pgd = pgd_offset(&tboot_mm, vaddr);
-	pud = pud_alloc(&tboot_mm, pgd, vaddr);
+	pud = pud_alloc(&tboot_mm, pgd, vaddr, GFP_KERNEL);
 	if (!pud)
 		return -1;
-	pmd = pmd_alloc(&tboot_mm, pud, vaddr);
+	pmd = pmd_alloc(&tboot_mm, pud, vaddr, GFP_KERNEL);
 	if (!pmd)
 		return -1;
 	pte = pte_alloc_map(&tboot_mm, NULL, pmd, vaddr);
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index f6679a7..95260b9 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -135,7 +135,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 	pte_t *pte = NULL;
 
 	pgd = pgd_offset(mm, addr);
-	pud = pud_alloc(mm, pgd, addr);
+	pud = pud_alloc(mm, pgd, addr, GFP_KERNEL);
 	if (pud) {
 		if (sz == PUD_SIZE) {
 			pte = (pte_t *)pud;
@@ -143,7 +143,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 			BUG_ON(sz != PMD_SIZE);
 			if (pud_none(*pud))
 				huge_pmd_share(mm, addr, pud);
-			pte = (pte_t *) pmd_alloc(mm, pud, addr);
+			pte = (pte_t *) pmd_alloc(mm, pud, addr, GFP_KERNEL);
 		}
 	}
 	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 8573b83..5b7ee39 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -5,7 +5,7 @@
 #include <asm/tlb.h>
 #include <asm/fixmap.h>
 
-#define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
+#define PGALLOC_GFP (GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
 
 #ifdef CONFIG_HIGHPTE
 #define PGALLOC_USER_GFP __GFP_HIGHMEM
@@ -15,9 +15,11 @@
 
 gfp_t __userpte_alloc_gfp = PGALLOC_GFP | PGALLOC_USER_GFP;
 
-pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
+pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
+		unsigned long address, gfp_t gfp_mask)
 {
-	return (pte_t *)__get_free_page(PGALLOC_GFP);
+	return (pte_t *)__get_free_page(PGALLOC_GFP & ~GFP_KERNEL |
+			(gfp_mask & ~__GFP_HIGHMEM));
 }
 
 pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/4level-fixup.h
index 77ff547..ceba139 100644
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -10,11 +10,12 @@
 
 #define pud_t				pgd_t
 
-#define pmd_alloc(mm, pud, address) \
-	((unlikely(pgd_none(*(pud))) && __pmd_alloc(mm, pud, address))? \
+#define pmd_alloc(mm, pud, address, gfp_mask) \
+	((unlikely(pgd_none(*(pud))) &&		\
+		__pmd_alloc(mm, pud, address, gfp_mask))? \
  		NULL: pmd_offset(pud, address))
 
-#define pud_alloc(mm, pgd, address)	(pgd)
+#define pud_alloc(mm, pgd, address, gfp_mask)	(pgd)
 #define pud_offset(pgd, start)		(pgd)
 #define pud_none(pud)			0
 #define pud_bad(pud)			0
diff --git a/include/asm-generic/pgtable-nopmd.h b/include/asm-generic/pgtable-nopmd.h
index 725612b..298bd89 100644
--- a/include/asm-generic/pgtable-nopmd.h
+++ b/include/asm-generic/pgtable-nopmd.h
@@ -55,7 +55,7 @@ static inline pmd_t * pmd_offset(pud_t * pud, unsigned long address)
  * allocating and freeing a pmd is trivial: the 1-entry pmd is
  * inside the pud, so has no extra memory associated with it.
  */
-#define pmd_alloc_one(mm, address)		NULL
+#define pmd_alloc_one(mm, address, gfp_mask)		NULL
 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 {
 }
diff --git a/include/asm-generic/pgtable-nopud.h b/include/asm-generic/pgtable-nopud.h
index 810431d..cdd3b08 100644
--- a/include/asm-generic/pgtable-nopud.h
+++ b/include/asm-generic/pgtable-nopud.h
@@ -50,7 +50,7 @@ static inline pud_t * pud_offset(pgd_t * pgd, unsigned long address)
  * allocating and freeing a pud is trivial: the 1-entry pud is
  * inside the pgd, so has no extra memory associated with it.
  */
-#define pud_alloc_one(mm, address)		NULL
+#define pud_alloc_one(mm, address, gfp_mask)		NULL
 #define pud_free(mm, x)				do { } while (0)
 #define __pud_free_tlb(tlb, x, a)		do { } while (0)
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d8738a4..c93302b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1153,42 +1153,48 @@ static inline pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
 
 #ifdef __PAGETABLE_PUD_FOLDED
 static inline int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
-						unsigned long address)
+				unsigned long address, gfp_t gfp_mask)
 {
 	return 0;
 }
 #else
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
+		unsigned long address, gfp_t gfp_mask);
 #endif
 
 #ifdef __PAGETABLE_PMD_FOLDED
 static inline int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
-						unsigned long address)
+				unsigned long address, gfp_t gfp_mask)
 {
 	return 0;
 }
 #else
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
+		unsigned long address, gfp_t gfp_mask);
 #endif
 
 int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 		pmd_t *pmd, unsigned long address);
-int __pte_alloc_kernel(pmd_t *pmd, unsigned long address);
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address, gfp_t gfp_mask);
 
 /*
  * The following ifdef needed to get the 4level-fixup.h header to work.
  * Remove it when 4level-fixup.h has been removed.
  */
 #if defined(CONFIG_MMU) && !defined(__ARCH_HAS_4LEVEL_HACK)
-static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd,
+			unsigned long address, gfp_t gfp_mask)
 {
-	return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
+	return (unlikely(pgd_none(*pgd)) &&
+		__pud_alloc(mm, pgd, address, gfp_mask))?
 		NULL: pud_offset(pgd, address);
 }
 
-static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud,
+			unsigned long address, gfp_t gfp_mask)
 {
-	return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
+	return (unlikely(pud_none(*pud)) &&
+		__pmd_alloc(mm, pud, address, gfp_mask))?
 		NULL: pmd_offset(pud, address);
 }
 #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */
@@ -1251,8 +1257,9 @@ static inline void pgtable_page_dtor(struct page *page)
 							pmd, address))?	\
 		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))
 
-#define pte_alloc_kernel(pmd, address)			\
-	((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
+#define pte_alloc_kernel(pmd, address, gfp_mask)			\
+	((unlikely(pmd_none(*(pmd))) &&		\
+		__pte_alloc_kernel(pmd, address, gfp_mask))? \
 		NULL: pte_offset_kernel(pmd, address))
 
 extern void free_area_init(unsigned long * zones_size);
diff --git a/lib/ioremap.c b/lib/ioremap.c
index 0c9216c..d2c4fd3 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -20,7 +20,7 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
 	u64 pfn;
 
 	pfn = phys_addr >> PAGE_SHIFT;
-	pte = pte_alloc_kernel(pmd, addr);
+	pte = pte_alloc_kernel(pmd, addr, GFP_KERNEL);
 	if (!pte)
 		return -ENOMEM;
 	do {
@@ -38,7 +38,7 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
 	unsigned long next;
 
 	phys_addr -= addr;
-	pmd = pmd_alloc(&init_mm, pud, addr);
+	pmd = pmd_alloc(&init_mm, pud, addr, GFP_KERNEL);
 	if (!pmd)
 		return -ENOMEM;
 	do {
@@ -56,7 +56,7 @@ static inline int ioremap_pud_range(pgd_t *pgd, unsigned long addr,
 	unsigned long next;
 
 	phys_addr -= addr;
-	pud = pud_alloc(&init_mm, pgd, addr);
+	pud = pud_alloc(&init_mm, pgd, addr, GFP_KERNEL);
 	if (!pud)
 		return -ENOMEM;
 	do {
diff --git a/mm/memory.c b/mm/memory.c
index 706a274..9d3bc40 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -608,9 +608,9 @@ int __pte_alloc(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 }
 
-int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address, gfp_t gfp_mask)
 {
-	pte_t *new = pte_alloc_one_kernel(&init_mm, address);
+	pte_t *new = pte_alloc_one_kernel(&init_mm, address, gfp_mask);
 	if (!new)
 		return -ENOMEM;
 
@@ -980,7 +980,7 @@ static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src
 	pmd_t *src_pmd, *dst_pmd;
 	unsigned long next;
 
-	dst_pmd = pmd_alloc(dst_mm, dst_pud, addr);
+	dst_pmd = pmd_alloc(dst_mm, dst_pud, addr, GFP_KERNEL);
 	if (!dst_pmd)
 		return -ENOMEM;
 	src_pmd = pmd_offset(src_pud, addr);
@@ -1013,7 +1013,7 @@ static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src
 	pud_t *src_pud, *dst_pud;
 	unsigned long next;
 
-	dst_pud = pud_alloc(dst_mm, dst_pgd, addr);
+	dst_pud = pud_alloc(dst_mm, dst_pgd, addr, GFP_KERNEL);
 	if (!dst_pud)
 		return -ENOMEM;
 	src_pud = pud_offset(src_pgd, addr);
@@ -1997,9 +1997,9 @@ pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
 			spinlock_t **ptl)
 {
 	pgd_t * pgd = pgd_offset(mm, addr);
-	pud_t * pud = pud_alloc(mm, pgd, addr);
+	pud_t * pud = pud_alloc(mm, pgd, addr, GFP_KERNEL);
 	if (pud) {
-		pmd_t * pmd = pmd_alloc(mm, pud, addr);
+		pmd_t * pmd = pmd_alloc(mm, pud, addr, GFP_KERNEL);
 		if (pmd) {
 			VM_BUG_ON(pmd_trans_huge(*pmd));
 			return pte_alloc_map_lock(mm, pmd, addr, ptl);
@@ -2219,7 +2219,7 @@ static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
 	unsigned long next;
 
 	pfn -= addr >> PAGE_SHIFT;
-	pmd = pmd_alloc(mm, pud, addr);
+	pmd = pmd_alloc(mm, pud, addr, GFP_KERNEL);
 	if (!pmd)
 		return -ENOMEM;
 	VM_BUG_ON(pmd_trans_huge(*pmd));
@@ -2240,7 +2240,7 @@ static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
 	unsigned long next;
 
 	pfn -= addr >> PAGE_SHIFT;
-	pud = pud_alloc(mm, pgd, addr);
+	pud = pud_alloc(mm, pgd, addr, GFP_KERNEL);
 	if (!pud)
 		return -ENOMEM;
 	do {
@@ -2337,7 +2337,7 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
 	spinlock_t *uninitialized_var(ptl);
 
 	pte = (mm == &init_mm) ?
-		pte_alloc_kernel(pmd, addr) :
+		pte_alloc_kernel(pmd, addr, GFP_KERNEL) :
 		pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)
 		return -ENOMEM;
@@ -2371,7 +2371,7 @@ static int apply_to_pmd_range(struct mm_struct *mm, pud_t *pud,
 
 	BUG_ON(pud_huge(*pud));
 
-	pmd = pmd_alloc(mm, pud, addr);
+	pmd = pmd_alloc(mm, pud, addr, GFP_KERNEL);
 	if (!pmd)
 		return -ENOMEM;
 	do {
@@ -2391,7 +2391,7 @@ static int apply_to_pud_range(struct mm_struct *mm, pgd_t *pgd,
 	unsigned long next;
 	int err;
 
-	pud = pud_alloc(mm, pgd, addr);
+	pud = pud_alloc(mm, pgd, addr, GFP_KERNEL);
 	if (!pud)
 		return -ENOMEM;
 	do {
@@ -3493,10 +3493,10 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		return hugetlb_fault(mm, vma, address, flags);
 
 	pgd = pgd_offset(mm, address);
-	pud = pud_alloc(mm, pgd, address);
+	pud = pud_alloc(mm, pgd, address, GFP_KERNEL);
 	if (!pud)
 		return VM_FAULT_OOM;
-	pmd = pmd_alloc(mm, pud, address);
+	pmd = pmd_alloc(mm, pud, address, GFP_KERNEL);
 	if (!pmd)
 		return VM_FAULT_OOM;
 	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
@@ -3542,9 +3542,10 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
  * Allocate page upper directory.
  * We've already handled the fast-path in-line.
  */
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
+		unsigned long address, gfp_t gfp_mask)
 {
-	pud_t *new = pud_alloc_one(mm, address);
+	pud_t *new = pud_alloc_one(mm, address, gfp_mask);
 	if (!new)
 		return -ENOMEM;
 
@@ -3565,9 +3566,10 @@ int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
  * Allocate page middle directory.
  * We've already handled the fast-path in-line.
  */
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
+		unsigned long address, gfp_t gfp_mask)
 {
-	pmd_t *new = pmd_alloc_one(mm, address);
+	pmd_t *new = pmd_alloc_one(mm, address, gfp_mask);
 	if (!new)
 		return -ENOMEM;
 
diff --git a/mm/mremap.c b/mm/mremap.c
index db8d983..309014a 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -55,11 +55,11 @@ static pmd_t *alloc_new_pmd(struct mm_struct *mm, struct vm_area_struct *vma,
 	pmd_t *pmd;
 
 	pgd = pgd_offset(mm, addr);
-	pud = pud_alloc(mm, pgd, addr);
+	pud = pud_alloc(mm, pgd, addr, GFP_KERNEL);
 	if (!pud)
 		return NULL;
 
-	pmd = pmd_alloc(mm, pud, addr);
+	pmd = pmd_alloc(mm, pud, addr, GFP_KERNEL);
 	if (!pmd)
 		return NULL;
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 94dff88..69e9aea 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -88,7 +88,8 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
 }
 
 static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+		unsigned long end, pgprot_t prot,
+		struct page **pages, int *nr, gfp_t gfp_mask)
 {
 	pte_t *pte;
 
@@ -97,7 +98,7 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 	 * callers keep track of where we're up to.
 	 */
 
-	pte = pte_alloc_kernel(pmd, addr);
+	pte = pte_alloc_kernel(pmd, addr, gfp_mask);
 	if (!pte)
 		return -ENOMEM;
 	do {
@@ -114,34 +115,38 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 }
 
 static int vmap_pmd_range(pud_t *pud, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+		unsigned long end, pgprot_t prot,
+		struct page **pages, int *nr, gfp_t gfp_mask)
 {
 	pmd_t *pmd;
 	unsigned long next;
 
-	pmd = pmd_alloc(&init_mm, pud, addr);
+	pmd = pmd_alloc(&init_mm, pud, addr, gfp_mask);
 	if (!pmd)
 		return -ENOMEM;
 	do {
 		next = pmd_addr_end(addr, end);
-		if (vmap_pte_range(pmd, addr, next, prot, pages, nr))
+		if (vmap_pte_range(pmd, addr, next, prot,
+				pages, nr, gfp_mask))
 			return -ENOMEM;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
 
 static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+		unsigned long end, pgprot_t prot,
+		struct page **pages, int *nr, gfp_t gfp_mask)
 {
 	pud_t *pud;
 	unsigned long next;
 
-	pud = pud_alloc(&init_mm, pgd, addr);
+	pud = pud_alloc(&init_mm, pgd, addr, gfp_mask);
 	if (!pud)
 		return -ENOMEM;
 	do {
 		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages, nr))
+		if (vmap_pmd_range(pud, addr, next, prot,
+					pages, nr, gfp_mask))
 			return -ENOMEM;
 	} while (pud++, addr = next, addr != end);
 	return 0;
@@ -154,7 +159,7 @@ static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
  * Ie. pte at addr+N*PAGE_SIZE shall point to pfn corresponding to pages[N]
  */
 static int vmap_page_range_noflush(unsigned long start, unsigned long end,
-				   pgprot_t prot, struct page **pages)
+			   pgprot_t prot, struct page **pages, gfp_t gfp_mask)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -166,7 +171,8 @@ static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = vmap_pud_range(pgd, addr, next, prot, pages, &nr);
+		err = vmap_pud_range(pgd, addr, next, prot,
+					pages, &nr, gfp_mask);
 		if (err)
 			return err;
 	} while (pgd++, addr = next, addr != end);
@@ -175,11 +181,11 @@ static int vmap_page_range_noflush(unsigned long start, unsigned long end,
 }
 
 static int vmap_page_range(unsigned long start, unsigned long end,
-			   pgprot_t prot, struct page **pages)
+		pgprot_t prot, struct page **pages, gfp_t gfp_mask)
 {
 	int ret;
 
-	ret = vmap_page_range_noflush(start, end, prot, pages);
+	ret = vmap_page_range_noflush(start, end, prot, pages, gfp_mask);
 	flush_cache_vmap(start, end);
 	return ret;
 }
@@ -1109,7 +1115,7 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 		addr = va->va_start;
 		mem = (void *)addr;
 	}
-	if (vmap_page_range(addr, addr + size, prot, pages) < 0) {
+	if (vmap_page_range(addr, addr + size, prot, pages, GFP_KERNEL) < 0) {
 		vm_unmap_ram(mem, count);
 		return NULL;
 	}
@@ -1218,7 +1224,8 @@ void __init vmalloc_init(void)
 int map_kernel_range_noflush(unsigned long addr, unsigned long size,
 			     pgprot_t prot, struct page **pages)
 {
-	return vmap_page_range_noflush(addr, addr + size, prot, pages);
+	return vmap_page_range_noflush(addr, addr + size,
+			prot, pages, GFP_KERNEL);
 }
 
 /**
@@ -1258,13 +1265,29 @@ void unmap_kernel_range(unsigned long addr, unsigned long size)
 	flush_tlb_kernel_range(addr, end);
 }
 
+int map_vm_area_gfp(struct vm_struct *area, pgprot_t prot,
+			struct page ***pages, gfp_t gfp_mask)
+{
+	unsigned long addr = (unsigned long)area->addr;
+	unsigned long end = addr + area->size - PAGE_SIZE;
+	int err;
+
+	err = vmap_page_range(addr, end, prot, *pages, gfp_mask);
+	if (err > 0) {
+		*pages += err;
+		err = 0;
+	}
+
+	return err;
+}
+
 int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
 {
 	unsigned long addr = (unsigned long)area->addr;
 	unsigned long end = addr + area->size - PAGE_SIZE;
 	int err;
 
-	err = vmap_page_range(addr, end, prot, *pages);
+	err = vmap_page_range(addr, end, prot, *pages, GFP_KERNEL);
 	if (err > 0) {
 		*pages += err;
 		err = 0;
@@ -1613,7 +1636,7 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 		area->pages[i] = page;
 	}
 
-	if (map_vm_area(area, prot, &pages))
+	if (map_vm_area_gfp(area, prot, &pages, gfp_mask))
 		goto fail;
 	return area->addr;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
