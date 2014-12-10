Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id CDED36B0075
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:30:40 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id i50so2337204qgf.2
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:30:40 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id f67si5355517qga.115.2014.12.10.08.30.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:30:37 -0800 (PST)
Message-Id: <20141210163033.612898004@linux.com>
Date: Wed, 10 Dec 2014 10:30:19 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 2/7] slub: Use page-mapping to store address of page frame like done in SLAB
References: <20141210163017.092096069@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=page_address
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

SLAB uses the mapping field of the page struct to store a pointer to the
begining of the objects in the page frame. Use the same field to store
the address of the objects in SLUB as well. This allows us to avoid a
number of invocations of page_address(). Those are mostly only used for
debugging though so this should have no performance benefit.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/include/linux/mm_types.h
===================================================================
--- linux.orig/include/linux/mm_types.h	2014-12-09 12:23:37.374266835 -0600
+++ linux/include/linux/mm_types.h	2014-12-09 12:23:37.370266955 -0600
@@ -54,6 +54,7 @@ struct page {
 						 * see PAGE_MAPPING_ANON below.
 						 */
 		void *s_mem;			/* slab first object */
+		void *address;			/* slub address of page */
 	};
 
 	/* Second double word */
Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-12-09 12:23:37.374266835 -0600
+++ linux/mm/slub.c	2014-12-09 12:23:37.370266955 -0600
@@ -232,7 +232,7 @@ static inline int check_valid_pointer(st
 	if (!object)
 		return 1;
 
-	base = page_address(page);
+	base = page->address;
 	if (object < base || object >= base + page->objects * s->size ||
 		(object - base) % s->size) {
 		return 0;
@@ -449,7 +449,7 @@ static inline bool cmpxchg_double_slab(s
 static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
 {
 	void *p;
-	void *addr = page_address(page);
+	void *addr = page->address;
 
 	for (p = page->freelist; p; p = get_freepointer(s, p))
 		set_bit(slab_index(p, s, addr), map);
@@ -596,7 +596,7 @@ static void slab_fix(struct kmem_cache *
 static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 {
 	unsigned int off;	/* Offset of last byte */
-	u8 *addr = page_address(page);
+	u8 *addr = page->address;
 
 	print_tracking(s, p);
 
@@ -763,7 +763,7 @@ static int slab_pad_check(struct kmem_ca
 	if (!(s->flags & SLAB_POISON))
 		return 1;
 
-	start = page_address(page);
+	start = page->address;
 	length = (PAGE_SIZE << compound_order(page)) - s->reserved;
 	end = start + length;
 	remainder = length % s->size;
@@ -1387,11 +1387,12 @@ static struct page *new_slab(struct kmem
 	order = compound_order(page);
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab_cache = s;
+	page->address = page_address(page);
 	__SetPageSlab(page);
 	if (page->pfmemalloc)
 		SetPageSlabPfmemalloc(page);
 
-	start = page_address(page);
+	start = page->address;
 
 	if (unlikely(s->flags & SLAB_POISON))
 		memset(start, POISON_INUSE, PAGE_SIZE << order);
@@ -1420,7 +1421,7 @@ static void __free_slab(struct kmem_cach
 		void *p;
 
 		slab_pad_check(s, page);
-		for_each_object(p, s, page_address(page),
+		for_each_object(p, s, page->address,
 						page->objects)
 			check_object(s, page, p, SLUB_RED_INACTIVE);
 	}
@@ -1433,9 +1434,10 @@ static void __free_slab(struct kmem_cach
 		-pages);
 
 	__ClearPageSlabPfmemalloc(page);
-	__ClearPageSlab(page);
 
 	page_mapcount_reset(page);
+	page->mapping = NULL;
+	__ClearPageSlab(page);
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
 	__free_pages(page, order);
@@ -1467,7 +1469,7 @@ static void free_slab(struct kmem_cache
 			int offset = (PAGE_SIZE << order) - s->reserved;
 
 			VM_BUG_ON(s->reserved != sizeof(*head));
-			head = page_address(page) + offset;
+			head = page->address + offset;
 		} else {
 			/*
 			 * RCU free overloads the RCU head over the LRU
@@ -3135,7 +3137,7 @@ static void list_slab_objects(struct kme
 							const char *text)
 {
 #ifdef CONFIG_SLUB_DEBUG
-	void *addr = page_address(page);
+	void *addr = page->address;
 	void *p;
 	unsigned long *map = kzalloc(BITS_TO_LONGS(page->objects) *
 				     sizeof(long), GFP_ATOMIC);
@@ -3775,7 +3777,7 @@ static int validate_slab(struct kmem_cac
 						unsigned long *map)
 {
 	void *p;
-	void *addr = page_address(page);
+	void *addr = page->address;
 
 	if (!check_slab(s, page) ||
 			!on_freelist(s, page, NULL))
@@ -3986,7 +3988,7 @@ static void process_slab(struct loc_trac
 		struct page *page, enum track_item alloc,
 		unsigned long *map)
 {
-	void *addr = page_address(page);
+	void *addr = page->address;
 	void *p;
 
 	bitmap_zero(map, page->objects);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
