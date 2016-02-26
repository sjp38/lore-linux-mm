Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 47C7F6B0009
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 23:36:12 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fl4so44219522pad.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 20:36:12 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id uj7si17052333pab.111.2016.02.25.20.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 20:36:11 -0800 (PST)
Received: by mail-pf0-x22e.google.com with SMTP id x65so45126682pfb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 20:36:11 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2] mm/slub: support left redzone
Date: Fri, 26 Feb 2016 13:36:01 +0900
Message-Id: <1456461361-4345-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

SLUB already has a redzone debugging feature.  But it is only positioned
at the end of object (aka right redzone) so it cannot catch left oob.
Although current object's right redzone acts as left redzone of next
object, first object in a slab cannot take advantage of this effect.  This
patch explicitly adds a left red zone to each object to detect left oob
more precisely.

Background:

Someone complained to me that left OOB isn't catched even if KASAN is
enabled which does page allocation debugging.  That page is out of our
control so it would be allocated when left OOB happens and, in this
case, we can't find OOB.  Moreover, SLUB debugging feature can be
enabled without page allocator debugging and, in this case, we will
miss that OOB.

Before trying to implement, I expected that changes would be too
complex, but, it doesn't look that complex to me now.  Almost changes
are applied to debug specific functions so I feel okay.

v2: fixes per Christoph
o move red_left_pad field to after the non debugging fields.
o make for_each_object(_idx) handle red_left_pad
o remove KASAN dependcy which is incorrect

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/slub_def.h |   1 +
 mm/slub.c                | 100 +++++++++++++++++++++++++++++++++--------------
 2 files changed, 72 insertions(+), 29 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index b7e57927..ac5143f 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -81,6 +81,7 @@ struct kmem_cache {
 	int reserved;		/* Reserved bytes at the end of slabs */
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
+	int red_left_pad;	/* Left redzone padding size */
 #ifdef CONFIG_SYSFS
 	struct kobject kobj;	/* For sysfs */
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index d0fae13..94ff285 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -124,6 +124,14 @@ static inline int kmem_cache_debug(struct kmem_cache *s)
 #endif
 }
 
