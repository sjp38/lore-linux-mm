Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id B32106B008A
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 18:51:04 -0400 (EDT)
Received: by mail-gg0-f169.google.com with SMTP id f4so241518ggn.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 15:51:04 -0700 (PDT)
From: Ezequiel Garcia <elezegarcia@gmail.com>
Subject: [PATCH 5/5] mm, slob: Trace allocation failures consistently
Date: Wed,  5 Sep 2012 19:48:43 -0300
Message-Id: <1346885323-15689-5-git-send-email-elezegarcia@gmail.com>
In-Reply-To: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
References: <1346885323-15689-1-git-send-email-elezegarcia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ezequiel Garcia <elezegarcia@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

This patch cleans how we trace kmalloc and kmem_cache_alloc.
In particular, it fixes out-of-memory tracing: now every failed
allocation will trace reporting non-zero requested bytes, zero obtained bytes.

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>
---
 mm/slob.c |   30 ++++++++++++++++++------------
 1 files changed, 18 insertions(+), 12 deletions(-)

diff --git a/mm/slob.c b/mm/slob.c
index 3f4dc9a..73f16ca 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -428,6 +428,7 @@ static __always_inline void *
 __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 {
 	int align = max(ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
+	size_t alloc_size = 0;
 	void *ret;
 
 	gfp &= gfp_allowed_mask;
@@ -441,24 +442,25 @@ __do_kmalloc_node(size_t size, gfp_t gfp, int node, unsigned long caller)
 		ret = slob_alloc(size + align, gfp, align, node);
 
 		if (!ret)
-			return NULL;
+			goto trace_out;
 		*(unsigned int *)ret = size;
 		ret += align;
-
-		trace_kmalloc_node(caller, ret,
-				   size, size + align, gfp, node);
+		alloc_size = size + align;
 	} else {
 		unsigned int order = get_order(size);
 
 		if (likely(order))
 			gfp |= __GFP_COMP;
 		ret = slob_new_pages(gfp, order, node);
+		if (!ret)
+			goto trace_out;
 
-		trace_kmalloc_node(caller, ret,
-				   size, PAGE_SIZE << order, gfp, node);
+		alloc_size = PAGE_SIZE << order;
 	}
 
 	kmemleak_alloc(ret, size, 1, gfp);
+trace_out:
+	trace_kmalloc_node(caller, ret, size, alloc_size, gfp, node);
 	return ret;
 }
 
@@ -565,6 +567,7 @@ EXPORT_SYMBOL(kmem_cache_destroy);
 
 void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 {
+	size_t alloc_size = 0;
 	void *b;
 
 	flags &= gfp_allowed_mask;
@@ -573,20 +576,23 @@ void *kmem_cache_alloc_node(struct kmem_cache *c, gfp_t flags, int node)
 
 	if (c->size < PAGE_SIZE) {
 		b = slob_alloc(c->size, flags, c->align, node);
-		trace_kmem_cache_alloc_node(_RET_IP_, b, c->size,
-					    SLOB_UNITS(c->size) * SLOB_UNIT,
-					    flags, node);
+		if (!b)
+			goto trace_out;
+		alloc_size = SLOB_UNITS(c->size) * SLOB_UNIT;
 	} else {
 		b = slob_new_pages(flags, get_order(c->size), node);
-		trace_kmem_cache_alloc_node(_RET_IP_, b, c->size,
-					    PAGE_SIZE << get_order(c->size),
-					    flags, node);
+		if (!b)
+			goto trace_out;
+		alloc_size = PAGE_SIZE << get_order(c->size);
 	}
 
 	if (c->ctor)
 		c->ctor(b);
 
 	kmemleak_alloc_recursive(b, c->size, 1, c->flags, flags);
+trace_out:
+	trace_kmem_cache_alloc_node(_RET_IP_, b, c->size, alloc_size,
+				    flags, node);
 	return b;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
-- 
1.7.8.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
