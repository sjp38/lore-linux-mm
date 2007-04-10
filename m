From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070410032917.18967.55114.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070410032912.18967.67076.sendpatchset@schroedinger.engr.sgi.com>
References: <20070410032912.18967.67076.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 2/5] Use enum for tracking modes instead of integers
Date: Mon,  9 Apr 2007 20:29:17 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Use enum for tracking modes instead of integers.

Integers caused some confusion. This cleans it up and uses symbolic constants
throughout.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-rc6-mm1.orig/mm/slub.c	2007-04-09 15:30:59.000000000 -0700
+++ linux-2.6.21-rc6-mm1/mm/slub.c	2007-04-09 15:32:10.000000000 -0700
@@ -211,7 +211,10 @@ struct track {
 	unsigned long when;	/* When did the operation occur */
 };
 
-struct track *get_track(struct kmem_cache *s, void *object, int alloc)
+enum track_item { TRACK_ALLOC, TRACK_FREE };
+
+struct track *get_track(struct kmem_cache *s, void *object,
+	enum track_item alloc)
 {
 	struct track *p;
 
@@ -224,7 +227,7 @@ struct track *get_track(struct kmem_cach
 }
 
 static void set_track(struct kmem_cache *s, void *object,
-				int alloc, void *addr)
+				enum track_item alloc, void *addr)
 {
 	struct track *p;
 
@@ -249,8 +252,8 @@ static void set_track(struct kmem_cache 
 static void init_tracking(struct kmem_cache *s, void *object)
 {
 	if (s->flags & SLAB_STORE_USER) {
-		set_track(s, object, 0, NULL);
-		set_track(s, object, 1, NULL);
+		set_track(s, object, TRACK_FREE, NULL);
+		set_track(s, object, TRACK_ALLOC, NULL);
 	}
 }
 
@@ -298,8 +301,8 @@ static void print_trailer(struct kmem_ca
 		off = s->inuse;
 
 	if (s->flags & SLAB_STORE_USER) {
-		print_track("Last alloc", get_track(s, p, 0));
-		print_track("Last free ", get_track(s, p, 1));
+		print_track("Last alloc", get_track(s, p, TRACK_ALLOC));
+		print_track("Last free ", get_track(s, p, TRACK_FREE));
 		off += 2 * sizeof(struct track);
 	}
 
@@ -1186,7 +1189,7 @@ debug:
 	if (!alloc_object_checks(s, page, object))
 		goto another_slab;
 	if (s->flags & SLAB_STORE_USER)
-		set_tracking(s, object, 0);
+		set_tracking(s, object, TRACK_ALLOC);
 	goto have_object;
 }
 
@@ -1274,7 +1277,7 @@ void kmem_cache_free(struct kmem_cache *
 	page = virt_to_head_page(x);
 
 	if (unlikely(PageError(page) && (s->flags & SLAB_STORE_USER)))
-		set_tracking(s, x, 1);
+		set_tracking(s, x, TRACK_FREE);
 	slab_free(s, page, x);
 }
 EXPORT_SYMBOL(kmem_cache_free);
@@ -1894,7 +1897,7 @@ void kfree(const void *x)
 	s = page->slab;
 
 	if (unlikely(PageError(page) && (s->flags & SLAB_STORE_USER)))
-		set_tracking(s, (void *)x, 1);
+		set_tracking(s, (void *)x, TRACK_FREE);
 	slab_free(s, page, (void *)x);
 }
 EXPORT_SYMBOL(kfree);
@@ -2254,7 +2257,7 @@ void *__kmalloc_track_caller(size_t size
 	object = kmem_cache_alloc(s, gfpflags);
 
 	if (object && (s->flags & SLAB_STORE_USER))
-		set_track(s, object, 0, caller);
+		set_track(s, object, TRACK_ALLOC, caller);
 
 	return object;
 }
@@ -2271,7 +2274,7 @@ void *__kmalloc_node_track_caller(size_t
 	object = kmem_cache_alloc_node(s, gfpflags, node);
 
 	if (object && (s->flags & SLAB_STORE_USER))
-		set_track(s, object, 0, caller);
+		set_track(s, object, TRACK_ALLOC, caller);
 
 	return object;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
