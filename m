Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3046B026C
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 17:30:55 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c83so3443364pfj.11
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 14:30:55 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id f15si3516104plr.724.2017.11.17.14.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 14:30:53 -0800 (PST)
From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH 1/5] mm/kasan: make space in shadow bytes for advanced check
Date: Fri, 17 Nov 2017 14:30:39 -0800
Message-Id: <20171117223043.7277-2-wen.gang.wang@oracle.com>
In-Reply-To: <20171117223043.7277-1-wen.gang.wang@oracle.com>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, aryabinin@virtuozzo.com
Cc: wen.gang.wang@oracle.com, glider@google.com, dvyukov@google.com

Kasan advanced check, I'm going to add this feature.
Currently Kasan provide the detection of use-after-free and out-of-bounds
problems. It is not able to find the overwrite-on-allocated-memory issue.
We sometimes hit this kind of issue: We have a messed up structure
(dynamially allocated), some of the fields in the structure were
overwritten with unreasaonable values. We know those fields were
overwritten somehow, but we have no easy way to find out which path did the
overwritten. The advanced check wants to help in this scenario.

Normally the write accesses on a given structure happen in only several or
a dozen of functions if the structure is not that complicated. We call
those functions "allowed functions". The idea is that we check if the write
accesses are from the allowed functions and report error accordingly.

As implementation, kasan provides a API to it's user to register their
allowed functions. The API returns a token to users.  At run time, users
bind the memory ranges they are interested in to the check they registered.
Kasan then checks the bound memory ranges with the allowed functions.

This is the first patch in the series it makes room for check in shadow
bytes.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 6f319fb..060ed72 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -128,7 +128,8 @@ static __always_inline bool memory_is_poisoned_1(unsigned long addr)
 
 	if (unlikely(shadow_value)) {
 		s8 last_accessible_byte = addr & KASAN_SHADOW_MASK;
-		return unlikely(last_accessible_byte >= shadow_value);
+		return unlikely(last_accessible_byte >=
+				KASAN_GET_POISON(shadow_value));
 	}
 
 	return false;
@@ -144,7 +145,8 @@ static __always_inline bool memory_is_poisoned_2_4_8(unsigned long addr,
 	 * into 2 shadow bytes, so we need to check them both.
 	 */
 	if (unlikely(((addr + size - 1) & KASAN_SHADOW_MASK) < size - 1))
-		return *shadow_addr || memory_is_poisoned_1(addr + size - 1);
+		return KASAN_GET_POISON(*shadow_addr) ||
+		       memory_is_poisoned_1(addr + size - 1);
 
 	return memory_is_poisoned_1(addr + size - 1);
 }
