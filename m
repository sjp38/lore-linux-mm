Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D5DC36B033C
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:18:18 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q6so111861913pgn.12
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:18:18 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id l70si11996251pge.240.2017.05.15.18.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:18:18 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id n23so16743032pfb.3
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:18:18 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v1 11/11] mm/kasan: change the order of shadow memory check
Date: Tue, 16 May 2017 10:16:49 +0900
Message-Id: <1494897409-14408-12-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Majority of access in the kernel is an access to slab objects.
In current implementation, we checks two types of shadow memory
in this case and it causes performance regression.

kernel build (2048 MB QEMU)
Base vs per-page
219 sec vs 238 sec

Although current per-page shadow implementation is easy
to understand in terms of concept, this performance regression is
too bad so this patch changes the check order from per-page and
then per-byte shadow to per-byte and then per-page shadow.

This change would increases chance of stale TLB problem since
mapping for per-byte shadow isn't fully synchronized and we will try
to access all the region on this shadow memory. But, it doesn't hurt
the correctness so there is no problem on this new implementation.
Following is the result of this patch.

kernel build (2048 MB QEMU)
base vs per-page vs this patch
219 sec vs 238 sec vs 222 sec

Performance is restored.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/kasan.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index e5612be..76c1c37 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -587,14 +587,6 @@ static __always_inline u8 pshadow_val(unsigned long addr, size_t size)
 
 static __always_inline bool memory_is_poisoned(unsigned long addr, size_t size)
 {
-	u8 shadow_val = pshadow_val(addr, size);
-
-	if (!shadow_val)
-		return false;
-
-	if (shadow_val != KASAN_PER_PAGE_BYPASS)
-		return true;
-
 	if (__builtin_constant_p(size)) {
 		switch (size) {
 		case 1:
@@ -649,6 +641,9 @@ static __always_inline void check_memory_region_inline(unsigned long addr,
 	if (likely(!memory_is_poisoned(addr, size)))
 		return;
 
+	if (!pshadow_val(addr, size))
+		return;
+
 	check_memory_region_slow(addr, size, write, ret_ip);
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
