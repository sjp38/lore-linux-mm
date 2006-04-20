Date: Thu, 20 Apr 2006 08:53:16 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [RFC] - Kernel text replication on IA64
Message-ID: <20060420135315.GA28021@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org
Cc: lee.schermerhorn@hp.com, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

There was a question about the effects of kernel text replication last
month.  I was curious so I resurrected an old trillian patch (Tony Luck's)
& got it working again. Here is the preliminary patch & some data about
the benefit.

This is still a work-in-progress. I have not concluded whether I think the
patch is beneficial. Please take a look. Comments are appreciated.

Note that one piece is missing from the patch. It is currently
incompatible with kprobes. That is easy to fix if we decide to go forward
with the patch.  For now, make sure that CONFIG_KPROBES is not selected.
Kdb breakpoints will not work, either.  (But, then, kdb breakpoints don't
really work anyway).

----------------

Here is a summary that shows the benefit of kernel text replication on a
few selected microbenchmarks.

The tests were run on a kernel that supports kernel text replication as a
boottime option. The first column shows the time (in usec) to run the
microbenchmark when text replication is disabled. The second column is the
same kernel but text replication was enabled at boot time.

Each test supports an option to select whether to run the test with a
"hot" or "cold" cache.

If "hot" is selected, the test is run multiple times in a tight loop.
Because the microbenchmarks have a small cache footprint, replication is
not expected to help if caches are hot. The rate of i-cache misses for
kernel code should be low.

If "cold" is selected, all caches are flushed between each iteration of
the loop. This removes any cached kernel code from the caches & will
increase the time of the next system call(s). When kernel text replication
is enabled, the caches are refilled from the local node which has a
smaller latency than when refilling from node 0 if replication is
disabled.  The cache flush time is not included in the times but does have
a small residual impact on timing (less than a usec).

All tests were run on a 12 cpu (Itanium2, 900 MHz, 1.5MB L3) , 6 node
system. All cpus are idle with the exception of the cpu running the test.

Tests run on node 0 (as expected) show no improvement when text
replication is enabled. Tests run on other nodes show a significant
improvement when replication is enabled.

Note that these are microbenchmarks. The effect on real applications has
not been determined. Applications that have small cache footprints or
applications that are mostly cpu bound in user code are not expected to
show significant improvement with kernel text replication. In addition,
the improvements when replication is enabled will increase as system size
or system activity increases.

Enabling replication reserves 1 additional DTLB entry for kernel code.
This reduces the number of DTLB entries that is available for user code.
There is the potential that this could impact some applications.
Additional measurements are still needed.



------------------------------------------------------
  Cold cache. Running on node 3 of 6 node system

                         NoRep        Rep   %improvement
null                :    0.894 :    0.812 :         9.17
forkexit            :  521.518 :  416.467 :        20.14
openclose           :  106.683 :   75.000 :        29.70
pid                 :    2.577 :    2.356 :         8.58
time                :   17.882 :   11.693 :        34.61
gettimeofday        :   17.523 :   11.695 :        33.26


------------------------------------------------------
   Hot cache. Running on node 3 of 6 node system

                         NoRep        Rep   %improvement
null                :    0.044 :    0.044 :         0.00
forkexit            :  162.019 :  151.927 :         6.23
openclose           :    8.445 :    8.128 :         3.75
pid                 :    0.067 :    0.067 :         0.00
time                :    1.110 :    1.100 :         0.90
gettimeofday        :    1.079 :    1.074 :         0.46







 arch/ia64/Kconfig              |    7 ++
 arch/ia64/kernel/head.S        |   89 +++++++++++++++++++++++++++++
 arch/ia64/kernel/mca_asm.S     |   13 +++-
 arch/ia64/kernel/setup.c       |    6 +
 arch/ia64/kernel/smpboot.c     |    2 
 arch/ia64/kernel/vmlinux.lds.S |   71 +++++++++++++----------
 arch/ia64/mm/init.c            |  125 ++++++++++++++++++++++++++++++++++++++---
 include/asm-ia64/kregs.h       |    7 +-
 include/asm-ia64/numa.h        |   10 +++
 include/asm-ia64/pgtable.h     |    1 
 include/asm-ia64/system.h      |    1 
 11 files changed, 294 insertions(+), 38 deletions(-)



Index: linux/arch/ia64/kernel/head.S
===================================================================
--- linux.orig/arch/ia64/kernel/head.S	2006-04-18 14:35:34.403444255 -0500
+++ linux/arch/ia64/kernel/head.S	2006-04-18 14:36:14.895436090 -0500
@@ -247,6 +247,20 @@ start_ap:
 	;;
 	itr.d dtr[r16]=r18
 	;;
+#ifdef CONFIG_KERNEL_TEXT_REPLICATION
+	mov r16=IA64_TR_KERNEL_DATA
+	movl r17=KERNEL_DATA_START
+	movl r18=PAGE_KERNEL
+	;;
+	or r18=r2,r18
+	mov cr.ifa=r17
+	;;
+	srlz.i
+	;;
+	itr.d dtr[r16]=r18
+	;;
+#endif
+
 	srlz.i
 
 	/*
@@ -1218,4 +1232,79 @@ tlb_purge_done:
 END(ia64_jump_to_sal)
 #endif /* CONFIG_HOTPLUG_CPU */
 
+
+#ifdef CONFIG_KERNEL_TEXT_REPLICATION
+
+#define PSR_BITS_TO_CLEAR						\
+	(IA64_PSR_I | IA64_PSR_IT | IA64_PSR_DT | IA64_PSR_RT |		\
+	 IA64_PSR_DD | IA64_PSR_SS | IA64_PSR_RI | IA64_PSR_ED |	\
+	 IA64_PSR_DFL | IA64_PSR_DFH)
+
+#define PSR_BITS_TO_SET							\
+	(IA64_PSR_BN)
+
+/*
+ * ccNUMA systems bring up all cpus running from the copy of the
+ * kernel that elilo loaded into memory.  Processors that find that
+ * they are not using the kernel text/rodata that is on their local
+ * node can use this routine to reset their TLB mappings to point
+ * at the correct copy.
+ *
+ * This is like the magic trick where you pull a table cloth out
+ * from under a table covered with plates, glasses and silverware,
+ * except in this version we slide an identical tablecloth in to
+ * replace the one we pulled out.
+ *
+ * Inputs:
+ *	in0 = virtual address of local node copy to be mapped
+ */
+
+GLOBAL_ENTRY(remap_kernel_text)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
+	alloc loc1=ar.pfs,8,5,7,0
+	mov loc0=rp
+	.body
+	;;
+	mov loc4=ar.rsc			// save RSE configuration
+	mov ar.rsc=0			// put RSE in enforced lazy, LE mode
+	tpa in0=in0
+	;;
+	movl r16=PSR_BITS_TO_CLEAR
+	mov loc3=psr			// save processor status word
+	movl r17=PSR_BITS_TO_SET
+	;;
+	or loc3=loc3,r17
+	;;
+	andcm r16=loc3,r16		// get psr with IT, DT, and RT bits cleared
+	br.call.sptk.few rp=ia64_switch_mode_phys
+.ret3:
+	rsm psr.i | psr.ic
+	movl r24=KERNEL_START
+	movl r25=KERNEL_TR_PAGE_SHIFT<<2
+	movl r21=PAGE_KERNELRX
+	mov r22=IA64_TR_KERNEL
+	;;
+	ptr.i r24,r25			// purge old code mapping
+	;;
+	srlz.i
+	;;
+	mov cr.ifa=r24
+	mov cr.itir=r25
+	or in0=r21,in0
+	;;
+	srlz.i
+	;;
+	itr.i itr[r22]=in0
+	;;
+	srlz.i
+	;;
+	mov r16=loc3
+	br.call.sptk.few rp=ia64_switch_mode_virt // return to virtual mode
+.ret4:	mov ar.rsc=loc4			// restore RSE configuration
+	mov ar.pfs=loc1
+	mov rp=loc0
+	br.ret.sptk.few rp
+END(remap_kernel_text)
+#endif /* CONFIG_KERNEL_TEXT_REPLICATION */
+
 #endif /* CONFIG_SMP */
Index: linux/arch/ia64/kernel/smpboot.c
===================================================================
--- linux.orig/arch/ia64/kernel/smpboot.c	2006-04-18 14:35:34.403444255 -0500
+++ linux/arch/ia64/kernel/smpboot.c	2006-04-18 14:36:14.895436090 -0500
@@ -402,6 +402,8 @@ smp_callin (void)
 
 	smp_setup_percpu_timer();
 
+	check_remap_kernel_text(cpuid);
+
 	ia64_mca_cmc_vector_setup();	/* Setup vector on AP */
 
 #ifdef CONFIG_PERFMON
Index: linux/arch/ia64/mm/init.c
===================================================================
--- linux.orig/arch/ia64/mm/init.c	2006-04-18 14:35:34.407443859 -0500
+++ linux/arch/ia64/mm/init.c	2006-04-18 15:22:15.766146875 -0500
@@ -60,6 +60,88 @@ EXPORT_SYMBOL(zero_page_memmap_ptr);
 #define MAX_PGT_FREES_PER_PASS		16L
 #define PGT_FRACTION_OF_NODE_MEM	16
 
+static unsigned long free_mem_range (void *, void *);
+
+#ifdef	CONFIG_KERNEL_TEXT_REPLICATION
+/*
+ * Set ktreplicate to 0 to disable kernel text replication.
+ */
+static int ktreplicate=1;
+
+static int __init replicate_setup(char *str)
+{
+	get_option(&str, &ktreplicate);
+	return 1;
+}
+
+__setup("ktreplicate=", replicate_setup);
+
+
+/*
+ * Addresses of per-node copies of kernel text/readonly-data
+ */
+static void *kcopybase[MAX_NUMNODES];
+
+/*
+ * Remap the kernel text for this cpu if a closer copy
+ * is available.
+ */
+void
+check_remap_kernel_text(int cpuid)
+{
+        if (kcopybase[node_cpuid[cpuid].nid])
+		remap_kernel_text(kcopybase[node_cpuid[cpuid].nid]);
+}
+
+/*
+ * Make properly aligned copies of kernel text and read-only
+ * data on other nodes.
+ */
+void replicate_kernel(void)
+{
+	extern void *_start_replicate, *_end_replicate;
+	void *kstart = &_start_replicate;
+	void *kend = &_end_replicate;
+	struct page *page;
+	int nid, length, copies = 1;
+	void *addr;
+	int kloadnode;
+	int cpuid = smp_processor_id();
+
+	kloadnode = paddr_to_nid(ia64_tpa(&kcopybase[0]));
+	kcopybase[kloadnode] = ia64_imva(&_start_replicate);
+	kcopybase[node_cpuid[cpuid].nid] = ia64_imva(&_start_replicate);
+
+	if (ktreplicate) {
+		length = kend - kstart;
+		for_each_online_node(nid) {
+			if (nid == kloadnode || nr_cpus_node(nid) == 0)
+				continue;
+
+			page = alloc_pages_node(nid, GFP_KERNEL, get_order(KERNEL_TR_PAGE_SIZE));
+			if (!page) {
+				printk("Could not replicate kernel to node %d\n", nid);
+				continue;
+			}
+			addr = page_address(page);
+			free_mem_range(addr + length, addr + KERNEL_TR_PAGE_SIZE);
+			kcopybase[nid] = addr;
+			memcpy(addr, &_start_replicate, length);
+			copies++;
+		}
+		printk("Replicated kernel to %d nodes\n", copies);
+	} else {
+		printk("Kernel text replication is disabled\n");
+	}
+
+	/*
+	 * Make kernel text read-only. We do this even if replication * is disabled.
+	 */
+	check_remap_kernel_text(cpuid);
+
+}
+#endif	/* CONFIG_KERNEL_TEXT_REPLICATION */
+
 static inline long
 max_pgt_pages(void)
 {
@@ -194,22 +276,51 @@ ia64_init_addr_space (void)
 	}
 }
 
