Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 32F7A6B0390
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 20:17:14 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id g187so7203999itc.2
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 17:17:14 -0800 (PST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com. [209.85.214.41])
        by mx.google.com with ESMTPS id 93si4096797ios.234.2016.11.17.17.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 17:17:13 -0800 (PST)
Received: by mail-it0-f41.google.com with SMTP id c20so6033729itb.0
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 17:17:13 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 5/6] arm64: Use __pa_symbol for kernel symbols
Date: Thu, 17 Nov 2016 17:16:55 -0800
Message-Id: <1479431816-5028-6-git-send-email-labbott@redhat.com>
In-Reply-To: <1479431816-5028-1-git-send-email-labbott@redhat.com>
References: <1479431816-5028-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org


__pa_symbol is technically the marco that should be used for kernel
symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL which
will do bounds checking.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
v3: Conversion of more sites besides just _end. Addition of __lm_sym_addr
macro to take care of the _va(__pa_symbol(..)) idiom.

Note that a copy of __pa_symbol was added to avoid a mess of headers
since the #ifndef __pa_symbol case is defined in linux/mm.h
---
 arch/arm64/include/asm/kvm_mmu.h          |  4 ++--
 arch/arm64/include/asm/memory.h           |  6 ++++++
 arch/arm64/include/asm/mmu_context.h      |  6 +++---
 arch/arm64/include/asm/pgtable.h          |  2 +-
 arch/arm64/kernel/acpi_parking_protocol.c |  2 +-
 arch/arm64/kernel/cpufeature.c            |  2 +-
 arch/arm64/kernel/hibernate.c             |  9 +++------
 arch/arm64/kernel/insn.c                  |  2 +-
 arch/arm64/kernel/psci.c                  |  2 +-
 arch/arm64/kernel/setup.c                 |  8 ++++----
 arch/arm64/kernel/smp_spin_table.c        |  2 +-
 arch/arm64/kernel/vdso.c                  |  4 ++--
 arch/arm64/mm/init.c                      | 11 ++++++-----
 arch/arm64/mm/mmu.c                       | 24 ++++++++++++------------
 drivers/firmware/psci.c                   |  2 +-
 15 files changed, 45 insertions(+), 41 deletions(-)

diff --git a/arch/arm64/include/asm/kvm_mmu.h b/arch/arm64/include/asm/kvm_mmu.h
index 6f72fe8..79a472c 100644
--- a/arch/arm64/include/asm/kvm_mmu.h
+++ b/arch/arm64/include/asm/kvm_mmu.h
@@ -47,7 +47,7 @@
  * If the page is in the bottom half, we have to use the top half. If
  * the page is in the top half, we have to use the bottom half:
  *
- * T = __virt_to_phys(__hyp_idmap_text_start)
+ * T = __pa_symbol(__hyp_idmap_text_start)
  * if (T & BIT(VA_BITS - 1))
  *	HYP_VA_MIN = 0  //idmap in upper half
  * else
@@ -271,7 +271,7 @@ static inline void __kvm_flush_dcache_pud(pud_t pud)
 	kvm_flush_dcache_to_poc(page_address(page), PUD_SIZE);
 }
 
-#define kvm_virt_to_phys(x)		__virt_to_phys((unsigned long)(x))
+#define kvm_virt_to_phys(x)		__pa_symbol((unsigned long)(x))
 
 void kvm_set_way_flush(struct kvm_vcpu *vcpu);
 void kvm_toggle_cache(struct kvm_vcpu *vcpu, bool was_enabled);
diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index d773e2c..1e65299 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -202,11 +202,17 @@ static inline void *phys_to_virt(phys_addr_t x)
  * Drivers should NOT use these either.
  */
 #define __pa(x)			__virt_to_phys((unsigned long)(x))
+#define __pa_symbol(x)		__pa(RELOC_HIDE((unsigned long)(x), 0))
 #define __va(x)			((void *)__phys_to_virt((phys_addr_t)(x)))
 #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
 #define virt_to_pfn(x)      __phys_to_pfn(__virt_to_phys((unsigned long)(x)))
 
 /*
+ * translates a kernel image symbol address into its linear alias.
+ */
+#define __lm_sym_addr(x)	__va(__pa_symbol(x))
+
+/*
  *  virt_to_page(k)	convert a _valid_ virtual address to struct page *
  *  virt_addr_valid(k)	indicates whether a virtual address is valid
  */
