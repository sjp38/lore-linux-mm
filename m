Message-Id: <20070507212409.659872065@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:50 -0700
From: clameter@sgi.com
Subject: [patch 10/17] SLUB: Add macros for scanning objects in a slab
Content-Disposition: inline; filename=for_each_object
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Scanning of objects happens in a number of functions. Consolidate that code.
DECLARE_BITMAP instead of coding the declaration for bitmaps.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/slub.c |   75 ++++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 44 insertions(+), 31 deletions(-)

Index: slub/mm/slub.c
===================================================================
--- slub.orig/mm/slub.c	2007-05-07 13:54:26.000000000 -0700
+++ slub/mm/slub.c	2007-05-07 13:54:31.000000000 -0700
@@ -211,6 +211,38 @@ static inline struct kmem_cache_node *ge
 }
 
 /*
+ * Slow version of get and set free pointer.
+ *
+ * This version requires touching the cache lines of kmem_cache which
+ * we avoid to do in the fast alloc free paths. There we obtain the offset
+ * from the page struct.
+ */
+static inline void *get_freepointer(struct kmem_cache *s, void *object)
+{
+	return *(void **)(object + s->offset);
+}
+
+static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
+{
+	*(void **)(object + s->offset) = fp;
+}
+
+/* Loop over all objects in a slab */
+#define for_each_object(__p, __s, __addr) \
+	for (__p = (__addr); __p < (__addr) + (__s)->objects * (__s)->size;\
+			__p += (__s)->size)
+
+/* Scan freelist */
+#define for_each_free_object(__p, __s, __free) \
+	for (__p = (__free); __p; __p = get_freepointer((__s), __p))
+
+/* Determine object index from a given position */
+static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
+{
+	return (p - addr) / s->size;
+}
+
+/*
  * Object debugging
  */
 static void print_section(char *text, u8 *addr, unsigned int length)
@@ -246,23 +278,6 @@ static void print_section(char *text, u8
 }
 
 /*
- * Slow version of get and set free pointer.
- *
- * This version requires touching the cache lines of kmem_cache which
- * we avoid to do in the fast alloc free paths. There we obtain the offset
- * from the page struct.
- */
-static void *get_freepointer(struct kmem_cache *s, void *object)
-{
-	return *(void **)(object + s->offset);
-}
-
-static void set_freepointer(struct kmem_cache *s, void *object, void *fp)
-{
-	*(void **)(object + s->offset) = fp;
-}
-
-/*
  * Tracking user of a slab.
  */
 struct track {
@@ -854,7 +869,7 @@ static struct page *new_slab(struct kmem
 		memset(start, POISON_INUSE, PAGE_SIZE << s->order);
 
 	last = start;
-	for (p = start + s->size; p < end; p += s->size) {
+	for_each_object(p, s, start) {
 		setup_object(s, page, last);
 		set_freepointer(s, last, p);
 		last = p;
@@ -875,12 +890,10 @@ static void __free_slab(struct kmem_cach
 	int pages = 1 << s->order;
 
 	if (unlikely(PageError(page) || s->dtor)) {
-		void *start = page_address(page);
-		void *end = start + (pages << PAGE_SHIFT);
 		void *p;
 
 		slab_pad_check(s, page);
-		for (p = start; p <= end - s->size; p += s->size) {
+		for_each_object(p, s, page_address(page)) {
 			if (s->dtor)
 				s->dtor(p, s, 0);
 			check_object(s, page, p, 0);
@@ -2516,7 +2529,7 @@ static int validate_slab(struct kmem_cac
 {
 	void *p;
 	void *addr = page_address(page);
-	unsigned long map[BITS_TO_LONGS(s->objects)];
+	DECLARE_BITMAP(map, s->objects);
 
 	if (!check_slab(s, page) ||
 			!on_freelist(s, page, NULL))
@@ -2525,14 +2538,14 @@ static int validate_slab(struct kmem_cac
 	/* Now we know that a valid freelist exists */
 	bitmap_zero(map, s->objects);
 
-	for(p = page->freelist; p; p = get_freepointer(s, p)) {
-		set_bit((p - addr) / s->size, map);
+	for_each_free_object(p, s, page->freelist) {
+		set_bit(slab_index(p, s, addr), map);
 		if (!check_object(s, page, p, 0))
 			return 0;
 	}
 
-	for(p = addr; p < addr + s->objects * s->size; p += s->size)
-		if (!test_bit((p - addr) / s->size, map))
+	for_each_object(p, s, addr)
+		if (!test_bit(slab_index(p, s, addr), map))
 			if (!check_object(s, page, p, 1))
 				return 0;
 	return 1;
@@ -2704,15 +2717,15 @@ static void process_slab(struct loc_trac
 		struct page *page, enum track_item alloc)
 {
 	void *addr = page_address(page);
-	unsigned long map[BITS_TO_LONGS(s->objects)];
+	DECLARE_BITMAP(map, s->objects);
 	void *p;
 
 	bitmap_zero(map, s->objects);
-	for (p = page->freelist; p; p = get_freepointer(s, p))
-		set_bit((p - addr) / s->size, map);
+	for_each_free_object(p, s, page->freelist)
+		set_bit(slab_index(p, s, addr), map);
 
-	for (p = addr; p < addr + s->objects * s->size; p += s->size)
-		if (!test_bit((p - addr) / s->size, map)) {
+	for_each_object(p, s, addr)
+		if (!test_bit(slab_index(p, s, addr), map)) {
 			void *addr = get_track(s, p, alloc)->addr;
 
 			add_location(t, s, addr);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
