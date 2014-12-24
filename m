Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 56A546B00BF
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:31:21 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so9901219pdi.2
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:31:21 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id j2si34277738pdo.128.2014.12.24.04.23.11
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:12 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 27/38] openrisc: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:35 +0200
Message-Id: <1419423766-114457-28-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jonas Bonn <jonas@southpole.se>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Jonas Bonn <jonas@southpole.se>
---
 arch/openrisc/include/asm/pgtable.h | 8 --------
 arch/openrisc/kernel/head.S         | 5 -----
 2 files changed, 13 deletions(-)

diff --git a/arch/openrisc/include/asm/pgtable.h b/arch/openrisc/include/asm/pgtable.h
index 37bf6a3ef8f4..18994ccb1185 100644
--- a/arch/openrisc/include/asm/pgtable.h
+++ b/arch/openrisc/include/asm/pgtable.h
@@ -125,7 +125,6 @@ extern void paging_init(void);
 #define _PAGE_CC       0x001 /* software: pte contains a translation */
 #define _PAGE_CI       0x002 /* cache inhibit          */
 #define _PAGE_WBC      0x004 /* write back cache       */
-#define _PAGE_FILE     0x004 /* set: pagecache, unset: swap (when !PRESENT) */
 #define _PAGE_WOM      0x008 /* weakly ordered memory  */
 
 #define _PAGE_A        0x010 /* accessed               */
@@ -240,7 +239,6 @@ static inline int pte_write(pte_t pte) { return pte_val(pte) & _PAGE_WRITE; }
 static inline int pte_exec(pte_t pte)  { return pte_val(pte) & _PAGE_EXEC; }
 static inline int pte_dirty(pte_t pte) { return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte) { return pte_val(pte) & _PAGE_ACCESSED; }
-static inline int pte_file(pte_t pte)  { return pte_val(pte) & _PAGE_FILE; }
 static inline int pte_special(pte_t pte) { return 0; }
 static inline pte_t pte_mkspecial(pte_t pte) { return pte; }
 
@@ -438,12 +436,6 @@ static inline void update_mmu_cache(struct vm_area_struct *vma,
 #define __pte_to_swp_entry(pte)		((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)		((pte_t) { (x).val })
 
-/* Encode and decode a nonlinear file mapping entry */
-
-#define PTE_FILE_MAX_BITS               26
-#define pte_to_pgoff(x)	                (pte_val(x) >> 6)
-#define pgoff_to_pte(x)	                __pte(((x) << 6) | _PAGE_FILE)
-
 #define kern_addr_valid(addr)           (1)
 
 #include <asm-generic/pgtable.h>
diff --git a/arch/openrisc/kernel/head.S b/arch/openrisc/kernel/head.S
index 1d3c9c28ac25..f14793306b03 100644
--- a/arch/openrisc/kernel/head.S
+++ b/arch/openrisc/kernel/head.S
@@ -754,11 +754,6 @@ _dc_enable:
 
 /* ===============================================[ page table masks ]=== */
 
-/* bit 4 is used in hardware as write back cache bit. we never use this bit
- * explicitly, so we can reuse it as _PAGE_FILE bit and mask it out when
- * writing into hardware pte's
- */
-
 #define DTLB_UP_CONVERT_MASK  0x3fa
 #define ITLB_UP_CONVERT_MASK  0x3a
 
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
