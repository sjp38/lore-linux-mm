Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 754636B0268
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 17:30:54 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id n61so4755029qte.3
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 14:30:54 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f65si3704558qkj.445.2017.11.17.14.30.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 14:30:52 -0800 (PST)
From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH 2/5] mm/kasan: pass access mode to poison check functions
Date: Fri, 17 Nov 2017 14:30:40 -0800
Message-Id: <20171117223043.7277-3-wen.gang.wang@oracle.com>
In-Reply-To: <20171117223043.7277-1-wen.gang.wang@oracle.com>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, aryabinin@virtuozzo.com
Cc: wen.gang.wang@oracle.com, glider@google.com, dvyukov@google.com

This is the second patch for the Kasan advanced check feature.
The advanced check would need access mode to make decision.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 060ed72..4501422 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -122,7 +122,7 @@ void kasan_unpoison_stack_above_sp_to(const void *watermark)
  * depending on memory access size X.
  */
 
-static __always_inline bool memory_is_poisoned_1(unsigned long addr)
+static __always_inline bool memory_is_poisoned_1(unsigned long addr, bool write)
 {
 	s8 shadow_value = *(s8 *)kasan_mem_to_shadow((void *)addr);
 
@@ -136,7 +136,8 @@ static __always_inline bool memory_is_poisoned_1(unsigned long addr)
 }
 
 static __always_inline bool memory_is_poisoned_2_4_8(unsigned long addr,
-						unsigned long size)
+						     unsigned long size,
+						     bool write)
 {
 	u8 *shadow_addr = (u8 *)kasan_mem_to_shadow((void *)addr);
 
@@ -146,25 +147,27 @@ static __always_inline bool memory_is_poisoned_2_4_8(unsigned long addr,
 	 */
 	if (unlikely(((addr + size - 1) & KASAN_SHADOW_MASK) < size - 1))
 		return KASAN_GET_POISON(*shadow_addr) ||
-		       memory_is_poisoned_1(addr + size - 1);
+		       memory_is_poisoned_1(addr + size - 1, write);
 
-	return memory_is_poisoned_1(addr + size - 1);
+	return memory_is_poisoned_1(addr + size - 1, write);
 }
 
-static __always_inline bool memory_is_poisoned_16(unsigned long addr)
+static __always_inline bool memory_is_poisoned_16(unsigned long addr,
+						  bool write)
 {
 	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
 
 	/* Unaligned 16-bytes access maps into 3 shadow bytes. */
 	if (unlikely(!IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
 		return KASAN_GET_POISON_16(*shadow_addr) ||
-		       memory_is_poisoned_1(addr + 15);
+		       memory_is_poisoned_1(addr + 15, write);
 
 	return *shadow_addr;
 }
 
 static __always_inline unsigned long bytes_is_nonzero(const u8 *start,
-					size_t size)
+						      size_t size,
+						      bool write)
 {
 	while (size) {
 		if (unlikely(KASAN_GET_POISON(*start)))
@@ -177,18 +180,19 @@ static __always_inline unsigned long bytes_is_nonzero(const u8 *start,
 }
 
 static __always_inline unsigned long memory_is_nonzero(const void *start,
-						const void *end)
+						       const void *end,
+						       bool write)
 {
 	unsigned int words;
 	unsigned long ret;
 	unsigned int prefix = (unsigned long)start % 8;
 
 	if (end - start <= 16)
-		return bytes_is_nonzero(start, end - start);
+		return bytes_is_nonzero(start, end - start, write);
 
 	if (prefix) {
 		prefix = 8 - prefix;
-		ret = bytes_is_nonzero(start, prefix);
+		ret = bytes_is_nonzero(start, prefix, write);
 		if (unlikely(ret))
 			return ret;
 		start += prefix;
@@ -197,21 +201,23 @@ static __always_inline unsigned long memory_is_nonzero(const void *start,
 	words = (end - start) / 8;
 	while (words) {
 		if (unlikely(KASAN_GET_POISON_64(*(u64 *)start)))
-			return bytes_is_nonzero(start, 8);
+			return bytes_is_nonzero(start, 8, write);
 		start += 8;
 		words--;
 	}
 
-	return bytes_is_nonzero(start, (end - start) % 8);
+	return bytes_is_nonzero(start, (end - start) % 8, write);
 }
 
 static __always_inline bool memory_is_poisoned_n(unsigned long addr,
-						size_t size)
+						 size_t size,
+						 bool write)
 {
 	unsigned long ret;
 
 	ret = memory_is_nonzero(kasan_mem_to_shadow((void *)addr),
-			kasan_mem_to_shadow((void *)addr + size - 1) + 1);
+			kasan_mem_to_shadow((void *)addr + size - 1) + 1,
+			write);
 
 	if (unlikely(ret)) {
 		unsigned long last_byte = addr + size - 1;
@@ -225,24 +231,25 @@ static __always_inline bool memory_is_poisoned_n(unsigned long addr,
 	return false;
 }
 
-static __always_inline bool memory_is_poisoned(unsigned long addr, size_t size)
+static __always_inline bool memory_is_poisoned(unsigned long addr, size_t size,
+					       bool write)
 {
 	if (__builtin_constant_p(size)) {
 		switch (size) {
 		case 1:
-			return memory_is_poisoned_1(addr);
+			return memory_is_poisoned_1(addr, write);
 		case 2:
 		case 4:
 		case 8:
-			return memory_is_poisoned_2_4_8(addr, size);
+			return memory_is_poisoned_2_4_8(addr, size, write);
 		case 16:
-			return memory_is_poisoned_16(addr);
+			return memory_is_poisoned_16(addr, write);
 		default:
 			BUILD_BUG();
 		}
 	}
 
-	return memory_is_poisoned_n(addr, size);
+	return memory_is_poisoned_n(addr, size, write);
 }
 
 static __always_inline void check_memory_region_inline(unsigned long addr,
@@ -258,7 +265,7 @@ static __always_inline void check_memory_region_inline(unsigned long addr,
 		return;
 	}
 
-	if (likely(!memory_is_poisoned(addr, size)))
+	if (likely(!memory_is_poisoned(addr, size, write)))
 		return;
 
 	kasan_report(addr, size, write, ret_ip);
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
