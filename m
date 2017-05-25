Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A5096B02C3
	for <linux-mm@kvack.org>; Thu, 25 May 2017 16:33:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e7so235038908pfk.9
        for <linux-mm@kvack.org>; Thu, 25 May 2017 13:33:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z66si29142522pgz.422.2017.05.25.13.33.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 13:33:55 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 4/8] x86/mm: Handle boot-time paging mode switching at early boot
Date: Thu, 25 May 2017 23:33:30 +0300
Message-Id: <20170525203334.867-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch adds detection of 5-level paging at boot-time and adjusts
virtual memory layout and folds p4d page table layer if needed.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/page_64_types.h    | 13 +++----
 arch/x86/include/asm/pgtable_64_types.h | 37 +++++++++++++-------
 arch/x86/include/asm/processor.h        |  2 +-
 arch/x86/kernel/head64.c                | 62 +++++++++++++++++++++++++--------
 arch/x86/kernel/head_64.S               | 16 +++++----
 arch/x86/mm/kaslr.c                     |  2 +-
 6 files changed, 90 insertions(+), 42 deletions(-)

diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index 0126d6bc2eb1..26056ef366b8 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -36,24 +36,21 @@
  * hypervisor to fit.  Choosing 16 slots here is arbitrary, but it's
  * what Xen requires.
  */
-#ifdef CONFIG_X86_5LEVEL
-#define __PAGE_OFFSET_BASE      _AC(0xff10000000000000, UL)
-#else
-#define __PAGE_OFFSET_BASE      _AC(0xffff880000000000, UL)
-#endif
+#define __PAGE_OFFSET_BASE57	_AC(0xff10000000000000, UL)
+#define __PAGE_OFFSET_BASE48	_AC(0xffff880000000000, UL)
 
 #if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)
 #define __PAGE_OFFSET           page_offset_base
 #else
-#define __PAGE_OFFSET           __PAGE_OFFSET_BASE
+#define __PAGE_OFFSET           __PAGE_OFFSET_BASE48
 #endif /* CONFIG_RANDOMIZE_MEMORY */
 
 #define __START_KERNEL_map	_AC(0xffffffff80000000, UL)
 
 /* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
 #ifdef CONFIG_X86_5LEVEL
-#define __PHYSICAL_MASK_SHIFT	52
-#define __VIRTUAL_MASK_SHIFT	56
+#define __PHYSICAL_MASK_SHIFT	(p4d_folded ? 52 : 46)
+#define __VIRTUAL_MASK_SHIFT	(p4d_folded ? 47 : 56)
 #else
 #define __PHYSICAL_MASK_SHIFT	46
 #define __VIRTUAL_MASK_SHIFT	47
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index a09f2fa91e09..46f52da75e16 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -19,6 +19,12 @@ typedef unsigned long	pgprotval_t;
 
 typedef struct { pteval_t pte; } pte_t;
 
+#ifdef CONFIG_X86_5LEVEL
+extern unsigned int p4d_folded;
+#else
+#define p4d_folded 1
+#endif
+
 extern unsigned int pgdir_shift;
 extern unsigned int ptrs_per_p4d;
 
@@ -79,23 +85,30 @@ extern unsigned int ptrs_per_p4d;
 
 /* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
 #define MAXMEM		_AC(__AC(1, UL) << MAX_PHYSMEM_BITS, UL)
-#ifdef CONFIG_X86_5LEVEL
-#define VMALLOC_SIZE_TB _AC(16384, UL)
-#define __VMALLOC_BASE	_AC(0xff92000000000000, UL)
-#define __VMEMMAP_BASE	_AC(0xffd4000000000000, UL)
-#else
-#define VMALLOC_SIZE_TB	_AC(32, UL)
-#define __VMALLOC_BASE	_AC(0xffffc90000000000, UL)
-#define __VMEMMAP_BASE	_AC(0xffffea0000000000, UL)
-#endif
+
+#ifndef __ASSEMBLY__
+#define __VMALLOC_BASE48	0xffffc90000000000
+#define __VMALLOC_BASE57	0xff92000000000000
+
+#define VMALLOC_SIZE_TB48	32UL
+#define VMALLOC_SIZE_TB57	16384UL
+
+#define __VMEMMAP_BASE48	0xffffea0000000000
+#define __VMEMMAP_BASE57	0xffd4000000000000
+
 #if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)
 #define VMALLOC_START	vmalloc_base
+#define VMALLOC_SIZE_TB	(!p4d_folded ? VMALLOC_SIZE_TB57 : VMALLOC_SIZE_TB48)
 #define VMEMMAP_START	vmemmap_base
 #else
-#define VMALLOC_START	__VMALLOC_BASE
-#define VMEMMAP_START	__VMEMMAP_BASE
+#define VMALLOC_START	__VMALLOC_BASE48
+#define VMALLOC_SIZE_TB	VMALLOC_SIZE_TB48
+#define VMEMMAP_START	__VMEMMAP_BASE48
 #endif /* CONFIG_RANDOMIZE_MEMORY */
