Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 262CF6B0062
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 16:12:16 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 13 Nov 2009 16:17:20 -0500
Message-Id: <20091113211720.15074.99808.sendpatchset@localhost.localdomain>
In-Reply-To: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
References: <20091113211714.15074.29078.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 1/6] numa: Use Generic Per-cpu Variables for numa_node_id()
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

Against:  2.6.32-rc5-mmotm-091101-1001

Rework the generic version of the numa_node_id() function to use the
new generic percpu variable infrastructure.

Guard the new implementation with a new config option:

        CONFIG_USE_PERCPU_NUMA_NODE_ID.

Archs which support this new implemention will default this option
to 'y' when NUMA is configured.  This config option could be removed
if/when all archs switch over to the generic percpu implementation
of numa_node_id().  Arch support involves:

1) converting any existing per cpu variable implementations to use
   this implementation.  x86_64 is an instance of such an arch.
2) archs that don't use a per cpu variable for numa_node_id() will
   need to initialize the new per cpu variable "numa_node" as cpus
   are brought on-line.  ia64 is an example.

Subsequent patches will convert x86_64 and ia64 to use this
implemenation.


Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
[Christoph's signoff here?]

V0:
#  From cl@linux-foundation.org Wed Nov  4 10:36:12 2009
#  Date: Wed, 4 Nov 2009 12:35:14 -0500 (EST)
#  From: Christoph Lameter <cl@linux-foundation.org>
#  To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
#  Subject: Re: [PATCH/RFC] slab:  handle memoryless nodes efficiently
#
#  I have a very early form of a draft of a patch here that genericizes
#  numa_node_id(). Uses the new generic this_cpu_xxx stuff.
#
#  Not complete.

V1:
  + split out x86 specific changes to subsequent patch
  + split out "numa_mem_id()" and related changes to separate patch
  + moved generic definitions of __this_cpu_xxx from linux/percpu.h
    to asm-generic/percpu.h where asm/percpu.h and other asm hdrs
    can use them.
  + export new percpu symbol 'numa_node' in mm/percpu.h
  + include <asm/percpu.h> in <linux/topology.h> for use by new
    numa_node_id().

V2:
  + add back the #ifndef/#endif guard around numa_node_id() so that archs
    can override generic definition
  + add generic stub for set_numa_node()
  + use generic percpu numa_node_id() only if enabled by
      CONFIG_USE_PERCPU_NUMA_NODE_ID
   to allow incremental per arch support.  This option could be removed when/if
   all archs that support NUMA support this option.

 include/asm-generic/percpu.h   |  456 ++++++++++++++++++++++++++++++++++++++++-
 include/asm-generic/topology.h |    3 
 include/linux/percpu.h         |  454 ----------------------------------------
 include/linux/topology.h       |   32 ++
 mm/percpu.c                    |    8 
 5 files changed, 493 insertions(+), 460 deletions(-)

Index: linux-2.6.32-rc5-mmotm-091101-1001/include/linux/topology.h
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/include/linux/topology.h
+++ linux-2.6.32-rc5-mmotm-091101-1001/include/linux/topology.h
@@ -203,8 +203,35 @@ int arch_update_cpu_topology(void);
 #ifndef SD_NODE_INIT
 #error Please define an appropriate SD_NODE_INIT in include/asm/topology.h!!!
 #endif
+
 #endif /* CONFIG_NUMA */
 
+#ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
+DECLARE_PER_CPU(int, numa_node);
+
+#ifndef numa_node_id
+/* Returns the number of the current Node. */
+#define numa_node_id()		__this_cpu_read(numa_node)
+#endif
+
+#ifndef cpu_to_node
+#define cpu_to_node(__cpu)	per_cpu(numa_node, (__cpu))
+#endif
+
+#ifndef set_numa_node
+#define set_numa_node(__node) percpu_write(numa_node, __node)
+#endif
+
+#else	/* !CONFIG_USE_PERCPU_NUMA_NODE_ID */
+
+/* Returns the number of the current Node. */
+#ifndef numa_node_id
+#define numa_node_id()		(cpu_to_node(raw_smp_processor_id()))
+
+#endif
+
+#endif	/* [!]CONFIG_USE_PERCPU_NUMA_NODE_ID */
+
 #ifndef topology_physical_package_id
 #define topology_physical_package_id(cpu)	((void)(cpu), -1)
 #endif
@@ -218,9 +245,4 @@ int arch_update_cpu_topology(void);
 #define topology_core_cpumask(cpu)		cpumask_of(cpu)
 #endif
 
-/* Returns the number of the current Node. */
-#ifndef numa_node_id
-#define numa_node_id()		(cpu_to_node(raw_smp_processor_id()))
-#endif
-
 #endif /* _LINUX_TOPOLOGY_H */
Index: linux-2.6.32-rc5-mmotm-091101-1001/mm/percpu.c
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/mm/percpu.c
+++ linux-2.6.32-rc5-mmotm-091101-1001/mm/percpu.c
@@ -2070,3 +2070,11 @@ void __init setup_per_cpu_areas(void)
 		__per_cpu_offset[cpu] = delta + pcpu_unit_offsets[cpu];
 }
 #endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
