Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8A16B0315
	for <linux-mm@kvack.org>; Sat, 17 Jun 2017 05:15:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d64so6245676wmf.9
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 02:15:42 -0700 (PDT)
Received: from mail-wr0-x232.google.com (mail-wr0-x232.google.com. [2a00:1450:400c:c0c::232])
        by mx.google.com with ESMTPS id 4si1252056wmy.138.2017.06.17.02.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jun 2017 02:15:40 -0700 (PDT)
Received: by mail-wr0-x232.google.com with SMTP id 36so48643715wry.3
        for <linux-mm@kvack.org>; Sat, 17 Jun 2017 02:15:40 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v4 3/7] asm-generic: add atomic-instrumented.h
Date: Sat, 17 Jun 2017 11:15:29 +0200
Message-Id: <4ffbfa72c29134ac87b1f69da1506a5720590b5d.1497690003.git.dvyukov@google.com>
In-Reply-To: <cover.1497690003.git.dvyukov@google.com>
References: <cover.1497690003.git.dvyukov@google.com>
In-Reply-To: <cover.1497690003.git.dvyukov@google.com>
References: <cover.1497690003.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

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
 include/asm-generic/atomic-instrumented.h | 316 ++++++++++++++++++++++++++++++
 1 file changed, 316 insertions(+)

diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
new file mode 100644
index 000000000000..50401d925290
--- /dev/null
+++ b/include/asm-generic/atomic-instrumented.h
@@ -0,0 +1,316 @@
+#ifndef _LINUX_ATOMIC_INSTRUMENTED_H
+#define _LINUX_ATOMIC_INSTRUMENTED_H
+
+static __always_inline int atomic_read(const atomic_t *v)
+{
+	return arch_atomic_read(v);
+}
+
+static __always_inline s64 atomic64_read(const atomic64_t *v)
+{
+	return arch_atomic64_read(v);
+}
+
+static __always_inline void atomic_set(atomic_t *v, int i)
+{
+	arch_atomic_set(v, i);
+}
+
+static __always_inline void atomic64_set(atomic64_t *v, s64 i)
+{
+	arch_atomic64_set(v, i);
+}
+
+static __always_inline int atomic_xchg(atomic_t *v, int i)
+{
+	return arch_atomic_xchg(v, i);
+}
+
+static __always_inline s64 atomic64_xchg(atomic64_t *v, s64 i)
+{
+	return arch_atomic64_xchg(v, i);
+}
+
+static __always_inline int atomic_cmpxchg(atomic_t *v, int old, int new)
+{
+	return arch_atomic_cmpxchg(v, old, new);
+}
+
+static __always_inline s64 atomic64_cmpxchg(atomic64_t *v, s64 old, s64 new)
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
+static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, s64 *old, s64 new)
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
+static __always_inline bool atomic64_add_unless(atomic64_t *v, s64 a, s64 u)
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
+static __always_inline void atomic64_add(s64 i, atomic64_t *v)
+{
+	arch_atomic64_add(i, v);
+}
+
+static __always_inline void atomic_sub(int i, atomic_t *v)
+{
+	arch_atomic_sub(i, v);
+}
+
+static __always_inline void atomic64_sub(s64 i, atomic64_t *v)
+{
+	arch_atomic64_sub(i, v);
+}
+
+static __always_inline void atomic_and(int i, atomic_t *v)
+{
+	arch_atomic_and(i, v);
+}
+
+static __always_inline void atomic64_and(s64 i, atomic64_t *v)
+{
+	arch_atomic64_and(i, v);
+}
+
+static __always_inline void atomic_or(int i, atomic_t *v)
+{
+	arch_atomic_or(i, v);
+}
+
+static __always_inline void atomic64_or(s64 i, atomic64_t *v)
+{
+	arch_atomic64_or(i, v);
+}
+
+static __always_inline void atomic_xor(int i, atomic_t *v)
+{
+	arch_atomic_xor(i, v);
+}
+
+static __always_inline void atomic64_xor(s64 i, atomic64_t *v)
+{
+	arch_atomic64_xor(i, v);
+}
+
+static __always_inline int atomic_inc_return(atomic_t *v)
+{
+	return arch_atomic_inc_return(v);
+}
+
+static __always_inline s64 atomic64_inc_return(atomic64_t *v)
+{
+	return arch_atomic64_inc_return(v);
+}
+
+static __always_inline int atomic_dec_return(atomic_t *v)
+{
+	return arch_atomic_dec_return(v);
+}
+
+static __always_inline s64 atomic64_dec_return(atomic64_t *v)
+{
+	return arch_atomic64_dec_return(v);
+}
+
+static __always_inline s64 atomic64_inc_not_zero(atomic64_t *v)
+{
+	return arch_atomic64_inc_not_zero(v);
+}
+
+static __always_inline s64 atomic64_dec_if_positive(atomic64_t *v)
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
+static __always_inline s64 atomic64_add_return(s64 i, atomic64_t *v)
+{
+	return arch_atomic64_add_return(i, v);
+}
+
+static __always_inline int atomic_sub_return(int i, atomic_t *v)
+{
+	return arch_atomic_sub_return(i, v);
+}
+
+static __always_inline s64 atomic64_sub_return(s64 i, atomic64_t *v)
+{
+	return arch_atomic64_sub_return(i, v);
+}
+
+static __always_inline int atomic_fetch_add(int i, atomic_t *v)
+{
+	return arch_atomic_fetch_add(i, v);
+}
+
+static __always_inline s64 atomic64_fetch_add(s64 i, atomic64_t *v)
+{
+	return arch_atomic64_fetch_add(i, v);
+}
+
+static __always_inline int atomic_fetch_sub(int i, atomic_t *v)
+{
+	return arch_atomic_fetch_sub(i, v);
+}
+
+static __always_inline s64 atomic64_fetch_sub(s64 i, atomic64_t *v)
+{
+	return arch_atomic64_fetch_sub(i, v);
+}
+
+static __always_inline int atomic_fetch_and(int i, atomic_t *v)
+{
+	return arch_atomic_fetch_and(i, v);
+}
+
+static __always_inline s64 atomic64_fetch_and(s64 i, atomic64_t *v)
+{
+	return arch_atomic64_fetch_and(i, v);
+}
+
+static __always_inline int atomic_fetch_or(int i, atomic_t *v)
+{
+	return arch_atomic_fetch_or(i, v);
+}
+
+static __always_inline s64 atomic64_fetch_or(s64 i, atomic64_t *v)
+{
+	return arch_atomic64_fetch_or(i, v);
+}
+
+static __always_inline int atomic_fetch_xor(int i, atomic_t *v)
+{
+	return arch_atomic_fetch_xor(i, v);
+}
+
+static __always_inline s64 atomic64_fetch_xor(s64 i, atomic64_t *v)
+{
+	return arch_atomic64_fetch_xor(i, v);
+}
+
+static __always_inline bool atomic_sub_and_test(int i, atomic_t *v)
+{
+	return arch_atomic_sub_and_test(i, v);
+}
+
+static __always_inline bool atomic64_sub_and_test(s64 i, atomic64_t *v)
+{
+	return arch_atomic64_sub_and_test(i, v);
+}
+
+static __always_inline bool atomic_add_negative(int i, atomic_t *v)
+{
+	return arch_atomic_add_negative(i, v);
+}
+
+static __always_inline bool atomic64_add_negative(s64 i, atomic64_t *v)
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
2.13.1.518.g3df882009-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
