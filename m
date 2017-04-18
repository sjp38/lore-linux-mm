Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 023EA2806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:18:03 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id e53so1309283qte.17
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:18:02 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0043.outbound.protection.outlook.com. [104.47.33.43])
        by mx.google.com with ESMTPS id q3si326476qtc.75.2017.04.18.14.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:18:01 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 09/32] x86/mm: Provide general kernel support for memory
 encryption
Date: Tue, 18 Apr 2017 16:17:54 -0500
Message-ID: <20170418211754.10190.25082.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Changes to the existing page table macros will allow the SME support to
be enabled in a simple fashion with minimal changes to files that use these
macros.  Since the memory encryption mask will now be part of the regular
pagetable macros, we introduce two new macros (_PAGE_TABLE_NOENC and
_KERNPG_TABLE_NOENC) to allow for early pagetable creation/initialization
without the encryption mask before SME becomes active.  Two new pgprot()
macros are defined to allow setting or clearing the page encryption mask.

The FIXMAP_PAGE_NOCACHE define is introduced for use with MMIO.  SME does
not support encryption for MMIO areas so this define removes the encryption
mask from the page attribute.

Two new macros are introduced (__sme_pa() / __sme_pa_nodebug()) to allow
creating a physical address with the encryption mask.  These are used when
working with the cr3 register so that the PGD can be encrypted. The current
__va() macro is updated so that the virtual address is generated based off
of the physical address without the encryption mask thus allowing the same
virtual address to be generated regardless of whether encryption is enabled
for that physical location or not.

Also, an early initialization function is added for SME.  If SME is active,
this function:
 - Updates the early_pmd_flags so that early page faults create mappings
   with the encryption mask.
 - Updates the __supported_pte_mask to include the encryption mask.
 - Updates the protection_map entries to include the encryption mask so
   that user-space allocations will automatically have the encryption mask
   applied.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/boot/compressed/pagetable.c |    7 +++++
 arch/x86/include/asm/fixmap.h        |    7 +++++
 arch/x86/include/asm/mem_encrypt.h   |   25 +++++++++++++++++++
 arch/x86/include/asm/page.h          |    4 ++-
 arch/x86/include/asm/page_types.h    |    2 +-
 arch/x86/include/asm/pgtable.h       |    9 +++++++
 arch/x86/include/asm/pgtable_types.h |   45 ++++++++++++++++++++++------------
 arch/x86/include/asm/processor.h     |    3 ++
 arch/x86/kernel/espfix_64.c          |    2 +-
 arch/x86/kernel/head64.c             |   12 ++++++++-
 arch/x86/kernel/head_64.S            |   18 +++++++-------
 arch/x86/mm/kasan_init_64.c          |    4 ++-
 arch/x86/mm/mem_encrypt.c            |   18 ++++++++++++++
 arch/x86/mm/pageattr.c               |    3 ++
 include/asm-generic/pgtable.h        |    8 ++++++
 15 files changed, 134 insertions(+), 33 deletions(-)

diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
index 56589d0..411c443 100644
--- a/arch/x86/boot/compressed/pagetable.c
+++ b/arch/x86/boot/compressed/pagetable.c
@@ -15,6 +15,13 @@
 #define __pa(x)  ((unsigned long)(x))
 #define __va(x)  ((void *)((unsigned long)(x)))
 
+/*
+ * The pgtable.h and mm/ident_map.c includes make use of the SME related
+ * information which is not used in the compressed image support. Un-define
+ * the SME support to avoid any compile and link errors.
+ */
+#undef CONFIG_AMD_MEM_ENCRYPT
+
 #include "misc.h"
 
 /* These actually do the work of building the kernel identity maps. */
diff --git a/arch/x86/include/asm/fixmap.h b/arch/x86/include/asm/fixmap.h
index b65155c..d9ff226 100644
--- a/arch/x86/include/asm/fixmap.h
+++ b/arch/x86/include/asm/fixmap.h
@@ -157,6 +157,13 @@ static inline void __set_fixmap(enum fixed_addresses idx,
 }
 #endif
 
+/*
+ * FIXMAP_PAGE_NOCACHE is used for MMIO. Memory encryption is not
+ * supported for MMIO addresses, so make sure that the memory encryption
+ * mask is not part of the page attributes.
+ */
+#define FIXMAP_PAGE_NOCACHE PAGE_KERNEL_IO_NOCACHE
+
 #include <asm-generic/fixmap.h>
 
 #define __late_set_fixmap(idx, phys, flags) __set_fixmap(idx, phys, flags)
diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index d5c4a2b..9fdbc53 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -15,6 +15,8 @@
 
 #ifndef __ASSEMBLY__
 
+#include <linux/init.h>
+
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
 extern unsigned long sme_me_mask;
@@ -24,6 +26,8 @@ static inline bool sme_active(void)
 	return !!sme_me_mask;
 }
 
+void __init sme_early_init(void);
+
 #else	/* !CONFIG_AMD_MEM_ENCRYPT */
 
 #ifndef sme_me_mask
@@ -35,8 +39,29 @@ static inline bool sme_active(void)
 }
 #endif
 
+static inline void __init sme_early_init(void)
+{
+}
+
 #endif	/* CONFIG_AMD_MEM_ENCRYPT */
 
+/*
+ * The __sme_pa() and __sme_pa_nodebug() macros are meant for use when
+ * writing to or comparing values from the cr3 register.  Having the
+ * encryption mask set in cr3 enables the PGD entry to be encrypted and
+ * avoid special case handling of PGD allocations.
+ */
+#define __sme_pa(x)		(__pa(x) | sme_me_mask)
+#define __sme_pa_nodebug(x)	(__pa_nodebug(x) | sme_me_mask)
+
+/*
+ * The __sme_set() and __sme_clr() macros are useful for adding or removing
+ * the encryption mask from a value (e.g. when dealing with pagetable
+ * entries).
+ */
+#define __sme_set(x)		((unsigned long)(x) | sme_me_mask)
+#define __sme_clr(x)		((unsigned long)(x) & ~sme_me_mask)
+
 #endif	/* __ASSEMBLY__ */
 
 #endif	/* __X86_MEM_ENCRYPT_H__ */
diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index cf8f619..b54dba7 100644
--- a/arch/x86/include/asm/page.h
+++ b/arch/x86/include/asm/page.h
@@ -15,6 +15,8 @@
 
 #ifndef __ASSEMBLY__
 
+#include <asm/mem_encrypt.h>
+
 struct page;
 
 #include <linux/range.h>
