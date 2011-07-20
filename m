Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id AE2746B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 13:04:36 -0400 (EDT)
Received: by wwj40 with SMTP id 40so376476wwj.26
        for <linux-mm@kvack.org>; Wed, 20 Jul 2011 10:04:33 -0700 (PDT)
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1311179465.2338.62.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110720121612.28888.38970.stgit@localhost6>
	 <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>
	 <alpine.DEB.2.00.1107200854390.32737@router.home>
	 <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107200950270.1472@router.home>
	 <1311174562.2338.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107201033080.1472@router.home>
	 <1311177362.2338.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107201114480.1472@router.home>
	 <1311179465.2338.62.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Jul 2011 19:04:23 +0200
Message-ID: <1311181463.2338.72.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

Le mercredi 20 juillet 2011 A  18:31 +0200, Eric Dumazet a A(C)crit :

> In fact resulting code is smaller, because most fields are now with <
> 127 offset (x86 assembly code can use shorter instructions)
> 
> Before patch :
> # size mm/slab.o
>    text	   data	    bss	    dec	    hex	filename
>   22605	 361665	     32	 384302	  5dd2e	mm/slab.o
> 
> After patch :
> # size mm/slab.o
>    text	   data	    bss	    dec	    hex	filename
>   22347	 328929	  32800	 384076	  5dc4c	mm/slab.o
> 
> > The per node pointers are lower priority in terms of performance than the
> > per cpu pointers. I'd rather have the per node pointers requiring an
> > additional lookup. Less impact on hot code paths.
> > 
> 
> Sure. I'll post a V2 to have CPU array before NODE array.
> 

Here it is. My dev machine still run after booting with this patch.
No performance impact seen yet.

Thanks

[PATCH v2] slab: shrinks sizeof(struct kmem_cache)

Reduce high order allocations for some setups.
(NR_CPUS=4096 -> we need 64KB per kmem_cache struct)

We now allocate exact needed size (using nr_cpu_ids and nr_node_ids)

This also makes code a bit smaller on x86_64, since some field offsets
are less than the 127 limit :

Before patch :
# size mm/slab.o
   text    data     bss     dec     hex filename
  22605  361665      32  384302   5dd2e mm/slab.o

After patch :
# size mm/slab.o
   text    data     bss     dec     hex filename
  22349	 353473	   8224	 384046	  5dc2e	mm/slab.o

Reported-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Pekka Enberg <penberg@kernel.org>
CC: Christoph Lameter <cl@linux.com>
CC: Andrew Morton <akpm@linux-foundation.org>
---
v2: move the CPU array before NODE array.

 include/linux/slab_def.h |   26 +++++++++++++-------------
 mm/slab.c                |   10 ++++++----
 2 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 83203ae..6e51c4d 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -50,21 +50,19 @@
  */
 
 struct kmem_cache {
-/* 1) per-cpu data, touched during every alloc/free */
-	struct array_cache *array[NR_CPUS];
-/* 2) Cache tunables. Protected by cache_chain_mutex */
+/* 1) Cache tunables. Protected by cache_chain_mutex */
 	unsigned int batchcount;
 	unsigned int limit;
 	unsigned int shared;
 
 	unsigned int buffer_size;
 	u32 reciprocal_buffer_size;
-/* 3) touched by every alloc & free from the backend */
+/* 2) touched by every alloc & free from the backend */
 
 	unsigned int flags;		/* constant flags */
 	unsigned int num;		/* # of objs per slab */
 
-/* 4) cache_grow/shrink */
+/* 3) cache_grow/shrink */
 	/* order of pgs per slab (2^n) */
 	unsigned int gfporder;
 
@@ -80,11 +78,11 @@ struct kmem_cache {
 	/* constructor func */
 	void (*ctor)(void *obj);
 
-/* 5) cache creation/removal */
+/* 4) cache creation/removal */
 	const char *name;
 	struct list_head next;
 
-/* 6) statistics */
+/* 5) statistics */
 #ifdef CONFIG_DEBUG_SLAB
 	unsigned long num_active;
 	unsigned long num_allocations;
@@ -111,16 +109,18 @@ struct kmem_cache {
 	int obj_size;
 #endif /* CONFIG_DEBUG_SLAB */
 
+/* 6) per-cpu/per-node data, touched during every alloc/free */
 	/*
-	 * We put nodelists[] at the end of kmem_cache, because we want to size
-	 * this array to nr_node_ids slots instead of MAX_NUMNODES
+	 * We put array[] at the end of kmem_cache, because we want to size
+	 * this array to nr_cpu_ids slots instead of NR_CPUS
 	 * (see kmem_cache_init())
-	 * We still use [MAX_NUMNODES] and not [1] or [0] because cache_cache
-	 * is statically defined, so we reserve the max number of nodes.
+	 * We still use [NR_CPUS] and not [1] or [0] because cache_cache
+	 * is statically defined, so we reserve the max number of cpus.
 	 */
-	struct kmem_list3 *nodelists[MAX_NUMNODES];
+	struct kmem_list3 **nodelists;
+	struct array_cache *array[NR_CPUS];
 	/*
-	 * Do not add fields after nodelists[]
+	 * Do not add fields after array[]
 	 */
 };
 
diff --git a/mm/slab.c b/mm/slab.c
index d96e223..30181fb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -574,7 +574,9 @@ static struct arraycache_init initarray_generic =
     { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 
 /* internal cache of cache description objs */
+static struct kmem_list3 *cache_cache_nodelists[MAX_NUMNODES];
 static struct kmem_cache cache_cache = {
+	.nodelists = cache_cache_nodelists,
 	.batchcount = 1,
 	.limit = BOOT_CPUCACHE_ENTRIES,
 	.shared = 1,
@@ -1492,11 +1494,10 @@ void __init kmem_cache_init(void)
 	cache_cache.nodelists[node] = &initkmem_list3[CACHE_CACHE + node];
 
 	/*
-	 * struct kmem_cache size depends on nr_node_ids, which
-	 * can be less than MAX_NUMNODES.
+	 * struct kmem_cache size depends on nr_node_ids & nr_cpu_ids
 	 */
-	cache_cache.buffer_size = offsetof(struct kmem_cache, nodelists) +
-				 nr_node_ids * sizeof(struct kmem_list3 *);
+	cache_cache.buffer_size = offsetof(struct kmem_cache, array[nr_cpu_ids]) +
+				  nr_node_ids * sizeof(struct kmem_list3 *);
 #if DEBUG
 	cache_cache.obj_size = cache_cache.buffer_size;
 #endif
@@ -2308,6 +2309,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 	if (!cachep)
 		goto oops;
 
+	cachep->nodelists = (struct kmem_list3 **)&cachep->array[nr_cpu_ids];
 #if DEBUG
 	cachep->obj_size = size;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
