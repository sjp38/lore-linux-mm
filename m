Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 73E5E6B02C3
	for <linux-mm@kvack.org>; Fri, 26 May 2017 15:10:18 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 204so4780309wmy.1
        for <linux-mm@kvack.org>; Fri, 26 May 2017 12:10:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w30sor9326wra.40.2017.05.26.12.10.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 May 2017 12:10:16 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v2 2/7] x86: use long long for 64-bit atomic ops
Date: Fri, 26 May 2017 21:09:04 +0200
Message-Id: <3758f3da9de01b1a082c4e1f44ba3b48f7a840ea.1495825151.git.dvyukov@google.com>
In-Reply-To: <cover.1495825151.git.dvyukov@google.com>
References: <cover.1495825151.git.dvyukov@google.com>
In-Reply-To: <cover.1495825151.git.dvyukov@google.com>
References: <cover.1495825151.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com
Cc: akpm@linux-foundation.org, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, tglx@linutronix.de, hpa@zytor.com, willy@infradead.org, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org

Some 64-bit atomic operations use 'long long' as operand/return type
(e.g. asm-generic/atomic64.h, arch/x86/include/asm/atomic64_32.h);
while others use 'long' (e.g. arch/x86/include/asm/atomic64_64.h).
This makes it impossible to write portable code.
For example, there is no format specifier that prints result of
atomic64_read() without warnings. atomic64_try_cmpxchg() is almost
impossible to use in portable fashion because it requires either
'long *' or 'long long *' as argument depending on arch.

Switch arch/x86/include/asm/atomic64_64.h to 'long long'.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: x86@kernel.org

---
Changes since v1:
 - reverted stray s/long/long long/ replace in comment
 - added arch/s390 changes to fix build errors/warnings
---
 arch/s390/include/asm/atomic_ops.h | 14 +++++-----
 arch/s390/include/asm/bitops.h     | 12 ++++-----
 arch/x86/include/asm/atomic64_64.h | 52 +++++++++++++++++++-------------------
 include/linux/types.h              |  2 +-
 4 files changed, 40 insertions(+), 40 deletions(-)

diff --git a/arch/s390/include/asm/atomic_ops.h b/arch/s390/include/asm/atomic_ops.h
index ac9e2b939d04..055a9083e52d 100644
--- a/arch/s390/include/asm/atomic_ops.h
+++ b/arch/s390/include/asm/atomic_ops.h
@@ -31,10 +31,10 @@ __ATOMIC_OPS(__atomic_and, int, "lan")
 __ATOMIC_OPS(__atomic_or,  int, "lao")
 __ATOMIC_OPS(__atomic_xor, int, "lax")
 
-__ATOMIC_OPS(__atomic64_add, long, "laag")
-__ATOMIC_OPS(__atomic64_and, long, "lang")
-__ATOMIC_OPS(__atomic64_or,  long, "laog")
-__ATOMIC_OPS(__atomic64_xor, long, "laxg")
+__ATOMIC_OPS(__atomic64_add, long long, "laag")
+__ATOMIC_OPS(__atomic64_and, long long, "lang")
+__ATOMIC_OPS(__atomic64_or,  long long, "laog")
+__ATOMIC_OPS(__atomic64_xor, long long, "laxg")
 
 #undef __ATOMIC_OPS
 #undef __ATOMIC_OP
@@ -46,7 +46,7 @@ static inline void __atomic_add_const(int val, int *ptr)
 		: [ptr] "+Q" (*ptr) : [val] "i" (val) : "cc");
 }
 
-static inline void __atomic64_add_const(long val, long *ptr)
+static inline void __atomic64_add_const(long val, long long *ptr)
 {
 	asm volatile(
 		"	agsi	%[ptr],%[val]\n"
@@ -82,7 +82,7 @@ __ATOMIC_OPS(__atomic_xor, "xr")
 #undef __ATOMIC_OPS
 
 #define __ATOMIC64_OP(op_name, op_string)				\
-static inline long op_name(long val, long *ptr)				\
+static inline long op_name(long val, long long *ptr)			\
 {									\
 	long old, new;							\
 									\
@@ -118,7 +118,7 @@ static inline int __atomic_cmpxchg(int *ptr, int old, int new)
 	return old;
 }
 
-static inline long __atomic64_cmpxchg(long *ptr, long old, long new)
+static inline long __atomic64_cmpxchg(long long *ptr, long old, long new)
 {
 	asm volatile(
 		"	csg	%[old],%[new],%[ptr]"
diff --git a/arch/s390/include/asm/bitops.h b/arch/s390/include/asm/bitops.h
index d92047da5ccb..8912f52bca5d 100644
--- a/arch/s390/include/asm/bitops.h
+++ b/arch/s390/include/asm/bitops.h
@@ -80,7 +80,7 @@ static inline void set_bit(unsigned long nr, volatile unsigned long *ptr)
 	}
 #endif
 	mask = 1UL << (nr & (BITS_PER_LONG - 1));
-	__atomic64_or(mask, addr);
+	__atomic64_or(mask, (long long *)addr);
 }
 
 static inline void clear_bit(unsigned long nr, volatile unsigned long *ptr)
@@ -101,7 +101,7 @@ static inline void clear_bit(unsigned long nr, volatile unsigned long *ptr)
 	}
 #endif
 	mask = ~(1UL << (nr & (BITS_PER_LONG - 1)));
-	__atomic64_and(mask, addr);
+	__atomic64_and(mask, (long long *)addr);
 }
 
 static inline void change_bit(unsigned long nr, volatile unsigned long *ptr)
