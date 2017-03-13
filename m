Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 91ECF6B041C
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:50:46 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id y17so283725539pgh.2
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:50:46 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l3si10474533pgl.298.2017.03.12.22.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 22:50:44 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 21/26] x86/mm: add support of additional page table level during early boot
Date: Mon, 13 Mar 2017 08:50:15 +0300
Message-Id: <20170313055020.69655-22-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch adds support for 5-level paging during early boot.
It generalizes boot for 4- and 5-level paging on 64-bit systems with
compile-time switch between them.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/boot/compressed/head_64.S          | 23 +++++++++--
 arch/x86/include/asm/pgtable.h              |  2 +-
 arch/x86/include/asm/pgtable_64.h           |  6 ++-
 arch/x86/include/uapi/asm/processor-flags.h |  2 +
 arch/x86/kernel/espfix_64.c                 |  2 +-
 arch/x86/kernel/head64.c                    | 40 +++++++++++++-----
 arch/x86/kernel/head_64.S                   | 63 +++++++++++++++++++++--------
 arch/x86/kernel/machine_kexec_64.c          |  2 +-
 arch/x86/mm/dump_pagetables.c               |  2 +-
 arch/x86/mm/kasan_init_64.c                 | 12 +++---
 arch/x86/realmode/init.c                    |  2 +-
 arch/x86/xen/mmu.c                          | 38 ++++++++++-------
 arch/x86/xen/xen-pvh.S                      |  2 +-
 13 files changed, 136 insertions(+), 60 deletions(-)

diff --git a/arch/x86/boot/compressed/head_64.S b/arch/x86/boot/compressed/head_64.S
index d2ae1f821e0c..3ed26769810b 100644
--- a/arch/x86/boot/compressed/head_64.S
+++ b/arch/x86/boot/compressed/head_64.S
@@ -122,9 +122,12 @@ ENTRY(startup_32)
 	addl	%ebp, gdt+2(%ebp)
 	lgdt	gdt(%ebp)
 
-	/* Enable PAE mode */
+	/* Enable PAE and LA57 mode */
 	movl	%cr4, %eax
 	orl	$X86_CR4_PAE, %eax
+#ifdef CONFIG_X86_5LEVEL
+	orl	$X86_CR4_LA57, %eax
+#endif
 	movl	%eax, %cr4
 
  /*
@@ -136,13 +139,24 @@ ENTRY(startup_32)
 	movl	$(BOOT_INIT_PGT_SIZE/4), %ecx
 	rep	stosl
 
+	xorl	%edx, %edx
+
+	/* Build Top Level */
+	leal	pgtable(%ebx,%edx,1), %edi
+	leal	0x1007 (%edi), %eax
+	movl	%eax, 0(%edi)
+
+#ifdef CONFIG_X86_5LEVEL
 	/* Build Level 4 */
-	leal	pgtable + 0(%ebx), %edi
+	addl	$0x1000, %edx
+	leal	pgtable(%ebx,%edx), %edi
 	leal	0x1007 (%edi), %eax
 	movl	%eax, 0(%edi)
+#endif
 
 	/* Build Level 3 */
-	leal	pgtable + 0x1000(%ebx), %edi
+	addl	$0x1000, %edx
+	leal	pgtable(%ebx,%edx), %edi
 	leal	0x1007(%edi), %eax
 	movl	$4, %ecx
 1:	movl	%eax, 0x00(%edi)
@@ -152,7 +166,8 @@ ENTRY(startup_32)
 	jnz	1b
 
 	/* Build Level 2 */
-	leal	pgtable + 0x2000(%ebx), %edi
+	addl	$0x1000, %edx
+	leal	pgtable(%ebx,%edx), %edi
 	movl	$0x00000183, %eax
 	movl	$2048, %ecx
 1:	movl	%eax, 0(%edi)
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 90f32116acd8..6cefd861ac65 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -917,7 +917,7 @@ extern pgd_t trampoline_pgd_entry;
 static inline void __meminit init_trampoline_default(void)
 {
 	/* Default trampoline pgd value */
-	trampoline_pgd_entry = init_level4_pgt[pgd_index(__PAGE_OFFSET)];
+	trampoline_pgd_entry = init_top_pgt[pgd_index(__PAGE_OFFSET)];
 }
 # ifdef CONFIG_RANDOMIZE_MEMORY
 void __meminit init_trampoline(void);
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 9991224f6238..c9e41f1599dd 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -14,15 +14,17 @@
 #include <linux/bitops.h>
 #include <linux/threads.h>
 
