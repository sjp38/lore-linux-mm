Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3515A6B0031
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 18:59:24 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so9414290pbc.29
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 15:59:23 -0700 (PDT)
From: Tim Bird <tim.bird@sonymobile.com>
Subject: [PATCH] slub: proper kmemleak tracking if CONFIG_SLUB_DEBUG disabled
Date: Tue, 8 Oct 2013 15:58:57 -0700
Message-ID: <1381273137-14680-1-git-send-email-tim.bird@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, catalin.marinas@arm.com, frowand.list@gmail.com, bjorn.andersson@sonymobile.com, tim.bird@sonymobile.com, tbird20d@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roman Bobniev <Roman.Bobniev@sonymobile.com>

From: Roman Bobniev <Roman.Bobniev@sonymobile.com>

Move all kmemleak calls into hook functions, and make it so
that all hooks (both inside and outside of #ifdef CONFIG_SLUB_DEBUG)
call the appropriate kmemleak routines.  This allows for kmemleak
to be configured independently of slub debug features.

It also fixes a bug where kmemleak was only partially enabled in some
configurations.

Signed-off-by: Roman Bobniev <Roman.Bobniev@sonymobile.com>
Signed-off-by: Tim Bird <tim.bird@sonymobile.com>
---
 mm/slub.c |   35 +++++++++++++++++++++++++++++++----
 1 file changed, 31 insertions(+), 4 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index c3eb3d3..0bb8591 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -933,6 +933,16 @@ static void trace(struct kmem_cache *s, struct page *page, void *object,
  * Hooks for other subsystems that check memory allocations. In a typical
  * production configuration these hooks all should produce no code at all.
  */
+static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
+{
+	kmemleak_alloc(ptr, size, 1, flags);
+}
+
+static inline void kfree_hook(const void *x)
+{
+	kmemleak_free(x);
+}
+
 static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
 {
 	flags &= gfp_allowed_mask;
@@ -1260,13 +1270,30 @@ static inline void inc_slabs_node(struct kmem_cache *s, int node,
 static inline void dec_slabs_node(struct kmem_cache *s, int node,
 							int objects) {}
 
+static inline void kmalloc_large_node_hook(void *ptr, size_t size, gfp_t flags)
+{
+	kmemleak_alloc(ptr, size, 1, flags);
+}
+
+static inline void kfree_hook(const void *x)
+{
+	kmemleak_free(x);
+}
+
 static inline int slab_pre_alloc_hook(struct kmem_cache *s, gfp_t flags)
 							{ return 0; }
 
 static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
-		void *object) {}
+		void *object)
+{
+	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags,
+		flags & gfp_allowed_mask);
+}
 
-static inline void slab_free_hook(struct kmem_cache *s, void *x) {}
+static inline void slab_free_hook(struct kmem_cache *s, void *x)
+{
+	kmemleak_free_recursive(x, s->flags);
+}
 
 #endif /* CONFIG_SLUB_DEBUG */
 
@@ -3272,7 +3299,7 @@ static void *kmalloc_large_node(size_t size, gfp_t flags, int node)
 	if (page)
 		ptr = page_address(page);
 
-	kmemleak_alloc(ptr, size, 1, flags);
+	kmalloc_large_node_hook(ptr, size, flags);
 	return ptr;
 }
 
@@ -3336,7 +3363,7 @@ void kfree(const void *x)
 	page = virt_to_head_page(x);
 	if (unlikely(!PageSlab(page))) {
 		BUG_ON(!PageCompound(page));
-		kmemleak_free(x);
+		kfree_hook(x);
 		__free_memcg_kmem_pages(page, compound_order(page));
 		return;
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