-void
-free_initmem (void)
+static unsigned long
+free_mem_range (void *addr, void *eaddr)
 {
-	unsigned long addr, eaddr;
+	unsigned long pages_freed = 0;
 
-	addr = (unsigned long) ia64_imva(__init_begin);
-	eaddr = (unsigned long) ia64_imva(__init_end);
 	while (addr < eaddr) {
 		ClearPageReserved(virt_to_page(addr));
 		init_page_count(virt_to_page(addr));
-		free_page(addr);
+		free_page((u64)addr);
 		++totalram_pages;
 		addr += PAGE_SIZE;
+		++pages_freed;
+	}
+	return pages_freed;
+}
+
+void
+free_initmem (void)
+{
+	void *addr, *eaddr;
+	unsigned long pages_freed = 0;
+	extern char __init_data_begin[], __init_data_end[];
+	int nid;
+
+#ifdef CONFIG_KERNEL_TEXT_REPLICATION
+	for_each_online_node(nid) {
+		if (!kcopybase[nid])
+			continue;
+		addr = kcopybase[nid] + ((u64) ia64_imva(&__init_begin) & (KERNEL_TR_PAGE_SIZE-1));
+		eaddr = kcopybase[nid] + ((u64) ia64_imva(&__init_end) & (KERNEL_TR_PAGE_SIZE-1));
+		pages_freed += free_mem_range(addr, eaddr);
 	}
+#else
+	addr = ia64_imva(__init_begin);
+	eaddr = ia64_imva(__init_end);
+	pages_freed += free_mem_range(addr, eaddr);
+#endif
+
+	addr = ia64_imva(__init_data_begin);
+	eaddr = ia64_imva(__init_data_end);
+	pages_freed += free_mem_range(addr, eaddr);
+
 	printk(KERN_INFO "Freeing unused kernel memory: %ldkB freed\n",
-	       (__init_end - __init_begin) >> 10);
+	       (pages_freed << PAGE_SHIFT) >> 10);
+
 }
 
 void __init
