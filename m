Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 619236B0314
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 18:37:13 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id k36so4281836otb.3
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 15:37:13 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u91si6218438otb.139.2017.06.05.15.37.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 15:37:12 -0700 (PDT)
From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC 09/11] x86/mm: Teach CR3 readers about PCID
Date: Mon,  5 Jun 2017 15:36:33 -0700
Message-Id: <a9a7927168e8b64ad00878032f65a7a19fcd3fac.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
In-Reply-To: <cover.1496701658.git.luto@kernel.org>
References: <cover.1496701658.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: X86 ML <x86@kernel.org>
Cc: Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Andy Lutomirski <luto@kernel.org>

The kernel has several code paths that read CR3.  Most of them assume that
CR3 contains the PGD's physical address, whereas some of them awkwardly
use PHYSICAL_PAGE_MASK to mask off low bits.

Add explicit mask macros for CR3 and convert all of the CR3 readers.
This will keep them from breaking when PCID is enabled.

Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 arch/x86/boot/compressed/pagetable.c   |  2 +-
 arch/x86/include/asm/efi.h             |  2 +-
 arch/x86/include/asm/mmu_context.h     |  4 ++--
 arch/x86/include/asm/paravirt.h        |  2 +-
 arch/x86/include/asm/processor-flags.h | 30 ++++++++++++++++++++++++++++++
 arch/x86/include/asm/processor.h       |  8 ++++++++
 arch/x86/include/asm/special_insns.h   | 10 +++++++---
 arch/x86/include/asm/tlbflush.h        |  2 +-
 arch/x86/kernel/head64.c               |  3 ++-
 arch/x86/kernel/paravirt.c             |  2 +-
 arch/x86/kernel/process_32.c           |  2 +-
 arch/x86/kernel/process_64.c           |  2 +-
 arch/x86/kvm/vmx.c                     |  2 +-
 arch/x86/mm/fault.c                    | 10 +++++-----
 arch/x86/mm/ioremap.c                  |  2 +-
 arch/x86/mm/tlb.c                      |  2 +-
 arch/x86/platform/efi/efi_64.c         |  4 ++--
 arch/x86/platform/olpc/olpc-xo1-pm.c   |  2 +-
 arch/x86/power/cpu.c                   |  2 +-
 arch/x86/power/hibernate_64.c          |  3 ++-
 arch/x86/xen/mmu_pv.c                  |  6 +++---
 21 files changed, 73 insertions(+), 29 deletions(-)

diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
index 1d78f1739087..16e8320f8658 100644
--- a/arch/x86/boot/compressed/pagetable.c
+++ b/arch/x86/boot/compressed/pagetable.c
@@ -92,7 +92,7 @@ void initialize_identity_maps(void)
 	 * and we must append to the existing area instead of entirely
 	 * overwriting it.
 	 */
-	level4p = read_cr3();
+	level4p = read_cr3_addr();
 	if (level4p == (unsigned long)_pgtable) {
 		debug_putstr("booted via startup_32()\n");
 		pgt_data.pgt_buf = _pgtable + BOOT_INIT_PGT_SIZE;
diff --git a/arch/x86/include/asm/efi.h b/arch/x86/include/asm/efi.h
index 2f77bcefe6b4..d2ff779f347e 100644
--- a/arch/x86/include/asm/efi.h
+++ b/arch/x86/include/asm/efi.h
@@ -74,7 +74,7 @@ struct efi_scratch {
 	__kernel_fpu_begin();						\
 									\
 	if (efi_scratch.use_pgd) {					\
-		efi_scratch.prev_cr3 = read_cr3();			\
+		efi_scratch.prev_cr3 = __read_cr3();			\
 		write_cr3((unsigned long)efi_scratch.efi_pgt);		\
 		__flush_tlb_all();					\
 	}								\
diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index da0cd502b4bd..793cbe858ebf 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -299,7 +299,7 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
 
 /*
  * This can be used from process context to figure out what the value of
- * CR3 is without needing to do a (slow) read_cr3().
+ * CR3 is without needing to do a (slow) __read_cr3().
  *
  * It's intended to be used for code like KVM that sneakily changes CR3
  * and needs to restore it.  It needs to be used very carefully.
@@ -311,7 +311,7 @@ static inline unsigned long __get_current_cr3_fast(void)
 	/* For now, be very restrictive about when this can be called. */
 	VM_WARN_ON(in_nmi() || !in_atomic());
 
-	VM_BUG_ON(cr3 != read_cr3());
+	VM_BUG_ON(cr3 != __read_cr3());
 	return cr3;
 }
 
diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 9a15739d9f4b..a63e77f8eb41 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -61,7 +61,7 @@ static inline void write_cr2(unsigned long x)
 	PVOP_VCALL1(pv_mmu_ops.write_cr2, x);
 }
 
