Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5482E8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 14:38:59 -0400 (EDT)
Received: by qyk30 with SMTP id 30so5153997qyk.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:38:24 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 14 Mar 2011 18:38:23 +0000
Message-ID: <AANLkTi=WjOEUAktf6KFGjxf_+HnVQSb+bPXwru7Vi6UZ@mail.gmail.com>
Subject: [RFC][PATCH v2 23/23] __vmalloc: add gfp flags variant of pte, pmd,
 and pud allocation
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m32r-ja@ml.linux-m32r.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org

__vmalloc: propagating GFP allocation flag.

- Added __map_vm_area, __vmap_page_range, __vmap_page_range_noflush
to accept the gfp_t allocation flag
- Added pud_alloc_with_mask(), similar to pud_alloc(), but also
accepts allocation flag
- Added pmd_alloc_with_mask
- Added pte_alloc_kernel_with_mask
- Modified __pte_alloc_kernel to accept allocation flag
- Every architecture has to add a function
__pte_alloc_one_kernel(struct mm_struct*, unsigned long, gfp_t)
- Modified __pmd_alloc to accept the allocation flag
- Every architecture has to add a function __pmd_alloc_one(struct
mm_struct *, unsigned long, gfp_t)
- Changed __pud_alloc to accepts gfp allocation flag
- Every architecture that uses pud has to add a function
__pud_alloc_one(struct mm_struct *, unsigned long, gfp_t)
- fixes the Bug 30702 (__vmalloc(GFP_NOFS) can callback file system
  evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
include/linux/mm.h |   40 +++++++++++++++++++++++++++---------
mm/memory.c        |   14 +++++++-----
mm/vmalloc.c       |   57 ++++++++++++++++++++++++++++++++++-----------------
3 files changed, 76 insertions(+), 35 deletions(-)
---
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f6385fc..5ff89df 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1156,44 +1156,60 @@ static inline pte_t *get_locked_pte(struct
mm_struct *mm, unsigned long addr,

 #ifdef __PAGETABLE_PUD_FOLDED
 static inline int __pud_alloc(struct mm_struct *mm, pgd_t *pgd,
-						unsigned long address)
+						unsigned long address, gfp_t gfp_mask)
 {
 	return 0;
 }
 #else
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address);
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address,
+		gfp_t gfp_mask);
 #endif

 #ifdef __PAGETABLE_PMD_FOLDED
 static inline int __pmd_alloc(struct mm_struct *mm, pud_t *pud,
-						unsigned long address)
+						unsigned long address, gfp_t gfp_mask)
 {
 	return 0;
 }
 #else
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address,
+		gfp_t gfp_mask);
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
-static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd,
unsigned long address)
+static inline pud_t *pud_alloc_with_mask(struct mm_struct *mm, pgd_t *pgd,
+		unsigned long address, gfp_t gfp_mask)
 {
-	return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address))?
+	return (unlikely(pgd_none(*pgd)) && __pud_alloc(mm, pgd, address, gfp_mask))?
 		NULL: pud_offset(pgd, address);
 }

-static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud,
unsigned long address)
+static inline pud_t *pud_alloc(struct mm_struct *mm, pgd_t *pgd,
+		unsigned long address)
 {
-	return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
+	return pud_alloc_with_mask(mm, pgd, address, GFP_KERNEL);
+}
+
+static inline pmd_t *pmd_alloc_with_mask(struct mm_struct *mm, pud_t *pud,
+		unsigned long address, gfp_t gfp_mask)
+{
+	return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address, gfp_mask))?
 		NULL: pmd_offset(pud, address);
 }
+
+static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud,
+		unsigned long address)
+{
+	return pmd_alloc_with_mask(mm, pud, address, GFP_KERNEL);
+}
 #endif /* CONFIG_MMU && !__ARCH_HAS_4LEVEL_HACK */

 #if USE_SPLIT_PTLOCKS