Index: linux/arch/ia64/kernel/mca_asm.S
===================================================================
--- linux.orig/arch/ia64/kernel/mca_asm.S	2006-04-18 14:35:34.403444255 -0500
+++ linux/arch/ia64/kernel/mca_asm.S	2006-04-18 14:36:14.899435695 -0500
@@ -96,8 +96,15 @@ ia64_do_tlb_purge:
 	mov r18=KERNEL_TR_PAGE_SHIFT<<2
 	;;
 	ptr.i r16, r18
-	ptr.d r16, r18
 	;;
+
+#ifdef CONFIG_KERNEL_TEXT_REPLICATION
+	movl r17=KERNEL_DATA_START
+	;;
+	ptr.d r17, r18
+	;;
+#endif
+
 	srlz.i
 	;;
 	srlz.d
@@ -192,6 +199,10 @@ ia64_reload_tr:
 	;;
         itr.i itr[r16]=r18
 	;;
+	movl r17=KERNEL_DATA_START
+	;;
+	mov cr.ifa=r17
+	;;
         itr.d dtr[r16]=r18
         ;;
 	srlz.i
Index: linux/arch/ia64/kernel/setup.c
===================================================================
--- linux.orig/arch/ia64/kernel/setup.c	2006-04-18 14:35:34.403444255 -0500
+++ linux/arch/ia64/kernel/setup.c	2006-04-18 14:36:14.899435695 -0500
@@ -887,6 +887,12 @@ check_bugs (void)
 {
 	ia64_patch_mckinley_e9((unsigned long) __start___mckinley_e9_bundles,
 			       (unsigned long) __end___mckinley_e9_bundles);
+
+	/*
+	 * This really doesn't belong here but this is the last arch-specific
+	 * callout before starting cpus. Need a better place for this.
+	 */
+	replicate_kernel();
 }
 
 static int __init run_dmi_scan(void)
