Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 937896B009A
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:24:00 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so9967141pad.15
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:24:00 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id kv12si34099307pab.232.2014.12.24.04.23.42
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:43 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 28/38] parisc: drop _PAGE_FILE and pte_file()-related helpers
Date: Wed, 24 Dec 2014 14:22:36 +0200
Message-Id: <1419423766-114457-29-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: "James E.J. Bottomley" <jejb@parisc-linux.org>
Cc: Helge Deller <deller@gmx.de>
---
 arch/parisc/include/asm/pgtable.h | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/arch/parisc/include/asm/pgtable.h b/arch/parisc/include/asm/pgtable.h
index 22b89d1edba7..1d49a4a7749b 100644
--- a/arch/parisc/include/asm/pgtable.h
+++ b/arch/parisc/include/asm/pgtable.h
@@ -146,7 +146,6 @@ extern void purge_tlb_entries(struct mm_struct *, unsigned long);
 #define _PAGE_GATEWAY_BIT  28   /* (0x008) privilege promotion allowed */
 #define _PAGE_DMB_BIT      27   /* (0x010) Data Memory Break enable (B bit) */
 #define _PAGE_DIRTY_BIT    26   /* (0x020) Page Dirty (D bit) */
-#define _PAGE_FILE_BIT	_PAGE_DIRTY_BIT	/* overload this bit */
 #define _PAGE_REFTRAP_BIT  25   /* (0x040) Page Ref. Trap enable (T bit) */
 #define _PAGE_NO_CACHE_BIT 24   /* (0x080) Uncached Page (U bit) */
 #define _PAGE_ACCESSED_BIT 23   /* (0x100) Software: Page Accessed */
@@ -167,13 +166,6 @@ extern void purge_tlb_entries(struct mm_struct *, unsigned long);
 /* PFN_PTE_SHIFT defines the shift of a PTE value to access the PFN field */
 #define PFN_PTE_SHIFT		12
 
-
-/* this is how many bits may be used by the file functions */
-#define PTE_FILE_MAX_BITS	(BITS_PER_LONG - PTE_SHIFT)
-
-#define pte_to_pgoff(pte) (pte_val(pte) >> PTE_SHIFT)
-#define pgoff_to_pte(off) ((pte_t) { ((off) << PTE_SHIFT) | _PAGE_FILE })
-
 #define _PAGE_READ     (1 << xlate_pabit(_PAGE_READ_BIT))
 #define _PAGE_WRITE    (1 << xlate_pabit(_PAGE_WRITE_BIT))
 #define _PAGE_RW       (_PAGE_READ | _PAGE_WRITE)
@@ -186,7 +178,6 @@ extern void purge_tlb_entries(struct mm_struct *, unsigned long);
 #define _PAGE_ACCESSED (1 << xlate_pabit(_PAGE_ACCESSED_BIT))
 #define _PAGE_PRESENT  (1 << xlate_pabit(_PAGE_PRESENT_BIT))
 #define _PAGE_USER     (1 << xlate_pabit(_PAGE_USER_BIT))
-#define _PAGE_FILE     (1 << xlate_pabit(_PAGE_FILE_BIT))
 
 #define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_READ | _PAGE_WRITE |  _PAGE_DIRTY | _PAGE_ACCESSED)
 #define _PAGE_CHG_MASK	(PAGE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY)
@@ -344,7 +335,6 @@ static inline void pgd_clear(pgd_t * pgdp)	{ }
 static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)		{ return pte_val(pte) & _PAGE_WRITE; }
-static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
 static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_mkclean(pte_t pte)	{ pte_val(pte) &= ~_PAGE_DIRTY; return pte; }
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
