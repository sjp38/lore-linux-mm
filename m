Date: Wed, 20 Feb 2008 13:07:47 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] x86_64: Fold pda into per cpu area v3
Message-ID: <20080220120747.GA13695@elte.hu>
References: <20080219203335.866324000@polaris-admin.engr.sgi.com> <20080219203336.046039000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Dxnq1zWXvFF0Q93v"
Content-Disposition: inline
In-Reply-To: <20080219203336.046039000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Randy Dunlap <rdunlap@xenotime.net>, Joel Schopp <jschopp@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


* Mike Travis <travis@sgi.com> wrote:

>   * Declare the pda as a per cpu variable. This will move the pda area
>     to an address accessible by the x86_64 per cpu macros.  
>     Subtraction of __per_cpu_start will make the offset based from the 
>     beginning of the per cpu area.  Since %gs is pointing to the pda, 
>     it will then also point to the per cpu variables and can be 
>     accessed thusly:
> 
> 	%gs:[&per_cpu_xxxx - __per_cpu_start]

randconfig QA on x86.git found a crash on x86.git#testing with 
nmi_watchdog=2 (config attached) - and i bisected it down to this patch.

config and crashlog attached. You can pick up x86.git#testing via:

  http://people.redhat.com/mingo/x86.git/README

(since i had to hand-merge the patch when integrating it, i've attached 
the merged version below.)

	Ingo

-------------->
Subject: x86_64: Fold pda into per cpu area v3
From: Mike Travis <travis@sgi.com>
Date: Tue, 19 Feb 2008 12:33:36 -0800

  * Declare the pda as a per cpu variable. This will move the pda area
    to an address accessible by the x86_64 per cpu macros.  Subtraction
    of __per_cpu_start will make the offset based from the beginning
    of the per cpu area.  Since %gs is pointing to the pda, it will
    then also point to the per cpu variables and can be accessed thusly:

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

Cc:	Andy Whitcroft <apw@shadowen.org>
Cc:	Randy Dunlap <rdunlap@xenotime.net>
Cc:	Joel Schopp <jschopp@austin.ibm.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mike Travis <travis@sgi.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 arch/x86/Kconfig                 |    3 +
 arch/x86/kernel/head64.c         |   41 ++++++++++++++++++++++++
 arch/x86/kernel/setup64.c        |   66 ++++++++++++++++++++++++---------------
 arch/x86/kernel/smpboot_64.c     |   16 ---------
 arch/x86/kernel/vmlinux_64.lds.S |    1 
 include/asm-x86/pda.h            |   13 +++++--
 include/asm-x86/percpu.h         |   33 +++++++++++--------
 7 files changed, 115 insertions(+), 58 deletions(-)

Index: linux-x86.q/arch/x86/Kconfig
===================================================================
--- linux-x86.q.orig/arch/x86/Kconfig
+++ linux-x86.q/arch/x86/Kconfig
@@ -122,6 +122,9 @@ config ARCH_HAS_CPU_RELAX
 config HAVE_SETUP_PER_CPU_AREA
 	def_bool X86_64
 
+config HAVE_ZERO_BASED_PER_CPU
+	def_bool X86_64
+
 config ARCH_HIBERNATION_POSSIBLE
 	def_bool y
 	depends on !SMP || !X86_VOYAGER
Index: linux-x86.q/arch/x86/kernel/head64.c
===================================================================
--- linux-x86.q.orig/arch/x86/kernel/head64.c
+++ linux-x86.q/arch/x86/kernel/head64.c
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
Index: linux-x86.q/arch/x86/kernel/setup64.c
===================================================================
--- linux-x86.q.orig/arch/x86/kernel/setup64.c
+++ linux-x86.q/arch/x86/kernel/setup64.c
@@ -33,9 +33,13 @@ struct boot_params boot_params;
 
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
 
