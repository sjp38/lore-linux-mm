Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E0D806B003B
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 04:44:19 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so748567pab.17
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 01:44:19 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 05/15] slab: remove cachep in struct slab_rcu
Date: Wed, 16 Oct 2013 17:44:02 +0900
Message-Id: <1381913052-23875-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can get cachep using page in struct slab_rcu, so remove it.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 71ba8f5..7e1aabe 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -204,7 +204,6 @@ typedef unsigned int kmem_bufctl_t;
  */
 struct slab_rcu {
 	struct rcu_head head;
-	struct kmem_cache *cachep;
 	struct page *page;
 };
 
@@ -1824,7 +1823,7 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 static void kmem_rcu_free(struct rcu_head *head)
 {
 	struct slab_rcu *slab_rcu = (struct slab_rcu *)head;
-	struct kmem_cache *cachep = slab_rcu->cachep;
+	struct kmem_cache *cachep = slab_rcu->page->slab_cache;
 
 	kmem_freepages(cachep, slab_rcu->page);
 	if (OFF_SLAB(cachep))
@@ -2052,7 +2051,6 @@ static void slab_destroy(struct kmem_cache *cachep, struct slab *slabp)
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
