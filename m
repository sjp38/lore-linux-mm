Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8C882F6A
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:16:21 -0500 (EST)
Received: by wmeg8 with SMTP id g8so18796946wme.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:16:21 -0800 (PST)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id t13si13373814wmd.42.2015.11.05.08.16.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 08:16:20 -0800 (PST)
Received: by wmeg8 with SMTP id g8so17936670wme.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:16:20 -0800 (PST)
From: mhocko@kernel.org
Subject: [PATCH 2/3] tree wide: get rid of __GFP_REPEAT for small order requests
Date: Thu,  5 Nov 2015 17:15:59 +0100
Message-Id: <1446740160-29094-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
References: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

__GFP_REPEAT has a rather weak semantic but since it has been introduced
around 2.6.12 it has been ignored for low order allocations. Yet we have
users which require this flag even though they are doing order-0 or
small order allocation in the end:

* arc: pte_alloc_one_kernel uses __get_order_pte but this is obviously
  always zero because BITS_FOR_PTE is not larger than 9 yet the page
  size is always larger than 4K
* arm: hides __GFP_REPEAT behind PGALLOC_GFP but the actual allocations
  are always order-0. __pgd_alloc is doing order-2 but this is still
  not costly allocation
* arm64: does basically the same except it can have PGD_SIZE != PAGE_SIZE
  so let's keep __GFP_REPEAT explicit there
* mips, nios2, parisc, score, x86: hide behind PTE_ORDER and PMD_ORDER but
  both are not larger than 1 and this seems like a copy&paste between
  arches.

This is really confusing because __GFP_REPEAT is explicitly documented
to allow allocation failures which is a weaker semantic than the current
order-0 has (basically nofail).

Let's simply reap out __GFP_REPEAT from those places. This would allow
to identify place which really need allocator to retry harder and
formulate a more specific semantic for what the flag is supposed to do
actually.

Cc: linux-arch@vger.kernel.org
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/arc/include/asm/pgalloc.h    | 4 ++--
 arch/arm/include/asm/pgalloc.h    | 2 +-
 arch/arm/mm/pgd.c                 | 2 +-
 arch/arm64/include/asm/pgalloc.h  | 2 +-
 arch/arm64/mm/pgd.c               | 2 +-
 arch/mips/include/asm/pgalloc.h   | 6 +++---
 arch/nios2/include/asm/pgalloc.h  | 5 ++---
 arch/parisc/include/asm/pgalloc.h | 3 +--
 arch/score/include/asm/pgalloc.h  | 5 ++---
 arch/x86/kernel/espfix_64.c       | 2 +-
 arch/x86/mm/pgtable.c             | 2 +-
 11 files changed, 16 insertions(+), 19 deletions(-)

diff --git a/arch/arc/include/asm/pgalloc.h b/arch/arc/include/asm/pgalloc.h
index 86ed671286df..3749234b7419 100644
--- a/arch/arc/include/asm/pgalloc.h
+++ b/arch/arc/include/asm/pgalloc.h
@@ -95,7 +95,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 {
 	pte_t *pte;
 
-	pte = (pte_t *) __get_free_pages(GFP_KERNEL | __GFP_REPEAT | __GFP_ZERO,
+	pte = (pte_t *) __get_free_pages(GFP_KERNEL | __GFP_ZERO,
 					 __get_order_pte());
 
 	return pte;
@@ -107,7 +107,7 @@ pte_alloc_one(struct mm_struct *mm, unsigned long address)
 	pgtable_t pte_pg;
 	struct page *page;
 
-	pte_pg = (pgtable_t)__get_free_pages(GFP_KERNEL | __GFP_REPEAT, __get_order_pte());
+	pte_pg = (pgtable_t)__get_free_pages(GFP_KERNEL, __get_order_pte());
 	if (!pte_pg)
 		return 0;
 	memzero((void *)pte_pg, PTRS_PER_PTE * sizeof(pte_t));
diff --git a/arch/arm/include/asm/pgalloc.h b/arch/arm/include/asm/pgalloc.h
index 20febb368844..b2902a5cd780 100644
--- a/arch/arm/include/asm/pgalloc.h
+++ b/arch/arm/include/asm/pgalloc.h
@@ -57,7 +57,7 @@ static inline void pud_populate(struct mm_struct *mm, pud_t *pud, pmd_t *pmd)
 extern pgd_t *pgd_alloc(struct mm_struct *mm);
 extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
 
-#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
+#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
 
 static inline void clean_pte_table(pte_t *pte)
 {
diff --git a/arch/arm/mm/pgd.c b/arch/arm/mm/pgd.c
index e683db1b90a3..107a2792d0a2 100644
--- a/arch/arm/mm/pgd.c
+++ b/arch/arm/mm/pgd.c
@@ -23,7 +23,7 @@
 #define __pgd_alloc()	kmalloc(PTRS_PER_PGD * sizeof(pgd_t), GFP_KERNEL)
 #define __pgd_free(pgd)	kfree(pgd)
 #else
-#define __pgd_alloc()	(pgd_t *)__get_free_pages(GFP_KERNEL | __GFP_REPEAT, 2)
+#define __pgd_alloc()	(pgd_t *)__get_free_pages(GFP_KERNEL, 2)
 #define __pgd_free(pgd)	free_pages((unsigned long)pgd, 2)
 #endif
 
diff --git a/arch/arm64/include/asm/pgalloc.h b/arch/arm64/include/asm/pgalloc.h
index c15053902942..ea515f74ac02 100644
--- a/arch/arm64/include/asm/pgalloc.h
+++ b/arch/arm64/include/asm/pgalloc.h
@@ -26,7 +26,7 @@
 
 #define check_pgt_cache()		do { } while (0)
 
-#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
+#define PGALLOC_GFP	(GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
 #define PGD_SIZE	(PTRS_PER_PGD * sizeof(pgd_t))
 
 #if CONFIG_PGTABLE_LEVELS > 2
diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
index cb3ba1b812e7..77902d234498 100644
--- a/arch/arm64/mm/pgd.c
+++ b/arch/arm64/mm/pgd.c
@@ -35,7 +35,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
 	if (PGD_SIZE == PAGE_SIZE)
 		return (pgd_t *)__get_free_page(PGALLOC_GFP);
 	else
-		return kmem_cache_alloc(pgd_cache, PGALLOC_GFP);
+		return kmem_cache_alloc(pgd_cache, PGALLOC_GFP | __GFP_REPEAT);
 }
 
 void pgd_free(struct mm_struct *mm, pgd_t *pgd)
diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
index b336037e8768..93c079a1cfc8 100644
--- a/arch/mips/include/asm/pgalloc.h
+++ b/arch/mips/include/asm/pgalloc.h
@@ -69,7 +69,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 {
 	pte_t *pte;
 
-	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO, PTE_ORDER);
+	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_ZERO, PTE_ORDER);
 
 	return pte;
 }