-#define VMALLOC_END	(VMALLOC_START + _AC((VMALLOC_SIZE_TB << 40) - 1, UL))
+
+#define VMALLOC_END	(VMALLOC_START + (VMALLOC_SIZE_TB << 40) - 1)
+#endif
+
 #define MODULES_VADDR    (__START_KERNEL_map + KERNEL_IMAGE_SIZE)
 /* The module sections ends with the start of the fixmap */
 #define MODULES_END   __fix_to_virt(__end_of_fixed_addresses + 1)
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 65663de9287b..92c3f33f7682 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -854,7 +854,7 @@ static inline void spin_lock_prefetch(const void *x)
 					IA32_PAGE_OFFSET : TASK_SIZE_MAX)
 
 #define STACK_TOP		TASK_SIZE_LOW
-#define STACK_TOP_MAX		TASK_SIZE_MAX
+#define STACK_TOP_MAX		(!p4d_folded ? TASK_SIZE_MAX : DEFAULT_MAP_WINDOW)
 
 #define INIT_THREAD  {						\
 	.sp0			= TOP_OF_INIT_STACK,		\
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index d4e8d4beeb62..47629f3e32aa 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -39,26 +39,54 @@ static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 
 #ifdef CONFIG_X86_5LEVEL
-unsigned int pgdir_shift = 48;
+unsigned int pgdir_shift = 39;
 EXPORT_SYMBOL(pgdir_shift);
-unsigned int ptrs_per_p4d = 512;
+unsigned int ptrs_per_p4d = 1;
 EXPORT_SYMBOL(ptrs_per_p4d);
 #endif
 
-#if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)
-unsigned long page_offset_base = __PAGE_OFFSET_BASE;
+unsigned long page_offset_base = __PAGE_OFFSET_BASE48;
 EXPORT_SYMBOL(page_offset_base);
-unsigned long vmalloc_base = __VMALLOC_BASE;
+unsigned long vmalloc_base = __VMALLOC_BASE48;
 EXPORT_SYMBOL(vmalloc_base);
-unsigned long vmemmap_base = __VMEMMAP_BASE;
+unsigned long vmemmap_base = __VMEMMAP_BASE48;
 EXPORT_SYMBOL(vmemmap_base);
-#endif
 
 static void __init *fixup_pointer(void *ptr, unsigned long physaddr)
 {
 	return ptr - (void *)_text + (void *)physaddr;
 }
 
