Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 57D8B280402
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 11:29:35 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s14so286063246pgs.4
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 08:29:35 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id d1si8302197pln.673.2017.08.21.08.29.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 08:29:33 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 12/19] x86/mm: Adjust virtual address space layout in early boot.
Date: Mon, 21 Aug 2017 18:29:09 +0300
Message-Id: <20170821152916.40124-13-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
References: <20170821152916.40124-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We need to adjust virtual address space to support switching between
paging modes.

The adjustment happens in __startup_64().

We also have to change KASLT code that doesn't expect variable
VMALLOC_SIZE_TB.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/kaslr.c        | 14 +++++++--
 arch/x86/include/asm/page_64_types.h    |  9 ++----
 arch/x86/include/asm/pgtable_64_types.h | 31 ++++++++++++--------
 arch/x86/kernel/head64.c                | 51 +++++++++++++++++++++++++++------
 arch/x86/kernel/head_64.S               |  2 +-
 arch/x86/mm/kaslr.c                     |  9 ++++--
 6 files changed, 82 insertions(+), 34 deletions(-)

diff --git a/arch/x86/boot/compressed/kaslr.c b/arch/x86/boot/compressed/kaslr.c
index 06837cf8445e..cb0c54701fba 100644
--- a/arch/x86/boot/compressed/kaslr.c
+++ b/arch/x86/boot/compressed/kaslr.c
@@ -44,9 +44,9 @@
 #include <linux/decompress/mm.h>
 
 #ifdef CONFIG_X86_5LEVEL
-unsigned int pgtable_l5_enabled __read_mostly = 1;
-unsigned int pgdir_shift __read_mostly = 48;
-unsigned int ptrs_per_p4d __read_mostly = 512;
+unsigned int pgtable_l5_enabled __read_mostly = 0;
+unsigned int pgdir_shift __read_mostly = 39;
+unsigned int ptrs_per_p4d __read_mostly = 1;
 #endif
 
 extern unsigned long get_cmd_line_ptr(void);
@@ -643,6 +643,14 @@ void choose_random_location(unsigned long input,
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
index 79d2180ffdec..3ce0efaea940 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -36,16 +36,13 @@
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
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 51364e705b35..fa9f8b6592fa 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -87,23 +87,30 @@ extern unsigned int ptrs_per_p4d;
 
 /* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
 #define MAXMEM		(1UL << MAX_PHYSMEM_BITS)
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
+#define VMALLOC_SIZE_TB	(pgtable_l5_enabled ? VMALLOC_SIZE_TB57 : VMALLOC_SIZE_TB48)
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
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 98d9788969cc..f013b0732c96 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -39,20 +39,20 @@ static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 
 #ifdef CONFIG_X86_5LEVEL
-unsigned int pgtable_l5_enabled __read_mostly = 1;
+unsigned int pgtable_l5_enabled __read_mostly = 0;
 EXPORT_SYMBOL(pgtable_l5_enabled);
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
 
@@ -63,10 +63,42 @@ static void __head *fixup_pointer(void *ptr, unsigned long physaddr)
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
+	*fixup_long(&page_offset_base, physaddr) = __PAGE_OFFSET_BASE57;
+	*fixup_long(&vmalloc_base, physaddr) = __VMALLOC_BASE57;
+	*fixup_long(&vmemmap_base, physaddr) = __VMEMMAP_BASE57;
+
+	return;
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
@@ -74,6 +106,8 @@ unsigned long __head __startup_64(unsigned long physaddr,
 	pmdval_t *pmd, pmd_entry;
 	int i;
 
+	check_la57_support(physaddr);
+
 	/* Is the address too large? */
 	if (physaddr >> MAX_PHYSMEM_BITS)
 		for (;;);
@@ -168,8 +202,7 @@ unsigned long __head __startup_64(unsigned long physaddr,
 	 * Fixup phys_base - remove the memory encryption mask to obtain
 	 * the true physical address.
 	 */
-	p = fixup_pointer(&phys_base, physaddr);
-	*p += load_delta - sme_get_me_mask();
+	*fixup_long(&phys_base, physaddr) += load_delta - sme_get_me_mask();
 
 	/* Encrypt the kernel (if SME is active) */
 	sme_encrypt_kernel();
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 2be7d1e7fcf1..a8409cd23b35 100644
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
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index 5597dd0635dd..e29eb50ea2a9 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -43,7 +43,6 @@
  * before. You also need to add a BUILD_BUG_ON() in kernel_randomize_memory() to
  * ensure that this order is correct and won't be changed.
  */
-static const unsigned long vaddr_start = __PAGE_OFFSET_BASE;
 
 #if defined(CONFIG_X86_ESPFIX64)
 static const unsigned long vaddr_end = ESPFIX_BASE_ADDR;
@@ -63,7 +62,7 @@ static __initdata struct kaslr_memory_region {
 	unsigned long size_tb;
 } kaslr_regions[] = {
 	{ &page_offset_base, 0 },
-	{ &vmalloc_base, VMALLOC_SIZE_TB },
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
 
+	vaddr_start = pgtable_l5_enabled ? __PAGE_OFFSET_BASE57 : __PAGE_OFFSET_BASE48;
+	vaddr = vaddr_start;
+
 	/*
 	 * All these BUILD_BUG_ON checks ensures the memory layout is
 	 * consistent with the vaddr_start/vaddr_end variables.
@@ -107,6 +109,7 @@ void __init kernel_randomize_memory(void)
 		return;
 
 	kaslr_regions[0].size_tb = 1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT);
+	kaslr_regions[1].size_tb = VMALLOC_SIZE_TB;
 
 	/*
 	 * Update Physical memory mapping to available and
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
