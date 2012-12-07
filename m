Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 472996B0083
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 06:54:17 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, REBASED] asm-generic, mm: PTE_SPECIAL cleanup
Date: Fri,  7 Dec 2012 13:55:21 +0200
Message-Id: <1354881321-29363-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Advertise PTE_SPECIAL through Kconfig option and consolidate dummy
pte_special() and mkspecial() in <asm-generic/pgtable.h>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/Kconfig                             |    6 ++++++
 arch/alpha/include/asm/pgtable.h         |    2 --
 arch/arm/include/asm/pgtable.h           |    3 ---
 arch/arm64/Kconfig                       |    3 ++-
 arch/arm64/include/asm/pgtable.h         |    2 --
 arch/avr32/include/asm/pgtable.h         |    8 --------
 arch/cris/include/asm/pgtable.h          |    2 --
 arch/frv/include/asm/pgtable.h           |    2 --
 arch/hexagon/include/asm/pgtable.h       |    2 --
 arch/ia64/include/asm/pgtable.h          |    2 --
 arch/m32r/include/asm/pgtable.h          |   10 ----------
 arch/m68k/include/asm/mcf_pgtable.h      |   10 ----------
 arch/m68k/include/asm/motorola_pgtable.h |    2 --
 arch/m68k/include/asm/sun3_pgtable.h     |    2 --
 arch/microblaze/include/asm/pgtable.h    |    4 ----
 arch/mips/include/asm/pgtable.h          |    2 --
 arch/mn10300/include/asm/pgtable.h       |    3 ---
 arch/openrisc/include/asm/pgtable.h      |    2 --
 arch/parisc/include/asm/pgtable.h        |    2 --
 arch/powerpc/Kconfig                     |    1 +
 arch/powerpc/include/asm/pte-common.h    |    4 ----
 arch/powerpc/mm/gup.c                    |    4 ----
 arch/s390/Kconfig                        |    1 +
 arch/s390/include/asm/pgtable.h          |    1 -
 arch/score/include/asm/pgtable.h         |    3 ---
 arch/sh/Kconfig                          |    1 +
 arch/sh/include/asm/pgtable.h            |    2 --
 arch/sparc/Kconfig                       |    1 +
 arch/sparc/include/asm/pgtable_32.h      |    7 -------
 arch/sparc/include/asm/pgtable_64.h      |    3 ---
 arch/tile/include/asm/pgtable.h          |    3 ---
 arch/um/include/asm/pgtable.h            |   10 ----------
 arch/unicore32/include/asm/pgtable.h     |    3 ---
 arch/x86/Kconfig                         |    1 +
 arch/x86/include/asm/pgtable_types.h     |    1 -
 arch/xtensa/include/asm/pgtable.h        |    3 ---
 include/asm-generic/pgtable.h            |   12 ++++++++++++
 mm/memory.c                              |   11 +++--------
 38 files changed, 28 insertions(+), 113 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index 6887f57..fc21a52 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -364,4 +364,10 @@ config CLONE_BACKWARDS2
 	help
 	  Architecture has the first two arguments of clone(2) swapped.
 
+config HAVE_PTE_SPECIAL
+	bool
+	help
+	  An arch should select this symbol if it provides pte_special() and
+	  mkspecial().
+
 source "kernel/gcov/Kconfig"
diff --git a/arch/alpha/include/asm/pgtable.h b/arch/alpha/include/asm/pgtable.h
index 81a4342..cf2b12a 100644
--- a/arch/alpha/include/asm/pgtable.h
+++ b/arch/alpha/include/asm/pgtable.h
@@ -269,7 +269,6 @@ extern inline int pte_write(pte_t pte)		{ return !(pte_val(pte) & _PAGE_FOW); }
 extern inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 extern inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 extern inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
-extern inline int pte_special(pte_t pte)	{ return 0; }
 
 extern inline pte_t pte_wrprotect(pte_t pte)	{ pte_val(pte) |= _PAGE_FOW; return pte; }
 extern inline pte_t pte_mkclean(pte_t pte)	{ pte_val(pte) &= ~(__DIRTY_BITS); return pte; }
