Date: Sat, 28 Apr 2007 22:06:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Remove per cpu flusher
Message-ID: <Pine.LNX.4.64.0704282204470.29440@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Tests show that we only have a very small number of slabs on the system
with the slab merge features. Its around 60 - 80 slabs with only about 40
to 50 of them having objects at all. If every one of these 50 slab keeps
an active per cpu slab then each processor uses about 50*16k = 800k of
memory for the per cpu slabs. This includes objects already allocated in
those slabs. For a system with 128 processors this is going to be 100M.
Of those only 25M are going to be saved through the per cpu flusher.
Pretty minor effect compared to the gigabyte that is used on these
systems by SLAB for its queueing structures of free objects alone.

I think we can readily affort to keep these per cpu slabs around for good.
If one wants to recover the cpu slabs regularly then one can set up a
cron job that runs

slabinfo -s

every minute or so. Slab shrinking will flush per cpu slabs back to the
partial lists and make it possible for other cpus to use them. Slab
shrinking is more effective and capable of reclaiming 50M of the 100M
in the percpu slabs.

Removing the per cpu flusher has the advantage that the system will be
completely silent if no slab activity occurs. No timers need to be used
for SLUB at all which is good for the realtime folks and for those who
want to conserve power.

Also the size of the kmem_cache structure shrinks significantly and most
of the data elements now fit into one cache line.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/slub_def.h |    7 --
 mm/slub.c                |  110 +++++------------------------------------------
 2 files changed, 14 insertions(+), 103 deletions(-)

Index: slub/include/linux/slub_def.h
===================================================================
--- slub.orig/include/linux/slub_def.h	2007-04-28 13:15:47.000000000 -0700
+++ slub/include/linux/slub_def.h	2007-04-28 15:32:34.000000000 -0700
@@ -28,8 +28,6 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int objsize;		/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
-	atomic_t cpu_slabs;	/* != 0 -> flusher scheduled. */
-	int defrag_ratio;
 	unsigned int order;
 
 	/*
@@ -49,11 +47,8 @@ struct kmem_cache {
 	struct list_head list;	/* List of slab caches */
 	struct kobject kobj;	/* For sysfs */
 
-#ifdef CONFIG_SMP
-	struct delayed_work flush;
-	struct mutex flushing;
-#endif
 #ifdef CONFIG_NUMA
+	int defrag_ratio;
 	struct kmem_cache_node *node[MAX_NUMNODES];
 #endif
 	struct page *cpu_slab[NR_CPUS];
Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-04-28 13:16:05.000000000 -0700
+++ slub/mm/slub.c	2007-04-28 16:07:17.000000000 -0700
@@ -38,17 +38,18 @@
  *   removed from the lists nor make the number of partial slabs be modified.
  *   (Note that the total number of slabs is an atomic value that may be
  *   modified without taking the list lock).
+ *
  *   The list_lock is a centralized lock and thus we avoid taking it as
  *   much as possible. As long as SLUB does not have to handle partial
- *   slabs operations can continue without any centralized lock. F.e.
+ *   slabs, operations can continue without any centralized lock. F.e.
  *   allocating a long series of objects that fill up slabs does not require
  *   the list lock.
  *
  *   The lock order is sometimes inverted when we are trying to get a slab
  *   off a list. We take the list_lock and then look for a page on the list
- *   to use. While we do that objects in the slabs may be freed so we can
+ *   to use. While we do that objects in the slabs may be freed. We can
  *   only operate on the slab if we have also taken the slab_lock. So we use
- *   a slab_trylock() on the page. If trylock was successful then no frees
+ *   a slab_trylock() on the slab. If trylock was successful then no frees
  *   can occur anymore and we can use the slab for allocations etc. If the
  *   slab_trylock() does not succeed then frees are in progress in the slab and
  *   we must stay away from it for a while since we may cause a bouncing
@@ -65,14 +66,11 @@
  * SLUB assigns one slab for allocation to each processor.
  * Allocations only occur from these slabs called cpu slabs.
  *
- * If a cpu slab exists then a workqueue thread checks every 30
- * seconds if the cpu slab is still in use. The cpu slab is pushed back
- * to the list if inactive [only needed for SMP].
- *
  * Slabs with free elements are kept on a partial list.
  * There is no list for full slabs. If an object in a full slab is
  * freed then the slab will show up again on the partial lists.
- * Otherwise there is no need to track full slabs (but we keep a counter).
+ * Otherwise there is no need to track full slabs unless we have to
+ * track full slabs for debugging purposes.
  *
  * Slabs are freed when they become empty. Teardown and setup is
  * minimal so we rely on the page allocators per cpu caches for
@@ -82,15 +80,11 @@
  *
  * PageActive 		The slab is used as a cpu cache. Allocations
  * 			may be performed from the slab. The slab is not
- * 			on a partial list.
- *
- * PageReferenced	The per cpu slab was used recently. This is used
- * 			to push back per cpu slabs if they are unused
- * 			for a longer time period.
+ * 			on any slab list and cannot be moved onto one.
  *
  * PageError		Slab requires special handling due to debug
