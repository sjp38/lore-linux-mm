Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA1C6B0031
	for <linux-mm@kvack.org>; Sun, 30 Mar 2014 05:02:30 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id jt11so6919283pbb.28
        for <linux-mm@kvack.org>; Sun, 30 Mar 2014 02:02:30 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id wm7si6946891pab.110.2014.03.30.02.02.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 30 Mar 2014 02:02:28 -0700 (PDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so6713032pde.11
        for <linux-mm@kvack.org>; Sun, 30 Mar 2014 02:02:28 -0700 (PDT)
From: Jianyu Zhan <nasa4836@gmail.com>
Subject: [PATCH] mm/slab.c: cleanup outdated comments and unify variables naming
Date: Sun, 30 Mar 2014 17:02:20 +0800
Message-Id: <1396170140-7415-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, nasa4836@gmail.com

As time goes, the code changes a lot, and this leads to that
some old-days comments scatter around , which instead of faciliating
understanding, but make more confusion. So this patch cleans up them.

Also, this patch unifies some variables naming.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
---
 mm/slab.c | 66 +++++++++++++++++++++++++++++++--------------------------------
 1 file changed, 32 insertions(+), 34 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b264214..5678673 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -277,8 +277,8 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
  * OTOH the cpuarrays can contain lots of objects,
  * which could lock up otherwise freeable slabs.
  */
-#define REAPTIMEOUT_CPUC	(2*HZ)
-#define REAPTIMEOUT_LIST3	(4*HZ)
+#define REAPTIMEOUT_AC		(2*HZ)
+#define REAPTIMEOUT_NODE	(4*HZ)
 
 #if STATS
 #define	STATS_INC_ACTIVE(x)	((x)->num_active++)
@@ -1067,7 +1067,7 @@ static int init_cache_node_node(int node)
 
 	list_for_each_entry(cachep, &slab_caches, list) {
 		/*
-		 * Set up the size64 kmemlist for cpu before we can
+		 * Set up the kmem_cache_node for cpu before we can
 		 * begin anything. Make sure some other cpu on this
 		 * node has not already allocated this
 		 */
@@ -1076,12 +1076,12 @@ static int init_cache_node_node(int node)
 			if (!n)
 				return -ENOMEM;
 			kmem_cache_node_init(n);
-			n->next_reap = jiffies + REAPTIMEOUT_LIST3 +
-			    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
+			n->next_reap = jiffies + REAPTIMEOUT_NODE +
+			    ((unsigned long)cachep) % REAPTIMEOUT_NODE;
 
 			/*
-			 * The l3s don't come and go as CPUs come and
-			 * go.  slab_mutex is sufficient
+			 * The kmem_cache_nodes don't come and go as CPUs
+			 * come and go.  slab_mutex is sufficient
 			 * protection here.
 			 */
 			cachep->node[node] = n;
@@ -1406,8 +1406,8 @@ static void __init set_up_node(struct kmem_cache *cachep, int index)
 	for_each_online_node(node) {
 		cachep->node[node] = &init_kmem_cache_node[index + node];
 		cachep->node[node]->next_reap = jiffies +
-		    REAPTIMEOUT_LIST3 +
-		    ((unsigned long)cachep) % REAPTIMEOUT_LIST3;
+		    REAPTIMEOUT_NODE +
+		    ((unsigned long)cachep) % REAPTIMEOUT_NODE;
 	}
 }
 
@@ -2103,8 +2103,8 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 		}
 	}
 	cachep->node[numa_mem_id()]->next_reap =
-			jiffies + REAPTIMEOUT_LIST3 +
-			((unsigned long)cachep) % REAPTIMEOUT_LIST3;
+			jiffies + REAPTIMEOUT_NODE +
+			((unsigned long)cachep) % REAPTIMEOUT_NODE;
 
 	cpu_cache_get(cachep)->avail = 0;
 	cpu_cache_get(cachep)->limit = BOOT_CPUCACHE_ENTRIES;
