Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0DBE06B0085
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 04:06:17 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so748963pbb.12
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 01:06:17 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id vu10si1517510pbc.339.2014.03.12.01.06.15
        for <linux-mm@kvack.org>;
        Wed, 12 Mar 2014 01:06:17 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RESEND PATCH] slab: fix wrongly used macro
Date: Wed, 12 Mar 2014 17:06:19 +0900
Message-Id: <1394611579-7709-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

commit 'slab: restrict the number of objects in a slab' uses
__builtin_constant_p() on #if macro. It is wrong usage of builtin
function, but it is compiled on x86 without any problem, so I can't
find it before 0 day build system find it.

This commit fixes the situation by using KMALLOC_MIN_SIZE, instead of
KMALLOC_SHIFT_LOW. KMALLOC_SHIFT_LOW is parsed to ilog2() on some
architecture and this ilog2() uses __builtin_constant_p() and results in
the problem. This problem would disappear by using KMALLOC_MIN_SIZE,
since it is just constant.

Tested-by: David Rientjes <rientjes@google.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
This patch is based on Pekka's slab/next branch.

diff --git a/include/linux/slab.h b/include/linux/slab.h
index d015dec..5df89f7 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -201,17 +201,6 @@ struct kmem_cache {
 #ifndef KMALLOC_SHIFT_LOW
 #define KMALLOC_SHIFT_LOW	5
 #endif
-
-/*
- * This restriction comes from byte sized index implementation.
- * Page size is normally 2^12 bytes and, in this case, if we want to use
- * byte sized index which can represent 2^8 entries, the size of the object
- * should be equal or greater to 2^12 / 2^8 = 2^4 = 16.
- * If minimum size of kmalloc is less than 16, we use it as minimum object
- * size and give up to use byte sized index.
- */
-#define SLAB_OBJ_MIN_SIZE	(KMALLOC_SHIFT_LOW < 4 ? \
-				(1 << KMALLOC_SHIFT_LOW) : 16)
 #endif
 
 #ifdef CONFIG_SLUB
@@ -253,6 +242,17 @@ struct kmem_cache {
 #define KMALLOC_MIN_SIZE (1 << KMALLOC_SHIFT_LOW)
 #endif
 
+/*
+ * This restriction comes from byte sized index implementation.
+ * Page size is normally 2^12 bytes and, in this case, if we want to use
+ * byte sized index which can represent 2^8 entries, the size of the object
+ * should be equal or greater to 2^12 / 2^8 = 2^4 = 16.
+ * If minimum size of kmalloc is less than 16, we use it as minimum object
+ * size and give up to use byte sized index.
+ */
+#define SLAB_OBJ_MIN_SIZE      (KMALLOC_MIN_SIZE < 16 ? \
+                               (KMALLOC_MIN_SIZE) : 16)
+
 #ifndef CONFIG_SLOB
 extern struct kmem_cache *kmalloc_caches[KMALLOC_SHIFT_HIGH + 1];
 #ifdef CONFIG_ZONE_DMA
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