Index: linux/include/asm-ia64/system.h
===================================================================
--- linux.orig/include/asm-ia64/system.h	2006-04-18 14:35:34.407443859 -0500
+++ linux/include/asm-ia64/system.h	2006-04-18 14:36:14.903435299 -0500
@@ -26,6 +26,7 @@
  * - 0xa000000000000000+3*PERCPU_PAGE_SIZE remain unmapped (guard page)
  */
 #define KERNEL_START		 (GATE_ADDR+0x100000000)
+#define KERNEL_DATA_START	 (GATE_ADDR+0x180000000)
 #define PERCPU_ADDR		(-PERCPU_PAGE_SIZE)
 
 #ifndef __ASSEMBLY__
Index: linux/arch/ia64/kernel/vmlinux.lds.S
===================================================================
--- linux.orig/arch/ia64/kernel/vmlinux.lds.S	2006-04-18 14:35:34.403444255 -0500
+++ linux/arch/ia64/kernel/vmlinux.lds.S	2006-04-18 15:38:28.645844817 -0500
@@ -39,6 +39,7 @@ SECTIONS
   code : { } :code
   . = KERNEL_START;
 
+  _start_replicate = .;
   _text = .;
   _stext = .;
 
@@ -79,8 +80,30 @@ SECTIONS
 	  __stop___mca_table = .;
 	}
 
