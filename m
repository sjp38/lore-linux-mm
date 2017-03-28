Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 961D36B0397
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 12:15:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id c21so51737396wra.19
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:15:54 -0700 (PDT)
Received: from mail-wr0-x234.google.com (mail-wr0-x234.google.com. [2a00:1450:400c:c0c::234])
        by mx.google.com with ESMTPS id b53si5199084wra.74.2017.03.28.09.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 09:15:53 -0700 (PDT)
Received: by mail-wr0-x234.google.com with SMTP id u1so110268595wra.2
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:15:53 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 4/8] asm-generic: add atomic-instrumented.h
Date: Tue, 28 Mar 2017 18:15:41 +0200
Message-Id: <ffaaa56d5099d2926004f0290f73396d0bd842c8.1490717337.git.dvyukov@google.com>
In-Reply-To: <cover.1490717337.git.dvyukov@google.com>
References: <cover.1490717337.git.dvyukov@google.com>
In-Reply-To: <cover.1490717337.git.dvyukov@google.com>
References: <cover.1490717337.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com
Cc: akpm@linux-foundation.org, will.deacon@arm.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org

The new header allows to wrap per-arch atomic operations
and add common functionality to all of them.

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
 include/asm-generic/atomic-instrumented.h | 319 ++++++++++++++++++++++++++++++
 1 file changed, 319 insertions(+)

diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
new file mode 100644
index 000000000000..fd483115d4c6
--- /dev/null
+++ b/include/asm-generic/atomic-instrumented.h
@@ -0,0 +1,319 @@
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
+#ifdef arch_atomic_try_cmpxchg
+#define atomic_try_cmpxchg atomic_try_cmpxchg
+static __always_inline bool atomic_try_cmpxchg(atomic_t *v, int *old, int new)
+{
+	return arch_atomic_try_cmpxchg(v, old, new);
+}
+#endif
+
+#ifdef arch_atomic64_try_cmpxchg
+#define atomic64_try_cmpxchg atomic64_try_cmpxchg
+static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, long long *old,
+						 long long new)
+{
+	return arch_atomic64_try_cmpxchg(v, old, new);
+}
+#endif
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
+static __always_inline void atomic_inc(atomic_t *v)
+{
+	arch_atomic_inc(v);
+}
+
+static __always_inline void atomic64_inc(atomic64_t *v)
+{
+	arch_atomic64_inc(v);
+}
+
+static __always_inline void atomic_dec(atomic_t *v)
+{
+	arch_atomic_dec(v);
+}
+
+static __always_inline void atomic64_dec(atomic64_t *v)
+{
+	arch_atomic64_dec(v);
+}
+
+static __always_inline void atomic_add(int i, atomic_t *v)
+{
+	arch_atomic_add(i, v);
+}
+
+static __always_inline void atomic64_add(long long i, atomic64_t *v)
+{
+	arch_atomic64_add(i, v);
+}
+
+static __always_inline void atomic_sub(int i, atomic_t *v)
+{
+	arch_atomic_sub(i, v);
+}
+
+static __always_inline void atomic64_sub(long long i, atomic64_t *v)
+{
+	arch_atomic64_sub(i, v);
+}
+
+static __always_inline void atomic_and(int i, atomic_t *v)
+{
+	arch_atomic_and(i, v);
+}
+
+static __always_inline void atomic64_and(long long i, atomic64_t *v)
+{
+	arch_atomic64_and(i, v);
+}
+
+static __always_inline void atomic_or(int i, atomic_t *v)
+{
+	arch_atomic_or(i, v);
+}
+
+static __always_inline void atomic64_or(long long i, atomic64_t *v)
+{
+	arch_atomic64_or(i, v);
+}
+
+static __always_inline void atomic_xor(int i, atomic_t *v)
+{
+	arch_atomic_xor(i, v);
+}
+
+static __always_inline void atomic64_xor(long long i, atomic64_t *v)
+{
+	arch_atomic64_xor(i, v);
+}
+
+static __always_inline int atomic_inc_return(atomic_t *v)
+{
+	return arch_atomic_inc_return(v);
+}
+
+static __always_inline long long atomic64_inc_return(atomic64_t *v)
+{
+	return arch_atomic64_inc_return(v);
+}
+
+static __always_inline int atomic_dec_return(atomic_t *v)
+{
+	return arch_atomic_dec_return(v);
+}
+
+static __always_inline long long atomic64_dec_return(atomic64_t *v)
+{
+	return arch_atomic64_dec_return(v);
+}
+
+static __always_inline long long atomic64_inc_not_zero(atomic64_t *v)
+{
+	return arch_atomic64_inc_not_zero(v);
+}
+
+static __always_inline long long atomic64_dec_if_positive(atomic64_t *v)
+{
+	return arch_atomic64_dec_if_positive(v);
+}
+
+static __always_inline bool atomic_dec_and_test(atomic_t *v)
+{
+	return arch_atomic_dec_and_test(v);
+}
+
+static __always_inline bool atomic64_dec_and_test(atomic64_t *v)
+{
+	return arch_atomic64_dec_and_test(v);
+}
+
+static __always_inline bool atomic_inc_and_test(atomic_t *v)
+{
+	return arch_atomic_inc_and_test(v);
+}
+
+static __always_inline bool atomic64_inc_and_test(atomic64_t *v)
+{
+	return arch_atomic64_inc_and_test(v);
+}
+
+static __always_inline int atomic_add_return(int i, atomic_t *v)
+{
+	return arch_atomic_add_return(i, v);
+}
+
+static __always_inline long long atomic64_add_return(long long i, atomic64_t *v)
+{
+	return arch_atomic64_add_return(i, v);
+}
+
+static __always_inline int atomic_sub_return(int i, atomic_t *v)
+{
+	return arch_atomic_sub_return(i, v);
+}
+
+static __always_inline long long atomic64_sub_return(long long i, atomic64_t *v)
+{
+	return arch_atomic64_sub_return(i, v);
+}
+
+static __always_inline int atomic_fetch_add(int i, atomic_t *v)
+{
+	return arch_atomic_fetch_add(i, v);
+}
+
+static __always_inline long long atomic64_fetch_add(long long i, atomic64_t *v)
+{
+	return arch_atomic64_fetch_add(i, v);
+}
+
+static __always_inline int atomic_fetch_sub(int i, atomic_t *v)
+{
+	return arch_atomic_fetch_sub(i, v);
+}
+
+static __always_inline long long atomic64_fetch_sub(long long i, atomic64_t *v)
+{
+	return arch_atomic64_fetch_sub(i, v);
+}
+
+static __always_inline int atomic_fetch_and(int i, atomic_t *v)
+{
+	return arch_atomic_fetch_and(i, v);
+}
+
+static __always_inline long long atomic64_fetch_and(long long i, atomic64_t *v)
+{
+	return arch_atomic64_fetch_and(i, v);
+}
+
+static __always_inline int atomic_fetch_or(int i, atomic_t *v)
+{
+	return arch_atomic_fetch_or(i, v);
+}
+
+static __always_inline long long atomic64_fetch_or(long long i, atomic64_t *v)
+{
+	return arch_atomic64_fetch_or(i, v);
+}
+
+static __always_inline int atomic_fetch_xor(int i, atomic_t *v)
+{
+	return arch_atomic_fetch_xor(i, v);
+}
+
+static __always_inline long long atomic64_fetch_xor(long long i, atomic64_t *v)
+{
+	return arch_atomic64_fetch_xor(i, v);
+}
+
+static __always_inline bool atomic_sub_and_test(int i, atomic_t *v)
+{
+	return arch_atomic_sub_and_test(i, v);
+}
+
+static __always_inline bool atomic64_sub_and_test(long long i, atomic64_t *v)
+{
+	return arch_atomic64_sub_and_test(i, v);
+}
+
+static __always_inline bool atomic_add_negative(int i, atomic_t *v)
+{
+	return arch_atomic_add_negative(i, v);
+}
+
+static __always_inline bool atomic64_add_negative(long long i, atomic64_t *v)
+{
+	return arch_atomic64_add_negative(i, v);
+}
+
+#define cmpxchg(ptr, old, new)				\
+({							\
+	arch_cmpxchg((ptr), (old), (new));		\
+})
+
+#define sync_cmpxchg(ptr, old, new)			\
+({							\
+	arch_sync_cmpxchg((ptr), (old), (new));		\
+})
+
+#define cmpxchg_local(ptr, old, new)			\
+({							\
+	arch_cmpxchg_local((ptr), (old), (new));	\
+})
+
+#define cmpxchg64(ptr, old, new)			\
+({							\
+	arch_cmpxchg64((ptr), (old), (new));		\
+})
+
+#define cmpxchg64_local(ptr, old, new)			\
+({							\
+	arch_cmpxchg64_local((ptr), (old), (new));	\
+})
+
+#define cmpxchg_double(p1, p2, o1, o2, n1, n2)				\
+({									\
+	arch_cmpxchg_double((p1), (p2), (o1), (o2), (n1), (n2));	\
+})
+
+#define cmpxchg_double_local(p1, p2, o1, o2, n1, n2)			\
+({									\
+	arch_cmpxchg_double_local((p1), (p2), (o1), (o2), (n1), (n2));	\
+})
+
+#endif /* _LINUX_ATOMIC_INSTRUMENTED_H */
-- 
2.12.2.564.g063fe858b8-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
