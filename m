Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B80596B00A8
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 07:28:57 -0400 (EDT)
From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: [PATCH v2] SLUB: fix ARCH_KMALLOC_MINALIGN cases 64 and 256
Date: Fri, 28 Aug 2009 14:28:54 +0300
Message-Id: <1251458934-25838-1-git-send-email-aaro.koskinen@nokia.com>
In-Reply-To: <>
References: <>
Sender: owner-linux-mm@kvack.org
To: mpm@selenic.com, penberg@cs.helsinki.fi, cl@linux-foundation.org, linux-mm@kvack.org
Cc: Artem.Bityutskiy@nokia.com
List-ID: <linux-mm.kvack.org>

If the minalign is 64 bytes, then the 96 byte cache should not be created
because it would conflict with the 128 byte cache.

If the minalign is 256 bytes, patching the size_index table should not
result in a buffer overrun.

The calculation "(i - 1) / 8" used to access size_index[] is moved to
a separate function as suggested by Christoph Lameter.

Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>
---

v2: Updated based on comments by Christoph Lameter.

The patch is against v2.6.31-rc7.

 include/linux/slub_def.h |    6 ++----
 mm/slub.c                |   29 +++++++++++++++++++++++------
 2 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index c1c862b..ac58d10 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -153,12 +153,10 @@ static __always_inline int kmalloc_index(size_t size)
 	if (size <= KMALLOC_MIN_SIZE)
 		return KMALLOC_SHIFT_LOW;
 
-#if KMALLOC_MIN_SIZE <= 64
-	if (size > 64 && size <= 96)
+	if (KMALLOC_MIN_SIZE <= 32 && size > 64 && size <= 96)
 		return 1;
-	if (size > 128 && size <= 192)
+	if (KMALLOC_MIN_SIZE <= 64 && size > 128 && size <= 192)
 		return 2;
-#endif
 	if (size <=          8) return 3;
 	if (size <=         16) return 4;
 	if (size <=         32) return 5;
diff --git a/mm/slub.c b/mm/slub.c
index b9f1491..259df05 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2789,6 +2789,10 @@ static s8 size_index[24] = {
 	2,	/* 184 */
 	2	/* 192 */
 };
+static inline int size_index_elem(size_t bytes)
+{
+	return (bytes - 1) / 8;
+}
 
 static struct kmem_cache *get_slab(size_t size, gfp_t flags)
 {
@@ -2798,7 +2802,7 @@ static struct kmem_cache *get_slab(size_t size, gfp_t flags)
 		if (!size)
 			return ZERO_SIZE_PTR;
 
-		index = size_index[(size - 1) / 8];
+		index = size_index[size_index_elem(size)];
 	} else
 		index = fls(size - 1);
 
@@ -3156,10 +3160,12 @@ void __init kmem_cache_init(void)
 	slab_state = PARTIAL;
 
 	/* Caches that are not of the two-to-the-power-of size */
-	if (KMALLOC_MIN_SIZE <= 64) {
+	if (KMALLOC_MIN_SIZE <= 32) {
 		create_kmalloc_cache(&kmalloc_caches[1],
 				"kmalloc-96", 96, GFP_NOWAIT);
 		caches++;
+	}
+	if (KMALLOC_MIN_SIZE <= 64) {
 		create_kmalloc_cache(&kmalloc_caches[2],
 				"kmalloc-192", 192, GFP_NOWAIT);
 		caches++;
@@ -3186,17 +3192,28 @@ void __init kmem_cache_init(void)
 	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
 		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
 
-	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8)
-		size_index[(i - 1) / 8] = KMALLOC_SHIFT_LOW;
+	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8) {
+		int elem = size_index_elem(i);
+		if (elem >= ARRAY_SIZE(size_index))
+			break;
+		size_index[elem] = KMALLOC_SHIFT_LOW;
+	}
 
-	if (KMALLOC_MIN_SIZE == 128) {
+	if (KMALLOC_MIN_SIZE == 64) {
+		/*
+		 * The 96 byte size cache is not used if the alignment
+		 * is 64 byte.
+		 */
+		for (i = 64 + 8; i <= 96; i += 8)
+			size_index[size_index_elem(i)] = 7;
+	} else if (KMALLOC_MIN_SIZE == 128) {
 		/*
 		 * The 192 byte sized cache is not used if the alignment
 		 * is 128 byte. Redirect kmalloc to use the 256 byte cache
 		 * instead.
 		 */
 		for (i = 128 + 8; i <= 192; i += 8)
-			size_index[(i - 1) / 8] = 8;
+			size_index[size_index_elem(i)] = 8;
 	}
 
 	slab_state = UP;
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
