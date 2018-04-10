Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id EF0AB6B0033
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:53:55 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id z2-v6so9479922plk.3
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:53:55 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m10-v6si2756997pln.595.2018.04.10.05.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 05:53:54 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 1/2] slab: __GFP_ZERO is incompatible with a constructor
Date: Tue, 10 Apr 2018 05:53:50 -0700
Message-Id: <20180410125351.15837-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, stable@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

__GFP_ZERO requests that the object be initialised to all-zeroes,
while the purpose of a constructor is to initialise an object to a
particular pattern.  We cannot do both.  Add a warning to catch any
users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
a constructor.

Fixes: d07dbea46405 ("Slab allocators: support __GFP_ZERO in all allocators")
Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Cc: stable@vger.kernel.org
---
 mm/slab.c | 6 ++++--
 mm/slob.c | 4 +++-
 mm/slub.c | 6 ++++--
 3 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 38d3f4fd17d7..8b2cb7db85db 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3313,8 +3313,10 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
 
-	if (unlikely(flags & __GFP_ZERO) && ptr)
-		memset(ptr, 0, cachep->object_size);
+	if (unlikely(flags & __GFP_ZERO) && ptr) {
+		if (!WARN_ON_ONCE(cachep->ctor))
+			memset(ptr, 0, cachep->object_size);
+	}
 
 	slab_post_alloc_hook(cachep, flags, 1, &ptr);
 	return ptr;
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
index 9e1100f9298f..0f55f0a0dcaa 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2714,8 +2714,10 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 		stat(s, ALLOC_FASTPATH);
 	}
 
-	if (unlikely(gfpflags & __GFP_ZERO) && object)
-		memset(object, 0, s->object_size);
+	if (unlikely(gfpflags & __GFP_ZERO) && object) {
+		if (!WARN_ON_ONCE(s->ctor))
+			memset(object, 0, s->object_size);
+	}
 
 	slab_post_alloc_hook(s, gfpflags, 1, &object);
 
-- 
2.16.3
