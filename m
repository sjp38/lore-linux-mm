Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 613FB6B003D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 09:00:27 -0400 (EDT)
From: Aaro Koskinen <Aaro.Koskinen@nokia.com>
Subject: [RFC PATCH 1/2] mm: tlb: Add range to tlb_start_vma() and tlb_end_vma()
Date: Mon,  9 Mar 2009 14:59:56 +0200
Message-Id: <1236603597-1646-1-git-send-email-Aaro.Koskinen@nokia.com>
In-Reply-To: <49B511E9.8030405@nokia.com>
References: <49B511E9.8030405@nokia.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Pass the range to be teared down with tlb_start_vma() and
tlb_end_vma(). This allows architectures doing per-VMA handling to flush
only the needed range instead of the full VMA region.

This patch changes the interface only, no changes in functionality.

Signed-off-by: Aaro Koskinen <Aaro.Koskinen@nokia.com>
---
 arch/alpha/include/asm/tlb.h    |    4 ++--
 arch/arm/include/asm/tlb.h      |    6 ++++--
 arch/avr32/include/asm/tlb.h    |    4 ++--
 arch/blackfin/include/asm/tlb.h |    4 ++--
 arch/cris/include/asm/tlb.h     |    4 ++--
 arch/ia64/include/asm/tlb.h     |    8 ++++----
 arch/m68k/include/asm/tlb.h     |    4 ++--
 arch/mips/include/asm/tlb.h     |    4 ++--
 arch/parisc/include/asm/tlb.h   |    4 ++--
 arch/powerpc/include/asm/tlb.h  |    4 ++--
 arch/s390/include/asm/tlb.h     |    4 ++--
 arch/sh/include/asm/tlb.h       |    4 ++--
 arch/sparc/include/asm/tlb_32.h |    4 ++--
 arch/sparc/include/asm/tlb_64.h |    4 ++--
 arch/um/include/asm/tlb.h       |    4 ++--
 arch/x86/include/asm/tlb.h      |    4 ++--
 arch/xtensa/include/asm/tlb.h   |    8 ++++----
 include/asm-frv/tlb.h           |    4 ++--
 include/asm-m32r/tlb.h          |    4 ++--
 include/asm-mn10300/tlb.h       |    4 ++--
 mm/memory.c                     |   10 +++++++---
 21 files changed, 53 insertions(+), 47 deletions(-)

diff --git a/arch/alpha/include/asm/tlb.h b/arch/alpha/include/asm/tlb.h
index c136365..26991bc 100644
--- a/arch/alpha/include/asm/tlb.h
+++ b/arch/alpha/include/asm/tlb.h
@@ -1,8 +1,8 @@
 #ifndef _ALPHA_TLB_H
 #define _ALPHA_TLB_H
 
-#define tlb_start_vma(tlb, vma)			do { } while (0)
-#define tlb_end_vma(tlb, vma)			do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end)	do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, pte, addr)	do { } while (0)
 
 #define tlb_flush(tlb)				flush_tlb_mm((tlb)->mm)
diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 857f1df..d10c9c3 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -71,14 +71,16 @@ tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
  * the vmas are adjusted to only cover the region to be torn down.
  */
 static inline void
-tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
+tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma,
+	      unsigned long range_start, unsigned long range_end)
 {
 	if (!tlb->fullmm)
 		flush_cache_range(vma, vma->vm_start, vma->vm_end);
 }
 
 static inline void
-tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
+tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma,
+	    unsigned long range_start, unsigned long range_end)
 {
 	if (!tlb->fullmm)
 		flush_tlb_range(vma, vma->vm_start, vma->vm_end);
diff --git a/arch/avr32/include/asm/tlb.h b/arch/avr32/include/asm/tlb.h
index 5c55f9c..41381e9 100644
--- a/arch/avr32/include/asm/tlb.h
+++ b/arch/avr32/include/asm/tlb.h
@@ -8,10 +8,10 @@
 #ifndef __ASM_AVR32_TLB_H
 #define __ASM_AVR32_TLB_H
 
-#define tlb_start_vma(tlb, vma) \
+#define tlb_start_vma(tlb, vma, range_start, range_end) \
 	flush_cache_range(vma, vma->vm_start, vma->vm_end)
 
-#define tlb_end_vma(tlb, vma) \
+#define tlb_end_vma(tlb, vma, range_start, range_end) \
 	flush_tlb_range(vma, vma->vm_start, vma->vm_end)
 
 #define __tlb_remove_tlb_entry(tlb, pte, address) do { } while(0)
diff --git a/arch/blackfin/include/asm/tlb.h b/arch/blackfin/include/asm/tlb.h
index 89a12ee..cf7eb67 100644
--- a/arch/blackfin/include/asm/tlb.h
+++ b/arch/blackfin/include/asm/tlb.h
@@ -1,8 +1,8 @@
 #ifndef _BLACKFIN_TLB_H
 #define _BLACKFIN_TLB_H
 
-#define tlb_start_vma(tlb, vma)	do { } while (0)
-#define tlb_end_vma(tlb, vma)	do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end)	do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
 /*
diff --git a/arch/cris/include/asm/tlb.h b/arch/cris/include/asm/tlb.h
index 77384ea..87e9879 100644
--- a/arch/cris/include/asm/tlb.h
+++ b/arch/cris/include/asm/tlb.h
@@ -9,8 +9,8 @@
  * cris doesn't need any special per-pte or
  * per-vma handling..
  */
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end) do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index 20d8a39..b1c7bbf 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -25,14 +25,14 @@
  *	tlb <- tlb_gather_mmu(mm, full_mm_flush);	// start unmap for address space MM
  *	{
  *	  for each vma that needs a shootdown do {
- *	    tlb_start_vma(tlb, vma);
+ *	    tlb_start_vma(tlb, vma, range_start, range_end);
  *	      for each page-table-entry PTE that needs to be removed do {
  *		tlb_remove_tlb_entry(tlb, pte, address);
  *		if (pte refers to a normal page) {
  *		  tlb_remove_page(tlb, page);
  *		}
  *	      }
- *	    tlb_end_vma(tlb, vma);
+ *	    tlb_end_vma(tlb, vma, range_start, range_end);
  *	  }
  *	}
  *	tlb_finish_mmu(tlb, start, end);	// finish unmap for address space MM
