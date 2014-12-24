Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 065056B00B7
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:30:11 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id z10so9893107pdj.14
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:30:10 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id nr8si34465401pdb.5.2014.12.24.04.23.10
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:15 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 19/38] ia64: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:27 +0200
Message-Id: <1419423766-114457-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

This patch also increase number of bits availble for swap offset.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
---
 arch/ia64/include/asm/pgtable.h | 25 +++++--------------------
 1 file changed, 5 insertions(+), 20 deletions(-)

diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 7935115398a6..2f07bb3dda91 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -57,9 +57,6 @@
 #define _PAGE_ED		(__IA64_UL(1) << 52)	/* exception deferral */
 #define _PAGE_PROTNONE		(__IA64_UL(1) << 63)
 
-/* Valid only for a PTE with the present bit cleared: */
-#define _PAGE_FILE		(1 << 1)		/* see swap & file pte remarks below */
-
 #define _PFN_MASK		_PAGE_PPN_MASK
 /* Mask of bits which may be changed by pte_modify(); the odd bits are there for _PAGE_PROTNONE */
 #define _PAGE_CHG_MASK	(_PAGE_P | _PAGE_PROTNONE | _PAGE_PL_MASK | _PAGE_AR_MASK | _PAGE_ED)
@@ -300,7 +297,6 @@ extern unsigned long VMALLOC_END;
 #define pte_exec(pte)		((pte_val(pte) & _PAGE_AR_RX) != 0)
 #define pte_dirty(pte)		((pte_val(pte) & _PAGE_D) != 0)
 #define pte_young(pte)		((pte_val(pte) & _PAGE_A) != 0)
-#define pte_file(pte)		((pte_val(pte) & _PAGE_FILE) != 0)
 #define pte_special(pte)	0
 
 /*
@@ -472,27 +468,16 @@ extern void paging_init (void);
  *
  * Format of swap pte:
  *	bit   0   : present bit (must be zero)
- *	bit   1   : _PAGE_FILE (must be zero)
- *	bits  2- 8: swap-type
- *	bits  9-62: swap offset
- *	bit  63   : _PAGE_PROTNONE bit
- *
- * Format of file pte:
- *	bit   0   : present bit (must be zero)
- *	bit   1   : _PAGE_FILE (must be one)
- *	bits  2-62: file_offset/PAGE_SIZE
+ *	bits  1- 7: swap-type
+ *	bits  8-62: swap offset
  *	bit  63   : _PAGE_PROTNONE bit
  */
-#define __swp_type(entry)		(((entry).val >> 2) & 0x7f)
-#define __swp_offset(entry)		(((entry).val << 1) >> 10)
-#define __swp_entry(type,offset)	((swp_entry_t) { ((type) << 2) | ((long) (offset) << 9) })
+#define __swp_type(entry)		(((entry).val >> 1) & 0x7f)
+#define __swp_offset(entry)		(((entry).val << 1) >> 9)
+#define __swp_entry(type,offset)	((swp_entry_t) { ((type) << 1) | ((long) (offset) << 8) })
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-#define PTE_FILE_MAX_BITS		61
-#define pte_to_pgoff(pte)		((pte_val(pte) << 1) >> 3)
-#define pgoff_to_pte(off)		((pte_t) { ((off) << 2) | _PAGE_FILE })
-
 /*
  * ZERO_PAGE is a global shared page that is always zero: used
  * for zero-mapped memory areas etc..
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
