Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id ABAB16B0039
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 02:03:03 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so1859062pbb.38
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 23:03:03 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 4/5] slab: introduce byte sized index for the freelist of a slab
Date: Thu, 17 Oct 2013 15:03:16 +0900
Message-Id: <1381989797-29269-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1381989797-29269-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381989797-29269-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, the freelist of a slab consist of unsigned int sized indexes.
Since most of slabs have less number of objects than 256, large sized
indexes is waste. For example, consider the minimum kmalloc slab. It's
object size is 32 byte and it would consist of one page, so 256 indexes
through byte sized index are enough to contain all possible indexes.

There can be some slabs whose object size is 8 byte. We cannot handle
this case with byte sized index, so we need to restrict minimum
object size. Since these slabs are not major, wasted memory from these
slabs would be negligible.

Below is some number for this patch.

* Before *
kmalloc-512          525    640    512    8    1 : tunables   54   27    0 : slabdata     80     80      0
kmalloc-256          210    210    256   15    1 : tunables  120   60    0 : slabdata     14     14      0
kmalloc-192         1016   1040    192   20    1 : tunables  120   60    0 : slabdata     52     52      0
kmalloc-96           560    620    128   31    1 : tunables  120   60    0 : slabdata     20     20      0
kmalloc-64          2148   2280     64   60    1 : tunables  120   60    0 : slabdata     38     38      0
kmalloc-128          647    682    128   31    1 : tunables  120   60    0 : slabdata     22     22      0
kmalloc-32         11360  11413     32  113    1 : tunables  120   60    0 : slabdata    101    101      0
kmem_cache           197    200    192   20    1 : tunables  120   60    0 : slabdata     10     10      0

* After *
kmalloc-512          521    648    512    8    1 : tunables   54   27    0 : slabdata     81     81      0
kmalloc-256          208    208    256   16    1 : tunables  120   60    0 : slabdata     13     13      0
kmalloc-192         1029   1029    192   21    1 : tunables  120   60    0 : slabdata     49     49      0
kmalloc-96           529    589    128   31    1 : tunables  120   60    0 : slabdata     19     19      0
kmalloc-64          2142   2142     64   63    1 : tunables  120   60    0 : slabdata     34     34      0
kmalloc-128          660    682    128   31    1 : tunables  120   60    0 : slabdata     22     22      0
kmalloc-32         11716  11780     32  124    1 : tunables  120   60    0 : slabdata     95     95      0
kmem_cache           197    210    192   21    1 : tunables  120   60    0 : slabdata     10     10      0

kmem_caches consisting of objects less than or equal to 256 byte have
one or more objects than before. In the case of kmalloc-32, we have 11 more
objects, so 352 bytes (11 * 32) are saved and this is roughly 9% saving of
memory. Of couse, this percentage decreases as the number of objects
in a slab decreases.

Here are the performance results on my 4 cpus machine.

* Before *

 Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):

       229,945,138 cache-misses                                                  ( +-  0.23% )

      11.627897174 seconds time elapsed                                          ( +-  0.14% )

* After *

 Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):

       218,640,472 cache-misses                                                  ( +-  0.42% )

      11.504999837 seconds time elapsed                                          ( +-  0.21% )

cache-misses are reduced by this patchset, roughly 5%.
And elapsed times are improved by 1%.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 3cee122..2f379ba 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -627,8 +627,8 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 
 	} else {
 		nr_objs = calculate_nr_objs(slab_size, buffer_size,
-					sizeof(unsigned int), align);
-		mgmt_size = ALIGN(nr_objs * sizeof(unsigned int), align);
+					sizeof(unsigned char), align);
+		mgmt_size = ALIGN(nr_objs * sizeof(unsigned char), align);
 	}
 	*num = nr_objs;
 	*left_over = slab_size - nr_objs*buffer_size - mgmt_size;
@@ -2031,7 +2031,7 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 			 * looping condition in cache_grow().
 			 */
 			offslab_limit = size;
-			offslab_limit /= sizeof(unsigned int);
+			offslab_limit /= sizeof(unsigned char);
 
  			if (num > offslab_limit)
 				break;
@@ -2279,7 +2279,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		return -E2BIG;
 
 	freelist_size =
-		ALIGN(cachep->num * sizeof(unsigned int), cachep->align);
+		ALIGN(cachep->num * sizeof(unsigned char), cachep->align);
 
 	/*
 	 * If the slab has been placed off-slab, and we have enough space then
@@ -2292,7 +2292,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 
 	if (flags & CFLGS_OFF_SLAB) {
 		/* really off slab. No need for manual alignment */
-		freelist_size = cachep->num * sizeof(unsigned int);
+		freelist_size = cachep->num * sizeof(unsigned char);
 
 #ifdef CONFIG_PAGE_POISONING
 		/* If we're going to use the generic kernel_map_pages()
@@ -2570,15 +2570,15 @@ static struct freelist *alloc_slabmgmt(struct kmem_cache *cachep,
 	return freelist;
 }
 
-static inline unsigned int get_free_obj(struct page *page, unsigned int idx)
+static inline unsigned char get_free_obj(struct page *page, unsigned char idx)
 {
-	return ((unsigned int *)page->freelist)[idx];
+	return ((unsigned char *)page->freelist)[idx];
 }
 
 static inline void set_free_obj(struct page *page,
-					unsigned int idx, unsigned int val)
+					unsigned char idx, unsigned char val)
 {
-	((unsigned int *)(page->freelist))[idx] = val;
+	((unsigned char *)(page->freelist))[idx] = val;
 }
 
 static void cache_init_objs(struct kmem_cache *cachep,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
