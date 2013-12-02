Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 078826B0036
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 03:47:26 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so17391080pdj.8
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 00:47:26 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id pj7si14074286pbc.99.2013.12.02.00.47.24
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 00:47:25 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 1/5] slab: factor out calculate nr objects in cache_estimate
Date: Mon,  2 Dec 2013 17:49:39 +0900
Message-Id: <1385974183-31423-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This logic is not simple to understand so that making separate function
helping readability. Additionally, we can use this change in the
following patch which implement for freelist to have another sized index
in according to nr objects.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index eb043bf..e749f75 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -565,9 +565,31 @@ static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
 	return cachep->array[smp_processor_id()];
 }
 
-static size_t slab_mgmt_size(size_t nr_objs, size_t align)
+static int calculate_nr_objs(size_t slab_size, size_t buffer_size,
+				size_t idx_size, size_t align)
 {
-	return ALIGN(nr_objs * sizeof(unsigned int), align);
+	int nr_objs;
+	size_t freelist_size;
+
+	/*
+	 * Ignore padding for the initial guess. The padding
+	 * is at most @align-1 bytes, and @buffer_size is at
+	 * least @align. In the worst case, this result will
+	 * be one greater than the number of objects that fit
+	 * into the memory allocation when taking the padding
+	 * into account.
+	 */
+	nr_objs = slab_size / (buffer_size + idx_size);
+
+	/*
+	 * This calculated number will be either the right
+	 * amount, or one greater than what we want.
+	 */
+	freelist_size = slab_size - nr_objs * buffer_size;
+	if (freelist_size < ALIGN(nr_objs * idx_size, align))
+		nr_objs--;
+
+	return nr_objs;
 }
 
 /*
@@ -600,25 +622,9 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 		nr_objs = slab_size / buffer_size;
 
 	} else {
-		/*
-		 * Ignore padding for the initial guess. The padding
-		 * is at most @align-1 bytes, and @buffer_size is at
-		 * least @align. In the worst case, this result will
-		 * be one greater than the number of objects that fit
-		 * into the memory allocation when taking the padding
-		 * into account.
-		 */
-		nr_objs = (slab_size) / (buffer_size + sizeof(unsigned int));
-
-		/*
-		 * This calculated number will be either the right
-		 * amount, or one greater than what we want.
-		 */
-		if (slab_mgmt_size(nr_objs, align) + nr_objs*buffer_size
-		       > slab_size)
-			nr_objs--;
-
-		mgmt_size = slab_mgmt_size(nr_objs, align);
+		nr_objs = calculate_nr_objs(slab_size, buffer_size,
+					sizeof(unsigned int), align);
+		mgmt_size = ALIGN(nr_objs * sizeof(unsigned int), align);
 	}
 	*num = nr_objs;
 	*left_over = slab_size - nr_objs*buffer_size - mgmt_size;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
