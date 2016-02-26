Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 93895828E1
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 01:01:46 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id e127so46382621pfe.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:46 -0800 (PST)
Received: from mail-pf0-x22a.google.com (mail-pf0-x22a.google.com. [2607:f8b0:400e:c00::22a])
        by mx.google.com with ESMTPS id lu9si685862pab.215.2016.02.25.22.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 22:01:45 -0800 (PST)
Received: by mail-pf0-x22a.google.com with SMTP id q63so46291478pfb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 22:01:45 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 04/17] mm/slab: activate debug_pagealloc in SLAB when it is actually enabled
Date: Fri, 26 Feb 2016 15:01:11 +0900
Message-Id: <1456466484-3442-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1456466484-3442-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 mm/slab.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 14c3f9c..4807cf4 100644
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
