Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D54396B0333
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 08:24:54 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y90so39456756wrb.1
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 05:24:54 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id 1si1958959wrk.174.2017.03.22.05.24.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 05:24:53 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id t189so36135745wmt.1
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 05:24:53 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH] x86: s/READ_ONCE_NOCHECK/READ_ONCE/ in arch_atomic_read()
Date: Wed, 22 Mar 2017 13:24:49 +0100
Message-Id: <20170322122449.54505-1-dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, arnd@arndb.de, aryabinin@virtuozzo.com
Cc: Dmitry Vyukov <dvyukov@google.com>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com

Two problems was reported with READ_ONCE_NOCHECK in arch_atomic_read:
1. Andrey Ryabinin reported significant binary size increase
(+400K of text). READ_ONCE_NOCHECK is intentionally compiled to
non-inlined function call, and I counted 640 copies of it in my vmlinux.
2. Arnd Bergmann reported a new splat of too large frame sizes.

A single inlined KASAN check is very cheap, a non-inlined function
call with KASAN/KCOV instrumentation can easily be more expensive.

Switch to READ_ONCE() in arch_atomic_read().

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Reported-by: Arnd Bergmann <arnd@arndb.de>
Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: kasan-dev@googlegroups.com
---
 arch/x86/include/asm/atomic.h | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/atomic.h b/arch/x86/include/asm/atomic.h
index 0cde164f058a..46e53bbf7ce3 100644
--- a/arch/x86/include/asm/atomic.h
+++ b/arch/x86/include/asm/atomic.h
@@ -24,10 +24,13 @@
 static __always_inline int arch_atomic_read(const atomic_t *v)
 {
 	/*
-	 * We use READ_ONCE_NOCHECK() because atomic_read() contains KASAN
-	 * instrumentation. Double instrumentation is unnecessary.
+	 * Note: READ_ONCE() here leads to double instrumentation as
+	 * both READ_ONCE() and atomic_read() contain instrumentation.
+	 * This is deliberate choice. READ_ONCE_NOCHECK() is compiled to a
+	 * non-inlined function call that considerably increases binary size
+	 * and stack usage under KASAN.
 	 */
-	return READ_ONCE_NOCHECK((v)->counter);
+	return READ_ONCE((v)->counter);
 }
 
 /**
@@ -39,12 +42,6 @@ static __always_inline int arch_atomic_read(const atomic_t *v)
  */
 static __always_inline void arch_atomic_set(atomic_t *v, int i)
 {
-	/*
-	 * We could use WRITE_ONCE_NOCHECK() if it exists, similar to
-	 * READ_ONCE_NOCHECK() in arch_atomic_read(). But there is no such
-	 * thing at the moment, and introducing it for this case does not
-	 * worth it.
-	 */
 	WRITE_ONCE(v->counter, i);
 }
 
-- 
2.12.1.500.gab5fba24ee-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
