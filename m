Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E77D36B0289
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:29 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id f9so12756116wra.2
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r11sor1793730wmf.52.2017.11.23.14.17.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:28 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 21/23] slub: make struct kmem_cache_order_objects::x unsigned int
Date: Fri, 24 Nov 2017 01:16:26 +0300
Message-Id: <20171123221628.8313-21-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

struct kmem_cache_order_objects is for mixing order and number of objects,
and orders aren't bit enough to warrant 64-bit width.

Propagate unsignedness down so that everything fits.

!!! Patch assumes that "PAGE_SIZE << order" doesn't overflow. !!!

Space savings on x86_64:

	add/remove: 1/0 grow/shrink: 1/14 up/down: 26/-163 (-137)
	Function                                     old     new   delta
	__bit_spin_unlock.constprop                    -      21     +21
	init_cache_random_seq                        123     128      +5
	kmem_cache_open                             1189    1188      -1
	on_freelist                                  585     582      -3
	get_slabinfo                                 155     152      -3
	check_slab                                   180     177      -3
	order_show                                    29      25      -4
	boot_kmem_cache_node                        8864    8856      -8
	boot_kmem_cache                             8864    8856      -8
	slab_out_of_memory                           260     250     -10
	__cmpxchg_double_slab.isra                   380     368     -12
	calculate_sizes                              625     612     -13
	order_store                                  103      88     -15
	slab_order                                   202     177     -25
	new_slab                                    1830    1805     -25
	cmpxchg_double_slab.isra                     569     536     -33

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h |  2 +-
 mm/slub.c                | 74 +++++++++++++++++++++++++-----------------------
 2 files changed, 40 insertions(+), 36 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index e768ac49f0b4..b9daf0f88b4f 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -73,7 +73,7 @@ struct kmem_cache_cpu {
  * given order would contain.
  */
 struct kmem_cache_order_objects {
-	unsigned long x;
+	unsigned int x;
 };
 
 /*
diff --git a/mm/slub.c b/mm/slub.c
index 04c8348b8ce9..27e619a38a02 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -316,13 +316,13 @@ static inline unsigned int slab_index(void *p, struct kmem_cache *s, void *addr)
 	return (p - addr) / s->size;
 }
 
-static inline int order_objects(int order, unsigned long size, int reserved)
+static inline unsigned int order_objects(unsigned int order, unsigned int size, unsigned int reserved)
 {
-	return ((PAGE_SIZE << order) - reserved) / size;
+	return (((unsigned int)PAGE_SIZE << order) - reserved) / size;
 }
 
-static inline struct kmem_cache_order_objects oo_make(int order,
-		unsigned long size, int reserved)
+static inline struct kmem_cache_order_objects oo_make(unsigned int order,
+		unsigned int size, unsigned int reserved)
 {
 	struct kmem_cache_order_objects x = {
 		(order << OO_SHIFT) + order_objects(order, size, reserved)
@@ -331,12 +331,12 @@ static inline struct kmem_cache_order_objects oo_make(int order,
 	return x;
 }
 
-static inline int oo_order(struct kmem_cache_order_objects x)
+static inline unsigned int oo_order(struct kmem_cache_order_objects x)
 {
 	return x.x >> OO_SHIFT;
 }
 
-static inline int oo_objects(struct kmem_cache_order_objects x)
+static inline unsigned int oo_objects(struct kmem_cache_order_objects x)
 {
 	return x.x & OO_MASK;
 }
@@ -1433,7 +1433,7 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 		gfp_t flags, int node, struct kmem_cache_order_objects oo)
 {
 	struct page *page;
-	int order = oo_order(oo);
+	unsigned int order = oo_order(oo);
 
 	if (node == NUMA_NO_NODE)
 		page = alloc_pages(flags, order);
@@ -1452,8 +1452,8 @@ static inline struct page *alloc_slab_page(struct kmem_cache *s,
 /* Pre-initialize the random sequence cache */
 static int init_cache_random_seq(struct kmem_cache *s)
 {
+	unsigned int count = oo_objects(s->oo);
 	int err;
-	unsigned long i, count = oo_objects(s->oo);
 
 	/* Bailout if already initialised */
 	if (s->random_seq)
@@ -1468,6 +1468,8 @@ static int init_cache_random_seq(struct kmem_cache *s)
 
 	/* Transform to an offset on the set of pages */
 	if (s->random_seq) {
+		unsigned int i;
+
 		for (i = 0; i < count; i++)
 			s->random_seq[i] *= s->size;
 	}
@@ -2398,7 +2400,7 @@ slab_out_of_memory(struct kmem_cache *s, gfp_t gfpflags, int nid)
 
 	pr_warn("SLUB: Unable to allocate memory on node %d, gfp=%#x(%pGg)\n",
 		nid, gfpflags, &gfpflags);
-	pr_warn("  cache: %s, object size: %u, buffer size: %u, default order: %d, min order: %d\n",
+	pr_warn("  cache: %s, object size: %u, buffer size: %u, default order: %u, min order: %u\n",
 		s->name, s->object_size, s->size, oo_order(s->oo),
 		oo_order(s->min));
 
@@ -3181,9 +3183,9 @@ EXPORT_SYMBOL(kmem_cache_alloc_bulk);
  * and increases the number of allocations possible without having to
  * take the list_lock.
  */
-static int slub_min_order;
-static int slub_max_order = PAGE_ALLOC_COSTLY_ORDER;
-static int slub_min_objects;
+static unsigned int slub_min_order;
+static unsigned int slub_max_order = PAGE_ALLOC_COSTLY_ORDER;
+static unsigned int slub_min_objects;
 
 /*
  * Calculate the order of allocation given an slab object size.
@@ -3210,20 +3212,21 @@ static int slub_min_objects;
  * requested a higher mininum order then we start with that one instead of
  * the smallest order which will fit the object.
  */
-static inline int slab_order(int size, int min_objects,
-				int max_order, int fract_leftover, int reserved)
+static inline unsigned int slab_order(unsigned int size,
+		unsigned int min_objects, unsigned int max_order,
+		unsigned int fract_leftover, unsigned int reserved)
 {
-	int order;
-	int rem;
-	int min_order = slub_min_order;
+	unsigned int min_order = slub_min_order;
+	unsigned int order;
 
 	if (order_objects(min_order, size, reserved) > MAX_OBJS_PER_PAGE)
 		return get_order(size * MAX_OBJS_PER_PAGE) - 1;
 
-	for (order = max(min_order, get_order(min_objects * size + reserved));
+	for (order = max(min_order, (unsigned int)get_order(min_objects * size + reserved));
 			order <= max_order; order++) {
 
-		unsigned long slab_size = PAGE_SIZE << order;
+		unsigned int slab_size = (unsigned int)PAGE_SIZE << order;
+		unsigned int rem;
 
 		rem = (slab_size - reserved) % size;
 
@@ -3234,12 +3237,11 @@ static inline int slab_order(int size, int min_objects,
 	return order;
 }
 
-static inline int calculate_order(int size, int reserved)
+static inline int calculate_order(unsigned int size, unsigned int reserved)
 {
-	int order;
-	int min_objects;
-	int fraction;
-	int max_objects;
+	unsigned int order;
+	unsigned int min_objects;
+	unsigned int max_objects;
 
 	/*
 	 * Attempt to find best configuration for a slab. This
@@ -3256,6 +3258,8 @@ static inline int calculate_order(int size, int reserved)
 	min_objects = min(min_objects, max_objects);
 
 	while (min_objects > 1) {
+		unsigned int fraction;
+
 		fraction = 16;
 		while (fraction >= 4) {
 			order = slab_order(size, min_objects,
@@ -3458,7 +3462,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 {
 	slab_flags_t flags = s->flags;
 	unsigned int size = s->object_size;
-	int order;
+	unsigned int order;
 
 	/*
 	 * Round up object size to the next word boundary. We can only
@@ -3548,7 +3552,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	else
 		order = calculate_order(size, s->reserved);
 
-	if (order < 0)
+	if ((int)order < 0)
 		return 0;
 
 	s->allocflags = 0;
@@ -3716,7 +3720,7 @@ int __kmem_cache_shutdown(struct kmem_cache *s)
 
 static int __init setup_slub_min_order(char *str)
 {
-	get_option(&str, &slub_min_order);
+	get_option(&str, (int *)&slub_min_order);
 
 	return 1;
 }
@@ -3725,8 +3729,8 @@ __setup("slub_min_order=", setup_slub_min_order);
 
 static int __init setup_slub_max_order(char *str)
 {
-	get_option(&str, &slub_max_order);
-	slub_max_order = min(slub_max_order, MAX_ORDER - 1);
+	get_option(&str, (int *)&slub_max_order);
+	slub_max_order = min(slub_max_order, (unsigned int)MAX_ORDER - 1);
 
 	return 1;
 }
@@ -3735,7 +3739,7 @@ __setup("slub_max_order=", setup_slub_max_order);
 
 static int __init setup_slub_min_objects(char *str)
 {
-	get_option(&str, &slub_min_objects);
+	get_option(&str, (int *)&slub_min_objects);
 
 	return 1;
 }
@@ -4212,7 +4216,7 @@ void __init kmem_cache_init(void)
 	cpuhp_setup_state_nocalls(CPUHP_SLUB_DEAD, "slub:dead", NULL,
 				  slub_cpu_dead);
 
-	pr_info("SLUB: HWalign=%d, Order=%d-%d, MinObjects=%d, CPUs=%u, Nodes=%d\n",
+	pr_info("SLUB: HWalign=%d, Order=%u-%u, MinObjects=%u, CPUs=%u, Nodes=%d\n",
 		cache_line_size(),
 		slub_min_order, slub_max_order, slub_min_objects,
 		nr_cpu_ids, nr_node_ids);
@@ -4888,17 +4892,17 @@ SLAB_ATTR_RO(object_size);
 
 static ssize_t objs_per_slab_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", oo_objects(s->oo));
+	return sprintf(buf, "%u\n", oo_objects(s->oo));
 }
 SLAB_ATTR_RO(objs_per_slab);
 
 static ssize_t order_store(struct kmem_cache *s,
 				const char *buf, size_t length)
 {
-	unsigned long order;
+	unsigned int order;
 	int err;
 
-	err = kstrtoul(buf, 10, &order);
+	err = kstrtouint(buf, 10, &order);
 	if (err)
 		return err;
 
@@ -4911,7 +4915,7 @@ static ssize_t order_store(struct kmem_cache *s,
 
 static ssize_t order_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", oo_order(s->oo));
+	return sprintf(buf, "%u\n", oo_order(s->oo));
 }
 SLAB_ATTR(order);
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
