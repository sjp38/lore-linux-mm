Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9816B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 08:28:59 -0400 (EDT)
Received: by mail-lb0-f177.google.com with SMTP id u10so305992lbd.8
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 05:28:58 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id td2si265505lbb.50.2014.06.24.05.28.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jun 2014 05:28:57 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm] slab: set free_limit for dead caches to 0
Date: Tue, 24 Jun 2014 16:28:36 +0400
Message-ID: <1403612916-26655-1-git-send-email-vdavydov@parallels.com>
In-Reply-To: <20140624072554.GB4836@js1304-P5Q-DELUXE>
References: <20140624072554.GB4836@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: iamjoonsoo.kim@lge.com, cl@linux.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

We mustn't keep empty slabs on dead memcg caches, because otherwise they
will never be destroyed.

Currently, we check if the cache is dead in free_block and drop empty
slab if so irrespective of the node's free_limit. This can be pretty
expensive. So let's avoid this additional check by zeroing nodes'
free_limit for dead caches on kmem_cache_shrink. This way no additional
overhead is added to free hot path.

Note, since ->free_limit can be updated on cpu/memory hotplug, we must
handle it properly there.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |   24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b35bf2120b96..6009e44a4d1d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1155,11 +1155,13 @@ static int init_cache_node_node(int node)
 			cachep->node[node] = n;
 		}
 
-		spin_lock_irq(&n->list_lock);
-		n->free_limit =
-			(1 + nr_cpus_node(node)) *
-			cachep->batchcount + cachep->num;
-		spin_unlock_irq(&n->list_lock);
+		if (!memcg_cache_dead(cachep)) {
+			spin_lock_irq(&n->list_lock);
+			n->free_limit =
+				(1 + nr_cpus_node(node)) *
+				cachep->batchcount + cachep->num;
+			spin_unlock_irq(&n->list_lock);
+		}
 	}
 	return 0;
 }
@@ -1193,7 +1195,8 @@ static void cpuup_canceled(long cpu)
 		spin_lock_irq(&n->list_lock);
 
 		/* Free limit for this kmem_cache_node */
-		n->free_limit -= cachep->batchcount;
+		if (!memcg_cache_dead(cachep))
+			n->free_limit -= cachep->batchcount;
 		if (nc)
 			free_block(cachep, nc->entry, nc->avail, node);
 
@@ -2544,6 +2547,12 @@ int __kmem_cache_shrink(struct kmem_cache *cachep)
 
 	check_irq_on();
 	for_each_kmem_cache_node(cachep, node, n) {
+		if (memcg_cache_dead(cachep)) {
+			spin_lock_irq(&n->list_lock);
+			n->free_limit = 0;
+			spin_unlock_irq(&n->list_lock);
+		}
+
 		drain_freelist(cachep, n, slabs_tofree(cachep, n));
 
 		ret += !list_empty(&n->slabs_full) ||
@@ -3426,8 +3435,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 
 		/* fixup slab chains */
 		if (page->active == 0) {
-			if (n->free_objects > n->free_limit ||
-			    memcg_cache_dead(cachep)) {
+			if (n->free_objects > n->free_limit) {
 				n->free_objects -= cachep->num;
 				/* No need to drop any previously held
 				 * lock here, even if we have a off-slab slab
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
