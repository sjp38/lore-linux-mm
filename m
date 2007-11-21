Message-Id: <20071121100201.417452000@sgi.com>
References: <20071121100201.156191000@sgi.com>
Date: Wed, 21 Nov 2007 02:02:02 -0800
From: travis@sgi.com
Subject: [PATCH 1/2] cpumask: Convert cpumask_of_cpu to static array -v2
Content-Disposition: inline; filename=cpumask-to-percpu
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>
Cc: mingo@elte.hu, apw@shadowen.org, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Here is a simple patch to use a per cpu cpumask instead of constructing 
one on the stack. I have been running awhile with this one:

Do not use stack to allocate cpumask for cpumask_of_cpu

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Modified to be used only if NR_CPUS is greater than the BITS_PER_LONG
as well as fix cases where !SMP and both NR_CPUS > and < BITS_PER_LONG.

Signed-off-by: Mike Travis <travis@sgi.com>

---
 arch/x86/kernel/apic_32.c      |    1 +
 arch/x86/kernel/apic_64.c      |    1 +
 arch/x86/kernel/cpu/intel.c    |    1 +
 arch/x86/kernel/smp_32.c       |    1 +
 arch/x86/kernel/smp_64.c       |    1 +
 arch/x86/kernel/smpcommon_32.c |    1 +
 arch/x86/mach-generic/bigsmp.c |    1 +
 arch/x86/mach-generic/summit.c |    1 +
 arch/x86/mm/numa_64.c          |    1 +
 include/linux/cpumask.h        |    4 ++++
 include/linux/sched.h          |    4 ++++
 kernel/sched.c                 |    9 +++++++++
 12 files changed, 26 insertions(+)

