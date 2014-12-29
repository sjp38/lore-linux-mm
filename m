Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 77A2D6B0071
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 07:16:57 -0500 (EST)
Received: by mail-wg0-f46.google.com with SMTP id x13so18740233wgg.5
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 04:16:57 -0800 (PST)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id r5si72613029wju.58.2014.12.29.04.16.55
        for <linux-mm@kvack.org>;
        Mon, 29 Dec 2014 04:16:55 -0800 (PST)
Date: Mon, 29 Dec 2014 14:16:16 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCHv2 21/38] m68k: drop _PAGE_FILE and pte_file()-related helpers
Message-ID: <20141229121616.GB379@node.dhcp.inet.fi>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1419423766-114457-22-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1419423766-114457-22-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>

We've replaced remap_file_pages(2) implementation with emulation.
Nobody creates non-linear mapping anymore.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
---
 v2: fix patch miss-fold -- move m68k changes from mips commit
---
 arch/m68k/include/asm/mcf_pgtable.h      | 23 ++---------------------
 arch/m68k/include/asm/motorola_pgtable.h | 15 ---------------
 arch/m68k/include/asm/pgtable_no.h       |  2 --
 arch/m68k/include/asm/sun3_pgtable.h     | 15 ---------------
 4 files changed, 2 insertions(+), 53 deletions(-)

diff --git a/arch/m68k/include/asm/mcf_pgtable.h b/arch/m68k/include/asm/mcf_pgtable.h
index 3c793682e5d9..2500ce04fcc4 100644
--- a/arch/m68k/include/asm/mcf_pgtable.h
+++ b/arch/m68k/include/asm/mcf_pgtable.h
@@ -35,7 +35,6 @@
  * hitting hardware.
  */
 #define CF_PAGE_DIRTY		0x00000001
-#define CF_PAGE_FILE		0x00000200
 #define CF_PAGE_ACCESSED	0x00001000
 
 #define _PAGE_CACHE040		0x020   /* 68040 cache mode, cachable, copyback */
@@ -243,11 +242,6 @@ static inline int pte_young(pte_t pte)
 	return pte_val(pte) & CF_PAGE_ACCESSED;
 }
 
-static inline int pte_file(pte_t pte)
-{
-	return pte_val(pte) & CF_PAGE_FILE;
-}
-
 static inline int pte_special(pte_t pte)
 {
 	return 0;
@@ -391,26 +385,13 @@ static inline void cache_page(void *vaddr)
 	*ptep = pte_mkcache(*ptep);
 }
 
-#define PTE_FILE_MAX_BITS	21
-#define PTE_FILE_SHIFT		11
-
-static inline unsigned long pte_to_pgoff(pte_t pte)
-{
-	return pte_val(pte) >> PTE_FILE_SHIFT;
-}
-
-static inline pte_t pgoff_to_pte(unsigned pgoff)
-{
-	return __pte((pgoff << PTE_FILE_SHIFT) + CF_PAGE_FILE);
-}
-
 /*
  * Encode and de-code a swap entry (must be !pte_none(e) && !pte_present(e))
  */
 #define __swp_type(x)		((x).val & 0xFF)
-#define __swp_offset(x)		((x).val >> PTE_FILE_SHIFT)
+#define __swp_offset(x)		((x).val >> 11)
 #define __swp_entry(typ, off)	((swp_entry_t) { (typ) | \
-					(off << PTE_FILE_SHIFT) })
+					(off << 11) })
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	(__pte((x).val))
 
diff --git a/arch/m68k/include/asm/motorola_pgtable.h b/arch/m68k/include/asm/motorola_pgtable.h
index e0fdd4d08075..0085aab80e5a 100644
--- a/arch/m68k/include/asm/motorola_pgtable.h
+++ b/arch/m68k/include/asm/motorola_pgtable.h
@@ -28,7 +28,6 @@
 #define _PAGE_CHG_MASK  (PAGE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_NOCACHE)
 
 #define _PAGE_PROTNONE	0x004
