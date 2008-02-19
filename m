Message-Id: <20080219203336.046039000@polaris-admin.engr.sgi.com>
References: <20080219203335.866324000@polaris-admin.engr.sgi.com>
Date: Tue, 19 Feb 2008 12:33:36 -0800
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 1/2] x86_64: Fold pda into per cpu area v3
Content-Disposition: inline; filename=x86_64_fold_pda
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Randy Dunlap <rdunlap@xenotime.net>, Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

	%gs:[&per_cpu_xxxx - __per_cpu_start]

  * The boot_pdas are only needed in head64.c so move the declaration
    over there.  And since the boot_cpu_pda is only used during
    bootup and then copied to the per_cpu areas during init, it is
    then removable.  In addition, the initial cpu_pda pointer table
    is reallocated to be the correct size for the number of cpus.

  * Remove the code that allocates special pda data structures.
    Since the percpu area is currently maintained for all possible
    cpus then the pda regions will stay intact in case cpus are
    hotplugged off and then back on.

  * Relocate the x86_64 percpu variables to begin at zero. Then
    we can directly use the x86_32 percpu operations. x86_32
    offsets %fs by __per_cpu_start. x86_64 has %gs pointing
    directly to the pda and the per cpu area thereby allowing
    access to the pda with the x86_64 pda operations and access
    to the per cpu variables using x86_32 percpu operations.

  * This also supports further integration of x86_32/64.

Based on git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git

Cc:	Andy Whitcroft <apw@shadowen.org>
Cc:	Randy Dunlap <rdunlap@xenotime.net>
Cc:	Joel Schopp <jschopp@austin.ibm.com>

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>
---
v3: * split generic/x86-specific into two patches