@@ -122,7 +122,7 @@ static inline void change_bit(unsigned long nr, volatile unsigned long *ptr)
 	}
 #endif
 	mask = 1UL << (nr & (BITS_PER_LONG - 1));
-	__atomic64_xor(mask, addr);
+	__atomic64_xor(mask, (long long *)addr);
 }
 
 static inline int
@@ -132,7 +132,7 @@ test_and_set_bit(unsigned long nr, volatile unsigned long *ptr)
 	unsigned long old, mask;
 
 	mask = 1UL << (nr & (BITS_PER_LONG - 1));
-	old = __atomic64_or_barrier(mask, addr);
+	old = __atomic64_or_barrier(mask, (long long *)addr);
 	return (old & mask) != 0;
 }
 
@@ -143,7 +143,7 @@ test_and_clear_bit(unsigned long nr, volatile unsigned long *ptr)
 	unsigned long old, mask;
 
 	mask = ~(1UL << (nr & (BITS_PER_LONG - 1)));
-	old = __atomic64_and_barrier(mask, addr);
+	old = __atomic64_and_barrier(mask, (long long *)addr);
 	return (old & ~mask) != 0;
 }
 
@@ -154,7 +154,7 @@ test_and_change_bit(unsigned long nr, volatile unsigned long *ptr)
 	unsigned long old, mask;
 
 	mask = 1UL << (nr & (BITS_PER_LONG - 1));
-	old = __atomic64_xor_barrier(mask, addr);
+	old = __atomic64_xor_barrier(mask, (long long *)addr);
 	return (old & mask) != 0;
 }
 
diff --git a/arch/x86/include/asm/atomic64_64.h b/arch/x86/include/asm/atomic64_64.h
index 8db8879a6d8c..8555cd19a916 100644
--- a/arch/x86/include/asm/atomic64_64.h
+++ b/arch/x86/include/asm/atomic64_64.h
@@ -16,7 +16,7 @@
  * Atomically reads the value of @v.
  * Doesn't imply a read memory barrier.
  */
-static inline long atomic64_read(const atomic64_t *v)
+static inline long long atomic64_read(const atomic64_t *v)
 {
 	return READ_ONCE((v)->counter);
 }
@@ -28,7 +28,7 @@ static inline long atomic64_read(const atomic64_t *v)
  *
  * Atomically sets the value of @v to @i.
  */
-static inline void atomic64_set(atomic64_t *v, long i)
+static inline void atomic64_set(atomic64_t *v, long long i)
 {
 	WRITE_ONCE(v->counter, i);
 }
@@ -40,7 +40,7 @@ static inline void atomic64_set(atomic64_t *v, long i)
  *
  * Atomically adds @i to @v.
  */
-static __always_inline void atomic64_add(long i, atomic64_t *v)
+static __always_inline void atomic64_add(long long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "addq %1,%0"
 		     : "=m" (v->counter)
@@ -54,7 +54,7 @@ static __always_inline void atomic64_add(long i, atomic64_t *v)
  *
  * Atomically subtracts @i from @v.
  */
-static inline void atomic64_sub(long i, atomic64_t *v)
+static inline void atomic64_sub(long long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "subq %1,%0"
 		     : "=m" (v->counter)
@@ -70,7 +70,7 @@ static inline void atomic64_sub(long i, atomic64_t *v)
  * true if the result is zero, or false for all
  * other cases.
  */
-static inline bool atomic64_sub_and_test(long i, atomic64_t *v)
+static inline bool atomic64_sub_and_test(long long i, atomic64_t *v)
 {
 	GEN_BINARY_RMWcc(LOCK_PREFIX "subq", v->counter, "er", i, "%0", e);
 }
@@ -136,7 +136,7 @@ static inline bool atomic64_inc_and_test(atomic64_t *v)
  * if the result is negative, or false when
  * result is greater than or equal to zero.
  */
-static inline bool atomic64_add_negative(long i, atomic64_t *v)
+static inline bool atomic64_add_negative(long long i, atomic64_t *v)
 {
 	GEN_BINARY_RMWcc(LOCK_PREFIX "addq", v->counter, "er", i, "%0", s);
 }
@@ -148,22 +148,22 @@ static inline bool atomic64_add_negative(long i, atomic64_t *v)
  *
  * Atomically adds @i to @v and returns @i + @v
  */
-static __always_inline long atomic64_add_return(long i, atomic64_t *v)
+static __always_inline long long atomic64_add_return(long long i, atomic64_t *v)
 {
 	return i + xadd(&v->counter, i);
 }
 
-static inline long atomic64_sub_return(long i, atomic64_t *v)
+static inline long long atomic64_sub_return(long long i, atomic64_t *v)
 {
 	return atomic64_add_return(-i, v);
 }
 
-static inline long atomic64_fetch_add(long i, atomic64_t *v)
+static inline long long atomic64_fetch_add(long long i, atomic64_t *v)
 {
 	return xadd(&v->counter, i);
 }
 
-static inline long atomic64_fetch_sub(long i, atomic64_t *v)
+static inline long long atomic64_fetch_sub(long long i, atomic64_t *v)
 {
 	return xadd(&v->counter, -i);
 }
@@ -171,18 +171,18 @@ static inline long atomic64_fetch_sub(long i, atomic64_t *v)
 #define atomic64_inc_return(v)  (atomic64_add_return(1, (v)))
 #define atomic64_dec_return(v)  (atomic64_sub_return(1, (v)))
 
-static inline long atomic64_cmpxchg(atomic64_t *v, long old, long new)
+static inline long long atomic64_cmpxchg(atomic64_t *v, long long old, long long new)
 {
 	return cmpxchg(&v->counter, old, new);
 }
 
 #define atomic64_try_cmpxchg atomic64_try_cmpxchg
-static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, long *old, long new)
+static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, long long *old, long long new)
 {
 	return try_cmpxchg(&v->counter, old, new);
 }
 
