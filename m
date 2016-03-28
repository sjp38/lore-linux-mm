Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id E47D76B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 18:53:06 -0400 (EDT)
Received: by mail-pf0-f175.google.com with SMTP id x3so148029435pfb.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 15:53:06 -0700 (PDT)
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com. [209.85.192.177])
        by mx.google.com with ESMTPS id x64si28480523pfi.208.2016.03.28.15.53.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 15:53:05 -0700 (PDT)
Received: by mail-pf0-f177.google.com with SMTP id x3so148029035pfb.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 15:53:05 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC][PATCH] mm/slub: Skip CPU slab activation when debugging
Date: Mon, 28 Mar 2016 15:53:01 -0700
Message-Id: <1459205581-4605-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

The per-cpu slab is designed to be the primary path for allocation in SLUB
since it assumed allocations will go through the fast path if possible.
When debugging is enabled, the fast path is disabled and per-cpu
allocations are not used. The current debugging code path still activates
the cpu slab for allocations and then immediately deactivates it. This
is useless work. When a slab is enabled for debugging, skip cpu
activation.

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
This is a follow on to the optimization of the debug paths for poisoning
With this I get ~2 second drop on hackbench -g 20 -l 1000 with slub_debug=P
and no noticable change with slub_debug=- .
---
 mm/slub.c | 82 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 77 insertions(+), 5 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 7277413..4507bd8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1482,8 +1482,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	}
 
 	page->freelist = fixup_red_left(s, start);
-	page->inuse = page->objects;
-	page->frozen = 1;
+	page->inuse = kmem_cache_debug(s) ? 1 : page->objects;
+	page->frozen = kmem_cache_debug(s) ? 0 : 1;
 
 out:
 	if (gfpflags_allow_blocking(flags))
@@ -1658,6 +1658,64 @@ static inline void *acquire_slab(struct kmem_cache *s,
 	return freelist;
 }
 
+
+static inline void *acquire_slab_debug(struct kmem_cache *s,
+		struct kmem_cache_node *n, struct page *page,
+		int mode, int *objects)
+{
+	void *freelist;
+	unsigned long counters;
+	struct page new;
+	void *next;
+
+	lockdep_assert_held(&n->list_lock);
+
+
+	/*
+	 * Zap the freelist and set the frozen bit.
+	 * The old freelist is the list of objects for the
+	 * per cpu allocation list.
+	 */
+	freelist = page->freelist;
+	counters = page->counters;
+
+	BUG_ON(!freelist);
+
+	next = get_freepointer_safe(s, freelist);
+
+	new.counters = counters;
+	*objects = new.objects - new.inuse;
+	if (mode) {
+		new.inuse++;
+		new.freelist = next;
+	} else {
+		BUG();
+	}
+
+	VM_BUG_ON(new.frozen);
+
+	if (!new.freelist) {
+		remove_partial(n, page);
+		add_full(s, n, page);
+	}
+
+	if (!__cmpxchg_double_slab(s, page,
+			freelist, counters,
+			new.freelist, new.counters,
+			"acquire_slab")) {
+		if (!new.freelist) {
+			remove_full(s, n, page);
+			add_partial(n, page, DEACTIVATE_TO_HEAD);
+		}
+		return NULL;
+	}
+
+	WARN_ON(!freelist);
+	return freelist;
+}
+
+
+
 static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain);
 static inline bool pfmemalloc_match(struct page *page, gfp_t gfpflags);
 
@@ -1688,7 +1746,11 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 		if (!pfmemalloc_match(page, flags))
 			continue;
 
-		t = acquire_slab(s, n, page, object == NULL, &objects);
+		if (kmem_cache_debug(s))
+			t = acquire_slab_debug(s, n, page, object == NULL, &objects);
+		else
+			t = acquire_slab(s, n, page, object == NULL, &objects);
+
 		if (!t)
 			break;
 
@@ -2284,7 +2346,17 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 		 * muck around with it freely without cmpxchg
 		 */
 		freelist = page->freelist;
-		page->freelist = NULL;
+		page->freelist = kmem_cache_debug(s) ?
+				get_freepointer(s, freelist) : NULL;
+
+		if (kmem_cache_debug(s)) {
+			struct kmem_cache_node *n;
+
+			n = get_node(s, page_to_nid(page));
+			spin_lock(&n->list_lock);
+			add_partial(n, page, DEACTIVATE_TO_HEAD);
+			spin_unlock(&n->list_lock);
+		}
 
 		stat(s, ALLOC_SLAB);
 		c->page = page;
@@ -2446,7 +2518,7 @@ new_slab:
 			!alloc_debug_processing(s, page, freelist, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
-	deactivate_slab(s, page, get_freepointer(s, freelist));
+	/* No need to deactivate, no cpu slab */
 	c->page = NULL;
 	c->freelist = NULL;
 	return freelist;
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
