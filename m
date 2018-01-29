Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C89136B000C
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 12:30:34 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r82so5288848wme.0
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 09:30:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b8sor2376677wrf.33.2018.01.29.09.30.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jan 2018 09:30:32 -0800 (PST)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v6 2/4] x86: switch atomic.h to use atomic-instrumented.h
Date: Mon, 29 Jan 2018 18:26:05 +0100
Message-Id: <54f0eb64260b84199e538652e079a89b5423ad41.1517246437.git.dvyukov@google.com>
In-Reply-To: <cover.1517246437.git.dvyukov@google.com>
References: <cover.1517246437.git.dvyukov@google.com>
In-Reply-To: <cover.1517246437.git.dvyukov@google.com>
References: <cover.1517246437.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, x86@kernel.org, linux-kernel@vger.kernel.org, tglx@linutronix.de
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

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
Changes since v1:
 - reverted unnecessary change in __raw_try_cmpxchg()
 - reverted s/try_cmpxchg/arch_try_cmpxchg/ change
   try_cmpxchg is x86 implementation detail

Changes since v3:
 - drop comment in arch_atomic_set()
---
 arch/x86/include/asm/atomic.h      | 102 ++++++++++++++++++-----------------
 arch/x86/include/asm/atomic64_32.h | 106 ++++++++++++++++++------------------
 arch/x86/include/asm/atomic64_64.h | 108 ++++++++++++++++++-------------------
 arch/x86/include/asm/cmpxchg.h     |  12 ++---
 arch/x86/include/asm/cmpxchg_32.h  |   8 +--
 arch/x86/include/asm/cmpxchg_64.h  |   4 +-
 6 files changed, 172 insertions(+), 168 deletions(-)

diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
index 72759f131cc5..33afc966d6a9 100644
--- a/arch/x86/include/asm/atomic.h
+++ b/arch/x86/include/asm/atomic.h
@@ -17,36 +17,36 @@
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
@@ -54,13 +54,13 @@ static __always_inline void atomic_add(int i, atomic_t *v)
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
@@ -68,7 +68,7 @@ static __always_inline void atomic_sub(int i, atomic_t *v)
 }
 
 /**
- * atomic_sub_and_test - subtract value from variable and test result
+ * arch_atomic_sub_and_test - subtract value from variable and test result
  * @i: integer value to subtract
  * @v: pointer of type atomic_t
  *
@@ -76,63 +76,63 @@ static __always_inline void atomic_sub(int i, atomic_t *v)
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
@@ -140,65 +140,65 @@ static __always_inline bool atomic_inc_and_test(atomic_t *v)
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
 	return try_cmpxchg(&v->counter, old, new);
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
@@ -206,16 +206,16 @@ static inline void atomic_and(int i, atomic_t *v)
 			: "memory");
 }
 
-static inline int atomic_fetch_and(int i, atomic_t *v)
+static inline int arch_atomic_fetch_and(int i, atomic_t *v)
 {
-	int val = atomic_read(v);
+	int val = arch_atomic_read(v);
 
-	do { } while (!atomic_try_cmpxchg(v, &val, val & i));
+	do { } while (!arch_atomic_try_cmpxchg(v, &val, val & i));
 
 	return val;
 }
 
-static inline void atomic_or(int i, atomic_t *v)
+static inline void arch_atomic_or(int i, atomic_t *v)
 {
 	asm volatile(LOCK_PREFIX "orl %1,%0"
 			: "+m" (v->counter)
@@ -223,16 +223,16 @@ static inline void atomic_or(int i, atomic_t *v)
 			: "memory");
 }
 
-static inline int atomic_fetch_or(int i, atomic_t *v)
+static inline int arch_atomic_fetch_or(int i, atomic_t *v)
 {
-	int val = atomic_read(v);
+	int val = arch_atomic_read(v);
 
-	do { } while (!atomic_try_cmpxchg(v, &val, val | i));
+	do { } while (!arch_atomic_try_cmpxchg(v, &val, val | i));
 
 	return val;
 }
 
-static inline void atomic_xor(int i, atomic_t *v)
+static inline void arch_atomic_xor(int i, atomic_t *v)
 {
 	asm volatile(LOCK_PREFIX "xorl %1,%0"
 			: "+m" (v->counter)
@@ -240,17 +240,17 @@ static inline void atomic_xor(int i, atomic_t *v)
 			: "memory");
 }
 
-static inline int atomic_fetch_xor(int i, atomic_t *v)
+static inline int arch_atomic_fetch_xor(int i, atomic_t *v)
 {
-	int val = atomic_read(v);
+	int val = arch_atomic_read(v);
 
-	do { } while (!atomic_try_cmpxchg(v, &val, val ^ i));
+	do { } while (!arch_atomic_try_cmpxchg(v, &val, val ^ i));
 
 	return val;
 }
 
 /**
- * __atomic_add_unless - add unless the number is already a given value
+ * __arch_atomic_add_unless - add unless the number is already a given value
  * @v: pointer of type atomic_t
  * @a: the amount to add to v...
  * @u: ...unless v is equal to u.
@@ -258,14 +258,14 @@ static inline int atomic_fetch_xor(int i, atomic_t *v)
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
@@ -276,4 +276,6 @@ static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
 # include <asm/atomic64_64.h>
 #endif
 
+#include <asm-generic/atomic-instrumented.h>
+
 #endif /* _ASM_X86_ATOMIC_H */
