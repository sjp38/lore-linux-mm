Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD5B6B0039
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:57:28 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id x10so11636394pdj.11
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:57:27 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id cb2si1827616pbb.244.2014.02.13.22.57.26
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 22:57:27 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/9] slab: move up code to get kmem_cache_node in free_block()
Date: Fri, 14 Feb 2014 15:57:17 +0900
Message-Id: <1392361043-22420-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

node isn't changed, so we don't need to retreive this structure
everytime we move the object. Maybe compiler do this optimization,
but making it explicitly is better.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 6d17cad..53d1a36 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3361,6 +3361,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 	int i;
 	struct kmem_cache_node *n;
 
+	n = cachep->node[node];
 	for (i = 0; i < nr_objects; i++) {
 		void *objp;
 		struct page *page;
@@ -3368,7 +3369,6 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
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
