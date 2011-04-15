Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 163F7900088
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 15:48:34 -0400 (EDT)
Message-Id: <20110415194830.839125394@linux.com>
Date: Fri, 15 Apr 2011 14:48:13 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [Slub cleanup6 2/5] slub: get_map() function to establish map of free objects in a slab
References: <20110415194811.810587216@linux.com>
Content-Disposition: inline; filename=slub_slowpath_get_map
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>

The bit map of free objects in a slab page is determined in various functions
if debugging is enabled.

Provide a common function for that purpose.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |   34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-03-30 14:09:27.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-03-30 14:30:24.000000000 -0500
@@ -271,10 +271,6 @@ static inline void set_freepointer(struc
 	for (__p = (__addr); __p < (__addr) + (__objects) * (__s)->size;\
 			__p += (__s)->size)
 
-/* Scan freelist */
-#define for_each_free_object(__p, __s, __free) \
-	for (__p = (__free); __p; __p = get_freepointer((__s), __p))
-
 /* Determine object index from a given position */
 static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
 {
@@ -330,6 +326,21 @@ static inline int oo_objects(struct kmem
 	return x.x & OO_MASK;
 }
 
+/*
+ * Determine a map of object in use on a page.
+ *
+ * Slab lock or node listlock must be held to guarantee that the page does
+ * not vanish from under us.
+ */
+static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
+{
+	void *p;
+	void *addr = page_address(page);
+
+	for (p = page->freelist; p; p = get_freepointer(s, p))
+		set_bit(slab_index(p, s, addr), map);
+}
+
 #ifdef CONFIG_SLUB_DEBUG
 /*
  * Debug settings:
@@ -2673,9 +2684,8 @@ static void list_slab_objects(struct kme
 		return;
 	slab_err(s, page, "%s", text);
 	slab_lock(page);
-	for_each_free_object(p, s, page->freelist)
-		set_bit(slab_index(p, s, addr), map);
 
+	get_map(s, page, map);
 	for_each_object(p, s, addr, page->objects) {
 
 		if (!test_bit(slab_index(p, s, addr), map)) {
@@ -3610,10 +3620,11 @@ static int validate_slab(struct kmem_cac
 	/* Now we know that a valid freelist exists */
 	bitmap_zero(map, page->objects);
 
-	for_each_free_object(p, s, page->freelist) {
-		set_bit(slab_index(p, s, addr), map);
-		if (!check_object(s, page, p, SLUB_RED_INACTIVE))
-			return 0;
+	get_map(s, page, map);
+	for_each_object(p, s, addr, page->objects) {
+		if (test_bit(slab_index(p, s, addr), map))
+			if (!check_object(s, page, p, SLUB_RED_INACTIVE))
+				return 0;
 	}
 
 	for_each_object(p, s, addr, page->objects)
@@ -3821,8 +3832,7 @@ static void process_slab(struct loc_trac
 	void *p;
 
 	bitmap_zero(map, page->objects);
-	for_each_free_object(p, s, page->freelist)
-		set_bit(slab_index(p, s, addr), map);
+	get_map(s, page, map);
 
 	for_each_object(p, s, addr, page->objects)
 		if (!test_bit(slab_index(p, s, addr), map))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
