Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 332816B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:14:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id f49so4980629wrf.5
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:14:27 -0700 (PDT)
Received: from mail-wr0-x230.google.com (mail-wr0-x230.google.com. [2a00:1450:400c:c0c::230])
        by mx.google.com with ESMTPS id v2si1697866wrb.15.2017.06.22.07.14.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 07:14:25 -0700 (PDT)
Received: by mail-wr0-x230.google.com with SMTP id k67so25191954wrc.2
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 07:14:25 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v5 4/4] asm-generic, x86: add comments for atomic instrumentation
Date: Thu, 22 Jun 2017 16:14:19 +0200
Message-Id: <65058e2d09cf0920769ca72a932d9de4f613249d.1498140838.git.dvyukov@google.com>
In-Reply-To: <cover.1498140468.git.dvyukov@google.com>
References: <cover.1498140468.git.dvyukov@google.com>
In-Reply-To: <cover.1498140838.git.dvyukov@google.com>
References: <cover.1498140838.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, x86@kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

The comments are factored out from the code changes to make them
easier to read. Add them separately to explain some non-obvious
aspects.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Acked-by: Mark Rutland <mark.rutland@arm.com>
Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: x86@kernel.org

---

Changes since v3:
 - rephrase comment in arch_atomic_read()
---
 arch/x86/include/asm/atomic.h             |  4 ++++
 include/asm-generic/atomic-instrumented.h | 30 ++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+)

diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
index 03dd2a6cf7e2..b1cd05da5d8a 100644
--- a/arch/x86/include/asm/atomic.h
+++ b/arch/x86/include/asm/atomic.h
@@ -23,6 +23,10 @@
  */
 static __always_inline int arch_atomic_read(const atomic_t *v)
 {
+	/*
+	 * Note for KASAN: we deliberately don't use READ_ONCE_NOCHECK() here,
+	 * it's non-inlined function that increases binary size and stack usage.
+	 */
 	return READ_ONCE((v)->counter);
 }
 
diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
index a0f5b7525bb2..5771439e7a31 100644
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
 
@@ -336,6 +348,15 @@ static __always_inline bool atomic64_add_negative(s64 i, atomic64_t *v)
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
@@ -371,6 +392,15 @@ static __always_inline bool atomic64_add_negative(s64 i, atomic64_t *v)
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
2.13.1.611.g7e3b11ae1-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
