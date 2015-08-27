Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 84A3A6B0256
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 05:03:52 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so18976888pac.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 02:03:52 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id vy5si2559372pac.10.2015.08.27.02.03.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 02:03:51 -0700 (PDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: [PATCH 01/11] ARC: mm: pte flags comsetic cleanups, comments
Date: Thu, 27 Aug 2015 14:33:04 +0530
Message-ID: <1440666194-21478-2-git-send-email-vgupta@synopsys.com>
In-Reply-To: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
References: <1440666194-21478-1-git-send-email-vgupta@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew
 Wilcox <matthew.r.wilcox@intel.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arc-linux-dev@synopsys.com, Vineet Gupta <Vineet.Gupta1@synopsys.com>

No semantical changes

Signed-off-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/pgtable.h | 37 ++++++++++++++++---------------------
 arch/arc/mm/tlbex.S            |  2 +-
 2 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index 1281718802f7..481359fe56ae 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -60,7 +60,7 @@
 #define _PAGE_EXECUTE       (1<<3)	/* Page has user execute perm (H) */
 #define _PAGE_WRITE         (1<<4)	/* Page has user write perm (H) */
 #define _PAGE_READ          (1<<5)	/* Page has user read perm (H) */
-#define _PAGE_MODIFIED      (1<<6)	/* Page modified (dirty) (S) */
+#define _PAGE_DIRTY         (1<<6)	/* Page modified (dirty) (S) */
 #define _PAGE_GLOBAL        (1<<8)	/* Page is global (H) */
 #define _PAGE_PRESENT       (1<<10)	/* TLB entry is valid (H) */
 
@@ -71,7 +71,7 @@
 #define _PAGE_WRITE         (1<<2)	/* Page has user write perm (H) */
 #define _PAGE_READ          (1<<3)	/* Page has user read perm (H) */
 #define _PAGE_ACCESSED      (1<<4)	/* Page is accessed (S) */
-#define _PAGE_MODIFIED      (1<<5)	/* Page modified (dirty) (S) */
+#define _PAGE_DIRTY         (1<<5)	/* Page modified (dirty) (S) */
 
 #if (CONFIG_ARC_MMU_VER >= 4)
 #define _PAGE_WTHRU         (1<<7)	/* Page cache mode write-thru (H) */
@@ -92,21 +92,16 @@
 #define _K_PAGE_PERMS  (_PAGE_EXECUTE | _PAGE_WRITE | _PAGE_READ | \
 			_PAGE_GLOBAL | _PAGE_PRESENT)
 
-#ifdef CONFIG_ARC_CACHE_PAGES
-#define _PAGE_DEF_CACHEABLE _PAGE_CACHEABLE
-#else
-#define _PAGE_DEF_CACHEABLE (0)
+#ifndef CONFIG_ARC_CACHE_PAGES
+#undef _PAGE_CACHEABLE
+#define _PAGE_CACHEABLE 0
 #endif
 
-/* Helper for every "user" page
- * -kernel can R/W/X
- * -by default cached, unless config otherwise
- * -present in memory
- */
-#define ___DEF (_PAGE_PRESENT | _PAGE_DEF_CACHEABLE)
+/* Defaults for every user page */
+#define ___DEF (_PAGE_PRESENT | _PAGE_CACHEABLE)
 
 /* Set of bits not changed in pte_modify */
-#define _PAGE_CHG_MASK	(PAGE_MASK | _PAGE_ACCESSED | _PAGE_MODIFIED)
+#define _PAGE_CHG_MASK	(PAGE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY)
 
 /* More Abbrevaited helpers */
 #define PAGE_U_NONE     __pgprot(___DEF)
@@ -122,7 +117,7 @@
  * user vaddr space - visible in all addr spaces, but kernel mode only
  * Thus Global, all-kernel-access, no-user-access, cached
  */