@@ -2300,10 +2300,10 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	if (flags & CFLGS_OFF_SLAB) {
 		cachep->freelist_cache = kmalloc_slab(freelist_size, 0u);
 		/*
-		 * This is a possibility for one of the malloc_sizes caches.
+		 * This is a possibility for one of the kmalloc_{dma,}_caches.
 		 * But since we go off slab only for object size greater than
-		 * PAGE_SIZE/8, and malloc_sizes gets created in ascending order,
-		 * this should not happen at all.
+		 * PAGE_SIZE/8, and kmalloc_{dma,}_caches get created
+		 * in ascending order,this should not happen at all.
 		 * But leave a BUG_ON for some lucky dude.
 		 */
 		BUG_ON(ZERO_OR_NULL_PTR(cachep->freelist_cache));
@@ -2511,14 +2511,17 @@ int __kmem_cache_shutdown(struct kmem_cache *cachep)
 
 /*
  * Get the memory for a slab management obj.
- * For a slab cache when the slab descriptor is off-slab, slab descriptors
- * always come from malloc_sizes caches.  The slab descriptor cannot
- * come from the same cache which is getting created because,
- * when we are searching for an appropriate cache for these
- * descriptors in kmem_cache_create, we search through the malloc_sizes array.
- * If we are creating a malloc_sizes cache here it would not be visible to
- * kmem_find_general_cachep till the initialization is complete.
- * Hence we cannot have freelist_cache same as the original cache.
+ *
+ * For a slab cache when the slab descriptor is off-slab, the
+ * slab descriptor can't come from the same cache which is being created,
+ * Because if it is the case, that means we defer the creation of
+ * the kmalloc_{dma,}_cache of size sizeof(slab descriptor) to this point.
+ * And we eventually call down to __kmem_cache_create(), which
+ * in turn looks up in the kmalloc_{dma,}_caches for the disired-size one.
+ * This is a "chicken-and-egg" problem.
+ *
+ * So the off-slab slab descriptor shall come from the kmalloc_{dma,}_caches,
+ * which are all initialized during kmem_cache_init().
  */
 static void *alloc_slabmgmt(struct kmem_cache *cachep,
 				   struct page *page, int colour_off,
@@ -3320,7 +3323,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 }
 
 /*
- * Caller needs to acquire correct kmem_list's list_lock
+ * Caller needs to acquire correct kmem_cache_node's list_lock
  */
 static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 		       int node)
@@ -3574,11 +3577,6 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	struct kmem_cache *cachep;
 	void *ret;
 
-	/* If you want to save a few bytes .text space: replace
-	 * __ with kmem_.
-	 * Then kmalloc uses the uninlined functions instead of the inline
-	 * functions.
-	 */
 	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
@@ -3670,7 +3668,7 @@ EXPORT_SYMBOL(kfree);
 /*
  * This initializes kmem_cache_node or resizes various caches for all nodes.
  */
-static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
+static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
 {
 	int node;
 	struct kmem_cache_node *n;
@@ -3726,8 +3724,8 @@ static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
 		}
 
 		kmem_cache_node_init(n);
-		n->next_reap = jiffies + REAPTIMEOUT_LIST3 +
-				((unsigned long)cachep) % REAPTIMEOUT_LIST3;
+		n->next_reap = jiffies + REAPTIMEOUT_NODE +
+				((unsigned long)cachep) % REAPTIMEOUT_NODE;
 		n->shared = new_shared;
 		n->alien = new_alien;
 		n->free_limit = (1 + nr_cpus_node(node)) *
@@ -3813,7 +3811,7 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
 		kfree(ccold);
 	}
 	kfree(new);
-	return alloc_kmemlist(cachep, gfp);
+	return alloc_kmem_cache_node(cachep, gfp);
 }
 
 static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
@@ -3982,7 +3980,7 @@ static void cache_reap(struct work_struct *w)
 		if (time_after(n->next_reap, jiffies))
 			goto next;
 
-		n->next_reap = jiffies + REAPTIMEOUT_LIST3;
+		n->next_reap = jiffies + REAPTIMEOUT_NODE;
 
 		drain_array(searchp, n, n->shared, 0, node);
 
@@ -4003,7 +4001,7 @@ next:
 	next_reap_node();
 out:
 	/* Set up the next iteration */
-	schedule_delayed_work(work, round_jiffies_relative(REAPTIMEOUT_CPUC));
+	schedule_delayed_work(work, round_jiffies_relative(REAPTIMEOUT_AC));
 }
 
 #ifdef CONFIG_SLABINFO
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
