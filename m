Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8214F6B0313
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:54:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y190so33985051pgb.3
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:54:32 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id w19si778931pgj.62.2017.08.08.05.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:54:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 09/14] x86/mm: Handle boot-time paging mode switching at early boot
Date: Tue,  8 Aug 2017 15:54:10 +0300
Message-Id: <20170808125415.78842-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch adds detection of 5-level paging at boot-time and adjusts
virtual memory layout and folds p4d page table layer if needed.

We have to make X86_5LEVEL dependant on SPARSEMEM_VMEMMAP.
!SPARSEMEM_VMEMMAP configuration doesn't work well with variable
MAX_PHYSMEM_BITS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/Kconfig                        |  1 +
 arch/x86/boot/compressed/kaslr.c        | 13 +++++--
 arch/x86/entry/entry_64.S               | 12 +++++++
 arch/x86/include/asm/page_64_types.h    | 13 +++----
 arch/x86/include/asm/pgtable_64_types.h | 35 +++++++++++--------
 arch/x86/include/asm/processor.h        |  2 +-
 arch/x86/include/asm/sparsemem.h        |  9 ++---
 arch/x86/kernel/head64.c                | 60 ++++++++++++++++++++++++++-------
 arch/x86/kernel/head_64.S               | 18 ++++++----
 arch/x86/kernel/setup.c                 |  5 ++-
 arch/x86/mm/dump_pagetables.c           |  8 +++--
 arch/x86/mm/kaslr.c                     | 13 ++++---
 12 files changed, 129 insertions(+), 60 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2c9c4899d9ff..ac3358bb7bd2 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1401,6 +1401,7 @@ config X86_PAE
 config X86_5LEVEL
 	bool "Enable 5-level page tables support"
 	depends on X86_64
+	depends on SPARSEMEM_VMEMMAP
 	---help---
 	  5-level paging enables access to larger address space:
 	  upto 128 PiB of virtual address space and 4 PiB of
diff --git a/arch/x86/boot/compressed/kaslr.c b/arch/x86/boot/compressed/kaslr.c
index f0f53817a8d2..e37bcfb9f432 100644
--- a/arch/x86/boot/compressed/kaslr.c
+++ b/arch/x86/boot/compressed/kaslr.c
@@ -44,8 +44,9 @@
 #include <linux/decompress/mm.h>
 
 #ifdef CONFIG_X86_5LEVEL
-unsigned int pgdir_shift __read_mostly = 48;
-unsigned int ptrs_per_p4d __read_mostly = 512;
+unsigned int p4d_folded __read_mostly = 1;
+unsigned int pgdir_shift __read_mostly = 39;
+unsigned int ptrs_per_p4d __read_mostly = 1;
 #endif
 
 extern unsigned long get_cmd_line_ptr(void);
@@ -642,6 +643,14 @@ void choose_random_location(unsigned long input,
 		return;
 	}
 
+#ifdef CONFIG_X86_5LEVEL
+	if (__read_cr4() & X86_CR4_LA57) {
+		p4d_folded = 0;
+		pgdir_shift = 48;
+		ptrs_per_p4d = 512;
+	}
+#endif
+
 	boot_params->hdr.loadflags |= KASLR_FLAG;
 
 	/* Prepare to add new identity pagetables on demand. */
diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
index daf8936d0628..077e8b45784c 100644
--- a/arch/x86/entry/entry_64.S
+++ b/arch/x86/entry/entry_64.S
@@ -273,8 +273,20 @@ return_from_SYSCALL_64:
 	 * Change top bits to match most significant bit (47th or 56th bit
 	 * depending on paging mode) in the address.
 	 */
