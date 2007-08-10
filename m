Date: Fri, 10 Aug 2007 13:55:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Fix dynamic dma kmalloc cache creation
In-Reply-To: <20070810115352.ef869659.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708101344120.20501@schroedinger.engr.sgi.com>
References: <200708100559.l7A5x3r2019930@hera.kernel.org>
 <20070810004059.8aa2aadb.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708101125390.17312@schroedinger.engr.sgi.com>
 <20070810115352.ef869659.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Just to show that we could do it (I can never resist a challenge. Sigh). 
I think the approach is overkill and it may create some new races
vs. hotplug since we may now be operating on slabs that are not
on the slab list. Not tested.


SLUB: Dynamic dma kmalloc slab allocation: Make it reliable

We can avoid the slight chance of failing on the first GFP_ATOMIC|GFP_DMA 
allocation through a new spin lock in the ZONE_DMA section if we do not 
take the slub_lock in dma_cache_create() but speculatively allocate the 
kmem_cache structures and related entities. Then we take the dma cache 
lock and check if the cache was already installed. If so then we just call 
kmem_cache_close() (I moved the flushing from kmem_cache_close() into 
kmem_cache_destroy() to make that work and added checking so that 
kmem_cache_close() works on a kmem_cache structure that has no nodes 
allocated) and then free up the space we allocated.

If we are successful then we schedule the dma_cache_add_func().
The function now scans over the dma kmalloc caches instead over all the
slab caches. If it finds a dma kmalloc caches whose adding to the
list was deferred then it will add the kmalloc cache to the slab list
in addition to performing the sysfs add.

This means that during short periods we may have active slab caches
that are not on the slab lists. We create races with cpu and node hotplug
by doing so. But maybe they are negligible.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-08-10 13:13:35.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-08-10 13:50:58.000000000 -0700
@@ -212,7 +212,7 @@ static inline void ClearSlabDebug(struct
 
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000 /* Poison object */
-#define __SYSFS_ADD_DEFERRED	0x40000000 /* Not yet visible via sysfs */
+#define __SLAB_ADD_DEFERRED	0x40000000 /* Not yet added to list */
 
 /* Not all arches define cache_line_size */
 #ifndef cache_line_size
@@ -2174,15 +2174,15 @@ static inline int kmem_cache_close(struc
 {
 	int node;
 
-	flush_all(s);
-
 	/* Attempt to free all objects */
 	for_each_online_node(node) {
 		struct kmem_cache_node *n = get_node(s, node);
 
-		n->nr_partial -= free_list(s, n, &n->partial);
-		if (atomic_long_read(&n->nr_slabs))
-			return 1;
+		if (n) {
+			n->nr_partial -= free_list(s, n, &n->partial);
+			if (atomic_long_read(&n->nr_slabs))
+				return 1;
+		}
 	}
 	free_kmem_cache_nodes(s);
 	return 0;
@@ -2194,6 +2194,7 @@ static inline int kmem_cache_close(struc
  */
 void kmem_cache_destroy(struct kmem_cache *s)
 {
+	flush_all(s);
 	down_write(&slub_lock);
 	s->refcount--;
 	if (!s->refcount) {
@@ -2215,10 +2216,6 @@ EXPORT_SYMBOL(kmem_cache_destroy);
 struct kmem_cache kmalloc_caches[KMALLOC_SHIFT_HIGH + 1] __cacheline_aligned;
 EXPORT_SYMBOL(kmalloc_caches);
 
-#ifdef CONFIG_ZONE_DMA
-static struct kmem_cache *kmalloc_caches_dma[KMALLOC_SHIFT_HIGH + 1];
-#endif
-
 static int __init setup_slub_min_order(char *str)
 {
 	get_option (&str, &slub_min_order);
@@ -2278,22 +2275,35 @@ panic:
 }
 
 #ifdef CONFIG_ZONE_DMA
+static struct kmem_cache *kmalloc_caches_dma[KMALLOC_SHIFT_HIGH + 1];
 
-static void sysfs_add_func(struct work_struct *w)
+static spinlock_t dma_cache_lock;
+
+static void dma_cache_add_func(struct work_struct *w)
 {
 	struct kmem_cache *s;
+	struct kmem_cache **p;
 
-	down_write(&slub_lock);
-	list_for_each_entry(s, &slab_caches, list) {
-		if (s->flags & __SYSFS_ADD_DEFERRED) {
-			s->flags &= ~__SYSFS_ADD_DEFERRED;
+redo:
+	spin_lock(&dma_cache_lock);
+	for (p = kmalloc_caches_dma;
+		p < kmalloc_caches_dma + KMALLOC_SHIFT_HIGH + 1; p++) {
+		s = *p;
+
+		if (s->flags & __SLAB_ADD_DEFERRED) {
+			spin_unlock(&dma_cache_lock);
+			down_write(&slub_lock);
+			s->flags &= ~__SLAB_ADD_DEFERRED;
+			list_add(&s->list, &slab_caches);
 			sysfs_slab_add(s);
+			up_write(&slub_lock);
+			goto redo;
 		}
 	}
-	up_write(&slub_lock);
+	spin_unlock(&dma_cache_lock);
 }
 
-static DECLARE_WORK(sysfs_add_work, sysfs_add_func);
+static DECLARE_WORK(dma_cache_add_work, dma_cache_add_func);
 
 static noinline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
 {
@@ -2306,36 +2316,30 @@ static noinline struct kmem_cache *dma_k
 		return s;
 
 	/* Dynamically create dma cache */
-	if (flags & __GFP_WAIT)
-		down_write(&slub_lock);
-	else {
-		if (!down_write_trylock(&slub_lock))
-			goto out;
-	}
-
-	if (kmalloc_caches_dma[index])
-		goto unlock_out;
-
 	realsize = kmalloc_caches[index].objsize;
 	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d", (unsigned int)realsize),
 	s = kmalloc(kmem_size, flags & ~SLUB_DMA);
 
 	if (!s || !text || !kmem_cache_open(s, flags, text,
 			realsize, ARCH_KMALLOC_MINALIGN,
-			SLAB_CACHE_DMA|__SYSFS_ADD_DEFERRED, NULL)) {
-		kfree(s);
-		kfree(text);
-		goto unlock_out;
-	}
+			SLAB_CACHE_DMA|__SLAB_ADD_DEFERRED, NULL))
+		goto out;
 
-	list_add(&s->list, &slab_caches);
+	spin_lock(&dma_cache_lock);
+	if (kmalloc_caches_dma[index]) {
+		spin_unlock(&dma_cache_lock);
+		goto out;
+	}
 	kmalloc_caches_dma[index] = s;
+	spin_unlock(&dma_cache_lock);
 
-	schedule_work(&sysfs_add_work);
+	schedule_work(&dma_cache_add_work);
+	return kmalloc_caches_dma[index];
 
-unlock_out:
-	up_write(&slub_lock);
 out:
+	kmem_cache_close(s);
+	kfree(s);
+	kfree(text);
 	return kmalloc_caches_dma[index];
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