@@ -96,22 +100,14 @@ static void __init setup_per_cpu_maps(vo
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
 
@@ -140,25 +136,45 @@ void __init setup_per_cpu_areas(void)
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
Index: linux-x86.q/arch/x86/kernel/smpboot_64.c
===================================================================
--- linux-x86.q.orig/arch/x86/kernel/smpboot_64.c
+++ linux-x86.q/arch/x86/kernel/smpboot_64.c
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
Index: linux-x86.q/arch/x86/kernel/vmlinux_64.lds.S
===================================================================
--- linux-x86.q.orig/arch/x86/kernel/vmlinux_64.lds.S
+++ linux-x86.q/arch/x86/kernel/vmlinux_64.lds.S
@@ -16,6 +16,7 @@ jiffies_64 = jiffies;
 _proxy_pda = 1;
 PHDRS {
 	text PT_LOAD FLAGS(5);	/* R_E */
+	percpu PT_LOAD FLAGS(4);	/* R__ */
 	data PT_LOAD FLAGS(7);	/* RWE */
 	user PT_LOAD FLAGS(7);	/* RWE */
 	data.init PT_LOAD FLAGS(7);	/* RWE */
Index: linux-x86.q/include/asm-x86/pda.h
===================================================================
--- linux-x86.q.orig/include/asm-x86/pda.h
+++ linux-x86.q/include/asm-x86/pda.h
@@ -35,11 +35,16 @@ struct x8664_pda {
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
Index: linux-x86.q/include/asm-x86/percpu.h
===================================================================
--- linux-x86.q.orig/include/asm-x86/percpu.h
+++ linux-x86.q/include/asm-x86/percpu.h
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

--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=config

#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.25-rc2
# Wed Feb 20 12:55:54 2008
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
CONFIG_X86_64=y
CONFIG_X86=y
# CONFIG_GENERIC_LOCKBREAK is not set
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_SEMAPHORE_SLEEPERS=y
CONFIG_FAST_CMPXCHG_LOCAL=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
# CONFIG_QUICKLIST is not set
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
# CONFIG_GENERIC_GPIO is not set
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_DMI=y
CONFIG_RWSEM_GENERIC_SPINLOCK=y
# CONFIG_RWSEM_XCHGADD_ALGORITHM is not set
# CONFIG_ARCH_HAS_ILOG2_U32 is not set
# CONFIG_ARCH_HAS_ILOG2_U64 is not set
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_HAVE_ZERO_BASED_PER_CPU=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ZONE_DMA32=y
CONFIG_ARCH_POPULATES_NODE_MAP=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_AOUT=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_X86_SMP=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_X86_TRAMPOLINE=y
# CONFIG_KTIME_SCALAR is not set
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_LOCK_KERNEL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_SWAP=y
# CONFIG_SYSVIPC is not set
CONFIG_POSIX_MQUEUE=y
# CONFIG_BSD_PROCESS_ACCT is not set
CONFIG_TASKSTATS=y
# CONFIG_TASK_DELAY_ACCT is not set
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=20
# CONFIG_CGROUPS is not set
CONFIG_GROUP_SCHED=y
# CONFIG_FAIR_GROUP_SCHED is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_USER_SCHED=y
# CONFIG_CGROUP_SCHED is not set
CONFIG_SYSFS_DEPRECATED=y
CONFIG_RELAY=y
# CONFIG_NAMESPACES is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_EMBEDDED=y
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
# CONFIG_KALLSYMS is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_COMPAT_BRK=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_ANON_INODES=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_SLUB_DEBUG=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
CONFIG_MARKERS=y
CONFIG_OPROFILE=y
CONFIG_HAVE_OPROFILE=y
CONFIG_HAVE_KPROBES=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
# CONFIG_TINY_SHMEM is not set
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
# CONFIG_MODULE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_KMOD is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
# CONFIG_BLK_DEV_IO_TRACE is not set
# CONFIG_BLK_DEV_BSG is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=m
CONFIG_DEFAULT_AS=y
# CONFIG_DEFAULT_DEADLINE is not set
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="anticipatory"
CONFIG_CLASSIC_RCU=y
# CONFIG_PREEMPT_RCU is not set

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_SMP=y
CONFIG_X86_PC=y
# CONFIG_X86_ELAN is not set
# CONFIG_X86_VOYAGER is not set
# CONFIG_X86_NUMAQ is not set
# CONFIG_X86_SUMMIT is not set
# CONFIG_X86_BIGSMP is not set
# CONFIG_X86_VISWS is not set
# CONFIG_X86_GENERICARCH is not set
# CONFIG_X86_ES7000 is not set
# CONFIG_X86_RDC321X is not set
# CONFIG_X86_VSMP is not set
# CONFIG_PARAVIRT_GUEST is not set
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP2 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MPSC is not set
CONFIG_MCORE2=y
# CONFIG_GENERIC_CPU is not set
CONFIG_X86_L1_CACHE_BYTES=64
CONFIG_X86_INTERNODE_CACHE_BYTES=64
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_GOOD_APIC=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_P6_NOP=y
CONFIG_X86_TSC=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_HPET_TIMER=y
# CONFIG_GART_IOMMU is not set
# CONFIG_CALGARY_IOMMU is not set
# CONFIG_IOMMU_HELPER is not set
CONFIG_NR_CPUS=8
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
# CONFIG_RCU_TRACE is not set
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_I8K=y
CONFIG_MICROCODE=m
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_NUMA=y
CONFIG_K8_NUMA=y
# CONFIG_X86_64_ACPI_NUMA is not set
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_SELECT_MEMORY_MODEL=y
# CONFIG_FLATMEM_MANUAL is not set
# CONFIG_DISCONTIGMEM_MANUAL is not set
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
# CONFIG_SPARSEMEM_VMEMMAP is not set

#
# Memory hotplug is currently incompatible with Software Suspend
#
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_MIGRATION=y
CONFIG_RESOURCES_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
# CONFIG_MTRR is not set
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
CONFIG_CRASH_DUMP=y
CONFIG_PHYSICAL_START=0x200000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_COMPAT_VDSO is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID=y

#
# Power management options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_PM=y
CONFIG_PM_LEGACY=y
CONFIG_PM_DEBUG=y
CONFIG_PM_VERBOSE=y
CONFIG_CAN_PM_TRACE=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_PM_SLEEP_SMP=y
CONFIG_PM_SLEEP=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_SYSFS_POWER=y
CONFIG_ACPI_PROC_EVENT=y
# CONFIG_ACPI_AC is not set
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_BAY=y
# CONFIG_ACPI_PROCESSOR is not set
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_WMI is not set
CONFIG_ACPI_ASUS=m
CONFIG_ACPI_TOSHIBA=y
# CONFIG_ACPI_CUSTOM_DSDT_INITRD is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_EC=y
CONFIG_ACPI_POWER=y
CONFIG_ACPI_SYSTEM=y
# CONFIG_X86_PM_TIMER is not set
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_SBS is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
# CONFIG_DMAR is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
CONFIG_PCI_LEGACY=y
CONFIG_HT_IRQ=y
CONFIG_ISA_DMA_API=y
CONFIG_K8_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA_DEBUG is not set
CONFIG_PCMCIA=y
# CONFIG_PCMCIA_LOAD_CIS is not set
CONFIG_PCMCIA_IOCTL=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_PD6729 is not set
CONFIG_I82092=y
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_FAKE is not set
CONFIG_HOTPLUG_PCI_ACPI=y
# CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_BINFMT_MISC=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y

#
# Networking
#
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_MMAP is not set
CONFIG_UNIX=y
CONFIG_XFRM=y
CONFIG_XFRM_USER=y
# CONFIG_XFRM_SUB_POLICY is not set
CONFIG_XFRM_MIGRATE=y
CONFIG_XFRM_STATISTICS=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_FIB_HASH=y
# CONFIG_IP_PNP is not set
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE=y
# CONFIG_ARPD is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_INET_AH is not set
CONFIG_INET_ESP=m
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=m
CONFIG_INET_XFRM_MODE_TRANSPORT=m
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=m
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=m
# CONFIG_TCP_CONG_WESTWOOD is not set
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=y
# CONFIG_TCP_CONG_VENO is not set
CONFIG_TCP_CONG_YEAH=y
# CONFIG_TCP_CONG_ILLINOIS is not set
# CONFIG_DEFAULT_BIC is not set
# CONFIG_DEFAULT_CUBIC is not set
# CONFIG_DEFAULT_HTCP is not set
CONFIG_DEFAULT_VEGAS=y
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="vegas"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IP_VS=y
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_ESP=y
# CONFIG_IP_VS_PROTO_AH is not set

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=y
CONFIG_IP_VS_WRR=m
# CONFIG_IP_VS_LC is not set
# CONFIG_IP_VS_WLC is not set
# CONFIG_IP_VS_LBLC is not set
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
# CONFIG_IP_VS_SED is not set
CONFIG_IP_VS_NQ=m

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=y
CONFIG_IPV6=m
# CONFIG_IPV6_PRIVACY is not set
# CONFIG_IPV6_ROUTER_PREF is not set
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
# CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=m
CONFIG_IPV6_SIT=m
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_NETLABEL is not set
CONFIG_NETWORK_SECMARK=y
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
# CONFIG_NETFILTER_ADVANCED is not set

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_LOG=y
# CONFIG_NF_CONNTRACK is not set
CONFIG_NETFILTER_XTABLES=m
# CONFIG_NETFILTER_XT_TARGET_MARK is not set
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
# CONFIG_NETFILTER_XT_TARGET_TCPMSS is not set
CONFIG_NETFILTER_XT_MATCH_MARK=m
# CONFIG_NETFILTER_XT_MATCH_POLICY is not set

#
# IP: Netfilter Configuration
#
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_LOG=m
# CONFIG_IP_NF_TARGET_ULOG is not set
CONFIG_IP_NF_MANGLE=m

#
# IPv6: Netfilter Configuration
#
# CONFIG_IP6_NF_IPTABLES is not set
CONFIG_IP_DCCP=m
CONFIG_INET_DCCP_DIAG=m
CONFIG_IP_DCCP_ACKVEC=y

#
# DCCP CCIDs Configuration (EXPERIMENTAL)
#
CONFIG_IP_DCCP_CCID2=m
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
# CONFIG_IP_DCCP_CCID3 is not set
# CONFIG_IP_DCCP_TFRC_LIB is not set
# CONFIG_IP_SCTP is not set
CONFIG_TIPC=y
CONFIG_TIPC_ADVANCED=y
CONFIG_TIPC_ZONES=3
CONFIG_TIPC_CLUSTERS=1
CONFIG_TIPC_NODES=255
CONFIG_TIPC_SLAVE_NODES=0
CONFIG_TIPC_PORTS=8191
CONFIG_TIPC_LOG=0
# CONFIG_TIPC_DEBUG is not set
CONFIG_ATM=m
CONFIG_ATM_CLIP=m
CONFIG_ATM_CLIP_NO_ICMP=y
# CONFIG_ATM_LANE is not set
CONFIG_ATM_BR2684=m
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_BRIDGE=y
CONFIG_VLAN_8021Q=m
# CONFIG_DECNET is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
CONFIG_IPX=y
# CONFIG_IPX_INTERN is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=m
CONFIG_IPDDP=m
# CONFIG_IPDDP_ENCAP is not set
# CONFIG_IPDDP_DECAP is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
CONFIG_WAN_ROUTER=y
# CONFIG_NET_SCHED is not set
CONFIG_NET_SCH_FIFO=y

#
# Network testing
#
CONFIG_NET_PKTGEN=m
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
# CONFIG_AX25 is not set
CONFIG_CAN=m
CONFIG_CAN_RAW=m
# CONFIG_CAN_BCM is not set

#
# CAN Device Drivers
#
# CONFIG_CAN_VCAN is not set
CONFIG_CAN_DEBUG_DEVICES=y
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=m
# CONFIG_IRNET is not set
CONFIG_IRCOMM=m
# CONFIG_IRDA_ULTRA is not set

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
# CONFIG_IRDA_FAST_RR is not set
CONFIG_IRDA_DEBUG=y

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
# CONFIG_IRTTY_SIR is not set

#
# Dongle support
#
CONFIG_KINGSUN_DONGLE=m
CONFIG_KSDAZZLE_DONGLE=m
CONFIG_KS959_DONGLE=m

#
# FIR device drivers
#
# CONFIG_USB_IRDA is not set
CONFIG_SIGMATEL_FIR=m
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=m
# CONFIG_SMC_IRCC_FIR is not set
# CONFIG_ALI_FIR is not set
CONFIG_VLSI_FIR=m
# CONFIG_VIA_FIR is not set
CONFIG_MCS_FIR=m
CONFIG_BT=y
# CONFIG_BT_L2CAP is not set
CONFIG_BT_SCO=m

#
# Bluetooth device drivers
#
CONFIG_BT_HCIUSB=m
CONFIG_BT_HCIUSB_SCO=y
CONFIG_BT_HCIBTSDIO=y
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_H4=y
# CONFIG_BT_HCIUART_BCSP is not set
# CONFIG_BT_HCIUART_LL is not set
CONFIG_BT_HCIBCM203X=m
CONFIG_BT_HCIBPA10X=y
CONFIG_BT_HCIBFUSB=m
# CONFIG_BT_HCIDTL1 is not set
CONFIG_BT_HCIBT3C=y
CONFIG_BT_HCIBLUECARD=m
CONFIG_BT_HCIBTUART=m
# CONFIG_BT_HCIVHCI is not set
CONFIG_AF_RXRPC=m
CONFIG_AF_RXRPC_DEBUG=y
CONFIG_RXKAD=m

#
# Wireless
#
CONFIG_CFG80211=y
# CONFIG_NL80211 is not set
CONFIG_WIRELESS_EXT=y
CONFIG_MAC80211=y

#
# Rate control algorithm selection
#
# CONFIG_MAC80211_RC_DEFAULT_PID is not set
CONFIG_MAC80211_RC_DEFAULT_SIMPLE=y
# CONFIG_MAC80211_RC_DEFAULT_NONE is not set

#
# Selecting 'y' for an algorithm will
#

#
# build the algorithm into mac80211.
#
CONFIG_MAC80211_RC_DEFAULT="simple"
# CONFIG_MAC80211_RC_PID is not set
CONFIG_MAC80211_RC_SIMPLE=y
CONFIG_MAC80211_DEBUGFS=y
# CONFIG_MAC80211_DEBUG_PACKET_ALIGNMENT is not set
CONFIG_MAC80211_DEBUG=y
# CONFIG_MAC80211_HT_DEBUG is not set
# CONFIG_MAC80211_VERBOSE_DEBUG is not set
CONFIG_MAC80211_LOWTX_FRAME_DUMP=y
CONFIG_TKIP_DEBUG=y
# CONFIG_MAC80211_DEBUG_COUNTERS is not set
# CONFIG_MAC80211_IBSS_DEBUG is not set
# CONFIG_MAC80211_VERBOSE_PS_DEBUG is not set
CONFIG_IEEE80211=y
# CONFIG_IEEE80211_DEBUG is not set
CONFIG_IEEE80211_CRYPT_WEP=y
# CONFIG_IEEE80211_CRYPT_CCMP is not set
CONFIG_IEEE80211_CRYPT_TKIP=y
# CONFIG_IEEE80211_SOFTMAC is not set
CONFIG_RFKILL=y
CONFIG_RFKILL_INPUT=y
CONFIG_NET_9P=y
CONFIG_NET_9P_FD=m
# CONFIG_NET_9P_DEBUG is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_SYS_HYPERVISOR is not set
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
# CONFIG_MTD is not set
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_PC_FIFO=y
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=m
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=m
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=y
# CONFIG_PARIDE is not set
CONFIG_BLK_CPQ_DA=y
CONFIG_BLK_CPQ_CISS_DA=m
# CONFIG_CISS_SCSI_TAPE is not set
CONFIG_BLK_DEV_DAC960=m
CONFIG_BLK_DEV_UMEM=y
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set
CONFIG_BLK_DEV_NBD=y
# CONFIG_BLK_DEV_SX8 is not set
CONFIG_BLK_DEV_UB=m
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
CONFIG_ATA_OVER_ETH=m
CONFIG_MISC_DEVICES=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_EEPROM_93CX6=y
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
# CONFIG_ACER_WMI is not set
# CONFIG_ASUS_LAPTOP is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_MSI_LAPTOP is not set
CONFIG_SONY_LAPTOP=y
CONFIG_SONYPI_COMPAT=y
CONFIG_THINKPAD_ACPI=y
CONFIG_THINKPAD_ACPI_DEBUG=y
CONFIG_THINKPAD_ACPI_BAY=y
# CONFIG_THINKPAD_ACPI_HOTKEY_POLL is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=m
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
CONFIG_SCSI_MULTI_LUN=y
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SAS_LIBSAS_DEBUG=y
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
CONFIG_SCSI_3W_9XXX=m
CONFIG_SCSI_ACARD=y
# CONFIG_SCSI_AACRAID is not set
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC7XXX_OLD=m
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=5000
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
CONFIG_SCSI_AIC94XX=m
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_ADVANSYS=m
CONFIG_SCSI_ARCMSR=m
CONFIG_SCSI_ARCMSR_AER=y
# CONFIG_MEGARAID_NEWGEN is not set
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_HPTIOP=y
CONFIG_SCSI_BUSLOGIC=m
CONFIG_SCSI_OMIT_FLASHPOINT=y
CONFIG_SCSI_DMX3191D=y
CONFIG_SCSI_EATA=m
# CONFIG_SCSI_EATA_TAGGED_QUEUE is not set
# CONFIG_SCSI_EATA_LINKED_COMMANDS is not set
CONFIG_SCSI_EATA_MAX_TAGS=16
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
CONFIG_SCSI_IPS=m
CONFIG_SCSI_INITIO=m
CONFIG_SCSI_INIA100=y
# CONFIG_SCSI_PPA is not set
# CONFIG_SCSI_IMM is not set
CONFIG_SCSI_STEX=m
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
# CONFIG_SCSI_IPR is not set
CONFIG_SCSI_QLOGIC_1280=y
# CONFIG_SCSI_QLA_FC is not set
CONFIG_SCSI_QLA_ISCSI=m
CONFIG_SCSI_LPFC=m
CONFIG_SCSI_DC395x=y
CONFIG_SCSI_DC390T=m
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_SRP is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
CONFIG_PCMCIA_FDOMAIN=m
# CONFIG_PCMCIA_QLOGIC is not set
# CONFIG_PCMCIA_SYM53C500 is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_ACPI=y
CONFIG_SATA_AHCI=y
CONFIG_SATA_SVW=y
CONFIG_ATA_PIIX=y
CONFIG_SATA_MV=y
CONFIG_SATA_NV=y
CONFIG_PDC_ADMA=m
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
CONFIG_SATA_SX4=m
CONFIG_SATA_SIL=m
CONFIG_SATA_SIL24=m
CONFIG_SATA_SIS=m
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
CONFIG_SATA_VITESSE=m
CONFIG_SATA_INIC162X=m
CONFIG_PATA_ACPI=y
CONFIG_PATA_ALI=m
CONFIG_PATA_AMD=y
# CONFIG_PATA_ARTOP is not set
CONFIG_PATA_ATIIXP=y
CONFIG_PATA_CMD640_PCI=y
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
CONFIG_PATA_CS5530=y
CONFIG_PATA_CYPRESS=m
# CONFIG_PATA_EFAR is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
CONFIG_PATA_HPT3X2N=m
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
CONFIG_PATA_IT8213=y
CONFIG_PATA_JMICRON=y
CONFIG_PATA_TRIFLEX=y
CONFIG_PATA_MARVELL=y
CONFIG_PATA_MPIIX=m
CONFIG_PATA_OLDPIIX=y
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87410 is not set
CONFIG_PATA_NS87415=y
CONFIG_PATA_OPTI=y
CONFIG_PATA_OPTIDMA=m
# CONFIG_PATA_PCMCIA is not set
CONFIG_PATA_PDC_OLD=y
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RZ1000=y
CONFIG_PATA_SC1200=y
CONFIG_PATA_SERVERWORKS=y
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
CONFIG_PATA_SIS=m
# CONFIG_PATA_VIA is not set
CONFIG_PATA_WINBOND=m
# CONFIG_PATA_PLATFORM is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=m
CONFIG_MD_LINEAR=m
# CONFIG_MD_RAID0 is not set
# CONFIG_MD_RAID1 is not set
# CONFIG_MD_RAID10 is not set
CONFIG_MD_RAID456=m
# CONFIG_MD_RAID5_RESHAPE is not set
CONFIG_MD_MULTIPATH=m
# CONFIG_MD_FAULTY is not set
# CONFIG_BLK_DEV_DM is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=y
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=m
# CONFIG_FIREWIRE_SBP2 is not set
CONFIG_IEEE1394=m

#
# Subsystem Options
#
CONFIG_IEEE1394_VERBOSEDEBUG=y

#
# Controllers
#
CONFIG_IEEE1394_PCILYNX=m
# CONFIG_IEEE1394_OHCI1394 is not set

#
# Protocols
#
# CONFIG_IEEE1394_SBP2 is not set
# CONFIG_IEEE1394_ETH1394_ROM_ENTRY is not set
# CONFIG_IEEE1394_ETH1394 is not set
# CONFIG_IEEE1394_RAWIO is not set
# CONFIG_I2O is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_MAC_EMUMOUSEBTN is not set
CONFIG_NETDEVICES=y
CONFIG_NETDEVICES_MULTIQUEUE=y
# CONFIG_DUMMY is not set
# CONFIG_BONDING is not set
CONFIG_MACVLAN=y
# CONFIG_EQUALIZER is not set
CONFIG_TUN=m
CONFIG_VETH=y
CONFIG_NET_SB1000=y
# CONFIG_ARCNET is not set
# CONFIG_PHYLIB is not set
CONFIG_NET_ETHERNET=y
CONFIG_MII=y
CONFIG_HAPPYMEAL=y
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
CONFIG_NET_VENDOR_3COM=y
CONFIG_VORTEX=y
CONFIG_TYPHOON=m
CONFIG_ENC28J60=m
CONFIG_ENC28J60_WRITEVERIFY=y
# CONFIG_NET_TULIP is not set
# CONFIG_HP100 is not set
# CONFIG_IBM_NEW_EMAC_ZMII is not set
# CONFIG_IBM_NEW_EMAC_RGMII is not set
# CONFIG_IBM_NEW_EMAC_TAH is not set
# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
CONFIG_NET_PCI=y
# CONFIG_PCNET32 is not set
# CONFIG_AMD8111_ETH is not set
CONFIG_ADAPTEC_STARFIRE=m
# CONFIG_ADAPTEC_STARFIRE_NAPI is not set
CONFIG_B44=m
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_FORCEDETH=y
CONFIG_FORCEDETH_NAPI=y
CONFIG_EEPRO100=y
CONFIG_E100=y
CONFIG_FEALNX=m
# CONFIG_NATSEMI is not set
CONFIG_NE2K_PCI=m
# CONFIG_8139CP is not set
CONFIG_8139TOO=y
# CONFIG_8139TOO_PIO is not set
CONFIG_8139TOO_TUNE_TWISTER=y
# CONFIG_8139TOO_8129 is not set
CONFIG_8139_OLD_RX_RESET=y
CONFIG_R6040=m
CONFIG_SIS900=y
# CONFIG_EPIC100 is not set
CONFIG_SUNDANCE=m
# CONFIG_SUNDANCE_MMIO is not set
# CONFIG_VIA_RHINE is not set
CONFIG_SC92031=y
# CONFIG_NET_POCKET is not set
CONFIG_NETDEV_1000=y
CONFIG_ACENIC=m
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_DL2K=m
CONFIG_E1000=y
# CONFIG_E1000_NAPI is not set
# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
# CONFIG_E1000E is not set
# CONFIG_E1000E_ENABLED is not set
CONFIG_IP1000=y
CONFIG_IGB=m
CONFIG_NS83820=m
# CONFIG_HAMACHI is not set
CONFIG_YELLOWFIN=y
CONFIG_R8169=y
# CONFIG_R8169_NAPI is not set
# CONFIG_R8169_VLAN is not set
# CONFIG_SIS190 is not set
CONFIG_SKGE=m
# CONFIG_SKGE_DEBUG is not set
# CONFIG_SKY2 is not set
CONFIG_SK98LIN=m
CONFIG_VIA_VELOCITY=y
CONFIG_TIGON3=y
CONFIG_BNX2=y
# CONFIG_QLA3XXX is not set
# CONFIG_ATL1 is not set
# CONFIG_NETDEV_10000 is not set
CONFIG_TR=y
# CONFIG_IBMOL is not set
CONFIG_3C359=m
CONFIG_TMS380TR=y
# CONFIG_TMSPCI is not set
CONFIG_ABYSS=y

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
CONFIG_WLAN_80211=y
CONFIG_PCMCIA_RAYCS=m
# CONFIG_IPW2100 is not set
CONFIG_IPW2200=y
# CONFIG_IPW2200_MONITOR is not set
CONFIG_IPW2200_QOS=y
CONFIG_IPW2200_DEBUG=y
CONFIG_LIBERTAS=y
CONFIG_LIBERTAS_USB=y
CONFIG_LIBERTAS_CS=y
CONFIG_LIBERTAS_SDIO=m
CONFIG_LIBERTAS_DEBUG=y
# CONFIG_AIRO is not set
CONFIG_HERMES=y
CONFIG_PLX_HERMES=m
# CONFIG_TMD_HERMES is not set
CONFIG_NORTEL_HERMES=y
CONFIG_PCI_HERMES=y
CONFIG_PCMCIA_HERMES=y
CONFIG_PCMCIA_SPECTRUM=y
CONFIG_ATMEL=m
CONFIG_PCI_ATMEL=m
# CONFIG_PCMCIA_ATMEL is not set
CONFIG_AIRO_CS=y
CONFIG_PCMCIA_WL3501=m
CONFIG_PRISM54=m
CONFIG_USB_ZD1201=y
# CONFIG_USB_NET_RNDIS_WLAN is not set
# CONFIG_RTL8180 is not set
CONFIG_RTL8187=m
# CONFIG_ADM8211 is not set
CONFIG_P54_COMMON=y
CONFIG_P54_USB=y
CONFIG_P54_PCI=m
CONFIG_ATH5K=y
CONFIG_IWL4965=y
# CONFIG_IWL4965_QOS is not set
CONFIG_IWL4965_SPECTRUM_MEASUREMENT=y
# CONFIG_IWL4965_SENSITIVITY is not set
CONFIG_IWL4965_DEBUG=y
CONFIG_IWL3945=y
CONFIG_IWL3945_QOS=y
# CONFIG_IWL3945_SPECTRUM_MEASUREMENT is not set
# CONFIG_IWL3945_DEBUG is not set
# CONFIG_HOSTAP is not set
CONFIG_B43=m
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_PCMCIA=y
CONFIG_B43_RFKILL=y
CONFIG_B43_DEBUG=y
CONFIG_B43LEGACY=m
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_RFKILL=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_DMA=y
# CONFIG_B43LEGACY_DMA_AND_PIO_MODE is not set
CONFIG_B43LEGACY_DMA_MODE=y
# CONFIG_B43LEGACY_PIO_MODE is not set
# CONFIG_ZD1211RW is not set
CONFIG_RT2X00=y
CONFIG_RT2X00_LIB=y
CONFIG_RT2X00_LIB_PCI=y
CONFIG_RT2X00_LIB_USB=m
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_RFKILL=y
CONFIG_RT2400PCI=y
# CONFIG_RT2400PCI_RFKILL is not set
# CONFIG_RT2500PCI is not set
CONFIG_RT61PCI=m
CONFIG_RT61PCI_RFKILL=y
CONFIG_RT2500USB=m
CONFIG_RT73USB=m
# CONFIG_RT2X00_LIB_DEBUGFS is not set
# CONFIG_RT2X00_DEBUG is not set

#
# USB Network Adapters
#
CONFIG_USB_CATC=m
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
CONFIG_USB_RTL8150=m
# CONFIG_USB_USBNET is not set
CONFIG_NET_PCMCIA=y
# CONFIG_PCMCIA_3C589 is not set
CONFIG_PCMCIA_3C574=m
CONFIG_PCMCIA_FMVJ18X=m
CONFIG_PCMCIA_PCNET=y
# CONFIG_PCMCIA_NMCLAN is not set
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_PCMCIA_XIRC2PS is not set
CONFIG_PCMCIA_AXNET=m
CONFIG_WAN=y
CONFIG_LANMEDIA=m
CONFIG_HDLC=m
# CONFIG_HDLC_RAW is not set
# CONFIG_HDLC_RAW_ETH is not set
# CONFIG_HDLC_CISCO is not set
# CONFIG_HDLC_FR is not set
# CONFIG_HDLC_PPP is not set

#
# X.25/LAPB support is disabled
#
# CONFIG_PCI200SYN is not set
CONFIG_WANXL=m
# CONFIG_PC300 is not set
# CONFIG_PC300TOO is not set
# CONFIG_FARSYNC is not set
CONFIG_DSCC4=m
# CONFIG_DSCC4_PCISYNC is not set
# CONFIG_DSCC4_PCI_RST is not set
CONFIG_DLCI=y
CONFIG_DLCI_MAX=8
# CONFIG_WAN_ROUTER_DRIVERS is not set
# CONFIG_SBNI is not set
# CONFIG_ATM_DRIVERS is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
CONFIG_PLIP=m
CONFIG_PPP=y
# CONFIG_PPP_MULTILINK is not set
CONFIG_PPP_FILTER=y
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=y
# CONFIG_PPP_DEFLATE is not set
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_MPPE=y
# CONFIG_PPPOE is not set
CONFIG_PPPOATM=m
CONFIG_PPPOL2TP=m
CONFIG_SLIP=y
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLHC=y
CONFIG_SLIP_SMART=y
CONFIG_SLIP_MODE_SLIP6=y
# CONFIG_NET_FC is not set
CONFIG_NETCONSOLE=y
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=m
CONFIG_INPUT_POLLDEV=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_SUNKBD=m
CONFIG_KEYBOARD_LKKBD=y
CONFIG_KEYBOARD_XTKBD=m
# CONFIG_KEYBOARD_NEWTON is not set
CONFIG_KEYBOARD_STOWAWAY=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_ADS7846=m
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
CONFIG_TOUCHSCREEN_ELO=m
CONFIG_TOUCHSCREEN_MTOUCH=y
# CONFIG_TOUCHSCREEN_MK712 is not set
CONFIG_TOUCHSCREEN_PENMOUNT=m
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
CONFIG_TOUCHSCREEN_TOUCHWIN=y
CONFIG_TOUCHSCREEN_UCB1400=y
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_PCSPKR is not set
# CONFIG_INPUT_APANEL is not set
CONFIG_INPUT_ATLAS_BTNS=m
CONFIG_INPUT_ATI_REMOTE=y
CONFIG_INPUT_ATI_REMOTE2=m
CONFIG_INPUT_KEYSPAN_REMOTE=m
CONFIG_INPUT_POWERMATE=y
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_UINPUT is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
CONFIG_SERIO_PCIPS2=m
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_VT_HW_CONSOLE_BINDING is not set
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_COMPUTONE=m
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=m
# CONFIG_CYZ_INTR is not set
CONFIG_DIGIEPCA=m
CONFIG_MOXA_INTELLIO=m
CONFIG_MOXA_SMARTIO=m
CONFIG_ISI=m
CONFIG_SYNCLINK=m
CONFIG_SYNCLINKMP=m
CONFIG_SYNCLINK_GT=m
CONFIG_N_HDLC=m
# CONFIG_RISCOM8 is not set
CONFIG_SPECIALIX=m
# CONFIG_SPECIALIX_RTSCTS is not set
# CONFIG_SX is not set
CONFIG_RIO=m
CONFIG_RIO_OLDPCI=y
CONFIG_STALDRV=y
CONFIG_NOZOMI=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
# CONFIG_SERIAL_8250_PCI is not set
# CONFIG_SERIAL_8250_PNP is not set
CONFIG_SERIAL_8250_CS=m
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
# CONFIG_SERIAL_8250_SHARE_IRQ is not set
CONFIG_SERIAL_8250_DETECT_IRQ=y
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=m
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_PRINTER=m
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=m
# CONFIG_HW_RANDOM_INTEL is not set
# CONFIG_HW_RANDOM_AMD is not set
CONFIG_NVRAM=y
# CONFIG_RTC is not set
# CONFIG_GEN_RTC is not set
CONFIG_R3964=m
# CONFIG_APPLICOM is not set

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=m
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=m
CONFIG_IPWIRELESS=y
CONFIG_MWAVE=m
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
CONFIG_HPET=y
# CONFIG_HPET_RTC_IRQ is not set
# CONFIG_HPET_MMAP is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_TCG_TPM=m
CONFIG_TCG_TIS=m
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
# CONFIG_TCG_INFINEON is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=m
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_CHARDEV is not set

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=m
# CONFIG_I2C_ALGOPCF is not set
# CONFIG_I2C_ALGOPCA is not set

#
# I2C Hardware Bus support
#
CONFIG_I2C_ALI1535=m
# CONFIG_I2C_ALI1563 is not set
CONFIG_I2C_ALI15X3=m
CONFIG_I2C_AMD756=m
CONFIG_I2C_AMD756_S4882=m
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=m
# CONFIG_I2C_I810 is not set
CONFIG_I2C_PIIX4=m
# CONFIG_I2C_NFORCE2 is not set
CONFIG_I2C_OCORES=m
CONFIG_I2C_PARPORT=m
# CONFIG_I2C_PARPORT_LIGHT is not set
CONFIG_I2C_PROSAVAGE=m
# CONFIG_I2C_SAVAGE4 is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_SIS5595 is not set
CONFIG_I2C_SIS630=m
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_STUB=m
# CONFIG_I2C_TINY_USB is not set
CONFIG_I2C_VIA=m
# CONFIG_I2C_VIAPRO is not set
CONFIG_I2C_VOODOO3=m

#
# Miscellaneous I2C Chip support
#
CONFIG_DS1682=m
# CONFIG_SENSORS_EEPROM is not set
# CONFIG_SENSORS_PCF8574 is not set
# CONFIG_PCF8575 is not set
CONFIG_SENSORS_PCF8591=m
CONFIG_TPS65010=m
CONFIG_SENSORS_MAX6875=m
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set

#
# SPI support
#
CONFIG_SPI=y
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_BITBANG=y
# CONFIG_SPI_BUTTERFLY is not set
CONFIG_SPI_LM70_LLP=m

#
# SPI Protocol Masters
#
CONFIG_SPI_AT25=y
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=y
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=m
# CONFIG_W1_MASTER_DS2482 is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=m
CONFIG_W1_SLAVE_SMEM=m
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
CONFIG_BATTERY_DS2760=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_SENSORS_ABITUGURU is not set
CONFIG_SENSORS_ABITUGURU3=m
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
# CONFIG_SENSORS_ADM1031 is not set
CONFIG_SENSORS_ADM9240=m
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_K8TEMP=m
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=m
CONFIG_SENSORS_F71882FG=m
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHER is not set
CONFIG_SENSORS_FSCPOS=m
CONFIG_SENSORS_FSCHMD=m
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IT87=y
CONFIG_SENSORS_LM63=m
CONFIG_SENSORS_LM70=y
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
CONFIG_SENSORS_LM78=m
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_MAX6650=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_SIS5595=y
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_SMSC47M1=m
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=m
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=m
# CONFIG_SENSORS_W83791D is not set
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=m
# CONFIG_SENSORS_HDAPS is not set
CONFIG_SENSORS_APPLESMC=y
# CONFIG_HWMON_DEBUG_CHIP is not set
# CONFIG_THERMAL is not set
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_NOWAYOUT=y

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=m
CONFIG_ALIM1535_WDT=y
CONFIG_ALIM7101_WDT=y
CONFIG_SC520_WDT=m
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=m
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=m
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
CONFIG_HP_WATCHDOG=m
# CONFIG_SC1200_WDT is not set
CONFIG_PC87413_WDT=m
CONFIG_60XX_WDT=m
CONFIG_SBC8360_WDT=m
CONFIG_CPU5_WDT=m
CONFIG_SMSC37B787_WDT=y
CONFIG_W83627HF_WDT=y
CONFIG_W83697HF_WDT=m
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=y

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=m
CONFIG_WDTPCI=y
# CONFIG_WDT_501_PCI is not set

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
# CONFIG_SSB_SILENT is not set
CONFIG_SSB_DEBUG=y
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y

#
# Multifunction device drivers
#
CONFIG_MFD_SM501=m

#
# Multimedia devices
#
# CONFIG_VIDEO_DEV is not set
CONFIG_DVB_CORE=y
CONFIG_DVB_CORE_ATTACH=y
# CONFIG_DVB_CAPTURE_DRIVERS is not set
CONFIG_DAB=y
CONFIG_USB_DABUSB=y

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_DRM=m
CONFIG_DRM_TDFX=m
CONFIG_DRM_R128=m
CONFIG_DRM_RADEON=m
CONFIG_DRM_MGA=m
# CONFIG_DRM_VIA is not set
# CONFIG_DRM_SAVAGE is not set
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=m
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_DDC=m
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=m
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=m
# CONFIG_FB_ASILIANT is not set
CONFIG_FB_IMSTT=y
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_EFI is not set
CONFIG_FB_HECUBA=m
# CONFIG_FB_HGA is not set
CONFIG_FB_S1D13XXX=m
# CONFIG_FB_NVIDIA is not set
CONFIG_FB_RIVA=y
# CONFIG_FB_RIVA_I2C is not set
CONFIG_FB_RIVA_DEBUG=y
CONFIG_FB_RIVA_BACKLIGHT=y
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_INTEL is not set
CONFIG_FB_MATROX=m
# CONFIG_FB_MATROX_MILLENIUM is not set
CONFIG_FB_MATROX_MYSTIQUE=y
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=m
CONFIG_FB_MATROX_MAVEN=m
# CONFIG_FB_MATROX_MULTIHEAD is not set
# CONFIG_FB_RADEON is not set
CONFIG_FB_ATY128=m
CONFIG_FB_ATY128_BACKLIGHT=y
# CONFIG_FB_ATY is not set
CONFIG_FB_S3=y
CONFIG_FB_SAVAGE=m
CONFIG_FB_SAVAGE_I2C=y
CONFIG_FB_SAVAGE_ACCEL=y
CONFIG_FB_SIS=m
# CONFIG_FB_SIS_300 is not set
# CONFIG_FB_SIS_315 is not set
# CONFIG_FB_NEOMAGIC is not set
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
CONFIG_FB_VOODOO1=m
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
CONFIG_FB_TRIDENT_ACCEL=y
CONFIG_FB_ARK=m
CONFIG_FB_PM3=m
# CONFIG_FB_GEODE is not set
# CONFIG_FB_SM501 is not set
# CONFIG_FB_VIRTUAL is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_LTV350QV=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_CORGI=y
CONFIG_BACKLIGHT_PROGEAR=y

#
# Display device support
#
CONFIG_DISPLAY_SUPPORT=y

#
# Display hardware drivers
#

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
CONFIG_VIDEO_SELECT=y
CONFIG_DUMMY_CONSOLE=y
# CONFIG_FRAMEBUFFER_CONSOLE is not set
# CONFIG_LOGO is not set

#
# Sound
#
CONFIG_SOUND=y

#
# Advanced Linux Sound Architecture
#
# CONFIG_SND is not set

#
# Open Sound System
#
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=y
# CONFIG_HID_SUPPORT is not set
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=y
CONFIG_USB_DEBUG=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
CONFIG_USB_DEVICE_CLASS=y
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_SUSPEND=y
# CONFIG_USB_PERSIST is not set
# CONFIG_USB_OTG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_EHCI_HCD=y
# CONFIG_USB_EHCI_ROOT_HUB_TT is not set
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
# CONFIG_USB_ISP116X_HCD is not set
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_HCD_SSB is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=m
CONFIG_USB_SL811_HCD=y
CONFIG_USB_SL811_CS=y
# CONFIG_USB_R8A66597_HCD is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y

#
# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
#

#
# may also be needed; see USB_STORAGE Help for more information
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_DATAFAB=y
# CONFIG_USB_STORAGE_FREECOM is not set
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_DPCM is not set
# CONFIG_USB_STORAGE_USBAT is not set
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
# CONFIG_USB_STORAGE_KARMA is not set
CONFIG_USB_LIBUSUAL=y

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
CONFIG_USB_MICROTEK=y
# CONFIG_USB_MON is not set

#
# USB port drivers
#
CONFIG_USB_USS720=y
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
# CONFIG_USB_EMI26 is not set
CONFIG_USB_ADUTUX=y
CONFIG_USB_AUERSWALD=m
CONFIG_USB_RIO500=m
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=m
# CONFIG_USB_BERRY_CHARGE is not set
# CONFIG_USB_LED is not set
CONFIG_USB_CYPRESS_CY7C63=y
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_PHIDGET is not set
# CONFIG_USB_IDMOUSE is not set
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
# CONFIG_USB_SISUSBVGA_CON is not set
CONFIG_USB_LD=m
CONFIG_USB_TRANCEVIBRATOR=m
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=m
# CONFIG_USB_ATM is not set
# CONFIG_USB_GADGET is not set
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set

#
# MMC/SD Card Drivers
#
# CONFIG_MMC_BLOCK is not set
CONFIG_SDIO_UART=y

#
# MMC/SD Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
CONFIG_MMC_WBSD=m
CONFIG_MMC_TIFM_SD=m
# CONFIG_MMC_SPI is not set
# CONFIG_MEMSTICK is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_CLEVO_MAIL=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
CONFIG_INFINIBAND=y
CONFIG_INFINIBAND_USER_MAD=y
CONFIG_INFINIBAND_USER_ACCESS=m
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ADDR_TRANS=y
# CONFIG_INFINIBAND_MTHCA is not set
# CONFIG_INFINIBAND_IPATH is not set
CONFIG_INFINIBAND_AMSO1100=m
CONFIG_INFINIBAND_AMSO1100_DEBUG=y
# CONFIG_MLX4_INFINIBAND is not set
# CONFIG_INFINIBAND_NES is not set
CONFIG_INFINIBAND_IPOIB=m
CONFIG_INFINIBAND_IPOIB_CM=y
# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
# CONFIG_INFINIBAND_SRP is not set
CONFIG_INFINIBAND_ISER=y
CONFIG_EDAC=y

#
# Reporting subsystems
#
CONFIG_EDAC_DEBUG=y
# CONFIG_EDAC_MM_EDAC is not set
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y

#
# DMA Devices
#
CONFIG_INTEL_IOATDMA=m
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
# CONFIG_NET_DMA is not set
CONFIG_DCA=m
# CONFIG_AUXDISPLAY is not set

#
# Userspace I/O
#
# CONFIG_UIO is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y

#
# File systems
#
CONFIG_EXT2_FS=m
# CONFIG_EXT2_FS_XATTR is not set
CONFIG_EXT2_FS_XIP=y
CONFIG_FS_XIP=y
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
# CONFIG_EXT4DEV_FS is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_XFS_FS=m
# CONFIG_XFS_QUOTA is not set
CONFIG_XFS_SECURITY=y
# CONFIG_XFS_POSIX_ACL is not set
# CONFIG_XFS_RT is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_DNOTIFY is not set
# CONFIG_INOTIFY is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
CONFIG_QFMT_V1=y
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS_FS is not set
CONFIG_AUTOFS4_FS=m
CONFIG_FUSE_FS=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
# CONFIG_JOLIET is not set
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=m
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
# CONFIG_PROC_VMCORE is not set
# CONFIG_PROC_SYSCTL is not set
CONFIG_SYSFS=y
# CONFIG_TMPFS is not set
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y

#
# Miscellaneous filesystems
#
CONFIG_ADFS_FS=m
# CONFIG_ADFS_FS_RW is not set
CONFIG_AFFS_FS=m
CONFIG_ECRYPT_FS=y
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
CONFIG_BEFS_FS=m
CONFIG_BEFS_DEBUG=y
CONFIG_BFS_FS=m
CONFIG_EFS_FS=m
# CONFIG_CRAMFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
CONFIG_HPFS_FS=y
# CONFIG_QNX4FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_SYSV_FS=m
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
# CONFIG_NFS_V4 is not set
# CONFIG_NFS_DIRECTIO is not set
CONFIG_NFSD=m
# CONFIG_NFSD_V3 is not set
# CONFIG_NFSD_TCP is not set
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
CONFIG_SUNRPC_GSS=m
CONFIG_SUNRPC_XPRT_RDMA=m
CONFIG_SUNRPC_BIND34=y
CONFIG_RPCSEC_GSS_KRB5=m
CONFIG_RPCSEC_GSS_SPKM3=m
CONFIG_SMB_FS=m
CONFIG_SMB_NLS_DEFAULT=y
CONFIG_SMB_NLS_REMOTE="cp437"
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
# CONFIG_CIFS_XATTR is not set
# CONFIG_CIFS_DEBUG2 is not set
CONFIG_CIFS_EXPERIMENTAL=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_DFS_UPCALL=y
CONFIG_NCP_FS=y
CONFIG_NCPFS_PACKET_SIGNING=y
# CONFIG_NCPFS_IOCTL_LOCKING is not set
CONFIG_NCPFS_STRONG=y
# CONFIG_NCPFS_NFS_NS is not set
CONFIG_NCPFS_OS2_NS=y
# CONFIG_NCPFS_SMALLDOS is not set
# CONFIG_NCPFS_NLS is not set
# CONFIG_NCPFS_EXTRAS is not set
CONFIG_CODA_FS=y
CONFIG_CODA_FS_OLD_API=y
# CONFIG_AFS_FS is not set
CONFIG_9P_FS=m

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
CONFIG_ACORN_PARTITION_CUMANA=y
CONFIG_ACORN_PARTITION_EESOX=y
CONFIG_ACORN_PARTITION_ICS=y
CONFIG_ACORN_PARTITION_ADFS=y
CONFIG_ACORN_PARTITION_POWERTEC=y
# CONFIG_ACORN_PARTITION_RISCIX is not set
CONFIG_OSF_PARTITION=y
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
# CONFIG_SOLARIS_X86_PARTITION is not set
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
# CONFIG_SGI_PARTITION is not set
CONFIG_ULTRIX_PARTITION=y
# CONFIG_SUN_PARTITION is not set
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=y
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=m
# CONFIG_NLS_ISO8859_1 is not set
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=m
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=m
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
# CONFIG_PRINTK_TIME is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_KERNEL is not set
CONFIG_SLUB_DEBUG_ON=y
CONFIG_SLUB_STATS=y
# CONFIG_DEBUG_BUGVERBOSE is not set
# CONFIG_LATENCYTOP is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_SAMPLES=y
CONFIG_SAMPLE_MARKERS=m
# CONFIG_SAMPLE_KOBJECT is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_NONPROMISC_DEVMEM=y
CONFIG_EARLY_PRINTK=y
CONFIG_X86_MPPARSE=y
# CONFIG_MMIOTRACE_HOOKS is not set
CONFIG_SYSPROF=m
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
CONFIG_SECURITY=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
CONFIG_SECURITY_CAPABILITIES=y
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
# CONFIG_SECURITY_ROOTPLUG is not set
CONFIG_SECURITY_DEFAULT_MMAP_MIN_ADDR=0
# CONFIG_SECURITY_SELINUX is not set
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_CRYPTO=y
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_HASH=m
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_HMAC=m
# CONFIG_CRYPTO_XCBC is not set
CONFIG_CRYPTO_NULL=m
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=m
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_WP512=m
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_XTS is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_BLOWFISH is not set
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
# CONFIG_CRYPTO_SERPENT is not set
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_ANUBIS=m
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SALSA20=m
CONFIG_CRYPTO_SALSA20_X86_64=m
# CONFIG_CRYPTO_DEFLATE is not set
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_CRC32C=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_LZO=m
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_HIFN_795X=m
CONFIG_CRYPTO_DEV_HIFN_795X_RNG=y
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_CRC_CCITT=y
# CONFIG_CRC16 is not set
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC7=m
CONFIG_LIBCRC32C=y
CONFIG_ZLIB_INFLATE=y
CONFIG_LZO_COMPRESS=m
CONFIG_LZO_DECOMPRESS=m
CONFIG_PLIST=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y

--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="crash5.log"

Linux version 2.6.25-rc2-sched-devel (mingo@dione) (gcc version 4.2.3) #29 SMP Wed Feb 20 12:11:44 CET 2008
Command line: root=/dev/sda6 console=ttyS0,115200 earlyprintk=serial,ttyS0,115200 debug initcall_debug apic=verbose sysrq_always_enabled ignore_loglevel selinux=0 nmi_watchdog=2 idle=poll
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000003fff0000 (usable)
 BIOS-e820: 000000003fff0000 - 000000003fff3000 (ACPI NVS)
 BIOS-e820: 000000003fff3000 - 0000000040000000 (ACPI data)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
console [earlyser0] enabled
debug: ignoring loglevel setting.
using polling idle threads.
Entering add_active_range(0, 0, 159) 0 entries of 3200 used
Entering add_active_range(0, 256, 262128) 1 entries of 3200 used
end_pfn_map = 1048576
kernel direct mapping tables up to 100000000 @ 8000-d000
DMI 2.3 present.
ACPI: RSDP 000F76F0, 0014 (r0 Nvidia)
ACPI: RSDT 3FFF3040, 0034 (r1 Nvidia AWRDACPI 42302E31 AWRD        0)
ACPI: FACP 3FFF30C0, 0074 (r1 Nvidia AWRDACPI 42302E31 AWRD        0)
ACPI: DSDT 3FFF3180, 6264 (r1 NVIDIA AWRDACPI     1000 MSFT  100000E)
ACPI: FACS 3FFF0000, 0040
ACPI: SRAT 3FFF9500, 00A0 (r1 AMD    HAMMER          1 AMD         1)
ACPI: MCFG 3FFF9600, 003C (r1 Nvidia AWRDACPI 42302E31 AWRD        0)
ACPI: APIC 3FFF9440, 007C (r1 Nvidia AWRDACPI 42302E31 AWRD        0)
SRAT: PXM 0 -> APIC 0 -> Node 0
SRAT: PXM 0 -> APIC 1 -> Node 0
SRAT: Node 0 PXM 0 0-a0000
Entering add_active_range(0, 0, 159) 0 entries of 3200 used
SRAT: Node 0 PXM 0 0-40000000
Entering add_active_range(0, 0, 159) 1 entries of 3200 used
Entering add_active_range(0, 256, 262128) 1 entries of 3200 used
NUMA: Using 63 for the hash shift.
Bootmem setup node 0 0000000000000000-000000003fff0000
  NODE_DATA [000000000000b000 - 0000000000011fff]
  bootmap [0000000000012000 -  0000000000019fff] pages 8
early res: 0 [0-fff] BIOS data page
early res: 1 [6000-7fff] SMP_TRAMPOLINE
early res: 2 [200000-b7011f] TEXT DATA BSS
early res: 3 [9f800-a07ff] EBDA
early res: 4 [8000-afff] PGTABLE
Zone PFN ranges:
  DMA             0 ->     4096
  DMA32        4096 ->  1048576
  Normal    1048576 ->  1048576
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0:        0 ->      159
    0:      256 ->   262128
On node 0 totalpages: 262031
  DMA zone: 56 pages used for memmap
  DMA zone: 2425 pages reserved
  DMA zone: 1518 pages, LIFO batch:0
  DMA32 zone: 3527 pages used for memmap
  DMA32 zone: 254505 pages, LIFO batch:31
  Normal zone: 0 pages used for memmap
  Movable zone: 0 pages used for memmap
Nvidia board detected. Ignoring ACPI timer override.
If you got timer trouble try acpi_use_timer_override
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
Processor #0 (Bootup-CPU)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
Processor #1
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: BIOS IRQ0 pin2 override ignored.
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: INT_SRC_OVR (bus 0 bus_irq 14 global_irq 14 high edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 15 global_irq 15 high edge)
ACPI: IRQ9 used by override.
ACPI: IRQ14 used by override.
ACPI: IRQ15 used by override.
Setting APIC routing to flat
Using ACPI (MADT) for SMP configuration information
mapped APIC to ffffffffff5fb000 (        fee00000)
mapped IOAPIC to ffffffffff5fa000 (00000000fec00000)
PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
PM: Registered nosave memory: 00000000000a0000 - 00000000000f0000
PM: Registered nosave memory: 00000000000f0000 - 0000000000100000
Allocating PCI resources starting at 50000000 (gap: 40000000:a0000000)
SMP: Allowing 2 CPUs, 0 hotplug CPUs
PERCPU: Allocating 40344 bytes of per cpu data
Built 1 zonelists in Node order, mobility grouping on.  Total pages: 256023
Policy zone: DMA32
Kernel command line: root=/dev/sda6 console=ttyS0,115200 earlyprintk=serial,ttyS0,115200 debug initcall_debug apic=verbose sysrq_always_enabled ignore_loglevel selinux=0 nmi_watchdog=2 idle=poll
debug: sysrq always enabled.
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
TSC calibrated against PIT
Marking TSC unstable due to TSCs unsynchronized
time.c: Detected 2160.234 MHz processor.
spurious 8259A interrupt: IRQ7.
Console: colour VGA+ 80x25
console handover: boot [earlyser0] -> real [ttyS0]
Memory: 1023824k/1048512k available (5134k kernel code, 24300k reserved, 2543k data, 364k init)
CPA: page pool initialized 1 of 1 pages preallocated
SLUB: Genslabs=13, HWalign=64, Order=0-1, MinObjects=4, CPUs=2, Nodes=1
Calibrating delay using timer specific routine.. 4323.16 BogoMIPS (lpj=8646328)
Security Framework initialized
Capability LSM initialized
Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
Mount-cache hash table entries: 256
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 0/0 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
ACPI: Core revision 20070126
enabled ExtINT on CPU#0
ENABLING IO-APIC IRQs
init IO_APIC IRQs
IOAPIC[0]: Set routing entry (2-0 -> 0x30 -> IRQ 0 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-2 -> 0x32 -> IRQ 2 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0)
IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0)
IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0)
 IO-APIC (apicid-pin) 2-16, 2-17, 2-18, 2-19, 2-20, 2-21, 2-22, 2-23 not connected.
..TIMER: vector=0x30 apic1=0 pin1=0 apic2=-1 pin2=-1
Using local APIC timer interrupts.
APIC timer calibration result 13501451
Detected 13.501 MHz APIC timer.
Booting processor 1/2 APIC 0x1
Initializing CPU#1
masked ExtINT on CPU#1
Calibrating delay using timer specific routine.. 4320.47 BogoMIPS (lpj=8640954)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 512K (64 bytes/line)
CPU 1/1 -> Node 0
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
AMD Athlon(tm) 64 X2 Dual Core Processor 3800+ stepping 02
Brought up 2 CPUs
Testing NMI watchdog ... <1>BUG: unable to handle kernel NULL pointer dereference at 000000000000003c
IP: [<ffffffff809b1b2b>]
PGD 0 
Oops: 0000 [1] SMP 
CPU 0 
Modules linked in:
Pid: 1, comm: swapper Not tainted 2.6.25-rc2-sched-devel #29
RIP: 0010:[<ffffffff809b1b2b>]  [<ffffffff809b1b2b>]
RSP: 0000:ffff81003fa17ec0  EFLAGS: 00010206
RAX: 0000000000000000 RBX: 0000000000000008 RCX: 0000000000000018
RDX: ffff81003f9b0418 RSI: 00000000000000fc RDI: 0000003000000008
RBP: 0000000000093100 R08: 0000000000000000 R09: ffff81003f9b0430
R10: 0000000000000000 R11: 0000000000000008 R12: ffff81003f9b0410
R13: ffffffff809d5320 R14: ffff81003fa17ee0 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff810001e0b000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 000000000000003c CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 1, threadinfo ffff81003fa16000, task ffff81003fa14000)
Stack:  0000000000000008 0000000000093100 ffffffff809f58a8 ffffffff809a96d4
 ffffffff808ae080 ffff81003fa17f28 ffff810001e12540 ffffffff808ae390
 ffffffff8022ba7f 0000000000000008 0000000000093100 0000000000000008
Call Trace:
 [<ffffffff809a96d4>]
 [<ffffffff8022ba7f>]
 [<ffffffff8020cc68>]
 [<ffffffff8020c37c>]
 [<ffffffff809a95fc>]
 [<ffffffff8020cc5e>]


Code: 31 c9 31 d2 48 c7 c6 d8 a9 9d 80 48 c7 c7 49 1c 9b 80 e8 1c 8e 86 ff 4c 89 e2 31 c9 48 8b 05 a5 1e fe ff 48 8b 04 08 48 83 c1 08 <8b> 40 3c 89 02 48 83 c2 04 48 83 f9 40 75 e2 e8 34 20 8b ff fb 
RIP  [<ffffffff809b1b2b>]
 RSP <ffff81003fa17ec0>
CR2: 000000000000003c
---[ end trace ca143223eefdc828 ]---
Kernel panic - not syncing: Attempted to kill init!
Rebooting in 10 seconds..Press any key to enter the menu

--Dxnq1zWXvFF0Q93v--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