@@ -55,7 +57,7 @@ static inline void copy_user_page(void *to, void *from, unsigned long vaddr,
 	__phys_addr_symbol(__phys_reloc_hide((unsigned long)(x)))
 
 #ifndef __va
-#define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
+#define __va(x)			((void *)(__sme_clr(x) + PAGE_OFFSET))
 #endif
 
 #define __boot_va(x)		__va(x)
diff --git a/arch/x86/include/asm/page_types.h b/arch/x86/include/asm/page_types.h
index 7bd0099..fead0a5 100644
--- a/arch/x86/include/asm/page_types.h
+++ b/arch/x86/include/asm/page_types.h
@@ -15,7 +15,7 @@
 #define PUD_PAGE_SIZE		(_AC(1, UL) << PUD_SHIFT)
 #define PUD_PAGE_MASK		(~(PUD_PAGE_SIZE-1))
 
-#define __PHYSICAL_MASK		((phys_addr_t)((1ULL << __PHYSICAL_MASK_SHIFT) - 1))
+#define __PHYSICAL_MASK		((phys_addr_t)(__sme_clr((1ULL << __PHYSICAL_MASK_SHIFT) - 1)))
 #define __VIRTUAL_MASK		((1UL << __VIRTUAL_MASK_SHIFT) - 1)
 
 /* Cast *PAGE_MASK to a signed type so that it is sign-extended if
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 42b7193..1f9a2c4 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -3,6 +3,7 @@
 
 #include <asm/page.h>
 #include <asm/pgtable_types.h>
+#include <asm/mem_encrypt.h>
 
 /*
  * Macro to mark a page protection value as UC-
@@ -13,6 +14,12 @@
 		     cachemode2protval(_PAGE_CACHE_MODE_UC_MINUS)))	\
 	 : (prot))
 
+/*
+ * Macros to add or remove encryption attribute
+ */
+#define pgprot_encrypted(prot)	__pgprot(__sme_set(pgprot_val(prot)))
+#define pgprot_decrypted(prot)	__pgprot(__sme_clr(pgprot_val(prot)))
+
 #ifndef __ASSEMBLY__
 #include <asm/x86_init.h>
 
@@ -38,6 +45,8 @@
 
 extern struct mm_struct *pgd_page_get_mm(struct page *page);
 
+extern pmdval_t early_pmd_flags;
+
 #ifdef CONFIG_PARAVIRT
 #include <asm/paravirt.h>
 #else  /* !CONFIG_PARAVIRT */
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index bf9638e..d3ae99c 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -2,7 +2,9 @@
 #define _ASM_X86_PGTABLE_DEFS_H
 
 #include <linux/const.h>
+
 #include <asm/page_types.h>
+#include <asm/mem_encrypt.h>
 
 #define FIRST_USER_ADDRESS	0UL
 
@@ -121,10 +123,10 @@
 
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
-#define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
-			 _PAGE_ACCESSED | _PAGE_DIRTY)
-#define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\
-			 _PAGE_DIRTY)
+#define _PAGE_TABLE_NOENC	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |\
+				 _PAGE_ACCESSED | _PAGE_DIRTY)
+#define _KERNPG_TABLE_NOENC	(_PAGE_PRESENT | _PAGE_RW |		\
+				 _PAGE_ACCESSED | _PAGE_DIRTY)
 
 /*
  * Set of bits not changed in pte_modify.  The pte's
@@ -191,18 +193,29 @@ enum page_cache_mode {
 #define __PAGE_KERNEL_IO		(__PAGE_KERNEL)
 #define __PAGE_KERNEL_IO_NOCACHE	(__PAGE_KERNEL_NOCACHE)
 
-#define PAGE_KERNEL			__pgprot(__PAGE_KERNEL)
-#define PAGE_KERNEL_RO			__pgprot(__PAGE_KERNEL_RO)
-#define PAGE_KERNEL_EXEC		__pgprot(__PAGE_KERNEL_EXEC)
-#define PAGE_KERNEL_RX			__pgprot(__PAGE_KERNEL_RX)
-#define PAGE_KERNEL_NOCACHE		__pgprot(__PAGE_KERNEL_NOCACHE)
-#define PAGE_KERNEL_LARGE		__pgprot(__PAGE_KERNEL_LARGE)
-#define PAGE_KERNEL_LARGE_EXEC		__pgprot(__PAGE_KERNEL_LARGE_EXEC)
-#define PAGE_KERNEL_VSYSCALL		__pgprot(__PAGE_KERNEL_VSYSCALL)
-#define PAGE_KERNEL_VVAR		__pgprot(__PAGE_KERNEL_VVAR)
-
-#define PAGE_KERNEL_IO			__pgprot(__PAGE_KERNEL_IO)
-#define PAGE_KERNEL_IO_NOCACHE		__pgprot(__PAGE_KERNEL_IO_NOCACHE)
+#ifndef __ASSEMBLY__
+
+#define _PAGE_ENC	(_AT(pteval_t, sme_me_mask))
+
+#define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
+			 _PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_ENC)
+#define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\
+			 _PAGE_DIRTY | _PAGE_ENC)
+
+#define PAGE_KERNEL		__pgprot(__PAGE_KERNEL | _PAGE_ENC)
+#define PAGE_KERNEL_RO		__pgprot(__PAGE_KERNEL_RO | _PAGE_ENC)
+#define PAGE_KERNEL_EXEC	__pgprot(__PAGE_KERNEL_EXEC | _PAGE_ENC)
+#define PAGE_KERNEL_RX		__pgprot(__PAGE_KERNEL_RX | _PAGE_ENC)
+#define PAGE_KERNEL_NOCACHE	__pgprot(__PAGE_KERNEL_NOCACHE | _PAGE_ENC)
+#define PAGE_KERNEL_LARGE	__pgprot(__PAGE_KERNEL_LARGE | _PAGE_ENC)
+#define PAGE_KERNEL_LARGE_EXEC	__pgprot(__PAGE_KERNEL_LARGE_EXEC | _PAGE_ENC)
+#define PAGE_KERNEL_VSYSCALL	__pgprot(__PAGE_KERNEL_VSYSCALL | _PAGE_ENC)
+#define PAGE_KERNEL_VVAR	__pgprot(__PAGE_KERNEL_VVAR | _PAGE_ENC)
+
+#define PAGE_KERNEL_IO		__pgprot(__PAGE_KERNEL_IO)
+#define PAGE_KERNEL_IO_NOCACHE	__pgprot(__PAGE_KERNEL_IO_NOCACHE)
+
+#endif	/* __ASSEMBLY__ */
 
 /*         xwr */
 #define __P000	PAGE_NONE
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 3cada99..61e055d 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -22,6 +22,7 @@
 #include <asm/nops.h>
 #include <asm/special_insns.h>
 #include <asm/fpu/types.h>
