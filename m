Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 956676B0069
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 02:20:18 -0500 (EST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/3] slub: correct bootstrap() for kmem_cache, kmem_cache_node
Date: Tue, 15 Jan 2013 16:20:01 +0900
Message-Id: <1358234402-2615-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Current implementation of bootstrap() is not sufficient for kmem_cache
and kmem_cache_node.

First, for kmem_cache.
bootstrap() call kmem_cache_zalloc() at first. When kmem_cache_zalloc()
is called, kmem_cache's slab is moved to cpu slab for satisfying kmem_cache
allocation request. In current implementation, we only consider
n->partial slabs, so, we miss this cpu slab for kmem_cache.

Second, for kmem_cache_node.
When slab_state = PARTIAL, create_boot_cache() is called. And then,
kmem_cache_node's slab is moved to cpu slab for satisfying kmem_cache_node
allocation request. So, we also miss this slab.

These didn't make any error previously, because we normally don't free
objects which comes from kmem_cache's first slab and kmem_cache_node's.

Problem will be solved if we consider a cpu slab in bootstrap().
This patch implement it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slub.c b/mm/slub.c
index abef30e..830348b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3613,11 +3613,22 @@ static int slab_memory_callback(struct notifier_block *self,
 
 static struct kmem_cache * __init bootstrap(struct kmem_cache *static_cache)
 {
+	int cpu;
 	int node;
 	struct kmem_cache *s = kmem_cache_zalloc(kmem_cache, GFP_NOWAIT);
 
 	memcpy(s, static_cache, kmem_cache->object_size);
 
+	for_each_possible_cpu(cpu) {
+		struct kmem_cache_cpu *c;
+		struct page *p;
+
+		c = per_cpu_ptr(s->cpu_slab, cpu);
+		p = c->page;
+		if (p)
+			p->slab_cache = s;
+	}
+
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 		struct page *p;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
