Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC906B003B
	for <linux-mm@kvack.org>; Fri, 30 May 2014 09:51:21 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id p9so1003765lbv.25
        for <linux-mm@kvack.org>; Fri, 30 May 2014 06:51:20 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ad3si11152782lbc.1.2014.05.30.06.51.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 May 2014 06:51:17 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 7/8] slub: make dead caches discard free slabs immediately
Date: Fri, 30 May 2014 17:51:10 +0400
Message-ID: <5d2fbc894a2c62597e7196bb1ebb8357b15529ab.1401457502.git.vdavydov@parallels.com>
In-Reply-To: <cover.1401457502.git.vdavydov@parallels.com>
References: <cover.1401457502.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

To speed up further allocations, SLUB may keep some empty slabs on per
cpu/node partial lists. If the cache is dead, i.e. belongs to a memcg
that was turned offline, there is no need in that, because dead caches
are never allocated from.

What is worse, keeping empty slabs on the list will prevent the dead
cache from self destruction, because each allocated slab holds a
reference to the cache, and the cache can only be destroyed when its ref
counter is zero.

To make a SLUB cache discard slabs as soon as they become empty, we have
to (1) drain per cpu/node caches, (2) disable caching of empty slabs on
per node list, (3) disable per cpu partial lists completely, as a slab
that becomes empty on such a list will be freed only when
unfreeze_partials() is called, which can never happen under certain
circumstances.

(1) is already done by kmem_cache_shrink(), which is called from
memcg_unregister_all_caches().

(2) is easy. It's enough to set kmem_cache->min_partial to 0 before
shrinking the cache. Since min_partial is only accessed under
kmem_cache_node->lock, and we take the lock while shrinking the cache,
this will guarantee no empty slabs will be added to the list after
kmem_cache_shrink is called.

(3) is a bit more difficult, because slabs are added to per-cpu partial
lists lock-less. Fortunately, we only have to handle the __slab_free
case, because, as there shouldn't be any allocation requests dispatched
to a dead memcg cache, get_partial_node() should never be called. In
__slab_free we use cmpxchg to modify kmem_cache_cpu->partial (see
put_cpu_partial) so that setting ->partial to a special value, which
will make put_cpu_partial bail out, will do the trick.

