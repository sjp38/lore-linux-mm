Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id F0DE76B0390
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 15:24:23 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w37so53270627wrc.2
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:24:23 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id b31si6238738wrd.314.2017.03.14.12.24.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Mar 2017 12:24:22 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id t189so7073734wmt.1
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 12:24:22 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 3/3] asm-generic: add KASAN instrumentation to atomic operations
Date: Tue, 14 Mar 2017 20:24:14 +0100
Message-Id: <7e450175a324bf93c602909c711bc34715d8e8f2.1489519233.git.dvyukov@google.com>
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

Add manual KASAN checks to atomic operations.

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
 include/asm-generic/atomic-instrumented.h | 36 +++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
index 41e5e6ffdfc8..951bcd083925 100644
--- a/include/asm-generic/atomic-instrumented.h
+++ b/include/asm-generic/atomic-instrumented.h
@@ -1,50 +1,72 @@
+/*
+ * This file provides wrappers with KASAN instrumentation for atomic operations.
+ * To use this functionality an arch's atomic.h file needs to define all
+ * atomic operations with arch_ prefix (e.g. arch_atomic_read()) and include
+ * this file at the end. This file provides atomic_read() that forwards to
+ * arch_atomic_read() for actual atomic operation.
+ * Note: if an arch atomic operation is implemented by means of other atomic
+ * operations (e.g. atomic_read()/atomic_cmpxchg() loop), then it needs to use
+ * arch_ variants (i.e. arch_atomic_read()/arch_atomic_cmpxchg()) to avoid
+ * double instrumentation.
+ */
 #ifndef _LINUX_ATOMIC_INSTRUMENTED_H
 #define _LINUX_ATOMIC_INSTRUMENTED_H
 
+#include <linux/kasan-checks.h>
+
 static __always_inline int atomic_read(const atomic_t *v)
 {
+	kasan_check_read(v, sizeof(*v));
 	return arch_atomic_read(v);
 }
 
 static __always_inline long long atomic64_read(const atomic64_t *v)
 {
+	kasan_check_read(v, sizeof(*v));
 	return arch_atomic64_read(v);
 }
 
 
 static __always_inline void atomic_set(atomic_t *v, int i)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_set(v, i);
 }
 
 static __always_inline void atomic64_set(atomic64_t *v, long long i)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_set(v, i);
 }
 
 static __always_inline int atomic_xchg(atomic_t *v, int i)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_xchg(v, i);
 }
 
 static __always_inline long long atomic64_xchg(atomic64_t *v, long long i)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_xchg(v, i);
 }
 
 static __always_inline int atomic_cmpxchg(atomic_t *v, int old, int new)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_cmpxchg(v, old, new);
 }
 
 static __always_inline long long atomic64_cmpxchg(atomic64_t *v, long long old,
 						  long long new)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_cmpxchg(v, old, new);
 }
 
 static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
 {
+	kasan_check_write(v, sizeof(*v));
 	return __arch_atomic_add_unless(v, a, u);
 }
 
@@ -52,17 +74,20 @@ static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
 static __always_inline bool atomic64_add_unless(atomic64_t *v, long long a,
 						long long u)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_add_unless(v, a, u);
 }
 
 static __always_inline short int atomic_inc_short(short int *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_inc_short(v);
 }
 
 #define __INSTR_VOID1(op, sz)						\
 static __always_inline void atomic##sz##_##op(atomic##sz##_t *v)	\
 {									\
+	kasan_check_write(v, sizeof(*v));				\
 	arch_atomic##sz##_##op(v);					\
 }
 
@@ -79,6 +104,7 @@ INSTR_VOID1(dec);
 #define __INSTR_VOID2(op, sz, type)					\
 static __always_inline void atomic##sz##_##op(type i, atomic##sz##_t *v)\
 {									\
+	kasan_check_write(v, sizeof(*v));				\
 	arch_atomic##sz##_##op(i, v);					\
 }
 
@@ -98,6 +124,7 @@ INSTR_VOID2(xor);
 #define __INSTR_RET1(op, sz, type, rtype)				\
 static __always_inline rtype atomic##sz##_##op(atomic##sz##_t *v)	\
 {									\
+	kasan_check_write(v, sizeof(*v));				\
 	return arch_atomic##sz##_##op(v);				\
 }
 
@@ -124,6 +151,7 @@ INSTR_RET_BOOL1(inc_and_test);
 #define __INSTR_RET2(op, sz, type, rtype)				\
 static __always_inline rtype atomic##sz##_##op(type i, atomic##sz##_t *v) \
 {									\
+	kasan_check_write(v, sizeof(*v));				\
 	return arch_atomic##sz##_##op(i, v);				\
 }
 
@@ -162,48 +190,56 @@ INSTR_RET_BOOL2(add_negative);
 #define xchg(ptr, v)					\
 ({							\
 	__typeof__(ptr) ____ptr = (ptr);		\
+	kasan_check_write(____ptr, sizeof(*____ptr));	\
 	arch_xchg(____ptr, (v));			\
 })
 
 #define cmpxchg(ptr, old, new)				\
 ({							\
 	__typeof__(ptr) ___ptr = (ptr);			\
+	kasan_check_write(___ptr, sizeof(*___ptr));	\
 	arch_cmpxchg(___ptr, (old), (new));		\
 })
 
 #define sync_cmpxchg(ptr, old, new)			\
 ({							\
 	__typeof__(ptr) ___ptr = (ptr);			\
+	kasan_check_write(___ptr, sizeof(*___ptr));	\
 	arch_sync_cmpxchg(___ptr, (old), (new));	\
 })
 
 #define cmpxchg_local(ptr, old, new)			\
 ({							\
 	__typeof__(ptr) ____ptr = (ptr);		\
+	kasan_check_write(____ptr, sizeof(*____ptr));	\
 	arch_cmpxchg_local(____ptr, (old), (new));	\
 })
 
 #define cmpxchg64(ptr, old, new)			\
 ({							\
 	__typeof__(ptr) ____ptr = (ptr);		\
+	kasan_check_write(____ptr, sizeof(*____ptr));	\
 	arch_cmpxchg64(____ptr, (old), (new));		\
 })
 
 #define cmpxchg64_local(ptr, old, new)			\
 ({							\
 	__typeof__(ptr) ____ptr = (ptr);		\
+	kasan_check_write(____ptr, sizeof(*____ptr));	\
 	arch_cmpxchg64_local(____ptr, (old), (new));	\
 })
 
 #define cmpxchg_double(p1, p2, o1, o2, n1, n2)				\
 ({									\
 	__typeof__(p1) ____p1 = (p1);					\
+	kasan_check_write(____p1, 2 * sizeof(*____p1));			\
 	arch_cmpxchg_double(____p1, (p2), (o1), (o2), (n1), (n2));	\
 })
 
 #define cmpxchg_double_local(p1, p2, o1, o2, n1, n2)			\
 ({									\
 	__typeof__(p1) ____p1 = (p1);					\
+	kasan_check_write(____p1, 2 * sizeof(*____p1));			\
 	arch_cmpxchg_double_local(____p1, (p2), (o1), (o2), (n1), (n2));\
 })
 
-- 
2.12.0.367.g23dc2f6d3c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
