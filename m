Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8F5C6B0292
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 06:11:47 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d64so1260875wmf.9
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 03:11:47 -0700 (PDT)
Received: from mail-wr0-x236.google.com (mail-wr0-x236.google.com. [2a00:1450:400c:c0c::236])
        by mx.google.com with ESMTPS id u139si15459517wmd.111.2017.06.06.03.11.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 03:11:46 -0700 (PDT)
Received: by mail-wr0-x236.google.com with SMTP id g76so51903042wrd.1
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 03:11:46 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH v3 2/7] x86: use s64* for old arg of atomic64_try_cmpxchg()
Date: Tue,  6 Jun 2017 12:11:35 +0200
Message-Id: <626e9ec17fd70591a6560e75df80dc372dc4f486.1496743523.git.dvyukov@google.com>
In-Reply-To: <cover.1496743523.git.dvyukov@google.com>
References: <cover.1496743523.git.dvyukov@google.com>
In-Reply-To: <cover.1496743523.git.dvyukov@google.com>
References: <cover.1496743523.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, will.deacon@arm.com, hpa@zytor.com
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org

atomic64_try_cmpxchg() declares old argument as long*,
this makes it impossible to use it in portable code.
If caller passes long*, it becomes 32-bits on 32-bit arches.
If caller passes s64*, it does not compile on x86_64.

Change type of old arg to s64*.

Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: kasan-dev@googlegroups.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Cc: x86@kernel.org
---
 arch/x86/include/asm/atomic64_64.h | 12 ++++++------
 arch/x86/include/asm/cmpxchg.h     |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/atomic64_64.h b/arch/x86/include/asm/atomic64_64.h
index 8db8879a6d8c..5d9de36a2f04 100644
--- a/arch/x86/include/asm/atomic64_64.h
+++ b/arch/x86/include/asm/atomic64_64.h
@@ -177,7 +177,7 @@ static inline long atomic64_cmpxchg(atomic64_t *v, long old, long new)
 }
 
 #define atomic64_try_cmpxchg atomic64_try_cmpxchg
-static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, long *old, long new)
+static __always_inline bool atomic64_try_cmpxchg(atomic64_t *v, s64 *old, long new)
 {
 	return try_cmpxchg(&v->counter, old, new);
 }
@@ -198,7 +198,7 @@ static inline long atomic64_xchg(atomic64_t *v, long new)
  */
 static inline bool atomic64_add_unless(atomic64_t *v, long a, long u)
 {
-	long c = atomic64_read(v);
+	s64 c = atomic64_read(v);
 	do {
 		if (unlikely(c == u))
 			return false;
@@ -217,7 +217,7 @@ static inline bool atomic64_add_unless(atomic64_t *v, long a, long u)
  */
 static inline long atomic64_dec_if_positive(atomic64_t *v)
 {
-	long dec, c = atomic64_read(v);
+	s64 dec, c = atomic64_read(v);
 	do {
 		dec = c - 1;
 		if (unlikely(dec < 0))
@@ -236,7 +236,7 @@ static inline void atomic64_and(long i, atomic64_t *v)
 
 static inline long atomic64_fetch_and(long i, atomic64_t *v)
 {
-	long val = atomic64_read(v);
+	s64 val = atomic64_read(v);
 
 	do {
 	} while (!atomic64_try_cmpxchg(v, &val, val & i));
@@ -253,7 +253,7 @@ static inline void atomic64_or(long i, atomic64_t *v)
 
 static inline long atomic64_fetch_or(long i, atomic64_t *v)
 {
-	long val = atomic64_read(v);
+	s64 val = atomic64_read(v);
 
 	do {
 	} while (!atomic64_try_cmpxchg(v, &val, val | i));
@@ -270,7 +270,7 @@ static inline void atomic64_xor(long i, atomic64_t *v)
 
 static inline long atomic64_fetch_xor(long i, atomic64_t *v)
 {
-	long val = atomic64_read(v);
+	s64 val = atomic64_read(v);
 
 	do {
 	} while (!atomic64_try_cmpxchg(v, &val, val ^ i));
diff --git a/arch/x86/include/asm/cmpxchg.h b/arch/x86/include/asm/cmpxchg.h
index d90296d061e8..b5069e802d5c 100644
--- a/arch/x86/include/asm/cmpxchg.h
+++ b/arch/x86/include/asm/cmpxchg.h
@@ -157,7 +157,7 @@ extern void __add_wrong_size(void)
 #define __raw_try_cmpxchg(_ptr, _pold, _new, size, lock)		\
 ({									\
 	bool success;							\
-	__typeof__(_ptr) _old = (_pold);				\
+	__typeof__(_ptr) _old = (__typeof__(_ptr))(_pold);		\
 	__typeof__(*(_ptr)) __old = *_old;				\
 	__typeof__(*(_ptr)) __new = (_new);				\
 	switch (size) {							\
-- 
2.13.0.506.g27d5fe0cd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
