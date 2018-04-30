Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67A6B6B0011
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 16:23:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a1so2990106pfn.11
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 13:23:14 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f11-v6si51844pgn.392.2018.04.30.13.23.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Apr 2018 13:23:13 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 07/16] slub: Remove page->counters
Date: Mon, 30 Apr 2018 13:22:38 -0700
Message-Id: <20180430202247.25220-8-willy@infradead.org>
In-Reply-To: <20180430202247.25220-1-willy@infradead.org>
References: <20180430202247.25220-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Use page->private instead, now that these two fields are in the same
location.  Include a compile-time assert that the fields don't get out
of sync.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h |  1 -
 mm/slub.c                | 68 ++++++++++++++++++----------------------
 2 files changed, 31 insertions(+), 38 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 9828cd170251..04d9dc442029 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -105,7 +105,6 @@ struct page {
 #endif
 #endif
 		void *s_mem;			/* slab first object */
-		unsigned long counters;		/* SLUB */
 		struct {			/* SLUB */
 			unsigned inuse:16;
 			unsigned objects:15;
diff --git a/mm/slub.c b/mm/slub.c
index 0b4b58740ed8..04625e3dab13 100644
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
@@ -1787,8 +1781,8 @@ static inline void *acquire_slab(struct kmem_cache *s,
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
@@ -1802,7 +1796,7 @@ static inline void *acquire_slab(struct kmem_cache *s,
 
 	if (!__cmpxchg_double_slab(s, page,
 			freelist, counters,
-			new.freelist, new.counters,
+			new.freelist, new.private,
 			"acquire_slab"))
 		return NULL;
 
@@ -2049,15 +2043,15 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 
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
@@ -2080,11 +2074,11 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
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
@@ -2145,8 +2139,8 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 
 	l = m;
 	if (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
+				old.freelist, old.private,
+				new.freelist, new.private,
 				"unfreezing slab"))
 		goto redo;
 
@@ -2195,17 +2189,17 @@ static void unfreeze_partials(struct kmem_cache *s,
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
@@ -2494,9 +2488,9 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 
 	do {
 		freelist = page->freelist;
-		counters = page->counters;
+		counters = page->private;
 
-		new.counters = counters;
+		new.private = counters;
 		VM_BUG_ON(!new.frozen);
 
 		new.inuse = page->objects;
@@ -2504,7 +2498,7 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 
 	} while (!__cmpxchg_double_slab(s, page,
 		freelist, counters,
-		NULL, new.counters,
+		NULL, new.private,
 		"get_freelist"));
 
 	return freelist;
@@ -2829,9 +2823,9 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
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
@@ -2864,7 +2858,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 	} while (!cmpxchg_double_slab(s, page,
 		prior, counters,
-		head, new.counters,
+		head, new.private,
 		"__slab_free"));
 
 	if (likely(!n)) {
-- 
2.17.0