-static inline long atomic64_xchg(atomic64_t *v, long new)
+static inline long long atomic64_xchg(atomic64_t *v, long long new)
 {
 	return xchg(&v->counter, new);
 }
@@ -196,9 +196,9 @@ static inline long atomic64_xchg(atomic64_t *v, long new)
  * Atomically adds @a to @v, so long as it was not @u.
  * Returns the old value of @v.
  */
-static inline bool atomic64_add_unless(atomic64_t *v, long a, long u)
+static inline bool atomic64_add_unless(atomic64_t *v, long long a, long long u)
 {
-	long c = atomic64_read(v);
+	long long c = atomic64_read(v);
 	do {
 		if (unlikely(c == u))
 			return false;
@@ -215,9 +215,9 @@ static inline bool atomic64_add_unless(atomic64_t *v, long a, long u)
  * The function returns the old value of *v minus 1, even if
  * the atomic variable, v, was not decremented.
  */
-static inline long atomic64_dec_if_positive(atomic64_t *v)
+static inline long long atomic64_dec_if_positive(atomic64_t *v)
 {
-	long dec, c = atomic64_read(v);
+	long long dec, c = atomic64_read(v);
 	do {
 		dec = c - 1;
 		if (unlikely(dec < 0))
@@ -226,7 +226,7 @@ static inline long atomic64_dec_if_positive(atomic64_t *v)
 	return dec;
 }
 
-static inline void atomic64_and(long i, atomic64_t *v)
+static inline void atomic64_and(long long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "andq %1,%0"
 			: "+m" (v->counter)
@@ -234,16 +234,16 @@ static inline void atomic64_and(long i, atomic64_t *v)
 			: "memory");
 }
 
-static inline long atomic64_fetch_and(long i, atomic64_t *v)
+static inline long long atomic64_fetch_and(long long i, atomic64_t *v)
 {
-	long val = atomic64_read(v);
+	long long val = atomic64_read(v);
 
 	do {
 	} while (!atomic64_try_cmpxchg(v, &val, val & i));
 	return val;
 }
 
-static inline void atomic64_or(long i, atomic64_t *v)
+static inline void atomic64_or(long long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "orq %1,%0"
 			: "+m" (v->counter)
@@ -251,16 +251,16 @@ static inline void atomic64_or(long i, atomic64_t *v)
 			: "memory");
 }
 
-static inline long atomic64_fetch_or(long i, atomic64_t *v)
+static inline long long atomic64_fetch_or(long long i, atomic64_t *v)
 {
-	long val = atomic64_read(v);
+	long long val = atomic64_read(v);
 
 	do {
 	} while (!atomic64_try_cmpxchg(v, &val, val | i));
 	return val;
 }
 
-static inline void atomic64_xor(long i, atomic64_t *v)
+static inline void atomic64_xor(long long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "xorq %1,%0"
 			: "+m" (v->counter)
@@ -268,9 +268,9 @@ static inline void atomic64_xor(long i, atomic64_t *v)
 			: "memory");
 }
 
-static inline long atomic64_fetch_xor(long i, atomic64_t *v)
+static inline long long atomic64_fetch_xor(long long i, atomic64_t *v)
 {
-	long val = atomic64_read(v);
+	long long val = atomic64_read(v);
 
 	do {
 	} while (!atomic64_try_cmpxchg(v, &val, val ^ i));
diff --git a/include/linux/types.h b/include/linux/types.h
index 1e7bd24848fc..569fc6db1bd5 100644
--- a/include/linux/types.h
+++ b/include/linux/types.h
@@ -177,7 +177,7 @@ typedef struct {
 
 #ifdef CONFIG_64BIT
 typedef struct {
-	long counter;
+	long long counter;
 } atomic64_t;
 #endif
 
-- 
2.13.0.219.gdb65acc882-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
