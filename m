Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8F36B000D
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 06:17:18 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y25so686003pfe.5
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 03:17:18 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u2-v6si1232404plr.50.2018.02.14.03.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 03:17:17 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 9/9] x86/mm: Adjust virtual address space layout in early boot
Date: Wed, 14 Feb 2018 14:16:56 +0300
Message-Id: <20180214111656.88514-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
References: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We need to adjust virtual address space to support switching between
paging modes.

The adjustment happens in __startup_64().

We also have to change KASLR code that doesn't expect variable
VMALLOC_SIZE_TB.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/kaslr.c        | 14 ++++++++--
 arch/x86/include/asm/page_64_types.h    |  9 ++----
 arch/x86/include/asm/pgtable_64_types.h | 25 +++++++++--------
 arch/x86/kernel/head64.c                | 49 +++++++++++++++++++++++++++------
 arch/x86/kernel/head_64.S               |  2 +-
 arch/x86/mm/dump_pagetables.c           |  3 ++
 arch/x86/mm/kaslr.c                     | 11 ++++----
 7 files changed, 77 insertions(+), 36 deletions(-)

diff --git a/arch/x86/boot/compressed/kaslr.c b/arch/x86/boot/compressed/kaslr.c
index b18e8f9512de..66e42a098d70 100644
--- a/arch/x86/boot/compressed/kaslr.c
+++ b/arch/x86/boot/compressed/kaslr.c
@@ -47,9 +47,9 @@
 #include <linux/decompress/mm.h>
 
 #ifdef CONFIG_X86_5LEVEL
-unsigned int pgtable_l5_enabled __ro_after_init = 1;
-unsigned int pgdir_shift __ro_after_init = 48;
-unsigned int ptrs_per_p4d __ro_after_init = 512;
+unsigned int pgtable_l5_enabled __ro_after_init;
+unsigned int pgdir_shift __ro_after_init = 39;
+unsigned int ptrs_per_p4d __ro_after_init = 1;
 #endif
 
 extern unsigned long get_cmd_line_ptr(void);
@@ -729,6 +729,14 @@ void choose_random_location(unsigned long input,
 		return;
 	}
 
+#ifdef CONFIG_X86_5LEVEL
+	if (__read_cr4() & X86_CR4_LA57) {
+		pgtable_l5_enabled = 1;
+		pgdir_shift = 48;
+		ptrs_per_p4d = 512;
+	}
+#endif
+
 	boot_params->hdr.loadflags |= KASLR_FLAG;
 
 	/* Prepare to add new identity pagetables on demand. */
diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index fa7dc7cd8c19..2c5a966dc222 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -37,16 +37,13 @@
  * hypervisor to fit.  Choosing 16 slots here is arbitrary, but it's
  * what Xen requires.
  */
-#ifdef CONFIG_X86_5LEVEL
-#define __PAGE_OFFSET_BASE      _AC(0xff10000000000000, UL)
-#else
-#define __PAGE_OFFSET_BASE      _AC(0xffff880000000000, UL)
-#endif
+#define __PAGE_OFFSET_BASE_L5	_AC(0xff10000000000000, UL)
+#define __PAGE_OFFSET_BASE_L4	_AC(0xffff880000000000, UL)
 
 #ifdef CONFIG_DYNAMIC_MEMORY_LAYOUT
 #define __PAGE_OFFSET           page_offset_base
 #else
-#define __PAGE_OFFSET           __PAGE_OFFSET_BASE
+#define __PAGE_OFFSET           __PAGE_OFFSET_BASE_L4
 #endif /* CONFIG_DYNAMIC_MEMORY_LAYOUT */
 
 #define __START_KERNEL_map	_AC(0xffffffff80000000, UL)
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 59d971c85de5..68909a68e5b9 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -102,25 +102,26 @@ extern unsigned int ptrs_per_p4d;
 #define LDT_PGD_ENTRY		(pgtable_l5_enabled ? LDT_PGD_ENTRY_L5 : LDT_PGD_ENTRY_L4)
 #define LDT_BASE_ADDR		(LDT_PGD_ENTRY << PGDIR_SHIFT)
 
