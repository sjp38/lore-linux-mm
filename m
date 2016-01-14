Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 23C078308B
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:25:20 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id ho8so109909857pac.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:20 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id bx1si6902805pab.57.2016.01.13.21.25.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:25:19 -0800 (PST)
Received: by mail-pa0-x241.google.com with SMTP id gi1so35229813pac.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:25:19 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 16/16] mm/slab: introduce new slab management type, OBJFREELIST_SLAB
Date: Thu, 14 Jan 2016 14:24:29 +0900
Message-Id: <1452749069-15334-17-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

SLAB needs a array to manage freed objects in a slab. It is only used
if some objects are freed so we can use free object itself as this array.
This requires additional branch in somewhat critical lock path to check
if it is first freed object or not but that's all we need. Benefits is
that we can save extra memory usage and reduce some computational
overhead by allocating a management array when new slab is created.

Code change is rather complex than what we can expect from the idea,
in order to handle debugging feature efficiently. If you want to see
core idea only, please remove '#if DEBUG' block in the patch.

Although this idea can apply to all caches whose size is larger than
management array size, it isn't applied to caches which have
a constructor. If such cache's object is used for management array,
constructor should be called for it before that object is returned to
user. I guess that overhead overwhelm benefit in that case so this idea
doesn't applied to them at least now.

For summary, from now on, slab management type is determined by
following logic.

1) if management array size is smaller than object size and no ctor,
it becomes OBJFREELIST_SLAB.
2) if management array size is smaller than leftover, it becomes
NORMAL_SLAB which uses leftover as a array.
3) if OFF_SLAB help to save memory than way 4), it becomes OFF_SLAB.
It allocate a management array from the other cache so memory waste
happens.
4) others become NORMAL_SLAB. It uses dedicated internal memory
in a slab as a management array so it causes memory waste.

In my system, without enabling CONFIG_DEBUG_SLAB, Almost caches become
OBJFREELIST_SLAB and NORMAL_SLAB (using leftover) which doesn't waste
memory. Following is the result of number of caches with specific slab
management type.

TOTAL = OBJFREELIST + NORMAL(leftover) + NORMAL + OFF

/Before/
126 = 0 + 60 + 25 + 41

/After/
126 = 97 + 12 + 15 + 2

Result shows that number of caches that doesn't waste memory increase
from 60 to 109.

I did some benchmarking and it looks that benefit are more than loss.

Kmalloc: Repeatedly allocate then free test

/Before/
[    0.286809] 1. Kmalloc: Repeatedly allocate then free test
[    1.143674] 100000 times kmalloc(32) -> 116 cycles kfree -> 78 cycles
[    1.441726] 100000 times kmalloc(64) -> 121 cycles kfree -> 80 cycles
[    1.815734] 100000 times kmalloc(128) -> 168 cycles kfree -> 85 cycles
[    2.380709] 100000 times kmalloc(256) -> 287 cycles kfree -> 95 cycles
[    3.101153] 100000 times kmalloc(512) -> 370 cycles kfree -> 117 cycles
[    3.942432] 100000 times kmalloc(1024) -> 413 cycles kfree -> 156 cycles
[    5.227396] 100000 times kmalloc(2048) -> 622 cycles kfree -> 248 cycles
[    7.519793] 100000 times kmalloc(4096) -> 1102 cycles kfree -> 452 cycles

/After/
[    1.205313] 100000 times kmalloc(32) -> 117 cycles kfree -> 78 cycles
[    1.510526] 100000 times kmalloc(64) -> 124 cycles kfree -> 81 cycles
[    1.827382] 100000 times kmalloc(128) -> 130 cycles kfree -> 84 cycles
[    2.226073] 100000 times kmalloc(256) -> 177 cycles kfree -> 92 cycles
[    2.814747] 100000 times kmalloc(512) -> 286 cycles kfree -> 112 cycles
[    3.532952] 100000 times kmalloc(1024) -> 344 cycles kfree -> 141 cycles
[    4.608777] 100000 times kmalloc(2048) -> 519 cycles kfree -> 210 cycles
[    6.350105] 100000 times kmalloc(4096) -> 789 cycles kfree -> 391 cycles

