Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id D44176B0031
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 04:38:14 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/4] slab: factor out calculate nr objects in cache_estimate
Date: Mon,  2 Sep 2013 17:38:55 +0900
Message-Id: <1378111138-30340-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1378111138-30340-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <CAAmzW4N1GXbr18Ws9QDKg7ChN5RVcOW9eEv2RxWhaEoHtw=ctw@mail.gmail.com>
 <1378111138-30340-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This logic is not simple to understand so that making separate function
helping readability. Additionally, we can use this change in the
following patch which implement for freelist to have another sized index
in according to nr objects.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index f3868fe..9d4bad5 100644
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
@@ -600,28 +622,12 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
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
-	*left_over = slab_size - nr_objs*buffer_size - mgmt_size;
+	*left_over = slab_size - (nr_objs * buffer_size) - mgmt_size;
 }
 
 #if DEBUG
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
