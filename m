Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B6DEF828E2
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:24:40 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id q63so96343836pfb.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:40 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id fa4si6898270pab.87.2016.01.13.21.24.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:24:40 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 65so6923223pff.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:40 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 04/16] mm/slab: activate debug_pagealloc in SLAB when it is actually enabled
Date: Thu, 14 Jan 2016 14:24:17 +0900
Message-Id: <1452749069-15334-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index bbe4df2..4b55516 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1838,7 +1838,8 @@ static void slab_destroy_debugcheck(struct kmem_cache *cachep,
 
 		if (cachep->flags & SLAB_POISON) {
 #ifdef CONFIG_DEBUG_PAGEALLOC
-			if (cachep->size % PAGE_SIZE == 0 &&
+			if (debug_pagealloc_enabled() &&
+				cachep->size % PAGE_SIZE == 0 &&
 					OFF_SLAB(cachep))
 				kernel_map_pages(virt_to_page(objp),
 					cachep->size / PAGE_SIZE, 1);
@@ -2176,7 +2177,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 	 * to check size >= 256. It guarantees that all necessary small
 	 * sized slab is initialized in current slab initialization sequence.
 	 */
-	if (!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
+	if (debug_pagealloc_enabled() &&
+		!slab_early_init && size >= kmalloc_size(INDEX_NODE) &&
 		size >= 256 && cachep->object_size > cache_line_size() &&
 		ALIGN(size, cachep->align) < PAGE_SIZE) {
 		cachep->obj_offset += PAGE_SIZE - ALIGN(size, cachep->align);
@@ -2232,7 +2234,8 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		 * poisoning, then it's going to smash the contents of
 		 * the redzone and userword anyhow, so switch them off.
 		 */
-		if (size % PAGE_SIZE == 0 && flags & SLAB_POISON)
+		if (debug_pagealloc_enabled() &&
+			size % PAGE_SIZE == 0 && flags & SLAB_POISON)
 			flags &= ~(SLAB_RED_ZONE | SLAB_STORE_USER);
 #endif
 	}
@@ -2716,7 +2719,8 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 	set_obj_status(page, objnr, OBJECT_FREE);
 	if (cachep->flags & SLAB_POISON) {
 #ifdef CONFIG_DEBUG_PAGEALLOC
-		if ((cachep->size % PAGE_SIZE)==0 && OFF_SLAB(cachep)) {
+		if (debug_pagealloc_enabled() &&
+			(cachep->size % PAGE_SIZE) == 0 && OFF_SLAB(cachep)) {
 			store_stackinfo(cachep, objp, caller);
 			kernel_map_pages(virt_to_page(objp),
 					 cachep->size / PAGE_SIZE, 0);
@@ -2861,7 +2865,8 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 		return objp;
 	if (cachep->flags & SLAB_POISON) {
 #ifdef CONFIG_DEBUG_PAGEALLOC
-		if ((cachep->size % PAGE_SIZE) == 0 && OFF_SLAB(cachep))
+		if (debug_pagealloc_enabled() &&
+			(cachep->size % PAGE_SIZE) == 0 && OFF_SLAB(cachep))
 			kernel_map_pages(virt_to_page(objp),
 					 cachep->size / PAGE_SIZE, 1);
 		else
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