-static inline unsigned long read_cr3(void)
+static inline unsigned long __read_cr3(void)
 {
 	return PVOP_CALL0(unsigned long, pv_mmu_ops.read_cr3);
 }
diff --git a/arch/x86/include/asm/processor-flags.h b/arch/x86/include/asm/processor-flags.h
index 39fb618e2211..ce25ac7945c4 100644
--- a/arch/x86/include/asm/processor-flags.h
+++ b/arch/x86/include/asm/processor-flags.h
@@ -8,4 +8,34 @@
 #else
 #define X86_VM_MASK	0 /* No VM86 support */
 #endif
+
+/*
+ * CR3 field masks.  On 32-bit systems, bits 31:12 of CR3 give the
+ * physical page frame number of the top-level page table.  (Yes, this
+ * means that the page directory pointer table on PAE needs to live
+ * below 4 GB.)  On 64-bit systems, bits MAXPHYADDR:12 are the PGD page
+ * frame number, bits 62:MAXPHYADDR are reserved (and will presumably be
+ * read as zero forever unless the OS sets some new feature flag), and
+ * bit 63 is read as zero.
+ *
+ * The upshot is that masking off the low 12 bits gives the physical
+ * address of the top-level paging structure on all x86 systems.
+ *
+ * If PCID is enabled, writing 1 to bit 63 suppresses the normal TLB
+ * flush implied by a CR3 write but does *not* set bit 63 of CR3.
+ *
+ * If PCID is enabled, the low 12 bits are the process context ID.  If
+ * PCID is disabled, the low 12 bits are actively counterproductive to
+ * use, and Linux will always set them to zero.  PCID cannot be enabled
+ * on x86_32, so, to save some code size, we fudge the masks so that CR3
+ * reads can skip masking off the known-zero bits on x86_32.
+ */
+#ifdef CONFIG_X86_64
+#define CR3_ADDR_MASK 0x7FFFFFFFFFFFF000ull
+#define CR3_PCID_MASK 0xFFFull
+#else
+#define CR3_ADDR_MASK 0xFFFFFFFFull
+#define CR3_PCID_MASK 0ull
+#endif
+
 #endif /* _ASM_X86_PROCESSOR_FLAGS_H */
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 3cada998a402..f9142a1fb0d3 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -231,6 +231,14 @@ native_cpuid_reg(ebx)
 native_cpuid_reg(ecx)
 native_cpuid_reg(edx)
 
+/*
+ * Friendlier CR3 helpers.
+ */
+static inline unsigned long read_cr3_addr(void)
+{
+	return __read_cr3() & CR3_ADDR_MASK;
+}
+
 static inline void load_cr3(pgd_t *pgdir)
 {
 	write_cr3(__pa(pgdir));
diff --git a/arch/x86/include/asm/special_insns.h b/arch/x86/include/asm/special_insns.h
index 12af3e35edfa..b3af02c7fa52 100644
--- a/arch/x86/include/asm/special_insns.h
+++ b/arch/x86/include/asm/special_insns.h
@@ -39,7 +39,7 @@ static inline void native_write_cr2(unsigned long val)
 	asm volatile("mov %0,%%cr2": : "r" (val), "m" (__force_order));
 }
 
