Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C9FE46B02FA
	for <linux-mm@kvack.org>; Fri, 26 May 2017 15:10:21 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a77so4761039wma.12
        for <linux-mm@kvack.org>; Fri, 26 May 2017 12:10:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g90sor8708wrd.5.2017.05.26.12.10.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 May 2017 12:10:20 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v2 6/7] asm-generic: add KASAN instrumentation to atomic operations
Date: Fri, 26 May 2017 21:09:08 +0200
Message-Id: <f0a089e443859804c5dd331d36bb8c885f1f3e8c.1495825151.git.dvyukov@google.com>
In-Reply-To: <cover.1495825151.git.dvyukov@google.com>
References: <cover.1495825151.git.dvyukov@google.com>
In-Reply-To: <cover.1495825151.git.dvyukov@google.com>
References: <cover.1495825151.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com
Cc: akpm@linux-foundation.org, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, tglx@linutronix.de, hpa@zytor.com, willy@infradead.org, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org

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
 include/asm-generic/atomic-instrumented.h | 76 +++++++++++++++++++++++++++++--
 1 file changed, 72 insertions(+), 4 deletions(-)

diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
index fd483115d4c6..7f8eb761f896 100644
--- a/include/asm-generic/atomic-instrumented.h
+++ b/include/asm-generic/atomic-instrumented.h
@@ -1,44 +1,54 @@
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
 
@@ -46,6 +56,8 @@ static __always_inline long long atomic64_cmpxchg(atomic64_t *v, long long old,
 #define atomic_try_cmpxchg atomic_try_cmpxchg
 static __always_inline bool atomic_try_cmpxchg(atomic_t *v, int *old, int new)
 {
+	kasan_check_write(v, sizeof(*v));
+	kasan_check_read(old, sizeof(*old));
 	return arch_atomic_try_cmpxchg(v, old, new);
 }
 #endif
@@ -55,12 +67,15 @@ static __always_inline bool atomic_try_cmpxchg(atomic_t *v, int *old, int new)
 static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, long long *old,
 						 long long new)
 {
+	kasan_check_write(v, sizeof(*v));
+	kasan_check_read(old, sizeof(*old));
 	return arch_atomic64_try_cmpxchg(v, old, new);
 }
 #endif
 
 static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
 {
+	kasan_check_write(v, sizeof(*v));
 	return __arch_atomic_add_unless(v, a, u);
 }
 
