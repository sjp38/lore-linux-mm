Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5FAF36B0011
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:24 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d13so1390089pfn.21
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q20si1588554pfh.37.2018.04.18.11.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:22 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 07/14] slub: Remove page->counters
Date: Wed, 18 Apr 2018 11:49:05 -0700
Message-Id: <20180418184912.2851-8-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

Use page->private instead, now that these two fields are in the same
location.  Include a compile-time assert that the fields don't get out
of sync.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h |  5 ++-
 mm/slub.c                | 68 ++++++++++++++++++----------------------
 2 files changed, 33 insertions(+), 40 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 9c048a512695..04d9dc442029 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -65,9 +65,9 @@ struct hmm;
  */
 #ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
 #define _struct_page_alignment	__aligned(2 * sizeof(unsigned long))
-#else /* !CONFIG_HAVE_ALIGNED_STRUCT_PAGE */
+#else
 #define _struct_page_alignment
-#endif /* !CONFIG_HAVE_ALIGNED_STRUCT_PAGE */
+#endif
 
 struct page {
 	/* First double word block */
@@ -105,7 +105,6 @@ struct page {
 #endif
 #endif
 		void *s_mem;			/* slab first object */
-		unsigned long counters;		/* SLUB */
 		struct {			/* SLUB */
 			unsigned inuse:16;
 			unsigned objects:15;
diff --git a/mm/slub.c b/mm/slub.c
index 27b6ba1c116a..f2f64568b25e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -55,8 +55,9 @@
  *   have the ability to do a cmpxchg_double. It only protects the second
  *   double word in the page struct. Meaning
  *	A. page->freelist	-> List of object free in a page
- *	B. page->counters	-> Counters of objects
- *	C. page->frozen		-> frozen state
+ *	B. page->inuse		-> Number of objects in use
+ *	C. page->objects	-> Number of objects in page
+ *	D. page->frozen		-> frozen state
  *
  *   If a slab is frozen then it is exempt from list management. It is not
  *   on any list. The processor that froze the slab is the one who can
@@ -358,17 +359,10 @@ static __always_inline void slab_unlock(struct page *page)
 
 static inline void set_page_slub_counters(struct page *page, unsigned long counters_new)
 {
-	struct page tmp;
-	tmp.counters = counters_new;
-	/*
-	 * page->counters can cover frozen/inuse/objects as well
-	 * as page->_refcount.  If we assign to ->counters directly
-	 * we run the risk of losing updates to page->_refcount, so
-	 * be careful and only assign to the fields we need.
-	 */
-	page->frozen  = tmp.frozen;
-	page->inuse   = tmp.inuse;
-	page->objects = tmp.objects;
+	BUILD_BUG_ON(offsetof(struct page, freelist) + sizeof(void *) !=
+			offsetof(struct page, private));
+	BUILD_BUG_ON(offsetof(struct page, freelist) % (2 * sizeof(void *)));
+	page->private = counters_new;
 }
 
 /* Interrupts must be disabled (for the fallback code to work right) */
@@ -381,7 +375,7 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
+		if (cmpxchg_double(&page->freelist, &page->private,
 				   freelist_old, counters_old,
 				   freelist_new, counters_new))
 			return true;
@@ -390,7 +384,7 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
 	{
 		slab_lock(page);
 		if (page->freelist == freelist_old &&
-					page->counters == counters_old) {
+					page->private == counters_old) {
 			page->freelist = freelist_new;
 			set_page_slub_counters(page, counters_new);
 			slab_unlock(page);
@@ -417,7 +411,7 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
+		if (cmpxchg_double(&page->freelist, &page->private,
 				   freelist_old, counters_old,
 				   freelist_new, counters_new))
 			return true;
@@ -429,7 +423,7 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 		local_irq_save(flags);
 		slab_lock(page);
 		if (page->freelist == freelist_old &&
-					page->counters == counters_old) {
+					page->private == counters_old) {
 			page->freelist = freelist_new;
 			set_page_slub_counters(page, counters_new);
 			slab_unlock(page);
@@ -1788,8 +1782,8 @@ static inline void *acquire_slab(struct kmem_cache *s,
 	 * per cpu allocation list.
 	 */
 	freelist = page->freelist;
-	counters = page->counters;
-	new.counters = counters;
+	counters = page->private;
+	new.private = counters;
 	*objects = new.objects - new.inuse;
 	if (mode) {
 		new.inuse = page->objects;
@@ -1803,7 +1797,7 @@ static inline void *acquire_slab(struct kmem_cache *s,
 
 	if (!__cmpxchg_double_slab(s, page,
 			freelist, counters,
-			new.freelist, new.counters,
+			new.freelist, new.private,
 			"acquire_slab"))
 		return NULL;
 
@@ -2050,15 +2044,15 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 
 		do {
 			prior = page->freelist;
-			counters = page->counters;
+			counters = page->private;
 			set_freepointer(s, freelist, prior);
-			new.counters = counters;
+			new.private = counters;
 			new.inuse--;
 			VM_BUG_ON(!new.frozen);
 
 		} while (!__cmpxchg_double_slab(s, page,
 			prior, counters,
-			freelist, new.counters,
+			freelist, new.private,
 			"drain percpu freelist"));
 
 		freelist = nextfree;
@@ -2081,11 +2075,11 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 redo:
 
 	old.freelist = page->freelist;
-	old.counters = page->counters;
+	old.private = page->private;
 	VM_BUG_ON(!old.frozen);
 
 	/* Determine target state of the slab */
-	new.counters = old.counters;
+	new.private = old.private;
 	if (freelist) {
 		new.inuse--;
 		set_freepointer(s, freelist, old.freelist);
@@ -2146,8 +2140,8 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 
 	l = m;
 	if (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
+				old.freelist, old.private,
+				new.freelist, new.private,
 				"unfreezing slab"))
 		goto redo;
 
@@ -2196,17 +2190,17 @@ static void unfreeze_partials(struct kmem_cache *s,
 		do {
 
 			old.freelist = page->freelist;
-			old.counters = page->counters;
+			old.private = page->private;
 			VM_BUG_ON(!old.frozen);
 
-			new.counters = old.counters;
+			new.private = old.private;
 			new.freelist = old.freelist;
 
 			new.frozen = 0;
 
 		} while (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
+				old.freelist, old.private,
+				new.freelist, new.private,
 				"unfreezing slab"));
 
 		if (unlikely(!new.inuse && n->nr_partial >= s->min_partial)) {
@@ -2495,9 +2489,9 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 
 	do {
 		freelist = page->freelist;
-		counters = page->counters;
+		counters = page->private;
 
-		new.counters = counters;
+		new.private = counters;
 		VM_BUG_ON(!new.frozen);
 
 		new.inuse = page->objects;
@@ -2505,7 +2499,7 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 
 	} while (!__cmpxchg_double_slab(s, page,
 		freelist, counters,
-		NULL, new.counters,
+		NULL, new.private,
 		"get_freelist"));
 
 	return freelist;
@@ -2830,9 +2824,9 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 			n = NULL;
 		}
 		prior = page->freelist;
-		counters = page->counters;
+		counters = page->private;
 		set_freepointer(s, tail, prior);
-		new.counters = counters;
+		new.private = counters;
 		was_frozen = new.frozen;
 		new.inuse -= cnt;
 		if ((!new.inuse || !prior) && !was_frozen) {
@@ -2865,7 +2859,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 	} while (!cmpxchg_double_slab(s, page,
 		prior, counters,
-		head, new.counters,
+		head, new.private,
 		"__slab_free"));
 
 	if (likely(!n)) {
-- 
2.17.0