diff --git a/arch/x86/include/asm/atomic64_32.h b/arch/x86/include/asm/atomic64_32.h
index 97c46b8169b7..46e1ef17d92d 100644
--- a/arch/x86/include/asm/atomic64_32.h
+++ b/arch/x86/include/asm/atomic64_32.h
@@ -62,7 +62,7 @@ ATOMIC64_DECL(add_unless);
 #undef ATOMIC64_EXPORT
 
 /**
- * atomic64_cmpxchg - cmpxchg atomic64 variable
+ * arch_atomic64_cmpxchg - cmpxchg atomic64 variable
  * @v: pointer to type atomic64_t
  * @o: expected value
  * @n: new value
@@ -71,20 +71,21 @@ ATOMIC64_DECL(add_unless);
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
@@ -96,13 +97,13 @@ static inline long long atomic64_xchg(atomic64_t *v, long long n)
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
@@ -112,12 +113,12 @@ static inline void atomic64_set(atomic64_t *v, long long i)
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
@@ -125,13 +126,13 @@ static inline long long atomic64_read(const atomic64_t *v)
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
@@ -142,7 +143,7 @@ static inline long long atomic64_add_return(long long i, atomic64_t *v)
 /*
  * Other variants with different arithmetic operators:
  */
-static inline long long atomic64_sub_return(long long i, atomic64_t *v)
+static inline long long arch_atomic64_sub_return(long long i, atomic64_t *v)
 {
 	alternative_atomic64(sub_return,
 			     ASM_OUTPUT2("+A" (i), "+c" (v)),
@@ -150,7 +151,7 @@ static inline long long atomic64_sub_return(long long i, atomic64_t *v)
 	return i;
 }
 
-static inline long long atomic64_inc_return(atomic64_t *v)
+static inline long long arch_atomic64_inc_return(atomic64_t *v)
 {
 	long long a;
 	alternative_atomic64(inc_return, "=&A" (a),
@@ -158,7 +159,7 @@ static inline long long atomic64_inc_return(atomic64_t *v)
 	return a;
 }
 
-static inline long long atomic64_dec_return(atomic64_t *v)
+static inline long long arch_atomic64_dec_return(atomic64_t *v)
 {
 	long long a;
 	alternative_atomic64(dec_return, "=&A" (a),
@@ -167,13 +168,13 @@ static inline long long atomic64_dec_return(atomic64_t *v)
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
@@ -182,13 +183,13 @@ static inline long long atomic64_add(long long i, atomic64_t *v)
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
@@ -197,7 +198,7 @@ static inline long long atomic64_sub(long long i, atomic64_t *v)
 }
 
 /**
- * atomic64_sub_and_test - subtract value from variable and test result
+ * arch_atomic64_sub_and_test - subtract value from variable and test result
  * @i: integer value to subtract
  * @v: pointer to type atomic64_t
  *
@@ -205,46 +206,46 @@ static inline long long atomic64_sub(long long i, atomic64_t *v)
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
@@ -255,13 +256,13 @@ static inline int atomic64_dec_and_test(atomic64_t *v)
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
@@ -269,13 +270,13 @@ static inline int atomic64_inc_and_test(atomic64_t *v)
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
@@ -283,7 +284,8 @@ static inline int atomic64_add_negative(long long i, atomic64_t *v)
  * Atomically adds @a to @v, so long as it was not @u.
  * Returns non-zero if the add was done, zero otherwise.
  */
-static inline int atomic64_add_unless(atomic64_t *v, long long a, long long u)
+static inline int arch_atomic64_add_unless(atomic64_t *v, long long a,
+					   long long u)
 {
 	unsigned low = (unsigned)u;
 	unsigned high = (unsigned)(u >> 32);
@@ -294,7 +296,7 @@ static inline int atomic64_add_unless(atomic64_t *v, long long a, long long u)
 }
 
 
-static inline int atomic64_inc_not_zero(atomic64_t *v)
+static inline int arch_atomic64_inc_not_zero(atomic64_t *v)
 {
 	int r;
 	alternative_atomic64(inc_not_zero, "=&a" (r),
@@ -302,7 +304,7 @@ static inline int atomic64_inc_not_zero(atomic64_t *v)
 	return r;
 }
 
-static inline long long atomic64_dec_if_positive(atomic64_t *v)
+static inline long long arch_atomic64_dec_if_positive(atomic64_t *v)
 {
 	long long r;
 	alternative_atomic64(dec_if_positive, "=&A" (r),
@@ -313,70 +315,70 @@ static inline long long atomic64_dec_if_positive(atomic64_t *v)
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
index 738495caf05f..6106b59d3260 100644
--- a/arch/x86/include/asm/atomic64_64.h
+++ b/arch/x86/include/asm/atomic64_64.h
@@ -11,37 +11,37 @@
 #define ATOMIC64_INIT(i)	{ (i) }
 
 /**
- * atomic64_read - read atomic64 variable
+ * arch_atomic64_read - read atomic64 variable
  * @v: pointer of type atomic64_t
  *
  * Atomically reads the value of @v.
  * Doesn't imply a read memory barrier.
  */
-static inline long atomic64_read(const atomic64_t *v)
+static inline long arch_atomic64_read(const atomic64_t *v)
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
-static inline void atomic64_set(atomic64_t *v, long i)
+static inline void arch_atomic64_set(atomic64_t *v, long i)
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
-static __always_inline void atomic64_add(long i, atomic64_t *v)
+static __always_inline void arch_atomic64_add(long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "addq %1,%0"
 		     : "=m" (v->counter)
@@ -49,13 +49,13 @@ static __always_inline void atomic64_add(long i, atomic64_t *v)
 }
 
 /**
- * atomic64_sub - subtract the atomic64 variable
+ * arch_atomic64_sub - subtract the atomic64 variable
  * @i: integer value to subtract
  * @v: pointer to type atomic64_t
  *
  * Atomically subtracts @i from @v.
  */
-static inline void atomic64_sub(long i, atomic64_t *v)
+static inline void arch_atomic64_sub(long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "subq %1,%0"
 		     : "=m" (v->counter)
@@ -63,7 +63,7 @@ static inline void atomic64_sub(long i, atomic64_t *v)
 }
 
 /**
- * atomic64_sub_and_test - subtract value from variable and test result
+ * arch_atomic64_sub_and_test - subtract value from variable and test result
  * @i: integer value to subtract
  * @v: pointer to type atomic64_t
  *
@@ -71,18 +71,18 @@ static inline void atomic64_sub(long i, atomic64_t *v)
  * true if the result is zero, or false for all
  * other cases.
  */
-static inline bool atomic64_sub_and_test(long i, atomic64_t *v)
+static inline bool arch_atomic64_sub_and_test(long i, atomic64_t *v)
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
@@ -90,12 +90,12 @@ static __always_inline void atomic64_inc(atomic64_t *v)
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
@@ -103,33 +103,33 @@ static __always_inline void atomic64_dec(atomic64_t *v)
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
@@ -137,59 +137,59 @@ static inline bool atomic64_inc_and_test(atomic64_t *v)
  * if the result is negative, or false when
  * result is greater than or equal to zero.
  */
-static inline bool atomic64_add_negative(long i, atomic64_t *v)
+static inline bool arch_atomic64_add_negative(long i, atomic64_t *v)
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
-static __always_inline long atomic64_add_return(long i, atomic64_t *v)
+static __always_inline long arch_atomic64_add_return(long i, atomic64_t *v)
 {
 	return i + xadd(&v->counter, i);
 }
 
-static inline long atomic64_sub_return(long i, atomic64_t *v)
+static inline long arch_atomic64_sub_return(long i, atomic64_t *v)
 {
-	return atomic64_add_return(-i, v);
+	return arch_atomic64_add_return(-i, v);
 }
 
-static inline long atomic64_fetch_add(long i, atomic64_t *v)
+static inline long arch_atomic64_fetch_add(long i, atomic64_t *v)
 {
 	return xadd(&v->counter, i);
 }
 
-static inline long atomic64_fetch_sub(long i, atomic64_t *v)
+static inline long arch_atomic64_fetch_sub(long i, atomic64_t *v)
 {
 	return xadd(&v->counter, -i);
 }
 
-#define atomic64_inc_return(v)  (atomic64_add_return(1, (v)))
-#define atomic64_dec_return(v)  (atomic64_sub_return(1, (v)))
+#define arch_atomic64_inc_return(v)  (arch_atomic64_add_return(1, (v)))
+#define arch_atomic64_dec_return(v)  (arch_atomic64_sub_return(1, (v)))
 
-static inline long atomic64_cmpxchg(atomic64_t *v, long old, long new)
+static inline long arch_atomic64_cmpxchg(atomic64_t *v, long old, long new)
 {
-	return cmpxchg(&v->counter, old, new);
+	return arch_cmpxchg(&v->counter, old, new);
 }
 
-#define atomic64_try_cmpxchg atomic64_try_cmpxchg
-static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, s64 *old, long new)
+#define arch_atomic64_try_cmpxchg arch_atomic64_try_cmpxchg
+static __always_inline bool arch_atomic64_try_cmpxchg(atomic64_t *v, s64 *old, long new)
 {
 	return try_cmpxchg(&v->counter, old, new);
 }
 
-static inline long atomic64_xchg(atomic64_t *v, long new)
+static inline long arch_atomic64_xchg(atomic64_t *v, long new)
 {
 	return xchg(&v->counter, new);
 }
 
 /**
- * atomic64_add_unless - add unless the number is a given value
+ * arch_atomic64_add_unless - add unless the number is a given value
  * @v: pointer of type atomic64_t
  * @a: the amount to add to v...
  * @u: ...unless v is equal to u.
@@ -197,37 +197,37 @@ static inline long atomic64_xchg(atomic64_t *v, long new)
  * Atomically adds @a to @v, so long as it was not @u.
  * Returns the old value of @v.
  */
-static inline bool atomic64_add_unless(atomic64_t *v, long a, long u)
+static inline bool arch_atomic64_add_unless(atomic64_t *v, long a, long u)
 {
-	s64 c = atomic64_read(v);
+	s64 c = arch_atomic64_read(v);
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
-static inline long atomic64_dec_if_positive(atomic64_t *v)
+static inline long arch_atomic64_dec_if_positive(atomic64_t *v)
 {
-	s64 dec, c = atomic64_read(v);
+	s64 dec, c = arch_atomic64_read(v);
 	do {
 		dec = c - 1;
 		if (unlikely(dec < 0))
 			break;
-	} while (!atomic64_try_cmpxchg(v, &c, dec));
+	} while (!arch_atomic64_try_cmpxchg(v, &c, dec));
 	return dec;
 }
 
-static inline void atomic64_and(long i, atomic64_t *v)
+static inline void arch_atomic64_and(long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "andq %1,%0"
 			: "+m" (v->counter)
@@ -235,16 +235,16 @@ static inline void atomic64_and(long i, atomic64_t *v)
 			: "memory");
 }
 
-static inline long atomic64_fetch_and(long i, atomic64_t *v)
+static inline long arch_atomic64_fetch_and(long i, atomic64_t *v)
 {
-	s64 val = atomic64_read(v);
+	s64 val = arch_atomic64_read(v);
 
 	do {
-	} while (!atomic64_try_cmpxchg(v, &val, val & i));
+	} while (!arch_atomic64_try_cmpxchg(v, &val, val & i));
 	return val;
 }
 
-static inline void atomic64_or(long i, atomic64_t *v)
+static inline void arch_atomic64_or(long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "orq %1,%0"
 			: "+m" (v->counter)
@@ -252,16 +252,16 @@ static inline void atomic64_or(long i, atomic64_t *v)
 			: "memory");
 }
 
-static inline long atomic64_fetch_or(long i, atomic64_t *v)
+static inline long arch_atomic64_fetch_or(long i, atomic64_t *v)
 {
-	s64 val = atomic64_read(v);
+	s64 val = arch_atomic64_read(v);
 
 	do {
-	} while (!atomic64_try_cmpxchg(v, &val, val | i));
+	} while (!arch_atomic64_try_cmpxchg(v, &val, val | i));
 	return val;
 }
 
-static inline void atomic64_xor(long i, atomic64_t *v)
+static inline void arch_atomic64_xor(long i, atomic64_t *v)
 {
 	asm volatile(LOCK_PREFIX "xorq %1,%0"
 			: "+m" (v->counter)
@@ -269,12 +269,12 @@ static inline void atomic64_xor(long i, atomic64_t *v)
 			: "memory");
 }
 
-static inline long atomic64_fetch_xor(long i, atomic64_t *v)
+static inline long arch_atomic64_fetch_xor(long i, atomic64_t *v)
 {
-	s64 val = atomic64_read(v);
+	s64 val = arch_atomic64_read(v);
 
 	do {
-	} while (!atomic64_try_cmpxchg(v, &val, val ^ i));
+	} while (!arch_atomic64_try_cmpxchg(v, &val, val ^ i));
 	return val;
 }
 
