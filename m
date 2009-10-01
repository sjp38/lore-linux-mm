Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 886E06B00A5
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 17:03:20 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8DCC882C702
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 17:06:46 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 72x3Ucv2zdSf for <linux-mm@kvack.org>;
	Thu,  1 Oct 2009 17:06:46 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 11BAA82C799
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 17:06:27 -0400 (EDT)
Message-Id: <20091001174119.735693166@gentwo.org>
References: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:34 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 01/19] Introduce this_cpu_ptr() and generic this_cpu_* operations
Content-Disposition: inline; filename=this_cpu_ptr_intro
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>, Eric Dumazet <dada1@cosmosbay.com>, davem@davemloft.net, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

This patch introduces two things: First this_cpu_ptr and then per cpu
atomic operations.

this_cpu_ptr
------------

A common operation when dealing with cpu data is to get the instance of the
cpu data associated with the currently executing processor. This can be
optimized by

this_cpu_ptr(xx) = per_cpu_ptr(xx, smp_processor_id).

The problem with per_cpu_ptr(x, smp_processor_id) is that it requires
an array lookup to find the offset for the cpu. Processors typically
have the offset for the current cpu area in some kind of (arch dependent)
efficiently accessible register or memory location.

We can use that instead of doing the array lookup to speed up the
determination of the address of the percpu variable. This is particularly
significant because these lookups occur in performance critical paths
of the core kernel. this_cpu_ptr() can avoid memory accesses and

this_cpu_ptr comes in two flavors. The preemption context matters since we
are referring the the currently executing processor. In many cases we must
insure that the processor does not change while a code segment is executed.

__this_cpu_ptr 	-> Do not check for preemption context
this_cpu_ptr	-> Check preemption context

The parameter to these operations is a per cpu pointer. This can be the
address of a statically defined per cpu variable (&per_cpu_var(xxx)) or
the address of a per cpu variable allocated with the per cpu allocator.

