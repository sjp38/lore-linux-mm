Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id D8A686B0039
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:22 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 10/16] slab: change the management method of free objects of the slab
Date: Thu, 22 Aug 2013 17:44:19 +0900
Message-Id: <1377161065-30552-11-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Current free objects management method of the slab is weird, because
it touch random position of the array of kmem_bufctl_t when we try to
get free object. See following example.

struct slab's free = 6
kmem_bufctl_t array: 1 END 5 7 0 4 3 2

To get free objects, we access this array with following pattern.
6 -> 3 -> 7 -> 2 -> 5 -> 4 -> 0 -> 1 -> END

If we have many objects, this array would be larger and be not in the same
cache line. It is not good for performance.

We can do same thing through more easy way, like as the stack.
Only thing we have to do is to maintain stack top to free object. I use
free field of struct slab for this purpose. After that, if we need to get
an object, we can get it at stack top and manipulate top pointer.
That's all. This method already used in array_cache management.
Following is an access pattern when we use this method.

struct slab's free = 0
kmem_bufctl_t array: 6 3 7 2 5 4 0 1

To get free objects, we access this array with following pattern.
0 -> 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7

This may help cache line footprint if slab has many objects, and,
in addition, this makes code much much simpler.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 855f481..4551d57 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -183,9 +183,6 @@ static bool pfmemalloc_active __read_mostly;
  */
 
 typedef unsigned int kmem_bufctl_t;
-#define BUFCTL_END	(((kmem_bufctl_t)(~0U))-0)
-#define BUFCTL_FREE	(((kmem_bufctl_t)(~0U))-1)
-#define	BUFCTL_ACTIVE	(((kmem_bufctl_t)(~0U))-2)
 #define	SLAB_LIMIT	(((kmem_bufctl_t)(~0U))-3)
 
 /*
@@ -2641,9 +2638,8 @@ static void cache_init_objs(struct kmem_cache *cachep,
 		if (cachep->ctor)
 			cachep->ctor(objp);
 #endif
-		slab_bufctl(slabp)[i] = i + 1;
+		slab_bufctl(slabp)[i] = i;
 	}
-	slab_bufctl(slabp)[i - 1] = BUFCTL_END;
 }
 
 static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
@@ -2659,16 +2655,14 @@ static void kmem_flagcheck(struct kmem_cache *cachep, gfp_t flags)
 static void *slab_get_obj(struct kmem_cache *cachep, struct slab *slabp,
 				int nodeid)
 {
-	void *objp = index_to_obj(cachep, slabp, slabp->free);
-	kmem_bufctl_t next;
+	void *objp;
 
 	slabp->inuse++;
-	next = slab_bufctl(slabp)[slabp->free];
+	objp = index_to_obj(cachep, slabp, slab_bufctl(slabp)[slabp->free]);
 #if DEBUG
-	slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
 #endif
-	slabp->free = next;
+	slabp->free++;
 
 	return objp;
 }
@@ -2677,19 +2671,23 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
 				void *objp, int nodeid)
 {
 	unsigned int objnr = obj_to_index(cachep, slabp, objp);
-
 #if DEBUG
+	kmem_bufctl_t i;
+
 	/* Verify that the slab belongs to the intended node */
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
 
-	if (slab_bufctl(slabp)[objnr] + 1 <= SLAB_LIMIT + 1) {
-		printk(KERN_ERR "slab: double free detected in cache "
-				"'%s', objp %p\n", cachep->name, objp);
-		BUG();
+	/* Verify double free bug */
+	for (i = slabp->free; i < cachep->num; i++) {
+		if (slab_bufctl(slabp)[i] == objnr) {
+			printk(KERN_ERR "slab: double free detected in cache "
+					"'%s', objp %p\n", cachep->name, objp);
+			BUG();
+		}
 	}
 #endif
-	slab_bufctl(slabp)[objnr] = slabp->free;
-	slabp->free = objnr;
+	slabp->free--;
+	slab_bufctl(slabp)[slabp->free] = objnr;
 	slabp->inuse--;
 }
 
@@ -2850,9 +2848,6 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 	BUG_ON(objnr >= cachep->num);
 	BUG_ON(objp != index_to_obj(cachep, slabp, objnr));
 
