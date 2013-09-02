Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 520CF6B0034
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 04:38:16 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/4] slab: introduce helper functions to get/set free object
Date: Mon,  2 Sep 2013 17:38:56 +0900
Message-Id: <1378111138-30340-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1378111138-30340-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <CAAmzW4N1GXbr18Ws9QDKg7ChN5RVcOW9eEv2RxWhaEoHtw=ctw@mail.gmail.com>
 <1378111138-30340-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In the following patches, to get/set free objects from the freelist
is changed so that simple casting doesn't work for it. Therefore,
introduce helper functions.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 9d4bad5..a0e49bb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2545,9 +2545,15 @@ static struct freelist *alloc_slabmgmt(struct kmem_cache *cachep,
 	return freelist;
 }
 
-static inline unsigned int *slab_freelist(struct page *page)
+static inline unsigned int get_free_obj(struct page *page, unsigned int idx)
 {
-	return (unsigned int *)(page->freelist);
+	return ((unsigned int *)page->freelist)[idx];
+}
+
+static inline void set_free_obj(struct page *page,
+					unsigned int idx, unsigned int val)
+{
+	((unsigned int *)(page->freelist))[idx] = val;
 }
 
 static void cache_init_objs(struct kmem_cache *cachep,
@@ -2592,7 +2598,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
 		if (cachep->ctor)
 			cachep->ctor(objp);
 #endif
-		slab_freelist(page)[i] = i;
+		set_free_obj(page, i, i);
 	}
 }
 
@@ -2611,7 +2617,7 @@ static void *slab_get_obj(struct kmem_cache *cachep, struct page *page,
 {
 	void *objp;
 
-	objp = index_to_obj(cachep, page, slab_freelist(page)[page->active]);
+	objp = index_to_obj(cachep, page, get_free_obj(page, page->active));
 	page->active++;
 #if DEBUG
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
@@ -2632,7 +2638,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
 
 	/* Verify double free bug */
 	for (i = page->active; i < cachep->num; i++) {
-		if (slab_freelist(page)[i] == objnr) {
+		if (get_free_obj(page, i) == objnr) {
 			printk(KERN_ERR "slab: double free detected in cache "
 					"'%s', objp %p\n", cachep->name, objp);
 			BUG();
@@ -2640,7 +2646,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
 	}
 #endif
 	page->active--;
-	slab_freelist(page)[page->active] = objnr;
+	set_free_obj(page, page->active, objnr);
 }
 
 /*
@@ -4214,7 +4220,7 @@ static void handle_slab(unsigned long *n, struct kmem_cache *c,
 
 		for (j = page->active; j < c->num; j++) {
 			/* Skip freed item */
-			if (slab_freelist(page)[j] == i) {
+			if (get_free_obj(page, j) == i) {
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
