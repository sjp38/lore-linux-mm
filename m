Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id A386B6B00BD
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:30:37 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so9884136pdb.32
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:30:37 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id b3si18958682pat.121.2014.12.24.04.23.14
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:15 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 38/38] xtensa: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:46 +0200
Message-Id: <1419423766-114457-39-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Max Filippov <jcmvbkbc@gmail.com>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Max Filippov <jcmvbkbc@gmail.com>
---
 arch/xtensa/include/asm/pgtable.h | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/arch/xtensa/include/asm/pgtable.h b/arch/xtensa/include/asm/pgtable.h
index 872bf0194e6d..01b80dce9d65 100644
--- a/arch/xtensa/include/asm/pgtable.h
+++ b/arch/xtensa/include/asm/pgtable.h
@@ -89,8 +89,6 @@
  *   (PAGE_NONE)|    PPN    | 0 | 00 | ADW | 01 | 11 | 11 |
  *		+-----------------------------------------+
  *   swap	|     index     |   type   | 01 | 11 | 00 |
- *		+- - - - - - - - - - - - - - - - - - - - -+
- *   file	|        file offset       | 01 | 11 | 10 |
  *		+-----------------------------------------+
  *
  * For T1050 hardware and earlier the layout differs for present and (PAGE_NONE)
@@ -111,7 +109,6 @@
  *   index      swap offset / PAGE_SIZE (bit 11-31: 21 bits -> 8 GB)
  *		(note that the index is always non-zero)
  *   type       swap type (5 bits -> 32 types)
- *   file offset 26-bit offset into the file, in increments of PAGE_SIZE
  *
  *  Notes:
  *   - (PROT_NONE) is a special case of 'present' but causes an exception for
@@ -144,7 +141,6 @@
 #define _PAGE_HW_VALID		0x00
 #define _PAGE_NONE		0x0f
 #endif
-#define _PAGE_FILE		(1<<1)	/* file mapped page, only if !present */
 
 #define _PAGE_USER		(1<<4)	/* user access (ring=1) */
 
@@ -260,7 +256,6 @@ static inline void pgtable_cache_init(void) { }
 static inline int pte_write(pte_t pte) { return pte_val(pte) & _PAGE_WRITABLE; }
 static inline int pte_dirty(pte_t pte) { return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte) { return pte_val(pte) & _PAGE_ACCESSED; }
-static inline int pte_file(pte_t pte)  { return pte_val(pte) & _PAGE_FILE; }
 static inline int pte_special(pte_t pte) { return 0; }
 
 static inline pte_t pte_wrprotect(pte_t pte)	
@@ -390,11 +385,6 @@ ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
 
-#define PTE_FILE_MAX_BITS	26
-#define pte_to_pgoff(pte)	(pte_val(pte) >> 6)
-#define pgoff_to_pte(off)	\
-	((pte_t) { ((off) << 6) | _PAGE_CA_INVALID | _PAGE_FILE | _PAGE_USER })
-
 #endif /*  !defined (__ASSEMBLY__) */
 
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