@@ -277,7 +276,6 @@ extern inline pte_t pte_mkold(pte_t pte)	{ pte_val(pte) &= ~(__ACCESS_BITS); ret
 extern inline pte_t pte_mkwrite(pte_t pte)	{ pte_val(pte) &= ~_PAGE_FOW; return pte; }
 extern inline pte_t pte_mkdirty(pte_t pte)	{ pte_val(pte) |= __DIRTY_BITS; return pte; }
 extern inline pte_t pte_mkyoung(pte_t pte)	{ pte_val(pte) |= __ACCESS_BITS; return pte; }
-extern inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 #define PAGE_DIR_OFFSET(tsk,address) pgd_offset((tsk),(address))
 
diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index 9c82f98..6e06db6 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -201,7 +201,6 @@ static inline pte_t *pmd_page_vaddr(pmd_t pmd)
 #define pte_dirty(pte)		(pte_val(pte) & L_PTE_DIRTY)
 #define pte_young(pte)		(pte_val(pte) & L_PTE_YOUNG)
 #define pte_exec(pte)		(!(pte_val(pte) & L_PTE_XN))
-#define pte_special(pte)	(0)
 
 #define pte_present_user(pte)  (pte_present(pte) && (pte_val(pte) & L_PTE_USER))
 
@@ -236,8 +235,6 @@ PTE_BIT_FUNC(mkdirty,   |= L_PTE_DIRTY);
 PTE_BIT_FUNC(mkold,     &= ~L_PTE_YOUNG);
 PTE_BIT_FUNC(mkyoung,   |= L_PTE_YOUNG);
 
-static inline pte_t pte_mkspecial(pte_t pte) { return pte; }
-
 static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
 {
 	const pteval_t mask = L_PTE_XN | L_PTE_RDONLY | L_PTE_USER | L_PTE_NONE;
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index ef90d61..1e2d450 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -32,7 +32,8 @@ config ARM64
 	select RTC_LIB
 	select SPARSE_IRQ
 	select SYSCTL_EXCEPTION_TRACE
-	select CLONE_BACKWARDS
+	select CHAVE_SPARSE_IRQLONE_BACKWARDS
+	select HAVE_SPARSE_IRQ
 	help
 	  ARM 64-bit (AArch64) Linux support.
 
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 64b1339..880ac4b 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -173,8 +173,6 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 #define __pgprot_modify(prot,mask,bits)		\
 	__pgprot((pgprot_val(prot) & ~(mask)) | (bits))
 
-#define __HAVE_ARCH_PTE_SPECIAL
-
 /*
  * Mark the prot value as uncacheable and unbufferable.
  */
diff --git a/arch/avr32/include/asm/pgtable.h b/arch/avr32/include/asm/pgtable.h
index 6fbfea6..262d3f5 100644
--- a/arch/avr32/include/asm/pgtable.h
+++ b/arch/avr32/include/asm/pgtable.h
@@ -205,10 +205,6 @@ static inline int pte_young(pte_t pte)
 {
 	return pte_val(pte) & _PAGE_ACCESSED;
 }
-static inline int pte_special(pte_t pte)
-{
-	return 0;
-}
 
 /*
  * The following only work if pte_present() is not true.
@@ -249,10 +245,6 @@ static inline pte_t pte_mkyoung(pte_t pte)
 	set_pte(&pte, __pte(pte_val(pte) | _PAGE_ACCESSED));
 	return pte;
 }
-static inline pte_t pte_mkspecial(pte_t pte)
-{
-	return pte;
-}
 
 #define pmd_none(x)	(!pmd_val(x))
 #define pmd_present(x)	(pmd_val(x))
diff --git a/arch/cris/include/asm/pgtable.h b/arch/cris/include/asm/pgtable.h
index 7df4301..2787331 100644
--- a/arch/cris/include/asm/pgtable.h
+++ b/arch/cris/include/asm/pgtable.h
@@ -115,7 +115,6 @@ static inline int pte_write(pte_t pte)          { return pte_val(pte) & _PAGE_WR
 static inline int pte_dirty(pte_t pte)          { return pte_val(pte) & _PAGE_MODIFIED; }
 static inline int pte_young(pte_t pte)          { return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)           { return pte_val(pte) & _PAGE_FILE; }
-static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_wrprotect(pte_t pte)
 {
@@ -163,7 +162,6 @@ static inline pte_t pte_mkyoung(pte_t pte)
         }
         return pte;
 }
-static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 /*
  * Conversion functions: convert a page and protection to a page entry,
diff --git a/arch/frv/include/asm/pgtable.h b/arch/frv/include/asm/pgtable.h
index 6bc241e..324d016 100644
--- a/arch/frv/include/asm/pgtable.h
+++ b/arch/frv/include/asm/pgtable.h
@@ -378,7 +378,6 @@ static inline pmd_t *pmd_offset(pud_t *dir, unsigned long address)
 static inline int pte_dirty(pte_t pte)		{ return (pte).pte & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return (pte).pte & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)		{ return !((pte).pte & _PAGE_WP); }
-static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_mkclean(pte_t pte)	{ (pte).pte &= ~_PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkold(pte_t pte)	{ (pte).pte &= ~_PAGE_ACCESSED; return pte; }
@@ -386,7 +385,6 @@ static inline pte_t pte_wrprotect(pte_t pte)	{ (pte).pte |= _PAGE_WP; return pte
 static inline pte_t pte_mkdirty(pte_t pte)	{ (pte).pte |= _PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte)	{ (pte).pte |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ (pte).pte &= ~_PAGE_WP; return pte; }
-static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 static inline int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
diff --git a/arch/hexagon/include/asm/pgtable.h b/arch/hexagon/include/asm/pgtable.h
index 20d55f6..d294932 100644
--- a/arch/hexagon/include/asm/pgtable.h
+++ b/arch/hexagon/include/asm/pgtable.h
@@ -179,8 +179,6 @@ extern pgd_t swapper_pg_dir[PTRS_PER_PGD];  /* located in head.S */
 
 /* Seems to be zero even in architectures where the zero page is firewalled? */
 #define FIRST_USER_ADDRESS 0
-#define pte_special(pte)	0
-#define pte_mkspecial(pte)	(pte)
 
 /*  HUGETLB not working currently  */
 #ifdef CONFIG_HUGETLB_PAGE
diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index 815810c..9b25431 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -301,7 +301,6 @@ extern unsigned long VMALLOC_END;
 #define pte_dirty(pte)		((pte_val(pte) & _PAGE_D) != 0)
 #define pte_young(pte)		((pte_val(pte) & _PAGE_A) != 0)
 #define pte_file(pte)		((pte_val(pte) & _PAGE_FILE) != 0)
-#define pte_special(pte)	0
 
 /*
  * Note: we convert AR_RWX to AR_RX and AR_RW to AR_R by clearing the 2nd bit in the
@@ -314,7 +313,6 @@ extern unsigned long VMALLOC_END;
 #define pte_mkclean(pte)	(__pte(pte_val(pte) & ~_PAGE_D))
 #define pte_mkdirty(pte)	(__pte(pte_val(pte) | _PAGE_D))
 #define pte_mkhuge(pte)		(__pte(pte_val(pte)))
-#define pte_mkspecial(pte)	(pte)
 
 /*
  * Because ia64's Icache and Dcache is not coherent (on a cpu), we need to
diff --git a/arch/m32r/include/asm/pgtable.h b/arch/m32r/include/asm/pgtable.h
index 8a28cfe..8c39a47 100644
--- a/arch/m32r/include/asm/pgtable.h
+++ b/arch/m32r/include/asm/pgtable.h
@@ -214,11 +214,6 @@ static inline int pte_file(pte_t pte)
 	return pte_val(pte) & _PAGE_FILE;
 }
 
-static inline int pte_special(pte_t pte)
-{
-	return 0;
-}
-
 static inline pte_t pte_mkclean(pte_t pte)
 {
 	pte_val(pte) &= ~_PAGE_DIRTY;
@@ -255,11 +250,6 @@ static inline pte_t pte_mkwrite(pte_t pte)
 	return pte;
 }
 
-static inline pte_t pte_mkspecial(pte_t pte)
-{
-	return pte;
-}
-
 static inline  int ptep_test_and_clear_young(struct vm_area_struct *vma, unsigned long addr, pte_t *ptep)
 {
 	return test_and_clear_bit(_PAGE_BIT_ACCESSED, ptep);
diff --git a/arch/m68k/include/asm/mcf_pgtable.h b/arch/m68k/include/asm/mcf_pgtable.h
index 3c79368..eba624b 100644
--- a/arch/m68k/include/asm/mcf_pgtable.h
+++ b/arch/m68k/include/asm/mcf_pgtable.h
@@ -248,11 +248,6 @@ static inline int pte_file(pte_t pte)
 	return pte_val(pte) & CF_PAGE_FILE;
 }
 
-static inline int pte_special(pte_t pte)
-{
-	return 0;
-}
-
 static inline pte_t pte_wrprotect(pte_t pte)
 {
 	pte_val(pte) &= ~CF_PAGE_WRITABLE;
@@ -325,11 +320,6 @@ static inline pte_t pte_mkcache(pte_t pte)
 	return pte;
 }
 
-static inline pte_t pte_mkspecial(pte_t pte)
-{
-	return pte;
-}
-
 #define swapper_pg_dir kernel_pg_dir
 extern pgd_t kernel_pg_dir[PTRS_PER_PGD];
 
diff --git a/arch/m68k/include/asm/motorola_pgtable.h b/arch/m68k/include/asm/motorola_pgtable.h
index e0fdd4d..a1c209f 100644
--- a/arch/m68k/include/asm/motorola_pgtable.h
+++ b/arch/m68k/include/asm/motorola_pgtable.h
@@ -169,7 +169,6 @@ static inline int pte_write(pte_t pte)		{ return !(pte_val(pte) & _PAGE_RONLY);
 static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
-static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_wrprotect(pte_t pte)	{ pte_val(pte) |= _PAGE_RONLY; return pte; }
 static inline pte_t pte_mkclean(pte_t pte)	{ pte_val(pte) &= ~_PAGE_DIRTY; return pte; }
@@ -187,7 +186,6 @@ static inline pte_t pte_mkcache(pte_t pte)
 	pte_val(pte) = (pte_val(pte) & _CACHEMASK040) | m68k_supervisor_cachemode;
 	return pte;
 }
-static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 #define PAGE_DIR_OFFSET(tsk,address) pgd_offset((tsk),(address))
 
diff --git a/arch/m68k/include/asm/sun3_pgtable.h b/arch/m68k/include/asm/sun3_pgtable.h
index f55aa04..5c98030 100644
--- a/arch/m68k/include/asm/sun3_pgtable.h
+++ b/arch/m68k/include/asm/sun3_pgtable.h
@@ -169,7 +169,6 @@ static inline int pte_write(pte_t pte)		{ return pte_val(pte) & SUN3_PAGE_WRITEA
 static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & SUN3_PAGE_MODIFIED; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & SUN3_PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & SUN3_PAGE_ACCESSED; }
-static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_wrprotect(pte_t pte)	{ pte_val(pte) &= ~SUN3_PAGE_WRITEABLE; return pte; }
 static inline pte_t pte_mkclean(pte_t pte)	{ pte_val(pte) &= ~SUN3_PAGE_MODIFIED; return pte; }
@@ -182,7 +181,6 @@ static inline pte_t pte_mknocache(pte_t pte)	{ pte_val(pte) |= SUN3_PAGE_NOCACHE
 //static inline pte_t pte_mkcache(pte_t pte)	{ pte_val(pte) &= SUN3_PAGE_NOCACHE; return pte; }
 // until then, use:
 static inline pte_t pte_mkcache(pte_t pte)	{ return pte; }
-static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 extern pgd_t swapper_pg_dir[PTRS_PER_PGD];
 extern pgd_t kernel_pg_dir[PTRS_PER_PGD];
diff --git a/arch/microblaze/include/asm/pgtable.h b/arch/microblaze/include/asm/pgtable.h
index a7311cd..5ea9038 100644
--- a/arch/microblaze/include/asm/pgtable.h
+++ b/arch/microblaze/include/asm/pgtable.h
@@ -87,10 +87,6 @@ extern pte_t *va_to_pte(unsigned long address);
  * Undefined behaviour if not..
  */
 
-static inline int pte_special(pte_t pte)	{ return 0; }
-
-static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
-
 /* Start and end of the vmalloc area. */
 /* Make sure to map the vmalloc area above the pinned kernel memory area
    of 32Mb.  */
diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
index ec50d52..e58e8a6 100644
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -315,8 +315,6 @@ static inline pte_t pte_mkhuge(pte_t pte)
 }
 #endif /* _PAGE_HUGE */
 #endif
-static inline int pte_special(pte_t pte)	{ return 0; }
-static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 /*
  * Macro to make mark a page protection value as "uncacheable".  Note
diff --git a/arch/mn10300/include/asm/pgtable.h b/arch/mn10300/include/asm/pgtable.h
index a1e894b..adf3617 100644
--- a/arch/mn10300/include/asm/pgtable.h
+++ b/arch/mn10300/include/asm/pgtable.h
@@ -239,7 +239,6 @@ static inline int pte_read(pte_t pte)	{ return pte_val(pte) & __PAGE_PROT_USER;
 static inline int pte_dirty(pte_t pte)	{ return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)	{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)	{ return pte_val(pte) & __PAGE_PROT_WRITE; }
-static inline int pte_special(pte_t pte){ return 0; }
 
 /*
  * The following only works if pte_present() is not true.
@@ -281,8 +280,6 @@ static inline pte_t pte_mkwrite(pte_t pte)
 	return pte;
 }
 
-static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
-
 #define pte_ERROR(e) \
 	printk(KERN_ERR "%s:%d: bad pte %08lx.\n", \
 	       __FILE__, __LINE__, pte_val(e))
diff --git a/arch/openrisc/include/asm/pgtable.h b/arch/openrisc/include/asm/pgtable.h
index 14c900c..9a3f279 100644
--- a/arch/openrisc/include/asm/pgtable.h
+++ b/arch/openrisc/include/asm/pgtable.h
@@ -241,8 +241,6 @@ static inline int pte_exec(pte_t pte)  { return pte_val(pte) & _PAGE_EXEC; }
 static inline int pte_dirty(pte_t pte) { return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte) { return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)  { return pte_val(pte) & _PAGE_FILE; }
-static inline int pte_special(pte_t pte) { return 0; }
-static inline pte_t pte_mkspecial(pte_t pte) { return pte; }
 
 static inline pte_t pte_wrprotect(pte_t pte)
 {
diff --git a/arch/parisc/include/asm/pgtable.h b/arch/parisc/include/asm/pgtable.h
index ee99f23..8387212 100644
--- a/arch/parisc/include/asm/pgtable.h
+++ b/arch/parisc/include/asm/pgtable.h
@@ -334,7 +334,6 @@ static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_write(pte_t pte)		{ return pte_val(pte) & _PAGE_WRITE; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
-static inline int pte_special(pte_t pte)	{ return 0; }
 
 static inline pte_t pte_mkclean(pte_t pte)	{ pte_val(pte) &= ~_PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkold(pte_t pte)	{ pte_val(pte) &= ~_PAGE_ACCESSED; return pte; }
@@ -342,7 +341,6 @@ static inline pte_t pte_wrprotect(pte_t pte)	{ pte_val(pte) &= ~_PAGE_WRITE; ret
 static inline pte_t pte_mkdirty(pte_t pte)	{ pte_val(pte) |= _PAGE_DIRTY; return pte; }
 static inline pte_t pte_mkyoung(pte_t pte)	{ pte_val(pte) |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)	{ pte_val(pte) |= _PAGE_WRITE; return pte; }
-static inline pte_t pte_mkspecial(pte_t pte)	{ return pte; }
 
 /*
  * Conversion functions: convert a page and protection to a page entry,
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 5fbd13b..d2beb0b 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -143,6 +143,7 @@ config PPC
 	select MODULES_USE_ELF_RELA
 	select GENERIC_KERNEL_EXECVE
 	select CLONE_BACKWARDS
+	select HAVE_PTE_SPECIAL
 
 config EARLY_PRINTK
 	bool
diff --git a/arch/powerpc/include/asm/pte-common.h b/arch/powerpc/include/asm/pte-common.h
index 8d1569c..4f47854 100644
--- a/arch/powerpc/include/asm/pte-common.h
+++ b/arch/powerpc/include/asm/pte-common.h
@@ -181,7 +181,3 @@ extern unsigned long bad_call_to_PMD_PAGE_SIZE(void);
 /* Advertise special mapping type for AGP */
 #define PAGE_AGP		(PAGE_KERNEL_NC)
 #define HAVE_PAGE_AGP
-
-/* Advertise support for _PAGE_SPECIAL */
-#define __HAVE_ARCH_PTE_SPECIAL
-
diff --git a/arch/powerpc/mm/gup.c b/arch/powerpc/mm/gup.c
index d7efdbf..ec2b46b 100644
--- a/arch/powerpc/mm/gup.c
+++ b/arch/powerpc/mm/gup.c
@@ -14,8 +14,6 @@
 #include <linux/rwsem.h>
 #include <asm/pgtable.h>
 
-#ifdef __HAVE_ARCH_PTE_SPECIAL
-
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
@@ -194,5 +192,3 @@ slow_irqon:
 		return ret;
 	}
 }