@@ -79,7 +79,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm,
 {
 	struct page *pte;
 
-	pte = alloc_pages(GFP_KERNEL | __GFP_REPEAT, PTE_ORDER);
+	pte = alloc_pages(GFP_KERNEL, PTE_ORDER);
 	if (!pte)
 		return NULL;
 	clear_highpage(pte);
@@ -113,7 +113,7 @@ static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 {
 	pmd_t *pmd;
 
-	pmd = (pmd_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT, PMD_ORDER);
+	pmd = (pmd_t *) __get_free_pages(GFP_KERNEL, PMD_ORDER);
 	if (pmd)
 		pmd_init((unsigned long)pmd, (unsigned long)invalid_pte_table);
 	return pmd;
diff --git a/arch/nios2/include/asm/pgalloc.h b/arch/nios2/include/asm/pgalloc.h
index 6e2985e0a7b9..bb47d08c8ef7 100644
--- a/arch/nios2/include/asm/pgalloc.h
+++ b/arch/nios2/include/asm/pgalloc.h
@@ -42,8 +42,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 {
 	pte_t *pte;
 
-	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO,
-					PTE_ORDER);
+	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_ZERO, PTE_ORDER);
 
 	return pte;
 }
@@ -53,7 +52,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm,
 {
 	struct page *pte;
 
-	pte = alloc_pages(GFP_KERNEL | __GFP_REPEAT, PTE_ORDER);
+	pte = alloc_pages(GFP_KERNEL, PTE_ORDER);
 	if (pte) {
 		if (!pgtable_page_ctor(pte)) {
 			__free_page(pte);
diff --git a/arch/parisc/include/asm/pgalloc.h b/arch/parisc/include/asm/pgalloc.h
index b7e4027aac4b..bd388cfd8141 100644
--- a/arch/parisc/include/asm/pgalloc.h
+++ b/arch/parisc/include/asm/pgalloc.h
@@ -63,8 +63,7 @@ static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmd)
 
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
 {
-	pmd_t *pmd = (pmd_t *)__get_free_pages(GFP_KERNEL|__GFP_REPEAT,
-					       PMD_ORDER);
+	pmd_t *pmd = (pmd_t *)__get_free_pages(GFP_KERNEL, PMD_ORDER);
 	if (pmd)
 		memset(pmd, 0, PAGE_SIZE<<PMD_ORDER);
 	return pmd;
diff --git a/arch/score/include/asm/pgalloc.h b/arch/score/include/asm/pgalloc.h
index 2e067657db98..49b012d78c1a 100644
--- a/arch/score/include/asm/pgalloc.h
+++ b/arch/score/include/asm/pgalloc.h
@@ -42,8 +42,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 {
 	pte_t *pte;
 
-	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO,
-					PTE_ORDER);
+	pte = (pte_t *) __get_free_pages(GFP_KERNEL|__GFP_ZERO, PTE_ORDER);
 
 	return pte;
 }
@@ -53,7 +52,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm,
 {
 	struct page *pte;
 
-	pte = alloc_pages(GFP_KERNEL | __GFP_REPEAT, PTE_ORDER);
+	pte = alloc_pages(GFP_KERNEL, PTE_ORDER);
 	if (!pte)
 		return NULL;
 	clear_highpage(pte);
diff --git a/arch/x86/kernel/espfix_64.c b/arch/x86/kernel/espfix_64.c
index 4d38416e2a7f..04f89caef9c4 100644
--- a/arch/x86/kernel/espfix_64.c
+++ b/arch/x86/kernel/espfix_64.c
@@ -57,7 +57,7 @@
 # error "Need more than one PGD for the ESPFIX hack"
 #endif
 
-#define PGALLOC_GFP (GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO)
+#define PGALLOC_GFP (GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO)
 
 /* This contains the *bottom* address of the espfix stack */
 DEFINE_PER_CPU_READ_MOSTLY(unsigned long, espfix_stack);
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index f52caf9c519b..bdbb3213f670 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -6,7 +6,7 @@
 #include <asm/fixmap.h>
 #include <asm/mtrr.h>
 
-#define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
+#define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_ZERO
 
 #ifdef CONFIG_HIGHPTE
 #define PGALLOC_USER_GFP __GFP_HIGHMEM
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
