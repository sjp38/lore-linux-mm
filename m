Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 937AB6B0333
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 07:10:27 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l37so38660562wrc.7
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 04:10:27 -0700 (PDT)
Received: from mail-wr0-x22c.google.com (mail-wr0-x22c.google.com. [2a00:1450:400c:c0c::22c])
        by mx.google.com with ESMTPS id h9si1651723wrc.243.2017.03.22.04.10.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 04:10:26 -0700 (PDT)
Received: by mail-wr0-x22c.google.com with SMTP id l37so127925064wrc.1
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 04:10:26 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] asm-generic: fix compilation failure in cmpxchg_double()
Date: Wed, 22 Mar 2017 12:10:22 +0100
Message-Id: <20170322111022.85745-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, akpm@linux-foundation.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Arnd reported that the new code leads to compilation failures
with some versions of gcc. I've filed gcc issue 72873,
but we need a kernel fix as well.

Remove instrumentation from cmpxchg_double() for now.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Reported-by: Arnd Bergmann <arnd@arndb.de>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 include/asm-generic/atomic-instrumented.h | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/asm-generic/atomic-instrumented.h b/include/asm-generic/atomic-instrumented.h
index 951bcd083925..de6c2a562a6e 100644
--- a/include/asm-generic/atomic-instrumented.h
+++ b/include/asm-generic/atomic-instrumented.h
@@ -229,18 +229,23 @@ INSTR_RET_BOOL2(add_negative);
 	arch_cmpxchg64_local(____ptr, (old), (new));	\
 })
 
+/*
+ * Originally we had the following code here:
+ *	__typeof__(p1) ____p1 = (p1);
+ *	kasan_check_write(____p1, 2 * sizeof(*____p1));
+ *	arch_cmpxchg_double(____p1, (p2), (o1), (o2), (n1), (n2));
+ * But it leads to compilation failures (see gcc issue 72873).
+ * So for now it's left non-instrumented.
+ * There are few callers of cmpxchg_double(), so it's not critical.
+ */
 #define cmpxchg_double(p1, p2, o1, o2, n1, n2)				\
 ({									\
-	__typeof__(p1) ____p1 = (p1);					\
-	kasan_check_write(____p1, 2 * sizeof(*____p1));			\
-	arch_cmpxchg_double(____p1, (p2), (o1), (o2), (n1), (n2));	\
+	arch_cmpxchg_double((p1), (p2), (o1), (o2), (n1), (n2));	\
 })
 
 #define cmpxchg_double_local(p1, p2, o1, o2, n1, n2)			\
 ({									\
-	__typeof__(p1) ____p1 = (p1);					\
-	kasan_check_write(____p1, 2 * sizeof(*____p1));			\
-	arch_cmpxchg_double_local(____p1, (p2), (o1), (o2), (n1), (n2));\
+	arch_cmpxchg_double_local((p1), (p2), (o1), (o2), (n1), (n2));	\
 })
 
 #endif /* _LINUX_ATOMIC_INSTRUMENTED_H */
-- 
2.12.1.500.gab5fba24ee-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