-
-#endif /* __HAVE_ARCH_PTE_SPECIAL */
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 2c9ae86..ec2abc9 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -141,6 +141,7 @@ config S390
 	select HAVE_MOD_ARCH_SPECIFIC
 	select MODULES_USE_ELF_RELA
 	select CLONE_BACKWARDS2
+	select HAVE_PTE_SPECIAL
 
 config SCHED_OMIT_FRAME_POINTER
 	def_bool y
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index c928dc1..dcc0bcf 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -224,7 +224,6 @@ extern unsigned long MODULES_END;
 #define _PAGE_SWC	0x004		/* SW pte changed bit (for KVM) */
 #define _PAGE_SWR	0x008		/* SW pte referenced bit (for KVM) */
 #define _PAGE_SPECIAL	0x010		/* SW associated with special page */
-#define __HAVE_ARCH_PTE_SPECIAL
 
 /* Set of bits not changed in pte_modify */
 #define _PAGE_CHG_MASK	(PAGE_MASK | _PAGE_SPECIAL | _PAGE_SWC | _PAGE_SWR)
diff --git a/arch/score/include/asm/pgtable.h b/arch/score/include/asm/pgtable.h
index 2fd4698..7bfc21d 100644
--- a/arch/score/include/asm/pgtable.h
+++ b/arch/score/include/asm/pgtable.h
@@ -106,7 +106,6 @@ static inline void pmd_clear(pmd_t *pmdp)
 #define pmd_phys(pmd)		__pa((void *)pmd_val(pmd))
 #define pmd_page(pmd)		(pfn_to_page(pmd_phys(pmd) >> PAGE_SHIFT))
 #define mk_pte(page, prot)	pfn_pte(page_to_pfn(page), prot)