-#ifdef CONFIG_DEBUG_SLAB_LEAK
-	slab_bufctl(slabp)[objnr] = BUFCTL_FREE;
-#endif
 	if (cachep->flags & SLAB_POISON) {
 #ifdef CONFIG_DEBUG_PAGEALLOC
 		if ((cachep->size % PAGE_SIZE)==0 && OFF_SLAB(cachep)) {
@@ -2869,33 +2864,9 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 	return objp;
 }
 
-static void check_slabp(struct kmem_cache *cachep, struct slab *slabp)
-{
-	kmem_bufctl_t i;
-	int entries = 0;
-
-	/* Check slab's freelist to see if this obj is there. */
-	for (i = slabp->free; i != BUFCTL_END; i = slab_bufctl(slabp)[i]) {
-		entries++;
-		if (entries > cachep->num || i >= cachep->num)
-			goto bad;
-	}
-	if (entries != cachep->num - slabp->inuse) {
-bad:
-		printk(KERN_ERR "slab: Internal list corruption detected in "
-			"cache '%s'(%d), slabp %p(%d). Tainted(%s). Hexdump:\n",
-			cachep->name, cachep->num, slabp, slabp->inuse,
-			print_tainted());
-		print_hex_dump(KERN_ERR, "", DUMP_PREFIX_OFFSET, 16, 1, slabp,
-			sizeof(*slabp) + cachep->num * sizeof(kmem_bufctl_t),
-			1);
-		BUG();
-	}
-}
 #else
 #define kfree_debugcheck(x) do { } while(0)
 #define cache_free_debugcheck(x,objp,z) (objp)
-#define check_slabp(x,y) do { } while(0)
 #endif
 
 static void *cache_alloc_refill(struct kmem_cache *cachep, gfp_t flags,
@@ -2945,7 +2916,6 @@ retry:
 		}
 
 		slabp = list_entry(entry, struct slab, list);
-		check_slabp(cachep, slabp);
 		check_spinlock_acquired(cachep);
 
 		/*
@@ -2963,11 +2933,10 @@ retry:
 			ac_put_obj(cachep, ac, slab_get_obj(cachep, slabp,
 									node));
 		}
-		check_slabp(cachep, slabp);
 
 		/* move slabp to correct slabp list: */
 		list_del(&slabp->list);
-		if (slabp->free == BUFCTL_END)
+		if (slabp->free == cachep->num)
 			list_add(&slabp->list, &n->slabs_full);
 		else
 			list_add(&slabp->list, &n->slabs_partial);
@@ -3042,16 +3011,6 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		*dbg_redzone1(cachep, objp) = RED_ACTIVE;
 		*dbg_redzone2(cachep, objp) = RED_ACTIVE;
 	}
-#ifdef CONFIG_DEBUG_SLAB_LEAK
-	{
-		struct slab *slabp;
-		unsigned objnr;
-
-		slabp = virt_to_slab(objp);
-		objnr = (unsigned)(objp - slabp->s_mem) / cachep->size;
-		slab_bufctl(slabp)[objnr] = BUFCTL_ACTIVE;
-	}
-#endif
 	objp += obj_offset(cachep);
 	if (cachep->ctor && cachep->flags & SLAB_POISON)
 		cachep->ctor(objp);
@@ -3257,7 +3216,6 @@ retry:
 
 	slabp = list_entry(entry, struct slab, list);
 	check_spinlock_acquired_node(cachep, nodeid);
-	check_slabp(cachep, slabp);
 
 	STATS_INC_NODEALLOCS(cachep);
 	STATS_INC_ACTIVE(cachep);
@@ -3266,12 +3224,11 @@ retry:
 	BUG_ON(slabp->inuse == cachep->num);
 
 	obj = slab_get_obj(cachep, slabp, nodeid);
-	check_slabp(cachep, slabp);
 	n->free_objects--;
 	/* move slabp to correct slabp list: */
 	list_del(&slabp->list);
 
-	if (slabp->free == BUFCTL_END)
+	if (slabp->free == cachep->num)
 		list_add(&slabp->list, &n->slabs_full);
 	else
 		list_add(&slabp->list, &n->slabs_partial);
@@ -3445,11 +3402,9 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 		n = cachep->node[node];
 		list_del(&slabp->list);
 		check_spinlock_acquired_node(cachep, node);
-		check_slabp(cachep, slabp);
 		slab_put_obj(cachep, slabp, objp, node);
 		STATS_DEC_ACTIVE(cachep);
 		n->free_objects++;
-		check_slabp(cachep, slabp);
 
 		/* fixup slab chains */
 		if (slabp->inuse == 0) {
@@ -4297,12 +4252,23 @@ static inline int add_caller(unsigned long *n, unsigned long v)
 static void handle_slab(unsigned long *n, struct kmem_cache *c, struct slab *s)
 {
 	void *p;
-	int i;
+	int i, j;
+
 	if (n[0] == n[1])
 		return;
 	for (i = 0, p = s->s_mem; i < c->num; i++, p += c->size) {
-		if (slab_bufctl(s)[i] != BUFCTL_ACTIVE)
+		bool active = true;
+
+		for (j = s->free; j < c->num; j++) {
+			/* Skip freed item */
+			if (slab_bufctl(s)[j] == i) {
+				active = false;
+				break;
+			}
+		}
+		if (!active)
 			continue;
+
 		if (!add_caller(n, (unsigned long)*dbg_userword(c, p)))
 			return;
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