Note, this shouldn't affect performance, because keeping empty slabs on
per node lists as well as using per cpu partials are only worthwhile if
the cache is used for allocations, which isn't the case for dead caches.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slub.c |  124 ++++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 95 insertions(+), 29 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ac39cc9b6849..d5a54b03d558 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -133,6 +133,21 @@ static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 }
 
 /*
+ * When the owner memcg of a cache is turned offline, its per cpu partial lists
+ * must be disabled, because they can contain empty slabs and hence prevent the
+ * cache from self-destruction.
+ *
+ * To zap per cpu partials, we set each cpu's cpu_slab->partial to a special
+ * value, CPU_SLAB_PARTIAL_DEAD. Whenever we see this value while trying to put
+ * a frozen slab to a per cpu partial list, we unfreeze the slab and put it
+ * back to its node's list.
+ *
+ * Actually, we only need to handle this on free path, because no allocations
+ * requests can be dispatched to a dead memcg cache.
+ */
+#define CPU_SLAB_PARTIAL_DEAD		((struct page *)~0UL)
+
+/*
  * Issues still to be resolved:
  *
  * - Support PAGE_ALLOC_DEBUG. Should be easy to do.
@@ -1643,6 +1658,7 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 			stat(s, ALLOC_FROM_PARTIAL);
 			object = t;
 		} else {
+			VM_BUG_ON(c->partial == CPU_SLAB_PARTIAL_DEAD);
 			prepare_cpu_partial(page, c->partial);
 			c->partial = page;
 			stat(s, CPU_PARTIAL_NODE);
@@ -1948,6 +1964,56 @@ redo:
 	}
 }
 
+#ifdef CONFIG_SLUB_CPU_PARTIAL
+static void __unfreeze_partial(struct kmem_cache *s, struct kmem_cache_node *n,
+			       struct page *page, struct page **discard_page)
+{
+	struct page new, old;
+
+	do {
+
+		old.freelist = page->freelist;
+		old.counters = page->counters;
+		VM_BUG_ON(!old.frozen);
+
+		new.counters = old.counters;
+		new.freelist = old.freelist;
+
+		new.frozen = 0;
+
+	} while (!__cmpxchg_double_slab(s, page,
+			old.freelist, old.counters,
+			new.freelist, new.counters,
+			"unfreezing slab"));
+
+	if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
+		page->next = *discard_page;
+		*discard_page = page;
+	} else {
+		add_partial(n, page, DEACTIVATE_TO_TAIL);
+		stat(s, FREE_ADD_PARTIAL);
+	}
+}
+
+static void cancel_frozen(struct kmem_cache *s, struct page *page)
+{
+	struct page *discard_page = NULL;
+	struct kmem_cache_node *n;
+	unsigned long flags;
+
+	n = get_node(s, page_to_nid(page));
+	spin_lock_irqsave(&n->list_lock, flags);
+	__unfreeze_partial(s, n, page, &discard_page);
+	spin_unlock_irqrestore(&n->list_lock, flags);
+
+	if (discard_page) {
+		stat(s, DEACTIVATE_EMPTY);
+		discard_slab(s, discard_page);
+		stat(s, FREE_SLAB);
+	}
+}
+#endif
+
 /*
  * Unfreeze all the cpu partial slabs.
  *
@@ -1962,10 +2028,10 @@ static void unfreeze_partials(struct kmem_cache *s,
 	struct kmem_cache_node *n = NULL, *n2 = NULL;
 	struct page *page, *discard_page = NULL;
 
-	while ((page = c->partial)) {
-		struct page new;
-		struct page old;
+	if (c->partial == CPU_SLAB_PARTIAL_DEAD)
+		return;
 
+	while ((page = c->partial)) {
 		c->partial = page->next;
 
 		n2 = get_node(s, page_to_nid(page));
@@ -1977,29 +2043,7 @@ static void unfreeze_partials(struct kmem_cache *s,
 			spin_lock(&n->list_lock);
 		}
 
-		do {
-
-			old.freelist = page->freelist;
-			old.counters = page->counters;
-			VM_BUG_ON(!old.frozen);
-
-			new.counters = old.counters;
-			new.freelist = old.freelist;
-
-			new.frozen = 0;
-
-		} while (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
-				"unfreezing slab"));
-
-		if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
-			page->next = discard_page;
-			discard_page = page;
-		} else {
-			add_partial(n, page, DEACTIVATE_TO_TAIL);
-			stat(s, FREE_ADD_PARTIAL);
-		}
+		__unfreeze_partial(s, n, page, &discard_page);
 	}
 
 	if (n)
@@ -2053,6 +2097,15 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page)
 	do {
 		oldpage = this_cpu_read(s->cpu_slab->partial);
 
+		/*
+		 * Per cpu partials are disabled. Unfreeze the slab and put it
+		 * to the node partial list.
+		 */
+		if (oldpage == CPU_SLAB_PARTIAL_DEAD) {
+			cancel_frozen(s, page);
+			break;
+		}
+
 		if (oldpage) {
 			if (oldpage->pobjects > s->cpu_partial) {
 				unsigned long flags;
@@ -2099,6 +2152,13 @@ static inline void __flush_cpu_slab(struct kmem_cache *s, int cpu)
 			flush_slab(s, c);
 
 		unfreeze_partials(s, c);
+
+		/*
+		 * Disable per cpu partials if the cache is dead so that it
+		 * won't be pinned by empty slabs that can be cached there.
+		 */
+		if (memcg_cache_dead(s))
+			c->partial = CPU_SLAB_PARTIAL_DEAD;
 	}
 }
 
@@ -2368,6 +2428,7 @@ new_slab:
 
 	if (c->partial) {
 		page = c->page = c->partial;
+		VM_BUG_ON(page == CPU_SLAB_PARTIAL_DEAD);
 		c->partial = page->next;
 		stat(s, CPU_PARTIAL_ALLOC);
 		c->freelist = NULL;
@@ -3416,6 +3477,10 @@ void __kmem_cache_shrink(struct kmem_cache *s)
 	struct list_head *slabs_by_inuse;
 	unsigned long flags;
 
+	/* Make dead caches discard empty slabs immediately. */
+	if (memcg_cache_dead(s))
+		s->min_partial = 0;
+
 	slabs_by_inuse = kcalloc(objects - 1, sizeof(struct list_head),
 				 GFP_KERNEL);
 	if (slabs_by_inuse) {
@@ -4329,7 +4394,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 			nodes[node] += x;
 
 			page = ACCESS_ONCE(c->partial);
-			if (page) {
+			if (page && page != CPU_SLAB_PARTIAL_DEAD) {
 				node = page_to_nid(page);
 				if (flags & SO_TOTAL)
 					WARN_ON_ONCE(1);
@@ -4561,7 +4626,7 @@ static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 	for_each_online_cpu(cpu) {
 		struct page *page = per_cpu_ptr(s->cpu_slab, cpu)->partial;
 
-		if (page) {
+		if (page && page != CPU_SLAB_PARTIAL_DEAD) {
 			pages += page->pages;
 			objects += page->pobjects;
 		}
@@ -4573,7 +4638,8 @@ static ssize_t slabs_cpu_partial_show(struct kmem_cache *s, char *buf)
 	for_each_online_cpu(cpu) {
 		struct page *page = per_cpu_ptr(s->cpu_slab, cpu) ->partial;
 
-		if (page && len < PAGE_SIZE - 20)
+		if (page && page != CPU_SLAB_PARTIAL_DEAD &&
+		    len < PAGE_SIZE - 20)
 			len += sprintf(buf + len, " C%d=%d(%d)", cpu,
 				page->pobjects, page->pages);
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
