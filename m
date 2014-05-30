Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1F16B003B
	for <linux-mm@kvack.org>; Fri, 30 May 2014 09:51:19 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id pn19so1035542lab.34
        for <linux-mm@kvack.org>; Fri, 30 May 2014 06:51:18 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id l4si5606192laf.21.2014.05.30.06.51.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 May 2014 06:51:17 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 4/8] slub: never fail kmem_cache_shrink
Date: Fri, 30 May 2014 17:51:07 +0400
Message-ID: <ac8907cace921c3209aa821649349106f4f70b34.1401457502.git.vdavydov@parallels.com>
In-Reply-To: <cover.1401457502.git.vdavydov@parallels.com>
References: <cover.1401457502.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

SLUB's kmem_cache_shrink not only removes empty slabs from the cache,
but also sorts slabs by the number of objects in-use to cope with
fragmentation. To achieve that, it tries to allocate a temporary array.
If it fails, it will abort the whole procedure.

This is unacceptable for kmemcg, where we want to be sure that all empty
slabs are removed from the cache on memcg offline, so let's just skip
the de-fragmentation step if the allocation fails, but still get rid of
empty slabs.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slub.c |   39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index d96faa2464c3..d9976ea93710 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3404,12 +3404,16 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 	struct page *page;
 	struct page *t;
 	int objects = oo_objects(s->max);
-	struct list_head *slabs_by_inuse =
-		kmalloc(sizeof(struct list_head) * objects, GFP_KERNEL);
+	LIST_HEAD(empty_slabs);
+	struct list_head *slabs_by_inuse;
 	unsigned long flags;
 
-	if (!slabs_by_inuse)
-		return -ENOMEM;
+	slabs_by_inuse = kcalloc(objects - 1, sizeof(struct list_head),
+				 GFP_KERNEL);
+	if (slabs_by_inuse) {
+		for (i = 0; i < objects - 1; i++)
+			INIT_LIST_HEAD(slabs_by_inuse + i);
+	}
 
 	flush_all(s);
 	for_each_node_state(node, N_NORMAL_MEMORY) {
@@ -3418,9 +3422,6 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 		if (!n->nr_partial)
 			continue;
 
-		for (i = 0; i < objects; i++)
-			INIT_LIST_HEAD(slabs_by_inuse + i);
-
 		spin_lock_irqsave(&n->list_lock, flags);
 
 		/*
@@ -3430,22 +3431,28 @@ int __kmem_cache_shrink(struct kmem_cache *s)
 		 * list_lock. page->inuse here is the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			list_move(&page->lru, slabs_by_inuse + page->inuse);
-			if (!page->inuse)
+			if (!page->inuse) {
+				list_move(&page->lru, &empty_slabs);
 				n->nr_partial--;
+			} else if (slabs_by_inuse)
+				list_move(&page->lru,
+					  slabs_by_inuse + page->inuse - 1);
 		}
 
 		/*
 		 * Rebuild the partial list with the slabs filled up most
 		 * first and the least used slabs at the end.
 		 */
-		for (i = objects - 1; i > 0; i--)
-			list_splice(slabs_by_inuse + i, n->partial.prev);
+		if (slabs_by_inuse) {
+			for (i = objects - 2; i >= 0; i--)
+				list_splice_tail_init(slabs_by_inuse + i,
+						      &n->partial);
+		}
 
 		spin_unlock_irqrestore(&n->list_lock, flags);
 
 		/* Release empty slabs */
-		list_for_each_entry_safe(page, t, slabs_by_inuse, lru)
+		list_for_each_entry_safe(page, t, &empty_slabs, lru)
 			discard_slab(s, page);
 	}
 
@@ -4780,13 +4787,9 @@ static ssize_t shrink_show(struct kmem_cache *s, char *buf)
 static ssize_t shrink_store(struct kmem_cache *s,
 			const char *buf, size_t length)
 {
-	if (buf[0] == '1') {
-		int rc = kmem_cache_shrink(s);
-
-		if (rc)
-			return rc;
-	} else
+	if (buf[0] != '1')
 		return -EINVAL;
+	kmem_cache_shrink(s);
 	return length;
 }
 SLAB_ATTR(shrink);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