+#include <asm/mem_encrypt.h>
 
 #include <linux/personality.h>
 #include <linux/cache.h>
@@ -233,7 +234,7 @@ static inline void native_cpuid(unsigned int *eax, unsigned int *ebx,
 
 static inline void load_cr3(pgd_t *pgdir)
 {
-	write_cr3(__pa(pgdir));
+	write_cr3(__sme_pa(pgdir));
 }
 
 #ifdef CONFIG_X86_32
diff --git a/arch/x86/kernel/espfix_64.c b/arch/x86/kernel/espfix_64.c
index 8e598a1..0955ec7 100644
--- a/arch/x86/kernel/espfix_64.c
+++ b/arch/x86/kernel/espfix_64.c
@@ -195,7 +195,7 @@ void init_espfix_ap(int cpu)
 
 	pte_p = pte_offset_kernel(&pmd, addr);
 	stack_page = page_address(alloc_pages_node(node, GFP_KERNEL, 0));
-	pte = __pte(__pa(stack_page) | (__PAGE_KERNEL_RO & ptemask));
+	pte = __pte(__pa(stack_page) | ((__PAGE_KERNEL_RO | _PAGE_ENC) & ptemask));
 	for (n = 0; n < ESPFIX_PTE_CLONES; n++)
 		set_pte(&pte_p[n*PTE_STRIDE], pte);
 
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 43b7002..9056cf9 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -29,6 +29,7 @@
 #include <asm/bootparam_utils.h>
 #include <asm/microcode.h>
 #include <asm/kasan.h>
+#include <asm/mem_encrypt.h>
 
 /*
  * Manage page tables very early on.
@@ -43,7 +44,7 @@ static void __init reset_early_page_tables(void)
 {
 	memset(early_level4_pgt, 0, sizeof(pgd_t)*(PTRS_PER_PGD-1));
 	next_early_pgt = 0;
-	write_cr3(__pa_nodebug(early_level4_pgt));
+	write_cr3(__sme_pa_nodebug(early_level4_pgt));
 }
 
 /* Create a new PMD entry */
@@ -55,7 +56,7 @@ int __init early_make_pgtable(unsigned long address)
 	pmdval_t pmd, *pmd_p;
 
 	/* Invalid address or early pgt is done ?  */
-	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_level4_pgt))
+	if (physaddr >= MAXMEM || read_cr3() != __sme_pa_nodebug(early_level4_pgt))
 		return -1;
 
 again:
@@ -158,6 +159,13 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 
 	clear_page(init_level4_pgt);
 
+	/*
+	 * SME support may update early_pmd_flags to include the memory
+	 * encryption mask, so it needs to be called before anything
+	 * that may generate a page fault.
+	 */
+	sme_early_init();
+
 	kasan_early_init();
 
 	for (i = 0; i < NUM_EXCEPTION_VECTORS; i++)
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 3115e21..abfe5ee 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -129,7 +129,7 @@ startup_64:
 	movq	%rdi, %rax
 	shrq	$PGDIR_SHIFT, %rax
 
-	leaq	(PAGE_SIZE + _KERNPG_TABLE)(%rbx), %rdx
+	leaq	(PAGE_SIZE + _KERNPG_TABLE_NOENC)(%rbx), %rdx
 	addq	%r12, %rdx
 	movq	%rdx, 0(%rbx,%rax,8)
 	movq	%rdx, 8(%rbx,%rax,8)
@@ -476,7 +476,7 @@ GLOBAL(name)
 	__INITDATA
 NEXT_PAGE(early_level4_pgt)
 	.fill	511,8,0
-	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
+	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
 
 NEXT_PAGE(early_dynamic_pgts)
 	.fill	512*EARLY_DYNAMIC_PAGE_TABLES,8,0
@@ -488,15 +488,15 @@ NEXT_PAGE(init_level4_pgt)
 	.fill	512,8,0
 #else
 NEXT_PAGE(init_level4_pgt)
-	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
+	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
 	.org    init_level4_pgt + L4_PAGE_OFFSET*8, 0
-	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
+	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
 	.org    init_level4_pgt + L4_START_KERNEL*8, 0
 	/* (2^48-(2*1024*1024*1024))/(2^39) = 511 */
-	.quad   level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
+	.quad   level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
 
 NEXT_PAGE(level3_ident_pgt)
