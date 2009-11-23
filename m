Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5767A6B0044
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 14:00:06 -0500 (EST)
Subject: Re: lockdep complaints in slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1258729748.4104.223.camel@laptop>
References: <20091118181202.GA12180@linux.vnet.ibm.com>
	 <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <1258709153.11284.429.camel@laptop>
	 <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com>
	 <1258714328.11284.522.camel@laptop>  <4B067816.6070304@cs.helsinki.fi>
	 <1258729748.4104.223.camel@laptop>
Date: Mon, 23 Nov 2009 21:00:00 +0200
Message-Id: <1259002800.5630.1.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, cl@linux-foundation.org, mpm@selenic.com, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Fri, 2009-11-20 at 16:09 +0100, Peter Zijlstra wrote:
> > Uh, ok, so apparently I was right after all. There's a comment in 
> > free_block() above the slab_destroy() call that refers to the comment 
> > above alloc_slabmgmt() function definition which explains it all.
> > 
> > Long story short: ->slab_cachep never points to the same kmalloc cache 
> > we're allocating or freeing from. Where do we need to put the 
> > spin_lock_nested() annotation? Would it be enough to just use it in 
> > cache_free_alien() for alien->lock or do we need it in 
> > cache_flusharray() as well?
> 
> You'd have to somehow push the nested state down from the
> kmem_cache_free() call in slab_destroy() to all nc->lock sites below.

That turns out to be _very_ hard. How about something like the following
untested patch which delays slab_destroy() while we're under nc->lock.

			Pekka

diff --git a/mm/slab.c b/mm/slab.c
index 7dfa481..6f522e3 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -316,7 +316,7 @@ struct kmem_list3 __initdata initkmem_list3[NUM_INIT_LISTS];
 static int drain_freelist(struct kmem_cache *cache,
 			struct kmem_list3 *l3, int tofree);
 static void free_block(struct kmem_cache *cachep, void **objpp, int len,
-			int node);
+			int node, struct list_head *to_destroy);
 static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp);
 static void cache_reap(struct work_struct *unused);
 
@@ -1002,7 +1002,8 @@ static void free_alien_cache(struct array_cache **ac_ptr)
 }
 
 static void __drain_alien_cache(struct kmem_cache *cachep,
-				struct array_cache *ac, int node)
+				struct array_cache *ac, int node,
+				struct list_head *to_destroy)
 {
 	struct kmem_list3 *rl3 = cachep->nodelists[node];
 
@@ -1016,12 +1017,22 @@ static void __drain_alien_cache(struct kmem_cache *cachep,
 		if (rl3->shared)
 			transfer_objects(rl3->shared, ac, ac->limit);
 
-		free_block(cachep, ac->entry, ac->avail, node);
+		free_block(cachep, ac->entry, ac->avail, node, to_destroy);
 		ac->avail = 0;
 		spin_unlock(&rl3->list_lock);
 	}
 }
 
+static void slab_destroy(struct kmem_cache *, struct slab *);
+
+static void destroy_slabs(struct kmem_cache *cache, struct list_head *to_destroy)
+{
+	struct slab *slab, *tmp;
+
+	list_for_each_entry_safe(slab, tmp, to_destroy, list)
+		slab_destroy(cache, slab);
+}
+
 /*
  * Called from cache_reap() to regularly drain alien caches round robin.
  */
@@ -1033,8 +1044,11 @@ static void reap_alien(struct kmem_cache *cachep, struct kmem_list3 *l3)
 		struct array_cache *ac = l3->alien[node];
 
 		if (ac && ac->avail && spin_trylock_irq(&ac->lock)) {
-			__drain_alien_cache(cachep, ac, node);
+			LIST_HEAD(to_destroy);
+
+			__drain_alien_cache(cachep, ac, node, &to_destroy);
 			spin_unlock_irq(&ac->lock);
+			destroy_slabs(cachep, &to_destroy);
 		}
 	}
 }
@@ -1049,9 +1063,12 @@ static void drain_alien_cache(struct kmem_cache *cachep,
 	for_each_online_node(i) {
 		ac = alien[i];
 		if (ac) {
+			LIST_HEAD(to_destroy);
+
 			spin_lock_irqsave(&ac->lock, flags);
-			__drain_alien_cache(cachep, ac, i);
+			__drain_alien_cache(cachep, ac, i, &to_destroy);
 			spin_unlock_irqrestore(&ac->lock, flags);
+			destroy_slabs(cachep, &to_destroy);
 		}
 	}
 }