-#ifdef CONFIG_X86_5LEVEL
-# define VMALLOC_SIZE_TB	_AC(12800, UL)
-# define __VMALLOC_BASE		_AC(0xffa0000000000000, UL)
-# define __VMEMMAP_BASE		_AC(0xffd4000000000000, UL)
-#else
-# define VMALLOC_SIZE_TB	_AC(32, UL)
-# define __VMALLOC_BASE		_AC(0xffffc90000000000, UL)
-# define __VMEMMAP_BASE		_AC(0xffffea0000000000, UL)
-#endif
+#define __VMALLOC_BASE_L4	0xffffc90000000000
+#define __VMALLOC_BASE_L5 	0xffa0000000000000
+
+#define VMALLOC_SIZE_TB_L4	32UL
+#define VMALLOC_SIZE_TB_L5	12800UL
+
+#define __VMEMMAP_BASE_L4	0xffffea0000000000
+#define __VMEMMAP_BASE_L5	0xffd4000000000000
 
 #ifdef CONFIG_DYNAMIC_MEMORY_LAYOUT
 # define VMALLOC_START		vmalloc_base
+# define VMALLOC_SIZE_TB	(pgtable_l5_enabled ? VMALLOC_SIZE_TB_L5 : VMALLOC_SIZE_TB_L4)
 # define VMEMMAP_START		vmemmap_base
 #else
-# define VMALLOC_START		__VMALLOC_BASE
-# define VMEMMAP_START		__VMEMMAP_BASE
+# define VMALLOC_START		__VMALLOC_BASE_L4
+# define VMALLOC_SIZE_TB	VMALLOC_SIZE_TB_L4
+# define VMEMMAP_START		__VMEMMAP_BASE_L4
 #endif /* CONFIG_DYNAMIC_MEMORY_LAYOUT */
 
-#define VMALLOC_END		(VMALLOC_START + _AC((VMALLOC_SIZE_TB << 40) - 1, UL))
+#define VMALLOC_END		(VMALLOC_START + (VMALLOC_SIZE_TB << 40) - 1)
 
 #define MODULES_VADDR		(__START_KERNEL_map + KERNEL_IMAGE_SIZE)
 /* The module sections ends with the start of the fixmap */
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 98b0ff49b220..795e762f3c66 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -40,20 +40,20 @@ static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 
 #ifdef CONFIG_X86_5LEVEL
-unsigned int pgtable_l5_enabled __ro_after_init = 1;
+unsigned int pgtable_l5_enabled __ro_after_init;
 EXPORT_SYMBOL(pgtable_l5_enabled);
-unsigned int pgdir_shift __ro_after_init = 48;
+unsigned int pgdir_shift __ro_after_init = 39;
 EXPORT_SYMBOL(pgdir_shift);
-unsigned int ptrs_per_p4d __ro_after_init = 512;
+unsigned int ptrs_per_p4d __ro_after_init = 1;
 EXPORT_SYMBOL(ptrs_per_p4d);
 #endif
 
 #ifdef CONFIG_DYNAMIC_MEMORY_LAYOUT
-unsigned long page_offset_base __ro_after_init = __PAGE_OFFSET_BASE;
+unsigned long page_offset_base __ro_after_init = __PAGE_OFFSET_BASE_L4;
 EXPORT_SYMBOL(page_offset_base);
-unsigned long vmalloc_base __ro_after_init = __VMALLOC_BASE;
+unsigned long vmalloc_base __ro_after_init = __VMALLOC_BASE_L4;
 EXPORT_SYMBOL(vmalloc_base);
-unsigned long vmemmap_base __ro_after_init = __VMEMMAP_BASE;
+unsigned long vmemmap_base __ro_after_init = __VMEMMAP_BASE_L4;
 EXPORT_SYMBOL(vmemmap_base);
 #endif
 
