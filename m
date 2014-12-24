Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD6C6B0075
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:23:21 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so9894693pdb.38
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:23:21 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j2si34277738pdo.128.2014.12.24.04.23.07
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:08 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 13/38] avr32: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:21 +0200
Message-Id: <1419423766-114457-14-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Haavard Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
---
 arch/avr32/include/asm/pgtable.h | 25 -------------------------
 1 file changed, 25 deletions(-)

diff --git a/arch/avr32/include/asm/pgtable.h b/arch/avr32/include/asm/pgtable.h
index 4beff97e2033..ac7a817e2126 100644
--- a/arch/avr32/include/asm/pgtable.h
+++ b/arch/avr32/include/asm/pgtable.h
@@ -86,9 +86,6 @@ extern struct page *empty_zero_page;
 #define _PAGE_BIT_PRESENT	10
 #define _PAGE_BIT_ACCESSED	11 /* software: page was accessed */
 
-/* The following flags are only valid when !PRESENT */
-#define _PAGE_BIT_FILE		0 /* software: pagecache or swap? */
-
 #define _PAGE_WT		(1 << _PAGE_BIT_WT)
 #define _PAGE_DIRTY		(1 << _PAGE_BIT_DIRTY)
 #define _PAGE_EXECUTE		(1 << _PAGE_BIT_EXECUTE)
@@ -101,7 +98,6 @@ extern struct page *empty_zero_page;
 /* Software flags */
 #define _PAGE_ACCESSED		(1 << _PAGE_BIT_ACCESSED)
 #define _PAGE_PRESENT		(1 << _PAGE_BIT_PRESENT)
-#define _PAGE_FILE		(1 << _PAGE_BIT_FILE)
 
 /*
  * Page types, i.e. sizes. _PAGE_TYPE_NONE corresponds to what is
@@ -210,14 +206,6 @@ static inline int pte_special(pte_t pte)
 	return 0;
 }
 
-/*
- * The following only work if pte_present() is not true.
- */
-static inline int pte_file(pte_t pte)
-{
-	return pte_val(pte) & _PAGE_FILE;
-}
-
 /* Mutator functions for PTE bits */
 static inline pte_t pte_wrprotect(pte_t pte)
 {
@@ -329,7 +317,6 @@ extern void update_mmu_cache(struct vm_area_struct * vma,
  * Encode and decode a swap entry
  *
  * Constraints:
- *   _PAGE_FILE at bit 0
  *   _PAGE_TYPE_* at bits 2-3 (for emulating _PAGE_PROTNONE)
  *   _PAGE_PRESENT at bit 10
  *
@@ -346,18 +333,6 @@ extern void update_mmu_cache(struct vm_area_struct * vma,
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
 
-/*
- * Encode and decode a nonlinear file mapping entry. We have to
- * preserve _PAGE_FILE and _PAGE_PRESENT here. _PAGE_TYPE_* isn't
- * necessary, since _PAGE_FILE implies !_PAGE_PROTNONE (?)
- */
-#define PTE_FILE_MAX_BITS	30
-#define pte_to_pgoff(pte)	(((pte_val(pte) >> 1) & 0x1ff)		\
-				 | ((pte_val(pte) >> 11) << 9))
-#define pgoff_to_pte(off)	((pte_t) { ((((off) & 0x1ff) << 1)	\
-					    | (((off) >> 9) << 11)	\
-					    | _PAGE_FILE) })
-
 typedef pte_t *pte_addr_t;
 
 #define kern_addr_valid(addr)	(1)
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