@@ -68,242 +83,295 @@ static __always_inline int __atomic_add_unless(atomic_t *v, int a, int u)
 static __always_inline bool atomic64_add_unless(atomic64_t *v, long long a,
 						long long u)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_add_unless(v, a, u);
 }
 
 static __always_inline void atomic_inc(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_inc(v);
 }
 
 static __always_inline void atomic64_inc(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_inc(v);
 }
 
 static __always_inline void atomic_dec(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_dec(v);
 }
 
 static __always_inline void atomic64_dec(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_dec(v);
 }
 
 static __always_inline void atomic_add(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_add(i, v);
 }
 
 static __always_inline void atomic64_add(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_add(i, v);
 }
 
 static __always_inline void atomic_sub(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_sub(i, v);
 }
 
 static __always_inline void atomic64_sub(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_sub(i, v);
 }
 
 static __always_inline void atomic_and(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_and(i, v);
 }
 
 static __always_inline void atomic64_and(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_and(i, v);
 }
 
 static __always_inline void atomic_or(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_or(i, v);
 }
 
 static __always_inline void atomic64_or(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_or(i, v);
 }
 
 static __always_inline void atomic_xor(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_xor(i, v);
 }
 
 static __always_inline void atomic64_xor(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_xor(i, v);
 }
 
 static __always_inline int atomic_inc_return(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_inc_return(v);
 }
 
 static __always_inline long long atomic64_inc_return(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_inc_return(v);
 }
 
 static __always_inline int atomic_dec_return(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_dec_return(v);
 }
 
 static __always_inline long long atomic64_dec_return(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_dec_return(v);
 }
 
 static __always_inline long long atomic64_inc_not_zero(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_inc_not_zero(v);
 }
 
 static __always_inline long long atomic64_dec_if_positive(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_dec_if_positive(v);
 }
 
 static __always_inline bool atomic_dec_and_test(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_dec_and_test(v);
 }
 
 static __always_inline bool atomic64_dec_and_test(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_dec_and_test(v);
 }
 
 static __always_inline bool atomic_inc_and_test(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_inc_and_test(v);
 }
 
 static __always_inline bool atomic64_inc_and_test(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_inc_and_test(v);
 }
 
 static __always_inline int atomic_add_return(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_add_return(i, v);
 }
 
 static __always_inline long long atomic64_add_return(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_add_return(i, v);
 }
 
 static __always_inline int atomic_sub_return(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_sub_return(i, v);
 }
 
 static __always_inline long long atomic64_sub_return(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_sub_return(i, v);
 }
 
 static __always_inline int atomic_fetch_add(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_fetch_add(i, v);
 }
 
 static __always_inline long long atomic64_fetch_add(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_fetch_add(i, v);
 }
 
 static __always_inline int atomic_fetch_sub(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_fetch_sub(i, v);
 }
 
 static __always_inline long long atomic64_fetch_sub(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_fetch_sub(i, v);
 }
 
 static __always_inline int atomic_fetch_and(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_fetch_and(i, v);
 }
 
 static __always_inline long long atomic64_fetch_and(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_fetch_and(i, v);
 }
 
 static __always_inline int atomic_fetch_or(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_fetch_or(i, v);
 }
 
 static __always_inline long long atomic64_fetch_or(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_fetch_or(i, v);
 }
 
 static __always_inline int atomic_fetch_xor(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_fetch_xor(i, v);
 }
 
 static __always_inline long long atomic64_fetch_xor(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_fetch_xor(i, v);
 }
 
 static __always_inline bool atomic_sub_and_test(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_sub_and_test(i, v);
 }
 
 static __always_inline bool atomic64_sub_and_test(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_sub_and_test(i, v);
 }
 
 static __always_inline bool atomic_add_negative(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_add_negative(i, v);
 }
 
 static __always_inline bool atomic64_add_negative(long long i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_add_negative(i, v);
 }
 
 #define cmpxchg(ptr, old, new)				\
 ({							\
+	__typeof__(ptr) ___ptr = (ptr);			\
+	kasan_check_write(___ptr, sizeof(*___ptr));	\
 	arch_cmpxchg((ptr), (old), (new));		\
 })
 
 #define sync_cmpxchg(ptr, old, new)			\
 ({							\
-	arch_sync_cmpxchg((ptr), (old), (new));		\
+	__typeof__(ptr) ___ptr = (ptr);			\
+	kasan_check_write(___ptr, sizeof(*___ptr));	\
+	arch_sync_cmpxchg(___ptr, (old), (new));	\
 })
 
 #define cmpxchg_local(ptr, old, new)			\
 ({							\
-	arch_cmpxchg_local((ptr), (old), (new));	\
+	__typeof__(ptr) ____ptr = (ptr);		\
+	kasan_check_write(____ptr, sizeof(*____ptr));	\
+	arch_cmpxchg_local(____ptr, (old), (new));	\
 })
 
 #define cmpxchg64(ptr, old, new)			\
 ({							\
-	arch_cmpxchg64((ptr), (old), (new));		\
+	__typeof__(ptr) ____ptr = (ptr);		\
+	kasan_check_write(____ptr, sizeof(*____ptr));	\
+	arch_cmpxchg64(____ptr, (old), (new));		\
 })
 
 #define cmpxchg64_local(ptr, old, new)			\
 ({							\
-	arch_cmpxchg64_local((ptr), (old), (new));	\
+	__typeof__(ptr) ____ptr = (ptr);		\
+	kasan_check_write(____ptr, sizeof(*____ptr));	\
+	arch_cmpxchg64_local(____ptr, (old), (new));	\
 })
 
 #define cmpxchg_double(p1, p2, o1, o2, n1, n2)				\
-- 
2.13.0.219.gdb65acc882-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
