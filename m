Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD8D6B02E1
	for <linux-mm@kvack.org>; Mon, 15 May 2017 21:17:39 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u21so124276284pgn.5
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:39 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id 24si11981670pgy.279.2017.05.15.18.17.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 18:17:38 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id s62so19214554pgc.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 18:17:38 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v1 01/11] mm/kasan: rename XXX_is_zero to XXX_is_nonzero
Date: Tue, 16 May 2017 10:16:39 +0900
Message-Id: <1494897409-14408-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1494897409-14408-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

They return positive value, that is, true, if non-zero value
is found. Rename them to reduce confusion.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/kasan.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index c81549d..85ee45b0 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -224,7 +224,7 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
 	return false;
 }
 
-static __always_inline unsigned long bytes_is_zero(const u8 *start,
+static __always_inline unsigned long bytes_is_nonzero(const u8 *start,
 					size_t size)
 {
 	while (size) {
@@ -237,7 +237,7 @@ static __always_inline unsigned long bytes_is_zero(const u8 *start,
 	return 0;
 }
 
-static __always_inline unsigned long memory_is_zero(const void *start,
+static __always_inline unsigned long memory_is_nonzero(const void *start,
 						const void *end)
 {
 	unsigned int words;
@@ -245,11 +245,11 @@ static __always_inline unsigned long memory_is_zero(const void *start,
 	unsigned int prefix = (unsigned long)start % 8;
 
 	if (end - start <= 16)
-		return bytes_is_zero(start, end - start);
+		return bytes_is_nonzero(start, end - start);
 
 	if (prefix) {
 		prefix = 8 - prefix;
-		ret = bytes_is_zero(start, prefix);
+		ret = bytes_is_nonzero(start, prefix);
 		if (unlikely(ret))
 			return ret;
 		start += prefix;
@@ -258,12 +258,12 @@ static __always_inline unsigned long memory_is_zero(const void *start,
 	words = (end - start) / 8;
 	while (words) {
 		if (unlikely(*(u64 *)start))
-			return bytes_is_zero(start, 8);
+			return bytes_is_nonzero(start, 8);
 		start += 8;
 		words--;
 	}
 
-	return bytes_is_zero(start, (end - start) % 8);
+	return bytes_is_nonzero(start, (end - start) % 8);
 }
 
 static __always_inline bool memory_is_poisoned_n(unsigned long addr,
@@ -271,7 +271,7 @@ static __always_inline bool memory_is_poisoned_n(unsigned long addr,
 {
 	unsigned long ret;
 
-	ret = memory_is_zero(kasan_mem_to_shadow((void *)addr),
+	ret = memory_is_nonzero(kasan_mem_to_shadow((void *)addr),
 			kasan_mem_to_shadow((void *)addr + size - 1) + 1);
 
 	if (unlikely(ret)) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
