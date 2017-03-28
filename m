Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 59BEB6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 12:15:54 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t195so400789wme.11
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:15:54 -0700 (PDT)
Received: from mail-wr0-x229.google.com (mail-wr0-x229.google.com. [2a00:1450:400c:c0c::229])
        by mx.google.com with ESMTPS id m16si5207328wrb.72.2017.03.28.09.15.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 09:15:52 -0700 (PDT)
Received: by mail-wr0-x229.google.com with SMTP id w43so95486318wrb.0
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:15:52 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 3/8] x86: use long long for 64-bit atomic ops
Date: Tue, 28 Mar 2017 18:15:40 +0200
Message-Id: <aa139aea58a0c57961a81edc8b76edda75c6560d.1490717337.git.dvyukov@google.com>
In-Reply-To: <cover.1490717337.git.dvyukov@google.com>
References: <cover.1490717337.git.dvyukov@google.com>
In-Reply-To: <cover.1490717337.git.dvyukov@google.com>
References: <cover.1490717337.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com
Cc: akpm@linux-foundation.org, will.deacon@arm.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org

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
 arch/x86/include/asm/atomic64_64.h | 54 +++++++++++++++++++-------------------
 include/linux/types.h              |  2 +-
 2 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/arch/x86/include/asm/atomic64_64.h b/arch/x86/include/asm/atomic64_64.h
index 8db8879a6d8c..a62982a2b534 100644
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
@@ -193,12 +193,12 @@ static inline long atomic64_xchg(atomic64_t *v, long new)
  * @a: the amount to add to v...
  * @u: ...unless v is equal to u.
  *
- * Atomically adds @a to @v, so long as it was not @u.
+ * Atomically adds @a to @v, so long long as it was not @u.
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
2.12.2.564.g063fe858b8-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