diff --git a/arch/arm64/include/asm/mmu_context.h b/arch/arm64/include/asm/mmu_context.h
index a501853..0322322 100644
--- a/arch/arm64/include/asm/mmu_context.h
+++ b/arch/arm64/include/asm/mmu_context.h
@@ -44,7 +44,7 @@ static inline void contextidr_thread_switch(struct task_struct *next)
  */
 static inline void cpu_set_reserved_ttbr0(void)
 {
-	unsigned long ttbr = virt_to_phys(empty_zero_page);
+	unsigned long ttbr = __pa_symbol(empty_zero_page);
 
 	write_sysreg(ttbr, ttbr0_el1);
 	isb();
@@ -113,7 +113,7 @@ static inline void cpu_install_idmap(void)
 	local_flush_tlb_all();
 	cpu_set_idmap_tcr_t0sz();
 
-	cpu_switch_mm(idmap_pg_dir, &init_mm);
+	cpu_switch_mm(__lm_sym_addr(idmap_pg_dir), &init_mm);
 }
 
 /*
@@ -128,7 +128,7 @@ static inline void cpu_replace_ttbr1(pgd_t *pgd)
 
 	phys_addr_t pgd_phys = virt_to_phys(pgd);
 
-	replace_phys = (void *)virt_to_phys(idmap_cpu_replace_ttbr1);
+	replace_phys = (void *)__pa_symbol(idmap_cpu_replace_ttbr1);
 
 	cpu_install_idmap();
 	replace_phys(pgd_phys);
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index ffbb9a5..c2041a3 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -52,7 +52,7 @@ extern void __pgd_error(const char *file, int line, unsigned long val);
  * for zero-mapped memory areas etc..
  */
 extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
-#define ZERO_PAGE(vaddr)	pfn_to_page(PHYS_PFN(__pa(empty_zero_page)))
+#define ZERO_PAGE(vaddr)	pfn_to_page(PHYS_PFN(__pa_symbol(empty_zero_page)))
 
 #define pte_ERROR(pte)		__pte_error(__FILE__, __LINE__, pte_val(pte))
 
diff --git a/arch/arm64/kernel/acpi_parking_protocol.c b/arch/arm64/kernel/acpi_parking_protocol.c
index a32b401..df58310 100644
--- a/arch/arm64/kernel/acpi_parking_protocol.c
+++ b/arch/arm64/kernel/acpi_parking_protocol.c
@@ -109,7 +109,7 @@ static int acpi_parking_protocol_cpu_boot(unsigned int cpu)
 	 * that read this address need to convert this address to the
 	 * Boot-Loader's endianness before jumping.
 	 */
-	writeq_relaxed(__pa(secondary_entry), &mailbox->entry_point);
+	writeq_relaxed(__pa_symbol(secondary_entry), &mailbox->entry_point);
 	writel_relaxed(cpu_entry->gic_cpu_id, &mailbox->cpu_id);
 
 	arch_send_wakeup_ipi_mask(cpumask_of(cpu));