@@ -64,10 +64,40 @@ static void __head *fixup_pointer(void *ptr, unsigned long physaddr)
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
+	*fixup_int(&pgtable_l5_enabled, physaddr) = 1;
+	*fixup_int(&pgdir_shift, physaddr) = 48;
+	*fixup_int(&ptrs_per_p4d, physaddr) = 512;
+	*fixup_long(&page_offset_base, physaddr) = __PAGE_OFFSET_BASE_L5;
+	*fixup_long(&vmalloc_base, physaddr) = __VMALLOC_BASE_L5;
+	*fixup_long(&vmemmap_base, physaddr) = __VMEMMAP_BASE_L5;
+}
+#else
+static void __head check_la57_support(unsigned long physaddr) {}
+#endif
+
 unsigned long __head __startup_64(unsigned long physaddr,
 				  struct boot_params *bp)
 {
-	unsigned long load_delta, *p;
+	unsigned long load_delta;
 	unsigned long pgtable_flags;
 	pgdval_t *pgd;
 	p4dval_t *p4d;
@@ -76,6 +106,8 @@ unsigned long __head __startup_64(unsigned long physaddr,
 	int i;
 	unsigned int *next_pgt_ptr;
 
+	check_la57_support(physaddr);
+
 	/* Is the address too large? */
 	if (physaddr >> MAX_PHYSMEM_BITS)
 		for (;;);
@@ -172,8 +204,7 @@ unsigned long __head __startup_64(unsigned long physaddr,
 	 * Fixup phys_base - remove the memory encryption mask to obtain
 	 * the true physical address.
 	 */
-	p = fixup_pointer(&phys_base, physaddr);
-	*p += load_delta - sme_get_me_mask();
+	*fixup_long(&phys_base, physaddr) += load_delta - sme_get_me_mask();
 
 	/* Encrypt the kernel and related (if SME is active) */
 	sme_encrypt_kernel(bp);
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 04a625f0fcda..d3f8b43d541a 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -41,7 +41,7 @@
 #define pud_index(x)	(((x) >> PUD_SHIFT) & (PTRS_PER_PUD-1))
 
 #if defined(CONFIG_XEN_PV) || defined(CONFIG_XEN_PVH)
-PGD_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE)
+PGD_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE_L4)
 PGD_START_KERNEL = pgd_index(__START_KERNEL_map)
 #endif
 L3_START_KERNEL = pud_index(__START_KERNEL_map)
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 9efee6f464ab..a32f0621d664 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -579,6 +579,9 @@ static int __init pt_dump_init(void)
 	address_markers[KASAN_SHADOW_START_NR].start_address = KASAN_SHADOW_START;
 	address_markers[KASAN_SHADOW_END_NR].start_address = KASAN_SHADOW_END;
 #endif
+#ifdef CONFIG_MODIFY_LDT_SYSCALL
+        address_markers[LDT_NR].start_address = LDT_BASE_ADDR;
+#endif
 #endif
 #ifdef CONFIG_X86_32
 	address_markers[VMALLOC_START_NR].start_address = VMALLOC_START;
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index d079878c6cbc..641169d38184 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -34,13 +34,10 @@
 #define TB_SHIFT 40
 
 /*
- * Virtual address start and end range for randomization.
- *
  * The end address could depend on more configuration options to make the
  * highest amount of space for randomization available, but that's too hard
  * to keep straight and caused issues already.
  */
-static const unsigned long vaddr_start = __PAGE_OFFSET_BASE;
 static const unsigned long vaddr_end = CPU_ENTRY_AREA_BASE;
 
 /*
@@ -53,7 +50,7 @@ static __initdata struct kaslr_memory_region {
 	unsigned long size_tb;
 } kaslr_regions[] = {
 	{ &page_offset_base, 0 },
-	{ &vmalloc_base, VMALLOC_SIZE_TB },
+	{ &vmalloc_base, 0 },
 	{ &vmemmap_base, 1 },
 };
 
@@ -76,11 +73,14 @@ static inline bool kaslr_memory_enabled(void)
 void __init kernel_randomize_memory(void)
 {
 	size_t i;
-	unsigned long vaddr = vaddr_start;
+	unsigned long vaddr_start, vaddr;
 	unsigned long rand, memory_tb;
 	struct rnd_state rand_state;
 	unsigned long remain_entropy;
 
+	vaddr_start = pgtable_l5_enabled ? __PAGE_OFFSET_BASE_L5 : __PAGE_OFFSET_BASE_L4;
+	vaddr = vaddr_start;
+
 	/*
 	 * These BUILD_BUG_ON checks ensure the memory layout is consistent
 	 * with the vaddr_start/vaddr_end variables. These checks are very
@@ -94,6 +94,7 @@ void __init kernel_randomize_memory(void)
 		return;
 
 	kaslr_regions[0].size_tb = 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT);
+	kaslr_regions[1].size_tb = VMALLOC_SIZE_TB;
 
 	/*
 	 * Update Physical memory mapping to available and
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
