Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BC3DE828E2
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 00:24:50 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id e65so93819218pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:50 -0800 (PST)
Received: from mail-pa0-x241.google.com (mail-pa0-x241.google.com. [2607:f8b0:400e:c03::241])
        by mx.google.com with ESMTPS id z7si6896375par.88.2016.01.13.21.24.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 21:24:50 -0800 (PST)
Received: by mail-pa0-x241.google.com with SMTP id yy13so27882215pab.1
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 21:24:49 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 07/16] mm/slab: alternative implementation for DEBUG_SLAB_LEAK
Date: Thu, 14 Jan 2016 14:24:20 +0900
Message-Id: <1452749069-15334-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1452749069-15334-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

DEBUG_SLAB_LEAK is a debug option. It's current implementation
requires status buffer so we need more memory to use it. And, it
cause kmem_cache initialization step more complex.

To remove this extra memory usage and to simplify initialization
step, this patch implement this feature with another way.

When user requests to get slab object owner information, it marks
that getting information is started. And then, all free objects
in caches are flushed to corresponding slab page. Now, we can
distinguish all freed object so we can know all allocated objects, too.
After collecting slab object owner information on allocated objects,
mark is checked that there is no free during the processing. If true,
we can be sure that our information is correct so information is
returned to user.

Although this way is rather complex, it has two important benefits
mentioned above. So, I think it is worth changing.

There is one drawback that it takes more time to get slab object owner
information but it is just a debug option so it doesn't matter at all.

To help review, this patch implements new way only. Following patch
will remove useless code.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/slab_def.h |  3 ++
 mm/slab.c                | 85 +++++++++++++++++++++++++++++++++++-------------
 2 files changed, 66 insertions(+), 22 deletions(-)

diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index cf139d3..e878ba3 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -60,6 +60,9 @@ struct kmem_cache {
 	atomic_t allocmiss;
 	atomic_t freehit;
 	atomic_t freemiss;
+#ifdef CONFIG_DEBUG_SLAB_LEAK
+	atomic_t store_user_clean;
+#endif
 
 	/*
 	 * If debugging is enabled, then the allocator can add additional
diff --git a/mm/slab.c b/mm/slab.c
index 7a10e18..9a64d8f 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -396,20 +396,25 @@ static void set_obj_status(struct page *page, int idx, int val)
 	status[idx] = val;
 }
 
-static inline unsigned int get_obj_status(struct page *page, int idx)
+static inline bool is_store_user_clean(struct kmem_cache *cachep)
 {
-	int freelist_size;
-	char *status;
-	struct kmem_cache *cachep = page->slab_cache;
+	return atomic_read(&cachep->store_user_clean) == 1;
+}
 
-	freelist_size = cachep->num * sizeof(freelist_idx_t);
-	status = (char *)page->freelist + freelist_size;
+static inline void set_store_user_clean(struct kmem_cache *cachep)
+{
+	atomic_set(&cachep->store_user_clean, 1);
+}
 
-	return status[idx];
+static inline void set_store_user_dirty(struct kmem_cache *cachep)
+{
+	if (is_store_user_clean(cachep))
+		atomic_set(&cachep->store_user_clean, 0);
 }
 
 #else
 static inline void set_obj_status(struct page *page, int idx, int val) {}
+static inline void set_store_user_dirty(struct kmem_cache *cachep) {}
 
 #endif
 
@@ -2550,6 +2555,11 @@ static void *slab_get_obj(struct kmem_cache *cachep, struct page *page)
 	objp = index_to_obj(cachep, page, get_free_obj(page, page->active));
 	page->active++;
 
+#if DEBUG
+	if (cachep->flags & SLAB_STORE_USER)
+		set_store_user_dirty(cachep);
+#endif
+
 	return objp;
 }
 
@@ -2725,8 +2735,10 @@ static void *cache_free_debugcheck(struct kmem_cache *cachep, void *objp,
 		*dbg_redzone1(cachep, objp) = RED_INACTIVE;
 		*dbg_redzone2(cachep, objp) = RED_INACTIVE;
 	}
-	if (cachep->flags & SLAB_STORE_USER)
+	if (cachep->flags & SLAB_STORE_USER) {
+		set_store_user_dirty(cachep);
 		*dbg_userword(cachep, objp) = (void *)caller;
+	}
 
 	objnr = obj_to_index(cachep, page, objp);
 
@@ -4082,15 +4094,34 @@ static void handle_slab(unsigned long *n, struct kmem_cache *c,
 						struct page *page)
 {
 	void *p;
-	int i;
+	int i, j;
+	unsigned long v;
 
 	if (n[0] == n[1])
 		return;
 	for (i = 0, p = page->s_mem; i < c->num; i++, p += c->size) {
-		if (get_obj_status(page, i) != OBJECT_ACTIVE)
+		bool active = true;
+
+		for (j = page->active; j < c->num; j++) {
+			if (get_free_obj(page, j) == i) {
+				active = false;
+				break;
+			}
+		}
+
+		if (!active)
 			continue;
 
-		if (!add_caller(n, (unsigned long)*dbg_userword(c, p)))
+		/*
+		 * probe_kernel_read() is used for DEBUG_PAGEALLOC. page table
+		 * mapping is established when actual object allocation and
+		 * we could mistakenly access the unmapped object in the cpu
+		 * cache.
+		 */
+		if (probe_kernel_read(&v, dbg_userword(c, p), sizeof(v)))
+			continue;
+
+		if (!add_caller(n, v))
 			return;
 	}
 }
@@ -4126,21 +4157,31 @@ static int leaks_show(struct seq_file *m, void *p)
 	if (!(cachep->flags & SLAB_RED_ZONE))
 		return 0;
 
-	/* OK, we can do it */
+	/*
+	 * Set store_user_clean and start to grab stored user information
+	 * for all objects on this cache. If some alloc/free requests comes
+	 * during the processing, information would be wrong so restart
+	 * whole processing.
+	 */
+	do {
+		set_store_user_clean(cachep);
+		drain_cpu_caches(cachep);
+
+		x[1] = 0;
 
-	x[1] = 0;
+		for_each_kmem_cache_node(cachep, node, n) {
 
-	for_each_kmem_cache_node(cachep, node, n) {
+			check_irq_on();
+			spin_lock_irq(&n->list_lock);
 
-		check_irq_on();
-		spin_lock_irq(&n->list_lock);
+			list_for_each_entry(page, &n->slabs_full, lru)
+				handle_slab(x, cachep, page);
+			list_for_each_entry(page, &n->slabs_partial, lru)
+				handle_slab(x, cachep, page);
+			spin_unlock_irq(&n->list_lock);
+		}
+	} while (!is_store_user_clean(cachep));
 
-		list_for_each_entry(page, &n->slabs_full, lru)
-			handle_slab(x, cachep, page);
-		list_for_each_entry(page, &n->slabs_partial, lru)
-			handle_slab(x, cachep, page);
-		spin_unlock_irq(&n->list_lock);
-	}
 	name = cachep->name;
 	if (x[0] == x[1]) {
 		/* Increase the buffer size */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
