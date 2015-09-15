Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 029206B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 22:04:21 -0400 (EDT)
Received: by obqa2 with SMTP id a2so123787221obq.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 19:04:20 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id mm1si8117552obb.103.2015.09.14.19.04.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Sep 2015 19:04:20 -0700 (PDT)
Message-ID: <55F77C52.3010101@huawei.com>
Date: Tue, 15 Sep 2015 10:02:58 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V3] kasan: use IS_ALIGNED in memory_is_poisoned_8()
References: <55F62C65.7070100@huawei.com> <CAPAsAGxf_OQD502cW1nbXJ7WdRxyKqTx6+BJJpJoD-Z6WFCZMg@mail.gmail.com>
In-Reply-To: <CAPAsAGxf_OQD502cW1nbXJ7WdRxyKqTx6+BJJpJoD-Z6WFCZMg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <adech.fo@gmail.com>, Rusty
 Russell <rusty@rustcorp.com.au>, Michal Marek <mmarek@suse.cz>, "long.wanglong" <long.wanglong@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Use IS_ALIGNED() to determine whether the shadow span two bytes. It
generates less code and more readable. Also add some comments in shadow
check functions.

Please apply "kasan: fix last shadow judgement in memory_is_poisoned_16()"
first.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/kasan/kasan.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 8da2114..d0a3af8 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -86,6 +86,11 @@ static __always_inline bool memory_is_poisoned_2(unsigned long addr)
 		if (memory_is_poisoned_1(addr + 1))
 			return true;
 
+		/*
+		 * If single shadow byte covers 2-byte access, we don't
+		 * need to do anything more. Otherwise, test the first
+		 * shadow byte.
+		 */
 		if (likely(((addr + 1) & KASAN_SHADOW_MASK) != 0))
 			return false;
 
@@ -103,6 +108,11 @@ static __always_inline bool memory_is_poisoned_4(unsigned long addr)
 		if (memory_is_poisoned_1(addr + 3))
 			return true;
 
+		/*
+		 * If single shadow byte covers 4-byte access, we don't
+		 * need to do anything more. Otherwise, test the first
+		 * shadow byte.
+		 */
 		if (likely(((addr + 3) & KASAN_SHADOW_MASK) >= 3))
 			return false;
 
@@ -120,7 +130,12 @@ static __always_inline bool memory_is_poisoned_8(unsigned long addr)
 		if (memory_is_poisoned_1(addr + 7))
 			return true;
 
-		if (likely(((addr + 7) & KASAN_SHADOW_MASK) >= 7))
+		/*
+		 * If single shadow byte covers 8-byte access, we don't
+		 * need to do anything more. Otherwise, test the first
+		 * shadow byte.
+		 */
+		if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
 			return false;
 
 		return unlikely(*(u8 *)shadow_addr);
@@ -139,7 +154,12 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
 		if (unlikely(shadow_first_bytes))
 			return true;
 
-		if (likely(IS_ALIGNED(addr, 8)))
+		/*
+		 * If two shadow bytes covers 16-byte access, we don't
+		 * need to do anything more. Otherwise, test the last
+		 * shadow byte.
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
