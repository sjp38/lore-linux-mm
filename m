From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 02 May 2006 15:25:57 +1000
Message-Id: <20060502052557.8990.87273.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20060502052546.8990.33000.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
References: <20060502052546.8990.33000.sendpatchset@wagner.orchestra.cse.unsw.EDU.AU>
Subject: [RFC 2/3] LVHPT - Setup LVHPT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org, Ian Wienand <ianw@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

LVHPT setup

The following patch sets up the LVHPT on boot.

For the initial boot processor, we allocate the VHPT in ia64_mmu_init.
Other CPUs get the LVHPT allocated from do_boot_cpu before they are
woken up.

The logic is per CPU, but it attempts to choose a reasonable size that
can be pinned in the TLB.  There are facilities to clamp it to a
specific size.

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

---

 Documentation/kernel-parameters.txt |   14 ++
 arch/ia64/Kconfig                   |   10 +
 arch/ia64/kernel/setup.c            |   30 +++++
 arch/ia64/kernel/smpboot.c          |   12 ++
 arch/ia64/mm/init.c                 |  187 +++++++++++++++++++++++++++++++++---
 include/asm-ia64/pgtable.h          |   20 +++
 6 files changed, 261 insertions(+), 12 deletions(-)

Index: linux-2.6.17-rc3/arch/ia64/Kconfig
===================================================================
--- linux-2.6.17-rc3.orig/arch/ia64/Kconfig	2006-05-01 15:35:44.000000000 +1000
+++ linux-2.6.17-rc3/arch/ia64/Kconfig	2006-05-01 15:35:51.000000000 +1000
@@ -374,6 +374,16 @@
 	def_bool y
 	depends on NEED_MULTIPLE_NODES
 
+config IA64_LONG_FORMAT_VHPT
+ 	bool "Long format VHPT"
+ 	depends on !DISABLE_VHPT
+ 	help
+ 	  The long format VHPT is an alternative hashed page table. Advantages
+ 	  of the long format VHPT are lower memory usage when there are a large
+ 	  number of processes in the system.
+ 	  The short format page table walker is currently the Linux default.
+ 	  If you're unsure, answer N.
+
 config IA32_SUPPORT
 	bool "Support for Linux/x86 binaries"
 	help
Index: linux-2.6.17-rc3/arch/ia64/kernel/setup.c
===================================================================
--- linux-2.6.17-rc3.orig/arch/ia64/kernel/setup.c	2006-05-01 15:35:44.000000000 +1000
+++ linux-2.6.17-rc3/arch/ia64/kernel/setup.c	2006-05-01 15:35:51.000000000 +1000
@@ -284,6 +284,18 @@
 #endif
 }
 
