Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 377E56B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 02:04:40 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id lj1so672002pab.14
        for <linux-mm@kvack.org>; Tue, 06 May 2014 23:04:39 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id bn5si1279513pbb.22.2014.05.06.23.04.37
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 23:04:38 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 03/10] slab: move up code to get kmem_cache_node in free_block()
Date: Wed,  7 May 2014 15:06:13 +0900
Message-Id: <1399442780-28748-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

node isn't changed, so we don't need to retreive this structure
everytime we move the object. Maybe compiler do this optimization,
but making it explicitly is better.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index e2c80df..92d08e3 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3340,7 +3340,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 		       int node)
 {
 	int i;
-	struct kmem_cache_node *n;
+	struct kmem_cache_node *n = cachep->node[node];
 
 	for (i = 0; i < nr_objects; i++) {
 		void *objp;
@@ -3349,7 +3349,6 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 		objp = clear_obj_pfmemalloc(objpp[i]);
 
 		page = virt_to_head_page(objp);
-		n = cachep->node[node];
 		list_del(&page->lru);
 		check_spinlock_acquired_node(cachep, node);
 		slab_put_obj(cachep, page, objp, node);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
