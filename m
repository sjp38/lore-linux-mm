Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA75F6B0269
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 18:57:06 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id b14so41923013qge.2
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 15:57:06 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0078.outbound.protection.outlook.com. [65.55.169.78])
        by mx.google.com with ESMTPS id n125si597227qkf.225.2016.04.26.15.57.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 15:57:05 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v1 06/18] x86: Provide general kernel support for memory
 encryption
Date: Tue, 26 Apr 2016 17:56:57 -0500
Message-ID: <20160426225657.13567.43518.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo
 Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander
 Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry
 Vyukov <dvyukov@google.com>

Adding general kernel support for memory encryption includes:
- Modify and create some page table macros to include the Secure Memory
  Encryption (SME) memory encryption mask
- Update kernel boot support to call an SME routine that checks for and
  sets the SME capability (the SME routine will grow later and for now
  is just a stub routine)
- Update kernel boot support to call an SME routine that encrypts the
  kernel (the SME routine will grow later and for now is just a stub
  routine)
- Provide an SME initialization routine to update the protection map with
  the memory encryption mask so that it is used by default

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/fixmap.h        |    7 ++++++
 arch/x86/include/asm/mem_encrypt.h   |   18 +++++++++++++++
 arch/x86/include/asm/pgtable_types.h |   41 ++++++++++++++++++++++-----------
 arch/x86/include/asm/processor.h     |    3 ++
 arch/x86/kernel/espfix_64.c          |    2 +-
 arch/x86/kernel/head64.c             |   10 ++++++--
 arch/x86/kernel/head_64.S            |   42 ++++++++++++++++++++++++++--------
 arch/x86/kernel/machine_kexec_64.c   |    2 +-
 arch/x86/kernel/mem_encrypt.S        |    8 ++++++
 arch/x86/mm/Makefile                 |    1 +
 arch/x86/mm/fault.c                  |    5 ++--
 arch/x86/mm/ioremap.c                |    3 ++
 arch/x86/mm/kasan_init_64.c          |    4 ++-
 arch/x86/mm/mem_encrypt.c            |   30 ++++++++++++++++++++++++
 arch/x86/mm/pageattr.c               |    3 ++
 15 files changed, 145 insertions(+), 34 deletions(-)
 create mode 100644 arch/x86/mm/mem_encrypt.c

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
index 747fc52..9f3e762 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -15,12 +15,21 @@
 
 #ifndef __ASSEMBLY__
 
+#include <linux/init.h>
+
 #ifdef CONFIG_AMD_MEM_ENCRYPT
 
 extern unsigned long sme_me_mask;
 
 u8 sme_get_me_loss(void);
 
+void __init sme_early_init(void);
+
+#define __sme_pa(x)		(__pa((x)) | sme_me_mask)
+#define __sme_pa_nodebug(x)	(__pa_nodebug((x)) | sme_me_mask)
+
+#define __sme_va(x)		(__va((x) & ~sme_me_mask))
+
 #else	/* !CONFIG_AMD_MEM_ENCRYPT */
 
 #define sme_me_mask		0UL
@@ -30,6 +39,15 @@ static inline u8 sme_get_me_loss(void)
 	return 0;
 }
 
+static inline void __init sme_early_init(void)
+{
+}
+
+#define __sme_pa		__pa
+#define __sme_pa_nodebug	__pa_nodebug
+
+#define __sme_va		__va
+
 #endif	/* CONFIG_AMD_MEM_ENCRYPT */
 
 #endif	/* __ASSEMBLY__ */
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 7b5efe2..fda7877 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -3,6 +3,7 @@
 
 #include <linux/const.h>
 #include <asm/page_types.h>
+#include <asm/mem_encrypt.h>
 
 #define FIRST_USER_ADDRESS	0UL
 
@@ -115,9 +116,9 @@
 
 #define _PAGE_PROTNONE	(_AT(pteval_t, 1) << _PAGE_BIT_PROTNONE)
 
-#define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
+#define __PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER |	\
 			 _PAGE_ACCESSED | _PAGE_DIRTY)
-#define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\
+#define __KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED |	\
 			 _PAGE_DIRTY)
 
 /*
@@ -185,18 +186,30 @@ enum page_cache_mode {
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
+#define _PAGE_ENC	sme_me_mask
+
+/* Redefine macros to inclue the memory encryption mask */
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
index 8d326e8..1fae737 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -22,6 +22,7 @@ struct vm86;
 #include <asm/nops.h>
 #include <asm/special_insns.h>
 #include <asm/fpu/types.h>
