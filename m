Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C85E6B0292
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:14:28 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id x23so4966528wrb.6
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:14:28 -0700 (PDT)
Received: from mail-wr0-x235.google.com (mail-wr0-x235.google.com. [2a00:1450:400c:c0c::235])
        by mx.google.com with ESMTPS id w143si1244832wmd.171.2017.06.22.07.14.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 07:14:26 -0700 (PDT)
Received: by mail-wr0-x235.google.com with SMTP id k67so25192813wrc.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:14:26 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v5 3/4] asm-generic: add KASAN instrumentation to atomic operations
Date: Thu, 22 Jun 2017 16:14:18 +0200
Message-Id: <85d51d3551b676ba1fc40e8fbddd2eadd056d8dd.1498140838.git.dvyukov@google.com>
In-Reply-To: <cover.1498140468.git.dvyukov@google.com>
References: <cover.1498140468.git.dvyukov@google.com>
In-Reply-To: <cover.1498140838.git.dvyukov@google.com>
References: <cover.1498140838.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

KASAN uses compiler instrumentation to intercept all memory accesses.
But it does not see memory accesses done in assembly code.
One notable user of assembly code is atomic operations. Frequently,
for example, an atomic reference decrement is the last access to an
object and a good candidate for a racy use-after-free.

Add manual KASAN checks to atomic operations.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Acked-by: Mark Rutland <mark.rutland@arm.com>
Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>,
Cc: Andrew Morton <akpm@linux-foundation.org>,
Cc: Ingo Molnar <mingo@redhat.com>,
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: x86@kernel.org
---
 include/asm-generic/atomic-instrumented.h | 76 +++++++++++++++++++++++++++++--
 1 file changed, 72 insertions(+), 4 deletions(-)

diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
index 50401d925290..a0f5b7525bb2 100644
--- a/include/asm-generic/atomic-instrumented.h
+++ b/include/asm-generic/atomic-instrumented.h
@@ -1,43 +1,53 @@
 #ifndef _LINUX_ATOMIC_INSTRUMENTED_H
 #define _LINUX_ATOMIC_INSTRUMENTED_H
 
+#include <linux/kasan-checks.h>
+
 static __always_inline int atomic_read(const atomic_t *v)
 {
+	kasan_check_read(v, sizeof(*v));
 	return arch_atomic_read(v);
 }
 
 static __always_inline s64 atomic64_read(const atomic64_t *v)
 {
+	kasan_check_read(v, sizeof(*v));
 	return arch_atomic64_read(v);
 }
 
 static __always_inline void atomic_set(atomic_t *v, int i)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_set(v, i);
 }
 
 static __always_inline void atomic64_set(atomic64_t *v, s64 i)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_set(v, i);
 }
 
 static __always_inline int atomic_xchg(atomic_t *v, int i)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_xchg(v, i);
 }
 
 static __always_inline s64 atomic64_xchg(atomic64_t *v, s64 i)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_xchg(v, i);
 }
 
 static __always_inline int atomic_cmpxchg(atomic_t *v, int old, int new)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_cmpxchg(v, old, new);
 }
 
 static __always_inline s64 atomic64_cmpxchg(atomic64_t *v, s64 old, s64 new)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_cmpxchg(v, old, new);
 }
 
@@ -45,6 +55,8 @@ static __always_inline s64 atomic64_cmpxchg(atomic64_t *v, s64 old, s64 new)
 #define atomic_try_cmpxchg atomic_try_cmpxchg
 static __always_inline bool atomic_try_cmpxchg(atomic_t *v, int *old, int new)
 {
+	kasan_check_write(v, sizeof(*v));
+	kasan_check_read(old, sizeof(*old));
 	return arch_atomic_try_cmpxchg(v, old, new);
 }
 #endif
@@ -53,254 +65,310 @@ static __always_inline bool atomic_try_cmpxchg(atomic_t *v, int *old, int new)
 #define atomic64_try_cmpxchg atomic64_try_cmpxchg
 static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, s64 *old, s64 new)
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
 
 
 static __always_inline bool atomic64_add_unless(atomic64_t *v, s64 a, s64 u)
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
 
 static __always_inline void atomic64_add(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_add(i, v);
 }
 
 static __always_inline void atomic_sub(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_sub(i, v);
 }
 
 static __always_inline void atomic64_sub(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_sub(i, v);
 }
 
 static __always_inline void atomic_and(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_and(i, v);
 }
 
 static __always_inline void atomic64_and(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_and(i, v);
 }
 
 static __always_inline void atomic_or(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_or(i, v);
 }
 
 static __always_inline void atomic64_or(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_or(i, v);
 }
 
 static __always_inline void atomic_xor(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic_xor(i, v);
 }
 
 static __always_inline void atomic64_xor(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	arch_atomic64_xor(i, v);
 }
 
 static __always_inline int atomic_inc_return(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_inc_return(v);
 }
 
 static __always_inline s64 atomic64_inc_return(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_inc_return(v);
 }
 
 static __always_inline int atomic_dec_return(atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_dec_return(v);
 }
 
 static __always_inline s64 atomic64_dec_return(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_dec_return(v);
 }
 
 static __always_inline s64 atomic64_inc_not_zero(atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_inc_not_zero(v);
 }
 
 static __always_inline s64 atomic64_dec_if_positive(atomic64_t *v)
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
 
 static __always_inline s64 atomic64_add_return(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_add_return(i, v);
 }
 
 static __always_inline int atomic_sub_return(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_sub_return(i, v);
 }
 
 static __always_inline s64 atomic64_sub_return(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_sub_return(i, v);
 }
 
 static __always_inline int atomic_fetch_add(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_fetch_add(i, v);
 }
 
 static __always_inline s64 atomic64_fetch_add(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_fetch_add(i, v);
 }
 
 static __always_inline int atomic_fetch_sub(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_fetch_sub(i, v);
 }
 
 static __always_inline s64 atomic64_fetch_sub(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_fetch_sub(i, v);
 }
 
 static __always_inline int atomic_fetch_and(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_fetch_and(i, v);
 }
 
 static __always_inline s64 atomic64_fetch_and(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_fetch_and(i, v);
 }
 
 static __always_inline int atomic_fetch_or(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_fetch_or(i, v);
 }
 
 static __always_inline s64 atomic64_fetch_or(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_fetch_or(i, v);
 }
 
 static __always_inline int atomic_fetch_xor(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_fetch_xor(i, v);
 }
 
 static __always_inline s64 atomic64_fetch_xor(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_fetch_xor(i, v);
 }
 
 static __always_inline bool atomic_sub_and_test(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_sub_and_test(i, v);
 }
 
 static __always_inline bool atomic64_sub_and_test(s64 i, atomic64_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic64_sub_and_test(i, v);
 }
 
 static __always_inline bool atomic_add_negative(int i, atomic_t *v)
 {
+	kasan_check_write(v, sizeof(*v));
 	return arch_atomic_add_negative(i, v);
 }
 
 static __always_inline bool atomic64_add_negative(s64 i, atomic64_t *v)
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
2.13.1.611.g7e3b11ae1-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
