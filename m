Message-Id: <20071121080225.780716000@sgi.com>
References: <20071121080225.606291000@sgi.com>
Date: Wed, 21 Nov 2007 00:02:26 -0800
From: travis@sgi.com
Subject: [PATCH 1/2] cpumask: Convert cpumask_of_cpu to static array
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
 arch/x86/kernel/process_64.c |    1 +
 arch/x86/mm/numa_64.c        |    1 +
 include/linux/cpumask.h      |    4 ++++
 include/linux/sched.h        |    4 ++++
 kernel/sched.c               |    9 +++++++++
 5 files changed, 19 insertions(+)

--- a/include/linux/cpumask.h
+++ b/include/linux/cpumask.h
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
 
--- a/kernel/sched.c
+++ b/kernel/sched.c
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
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -36,6 +36,7 @@
 #include <linux/kprobes.h>
 #include <linux/kdebug.h>
 #include <linux/tick.h>
+#include <linux/percpu.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
--- a/arch/x86/mm/numa_64.c
+++ b/arch/x86/mm/numa_64.c
@@ -11,6 +11,7 @@
 #include <linux/ctype.h>
 #include <linux/module.h>
 #include <linux/nodemask.h>
+#include <linux/sched.h>
 
 #include <asm/e820.h>
 #include <asm/proto.h>
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2024,6 +2024,10 @@ static inline void migration_init(void)
 #define TASK_SIZE_OF(tsk)	TASK_SIZE
 #endif
 
+#if defined(CONFIG_SMP) && (NR_CPUS > BITS_PER_LONG)
+DECLARE_PER_CPU(cpumask_t, cpu_mask);
+#endif
+
 #endif /* __KERNEL__ */
 
 #endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
