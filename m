Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EACD76B0009
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 02:03:27 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p12so409428pfn.13
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 23:03:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s78si336656pfj.259.2018.04.10.23.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 23:03:26 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2 2/2] slab: __GFP_ZERO is incompatible with a constructor
Date: Tue, 10 Apr 2018 23:03:20 -0700
Message-Id: <20180411060320.14458-3-willy@infradead.org>
In-Reply-To: <20180411060320.14458-1-willy@infradead.org>
References: <20180411060320.14458-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

From: Matthew Wilcox <mawilcox@microsoft.com>

__GFP_ZERO requests that the object be initialised to all-zeroes,
while the purpose of a constructor is to initialise an object to a
particular pattern.  We cannot do both.  Add a warning to catch any
users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
a constructor.

Fixes: d07dbea46405 ("Slab allocators: support __GFP_ZERO in all allocators")
Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/slab.c | 7 ++++---
 mm/slab.h | 7 +++++++
 mm/slob.c | 4 +++-
 mm/slub.c | 5 +++--
 4 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 58c8cecc26ab..9ad85fd9fca8 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2661,6 +2661,7 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 				invalid_mask, &invalid_mask, flags, &flags);
 		dump_stack();
 	}
+	BUG_ON(cachep->ctor && (flags & __GFP_ZERO));
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
 	check_irq_off();
@@ -3325,7 +3326,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
 
-	if (unlikely(flags & __GFP_ZERO) && ptr)
+	if (unlikely(flags & __GFP_ZERO) && ptr && slab_no_ctor(cachep))
 		memset(ptr, 0, cachep->object_size);
 
 	slab_post_alloc_hook(cachep, flags, 1, &ptr);
@@ -3382,7 +3383,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
 	prefetchw(objp);
 
-	if (unlikely(flags & __GFP_ZERO) && objp)
+	if (unlikely(flags & __GFP_ZERO) && objp && slab_no_ctor(cachep))
 		memset(objp, 0, cachep->object_size);
 
 	slab_post_alloc_hook(cachep, flags, 1, &objp);
@@ -3589,7 +3590,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	cache_alloc_debugcheck_after_bulk(s, flags, size, p, _RET_IP_);
 
 	/* Clear memory outside IRQ disabled section */
-	if (unlikely(flags & __GFP_ZERO))
+	if (unlikely(flags & __GFP_ZERO) && slab_no_ctor(s))
 		for (i = 0; i < size; i++)
 			memset(p[i], 0, s->object_size);
 
diff --git a/mm/slab.h b/mm/slab.h
index 3cd4677953c6..896818c7b30a 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -515,6 +515,13 @@ static inline void dump_unreclaimable_slab(void)
 
 void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
 
+static inline bool slab_no_ctor(struct kmem_cache *s)
+{
+	if (IS_ENABLED(CONFIG_DEBUG_VM))
+		return !WARN_ON_ONCE(s->ctor);
+	return true;
+}
+
 #ifdef CONFIG_SLAB_FREELIST_RANDOM
 int cache_random_seq_create(struct kmem_cache *cachep, unsigned int count,
 			gfp_t gfp);
diff --git a/mm/slob.c b/mm/slob.c
index 1a46181b675c..958173fd7c24 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -556,8 +556,10 @@ static void *slob_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 					    flags, node);
 	}
 
-	if (b && c->ctor)
+	if (b && c->ctor) {
+		WARN_ON_ONCE(flags & __GFP_ZERO);
 		c->ctor(b);
+	}
 
 	kmemleak_alloc_recursive(b, c->size, 1, c->flags, flags);
 	return b;
diff --git a/mm/slub.c b/mm/slub.c
index a28488643603..9f8f38a552e5 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1576,6 +1576,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 
 	if (gfpflags_allow_blocking(flags))
 		local_irq_enable();
+	BUG_ON(s->ctor && (flags & __GFP_ZERO));
 
 	flags |= s->allocflags;
 
@@ -2725,7 +2726,7 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 		stat(s, ALLOC_FASTPATH);
 	}
 
-	if (unlikely(gfpflags & __GFP_ZERO) && object)
+	if (unlikely(gfpflags & __GFP_ZERO) && object && slab_no_ctor(s))
 		memset(object, 0, s->object_size);
 
 	slab_post_alloc_hook(s, gfpflags, 1, &object);
@@ -3149,7 +3150,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	local_irq_enable();
 
 	/* Clear memory outside IRQ disabled fastpath loop */
-	if (unlikely(flags & __GFP_ZERO)) {
+	if (unlikely(flags & __GFP_ZERO) && slab_no_ctor(s)) {
 		int j;
 
 		for (j = 0; j < i; j++)
-- 
2.16.3
