Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id C18D66B025F
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:51:38 -0400 (EDT)
Received: by mail-pf0-f178.google.com with SMTP id c20so6237463pfc.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:38 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id t24si7647440pfi.39.2016.04.11.21.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 21:51:38 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id bx7so6042058pad.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:38 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 03/11] mm/slab: drain the free slab as much as possible
Date: Tue, 12 Apr 2016 13:50:58 +0900
Message-Id: <1460436666-20462-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

slabs_tofree() implies freeing all free slab. We can do it with
just providing INT_MAX.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 373b8be..5451929 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -888,12 +888,6 @@ static int init_cache_node_node(int node)
 	return 0;
 }
 
-static inline int slabs_tofree(struct kmem_cache *cachep,
-						struct kmem_cache_node *n)
-{
-	return (n->free_objects + cachep->num - 1) / cachep->num;
-}
-
 static void cpuup_canceled(long cpu)
 {
 	struct kmem_cache *cachep;
@@ -958,7 +952,7 @@ free_slab:
 		n = get_node(cachep, node);
 		if (!n)
 			continue;
-		drain_freelist(cachep, n, slabs_tofree(cachep, n));
+		drain_freelist(cachep, n, INT_MAX);
 	}
 }
 
@@ -1110,7 +1104,7 @@ static int __meminit drain_cache_node_node(int node)
 		if (!n)
 			continue;
 
-		drain_freelist(cachep, n, slabs_tofree(cachep, n));
+		drain_freelist(cachep, n, INT_MAX);
 
 		if (!list_empty(&n->slabs_full) ||
 		    !list_empty(&n->slabs_partial)) {
@@ -2304,7 +2298,7 @@ int __kmem_cache_shrink(struct kmem_cache *cachep, bool deactivate)
 
 	check_irq_on();
 	for_each_kmem_cache_node(cachep, node, n) {
-		drain_freelist(cachep, n, slabs_tofree(cachep, n));
+		drain_freelist(cachep, n, INT_MAX);
 
 		ret += !list_empty(&n->slabs_full) ||
 			!list_empty(&n->slabs_partial);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