+
+/* NUMA Setup */
+
+#ifdef CONFIG_USE_PERCPU_NUMA_NODE_ID
+DEFINE_PER_CPU(int, numa_node);
+EXPORT_PER_CPU_SYMBOL(numa_node);
+#endif
+
Index: linux-2.6.32-rc5-mmotm-091101-1001/include/asm-generic/topology.h
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/include/asm-generic/topology.h
+++ linux-2.6.32-rc5-mmotm-091101-1001/include/asm-generic/topology.h
@@ -34,6 +34,9 @@
 #ifndef cpu_to_node
 #define cpu_to_node(cpu)	((void)(cpu),0)
 #endif
+#ifndef cpu_to_mem
+#define cpu_to_mem(cpu)		((void)(cpu),0)
+#endif
 #ifndef parent_node
 #define parent_node(node)	((void)(node),0)
 #endif
Index: linux-2.6.32-rc5-mmotm-091101-1001/include/asm-generic/percpu.h
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/include/asm-generic/percpu.h
+++ linux-2.6.32-rc5-mmotm-091101-1001/include/asm-generic/percpu.h
@@ -63,11 +63,465 @@ extern unsigned long __per_cpu_offset[NR
 #define this_cpu_ptr(ptr) SHIFT_PERCPU_PTR(ptr, my_cpu_offset)
 #define __this_cpu_ptr(ptr) SHIFT_PERCPU_PTR(ptr, __my_cpu_offset)
 
-
 #ifdef CONFIG_HAVE_SETUP_PER_CPU_AREA
 extern void setup_per_cpu_areas(void);
 #endif
 
+/*
+ * Optional methods for optimized non-lvalue per-cpu variable access.
+ *
+ * @var can be a percpu variable or a field of it and its size should
+ * equal char, int or long.  percpu_read() evaluates to a lvalue and
+ * all others to void.
+ *
+ * These operations are guaranteed to be atomic w.r.t. preemption.
+ * The generic versions use plain get/put_cpu_var().  Archs are
+ * encouraged to implement single-instruction alternatives which don't
+ * require preemption protection.
+ */
+#ifndef percpu_read
+# define percpu_read(var)						\
+  ({									\
+	typeof(var) *pr_ptr__ = &(var);					\
+	typeof(var) pr_ret__;						\
+	pr_ret__ = get_cpu_var(*pr_ptr__);				\
+	put_cpu_var(*pr_ptr__);						\
+	pr_ret__;							\
+  })
+#endif
+
+#define __percpu_generic_to_op(var, val, op)				\
+do {									\
+	typeof(var) *pgto_ptr__ = &(var);				\
+	get_cpu_var(*pgto_ptr__) op val;				\
+	put_cpu_var(*pgto_ptr__);					\
+} while (0)
+
+#ifndef percpu_write
+# define percpu_write(var, val)		__percpu_generic_to_op(var, (val), =)
+#endif
+
+#ifndef percpu_add
+# define percpu_add(var, val)		__percpu_generic_to_op(var, (val), +=)
+#endif
+
+#ifndef percpu_sub
+# define percpu_sub(var, val)		__percpu_generic_to_op(var, (val), -=)
+#endif
+
+#ifndef percpu_and
+# define percpu_and(var, val)		__percpu_generic_to_op(var, (val), &=)
+#endif
+
+#ifndef percpu_or
+# define percpu_or(var, val)		__percpu_generic_to_op(var, (val), |=)
+#endif
+
+#ifndef percpu_xor
+# define percpu_xor(var, val)		__percpu_generic_to_op(var, (val), ^=)
+#endif
+
+/*
+ * Branching function to split up a function into a set of functions that
+ * are called for different scalar sizes of the objects handled.
+ */
+
+extern void __bad_size_call_parameter(void);
+
+#define __pcpu_size_call_return(stem, variable)				\
+({	typeof(variable) pscr_ret__;					\
+	__verify_pcpu_ptr(&(variable));					\
+	switch(sizeof(variable)) {					\
+	case 1: pscr_ret__ = stem##1(variable);break;			\
+	case 2: pscr_ret__ = stem##2(variable);break;			\
+	case 4: pscr_ret__ = stem##4(variable);break;			\
+	case 8: pscr_ret__ = stem##8(variable);break;			\
+	default:							\
+		__bad_size_call_parameter();break;			\
+	}								\
+	pscr_ret__;							\
+})
+
+#define __pcpu_size_call(stem, variable, ...)				\
+do {									\
+	__verify_pcpu_ptr(&(variable));					\
+	switch(sizeof(variable)) {					\
+		case 1: stem##1(variable, __VA_ARGS__);break;		\
+		case 2: stem##2(variable, __VA_ARGS__);break;		\
+		case 4: stem##4(variable, __VA_ARGS__);break;		\
+		case 8: stem##8(variable, __VA_ARGS__);break;		\
+		default: 						\
+			__bad_size_call_parameter();break;		\
+	}								\
+} while (0)
+
+/*
+ * Optimized manipulation for memory allocated through the per cpu
+ * allocator or for addresses of per cpu variables.
+ *
+ * These operation guarantee exclusivity of access for other operations
+ * on the *same* processor. The assumption is that per cpu data is only
+ * accessed by a single processor instance (the current one).
+ *
+ * The first group is used for accesses that must be done in a
+ * preemption safe way since we know that the context is not preempt
+ * safe. Interrupts may occur. If the interrupt modifies the variable
+ * too then RMW actions will not be reliable.
+ *
+ * The arch code can provide optimized functions in two ways:
+ *
+ * 1. Override the function completely. F.e. define this_cpu_add().
+ *    The arch must then ensure that the various scalar format passed
+ *    are handled correctly.
+ *
+ * 2. Provide functions for certain scalar sizes. F.e. provide
+ *    this_cpu_add_2() to provide per cpu atomic operations for 2 byte
+ *    sized RMW actions. If arch code does not provide operations for
+ *    a scalar size then the fallback in the generic code will be
+ *    used.
+ */
+
+#define _this_cpu_generic_read(pcp)					\
+({	typeof(pcp) ret__;						\
+	preempt_disable();						\
+	ret__ = *this_cpu_ptr(&(pcp));					\
+	preempt_enable();						\
+	ret__;								\
+})
+
+#ifndef this_cpu_read
+# ifndef this_cpu_read_1
+#  define this_cpu_read_1(pcp)	_this_cpu_generic_read(pcp)
+# endif
+# ifndef this_cpu_read_2
+#  define this_cpu_read_2(pcp)	_this_cpu_generic_read(pcp)
+# endif
+# ifndef this_cpu_read_4
+#  define this_cpu_read_4(pcp)	_this_cpu_generic_read(pcp)
+# endif
+# ifndef this_cpu_read_8
+#  define this_cpu_read_8(pcp)	_this_cpu_generic_read(pcp)
+# endif
+# define this_cpu_read(pcp)	__pcpu_size_call_return(this_cpu_read_, (pcp))
+#endif
+
+#define _this_cpu_generic_to_op(pcp, val, op)				\
+do {									\
+	preempt_disable();						\
+	*__this_cpu_ptr(&(pcp)) op val;					\
+	preempt_enable();						\
+} while (0)
+
+#ifndef this_cpu_write
+# ifndef this_cpu_write_1
+#  define this_cpu_write_1(pcp, val)	_this_cpu_generic_to_op((pcp), (val), =)
+# endif
+# ifndef this_cpu_write_2
+#  define this_cpu_write_2(pcp, val)	_this_cpu_generic_to_op((pcp), (val), =)
+# endif
+# ifndef this_cpu_write_4
+#  define this_cpu_write_4(pcp, val)	_this_cpu_generic_to_op((pcp), (val), =)
+# endif
+# ifndef this_cpu_write_8
+#  define this_cpu_write_8(pcp, val)	_this_cpu_generic_to_op((pcp), (val), =)
+# endif
+# define this_cpu_write(pcp, val)	__pcpu_size_call(this_cpu_write_, (pcp), (val))
+#endif
+
+#ifndef this_cpu_add
+# ifndef this_cpu_add_1
+#  define this_cpu_add_1(pcp, val)	_this_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef this_cpu_add_2
+#  define this_cpu_add_2(pcp, val)	_this_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef this_cpu_add_4
+#  define this_cpu_add_4(pcp, val)	_this_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef this_cpu_add_8
+#  define this_cpu_add_8(pcp, val)	_this_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# define this_cpu_add(pcp, val)		__pcpu_size_call(this_cpu_add_, (pcp), (val))
+#endif
+
+#ifndef this_cpu_sub
+# define this_cpu_sub(pcp, val)		this_cpu_add((pcp), -(val))
+#endif
+
+#ifndef this_cpu_inc
+# define this_cpu_inc(pcp)		this_cpu_add((pcp), 1)
+#endif
+
+#ifndef this_cpu_dec
+# define this_cpu_dec(pcp)		this_cpu_sub((pcp), 1)
+#endif
+
+#ifndef this_cpu_and
+# ifndef this_cpu_and_1
+#  define this_cpu_and_1(pcp, val)	_this_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef this_cpu_and_2
+#  define this_cpu_and_2(pcp, val)	_this_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef this_cpu_and_4
+#  define this_cpu_and_4(pcp, val)	_this_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef this_cpu_and_8
+#  define this_cpu_and_8(pcp, val)	_this_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# define this_cpu_and(pcp, val)		__pcpu_size_call(this_cpu_and_, (pcp), (val))
+#endif
+
+#ifndef this_cpu_or
+# ifndef this_cpu_or_1
+#  define this_cpu_or_1(pcp, val)	_this_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef this_cpu_or_2
+#  define this_cpu_or_2(pcp, val)	_this_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef this_cpu_or_4
+#  define this_cpu_or_4(pcp, val)	_this_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef this_cpu_or_8
+#  define this_cpu_or_8(pcp, val)	_this_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# define this_cpu_or(pcp, val)		__pcpu_size_call(this_cpu_or_, (pcp), (val))
+#endif
+
+#ifndef this_cpu_xor
+# ifndef this_cpu_xor_1
+#  define this_cpu_xor_1(pcp, val)	_this_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef this_cpu_xor_2
+#  define this_cpu_xor_2(pcp, val)	_this_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef this_cpu_xor_4
+#  define this_cpu_xor_4(pcp, val)	_this_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef this_cpu_xor_8
+#  define this_cpu_xor_8(pcp, val)	_this_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# define this_cpu_xor(pcp, val)		__pcpu_size_call(this_cpu_or_, (pcp), (val))
+#endif
+
+/*
+ * Generic percpu operations that do not require preemption handling.
+ * Either we do not care about races or the caller has the
+ * responsibility of handling preemptions issues. Arch code can still
+ * override these instructions since the arch per cpu code may be more
+ * efficient and may actually get race freeness for free (that is the
+ * case for x86 for example).
+ *
+ * If there is no other protection through preempt disable and/or
+ * disabling interupts then one of these RMW operations can show unexpected
+ * behavior because the execution thread was rescheduled on another processor
+ * or an interrupt occurred and the same percpu variable was modified from
+ * the interrupt context.
+ */
+#ifndef __this_cpu_read
+# ifndef __this_cpu_read_1
+#  define __this_cpu_read_1(pcp)	(*__this_cpu_ptr(&(pcp)))
+# endif
+# ifndef __this_cpu_read_2
+#  define __this_cpu_read_2(pcp)	(*__this_cpu_ptr(&(pcp)))
+# endif
+# ifndef __this_cpu_read_4
+#  define __this_cpu_read_4(pcp)	(*__this_cpu_ptr(&(pcp)))
+# endif
+# ifndef __this_cpu_read_8
+#  define __this_cpu_read_8(pcp)	(*__this_cpu_ptr(&(pcp)))
+# endif
+# define __this_cpu_read(pcp)	__pcpu_size_call_return(__this_cpu_read_, (pcp))
+#endif
+
+#define __this_cpu_generic_to_op(pcp, val, op)				\
+do {									\
+	*__this_cpu_ptr(&(pcp)) op val;					\
+} while (0)
+
+#ifndef __this_cpu_write
+# ifndef __this_cpu_write_1
+#  define __this_cpu_write_1(pcp, val)	__this_cpu_generic_to_op((pcp), (val), =)
+# endif
+# ifndef __this_cpu_write_2
+#  define __this_cpu_write_2(pcp, val)	__this_cpu_generic_to_op((pcp), (val), =)
+# endif
+# ifndef __this_cpu_write_4
+#  define __this_cpu_write_4(pcp, val)	__this_cpu_generic_to_op((pcp), (val), =)
+# endif
+# ifndef __this_cpu_write_8
+#  define __this_cpu_write_8(pcp, val)	__this_cpu_generic_to_op((pcp), (val), =)
+# endif
+# define __this_cpu_write(pcp, val)	__pcpu_size_call(__this_cpu_write_, (pcp), (val))
+#endif
+
+#ifndef __this_cpu_add
+# ifndef __this_cpu_add_1
+#  define __this_cpu_add_1(pcp, val)	__this_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef __this_cpu_add_2
+#  define __this_cpu_add_2(pcp, val)	__this_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef __this_cpu_add_4
+#  define __this_cpu_add_4(pcp, val)	__this_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef __this_cpu_add_8
+#  define __this_cpu_add_8(pcp, val)	__this_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# define __this_cpu_add(pcp, val)	__pcpu_size_call(__this_cpu_add_, (pcp), (val))
+#endif
+
+#ifndef __this_cpu_sub
+# define __this_cpu_sub(pcp, val)	__this_cpu_add((pcp), -(val))
+#endif
+
+#ifndef __this_cpu_inc
+# define __this_cpu_inc(pcp)		__this_cpu_add((pcp), 1)
+#endif
+
+#ifndef __this_cpu_dec
+# define __this_cpu_dec(pcp)		__this_cpu_sub((pcp), 1)
+#endif
+
+#ifndef __this_cpu_and
+# ifndef __this_cpu_and_1
+#  define __this_cpu_and_1(pcp, val)	__this_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef __this_cpu_and_2
+#  define __this_cpu_and_2(pcp, val)	__this_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef __this_cpu_and_4
+#  define __this_cpu_and_4(pcp, val)	__this_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef __this_cpu_and_8
+#  define __this_cpu_and_8(pcp, val)	__this_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# define __this_cpu_and(pcp, val)	__pcpu_size_call(__this_cpu_and_, (pcp), (val))
+#endif
+
+#ifndef __this_cpu_or
+# ifndef __this_cpu_or_1
+#  define __this_cpu_or_1(pcp, val)	__this_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef __this_cpu_or_2
+#  define __this_cpu_or_2(pcp, val)	__this_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef __this_cpu_or_4
+#  define __this_cpu_or_4(pcp, val)	__this_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef __this_cpu_or_8
+#  define __this_cpu_or_8(pcp, val)	__this_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# define __this_cpu_or(pcp, val)	__pcpu_size_call(__this_cpu_or_, (pcp), (val))
+#endif
+
+#ifndef __this_cpu_xor
+# ifndef __this_cpu_xor_1
+#  define __this_cpu_xor_1(pcp, val)	__this_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef __this_cpu_xor_2
+#  define __this_cpu_xor_2(pcp, val)	__this_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef __this_cpu_xor_4
+#  define __this_cpu_xor_4(pcp, val)	__this_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef __this_cpu_xor_8
+#  define __this_cpu_xor_8(pcp, val)	__this_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# define __this_cpu_xor(pcp, val)	__pcpu_size_call(__this_cpu_xor_, (pcp), (val))
+#endif
+
+/*
+ * IRQ safe versions of the per cpu RMW operations. Note that these operations
+ * are *not* safe against modification of the same variable from another
+ * processors (which one gets when using regular atomic operations)
+ . They are guaranteed to be atomic vs. local interrupts and
+ * preemption only.
+ */
+#define irqsafe_cpu_generic_to_op(pcp, val, op)				\
+do {									\
+	unsigned long flags;						\
+	local_irq_save(flags);						\
+	*__this_cpu_ptr(&(pcp)) op val;					\
+	local_irq_restore(flags);					\
+} while (0)
+
+#ifndef irqsafe_cpu_add
+# ifndef irqsafe_cpu_add_1
+#  define irqsafe_cpu_add_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef irqsafe_cpu_add_2
+#  define irqsafe_cpu_add_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef irqsafe_cpu_add_4
+#  define irqsafe_cpu_add_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef irqsafe_cpu_add_8
+#  define irqsafe_cpu_add_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# define irqsafe_cpu_add(pcp, val) __pcpu_size_call(irqsafe_cpu_add_, (pcp), (val))
+#endif
+
+#ifndef irqsafe_cpu_sub
+# define irqsafe_cpu_sub(pcp, val)	irqsafe_cpu_add((pcp), -(val))
+#endif
+
+#ifndef irqsafe_cpu_inc
+# define irqsafe_cpu_inc(pcp)	irqsafe_cpu_add((pcp), 1)
+#endif
+
+#ifndef irqsafe_cpu_dec
+# define irqsafe_cpu_dec(pcp)	irqsafe_cpu_sub((pcp), 1)
+#endif
+
+#ifndef irqsafe_cpu_and
+# ifndef irqsafe_cpu_and_1
+#  define irqsafe_cpu_and_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef irqsafe_cpu_and_2
+#  define irqsafe_cpu_and_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef irqsafe_cpu_and_4
+#  define irqsafe_cpu_and_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef irqsafe_cpu_and_8
+#  define irqsafe_cpu_and_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# define irqsafe_cpu_and(pcp, val) __pcpu_size_call(irqsafe_cpu_and_, (val))
+#endif
+
+#ifndef irqsafe_cpu_or
+# ifndef irqsafe_cpu_or_1
+#  define irqsafe_cpu_or_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef irqsafe_cpu_or_2
+#  define irqsafe_cpu_or_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef irqsafe_cpu_or_4
+#  define irqsafe_cpu_or_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef irqsafe_cpu_or_8
+#  define irqsafe_cpu_or_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# define irqsafe_cpu_or(pcp, val) __pcpu_size_call(irqsafe_cpu_or_, (val))
+#endif
+
+#ifndef irqsafe_cpu_xor
+# ifndef irqsafe_cpu_xor_1
+#  define irqsafe_cpu_xor_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef irqsafe_cpu_xor_2
+#  define irqsafe_cpu_xor_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef irqsafe_cpu_xor_4
+#  define irqsafe_cpu_xor_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef irqsafe_cpu_xor_8
+#  define irqsafe_cpu_xor_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# define irqsafe_cpu_xor(pcp, val) __pcpu_size_call(irqsafe_cpu_xor_, (val))
+#endif
+
 #else /* ! SMP */
 
 #define per_cpu(var, cpu)			(*((void)(cpu), &(var)))
Index: linux-2.6.32-rc5-mmotm-091101-1001/include/linux/percpu.h
===================================================================
--- linux-2.6.32-rc5-mmotm-091101-1001.orig/include/linux/percpu.h
+++ linux-2.6.32-rc5-mmotm-091101-1001/include/linux/percpu.h
@@ -174,459 +174,5 @@ static inline void *pcpu_lpage_remapped(
 #define alloc_percpu(type)	\
 	(typeof(type) __percpu *)__alloc_percpu(sizeof(type), __alignof__(type))
 
-/*
- * Optional methods for optimized non-lvalue per-cpu variable access.
- *
- * @var can be a percpu variable or a field of it and its size should
- * equal char, int or long.  percpu_read() evaluates to a lvalue and
- * all others to void.
- *
- * These operations are guaranteed to be atomic w.r.t. preemption.
- * The generic versions use plain get/put_cpu_var().  Archs are
- * encouraged to implement single-instruction alternatives which don't
- * require preemption protection.
- */
-#ifndef percpu_read
-# define percpu_read(var)						\
-  ({									\
-	typeof(var) *pr_ptr__ = &(var);					\
-	typeof(var) pr_ret__;						\
-	pr_ret__ = get_cpu_var(*pr_ptr__);				\
-	put_cpu_var(*pr_ptr__);						\
-	pr_ret__;							\
-  })
-#endif
-
-#define __percpu_generic_to_op(var, val, op)				\
-do {									\
-	typeof(var) *pgto_ptr__ = &(var);				\
-	get_cpu_var(*pgto_ptr__) op val;				\
-	put_cpu_var(*pgto_ptr__);					\
-} while (0)
-
-#ifndef percpu_write
-# define percpu_write(var, val)		__percpu_generic_to_op(var, (val), =)
-#endif
-
-#ifndef percpu_add
-# define percpu_add(var, val)		__percpu_generic_to_op(var, (val), +=)
-#endif
-
-#ifndef percpu_sub
-# define percpu_sub(var, val)		__percpu_generic_to_op(var, (val), -=)
-#endif
-
-#ifndef percpu_and
-# define percpu_and(var, val)		__percpu_generic_to_op(var, (val), &=)
-#endif
-
-#ifndef percpu_or
-# define percpu_or(var, val)		__percpu_generic_to_op(var, (val), |=)
-#endif
-
-#ifndef percpu_xor
-# define percpu_xor(var, val)		__percpu_generic_to_op(var, (val), ^=)
-#endif
-
-/*
- * Branching function to split up a function into a set of functions that
- * are called for different scalar sizes of the objects handled.
- */
-
-extern void __bad_size_call_parameter(void);
-
-#define __pcpu_size_call_return(stem, variable)				\
-({	typeof(variable) pscr_ret__;					\
-	__verify_pcpu_ptr(&(variable));					\
-	switch(sizeof(variable)) {					\
-	case 1: pscr_ret__ = stem##1(variable);break;			\
-	case 2: pscr_ret__ = stem##2(variable);break;			\
-	case 4: pscr_ret__ = stem##4(variable);break;			\
-	case 8: pscr_ret__ = stem##8(variable);break;			\
-	default:							\
-		__bad_size_call_parameter();break;			\
-	}								\
-	pscr_ret__;							\
-})
-
-#define __pcpu_size_call(stem, variable, ...)				\
-do {									\
-	__verify_pcpu_ptr(&(variable));					\
-	switch(sizeof(variable)) {					\
-		case 1: stem##1(variable, __VA_ARGS__);break;		\
-		case 2: stem##2(variable, __VA_ARGS__);break;		\
-		case 4: stem##4(variable, __VA_ARGS__);break;		\
-		case 8: stem##8(variable, __VA_ARGS__);break;		\
-		default: 						\
-			__bad_size_call_parameter();break;		\
-	}								\
-} while (0)
-
-/*
- * Optimized manipulation for memory allocated through the per cpu
- * allocator or for addresses of per cpu variables.
- *
- * These operation guarantee exclusivity of access for other operations
- * on the *same* processor. The assumption is that per cpu data is only
- * accessed by a single processor instance (the current one).
- *
- * The first group is used for accesses that must be done in a
- * preemption safe way since we know that the context is not preempt
- * safe. Interrupts may occur. If the interrupt modifies the variable
- * too then RMW actions will not be reliable.
- *
- * The arch code can provide optimized functions in two ways:
- *
- * 1. Override the function completely. F.e. define this_cpu_add().
- *    The arch must then ensure that the various scalar format passed
- *    are handled correctly.
- *
- * 2. Provide functions for certain scalar sizes. F.e. provide
- *    this_cpu_add_2() to provide per cpu atomic operations for 2 byte
- *    sized RMW actions. If arch code does not provide operations for
- *    a scalar size then the fallback in the generic code will be
- *    used.
- */
-
-#define _this_cpu_generic_read(pcp)					\
-({	typeof(pcp) ret__;						\
-	preempt_disable();						\
-	ret__ = *this_cpu_ptr(&(pcp));					\
-	preempt_enable();						\
-	ret__;								\
-})
-
-#ifndef this_cpu_read
-# ifndef this_cpu_read_1
-#  define this_cpu_read_1(pcp)	_this_cpu_generic_read(pcp)
-# endif
-# ifndef this_cpu_read_2
-#  define this_cpu_read_2(pcp)	_this_cpu_generic_read(pcp)
-# endif
-# ifndef this_cpu_read_4
-#  define this_cpu_read_4(pcp)	_this_cpu_generic_read(pcp)
-# endif
-# ifndef this_cpu_read_8
-#  define this_cpu_read_8(pcp)	_this_cpu_generic_read(pcp)
-# endif
-# define this_cpu_read(pcp)	__pcpu_size_call_return(this_cpu_read_, (pcp))
-#endif
-
-#define _this_cpu_generic_to_op(pcp, val, op)				\
-do {									\
-	preempt_disable();						\
-	*__this_cpu_ptr(&(pcp)) op val;					\
-	preempt_enable();						\
-} while (0)
-
-#ifndef this_cpu_write
-# ifndef this_cpu_write_1
-#  define this_cpu_write_1(pcp, val)	_this_cpu_generic_to_op((pcp), (val), =)
-# endif
-# ifndef this_cpu_write_2
-#  define this_cpu_write_2(pcp, val)	_this_cpu_generic_to_op((pcp), (val), =)
-# endif
-# ifndef this_cpu_write_4
-#  define this_cpu_write_4(pcp, val)	_this_cpu_generic_to_op((pcp), (val), =)
-# endif
-# ifndef this_cpu_write_8
-#  define this_cpu_write_8(pcp, val)	_this_cpu_generic_to_op((pcp), (val), =)
-# endif
-# define this_cpu_write(pcp, val)	__pcpu_size_call(this_cpu_write_, (pcp), (val))
-#endif
-
-#ifndef this_cpu_add
-# ifndef this_cpu_add_1
-#  define this_cpu_add_1(pcp, val)	_this_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# ifndef this_cpu_add_2
-#  define this_cpu_add_2(pcp, val)	_this_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# ifndef this_cpu_add_4
-#  define this_cpu_add_4(pcp, val)	_this_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# ifndef this_cpu_add_8
-#  define this_cpu_add_8(pcp, val)	_this_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# define this_cpu_add(pcp, val)		__pcpu_size_call(this_cpu_add_, (pcp), (val))
-#endif
-
-#ifndef this_cpu_sub
-# define this_cpu_sub(pcp, val)		this_cpu_add((pcp), -(val))
-#endif
-
-#ifndef this_cpu_inc
-# define this_cpu_inc(pcp)		this_cpu_add((pcp), 1)
-#endif
-
-#ifndef this_cpu_dec
-# define this_cpu_dec(pcp)		this_cpu_sub((pcp), 1)
-#endif
-
-#ifndef this_cpu_and
-# ifndef this_cpu_and_1
-#  define this_cpu_and_1(pcp, val)	_this_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# ifndef this_cpu_and_2
-#  define this_cpu_and_2(pcp, val)	_this_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# ifndef this_cpu_and_4
-#  define this_cpu_and_4(pcp, val)	_this_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# ifndef this_cpu_and_8
-#  define this_cpu_and_8(pcp, val)	_this_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# define this_cpu_and(pcp, val)		__pcpu_size_call(this_cpu_and_, (pcp), (val))
-#endif
-
-#ifndef this_cpu_or
-# ifndef this_cpu_or_1
-#  define this_cpu_or_1(pcp, val)	_this_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# ifndef this_cpu_or_2
-#  define this_cpu_or_2(pcp, val)	_this_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# ifndef this_cpu_or_4
-#  define this_cpu_or_4(pcp, val)	_this_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# ifndef this_cpu_or_8
-#  define this_cpu_or_8(pcp, val)	_this_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# define this_cpu_or(pcp, val)		__pcpu_size_call(this_cpu_or_, (pcp), (val))
-#endif
-
-#ifndef this_cpu_xor
-# ifndef this_cpu_xor_1
-#  define this_cpu_xor_1(pcp, val)	_this_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# ifndef this_cpu_xor_2
-#  define this_cpu_xor_2(pcp, val)	_this_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# ifndef this_cpu_xor_4
-#  define this_cpu_xor_4(pcp, val)	_this_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# ifndef this_cpu_xor_8
-#  define this_cpu_xor_8(pcp, val)	_this_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# define this_cpu_xor(pcp, val)		__pcpu_size_call(this_cpu_or_, (pcp), (val))
-#endif
-
-/*
- * Generic percpu operations that do not require preemption handling.
- * Either we do not care about races or the caller has the
- * responsibility of handling preemptions issues. Arch code can still
- * override these instructions since the arch per cpu code may be more
- * efficient and may actually get race freeness for free (that is the
- * case for x86 for example).
- *
- * If there is no other protection through preempt disable and/or
- * disabling interupts then one of these RMW operations can show unexpected
- * behavior because the execution thread was rescheduled on another processor
- * or an interrupt occurred and the same percpu variable was modified from
- * the interrupt context.
- */
-#ifndef __this_cpu_read
-# ifndef __this_cpu_read_1
-#  define __this_cpu_read_1(pcp)	(*__this_cpu_ptr(&(pcp)))
-# endif
-# ifndef __this_cpu_read_2
-#  define __this_cpu_read_2(pcp)	(*__this_cpu_ptr(&(pcp)))
-# endif
-# ifndef __this_cpu_read_4
-#  define __this_cpu_read_4(pcp)	(*__this_cpu_ptr(&(pcp)))
-# endif
-# ifndef __this_cpu_read_8
-#  define __this_cpu_read_8(pcp)	(*__this_cpu_ptr(&(pcp)))
-# endif
-# define __this_cpu_read(pcp)	__pcpu_size_call_return(__this_cpu_read_, (pcp))
-#endif
-
-#define __this_cpu_generic_to_op(pcp, val, op)				\
-do {									\
-	*__this_cpu_ptr(&(pcp)) op val;					\
-} while (0)
-
-#ifndef __this_cpu_write
-# ifndef __this_cpu_write_1
-#  define __this_cpu_write_1(pcp, val)	__this_cpu_generic_to_op((pcp), (val), =)
-# endif
-# ifndef __this_cpu_write_2
-#  define __this_cpu_write_2(pcp, val)	__this_cpu_generic_to_op((pcp), (val), =)
-# endif
-# ifndef __this_cpu_write_4
-#  define __this_cpu_write_4(pcp, val)	__this_cpu_generic_to_op((pcp), (val), =)
-# endif
-# ifndef __this_cpu_write_8
-#  define __this_cpu_write_8(pcp, val)	__this_cpu_generic_to_op((pcp), (val), =)
-# endif
-# define __this_cpu_write(pcp, val)	__pcpu_size_call(__this_cpu_write_, (pcp), (val))
-#endif
-
-#ifndef __this_cpu_add
-# ifndef __this_cpu_add_1
-#  define __this_cpu_add_1(pcp, val)	__this_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# ifndef __this_cpu_add_2
-#  define __this_cpu_add_2(pcp, val)	__this_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# ifndef __this_cpu_add_4
-#  define __this_cpu_add_4(pcp, val)	__this_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# ifndef __this_cpu_add_8
-#  define __this_cpu_add_8(pcp, val)	__this_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# define __this_cpu_add(pcp, val)	__pcpu_size_call(__this_cpu_add_, (pcp), (val))
-#endif
-
-#ifndef __this_cpu_sub
-# define __this_cpu_sub(pcp, val)	__this_cpu_add((pcp), -(val))
-#endif
-
-#ifndef __this_cpu_inc
-# define __this_cpu_inc(pcp)		__this_cpu_add((pcp), 1)
-#endif
-
-#ifndef __this_cpu_dec
-# define __this_cpu_dec(pcp)		__this_cpu_sub((pcp), 1)
-#endif
-
-#ifndef __this_cpu_and
-# ifndef __this_cpu_and_1
-#  define __this_cpu_and_1(pcp, val)	__this_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# ifndef __this_cpu_and_2
-#  define __this_cpu_and_2(pcp, val)	__this_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# ifndef __this_cpu_and_4
-#  define __this_cpu_and_4(pcp, val)	__this_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# ifndef __this_cpu_and_8
-#  define __this_cpu_and_8(pcp, val)	__this_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# define __this_cpu_and(pcp, val)	__pcpu_size_call(__this_cpu_and_, (pcp), (val))
-#endif
-
-#ifndef __this_cpu_or
-# ifndef __this_cpu_or_1
-#  define __this_cpu_or_1(pcp, val)	__this_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# ifndef __this_cpu_or_2
-#  define __this_cpu_or_2(pcp, val)	__this_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# ifndef __this_cpu_or_4
-#  define __this_cpu_or_4(pcp, val)	__this_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# ifndef __this_cpu_or_8
-#  define __this_cpu_or_8(pcp, val)	__this_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# define __this_cpu_or(pcp, val)	__pcpu_size_call(__this_cpu_or_, (pcp), (val))
-#endif
-
-#ifndef __this_cpu_xor
-# ifndef __this_cpu_xor_1
-#  define __this_cpu_xor_1(pcp, val)	__this_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# ifndef __this_cpu_xor_2
-#  define __this_cpu_xor_2(pcp, val)	__this_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# ifndef __this_cpu_xor_4
-#  define __this_cpu_xor_4(pcp, val)	__this_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# ifndef __this_cpu_xor_8
-#  define __this_cpu_xor_8(pcp, val)	__this_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# define __this_cpu_xor(pcp, val)	__pcpu_size_call(__this_cpu_xor_, (pcp), (val))
-#endif
-
-/*
- * IRQ safe versions of the per cpu RMW operations. Note that these operations
- * are *not* safe against modification of the same variable from another
- * processors (which one gets when using regular atomic operations)
- . They are guaranteed to be atomic vs. local interrupts and
- * preemption only.
- */
-#define irqsafe_cpu_generic_to_op(pcp, val, op)				\
-do {									\
-	unsigned long flags;						\
-	local_irq_save(flags);						\
-	*__this_cpu_ptr(&(pcp)) op val;					\
-	local_irq_restore(flags);					\
-} while (0)
-
-#ifndef irqsafe_cpu_add
-# ifndef irqsafe_cpu_add_1
-#  define irqsafe_cpu_add_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# ifndef irqsafe_cpu_add_2
-#  define irqsafe_cpu_add_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# ifndef irqsafe_cpu_add_4
-#  define irqsafe_cpu_add_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# ifndef irqsafe_cpu_add_8
-#  define irqsafe_cpu_add_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
-# endif
-# define irqsafe_cpu_add(pcp, val) __pcpu_size_call(irqsafe_cpu_add_, (pcp), (val))
-#endif
-
-#ifndef irqsafe_cpu_sub
-# define irqsafe_cpu_sub(pcp, val)	irqsafe_cpu_add((pcp), -(val))
-#endif
-
-#ifndef irqsafe_cpu_inc
-# define irqsafe_cpu_inc(pcp)	irqsafe_cpu_add((pcp), 1)
-#endif
-
-#ifndef irqsafe_cpu_dec
-# define irqsafe_cpu_dec(pcp)	irqsafe_cpu_sub((pcp), 1)
-#endif
-
-#ifndef irqsafe_cpu_and
-# ifndef irqsafe_cpu_and_1
-#  define irqsafe_cpu_and_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# ifndef irqsafe_cpu_and_2
-#  define irqsafe_cpu_and_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# ifndef irqsafe_cpu_and_4
-#  define irqsafe_cpu_and_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# ifndef irqsafe_cpu_and_8
-#  define irqsafe_cpu_and_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
-# endif
-# define irqsafe_cpu_and(pcp, val) __pcpu_size_call(irqsafe_cpu_and_, (val))
-#endif
-
-#ifndef irqsafe_cpu_or
-# ifndef irqsafe_cpu_or_1
-#  define irqsafe_cpu_or_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# ifndef irqsafe_cpu_or_2
-#  define irqsafe_cpu_or_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# ifndef irqsafe_cpu_or_4
-#  define irqsafe_cpu_or_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# ifndef irqsafe_cpu_or_8
-#  define irqsafe_cpu_or_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
-# endif
-# define irqsafe_cpu_or(pcp, val) __pcpu_size_call(irqsafe_cpu_or_, (val))
-#endif
-
-#ifndef irqsafe_cpu_xor
-# ifndef irqsafe_cpu_xor_1
-#  define irqsafe_cpu_xor_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# ifndef irqsafe_cpu_xor_2
-#  define irqsafe_cpu_xor_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# ifndef irqsafe_cpu_xor_4
-#  define irqsafe_cpu_xor_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# ifndef irqsafe_cpu_xor_8
-#  define irqsafe_cpu_xor_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
-# endif
-# define irqsafe_cpu_xor(pcp, val) __pcpu_size_call(irqsafe_cpu_xor_, (val))
-#endif
 
 #endif /* __LINUX_PERCPU_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