-static inline unsigned long native_read_cr3(void)
+static inline unsigned long __native_read_cr3(void)
 {
 	unsigned long val;
 	asm volatile("mov %%cr3,%0\n\t" : "=r" (val), "=m" (__force_order));
@@ -159,9 +159,13 @@ static inline void write_cr2(unsigned long x)
 	native_write_cr2(x);
 }
 
-static inline unsigned long read_cr3(void)
+/*
+ * Careful!  CR3 contains more than just an address.  You probably want
+ * read_cr3_addr() instead.
+ */
+static inline unsigned long __read_cr3(void)
 {
-	return native_read_cr3();
+	return __native_read_cr3();
 }
 
 static inline void write_cr3(unsigned long x)
diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index c68b7c9a7d77..87b13e51e867 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -192,7 +192,7 @@ static inline void __native_flush_tlb(void)
 	 * back:
 	 */
 	preempt_disable();
-	native_write_cr3(native_read_cr3());
+	native_write_cr3(__native_read_cr3());
 	preempt_enable();
 }
 
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 43b7002f44fb..75fa59b22837 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -55,7 +55,8 @@ int __init early_make_pgtable(unsigned long address)
 	pmdval_t pmd, *pmd_p;
 
 	/* Invalid address or early pgt is done ?  */