@@ -1076,17 +1093,20 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 	l3 = cachep->nodelists[node];
 	STATS_INC_NODEFREES(cachep);
 	if (l3->alien && l3->alien[nodeid]) {
+		LIST_HEAD(to_destroy);
+
 		alien = l3->alien[nodeid];
 		spin_lock(&alien->lock);
 		if (unlikely(alien->avail == alien->limit)) {
 			STATS_INC_ACOVERFLOW(cachep);
-			__drain_alien_cache(cachep, alien, nodeid);
+			__drain_alien_cache(cachep, alien, nodeid, &to_destroy);
 		}
 		alien->entry[alien->avail++] = objp;
 		spin_unlock(&alien->lock);
+		destroy_slabs(cachep, &to_destroy);
 	} else {
 		spin_lock(&(cachep->nodelists[nodeid])->list_lock);
-		free_block(cachep, &objp, 1, nodeid);
+		free_block(cachep, &objp, 1, nodeid, NULL);
 		spin_unlock(&(cachep->nodelists[nodeid])->list_lock);
 	}
 	return 1;
@@ -1118,7 +1138,7 @@ static void __cpuinit cpuup_canceled(long cpu)
 		/* Free limit for this kmem_list3 */
 		l3->free_limit -= cachep->batchcount;
 		if (nc)
-			free_block(cachep, nc->entry, nc->avail, node);
+			free_block(cachep, nc->entry, nc->avail, node, NULL);
 
 		if (!cpus_empty(*mask)) {
 			spin_unlock_irq(&l3->list_lock);
@@ -1128,7 +1148,7 @@ static void __cpuinit cpuup_canceled(long cpu)
 		shared = l3->shared;
 		if (shared) {
 			free_block(cachep, shared->entry,
-				   shared->avail, node);
+				   shared->avail, node, NULL);
 			l3->shared = NULL;
 		}
 
@@ -2402,7 +2422,7 @@ static void do_drain(void *arg)
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
 	spin_lock(&cachep->nodelists[node]->list_lock);
-	free_block(cachep, ac->entry, ac->avail, node);
+	free_block(cachep, ac->entry, ac->avail, node, NULL);
 	spin_unlock(&cachep->nodelists[node]->list_lock);
 	ac->avail = 0;
 }
@@ -3410,7 +3430,7 @@ __cache_alloc(struct kmem_cache *cachep, gfp_t flags, void *caller)
  * Caller needs to acquire correct kmem_list's list_lock
  */
 static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
-		       int node)
+		       int node, struct list_head *to_destroy)
 {
 	int i;
 	struct kmem_list3 *l3;
@@ -3439,7 +3459,10 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 				 * a different cache, refer to comments before
 				 * alloc_slabmgmt.
 				 */
-				slab_destroy(cachep, slabp);
+				if (to_destroy)
+					list_add(&slabp->list, to_destroy);
+				else
+					slab_destroy(cachep, slabp);
 			} else {
 				list_add(&slabp->list, &l3->slabs_free);
 			}
@@ -3479,7 +3502,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 		}
 	}
 
-	free_block(cachep, ac->entry, batchcount, node);
+	free_block(cachep, ac->entry, batchcount, node, NULL);
 free_done:
 #if STATS
 	{
@@ -3822,7 +3845,7 @@ static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
 
 			if (shared)
 				free_block(cachep, shared->entry,
-						shared->avail, node);
+						shared->avail, node, NULL);
 
 			l3->shared = new_shared;
 			if (!l3->alien) {
@@ -3925,7 +3948,7 @@ static int do_tune_cpucache(struct kmem_cache *cachep, int limit,
 		if (!ccold)
 			continue;
 		spin_lock_irq(&cachep->nodelists[cpu_to_node(i)]->list_lock);
-		free_block(cachep, ccold->entry, ccold->avail, cpu_to_node(i));
+		free_block(cachep, ccold->entry, ccold->avail, cpu_to_node(i), NULL);
 		spin_unlock_irq(&cachep->nodelists[cpu_to_node(i)]->list_lock);
 		kfree(ccold);
 	}
@@ -4007,7 +4030,7 @@ void drain_array(struct kmem_cache *cachep, struct kmem_list3 *l3,
 			tofree = force ? ac->avail : (ac->limit + 4) / 5;
 			if (tofree > ac->avail)
 				tofree = (ac->avail + 1) / 2;
-			free_block(cachep, ac->entry, tofree, node);
+			free_block(cachep, ac->entry, tofree, node, NULL);
 			ac->avail -= tofree;
 			memmove(ac->entry, &(ac->entry[tofree]),
 				sizeof(void *) * ac->avail);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
