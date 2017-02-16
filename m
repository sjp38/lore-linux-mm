Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51C2B680FF1
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 10:43:45 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id u143so21402770oif.1
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 07:43:45 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0064.outbound.protection.outlook.com. [104.47.32.64])
        by mx.google.com with ESMTPS id b16si3458669otd.242.2017.02.16.07.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 16 Feb 2017 07:43:44 -0800 (PST)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v4 07/28] x86: Provide general kernel support for memory
 encryption
Date: Thu, 16 Feb 2017 09:43:32 -0600
Message-ID: <20170216154332.19244.55451.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
References: <20170216154158.19244.66630.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Larry Woodman <lwoodman@redhat.com>, Dmitry Vyukov <dvyukov@google.com>

Adding general kernel support for memory encryption includes:
- Modify and create some page table macros to include the Secure Memory
  Encryption (SME) memory encryption mask
- Modify and create some macros for calculating physical and virtual
  memory addresses
- Provide an SME initialization routine to update the protection map with
  the memory encryption mask so that it is used by default
- #undef CONFIG_AMD_MEM_ENCRYPT in the compressed boot path

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/boot/compressed/pagetable.c |    7 +++++
 arch/x86/include/asm/fixmap.h        |    7 +++++
 arch/x86/include/asm/mem_encrypt.h   |   14 +++++++++++
 arch/x86/include/asm/page.h          |    4 ++-
 arch/x86/include/asm/pgtable.h       |   26 ++++++++++++++------
 arch/x86/include/asm/pgtable_types.h |   45 ++++++++++++++++++++++------------
 arch/x86/include/asm/processor.h     |    3 ++
 arch/x86/kernel/espfix_64.c          |    2 +-
 arch/x86/kernel/head64.c             |   12 ++++++++-
 arch/x86/kernel/head_64.S            |   18 +++++++-------
 arch/x86/mm/kasan_init_64.c          |    4 ++-
 arch/x86/mm/mem_encrypt.c            |   20 +++++++++++++++
 arch/x86/mm/pageattr.c               |    3 ++
 include/asm-generic/pgtable.h        |    8 ++++++
 14 files changed, 133 insertions(+), 40 deletions(-)

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
index 8554f96..83e91f0 100644
--- a/arch/x86/include/asm/fixmap.h
+++ b/arch/x86/include/asm/fixmap.h
@@ -153,6 +153,13 @@ static inline void __set_fixmap(enum fixed_addresses idx,
 }
 #endif
 
+/*
+ * Fixmap settings used with memory encryption
+ *   - FIXMAP_PAGE_NOCACHE is used for MMIO so make sure the memory
+ *     encryption mask is not part of the page attributes
+ */
+#define FIXMAP_PAGE_NOCACHE PAGE_KERNEL_IO_NOCACHE
+
 #include <asm-generic/fixmap.h>
 
 #define __late_set_fixmap(idx, phys, flags) __set_fixmap(idx, phys, flags)
diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index ccc53b0..547989d 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -15,6 +15,8 @@
 
 #ifndef __ASSEMBLY__
 
+#include <linux/init.h>
+
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
 extern unsigned long sme_me_mask;
@@ -24,6 +26,11 @@ static inline bool sme_active(void)
 	return (sme_me_mask) ? true : false;
 }
 
+void __init sme_early_init(void);
+
+#define __sme_pa(x)		(__pa((x)) | sme_me_mask)
+#define __sme_pa_nodebug(x)	(__pa_nodebug((x)) | sme_me_mask)
+
 #else	/* !CONFIG_AMD_MEM_ENCRYPT */
 
 #ifndef sme_me_mask
@@ -35,6 +42,13 @@ static inline bool sme_active(void)
 }
 #endif
 
+static inline void __init sme_early_init(void)
+{
+}
+
+#define __sme_pa		__pa
+#define __sme_pa_nodebug	__pa_nodebug
+
 #endif	/* CONFIG_AMD_MEM_ENCRYPT */
 
 #endif	/* __ASSEMBLY__ */
diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index cf8f619..b1f7bf6 100644
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
+#define __va(x)			((void *)(((unsigned long)(x) & ~sme_me_mask) + PAGE_OFFSET))
 #endif
 
 #define __boot_va(x)		__va(x)
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 2d81161..b41caab 100644
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
+#define pgprot_encrypted(prot)	__pgprot(pgprot_val(prot) | sme_me_mask)
+#define pgprot_decrypted(prot)	__pgprot(pgprot_val(prot) & ~sme_me_mask)
+
 #ifndef __ASSEMBLY__
 #include <asm/x86_init.h>
 
