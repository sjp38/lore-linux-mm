Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83D196B0007
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:07:54 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r29so11988832wra.13
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:07:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a63sor683116wmf.82.2018.03.05.12.07.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:07:53 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 03/25] slab: make kmalloc_size() return "unsigned int"
Date: Mon,  5 Mar 2018 23:07:08 +0300
Message-Id: <20180305200730.15812-3-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

kmalloc_size() derives size of kmalloc cache from internal index,
which can't be negative.

Propagate unsignedness a bit.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slab.h | 4 ++--
 mm/slab_common.c     | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 296f33a512eb..ad157fbf3886 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -522,11 +522,11 @@ static __always_inline void *kmalloc(size_t size, gfp_t flags)
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
index 7626a64b8f14..d3f4209c297d 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1138,9 +1138,9 @@ void __init create_kmalloc_caches(slab_flags_t flags)
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
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
