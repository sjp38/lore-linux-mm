Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE6366B038F
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 15:24:23 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id y90so53200884wrb.1
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:24:23 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id k20si988545wmc.118.2017.03.14.12.24.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 12:24:22 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id v186so71935661wmd.0
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:24:22 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Date: Tue, 14 Mar 2017 20:24:13 +0100
Message-Id: <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
In-Reply-To: <cover.1489519233.git.dvyukov@google.com>
References: <cover.1489519233.git.dvyukov@google.com>
In-Reply-To: <cover.1489519233.git.dvyukov@google.com>
References: <cover.1489519233.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, aryabinin@virtuozzo.com, mingo@redhat.com
Cc: will.deacon@arm.com, akpm@linux-foundation.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>

KASAN uses compiler instrumentation to intercept all memory accesses.
But it does not see memory accesses done in assembly code.
One notable user of assembly code is atomic operations. Frequently,
for example, an atomic reference decrement is the last access to an
object and a good candidate for a racy use-after-free.

Atomic operations are defined in arch files, but KASAN instrumentation
is required for several archs that support KASAN. Later we will need
similar hooks for KMSAN (uninit use detector) and KTSAN (data race
detector).

This change introduces wrappers around atomic operations that can be
used to add KASAN/KMSAN/KTSAN instrumentation across several archs.
This patch uses the wrappers only for x86 arch. Arm64 will be switched
later.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>,
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
Cc: Ingo Molnar <mingo@redhat.com>,
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: x86@kernel.org
---
 arch/x86/include/asm/atomic.h             | 100 +++++++-------
 arch/x86/include/asm/atomic64_32.h        |  86 ++++++------
 arch/x86/include/asm/atomic64_64.h        |  90 ++++++-------
 arch/x86/include/asm/cmpxchg.h            |  12 +-
 arch/x86/include/asm/cmpxchg_32.h         |   8 +-
 arch/x86/include/asm/cmpxchg_64.h         |   4 +-
 include/asm-generic/atomic-instrumented.h | 210 ++++++++++++++++++++++++++++++
 7 files changed, 367 insertions(+), 143 deletions(-)

diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
index 14635c5ea025..95dd167eb3af 100644
--- a/arch/x86/include/asm/atomic.h
+++ b/arch/x86/include/asm/atomic.h
@@ -16,36 +16,46 @@
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
-	return READ_ONCE((v)->counter);
+	/*
+	 * We use READ_ONCE_NOCHECK() because atomic_read() contains KASAN
+	 * instrumentation. Double instrumentation is unnecessary.
+	 */
+	return READ_ONCE_NOCHECK((v)->counter);
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
@@ -53,13 +63,13 @@ static __always_inline void atomic_add(int i, atomic_t *v)
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
@@ -67,7 +77,7 @@ static __always_inline void atomic_sub(int i, atomic_t *v)
 }
 
 /**
- * atomic_sub_and_test - subtract value from variable and test result
+ * arch_atomic_sub_and_test - subtract value from variable and test result
  * @i: integer value to subtract
  * @v: pointer of type atomic_t
  *
@@ -75,63 +85,63 @@ static __always_inline void atomic_sub(int i, atomic_t *v)
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
@@ -139,60 +149,60 @@ static __always_inline bool atomic_inc_and_test(atomic_t *v)
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
 
-static inline int atomic_xchg(atomic_t *v, int new)
+static inline int arch_atomic_xchg(atomic_t *v, int new)
 {
-	return xchg(&v->counter, new);
+	return arch_xchg(&v->counter, new);
 }
 
 #define ATOMIC_OP(op)							\
-static inline void atomic_##op(int i, atomic_t *v)			\
+static inline void arch_atomic_##op(int i, atomic_t *v)			\
 {									\
 	asm volatile(LOCK_PREFIX #op"l %1,%0"				\
 			: "+m" (v->counter)				\
@@ -201,11 +211,11 @@ static inline void atomic_##op(int i, atomic_t *v)			\
 }
 
 #define ATOMIC_FETCH_OP(op, c_op)					\
-static inline int atomic_fetch_##op(int i, atomic_t *v)		\
+static inline int arch_atomic_fetch_##op(int i, atomic_t *v)		\
 {									\
-	int old, val = atomic_read(v);					\
+	int old, val = arch_atomic_read(v);				\
 	for (;;) {							\
-		old = atomic_cmpxchg(v, val, val c_op i);		\
+		old = arch_atomic_cmpxchg(v, val, val c_op i);		\
 		if (old == val)						\
 			break;						\
 		val = old;						\
@@ -226,7 +236,7 @@ ATOMIC_OPS(xor, ^)
 #undef ATOMIC_OP
 
 /**
- * __atomic_add_unless - add unless the number is already a given value
+ * __arch_atomic_add_unless - add unless the number is already a given value
  * @v: pointer of type atomic_t
  * @a: the amount to add to v...
  * @u: ...unless v is equal to u.
@@ -234,14 +244,14 @@ ATOMIC_OPS(xor, ^)
  * Atomically adds @a to @v, so long as @v was not already @u.
  * Returns the old value of @v.
  */
