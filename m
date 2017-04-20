Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE0326B03D9
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 12:23:01 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l196so81768746ioe.19
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 09:23:01 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b83si6874334pfl.225.2017.04.20.09.23.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 09:23:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 3/9] x86/boot/64: Rename init_level4_pgt and early_level4_pgt
Date: Thu, 20 Apr 2017 19:21:41 +0300
Message-Id: <20170420162147.86517-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170420162147.86517-1-kirill.shutemov@linux.intel.com>
References: <20170420162147.86517-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With CONFIG_X86_5LEVEL=y, level 4 is no longer top level of page tables.

Let's give these variable more generic names: init_top_pgt and
early_top_pgt.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable.h     |  2 +-
 arch/x86/include/asm/pgtable_64.h  |  4 ++--
 arch/x86/kernel/espfix_64.c        |  2 +-
 arch/x86/kernel/head64.c           | 18 +++++++++---------
 arch/x86/kernel/head_64.S          | 14 +++++++-------
 arch/x86/kernel/machine_kexec_64.c |  2 +-
 arch/x86/mm/dump_pagetables.c      |  2 +-
 arch/x86/mm/kasan_init_64.c        | 12 ++++++------
 arch/x86/realmode/init.c           |  2 +-
 arch/x86/xen/mmu.c                 | 18 +++++++++---------
 arch/x86/xen/xen-pvh.S             |  2 +-
 11 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 942482ac36a8..77037b6f1caa 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -922,7 +922,7 @@ extern pgd_t trampoline_pgd_entry;
 static inline void __meminit init_trampoline_default(void)
 {
 	/* Default trampoline pgd value */
-	trampoline_pgd_entry = init_level4_pgt[pgd_index(__PAGE_OFFSET)];
+	trampoline_pgd_entry = init_top_pgt[pgd_index(__PAGE_OFFSET)];
 }
 # ifdef CONFIG_RANDOMIZE_MEMORY
 void __meminit init_trampoline(void);
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 12ea31274eb6..affcb2a9c563 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -20,9 +20,9 @@ extern pmd_t level2_kernel_pgt[512];
 extern pmd_t level2_fixmap_pgt[512];
 extern pmd_t level2_ident_pgt[512];
 extern pte_t level1_fixmap_pgt[512];
-extern pgd_t init_level4_pgt[];
+extern pgd_t init_top_pgt[];
 
-#define swapper_pg_dir init_level4_pgt
+#define swapper_pg_dir init_top_pgt
 
 extern void paging_init(void);
 
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
index b59c550b1d3a..f8a2f34fa15d 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -33,7 +33,7 @@
 /*
  * Manage page tables very early on.
  */
-extern pgd_t early_level4_pgt[PTRS_PER_PGD];
+extern pgd_t early_top_pgt[PTRS_PER_PGD];
 extern pmd_t early_dynamic_pgts[EARLY_DYNAMIC_PAGE_TABLES][PTRS_PER_PMD];
 static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
@@ -67,7 +67,7 @@ void __init __startup_64(unsigned long physaddr)
 
 	/* Fixup the physical addresses in the page table */
 
-	pgd = fixup_pointer(&early_level4_pgt, physaddr);
+	pgd = fixup_pointer(&early_top_pgt, physaddr);
 	pgd[pgd_index(__START_KERNEL_map)] += load_delta;
 
 	pud = fixup_pointer(&level3_kernel_pgt, physaddr);
@@ -124,9 +124,9 @@ void __init __startup_64(unsigned long physaddr)
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
@@ -138,11 +138,11 @@ int __init early_make_pgtable(unsigned long address)
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
@@ -239,7 +239,7 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 
 	clear_bss();
 
-	clear_page(init_level4_pgt);
+	clear_page(init_top_pgt);
 
 	kasan_early_init();
 
@@ -254,8 +254,8 @@ asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
 	 */
 	load_ucode_bsp();
 
-	/* set init_level4_pgt kernel high mapping*/
-	init_level4_pgt[511] = early_level4_pgt[511];
+	/* set init_top_pgt kernel high mapping*/
+	init_top_pgt[511] = early_top_pgt[511];
 
 	x86_64_start_reservations(real_mode_data);
 }
diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 1432d530fa35..0ae0bad4d4d5 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -77,7 +77,7 @@ startup_64:
 	call	__startup_64
 	popq	%rsi
 