-	.quad	level2_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
+	.quad	level2_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
 	.fill	511, 8, 0
 NEXT_PAGE(level2_ident_pgt)
 	/* Since I easily can, map the first 1G.
@@ -508,8 +508,8 @@ NEXT_PAGE(level2_ident_pgt)
 NEXT_PAGE(level3_kernel_pgt)
 	.fill	L3_START_KERNEL,8,0
 	/* (2^48-(2*1024*1024*1024)-((2^39)*511))/(2^30) = 510 */
-	.quad	level2_kernel_pgt - __START_KERNEL_map + _KERNPG_TABLE
-	.quad	level2_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE
+	.quad	level2_kernel_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
+	.quad	level2_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
 
 NEXT_PAGE(level2_kernel_pgt)
 	/*
@@ -527,7 +527,7 @@ NEXT_PAGE(level2_kernel_pgt)
 
 NEXT_PAGE(level2_fixmap_pgt)
 	.fill	506,8,0
-	.quad	level1_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE
+	.quad	level1_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
 	/* 8MB reserved for vsyscalls + a 2MB hole = 4 + 1 entries */
 	.fill	5,8,0
 
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 0c7d812..6f1837a 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -92,7 +92,7 @@ static int kasan_die_handler(struct notifier_block *self,
 void __init kasan_early_init(void)
 {
 	int i;
-	pteval_t pte_val = __pa_nodebug(kasan_zero_page) | __PAGE_KERNEL;
+	pteval_t pte_val = __pa_nodebug(kasan_zero_page) | __PAGE_KERNEL | _PAGE_ENC;
 	pmdval_t pmd_val = __pa_nodebug(kasan_zero_pte) | _KERNPG_TABLE;
 	pudval_t pud_val = __pa_nodebug(kasan_zero_pmd) | _KERNPG_TABLE;
 	p4dval_t p4d_val = __pa_nodebug(kasan_zero_pud) | _KERNPG_TABLE;
@@ -158,7 +158,7 @@ void __init kasan_init(void)
 	 */
 	memset(kasan_zero_page, 0, PAGE_SIZE);
 	for (i = 0; i < PTRS_PER_PTE; i++) {
-		pte_t pte = __pte(__pa(kasan_zero_page) | __PAGE_KERNEL_RO);
+		pte_t pte = __pte(__pa(kasan_zero_page) | __PAGE_KERNEL_RO | _PAGE_ENC);
 		set_pte(&kasan_zero_pte[i], pte);
 	}
 	/* Flush TLBs again to be sure that write protection applied. */
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index cc00d8b..8ca93e5 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -15,6 +15,8 @@
 
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
+#include <linux/mm.h>
+
 /*
  * Since SME related variables are set early in the boot process they must
  * reside in the .data section so as not to be zeroed out when the .bss
@@ -23,6 +25,22 @@
 unsigned long sme_me_mask __section(.data) = 0;
 EXPORT_SYMBOL_GPL(sme_me_mask);
 
+void __init sme_early_init(void)
+{
+	unsigned int i;
+
+	if (!sme_me_mask)
+		return;
+
+	early_pmd_flags = __sme_set(early_pmd_flags);
+
+	__supported_pte_mask = __sme_set(__supported_pte_mask);
+
+	/* Update the protection map with memory encryption mask */
+	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
+		protection_map[i] = pgprot_encrypted(protection_map[i]);
+}
+
 void __init sme_encrypt_kernel(void)
 {
 }
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 56b22fa..669fa48 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -2013,6 +2013,9 @@ int kernel_map_pages_in_pgd(pgd_t *pgd, u64 pfn, unsigned long address,
 	if (!(page_flags & _PAGE_RW))
 		cpa.mask_clr = __pgprot(_PAGE_RW);
 
+	if (!(page_flags & _PAGE_ENC))
+		cpa.mask_clr = pgprot_encrypted(cpa.mask_clr);
+
 	cpa.mask_set = __pgprot(_PAGE_PRESENT | page_flags);
 
 	retval = __change_page_attr_set_clr(&cpa, 0);
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 7dfa767..882cb5d 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -424,6 +424,14 @@ static inline int pud_same(pud_t pud_a, pud_t pud_b)
 #define pgprot_device pgprot_noncached
 #endif
 
+#ifndef pgprot_encrypted
+#define pgprot_encrypted(prot)	(prot)
+#endif
+
+#ifndef pgprot_decrypted
+#define pgprot_decrypted(prot)	(prot)
+#endif
+
 #ifndef pgprot_modify
 #define pgprot_modify pgprot_modify
 static inline pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
