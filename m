Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 245DB6B0269
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 12:22:24 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id y1so251413033qkd.6
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:22:24 -0800 (PST)
Received: from mail-qt0-f170.google.com (mail-qt0-f170.google.com. [209.85.216.170])
        by mx.google.com with ESMTPS id l2si25187765qta.190.2017.01.03.09.22.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 09:22:22 -0800 (PST)
Received: by mail-qt0-f170.google.com with SMTP id k15so229563998qtg.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:22:22 -0800 (PST)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv6 06/11] arm64: Use __pa_symbol for kernel symbols
Date: Tue,  3 Jan 2017 09:21:48 -0800
Message-Id: <1483464113-1587-7-git-send-email-labbott@redhat.com>
In-Reply-To: <1483464113-1587-1-git-send-email-labbott@redhat.com>
References: <1483464113-1587-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org

__pa_symbol is technically the marcro that should be used for kernel
symbols. Switch to this as a pre-requisite for DEBUG_VIRTUAL which
will do bounds checking.

Reviewed-by: Mark Rutland <mark.rutland@arm.com>
Tested-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Laura Abbott <labbott@redhat.com>
---
 arch/arm64/include/asm/kvm_mmu.h          |  4 ++--
 arch/arm64/include/asm/memory.h           |  1 +
 arch/arm64/include/asm/mmu_context.h      |  6 +++---
 arch/arm64/include/asm/pgtable.h          |  2 +-
 arch/arm64/kernel/acpi_parking_protocol.c |  3 ++-
 arch/arm64/kernel/cpu-reset.h             |  2 +-
 arch/arm64/kernel/cpufeature.c            |  3 ++-
 arch/arm64/kernel/hibernate.c             | 20 +++++--------------
 arch/arm64/kernel/insn.c                  |  2 +-
 arch/arm64/kernel/psci.c                  |  3 ++-
 arch/arm64/kernel/setup.c                 |  9 +++++----
 arch/arm64/kernel/smp_spin_table.c        |  3 ++-
 arch/arm64/kernel/vdso.c                  |  8 ++++++--
 arch/arm64/mm/init.c                      | 12 ++++++-----
 arch/arm64/mm/kasan_init.c                | 22 ++++++++++++++-------
 arch/arm64/mm/mmu.c                       | 33 ++++++++++++++++++++-----------
 16 files changed, 76 insertions(+), 57 deletions(-)

diff --git a/arch/arm64/include/asm/kvm_mmu.h b/arch/arm64/include/asm/kvm_mmu.h
index 6f72fe8..55772c1 100644
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
+#define kvm_virt_to_phys(x)		__pa_symbol(x)
 
 void kvm_set_way_flush(struct kvm_vcpu *vcpu);
 void kvm_toggle_cache(struct kvm_vcpu *vcpu, bool was_enabled);
diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index cd6e3ee..0ff237a 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -210,6 +210,7 @@ static inline void *phys_to_virt(phys_addr_t x)
 #define __va(x)			((void *)__phys_to_virt((phys_addr_t)(x)))
 #define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
 #define virt_to_pfn(x)      __phys_to_pfn(__virt_to_phys((unsigned long)(x)))
+#define sym_to_pfn(x)	    __phys_to_pfn(__pa_symbol(x))
 
 /*
  *  virt_to_page(k)	convert a _valid_ virtual address to struct page *
diff --git a/arch/arm64/include/asm/mmu_context.h b/arch/arm64/include/asm/mmu_context.h
index 0363fe8..63e9982 100644
--- a/arch/arm64/include/asm/mmu_context.h
+++ b/arch/arm64/include/asm/mmu_context.h
@@ -45,7 +45,7 @@ static inline void contextidr_thread_switch(struct task_struct *next)
  */
 static inline void cpu_set_reserved_ttbr0(void)
 {
-	unsigned long ttbr = virt_to_phys(empty_zero_page);
+	unsigned long ttbr = __pa_symbol(empty_zero_page);
 
 	write_sysreg(ttbr, ttbr0_el1);
 	isb();
@@ -114,7 +114,7 @@ static inline void cpu_install_idmap(void)
 	local_flush_tlb_all();
 	cpu_set_idmap_tcr_t0sz();
 
-	cpu_switch_mm(idmap_pg_dir, &init_mm);
+	cpu_switch_mm(lm_alias(idmap_pg_dir), &init_mm);
 }
 
 /*
@@ -129,7 +129,7 @@ static inline void cpu_replace_ttbr1(pgd_t *pgd)
 
 	phys_addr_t pgd_phys = virt_to_phys(pgd);
 
-	replace_phys = (void *)virt_to_phys(idmap_cpu_replace_ttbr1);
+	replace_phys = (void *)__pa_symbol(idmap_cpu_replace_ttbr1);
 
 	cpu_install_idmap();
 	replace_phys(pgd_phys);
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index ffbb9a5..090134c 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -52,7 +52,7 @@ extern void __pgd_error(const char *file, int line, unsigned long val);
  * for zero-mapped memory areas etc..
  */
 extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