@@ -227,8 +227,8 @@ __tlb_remove_tlb_entry (struct mmu_gather *tlb, pte_t *ptep, unsigned long addre
 
 #define tlb_migrate_finish(mm)	platform_tlb_migrate_finish(mm)
 
-#define tlb_start_vma(tlb, vma)			do { } while (0)
-#define tlb_end_vma(tlb, vma)			do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end)	do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end)	do { } while (0)
 
 #define tlb_remove_tlb_entry(tlb, ptep, addr)		\
 do {							\
diff --git a/arch/m68k/include/asm/tlb.h b/arch/m68k/include/asm/tlb.h
index 1785cff..0363248 100644
--- a/arch/m68k/include/asm/tlb.h
+++ b/arch/m68k/include/asm/tlb.h
@@ -5,8 +5,8 @@
  * m68k doesn't need any special per-pte or
  * per-vma handling..
  */
-#define tlb_start_vma(tlb, vma)	do { } while (0)
-#define tlb_end_vma(tlb, vma)	do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end)	do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
 /*
diff --git a/arch/mips/include/asm/tlb.h b/arch/mips/include/asm/tlb.h
index 80d9dfc..8491179 100644
--- a/arch/mips/include/asm/tlb.h
+++ b/arch/mips/include/asm/tlb.h
@@ -5,12 +5,12 @@
  * MIPS doesn't need any special per-pte or per-vma handling, except
  * we need to flush cache for area to be unmapped.
  */
-#define tlb_start_vma(tlb, vma) 				\
+#define tlb_start_vma(tlb, vma, range_start, range_end) 	\
 	do {							\
 		if (!tlb->fullmm)				\
 			flush_cache_range(vma, vma->vm_start, vma->vm_end); \
 	}  while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
 /*
diff --git a/arch/parisc/include/asm/tlb.h b/arch/parisc/include/asm/tlb.h
index 383b1db..37c40e5 100644
--- a/arch/parisc/include/asm/tlb.h
+++ b/arch/parisc/include/asm/tlb.h
@@ -6,12 +6,12 @@ do {	if ((tlb)->fullmm)		\
 		flush_tlb_mm((tlb)->mm);\
 } while (0)
 
-#define tlb_start_vma(tlb, vma) \
+#define tlb_start_vma(tlb, vma, range_start, range_end) \
 do {	if (!(tlb)->fullmm)	\
 		flush_cache_range(vma, vma->vm_start, vma->vm_end); \
 } while (0)
 
-#define tlb_end_vma(tlb, vma)	\
+#define tlb_end_vma(tlb, vma, range_start, range_end)	\
 do {	if (!(tlb)->fullmm)	\
 		flush_tlb_range(vma, vma->vm_start, vma->vm_end); \
 } while (0)
diff --git a/arch/powerpc/include/asm/tlb.h b/arch/powerpc/include/asm/tlb.h
index e20ff75..d7ab142 100644
--- a/arch/powerpc/include/asm/tlb.h
+++ b/arch/powerpc/include/asm/tlb.h
@@ -27,8 +27,8 @@
 
 struct mmu_gather;
 
-#define tlb_start_vma(tlb, vma)	do { } while (0)
-#define tlb_end_vma(tlb, vma)	do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end)	do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end)	do { } while (0)
 
 #if !defined(CONFIG_PPC_STD_MMU)
 
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 3d8a96d..718d16f 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -148,8 +148,8 @@ static inline void pud_free_tlb(struct mmu_gather *tlb, pud_t *pud)
 #endif
 }
 
-#define tlb_start_vma(tlb, vma)			do { } while (0)
-#define tlb_end_vma(tlb, vma)			do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end)	do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end)	do { } while (0)
 #define tlb_remove_tlb_entry(tlb, ptep, addr)	do { } while (0)
 #define tlb_migrate_finish(mm)			do { } while (0)
 
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 88ff1ae..84ad1f9 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -7,10 +7,10 @@
 
 #ifndef __ASSEMBLY__
 
-#define tlb_start_vma(tlb, vma) \
+#define tlb_start_vma(tlb, vma, range_start, range_end) \
 	flush_cache_range(vma, vma->vm_start, vma->vm_end)
 
-#define tlb_end_vma(tlb, vma)	\
+#define tlb_end_vma(tlb, vma, range_start, range_end)	\
 	flush_tlb_range(vma, vma->vm_start, vma->vm_end)
 
 #define __tlb_remove_tlb_entry(tlb, pte, address)	do { } while (0)
diff --git a/arch/sparc/include/asm/tlb_32.h b/arch/sparc/include/asm/tlb_32.h
index 6d02d1c..8161627 100644
--- a/arch/sparc/include/asm/tlb_32.h
+++ b/arch/sparc/include/asm/tlb_32.h
@@ -1,12 +1,12 @@
 #ifndef _SPARC_TLB_H
 #define _SPARC_TLB_H
 
-#define tlb_start_vma(tlb, vma) \
+#define tlb_start_vma(tlb, vma, range_start, range_end) \
 do {								\
 	flush_cache_range(vma, vma->vm_start, vma->vm_end);	\
 } while (0)
 
-#define tlb_end_vma(tlb, vma) \
+#define tlb_end_vma(tlb, vma, range_start, range_end) \
 do {								\
 	flush_tlb_range(vma, vma->vm_start, vma->vm_end);	\
 } while (0)
diff --git a/arch/sparc/include/asm/tlb_64.h b/arch/sparc/include/asm/tlb_64.h
index ec81cde..e5d121e 100644
--- a/arch/sparc/include/asm/tlb_64.h
+++ b/arch/sparc/include/asm/tlb_64.h
@@ -105,7 +105,7 @@ static inline void tlb_remove_page(struct mmu_gather *mp, struct page *page)
 #define pud_free_tlb(tlb,pudp) __pud_free_tlb(tlb,pudp)
 
 #define tlb_migrate_finish(mm)	do { } while (0)
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma)	do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end) do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end)	do { } while (0)
 
 #endif /* _SPARC64_TLB_H */
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index 5240fa1..a2eafcc 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -7,8 +7,8 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end) do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end) do { } while (0)
 #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 
 /* struct mmu_gather is an opaque type used by the mm code for passing around
diff --git a/arch/x86/include/asm/tlb.h b/arch/x86/include/asm/tlb.h
index 829215f..7421c06 100644
--- a/arch/x86/include/asm/tlb.h
+++ b/arch/x86/include/asm/tlb.h
@@ -1,8 +1,8 @@
 #ifndef _ASM_X86_TLB_H
 #define _ASM_X86_TLB_H
 
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end) do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 #define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
 
diff --git a/arch/xtensa/include/asm/tlb.h b/arch/xtensa/include/asm/tlb.h
index 31c220f..8f99a8e 100644
--- a/arch/xtensa/include/asm/tlb.h
+++ b/arch/xtensa/include/asm/tlb.h
@@ -18,18 +18,18 @@
 
 /* Note, read http://lkml.org/lkml/2004/1/15/6 */
 
