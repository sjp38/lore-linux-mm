Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2BC96B039F
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 12:15:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u18so40114456wrc.10
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:15:55 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id 91si5178202wrb.235.2017.03.28.09.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 09:15:54 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id x124so3054276wmf.0
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:15:53 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 5/8] x86: switch atomic.h to use atomic-instrumented.h
Date: Tue, 28 Mar 2017 18:15:42 +0200
Message-Id: <4d4bb87870e5d7b1a3c660c74a1cd474def20e74.1490717337.git.dvyukov@google.com>
In-Reply-To: <cover.1490717337.git.dvyukov@google.com>
References: <cover.1490717337.git.dvyukov@google.com>
In-Reply-To: <cover.1490717337.git.dvyukov@google.com>
References: <cover.1490717337.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com
Cc: akpm@linux-foundation.org, will.deacon@arm.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org

Add arch_ prefix to all atomic operations and include
<asm-generic/atomic-instrumented.h>. This will allow
to add KASAN instrumentation to all atomic ops.

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
 arch/x86/include/asm/atomic.h      | 110 ++++++++++++++++++++-----------------
 arch/x86/include/asm/atomic64_32.h | 106 +++++++++++++++++------------------
 arch/x86/include/asm/atomic64_64.h | 110 ++++++++++++++++++-------------------
 arch/x86/include/asm/cmpxchg.h     |  14 ++---
 arch/x86/include/asm/cmpxchg_32.h  |   8 +--
 arch/x86/include/asm/cmpxchg_64.h  |   4 +-
 6 files changed, 181 insertions(+), 171 deletions(-)

diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
index 8d7f6e579be4..92dd59f24eba 100644
--- a/arch/x86/include/asm/atomic.h
+++ b/arch/x86/include/asm/atomic.h
@@ -16,36 +16,42 @@
 #define ATOMIC_INIT(i)	{ (i) }
 
 /**
- * atomic_read - read atomic variable
+ * arch_atomic_read - read atomic variable
  * @v: pointer of type atomic_t
  *
  * Atomically reads the value of @v.
  */
-static __always_inline int atomic_read(const atomic_t *v)
+static __always_inline int arch_atomic_read(const atomic_t *v)
 {
 	return READ_ONCE((v)->counter);
 }
 
 /**
- * atomic_set - set atomic variable
+ * arch_atomic_set - set atomic variable
  * @v: pointer of type atomic_t
  * @i: required value
  *
  * Atomically sets the value of @v to @i.
  */
-static __always_inline void atomic_set(atomic_t *v, int i)
+static __always_inline void arch_atomic_set(atomic_t *v, int i)
 {
+	/*
+	 * We could use WRITE_ONCE_NOCHECK() if it exists, similar to
+	 * READ_ONCE_NOCHECK() in arch_atomic_read(). But there is no such
+	 * thing at the moment, and introducing it for this case does not
+	 * worth it.
+	 */
 	WRITE_ONCE(v->counter, i);
 }
 
 /**
- * atomic_add - add integer to atomic variable
+ * arch_atomic_add - add integer to atomic variable
  * @i: integer value to add
  * @v: pointer of type atomic_t
  *
  * Atomically adds @i to @v.
  */
