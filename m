Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 141186B0096
	for <linux-mm@kvack.org>; Wed,  7 May 2014 18:00:28 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1710489pad.16
        for <linux-mm@kvack.org>; Wed, 07 May 2014 15:00:27 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id ef1si2536667pbc.429.2014.05.07.15.00.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 15:00:27 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so1738072pab.1
        for <linux-mm@kvack.org>; Wed, 07 May 2014 15:00:26 -0700 (PDT)
Date: Wed, 7 May 2014 15:00:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch v2] mm, slab: suppress out of memory warning unless debug is
 enabled
In-Reply-To: <20140507144858.9aee4e420908ccf9334dfdf2@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1405071500030.25024@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405071418410.8389@chino.kir.corp.google.com> <20140507142925.b0e31514d4cd8d5857b10850@linux-foundation.org> <alpine.DEB.2.02.1405071431580.8454@chino.kir.corp.google.com>
 <20140507144858.9aee4e420908ccf9334dfdf2@linux-foundation.org>
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
slab allocation, the order, and the gfp mask, so this is only useful to diagnose 
allocator issues.

Since CONFIG_SLUB_DEBUG is already enabled by default for the slub allocator, 
there is no functional change with this patch.  If debug is disabled, however, 
the warnings are now suppressed.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 v2: added ratelimit state for slab out of memory warnings per Andrew
     added gfp mask and order to changelog per Andrew

 mm/slab.c | 10 ++++++++--
 mm/slub.c | 11 ++++++++---
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1621,10 +1621,16 @@ __initcall(cpucache_init);
 static noinline void
 slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 {
+#if DEBUG
 	struct kmem_cache_node *n;
 	struct page *page;
 	unsigned long flags;
 	int node;
+	static DEFINE_RATELIMIT_STATE(slab_oom_rs, DEFAULT_RATELIMIT_INTERVAL,
+				      DEFAULT_RATELIMIT_BURST);
+
+	if ((gfpflags & __GFP_NOWARN) || !__ratelimit(&slab_oom_rs))
+		return;
 
 	printk(KERN_WARNING
 		"SLAB: Unable to allocate memory on node %d (gfp=0x%x)\n",
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
+	static DEFINE_RATELIMIT_STATE(slub_oom_rs, DEFAULT_RATELIMIT_INTERVAL,
+				      DEFAULT_RATELIMIT_BURST);
 	int node;
 
+	if ((gfpflags & __GFP_NOWARN) || !__ratelimit(&slub_oom_rs))
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
