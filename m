Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6AE026B005A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 16:57:14 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 591C882C53D
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 17:15:18 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id eXX3loW3598Z for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 17:15:12 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 40BC482C335
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 17:15:12 -0400 (EDT)
Message-Id: <20090617203443.173725344@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:39 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 02/19] Introduce this_cpu_ptr() and generic this_cpu_* operations
Content-Disposition: inline; filename=this_cpu_ptr_intro
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>, Eric Dumazet <dada1@cosmosbay.com>, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

this_cpu_ptr
------------

this_cpu_ptr(xx) = per_cpu_ptr(xx, smp_processor_id).

The problem with per_cpu_ptr(x, smp_processor_id) is that it requires
an array lookup to find the offset for the cpu. Processors typically
have the offset for the current cpu area in some kind of (arch dependent)
efficiently accessible register or memory location.

We can use that instead of doing the array lookup to speed up the
determination of the addressof the percpu variable. This is particularly
significant because these lookups occur in performance critical paths
of the core kernel.

this_cpu_ptr comes in two flavors. The preemption context matters since we
are referring the the currently executing processor. In many cases we must
insure that the processor does not change while a code segment is executed.

__this_cpu_ptr 	-> Do not check for preemption context
this_cpu_ptr	-> Check preemption context

Generic this_cpu_* operations
-----------------------------

this_cpu_* operations operate on scalars that are members of structures
allocated with the new per cpu allocator. They can also operate on
static per_cpu variables if the address of those is determined with
per_cpu_var().

Generic functions that are used if an arch does not define optimized
this_cpu operations. The functions come also come in the two favors. The first
parameter is a scalar that is a member of a structure allocated through
allocpercpu or by taking the address of a per cpu variable.

The operations are guaranteed to be atomic vs preemption if they modify
the scalar (unless they are prefixed by __ in which case they do not need
to be). The calculation of the per cpu offset is also guaranteed to be atomic
in the same way.

this_cpu_read(scalar)
this_cpu_write(scalar, value)
this_cpu_add(scale, value)
this_cpu_sub(scalar, value)
this_cpu_inc(scalar)
this_cpu_dec(scalar)
this_cpu_and(scalar, value)
this_cpu_or(scalar, value)
this_cpu_xor(scalar, value)

Arche code can override the generic functions and provide optimized atomic
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
 include/asm-generic/percpu.h |    5 +
 include/linux/percpu.h       |  159 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 164 insertions(+)

Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2009-06-17 11:47:17.000000000 -0500
+++ linux-2.6/include/linux/percpu.h	2009-06-17 13:59:19.000000000 -0500
@@ -181,4 +181,163 @@ do {									\
 # define percpu_xor(var, val)		__percpu_generic_to_op(var, (val), ^=)
 #endif
 
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
+ */
+#ifndef this_cpu_read
+# define this_cpu_read(pcp)						\
+  ({									\
+	*this_cpu_ptr(&(pcp));						\
+  })
+#endif
+
+#define _this_cpu_generic_to_op(pcp, val, op)				\
+do {									\
+	preempt_disable();						\
+	*__this_cpu_ptr(&pcp) op val;					\
+	preempt_enable_no_resched();					\
+} while (0)
+
+#ifndef this_cpu_write
+# define this_cpu_write(pcp, val)	_this_cpu_generic_to_op((pcp), (val), =)
+#endif
+
+#ifndef this_cpu_add
+# define this_cpu_add(pcp, val)		_this_cpu_generic_to_op((pcp), (val), +=)
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
+# define this_cpu_and(pcp, val)		_this_cpu_generic_to_op((pcp), (val), &=)
+#endif
+
+#ifndef this_cpu_or
+# define this_cpu_or(pcp, val)		_this_cpu_generic_to_op((pcp), (val), |=)
+#endif
+
+#ifndef this_cpu_xor
+# define this_cpu_xor(pcp, val)		_this_cpu_generic_to_op((pcp), (val), ^=)
+#endif
+
+
+/*
+ * Generic percpu operations that do not require preemption handling.
+ * Either we do not care about races or the caller has the
+ * responsibility of handling preemptions issues.
+ *
+ * If there is no other protection through preempt disable and/or
+ * disabling interupts then one of these RMW operations can show unexpected
+ * behavior because the execution thread was rescheduled on another processor
+ * or an interrupt occurred and the same percpu variable was modified from
+ * the interrupt context.
+ */
+#ifndef __this_cpu_read
+# define __this_cpu_read(pcp)						\
+  ({									\
+	*__this_cpu_ptr(&(pcp));					\
+  })
+#endif
+
+#define __this_cpu_generic_to_op(pcp, val, op)				\
+do {									\
+	*__this_cpu_ptr(&(pcp)) op val;					\
+} while (0)
+
+#ifndef __this_cpu_write
+# define __this_cpu_write(pcp, val)	__this_cpu_generic_to_op((pcp), (val), =)
+#endif
+
+#ifndef __this_cpu_add
+# define __this_cpu_add(pcp, val)	__this_cpu_generic_to_op((pcp), (val), +=)
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
+# define __this_cpu_and(pcp, val)	__this_cpu_generic_to_op((pcp), (val), &=)
+#endif
+
+#ifndef __this_cpu_or
+# define __this_cpu_or(pcp, val)	__this_cpu_generic_to_op((pcp), (val), |=)
+#endif
+
+#ifndef __this_cpu_xor
+# define __this_cpu_xor(pcp, val)	__this_cpu_generic_to_op((pcp), (val), ^=)
+#endif
+
+/*
+ * IRQ safe versions of the per cpu RMW operations. Note that these operations
+ * are *not* safe against modification of the same variable from another
+ * processors. They are guaranteed to be atomic vs. local interrupts and
+ * preemption.
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
+# define irqsafe_this_cpu_add(pcp, val)	irqsafe_cpu_generic_to_op((pcp), (val), +=)
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
+# define irqsafe_this_cpu_and(pcp, val)	irqsafe_cpu_generic_to_op((pcp), (val), &=)
+#endif
+
+#ifndef irqsafe_this_cpu_or
+# define irqsafe_this_cpu_or(pcp, val)	irqsafe_cpu_generic_to_op((pcp), (val), |=)
+#endif
+
+#ifndef irqsafe_this_cpu_xor
+# define irqsafe_this_cpu_xor(pcp, val)	irqsafe_cpu_generic_to_op((pcp), (val), ^=)
+#endif
+
 #endif /* __LINUX_PERCPU_H */
Index: linux-2.6/include/asm-generic/percpu.h
===================================================================
--- linux-2.6.orig/include/asm-generic/percpu.h	2009-06-17 11:47:17.000000000 -0500
+++ linux-2.6/include/asm-generic/percpu.h	2009-06-17 13:41:40.000000000 -0500
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
