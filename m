Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 794BE6B0036
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 04:38:16 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/4] slab: introduce byte sized index for the freelist of a slab
Date: Mon,  2 Sep 2013 17:38:57 +0900
Message-Id: <1378111138-30340-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1378111138-30340-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <CAAmzW4N1GXbr18Ws9QDKg7ChN5RVcOW9eEv2RxWhaEoHtw=ctw@mail.gmail.com>
 <1378111138-30340-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, the freelist of a slab consist of unsigned int sized indexes.
Most of slabs have less number of objects than 256, since restriction
for page order is at most 1 in default configuration. For example,
consider a slab consisting of 32 byte sized objects on two continous
pages. In this case, 256 objects is possible and these number fit to byte
sized indexes. 256 objects is maximum possible value in default
configuration, since 32 byte is minimum object size in the SLAB.
(8192 / 32 = 256). Therefore, if we use byte sized index, we can save
3 bytes for each object.

This introduce one likely branch to functions used for setting/getting
objects to/from the freelist, but we may get more benefits from
this change.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index a0e49bb..bd366e5 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -565,8 +565,16 @@ static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
 	return cachep->array[smp_processor_id()];
 }
 
-static int calculate_nr_objs(size_t slab_size, size_t buffer_size,
-				size_t idx_size, size_t align)
+static inline bool can_byte_index(int nr_objs)
+{
+	if (likely(nr_objs <= (sizeof(unsigned char) << 8)))
+		return true;
+
+	return false;
+}
+
+static int __calculate_nr_objs(size_t slab_size, size_t buffer_size,
+				unsigned int idx_size, size_t align)
 {
 	int nr_objs;
 	size_t freelist_size;
@@ -592,6 +600,29 @@ static int calculate_nr_objs(size_t slab_size, size_t buffer_size,
 	return nr_objs;
 }
 
+static int calculate_nr_objs(size_t slab_size, size_t buffer_size,
+							size_t align)
+{
+	int nr_objs;
+	int byte_nr_objs;
+
+	nr_objs = __calculate_nr_objs(slab_size, buffer_size,
+					sizeof(unsigned int), align);
+	if (!can_byte_index(nr_objs))
+		return nr_objs;
+
+	byte_nr_objs = __calculate_nr_objs(slab_size, buffer_size,
+					sizeof(unsigned char), align);
+	/*
+	 * nr_objs can be larger when using byte index,
+	 * so that it cannot be indexed by byte index.
+	 */
+	if (can_byte_index(byte_nr_objs))
+		return byte_nr_objs;
+	else
+		return nr_objs;
+}
+
 /*
  * Calculate the number of objects and left-over bytes for a given buffer size.
  */
@@ -618,13 +649,18 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 	 * correct alignment when allocated.
 	 */
 	if (flags & CFLGS_OFF_SLAB) {
-		mgmt_size = 0;
 		nr_objs = slab_size / buffer_size;
+		mgmt_size = 0;
 
 	} else {
-		nr_objs = calculate_nr_objs(slab_size, buffer_size,
-					sizeof(unsigned int), align);
-		mgmt_size = ALIGN(nr_objs * sizeof(unsigned int), align);
+		nr_objs = calculate_nr_objs(slab_size, buffer_size, align);
+		if (can_byte_index(nr_objs)) {
+			mgmt_size =
+				ALIGN(nr_objs * sizeof(unsigned char), align);
+		} else {
+			mgmt_size =
+				ALIGN(nr_objs * sizeof(unsigned int), align);
+		}
 	}
 	*num = nr_objs;
 	*left_over = slab_size - (nr_objs * buffer_size) - mgmt_size;
@@ -2012,7 +2048,10 @@ static size_t calculate_slab_order(struct kmem_cache *cachep,
 			 * looping condition in cache_grow().
 			 */
 			offslab_limit = size;
-			offslab_limit /= sizeof(unsigned int);
+			if (can_byte_index(num))
+				offslab_limit /= sizeof(unsigned char);
+			else
+				offslab_limit /= sizeof(unsigned int);
 
  			if (num > offslab_limit)
 				break;
@@ -2253,8 +2292,13 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (!cachep->num)
 		return -E2BIG;
 
-	freelist_size =
-		ALIGN(cachep->num * sizeof(unsigned int), cachep->align);
+	if (can_byte_index(cachep->num)) {
+		freelist_size = ALIGN(cachep->num * sizeof(unsigned char),
+								cachep->align);
+	} else {
+		freelist_size = ALIGN(cachep->num * sizeof(unsigned int),
+								cachep->align);
+	}
 
 	/*
 	 * If the slab has been placed off-slab, and we have enough space then
@@ -2267,7 +2311,10 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 
 	if (flags & CFLGS_OFF_SLAB) {
 		/* really off slab. No need for manual alignment */
-		freelist_size = cachep->num * sizeof(unsigned int);
+		if (can_byte_index(cachep->num))
+			freelist_size = cachep->num * sizeof(unsigned char);
+		else
+			freelist_size = cachep->num * sizeof(unsigned int);
 
 #ifdef CONFIG_PAGE_POISONING
 		/* If we're going to use the generic kernel_map_pages()
@@ -2545,15 +2592,22 @@ static struct freelist *alloc_slabmgmt(struct kmem_cache *cachep,
 	return freelist;
 }
 
-static inline unsigned int get_free_obj(struct page *page, unsigned int idx)
+static inline unsigned int get_free_obj(struct kmem_cache *cachep,
+					struct page *page, unsigned int idx)
 {
-	return ((unsigned int *)page->freelist)[idx];
+	if (likely(can_byte_index(cachep->num)))
+		return ((unsigned char *)page->freelist)[idx];
+	else
+		return ((unsigned int *)page->freelist)[idx];
 }
 
-static inline void set_free_obj(struct page *page,
+static inline void set_free_obj(struct kmem_cache *cachep, struct page *page,
 					unsigned int idx, unsigned int val)
 {
-	((unsigned int *)(page->freelist))[idx] = val;
+	if (likely(can_byte_index(cachep->num)))
+		((unsigned char *)(page->freelist))[idx] = (unsigned char)val;
+	else
+		((unsigned int *)(page->freelist))[idx] = val;
 }
 
 static void cache_init_objs(struct kmem_cache *cachep,
@@ -2598,7 +2652,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
 		if (cachep->ctor)
 			cachep->ctor(objp);
 #endif
-		set_free_obj(page, i, i);
+		set_free_obj(cachep, page, i, i);
 	}
 }
 
@@ -2615,9 +2669,11 @@ static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
 static void *slab_get_obj(struct kmem_cache *cachep, struct page *page,
 				int nodeid)
 {
+	unsigned int index;
 	void *objp;
 
-	objp = index_to_obj(cachep, page, get_free_obj(page, page->active));
+	index = get_free_obj(cachep, page, page->active);
+	objp = index_to_obj(cachep, page, index);
 	page->active++;
 #if DEBUG
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
@@ -2638,7 +2694,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
 
 	/* Verify double free bug */
 	for (i = page->active; i < cachep->num; i++) {
-		if (get_free_obj(page, i) == objnr) {
+		if (get_free_obj(cachep, page, i) == objnr) {
 			printk(KERN_ERR "slab: double free detected in cache "
 					"'%s', objp %p\n", cachep->name, objp);
 			BUG();
@@ -2646,7 +2702,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
 	}
 #endif
 	page->active--;
-	set_free_obj(page, page->active, objnr);
+	set_free_obj(cachep, page, page->active, objnr);
 }
 
 /*
@@ -4220,7 +4276,7 @@ static void handle_slab(unsigned long *n, struct kmem_cache *c,
 
 		for (j = page->active; j < c->num; j++) {
 			/* Skip freed item */
-			if (get_free_obj(page, j) == i) {
+			if (get_free_obj(c, page, j) == i) {
 				active = false;
 				break;
 			}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
