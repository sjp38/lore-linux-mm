Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id A20706B0038
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 04:09:31 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so13532528pdj.2
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 01:09:31 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id x3si16640617pde.134.2014.08.21.01.09.26
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 01:09:30 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 5/5] mm/slab: factor out unlikely part of cache_free_alien()
Date: Thu, 21 Aug 2014 17:09:22 +0900
Message-Id: <1408608562-20339-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1408608562-20339-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

cache_free_alien() is rarely used function when node mismatch. But,
it is defined with inline attribute so it is inlined to __cache_free()
which is core free function of slab allocator. It uselessly makes
kmem_cache_free()/kfree() functions large. What we really need to
inline is just checking node match so this patch factor out other
parts of cache_free_alien() to reduce code size of kmem_cache_free()/
kfree().

<Before>
nm -S mm/slab.o | grep -e "T kfree" -e "T kmem_cache_free"
00000000000011e0 0000000000000228 T kfree
0000000000000670 0000000000000216 T kmem_cache_free

<After>
nm -S mm/slab.o | grep -e "T kfree" -e "T kmem_cache_free"
0000000000001110 00000000000001b5 T kfree
0000000000000750 0000000000000181 T kmem_cache_free

You can see slightly reduced size of text: 0x228->0x1b5, 0x216->0x181.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |   38 +++++++++++++++++++++-----------------
 1 file changed, 21 insertions(+), 17 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index c9f137f..5927a17 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -984,46 +984,50 @@ static void drain_alien_cache(struct kmem_cache *cachep,
 	}
 }
 
-static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
+static int __cache_free_alien(struct kmem_cache *cachep, void *objp,
+				int node, int page_node)
 {
-	int nodeid = page_to_nid(virt_to_page(objp));
 	struct kmem_cache_node *n;
 	struct alien_cache *alien = NULL;
 	struct array_cache *ac;
-	int node;
 	LIST_HEAD(list);
 
-	node = numa_mem_id();
-
-	/*
-	 * Make sure we are not freeing a object from another node to the array
-	 * cache on this cpu.
-	 */
-	if (likely(nodeid == node))
-		return 0;
-
 	n = get_node(cachep, node);
 	STATS_INC_NODEFREES(cachep);
-	if (n->alien && n->alien[nodeid]) {
-		alien = n->alien[nodeid];
+	if (n->alien && n->alien[page_node]) {
+		alien = n->alien[page_node];
 		ac = &alien->ac;
 		spin_lock(&alien->lock);
 		if (unlikely(ac->avail == ac->limit)) {
 			STATS_INC_ACOVERFLOW(cachep);
-			__drain_alien_cache(cachep, ac, nodeid, &list);
+			__drain_alien_cache(cachep, ac, page_node, &list);
 		}
 		ac_put_obj(cachep, ac, objp);
 		spin_unlock(&alien->lock);
 		slabs_destroy(cachep, &list);
 	} else {
-		n = get_node(cachep, nodeid);
+		n = get_node(cachep, page_node);
 		spin_lock(&n->list_lock);
-		free_block(cachep, &objp, 1, nodeid, &list);
+		free_block(cachep, &objp, 1, page_node, &list);
 		spin_unlock(&n->list_lock);
 		slabs_destroy(cachep, &list);
 	}
 	return 1;
 }
+
+static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
+{
+	int page_node = page_to_nid(virt_to_page(objp));
+	int node = numa_mem_id();
+	/*
+	 * Make sure we are not freeing a object from another node to the array
+	 * cache on this cpu.
+	 */
+	if (likely(node == page_node))
+		return 0;
+
+	return __cache_free_alien(cachep, objp, node, page_node);
+}
 #endif
 
 /*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