-static __always_inline void atomic_add(int i, atomic_t *v)
+static __always_inline void arch_atomic_add(int i, atomic_t *v)
 {
 	asm volatile(LOCK_PREFIX "addl %1,%0"
 		     : "+m" (v->counter)
@@ -53,13 +59,13 @@ static __always_inline void atomic_add(int i, atomic_t *v)
 }
 
 /**
- * atomic_sub - subtract integer from atomic variable
+ * arch_atomic_sub - subtract integer from atomic variable
  * @i: integer value to subtract
  * @v: pointer of type atomic_t
  *
  * Atomically subtracts @i from @v.
  */
-static __always_inline void atomic_sub(int i, atomic_t *v)
+static __always_inline void arch_atomic_sub(int i, atomic_t *v)
 {
 	asm volatile(LOCK_PREFIX "subl %1,%0"
 		     : "+m" (v->counter)
@@ -67,7 +73,7 @@ static __always_inline void atomic_sub(int i, atomic_t *v)
 }
 
 /**
- * atomic_sub_and_test - subtract value from variable and test result
+ * arch_atomic_sub_and_test - subtract value from variable and test result
  * @i: integer value to subtract
  * @v: pointer of type atomic_t
  *
@@ -75,63 +81,63 @@ static __always_inline void atomic_sub(int i, atomic_t *v)
  * true if the result is zero, or false for all
  * other cases.
  */
-static __always_inline bool atomic_sub_and_test(int i, atomic_t *v)
+static __always_inline bool arch_atomic_sub_and_test(int i, atomic_t *v)
 {
 	GEN_BINARY_RMWcc(LOCK_PREFIX "subl", v->counter, "er", i, "%0", e);
 }
 
 /**
- * atomic_inc - increment atomic variable
+ * arch_atomic_inc - increment atomic variable
  * @v: pointer of type atomic_t
  *
  * Atomically increments @v by 1.
  */
-static __always_inline void atomic_inc(atomic_t *v)
+static __always_inline void arch_atomic_inc(atomic_t *v)
 {
 	asm volatile(LOCK_PREFIX "incl %0"
 		     : "+m" (v->counter));
 }
 
 /**
- * atomic_dec - decrement atomic variable
+ * arch_atomic_dec - decrement atomic variable
  * @v: pointer of type atomic_t
  *
  * Atomically decrements @v by 1.
  */
-static __always_inline void atomic_dec(atomic_t *v)
+static __always_inline void arch_atomic_dec(atomic_t *v)
 {
 	asm volatile(LOCK_PREFIX "decl %0"
 		     : "+m" (v->counter));
 }
 
 /**
- * atomic_dec_and_test - decrement and test
+ * arch_atomic_dec_and_test - decrement and test
  * @v: pointer of type atomic_t
  *
  * Atomically decrements @v by 1 and
  * returns true if the result is 0, or false for all other
  * cases.
  */
-static __always_inline bool atomic_dec_and_test(atomic_t *v)
+static __always_inline bool arch_atomic_dec_and_test(atomic_t *v)
 {
 	GEN_UNARY_RMWcc(LOCK_PREFIX "decl", v->counter, "%0", e);
 }
 
 /**
- * atomic_inc_and_test - increment and test
+ * arch_atomic_inc_and_test - increment and test
  * @v: pointer of type atomic_t
  *
  * Atomically increments @v by 1
  * and returns true if the result is zero, or false for all
  * other cases.
  */
-static __always_inline bool atomic_inc_and_test(atomic_t *v)
+static __always_inline bool arch_atomic_inc_and_test(atomic_t *v)
 {
 	GEN_UNARY_RMWcc(LOCK_PREFIX "incl", v->counter, "%0", e);
 }
 
 /**
- * atomic_add_negative - add and test if negative
+ * arch_atomic_add_negative - add and test if negative
  * @i: integer value to add
  * @v: pointer of type atomic_t
  *
@@ -139,65 +145,65 @@ static __always_inline bool atomic_inc_and_test(atomic_t *v)
  * if the result is negative, or false when
  * result is greater than or equal to zero.
  */
-static __always_inline bool atomic_add_negative(int i, atomic_t *v)
+static __always_inline bool arch_atomic_add_negative(int i, atomic_t *v)
 {
 	GEN_BINARY_RMWcc(LOCK_PREFIX "addl", v->counter, "er", i, "%0", s);
 }
 
 /**
- * atomic_add_return - add integer and return
+ * arch_atomic_add_return - add integer and return
  * @i: integer value to add
  * @v: pointer of type atomic_t
  *
  * Atomically adds @i to @v and returns @i + @v
  */
-static __always_inline int atomic_add_return(int i, atomic_t *v)
+static __always_inline int arch_atomic_add_return(int i, atomic_t *v)
 {
 	return i + xadd(&v->counter, i);
 }
 
 /**
- * atomic_sub_return - subtract integer and return
+ * arch_atomic_sub_return - subtract integer and return
  * @v: pointer of type atomic_t
  * @i: integer value to subtract
  *
  * Atomically subtracts @i from @v and returns @v - @i
  */
-static __always_inline int atomic_sub_return(int i, atomic_t *v)
+static __always_inline int arch_atomic_sub_return(int i, atomic_t *v)
 {
-	return atomic_add_return(-i, v);
+	return arch_atomic_add_return(-i, v);
 }
 
-#define atomic_inc_return(v)  (atomic_add_return(1, v))
-#define atomic_dec_return(v)  (atomic_sub_return(1, v))
+#define arch_atomic_inc_return(v)  (arch_atomic_add_return(1, v))
+#define arch_atomic_dec_return(v)  (arch_atomic_sub_return(1, v))
 
-static __always_inline int atomic_fetch_add(int i, atomic_t *v)
+static __always_inline int arch_atomic_fetch_add(int i, atomic_t *v)
 {
 	return xadd(&v->counter, i);
 }
 
-static __always_inline int atomic_fetch_sub(int i, atomic_t *v)
+static __always_inline int arch_atomic_fetch_sub(int i, atomic_t *v)
 {
 	return xadd(&v->counter, -i);
 }
 
-static __always_inline int atomic_cmpxchg(atomic_t *v, int old, int new)
+static __always_inline int arch_atomic_cmpxchg(atomic_t *v, int old, int new)
 {
-	return cmpxchg(&v->counter, old, new);
+	return arch_cmpxchg(&v->counter, old, new);
 }
 
-#define atomic_try_cmpxchg atomic_try_cmpxchg
-static __always_inline bool atomic_try_cmpxchg(atomic_t *v, int *old, int new)
+#define arch_atomic_try_cmpxchg arch_atomic_try_cmpxchg
+static __always_inline bool arch_atomic_try_cmpxchg(atomic_t *v, int *old, int new)
 {
-	return try_cmpxchg(&v->counter, old, new);
+	return arch_try_cmpxchg(&v->counter, old, new);
 }
 
-static inline int atomic_xchg(atomic_t *v, int new)
+static inline int arch_atomic_xchg(atomic_t *v, int new)
 {
 	return xchg(&v->counter, new);
 }
 
-static inline void atomic_and(int i, atomic_t *v)
+static inline void arch_atomic_and(int i, atomic_t *v)
 {
 	asm volatile(LOCK_PREFIX "andl %1,%0"
 			: "+m" (v->counter)
@@ -205,16 +211,16 @@ static inline void atomic_and(int i, atomic_t *v)
 			: "memory");
 }
 
-static inline int atomic_fetch_and(int i, atomic_t *v)
+static inline int arch_atomic_fetch_and(int i, atomic_t *v)
 {
-	int val = atomic_read(v);
+	int val = arch_atomic_read(v);
 
 	do {
-	} while (!atomic_try_cmpxchg(v, &val, val & i));
+	} while (!arch_atomic_try_cmpxchg(v, &val, val & i));
 	return val;
 }
 
-static inline void atomic_or(int i, atomic_t *v)
+static inline void arch_atomic_or(int i, atomic_t *v)
 {
 	asm volatile(LOCK_PREFIX "orl %1,%0"
 			: "+m" (v->counter)
@@ -222,17 +228,17 @@ static inline void atomic_or(int i, atomic_t *v)
 			: "memory");
 }
 
-static inline int atomic_fetch_or(int i, atomic_t *v)
+static inline int arch_atomic_fetch_or(int i, atomic_t *v)
 {
-	int val = atomic_read(v);
+	int val = arch_atomic_read(v);
 
 	do {
-	} while (!atomic_try_cmpxchg(v, &val, val | i));
+	} while (!arch_atomic_try_cmpxchg(v, &val, val | i));
 	return val;
 }
 
 