-#define ZERO_PAGE(vaddr)	pfn_to_page(PHYS_PFN(__pa(empty_zero_page)))
+#define ZERO_PAGE(vaddr)	phys_to_page(__pa_symbol(empty_zero_page))
 
 #define pte_ERROR(pte)		__pte_error(__FILE__, __LINE__, pte_val(pte))
 
diff --git a/arch/arm64/kernel/acpi_parking_protocol.c b/arch/arm64/kernel/acpi_parking_protocol.c
index a32b401..1f5655c 100644
--- a/arch/arm64/kernel/acpi_parking_protocol.c
+++ b/arch/arm64/kernel/acpi_parking_protocol.c
@@ -17,6 +17,7 @@
  * along with this program.  If not, see <http://www.gnu.org/licenses/>.
  */
 #include <linux/acpi.h>
+#include <linux/mm.h>
 #include <linux/types.h>
 
 #include <asm/cpu_ops.h>
@@ -109,7 +110,7 @@ static int acpi_parking_protocol_cpu_boot(unsigned int cpu)
 	 * that read this address need to convert this address to the
 	 * Boot-Loader's endianness before jumping.
 	 */
-	writeq_relaxed(__pa(secondary_entry), &mailbox->entry_point);
+	writeq_relaxed(__pa_symbol(secondary_entry), &mailbox->entry_point);
 	writel_relaxed(cpu_entry->gic_cpu_id, &mailbox->cpu_id);
 
 	arch_send_wakeup_ipi_mask(cpumask_of(cpu));
