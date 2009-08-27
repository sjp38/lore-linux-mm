Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9D16B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 11:39:22 -0400 (EDT)
From: Aaro Koskinen <aaro.koskinen@nokia.com>
Subject: [PATCH] SLUB: fix ARCH_KMALLOC_MINALIGN cases 64 and 256
Date: Thu, 27 Aug 2009 18:38:11 +0300
Message-Id: <1251387491-8417-1-git-send-email-aaro.koskinen@nokia.com>
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

Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>
---

The patch is against v2.6.31-rc7.

 include/linux/slub_def.h |    2 ++
 mm/slub.c                |   15 ++++++++++++---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index c1c862b..ed291c8 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -154,8 +154,10 @@ static __always_inline int kmalloc_index(size_t size)
 		return KMALLOC_SHIFT_LOW;
 
 #if KMALLOC_MIN_SIZE <= 64
+#if KMALLOC_MIN_SIZE <= 32
 	if (size > 64 && size <= 96)
 		return 1;
+#endif
 	if (size > 128 && size <= 192)
 		return 2;
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index b9f1491..3d32ebf 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3156,10 +3156,12 @@ void __init kmem_cache_init(void)
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
@@ -3186,10 +3188,17 @@ void __init kmem_cache_init(void)
 	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 256 ||
 		(KMALLOC_MIN_SIZE & (KMALLOC_MIN_SIZE - 1)));
 
-	for (i = 8; i < KMALLOC_MIN_SIZE; i += 8)
+	for (i = 8; i < min(KMALLOC_MIN_SIZE, 192 + 8); i += 8)
 		size_index[(i - 1) / 8] = KMALLOC_SHIFT_LOW;
 
-	if (KMALLOC_MIN_SIZE == 128) {
+	if (KMALLOC_MIN_SIZE == 64) {
+		/*
+		 * The 96 byte size cache is not used if the alignment
+		 * is 64 byte.
+		 */
+		for (i = 64 + 8; i <= 96; i += 8)
+			size_index[(i - 1) / 8] = 7;
+	} else if (KMALLOC_MIN_SIZE == 128) {
 		/*
 		 * The 192 byte sized cache is not used if the alignment
 		 * is 128 byte. Redirect kmalloc to use the 256 byte cache
-- 
1.5.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