-static inline void atomic_xor(int i, atomic_t *v)
+static inline void arch_atomic_xor(int i, atomic_t *v)
 {
 	asm volatile(LOCK_PREFIX "xorl %1,%0"
 			: "+m" (v->counter)
@@ -240,17 +246,17 @@ static inline void atomic_xor(int i, atomic_t *v)
 			: "memory");
 }
 
-static inline int atomic_fetch_xor(int i, atomic_t *v)
+static inline int arch_atomic_fetch_xor(int i, atomic_t *v)
 {
-	int val = atomic_read(v);
+	int val = arch_atomic_read(v);
 
 	do {
-	} while (!atomic_try_cmpxchg(v, &val, val ^ i));
+	} while (!arch_atomic_try_cmpxchg(v, &val, val ^ i));
 	return val;
 }
 
 /**
- * __atomic_add_unless - add unless the number is already a given value
+ * __arch_atomic_add_unless - add unless the number is already a given value
  * @v: pointer of type atomic_t
  * @a: the amount to add to v...
  * @u: ...unless v is equal to u.
@@ -258,13 +264,13 @@ static inline int atomic_fetch_xor(int i, atomic_t *v)
  * Atomically adds @a to @v, so long as @v was not already @u.
  * Returns the old value of @v.
  */
-static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
+static __always_inline int __arch_atomic_add_unless(atomic_t *v, int a, int u)
 {
-	int c = atomic_read(v);
+	int c = arch_atomic_read(v);
 	do {
 		if (unlikely(c == u))
 			break;
-	} while (!atomic_try_cmpxchg(v, &c, c + a));
+	} while (!arch_atomic_try_cmpxchg(v, &c, c + a));
 	return c;
 }
 
@@ -274,4 +280,6 @@ static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
 # include <asm/atomic64_64.h>
 #endif
 
+#include <asm-generic/atomic-instrumented.h>
+
 #endif /* _ASM_X86_ATOMIC_H */
diff --git a/arch/x86/include/asm/atomic64_32.h b/arch/x86/include/asm/atomic64_32.h
index f107fef7bfcc..8501e4fc5054 100644
--- a/arch/x86/include/asm/atomic64_32.h
+++ b/arch/x86/include/asm/atomic64_32.h
@@ -61,7 +61,7 @@ ATOMIC64_DECL(add_unless);
 #undef ATOMIC64_EXPORT
 
 /**
- * atomic64_cmpxchg - cmpxchg atomic64 variable
+ * arch_atomic64_cmpxchg - cmpxchg atomic64 variable
  * @v: pointer to type atomic64_t
  * @o: expected value
  * @n: new value
@@ -70,20 +70,21 @@ ATOMIC64_DECL(add_unless);
  * the old value.
  */
 
-static inline long long atomic64_cmpxchg(atomic64_t *v, long long o, long long n)
+static inline long long arch_atomic64_cmpxchg(atomic64_t *v, long long o,
+					      long long n)
 {
-	return cmpxchg64(&v->counter, o, n);
+	return arch_cmpxchg64(&v->counter, o, n);
 }
 
 /**
- * atomic64_xchg - xchg atomic64 variable
+ * arch_atomic64_xchg - xchg atomic64 variable
  * @v: pointer to type atomic64_t
  * @n: value to assign
  *
  * Atomically xchgs the value of @v to @n and returns
  * the old value.
  */
-static inline long long atomic64_xchg(atomic64_t *v, long long n)
+static inline long long arch_atomic64_xchg(atomic64_t *v, long long n)
 {
 	long long o;
 	unsigned high = (unsigned)(n >> 32);
@@ -95,13 +96,13 @@ static inline long long atomic64_xchg(atomic64_t *v, long long n)
 }
 
 /**
- * atomic64_set - set atomic64 variable
+ * arch_atomic64_set - set atomic64 variable
  * @v: pointer to type atomic64_t
  * @i: value to assign
  *
  * Atomically sets the value of @v to @n.
  */
-static inline void atomic64_set(atomic64_t *v, long long i)
+static inline void arch_atomic64_set(atomic64_t *v, long long i)
 {
 	unsigned high = (unsigned)(i >> 32);
 	unsigned low = (unsigned)i;
@@ -111,12 +112,12 @@ static inline void atomic64_set(atomic64_t *v, long long i)
 }
 
 /**
- * atomic64_read - read atomic64 variable
+ * arch_atomic64_read - read atomic64 variable
  * @v: pointer to type atomic64_t
  *
  * Atomically reads the value of @v and returns it.
  */
-static inline long long atomic64_read(const atomic64_t *v)
+static inline long long arch_atomic64_read(const atomic64_t *v)
 {
 	long long r;
 	alternative_atomic64(read, "=&A" (r), "c" (v) : "memory");
@@ -124,13 +125,13 @@ static inline long long atomic64_read(const atomic64_t *v)
  }
 
 /**
- * atomic64_add_return - add and return
+ * arch_atomic64_add_return - add and return
  * @i: integer value to add
  * @v: pointer to type atomic64_t
  *
  * Atomically adds @i to @v and returns @i + *@v
  */
