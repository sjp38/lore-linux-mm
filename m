Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C56E96B02EE
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:17:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b74so82349661pfd.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:44 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 1si12048301plx.288.2017.05.15.18.17.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:17:42 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id s62so19214692pgc.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:42 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v1 02/11] mm/kasan: don't fetch the next shadow value speculartively
Date: Tue, 16 May 2017 10:16:40 +0900
Message-Id: <1494897409-14408-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Fetching the next shadow value speculartively has pros and cons.
If shadow bytes are zero, we can exit the check with a single branch.
However, it could cause unaligned access. And, if the next shadow value
isn't zero, we need to do additional check. Next shadow value can be
non-zero due to various reasons.

Moreoever, following patch will introduce on-demand shadow memory
allocation/mapping and this speculartive fetch would cause more stale
TLB case.

So, I think that there is more side-effect than the benefit.
This patch removes it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/kasan.c | 104 +++++++++++++++++++++++--------------------------------
 1 file changed, 44 insertions(+), 60 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 85ee45b0..97d3560 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -136,90 +136,74 @@ static __always_inline bool memory_is_poisoned_1(unsigned long addr)
 
 static __always_inline bool memory_is_poisoned_2(unsigned long addr)
 {
-	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
-
-	if (unlikely(*shadow_addr)) {
-		if (memory_is_poisoned_1(addr + 1))
-			return true;
-
-		/*
-		 * If single shadow byte covers 2-byte access, we don't
-		 * need to do anything more. Otherwise, test the first
-		 * shadow byte.
-		 */
-		if (likely(((addr + 1) & KASAN_SHADOW_MASK) != 0))
-			return false;
+	if (unlikely(memory_is_poisoned_1(addr)))
+		return true;
 
-		return unlikely(*(u8 *)shadow_addr);
-	}
+	/*
+	 * If single shadow byte covers 2-byte access, we don't
+	 * need to do anything more. Otherwise, test the first
+	 * shadow byte.
+	 */
+	if (likely(((addr + 1) & KASAN_SHADOW_MASK) != 0))
+		return false;
 
-	return false;
+	return memory_is_poisoned_1(addr + 1);
 }
 
 static __always_inline bool memory_is_poisoned_4(unsigned long addr)
 {
-	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
-
-	if (unlikely(*shadow_addr)) {
-		if (memory_is_poisoned_1(addr + 3))
-			return true;
-
-		/*
-		 * If single shadow byte covers 4-byte access, we don't
-		 * need to do anything more. Otherwise, test the first
-		 * shadow byte.
-		 */
-		if (likely(((addr + 3) & KASAN_SHADOW_MASK) >= 3))
-			return false;
+	if (unlikely(memory_is_poisoned_1(addr + 3)))
+		return true;
 
-		return unlikely(*(u8 *)shadow_addr);
-	}
+	/*
+	 * If single shadow byte covers 4-byte access, we don't
+	 * need to do anything more. Otherwise, test the first
+	 * shadow byte.
+	 */
+	if (likely(((addr + 3) & KASAN_SHADOW_MASK) >= 3))
+		return false;
 
-	return false;
+	return memory_is_poisoned_1(addr);
 }
 
 static __always_inline bool memory_is_poisoned_8(unsigned long addr)
 {
-	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
+	u8 *shadow_addr = (u8 *)kasan_mem_to_shadow((void *)addr);
 
-	if (unlikely(*shadow_addr)) {
-		if (memory_is_poisoned_1(addr + 7))
-			return true;
+	if (unlikely(*shadow_addr))
+		return true;
 
-		/*
-		 * If single shadow byte covers 8-byte access, we don't
-		 * need to do anything more. Otherwise, test the first
-		 * shadow byte.
-		 */
-		if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
-			return false;
+	/*
+	 * If single shadow byte covers 8-byte access, we don't
+	 * need to do anything more. Otherwise, test the first
+	 * shadow byte.
+	 */
+	if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
+		return false;
 
-		return unlikely(*(u8 *)shadow_addr);
-	}
+	if (unlikely(memory_is_poisoned_1(addr + 7)))
+		return true;
 
 	return false;
 }
 
 static __always_inline bool memory_is_poisoned_16(unsigned long addr)
 {
-	u32 *shadow_addr = (u32 *)kasan_mem_to_shadow((void *)addr);
-
-	if (unlikely(*shadow_addr)) {
-		u16 shadow_first_bytes = *(u16 *)shadow_addr;
+	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
 
-		if (unlikely(shadow_first_bytes))
-			return true;
+	if (unlikely(*shadow_addr))
+		return true;
 
-		/*
-		 * If two shadow bytes covers 16-byte access, we don't
-		 * need to do anything more. Otherwise, test the last
-		 * shadow byte.
-		 */
-		if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
-			return false;
+	/*
+	 * If two shadow bytes covers 16-byte access, we don't
+	 * need to do anything more. Otherwise, test the last
+	 * shadow byte.
+	 */
+	if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
+		return false;
 
-		return memory_is_poisoned_1(addr + 15);
-	}
+	if (unlikely(memory_is_poisoned_1(addr + 15)))
+		return true;
 
 	return false;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
