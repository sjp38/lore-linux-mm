Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id C765E6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:36:24 -0400 (EDT)
Message-Id: <20120514201609.418025254@linux.com>
Date: Mon, 14 May 2012 15:15:45 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC] SL[AUO]B common code 1/9] [slob] define page struct fields used in mm_types.h
References: <20120514201544.334122849@linux.com>
Content-Disposition: inline; filename=slob_use_page_struct
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>

Define the fields used by slob in mm_types.h and use struct page instead
of struct slob_page in slob. This cleans up a lot of typecasts in slob.c and
makes readers aware of slob's use of page struct fields.

[Also cleans up some bitrot in slob.c. The page struct field layout
in slob.c is an old layout and does not match the one in mm_types.h]

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/mm_types.h |    5 +-
 mm/slob.c                |  105 ++++++++++++++++++-----------------------------
 2 files changed, 45 insertions(+), 65 deletions(-)

Index: linux-2.6/mm/slob.c
===================================================================
--- linux-2.6.orig/mm/slob.c	2012-04-11 07:07:16.672129272 -0500
+++ linux-2.6/mm/slob.c	2012-04-11 07:12:34.344122598 -0500
@@ -92,33 +92,12 @@ struct slob_block {
 typedef struct slob_block slob_t;
 
 /*
- * We use struct page fields to manage some slob allocation aspects,
- * however to avoid the horrible mess in include/linux/mm_types.h, we'll
- * just define our own struct page type variant here.
- */
-struct slob_page {
-	union {
-		struct {
-			unsigned long flags;	/* mandatory */
-			atomic_t _count;	/* mandatory */
-			slobidx_t units;	/* free units left in page */
-			unsigned long pad[2];
-			slob_t *free;		/* first free slob_t in page */
-			struct list_head list;	/* linked list of free pages */
-		};
-		struct page page;
-	};
-};
-static inline void struct_slob_page_wrong_size(void)
-{ BUILD_BUG_ON(sizeof(struct slob_page) != sizeof(struct page)); }
-
-/*
  * free_slob_page: call before a slob_page is returned to the page allocator.
  */
-static inline void free_slob_page(struct slob_page *sp)
+static inline void free_slob_page(struct page *sp)
 {
-	reset_page_mapcount(&sp->page);
-	sp->page.mapping = NULL;
+	reset_page_mapcount(sp);
+	sp->mapping = NULL;
 }
 
 /*
@@ -133,44 +112,44 @@ static LIST_HEAD(free_slob_large);
 /*
  * is_slob_page: True for all slob pages (false for bigblock pages)
  */
-static inline int is_slob_page(struct slob_page *sp)
+static inline int is_slob_page(struct page *sp)
 {
-	return PageSlab((struct page *)sp);
+	return PageSlab(sp);
 }
 
-static inline void set_slob_page(struct slob_page *sp)
+static inline void set_slob_page(struct page *sp)
 {
-	__SetPageSlab((struct page *)sp);
+	__SetPageSlab(sp);
 }
 
-static inline void clear_slob_page(struct slob_page *sp)
+static inline void clear_slob_page(struct page *sp)
 {
-	__ClearPageSlab((struct page *)sp);
+	__ClearPageSlab(sp);
 }
 
-static inline struct slob_page *slob_page(const void *addr)
+static inline struct page *slob_page(const void *addr)
 {
-	return (struct slob_page *)virt_to_page(addr);
+	return virt_to_page(addr);
 }
 
 /*
  * slob_page_free: true for pages on free_slob_pages list.
  */
-static inline int slob_page_free(struct slob_page *sp)
+static inline int slob_page_free(struct page *sp)
 {
-	return PageSlobFree((struct page *)sp);
+	return PageSlobFree(sp);
 }
 
-static void set_slob_page_free(struct slob_page *sp, struct list_head *list)
+static void set_slob_page_free(struct page *sp, struct list_head *list)
 {
-	list_add(&sp->list, list);
-	__SetPageSlobFree((struct page *)sp);
+	list_add(&sp->lru, list);
+	__SetPageSlobFree(sp);
 }
 
-static inline void clear_slob_page_free(struct slob_page *sp)
+static inline void clear_slob_page_free(struct page *sp)
 {
-	list_del(&sp->list);
-	__ClearPageSlobFree((struct page *)sp);
+	list_del(&sp->lru);
+	__ClearPageSlobFree(sp);
 }
 
 #define SLOB_UNIT sizeof(slob_t)
@@ -267,12 +246,12 @@ static void slob_free_pages(void *b, int
 /*
  * Allocate a slob block within a given slob_page sp.
  */
-static void *slob_page_alloc(struct slob_page *sp, size_t size, int align)
+static void *slob_page_alloc(struct page *sp, size_t size, int align)
 {
 	slob_t *prev, *cur, *aligned = NULL;
 	int delta = 0, units = SLOB_UNITS(size);
 
-	for (prev = NULL, cur = sp->free; ; prev = cur, cur = slob_next(cur)) {
+	for (prev = NULL, cur = sp->freelist; ; prev = cur, cur = slob_next(cur)) {
 		slobidx_t avail = slob_units(cur);
 
 		if (align) {
@@ -296,12 +275,12 @@ static void *slob_page_alloc(struct slob
 				if (prev)
 					set_slob(prev, slob_units(prev), next);
 				else
-					sp->free = next;
+					sp->freelist = next;
 			} else { /* fragment */
 				if (prev)
 					set_slob(prev, slob_units(prev), cur + units);
 				else
-					sp->free = cur + units;
+					sp->freelist = cur + units;
 				set_slob(cur + units, avail - units, next);
 			}
 
@@ -320,7 +299,7 @@ static void *slob_page_alloc(struct slob
  */
 static void *slob_alloc(size_t size, gfp_t gfp, int align, int node)
 {
-	struct slob_page *sp;
+	struct page *sp;
 	struct list_head *prev;
 	struct list_head *slob_list;
 	slob_t *b = NULL;
@@ -335,13 +314,13 @@ static void *slob_alloc(size_t size, gfp
 
 	spin_lock_irqsave(&slob_lock, flags);
 	/* Iterate through each partially free page, try to find room */
-	list_for_each_entry(sp, slob_list, list) {
+	list_for_each_entry(sp, slob_list, lru) {
 #ifdef CONFIG_NUMA
 		/*
 		 * If there's a node specification, search for a partial
 		 * page with a matching node id in the freelist.
 		 */
-		if (node != -1 && page_to_nid(&sp->page) != node)
+		if (node != -1 && page_to_nid(sp) != node)
 			continue;
 #endif
 		/* Enough room on this page? */
@@ -349,7 +328,7 @@ static void *slob_alloc(size_t size, gfp
 			continue;
 
 		/* Attempt to alloc */
-		prev = sp->list.prev;
+		prev = sp->lru.prev;
 		b = slob_page_alloc(sp, size, align);
 		if (!b)
 			continue;
@@ -374,8 +353,8 @@ static void *slob_alloc(size_t size, gfp
 
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
-		sp->free = b;
-		INIT_LIST_HEAD(&sp->list);
+		sp->freelist = b;
+		INIT_LIST_HEAD(&sp->lru);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
 		b = slob_page_alloc(sp, size, align);
@@ -392,7 +371,7 @@ static void *slob_alloc(size_t size, gfp
  */
 static void slob_free(void *block, int size)
 {
-	struct slob_page *sp;
+	struct page *sp;
 	slob_t *prev, *next, *b = (slob_t *)block;
 	slobidx_t units;
 	unsigned long flags;
@@ -421,7 +400,7 @@ static void slob_free(void *block, int s
 	if (!slob_page_free(sp)) {
 		/* This slob page is about to become partially free. Easy! */
 		sp->units = units;
-		sp->free = b;
+		sp->freelist = b;
 		set_slob(b, units,
 			(void *)((unsigned long)(b +
 					SLOB_UNITS(PAGE_SIZE)) & PAGE_MASK));
@@ -441,15 +420,15 @@ static void slob_free(void *block, int s
 	 */
 	sp->units += units;
 
-	if (b < sp->free) {
-		if (b + units == sp->free) {
-			units += slob_units(sp->free);
-			sp->free = slob_next(sp->free);
+	if (b < (slob_t *)sp->freelist) {
+		if (b + units == sp->freelist) {
+			units += slob_units(sp->freelist);
+			sp->freelist = slob_next(sp->freelist);
 		}
-		set_slob(b, units, sp->free);
-		sp->free = b;
+		set_slob(b, units, sp->freelist);
+		sp->freelist = b;
 	} else {
-		prev = sp->free;
+		prev = sp->freelist;
 		next = slob_next(prev);
 		while (b > next) {
 			prev = next;
@@ -522,7 +501,7 @@ EXPORT_SYMBOL(__kmalloc_node);
 
 void kfree(const void *block)
 {
-	struct slob_page *sp;
+	struct page *sp;
 
 	trace_kfree(_RET_IP_, block);
 
@@ -536,14 +515,14 @@ void kfree(const void *block)
 		unsigned int *m = (unsigned int *)(block - align);
 		slob_free(m, *m + align);
 	} else
-		put_page(&sp->page);
+		put_page(sp);
 }
 EXPORT_SYMBOL(kfree);
 
 /* can't use ksize for kmem_cache_alloc memory, only kmalloc */
 size_t ksize(const void *block)
 {
-	struct slob_page *sp;
+	struct page *sp;
 
 	BUG_ON(!block);
 	if (unlikely(block == ZERO_SIZE_PTR))
@@ -555,7 +534,7 @@ size_t ksize(const void *block)
 		unsigned int *m = (unsigned int *)(block - align);
 		return SLOB_UNITS(*m) * SLOB_UNIT;
 	} else
-		return sp->page.private;
+		return sp->private;
 }
 EXPORT_SYMBOL(ksize);
 
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2012-04-11 07:07:16.660129272 -0500
+++ linux-2.6/include/linux/mm_types.h	2012-04-11 07:11:01.944124607 -0500
@@ -52,7 +52,7 @@ struct page {
 	struct {
 		union {
 			pgoff_t index;		/* Our offset within mapping. */
-			void *freelist;		/* slub first free object */
+			void *freelist;		/* slub/slob first free object */
 		};
 
 		union {
@@ -80,11 +80,12 @@ struct page {
 					 */
 					atomic_t _mapcount;
 
-					struct {
+					struct { /* SLUB */
 						unsigned inuse:16;
 						unsigned objects:15;
 						unsigned frozen:1;
 					};
+					int units;	/* SLOB */
 				};
 				atomic_t _count;		/* Usage count, see below. */
 			};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
