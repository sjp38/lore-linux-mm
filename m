Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C230A6B0099
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 11:58:50 -0500 (EST)
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 04 Mar 2010 12:07:02 -0500
Message-Id: <20100304170702.10606.85808.sendpatchset@localhost.localdomain>
In-Reply-To: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
References: <20100304170654.10606.32225.sendpatchset@localhost.localdomain>
Subject: [PATCH/RFC 1/8] numa: prep:  move generic percpu interface definitions to percpu-defs.h
Sender: owner-linux-mm@kvack.org
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-numa@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

PATCH:  numa - prep:  move generic percpu interface definitions to percpu-defs.h

Against:  2.6.33-mmotm-100302-1838

To use the generic percpu infrastructure for the numa_node_id() interface,
defined in linux/topology.h, we need to break the circular header dependency
that results from including <linux/percpu.h> in <linux/topology.h>.  The
circular dependency:

	percpu.h -> slab.h -> gfp.h -> topology.h

percpu.h includes slab.h to obtain the definition of kzalloc()/kfree() for
inlining __alloc_percpu() and free_percpu() in !SMP configurations.  One could
un-inline these functions in the !SMP case, but a large number of files depend
on percpu.h to include slab.h.  Tejun Heo suggested moving the definitions to
percpu-defs.h and requested that this be separated from the remainder of the
generic percpu numa_node_id() preparation patch.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/percpu-defs.h |  455 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/percpu.h      |  454 -------------------------------------------
 2 files changed, 455 insertions(+), 454 deletions(-)

Index: linux-2.6.33-mmotm-100302-1838/include/linux/percpu-defs.h
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/include/linux/percpu-defs.h
+++ linux-2.6.33-mmotm-100302-1838/include/linux/percpu-defs.h
@@ -151,4 +151,459 @@
 #define EXPORT_PER_CPU_SYMBOL_GPL(var)
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
 #endif /* _LINUX_PERCPU_DEFS_H */
Index: linux-2.6.33-mmotm-100302-1838/include/linux/percpu.h
===================================================================
--- linux-2.6.33-mmotm-100302-1838.orig/include/linux/percpu.h
+++ linux-2.6.33-mmotm-100302-1838/include/linux/percpu.h
@@ -180,459 +180,5 @@ static inline void *pcpu_lpage_remapped(
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