+static void __init parse_cmdline_early (char ** cmdline_p)
+{
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+ 	char *p;
+ 	extern int lvhpt_bits_clamp_setup(char *s);
+
+ 	strlcpy(saved_command_line, *cmdline_p, COMMAND_LINE_SIZE);
+ 	if ((p = strstr(*cmdline_p, "lvhpt_bits_clamp=")))
+ 		lvhpt_bits_clamp_setup(p + 17);
+#endif
+}
+
 static void __init
 io_port_init (void)
 {
@@ -400,12 +412,14 @@
 void __init
 setup_arch (char **cmdline_p)
 {
+	extern void __devinit ia64_tlb_early_init(void);
+
 	unw_init();
 
 	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
 
 	*cmdline_p = __va(ia64_boot_param->command_line);
-	strlcpy(saved_command_line, *cmdline_p, COMMAND_LINE_SIZE);
+	parse_cmdline_early(cmdline_p);
 
 	efi_init();
 	io_port_init();
@@ -438,6 +452,20 @@
 
 	ia64_setup_printk_clock();
 
+	/* Setup some information about the TLBS */
+	ia64_tlb_early_init();
+
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	/*
+	 * put this after all the ACPI walking so we can get the size
+	 * of memory on nodes
+	 */
+ 	{
+ 		extern void compute_vhpt_size(void);
+ 		compute_vhpt_size();
+ 	}
+#endif
+
 #ifdef CONFIG_SMP
 	cpu_physical_id(0) = hard_smp_processor_id();
 
Index: linux-2.6.17-rc3/arch/ia64/kernel/smpboot.c
===================================================================
--- linux-2.6.17-rc3.orig/arch/ia64/kernel/smpboot.c	2006-05-01 15:35:44.000000000 +1000
+++ linux-2.6.17-rc3/arch/ia64/kernel/smpboot.c	2006-05-01 15:35:51.000000000 +1000
@@ -478,6 +478,11 @@
 	complete(&c_idle->done);
 }
 
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+/* required for do_boot_cpu, defined in init.c */
+extern unsigned int alloc_vhpt(int cpu);
+#endif
+
 static int __devinit
 do_boot_cpu (int sapicid, int cpu)
 {
@@ -512,6 +517,13 @@
 do_rest:
 	task_for_booting_cpu = c_idle.idle;
 
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	if (alloc_vhpt(cpu)) {
+		panic("Couldn't allocate VHPT on CPU %d\n", cpu);
+	}
+	Dprintk("Allocated long format VHPT for CPU %d at: 0x%lx, size: 0x%lx\n", cpu, vhpt_base[cpu], long_vhpt_size(cpu));
+#endif /* CONFIG_IA64_LONG_FORMAT_VHPT */
+
 	Dprintk("Sending wakeup vector %lu to AP 0x%x/0x%x.\n", ap_wakeup_vector, cpu, sapicid);
 
 	set_brendez_area(cpu);
Index: linux-2.6.17-rc3/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.17-rc3.orig/arch/ia64/mm/init.c	2006-05-01 15:35:44.000000000 +1000
+++ linux-2.6.17-rc3/arch/ia64/mm/init.c	2006-05-01 15:35:51.000000000 +1000
@@ -42,6 +42,11 @@
 DEFINE_PER_CPU(unsigned long *, __pgtable_quicklist);
 DEFINE_PER_CPU(long, __pgtable_quicklist_size);
 
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+unsigned long vhpt_base[NR_CPUS];
+unsigned long long_vhpt_bits[MAX_NUMNODES];
+#endif
+
 extern void ia64_tlb_init (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
@@ -335,10 +340,140 @@
 	ia64_patch_gate();
 }
 
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+/*
+ * This code must be called on a CPU which has it's MMU
+ * initialized. The page allocator seems to depend on it.
+ *
+ * Returns 0 on success.
+ */
+unsigned int
+alloc_vhpt(int cpu)
+{
+	int node = cpu_to_node(cpu);
+
+#ifdef CONFIG_NUMA
+	struct page *page;
+
+	page = alloc_pages_node(node, __GFP_HIGHMEM|GFP_ATOMIC, long_vhpt_bits[node] - PAGE_SHIFT);
+	if (!page)
+		return -1;
+	vhpt_base[cpu] = (unsigned long) page_address(page);
+#else
+	vhpt_base[cpu] = (unsigned long)__get_free_pages(__GFP_HIGHMEM|GFP_ATOMIC,
+							 long_vhpt_bits[node] - PAGE_SHIFT);
+#endif
+	return (vhpt_base[cpu] == 0);
+}
+
+static int lvhpt_bits_clamp;
+
+/*
+ * This allows you to clamp the number of bits used for the long
+ * format vhpt. TODO check for invalid values here.
+ */
+
+int __init
+lvhpt_bits_clamp_setup(char *s)
+{
+	if (sscanf(s, "%d", &lvhpt_bits_clamp) <= 0)
+		lvhpt_bits_clamp = 0;
+	return 1;
+}
+
+__setup("lvhpt_bits_clamp=", lvhpt_bits_clamp_setup);
+
+static unsigned long vhpt_addressable_memory[MAX_NUMNODES];
+
+/*
+ * Passed to efi_memmap_walk to simply add up how much memory we have.
+ * This is used to size the LVHPT
+ */
+static int
+get_total_ram(unsigned long start, unsigned long end, void *arg)
+{
+	unsigned long *s = arg;
+	*s += (end - start);
+	return 0;
+}
+
+#ifdef CONFIG_NUMA
+static void compute_vhpt_size_numa(void)
+{
+	int i;
+
+	if (lvhpt_bits_clamp)
+	{
+		printk(KERN_INFO "Clamping LVHPT to %d bits\n", lvhpt_bits_clamp);
+		for (i = 0; i < MAX_NUMNODES; i++)
+			long_vhpt_bits[i] = lvhpt_bits_clamp;
+		return;
+	}
+
+	/* In the NUMA case, we evaluate how much memory each node has
+	 * and then try to size it to three times the physical memory
+	 * of the node (as this gives us the best coverage.  As we pin
+	 * this with a TLB entry, we need to make sure the size we
+	 * choose is however suitable for the architecture.
+	 */
+	for (i = 0; i < num_node_memblks; i++) {
+		printk(KERN_ERR "vhpt_addr_mem[%d] = %lx\n", node_memblk[i].nid, node_memblk[i].size);
+		vhpt_addressable_memory[node_memblk[i].nid] +=
+			node_memblk[i].size;
+	}
+
+	for (i = 0; i < MAX_NUMNODES; i++)
+	{
+		unsigned long size =
+			3 * (vhpt_addressable_memory[i] >> PAGE_SHIFT);
+		long_vhpt_bits[i] = find_largest_page_size(size);
+	}
+}
+#endif
+
+/* This version in both NUMA and non-NUMA, since we can use it in either. */
+static void compute_vhpt_size_non_numa(void)
+{
+	/*
+	 * In the non-NUMA case we just put everything in the first
+	 * node space and take a guess.
+	 */
+	if (lvhpt_bits_clamp)
+	{
+		long_vhpt_bits[0] = lvhpt_bits_clamp;
+		printk(KERN_INFO "Clamping LVHPT to %d bits\n", lvhpt_bits_clamp);
+		return;
+	}
+	efi_memmap_walk(get_total_ram, &vhpt_addressable_memory);
+	/*
+	 * For some reason the above doesn't work with the simulator.
+	 * Clamp it to a fairly reasonable 4 megabytes
+	 */
+	long_vhpt_bits[0]  = max(22, find_largest_page_size(vhpt_addressable_memory[0] >> PAGE_SHIFT));
+}
+
+void __init
+compute_vhpt_size(void)
+{
+#ifdef CONFIG_NUMA
+	/* Machines like the ZX1 don't setup all the node info we
+	 * require, but someone might still try to boot a NUMA kernel
+	 * on it.  In this case, fall back to our non-numa case.*/
+	if (num_node_memblks == 0)
+		compute_vhpt_size_non_numa();
+	else
+		compute_vhpt_size_numa();
+#else
+	compute_vhpt_size_non_numa();
+#endif
+}
+
+#endif /* CONFIG_IA64_LONG_FORMAT_VHPT */
+
 void __devinit
 ia64_mmu_init (void *my_cpu_data)
 {
-	unsigned long psr, pta, impl_va_bits;
+	unsigned long psr, pta;
 	extern void __devinit tlb_init (void);
 
 #ifdef CONFIG_DISABLE_VHPT
@@ -347,16 +482,48 @@
 #	define VHPT_ENABLE_BIT	1
 #endif
 
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	int cpu = smp_processor_id();
+#ifdef  CONFIG_NUMA
+	int node = cpu_to_node_map[cpu];
+#else
+	int node = 0; // only one node
+#endif
+	/* boot CPU is guaranteed to be zero, I read that somewhere */
+	if (cpu == 0)
+	{
+		unsigned long size = long_vhpt_size(0);
+		vhpt_base[cpu] = (unsigned long)__alloc_bootmem(size, size, __pa(MAX_DMA_ADDRESS));
+		if (vhpt_base[cpu] == 0)
+			panic("Couldn't allocate VHPT on CPU %d, size: 0x%lx!\n",
+			      cpu, long_vhpt_size(0));
+		printk(KERN_INFO "Allocated long format VHPT for boot processor (CPU %d) at: 0x%lx, size: 0x%lx\n",
+		       cpu, vhpt_base[cpu], long_vhpt_size(0));
+	}
+#else /* !CONFIG_IA64_LONG_FORMAT_VHPT */
+	unsigned long impl_va_bits;
+#endif
 	/* Pin mapping for percpu area into TLB */
 	psr = ia64_clear_ic();
 	ia64_itr(0x2, IA64_TR_PERCPU_DATA, PERCPU_ADDR,
 		 pte_val(pfn_pte(__pa(my_cpu_data) >> PAGE_SHIFT, PAGE_KERNEL)),
 		 PERCPU_PAGE_SHIFT);
 
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+	/* Insert the permanent translation for the VHPT */
+	ia64_itr(0x2, IA64_TR_LONG_VHPT, LONG_VHPT_BASE,
+	pte_val(pfn_pte(__pa(vhpt_base[cpu]) >> PAGE_SHIFT, PAGE_KERNEL)), long_vhpt_bits[node]);
+#endif
 	ia64_set_psr(psr);
 	ia64_srlz_i();
-
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+#	define VHPT_FORMAT_BIT		1
+#	define vhpt_bits		long_vhpt_bits[node]
+	pta = LONG_VHPT_BASE;
+#else
 	/*
+	 * SHORT FORMAT VHPT (virtually mapped linear pagetable)
+	 *
 	 * Check if the virtually mapped linear page table (VMLPT) overlaps with a mapped
 	 * address space.  The IA-64 architecture guarantees that at least 50 bits of
 	 * virtual address space are implemented but if we pick a large enough page size
@@ -367,6 +534,7 @@
 	 * address space to not permit mappings that would overlap with the VMLPT.
 	 * --davidm 00/12/06
 	 */
+#	define VHPT_FORMAT_BIT		0
 #	define pte_bits			3
 #	define mapped_space_bits	(3*(PAGE_SHIFT - pte_bits) + PAGE_SHIFT)
 	/*
@@ -376,28 +544,27 @@
 	 * non-speculative accesses to the virtual page table, so the address range of the
 	 * virtual page table itself needs to be covered by virtual page table.
 	 */
-#	define vmlpt_bits		(impl_va_bits - PAGE_SHIFT + pte_bits)
+#	define vhpt_bits		(impl_va_bits - PAGE_SHIFT + pte_bits)
 #	define POW2(n)			(1ULL << (n))
-
 	impl_va_bits = ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
 
 	if (impl_va_bits < 51 || impl_va_bits > 61)
 		panic("CPU has bogus IMPL_VA_MSB value of %lu!\n", impl_va_bits - 1);
 	/*
 	 * mapped_space_bits - PAGE_SHIFT is the total number of ptes we need,
-	 * which must fit into "vmlpt_bits - pte_bits" slots. Second half of
+	 * which must fit into "vhpt_bits - pte_bits" slots. Second half of
 	 * the test makes sure that our mapped space doesn't overlap the
 	 * unimplemented hole in the middle of the region.
 	 */
-	if ((mapped_space_bits - PAGE_SHIFT > vmlpt_bits - pte_bits) ||
+	if ((mapped_space_bits - PAGE_SHIFT > vhpt_bits - pte_bits) ||
 	    (mapped_space_bits > impl_va_bits - 1))
 		panic("Cannot build a big enough virtual-linear page table"
 		      " to cover mapped address space.\n"
 		      " Try using a smaller page size.\n");
 
-
 	/* place the VMLPT at the end of each page-table mapped region: */
-	pta = POW2(61) - POW2(vmlpt_bits);
+	pta = POW2(61) - POW2(vhpt_bits);
+#endif
 
 	/*
 	 * Set the (virtually mapped linear) page table address.  Bit
@@ -405,10 +572,8 @@
 	 * size of the table, and bit 0 whether the VHPT walker is
 	 * enabled.
 	 */
-	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | VHPT_ENABLE_BIT);
-
+	ia64_set_pta(pta | (VHPT_FORMAT_BIT << 8) | (vhpt_bits << 2) | VHPT_ENABLE_BIT);
 	ia64_tlb_init();
-
 #ifdef	CONFIG_HUGETLB_PAGE
 	ia64_set_rr(HPAGE_REGION_BASE, HPAGE_SHIFT << 2);
 	ia64_srlz_d();
Index: linux-2.6.17-rc3/include/asm-ia64/pgtable.h
===================================================================
--- linux-2.6.17-rc3.orig/include/asm-ia64/pgtable.h	2006-05-01 15:35:44.000000000 +1000
+++ linux-2.6.17-rc3/include/asm-ia64/pgtable.h	2006-05-01 15:35:51.000000000 +1000
@@ -556,6 +556,21 @@
     extern void memmap_init (unsigned long size, int nid, unsigned long zone,
 			     unsigned long start_pfn);
 #  endif /* CONFIG_VIRTUAL_MEM_MAP */
+
+#ifdef CONFIG_IA64_LONG_FORMAT_VHPT
+extern unsigned long vhpt_base[NR_CPUS];
+extern unsigned long long_vhpt_bits[MAX_NUMNODES];
+static inline unsigned long long_vhpt_size(int cpu)
+{
+#ifdef CONFIG_NUMA
+	return (1UL << long_vhpt_bits[cpu_to_node_map[cpu]]);
+#else
+	/* For now, all CPUs in non-numa case have the same size VHPT */
+	return (1UL << long_vhpt_bits[0]);
+#endif
+}
+#endif
+
 # endif /* !__ASSEMBLY__ */
 
 /*
@@ -576,6 +591,11 @@
 #define KERNEL_TR_PAGE_SIZE	(1 << KERNEL_TR_PAGE_SHIFT)
 
 /*
+ * Long format VHPT
+ */
+#define LONG_VHPT_BASE		(0xc000000000000000 - long_vhpt_size(smp_processor_id()))
+
+/*
  * No page table caches to initialise
  */
 #define pgtable_cache_init()	do { } while (0)
Index: linux-2.6.17-rc3/Documentation/kernel-parameters.txt
===================================================================
--- linux-2.6.17-rc3.orig/Documentation/kernel-parameters.txt	2006-05-01 15:35:44.000000000 +1000
+++ linux-2.6.17-rc3/Documentation/kernel-parameters.txt	2006-05-01 15:35:51.000000000 +1000
@@ -50,6 +50,7 @@
 	ISDN	Appropriate ISDN support is enabled.
 	JOY	Appropriate joystick support is enabled.
 	LP	Printer support is enabled.
+	LONG_FORMAT_VHPT Long Format VHPT is enabled
 	LOOP	Loopback device support is enabled.
 	M68k	M68k architecture is enabled.
 			These options have more detailed description inside of
@@ -805,6 +806,19 @@
 	ltpc=		[NET]
 			Format: <io>,<irq>,<dma>
 
+	lvhpt_bits_clamp=	[IA64,LONG_FORMAT_VHPT]
+				Format: <1-39>
+
+				Clamp the size of the LVHPT (on all
+				nodes for a NUMA system) to 2^n bits.
+				E.g. 2^22 gives a LVHPT of 4MB.  We
+				pin a TLB entry of this size, so the
+				size must be valid for the
+				architecture, otherwise your kernel
+				will not boot.  By default we take a
+				good guess at sizing this for optimal
+				operation.
+
 	mac5380=	[HW,SCSI] Format:
 			<can_queue>,<cmd_per_lun>,<sg_tablesize>,<hostid>,<use_tags>
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