-static inline pte_t pte_mkspecial(pte_t pte) { return pte; }
 
 #define set_pte(pteptr, pteval) (*(pteptr) = pteval)
 #define set_pte_at(mm, addr, ptep, pteval) set_pte(ptep, pteval)
@@ -206,8 +205,6 @@ static inline int pte_file(pte_t pte)
 	return pte_val(pte) & _PAGE_FILE;
 }
 
-#define pte_special(pte)	(0)
-
 static inline pte_t pte_wrprotect(pte_t pte)
 {
 	pte_val(pte) &= ~(_PAGE_WRITE | _PAGE_SILENT_WRITE);
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 3282046..d5e89fc 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -42,6 +42,7 @@ config SUPERH
 	select MODULES_USE_ELF_RELA
 	select GENERIC_KERNEL_THREAD
 	select GENERIC_KERNEL_EXECVE
+	select HAVE_PTE_SPECIAL
 	help
 	  The SuperH is a RISC processor targeted for use in embedded systems
 	  and consumer electronics; it was also used in the Sega Dreamcast
diff --git a/arch/sh/include/asm/pgtable.h b/arch/sh/include/asm/pgtable.h
index 9210e93..25fadfa 100644
--- a/arch/sh/include/asm/pgtable.h
+++ b/arch/sh/include/asm/pgtable.h
@@ -159,8 +159,6 @@ extern void page_table_range_init(unsigned long start, unsigned long end,
 #define HAVE_ARCH_UNMAPPED_AREA
 #define HAVE_ARCH_UNMAPPED_AREA_TOPDOWN
 
-#define __HAVE_ARCH_PTE_SPECIAL
-
 #include <asm-generic/pgtable.h>
 
 #endif /* __ASM_SH_PGTABLE_H */
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 123d604..9edd70d 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -77,6 +77,7 @@ config SPARC64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select HAVE_C_RECORDMCOUNT
 	select NO_BOOTMEM
+	select HAVE_PTE_SPECIAL
 
 config ARCH_DEFCONFIG
 	string
diff --git a/arch/sparc/include/asm/pgtable_32.h b/arch/sparc/include/asm/pgtable_32.h
index 6fc1348..80fad99 100644
--- a/arch/sparc/include/asm/pgtable_32.h
+++ b/arch/sparc/include/asm/pgtable_32.h
@@ -228,11 +228,6 @@ static inline int pte_file(pte_t pte)
 	return pte_val(pte) & SRMMU_FILE;
 }
 
-static inline int pte_special(pte_t pte)
-{
-	return 0;
-}
-
 static inline pte_t pte_wrprotect(pte_t pte)
 {
 	return __pte(pte_val(pte) & ~SRMMU_WRITE);
@@ -263,8 +258,6 @@ static inline pte_t pte_mkyoung(pte_t pte)
 	return __pte(pte_val(pte) | SRMMU_REF);
 }
 
-#define pte_mkspecial(pte)    (pte)
-
 #define pfn_pte(pfn, prot)		mk_pte(pfn_to_page(pfn), prot)
 
 static inline unsigned long pte_pfn(pte_t pte)
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 95515f1..65428b1 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -115,9 +115,6 @@
 #define _PAGE_R	  	  _AC(0x8000000000000000,UL) /* Keep ref bit uptodate*/
 #define _PAGE_SPECIAL     _AC(0x0200000000000000,UL) /* Special page         */
 
-/* Advertise support for _PAGE_SPECIAL */
-#define __HAVE_ARCH_PTE_SPECIAL
-
 /* SUN4U pte bits... */
 #define _PAGE_SZ4MB_4U	  _AC(0x6000000000000000,UL) /* 4MB Page             */
 #define _PAGE_SZ512K_4U	  _AC(0x4000000000000000,UL) /* 512K Page            */
diff --git a/arch/tile/include/asm/pgtable.h b/arch/tile/include/asm/pgtable.h
index 73b1a4c..debd61c 100644
--- a/arch/tile/include/asm/pgtable.h
+++ b/arch/tile/include/asm/pgtable.h
@@ -214,9 +214,6 @@ static inline void __pte_clear(pte_t *ptep)
 #define pte_mkhuge hv_pte_set_page
 #define pte_mksuper hv_pte_set_super
 
-#define pte_special(pte) 0
-#define pte_mkspecial(pte) (pte)
-
 /*
  * Use some spare bits in the PTE for user-caching tags.
  */
diff --git a/arch/um/include/asm/pgtable.h b/arch/um/include/asm/pgtable.h
index ae02909..0cea97c 100644
--- a/arch/um/include/asm/pgtable.h
+++ b/arch/um/include/asm/pgtable.h
@@ -181,11 +181,6 @@ static inline int pte_newprot(pte_t pte)
 	return(pte_present(pte) && (pte_get_bits(pte, _PAGE_NEWPROT)));
 }
 
