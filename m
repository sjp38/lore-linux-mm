Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7E1FB8D0041
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 22:28:08 -0400 (EDT)
Message-ID: <20110316022805.27719.qmail@science.horizon.com>
From: George Spelvin <linux@horizon.com>
Date: Mon, 14 Mar 2011 22:22:14 -0400
Subject: [PATCH 6/8] mm/slub: Remove unnecessary parameter
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, mpm@selenic.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@horizon.com

setup_object() does not need the page pointer.
It's a private static function, so no API changes whatsoever.
---
 mm/slub.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 856246f..3a20b71 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -878,8 +878,7 @@ static inline void dec_slabs_node(struct kmem_cache *s, int node, int objects)
 }
 
 /* Object debug checks for alloc/free paths */
-static void setup_object_debug(struct kmem_cache *s, struct page *page,
-								void *object)
+static void setup_object_debug(struct kmem_cache *s, void *object)
 {
 	if (!(s->flags & (SLAB_STORE_USER|SLAB_RED_ZONE|__OBJECT_POISON)))
 		return;
@@ -1060,8 +1059,7 @@ static unsigned long kmem_cache_flags(unsigned long objsize,
 	return flags;
 }
 #else
-static inline void setup_object_debug(struct kmem_cache *s,
-			struct page *page, void *object) {}
+static inline void setup_object_debug(struct kmem_cache *s, void *object) {}
 
 static inline int alloc_debug_processing(struct kmem_cache *s,
 	struct page *page, void *object, unsigned long addr) { return 0; }
@@ -1175,10 +1173,9 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	return page;
 }
 
-static void setup_object(struct kmem_cache *s, struct page *page,
-				void *object)
+static void setup_object(struct kmem_cache *s, void *object)
 {
-	setup_object_debug(s, page, object);
+	setup_object_debug(s, object);
 	if (unlikely(s->ctor))
 		s->ctor(object);
 }
@@ -1208,11 +1205,11 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 
 	last = start;
 	for_each_object(p, s, start, page->objects) {
-		setup_object(s, page, last);
+		setup_object(s, last);
 		set_freepointer(s, last, p);
 		last = p;
 	}
-	setup_object(s, page, last);
+	setup_object(s, last);
 	set_freepointer(s, last, NULL);
 
 	page->freelist = start;
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