+#include <asm/mem_encrypt.h>
 
 #include <linux/personality.h>
 #include <linux/cache.h>
@@ -207,7 +208,7 @@ static inline void native_cpuid(unsigned int *eax, unsigned int *ebx,
 
 static inline void load_cr3(pgd_t *pgdir)
 {
-	write_cr3(__pa(pgdir));
+	write_cr3(__sme_pa(pgdir));
 }
 
 #ifdef CONFIG_X86_32
diff --git a/arch/x86/kernel/espfix_64.c b/arch/x86/kernel/espfix_64.c
index 4d38416..3385377 100644
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
index b72fb0b..3516f9f 100644
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
@@ -157,6 +158,11 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 
 	clear_page(init_level4_pgt);
 
+	/* Update the early_pmd_flags with the memory encryption mask */
+	early_pmd_flags |= _PAGE_ENC;
+
+	sme_early_init();
+
 	kasan_early_init();
 
 	for (i = 0; i < NUM_EXCEPTION_VECTORS; i++)
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 5df831e..0f3ad72 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -95,6 +95,13 @@ startup_64:
 	jnz	bad_address
 
 	/*
+	 * Enable memory encryption (if available). Add the memory encryption
+	 * mask to %rbp to include it in the the page table fixup.
+	 */
+	call	sme_enable
+	addq	sme_me_mask(%rip), %rbp
+
+	/*
 	 * Fixup the physical addresses in the page table
 	 */
 	addq	%rbp, early_level4_pgt + (L4_START_KERNEL*8)(%rip)
@@ -116,7 +123,8 @@ startup_64:
 	movq	%rdi, %rax
 	shrq	$PGDIR_SHIFT, %rax
 
-	leaq	(4096 + _KERNPG_TABLE)(%rbx), %rdx
+	leaq	(4096 + __KERNPG_TABLE)(%rbx), %rdx
+	addq	sme_me_mask(%rip), %rdx		/* Apply mem encryption mask */
 	movq	%rdx, 0(%rbx,%rax,8)
 	movq	%rdx, 8(%rbx,%rax,8)
 
@@ -133,6 +141,7 @@ startup_64:
 	movq	%rdi, %rax
 	shrq	$PMD_SHIFT, %rdi
 	addq	$(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL), %rax
+	addq	sme_me_mask(%rip), %rax		/* Apply mem encryption mask */
 	leaq	(_end - 1)(%rip), %rcx
 	shrq	$PMD_SHIFT, %rcx
 	subq	%rdi, %rcx
@@ -163,9 +172,19 @@ startup_64:
 	cmp	%r8, %rdi
 	jne	1b
 
-	/* Fixup phys_base */
+	/*
+	 * Fixup phys_base, remove the memory encryption mask from %rbp
+	 * to obtain the true physical address.
+	 */
+	subq	sme_me_mask(%rip), %rbp
 	addq	%rbp, phys_base(%rip)
 
+	/*
+	 * The page tables have been updated with the memory encryption mask,
+	 * so encrypt the kernel if memory encryption is active
+	 */
+	call	sme_encrypt_kernel
+
 	movq	$(early_level4_pgt - __START_KERNEL_map), %rax
 	jmp 1f
 ENTRY(secondary_startup_64)
@@ -189,6 +208,9 @@ ENTRY(secondary_startup_64)
 	movq	$(init_level4_pgt - __START_KERNEL_map), %rax
 1:
 
+	/* Add the memory encryption mask to RAX */
+	addq	sme_me_mask(%rip), %rax
+
 	/* Enable PAE mode and PGE */
 	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
 	movq	%rcx, %cr4
@@ -416,7 +438,7 @@ GLOBAL(name)
 	__INITDATA
 NEXT_PAGE(early_level4_pgt)
 	.fill	511,8,0
-	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
+	.quad	level3_kernel_pgt - __START_KERNEL_map + __PAGE_TABLE
 
 NEXT_PAGE(early_dynamic_pgts)
 	.fill	512*EARLY_DYNAMIC_PAGE_TABLES,8,0
@@ -428,15 +450,15 @@ NEXT_PAGE(init_level4_pgt)
 	.fill	512,8,0
 #else
 NEXT_PAGE(init_level4_pgt)
-	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
+	.quad   level3_ident_pgt - __START_KERNEL_map + __KERNPG_TABLE
 	.org    init_level4_pgt + L4_PAGE_OFFSET*8, 0
-	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
+	.quad   level3_ident_pgt - __START_KERNEL_map + __KERNPG_TABLE
 	.org    init_level4_pgt + L4_START_KERNEL*8, 0
 	/* (2^48-(2*1024*1024*1024))/(2^39) = 511 */
-	.quad   level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
+	.quad   level3_kernel_pgt - __START_KERNEL_map + __PAGE_TABLE
 
 NEXT_PAGE(level3_ident_pgt)
-	.quad	level2_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
+	.quad	level2_ident_pgt - __START_KERNEL_map + __KERNPG_TABLE
 	.fill	511, 8, 0
 NEXT_PAGE(level2_ident_pgt)
 	/* Since I easily can, map the first 1G.
@@ -448,8 +470,8 @@ NEXT_PAGE(level2_ident_pgt)
 NEXT_PAGE(level3_kernel_pgt)
 	.fill	L3_START_KERNEL,8,0
 	/* (2^48-(2*1024*1024*1024)-((2^39)*511))/(2^30) = 510 */
-	.quad	level2_kernel_pgt - __START_KERNEL_map + _KERNPG_TABLE
-	.quad	level2_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE
+	.quad	level2_kernel_pgt - __START_KERNEL_map + __KERNPG_TABLE
+	.quad	level2_fixmap_pgt - __START_KERNEL_map + __PAGE_TABLE
 
 NEXT_PAGE(level2_kernel_pgt)
 	/*
@@ -467,7 +489,7 @@ NEXT_PAGE(level2_kernel_pgt)
 
 NEXT_PAGE(level2_fixmap_pgt)
 	.fill	506,8,0
-	.quad	level1_fixmap_pgt - __START_KERNEL_map + _PAGE_TABLE
+	.quad	level1_fixmap_pgt - __START_KERNEL_map + __PAGE_TABLE
 	/* 8MB reserved for vsyscalls + a 2MB hole = 4 + 1 entries */
 	.fill	5,8,0
 
diff --git a/arch/x86/kernel/machine_kexec_64.c b/arch/x86/kernel/machine_kexec_64.c
index ba7fbba..eb2faee 100644
--- a/arch/x86/kernel/machine_kexec_64.c
+++ b/arch/x86/kernel/machine_kexec_64.c
@@ -103,7 +103,7 @@ static int init_pgtable(struct kimage *image, unsigned long start_pgtable)
 	struct x86_mapping_info info = {
 		.alloc_pgt_page	= alloc_pgt_page,
 		.context	= image,
-		.pmd_flag	= __PAGE_KERNEL_LARGE_EXEC,
+		.pmd_flag	= __PAGE_KERNEL_LARGE_EXEC | _PAGE_ENC,
 	};
 	unsigned long mstart, mend;
 	pgd_t *level4p;
diff --git a/arch/x86/kernel/mem_encrypt.S b/arch/x86/kernel/mem_encrypt.S
index ef7f325..f2e0536 100644
--- a/arch/x86/kernel/mem_encrypt.S
+++ b/arch/x86/kernel/mem_encrypt.S
@@ -14,6 +14,14 @@
 
 	.text
 	.code64
+ENTRY(sme_enable)
+	ret
+ENDPROC(sme_enable)
+
+ENTRY(sme_encrypt_kernel)
+	ret
+ENDPROC(sme_encrypt_kernel)
+
 ENTRY(sme_get_me_loss)
 	xor	%rax, %rax
 	mov	sme_me_loss(%rip), %al
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index f989132..21f8ea3 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -39,3 +39,4 @@ obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
 obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
 obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS) += pkeys.o
 
+obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 5ce1ed0..9e93a0d 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -23,6 +23,7 @@
 #include <asm/vsyscall.h>		/* emulate_vsyscall		*/
 #include <asm/vm86.h>			/* struct vm86			*/
 #include <asm/mmu_context.h>		/* vma_pkey()			*/
+#include <asm/mem_encrypt.h>		/* __sme_va()			*/
 
 #define CREATE_TRACE_POINTS
 #include <asm/trace/exceptions.h>
@@ -523,7 +524,7 @@ static int bad_address(void *p)
 
 static void dump_pagetable(unsigned long address)
 {
-	pgd_t *base = __va(read_cr3() & PHYSICAL_PAGE_MASK);
+	pgd_t *base = __sme_va(read_cr3() & PHYSICAL_PAGE_MASK);
 	pgd_t *pgd = base + pgd_index(address);
 	pud_t *pud;
 	pmd_t *pmd;
@@ -659,7 +660,7 @@ show_fault_oops(struct pt_regs *regs, unsigned long error_code,
 		pgd_t *pgd;
 		pte_t *pte;
 
-		pgd = __va(read_cr3() & PHYSICAL_PAGE_MASK);
+		pgd = __sme_va(read_cr3() & PHYSICAL_PAGE_MASK);
 		pgd += pgd_index(address);
 
 		pte = lookup_address_in_pgd(pgd, address, &level);
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index f089491..77dadf5 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -21,6 +21,7 @@
 #include <asm/tlbflush.h>
 #include <asm/pgalloc.h>
 #include <asm/pat.h>
+#include <asm/mem_encrypt.h>
 
 #include "physaddr.h"
 
@@ -424,7 +425,7 @@ static pte_t bm_pte[PAGE_SIZE/sizeof(pte_t)] __page_aligned_bss;
 static inline pmd_t * __init early_ioremap_pmd(unsigned long addr)
 {
 	/* Don't assume we're using swapper_pg_dir at this point */
-	pgd_t *base = __va(read_cr3());
+	pgd_t *base = __sme_va(read_cr3());
 	pgd_t *pgd = &base[pgd_index(addr)];
 	pud_t *pud = pud_offset(pgd, addr);
 	pmd_t *pmd = pmd_offset(pud, addr);
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 1b1110f..7102408 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -68,7 +68,7 @@ static struct notifier_block kasan_die_notifier = {
 void __init kasan_early_init(void)
 {
 	int i;
-	pteval_t pte_val = __pa_nodebug(kasan_zero_page) | __PAGE_KERNEL;
+	pteval_t pte_val = __pa_nodebug(kasan_zero_page) | __PAGE_KERNEL | _PAGE_ENC;
 	pmdval_t pmd_val = __pa_nodebug(kasan_zero_pte) | _KERNPG_TABLE;
 	pudval_t pud_val = __pa_nodebug(kasan_zero_pmd) | _KERNPG_TABLE;
 
@@ -130,7 +130,7 @@ void __init kasan_init(void)
 	 */
 	memset(kasan_zero_page, 0, PAGE_SIZE);
 	for (i = 0; i < PTRS_PER_PTE; i++) {
-		pte_t pte = __pte(__pa(kasan_zero_page) | __PAGE_KERNEL_RO);
+		pte_t pte = __pte(__pa(kasan_zero_page) | __PAGE_KERNEL_RO | _PAGE_ENC);
 		set_pte(&kasan_zero_pte[i], pte);
 	}
 	/* Flush TLBs again to be sure that write protection applied. */
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
new file mode 100644
index 0000000..00eb705
--- /dev/null
+++ b/arch/x86/mm/mem_encrypt.c
@@ -0,0 +1,30 @@
+/*
+ * AMD Memory Encryption Support
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Tom Lendacky <thomas.lendacky@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/init.h>
+#include <linux/mm.h>
+
+#include <asm/mem_encrypt.h>
+
+void __init sme_early_init(void)
+{
+	unsigned int i;
+
+	if (!sme_me_mask)
+		return;
+
+	__supported_pte_mask |= sme_me_mask;
+
+	/* Update the protection map with memory encryption mask */
+	for (i = 0; i < ARRAY_SIZE(protection_map); i++)
+		protection_map[i] = __pgprot(pgprot_val(protection_map[i]) | sme_me_mask);
+}
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index bbf462f..c055302 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1976,6 +1976,9 @@ int kernel_map_pages_in_pgd(pgd_t *pgd, u64 pfn, unsigned long address,
 	if (!(page_flags & _PAGE_RW))
 		cpa.mask_clr = __pgprot(_PAGE_RW);
 
+	if (!(page_flags & _PAGE_ENC))
+		cpa.mask_clr = __pgprot(pgprot_val(cpa.mask_clr) | _PAGE_ENC);
+
 	cpa.mask_set = __pgprot(_PAGE_PRESENT | page_flags);
 
 	retval = __change_page_attr_set_clr(&cpa, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
