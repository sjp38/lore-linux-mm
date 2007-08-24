Date: Fri, 24 Aug 2007 11:50:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: SLUB: Accurately compare debug flags during slab cache merge
In-Reply-To: <200708241804.l7OI4u4T007741@imap1.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708241129300.22511@schroedinger.engr.sgi.com>
References: <200708241804.l7OI4u4T007741@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@davemloft.net
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


SLUB: Accurately compare debug flags during slab cache merge

Currently we simply add the debug flags unconditional when checking for a 
matching slab cache. This can create issues for sysfs processing when 
slabs exist that are exempt from debugging due to their huge size or 
because only a subset of slabs was selected for debugging.

We need to only add the debug flags if kmem_cache_open() would also add 
them.

Create a function kmem_cache_flags() to calculate the flags to set on a 
slab cache and use kmem_cache_flags() to determine the flags 
in find_mergeable_slab().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   37 ++++++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 15 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2007-08-24 11:14:02.000000000 -0700
+++ linux-2.6/mm/slub.c	2007-08-24 11:38:43.000000000 -0700
@@ -986,7 +986,9 @@ out:
 
 __setup("slub_debug", setup_slub_debug);
 
-static void kmem_cache_open_debug_check(struct kmem_cache *s)
+static unsigned long kmem_cache_flags(unsigned long objsize,
+	unsigned long flags, const char *name,
+	void (*ctor)(void *, struct kmem_cache *, unsigned long))
 {
 	/*
 	 * The page->offset field is only 16 bit wide. This is an offset
@@ -1000,19 +1002,20 @@ static void kmem_cache_open_debug_check(
 	 * Debugging or ctor may create a need to move the free
 	 * pointer. Fail if this happens.
 	 */
-	if (s->objsize >= 65535 * sizeof(void *)) {
-		BUG_ON(s->flags & (SLAB_RED_ZONE | SLAB_POISON |
+	if (objsize >= 65535 * sizeof(void *)) {
+		BUG_ON(flags & (SLAB_RED_ZONE | SLAB_POISON |
 				SLAB_STORE_USER | SLAB_DESTROY_BY_RCU));
-		BUG_ON(s->ctor);
-	}
-	else
+		BUG_ON(ctor);
+	} else
 		/*
 		 * Enable debugging if selected on the kernel commandline.
 		 */
 		if (slub_debug && (!slub_debug_slabs ||
-		    strncmp(slub_debug_slabs, s->name,
+		    strncmp(slub_debug_slabs, name,
 		    	strlen(slub_debug_slabs)) == 0))
-				s->flags |= slub_debug;
+				flags |= slub_debug;
+
+	return flags;
 }
 #else
 static inline void setup_object_debug(struct kmem_cache *s,
@@ -1029,7 +1032,12 @@ static inline int slab_pad_check(struct 
 static inline int check_object(struct kmem_cache *s, struct page *page,
 			void *object, int active) { return 1; }
 static inline void add_full(struct kmem_cache_node *n, struct page *page) {}
-static inline void kmem_cache_open_debug_check(struct kmem_cache *s) {}
+static unsigned long kmem_cache_flags(unsigned long objsize,
+	unsigned long flags, const char *name,
+	void (*ctor)(void *, struct kmem_cache *, unsigned long))
+{
+	return flags;
+}
 #define slub_debug 0
 #endif
 /*
@@ -2081,9 +2089,8 @@ static int kmem_cache_open(struct kmem_c
 	s->name = name;
 	s->ctor = ctor;
 	s->objsize = size;
-	s->flags = flags;
 	s->align = align;
-	kmem_cache_open_debug_check(s);
+	s->flags = kmem_cache_flags(size, flags, name, ctor);
 
 	if (!calculate_sizes(s))
 		goto error;
@@ -2653,7 +2660,7 @@ static int slab_unmergeable(struct kmem_
 }
 
 static struct kmem_cache *find_mergeable(size_t size,
-		size_t align, unsigned long flags,
+		size_t align, unsigned long flags, const char *name,
 		void (*ctor)(void *, struct kmem_cache *, unsigned long))
 {
 	struct kmem_cache *s;
@@ -2667,6 +2674,7 @@ static struct kmem_cache *find_mergeable
 	size = ALIGN(size, sizeof(void *));
 	align = calculate_alignment(flags, align, size);
 	size = ALIGN(size, align);
+	flags = kmem_cache_flags(size, flags, name, NULL);
 
 	list_for_each_entry(s, &slab_caches, list) {
 		if (slab_unmergeable(s))
@@ -2675,8 +2683,7 @@ static struct kmem_cache *find_mergeable
 		if (size > s->size)
 			continue;
 
-		if (((flags | slub_debug) & SLUB_MERGE_SAME) !=
-			(s->flags & SLUB_MERGE_SAME))
+		if ((flags & SLUB_MERGE_SAME) != (s->flags & SLUB_MERGE_SAME))
 				continue;
 		/*
 		 * Check if alignment is compatible.
@@ -2700,7 +2707,7 @@ struct kmem_cache *kmem_cache_create(con
 	struct kmem_cache *s;
 
 	down_write(&slub_lock);
-	s = find_mergeable(size, align, flags, ctor);
+	s = find_mergeable(size, align, flags, name, ctor);
 	if (s) {
 		s->refcount++;
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
