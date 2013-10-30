Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA986B0036
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 06:03:57 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id q10so751832pdj.28
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 03:03:56 -0700 (PDT)
Received: from psmtp.com ([74.125.245.114])
        by mx.google.com with SMTP id ai2si1438110pad.30.2013.10.30.03.03.53
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 03:03:56 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 17/15] slab: replace non-existing 'struct freelist *' with 'void *'
Date: Wed, 30 Oct 2013 19:04:01 +0900
Message-Id: <1383127441-30563-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1383127441-30563-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1383127441-30563-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is no 'strcut freelist', but codes use pointer to 'struct freelist'.
Although compiler doesn't complain anything about this wrong usage and
codes work fine, but fixing it is better.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index a8a9349..a983e30 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1954,7 +1954,7 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
  */
 static void slab_destroy(struct kmem_cache *cachep, struct page *page)
 {
-	struct freelist *freelist;
+	void *freelist;
 
 	freelist = page->freelist;
 	slab_destroy_debugcheck(cachep, page);
@@ -2520,11 +2520,11 @@ int __kmem_cache_shutdown(struct kmem_cache *cachep)
  * kmem_find_general_cachep till the initialization is complete.
  * Hence we cannot have freelist_cache same as the original cache.
  */
-static struct freelist *alloc_slabmgmt(struct kmem_cache *cachep,
+static void *alloc_slabmgmt(struct kmem_cache *cachep,
 				   struct page *page, int colour_off,
 				   gfp_t local_flags, int nodeid)
 {
-	struct freelist *freelist;
+	void *freelist;
 	void *addr = page_address(page);
 
 	if (OFF_SLAB(cachep)) {
@@ -2646,7 +2646,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
  * virtual address for kfree, ksize, and slab debugging.
  */
 static void slab_map_pages(struct kmem_cache *cache, struct page *page,
-			   struct freelist *freelist)
+			   void *freelist)
 {
 	page->slab_cache = cache;
 	page->freelist = freelist;
@@ -2659,7 +2659,7 @@ static void slab_map_pages(struct kmem_cache *cache, struct page *page,
 static int cache_grow(struct kmem_cache *cachep,
 		gfp_t flags, int nodeid, struct page *page)
 {
-	struct freelist *freelist;
+	void *freelist;
 	size_t offset;
 	gfp_t local_flags;
 	struct kmem_cache_node *n;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
