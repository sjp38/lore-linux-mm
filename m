Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 7923B6B0039
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:21 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 06/16] slab: put forward freeing slab management object
Date: Thu, 22 Aug 2013 17:44:15 +0900
Message-Id: <1377161065-30552-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We don't need to free slab management object in rcu context,
because, from now on, we don't manage this slab anymore.
So put forward freeing.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index b378f91..607a9b8 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1820,8 +1820,6 @@ static void kmem_rcu_free(struct rcu_head *head)
 	struct kmem_cache *cachep = slab_rcu->page->slab_cache;
 
 	kmem_freepages(cachep, slab_rcu->page);
-	if (OFF_SLAB(cachep))
-		kmem_cache_free(cachep->slabp_cache, slab_rcu);
 }
 
 #if DEBUG
@@ -2047,11 +2045,16 @@ static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
 		slab_rcu = (struct slab_rcu *)slabp;
 		slab_rcu->page = page;
 		call_rcu(&slab_rcu->head, kmem_rcu_free);
-	} else {
+
+	} else
 		kmem_freepages(cachep, page);
-		if (OFF_SLAB(cachep))
-			kmem_cache_free(cachep->slabp_cache, slabp);
-	}
+
+	/*
+	 * From now on, we don't use slab management
+	 * although actual page will be freed in rcu context.
+	 */
+	if (OFF_SLAB(cachep))
+		kmem_cache_free(cachep->slabp_cache, slabp);
 }
 
 /**
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