-static inline int pte_special(pte_t pte)
-{
-	return 0;
-}
-
 /*
  * =================================
  * Flags setting section.
@@ -254,11 +249,6 @@ static inline pte_t pte_mknewpage(pte_t pte)
 	return(pte);
 }
 
-static inline pte_t pte_mkspecial(pte_t pte)
-{
-	return(pte);
-}
-
 static inline void set_pte(pte_t *pteptr, pte_t pteval)
 {
 	pte_copy(*pteptr, pteval);
diff --git a/arch/unicore32/include/asm/pgtable.h b/arch/unicore32/include/asm/pgtable.h
index 68b2f29..3c6ff1a 100644
--- a/arch/unicore32/include/asm/pgtable.h
+++ b/arch/unicore32/include/asm/pgtable.h
@@ -179,7 +179,6 @@ extern struct page *empty_zero_page;
 #define pte_dirty(pte)		(pte_val(pte) & PTE_DIRTY)
 #define pte_young(pte)		(pte_val(pte) & PTE_YOUNG)
 #define pte_exec(pte)		(pte_val(pte) & PTE_EXEC)
-#define pte_special(pte)	(0)
 
 #define PTE_BIT_FUNC(fn, op) \
 static inline pte_t pte_##fn(pte_t pte) { pte_val(pte) op; return pte; }
@@ -191,8 +190,6 @@ PTE_BIT_FUNC(mkdirty,   |= PTE_DIRTY);
 PTE_BIT_FUNC(mkold,     &= ~PTE_YOUNG);
 PTE_BIT_FUNC(mkyoung,   |= PTE_YOUNG);
 
-static inline pte_t pte_mkspecial(pte_t pte) { return pte; }
-
 /*
  * Mark the prot value as uncacheable.
  */
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 4af6657..652996e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -114,6 +114,7 @@ config X86
 	select MODULES_USE_ELF_REL if X86_32
 	select MODULES_USE_ELF_RELA if X86_64
 	select CLONE_BACKWARDS if X86_32
