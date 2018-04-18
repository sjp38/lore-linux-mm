Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE756B0028
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:29 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m190so1036690pgm.4
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bg11-v6si1763244plb.171.2018.04.18.11.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:26 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 14/14] slub: Remove kmem_cache->reserved
Date: Wed, 18 Apr 2018 11:49:12 -0700
Message-Id: <20180418184912.2851-15-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

The reserved field was only used for embedding an rcu_head in the data
structure.  With the previous commit, we no longer need it.  That lets
us remove the 'reserved' argument to a lot of functions.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/slub_def.h |  1 -
 mm/slub.c                | 41 ++++++++++++++++++++--------------------
 2 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3773e26c08c1..09fa2c6f0e68 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -101,7 +101,6 @@ struct kmem_cache {
 	void (*ctor)(void *);
 	unsigned int inuse;		/* Offset to metadata */
 	unsigned int align;		/* Alignment */
-	unsigned int reserved;		/* Reserved bytes at the end of slabs */
 	unsigned int red_left_pad;	/* Left redzone padding size */
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
diff --git a/mm/slub.c b/mm/slub.c
index 8af8ce91062a..53aa459d2343 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -317,16 +317,16 @@ static inline unsigned int slab_index(void *p, struct kmem_cache *s, void *addr)
 	return (p - addr) / s->size;
 }
 
-static inline unsigned int order_objects(unsigned int order, unsigned int size, unsigned int reserved)
+static inline unsigned int order_objects(unsigned int order, unsigned int size)
 {
-	return (((unsigned int)PAGE_SIZE << order) - reserved) / size;
+	return ((unsigned int)PAGE_SIZE << order) / size;
 }
 
 static inline struct kmem_cache_order_objects oo_make(unsigned int order,
-		unsigned int size, unsigned int reserved)
+		unsigned int size)
 {
 	struct kmem_cache_order_objects x = {
-		(order << OO_SHIFT) + order_objects(order, size, reserved)
+		(order << OO_SHIFT) + order_objects(order, size)
 	};
 
 	return x;
@@ -841,7 +841,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 		return 1;
 
 	start = page_address(page);
-	length = (PAGE_SIZE << compound_order(page)) - s->reserved;
+	length = PAGE_SIZE << compound_order(page);
 	end = start + length;
 	remainder = length % s->size;
 	if (!remainder)
@@ -930,7 +930,7 @@ static int check_slab(struct kmem_cache *s, struct page *page)
 		return 0;
 	}
 
-	maxobj = order_objects(compound_order(page), s->size, s->reserved);
+	maxobj = order_objects(compound_order(page), s->size);
 	if (page->objects > maxobj) {
 		slab_err(s, page, "objects %u > max %u",
 			page->objects, maxobj);
@@ -980,7 +980,7 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
 		nr++;
 	}
 
-	max_objects = order_objects(compound_order(page), s->size, s->reserved);
+	max_objects = order_objects(compound_order(page), s->size);
 	if (max_objects > MAX_OBJS_PER_PAGE)
 		max_objects = MAX_OBJS_PER_PAGE;
 
@@ -3198,21 +3198,21 @@ static unsigned int slub_min_objects;
  */
 static inline unsigned int slab_order(unsigned int size,
 		unsigned int min_objects, unsigned int max_order,
-		unsigned int fract_leftover, unsigned int reserved)
+		unsigned int fract_leftover)
 {
 	unsigned int min_order = slub_min_order;
 	unsigned int order;
 
-	if (order_objects(min_order, size, reserved) > MAX_OBJS_PER_PAGE)
+	if (order_objects(min_order, size) > MAX_OBJS_PER_PAGE)
 		return get_order(size * MAX_OBJS_PER_PAGE) - 1;
 
-	for (order = max(min_order, (unsigned int)get_order(min_objects * size + reserved));
+	for (order = max(min_order, (unsigned int)get_order(min_objects * size));
 			order <= max_order; order++) {
 
 		unsigned int slab_size = (unsigned int)PAGE_SIZE << order;
 		unsigned int rem;
 
-		rem = (slab_size - reserved) % size;
+		rem = slab_size % size;
 
 		if (rem <= slab_size / fract_leftover)
 			break;
@@ -3221,7 +3221,7 @@ static inline unsigned int slab_order(unsigned int size,
 	return order;
 }
 
-static inline int calculate_order(unsigned int size, unsigned int reserved)
+static inline int calculate_order(unsigned int size)
 {
 	unsigned int order;
 	unsigned int min_objects;
@@ -3238,7 +3238,7 @@ static inline int calculate_order(unsigned int size, unsigned int reserved)
 	min_objects = slub_min_objects;
 	if (!min_objects)
 		min_objects = 4 * (fls(nr_cpu_ids) + 1);
-	max_objects = order_objects(slub_max_order, size, reserved);
+	max_objects = order_objects(slub_max_order, size);
 	min_objects = min(min_objects, max_objects);
 
 	while (min_objects > 1) {
@@ -3247,7 +3247,7 @@ static inline int calculate_order(unsigned int size, unsigned int reserved)
 		fraction = 16;
 		while (fraction >= 4) {
 			order = slab_order(size, min_objects,
-					slub_max_order, fraction, reserved);
+					slub_max_order, fraction);
 			if (order <= slub_max_order)
 				return order;
 			fraction /= 2;
@@ -3259,14 +3259,14 @@ static inline int calculate_order(unsigned int size, unsigned int reserved)
 	 * We were unable to place multiple objects in a slab. Now
 	 * lets see if we can place a single object there.
 	 */
-	order = slab_order(size, 1, slub_max_order, 1, reserved);
+	order = slab_order(size, 1, slub_max_order, 1);
 	if (order <= slub_max_order)
 		return order;
 
 	/*
 	 * Doh this slab cannot be placed using slub_max_order.
 	 */
-	order = slab_order(size, 1, MAX_ORDER, 1, reserved);
+	order = slab_order(size, 1, MAX_ORDER, 1);
 	if (order < MAX_ORDER)
 		return order;
 	return -ENOSYS;
@@ -3534,7 +3534,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	if (forced_order >= 0)
 		order = forced_order;
 	else
-		order = calculate_order(size, s->reserved);
+		order = calculate_order(size);
 
 	if ((int)order < 0)
 		return 0;
@@ -3552,8 +3552,8 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	/*
 	 * Determine the number of objects per slab
 	 */
-	s->oo = oo_make(order, size, s->reserved);
-	s->min = oo_make(get_order(size), size, s->reserved);
+	s->oo = oo_make(order, size);
+	s->min = oo_make(get_order(size), size);
 	if (oo_objects(s->oo) > oo_objects(s->max))
 		s->max = s->oo;
 
@@ -3563,7 +3563,6 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
 {
 	s->flags = kmem_cache_flags(s->size, flags, s->name, s->ctor);
-	s->reserved = 0;
 #ifdef CONFIG_SLAB_FREELIST_HARDENED
 	s->random = get_random_long();
 #endif
@@ -5107,7 +5106,7 @@ SLAB_ATTR_RO(destroy_by_rcu);
 
 static ssize_t reserved_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%u\n", s->reserved);
+	return sprintf(buf, "0\n");
 }
 SLAB_ATTR_RO(reserved);
 
-- 
2.17.0
