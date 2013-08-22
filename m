Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 1C3E86B0068
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:24 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 13/16] slab: replace free and inuse in struct slab with newly introduced active
Date: Thu, 22 Aug 2013 17:44:22 +0900
Message-Id: <1377161065-30552-14-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, free in struct slab is same meaning as inuse.
So, remove both and replace them with active.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 98257e4..9dcbb22 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -174,8 +174,7 @@ struct slab {
 	struct {
 		struct list_head list;
 		void *s_mem;		/* including colour offset */
-		unsigned int inuse;	/* num of objs active in slab */
-		unsigned int free;
+		unsigned int active;	/* num of objs active in slab */
 	};
 };
 
@@ -1652,7 +1651,7 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 			active_slabs++;
 		}
 		list_for_each_entry(slabp, &n->slabs_partial, list) {
-			active_objs += slabp->inuse;
+			active_objs += slabp->active;
 			active_slabs++;
 		}
 		list_for_each_entry(slabp, &n->slabs_free, list)
@@ -2439,7 +2438,7 @@ static int drain_freelist(struct kmem_cache *cache,
 
 		slabp = list_entry(p, struct slab, list);
 #if DEBUG
-		BUG_ON(slabp->inuse);
+		BUG_ON(slabp->active);
 #endif
 		list_del(&slabp->list);
 		/*
@@ -2558,9 +2557,8 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep,
 		slabp = addr + colour_off;
 		colour_off += cachep->slab_size;
 	}
-	slabp->inuse = 0;
+	slabp->active = 0;
 	slabp->s_mem = addr + colour_off;
-	slabp->free = 0;
 	return slabp;
 }
 
@@ -2630,12 +2628,11 @@ static void *slab_get_obj(struct kmem_cache *cachep, struct slab *slabp,
 {
 	void *objp;
 
-	slabp->inuse++;
-	objp = index_to_obj(cachep, slabp, slab_bufctl(slabp)[slabp->free]);
+	objp = index_to_obj(cachep, slabp, slab_bufctl(slabp)[slabp->active]);
+	slabp->active++;
 #if DEBUG
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
 #endif
-	slabp->free++;
 
 	return objp;
 }
@@ -2651,7 +2648,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
 
 	/* Verify double free bug */
-	for (i = slabp->free; i < cachep->num; i++) {
+	for (i = slabp->active; i < cachep->num; i++) {
 		if (slab_bufctl(slabp)[i] == objnr) {
 			printk(KERN_ERR "slab: double free detected in cache "
 					"'%s', objp %p\n", cachep->name, objp);
@@ -2659,9 +2656,8 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
 		}
 	}
 #endif
-	slabp->free--;
-	slab_bufctl(slabp)[slabp->free] = objnr;
-	slabp->inuse--;
+	slabp->active--;
+	slab_bufctl(slabp)[slabp->active] = objnr;
 }
 
 /*
@@ -2896,9 +2892,9 @@ retry:
 		 * there must be at least one object available for
 		 * allocation.
 		 */
-		BUG_ON(slabp->inuse >= cachep->num);
+		BUG_ON(slabp->active >= cachep->num);
 
-		while (slabp->inuse < cachep->num && batchcount--) {
+		while (slabp->active < cachep->num && batchcount--) {
 			STATS_INC_ALLOCED(cachep);
 			STATS_INC_ACTIVE(cachep);
 			STATS_SET_HIGH(cachep);
@@ -2909,7 +2905,7 @@ retry:
 
 		/* move slabp to correct slabp list: */
 		list_del(&slabp->list);
-		if (slabp->free == cachep->num)
+		if (slabp->active == cachep->num)
 			list_add(&slabp->list, &n->slabs_full);
 		else
 			list_add(&slabp->list, &n->slabs_partial);
@@ -3194,14 +3190,14 @@ retry:
 	STATS_INC_ACTIVE(cachep);
 	STATS_SET_HIGH(cachep);
 
-	BUG_ON(slabp->inuse == cachep->num);
+	BUG_ON(slabp->active == cachep->num);
 
 	obj = slab_get_obj(cachep, slabp, nodeid);
 	n->free_objects--;
 	/* move slabp to correct slabp list: */
 	list_del(&slabp->list);
 
-	if (slabp->free == cachep->num)
+	if (slabp->active == cachep->num)
 		list_add(&slabp->list, &n->slabs_full);
 	else
 		list_add(&slabp->list, &n->slabs_partial);
@@ -3380,7 +3376,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 		n->free_objects++;
 
 		/* fixup slab chains */
-		if (slabp->inuse == 0) {
+		if (slabp->active == 0) {
 			if (n->free_objects > n->free_limit) {
 				n->free_objects -= cachep->num;
 				/* No need to drop any previously held
@@ -3441,7 +3437,7 @@ free_done:
 			struct slab *slabp;
 
 			slabp = list_entry(p, struct slab, list);
-			BUG_ON(slabp->inuse);
+			BUG_ON(slabp->active);
 
 			i++;
 			p = p->next;
@@ -4055,22 +4051,22 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 		spin_lock_irq(&n->list_lock);
 
 		list_for_each_entry(slabp, &n->slabs_full, list) {
-			if (slabp->inuse != cachep->num && !error)
+			if (slabp->active != cachep->num && !error)
 				error = "slabs_full accounting error";
 			active_objs += cachep->num;
 			active_slabs++;
 		}
 		list_for_each_entry(slabp, &n->slabs_partial, list) {
-			if (slabp->inuse == cachep->num && !error)
-				error = "slabs_partial inuse accounting error";
-			if (!slabp->inuse && !error)
-				error = "slabs_partial/inuse accounting error";
-			active_objs += slabp->inuse;
+			if (slabp->active == cachep->num && !error)
+				error = "slabs_partial accounting error";
+			if (!slabp->active && !error)
+				error = "slabs_partial accounting error";
+			active_objs += slabp->active;
 			active_slabs++;
 		}
 		list_for_each_entry(slabp, &n->slabs_free, list) {
-			if (slabp->inuse && !error)
-				error = "slabs_free/inuse accounting error";
+			if (slabp->active && !error)
+				error = "slabs_free accounting error";
 			num_slabs++;
 		}
 		free_objects += n->free_objects;
@@ -4232,7 +4228,7 @@ static void handle_slab(unsigned long *n, struct kmem_cache *c, struct slab *s)
 	for (i = 0, p = s->s_mem; i < c->num; i++, p += c->size) {
 		bool active = true;
 
-		for (j = s->free; j < c->num; j++) {
+		for (j = s->active; j < c->num; j++) {
 			/* Skip freed item */
 			if (slab_bufctl(s)[j] == i) {
 				active = false;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