-static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
+static __always_inline int __arch_atomic_add_unless(atomic_t *v, int a, int u)
 {
 	int c, old;
-	c = atomic_read(v);
+	c = arch_atomic_read(v);
 	for (;;) {
 		if (unlikely(c == (u)))
 			break;
-		old = atomic_cmpxchg((v), c, c + (a));
+		old = arch_atomic_cmpxchg((v), c, c + (a));
 		if (likely(old == c))
 			break;
 		c = old;
@@ -250,13 +260,13 @@ static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
 }
 
 /**
- * atomic_inc_short - increment of a short integer
+ * arch_atomic_inc_short - increment of a short integer
  * @v: pointer to type int
  *
  * Atomically adds 1 to @v
  * Returns the new value of @u
  */
-static __always_inline short int atomic_inc_short(short int *v)
+static __always_inline short int arch_atomic_inc_short(short int *v)
 {
 	asm(LOCK_PREFIX "addw $1, %0" : "+m" (*v));
 	return *v;
@@ -268,4 +278,6 @@ static __always_inline short int atomic_inc_short(short int *v)
 # include <asm/atomic64_64.h>
 #endif
 
+#include <asm-generic/atomic-instrumented.h>
+
 #endif /* _ASM_X86_ATOMIC_H */
diff --git a/arch/x86/include/asm/atomic64_32.h b/arch/x86/include/asm/atomic64_32.h
index 71d7705fb303..4a48b20000f3 100644
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
@@ -313,25 +315,25 @@ static inline long long atomic64_dec_if_positive(atomic64_t *v)
 #undef __alternative_atomic64
 
 #define ATOMIC64_OP(op, c_op)						\
-static inline void atomic64_##op(long long i, atomic64_t *v)		\
+static inline void arch_atomic64_##op(long long i, atomic64_t *v)	\
 {									\
 	long long old, c = 0;						\
-	while ((old = atomic64_cmpxchg(v, c, c c_op i)) != c)		\
+	while ((old = arch_atomic64_cmpxchg(v, c, c c_op i)) != c)	\
 		c = old;						\
 }
 
 #define ATOMIC64_FETCH_OP(op, c_op)					\
-static inline long long atomic64_fetch_##op(long long i, atomic64_t *v)	\
+static inline long long arch_atomic64_fetch_##op(long long i, atomic64_t *v) \
 {									\
 	long long old, c = 0;						\
-	while ((old = atomic64_cmpxchg(v, c, c c_op i)) != c)		\
+	while ((old = arch_atomic64_cmpxchg(v, c, c c_op i)) != c)	\
 		c = old;						\
 	return old;							\
 }
 
 ATOMIC64_FETCH_OP(add, +)
 
-#define atomic64_fetch_sub(i, v)	atomic64_fetch_add(-(i), (v))
+#define arch_atomic64_fetch_sub(i, v)	arch_atomic64_fetch_add(-(i), (v))
 
 #define ATOMIC64_OPS(op, c_op)						\
 	ATOMIC64_OP(op, c_op)						\
diff --git a/arch/x86/include/asm/atomic64_64.h b/arch/x86/include/asm/atomic64_64.h
index 89ed2f6ae2f7..de9555d35cb0 100644
--- a/arch/x86/include/asm/atomic64_64.h
+++ b/arch/x86/include/asm/atomic64_64.h
@@ -16,31 +16,31 @@
  * Atomically reads the value of @v.
  * Doesn't imply a read memory barrier.
  */
-static inline long atomic64_read(const atomic64_t *v)
+static inline long arch_atomic64_read(const atomic64_t *v)
 {
-	return READ_ONCE((v)->counter);
+	return READ_ONCE_NOCHECK((v)->counter);
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
@@ -48,13 +48,13 @@ static __always_inline void atomic64_add(long i, atomic64_t *v)
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
@@ -62,7 +62,7 @@ static inline void atomic64_sub(long i, atomic64_t *v)
 }
 
 /**
- * atomic64_sub_and_test - subtract value from variable and test result
+ * arch_atomic64_sub_and_test - subtract value from variable and test result
  * @i: integer value to subtract
  * @v: pointer to type atomic64_t
  *
@@ -70,18 +70,18 @@ static inline void atomic64_sub(long i, atomic64_t *v)
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
@@ -136,53 +136,53 @@ static inline bool atomic64_inc_and_test(atomic64_t *v)
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
 
-static inline long atomic64_xchg(atomic64_t *v, long new)
+static inline long arch_atomic64_xchg(atomic64_t *v, long new)
 {
-	return xchg(&v->counter, new);
+	return arch_xchg(&v->counter, new);
 }
 
 /**
- * atomic64_add_unless - add unless the number is a given value
+ * arch_atomic64_add_unless - add unless the number is a given value
  * @v: pointer of type atomic64_t
  * @a: the amount to add to v...
  * @u: ...unless v is equal to u.
@@ -190,14 +190,14 @@ static inline long atomic64_xchg(atomic64_t *v, long new)
  * Atomically adds @a to @v, so long as it was not @u.
  * Returns the old value of @v.
  */
-static inline bool atomic64_add_unless(atomic64_t *v, long a, long u)
+static inline bool arch_atomic64_add_unless(atomic64_t *v, long a, long u)
 {
 	long c, old;
-	c = atomic64_read(v);
+	c = arch_atomic64_read(v);
 	for (;;) {
 		if (unlikely(c == (u)))
 			break;
-		old = atomic64_cmpxchg((v), c, c + (a));
+		old = arch_atomic64_cmpxchg((v), c, c + (a));
 		if (likely(old == c))
 			break;
 		c = old;
@@ -205,24 +205,24 @@ static inline bool atomic64_add_unless(atomic64_t *v, long a, long u)
 	return c != (u);
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
 	long c, old, dec;
-	c = atomic64_read(v);
+	c = arch_atomic64_read(v);
 	for (;;) {
 		dec = c - 1;
 		if (unlikely(dec < 0))
 			break;
-		old = atomic64_cmpxchg((v), c, dec);
+		old = arch_atomic64_cmpxchg((v), c, dec);
 		if (likely(old == c))
 			break;
 		c = old;
@@ -231,7 +231,7 @@ static inline long atomic64_dec_if_positive(atomic64_t *v)
 }
 
 #define ATOMIC64_OP(op)							\
-static inline void atomic64_##op(long i, atomic64_t *v)			\
+static inline void arch_atomic64_##op(long i, atomic64_t *v)		\
 {									\
 	asm volatile(LOCK_PREFIX #op"q %1,%0"				\
 			: "+m" (v->counter)				\
@@ -240,11 +240,11 @@ static inline void atomic64_##op(long i, atomic64_t *v)			\
 }
 
 #define ATOMIC64_FETCH_OP(op, c_op)					\
-static inline long atomic64_fetch_##op(long i, atomic64_t *v)		\
+static inline long arch_atomic64_fetch_##op(long i, atomic64_t *v)	\
 {									\
-	long old, val = atomic64_read(v);				\
+	long old, val = arch_atomic64_read(v);				\
 	for (;;) {							\
-		old = atomic64_cmpxchg(v, val, val c_op i);		\
+		old = arch_atomic64_cmpxchg(v, val, val c_op i);	\
 		if (old == val)						\
 			break;						\
 		val = old;						\
diff --git a/arch/x86/include/asm/cmpxchg.h b/arch/x86/include/asm/cmpxchg.h
index 97848cdfcb1a..75f09809666f 100644
--- a/arch/x86/include/asm/cmpxchg.h
+++ b/arch/x86/include/asm/cmpxchg.h
@@ -74,7 +74,7 @@ extern void __add_wrong_size(void)
  * use "asm volatile" and "memory" clobbers to prevent gcc from moving
  * information around.
  */
-#define xchg(ptr, v)	__xchg_op((ptr), (v), xchg, "")
+#define arch_xchg(ptr, v)	__xchg_op((ptr), (v), xchg, "")
 
 /*
  * Atomic compare and exchange.  Compare OLD with MEM, if identical,
@@ -144,13 +144,13 @@ extern void __add_wrong_size(void)
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
 
 /*
@@ -179,10 +179,10 @@ extern void __add_wrong_size(void)
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
diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
new file mode 100644
index 000000000000..41e5e6ffdfc8
--- /dev/null
+++ b/include/asm-generic/atomic-instrumented.h
@@ -0,0 +1,210 @@
+#ifndef _LINUX_ATOMIC_INSTRUMENTED_H
+#define _LINUX_ATOMIC_INSTRUMENTED_H
+
+static __always_inline int atomic_read(const atomic_t *v)
+{
+	return arch_atomic_read(v);
+}
+
+static __always_inline long long atomic64_read(const atomic64_t *v)
+{
+	return arch_atomic64_read(v);
+}
+
+
+static __always_inline void atomic_set(atomic_t *v, int i)
+{
+	arch_atomic_set(v, i);
+}
+
+static __always_inline void atomic64_set(atomic64_t *v, long long i)
+{
+	arch_atomic64_set(v, i);
+}
+
+static __always_inline int atomic_xchg(atomic_t *v, int i)
+{
+	return arch_atomic_xchg(v, i);
+}
+
+static __always_inline long long atomic64_xchg(atomic64_t *v, long long i)
+{
+	return arch_atomic64_xchg(v, i);
+}
+
+static __always_inline int atomic_cmpxchg(atomic_t *v, int old, int new)
+{
+	return arch_atomic_cmpxchg(v, old, new);
+}
+
+static __always_inline long long atomic64_cmpxchg(atomic64_t *v, long long old,
+						  long long new)
+{
+	return arch_atomic64_cmpxchg(v, old, new);
+}
+
+static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
+{
+	return __arch_atomic_add_unless(v, a, u);
+}
+
+
+static __always_inline bool atomic64_add_unless(atomic64_t *v, long long a,
+						long long u)
+{
+	return arch_atomic64_add_unless(v, a, u);
+}
+
+static __always_inline short int atomic_inc_short(short int *v)
+{
+	return arch_atomic_inc_short(v);
+}
+
+#define __INSTR_VOID1(op, sz)						\
+static __always_inline void atomic##sz##_##op(atomic##sz##_t *v)	\
+{									\
+	arch_atomic##sz##_##op(v);					\
+}
+
+#define INSTR_VOID1(op)	\
+__INSTR_VOID1(op,);	\
+__INSTR_VOID1(op, 64)
+
+INSTR_VOID1(inc);
+INSTR_VOID1(dec);
+
+#undef __INSTR_VOID1
+#undef INSTR_VOID1
+
+#define __INSTR_VOID2(op, sz, type)					\
+static __always_inline void atomic##sz##_##op(type i, atomic##sz##_t *v)\
+{									\
+	arch_atomic##sz##_##op(i, v);					\
+}
+
+#define INSTR_VOID2(op)		\
+__INSTR_VOID2(op, , int);	\
+__INSTR_VOID2(op, 64, long long)
+
+INSTR_VOID2(add);
+INSTR_VOID2(sub);
+INSTR_VOID2(and);
+INSTR_VOID2(or);
+INSTR_VOID2(xor);
+
+#undef __INSTR_VOID2
+#undef INSTR_VOID2
+
+#define __INSTR_RET1(op, sz, type, rtype)				\
+static __always_inline rtype atomic##sz##_##op(atomic##sz##_t *v)	\
+{									\
+	return arch_atomic##sz##_##op(v);				\
+}
+
+#define INSTR_RET1(op)		\
+__INSTR_RET1(op, , int, int);	\
+__INSTR_RET1(op, 64, long long, long long)
+
+INSTR_RET1(inc_return);
+INSTR_RET1(dec_return);
+__INSTR_RET1(inc_not_zero, 64, long long, long long);
+__INSTR_RET1(dec_if_positive, 64, long long, long long);
+
+#define INSTR_RET_BOOL1(op)	\
+__INSTR_RET1(op, , int, bool);	\
+__INSTR_RET1(op, 64, long long, bool)
+
+INSTR_RET_BOOL1(dec_and_test);
+INSTR_RET_BOOL1(inc_and_test);
+
+#undef __INSTR_RET1
+#undef INSTR_RET1
+#undef INSTR_RET_BOOL1
+
+#define __INSTR_RET2(op, sz, type, rtype)				\
+static __always_inline rtype atomic##sz##_##op(type i, atomic##sz##_t *v) \
+{									\
+	return arch_atomic##sz##_##op(i, v);				\
+}
+
+#define INSTR_RET2(op)		\
+__INSTR_RET2(op, , int, int);	\
+__INSTR_RET2(op, 64, long long, long long)
+
+INSTR_RET2(add_return);
+INSTR_RET2(sub_return);
+INSTR_RET2(fetch_add);
+INSTR_RET2(fetch_sub);
+INSTR_RET2(fetch_and);
+INSTR_RET2(fetch_or);
+INSTR_RET2(fetch_xor);
+
+#define INSTR_RET_BOOL2(op)		\
+__INSTR_RET2(op, , int, bool);		\
+__INSTR_RET2(op, 64, long long, bool)
+
+INSTR_RET_BOOL2(sub_and_test);
+INSTR_RET_BOOL2(add_negative);
+
+#undef __INSTR_RET2
+#undef INSTR_RET2
+#undef INSTR_RET_BOOL2
+
+/*
+ * In the following macros we need to be careful to not clash with arch_ macros.
+ * arch_xchg() can be defined as an extended statement expression as well,
+ * if we define a __ptr variable, and arch_xchg() also defines __ptr variable,
+ * and we pass __ptr as an argument to arch_xchg(), it will use own __ptr
+ * instead of ours. This leads to unpleasant crashes. To avoid the problem
+ * the following macros declare variables with lots of underscores.
+ */
+
+#define xchg(ptr, v)					\
+({							\
+	__typeof__(ptr) ____ptr = (ptr);		\
+	arch_xchg(____ptr, (v));			\
+})
+
+#define cmpxchg(ptr, old, new)				\
+({							\
+	__typeof__(ptr) ___ptr = (ptr);			\
+	arch_cmpxchg(___ptr, (old), (new));		\
+})
+
+#define sync_cmpxchg(ptr, old, new)			\
+({							\
+	__typeof__(ptr) ___ptr = (ptr);			\
+	arch_sync_cmpxchg(___ptr, (old), (new));	\
+})
+
+#define cmpxchg_local(ptr, old, new)			\
+({							\
+	__typeof__(ptr) ____ptr = (ptr);		\
+	arch_cmpxchg_local(____ptr, (old), (new));	\
+})
+
+#define cmpxchg64(ptr, old, new)			\
+({							\
+	__typeof__(ptr) ____ptr = (ptr);		\
+	arch_cmpxchg64(____ptr, (old), (new));		\
+})
+
+#define cmpxchg64_local(ptr, old, new)			\
+({							\
+	__typeof__(ptr) ____ptr = (ptr);		\
+	arch_cmpxchg64_local(____ptr, (old), (new));	\
+})
+
+#define cmpxchg_double(p1, p2, o1, o2, n1, n2)				\
+({									\
+	__typeof__(p1) ____p1 = (p1);					\
+	arch_cmpxchg_double(____p1, (p2), (o1), (o2), (n1), (n2));	\
+})
+
+#define cmpxchg_double_local(p1, p2, o1, o2, n1, n2)			\
+({									\
+	__typeof__(p1) ____p1 = (p1);					\
+	arch_cmpxchg_double_local(____p1, (p2), (o1), (o2), (n1), (n2));\
+})
+
+#endif /* _LINUX_ATOMIC_INSTRUMENTED_H */
-- 
2.12.0.367.g23dc2f6d3c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
