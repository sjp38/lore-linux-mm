Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 871776B0062
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:44:25 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 16/16] slab: rename slab_bufctl to slab_freelist
Date: Thu, 22 Aug 2013 17:44:25 +0900
Message-Id: <1377161065-30552-17-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, bufctl is not proper name to this array.
So change it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 6abc069..e8ec4c5 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2538,7 +2538,7 @@ static struct freelist *alloc_slabmgmt(struct kmem_cache *cachep,
 	return freelist;
 }
 
-static inline unsigned int *slab_bufctl(struct page *page)
+static inline unsigned int *slab_freelist(struct page *page)
 {
 	return (unsigned int *)(page->freelist);
 }
@@ -2585,7 +2585,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
 		if (cachep->ctor)
 			cachep->ctor(objp);
 #endif
-		slab_bufctl(page)[i] = i;
+		slab_freelist(page)[i] = i;
 	}
 }
 
@@ -2604,7 +2604,7 @@ static void *slab_get_obj(struct kmem_cache *cachep, struct page *page,
 {
 	void *objp;
 
-	objp = index_to_obj(cachep, page, slab_bufctl(page)[page->active]);
+	objp = index_to_obj(cachep, page, slab_freelist(page)[page->active]);
 	page->active++;
 #if DEBUG
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
@@ -2625,7 +2625,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
 
 	/* Verify double free bug */
 	for (i = page->active; i < cachep->num; i++) {
-		if (slab_bufctl(page)[i] == objnr) {
+		if (slab_freelist(page)[i] == objnr) {
 			printk(KERN_ERR "slab: double free detected in cache "
 					"'%s', objp %p\n", cachep->name, objp);
 			BUG();
@@ -2633,7 +2633,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
 	}
 #endif
 	page->active--;
-	slab_bufctl(page)[page->active] = objnr;
+	slab_freelist(page)[page->active] = objnr;
 }
 
 /*
@@ -4207,7 +4207,7 @@ static void handle_slab(unsigned long *n, struct kmem_cache *c,
 
 		for (j = page->active; j < c->num; j++) {
 			/* Skip freed item */
-			if (slab_bufctl(page)[j] == i) {
+			if (slab_freelist(page)[j] == i) {
 				active = false;
 				break;
 			}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