-static inline long long atomic64_add_return(long long i, atomic64_t *v)
+static inline long long arch_atomic64_add_return(long long i, atomic64_t *v)
 {
 	alternative_atomic64(add_return,
 			     ASM_OUTPUT2("+A" (i), "+c" (v)),
@@ -141,7 +142,7 @@ static inline long long atomic64_add_return(long long i, atomic64_t *v)
 /*
  * Other variants with different arithmetic operators:
  */
-static inline long long atomic64_sub_return(long long i, atomic64_t *v)
+static inline long long arch_atomic64_sub_return(long long i, atomic64_t *v)
 {
 	alternative_atomic64(sub_return,
 			     ASM_OUTPUT2("+A" (i), "+c" (v)),
@@ -149,7 +150,7 @@ static inline long long atomic64_sub_return(long long i, atomic64_t *v)
 	return i;
 }
 
-static inline long long atomic64_inc_return(atomic64_t *v)
+static inline long long arch_atomic64_inc_return(atomic64_t *v)
 {
 	long long a;
 	alternative_atomic64(inc_return, "=&A" (a),
@@ -157,7 +158,7 @@ static inline long long atomic64_inc_return(atomic64_t *v)
 	return a;
 }
 
-static inline long long atomic64_dec_return(atomic64_t *v)
+static inline long long arch_atomic64_dec_return(atomic64_t *v)
 {
 	long long a;
 	alternative_atomic64(dec_return, "=&A" (a),
@@ -166,13 +167,13 @@ static inline long long atomic64_dec_return(atomic64_t *v)
 }
 
 /**
- * atomic64_add - add integer to atomic64 variable
+ * arch_atomic64_add - add integer to atomic64 variable
  * @i: integer value to add
  * @v: pointer to type atomic64_t
  *
  * Atomically adds @i to @v.
  */
-static inline long long atomic64_add(long long i, atomic64_t *v)
+static inline long long arch_atomic64_add(long long i, atomic64_t *v)
 {
 	__alternative_atomic64(add, add_return,
 			       ASM_OUTPUT2("+A" (i), "+c" (v)),
@@ -181,13 +182,13 @@ static inline long long atomic64_add(long long i, atomic64_t *v)
 }
 
 /**
- * atomic64_sub - subtract the atomic64 variable
+ * arch_atomic64_sub - subtract the atomic64 variable
  * @i: integer value to subtract
  * @v: pointer to type atomic64_t
  *
  * Atomically subtracts @i from @v.
  */
-static inline long long atomic64_sub(long long i, atomic64_t *v)
+static inline long long arch_atomic64_sub(long long i, atomic64_t *v)
 {
 	__alternative_atomic64(sub, sub_return,
 			       ASM_OUTPUT2("+A" (i), "+c" (v)),
@@ -196,7 +197,7 @@ static inline long long atomic64_sub(long long i, atomic64_t *v)
 }
 
 /**
- * atomic64_sub_and_test - subtract value from variable and test result
+ * arch_atomic64_sub_and_test - subtract value from variable and test result
  * @i: integer value to subtract
  * @v: pointer to type atomic64_t
  *
@@ -204,46 +205,46 @@ static inline long long atomic64_sub(long long i, atomic64_t *v)
  * true if the result is zero, or false for all
  * other cases.
  */
-static inline int atomic64_sub_and_test(long long i, atomic64_t *v)
+static inline int arch_atomic64_sub_and_test(long long i, atomic64_t *v)
 {
-	return atomic64_sub_return(i, v) == 0;
+	return arch_atomic64_sub_return(i, v) == 0;
 }
 
 /**
- * atomic64_inc - increment atomic64 variable
+ * arch_atomic64_inc - increment atomic64 variable
  * @v: pointer to type atomic64_t
  *
  * Atomically increments @v by 1.
  */
-static inline void atomic64_inc(atomic64_t *v)
+static inline void arch_atomic64_inc(atomic64_t *v)
 {
 	__alternative_atomic64(inc, inc_return, /* no output */,
 			       "S" (v) : "memory", "eax", "ecx", "edx");
 }
 
 /**
- * atomic64_dec - decrement atomic64 variable
+ * arch_atomic64_dec - decrement atomic64 variable
  * @v: pointer to type atomic64_t
  *
  * Atomically decrements @v by 1.
  */
-static inline void atomic64_dec(atomic64_t *v)
+static inline void arch_atomic64_dec(atomic64_t *v)
 {
 	__alternative_atomic64(dec, dec_return, /* no output */,
 			       "S" (v) : "memory", "eax", "ecx", "edx");
 }
 
 /**
- * atomic64_dec_and_test - decrement and test
+ * arch_atomic64_dec_and_test - decrement and test
  * @v: pointer to type atomic64_t
  *
  * Atomically decrements @v by 1 and
  * returns true if the result is 0, or false for all other
  * cases.
  */
-static inline int atomic64_dec_and_test(atomic64_t *v)
+static inline int arch_atomic64_dec_and_test(atomic64_t *v)
 {
-	return atomic64_dec_return(v) == 0;
+	return arch_atomic64_dec_return(v) == 0;
 }
 
 /**
@@ -254,13 +255,13 @@ static inline int atomic64_dec_and_test(atomic64_t *v)
  * and returns true if the result is zero, or false for all
  * other cases.
  */
-static inline int atomic64_inc_and_test(atomic64_t *v)
+static inline int arch_atomic64_inc_and_test(atomic64_t *v)
 {
-	return atomic64_inc_return(v) == 0;
+	return arch_atomic64_inc_return(v) == 0;
 }
 
 /**
- * atomic64_add_negative - add and test if negative
+ * arch_atomic64_add_negative - add and test if negative
  * @i: integer value to add
  * @v: pointer to type atomic64_t
  *
@@ -268,13 +269,13 @@ static inline int atomic64_inc_and_test(atomic64_t *v)
  * if the result is negative, or false when
  * result is greater than or equal to zero.
  */
-static inline int atomic64_add_negative(long long i, atomic64_t *v)
+static inline int arch_atomic64_add_negative(long long i, atomic64_t *v)
 {
-	return atomic64_add_return(i, v) < 0;
+	return arch_atomic64_add_return(i, v) < 0;
 }
 
 /**
- * atomic64_add_unless - add unless the number is a given value
+ * arch_atomic64_add_unless - add unless the number is a given value
  * @v: pointer of type atomic64_t
  * @a: the amount to add to v...
  * @u: ...unless v is equal to u.
@@ -282,7 +283,8 @@ static inline int atomic64_add_negative(long long i, atomic64_t *v)
  * Atomically adds @a to @v, so long as it was not @u.
  * Returns non-zero if the add was done, zero otherwise.
  */
-static inline int atomic64_add_unless(atomic64_t *v, long long a, long long u)
+static inline int arch_atomic64_add_unless(atomic64_t *v, long long a,
+					   long long u)
 {
 	unsigned low = (unsigned)u;
 	unsigned high = (unsigned)(u >> 32);
@@ -293,7 +295,7 @@ static inline int atomic64_add_unless(atomic64_t *v, long long a, long long u)
 }
 
 
-static inline int atomic64_inc_not_zero(atomic64_t *v)
+static inline int arch_atomic64_inc_not_zero(atomic64_t *v)
 {
 	int r;
 	alternative_atomic64(inc_not_zero, "=&a" (r),
@@ -301,7 +303,7 @@ static inline int atomic64_inc_not_zero(atomic64_t *v)
 	return r;
 }
 
-static inline long long atomic64_dec_if_positive(atomic64_t *v)
+static inline long long arch_atomic64_dec_if_positive(atomic64_t *v)
 {
 	long long r;
 	alternative_atomic64(dec_if_positive, "=&A" (r),
@@ -312,66 +314,66 @@ static inline long long atomic64_dec_if_positive(atomic64_t *v)
 #undef alternative_atomic64
 #undef __alternative_atomic64
 
-static inline void atomic64_and(long long i, atomic64_t *v)
+static inline void arch_atomic64_and(long long i, atomic64_t *v)
 {
 	long long old, c = 0;
 
-	while ((old = atomic64_cmpxchg(v, c, c & i)) != c)
+	while ((old = arch_atomic64_cmpxchg(v, c, c & i)) != c)
 		c = old;
 }
 
-static inline long long atomic64_fetch_and(long long i, atomic64_t *v)
+static inline long long arch_atomic64_fetch_and(long long i, atomic64_t *v)
 {
 	long long old, c = 0;
 
-	while ((old = atomic64_cmpxchg(v, c, c & i)) != c)
+	while ((old = arch_atomic64_cmpxchg(v, c, c & i)) != c)
 		c = old;
 	return old;
 }
 
-static inline void atomic64_or(long long i, atomic64_t *v)
+static inline void arch_atomic64_or(long long i, atomic64_t *v)
 {
 	long long old, c = 0;
 
-	while ((old = atomic64_cmpxchg(v, c, c | i)) != c)
+	while ((old = arch_atomic64_cmpxchg(v, c, c | i)) != c)
 		c = old;
 }
 
-static inline long long atomic64_fetch_or(long long i, atomic64_t *v)
+static inline long long arch_atomic64_fetch_or(long long i, atomic64_t *v)
 {
 	long long old, c = 0;
 
-	while ((old = atomic64_cmpxchg(v, c, c | i)) != c)
+	while ((old = arch_atomic64_cmpxchg(v, c, c | i)) != c)
 		c = old;
 	return old;
 }
 
-static inline void atomic64_xor(long long i, atomic64_t *v)
+static inline void arch_atomic64_xor(long long i, atomic64_t *v)
 {
 	long long old, c = 0;
 
-	while ((old = atomic64_cmpxchg(v, c, c ^ i)) != c)
+	while ((old = arch_atomic64_cmpxchg(v, c, c ^ i)) != c)
 		c = old;
 }
 
-static inline long long atomic64_fetch_xor(long long i, atomic64_t *v)
+static inline long long arch_atomic64_fetch_xor(long long i, atomic64_t *v)
 {
 	long long old, c = 0;
 
-	while ((old = atomic64_cmpxchg(v, c, c ^ i)) != c)
+	while ((old = arch_atomic64_cmpxchg(v, c, c ^ i)) != c)
 		c = old;
 	return old;
 }
 
-static inline long long atomic64_fetch_add(long long i, atomic64_t *v)
+static inline long long arch_atomic64_fetch_add(long long i, atomic64_t *v)
 {
 	long long old, c = 0;
 
-	while ((old = atomic64_cmpxchg(v, c, c + i)) != c)
+	while ((old = arch_atomic64_cmpxchg(v, c, c + i)) != c)
 		c = old;
 	return old;
 }
 
-#define atomic64_fetch_sub(i, v)	atomic64_fetch_add(-(i), (v))
+#define arch_atomic64_fetch_sub(i, v)	arch_atomic64_fetch_add(-(i), (v))
 
 #endif /* _ASM_X86_ATOMIC64_32_H */
diff --git a/arch/x86/include/asm/atomic64_64.h b/arch/x86/include/asm/atomic64_64.h
index a62982a2b534..6b6873e4d4e8 100644
--- a/arch/x86/include/asm/atomic64_64.h
+++ b/arch/x86/include/asm/atomic64_64.h
@@ -10,37 +10,37 @@
 #define ATOMIC64_INIT(i)	{ (i) }
 
 /**
- * atomic64_read - read atomic64 variable
+ * arch_atomic64_read - read atomic64 variable
  * @v: pointer of type atomic64_t
  *
  * Atomically reads the value of @v.
  * Doesn't imply a read memory barrier.
  */
-static inline long long atomic64_read(const atomic64_t *v)
+static inline long long arch_atomic64_read(const atomic64_t *v)
 {
 	return READ_ONCE((v)->counter);
 }
 
 /**
- * atomic64_set - set atomic64 variable
+ * arch_atomic64_set - set atomic64 variable
  * @v: pointer to type atomic64_t
  * @i: required value
  *
  * Atomically sets the value of @v to @i.
  */
-static inline void atomic64_set(atomic64_t *v, long long i)
+static inline void arch_atomic64_set(atomic64_t *v, long long i)
 {
 	WRITE_ONCE(v->counter, i);
 }
 
 /**
- * atomic64_add - add integer to atomic64 variable
+ * arch_atomic64_add - add integer to atomic64 variable
  * @i: integer value to add
  * @v: pointer to type atomic64_t
  *
  * Atomically adds @i to @v.
  */
-static __always_inline void atomic64_add(long long i, atomic64_t *v)
+static __always_inline void arch_atomic64_add(long long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "addq %1,%0"
 		     : "=m" (v->counter)
@@ -48,13 +48,13 @@ static __always_inline void atomic64_add(long long i, atomic64_t *v)
 }
 
 /**
- * atomic64_sub - subtract the atomic64 variable
+ * arch_atomic64_sub - subtract the atomic64 variable
  * @i: integer value to subtract
  * @v: pointer to type atomic64_t
  *
  * Atomically subtracts @i from @v.
  */
-static inline void atomic64_sub(long long i, atomic64_t *v)
+static inline void arch_atomic64_sub(long long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "subq %1,%0"
 		     : "=m" (v->counter)
@@ -62,7 +62,7 @@ static inline void atomic64_sub(long long i, atomic64_t *v)
 }
 
 /**
- * atomic64_sub_and_test - subtract value from variable and test result
+ * arch_atomic64_sub_and_test - subtract value from variable and test result
  * @i: integer value to subtract
  * @v: pointer to type atomic64_t
  *
@@ -70,18 +70,18 @@ static inline void atomic64_sub(long long i, atomic64_t *v)
  * true if the result is zero, or false for all
  * other cases.
  */
-static inline bool atomic64_sub_and_test(long long i, atomic64_t *v)
+static inline bool arch_atomic64_sub_and_test(long long i, atomic64_t *v)
 {
 	GEN_BINARY_RMWcc(LOCK_PREFIX "subq", v->counter, "er", i, "%0", e);
 }
 
 /**
- * atomic64_inc - increment atomic64 variable
+ * arch_atomic64_inc - increment atomic64 variable
  * @v: pointer to type atomic64_t
  *
  * Atomically increments @v by 1.
  */
-static __always_inline void atomic64_inc(atomic64_t *v)
+static __always_inline void arch_atomic64_inc(atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "incq %0"
 		     : "=m" (v->counter)
@@ -89,12 +89,12 @@ static __always_inline void atomic64_inc(atomic64_t *v)
 }
 
 /**
- * atomic64_dec - decrement atomic64 variable
+ * arch_atomic64_dec - decrement atomic64 variable
  * @v: pointer to type atomic64_t
  *
  * Atomically decrements @v by 1.
  */
-static __always_inline void atomic64_dec(atomic64_t *v)
+static __always_inline void arch_atomic64_dec(atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "decq %0"
 		     : "=m" (v->counter)
@@ -102,33 +102,33 @@ static __always_inline void atomic64_dec(atomic64_t *v)
 }
 
 /**
- * atomic64_dec_and_test - decrement and test
+ * arch_atomic64_dec_and_test - decrement and test
  * @v: pointer to type atomic64_t
  *
  * Atomically decrements @v by 1 and
  * returns true if the result is 0, or false for all other
  * cases.
  */
-static inline bool atomic64_dec_and_test(atomic64_t *v)
+static inline bool arch_atomic64_dec_and_test(atomic64_t *v)
 {
 	GEN_UNARY_RMWcc(LOCK_PREFIX "decq", v->counter, "%0", e);
 }
 
 /**
- * atomic64_inc_and_test - increment and test
+ * arch_atomic64_inc_and_test - increment and test
  * @v: pointer to type atomic64_t
  *
  * Atomically increments @v by 1
  * and returns true if the result is zero, or false for all
  * other cases.
  */
-static inline bool atomic64_inc_and_test(atomic64_t *v)
+static inline bool arch_atomic64_inc_and_test(atomic64_t *v)
 {
 	GEN_UNARY_RMWcc(LOCK_PREFIX "incq", v->counter, "%0", e);
 }
 
 /**
- * atomic64_add_negative - add and test if negative
+ * arch_atomic64_add_negative - add and test if negative
  * @i: integer value to add
  * @v: pointer to type atomic64_t
  *
@@ -136,59 +136,59 @@ static inline bool atomic64_inc_and_test(atomic64_t *v)
  * if the result is negative, or false when
  * result is greater than or equal to zero.
  */
-static inline bool atomic64_add_negative(long long i, atomic64_t *v)
+static inline bool arch_atomic64_add_negative(long long i, atomic64_t *v)
 {
 	GEN_BINARY_RMWcc(LOCK_PREFIX "addq", v->counter, "er", i, "%0", s);
 }
 
 /**
- * atomic64_add_return - add and return
+ * arch_atomic64_add_return - add and return
  * @i: integer value to add
  * @v: pointer to type atomic64_t
  *
  * Atomically adds @i to @v and returns @i + @v
  */
-static __always_inline long long atomic64_add_return(long long i, atomic64_t *v)
+static __always_inline long long arch_atomic64_add_return(long long i, atomic64_t *v)
 {
 	return i + xadd(&v->counter, i);
 }
 
-static inline long long atomic64_sub_return(long long i, atomic64_t *v)
+static inline long long arch_atomic64_sub_return(long long i, atomic64_t *v)
 {
-	return atomic64_add_return(-i, v);
+	return arch_atomic64_add_return(-i, v);
 }
 
-static inline long long atomic64_fetch_add(long long i, atomic64_t *v)
+static inline long long arch_atomic64_fetch_add(long long i, atomic64_t *v)
 {
 	return xadd(&v->counter, i);
 }
 
-static inline long long atomic64_fetch_sub(long long i, atomic64_t *v)
+static inline long long arch_atomic64_fetch_sub(long long i, atomic64_t *v)
 {
 	return xadd(&v->counter, -i);
 }
 
-#define atomic64_inc_return(v)  (atomic64_add_return(1, (v)))
-#define atomic64_dec_return(v)  (atomic64_sub_return(1, (v)))
+#define arch_atomic64_inc_return(v)  (arch_atomic64_add_return(1, (v)))
+#define arch_atomic64_dec_return(v)  (arch_atomic64_sub_return(1, (v)))
 
-static inline long long atomic64_cmpxchg(atomic64_t *v, long long old, long long new)
+static inline long long arch_atomic64_cmpxchg(atomic64_t *v, long long old, long long new)
 {
-	return cmpxchg(&v->counter, old, new);
+	return arch_cmpxchg(&v->counter, old, new);
 }
 
-#define atomic64_try_cmpxchg atomic64_try_cmpxchg
-static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, long long *old, long long new)
+#define arch_atomic64_try_cmpxchg arch_atomic64_try_cmpxchg
+static __always_inline bool arch_atomic64_try_cmpxchg(atomic64_t *v, long long *old, long long new)
 {
-	return try_cmpxchg(&v->counter, old, new);
+	return arch_try_cmpxchg(&v->counter, old, new);
 }
 
-static inline long long atomic64_xchg(atomic64_t *v, long long new)
+static inline long long arch_atomic64_xchg(atomic64_t *v, long long new)
 {
 	return xchg(&v->counter, new);
 }
 
 /**
- * atomic64_add_unless - add unless the number is a given value
+ * arch_atomic64_add_unless - add unless the number is a given value
  * @v: pointer of type atomic64_t
  * @a: the amount to add to v...
  * @u: ...unless v is equal to u.
@@ -196,37 +196,37 @@ static inline long long atomic64_xchg(atomic64_t *v, long long new)
  * Atomically adds @a to @v, so long long as it was not @u.
  * Returns the old value of @v.
  */
-static inline bool atomic64_add_unless(atomic64_t *v, long long a, long long u)
+static inline bool arch_atomic64_add_unless(atomic64_t *v, long long a, long long u)
 {
-	long long c = atomic64_read(v);
+	long long c = arch_atomic64_read(v);
 	do {
 		if (unlikely(c == u))
 			return false;
-	} while (!atomic64_try_cmpxchg(v, &c, c + a));
+	} while (!arch_atomic64_try_cmpxchg(v, &c, c + a));
 	return true;
 }
 
-#define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
+#define arch_atomic64_inc_not_zero(v) arch_atomic64_add_unless((v), 1, 0)
 
 /*
- * atomic64_dec_if_positive - decrement by 1 if old value positive
+ * arch_atomic64_dec_if_positive - decrement by 1 if old value positive
  * @v: pointer of type atomic_t
  *
  * The function returns the old value of *v minus 1, even if
  * the atomic variable, v, was not decremented.
  */
-static inline long long atomic64_dec_if_positive(atomic64_t *v)
+static inline long long arch_atomic64_dec_if_positive(atomic64_t *v)
 {
-	long long dec, c = atomic64_read(v);
+	long long dec, c = arch_atomic64_read(v);
 	do {
 		dec = c - 1;
 		if (unlikely(dec < 0))
 			break;
-	} while (!atomic64_try_cmpxchg(v, &c, dec));
+	} while (!arch_atomic64_try_cmpxchg(v, &c, dec));
 	return dec;
 }
 
-static inline void atomic64_and(long long i, atomic64_t *v)
+static inline void arch_atomic64_and(long long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "andq %1,%0"
 			: "+m" (v->counter)
@@ -234,16 +234,16 @@ static inline void atomic64_and(long long i, atomic64_t *v)
 			: "memory");
 }
 
-static inline long long atomic64_fetch_and(long long i, atomic64_t *v)
+static inline long long arch_atomic64_fetch_and(long long i, atomic64_t *v)
 {
-	long long val = atomic64_read(v);
+	long long val = arch_atomic64_read(v);
 
 	do {
-	} while (!atomic64_try_cmpxchg(v, &val, val & i));
+	} while (!arch_atomic64_try_cmpxchg(v, &val, val & i));
 	return val;
 }
 
-static inline void atomic64_or(long long i, atomic64_t *v)
+static inline void arch_atomic64_or(long long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "orq %1,%0"
 			: "+m" (v->counter)
@@ -251,16 +251,16 @@ static inline void atomic64_or(long long i, atomic64_t *v)
 			: "memory");
 }
 
-static inline long long atomic64_fetch_or(long long i, atomic64_t *v)
+static inline long long arch_atomic64_fetch_or(long long i, atomic64_t *v)
 {
-	long long val = atomic64_read(v);
+	long long val = arch_atomic64_read(v);
 
 	do {
-	} while (!atomic64_try_cmpxchg(v, &val, val | i));
+	} while (!arch_atomic64_try_cmpxchg(v, &val, val | i));
 	return val;
 }
 
-static inline void atomic64_xor(long long i, atomic64_t *v)
+static inline void arch_atomic64_xor(long long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "xorq %1,%0"
 			: "+m" (v->counter)
@@ -268,12 +268,12 @@ static inline void atomic64_xor(long long i, atomic64_t *v)
 			: "memory");
 }
 
-static inline long long atomic64_fetch_xor(long long i, atomic64_t *v)
+static inline long long arch_atomic64_fetch_xor(long long i, atomic64_t *v)
 {
-	long long val = atomic64_read(v);
+	long long val = arch_atomic64_read(v);
 
 	do {
-	} while (!atomic64_try_cmpxchg(v, &val, val ^ i));
+	} while (!arch_atomic64_try_cmpxchg(v, &val, val ^ i));
 	return val;
 }
 
diff --git a/arch/x86/include/asm/cmpxchg.h b/arch/x86/include/asm/cmpxchg.h
index fb961db51a2a..b4e70a0b1238 100644
--- a/arch/x86/include/asm/cmpxchg.h
+++ b/arch/x86/include/asm/cmpxchg.h
@@ -144,20 +144,20 @@ extern void __add_wrong_size(void)
 # include <asm/cmpxchg_64.h>
 #endif
 
-#define cmpxchg(ptr, old, new)						\
+#define arch_cmpxchg(ptr, old, new)					\
 	__cmpxchg(ptr, old, new, sizeof(*(ptr)))
 
-#define sync_cmpxchg(ptr, old, new)					\
+#define arch_sync_cmpxchg(ptr, old, new)				\
 	__sync_cmpxchg(ptr, old, new, sizeof(*(ptr)))
 
-#define cmpxchg_local(ptr, old, new)					\
+#define arch_cmpxchg_local(ptr, old, new)				\
 	__cmpxchg_local(ptr, old, new, sizeof(*(ptr)))
 
 
 #define __raw_try_cmpxchg(_ptr, _pold, _new, size, lock)		\
 ({									\
 	bool success;							\
-	__typeof__(_ptr) _old = (_pold);				\
+	__typeof__(_pold) _old = (_pold);				\
 	__typeof__(*(_ptr)) __old = *_old;				\
 	__typeof__(*(_ptr)) __new = (_new);				\
 	switch (size) {							\
@@ -219,7 +219,7 @@ extern void __add_wrong_size(void)
 #define __try_cmpxchg(ptr, pold, new, size)				\
 	__raw_try_cmpxchg((ptr), (pold), (new), (size), LOCK_PREFIX)
 
-#define try_cmpxchg(ptr, pold, new)					\
+#define arch_try_cmpxchg(ptr, pold, new)				\
 	__try_cmpxchg((ptr), (pold), (new), sizeof(*(ptr)))
 
 /*
@@ -248,10 +248,10 @@ extern void __add_wrong_size(void)
 	__ret;								\
 })
 
-#define cmpxchg_double(p1, p2, o1, o2, n1, n2) \
+#define arch_cmpxchg_double(p1, p2, o1, o2, n1, n2) \
 	__cmpxchg_double(LOCK_PREFIX, p1, p2, o1, o2, n1, n2)
 
-#define cmpxchg_double_local(p1, p2, o1, o2, n1, n2) \
+#define arch_cmpxchg_double_local(p1, p2, o1, o2, n1, n2) \
 	__cmpxchg_double(, p1, p2, o1, o2, n1, n2)
 
 #endif	/* ASM_X86_CMPXCHG_H */
diff --git a/arch/x86/include/asm/cmpxchg_32.h b/arch/x86/include/asm/cmpxchg_32.h
index e4959d023af8..d897291d2bf9 100644
--- a/arch/x86/include/asm/cmpxchg_32.h
+++ b/arch/x86/include/asm/cmpxchg_32.h
@@ -35,10 +35,10 @@ static inline void set_64bit(volatile u64 *ptr, u64 value)
 }
 
 #ifdef CONFIG_X86_CMPXCHG64
-#define cmpxchg64(ptr, o, n)						\
+#define arch_cmpxchg64(ptr, o, n)					\
 	((__typeof__(*(ptr)))__cmpxchg64((ptr), (unsigned long long)(o), \
 					 (unsigned long long)(n)))
-#define cmpxchg64_local(ptr, o, n)					\
+#define arch_cmpxchg64_local(ptr, o, n)					\
 	((__typeof__(*(ptr)))__cmpxchg64_local((ptr), (unsigned long long)(o), \
 					       (unsigned long long)(n)))
 #endif
@@ -75,7 +75,7 @@ static inline u64 __cmpxchg64_local(volatile u64 *ptr, u64 old, u64 new)
  * to simulate the cmpxchg8b on the 80386 and 80486 CPU.
  */
 
-#define cmpxchg64(ptr, o, n)					\
+#define arch_cmpxchg64(ptr, o, n)				\
 ({								\
 	__typeof__(*(ptr)) __ret;				\
 	__typeof__(*(ptr)) __old = (o);				\
@@ -92,7 +92,7 @@ static inline u64 __cmpxchg64_local(volatile u64 *ptr, u64 old, u64 new)
 	__ret; })
 
 
-#define cmpxchg64_local(ptr, o, n)				\
+#define arch_cmpxchg64_local(ptr, o, n)				\
 ({								\
 	__typeof__(*(ptr)) __ret;				\
 	__typeof__(*(ptr)) __old = (o);				\
diff --git a/arch/x86/include/asm/cmpxchg_64.h b/arch/x86/include/asm/cmpxchg_64.h
index caa23a34c963..fafaebacca2d 100644
--- a/arch/x86/include/asm/cmpxchg_64.h
+++ b/arch/x86/include/asm/cmpxchg_64.h
@@ -6,13 +6,13 @@ static inline void set_64bit(volatile u64 *ptr, u64 val)
 	*ptr = val;
 }
 
-#define cmpxchg64(ptr, o, n)						\
+#define arch_cmpxchg64(ptr, o, n)					\
 ({									\
 	BUILD_BUG_ON(sizeof(*(ptr)) != 8);				\
 	cmpxchg((ptr), (o), (n));					\
 })
 
-#define cmpxchg64_local(ptr, o, n)					\
+#define arch_cmpxchg64_local(ptr, o, n)					\
 ({									\
 	BUILD_BUG_ON(sizeof(*(ptr)) != 8);				\
 	cmpxchg_local((ptr), (o), (n));					\
-- 
2.12.2.564.g063fe858b8-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
