Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id D50316B0096
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:55 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id v10so9852941pde.15
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:55 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hu6si22106881pac.115.2014.12.24.04.23.33
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 10/38] arc: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:18 +0200
Message-Id: <1419423766-114457-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vineet Gupta <vgupta@synopsys.com>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/pgtable.h | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index 6b0b7f7ef783..55694ee428d4 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -61,7 +61,6 @@
 #define _PAGE_WRITE         (1<<4)	/* Page has user write perm (H) */
 #define _PAGE_READ          (1<<5)	/* Page has user read perm (H) */
 #define _PAGE_MODIFIED      (1<<6)	/* Page modified (dirty) (S) */
-#define _PAGE_FILE          (1<<7)	/* page cache/ swap (S) */
 #define _PAGE_GLOBAL        (1<<8)	/* Page is global (H) */
 #define _PAGE_PRESENT       (1<<10)	/* TLB entry is valid (H) */
 
@@ -73,7 +72,6 @@
 #define _PAGE_READ          (1<<3)	/* Page has user read perm (H) */
 #define _PAGE_ACCESSED      (1<<4)	/* Page is accessed (S) */
 #define _PAGE_MODIFIED      (1<<5)	/* Page modified (dirty) (S) */
-#define _PAGE_FILE          (1<<6)	/* page cache/ swap (S) */
 #define _PAGE_GLOBAL        (1<<8)	/* Page is global (H) */
 #define _PAGE_PRESENT       (1<<9)	/* TLB entry is valid (H) */
 #define _PAGE_SHARED_CODE   (1<<11)	/* Shared Code page with cmn vaddr
@@ -268,15 +266,6 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 	pte;								\
 })
 
-/* TBD: Non linear mapping stuff */
-static inline int pte_file(pte_t pte)
-{
-	return pte_val(pte) & _PAGE_FILE;
-}
-
-#define PTE_FILE_MAX_BITS	30
-#define pgoff_to_pte(x)         __pte(x)
-#define pte_to_pgoff(x)		(pte_val(x) >> 2)
 #define pte_pfn(pte)		(pte_val(pte) >> PAGE_SHIFT)
 #define pfn_pte(pfn, prot)	(__pte(((pfn) << PAGE_SHIFT) | pgprot_val(prot)))
 #define __pte_index(addr)	(((addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
@@ -358,13 +347,13 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 #endif
 
 extern void paging_init(void);
-extern pgd_t swapper_pg_dir[] __aligned(PAGE_SIZE);
+xtern pgd_t swapper_pg_dir[] __aligned(PAGE_SIZE);
 void update_mmu_cache(struct vm_area_struct *vma, unsigned long address,
 		      pte_t *ptep);
 
 /* Encode swap {type,off} tuple into PTE
  * We reserve 13 bits for 5-bit @type, keeping bits 12-5 zero, ensuring that
- * both PAGE_FILE and PAGE_PRESENT are zero in a PTE holding swap "identifier"
+ * PAGE_PRESENT is zero in a PTE holding swap "identifier"
  */
 #define __swp_entry(type, off)	((swp_entry_t) { \
 					((type) & 0x1f) | ((off) << 13) })
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
