Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 48D276B0253
	for <linux-mm@kvack.org>; Sun, 13 Sep 2015 22:17:28 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so130936353pac.2
        for <linux-mm@kvack.org>; Sun, 13 Sep 2015 19:17:28 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id cy1si19607606pad.200.2015.09.13.19.17.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Sun, 13 Sep 2015 19:17:27 -0700 (PDT)
Message-ID: <55F62C65.7070100@huawei.com>
Date: Mon, 14 Sep 2015 10:09:41 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V2] kasan: use IS_ALIGNED in memory_is_poisoned_8()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, "long.wanglong" <long.wanglong@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Use IS_ALIGNED() to determine whether the shadow span two bytes.
It generates less code and more readable. Add some comments in 
shadow check functions.

Please apply "kasan: fix last shadow judgement in memory_is_poisoned_16()"
first.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/kasan/kasan.c | 21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 8da2114..00d5605 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -86,6 +86,10 @@ static __always_inline bool memory_is_poisoned_2(unsigned long addr)
 		if (memory_is_poisoned_1(addr + 1))
 			return true;
 
+		/*
+		 * If the shadow spans two bytes, the first byte should
+		 * be zero.
+		 */
 		if (likely(((addr + 1) & KASAN_SHADOW_MASK) != 0))
 			return false;
 
@@ -103,6 +107,10 @@ static __always_inline bool memory_is_poisoned_4(unsigned long addr)
 		if (memory_is_poisoned_1(addr + 3))
 			return true;
 
+		/*
+		 * If the shadow spans two bytes, the first byte should
+		 * be zero.
+		 */
 		if (likely(((addr + 3) & KASAN_SHADOW_MASK) >= 3))
 			return false;
 
@@ -120,7 +128,11 @@ static __always_inline bool memory_is_poisoned_8(unsigned long addr)
 		if (memory_is_poisoned_1(addr + 7))
 			return true;
 
-		if (likely(((addr + 7) & KASAN_SHADOW_MASK) >= 7))
+		/*
+		 * If the shadow spans two bytes, the first byte should
+		 * be zero.
+		 */
+		if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
 			return false;
 
 		return unlikely(*(u8 *)shadow_addr);
@@ -139,7 +151,12 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
 		if (unlikely(shadow_first_bytes))
 			return true;
 
-		if (likely(IS_ALIGNED(addr, 8)))
+		/*
+		 * If the shadow spans three bytes, we should continue to
+		 * check the last byte. The first two bytes which we
+		 * checked above should always be zero.
+		 */
+		if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
 			return false;
 
 		return memory_is_poisoned_1(addr + 15);
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
