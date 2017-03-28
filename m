Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 287106B03A0
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 12:15:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m72so397914wmb.22
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:15:56 -0700 (PDT)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id i14si5180319wrc.245.2017.03.28.09.15.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 09:15:54 -0700 (PDT)
Received: by mail-wm0-x230.google.com with SMTP id x124so3054615wmf.0
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:15:54 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 8/8] asm-generic, x86: add comments for atomic instrumentation
Date: Tue, 28 Mar 2017 18:15:45 +0200
Message-Id: <600eb4ad6f7b1511620488ac0494a7887a8e0415.1490717337.git.dvyukov@google.com>
In-Reply-To: <cover.1490717337.git.dvyukov@google.com>
References: <cover.1490717337.git.dvyukov@google.com>
In-Reply-To: <cover.1490717337.git.dvyukov@google.com>
References: <cover.1490717337.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com
Cc: akpm@linux-foundation.org, will.deacon@arm.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org

The comments are factored out from the code changes to make them
easier to read. Add them separately to explain some non-obvious
aspects.

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
 arch/x86/include/asm/atomic.h             |  7 +++++++
 include/asm-generic/atomic-instrumented.h | 30 ++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
index 92dd59f24eba..b2a2220c7ac2 100644
--- a/arch/x86/include/asm/atomic.h
+++ b/arch/x86/include/asm/atomic.h
@@ -23,6 +23,13 @@
  */
 static __always_inline int arch_atomic_read(const atomic_t *v)
 {
+	/*
+	 * Note: READ_ONCE() here leads to double instrumentation as
+	 * both READ_ONCE() and atomic_read() contain instrumentation.
+	 * This is a deliberate choice. READ_ONCE_NOCHECK() is compiled to a
+	 * non-inlined function call that considerably increases binary size
+	 * and stack usage under KASAN.
+	 */
 	return READ_ONCE((v)->counter);
 }
 
diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
index 7f8eb761f896..1134af090976 100644
--- a/include/asm-generic/atomic-instrumented.h
+++ b/include/asm-generic/atomic-instrumented.h
@@ -1,3 +1,15 @@
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
+
 #ifndef _LINUX_ATOMIC_INSTRUMENTED_H
 #define _LINUX_ATOMIC_INSTRUMENTED_H
 
@@ -339,6 +351,15 @@ static __always_inline bool atomic64_add_negative(long long i, atomic64_t *v)
 	return arch_atomic64_add_negative(i, v);
 }
 
+/*
+ * In the following macros we need to be careful to not clash with arch_ macros.
+ * arch_xchg() can be defined as an extended statement expression as well,
+ * if we define a __ptr variable, and arch_xchg() also defines __ptr variable,
+ * and we pass __ptr as an argument to arch_xchg(), it will use own __ptr
+ * instead of ours. This leads to unpleasant crashes. To avoid the problem
+ * the following macros declare variables with lots of underscores.
+ */
+
 #define cmpxchg(ptr, old, new)				\
 ({							\
 	__typeof__(ptr) ___ptr = (ptr);			\
@@ -374,6 +395,15 @@ static __always_inline bool atomic64_add_negative(long long i, atomic64_t *v)
 	arch_cmpxchg64_local(____ptr, (old), (new));	\
 })
 
+/*
+ * Originally we had the following code here:
+ *     __typeof__(p1) ____p1 = (p1);
+ *     kasan_check_write(____p1, 2 * sizeof(*____p1));
+ *     arch_cmpxchg_double(____p1, (p2), (o1), (o2), (n1), (n2));
+ * But it leads to compilation failures (see gcc issue 72873).
+ * So for now it's left non-instrumented.
+ * There are few callers of cmpxchg_double(), so it's not critical.
+ */
 #define cmpxchg_double(p1, p2, o1, o2, n1, n2)				\
 ({									\
 	arch_cmpxchg_double((p1), (p2), (o1), (o2), (n1), (n2));	\
-- 
2.12.2.564.g063fe858b8-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
