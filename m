Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 4BF5D6B003C
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:21 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 05/16] slab: remove cachep in struct slab_rcu
Date: Thu, 22 Aug 2013 17:44:14 +0900
Message-Id: <1377161065-30552-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can get cachep using page in struct slab_rcu, so remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 69dc25a..b378f91 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -204,7 +204,6 @@ typedef unsigned int kmem_bufctl_t;
  */
 struct slab_rcu {
 	struct rcu_head head;
-	struct kmem_cache *cachep;
 	struct page *page;
 };
 
@@ -1818,7 +1817,7 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 static void kmem_rcu_free(struct rcu_head *head)
 {
 	struct slab_rcu *slab_rcu = (struct slab_rcu *)head;
-	struct kmem_cache *cachep = slab_rcu->cachep;
+	struct kmem_cache *cachep = slab_rcu->page->slab_cache;
 
 	kmem_freepages(cachep, slab_rcu->page);
 	if (OFF_SLAB(cachep))
@@ -2046,7 +2045,6 @@ static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
 		struct slab_rcu *slab_rcu;
 
 		slab_rcu = (struct slab_rcu *)slabp;
-		slab_rcu->cachep = cachep;
 		slab_rcu->page = page;
 		call_rcu(&slab_rcu->head, kmem_rcu_free);
 	} else {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