+static inline void *fixup_red_left(struct kmem_cache *s, void *p)
+{
+	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE)
+		p += s->red_left_pad;
+
+	return p;
+}
+
 static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 {
 #ifdef CONFIG_SLUB_CPU_PARTIAL
@@ -232,24 +240,6 @@ static inline void stat(const struct kmem_cache *s, enum stat_item si)
  * 			Core slab cache functions
  *******************************************************************/
 
-/* Verify that a pointer has an address that is valid within a slab page */
-static inline int check_valid_pointer(struct kmem_cache *s,
-				struct page *page, const void *object)
-{
-	void *base;
-
-	if (!object)
-		return 1;
-
-	base = page_address(page);
-	if (object < base || object >= base + page->objects * s->size ||
-		(object - base) % s->size) {
-		return 0;
-	}
-
-	return 1;
-}
-
 static inline void *get_freepointer(struct kmem_cache *s, void *object)
 {
 	return *(void **)(object + s->offset);
@@ -278,12 +268,14 @@ static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
 
 /* Loop over all objects in a slab */
 #define for_each_object(__p, __s, __addr, __objects) \
-	for (__p = (__addr); __p < (__addr) + (__objects) * (__s)->size;\
-			__p += (__s)->size)
+	for (__p = fixup_red_left(__s, __addr); \
+		__p < (__addr) + (__objects) * (__s)->size; \
+		__p += (__s)->size)
 
 #define for_each_object_idx(__p, __idx, __s, __addr, __objects) \
-	for (__p = (__addr), __idx = 1; __idx <= __objects;\
-			__p += (__s)->size, __idx++)
+	for (__p = fixup_red_left(__s, __addr), __idx = 1; \
+		__idx <= __objects; \
+		__p += (__s)->size, __idx++)
 
 /* Determine object index from a given position */
 static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
@@ -441,6 +433,22 @@ static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
 		set_bit(slab_index(p, s, addr), map);
 }
 
+static inline int size_from_object(struct kmem_cache *s)
+{
+	if (s->flags & SLAB_RED_ZONE)
+		return s->size - s->red_left_pad;
+
+	return s->size;
+}
+
+static inline void *restore_red_left(struct kmem_cache *s, void *p)
+{
+	if (s->flags & SLAB_RED_ZONE)
+		p -= s->red_left_pad;
+
+	return p;
+}
+
 /*
  * Debug settings:
  */
@@ -474,6 +482,26 @@ static inline void metadata_access_disable(void)
 /*
  * Object debugging
  */
+
+/* Verify that a pointer has an address that is valid within a slab page */
+static inline int check_valid_pointer(struct kmem_cache *s,
+				struct page *page, void *object)
+{
+	void *base;
+
+	if (!object)
+		return 1;
+
+	base = page_address(page);
+	object = restore_red_left(s, object);
+	if (object < base || object >= base + page->objects * s->size ||
+		(object - base) % s->size) {
+		return 0;
+	}
+
+	return 1;
+}
+
 static void print_section(char *text, u8 *addr, unsigned int length)
 {
 	metadata_access_enable();
@@ -613,7 +641,9 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 	pr_err("INFO: Object 0x%p @offset=%tu fp=0x%p\n\n",
 	       p, p - addr, get_freepointer(s, p));
 
-	if (p > addr + 16)
+	if (s->flags & SLAB_RED_ZONE)
+		print_section("Redzone ", p - s->red_left_pad, s->red_left_pad);
+	else if (p > addr + 16)
 		print_section("Bytes b4 ", p - 16, 16);
 
 	print_section("Object ", p, min_t(unsigned long, s->object_size,
@@ -630,9 +660,9 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 	if (s->flags & SLAB_STORE_USER)
 		off += 2 * sizeof(struct track);
 
-	if (off != s->size)
+	if (off != size_from_object(s))
 		/* Beginning of the filler is the free pointer */
-		print_section("Padding ", p + off, s->size - off);
+		print_section("Padding ", p + off, size_from_object(s) - off);
 
 	dump_stack();
 }
@@ -662,6 +692,9 @@ static void init_object(struct kmem_cache *s, void *object, u8 val)
 {
 	u8 *p = object;
 
+	if (s->flags & SLAB_RED_ZONE)
+		memset(p - s->red_left_pad, val, s->red_left_pad);
+
 	if (s->flags & __OBJECT_POISON) {
 		memset(p, POISON_FREE, s->object_size - 1);
 		p[s->object_size - 1] = POISON_END;
@@ -754,11 +787,11 @@ static int check_pad_bytes(struct kmem_cache *s, struct page *page, u8 *p)
 		/* We also have user information there */
 		off += 2 * sizeof(struct track);
 
-	if (s->size == off)
+	if (size_from_object(s) == off)
 		return 1;
 
 	return check_bytes_and_report(s, page, p, "Object padding",
-				p + off, POISON_INUSE, s->size - off);
+			p + off, POISON_INUSE, size_from_object(s) - off);
 }
 
 /* Check the pad bytes at the end of a slab page */
@@ -803,6 +836,10 @@ static int check_object(struct kmem_cache *s, struct page *page,
 
 	if (s->flags & SLAB_RED_ZONE) {
 		if (!check_bytes_and_report(s, page, object, "Redzone",
+			object - s->red_left_pad, val, s->red_left_pad))
+			return 0;
+
+		if (!check_bytes_and_report(s, page, object, "Redzone",
 			endobject, val, s->inuse - s->object_size))
 			return 0;
 	} else {
@@ -1444,7 +1481,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 			set_freepointer(s, p, NULL);
 	}
 
-	page->freelist = start;
+	page->freelist = fixup_red_left(s, start);
 	page->inuse = page->objects;
 	page->frozen = 1;
 
@@ -3274,7 +3311,7 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 		 */
 		size += 2 * sizeof(struct track);
 
-	if (flags & SLAB_RED_ZONE)
+	if (flags & SLAB_RED_ZONE) {
 		/*
 		 * Add some empty padding so that we can catch
 		 * overwrites from earlier objects rather than let
@@ -3283,6 +3320,11 @@ static int calculate_sizes(struct kmem_cache *s, int forced_order)
 		 * of the object.
 		 */
 		size += sizeof(void *);
+
+		s->red_left_pad = sizeof(void *);
+		s->red_left_pad = ALIGN(s->red_left_pad, s->align);
+		size += s->red_left_pad;
+	}
 #endif
 
 	/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