-# define tlb_start_vma(tlb,vma)			do { } while (0)
-# define tlb_end_vma(tlb,vma)			do { } while (0)
+# define tlb_start_vma(tlb, vma, range_start, range_end) do { } while (0)
+# define tlb_end_vma(tlb, vma, range_start, range_end) do { } while (0)
 
 #else
 
-# define tlb_start_vma(tlb, vma)					      \
+# define tlb_start_vma(tlb, vma, range_start, range_end)		      \
 	do {								      \
 		if (!tlb->fullmm)					      \
 			flush_cache_range(vma, vma->vm_start, vma->vm_end);   \
 	} while(0)
 
-# define tlb_end_vma(tlb, vma)						      \
+# define tlb_end_vma(tlb, vma, range_start, range_end)			      \
 	do {								      \
 		if (!tlb->fullmm)					      \
 			flush_tlb_range(vma, vma->vm_start, vma->vm_end);     \
diff --git a/include/asm-frv/tlb.h b/include/asm-frv/tlb.h
index cd458eb..8553784 100644
--- a/include/asm-frv/tlb.h
+++ b/include/asm-frv/tlb.h
@@ -12,8 +12,8 @@ extern void check_pgt_cache(void);
 /*
  * we don't need any special per-pte or per-vma handling...
  */
-#define tlb_start_vma(tlb, vma)				do { } while (0)
-#define tlb_end_vma(tlb, vma)				do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end)	do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
 /*
diff --git a/include/asm-m32r/tlb.h b/include/asm-m32r/tlb.h
index c7ebd8d..3f4c08d 100644
--- a/include/asm-m32r/tlb.h
+++ b/include/asm-m32r/tlb.h
@@ -5,8 +5,8 @@
  * x86 doesn't need any special per-pte or
  * per-vma handling..
  */
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end) do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, pte, address) do { } while (0)
 
 /*
diff --git a/include/asm-mn10300/tlb.h b/include/asm-mn10300/tlb.h
index 65d232b..89acf74 100644
--- a/include/asm-mn10300/tlb.h
+++ b/include/asm-mn10300/tlb.h
@@ -19,8 +19,8 @@ extern void check_pgt_cache(void);
 /*
  * we don't need any special per-pte or per-vma handling...
  */
-#define tlb_start_vma(tlb, vma)				do { } while (0)
-#define tlb_end_vma(tlb, vma)				do { } while (0)
+#define tlb_start_vma(tlb, vma, range_start, range_end)	do { } while (0)
+#define tlb_end_vma(tlb, vma, range_start, range_end)	do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address)	do { } while (0)
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index baa999e..44996b6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -896,17 +896,21 @@ static inline unsigned long zap_pud_range(struct mmu_gather *tlb,
 
 static unsigned long unmap_page_range(struct mmu_gather *tlb,
 				struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end,
+				unsigned long range_start, unsigned long end,
 				long *zap_work, struct zap_details *details)
 {
 	pgd_t *pgd;
 	unsigned long next;
+	unsigned long addr = range_start;
+	unsigned long range_end;
 
 	if (details && !details->check_mapping && !details->nonlinear_vma)
 		details = NULL;
 
 	BUG_ON(addr >= end);
-	tlb_start_vma(tlb, vma);
+	BUG_ON(*zap_work <= 0);
+	range_end = addr + min(end - addr, (unsigned long)*zap_work);
+	tlb_start_vma(tlb, vma, range_start, range_end);
 	pgd = pgd_offset(vma->vm_mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -917,7 +921,7 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
 		next = zap_pud_range(tlb, vma, pgd, addr, next,
 						zap_work, details);
 	} while (pgd++, addr = next, (addr != end && *zap_work > 0));
-	tlb_end_vma(tlb, vma);
+	tlb_end_vma(tlb, vma, range_start, range_end);
 
 	return addr;
 }
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
