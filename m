Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id EF3766B0072
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 13:25:07 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3466014pbb.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 10:25:07 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 4/4] slub: deactivate freelist of kmem_cache_cpu all at once in deactivate_slab()
Date: Sat,  9 Jun 2012 02:23:17 +0900
Message-Id: <1339176197-13270-4-git-send-email-js1304@gmail.com>
In-Reply-To: <1339176197-13270-1-git-send-email-js1304@gmail.com>
References: <yes>
 <1339176197-13270-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

Current implementation of deactivate_slab() which deactivate
freelist of kmem_cache_cpu one by one is inefficient.
This patch changes it to deactivate freelist all at once.
But, there is no overall performance benefit,
because deactivate_slab() is invoked infrequently.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index b5f2108..7bcb434 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1733,16 +1733,14 @@ void init_kmem_cache_cpus(struct kmem_cache *s)
  */
 static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
-	enum slab_modes { M_NONE, M_PARTIAL, M_FULL, M_FREE };
 	struct page *page = c->page;
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
-	int lock = 0;
-	enum slab_modes l = M_NONE, m = M_NONE;
-	void *freelist;
-	void *nextfree;
-	int tail = DEACTIVATE_TO_HEAD;
+	void *freelist, *lastfree = NULL;
+	unsigned int nr_free = 0;
 	struct page new;
-	struct page old;
+	void *prior;
+	unsigned long counters;
+	int lock = 0, tail = DEACTIVATE_TO_HEAD;
 
 	if (page->freelist) {
 		stat(s, DEACTIVATE_REMOTE_FREES);
@@ -1752,127 +1750,54 @@ static void deactivate_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 	c->tid = next_tid(c->tid);
 	c->page = NULL;
 	freelist = c->freelist;
-	c->freelist = NULL;
-
-	/*
-	 * Stage one: Free all available per cpu objects back
-	 * to the page freelist while it is still frozen. Leave the
-	 * last one.
-	 *
-	 * There is no need to take the list->lock because the page
-	 * is still frozen.
-	 */
-	while (freelist && (nextfree = get_freepointer(s, freelist))) {
-		void *prior;
-		unsigned long counters;
-
-		do {
-			prior = page->freelist;
-			counters = page->counters;
-			set_freepointer(s, freelist, prior);
-			new.counters = counters;
-			new.inuse--;
-			VM_BUG_ON(!new.frozen);
-
-		} while (!__cmpxchg_double_slab(s, page,
-			prior, counters,
-			freelist, new.counters,
-			"drain percpu freelist"));
-
-		freelist = nextfree;
+	while (freelist) {
+		lastfree = freelist;
+		freelist = get_freepointer(s, freelist);
+		nr_free++;
 	}
 
-	/*
-	 * Stage two: Ensure that the page is unfrozen while the
-	 * list presence reflects the actual number of objects
-	 * during unfreeze.
-	 *
-	 * We setup the list membership and then perform a cmpxchg
-	 * with the count. If there is a mismatch then the page
-	 * is not unfrozen but the page is on the wrong list.
-	 *
-	 * Then we restart the process which may have to remove
-	 * the page from the list that we just put it on again
-	 * because the number of objects in the slab may have
-	 * changed.
-	 */
-redo:
+	freelist = c->freelist;
+	c->freelist = NULL;
 
-	old.freelist = page->freelist;
-	old.counters = page->counters;
-	VM_BUG_ON(!old.frozen);
+	do {
+		if (lock) {
+			lock = 0;
+			spin_unlock(&n->list_lock);
+		}
 
-	/* Determine target state of the slab */
-	new.counters = old.counters;
-	if (freelist) {
-		new.inuse--;
-		set_freepointer(s, freelist, old.freelist);
-		new.freelist = freelist;
-	} else
-		new.freelist = old.freelist;
+		prior = page->freelist;
+		counters = page->counters;
 
-	new.frozen = 0;
+		if (lastfree)
+			set_freepointer(s, lastfree, prior);
+		else
+			freelist = prior;
 
-	if (!new.inuse && n->nr_partial > s->min_partial)
-		m = M_FREE;
-	else if (new.freelist) {
-		m = M_PARTIAL;
-		if (!lock) {
-			lock = 1;
-			/*
-			 * Taking the spinlock removes the possiblity
-			 * that acquire_slab() will see a slab page that
-			 * is frozen
-			 */
-			spin_lock(&n->list_lock);
-		}
-	} else {
-		m = M_FULL;
-		if (kmem_cache_debug(s) && !lock) {
+		new.counters = counters;
+		VM_BUG_ON(!new.frozen);
+		new.inuse -= nr_free;
+		new.frozen = 0;
+
+		if (new.inuse || n->nr_partial <= s->min_partial) {
 			lock = 1;
-			/*
-			 * This also ensures that the scanning of full
-			 * slabs from diagnostic functions will not see
-			 * any frozen slabs.
-			 */
 			spin_lock(&n->list_lock);
 		}
-	}
-
-	if (l != m) {
-
-		if (l == M_PARTIAL)
-
-			remove_partial(n, page);
-
-		else if (l == M_FULL)
-
-			remove_full(s, page);
-
-		if (m == M_PARTIAL) {
 
+	} while (!__cmpxchg_double_slab(s, page,
+				prior, counters,
+				freelist, new.counters,
+				"drain percpu freelist"));
+	if (lock) {
+		if (kmem_cache_debug(s) && !freelist) {
+			add_full(s, n, page);
+			stat(s, DEACTIVATE_FULL);
+		} else {
 			add_partial(n, page, tail);
 			stat(s, tail);
-
-		} else if (m == M_FULL) {
-
-			stat(s, DEACTIVATE_FULL);
-			add_full(s, n, page);
-
 		}
-	}
-
-	l = m;
-	if (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
-				"unfreezing slab"))
-		goto redo;
-
-	if (lock)
 		spin_unlock(&n->list_lock);
-
-	if (m == M_FREE) {
+	} else {
+		VM_BUG_ON(new.inuse);
 		stat(s, DEACTIVATE_EMPTY);
 		discard_slab(s, page);
 		stat(s, FREE_SLAB);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