-	movq	$(early_level4_pgt - __START_KERNEL_map), %rax
+	movq	$(early_top_pgt - __START_KERNEL_map), %rax
 	jmp 1f
 ENTRY(secondary_startup_64)
 	/*
@@ -97,7 +97,7 @@ ENTRY(secondary_startup_64)
 	/* Sanitize CPU configuration */
 	call verify_cpu
 
-	movq	$(init_level4_pgt - __START_KERNEL_map), %rax
+	movq	$(init_top_pgt - __START_KERNEL_map), %rax
 1:
 
 	/* Enable PAE mode and PGE */
@@ -328,7 +328,7 @@ GLOBAL(name)
 	.endr
 
 	__INITDATA
-NEXT_PAGE(early_level4_pgt)
+NEXT_PAGE(early_top_pgt)
 	.fill	511,8,0
 	.quad	level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
 
@@ -338,14 +338,14 @@ NEXT_PAGE(early_dynamic_pgts)
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
+	.org    init_top_pgt + L4_PAGE_OFFSET*8, 0
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
-	.org    init_level4_pgt + L4_START_KERNEL*8, 0
+	.org    init_top_pgt + L4_START_KERNEL*8, 0
 	/* (2^48-(2*1024*1024*1024))/(2^39) = 511 */
 	.quad   level3_kernel_pgt - __START_KERNEL_map + _PAGE_TABLE
 
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
index bce6990b1d81..0470826d2bdc 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -431,7 +431,7 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 				       bool checkwx)
 {
 #ifdef CONFIG_X86_64
-	pgd_t *start = (pgd_t *) &init_level4_pgt;
+	pgd_t *start = (pgd_t *) &init_top_pgt;
 #else
 	pgd_t *start = swapper_pg_dir;
 #endif
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 0c7d8129bed6..88215ac16b24 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -12,7 +12,7 @@
 #include <asm/tlbflush.h>
 #include <asm/sections.h>
 
-extern pgd_t early_level4_pgt[PTRS_PER_PGD];
+extern pgd_t early_top_pgt[PTRS_PER_PGD];
 extern struct range pfn_mapped[E820_MAX_ENTRIES];
 
 static int __init map_range(struct range *range)
@@ -109,8 +109,8 @@ void __init kasan_early_init(void)
 	for (i = 0; CONFIG_PGTABLE_LEVELS >= 5 && i < PTRS_PER_P4D; i++)
 		kasan_zero_p4d[i] = __p4d(p4d_val);
 
-	kasan_map_early_shadow(early_level4_pgt);
-	kasan_map_early_shadow(init_level4_pgt);
+	kasan_map_early_shadow(early_top_pgt);
+	kasan_map_early_shadow(init_top_pgt);
 }
 
 void __init kasan_init(void)
@@ -121,8 +121,8 @@ void __init kasan_init(void)
 	register_die_notifier(&kasan_die_notifier);
 #endif
 
-	memcpy(early_level4_pgt, init_level4_pgt, sizeof(early_level4_pgt));
-	load_cr3(early_level4_pgt);
+	memcpy(early_top_pgt, init_top_pgt, sizeof(early_top_pgt));
+	load_cr3(early_top_pgt);
 	__flush_tlb_all();
 
 	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
@@ -148,7 +148,7 @@ void __init kasan_init(void)
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
index f226038a39ca..7c2081f78a19 100644
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -1531,8 +1531,8 @@ static void xen_write_cr3(unsigned long cr3)
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
@@ -1975,13 +1975,13 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
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
@@ -2012,11 +2012,11 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
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
 		set_page_prot(level3_user_vsyscall, PAGE_KERNEL_RO);
@@ -2027,7 +2027,7 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
 
 		/* Pin down new L4 */
 		pin_pagetable_pfn(MMUEXT_PIN_L4_TABLE,
-				  PFN_DOWN(__pa_symbol(init_level4_pgt)));
+				  PFN_DOWN(__pa_symbol(init_top_pgt)));
 
 		/* Unpin Xen-provided one */
 		pin_pagetable_pfn(MMUEXT_UNPIN_TABLE, PFN_DOWN(__pa(pgd)));
@@ -2038,10 +2038,10 @@ void __init xen_setup_kernel_pagetable(pgd_t *pgd, unsigned long max_pfn)
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
