Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD746B003D
	for <linux-mm@kvack.org>; Wed,  7 May 2014 17:19:24 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id uy17so1673775igb.15
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:19:24 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id vv4si2495641pbc.150.2014.05.07.14.19.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 14:19:23 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so1499196pdj.22
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:19:23 -0700 (PDT)
Date: Wed, 7 May 2014 14:19:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, slab: suppress out of memory warning unless debug is
 enabled
Message-ID: <alpine.DEB.2.02.1405071418410.8389@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When the slab or slub allocators cannot allocate additional slab pages, they 
emit diagnostic information to the kernel log such as current number of slabs, 
number of objects, active objects, etc.  This is always coupled with a page 
allocation failure warning since it is controlled by !__GFP_NOWARN.

Suppress this out of memory warning if the allocator is configured without debug 
supported.  The page allocation failure warning will indicate it is a failed 
slab allocation, so this is only useful to diagnose allocator bugs.

Since CONFIG_SLUB_DEBUG is already enabled by default for the slub allocator, 
there is no functional change with this patch.  If debug is disabled, however, 
the warnings are now suppressed.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slab.c | 10 ++++++++--
 mm/slub.c | 11 ++++++++---
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1621,11 +1621,17 @@ __initcall(cpucache_init);
 static noinline void
 slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 {
+#if DEBUG
 	struct kmem_cache_node *n;
 	struct page *page;
 	unsigned long flags;
 	int node;
 
+	if (gfpflags & __GFP_NOWARN)
+		return;
+	if (!printk_ratelimit())
+		return;
+
 	printk(KERN_WARNING
 		"SLAB: Unable to allocate memory on node %d (gfp=0x%x)\n",
 		nodeid, gfpflags);
@@ -1662,6 +1668,7 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 			node, active_slabs, num_slabs, active_objs, num_objs,
 			free_objects);
 	}
+#endif
 }
 
 /*
@@ -1683,8 +1690,7 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 
 	page = alloc_pages_exact_node(nodeid, flags | __GFP_NOTRACK, cachep->gfporder);
 	if (!page) {
-		if (!(flags & __GFP_NOWARN) && printk_ratelimit())
-			slab_out_of_memory(cachep, flags, nodeid);
+		slab_out_of_memory(cachep, flags, nodeid);
 		return NULL;
 	}
 
diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2152,8 +2152,14 @@ static inline unsigned long node_nr_objs(struct kmem_cache_node *n)
 static noinline void
 slab_out_of_memory(struct kmem_cache *s, gfp_t gfpflags, int nid)
 {
+#ifdef CONFIG_SLUB_DEBUG
 	int node;
 
+	if (gfpflags & __GFP_NOWARN)
+		return;
+	if (!printk_ratelimit())
+		return;
+
 	printk(KERN_WARNING
 		"SLUB: Unable to allocate memory on node %d (gfp=0x%x)\n",
 		nid, gfpflags);
@@ -2182,6 +2188,7 @@ slab_out_of_memory(struct kmem_cache *s, gfp_t gfpflags, int nid)
 			"  node %d: slabs: %ld, objs: %ld, free: %ld\n",
 			node, nr_slabs, nr_objs, nr_free);
 	}
+#endif
 }
 
 static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
@@ -2360,9 +2367,7 @@ new_slab:
 	freelist = new_slab_objects(s, gfpflags, node, &c);
 
 	if (unlikely(!freelist)) {
-		if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
-			slab_out_of_memory(s, gfpflags, node);
-
+		slab_out_of_memory(s, gfpflags, node);
 		local_irq_restore(flags);
 		return NULL;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