In fact, I tested another idea implementing OBJFREELIST_SLAB with
extendable linked array through another freed object. It can remove
memory waste completely but it causes more computational overhead
in critical lock path and it seems that overhead outweigh benefit.
So, this patch doesn't include it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 94 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 86 insertions(+), 8 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index a9807c3..f75f569 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -270,7 +270,9 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
 	MAKE_LIST((cachep), (&(ptr)->slabs_free), slabs_free, nodeid);	\
 	} while (0)
 
+#define CFLGS_OBJFREELIST_SLAB	(0x40000000UL)
 #define CFLGS_OFF_SLAB		(0x80000000UL)
+#define	OBJFREELIST_SLAB(x)	((x)->flags & CFLGS_OBJFREELIST_SLAB)
 #define	OFF_SLAB(x)	((x)->flags & CFLGS_OFF_SLAB)
 
 #define BATCHREFILL_LIMIT	16
@@ -480,7 +482,7 @@ static void cache_estimate(unsigned long gfporder, size_t buffer_size,
 	 * the slabs are all pages aligned, the objects will be at the
 	 * correct alignment when allocated.
 	 */
-	if (flags & CFLGS_OFF_SLAB) {
+	if (flags & (CFLGS_OBJFREELIST_SLAB | CFLGS_OFF_SLAB)) {
 		*num = slab_size / buffer_size;
 		*left_over = slab_size % buffer_size;
 	} else {
@@ -1801,6 +1803,12 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
 						struct page *page)
 {
 	int i;
+
+	if (OBJFREELIST_SLAB(cachep) && cachep->flags & SLAB_POISON) {
+		poison_obj(cachep, page->freelist - obj_offset(cachep),
+			POISON_FREE);
+	}
+
 	for (i = 0; i < cachep->num; i++) {
 		void *objp = index_to_obj(cachep, page, i);
 
@@ -2030,6 +2038,29 @@ __kmem_cache_alias(const char *name, size_t size, size_t align,
 	return cachep;
 }
 
+static bool set_objfreelist_slab_cache(struct kmem_cache *cachep,
+			size_t size, unsigned long flags)
+{
+	size_t left;
+
+	cachep->num = 0;
+
+	if (cachep->ctor)
+		return false;
+
+	left = calculate_slab_order(cachep, size,
+			flags | CFLGS_OBJFREELIST_SLAB);
+	if (!cachep->num)
+		return false;
+
+	if (cachep->num * sizeof(freelist_idx_t) > cachep->object_size)
+		return false;
+
+	cachep->colour = left / cachep->colour_off;
+
+	return true;
+}
+
 static bool set_off_slab_cache(struct kmem_cache *cachep,
 			size_t size, unsigned long flags)
 {
@@ -2218,6 +2249,11 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	}
 #endif
 
+	if (set_objfreelist_slab_cache(cachep, size, flags)) {
+		flags |= CFLGS_OBJFREELIST_SLAB;
+		goto done;
+	}
+
 	if (set_off_slab_cache(cachep, size, flags)) {
 		flags |= CFLGS_OFF_SLAB;
 		goto done;
@@ -2435,7 +2471,9 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 	page->s_mem = addr + colour_off;
 	page->active = 0;
 
-	if (OFF_SLAB(cachep)) {
+	if (OBJFREELIST_SLAB(cachep))
+		freelist = NULL;
+	else if (OFF_SLAB(cachep)) {
 		/* Slab management obj is off-slab. */
 		freelist = kmem_cache_alloc_node(cachep->freelist_cache,
 					      local_flags, nodeid);
@@ -2508,6 +2546,11 @@ static void cache_init_objs(struct kmem_cache *cachep,
 
 	cache_init_objs_debug(cachep, page);
 
+	if (OBJFREELIST_SLAB(cachep)) {
+		page->freelist = index_to_obj(cachep, page, cachep->num - 1) +
+						obj_offset(cachep);
+	}
+
 	for (i = 0; i < cachep->num; i++) {
 		/* constructor could break poison info */
 		if (DEBUG == 0 && cachep->ctor)
@@ -2559,6 +2602,9 @@ static void slab_put_obj(struct kmem_cache *cachep,
 	}
 #endif
 	page->active--;
+	if (!page->freelist)
+		page->freelist = objp + obj_offset(cachep);
+
 	set_free_obj(page, page->active, objnr);
 }
 
@@ -2633,7 +2679,7 @@ static int cache_grow(struct kmem_cache *cachep,
 	/* Get slab management. */
 	freelist = alloc_slabmgmt(cachep, page, offset,
 			local_flags & ~GFP_CONSTRAINT_MASK, nodeid);
-	if (!freelist)
+	if (OFF_SLAB(cachep) && !freelist)
 		goto opps1;
 
 	slab_map_pages(cachep, page, freelist);
@@ -2736,14 +2782,42 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 #define cache_free_debugcheck(x,objp,z) (objp)
 #endif
 
+static inline void fixup_objfreelist_debug(struct kmem_cache *cachep,
+						void **list)
+{
+#if DEBUG
+	void *next = *list;
+	void *objp;
+
+	while (next) {
+		objp = next - obj_offset(cachep);
+		next = *(void **)next;
+		poison_obj(cachep, objp, POISON_FREE);
+	}
+#endif
+}
+
 static inline void fixup_slab_list(struct kmem_cache *cachep,
-				struct kmem_cache_node *n, struct page *page)
+				struct kmem_cache_node *n, struct page *page,
+				void **list)
 {
 	/* move slabp to correct slabp list: */
 	list_del(&page->lru);
-	if (page->active == cachep->num)
+	if (page->active == cachep->num) {
 		list_add(&page->lru, &n->slabs_full);
-	else
+		if (OBJFREELIST_SLAB(cachep)) {
+#if DEBUG
+			/* Poisoning will be done without holding the lock */
+			if (cachep->flags & SLAB_POISON) {
+				void **objp = page->freelist;
+
+				*objp = *list;
+				*list = objp;
+			}
+#endif
+			page->freelist = NULL;
+		}
+	} else
 		list_add(&page->lru, &n->slabs_partial);
 }
 
@@ -2769,6 +2843,7 @@ static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags,
 	struct kmem_cache_node *n;
 	struct array_cache *ac;
 	int node;
+	void *list = NULL;
 
 	check_irq_off();
 	node = numa_mem_id();
@@ -2820,13 +2895,14 @@ retry:
 			ac_put_obj(cachep, ac, slab_get_obj(cachep, page));
 		}
 
-		fixup_slab_list(cachep, n, page);
+		fixup_slab_list(cachep, n, page, &list);
 	}
 
 must_grow:
 	n->free_objects -= ac->avail;
 alloc_done:
 	spin_unlock(&n->list_lock);
+	fixup_objfreelist_debug(cachep, &list);
 
 	if (unlikely(!ac->avail)) {
 		int x;
@@ -3071,6 +3147,7 @@ static void *____cache_alloc_node(struct kmem_cache *cachep, gfp_t flags,
 	struct page *page;
 	struct kmem_cache_node *n;
 	void *obj;
+	void *list = NULL;
 	int x;
 
 	VM_BUG_ON(nodeid < 0 || nodeid >= MAX_NUMNODES);
@@ -3095,9 +3172,10 @@ retry:
 	obj = slab_get_obj(cachep, page);
 	n->free_objects--;
 
-	fixup_slab_list(cachep, n, page);
+	fixup_slab_list(cachep, n, page, &list);
 
 	spin_unlock(&n->list_lock);
+	fixup_objfreelist_debug(cachep, &list);
 	goto done;
 
 must_grow:
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