+#ifdef CONFIG_X86_5LEVEL
+	testl	$1, p4d_folded(%rip)
+	jnz	1f
+	shl	$(64 - 57), %rcx
+	sar	$(64 - 57), %rcx
+	jmp	2f
+1:
+	shl	$(64 - 48), %rcx
+	sar	$(64 - 48), %rcx
+2:
+#else
 	shl	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
 	sar	$(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
+#endif
 
 	/* If this changed %rcx, it was not canonical */
 	cmpq	%rcx, %r11
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
index a5338b0936ad..1958a50d79cf 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -20,7 +20,7 @@ typedef unsigned long	pgprotval_t;
 typedef struct { pteval_t pte; } pte_t;
 
 #ifdef CONFIG_X86_5LEVEL
-#define p4d_folded 0
+extern unsigned int p4d_folded;
 #else
 #define p4d_folded 1
 #endif
@@ -86,24 +86,31 @@ extern unsigned int ptrs_per_p4d;
 #define PGDIR_MASK	(~(PGDIR_SIZE - 1))
 
 /* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
-#define MAXMEM		_AC(__AC(1, UL) << MAX_PHYSMEM_BITS, UL)
-#ifdef CONFIG_X86_5LEVEL
-#define VMALLOC_SIZE_TB _AC(16384, UL)
-#define __VMALLOC_BASE	_AC(0xff92000000000000, UL)
-#define __VMEMMAP_BASE	_AC(0xffd4000000000000, UL)
-#else
-#define VMALLOC_SIZE_TB	_AC(32, UL)
-#define __VMALLOC_BASE	_AC(0xffffc90000000000, UL)
-#define __VMEMMAP_BASE	_AC(0xffffea0000000000, UL)
-#endif
+#define MAXMEM		(1UL << MAX_PHYSMEM_BITS)
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
index c1352771b2f6..cb2958b88de5 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -871,7 +871,7 @@ static inline void spin_lock_prefetch(const void *x)
 					IA32_PAGE_OFFSET : TASK_SIZE_MAX)
 
 #define STACK_TOP		TASK_SIZE_LOW
-#define STACK_TOP_MAX		TASK_SIZE_MAX
+#define STACK_TOP_MAX		(!p4d_folded ? TASK_SIZE_MAX : DEFAULT_MAP_WINDOW)
 
 #define INIT_THREAD  {						\
 	.sp0			= TOP_OF_INIT_STACK,		\
diff --git a/arch/x86/include/asm/sparsemem.h b/arch/x86/include/asm/sparsemem.h
index 1f5bee2c202f..ba67afd870b7 100644
--- a/arch/x86/include/asm/sparsemem.h
+++ b/arch/x86/include/asm/sparsemem.h
@@ -26,13 +26,8 @@
 # endif
 #else /* CONFIG_X86_32 */
 # define SECTION_SIZE_BITS	27 /* matt - 128 is convenient right now */
-# ifdef CONFIG_X86_5LEVEL
-#  define MAX_PHYSADDR_BITS	52
-#  define MAX_PHYSMEM_BITS	52
-# else
-#  define MAX_PHYSADDR_BITS	44
-#  define MAX_PHYSMEM_BITS	46
-# endif
+# define MAX_PHYSADDR_BITS	(p4d_folded ? 44 : 52)
+# define MAX_PHYSMEM_BITS	(p4d_folded ? 46 : 52)
 #endif
 
 #endif /* CONFIG_SPARSEMEM */
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index f05ea8d6b0fa..5a2029114fb7 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -39,18 +39,18 @@ static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 
 #ifdef CONFIG_X86_5LEVEL
-unsigned int pgdir_shift __read_mostly = 48;
+unsigned int pgdir_shift __read_mostly = 39;
 EXPORT_SYMBOL(pgdir_shift);
-unsigned int ptrs_per_p4d __read_mostly = 512;
+unsigned int ptrs_per_p4d __read_mostly = 1;
 EXPORT_SYMBOL(ptrs_per_p4d);
 #endif
 
 #if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)
-unsigned long page_offset_base __read_mostly = __PAGE_OFFSET_BASE;
+unsigned long page_offset_base __read_mostly = __PAGE_OFFSET_BASE48;
 EXPORT_SYMBOL(page_offset_base);
-unsigned long vmalloc_base __read_mostly = __VMALLOC_BASE;
+unsigned long vmalloc_base __read_mostly = __VMALLOC_BASE48;
 EXPORT_SYMBOL(vmalloc_base);
-unsigned long vmemmap_base __read_mostly = __VMEMMAP_BASE;
+unsigned long vmemmap_base __read_mostly = __VMEMMAP_BASE48;
 EXPORT_SYMBOL(vmemmap_base);
 #endif
 
@@ -61,6 +61,36 @@ static void __head *fixup_pointer(void *ptr, unsigned long physaddr)
 	return ptr - (void *)_text + (void *)physaddr;
 }
 