--- linux-2.6.24-rc2.orig/include/linux/cpumask.h	2007-11-20 23:47:27.012300595 -0800
+++ linux-2.6.24-rc2/include/linux/cpumask.h	2007-11-20 23:47:27.116306809 -0800
@@ -222,6 +222,9 @@ int __next_cpu(int n, const cpumask_t *s
 #define next_cpu(n, src)	1
 #endif
 
+#if defined(CONFIG_SMP) && (NR_CPUS > BITS_PER_LONG)
+#define cpumask_of_cpu(cpu)    per_cpu(cpu_mask, cpu)
+#else
 #define cpumask_of_cpu(cpu)						\
 ({									\
 	typeof(_unused_cpumask_arg_) m;					\
@@ -233,6 +236,7 @@ int __next_cpu(int n, const cpumask_t *s
 	}								\
 	m;								\
 })
+#endif
 
 #define CPU_MASK_LAST_WORD BITMAP_LAST_WORD_MASK(NR_CPUS)
 
--- linux-2.6.24-rc2.orig/kernel/sched.c	2007-11-20 23:47:27.012300595 -0800
+++ linux-2.6.24-rc2/kernel/sched.c	2007-11-21 00:48:39.619652089 -0800
@@ -6732,6 +6732,11 @@ static void init_cfs_rq(struct cfs_rq *c
 	cfs_rq->min_vruntime = (u64)(-(1LL << 20));
 }
 
+#if NR_CPUS > BITS_PER_LONG
+DEFINE_PER_CPU(cpumask_t, cpu_mask);
+EXPORT_PER_CPU_SYMBOL(cpu_mask);
+#endif
+
 void __init sched_init(void)
 {
 	int highest_cpu = 0;
@@ -6741,6 +6746,10 @@ void __init sched_init(void)
 		struct rt_prio_array *array;
 		struct rq *rq;
 
+#if NR_CPUS > BITS_PER_LONG
+		/* This makes cpumask_of_cpu work */
+		cpu_set(i, per_cpu(cpu_mask, i));
+#endif
 		rq = cpu_rq(i);
 		spin_lock_init(&rq->lock);
 		lockdep_set_class(&rq->lock, &rq->rq_lock_key);
--- linux-2.6.24-rc2.orig/arch/x86/mm/numa_64.c	2007-11-20 23:47:27.024301312 -0800
+++ linux-2.6.24-rc2/arch/x86/mm/numa_64.c	2007-11-20 23:47:27.144308482 -0800
@@ -11,6 +11,7 @@
 #include <linux/ctype.h>
 #include <linux/module.h>
 #include <linux/nodemask.h>
+#include <linux/sched.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
--- linux-2.6.24-rc2.orig/include/linux/sched.h	2007-11-20 23:47:27.012300595 -0800
+++ linux-2.6.24-rc2/include/linux/sched.h	2007-11-21 00:48:39.619652089 -0800
@@ -2024,6 +2024,10 @@ static inline void migration_init(void)
 #define TASK_SIZE_OF(tsk)	TASK_SIZE
 #endif
 
+#if defined(CONFIG_SMP) && (NR_CPUS > BITS_PER_LONG)
+DECLARE_PER_CPU(cpumask_t, cpu_mask);
+#endif
+
 #endif /* __KERNEL__ */
 
 #endif
--- linux-2.6.24-rc2.orig/arch/x86/kernel/apic_32.c	2007-11-20 11:56:44.000000000 -0800
+++ linux-2.6.24-rc2/arch/x86/kernel/apic_32.c	2007-11-21 00:29:36.619377873 -0800
@@ -28,6 +28,7 @@
 #include <linux/acpi_pmtmr.h>
 #include <linux/module.h>
 #include <linux/dmi.h>
+#include <linux/sched.h>
 
 #include <asm/atomic.h>
 #include <asm/smp.h>
--- linux-2.6.24-rc2.orig/arch/x86/kernel/apic_64.c	2007-11-20 11:56:44.000000000 -0800
+++ linux-2.6.24-rc2/arch/x86/kernel/apic_64.c	2007-11-21 00:29:47.240012242 -0800
@@ -27,6 +27,7 @@
 #include <linux/ioport.h>
 #include <linux/clockchips.h>
 #include <linux/acpi_pmtmr.h>
+#include <linux/sched.h>
 
 #include <asm/atomic.h>
 #include <asm/smp.h>
--- linux-2.6.24-rc2.orig/arch/x86/kernel/smp_32.c	2007-11-06 13:57:46.000000000 -0800
+++ linux-2.6.24-rc2/arch/x86/kernel/smp_32.c	2007-11-21 00:29:23.066568364 -0800
@@ -19,6 +19,7 @@
 #include <linux/interrupt.h>
 #include <linux/cpu.h>
 #include <linux/module.h>
+#include <linux/sched.h>
 
 #include <asm/mtrr.h>
 #include <asm/tlbflush.h>
--- linux-2.6.24-rc2.orig/arch/x86/kernel/smp_64.c	2007-11-20 11:56:45.000000000 -0800
+++ linux-2.6.24-rc2/arch/x86/kernel/smp_64.c	2007-11-21 00:29:09.389751446 -0800
@@ -18,6 +18,7 @@
 #include <linux/kernel_stat.h>
 #include <linux/mc146818rtc.h>
 #include <linux/interrupt.h>
+#include <linux/sched.h>
 
 #include <asm/mtrr.h>
 #include <asm/pgalloc.h>
--- linux-2.6.24-rc2.orig/arch/x86/kernel/smpcommon_32.c	2007-11-06 13:57:46.000000000 -0800
+++ linux-2.6.24-rc2/arch/x86/kernel/smpcommon_32.c	2007-11-21 00:36:48.833194837 -0800
@@ -2,6 +2,7 @@
  * SMP stuff which is common to all sub-architectures.
  */
 #include <linux/module.h>
+#include <linux/sched.h>
 #include <asm/smp.h>
 
 DEFINE_PER_CPU(unsigned long, this_cpu_off);
--- linux-2.6.24-rc2.orig/arch/x86/mach-generic/bigsmp.c	2007-11-06 13:57:46.000000000 -0800
+++ linux-2.6.24-rc2/arch/x86/mach-generic/bigsmp.c	2007-11-21 00:34:34.017141068 -0800
@@ -14,6 +14,7 @@
 #include <linux/smp.h>
 #include <linux/init.h>
 #include <linux/dmi.h>
+#include <linux/sched.h>
 #include <asm/mach-bigsmp/mach_apic.h>
 #include <asm/mach-bigsmp/mach_apicdef.h>
 #include <asm/mach-bigsmp/mach_ipi.h>
--- linux-2.6.24-rc2.orig/arch/x86/mach-generic/summit.c	2007-11-06 13:57:46.000000000 -0800
+++ linux-2.6.24-rc2/arch/x86/mach-generic/summit.c	2007-11-21 00:32:03.188132268 -0800
@@ -13,6 +13,7 @@
 #include <linux/string.h>
 #include <linux/smp.h>
 #include <linux/init.h>
+#include <linux/sched.h>
 #include <asm/mach-summit/mach_apic.h>
 #include <asm/mach-summit/mach_apicdef.h>
 #include <asm/mach-summit/mach_ipi.h>
--- linux-2.6.24-rc2.orig/arch/x86/kernel/cpu/intel.c	2007-11-20 11:56:44.000000000 -0800
+++ linux-2.6.24-rc2/arch/x86/kernel/cpu/intel.c	2007-11-21 00:49:36.267035499 -0800
@@ -6,6 +6,7 @@
 #include <linux/smp.h>
 #include <linux/thread_info.h>
 #include <linux/module.h>
+#include <linux/sched.h>
 
 #include <asm/processor.h>
 #include <asm/pgtable.h>

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