@@ -153,17 +160,22 @@ static inline int pte_special(pte_t pte)
 
 static inline unsigned long pte_pfn(pte_t pte)
 {
-	return (pte_val(pte) & PTE_PFN_MASK) >> PAGE_SHIFT;
+	return (pte_val(pte) & ~sme_me_mask & PTE_PFN_MASK) >> PAGE_SHIFT;
 }
 
 static inline unsigned long pmd_pfn(pmd_t pmd)
 {
-	return (pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT;
+	return (pmd_val(pmd) & ~sme_me_mask & pmd_pfn_mask(pmd)) >> PAGE_SHIFT;
 }
 
 static inline unsigned long pud_pfn(pud_t pud)
 {
-	return (pud_val(pud) & pud_pfn_mask(pud)) >> PAGE_SHIFT;
+	return (pud_val(pud) & ~sme_me_mask & pud_pfn_mask(pud)) >> PAGE_SHIFT;
+}
+
+static inline unsigned long pgd_pfn(pgd_t pgd)
+{
+	return (pgd_val(pgd) & ~sme_me_mask) >> PAGE_SHIFT;
 }
 
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
@@ -563,8 +575,7 @@ static inline unsigned long pmd_page_vaddr(pmd_t pmd)
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pmd_page(pmd)		\
-	pfn_to_page((pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT)
+#define pmd_page(pmd)	pfn_to_page(pmd_pfn(pmd))
 
 /*
  * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
@@ -632,8 +643,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pud_page(pud)		\
-	pfn_to_page((pud_val(pud) & pud_pfn_mask(pud)) >> PAGE_SHIFT)
+#define pud_page(pud)	pfn_to_page(pud_pfn(pud))
 
 /* Find an entry in the second-level page table.. */
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
@@ -673,7 +683,7 @@ static inline unsigned long pgd_page_vaddr(pgd_t pgd)
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pgd_page(pgd)		pfn_to_page(pgd_val(pgd) >> PAGE_SHIFT)
+#define pgd_page(pgd)	pfn_to_page(pgd_pfn(pgd))
 
 /* to find an entry in a page-table-directory. */
 static inline unsigned long pud_index(unsigned long address)
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 8b4de22..500fc60 100644
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
index e6cfe7b..86da9a4 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -22,6 +22,7 @@
 #include <asm/nops.h>
 #include <asm/special_insns.h>
 #include <asm/fpu/types.h>
+#include <asm/mem_encrypt.h>
 
 #include <linux/personality.h>
 #include <linux/cache.h>
@@ -240,7 +241,7 @@ static inline void native_cpuid(unsigned int *eax, unsigned int *ebx,
 
 static inline void load_cr3(pgd_t *pgdir)
 {
-	write_cr3(__pa(pgdir));
+	write_cr3(__sme_pa(pgdir));
 }
 
 #ifdef CONFIG_X86_32
diff --git a/arch/x86/kernel/espfix_64.c b/arch/x86/kernel/espfix_64.c
index 04f89ca..51566d7 100644
--- a/arch/x86/kernel/espfix_64.c
+++ b/arch/x86/kernel/espfix_64.c
@@ -193,7 +193,7 @@ void init_espfix_ap(int cpu)
 
 	pte_p = pte_offset_kernel(&pmd, addr);
 	stack_page = page_address(alloc_pages_node(node, GFP_KERNEL, 0));
-	pte = __pte(__pa(stack_page) | (__PAGE_KERNEL_RO & ptemask));
+	pte = __pte(__pa(stack_page) | ((__PAGE_KERNEL_RO | _PAGE_ENC) & ptemask));
 	for (n = 0; n < ESPFIX_PTE_CLONES; n++)
 		set_pte(&pte_p[n*PTE_STRIDE], pte);
 
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index baa0e7b..182a4c7 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -28,6 +28,7 @@
 #include <asm/bootparam_utils.h>
 #include <asm/microcode.h>
 #include <asm/kasan.h>
+#include <asm/mem_encrypt.h>
 
 /*
  * Manage page tables very early on.
@@ -42,7 +43,7 @@ static void __init reset_early_page_tables(void)
 {
 	memset(early_level4_pgt, 0, sizeof(pgd_t)*(PTRS_PER_PGD-1));
 	next_early_pgt = 0;
-	write_cr3(__pa_nodebug(early_level4_pgt));
+	write_cr3(__sme_pa_nodebug(early_level4_pgt));
 }
 
 /* Create a new PMD entry */
@@ -54,7 +55,7 @@ int __init early_make_pgtable(unsigned long address)
 	pmdval_t pmd, *pmd_p;
 
 	/* Invalid address or early pgt is done ?  */
-	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_level4_pgt))
+	if (physaddr >= MAXMEM || read_cr3() != __sme_pa_nodebug(early_level4_pgt))
 		return -1;
 
 again:
@@ -157,6 +158,13 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 
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
index 4f8201b..edd2f14 100644
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
@@ -463,7 +463,7 @@ GLOBAL(name)
 	__INITDATA
 NEXT_PAGE(early_level4_pgt)
 	.fill	511,8,0
-	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
+	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
 
 NEXT_PAGE(early_dynamic_pgts)
 	.fill	512*EARLY_DYNAMIC_PAGE_TABLES,8,0
@@ -475,15 +475,15 @@ NEXT_PAGE(init_level4_pgt)
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
@@ -495,8 +495,8 @@ NEXT_PAGE(level2_ident_pgt)
 NEXT_PAGE(level3_kernel_pgt)
 	.fill	L3_START_KERNEL,8,0
 	/* (2^48-(2*1024*1024*1024)-((2^39)*511))/(2^30) = 510 */
-	.quad	level2_kernel_pgt - __START_KERNEL_map + _KERNPG_TABLE
-	.quad	level2_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE
+	.quad	level2_kernel_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
+	.quad	level2_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
 
 NEXT_PAGE(level2_kernel_pgt)
 	/*
@@ -514,7 +514,7 @@ NEXT_PAGE(level2_kernel_pgt)
 
 NEXT_PAGE(level2_fixmap_pgt)
 	.fill	506,8,0
-	.quad	level1_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE
+	.quad	level1_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
 	/* 8MB reserved for vsyscalls + a 2MB hole = 4 + 1 entries */
 	.fill	5,8,0
 
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 66d2017..072a70a 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -70,7 +70,7 @@ static int kasan_die_handler(struct notifier_block *self,
 void __init kasan_early_init(void)
 {
 	int i;
-	pteval_t pte_val = __pa_nodebug(kasan_zero_page) | __PAGE_KERNEL;
+	pteval_t pte_val = __pa_nodebug(kasan_zero_page) | __PAGE_KERNEL | _PAGE_ENC;
 	pmdval_t pmd_val = __pa_nodebug(kasan_zero_pte) | _KERNPG_TABLE;
 	pudval_t pud_val = __pa_nodebug(kasan_zero_pmd) | _KERNPG_TABLE;
 
@@ -132,7 +132,7 @@ void __init kasan_init(void)
 	 */
 	memset(kasan_zero_page, 0, PAGE_SIZE);
 	for (i = 0; i < PTRS_PER_PTE; i++) {
-		pte_t pte = __pte(__pa(kasan_zero_page) | __PAGE_KERNEL_RO);
+		pte_t pte = __pte(__pa(kasan_zero_page) | __PAGE_KERNEL_RO | _PAGE_ENC);
 		set_pte(&kasan_zero_pte[i], pte);
 	}
 	/* Flush TLBs again to be sure that write protection applied. */
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index b99d469..d71df97 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -11,6 +11,10 @@
  */
 
 #include <linux/linkage.h>
+#include <linux/init.h>
+#include <linux/mm.h>
+
+extern pmdval_t early_pmd_flags;
 
 /*
  * Since SME related variables are set early in the boot process they must
@@ -19,3 +23,19 @@
  */
 unsigned long sme_me_mask __section(.data) = 0;
 EXPORT_SYMBOL_GPL(sme_me_mask);
+
+void __init sme_early_init(void)
+{
+	unsigned int i;
+
+	if (!sme_me_mask)
+		return;
+
+	early_pmd_flags |= sme_me_mask;
+
+	__supported_pte_mask |= sme_me_mask;
+
+	/* Update the protection map with memory encryption mask */
+	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
+		protection_map[i] = pgprot_encrypted(protection_map[i]);
+}
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index a57e8e0..91c5c63 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1987,6 +1987,9 @@ int kernel_map_pages_in_pgd(pgd_t *pgd, u64 pfn, unsigned long address,
 	if (!(page_flags & _PAGE_RW))
 		cpa.mask_clr = __pgprot(_PAGE_RW);
 
+	if (!(page_flags & _PAGE_ENC))
+		cpa.mask_clr = __pgprot(pgprot_val(cpa.mask_clr) | _PAGE_ENC);
+
 	cpa.mask_set = __pgprot(_PAGE_PRESENT | page_flags);
 
 	retval = __change_page_attr_set_clr(&cpa, 0);
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 18af2bc..4a24451 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -314,6 +314,14 @@ static inline int pmd_same(pmd_t pmd_a, pmd_t pmd_b)
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