-#define _PAGE_FILE	0x008	/* pagecache or swap? */
 
 #ifndef __ASSEMBLY__
 
@@ -168,7 +167,6 @@ static inline void pgd_set(pgd_t *pgdp, pmd_t *pmdp)
 static inline int pte_write(pte_t pte)		{ return !(pte_val(pte) & _PAGE_RONLY); }
 static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
-static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
 static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_wrprotect(pte_t pte)	{ pte_val(pte) |= _PAGE_RONLY; return pte; }
@@ -266,19 +264,6 @@ static inline void cache_page(void *vaddr)
 	}
 }
 
-#define PTE_FILE_MAX_BITS	28
-
-static inline unsigned long pte_to_pgoff(pte_t pte)
-{
-	return pte.pte >> 4;
-}
-
-static inline pte_t pgoff_to_pte(unsigned off)
-{
-	pte_t pte = { (off << 4) + _PAGE_FILE };
-	return pte;
-}
-
 /* Encode and de-code a swap entry (must be !pte_none(e) && !pte_present(e)) */
 #define __swp_type(x)		(((x).val >> 4) & 0xff)
 #define __swp_offset(x)		((x).val >> 12)
diff --git a/arch/m68k/include/asm/pgtable_no.h b/arch/m68k/include/asm/pgtable_no.h
index 11859b86b1f9..ac7d87a02335 100644
--- a/arch/m68k/include/asm/pgtable_no.h
+++ b/arch/m68k/include/asm/pgtable_no.h
@@ -37,8 +37,6 @@ extern void paging_init(void);
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
 
-static inline int pte_file(pte_t pte) { return 0; }
-
 /*
  * ZERO_PAGE is a global shared page that is always zero: used
  * for zero-mapped memory areas etc..
diff --git a/arch/m68k/include/asm/sun3_pgtable.h b/arch/m68k/include/asm/sun3_pgtable.h
index f55aa04161e8..48657f9fdece 100644
--- a/arch/m68k/include/asm/sun3_pgtable.h
+++ b/arch/m68k/include/asm/sun3_pgtable.h
@@ -38,8 +38,6 @@
 #define _PAGE_PRESENT	(SUN3_PAGE_VALID)
 #define _PAGE_ACCESSED	(SUN3_PAGE_ACCESSED)
 
-#define PTE_FILE_MAX_BITS 28
-
 /* Compound page protection values. */
 //todo: work out which ones *should* have SUN3_PAGE_NOCACHE and fix...
 // is it just PAGE_KERNEL and PAGE_SHARED?
@@ -168,7 +166,6 @@ static inline void pgd_clear (pgd_t *pgdp) {}
 static inline int pte_write(pte_t pte)		{ return pte_val(pte) & SUN3_PAGE_WRITEABLE; }
 static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & SUN3_PAGE_MODIFIED; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & SUN3_PAGE_ACCESSED; }
-static inline int pte_file(pte_t pte)		{ return pte_val(pte) & SUN3_PAGE_ACCESSED; }
 static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_wrprotect(pte_t pte)	{ pte_val(pte) &= ~SUN3_PAGE_WRITEABLE; return pte; }
@@ -202,18 +199,6 @@ static inline pmd_t *pmd_offset (pgd_t *pgd, unsigned long address)
 	return (pmd_t *) pgd;
 }
 
-static inline unsigned long pte_to_pgoff(pte_t pte)
-{
-	return pte.pte & SUN3_PAGE_PGNUM_MASK;
-}
-
-static inline pte_t pgoff_to_pte(unsigned off)
-{
-	pte_t pte = { off + SUN3_PAGE_ACCESSED };
-	return pte;
-}
-
-
 /* Find an entry in the third-level pagetable. */
 #define pte_index(address) ((address >> PAGE_SHIFT) & (PTRS_PER_PTE-1))
 #define pte_offset_kernel(pmd, address) ((pte_t *) __pmd_page(*pmd) + pte_index(address))
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