+static unsigned long __init *fixup_long(void *ptr, unsigned long physaddr)
+{
+	return fixup_pointer(ptr, physaddr);
+}
+
+#ifdef CONFIG_X86_5LEVEL
+static unsigned int __init *fixup_int(void *ptr, unsigned long physaddr)
+{
+	return fixup_pointer(ptr, physaddr);
+}
+
+static void __init check_la57_support(unsigned long physaddr)
+{
+	if (native_cpuid_eax(0) < 7)
+		return;
+
+	if (!(native_cpuid_ecx(7) & (1 << (X86_FEATURE_LA57 & 31))))
+		return;
+
+	*fixup_int(&p4d_folded, physaddr) = 0;
+	*fixup_int(&pgdir_shift, physaddr) = 48;
+	*fixup_int(&ptrs_per_p4d, physaddr) = 512;
+	*fixup_long(&page_offset_base, physaddr) = __PAGE_OFFSET_BASE57;
+	*fixup_long(&vmalloc_base, physaddr) = __VMALLOC_BASE57;
+	*fixup_long(&vmemmap_base, physaddr) = __VMEMMAP_BASE57;
+}
+#else
+static void __init check_la57_support(unsigned long physaddr) {}
+#endif
+
 void __init __startup_64(unsigned long physaddr)
 {
 	unsigned long load_delta, *p;
@@ -68,6 +96,8 @@ void __init __startup_64(unsigned long physaddr)
 	pmdval_t *pmd, pmd_entry;
 	int i;
 
+	check_la57_support(physaddr);
+
 	/* Is the address too large? */
 	if (physaddr >> MAX_PHYSMEM_BITS)
 		for (;;);
@@ -85,9 +115,14 @@ void __init __startup_64(unsigned long physaddr)
 	/* Fixup the physical addresses in the page table */
 
 	pgd = fixup_pointer(&early_top_pgt, physaddr);
-	pgd[pgd_index(__START_KERNEL_map)] += load_delta;
-
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	p = pgd + pgd_index(__START_KERNEL_map);
+	if (p4d_folded)
+		*p = (unsigned long)level3_kernel_pgt;
+	else
+		*p = (unsigned long)level4_kernel_pgt;
+	*p += _PAGE_TABLE - __START_KERNEL_map + load_delta;
+
+	if (!p4d_folded) {
 		p4d = fixup_pointer(&level4_kernel_pgt, physaddr);
 		p4d[511] += load_delta;
 	}
@@ -109,7 +144,7 @@ void __init __startup_64(unsigned long physaddr)
 	pud = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 	pmd = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (!p4d_folded) {
 		p4d = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 
 		i = (physaddr >> PGDIR_SHIFT) % PTRS_PER_PGD;
@@ -151,8 +186,7 @@ void __init __startup_64(unsigned long physaddr)
 	}
 
 	/* Fixup phys_base */
-	p = fixup_pointer(&phys_base, physaddr);
-	*p += load_delta;
+	*fixup_long(&phys_base, physaddr) += load_delta;
 }
 
 /* Wipe all early page tables except for the kernel symbol map */
@@ -185,7 +219,7 @@ int __init early_make_pgtable(unsigned long address)
 	 * critical -- __PAGE_OFFSET would point us back into the dynamic
 	 * range and we might end up looping forever...
 	 */
-	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (p4d_folded)
 		p4d_p = pgd_p;
 	else if (pgd)
 		p4d_p = (p4dval_t *)((pgd & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 6225550883df..2009d9849e98 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -104,7 +104,10 @@ ENTRY(secondary_startup_64)
 	/* Enable PAE mode, PGE and LA57 */
 	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
 #ifdef CONFIG_X86_5LEVEL
+	testl	$1, p4d_folded(%rip)
+	jnz	1f
 	orl	$X86_CR4_LA57, %ecx
+1:
 #endif
 	movq	%rcx, %cr4
 
@@ -333,12 +336,7 @@ GLOBAL(name)
 
 	__INITDATA
 NEXT_PAGE(early_top_pgt)
-	.fill	511,8,0
-#ifdef CONFIG_X86_5LEVEL
-	.quad	level4_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
-#else
-	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
-#endif
+	.fill	512,8,0
 
 NEXT_PAGE(early_dynamic_pgts)
 	.fill	512*EARLY_DYNAMIC_PAGE_TABLES,8,0
@@ -417,6 +415,12 @@ ENTRY(phys_base)
 	.quad   0x0000000000000000
 EXPORT_SYMBOL(phys_base)
 
+#ifdef CONFIG_X86_5LEVEL
+ENTRY(p4d_folded)
+	.word	1
+EXPORT_SYMBOL(p4d_folded)
+#endif
+
 #include "../../x86/xen/xen-head.S"
 	
 	__PAGE_ALIGNED_BSS
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index e6420b18f6e0..55433f2d1957 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -43,7 +43,7 @@
  * before. You also need to add a BUILD_BUG_ON() in kernel_randomize_memory() to
  * ensure that this order is correct and won't be changed.
  */
-static const unsigned long vaddr_start = __PAGE_OFFSET_BASE;
+static const unsigned long vaddr_start = __PAGE_OFFSET_BASE48;
 
 #if defined(CONFIG_X86_ESPFIX64)
 static const unsigned long vaddr_end = ESPFIX_BASE_ADDR;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