-	if (physaddr >= MAXMEM || read_cr3() != __pa_nodebug(early_level4_pgt))
+	if (physaddr >= MAXMEM ||
+	    read_cr3_addr() != __pa_nodebug(early_level4_pgt))
 		return -1;
 
 again:
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
index 3586996fc50d..bc0a849589bb 100644
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -391,7 +391,7 @@ struct pv_mmu_ops pv_mmu_ops __ro_after_init = {
 
 	.read_cr2 = native_read_cr2,
 	.write_cr2 = native_write_cr2,
-	.read_cr3 = native_read_cr3,
+	.read_cr3 = __native_read_cr3,
 	.write_cr3 = native_write_cr3,
 
 	.flush_tlb_user = native_flush_tlb,
diff --git a/arch/x86/kernel/process_32.c b/arch/x86/kernel/process_32.c
index ffeae818aa7a..c6d6dc5f8bb2 100644
--- a/arch/x86/kernel/process_32.c
+++ b/arch/x86/kernel/process_32.c
@@ -92,7 +92,7 @@ void __show_regs(struct pt_regs *regs, int all)
 
 	cr0 = read_cr0();
 	cr2 = read_cr2();
-	cr3 = read_cr3();
+	cr3 = __read_cr3();
 	cr4 = __read_cr4();
 	printk(KERN_DEFAULT "CR0: %08lx CR2: %08lx CR3: %08lx CR4: %08lx\n",
 			cr0, cr2, cr3, cr4);
diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index b6840bf3940b..75e235a91e3c 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -104,7 +104,7 @@ void __show_regs(struct pt_regs *regs, int all)
 
 	cr0 = read_cr0();
 	cr2 = read_cr2();
-	cr3 = read_cr3();
+	cr3 = __read_cr3();
 	cr4 = __read_cr4();
 
 	printk(KERN_DEFAULT "FS:  %016lx(%04x) GS:%016lx(%04x) knlGS:%016lx\n",
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 19cde555d73f..d143dd397dc9 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -5024,7 +5024,7 @@ static void vmx_set_constant_host_state(struct vcpu_vmx *vmx)
 	 * Save the most likely value for this task's CR3 in the VMCS.
 	 * We can't use __get_current_cr3_fast() because we're not atomic.
 	 */
-	cr3 = read_cr3();
+	cr3 = __read_cr3();
 	vmcs_writel(HOST_CR3, cr3);		/* 22.2.3  FIXME: shadow tables */
 	vmx->host_state.vmcs_host_cr3 = cr3;
 
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 8ad91a01cbc8..6fc2dfa28124 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -346,7 +346,7 @@ static noinline int vmalloc_fault(unsigned long address)
 	 * Do _not_ use "current" here. We might be inside
 	 * an interrupt in the middle of a task switch..
 	 */
-	pgd_paddr = read_cr3();
+	pgd_paddr = read_cr3_addr();
 	pmd_k = vmalloc_sync_one(__va(pgd_paddr), address);
 	if (!pmd_k)
 		return -1;
@@ -388,7 +388,7 @@ static bool low_pfn(unsigned long pfn)
 
 static void dump_pagetable(unsigned long address)
 {
-	pgd_t *base = __va(read_cr3());
+	pgd_t *base = __va(read_cr3_addr());
 	pgd_t *pgd = &base[pgd_index(address)];
 	p4d_t *p4d;
 	pud_t *pud;
@@ -451,7 +451,7 @@ static noinline int vmalloc_fault(unsigned long address)
 	 * happen within a race in page table update. In the later
 	 * case just flush:
 	 */
-	pgd = (pgd_t *)__va(read_cr3()) + pgd_index(address);
+	pgd = (pgd_t *)__va(read_cr3_addr()) + pgd_index(address);
 	pgd_ref = pgd_offset_k(address);
 	if (pgd_none(*pgd_ref))
 		return -1;
@@ -555,7 +555,7 @@ static int bad_address(void *p)
 
 static void dump_pagetable(unsigned long address)
 {
-	pgd_t *base = __va(read_cr3() & PHYSICAL_PAGE_MASK);
+	pgd_t *base = __va(read_cr3_addr());
 	pgd_t *pgd = base + pgd_index(address);
 	p4d_t *p4d;
 	pud_t *pud;
@@ -700,7 +700,7 @@ show_fault_oops(struct pt_regs *regs, unsigned long error_code,
 		pgd_t *pgd;
 		pte_t *pte;
 
-		pgd = __va(read_cr3() & PHYSICAL_PAGE_MASK);
+		pgd = __va(read_cr3_addr());
 		pgd += pgd_index(address);
 
 		pte = lookup_address_in_pgd(pgd, address, &level);
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index bbc558b88a88..b21e00712dd7 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -424,7 +424,7 @@ static pte_t bm_pte[PAGE_SIZE/sizeof(pte_t)] __page_aligned_bss;
 static inline pmd_t * __init early_ioremap_pmd(unsigned long addr)
 {
 	/* Don't assume we're using swapper_pg_dir at this point */
-	pgd_t *base = __va(read_cr3());
+	pgd_t *base = __va(read_cr3_addr());
 	pgd_t *pgd = &base[pgd_index(addr)];
 	p4d_t *p4d = p4d_offset(pgd, addr);
 	pud_t *pud = pud_offset(p4d, addr);
diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 09775cf5cb1b..3773ba72cf2d 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -81,7 +81,7 @@ void switch_mm_irqs_off(struct mm_struct *prev, struct mm_struct *next,
 	if (IS_ENABLED(CONFIG_PROVE_LOCKING))
 		WARN_ON_ONCE(!irqs_disabled());
 
-	VM_BUG_ON(read_cr3() != __pa(real_prev->pgd));
+	VM_BUG_ON(read_cr3_addr() != __pa(real_prev->pgd));
 
 	if (real_prev == next) {
 		if (cpumask_test_cpu(cpu, mm_cpumask(next))) {
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index eb8dff15a7f6..f40bf6230480 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -80,7 +80,7 @@ pgd_t * __init efi_call_phys_prolog(void)
 	int n_pgds, i, j;
 
 	if (!efi_enabled(EFI_OLD_MEMMAP)) {
-		save_pgd = (pgd_t *)read_cr3();
+		save_pgd = (pgd_t *)__read_cr3();
 		write_cr3((unsigned long)efi_scratch.efi_pgt);
 		goto out;
 	}
@@ -646,7 +646,7 @@ efi_status_t efi_thunk_set_virtual_address_map(
 	efi_sync_low_kernel_mappings();
 	local_irq_save(flags);
 
-	efi_scratch.prev_cr3 = read_cr3();
+	efi_scratch.prev_cr3 = __read_cr3();
 	write_cr3((unsigned long)efi_scratch.efi_pgt);
 	__flush_tlb_all();
 
diff --git a/arch/x86/platform/olpc/olpc-xo1-pm.c b/arch/x86/platform/olpc/olpc-xo1-pm.c
index c5350fd27d70..1ad9932ded7c 100644
--- a/arch/x86/platform/olpc/olpc-xo1-pm.c
+++ b/arch/x86/platform/olpc/olpc-xo1-pm.c
@@ -77,7 +77,7 @@ static int xo1_power_state_enter(suspend_state_t pm_state)
 
 asmlinkage __visible int xo1_do_sleep(u8 sleep_state)
 {
-	void *pgd_addr = __va(read_cr3());
+	void *pgd_addr = __va(read_cr3_addr());
 
 	/* Program wakeup mask (using dword access to CS5536_PM1_EN) */
 	outl(wakeup_mask << 16, acpi_base + CS5536_PM1_STS);
diff --git a/arch/x86/power/cpu.c b/arch/x86/power/cpu.c
index 6b05a9219ea2..78459a6d455a 100644
--- a/arch/x86/power/cpu.c
+++ b/arch/x86/power/cpu.c
@@ -129,7 +129,7 @@ static void __save_processor_state(struct saved_context *ctxt)
 	 */
 	ctxt->cr0 = read_cr0();
 	ctxt->cr2 = read_cr2();
-	ctxt->cr3 = read_cr3();
+	ctxt->cr3 = __read_cr3();
 	ctxt->cr4 = __read_cr4();
 #ifdef CONFIG_X86_64
 	ctxt->cr8 = read_cr8();
diff --git a/arch/x86/power/hibernate_64.c b/arch/x86/power/hibernate_64.c
index a6e21fee22ea..98a17db2b214 100644
--- a/arch/x86/power/hibernate_64.c
+++ b/arch/x86/power/hibernate_64.c
@@ -150,7 +150,8 @@ static int relocate_restore_code(void)
 	memcpy((void *)relocated_restore_code, &core_restore_code, PAGE_SIZE);
 
 	/* Make the page containing the relocated code executable */
-	pgd = (pgd_t *)__va(read_cr3()) + pgd_index(relocated_restore_code);
+	pgd = (pgd_t *)__va(read_cr3_addr()) +
+		pgd_index(relocated_restore_code);
 	p4d = p4d_offset(pgd, relocated_restore_code);
 	if (p4d_large(*p4d)) {
 		set_p4d(p4d, __p4d(p4d_val(*p4d) & ~_PAGE_NX));
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index 21beb37114b7..73e8595621c1 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -2017,7 +2017,7 @@ static phys_addr_t __init xen_early_virt_to_phys(unsigned long vaddr)
 	pmd_t pmd;
 	pte_t pte;
 
-	pa = read_cr3();
+	pa = read_cr3_addr();
 	pgd = native_make_pgd(xen_read_phys_ulong(pa + pgd_index(vaddr) *
 						       sizeof(pgd)));
 	if (!pgd_present(pgd))
@@ -2097,7 +2097,7 @@ void __init xen_relocate_p2m(void)
 	pt_phys = pmd_phys + PFN_PHYS(n_pmd);
 	p2m_pfn = PFN_DOWN(pt_phys) + n_pt;
 
-	pgd = __va(read_cr3());
+	pgd = __va(read_cr3_addr());
 	new_p2m = (unsigned long *)(2 * PGDIR_SIZE);
 	idx_p4d = 0;
 	save_pud = n_pud;
@@ -2204,7 +2204,7 @@ static void __init xen_write_cr3_init(unsigned long cr3)
 {
 	unsigned long pfn = PFN_DOWN(__pa(swapper_pg_dir));
 
-	BUG_ON(read_cr3() != __pa(initial_page_table));
+	BUG_ON(read_cr3_addr() != __pa(initial_page_table));
 	BUG_ON(cr3 != __pa(swapper_pg_dir));
 
 	/*
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
