Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 4651A6B0044
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:23 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 11/16] slab: remove kmem_bufctl_t
Date: Thu, 22 Aug 2013 17:44:20 +0900
Message-Id: <1377161065-30552-12-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we changed the management method of free objects of the slab and
there is no need to use special value, BUFCTL_END, BUFCTL_FREE and
BUFCTL_ACTIVE. So remove them.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 4551d57..7216ebe 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -163,27 +163,7 @@
  */
 static bool pfmemalloc_active __read_mostly;
 
-/*
- * kmem_bufctl_t:
- *
- * Bufctl's are used for linking objs within a slab
- * linked offsets.
- *
- * This implementation relies on "struct page" for locating the cache &
- * slab an object belongs to.
- * This allows the bufctl structure to be small (one int), but limits
- * the number of objects a slab (not a cache) can contain when off-slab
- * bufctls are used. The limit is the size of the largest general cache
- * that does not use off-slab slabs.
- * For 32bit archs with 4 kB pages, is this 56.
- * This is not serious, as it is only for large objects, when it is unwise
- * to have too many per slab.
- * Note: This limit can be raised by introducing a general cache whose size
- * is less than 512 (PAGE_SIZE<<3), but greater than 256.
- */
-
-typedef unsigned int kmem_bufctl_t;
-#define	SLAB_LIMIT	(((kmem_bufctl_t)(~0U))-3)
+#define	SLAB_LIMIT	(((unsigned int)(~0U))-1)
 
 /*
  * struct slab
@@ -197,7 +177,7 @@ struct slab {
 		struct list_head list;
 		void *s_mem;		/* including colour offset */
 		unsigned int inuse;	/* num of objs active in slab */
-		kmem_bufctl_t free;
+		unsigned int free;
 	};
 };
 
@@ -613,7 +593,7 @@ static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
 
 static size_t slab_mgmt_size(size_t nr_objs, size_t align)
 {
-	return ALIGN(sizeof(struct slab)+nr_objs*sizeof(kmem_bufctl_t), align);
+	return ALIGN(sizeof(struct slab)+nr_objs*sizeof(unsigned int), align);
 }
 
 /*
@@ -633,7 +613,7 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 	 * slab is used for:
 	 *
 	 * - The struct slab
-	 * - One kmem_bufctl_t for each object
+	 * - One unsigned int for each object
 	 * - Padding to respect alignment of @align
 	 * - @buffer_size bytes for each object
 	 *
@@ -658,7 +638,7 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 		 * into account.
 		 */
 		nr_objs = (slab_size - sizeof(struct slab)) /
-			  (buffer_size + sizeof(kmem_bufctl_t));
+			  (buffer_size + sizeof(unsigned int));
 
 		/*
 		 * This calculated number will be either the right
@@ -2056,7 +2036,7 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 			 * looping condition in cache_grow().
 			 */
 			offslab_limit = size - sizeof(struct slab);
-			offslab_limit /= sizeof(kmem_bufctl_t);
+			offslab_limit /= sizeof(unsigned int);
 
  			if (num > offslab_limit)
 				break;
@@ -2297,7 +2277,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (!cachep->num)
 		return -E2BIG;
 
-	slab_size = ALIGN(cachep->num * sizeof(kmem_bufctl_t)
+	slab_size = ALIGN(cachep->num * sizeof(unsigned int)
 			  + sizeof(struct slab), cachep->align);
 
 	/*
@@ -2312,7 +2292,7 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (flags & CFLGS_OFF_SLAB) {
 		/* really off slab. No need for manual alignment */
 		slab_size =
-		    cachep->num * sizeof(kmem_bufctl_t) + sizeof(struct slab);
+		    cachep->num * sizeof(unsigned int) + sizeof(struct slab);
 
 #ifdef CONFIG_PAGE_POISONING
 		/* If we're going to use the generic kernel_map_pages()
@@ -2591,9 +2571,9 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep,
 	return slabp;
 }
 
-static inline kmem_bufctl_t *slab_bufctl(struct slab *slabp)
+static inline unsigned int *slab_bufctl(struct slab *slabp)
 {
-	return (kmem_bufctl_t *) (slabp + 1);
+	return (unsigned int *) (slabp + 1);
 }
 
 static void cache_init_objs(struct kmem_cache *cachep,
@@ -2672,7 +2652,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
 {
 	unsigned int objnr = obj_to_index(cachep, slabp, objp);
 #if DEBUG
-	kmem_bufctl_t i;
+	unsigned int i;
 
 	/* Verify that the slab belongs to the intended node */
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