diff --git a/arch/arm64/kernel/cpu-reset.h b/arch/arm64/kernel/cpu-reset.h
index d4e9ecb..6c2b1b4 100644
--- a/arch/arm64/kernel/cpu-reset.h
+++ b/arch/arm64/kernel/cpu-reset.h
@@ -24,7 +24,7 @@ static inline void __noreturn cpu_soft_restart(unsigned long el2_switch,
 
 	el2_switch = el2_switch && !is_kernel_in_hyp_mode() &&
 		is_hyp_mode_available();
-	restart = (void *)virt_to_phys(__cpu_soft_restart);
+	restart = (void *)__pa_symbol(__cpu_soft_restart);
 
 	cpu_install_idmap();
 	restart(el2_switch, entry, arg0, arg1, arg2);
diff --git a/arch/arm64/kernel/cpufeature.c b/arch/arm64/kernel/cpufeature.c
index fdf8f04..0ec6a1e 100644
--- a/arch/arm64/kernel/cpufeature.c
+++ b/arch/arm64/kernel/cpufeature.c
@@ -23,6 +23,7 @@
 #include <linux/sort.h>
 #include <linux/stop_machine.h>
 #include <linux/types.h>
+#include <linux/mm.h>
 #include <asm/cpu.h>
 #include <asm/cpufeature.h>
 #include <asm/cpu_ops.h>
@@ -737,7 +738,7 @@ static bool runs_at_el2(const struct arm64_cpu_capabilities *entry, int __unused
 static bool hyp_offset_low(const struct arm64_cpu_capabilities *entry,
 			   int __unused)
 {
-	phys_addr_t idmap_addr = virt_to_phys(__hyp_idmap_text_start);
+	phys_addr_t idmap_addr = __pa_symbol(__hyp_idmap_text_start);
 
 	/*
 	 * Activate the lower HYP offset only if:
diff --git a/arch/arm64/kernel/hibernate.c b/arch/arm64/kernel/hibernate.c
index fe301cb..3e94a45 100644
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
 
@@ -102,8 +99,8 @@ static inline void arch_hdr_invariants(struct arch_hibernate_hdr_invariants *i)
 
 int pfn_is_nosave(unsigned long pfn)
 {
-	unsigned long nosave_begin_pfn = virt_to_pfn(&__nosave_begin);
-	unsigned long nosave_end_pfn = virt_to_pfn(&__nosave_end - 1);
+	unsigned long nosave_begin_pfn = sym_to_pfn(&__nosave_begin);
+	unsigned long nosave_end_pfn = sym_to_pfn(&__nosave_end - 1);
 
 	return (pfn >= nosave_begin_pfn) && (pfn <= nosave_end_pfn);
 }
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
 
@@ -460,7 +457,6 @@ int swsusp_arch_resume(void)
 	void *zero_page;
 	size_t exit_size;
 	pgd_t *tmp_pg_dir;
-	void *lm_restore_pblist;
 	phys_addr_t phys_hibernate_exit;
 	void __noreturn (*hibernate_exit)(phys_addr_t, phys_addr_t, void *,
 					  void *, phys_addr_t, phys_addr_t);
@@ -481,12 +477,6 @@ int swsusp_arch_resume(void)
 		goto out;
 
 	/*
-	 * Since we only copied the linear map, we need to find restore_pblist's
-	 * linear map address.
-	 */
-	lm_restore_pblist = LMADDR(restore_pblist);
-
-	/*
 	 * We need a zero page that is zero before & after resume in order to
 	 * to break before make on the ttbr1 page tables.
 	 */
@@ -537,7 +527,7 @@ int swsusp_arch_resume(void)
 	}
 
 	hibernate_exit(virt_to_phys(tmp_pg_dir), resume_hdr.ttbr1_el1,
-		       resume_hdr.reenter_kernel, lm_restore_pblist,
+		       resume_hdr.reenter_kernel, restore_pblist,
 		       resume_hdr.__hyp_stub_vectors, virt_to_phys(zero_page));
 
 out:
diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
index 94b62c1..682f1a6 100644
--- a/arch/arm64/kernel/insn.c
+++ b/arch/arm64/kernel/insn.c
@@ -96,7 +96,7 @@ static void __kprobes *patch_map(void *addr, int fixmap)
 	if (module && IS_ENABLED(CONFIG_DEBUG_SET_MODULE_RONX))
 		page = vmalloc_to_page(addr);
 	else if (!module)
-		page = pfn_to_page(PHYS_PFN(__pa(addr)));
+		page = phys_to_page(__pa_symbol(addr));
 	else
 		return addr;
 
diff --git a/arch/arm64/kernel/psci.c b/arch/arm64/kernel/psci.c
index 42816be..e8edbf1 100644
--- a/arch/arm64/kernel/psci.c
+++ b/arch/arm64/kernel/psci.c
@@ -20,6 +20,7 @@
 #include <linux/smp.h>
 #include <linux/delay.h>
 #include <linux/psci.h>
+#include <linux/mm.h>
 
 #include <uapi/linux/psci.h>
 
@@ -45,7 +46,7 @@ static int __init cpu_psci_cpu_prepare(unsigned int cpu)
 
 static int cpu_psci_cpu_boot(unsigned int cpu)
 {
-	int err = psci_ops.cpu_on(cpu_logical_map(cpu), __pa(secondary_entry));
+	int err = psci_ops.cpu_on(cpu_logical_map(cpu), __pa_symbol(secondary_entry));
 	if (err)
 		pr_err("failed to boot CPU%d (%d)\n", cpu, err);
 
diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
index b051367..669fc9f 100644
--- a/arch/arm64/kernel/setup.c
+++ b/arch/arm64/kernel/setup.c
@@ -42,6 +42,7 @@
 #include <linux/of_fdt.h>
 #include <linux/efi.h>
 #include <linux/psci.h>
+#include <linux/mm.h>
 
 #include <asm/acpi.h>
 #include <asm/fixmap.h>
@@ -199,10 +200,10 @@ static void __init request_standard_resources(void)
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
index 9a00eee..9303465 100644
--- a/arch/arm64/kernel/smp_spin_table.c
+++ b/arch/arm64/kernel/smp_spin_table.c
@@ -21,6 +21,7 @@
 #include <linux/of.h>
 #include <linux/smp.h>
 #include <linux/types.h>
+#include <linux/mm.h>
 
 #include <asm/cacheflush.h>
 #include <asm/cpu_ops.h>
@@ -98,7 +99,7 @@ static int smp_spin_table_cpu_prepare(unsigned int cpu)
 	 * boot-loader's endianess before jumping. This is mandated by
 	 * the boot protocol.
 	 */
-	writeq_relaxed(__pa(secondary_holding_pen), release_addr);
+	writeq_relaxed(__pa_symbol(secondary_holding_pen), release_addr);
 	__flush_dcache_area((__force void *)release_addr,
 			    sizeof(*release_addr));
 
diff --git a/arch/arm64/kernel/vdso.c b/arch/arm64/kernel/vdso.c
index a2c2478..41b6e31 100644
--- a/arch/arm64/kernel/vdso.c
+++ b/arch/arm64/kernel/vdso.c
@@ -123,6 +123,7 @@ static int __init vdso_init(void)
 {
 	int i;
 	struct page **vdso_pagelist;
+	unsigned long pfn;
 
 	if (memcmp(&vdso_start, "\177ELF", 4)) {
 		pr_err("vDSO is not a valid ELF object!\n");
@@ -140,11 +141,14 @@ static int __init vdso_init(void)
 		return -ENOMEM;
 
 	/* Grab the vDSO data page. */
-	vdso_pagelist[0] = pfn_to_page(PHYS_PFN(__pa(vdso_data)));
+	vdso_pagelist[0] = phys_to_page(__pa_symbol(vdso_data));
+
 
 	/* Grab the vDSO code pages. */
+	pfn = sym_to_pfn(&vdso_start);
+
 	for (i = 0; i < vdso_pages; i++)
-		vdso_pagelist[i + 1] = pfn_to_page(PHYS_PFN(__pa(&vdso_start)) + i);
+		vdso_pagelist[i + 1] = pfn_to_page(pfn + i);
 
 	vdso_spec[0].pages = &vdso_pagelist[0];
 	vdso_spec[1].pages = &vdso_pagelist[1];
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 212c4d1..8af2ad6 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -36,6 +36,7 @@
 #include <linux/efi.h>
 #include <linux/swiotlb.h>
 #include <linux/vmalloc.h>
+#include <linux/mm.h>
 
 #include <asm/boot.h>
 #include <asm/fixmap.h>
@@ -209,8 +210,8 @@ void __init arm64_memblock_init(void)
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
@@ -225,7 +226,7 @@ void __init arm64_memblock_init(void)
 	 */
 	if (memory_limit != (phys_addr_t)ULLONG_MAX) {
 		memblock_mem_limit_remove_map(memory_limit);
-		memblock_add(__pa(_text), (u64)(_end - _text));
+		memblock_add(__pa_symbol(_text), (u64)(_end - _text));
 	}
 
 	if (IS_ENABLED(CONFIG_BLK_DEV_INITRD) && initrd_start) {
@@ -278,7 +279,7 @@ void __init arm64_memblock_init(void)
 	 * Register the kernel text, kernel data, initrd, and initial
 	 * pagetables with memblock.
 	 */
-	memblock_reserve(__pa(_text), _end - _text);
+	memblock_reserve(__pa_symbol(_text), _end - _text);
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (initrd_start) {
 		memblock_reserve(initrd_start, initrd_end - initrd_start);
@@ -483,7 +484,8 @@ void __init mem_init(void)
 
 void free_initmem(void)
 {
-	free_reserved_area(__va(__pa(__init_begin)), __va(__pa(__init_end)),
+	free_reserved_area(lm_alias(__init_begin),
+			   lm_alias(__init_end),
 			   0, "unused kernel");
 	/*
 	 * Unmap the __init region but leave the VM area in place. This
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 757009d..201d918 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -15,6 +15,7 @@
 #include <linux/kernel.h>
 #include <linux/memblock.h>
 #include <linux/start_kernel.h>
+#include <linux/mm.h>
 
 #include <asm/mmu_context.h>
 #include <asm/kernel-pgtable.h>
@@ -26,6 +27,13 @@
 
 static pgd_t tmp_pg_dir[PTRS_PER_PGD] __initdata __aligned(PGD_SIZE);
 
+/*
+ * The p*d_populate functions call virt_to_phys implicitly so they can't be used
+ * directly on kernel symbols (bm_p*d). All the early functions are called too
+ * early to use lm_alias so __p*d_populate functions must be used to populate
+ * with the physical address from __pa_symbol.
+ */
+
 static void __init kasan_early_pte_populate(pmd_t *pmd, unsigned long addr,
 					unsigned long end)
 {
@@ -33,12 +41,12 @@ static void __init kasan_early_pte_populate(pmd_t *pmd, unsigned long addr,
 	unsigned long next;
 
 	if (pmd_none(*pmd))
-		pmd_populate_kernel(&init_mm, pmd, kasan_zero_pte);
+		__pmd_populate(pmd, __pa_symbol(kasan_zero_pte), PMD_TYPE_TABLE);
 
 	pte = pte_offset_kimg(pmd, addr);
 	do {
 		next = addr + PAGE_SIZE;
-		set_pte(pte, pfn_pte(virt_to_pfn(kasan_zero_page),
+		set_pte(pte, pfn_pte(sym_to_pfn(kasan_zero_page),
 					PAGE_KERNEL));
 	} while (pte++, addr = next, addr != end && pte_none(*pte));
 }
@@ -51,7 +59,7 @@ static void __init kasan_early_pmd_populate(pud_t *pud,
 	unsigned long next;
 
 	if (pud_none(*pud))
-		pud_populate(&init_mm, pud, kasan_zero_pmd);
+		__pud_populate(pud, __pa_symbol(kasan_zero_pmd), PMD_TYPE_TABLE);
 
 	pmd = pmd_offset_kimg(pud, addr);
 	do {
@@ -68,7 +76,7 @@ static void __init kasan_early_pud_populate(pgd_t *pgd,
 	unsigned long next;
 
 	if (pgd_none(*pgd))
-		pgd_populate(&init_mm, pgd, kasan_zero_pud);
+		__pgd_populate(pgd, __pa_symbol(kasan_zero_pud), PUD_TYPE_TABLE);
 
 	pud = pud_offset_kimg(pgd, addr);
 	do {
@@ -148,7 +156,7 @@ void __init kasan_init(void)
 	 */
 	memcpy(tmp_pg_dir, swapper_pg_dir, sizeof(tmp_pg_dir));
 	dsb(ishst);
-	cpu_replace_ttbr1(tmp_pg_dir);
+	cpu_replace_ttbr1(lm_alias(tmp_pg_dir));
 
 	clear_pgds(KASAN_SHADOW_START, KASAN_SHADOW_END);
 
@@ -199,10 +207,10 @@ void __init kasan_init(void)
 	 */
 	for (i = 0; i < PTRS_PER_PTE; i++)
 		set_pte(&kasan_zero_pte[i],
-			pfn_pte(virt_to_pfn(kasan_zero_page), PAGE_KERNEL_RO));
+			pfn_pte(sym_to_pfn(kasan_zero_page), PAGE_KERNEL_RO));
 
 	memset(kasan_zero_page, 0, PAGE_SIZE);
-	cpu_replace_ttbr1(swapper_pg_dir);
+	cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
 
 	/* At this point kasan is fully initialized. Enable error messages */
 	init_task.kasan_depth = 0;
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 17243e4..a434157 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -28,6 +28,7 @@
 #include <linux/memblock.h>
 #include <linux/fs.h>
 #include <linux/io.h>
+#include <linux/mm.h>
 
 #include <asm/barrier.h>
 #include <asm/cputype.h>
@@ -359,8 +360,8 @@ static void create_mapping_late(phys_addr_t phys, unsigned long virt,
 
 static void __init __map_memblock(pgd_t *pgd, phys_addr_t start, phys_addr_t end)
 {
-	unsigned long kernel_start = __pa(_text);
-	unsigned long kernel_end = __pa(__init_begin);
+	unsigned long kernel_start = __pa_symbol(_text);
+	unsigned long kernel_end = __pa_symbol(__init_begin);
 
 	/*
 	 * Take care not to create a writable alias for the
@@ -427,14 +428,14 @@ void mark_rodata_ro(void)
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
 
 	/* flush the TLBs after updating live kernel mappings */
@@ -446,7 +447,7 @@ void mark_rodata_ro(void)
 static void __init map_kernel_segment(pgd_t *pgd, void *va_start, void *va_end,
 				      pgprot_t prot, struct vm_struct *vma)
 {
-	phys_addr_t pa_start = __pa(va_start);
+	phys_addr_t pa_start = __pa_symbol(va_start);
 	unsigned long size = va_end - va_start;
 
 	BUG_ON(!PAGE_ALIGNED(pa_start));
@@ -494,7 +495,7 @@ static void __init map_kernel(pgd_t *pgd)
 		 */
 		BUG_ON(!IS_ENABLED(CONFIG_ARM64_16K_PAGES));
 		set_pud(pud_set_fixmap_offset(pgd, FIXADDR_START),
-			__pud(__pa(bm_pmd) | PUD_TYPE_TABLE));
+			__pud(__pa_symbol(bm_pmd) | PUD_TYPE_TABLE));
 		pud_clear_fixmap();
 	} else {
 		BUG();
@@ -525,7 +526,7 @@ void __init paging_init(void)
 	 */
 	cpu_replace_ttbr1(__va(pgd_phys));
 	memcpy(swapper_pg_dir, pgd, PAGE_SIZE);
-	cpu_replace_ttbr1(swapper_pg_dir);
+	cpu_replace_ttbr1(lm_alias(swapper_pg_dir));
 
 	pgd_clear_fixmap();
 	memblock_free(pgd_phys, PAGE_SIZE);
@@ -534,7 +535,7 @@ void __init paging_init(void)
 	 * We only reuse the PGD from the swapper_pg_dir, not the pud + pmd
 	 * allocated with it.
 	 */
-	memblock_free(__pa(swapper_pg_dir) + PAGE_SIZE,
+	memblock_free(__pa_symbol(swapper_pg_dir) + PAGE_SIZE,
 		      SWAPPER_DIR_SIZE - PAGE_SIZE);
 }
 
@@ -645,6 +646,12 @@ static inline pte_t * fixmap_pte(unsigned long addr)
 	return &bm_pte[pte_index(addr)];
 }
 
+/*
+ * The p*d_populate functions call virt_to_phys implicitly so they can't be used
+ * directly on kernel symbols (bm_p*d). This function is called too early to use
+ * lm_alias so __p*d_populate functions must be used to populate with the
+ * physical address from __pa_symbol.
+ */
 void __init early_fixmap_init(void)
 {
 	pgd_t *pgd;
@@ -654,7 +661,7 @@ void __init early_fixmap_init(void)
 
 	pgd = pgd_offset_k(addr);
 	if (CONFIG_PGTABLE_LEVELS > 3 &&
-	    !(pgd_none(*pgd) || pgd_page_paddr(*pgd) == __pa(bm_pud))) {
+	    !(pgd_none(*pgd) || pgd_page_paddr(*pgd) == __pa_symbol(bm_pud))) {
 		/*
 		 * We only end up here if the kernel mapping and the fixmap
 		 * share the top level pgd entry, which should only happen on
@@ -663,12 +670,14 @@ void __init early_fixmap_init(void)
 		BUG_ON(!IS_ENABLED(CONFIG_ARM64_16K_PAGES));
 		pud = pud_offset_kimg(pgd, addr);
 	} else {
-		pgd_populate(&init_mm, pgd, bm_pud);
+		if (pgd_none(*pgd))
+			__pgd_populate(pgd, __pa_symbol(bm_pud), PUD_TYPE_TABLE);
 		pud = fixmap_pud(addr);
 	}
-	pud_populate(&init_mm, pud, bm_pmd);
+	if (pud_none(*pud))
+		__pud_populate(pud, __pa_symbol(bm_pmd), PMD_TYPE_TABLE);
 	pmd = fixmap_pmd(addr);
-	pmd_populate_kernel(&init_mm, pmd, bm_pte);
+	__pmd_populate(pmd, __pa_symbol(bm_pte), PMD_TYPE_TABLE);
 
 	/*
 	 * The boot-ioremap range spans multiple pmds, for which
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