@@ -155,7 +157,8 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr)
 
 	/* Unaligned 16-bytes access maps into 3 shadow bytes. */
 	if (unlikely(!IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
-		return *shadow_addr || memory_is_poisoned_1(addr + 15);
+		return KASAN_GET_POISON_16(*shadow_addr) ||
+		       memory_is_poisoned_1(addr + 15);
 
 	return *shadow_addr;
 }
@@ -164,7 +167,7 @@ static __always_inline unsigned long bytes_is_nonzero(const u8 *start,
 					size_t size)
 {
 	while (size) {
-		if (unlikely(*start))
+		if (unlikely(KASAN_GET_POISON(*start)))
 			return (unsigned long)start;
 		start++;
 		size--;
@@ -193,7 +196,7 @@ static __always_inline unsigned long memory_is_nonzero(const void *start,
 
 	words = (end - start) / 8;
 	while (words) {
-		if (unlikely(*(u64 *)start))
+		if (unlikely(KASAN_GET_POISON_64(*(u64 *)start)))
 			return bytes_is_nonzero(start, 8);
 		start += 8;
 		words--;
@@ -215,7 +218,8 @@ static __always_inline bool memory_is_poisoned_n(unsigned long addr,
 		s8 *last_shadow = (s8 *)kasan_mem_to_shadow((void *)last_byte);
 
 		if (unlikely(ret != (unsigned long)last_shadow ||
-			((long)(last_byte & KASAN_SHADOW_MASK) >= *last_shadow)))
+			((long)(last_byte & KASAN_SHADOW_MASK) >=
+			KASAN_GET_POISON(*last_shadow))))
 			return true;
 	}
 	return false;
@@ -504,13 +508,15 @@ static void kasan_poison_slab_free(struct kmem_cache *cache, void *object)
 bool kasan_slab_free(struct kmem_cache *cache, void *object)
 {
 	s8 shadow_byte;
+	s8 poison;
 
 	/* RCU slabs could be legally used after free within the RCU period */
 	if (unlikely(cache->flags & SLAB_TYPESAFE_BY_RCU))
 		return false;
 
 	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
-	if (shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE) {
+	poison = KASAN_GET_POISON(shadow_byte);
+	if (poison < 0 || poison >= KASAN_SHADOW_SCALE_SIZE) {
 		kasan_report_double_free(cache, object,
 				__builtin_return_address(1));
 		return true;
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index c70851a..df7fbfe 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -8,6 +8,18 @@
 #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
 #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
 
+/* We devide one shadow byte into two parts: "check" and "poison".
+ * "check" is a used for advanced check.
+ * "poison" is used to store the foot print of the tracked memory,
+ * For a paticular address, one extra check is enough. So we can have up to
+ * (1 << (KASAN_CHECK_BITS) - 1) - 1 checks. That's 0b001 to 0b110 (0b111 is
+ * reserved for poison values)
+ *
+ * The bits occupition in shadow bytes (P for poison, C for check):
+ *
+ * |P|C|C|C|P|P|P|P|
+ *
+ */
 #define KASAN_FREE_PAGE         0xFF  /* page was freed */
 #define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
 #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
@@ -29,6 +41,19 @@
 #define KASAN_ABI_VERSION 1
 #endif
 
+#define KASAN_POISON_MASK	0x8F
+#define KASAN_POISON_MASK_16	0x8F8F
+#define KASAN_POISON_MASK_64	0x8F8F8F8F8F8F8F8F
+#define KASAN_CHECK_MASK	0x70
+#define KASAN_CHECK_SHIFT	4
+#define KASAN_CHECK_BITS	3
+
+#define KASAN_GET_POISON(val) ((s8)((val) & KASAN_POISON_MASK))
+#define KASAN_CHECK_LOWMASK (KASAN_CHECK_MASK >> KASAN_CHECK_SHIFT)
+/* 16 bits and 64 bits version */
+#define KASAN_GET_POISON_16(val) ((val) & KASAN_POISON_MASK_16)
+#define KASAN_GET_POISON_64(val) ((val) & KASAN_POISON_MASK_64)
+
 struct kasan_access_info {
 	const void *access_addr;
 	const void *first_bad_addr;
@@ -113,4 +138,11 @@ static inline void quarantine_reduce(void) { }
 static inline void quarantine_remove_cache(struct kmem_cache *cache) { }
 #endif
 
+static inline u8 kasan_get_check(u8 val)
+{
+	val &= KASAN_CHECK_MASK;
+	val >>= KASAN_CHECK_SHIFT;
+
+	return (val ^ KASAN_CHECK_LOWMASK) ?  val : 0;
+}
 #endif
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 6bcfb01..caf3a13 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -61,20 +61,24 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
 {
 	const char *bug_type = "unknown-crash";
 	u8 *shadow_addr;
+	s8 poison;
 
 	info->first_bad_addr = find_first_bad_addr(info->access_addr,
 						info->access_size);
 
 	shadow_addr = (u8 *)kasan_mem_to_shadow(info->first_bad_addr);
-
+	poison = KASAN_GET_POISON(*shadow_addr);
 	/*
 	 * If shadow byte value is in [0, KASAN_SHADOW_SCALE_SIZE) we can look
 	 * at the next shadow byte to determine the type of the bad access.
 	 */
-	if (*shadow_addr > 0 && *shadow_addr <= KASAN_SHADOW_SCALE_SIZE - 1)
-		shadow_addr++;
+	if (poison > 0 && poison <= KASAN_SHADOW_SCALE_SIZE - 1)
+		poison = KASAN_GET_POISON(*(shadow_addr + 1));
+
+	if (poison < 0)
+		poison |= KASAN_CHECK_MASK;
 
-	switch (*shadow_addr) {
+	switch ((u8)poison) {
 	case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
 		/*
 		 * In theory it's still possible to see these shadow values
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
