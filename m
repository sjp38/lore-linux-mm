Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id F13326B00BB
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:30:29 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so9888212pde.40
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:30:29 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id nr8si34465401pdb.5.2014.12.24.04.23.15
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:17 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 30/38] s390: drop pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:38 +0200
Message-Id: <1419423766-114457-31-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 arch/s390/include/asm/pgtable.h | 29 ++++-------------------------
 1 file changed, 4 insertions(+), 25 deletions(-)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 5e102422c9ab..ffb1d8ce97ae 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -249,10 +249,10 @@ static inline int is_module_addr(void *addr)
 				 _PAGE_YOUNG)
 
 /*
- * handle_pte_fault uses pte_present, pte_none and pte_file to find out the
- * pte type WITHOUT holding the page table lock. The _PAGE_PRESENT bit
- * is used to distinguish present from not-present ptes. It is changed only
- * with the page table lock held.
+ * handle_pte_fault uses pte_present and pte_none to find out the pte type
+ * WITHOUT holding the page table lock. The _PAGE_PRESENT bit is used to
+ * distinguish present from not-present ptes. It is changed only with the page
+ * table lock held.
  *
  * The following table gives the different possible bit combinations for
  * the pte hardware and software bits in the last 12 bits of a pte:
@@ -279,7 +279,6 @@ static inline int is_module_addr(void *addr)
  *
  * pte_present is true for the bit pattern .xx...xxxxx1, (pte & 0x001) == 0x001
  * pte_none    is true for the bit pattern .10...xxxx00, (pte & 0x603) == 0x400
- * pte_file    is true for the bit pattern .11...xxxxx0, (pte & 0x601) == 0x600
  * pte_swap    is true for the bit pattern .10...xxxx10, (pte & 0x603) == 0x402
  */
 
@@ -671,13 +670,6 @@ static inline int pte_swap(pte_t pte)
 		== (_PAGE_INVALID | _PAGE_TYPE);
 }
 
-static inline int pte_file(pte_t pte)
-{
-	/* Bit pattern: (pte & 0x601) == 0x600 */
-	return (pte_val(pte) & (_PAGE_INVALID | _PAGE_PROTECT | _PAGE_PRESENT))
-		== (_PAGE_INVALID | _PAGE_PROTECT);
-}
-
 static inline int pte_special(pte_t pte)
 {
 	return (pte_val(pte) & _PAGE_SPECIAL);
@@ -1756,19 +1748,6 @@ static inline pte_t mk_swap_pte(unsigned long type, unsigned long offset)
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
 
-#ifndef CONFIG_64BIT
-# define PTE_FILE_MAX_BITS	26
-#else /* CONFIG_64BIT */
-# define PTE_FILE_MAX_BITS	59
-#endif /* CONFIG_64BIT */
-
-#define pte_to_pgoff(__pte) \
-	((((__pte).pte >> 12) << 7) + (((__pte).pte >> 1) & 0x7f))
-
-#define pgoff_to_pte(__off) \
-	((pte_t) { ((((__off) & 0x7f) << 1) + (((__off) >> 7) << 12)) \
-		   | _PAGE_INVALID | _PAGE_PROTECT })
-
 #endif /* !__ASSEMBLY__ */
 
 #define kern_addr_valid(addr)   (1)
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
