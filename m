Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id AB2636B0037
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 02:03:01 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fa1so2195984pad.37
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 23:03:01 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 3/5] slab: restrict the number of objects in a slab
Date: Thu, 17 Oct 2013 15:03:15 +0900
Message-Id: <1381989797-29269-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1381989797-29269-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381989797-29269-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

To prepare to implement byte sized index for managing the freelist
of a slab, we should restrict the number of objects in a slab to be less
or equal to 256, since byte only represent 256 different values.
Setting the size of object to value equal or more than newly introduced
SLAB_MIN_SIZE ensures that the number of objects in a slab is less or
equal to 256 for a slab with 1 page.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index ec197b9..3cee122 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -157,6 +157,10 @@
 #define ARCH_KMALLOC_FLAGS SLAB_HWCACHE_ALIGN
 #endif
 
+/* We use byte sized index to manage the freelist of a slab */
+#define NR_PER_BYTE (1 << BITS_PER_BYTE)
+#define SLAB_MIN_SIZE (PAGE_SIZE >> BITS_PER_BYTE)
+
 /*
  * true if a page was allocated from pfmemalloc reserves for network-based
  * swap
@@ -2016,6 +2020,10 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 		if (!num)
 			continue;
 
+		/* We can't handler number of objects more than NR_PER_BYTE */
+		if (num > NR_PER_BYTE)
+			break;
+
 		if (flags & CFLGS_OFF_SLAB) {
 			/*
 			 * Max number of objs-per-slab for caches which
@@ -2258,6 +2266,12 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		flags |= CFLGS_OFF_SLAB;
 
 	size = ALIGN(size, cachep->align);
+	/*
+	 * We want to restrict the number of objects in a slab to be equal or
+	 * less than 256 in order to manage freelist via byte sized indexes.
+	 */
+	if (size < SLAB_MIN_SIZE)
+		size = ALIGN(SLAB_MIN_SIZE, cachep->align);
 
 	left_over = calculate_slab_order(cachep, size, cachep->align, flags);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
