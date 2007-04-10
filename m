From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070410032922.18967.18484.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070410032912.18967.67076.sendpatchset@schroedinger.engr.sgi.com>
References: <20070410032912.18967.67076.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 3/5] Fix object tracking
Date: Mon,  9 Apr 2007 20:29:22 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Object tracking did not work the right way for several call chains. Fix this up
by adding a new parameter to slub_alloc and slub_free that specifies the
caller address explicitly.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |  133 +++++++++++++++++++++++++++++---------------------------------
 1 file changed, 63 insertions(+), 70 deletions(-)

Index: linux-2.6.21-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-rc6-mm1.orig/mm/slub.c	2007-04-09 16:03:51.000000000 -0700
+++ linux-2.6.21-rc6-mm1/mm/slub.c	2007-04-09 16:06:47.000000000 -0700
@@ -246,9 +246,6 @@ static void set_track(struct kmem_cache 
 		memset(p, 0, sizeof(struct track));
 }
 
-#define set_tracking(__s, __o, __a) set_track(__s, __o, __a, \
-			__builtin_return_address(0))
-
 static void init_tracking(struct kmem_cache *s, void *object)
 {
 	if (s->flags & SLAB_STORE_USER) {
@@ -1107,8 +1104,8 @@ static void flush_all(struct kmem_cache 
  * Fastpath is not possible if we need to get a new slab or have
  * debugging enabled (which means all slabs are marked with PageError)
  */
-static __always_inline void *slab_alloc(struct kmem_cache *s,
-					gfp_t gfpflags, int node)
+static void *slab_alloc(struct kmem_cache *s,
+				gfp_t gfpflags, int node, void *addr)
 {
 	struct page *page;
 	void **object;
@@ -1189,20 +1186,20 @@ debug:
 	if (!alloc_object_checks(s, page, object))
 		goto another_slab;
 	if (s->flags & SLAB_STORE_USER)
-		set_tracking(s, object, TRACK_ALLOC);
+		set_track(s, object, TRACK_ALLOC, addr);
 	goto have_object;
 }
 
 void *kmem_cache_alloc(struct kmem_cache *s, gfp_t gfpflags)
 {
-	return slab_alloc(s, gfpflags, -1);
+	return slab_alloc(s, gfpflags, -1, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
 #ifdef CONFIG_NUMA
 void *kmem_cache_alloc_node(struct kmem_cache *s, gfp_t gfpflags, int node)
 {
-	return slab_alloc(s, gfpflags, node);
+	return slab_alloc(s, gfpflags, node, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(kmem_cache_alloc_node);
 #endif
@@ -1213,7 +1210,8 @@ EXPORT_SYMBOL(kmem_cache_alloc_node);
  *
  * No special cachelines need to be read
  */
-static void slab_free(struct kmem_cache *s, struct page *page, void *x)
+static void slab_free(struct kmem_cache *s, struct page *page,
+					void *x, void *addr)
 {
 	void *prior;
 	void **object = (void *)x;
@@ -1265,20 +1263,20 @@ slab_empty:
 	return;
 
 debug:
-	if (free_object_checks(s, page, x))
-		goto checks_ok;
-	goto out_unlock;
+	if (!free_object_checks(s, page, x))
+		goto out_unlock;
+	if (s->flags & SLAB_STORE_USER)
+		set_track(s, x, TRACK_FREE, addr);
+	goto checks_ok;
 }
 
 void kmem_cache_free(struct kmem_cache *s, void *x)
 {
-	struct page * page;
+	struct page *page;
 
 	page = virt_to_head_page(x);
 
-	if (unlikely(PageError(page) && (s->flags & SLAB_STORE_USER)))
-		set_tracking(s, x, TRACK_FREE);
-	slab_free(s, page, x);
+	slab_free(s, page, x, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
@@ -1836,7 +1834,7 @@ void *__kmalloc(size_t size, gfp_t flags
 	struct kmem_cache *s = get_slab(size, flags);
 
 	if (s)
-		return kmem_cache_alloc(s, flags);
+		return slab_alloc(s, flags, -1, __builtin_return_address(0));
 	return NULL;
 }
 EXPORT_SYMBOL(__kmalloc);
@@ -1847,7 +1845,7 @@ void *__kmalloc_node(size_t size, gfp_t 
 	struct kmem_cache *s = get_slab(size, flags);
 
 	if (s)
-		return kmem_cache_alloc_node(s, flags, node);
+		return slab_alloc(s, flags, node, __builtin_return_address(0));
 	return NULL;
 }
 EXPORT_SYMBOL(__kmalloc_node);
@@ -1893,12 +1891,9 @@ void kfree(const void *x)
 		return;
 
 	page = virt_to_head_page(x);
-
 	s = page->slab;
 
-	if (unlikely(PageError(page) && (s->flags & SLAB_STORE_USER)))
-		set_tracking(s, (void *)x, TRACK_FREE);
-	slab_free(s, page, (void *)x);
+	slab_free(s, page, (void *)x, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(kfree);
 
@@ -2098,7 +2093,7 @@ void *kmem_cache_zalloc(struct kmem_cach
 {
 	void *x;
 
-	x = kmem_cache_alloc(s, flags);
+	x = slab_alloc(s, flags, -1, __builtin_return_address(0));
 	if (x)
 		memset(x, 0, s->objsize);
 	return x;
@@ -2249,34 +2244,22 @@ __initcall(cpucache_init);
 void *__kmalloc_track_caller(size_t size, gfp_t gfpflags, void *caller)
 {
 	struct kmem_cache *s = get_slab(size, gfpflags);
-	void *object;
 
 	if (!s)
 		return NULL;
 
-	object = kmem_cache_alloc(s, gfpflags);
-
-	if (object && (s->flags & SLAB_STORE_USER))
-		set_track(s, object, TRACK_ALLOC, caller);
-
-	return object;
+	return slab_alloc(s, gfpflags, -1, caller);
 }
 
 void *__kmalloc_node_track_caller(size_t size, gfp_t gfpflags,
 					int node, void *caller)
 {
 	struct kmem_cache *s = get_slab(size, gfpflags);
-	void *object;
 
 	if (!s)
 		return NULL;
 
-	object = kmem_cache_alloc_node(s, gfpflags, node);
-
-	if (object && (s->flags & SLAB_STORE_USER))
-		set_track(s, object, TRACK_ALLOC, caller);
-
-	return object;
+	return slab_alloc(s, gfpflags, node, caller);
 }
 
 #ifdef CONFIG_SYSFS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