- * 			options set or a single page slab. This moves
- * 			slab handling out of the fast path.
+ * 			options set. This moves	slab handling out of
+ * 			the fast path.
  */
 
 /*
@@ -1132,7 +1126,6 @@ static void deactivate_slab(struct kmem_
 {
 	s->cpu_slab[cpu] = NULL;
 	ClearPageActive(page);
-	ClearPageReferenced(page);
 
 	putback_slab(s, page);
 }
@@ -1163,61 +1156,18 @@ static void flush_cpu_slab(void *d)
 	__flush_cpu_slab(s, cpu);
 }
 
-#ifdef CONFIG_SMP
-/*
- * Called from IPI to check and flush cpu slabs.
- */
-static void check_flush_cpu_slab(void *private)
-{
-	struct kmem_cache *s = private;
-	int cpu = smp_processor_id();
-	struct page *page = s->cpu_slab[cpu];
-
-	if (page) {
-		if (!TestClearPageReferenced(page))
-			return;
-		flush_slab(s, page, cpu);
-	}
-	atomic_dec(&s->cpu_slabs);
-}
-
-/*
- * Called from eventd
- */
-static void flusher(struct work_struct *w)
-{
-	struct kmem_cache *s = container_of(w, struct kmem_cache, flush.work);
-
-	if (!mutex_trylock(&s->flushing))
-		return;
-
-	atomic_set(&s->cpu_slabs, num_online_cpus());
-	on_each_cpu(check_flush_cpu_slab, s, 1, 1);
-	if (atomic_read(&s->cpu_slabs))
-		schedule_delayed_work(&s->flush, 30 * HZ);
-	mutex_unlock(&s->flushing);
-}
-
 static void flush_all(struct kmem_cache *s)
 {
-	if (atomic_read(&s->cpu_slabs)) {
-		mutex_lock(&s->flushing);
-		cancel_delayed_work(&s->flush);
-		atomic_set(&s->cpu_slabs, 0);
-		on_each_cpu(flush_cpu_slab, s, 1, 1);
-		mutex_unlock(&s->flushing);
-	}
-}
+#ifdef CONFIG_SMP
+	on_each_cpu(flush_cpu_slab, s, 1, 1);
 #else
-static void flush_all(struct kmem_cache *s)
-{
 	unsigned long flags;
 
 	local_irq_save(flags);
 	flush_cpu_slab(s);
 	local_irq_restore(flags);
-}
 #endif
+}
 
 /*
  * slab_alloc is optimized to only modify two cachelines on the fast path
@@ -1259,7 +1209,6 @@ redo:
 have_object:
 	page->inuse++;
 	page->freelist = object[page->offset];
-	SetPageReferenced(page);
 	slab_unlock(page);
 	local_irq_restore(flags);
 	return object;
@@ -1273,13 +1222,6 @@ new_slab:
 have_slab:
 		s->cpu_slab[cpu] = page;
 		SetPageActive(page);
-
-#ifdef CONFIG_SMP
-		if (!atomic_read(&s->cpu_slabs)) {
-			atomic_inc(&s->cpu_slabs);
-			schedule_delayed_work(&s->flush, 30 * HZ);
-		}
-#endif
 		goto redo;
 	}
 
@@ -1785,13 +1727,6 @@ static int __init finish_bootstrap(void)
 
 		err = sysfs_slab_add(s);
 		BUG_ON(err);
-		/*
-		 * Start the periodic checks for inactive cpu slabs.
-		 * flush_all() will zero s->cpu_slabs which will cause
-		 * any allocation of a new cpu slab to schedule an event
-		 * via keventd to watch for inactive cpu slabs.
-		 */
-		flush_all(s);
 	}
 	return 0;
 }
@@ -1844,24 +1779,6 @@ static int kmem_cache_open(struct kmem_c
 	s->defrag_ratio = 100;
 #endif
 
-#ifdef CONFIG_SMP
-	mutex_init(&s->flushing);
-	if (slab_state >= SYSFS)
-		atomic_set(&s->cpu_slabs, 0);
-	else
-		/*
-		 * Keventd may not be up yet. Pretend that we have active
-		 * per_cpu slabs so that there will be no attempt to
-		 * schedule a flusher in slab_alloc.
-		 *
-		 * We fix the situation up later when sysfs is brought up
-		 * by flushing all slabs (which puts the slab caches that
-		 * are mostly/only used in a nice quiet state).
-		 */
-		atomic_set(&s->cpu_slabs, 1);
-
-	INIT_DELAYED_WORK(&s->flush, flusher);
-#endif
 	if (init_kmem_cache_nodes(s, gfpflags & ~SLUB_DMA))
 		return 1;
 error:
@@ -2088,8 +2005,7 @@ static struct kmem_cache *create_kmalloc
 	return s;
 
 panic:
-	panic("Creation of kmalloc slab %s size=%d failed.\n",
-			name, size);
+	panic("Creation of kmalloc slab %s size=%d failed.\n", name, size);
 }
 
 static struct kmem_cache *get_slab(size_t size, gfp_t flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
