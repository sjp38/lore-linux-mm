Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9D16B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 15:13:27 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id u11-v6so4446657pls.22
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 12:13:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n23si2638074pgd.345.2018.04.12.12.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Apr 2018 12:13:25 -0700 (PDT)
Date: Thu, 12 Apr 2018 12:13:22 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 2/2] slab: __GFP_ZERO is incompatible with a constructor
Message-ID: <20180412191322.GA21205@bombadil.infradead.org>
References: <20180411060320.14458-1-willy@infradead.org>
 <20180411060320.14458-3-willy@infradead.org>
 <alpine.DEB.2.20.1804110842560.3788@nuc-kabylake>
 <20180411192448.GD22494@bombadil.infradead.org>
 <alpine.DEB.2.20.1804111601090.7458@nuc-kabylake>
 <20180411235652.GA28279@bombadil.infradead.org>
 <alpine.DEB.2.20.1804120907100.11220@nuc-kabylake>
 <20180412142718.GA20398@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180412142718.GA20398@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

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
Acked-by: Michal Hocko <mhocko@suse.com>
---
 mm/slab.c | 2 ++
 mm/slob.c | 4 +++-
 mm/slub.c | 2 ++
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 58c8cecc26ab..aca63d49b270 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2661,6 +2661,7 @@ static struct page *cache_grow_begin(struct kmem_cache *cachep,
 				invalid_mask, &invalid_mask, flags, &flags);
 		dump_stack();
 	}
+	WARN_ON_ONCE(cachep->ctor && (flags & __GFP_ZERO));
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
 	check_irq_off();
@@ -3067,6 +3068,7 @@ static inline void cache_alloc_debugcheck_before(struct kmem_cache *cachep,
 static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 				gfp_t flags, void *objp, unsigned long caller)
 {
+	WARN_ON_ONCE(cachep->ctor && (flags & __GFP_ZERO));
 	if (!objp)
 		return objp;
 	if (cachep->flags & SLAB_POISON) {
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
index a28488643603..0487d316a665 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2434,6 +2434,8 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 	struct kmem_cache_cpu *c = *pc;
 	struct page *page;
 
+	WARN_ON_ONCE(s->ctor && (flags & __GFP_ZERO));
+
 	freelist = get_partial(s, flags, node, c);
 
 	if (freelist)
-- 
2.16.3