+extern p4d_t level4_kernel_pgt[512];
+extern p4d_t level4_ident_pgt[512];
 extern pud_t level3_kernel_pgt[512];
 extern pud_t level3_ident_pgt[512];
 extern pmd_t level2_kernel_pgt[512];
 extern pmd_t level2_fixmap_pgt[512];
 extern pmd_t level2_ident_pgt[512];
 extern pte_t level1_fixmap_pgt[512];
-extern pgd_t init_level4_pgt[];
+extern pgd_t init_top_pgt[];
 
-#define swapper_pg_dir init_level4_pgt
+#define swapper_pg_dir init_top_pgt
 
 extern void paging_init(void);
 
diff --git a/arch/x86/include/uapi/asm/processor-flags.h b/arch/x86/include/uapi/asm/processor-flags.h
index 567de50a4c2a..185f3d10c194 100644
--- a/arch/x86/include/uapi/asm/processor-flags.h
+++ b/arch/x86/include/uapi/asm/processor-flags.h
@@ -104,6 +104,8 @@
 #define X86_CR4_OSFXSR		_BITUL(X86_CR4_OSFXSR_BIT)
 #define X86_CR4_OSXMMEXCPT_BIT	10 /* enable unmasked SSE exceptions */
 #define X86_CR4_OSXMMEXCPT	_BITUL(X86_CR4_OSXMMEXCPT_BIT)
+#define X86_CR4_LA57_BIT	12 /* enable 5-level page tables */
+#define X86_CR4_LA57		_BITUL(X86_CR4_LA57_BIT)
 #define X86_CR4_VMXE_BIT	13 /* enable VMX virtualization */
 #define X86_CR4_VMXE		_BITUL(X86_CR4_VMXE_BIT)
 #define X86_CR4_SMXE_BIT	14 /* enable safer mode (TXT) */
diff --git a/arch/x86/kernel/espfix_64.c b/arch/x86/kernel/espfix_64.c
index 8e598a1ad986..6b91e2eb8d3f 100644
--- a/arch/x86/kernel/espfix_64.c
+++ b/arch/x86/kernel/espfix_64.c
@@ -125,7 +125,7 @@ void __init init_espfix_bsp(void)
 	p4d_t *p4d;
 
 	/* Install the espfix pud into the kernel page directory */
-	pgd = &init_level4_pgt[pgd_index(ESPFIX_BASE_ADDR)];
+	pgd = &init_top_pgt[pgd_index(ESPFIX_BASE_ADDR)];
 	p4d = p4d_alloc(&init_mm, pgd, ESPFIX_BASE_ADDR);
 	p4d_populate(&init_mm, p4d, espfix_pud_page);
 
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 54a2372f5dbb..f32d22986f47 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -32,7 +32,7 @@
 /*
  * Manage page tables very early on.
  */
-extern pgd_t early_level4_pgt[PTRS_PER_PGD];
+extern pgd_t early_top_pgt[PTRS_PER_PGD];
 extern pmd_t early_dynamic_pgts[EARLY_DYNAMIC_PAGE_TABLES][PTRS_PER_PMD];
 static unsigned int __initdata next_early_pgt = 2;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
@@ -40,9 +40,9 @@ pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 /* Wipe all early page tables except for the kernel symbol map */
 static void __init reset_early_page_tables(void)
 {
-	memset(early_level4_pgt, 0, sizeof(pgd_t)*(PTRS_PER_PGD-1));
+	memset(early_top_pgt, 0, sizeof(pgd_t)*(PTRS_PER_PGD-1));
 	next_early_pgt = 0;
-	write_cr3(__pa_nodebug(early_level4_pgt));
+	write_cr3(__pa_nodebug(early_top_pgt));
 }
 
 /* Create a new PMD entry */