+	select HAVE_PTE_SPECIAL
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index ec8a1fc..5ec4e02 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -47,7 +47,6 @@
 #define _PAGE_SPECIAL	(_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
 #define _PAGE_CPA_TEST	(_AT(pteval_t, 1) << _PAGE_BIT_CPA_TEST)
 #define _PAGE_SPLITTING	(_AT(pteval_t, 1) << _PAGE_BIT_SPLITTING)
-#define __HAVE_ARCH_PTE_SPECIAL
 
 #ifdef CONFIG_KMEMCHECK
 #define _PAGE_HIDDEN	(_AT(pteval_t, 1) << _PAGE_BIT_HIDDEN)
diff --git a/arch/xtensa/include/asm/pgtable.h b/arch/xtensa/include/asm/pgtable.h
index b03c043..e0c243e 100644
--- a/arch/xtensa/include/asm/pgtable.h
+++ b/arch/xtensa/include/asm/pgtable.h
@@ -218,7 +218,6 @@ static inline int pte_write(pte_t pte) { return pte_val(pte) & _PAGE_WRITABLE; }
 static inline int pte_dirty(pte_t pte) { return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte) { return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)  { return pte_val(pte) & _PAGE_FILE; }
-static inline int pte_special(pte_t pte) { return 0; }
 
 static inline pte_t pte_wrprotect(pte_t pte)	
 	{ pte_val(pte) &= ~(_PAGE_WRITABLE | _PAGE_HW_WRITE); return pte; }