+static unsigned long __head *fixup_long(void *ptr, unsigned long physaddr)
+{
+	return fixup_pointer(ptr, physaddr);
+}
+
+#ifdef CONFIG_X86_5LEVEL
+static unsigned int __head *fixup_int(void *ptr, unsigned long physaddr)
+{
+	return fixup_pointer(ptr, physaddr);
+}
+
+static void __head check_la57_support(unsigned long physaddr)
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
+static void __head check_la57_support(unsigned long physaddr) {}
+#endif
+
 unsigned long __head __startup_64(unsigned long physaddr,
 				  struct boot_params *bp)
 {
@@ -72,6 +102,8 @@ unsigned long __head __startup_64(unsigned long physaddr,
 	pmdval_t *pmd, pmd_entry;
 	int i;
 
+	check_la57_support(physaddr);
+
 	/* Is the address too large? */
 	if (physaddr >> MAX_PHYSMEM_BITS)
 		for (;;);
@@ -95,9 +127,14 @@ unsigned long __head __startup_64(unsigned long physaddr,
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
+	*p += _PAGE_TABLE_NOENC - __START_KERNEL_map + load_delta;
+
+	if (!p4d_folded) {
 		p4d = fixup_pointer(&level4_kernel_pgt, physaddr);
 		p4d[511] += load_delta;
 	}
@@ -120,7 +157,7 @@ unsigned long __head __startup_64(unsigned long physaddr,
 	pmd = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 	pgtable_flags = _KERNPG_TABLE_NOENC + sme_get_me_mask();
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (!p4d_folded) {
 		p4d = fixup_pointer(early_dynamic_pgts[next_early_pgt++], physaddr);
 
 		i = (physaddr >> PGDIR_SHIFT) % PTRS_PER_PGD;
@@ -166,8 +203,7 @@ unsigned long __head __startup_64(unsigned long physaddr,
 	 * Fixup phys_base - remove the memory encryption mask to obtain
 	 * the true physical address.
 	 */
-	p = fixup_pointer(&phys_base, physaddr);
-	*p += load_delta - sme_get_me_mask();
+	*fixup_long(&phys_base, physaddr) += load_delta - sme_get_me_mask();
 
 	/* Encrypt the kernel (if SME is active) */
 	sme_encrypt_kernel();
@@ -218,7 +254,7 @@ int __init __early_make_pgtable(unsigned long address, pmdval_t pmd)
 	 * critical -- __PAGE_OFFSET would point us back into the dynamic
 	 * range and we might end up looping forever...
 	 */
-	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (p4d_folded)
 		p4d_p = pgd_p;
 	else if (pgd)
 		p4d_p = (p4dval_t *)((pgd & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 2be7d1e7fcf1..ebdcb08a91cb 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -40,7 +40,7 @@
 #define pud_index(x)	(((x) >> PUD_SHIFT) & (PTRS_PER_PUD-1))
 
 #if defined(CONFIG_XEN_PV) || defined(CONFIG_XEN_PVH)
-PGD_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE)
+PGD_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE48)
 PGD_START_KERNEL = pgd_index(__START_KERNEL_map)
 #endif
 L3_START_KERNEL = pud_index(__START_KERNEL_map)
@@ -121,7 +121,10 @@ ENTRY(secondary_startup_64)
 	/* Enable PAE mode, PGE and LA57 */
 	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
 #ifdef CONFIG_X86_5LEVEL
+	testl	$1, p4d_folded(%rip)
+	jnz	1f
 	orl	$X86_CR4_LA57, %ecx
+1:
 #endif
 	movq	%rcx, %cr4
 
@@ -350,12 +353,7 @@ GLOBAL(name)
 
 	__INITDATA
 NEXT_PAGE(early_top_pgt)
-	.fill	511,8,0
-#ifdef CONFIG_X86_5LEVEL
-	.quad	level4_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
-#else
-	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE_NOENC
-#endif
+	.fill	512,8,0
 
 NEXT_PAGE(early_dynamic_pgts)
 	.fill	512*EARLY_DYNAMIC_PAGE_TABLES,8,0
@@ -434,6 +432,12 @@ ENTRY(phys_base)
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
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 022ebddb3734..10e6dd1cb948 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -202,9 +202,7 @@ struct ist_info ist_info;
 #endif
 
 #else
-struct cpuinfo_x86 boot_cpu_data __read_mostly = {
-	.x86_phys_bits = MAX_PHYSMEM_BITS,
-};
+struct cpuinfo_x86 boot_cpu_data __read_mostly;
 EXPORT_SYMBOL(boot_cpu_data);
 #endif
 
@@ -892,6 +890,7 @@ void __init setup_arch(char **cmdline_p)
 	__flush_tlb_all();
 #else
 	printk(KERN_INFO "Command line: %s\n", boot_command_line);
+	boot_cpu_data.x86_phys_bits = MAX_PHYSMEM_BITS;
 #endif
 
 	/*
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index bad178deffba..acf264ab02f3 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -82,8 +82,8 @@ static struct addr_marker address_markers[] = {
 	{ 0/* VMALLOC_START */, "vmalloc() Area" },
 	{ 0/* VMEMMAP_START */, "Vmemmap" },
 #ifdef CONFIG_KASAN
-	{ KASAN_SHADOW_START,	"KASAN shadow" },
-	{ KASAN_SHADOW_END,	"KASAN shadow end" },
+	{ 0/* KASAN_SHADOW_START */,	"KASAN shadow" },
+	{ 0/* KASAN_SHADOW_END */,	"KASAN shadow end" },
 #endif
 # ifdef CONFIG_X86_ESPFIX64
 	{ ESPFIX_BASE_ADDR,	"ESPfix Area", 16 },
@@ -515,6 +515,10 @@ static int __init pt_dump_init(void)
 	address_markers[LOW_KERNEL_NR].start_address = PAGE_OFFSET;
 	address_markers[VMALLOC_START_NR].start_address = VMALLOC_START;
 	address_markers[VMEMMAP_START_NR].start_address = VMEMMAP_START;
+#ifdef CONFIG_KASAN
+	address_markers[KASAN_SHADOW_START_NR].start_address = KASAN_SHADOW_START;
+	address_markers[KASAN_SHADOW_END_NR].start_address = KASAN_SHADOW_END;
+#endif
 #endif
 #ifdef CONFIG_X86_32
 	address_markers[VMALLOC_START_NR].start_address = VMALLOC_START;
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index e6420b18f6e0..2f6ba5c72905 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -43,7 +43,6 @@
  * before. You also need to add a BUILD_BUG_ON() in kernel_randomize_memory() to
  * ensure that this order is correct and won't be changed.
  */
-static const unsigned long vaddr_start = __PAGE_OFFSET_BASE;
 
 #if defined(CONFIG_X86_ESPFIX64)
 static const unsigned long vaddr_end = ESPFIX_BASE_ADDR;
@@ -62,8 +61,8 @@ static __initdata struct kaslr_memory_region {
 	unsigned long *base;
 	unsigned long size_tb;
 } kaslr_regions[] = {
-	{ &page_offset_base, 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT) /* Maximum */ },
-	{ &vmalloc_base, VMALLOC_SIZE_TB },
+	{ &page_offset_base, 0 },
+	{ &vmalloc_base, 0 },
 	{ &vmemmap_base, 1 },
 };
 
@@ -86,11 +85,14 @@ static inline bool kaslr_memory_enabled(void)
 void __init kernel_randomize_memory(void)
 {
 	size_t i;
-	unsigned long vaddr = vaddr_start;
+	unsigned long vaddr_start, vaddr;
 	unsigned long rand, memory_tb;
 	struct rnd_state rand_state;
 	unsigned long remain_entropy;
 
+	vaddr_start = p4d_folded ? __PAGE_OFFSET_BASE48 : __PAGE_OFFSET_BASE57;
+	vaddr = vaddr_start;
+
 	/*
 	 * All these BUILD_BUG_ON checks ensures the memory layout is
 	 * consistent with the vaddr_start/vaddr_end variables.
@@ -106,6 +108,9 @@ void __init kernel_randomize_memory(void)
 	if (!kaslr_memory_enabled())
 		return;
 
+	kaslr_regions[0].size_tb = 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT);
+	kaslr_regions[1].size_tb = VMALLOC_SIZE_TB;
+
 	/*
 	 * Update Physical memory mapping to available and
 	 * add padding if needed (especially for memory hotplug support).
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