@@ -50,15 +50,16 @@ int __init early_make_pgtable(unsigned long address)
 {
 	unsigned long physaddr = address - __PAGE_OFFSET;
 	pgdval_t pgd, *pgd_p;
+	p4dval_t p4d, *p4d_p;
 	pudval_t pud, *pud_p;
 	pmdval_t pmd, *pmd_p;
 
 	/* Invalid address or early pgt is done ?  */
-	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_level4_pgt))
+	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_top_pgt))
 		return -1;
 
 again:
-	pgd_p = &early_level4_pgt[pgd_index(address)].pgd;
+	pgd_p = &early_top_pgt[pgd_index(address)].pgd;
 	pgd = *pgd_p;
 
 	/*
@@ -66,8 +67,25 @@ int __init early_make_pgtable(unsigned long address)
 	 * critical -- __PAGE_OFFSET would point us back into the dynamic
 	 * range and we might end up looping forever...
 	 */
-	if (pgd)
-		pud_p = (pudval_t *)((pgd & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
+	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+		p4d_p = pgd_p;
+	else if (pgd)
+		p4d_p = (p4dval_t *)((pgd & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
+	else {
+		if (next_early_pgt >= EARLY_DYNAMIC_PAGE_TABLES) {
+			reset_early_page_tables();
+			goto again;
+		}
+
+		p4d_p = (p4dval_t *)early_dynamic_pgts[next_early_pgt++];
+		memset(p4d_p, 0, sizeof(*p4d_p) * PTRS_PER_P4D);
+		*pgd_p = (pgdval_t)p4d_p - __START_KERNEL_map + phys_base + _KERNPG_TABLE;
+	}
+	p4d_p += p4d_index(address);
+	p4d = *p4d_p;
+
+	if (p4d)
+		pud_p = (pudval_t *)((p4d & PTE_PFN_MASK) + __START_KERNEL_map - phys_base);
 	else {
 		if (next_early_pgt >= EARLY_DYNAMIC_PAGE_TABLES) {
 			reset_early_page_tables();
@@ -76,7 +94,7 @@ int __init early_make_pgtable(unsigned long address)
 
 		pud_p = (pudval_t *)early_dynamic_pgts[next_early_pgt++];
 		memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
-		*pgd_p = (pgdval_t)pud_p - __START_KERNEL_map + phys_base + _KERNPG_TABLE;
+		*p4d_p = (p4dval_t)pud_p - __START_KERNEL_map + phys_base + _KERNPG_TABLE;
 	}
 	pud_p += pud_index(address);
 	pud = *pud_p;
@@ -155,7 +173,7 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 
 	clear_bss();
 
-	clear_page(init_level4_pgt);
+	clear_page(init_top_pgt);
 
 	kasan_early_init();
 
@@ -170,8 +188,8 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	 */
 	load_ucode_bsp();
 
-	/* set init_level4_pgt kernel high mapping*/
-	init_level4_pgt[511] = early_level4_pgt[511];
+	/* set init_top_pgt kernel high mapping*/
+	init_top_pgt[511] = early_top_pgt[511];
 
 	x86_64_start_reservations(real_mode_data);
 }
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index b467b14b03eb..fd1f88d94d6b 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -37,10 +37,14 @@
  *
  */
 
+#define p4d_index(x)	(((x) >> P4D_SHIFT) & (PTRS_PER_P4D-1))
 #define pud_index(x)	(((x) >> PUD_SHIFT) & (PTRS_PER_PUD-1))
 
-L4_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE)
-L4_START_KERNEL = pgd_index(__START_KERNEL_map)
+PGD_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE)
+PGD_START_KERNEL = pgd_index(__START_KERNEL_map)
+#ifdef CONFIG_X86_5LEVEL
+L4_START_KERNEL = p4d_index(__START_KERNEL_map)
+#endif
 L3_START_KERNEL = pud_index(__START_KERNEL_map)
 
 	.text
@@ -93,7 +97,11 @@ startup_64:
 	/*
 	 * Fixup the physical addresses in the page table
 	 */
-	addq	%rbp, early_level4_pgt + (L4_START_KERNEL*8)(%rip)
+	addq	%rbp, early_top_pgt + (PGD_START_KERNEL*8)(%rip)
+
+#ifdef CONFIG_X86_5LEVEL
+	addq	%rbp, level4_kernel_pgt + (511*8)(%rip)
+#endif
 
 	addq	%rbp, level3_kernel_pgt + (510*8)(%rip)
 	addq	%rbp, level3_kernel_pgt + (511*8)(%rip)
@@ -107,7 +115,7 @@ startup_64:
 	 * it avoids problems around wraparound.
 	 */
 	leaq	_text(%rip), %rdi
-	leaq	early_level4_pgt(%rip), %rbx
+	leaq	early_top_pgt(%rip), %rbx
 
 	movq	%rdi, %rax
 	shrq	$PGDIR_SHIFT, %rax
@@ -116,16 +124,26 @@ startup_64:
 	movq	%rdx, 0(%rbx,%rax,8)
 	movq	%rdx, 8(%rbx,%rax,8)
 
+#ifdef CONFIG_X86_5LEVEL
+	addq	$PAGE_SIZE, %rbx
+	addq	$PAGE_SIZE, %rdx
+	movq	%rdi, %rax
+	shrq	$P4D_SHIFT, %rax
+	andl	$(PTRS_PER_P4D-1), %eax
+	movq	%rdx, 0(%rbx,%rax,8)
+#endif
+
+	addq	$PAGE_SIZE, %rbx
 	addq	$PAGE_SIZE, %rdx
 	movq	%rdi, %rax
 	shrq	$PUD_SHIFT, %rax
 	andl	$(PTRS_PER_PUD-1), %eax
-	movq	%rdx, PAGE_SIZE(%rbx,%rax,8)
+	movq	%rdx, 0(%rbx,%rax,8)
 	incl	%eax
 	andl	$(PTRS_PER_PUD-1), %eax
-	movq	%rdx, PAGE_SIZE(%rbx,%rax,8)
+	movq	%rdx, 0(%rbx,%rax,8)
 
-	addq	$PAGE_SIZE * 2, %rbx
+	addq	$PAGE_SIZE, %rbx
 	movq	%rdi, %rax
 	shrq	$PMD_SHIFT, %rdi
 	addq	$(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL), %rax
@@ -166,7 +184,7 @@ startup_64:
 	addq	%rbp, phys_base(%rip)
 
 .Lskip_fixup:
-	movq	$(early_level4_pgt - __START_KERNEL_map), %rax
+	movq	$(early_top_pgt - __START_KERNEL_map), %rax
 	jmp 1f
 ENTRY(secondary_startup_64)
 	/*
@@ -186,14 +204,17 @@ ENTRY(secondary_startup_64)
 	/* Sanitize CPU configuration */
 	call verify_cpu
 
-	movq	$(init_level4_pgt - __START_KERNEL_map), %rax
+	movq	$(init_top_pgt - __START_KERNEL_map), %rax
 1:
 
-	/* Enable PAE mode and PGE */
+	/* Enable PAE mode, PGE and LA57 */
 	movl	$(X86_CR4_PAE | X86_CR4_PGE), %ecx
+#ifdef CONFIG_X86_5LEVEL
+	orl	$X86_CR4_LA57, %ecx
+#endif
 	movq	%rcx, %cr4
 
-	/* Setup early boot stage 4 level pagetables. */
+	/* Setup early boot stage 4-/5-level pagetables. */
 	addq	phys_base(%rip), %rax
 	movq	%rax, %cr3
 
@@ -419,9 +440,13 @@ GLOBAL(name)
 	.endr
 
 	__INITDATA
-NEXT_PAGE(early_level4_pgt)
+NEXT_PAGE(early_top_pgt)
 	.fill	511,8,0
+#ifdef CONFIG_X86_5LEVEL
+	.quad	level4_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
+#else
 	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
+#endif
 
 NEXT_PAGE(early_dynamic_pgts)
 	.fill	512*EARLY_DYNAMIC_PAGE_TABLES,8,0
@@ -429,14 +454,14 @@ NEXT_PAGE(early_dynamic_pgts)
 	.data
 
 #ifndef CONFIG_XEN
-NEXT_PAGE(init_level4_pgt)
+NEXT_PAGE(init_top_pgt)
 	.fill	512,8,0
 #else
-NEXT_PAGE(init_level4_pgt)
+NEXT_PAGE(init_top_pgt)
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
-	.org    init_level4_pgt + L4_PAGE_OFFSET*8, 0
+	.org    init_top_pgt + PGD_PAGE_OFFSET*8, 0
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
-	.org    init_level4_pgt + L4_START_KERNEL*8, 0
+	.org    init_top_pgt + PGD_START_KERNEL*8, 0
 	/* (2^48-(2*1024*1024*1024))/(2^39) = 511 */
 	.quad   level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
 
@@ -450,6 +475,12 @@ NEXT_PAGE(level2_ident_pgt)
 	PMDS(0, __PAGE_KERNEL_IDENT_LARGE_EXEC, PTRS_PER_PMD)
 #endif
 
+#ifdef CONFIG_X86_5LEVEL
+NEXT_PAGE(level4_kernel_pgt)
+	.fill	511,8,0
+	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
+#endif
+
 NEXT_PAGE(level3_kernel_pgt)
 	.fill	L3_START_KERNEL,8,0
 	/* (2^48-(2*1024*1024*1024)-((2^39)*511))/(2^30) = 510 */
diff --git a/arch/x86/kernel/machine_kexec_64.c b/arch/x86/kernel/machine_kexec_64.c
index 085c3b300d32..42f502b45e62 100644
--- a/arch/x86/kernel/machine_kexec_64.c
+++ b/arch/x86/kernel/machine_kexec_64.c
@@ -342,7 +342,7 @@ void machine_kexec(struct kimage *image)
 void arch_crash_save_vmcoreinfo(void)
 {
 	VMCOREINFO_NUMBER(phys_base);
-	VMCOREINFO_SYMBOL(init_level4_pgt);
+	VMCOREINFO_SYMBOL(init_top_pgt);
 
 #ifdef CONFIG_NUMA
 	VMCOREINFO_SYMBOL(node_data);
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 0effac6989cd..0431bfd5e09f 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -435,7 +435,7 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 				       bool checkwx)
 {
 #ifdef CONFIG_X86_64
-	pgd_t *start = (pgd_t *) &init_level4_pgt;
+	pgd_t *start = (pgd_t *) &init_top_pgt;
 #else
 	pgd_t *start = swapper_pg_dir;
 #endif
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index bcabc56e0dc4..a25dd40a0683 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -10,7 +10,7 @@
 #include <asm/tlbflush.h>
 #include <asm/sections.h>
 
-extern pgd_t early_level4_pgt[PTRS_PER_PGD];
+extern pgd_t early_top_pgt[PTRS_PER_PGD];
 extern struct range pfn_mapped[E820_X_MAX];
 
 static int __init map_range(struct range *range)
@@ -103,8 +103,8 @@ void __init kasan_early_init(void)
 	for (i = 0; CONFIG_PGTABLE_LEVELS >= 5 && i < PTRS_PER_P4D; i++)
 		kasan_zero_p4d[i] = __p4d(p4d_val);
 
-	kasan_map_early_shadow(early_level4_pgt);
-	kasan_map_early_shadow(init_level4_pgt);
+	kasan_map_early_shadow(early_top_pgt);
+	kasan_map_early_shadow(init_top_pgt);
 }
 
 void __init kasan_init(void)
@@ -115,8 +115,8 @@ void __init kasan_init(void)
 	register_die_notifier(&kasan_die_notifier);
 #endif
 
-	memcpy(early_level4_pgt, init_level4_pgt, sizeof(early_level4_pgt));
-	load_cr3(early_level4_pgt);
+	memcpy(early_top_pgt, init_top_pgt, sizeof(early_top_pgt));
+	load_cr3(early_top_pgt);
 	__flush_tlb_all();
 
 	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
@@ -142,7 +142,7 @@ void __init kasan_init(void)
 	kasan_populate_zero_shadow(kasan_mem_to_shadow((void *)MODULES_END),
 			(void *)KASAN_SHADOW_END);
 
-	load_cr3(init_level4_pgt);
+	load_cr3(init_top_pgt);
 	__flush_tlb_all();
 
 	/*
diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
index 5db706f14111..dc0836d5c5eb 100644
--- a/arch/x86/realmode/init.c
+++ b/arch/x86/realmode/init.c
@@ -102,7 +102,7 @@ static void __init setup_real_mode(void)
 
 	trampoline_pgd = (u64 *) __va(real_mode_header->trampoline_pgd);
 	trampoline_pgd[0] = trampoline_pgd_entry.pgd;
-	trampoline_pgd[511] = init_level4_pgt[511].pgd;
+	trampoline_pgd[511] = init_top_pgt[511].pgd;
 #endif
 }
 
diff --git a/arch/x86/xen/mmu.c b/arch/x86/xen/mmu.c
index abb3a7701bc7..d66b7e79781a 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -97,7 +97,11 @@ static RESERVE_BRK_ARRAY(pte_t, level1_ident_pgt, LEVEL1_IDENT_ENTRIES);
 #endif
 #ifdef CONFIG_X86_64
 /* l3 pud for userspace vsyscall mapping */
-static pud_t level3_user_vsyscall[PTRS_PER_PUD] __page_aligned_bss;
+#if CONFIG_PGTABLE_LEVELS == 5
+static p4d_t user_vsyscall[PTRS_PER_P4D] __page_aligned_bss;
+#else
+static pud_t user_vsyscall[PTRS_PER_PUD] __page_aligned_bss;
+#endif
 #endif /* CONFIG_X86_64 */
 
 /*
@@ -504,7 +508,7 @@ __visible pmd_t xen_make_pmd(pmdval_t pmd)
 }
 PV_CALLEE_SAVE_REGS_THUNK(xen_make_pmd);
 
-#if CONFIG_PGTABLE_LEVELS == 4
+#if CONFIG_PGTABLE_LEVELS >= 4
 __visible pudval_t xen_pud_val(pud_t pud)
 {
 	return pte_mfn_to_pfn(pud.pud);
@@ -1531,8 +1535,8 @@ static void xen_write_cr3(unsigned long cr3)
  * At the start of the day - when Xen launches a guest, it has already
  * built pagetables for the guest. We diligently look over them
  * in xen_setup_kernel_pagetable and graft as appropriate them in the
- * init_level4_pgt and its friends. Then when we are happy we load
- * the new init_level4_pgt - and continue on.
+ * init_top_pgt and its friends. Then when we are happy we load
+ * the new init_top_pgt - and continue on.
  *
  * The generic code starts (start_kernel) and 'init_mem_mapping' sets
  * up the rest of the pagetables. When it has completed it loads the cr3.
@@ -1585,7 +1589,7 @@ static int xen_pgd_alloc(struct mm_struct *mm)
 		if (user_pgd != NULL) {
 #ifdef CONFIG_X86_VSYSCALL_EMULATION
 			user_pgd[pgd_index(VSYSCALL_ADDR)] =
-				__pgd(__pa(level3_user_vsyscall) | _PAGE_TABLE);
+				__pgd(__pa(user_vsyscall) | _PAGE_TABLE);
 #endif
 			ret = 0;
 		}
@@ -1975,13 +1979,13 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 	pt_end = pt_base + xen_start_info->nr_pt_frames;
 
 	/* Zap identity mapping */
-	init_level4_pgt[0] = __pgd(0);
+	init_top_pgt[0] = __pgd(0);
 
 	if (!xen_feature(XENFEAT_auto_translated_physmap)) {
 		/* Pre-constructed entries are in pfn, so convert to mfn */
 		/* L4[272] -> level3_ident_pgt
 		 * L4[511] -> level3_kernel_pgt */
-		convert_pfn_mfn(init_level4_pgt);
+		convert_pfn_mfn(init_top_pgt);
 
 		/* L3_i[0] -> level2_ident_pgt */
 		convert_pfn_mfn(level3_ident_pgt);
@@ -2012,14 +2016,14 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 	/* Copy the initial P->M table mappings if necessary. */
 	i = pgd_index(xen_start_info->mfn_list);
 	if (i && i < pgd_index(__START_KERNEL_map))
-		init_level4_pgt[i] = ((pgd_t *)xen_start_info->pt_base)[i];
+		init_top_pgt[i] = ((pgd_t *)xen_start_info->pt_base)[i];
 
 	if (!xen_feature(XENFEAT_auto_translated_physmap)) {
 		/* Make pagetable pieces RO */
-		set_page_prot(init_level4_pgt, PAGE_KERNEL_RO);
+		set_page_prot(init_top_pgt, PAGE_KERNEL_RO);
 		set_page_prot(level3_ident_pgt, PAGE_KERNEL_RO);
 		set_page_prot(level3_kernel_pgt, PAGE_KERNEL_RO);
-		set_page_prot(level3_user_vsyscall, PAGE_KERNEL_RO);
+		set_page_prot(user_vsyscall, PAGE_KERNEL_RO);
 		set_page_prot(level2_ident_pgt, PAGE_KERNEL_RO);
 		set_page_prot(level2_kernel_pgt, PAGE_KERNEL_RO);
 		set_page_prot(level2_fixmap_pgt, PAGE_KERNEL_RO);
@@ -2027,7 +2031,7 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 
 		/* Pin down new L4 */
 		pin_pagetable_pfn(MMUEXT_PIN_L4_TABLE,
-				  PFN_DOWN(__pa_symbol(init_level4_pgt)));
+				  PFN_DOWN(__pa_symbol(init_top_pgt)));
 
 		/* Unpin Xen-provided one */
 		pin_pagetable_pfn(MMUEXT_UNPIN_TABLE, PFN_DOWN(__pa(pgd)));
@@ -2038,10 +2042,10 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 		 * pgd.
 		 */
 		xen_mc_batch();
-		__xen_write_cr3(true, __pa(init_level4_pgt));
+		__xen_write_cr3(true, __pa(init_top_pgt));
 		xen_mc_issue(PARAVIRT_LAZY_CPU);
 	} else
-		native_write_cr3(__pa(init_level4_pgt));
+		native_write_cr3(__pa(init_top_pgt));
 
 	/* We can't that easily rip out L3 and L2, as the Xen pagetables are
 	 * set out this way: [L4], [L1], [L2], [L3], [L1], [L1] ...  for
@@ -2446,7 +2450,11 @@ static void xen_set_fixmap(unsigned idx, phys_addr_t phys, pgprot_t prot)
 	   pagetable vsyscall mapping. */
 	if (idx == VSYSCALL_PAGE) {
 		unsigned long vaddr = __fix_to_virt(idx);
-		set_pte_vaddr_pud(level3_user_vsyscall, vaddr, pte);
+#if CONFIG_PGTABLE_LEVELS == 5
+		set_pte_vaddr_p4d(user_vsyscall, vaddr, pte);
+#else
+		set_pte_vaddr_pud(user_vsyscall, vaddr, pte);
+#endif
 	}
 #endif
 }
@@ -2477,7 +2485,7 @@ static void __init xen_post_allocator_init(void)
 
 #ifdef CONFIG_X86_64
 	pv_mmu_ops.write_cr3 = &xen_write_cr3;
-	SetPagePinned(virt_to_page(level3_user_vsyscall));
+	SetPagePinned(virt_to_page(user_vsyscall));
 #endif
 	xen_mark_init_mm_pinned();
 }
diff --git a/arch/x86/xen/xen-pvh.S b/arch/x86/xen/xen-pvh.S
index 5e246716d58f..e1a5fbeae08d 100644
--- a/arch/x86/xen/xen-pvh.S
+++ b/arch/x86/xen/xen-pvh.S
@@ -87,7 +87,7 @@ ENTRY(pvh_start_xen)
 	wrmsr
 
 	/* Enable pre-constructed page tables. */
-	mov $_pa(init_level4_pgt), %eax
+	mov $_pa(init_top_pgt), %eax
 	mov %eax, %cr3
 	mov $(X86_CR0_PG | X86_CR0_PE), %eax
 	mov %eax, %cr0
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
