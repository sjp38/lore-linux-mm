Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6C56B0265
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 01:27:31 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id fe3so90066997pab.1
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:27:31 -0700 (PDT)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id oq6si157194pab.84.2016.03.27.22.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Mar 2016 22:27:30 -0700 (PDT)
Received: by mail-pf0-x22d.google.com with SMTP id u190so129232592pfb.3
        for <linux-mm@kvack.org>; Sun, 27 Mar 2016 22:27:30 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 06/11] mm/slab: don't keep free slabs if free_objects exceeds free_limit
Date: Mon, 28 Mar 2016 14:26:56 +0900
Message-Id: <1459142821-20303-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, determination to free a slab is done whenever free object is
put into the slab. This has a problem that free slabs are not freed
even if we have free slabs and have more free_objects than free_limit
when processed slab isn't a free slab. This would cause to keep
too much memory in the slab subsystem. This patch try to fix it
by checking number of free object after all free work is done. If there
is free slab at that time, we can free it so we keep free slab as minimal
as possible.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b96f381..df11757 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3258,6 +3258,9 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 {
 	int i;
 	struct kmem_cache_node *n = get_node(cachep, node);
+	struct page *page;
+
+	n->free_objects += nr_objects;
 
 	for (i = 0; i < nr_objects; i++) {
 		void *objp;
@@ -3270,17 +3273,11 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
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
@@ -3288,6 +3285,14 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
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
