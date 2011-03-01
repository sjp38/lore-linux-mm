Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 04C358D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 03:02:17 -0500 (EST)
Message-ID: <4D6CA84B.9080606@cn.fujitsu.com>
Date: Tue, 01 Mar 2011 16:03:23 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 1/4] slub: automatically reserve bytes at the end of slab
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

There is no "struct" for slub's slab, it shares with struct page.
But struct page is very small, it is insufficient when we need
to add some metadata for slab.

So we add a field "reserved" to struct kmem_cache, when a slab
is allocated, kmem_cache->reserved bytes are automatically reserved
at the end of the slab for slab's metadata.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 include/linux/slub_def.h |    1 +
 mm/slub.c                |   40 +++++++++++++++++++++++-----------------
 2 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 8b6e8ae..ae0093c 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -83,6 +83,7 @@ struct kmem_cache {
 	void (*ctor)(void *);
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
+	int reserved;		/* Reserved bytes at the end of slabs */
 	unsigned long min_partial;
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
diff --git a/mm/slub.c b/mm/slub.c
index e15aa7f..ad545b2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -281,11 +281,16 @@ static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
 	return (p - addr) / s->size;
 }
 
+static inline int order_objects(int order, unsigned long size, int reserved)
+{
+	return ((PAGE_SIZE << order) - reserved) / size;
+}
+
 static inline struct kmem_cache_order_objects oo_make(int order,
-						unsigned long size)
+		unsigned long size, int reserved)
 {
 	struct kmem_cache_order_objects x = {
-		(order << OO_SHIFT) + (PAGE_SIZE << order) / size
+		(order << OO_SHIFT) + order_objects(order, size, reserved)
 	};
 
 	return x;
@@ -617,7 +622,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 		return 1;
 
 	start = page_address(page);
-	length = (PAGE_SIZE << compound_order(page));
+	length = (PAGE_SIZE << compound_order(page)) - s->reserved;
 	end = start + length;
 	remainder = length % s->size;
 	if (!remainder)
@@ -698,7 +703,7 @@ static int check_slab(struct kmem_cache *s, struct page *page)
 		return 0;
 	}
 
-	maxobj = (PAGE_SIZE << compound_order(page)) / s->size;
+	maxobj = order_objects(compound_order(page), s->size, s->reserved);
 	if (page->objects > maxobj) {
 		slab_err(s, page, "objects %u > max %u",
 			s->name, page->objects, maxobj);
@@ -748,7 +753,7 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
 		nr++;
 	}
 
-	max_objects = (PAGE_SIZE << compound_order(page)) / s->size;
+	max_objects = order_objects(compound_order(page), s->size, s->reserved);
 	if (max_objects > MAX_OBJS_PER_PAGE)
 		max_objects = MAX_OBJS_PER_PAGE;
 
@@ -1988,13 +1993,13 @@ static int slub_nomerge;
  * the smallest order which will fit the object.
  */
 static inline int slab_order(int size, int min_objects,
-				int max_order, int fract_leftover)
+				int max_order, int fract_leftover, int reserved)
 {
 	int order;
 	int rem;
 	int min_order = slub_min_order;
 
-	if ((PAGE_SIZE << min_order) / size > MAX_OBJS_PER_PAGE)
+	if (order_objects(min_order, size, reserved) > MAX_OBJS_PER_PAGE)
 		return get_order(size * MAX_OBJS_PER_PAGE) - 1;
 
 	for (order = max(min_order,
@@ -2003,10 +2008,10 @@ static inline int slab_order(int size, int min_objects,
 
 		unsigned long slab_size = PAGE_SIZE << order;
 
-		if (slab_size < min_objects * size)
+		if (slab_size < min_objects * size + reserved)
 			continue;
 
-		rem = slab_size % size;
+		rem = (slab_size - reserved) % size;
 
 		if (rem <= slab_size / fract_leftover)
 			break;
@@ -2016,7 +2021,7 @@ static inline int slab_order(int size, int min_objects,
 	return order;
 }
 
-static inline int calculate_order(int size)
+static inline int calculate_order(int size, int reserved)
 {
 	int order;
 	int min_objects;
@@ -2034,14 +2039,14 @@ static inline int calculate_order(int size)
 	min_objects = slub_min_objects;
 	if (!min_objects)
 		min_objects = 4 * (fls(nr_cpu_ids) + 1);
-	max_objects = (PAGE_SIZE << slub_max_order)/size;
+	max_objects = order_objects(slub_max_order, size, reserved);
 	min_objects = min(min_objects, max_objects);
 
 	while (min_objects > 1) {
 		fraction = 16;
 		while (fraction >= 4) {
 			order = slab_order(size, min_objects,
-						slub_max_order, fraction);
+					slub_max_order, fraction, reserved);
 			if (order <= slub_max_order)
 				return order;
 			fraction /= 2;
@@ -2053,14 +2058,14 @@ static inline int calculate_order(int size)
 	 * We were unable to place multiple objects in a slab. Now
 	 * lets see if we can place a single object there.
 	 */
-	order = slab_order(size, 1, slub_max_order, 1);
+	order = slab_order(size, 1, slub_max_order, 1, reserved);
 	if (order <= slub_max_order)
 		return order;
 
 	/*
 	 * Doh this slab cannot be placed using slub_max_order.
 	 */
-	order = slab_order(size, 1, MAX_ORDER, 1);
+	order = slab_order(size, 1, MAX_ORDER, 1, reserved);
 	if (order < MAX_ORDER)
 		return order;
 	return -ENOSYS;
@@ -2311,7 +2316,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	if (forced_order >= 0)
 		order = forced_order;
 	else
-		order = calculate_order(size);
+		order = calculate_order(size, s->reserved);
 
 	if (order < 0)
 		return 0;
@@ -2329,8 +2334,8 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 	/*
 	 * Determine the number of objects per slab
 	 */
-	s->oo = oo_make(order, size);
-	s->min = oo_make(get_order(size), size);
+	s->oo = oo_make(order, size, s->reserved);
+	s->min = oo_make(get_order(size), size, s->reserved);
 	if (oo_objects(s->oo) > oo_objects(s->max))
 		s->max = s->oo;
 
@@ -2349,6 +2354,7 @@ static int kmem_cache_open(struct kmem_cache *s,
 	s->objsize = size;
 	s->align = align;
 	s->flags = kmem_cache_flags(size, flags, name, ctor);
+	s->reserved = 0;
 
 	if (!calculate_sizes(s, -1))
 		goto error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