@@ -1254,8 +1270,12 @@ static inline void pgtable_page_dtor(struct page *page)
 							pmd, address))?	\
 		NULL: pte_offset_map_lock(mm, pmd, address, ptlp))

+#define pte_alloc_kernel_with_mask(pmd, address, mask)			\
+	((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address, mask))? \
+		NULL: pte_offset_kernel(pmd, address))
+
 #define pte_alloc_kernel(pmd, address)			\
-	((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
+	((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address,
GFP_KERNEL))? \
 		NULL: pte_offset_kernel(pmd, address))

 extern void free_area_init(unsigned long * zones_size);
diff --git a/mm/memory.c b/mm/memory.c
index 5823698..dc4964e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -433,9 +433,9 @@ int __pte_alloc(struct mm_struct *mm, struct
vm_area_struct *vma,
 	return 0;
 }

-int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
+int __pte_alloc_kernel(pmd_t *pmd, unsigned long address, gfp_t gfp_mask)
 {
-	pte_t *new = pte_alloc_one_kernel(&init_mm, address);
+	pte_t *new = __pte_alloc_one_kernel(&init_mm, address, gfp_mask);
 	if (!new)
 		return -ENOMEM;

@@ -3343,9 +3343,10 @@ int handle_mm_fault(struct mm_struct *mm,
struct vm_area_struct *vma,
  * Allocate page upper directory.
  * We've already handled the fast-path in-line.
  */
-int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
+int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address,
+		gfp_t gfp_mask)
 {
-	pud_t *new = pud_alloc_one(mm, address);
+	pud_t *new = __pud_alloc_one(mm, address, gfp_mask);
 	if (!new)
 		return -ENOMEM;

@@ -3366,9 +3367,10 @@ int __pud_alloc(struct mm_struct *mm, pgd_t
*pgd, unsigned long address)
  * Allocate page middle directory.
  * We've already handled the fast-path in-line.
  */
-int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
+int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address,
+		gfp_t gfp_mask)
 {
-	pmd_t *new = pmd_alloc_one(mm, address);
+	pmd_t *new = __pmd_alloc_one(mm, address, gfp_mask);
 	if (!new)
 		return -ENOMEM;

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f9b1667..3df33fb 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -87,8 +87,8 @@ static void vunmap_page_range(unsigned long addr,
unsigned long end)
 	} while (pgd++, addr = next, addr != end);
 }

-static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+static int vmap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
+		pgprot_t prot, struct page **pages, int *nr, gfp_t gfp_mask)
 {
 	pte_t *pte;

@@ -97,7 +97,7 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 	 * callers keep track of where we're up to.
 	 */

-	pte = pte_alloc_kernel(pmd, addr);
+	pte = pte_alloc_kernel_with_mask(pmd, addr, gfp_mask);
 	if (!pte)
 		return -ENOMEM;
 	do {
@@ -114,34 +114,34 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 }

 static int vmap_pmd_range(pud_t *pud, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+		unsigned long end, pgprot_t prot, struct page **pages, int *nr,
gfp_t gfp_mask)
 {
 	pmd_t *pmd;
 	unsigned long next;

-	pmd = pmd_alloc(&init_mm, pud, addr);
+	pmd = pmd_alloc_with_mask(&init_mm, pud, addr, gfp_mask);
 	if (!pmd)
 		return -ENOMEM;
 	do {
 		next = pmd_addr_end(addr, end);
-		if (vmap_pte_range(pmd, addr, next, prot, pages, nr))
+		if (vmap_pte_range(pmd, addr, next, prot, pages, nr, gfp_mask))
 			return -ENOMEM;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }

-static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
-		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
+static int vmap_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
+		pgprot_t prot, struct page **pages, int *nr, gfp_t gfp_mask)
 {
 	pud_t *pud;
 	unsigned long next;

-	pud = pud_alloc(&init_mm, pgd, addr);
+	pud = pud_alloc_with_mask(&init_mm, pgd, addr, gfp_mask);
 	if (!pud)
 		return -ENOMEM;
 	do {
 		next = pud_addr_end(addr, end);
-		if (vmap_pmd_range(pud, addr, next, prot, pages, nr))
+		if (vmap_pmd_range(pud, addr, next, prot, pages, nr, gfp_mask))
 			return -ENOMEM;
 	} while (pud++, addr = next, addr != end);
 	return 0;
@@ -153,8 +153,8 @@ static int vmap_pud_range(pgd_t *pgd, unsigned long addr,
  *
  * Ie. pte at addr+N*PAGE_SIZE shall point to pfn corresponding to pages[N]
  */
-static int vmap_page_range_noflush(unsigned long start, unsigned long end,
-				   pgprot_t prot, struct page **pages)
+static int __vmap_page_range_noflush(unsigned long start, unsigned long end,
+				   pgprot_t prot, struct page **pages, gfp_t gfp_mask)
 {
 	pgd_t *pgd;
 	unsigned long next;
@@ -166,7 +166,7 @@ static int vmap_page_range_noflush(unsigned long
start, unsigned long end,
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = vmap_pud_range(pgd, addr, next, prot, pages, &nr);
+		err = vmap_pud_range(pgd, addr, next, prot, pages, &nr, gfp_mask);
 		if (err)
 			return err;
 	} while (pgd++, addr = next, addr != end);
@@ -174,16 +174,29 @@ static int vmap_page_range_noflush(unsigned long
start, unsigned long end,
 	return nr;
 }

-static int vmap_page_range(unsigned long start, unsigned long end,
-			   pgprot_t prot, struct page **pages)
+
+static int vmap_page_range_noflush(unsigned long start, unsigned long end,
+				   pgprot_t prot, struct page **pages)
+{
+	return __vmap_page_range_noflush(start, end, prot, pages, GFP_KERNEL);
+}
+
+static int __vmap_page_range(unsigned long start, unsigned long end,
+			   pgprot_t prot, struct page **pages, gfp_t gfp_mask)
 {
 	int ret;

-	ret = vmap_page_range_noflush(start, end, prot, pages);
+	ret = __vmap_page_range_noflush(start, end, prot, pages, gfp_mask);
 	flush_cache_vmap(start, end);
 	return ret;
 }

+static int vmap_page_range(unsigned long start, unsigned long end,
+			   pgprot_t prot, struct page **pages)
+{
+	return __vmap_page_range(start, end, prot, pages, GFP_KERNEL);
+}
+
 int is_vmalloc_or_module_addr(const void *x)
 {
 	/*
@@ -1194,13 +1207,14 @@ void unmap_kernel_range(unsigned long addr,
unsigned long size)
 	flush_tlb_kernel_range(addr, end);
 }

-int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
+int __map_vm_area(struct vm_struct *area, pgprot_t prot,
+		struct page ***pages, gfp_t gfp_mask)
 {
 	unsigned long addr = (unsigned long)area->addr;
 	unsigned long end = addr + area->size - PAGE_SIZE;
 	int err;

-	err = vmap_page_range(addr, end, prot, *pages);
+	err = __vmap_page_range(addr, end, prot, *pages, gfp_mask);
 	if (err > 0) {
 		*pages += err;
 		err = 0;
@@ -1208,6 +1222,11 @@ int map_vm_area(struct vm_struct *area,
pgprot_t prot, struct page ***pages)

 	return err;
 }
+
+int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page ***pages)
+{
+	return __map_vm_area(area, prot, pages, GFP_KERNEL);
+}
 EXPORT_SYMBOL_GPL(map_vm_area);

 /*** Old vmalloc interfaces ***/
@@ -1522,7 +1541,7 @@ static void *__vmalloc_area_node(struct
vm_struct *area, gfp_t gfp_mask,
 		area->pages[i] = page;
 	}

-	if (map_vm_area(area, prot, &pages))
+	if (__map_vm_area(area, prot, &pages, gfp_mask))
 		goto fail;
 	return area->addr;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