@@ -232,8 +231,6 @@ static inline pte_t pte_mkyoung(pte_t pte)
 	{ pte_val(pte) |= _PAGE_ACCESSED; return pte; }
 static inline pte_t pte_mkwrite(pte_t pte)
 	{ pte_val(pte) |= _PAGE_WRITABLE; return pte; }
-static inline pte_t pte_mkspecial(pte_t pte)
-	{ return pte; }
 
 /*
  * Conversion functions: convert a page and protection to a page entry,
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 04a398e..1e1de80 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -479,6 +479,18 @@ static inline unsigned long my_zero_pfn(unsigned long addr)
 }
 #endif
 
+#ifndef CONFIG_HAVE_PTE_SPECIAL
+static inline pte_t pte_mkspecial(pte_t pte)
+{
+       return pte;
+}
+
+static inline int pte_special(pte_t pte)
+{
+       return 0;
+}
+#endif
+
 #ifdef CONFIG_MMU
 
 #ifndef CONFIG_TRANSPARENT_HUGEPAGE
diff --git a/mm/memory.c b/mm/memory.c
index efd870d..847789f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -767,17 +767,12 @@ static inline bool is_cow_mapping(vm_flags_t flags)
  * PFNMAP mappings in order to support COWable mappings.
  *
  */