per cpu atomic operations: this_cpu_*(var, val)
-----------------------------------------------
this_cpu_* operations (like this_cpu_add(struct->y, value) operate on
abitrary scalars that are members of structures allocated with the new
per cpu allocator. They can also operate on static per_cpu variables
if they are passed to per_cpu_var() (See patch to use this_cpu_*
operations for vm statistics).

These operations are guaranteed to be atomic vs preemption when modifying
the scalar. The calculation of the per cpu offset is also guaranteed to
be atomic at the same time. This means that a this_cpu_* operation can be
safely used to modify a per cpu variable in a context where interrupts are
enabled and preemption is allowed. Many architectures can perform such
a per cpu atomic operation with a single instruction.

Note that the atomicity here is different from regular atomic operations.
Atomicity is only guaranteed for data accessed from the currently executing
processor. Modifications from other processors are still possible. There
must be other guarantees that the per cpu data is not modified from another
processor when using these instruction. The per cpu atomicity is created
by the fact that the processor either executes and instruction or not.
Embedded in the instruction is the relocation of the per cpu address to
the are reserved for the current processor and the RMW action. Therefore
interrupts or preemption cannot occur in the mids of this processing.

Generic fallback functions are used if an arch does not define optimized
this_cpu operations. The functions come also come in the two flavors used
for this_cpu_ptr().

The firstparameter is a scalar that is a member of a structure allocated
through allocpercpu or a per cpu variable (use per_cpu_var(xxx)). The
operations are similar to what percpu_add() and friends do.

this_cpu_read(scalar)
this_cpu_write(scalar, value)
this_cpu_add(scale, value)
this_cpu_sub(scalar, value)
this_cpu_inc(scalar)
this_cpu_dec(scalar)
this_cpu_and(scalar, value)
this_cpu_or(scalar, value)
this_cpu_xor(scalar, value)

Arch code can override the generic functions and provide optimized atomic
per cpu operations. These atomic operations must provide both the relocation
(x86 does it through a segment override) and the operation on the data in a
single instruction. Otherwise preempt needs to be disabled and there is no
gain from providing arch implementations.

A third variant is provided prefixed by irqsafe_. These variants are safe
against hardware interrupts on the *same* processor (all per cpu atomic
primitives are *always* *only* providing safety for code running on the
*same* processor!). The increment needs to be implemented by the hardware
in such a way that it is a single RMW instruction that is either processed
before or after an interrupt.

cc: David Howells <dhowells@redhat.com>
cc: Tejun Heo <tj@kernel.org>
cc: Ingo Molnar <mingo@elte.hu>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/asm-generic/percpu.h |    5 
 include/linux/percpu.h       |  400 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 405 insertions(+)

Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2009-10-01 10:56:26.000000000 -0500
+++ linux-2.6/include/linux/percpu.h	2009-10-01 10:57:13.000000000 -0500
@@ -243,4 +243,404 @@ do {									\
 # define percpu_xor(var, val)		__percpu_generic_to_op(var, (val), ^=)
 #endif
 
+/*
+ * Branching function to split up a function into a set of functions that
+ * are called for different scalar sizes of the objects handled.
+ */
+
+extern void __bad_size_call_parameter(void);
+
+#define __size_call_return(stem, variable)				\
+({	typeof(variable) ret__;						\
+	switch(sizeof(variable)) {					\
+	case 1: ret__ = stem##1(variable);break;			\
+	case 2: ret__ = stem##2(variable);break;			\
+	case 4: ret__ = stem##4(variable);break;			\
+	case 8: ret__ = stem##8(variable);break;			\
+	default:							\
+		__bad_size_call_parameter();break;			\
+	}								\
+	ret__;								\
+})
+
+#define __size_call(stem, variable, ...)				\
+do {									\
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
+ * allocator or for addresses of per cpu variables (can be determined
+ * using per_cpu_var(xx).
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
+	ret__ = *this_cpu_ptr(&(pcp);					\
+	preempt_enable());						\
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
+# define this_cpu_read(pcp)	__size_call_return(this_cpu_read_, (pcp))
+#endif
+
+#define _this_cpu_generic_to_op(pcp, val, op)				\
+do {									\
+	preempt_disable();						\
+	*__this_cpu_ptr(&pcp) op val;					\
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
+# define this_cpu_write(pcp, val)	__size_call(this_cpu_write_, (pcp), (val))
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
+# define this_cpu_add(pcp, val)		__size_call(this_cpu_add_, (pcp), (val))
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
+# define this_cpu_and(pcp, val)		__size_call(this_cpu_and_, (pcp), (val))
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
+# define this_cpu_or(pcp, val)		__size_call(this_cpu_or_, (pcp), (val))
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
+# define this_cpu_xor(pcp, val)		__size_call(this_cpu_or_, (pcp), (val))
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
+# define __this_cpu_read(pcp)	__size_call_return(__this_cpu_read_, (pcp))
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
+# define __this_cpu_write(pcp, val)	__size_call(__this_cpu_write_, (pcp), (val))
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
+# define __this_cpu_add(pcp, val)	__size_call(__this_cpu_add_, (pcp), (val))
+#endif
+
+#ifndef __this_cpu_sub
+# define __this_cpu_sub(pcp, val)	__this_cpu_add((pcp), -(var))
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
+# define __this_cpu_and(pcp, val)	__size_call(__this_cpu_and_, (pcp), (val))
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
+# define __this_cpu_or(pcp, val)	__size_call(__this_cpu_or_, (pcp), (val))
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
+# define __this_cpu_xor(pcp, val)	__size_call(__this_cpu_xor_, (pcp), (val))
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
+	local_irqsave(flags);						\
+	*__this_cpu_ptr(&(pcp)) op val;					\
+	local_irqrestore(flags);					\
+} while (0)
+
+#ifndef irqsafe_this_cpu_add
+# ifndef irqsafe_this_cpu_add_1
+#  define irqsafe_this_cpu_add_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef irqsafe_this_cpu_add_2
+#  define irqsafe_this_cpu_add_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef irqsafe_this_cpu_add_4
+#  define irqsafe_this_cpu_add_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# ifndef irqsafe_this_cpu_add_8
+#  define irqsafe_this_cpu_add_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), +=)
+# endif
+# define irqsafe_this_cpu_add(pcp, val) __size_call(irqsafe_this_cpu_add_, (val))
+#endif
+
+#ifndef irqsafe_this_cpu_sub
+# define irqsafe_this_cpu_sub(pcp, val)	irqsafe_cpu_add((pcp), -(var))
+#endif
+
+#ifndef irqsafe_this_cpu_inc
+# define irqsafe_this_cpu_inc(pcp)	irqsafe_cpu_add((pcp), 1)
+#endif
+
+#ifndef irqsafe_this_cpu_dec
+# define irqsafe_this_cpu_dec(pcp)	irqsafe_cpu_sub((pcp), 1)
+#endif
+
+#ifndef irqsafe_this_cpu_and
+# ifndef irqsafe_this_cpu_and_1
+#  define irqsafe_this_cpu_and_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef irqsafe_this_cpu_and_2
+#  define irqsafe_this_cpu_and_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef irqsafe_this_cpu_and_4
+#  define irqsafe_this_cpu_and_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# ifndef irqsafe_this_cpu_and_8
+#  define irqsafe_this_cpu_and_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), &=)
+# endif
+# define irqsafe_this_cpu_and(pcp, val) __size_call(irqsafe_this_cpu_and_, (val))
+#endif
+
+#ifndef irqsafe_this_cpu_or
+# ifndef irqsafe_this_cpu_or_1
+#  define irqsafe_this_cpu_or_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef irqsafe_this_cpu_or_2
+#  define irqsafe_this_cpu_or_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef irqsafe_this_cpu_or_4
+#  define irqsafe_this_cpu_or_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# ifndef irqsafe_this_cpu_or_8
+#  define irqsafe_this_cpu_or_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), |=)
+# endif
+# define irqsafe_this_cpu_or(pcp, val) __size_call(irqsafe_this_cpu_or_, (val))
+#endif
+
+#ifndef irqsafe_this_cpu_xor
+# ifndef irqsafe_this_cpu_xor_1
+#  define irqsafe_this_cpu_xor_1(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef irqsafe_this_cpu_xor_2
+#  define irqsafe_this_cpu_xor_2(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef irqsafe_this_cpu_xor_4
+#  define irqsafe_this_cpu_xor_4(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# ifndef irqsafe_this_cpu_xor_8
+#  define irqsafe_this_cpu_xor_8(pcp, val) irqsafe_cpu_generic_to_op((pcp), (val), ^=)
+# endif
+# define irqsafe_this_cpu_xor(pcp, val) __size_call(irqsafe_this_cpu_xor_, (val))
+#endif
+
 #endif /* __LINUX_PERCPU_H */
Index: linux-2.6/include/asm-generic/percpu.h
===================================================================
--- linux-2.6.orig/include/asm-generic/percpu.h	2009-10-01 10:56:26.000000000 -0500
+++ linux-2.6/include/asm-generic/percpu.h	2009-10-01 10:56:36.000000000 -0500
@@ -56,6 +56,9 @@ extern unsigned long __per_cpu_offset[NR
 #define __raw_get_cpu_var(var) \
 	(*SHIFT_PERCPU_PTR(&per_cpu_var(var), __my_cpu_offset))
 
+#define this_cpu_ptr(ptr) SHIFT_PERCPU_PTR(ptr, my_cpu_offset)
+#define __this_cpu_ptr(ptr) SHIFT_PERCPU_PTR(ptr, __my_cpu_offset)
+
 
 #ifdef CONFIG_HAVE_SETUP_PER_CPU_AREA
 extern void setup_per_cpu_areas(void);
@@ -66,6 +69,8 @@ extern void setup_per_cpu_areas(void);
 #define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu_var(var)))
 #define __get_cpu_var(var)			per_cpu_var(var)
 #define __raw_get_cpu_var(var)			per_cpu_var(var)
+#define this_cpu_ptr(ptr) per_cpu_ptr(ptr, 0)
+#define __this_cpu_ptr(ptr) this_cpu_ptr(ptr)
 
 #endif	/* SMP */
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