-  /* Global data */
-  _data = .;
+  .data.patch.vtop : AT(ADDR(.data.patch.vtop) - LOAD_OFFSET)
+	{
+	  __start___vtop_patchlist = .;
+	  *(.data.patch.vtop)
+	  __end___vtop_patchlist = .;
+	}
+
+  .data.patch.mckinley_e9 : AT(ADDR(.data.patch.mckinley_e9) - LOAD_OFFSET)
+	{
+	  __start___mckinley_e9_bundles = .;
+	  *(.data.patch.mckinley_e9)
+	  __end___mckinley_e9_bundles = .;
+	}
+
+#if defined(CONFIG_IA64_GENERIC)
+  /* Machine Vector */
+  . = ALIGN(16);
+  .machvec : AT(ADDR(.machvec) - LOAD_OFFSET)
+	{
+	  machvec_start = .;
+	  *(.machvec)
+	  machvec_end = .;
+	}
+#endif
 
   /* Unwind info & table: */
   . = ALIGN(8);
@@ -98,7 +121,7 @@ SECTIONS
   .opd : AT(ADDR(.opd) - LOAD_OFFSET)
 	{ *(.opd) }
 
-  /* Initialization code and data: */
+  /* Initialization code: */
 
   . = ALIGN(PAGE_SIZE);
   __init_begin = .;
@@ -109,6 +132,21 @@ SECTIONS
 	  _einittext = .;
 	}
 
+  . = ALIGN(PAGE_SIZE);
+  __init_end = .;
+  _end_replicate = .;
+
+#ifdef CONFIG_KERNEL_TEXT_REPLICATION
+#undef LOAD_OFFSET
+#define LOAD_OFFSET	(KERNEL_DATA_START - KERNEL_TR_PAGE_SIZE)
+. = KERNEL_DATA_START + (. - KERNEL_START);
+#endif
+
+  /* Global read/write data */
+  _data = .;
+
+  /* Initialization data: */
+  __init_data_begin = .;
   .init.data : AT(ADDR(.init.data) - LOAD_OFFSET)
 	{ *(.init.data) }
 
@@ -139,31 +177,6 @@ SECTIONS
 	  __initcall_end = .;
 	}
 
-  .data.patch.vtop : AT(ADDR(.data.patch.vtop) - LOAD_OFFSET)
-	{
-	  __start___vtop_patchlist = .;
-	  *(.data.patch.vtop)
-	  __end___vtop_patchlist = .;
-	}
-
-  .data.patch.mckinley_e9 : AT(ADDR(.data.patch.mckinley_e9) - LOAD_OFFSET)
-	{
-	  __start___mckinley_e9_bundles = .;
-	  *(.data.patch.mckinley_e9)
-	  __end___mckinley_e9_bundles = .;
-	}
-
-#if defined(CONFIG_IA64_GENERIC)
-  /* Machine Vector */
-  . = ALIGN(16);
-  .machvec : AT(ADDR(.machvec) - LOAD_OFFSET)
-	{
-	  machvec_start = .;
-	  *(.machvec)
-	  machvec_end = .;
-	}
-#endif
-
    __con_initcall_start = .;
   .con_initcall.init : AT(ADDR(.con_initcall.init) - LOAD_OFFSET)
 	{ *(.con_initcall.init) }
@@ -173,7 +186,7 @@ SECTIONS
 	{ *(.security_initcall.init) }
   __security_initcall_end = .;
   . = ALIGN(PAGE_SIZE);