diff --git a/arch/x86/include/asm/cmpxchg.h b/arch/x86/include/asm/cmpxchg.h
index 56bd436ed01b..e3efd8a06066 100644
--- a/arch/x86/include/asm/cmpxchg.h
+++ b/arch/x86/include/asm/cmpxchg.h
@@ -145,13 +145,13 @@ extern void __add_wrong_size(void)
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
 
 
@@ -221,7 +221,7 @@ extern void __add_wrong_size(void)
 #define __try_cmpxchg(ptr, pold, new, size)				\
 	__raw_try_cmpxchg((ptr), (pold), (new), (size), LOCK_PREFIX)
 
-#define try_cmpxchg(ptr, pold, new)					\
+#define try_cmpxchg(ptr, pold, new) 					\
 	__try_cmpxchg((ptr), (pold), (new), sizeof(*(ptr)))
 
 /*
@@ -250,10 +250,10 @@ extern void __add_wrong_size(void)
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
index 1732704f0445..1a2eafca7038 100644
--- a/arch/x86/include/asm/cmpxchg_32.h
+++ b/arch/x86/include/asm/cmpxchg_32.h
@@ -36,10 +36,10 @@ static inline void set_64bit(volatile u64 *ptr, u64 value)
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
@@ -76,7 +76,7 @@ static inline u64 __cmpxchg64_local(volatile u64 *ptr, u64 old, u64 new)
  * to simulate the cmpxchg8b on the 80386 and 80486 CPU.
  */
 
-#define cmpxchg64(ptr, o, n)					\
+#define arch_cmpxchg64(ptr, o, n)				\
 ({								\
 	__typeof__(*(ptr)) __ret;				\
 	__typeof__(*(ptr)) __old = (o);				\
@@ -93,7 +93,7 @@ static inline u64 __cmpxchg64_local(volatile u64 *ptr, u64 old, u64 new)
 	__ret; })
 
 
-#define cmpxchg64_local(ptr, o, n)				\
+#define arch_cmpxchg64_local(ptr, o, n)				\
 ({								\
 	__typeof__(*(ptr)) __ret;				\
 	__typeof__(*(ptr)) __old = (o);				\
diff --git a/arch/x86/include/asm/cmpxchg_64.h b/arch/x86/include/asm/cmpxchg_64.h
index 03cad196a301..bfca3b346c74 100644
--- a/arch/x86/include/asm/cmpxchg_64.h
+++ b/arch/x86/include/asm/cmpxchg_64.h
@@ -7,13 +7,13 @@ static inline void set_64bit(volatile u64 *ptr, u64 val)
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
2.16.0.rc1.238.g530d649a79-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
