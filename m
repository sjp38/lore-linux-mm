Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C06E6B0069
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:12 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id w95so12721897wrc.20
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e26sor1986526wmc.20.2017.11.23.14.17.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:10 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 02/23] slab: make kmalloc_size() return "unsigned int"
Date: Fri, 24 Nov 2017 01:16:07 +0300
Message-Id: <20171123221628.8313-2-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

kmalloc_size() derives size of kmalloc cache from internal index,
which of course can't be negative.

Propagate unsignedness a bit.

Space savings:

	add/remove: 0/0 grow/shrink: 0/2 up/down: 0/-2 (-2)
	Function                                     old     new   delta
	new_kmalloc_cache                             42      41      -1
	create_kmalloc_caches                        238     237      -1

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slab.h | 4 ++--
 mm/slab_common.c     | 8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index e765800d7c9b..f3e4aca74406 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -509,11 +509,11 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
  * return size or 0 if a kmalloc cache for that
  * size does not exist
  */
-static __always_inline int kmalloc_size(int n)
+static __always_inline unsigned int kmalloc_size(unsigned int n)
 {
 #ifndef CONFIG_SLOB
 	if (n > 2)
-		return 1 << n;
+		return 1U << n;
 
 	if (n == 1 && KMALLOC_MIN_SIZE <= 32)
 		return 96;
diff --git a/mm/slab_common.c b/mm/slab_common.c
index c8cb36774ba1..8ba0ffb31279 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1057,7 +1057,7 @@ void __init setup_kmalloc_cache_index_table(void)
 	}
 }
 
-static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
+static void __init new_kmalloc_cache(unsigned int idx, slab_flags_t flags)
 {
 	kmalloc_caches[idx] = create_kmalloc_cache(kmalloc_info[idx].name,
 					kmalloc_info[idx].size, flags);
@@ -1070,7 +1070,7 @@ static void __init new_kmalloc_cache(int idx, slab_flags_t flags)
  */
 void __init create_kmalloc_caches(slab_flags_t flags)
 {
-	int i;
+	unsigned int i;
 
 	for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
 		if (!kmalloc_caches[i])
@@ -1095,9 +1095,9 @@ void __init create_kmalloc_caches(slab_flags_t flags)
 		struct kmem_cache *s = kmalloc_caches[i];
 
 		if (s) {
-			int size = kmalloc_size(i);
+			unsigned int size = kmalloc_size(i);
 			char *n = kasprintf(GFP_NOWAIT,
-				 "dma-kmalloc-%d", size);
+				 "dma-kmalloc-%u", size);
 
 			BUG_ON(!n);
 			kmalloc_dma_caches[i] = create_kmalloc_cache(n,
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