diff --git a/arch/arm64/kernel/cpufeature.c b/arch/arm64/kernel/cpufeature.c
index c02504e..6ccadf2 100644
--- a/arch/arm64/kernel/cpufeature.c
+++ b/arch/arm64/kernel/cpufeature.c
@@ -736,7 +736,7 @@ static bool runs_at_el2(const struct arm64_cpu_capabilities *entry, int __unused
 static bool hyp_offset_low(const struct arm64_cpu_capabilities *entry,
 			   int __unused)
 {
-	phys_addr_t idmap_addr = virt_to_phys(__hyp_idmap_text_start);
+	phys_addr_t idmap_addr = __pa_symbol(__hyp_idmap_text_start);
 
 	/*
 	 * Activate the lower HYP offset only if:
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
index d55a7b0..7103b8b 100644
--- a/arch/arm64/kernel/hibernate.c
+++ b/arch/arm64/kernel/hibernate.c
@@ -50,9 +50,6 @@
  */
 extern int in_suspend;
 
-/* Find a symbols alias in the linear map */
-#define LMADDR(x)	phys_to_virt(virt_to_phys(x))
-
 /* Do we need to reset el2? */
 #define el2_reset_needed() (is_hyp_mode_available() && !is_kernel_in_hyp_mode())
 
@@ -125,12 +122,12 @@ int arch_hibernation_header_save(void *addr, unsigned int max_size)
 		return -EOVERFLOW;
 
 	arch_hdr_invariants(&hdr->invariants);
-	hdr->ttbr1_el1		= virt_to_phys(swapper_pg_dir);
+	hdr->ttbr1_el1		= __pa_symbol(swapper_pg_dir);
 	hdr->reenter_kernel	= _cpu_resume;
 
 	/* We can't use __hyp_get_vectors() because kvm may still be loaded */
 	if (el2_reset_needed())
-		hdr->__hyp_stub_vectors = virt_to_phys(__hyp_stub_vectors);
+		hdr->__hyp_stub_vectors = __pa_symbol(__hyp_stub_vectors);
 	else
 		hdr->__hyp_stub_vectors = 0;
 
@@ -484,7 +481,7 @@ int swsusp_arch_resume(void)
 	 * Since we only copied the linear map, we need to find restore_pblist's
 	 * linear map address.
 	 */
-	lm_restore_pblist = LMADDR(restore_pblist);
+	lm_restore_pblist = __lm_sym_addr(restore_pblist);
 
 	/*
 	 * We need a zero page that is zero before & after resume in order to
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 6f2ac4f..af8967a 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -97,7 +97,7 @@ static void __kprobes *patch_map(void *addr, int fixmap)
 	if (module && IS_ENABLED(CONFIG_DEBUG_SET_MODULE_RONX))
 		page = vmalloc_to_page(addr);
 	else if (!module)
-		page = pfn_to_page(PHYS_PFN(__pa(addr)));
+		page = pfn_to_page(PHYS_PFN(__pa_symbol(addr)));
 	else
 		return addr;
 
diff --git a/arch/arm64/kernel/psci.c b/arch/arm64/kernel/psci.c
index 42816be..f0f2abb 100644
--- a/arch/arm64/kernel/psci.c
+++ b/arch/arm64/kernel/psci.c
@@ -45,7 +45,7 @@ static int __init cpu_psci_cpu_prepare(unsigned int cpu)
 
 static int cpu_psci_cpu_boot(unsigned int cpu)
 {
-	int err = psci_ops.cpu_on(cpu_logical_map(cpu), __pa(secondary_entry));
+	int err = psci_ops.cpu_on(cpu_logical_map(cpu), __pa_symbol(secondary_entry));
 	if (err)
 		pr_err("failed to boot CPU%d (%d)\n", cpu, err);
 
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index f534f49..e2dbc02 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -199,10 +199,10 @@ static void __init request_standard_resources(void)
 	struct memblock_region *region;
 	struct resource *res;
 
-	kernel_code.start   = virt_to_phys(_text);
-	kernel_code.end     = virt_to_phys(__init_begin - 1);
-	kernel_data.start   = virt_to_phys(_sdata);
-	kernel_data.end     = virt_to_phys(_end - 1);
+	kernel_code.start   = __pa_symbol(_text);
+	kernel_code.end     = __pa_symbol(__init_begin - 1);
+	kernel_data.start   = __pa_symbol(_sdata);
+	kernel_data.end     = __pa_symbol(_end - 1);
 
 	for_each_memblock(memory, region) {
 		res = alloc_bootmem_low(sizeof(*res));
diff --git a/arch/arm64/kernel/smp_spin_table.c b/arch/arm64/kernel/smp_spin_table.c
index 9a00eee..25fccca 100644
--- a/arch/arm64/kernel/smp_spin_table.c
+++ b/arch/arm64/kernel/smp_spin_table.c
@@ -98,7 +98,7 @@ static int smp_spin_table_cpu_prepare(unsigned int cpu)
 	 * boot-loader's endianess before jumping. This is mandated by
 	 * the boot protocol.
 	 */
-	writeq_relaxed(__pa(secondary_holding_pen), release_addr);
+	writeq_relaxed(__pa_symbol(secondary_holding_pen), release_addr);
 	__flush_dcache_area((__force void *)release_addr,
 			    sizeof(*release_addr));
 
diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
index a2c2478..791e87a 100644
--- a/arch/arm64/kernel/vdso.c
+++ b/arch/arm64/kernel/vdso.c
@@ -140,11 +140,11 @@ static int __init vdso_init(void)
 		return -ENOMEM;
 
 	/* Grab the vDSO data page. */
-	vdso_pagelist[0] = pfn_to_page(PHYS_PFN(__pa(vdso_data)));
+	vdso_pagelist[0] = pfn_to_page(PHYS_PFN(__pa_symbol(vdso_data)));
 
 	/* Grab the vDSO code pages. */
 	for (i = 0; i < vdso_pages; i++)
-		vdso_pagelist[i + 1] = pfn_to_page(PHYS_PFN(__pa(&vdso_start)) + i);
+		vdso_pagelist[i + 1] = pfn_to_page(PHYS_PFN(__pa_symbol(&vdso_start)) + i);
 
 	vdso_spec[0].pages = &vdso_pagelist[0];
 	vdso_spec[1].pages = &vdso_pagelist[1];
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 212c4d1..a2981a7 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -209,8 +209,8 @@ void __init arm64_memblock_init(void)
 	 * linear mapping. Take care not to clip the kernel which may be
 	 * high in memory.
 	 */
-	memblock_remove(max_t(u64, memstart_addr + linear_region_size, __pa(_end)),
-			ULLONG_MAX);
+	memblock_remove(max_t(u64, memstart_addr + linear_region_size,
+			__pa_symbol(_end)), ULLONG_MAX);
 	if (memstart_addr + linear_region_size < memblock_end_of_DRAM()) {
 		/* ensure that memstart_addr remains sufficiently aligned */
 		memstart_addr = round_up(memblock_end_of_DRAM() - linear_region_size,
@@ -225,7 +225,7 @@ void __init arm64_memblock_init(void)
 	 */
 	if (memory_limit != (phys_addr_t)ULLONG_MAX) {
 		memblock_mem_limit_remove_map(memory_limit);
-		memblock_add(__pa(_text), (u64)(_end - _text));
+		memblock_add(__pa_symbol(_text), (u64)(_end - _text));
 	}
 
 	if (IS_ENABLED(CONFIG_BLK_DEV_INITRD) && initrd_start) {
@@ -278,7 +278,7 @@ void __init arm64_memblock_init(void)
 	 * Register the kernel text, kernel data, initrd, and initial
 	 * pagetables with memblock.
 	 */
-	memblock_reserve(__pa(_text), _end - _text);
+	memblock_reserve(__pa_symbol(_text), _end - _text);
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (initrd_start) {
 		memblock_reserve(initrd_start, initrd_end - initrd_start);
@@ -483,7 +483,8 @@ void __init mem_init(void)
 
 void free_initmem(void)
 {
-	free_reserved_area(__va(__pa(__init_begin)), __va(__pa(__init_end)),
+	free_reserved_area(__lm_sym_addr(__init_begin),
+			   __lm_sym_addr(__init_end),
 			   0, "unused kernel");
 	/*
 	 * Unmap the __init region but leave the VM area in place. This
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 05615a3..cf04157 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -319,8 +319,8 @@ static void create_mapping_late(phys_addr_t phys, unsigned long virt,
 
 static void __init __map_memblock(pgd_t *pgd, phys_addr_t start, phys_addr_t end)
 {
-	unsigned long kernel_start = __pa(_text);
-	unsigned long kernel_end = __pa(__init_begin);
+	unsigned long kernel_start = __pa_symbol(_text);
+	unsigned long kernel_end = __pa_symbol(__init_begin);
 
 	/*
 	 * Take care not to create a writable alias for the
@@ -387,21 +387,21 @@ void mark_rodata_ro(void)
 	unsigned long section_size;
 
 	section_size = (unsigned long)_etext - (unsigned long)_text;
-	create_mapping_late(__pa(_text), (unsigned long)_text,
+	create_mapping_late(__pa_symbol(_text), (unsigned long)_text,
 			    section_size, PAGE_KERNEL_ROX);
 	/*
 	 * mark .rodata as read only. Use __init_begin rather than __end_rodata
 	 * to cover NOTES and EXCEPTION_TABLE.
 	 */
 	section_size = (unsigned long)__init_begin - (unsigned long)__start_rodata;
-	create_mapping_late(__pa(__start_rodata), (unsigned long)__start_rodata,
+	create_mapping_late(__pa_symbol(__start_rodata), (unsigned long)__start_rodata,
 			    section_size, PAGE_KERNEL_RO);
 }
 
 static void __init map_kernel_segment(pgd_t *pgd, void *va_start, void *va_end,
 				      pgprot_t prot, struct vm_struct *vma)
 {
-	phys_addr_t pa_start = __pa(va_start);
+	phys_addr_t pa_start = __pa_symbol(va_start);
 	unsigned long size = va_end - va_start;
 
 	BUG_ON(!PAGE_ALIGNED(pa_start));
@@ -449,7 +449,7 @@ static void __init map_kernel(pgd_t *pgd)
 		 */
 		BUG_ON(!IS_ENABLED(CONFIG_ARM64_16K_PAGES));
 		set_pud(pud_set_fixmap_offset(pgd, FIXADDR_START),
-			__pud(__pa(bm_pmd) | PUD_TYPE_TABLE));
+			__pud(__pa_symbol(bm_pmd) | PUD_TYPE_TABLE));
 		pud_clear_fixmap();
 	} else {
 		BUG();
@@ -480,7 +480,7 @@ void __init paging_init(void)
 	 */
 	cpu_replace_ttbr1(__va(pgd_phys));
 	memcpy(swapper_pg_dir, pgd, PAGE_SIZE);
-	cpu_replace_ttbr1(swapper_pg_dir);
+	cpu_replace_ttbr1(__lm_sym_addr(swapper_pg_dir));
 
 	pgd_clear_fixmap();
 	memblock_free(pgd_phys, PAGE_SIZE);
@@ -489,7 +489,7 @@ void __init paging_init(void)
 	 * We only reuse the PGD from the swapper_pg_dir, not the pud + pmd
 	 * allocated with it.
 	 */
-	memblock_free(__pa(swapper_pg_dir) + PAGE_SIZE,
+	memblock_free(__pa_symbol(swapper_pg_dir) + PAGE_SIZE,
 		      SWAPPER_DIR_SIZE - PAGE_SIZE);
 }
 
@@ -609,7 +609,7 @@ void __init early_fixmap_init(void)
 
 	pgd = pgd_offset_k(addr);
 	if (CONFIG_PGTABLE_LEVELS > 3 &&
-	    !(pgd_none(*pgd) || pgd_page_paddr(*pgd) == __pa(bm_pud))) {
+	    !(pgd_none(*pgd) || pgd_page_paddr(*pgd) == __pa_symbol(bm_pud))) {
 		/*
 		 * We only end up here if the kernel mapping and the fixmap
 		 * share the top level pgd entry, which should only happen on
@@ -618,12 +618,12 @@ void __init early_fixmap_init(void)
 		BUG_ON(!IS_ENABLED(CONFIG_ARM64_16K_PAGES));
 		pud = pud_offset_kimg(pgd, addr);
 	} else {
-		pgd_populate(&init_mm, pgd, bm_pud);
+		pgd_populate(&init_mm, pgd, __lm_sym_addr(bm_pud));
 		pud = fixmap_pud(addr);
 	}
-	pud_populate(&init_mm, pud, bm_pmd);
+	pud_populate(&init_mm, pud, __lm_sym_addr(bm_pmd));
 	pmd = fixmap_pmd(addr);
-	pmd_populate_kernel(&init_mm, pmd, bm_pte);
+	pmd_populate_kernel(&init_mm, pmd, __lm_sym_addr(bm_pte));
 
 	/*
 	 * The boot-ioremap range spans multiple pmds, for which
diff --git a/drivers/firmware/psci.c b/drivers/firmware/psci.c
index 8263429..9defbe2 100644
--- a/drivers/firmware/psci.c
+++ b/drivers/firmware/psci.c
@@ -383,7 +383,7 @@ static int psci_suspend_finisher(unsigned long index)
 	u32 *state = __this_cpu_read(psci_power_state);
 
 	return psci_ops.cpu_suspend(state[index - 1],
-				    virt_to_phys(cpu_resume));
+				    __pa_symbol(cpu_resume));
 }
 
 int psci_cpu_suspend_enter(unsigned long index)
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