v2: * rebased and retested using linux-2.6.git
    * fixed errors reported by checkpatch.pl
      - one error that I don't understand (why did it find an error on
        this line while the other similar lines were ok?)
        (Cc'd MAINTAINERS)

ERROR: Macros with complex values should be enclosed in parenthesis
#392: FILE: include/linux/percpu.h:23:
+	__attribute__((__section__(".data.percpu.first")))		\

---
 arch/x86/Kconfig                 |    3 +
 arch/x86/kernel/head64.c         |   41 ++++++++++++++++++++++++
 arch/x86/kernel/setup64.c        |   66 ++++++++++++++++++++++++---------------
 arch/x86/kernel/smpboot_64.c     |   16 ---------
 arch/x86/kernel/vmlinux_64.lds.S |    1 
 include/asm-x86/pda.h            |   13 +++++--
 include/asm-x86/percpu.h         |   33 +++++++++++--------
 7 files changed, 115 insertions(+), 58 deletions(-)

--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -121,6 +121,9 @@ config ARCH_HAS_CPU_RELAX
 config HAVE_SETUP_PER_CPU_AREA
 	def_bool X86_64
 
+config HAVE_ZERO_BASED_PER_CPU
+	def_bool X86_64
+
 config ARCH_HIBERNATION_POSSIBLE
 	def_bool y
 	depends on !SMP || !X86_VOYAGER
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -11,6 +11,7 @@
 #include <linux/string.h>
 #include <linux/percpu.h>
 #include <linux/start_kernel.h>
+#include <linux/bootmem.h>
 
 #include <asm/processor.h>
 #include <asm/proto.h>
@@ -23,6 +24,12 @@
 #include <asm/kdebug.h>
 #include <asm/e820.h>
 
+#ifdef CONFIG_SMP
+/* Only used before the per cpu areas are setup. */
+static struct x8664_pda boot_cpu_pda[NR_CPUS] __initdata;
+static struct x8664_pda *_cpu_pda_init[NR_CPUS] __initdata;
+#endif
+
 static void __init zap_identity_mappings(void)
 {
 	pgd_t *pgd = pgd_offset_k(0UL);
@@ -102,8 +109,14 @@ void __init x86_64_start_kernel(char * r
 
 	early_printk("Kernel alive\n");
 
+#ifdef CONFIG_SMP
+	_cpu_pda = (void *)_cpu_pda_init;
  	for (i = 0; i < NR_CPUS; i++)
  		cpu_pda(i) = &boot_cpu_pda[i];
+#endif
+
+	/* setup percpu segment offset for cpu 0 */
+	cpu_pda(0)->data_offset = (unsigned long)__per_cpu_load;
 
 	pda_init(0);
 	copy_bootdata(__va(real_mode_data));
@@ -128,3 +141,31 @@ void __init x86_64_start_kernel(char * r
 
 	start_kernel();
 }
+
+#ifdef	CONFIG_SMP
+/*
+ * Remove initial boot_cpu_pda array and cpu_pda pointer table.
+ *
+ * This depends on setup_per_cpu_areas relocating the pda to the beginning
+ * of the per_cpu area so that (_cpu_pda[i] != &boot_cpu_pda[i]).  If it
+ * is equal then the new pda has not been setup for this cpu, and the pda
+ * table will have a NULL address for this cpu.
+ */
+void __init x86_64_cleanup_pda(void)
+{
+	int i;
+
+	_cpu_pda = alloc_bootmem_low(nr_cpu_ids * sizeof(void *));
+
+	if (!_cpu_pda)
+		panic("Cannot allocate cpu pda table\n");
+
+	/* cpu_pda() now points to allocated cpu_pda_table */
+
+	for (i = 0; i < NR_CPUS; i++)
+		if (_cpu_pda_init[i] == &boot_cpu_pda[i])
+			cpu_pda(i) = NULL;
+		else
+			cpu_pda(i) = _cpu_pda_init[i];
+}
+#endif
--- a/arch/x86/kernel/setup64.c
+++ b/arch/x86/kernel/setup64.c
@@ -32,9 +32,13 @@ struct boot_params boot_params;
 
 cpumask_t cpu_initialized __cpuinitdata = CPU_MASK_NONE;
 
-struct x8664_pda *_cpu_pda[NR_CPUS] __read_mostly;
+#ifdef CONFIG_SMP
+struct x8664_pda **_cpu_pda __read_mostly;
 EXPORT_SYMBOL(_cpu_pda);
-struct x8664_pda boot_cpu_pda[NR_CPUS] __cacheline_aligned;
+#endif
+
+DEFINE_PER_CPU_FIRST(struct x8664_pda, pda);
+EXPORT_PER_CPU_SYMBOL(pda);
 
 struct desc_ptr idt_descr = { 256 * 16 - 1, (unsigned long) idt_table };
 
@@ -95,22 +99,14 @@ static void __init setup_per_cpu_maps(vo
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
-#ifdef CONFIG_SMP
-		if (per_cpu_offset(cpu)) {
-#endif
-			per_cpu(x86_cpu_to_apicid, cpu) =
-						x86_cpu_to_apicid_init[cpu];
-			per_cpu(x86_bios_cpu_apicid, cpu) =
-						x86_bios_cpu_apicid_init[cpu];
+		per_cpu(x86_cpu_to_apicid, cpu) =
+					x86_cpu_to_apicid_init[cpu];
+
+		per_cpu(x86_bios_cpu_apicid, cpu) =
+					x86_bios_cpu_apicid_init[cpu];
 #ifdef CONFIG_NUMA
-			per_cpu(x86_cpu_to_node_map, cpu) =
-						x86_cpu_to_node_map_init[cpu];
-#endif
-#ifdef CONFIG_SMP
-		}
-		else
-			printk(KERN_NOTICE "per_cpu_offset zero for cpu %d\n",
-									cpu);
+		per_cpu(x86_cpu_to_node_map, cpu) =
+					x86_cpu_to_node_map_init[cpu];
 #endif
 	}
 
@@ -139,25 +135,45 @@ void __init setup_per_cpu_areas(void)
 	/* Copy section for each CPU (we discard the original) */
 	size = PERCPU_ENOUGH_ROOM;
 
-	printk(KERN_INFO "PERCPU: Allocating %lu bytes of per cpu data\n", size);
-	for_each_cpu_mask (i, cpu_possible_map) {
+	printk(KERN_INFO
+		"PERCPU: Allocating %lu bytes of per cpu data\n", size);
+
+	for_each_possible_cpu(i) {
+
+#ifndef CONFIG_NEED_MULTIPLE_NODES
+		char *ptr = alloc_bootmem_pages(size);
+#else
 		char *ptr;
 
-		if (!NODE_DATA(early_cpu_to_node(i))) {
-			printk("cpu with no node %d, num_online_nodes %d\n",
-			       i, num_online_nodes());
+		if (NODE_DATA(early_cpu_to_node(i)))
+			ptr = alloc_bootmem_pages_node
+				(NODE_DATA(early_cpu_to_node(i)), size);
+
+		else {
+			printk(KERN_INFO
+			       "cpu %d has no node or node-local memory\n", i);
 			ptr = alloc_bootmem_pages(size);
-		} else { 
-			ptr = alloc_bootmem_pages_node(NODE_DATA(early_cpu_to_node(i)), size);
 		}
+#endif
 		if (!ptr)
 			panic("Cannot allocate cpu data for CPU %d\n", i);
+
+		memcpy(ptr, __per_cpu_load, __per_cpu_size);
+
+		/* Relocate the pda */
+		memcpy(ptr, cpu_pda(i), sizeof(struct x8664_pda));
+		cpu_pda(i) = (struct x8664_pda *)ptr;
 		cpu_pda(i)->data_offset = ptr - __per_cpu_start;
-		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
 	}
 
 	/* setup percpu data maps early */
 	setup_per_cpu_maps();
+
+	/* clean up early cpu_pda pointer array */
+	x86_64_cleanup_pda();
+
+	/* Fix up pda for this processor .... */
+	pda_init(0);
 } 
 
 void pda_init(int cpu)
--- a/arch/x86/kernel/smpboot_64.c
+++ b/arch/x86/kernel/smpboot_64.c
@@ -566,22 +566,6 @@ static int __cpuinit do_boot_cpu(int cpu
 		return -1;
 	}
 
-	/* Allocate node local memory for AP pdas */
-	if (cpu_pda(cpu) == &boot_cpu_pda[cpu]) {
-		struct x8664_pda *newpda, *pda;
-		int node = cpu_to_node(cpu);
-		pda = cpu_pda(cpu);
-		newpda = kmalloc_node(sizeof (struct x8664_pda), GFP_ATOMIC,
-				      node);
-		if (newpda) {
-			memcpy(newpda, pda, sizeof (struct x8664_pda));
-			cpu_pda(cpu) = newpda;
-		} else
-			printk(KERN_ERR
-		"Could not allocate node local PDA for CPU %d on node %d\n",
-				cpu, node);
-	}
-
 	alternatives_smp_switch(1);
 
 	c_idle.idle = get_idle_for_cpu(cpu);
--- a/arch/x86/kernel/vmlinux_64.lds.S
+++ b/arch/x86/kernel/vmlinux_64.lds.S
@@ -16,6 +16,7 @@ jiffies_64 = jiffies;
 _proxy_pda = 1;
 PHDRS {
 	text PT_LOAD FLAGS(5);	/* R_E */
+	percpu PT_LOAD FLAGS(4);	/* R__ */
 	data PT_LOAD FLAGS(7);	/* RWE */
 	user PT_LOAD FLAGS(7);	/* RWE */
 	data.init PT_LOAD FLAGS(7);	/* RWE */
--- a/include/asm-x86/pda.h
+++ b/include/asm-x86/pda.h
@@ -38,11 +38,16 @@ struct x8664_pda {
 	unsigned irq_spurious_count;
 } ____cacheline_aligned_in_smp;
 
-extern struct x8664_pda *_cpu_pda[];
-extern struct x8664_pda boot_cpu_pda[];
-extern void pda_init(int);
-
+#ifdef CONFIG_SMP
 #define cpu_pda(i) (_cpu_pda[i])
+extern struct x8664_pda **_cpu_pda;
+extern void x86_64_cleanup_pda(void);
+#else
+#define	cpu_pda(i)	(&per_cpu(pda, i))
+static inline void x86_64_cleanup_pda(void) { }
+#endif
+
+extern void pda_init(int);
 
 /*
  * There is no fast way to get the base address of the PDA, all the accesses
--- a/include/asm-x86/percpu.h
+++ b/include/asm-x86/percpu.h
@@ -13,13 +13,19 @@
 #include <asm/pda.h>
 
 #define __per_cpu_offset(cpu) (cpu_pda(cpu)->data_offset)
-#define __my_cpu_offset read_pda(data_offset)
-
 #define per_cpu_offset(x) (__per_cpu_offset(x))
 
+#define __my_cpu_offset read_pda(data_offset)
+#define __percpu_seg "%%gs:"
+
+#else
+#define __percpu_seg ""
 #endif
 #include <asm-generic/percpu.h>
 
+/* Calculate the offset to use with the segment register */
+#define seg_offset(name)   per_cpu_var(name)
+
 DECLARE_PER_CPU(struct x8664_pda, pda);
 
 #else /* CONFIG_X86_64 */
@@ -64,16 +70,11 @@ DECLARE_PER_CPU(struct x8664_pda, pda);
  *    PER_CPU(cpu_gdt_descr, %ebx)
  */
 #ifdef CONFIG_SMP
-
 #define __my_cpu_offset x86_read_percpu(this_cpu_off)
-
 /* fs segment starts at (positive) offset == __per_cpu_offset[cpu] */
 #define __percpu_seg "%%fs:"
-
 #else  /* !SMP */
-
 #define __percpu_seg ""
-
 #endif	/* SMP */
 
 #include <asm-generic/percpu.h>
@@ -81,6 +82,13 @@ DECLARE_PER_CPU(struct x8664_pda, pda);
 /* We can use this directly for local CPU (faster). */
 DECLARE_PER_CPU(unsigned long, this_cpu_off);
 
+#define seg_offset(name)	per_cpu_var(name)
+
+#endif /* __ASSEMBLY__ */
+#endif /* !CONFIG_X86_64 */
+
+#ifndef __ASSEMBLY__
+
 /* For arch-specific code, we can use direct single-insn ops (they
  * don't give an lvalue though). */
 extern void __bad_percpu_size(void);
@@ -132,11 +140,10 @@ extern void __bad_percpu_size(void);
 		}						\
 		ret__; })
 
-#define x86_read_percpu(var) percpu_from_op("mov", per_cpu__##var)
-#define x86_write_percpu(var,val) percpu_to_op("mov", per_cpu__##var, val)
-#define x86_add_percpu(var,val) percpu_to_op("add", per_cpu__##var, val)
-#define x86_sub_percpu(var,val) percpu_to_op("sub", per_cpu__##var, val)
-#define x86_or_percpu(var,val) percpu_to_op("or", per_cpu__##var, val)
+#define x86_read_percpu(var) percpu_from_op("mov", seg_offset(var))
+#define x86_write_percpu(var, val) percpu_to_op("mov", seg_offset(var), val)
+#define x86_add_percpu(var, val) percpu_to_op("add", seg_offset(var), val)
+#define x86_sub_percpu(var, val) percpu_to_op("sub", seg_offset(var), val)
+#define x86_or_percpu(var, val) percpu_to_op("or", seg_offset(var), val)
 #endif /* !__ASSEMBLY__ */
-#endif /* !CONFIG_X86_64 */
 #endif /* _ASM_X86_PERCPU_H_ */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