-#define PAGE_KERNEL          __pgprot(_K_PAGE_PERMS | _PAGE_DEF_CACHEABLE)
+#define PAGE_KERNEL          __pgprot(_K_PAGE_PERMS | _PAGE_CACHEABLE)
 
 /* ioremap */
 #define PAGE_KERNEL_NO_CACHE __pgprot(_K_PAGE_PERMS)
@@ -191,16 +186,16 @@
 
 /* Optimal Sizing of Pg Tbl - based on MMU page size */
 #if defined(CONFIG_ARC_PAGE_SIZE_8K)
-#define BITS_FOR_PTE	8
+#define BITS_FOR_PTE	8		/* 11:8:13 */
 #elif defined(CONFIG_ARC_PAGE_SIZE_16K)
-#define BITS_FOR_PTE	8
+#define BITS_FOR_PTE	8		/* 10:8:14 */
 #elif defined(CONFIG_ARC_PAGE_SIZE_4K)
-#define BITS_FOR_PTE	9
+#define BITS_FOR_PTE	9		/* 11:9:12 */
 #endif
 
 #define BITS_FOR_PGD	(32 - BITS_FOR_PTE - BITS_IN_PAGE)
 
-#define PGDIR_SHIFT	(BITS_FOR_PTE + BITS_IN_PAGE)
+#define PGDIR_SHIFT	(32 - BITS_FOR_PGD)
 #define PGDIR_SIZE	(1UL << PGDIR_SHIFT)	/* vaddr span, not PDG sz */
 #define PGDIR_MASK	(~(PGDIR_SIZE-1))
 
@@ -295,7 +290,7 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 /* Zoo of pte_xxx function */
 #define pte_read(pte)		(pte_val(pte) & _PAGE_READ)
 #define pte_write(pte)		(pte_val(pte) & _PAGE_WRITE)
-#define pte_dirty(pte)		(pte_val(pte) & _PAGE_MODIFIED)
+#define pte_dirty(pte)		(pte_val(pte) & _PAGE_DIRTY)
 #define pte_young(pte)		(pte_val(pte) & _PAGE_ACCESSED)
 #define pte_special(pte)	(0)
 
@@ -304,8 +299,8 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 
 PTE_BIT_FUNC(wrprotect,	&= ~(_PAGE_WRITE));
 PTE_BIT_FUNC(mkwrite,	|= (_PAGE_WRITE));
-PTE_BIT_FUNC(mkclean,	&= ~(_PAGE_MODIFIED));
-PTE_BIT_FUNC(mkdirty,	|= (_PAGE_MODIFIED));
+PTE_BIT_FUNC(mkclean,	&= ~(_PAGE_DIRTY));
+PTE_BIT_FUNC(mkdirty,	|= (_PAGE_DIRTY));
 PTE_BIT_FUNC(mkold,	&= ~(_PAGE_ACCESSED));
 PTE_BIT_FUNC(mkyoung,	|= (_PAGE_ACCESSED));
 PTE_BIT_FUNC(exprotect,	&= ~(_PAGE_EXECUTE));
diff --git a/arch/arc/mm/tlbex.S b/arch/arc/mm/tlbex.S
index f6f4c3cb505d..b8b014c6904d 100644
--- a/arch/arc/mm/tlbex.S
+++ b/arch/arc/mm/tlbex.S
@@ -365,7 +365,7 @@ ENTRY(EV_TLBMissD)
 	lr      r3, [ecr]
 	or      r0, r0, _PAGE_ACCESSED        ; Accessed bit always
 	btst_s  r3,  ECR_C_BIT_DTLB_ST_MISS   ; See if it was a Write Access ?
-	or.nz   r0, r0, _PAGE_MODIFIED        ; if Write, set Dirty bit as well
+	or.nz   r0, r0, _PAGE_DIRTY           ; if Write, set Dirty bit as well
 	st_s    r0, [r1]                      ; Write back PTE
 
 	CONV_PTE_TO_TLB
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