-#ifdef __HAVE_ARCH_PTE_SPECIAL
-# define HAVE_PTE_SPECIAL 1
-#else
-# define HAVE_PTE_SPECIAL 0
-#endif
 struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 				pte_t pte)
 {
 	unsigned long pfn = pte_pfn(pte);
 
-	if (HAVE_PTE_SPECIAL) {
+	if (IS_ENABLED(CONFIG_HAVE_PTE_SPECIAL)) {
 		if (likely(!pte_special(pte)))
 			goto check_pfn;
 		if (vma->vm_flags & (VM_PFNMAP | VM_MIXEDMAP))
@@ -787,7 +782,7 @@ struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
 		return NULL;
 	}
 
-	/* !HAVE_PTE_SPECIAL case follows: */
+	/* !CONFIG_HAVE_PTE_SPECIAL case follows: */
 
 	if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
 		if (vma->vm_flags & VM_MIXEDMAP) {
@@ -2213,7 +2208,7 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 	 * than insert_pfn).  If a zero_pfn were inserted into a VM_MIXEDMAP
 	 * without pte special, it would there be refcounted as a normal page.
 	 */
-	if (!HAVE_PTE_SPECIAL && pfn_valid(pfn)) {
+	if (!IS_ENABLED(CONFIG_HAVE_PTE_SPECIAL) && pfn_valid(pfn)) {
 		struct page *page;
 
 		page = pfn_to_page(pfn);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
