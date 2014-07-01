Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A7B796B0039
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 04:22:34 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fb1so10154208pad.14
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 01:22:34 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id xa8si16747250pab.3.2014.07.01.01.22.32
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 01:22:33 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 2/9] slab: move up code to get kmem_cache_node in free_block()
Date: Tue,  1 Jul 2014 17:27:31 +0900
Message-Id: <1404203258-8923-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

node isn't changed, so we don't need to retreive this structure
everytime we move the object. Maybe compiler do this optimization,
but making it explicitly is better.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index f8a0ed1..19e2136 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3417,7 +3417,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 		       int node)
 {
 	int i;
-	struct kmem_cache_node *n;
+	struct kmem_cache_node *n = get_node(cachep, node);
 
 	for (i = 0; i < nr_objects; i++) {
 		void *objp;
@@ -3427,7 +3427,6 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 		objp = objpp[i];
 
 		page = virt_to_head_page(objp);
-		n = get_node(cachep, node);
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
