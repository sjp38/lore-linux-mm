Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id C319E6B0037
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 03:47:27 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so17451429pdj.23
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 00:47:27 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id d5si19553623pac.57.2013.12.02.00.47.25
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 00:47:26 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 2/5] slab: introduce helper functions to get/set free object
Date: Mon,  2 Dec 2013 17:49:40 +0900
Message-Id: <1385974183-31423-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In the following patches, to get/set free objects from the freelist
is changed so that simple casting doesn't work for it. Therefore,
introduce helper functions.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index e749f75..77f9eae 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2548,9 +2548,15 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
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
@@ -2595,7 +2601,7 @@ static void cache_init_objs(struct kmem_cache *cachep,
 		if (cachep->ctor)
 			cachep->ctor(objp);
 #endif
-		slab_freelist(page)[i] = i;
+		set_free_obj(page, i, i);
 	}
 }
 
@@ -2614,7 +2620,7 @@ static void *slab_get_obj(struct kmem_cache *cachep, struct page *page,
 {
 	void *objp;
 
-	objp = index_to_obj(cachep, page, slab_freelist(page)[page->active]);
+	objp = index_to_obj(cachep, page, get_free_obj(page, page->active));
 	page->active++;
 #if DEBUG
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
@@ -2635,7 +2641,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
 
 	/* Verify double free bug */
 	for (i = page->active; i < cachep->num; i++) {
-		if (slab_freelist(page)[i] == objnr) {
+		if (get_free_obj(page, i) == objnr) {
 			printk(KERN_ERR "slab: double free detected in cache "
 					"'%s', objp %p\n", cachep->name, objp);
 			BUG();
@@ -2643,7 +2649,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
 	}
 #endif
 	page->active--;
-	slab_freelist(page)[page->active] = objnr;
+	set_free_obj(page, page->active, objnr);
 }
 
 /*
@@ -4216,7 +4222,7 @@ static void handle_slab(unsigned long *n, struct kmem_cache *c,
 
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
