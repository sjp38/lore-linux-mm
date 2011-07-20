Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4696B004A
	for <linux-mm@kvack.org>; Wed, 20 Jul 2011 11:56:13 -0400 (EDT)
Received: by wyg36 with SMTP id 36so347930wyg.14
        for <linux-mm@kvack.org>; Wed, 20 Jul 2011 08:56:10 -0700 (PDT)
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1107201033080.1472@router.home>
References: <20110720121612.28888.38970.stgit@localhost6>
	 <alpine.DEB.2.00.1107201611010.3528@tiger> <20110720134342.GK5349@suse.de>
	 <alpine.DEB.2.00.1107200854390.32737@router.home>
	 <1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107200950270.1472@router.home>
	 <1311174562.2338.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <alpine.DEB.2.00.1107201033080.1472@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Jul 2011 17:56:02 +0200
Message-ID: <1311177362.2338.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>

Le mercredi 20 juillet 2011 A  10:34 -0500, Christoph Lameter a A(C)crit :
> On Wed, 20 Jul 2011, Eric Dumazet wrote:
> 
> > [PATCH] slab: remove one NR_CPUS dependency
> 
> Ok simple enough.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> 

Thanks Christoph

Here is the second patch, also simple and working for me (tested on
x86_64, NR_CPUS=4096, on my 2x4x2 machine)

Eventually, we could avoid the extra 'array' pointer if NR_CPUS is known
to be a small value (<= 16 for example)

Note that adding ____cacheline_aligned_in_smp on nodelists[] actually
helps performance, as all following fields are readonly after kmem_cache
setup.

[PATCH] slab: shrinks sizeof(struct kmem_cache)

Reduce high order allocations for some setups.
(NR_CPUS=4096 -> we need 64KB per kmem_cache struct)


Reported-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Pekka Enberg <penberg@kernel.org>
CC: Christoph Lameter <cl@linux.com>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/slab_def.h |    4 ++--
 mm/slab.c                |   10 ++++++----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 83203ae..abedd8e 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -51,7 +51,7 @@
 
 struct kmem_cache {
 /* 1) per-cpu data, touched during every alloc/free */
-	struct array_cache *array[NR_CPUS];
+	struct array_cache **array;
 /* 2) Cache tunables. Protected by cache_chain_mutex */
 	unsigned int batchcount;
 	unsigned int limit;
@@ -118,7 +118,7 @@ struct kmem_cache {
 	 * We still use [MAX_NUMNODES] and not [1] or [0] because cache_cache
 	 * is statically defined, so we reserve the max number of nodes.
 	 */
-	struct kmem_list3 *nodelists[MAX_NUMNODES];
+	struct kmem_list3 *nodelists[MAX_NUMNODES] ____cacheline_aligned_in_smp;
 	/*
 	 * Do not add fields after nodelists[]
 	 */
diff --git a/mm/slab.c b/mm/slab.c
index d96e223..f951015 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -574,7 +574,9 @@ static struct arraycache_init initarray_generic =
     { {0, BOOT_CPUCACHE_ENTRIES, 1, 0} };
 
 /* internal cache of cache description objs */
+static struct array_cache *array_cache_cache[NR_CPUS];
 static struct kmem_cache cache_cache = {
+	.array = array_cache_cache,
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
+	cache_cache.buffer_size = offsetof(struct kmem_cache, nodelists[nr_node_ids]) +
+				 nr_cpu_ids * sizeof(struct array_cache *);
 #if DEBUG
 	cache_cache.obj_size = cache_cache.buffer_size;
 #endif
@@ -2308,6 +2309,7 @@ kmem_cache_create (const char *name, size_t size, size_t align,
 	if (!cachep)
 		goto oops;
 
+	cachep->array = (struct array_cache **)&cachep->nodelists[nr_node_ids];
 #if DEBUG
 	cachep->obj_size = size;
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
