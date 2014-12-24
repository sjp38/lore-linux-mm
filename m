Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 060B56B0082
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:36 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so9874555pdb.4
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:35 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j2si34277738pdo.128.2014.12.24.04.23.10
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:11 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 20/38] m32r: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:28 +0200
Message-Id: <1419423766-114457-21-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/m32r/include/asm/pgtable-2level.h |  4 ----
 arch/m32r/include/asm/pgtable.h        | 11 -----------
 2 files changed, 15 deletions(-)

diff --git a/arch/m32r/include/asm/pgtable-2level.h b/arch/m32r/include/asm/pgtable-2level.h
index 9cdaf7350ef6..8fd8ee70266a 100644
--- a/arch/m32r/include/asm/pgtable-2level.h
+++ b/arch/m32r/include/asm/pgtable-2level.h
@@ -70,9 +70,5 @@ static inline pmd_t *pmd_offset(pgd_t * dir, unsigned long address)
 #define pfn_pte(pfn, prot)	__pte(((pfn) << PAGE_SHIFT) | pgprot_val(prot))
 #define pfn_pmd(pfn, prot)	__pmd(((pfn) << PAGE_SHIFT) | pgprot_val(prot))
 
-#define PTE_FILE_MAX_BITS	29
-#define pte_to_pgoff(pte)	(((pte_val(pte) >> 2) & 0x7f) | (((pte_val(pte) >> 10)) << 7))
-#define pgoff_to_pte(off)	((pte_t) { (((off) & 0x7f) << 2) | (((off) >> 7) << 10) | _PAGE_FILE })
-
 #endif /* __KERNEL__ */
 #endif /* _ASM_M32R_PGTABLE_2LEVEL_H */
diff --git a/arch/m32r/include/asm/pgtable.h b/arch/m32r/include/asm/pgtable.h
index 103ce6710f07..050f7a686e3d 100644
--- a/arch/m32r/include/asm/pgtable.h
+++ b/arch/m32r/include/asm/pgtable.h
@@ -80,8 +80,6 @@ extern unsigned long empty_zero_page[1024];
  */
 
 #define _PAGE_BIT_DIRTY		0	/* software: page changed */
-#define _PAGE_BIT_FILE		0	/* when !present: nonlinear file
-					   mapping */
 #define _PAGE_BIT_PRESENT	1	/* Valid: page is valid */
 #define _PAGE_BIT_GLOBAL	2	/* Global */
 #define _PAGE_BIT_LARGE		3	/* Large */
@@ -93,7 +91,6 @@ extern unsigned long empty_zero_page[1024];
 #define _PAGE_BIT_PROTNONE	9	/* software: if not present */
 
 #define _PAGE_DIRTY		(1UL << _PAGE_BIT_DIRTY)
-#define _PAGE_FILE		(1UL << _PAGE_BIT_FILE)
 #define _PAGE_PRESENT		(1UL << _PAGE_BIT_PRESENT)
 #define _PAGE_GLOBAL		(1UL << _PAGE_BIT_GLOBAL)
 #define _PAGE_LARGE		(1UL << _PAGE_BIT_LARGE)
@@ -206,14 +203,6 @@ static inline int pte_write(pte_t pte)
 	return pte_val(pte) & _PAGE_WRITE;
 }
 
-/*
- * The following only works if pte_present() is not true.
- */
-static inline int pte_file(pte_t pte)
-{
-	return pte_val(pte) & _PAGE_FILE;
-}
-
 static inline int pte_special(pte_t pte)
 {
 	return 0;
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
