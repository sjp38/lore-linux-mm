Message-Id: <20071030192107.091973012@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:14 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 17/28] local_t m32r use architecture specific cmpxchg_local
Content-Disposition: inline; filename=local_t_m32r_optimized.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, Hirokazu Takata <takata@linux-m32r.org>, linux-m32r@ml.linux-m32r.org
List-ID: <linux-mm.kvack.org>

On m32r, use the new cmpxchg_local as primitive for the local_cmpxchg
operation.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Acked-by: Hirokazu Takata <takata@linux-m32r.org>
CC: linux-m32r@ml.linux-m32r.org
---
 include/asm-m32r/local.h |  362 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 361 insertions(+), 1 deletion(-)

Index: linux-2.6-lttng/include/asm-m32r/local.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-m32r/local.h	2007-07-20 17:29:08.000000000 -0400
+++ linux-2.6-lttng/include/asm-m32r/local.h	2007-07-20 17:43:28.000000000 -0400
@@ -1,6 +1,366 @@
 #ifndef __M32R_LOCAL_H
 #define __M32R_LOCAL_H
 
-#include <asm-generic/local.h>
+/*
+ *  linux/include/asm-m32r/local.h
+ *
+ *  M32R version:
+ *    Copyright (C) 2001, 2002  Hitoshi Yamamoto
+ *    Copyright (C) 2004  Hirokazu Takata <takata at linux-m32r.org>
+ *    Copyright (C) 2007  Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
+ */
+
+#include <linux/percpu.h>
+#include <asm/assembler.h>
+#include <asm/system.h>
+#include <asm/local.h>
+
+/*
+ * Atomic operations that C can't guarantee us.  Useful for
+ * resource counting etc..
+ */
+
+/*
+ * Make sure gcc doesn't try to be clever and move things around
+ * on us. We need to use _exactly_ the address the user gave us,
+ * not some alias that contains the same information.
+ */
+typedef struct { volatile int counter; } local_t;
+
+#define LOCAL_INIT(i)	{ (i) }
+
+/**
+ * local_read - read local variable
+ * @l: pointer of type local_t
+ *
+ * Atomically reads the value of @l.
+ */
+#define local_read(l)	((l)->counter)
+
+/**
+ * local_set - set local variable
+ * @l: pointer of type local_t
+ * @i: required value
+ *
+ * Atomically sets the value of @l to @i.
+ */
+#define local_set(l,i)	(((l)->counter) = (i))
+
+/**
+ * local_add_return - add long to local variable and return it
+ * @i: long value to add
+ * @l: pointer of type local_t
+ *
+ * Atomically adds @i to @l and return (@i + @l).
+ */
+static __inline__ long local_add_return(long i, local_t *l)
+{
+	unsigned long flags;
+	long result;
+
+	local_irq_save(flags);
+	__asm__ __volatile__ (
+		"# local_add_return		\n\t"
+		DCACHE_CLEAR("%0", "r4", "%1")
+		"ld %0, @%1;			\n\t"
+		"add	%0, %2;			\n\t"
+		"st %0, @%1;			\n\t"
+		: "=&r" (result)
+		: "r" (&l->counter), "r" (i)
+		: "memory"
+#ifdef CONFIG_CHIP_M32700_TS1
+		, "r4"
+#endif	/* CONFIG_CHIP_M32700_TS1 */
+	);
+	local_irq_restore(flags);
+
+	return result;
+}
+
+/**
+ * local_sub_return - subtract long from local variable and return it
+ * @i: long value to subtract
+ * @l: pointer of type local_t
+ *
+ * Atomically subtracts @i from @l and return (@l - @i).
+ */
+static __inline__ long local_sub_return(long i, local_t *l)
+{
+	unsigned long flags;
+	long result;
+
+	local_irq_save(flags);
+	__asm__ __volatile__ (
+		"# local_sub_return		\n\t"
+		DCACHE_CLEAR("%0", "r4", "%1")
+		"ld %0, @%1;			\n\t"
+		"sub	%0, %2;			\n\t"
+		"st %0, @%1;			\n\t"
+		: "=&r" (result)
+		: "r" (&l->counter), "r" (i)
+		: "memory"
+#ifdef CONFIG_CHIP_M32700_TS1
+		, "r4"
+#endif	/* CONFIG_CHIP_M32700_TS1 */
+	);
+	local_irq_restore(flags);
+
+	return result;
+}
+
+/**
+ * local_add - add long to local variable
+ * @i: long value to add
+ * @l: pointer of type local_t
+ *
+ * Atomically adds @i to @l.
+ */
+#define local_add(i,l) ((void) local_add_return((i), (l)))
+
+/**
+ * local_sub - subtract the local variable
+ * @i: long value to subtract
+ * @l: pointer of type local_t
+ *
+ * Atomically subtracts @i from @l.
+ */
+#define local_sub(i,l) ((void) local_sub_return((i), (l)))
+
+/**
+ * local_sub_and_test - subtract value from variable and test result
+ * @i: integer value to subtract
+ * @l: pointer of type local_t
+ *
+ * Atomically subtracts @i from @l and returns
+ * true if the result is zero, or false for all
+ * other cases.
+ */
+#define local_sub_and_test(i,l) (local_sub_return((i), (l)) == 0)
+
+/**
+ * local_inc_return - increment local variable and return it
+ * @l: pointer of type local_t
+ *
+ * Atomically increments @l by 1 and returns the result.
+ */
+static __inline__ long local_inc_return(local_t *l)
+{
+	unsigned long flags;
+	long result;
+
+	local_irq_save(flags);
+	__asm__ __volatile__ (
+		"# local_inc_return		\n\t"
+		DCACHE_CLEAR("%0", "r4", "%1")
+		"ld %0, @%1;			\n\t"
+		"addi	%0, #1;			\n\t"
+		"st %0, @%1;			\n\t"
+		: "=&r" (result)
+		: "r" (&l->counter)
+		: "memory"
+#ifdef CONFIG_CHIP_M32700_TS1
+		, "r4"
+#endif	/* CONFIG_CHIP_M32700_TS1 */
+	);
+	local_irq_restore(flags);
+
+	return result;
+}
+
+/**
+ * local_dec_return - decrement local variable and return it
+ * @l: pointer of type local_t
+ *
+ * Atomically decrements @l by 1 and returns the result.
+ */
+static __inline__ long local_dec_return(local_t *l)
+{
+	unsigned long flags;
+	long result;
+
+	local_irq_save(flags);
+	__asm__ __volatile__ (
+		"# local_dec_return		\n\t"
+		DCACHE_CLEAR("%0", "r4", "%1")
+		"ld %0, @%1;			\n\t"
+		"addi	%0, #-1;		\n\t"
+		"st %0, @%1;			\n\t"
+		: "=&r" (result)
+		: "r" (&l->counter)
+		: "memory"
+#ifdef CONFIG_CHIP_M32700_TS1
+		, "r4"
+#endif	/* CONFIG_CHIP_M32700_TS1 */
+	);
+	local_irq_restore(flags);
+
+	return result;
+}
+
+/**
+ * local_inc - increment local variable
+ * @l: pointer of type local_t
+ *
+ * Atomically increments @l by 1.
+ */
+#define local_inc(l) ((void)local_inc_return(l))
+
+/**
+ * local_dec - decrement local variable
+ * @l: pointer of type local_t
+ *
+ * Atomically decrements @l by 1.
+ */
+#define local_dec(l) ((void)local_dec_return(l))
+
+/**
+ * local_inc_and_test - increment and test
+ * @l: pointer of type local_t
+ *
+ * Atomically increments @l by 1
+ * and returns true if the result is zero, or false for all
+ * other cases.
+ */
+#define local_inc_and_test(l) (local_inc_return(l) == 0)
+
+/**
+ * local_dec_and_test - decrement and test
+ * @l: pointer of type local_t
+ *
+ * Atomically decrements @l by 1 and
+ * returns true if the result is 0, or false for all
+ * other cases.
+ */
+#define local_dec_and_test(l) (local_dec_return(l) == 0)
+
+/**
+ * local_add_negative - add and test if negative
+ * @l: pointer of type local_t
+ * @i: integer value to add
+ *
+ * Atomically adds @i to @l and returns true
+ * if the result is negative, or false when
+ * result is greater than or equal to zero.
+ */
+#define local_add_negative(i,l) (local_add_return((i), (l)) < 0)
+
+#define local_cmpxchg(l, o, n) (cmpxchg_local(&((l)->counter), (o), (n)))
+#define local_xchg(v, new) (xchg_local(&((l)->counter), new))
+
+/**
+ * local_add_unless - add unless the number is a given value
+ * @l: pointer of type local_t
+ * @a: the amount to add to l...
+ * @u: ...unless l is equal to u.
+ *
+ * Atomically adds @a to @l, so long as it was not @u.
+ * Returns non-zero if @l was not @u, and zero otherwise.
+ */
+static __inline__ int local_add_unless(local_t *l, long a, long u)
+{
+	long c, old;
+	c = local_read(l);
+	for (;;) {
+		if (unlikely(c == (u)))
+			break;
+		old = local_cmpxchg((l), c, c + (a));
+		if (likely(old == c))
+			break;
+		c = old;
+	}
+	return c != (u);
+}
+
+#define local_inc_not_zero(l) local_add_unless((l), 1, 0)
+
+static __inline__ void local_clear_mask(unsigned long  mask, local_t *addr)
+{
+	unsigned long flags;
+	unsigned long tmp;
+
+	local_irq_save(flags);
+	__asm__ __volatile__ (
+		"# local_clear_mask		\n\t"
+		DCACHE_CLEAR("%0", "r5", "%1")
+		"ld %0, @%1;			\n\t"
+		"and	%0, %2;			\n\t"
+		"st %0, @%1;			\n\t"
+		: "=&r" (tmp)
+		: "r" (addr), "r" (~mask)
+		: "memory"
+#ifdef CONFIG_CHIP_M32700_TS1
+		, "r5"
+#endif	/* CONFIG_CHIP_M32700_TS1 */
+	);
+	local_irq_restore(flags);
+}
+
+static __inline__ void local_set_mask(unsigned long  mask, local_t *addr)
+{
+	unsigned long flags;
+	unsigned long tmp;
+
+	local_irq_save(flags);
+	__asm__ __volatile__ (
+		"# local_set_mask		\n\t"
+		DCACHE_CLEAR("%0", "r5", "%1")
+		"ld %0, @%1;			\n\t"
+		"or	%0, %2;			\n\t"
+		"st %0, @%1;			\n\t"
+		: "=&r" (tmp)
+		: "r" (addr), "r" (mask)
+		: "memory"
+#ifdef CONFIG_CHIP_M32700_TS1
+		, "r5"
+#endif	/* CONFIG_CHIP_M32700_TS1 */
+	);
+	local_irq_restore(flags);
+}
+
+/* Atomic operations are already serializing on m32r */
+#define smp_mb__before_local_dec()	barrier()
+#define smp_mb__after_local_dec()	barrier()
+#define smp_mb__before_local_inc()	barrier()
+#define smp_mb__after_local_inc()	barrier()
+
+/* Use these for per-cpu local_t variables: on some archs they are
+ * much more efficient than these naive implementations.  Note they take
+ * a variable, not an address.
+ */
+
+#define __local_inc(l)		((l)->a.counter++)
+#define __local_dec(l)		((l)->a.counter++)
+#define __local_add(i,l)	((l)->a.counter+=(i))
+#define __local_sub(i,l)	((l)->a.counter-=(i))
+
+/* Use these for per-cpu local_t variables: on some archs they are
+ * much more efficient than these naive implementations.  Note they take
+ * a variable, not an address.
+ */
+
+/* Need to disable preemption for the cpu local counters otherwise we could
+   still access a variable of a previous CPU in a non local way. */
+#define cpu_local_wrap_v(l)	 	\
+	({ local_t res__;		\
+	   preempt_disable(); 		\
+	   res__ = (l);			\
+	   preempt_enable();		\
+	   res__; })
+#define cpu_local_wrap(l)		\
+	({ preempt_disable();		\
+	   l;				\
+	   preempt_enable(); })		\
+
+#define cpu_local_read(l)    cpu_local_wrap_v(local_read(&__get_cpu_var(l)))
+#define cpu_local_set(l, i)  cpu_local_wrap(local_set(&__get_cpu_var(l), (i)))
+#define cpu_local_inc(l)     cpu_local_wrap(local_inc(&__get_cpu_var(l)))
+#define cpu_local_dec(l)     cpu_local_wrap(local_dec(&__get_cpu_var(l)))
+#define cpu_local_add(i, l)  cpu_local_wrap(local_add((i), &__get_cpu_var(l)))
+#define cpu_local_sub(i, l)  cpu_local_wrap(local_sub((i), &__get_cpu_var(l)))
+
+#define __cpu_local_inc(l)	cpu_local_inc(l)
+#define __cpu_local_dec(l)	cpu_local_dec(l)
+#define __cpu_local_add(i, l)	cpu_local_add((i), (l))
+#define __cpu_local_sub(i, l)	cpu_local_sub((i), (l))
 
 #endif /* __M32R_LOCAL_H */

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