-  __init_end = .;
+  __init_data_end = .;
 
   /* The initial task and kernel stack */
   .data.init_task : AT(ADDR(.data.init_task) - LOAD_OFFSET)
Index: linux/include/asm-ia64/kregs.h
===================================================================
--- linux.orig/include/asm-ia64/kregs.h	2006-04-18 14:35:34.407443859 -0500
+++ linux/include/asm-ia64/kregs.h	2006-04-18 14:36:14.903435299 -0500
@@ -27,11 +27,16 @@
 /*
  * Translation registers:
  */
-#define IA64_TR_KERNEL		0	/* itr0, dtr0: maps kernel image (code & data) */
+#define IA64_TR_KERNEL		0	/* itr0, dtr0: maps kernel image (code & readonly data) */
+					/*    also maps RW data if text replication is not enabled */
 #define IA64_TR_PALCODE		1	/* itr1: maps PALcode as required by EFI */
 #define IA64_TR_PERCPU_DATA	1	/* dtr1: percpu data */
 #define IA64_TR_CURRENT_STACK	2	/* dtr2: maps kernel's memory- & register-stacks */
 
+#ifdef CONFIG_KERNEL_TEXT_REPLICATION
+#define IA64_TR_KERNEL_DATA	3	/* dtr3: maps kernel's global data */
+#endif
+
 /* Processor status register bits: */
 #define IA64_PSR_BE_BIT		1
 #define IA64_PSR_UP_BIT		2
Index: linux/include/asm-ia64/numa.h
===================================================================
--- linux.orig/include/asm-ia64/numa.h	2006-04-18 14:35:34.407443859 -0500
+++ linux/include/asm-ia64/numa.h	2006-04-18 14:36:14.903435299 -0500
@@ -71,4 +71,14 @@ extern int paddr_to_nid(unsigned long pa
 
 #endif /* CONFIG_NUMA */
 
+#ifdef CONFIG_KERNEL_TEXT_REPLICATION
+extern void remap_kernel_text(void *);
+extern void check_remap_kernel_text(int);
+extern void replicate_kernel(void);
+#else
+#define remap_kernel_text(p)
+#define check_remap_kernel_text(c)
+#define replicate_kernel()
+#endif
+
 #endif /* _ASM_IA64_NUMA_H */
Index: linux/include/asm-ia64/pgtable.h
===================================================================
--- linux.orig/include/asm-ia64/pgtable.h	2006-04-18 14:35:34.411443463 -0500
+++ linux/include/asm-ia64/pgtable.h	2006-04-18 14:36:14.903435299 -0500
@@ -146,6 +146,7 @@
 #define PAGE_COPY_EXEC	__pgprot(__ACCESS_BITS | _PAGE_PL_3 | _PAGE_AR_RX)
 #define PAGE_GATE	__pgprot(__ACCESS_BITS | _PAGE_PL_0 | _PAGE_AR_X_RX)
 #define PAGE_KERNEL	__pgprot(__DIRTY_BITS  | _PAGE_PL_0 | _PAGE_AR_RWX)
+#define PAGE_KERNELR	__pgprot(__ACCESS_BITS | _PAGE_PL_0 | _PAGE_AR_R)
 #define PAGE_KERNELRX	__pgprot(__ACCESS_BITS | _PAGE_PL_0 | _PAGE_AR_RX)
 
 # ifndef __ASSEMBLY__
Index: linux/arch/ia64/Kconfig
===================================================================
--- linux.orig/arch/ia64/Kconfig	2006-04-18 14:35:34.407443859 -0500
+++ linux/arch/ia64/Kconfig	2006-04-18 14:36:14.907434903 -0500
@@ -260,6 +260,13 @@ config NR_CPUS
 	  than 64 will cause the use of a CPU mask array, causing a small
 	  performance hit.
 
+config KERNEL_TEXT_REPLICATION
+	bool "Kernel text replication"
+	depends on NUMA
+	default off
+	help
+	  Say Y if you want to eeplicate kernel text on each node of a NUMA system.
+
 config HOTPLUG_CPU
 	bool "Support for hot-pluggable CPUs (EXPERIMENTAL)"
 	depends on SMP && EXPERIMENTAL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
