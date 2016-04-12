Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5AA876B0262
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:51:49 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id c20so6240401pfc.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:49 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id qd3si7917566pab.208.2016.04.11.21.51.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 21:51:48 -0700 (PDT)
Received: by mail-pa0-x22c.google.com with SMTP id bx7so6044787pad.3
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 21:51:48 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v2 06/11] mm/slab: don't keep free slabs if free_objects exceeds free_limit
Date: Tue, 12 Apr 2016 13:51:01 +0900
Message-Id: <1460436666-20462-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1460436666-20462-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, determination to free a slab is done whenever each freed
object is put into the slab. This has a following problem.

Assume free_limit = 10 and nr_free = 9.

Free happens as following sequence and nr_free changes as following.

free(become a free slab) free(not become a free slab)
nr_free: 9 -> 10 (at first free) -> 11 (at second free)

If we try to check if we can free current slab or not on each object free,
we can't free any slab in this situation because current slab isn't
a free slab when nr_free exceed free_limit (at second free) even if
there is a free slab.

However, if we check it lastly, we can free 1 free slab.

This problem would cause to keep too much memory in the slab subsystem.
This patch try to fix it by checking number of free object after
all free work is done. If there is free slab at that time, we can
free slab as much as possible so we keep free slab as minimal.

v2: explain more about the problem

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 27cb390..6e61461 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3283,6 +3283,9 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 {
 	int i;
 	struct kmem_cache_node *n = get_node(cachep, node);
+	struct page *page;
+
+	n->free_objects += nr_objects;
 
 	for (i = 0; i < nr_objects; i++) {
 		void *objp;
@@ -3295,17 +3298,11 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 		check_spinlock_acquired_node(cachep, node);
 		slab_put_obj(cachep, page, objp);
 		STATS_DEC_ACTIVE(cachep);
-		n->free_objects++;
 
 		/* fixup slab chains */
-		if (page->active == 0) {
-			if (n->free_objects > n->free_limit) {
-				n->free_objects -= cachep->num;
-				list_add_tail(&page->lru, list);
-			} else {
-				list_add(&page->lru, &n->slabs_free);
-			}
-		} else {
+		if (page->active == 0)
+			list_add(&page->lru, &n->slabs_free);
+		else {
 			/* Unconditionally move a slab to the end of the
 			 * partial list on free - maximum time for the
 			 * other objects to be freed, too.
@@ -3313,6 +3310,14 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 			list_add_tail(&page->lru, &n->slabs_partial);
 		}
 	}
+
+	while (n->free_objects > n->free_limit && !list_empty(&n->slabs_free)) {
+		n->free_objects -= cachep->num;
+
+		page = list_last_entry(&n->slabs_free, struct page, lru);
+		list_del(&page->lru);
+		list_add(&page->lru, list);
+	}
 }
 
 static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
