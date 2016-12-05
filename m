Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 539866B0038
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 23:23:11 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so491748214pfx.1
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 20:23:11 -0800 (PST)
Received: from mail-pg0-x22a.google.com (mail-pg0-x22a.google.com. [2607:f8b0:400e:c05::22a])
        by mx.google.com with ESMTPS id a28si13205108pfl.157.2016.12.04.20.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Dec 2016 20:23:10 -0800 (PST)
Received: by mail-pg0-x22a.google.com with SMTP id 3so131971866pgd.0
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 20:23:10 -0800 (PST)
Date: Sun, 4 Dec 2016 20:23:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, slab: maintain total slab count instead of active
 count
In-Reply-To: <C80AB6F618D91B4E8F391CB202C12DFD14C4E91C59@LGEVEXMBHQSVC1.LGE.NET>
Message-ID: <alpine.DEB.2.10.1612042020110.115755@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1611081505240.13403@chino.kir.corp.google.com> <20161108151727.b64035da825c69bced88b46d@linux-foundation.org> <alpine.DEB.2.10.1611091637460.125130@chino.kir.corp.google.com> <20161111055326.GA16336@js1304-P5Q-DELUXE>
 <alpine.DEB.2.10.1611110222440.16406@chino.kir.corp.google.com> <20161128074001.GA32105@js1304-P5Q-DELUXE> <alpine.DEB.2.10.1611291655580.135607@chino.kir.corp.google.com> <C80AB6F618D91B4E8F391CB202C12DFD14C4E91C59@LGEVEXMBHQSVC1.LGE.NET>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, iamjoonsoo.kim@lge.com
Cc: Greg Thelen <gthelen@google.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, js1304@gmail.com

Rather than tracking the number of active slabs for each node, track the
total number of slabs.  This is a minor improvement that avoids active
slab tracking when a slab goes from free to partial or partial to free.

For slab debugging, this also removes an explicit free count since it can 
easily be inferred by the difference in number of total objects and number 
of active objects.

Suggested-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 For -mm because this depends on 
 mm-slab-faster-active-and-free-stats.patch

 mm/slab.c | 70 ++++++++++++++++++++++++++-------------------------------------
 mm/slab.h |  4 ++--
 2 files changed, 31 insertions(+), 43 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -227,7 +227,7 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
 	INIT_LIST_HEAD(&parent->slabs_full);
 	INIT_LIST_HEAD(&parent->slabs_partial);
 	INIT_LIST_HEAD(&parent->slabs_free);
-	parent->active_slabs = 0;
+	parent->total_slabs = 0;
 	parent->free_slabs = 0;
 	parent->shared = NULL;
 	parent->alien = NULL;
@@ -1376,20 +1376,18 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 		cachep->name, cachep->size, cachep->gfporder);
 
 	for_each_kmem_cache_node(cachep, node, n) {
-		unsigned long active_objs = 0, free_objs = 0;
-		unsigned long active_slabs, num_slabs;
+		unsigned long total_slabs, free_slabs, free_objs;
 
 		spin_lock_irqsave(&n->list_lock, flags);
-		active_slabs = n->active_slabs;
-		num_slabs = active_slabs + n->free_slabs;
-
-		active_objs += (num_slabs * cachep->num) - n->free_objects;
-		free_objs += n->free_objects;
+		total_slabs = n->total_slabs;
+		free_slabs = n->free_slabs;
+		free_objs = n->free_objects;
 		spin_unlock_irqrestore(&n->list_lock, flags);
 
-		pr_warn("  node %d: slabs: %ld/%ld, objs: %ld/%ld, free: %ld\n",
-			node, active_slabs, num_slabs, active_objs,
-			num_slabs * cachep->num, free_objs);
+		pr_warn("  node %d: slabs: %ld/%ld, objs: %ld/%ld\n",
+			node, total_slabs - free_slabs, total_slabs,
+			(total_slabs * cachep->num) - free_objs,
+			total_slabs * cachep->num);
 	}
 #endif
 }
@@ -2302,6 +2300,7 @@ static int drain_freelist(struct kmem_cache *cache,
 		page = list_entry(p, struct page, lru);
 		list_del(&page->lru);
 		n->free_slabs--;
+		n->total_slabs--;
 		/*
 		 * Safe to drop the lock. The slab is no longer linked
 		 * to the cache.
@@ -2736,13 +2735,12 @@ static void cache_grow_end(struct kmem_cache *cachep, struct page *page)
 	n = get_node(cachep, page_to_nid(page));
 
 	spin_lock(&n->list_lock);
+	n->total_slabs++;
 	if (!page->active) {
 		list_add_tail(&page->lru, &(n->slabs_free));
 		n->free_slabs++;
-	} else {
+	} else
 		fixup_slab_list(cachep, n, page, &list);
-		n->active_slabs++;
-	}
 
 	STATS_INC_GROWN(cachep);
 	n->free_objects += cachep->num - page->active;
@@ -2869,7 +2867,7 @@ static inline void fixup_slab_list(struct kmem_cache *cachep,
 
 /* Try to find non-pfmemalloc slab if needed */
 static noinline struct page *get_valid_first_slab(struct kmem_cache_node *n,
-			struct page *page, bool *page_is_free, bool pfmemalloc)
+					struct page *page, bool pfmemalloc)
 {
 	if (!page)
 		return NULL;
@@ -2888,10 +2886,9 @@ static noinline struct page *get_valid_first_slab(struct kmem_cache_node *n,
 
 	/* Move pfmemalloc slab to the end of list to speed up next search */
 	list_del(&page->lru);
-	if (*page_is_free) {
-		WARN_ON(page->active);
+	if (!page->active) {
 		list_add_tail(&page->lru, &n->slabs_free);
-		*page_is_free = false;
+		n->free_slabs++;
 	} else
 		list_add_tail(&page->lru, &n->slabs_partial);
 
@@ -2903,7 +2900,7 @@ static noinline struct page *get_valid_first_slab(struct kmem_cache_node *n,
 	n->free_touched = 1;
 	list_for_each_entry(page, &n->slabs_free, lru) {
 		if (!PageSlabPfmemalloc(page)) {
-			*page_is_free = true;
+			n->free_slabs--;
 			return page;
 		}
 	}
@@ -2914,26 +2911,19 @@ static noinline struct page *get_valid_first_slab(struct kmem_cache_node *n,
 static struct page *get_first_slab(struct kmem_cache_node *n, bool pfmemalloc)
 {
 	struct page *page;
-	bool page_is_free = false;
 
 	assert_spin_locked(&n->list_lock);
-	page = list_first_entry_or_null(&n->slabs_partial,
-			struct page, lru);
+	page = list_first_entry_or_null(&n->slabs_partial, struct page, lru);
 	if (!page) {
 		n->free_touched = 1;
-		page = list_first_entry_or_null(&n->slabs_free,
-				struct page, lru);
+		page = list_first_entry_or_null(&n->slabs_free, struct page,
+						lru);
 		if (page)
-			page_is_free = true;
+			n->free_slabs--;
 	}
 
 	if (sk_memalloc_socks())
-		page = get_valid_first_slab(n, page, &page_is_free, pfmemalloc);
-
-	if (page && page_is_free) {
-		n->active_slabs++;
-		n->free_slabs--;
-	}
+		page = get_valid_first_slab(n, page, pfmemalloc);
 
 	return page;
 }
@@ -3436,7 +3426,6 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 		if (page->active == 0) {
 			list_add(&page->lru, &n->slabs_free);
 			n->free_slabs++;
-			n->active_slabs--;
 		} else {
 			/* Unconditionally move a slab to the end of the
 			 * partial list on free - maximum time for the
@@ -3452,6 +3441,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 		page = list_last_entry(&n->slabs_free, struct page, lru);
 		list_move(&page->lru, list);
 		n->free_slabs--;
+		n->total_slabs--;
 	}
 }
 
@@ -4104,8 +4094,8 @@ static void cache_reap(struct work_struct *w)
 void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 {
 	unsigned long active_objs, num_objs, active_slabs;
-	unsigned long num_slabs = 0, free_objs = 0, shared_avail = 0;
-	unsigned long num_slabs_free = 0;
+	unsigned long total_slabs = 0, free_objs = 0, shared_avail = 0;
+	unsigned long free_slabs = 0;
 	int node;
 	struct kmem_cache_node *n;
 
@@ -4113,9 +4103,8 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 		check_irq_on();
 		spin_lock_irq(&n->list_lock);
 
-		num_slabs += n->active_slabs + n->free_slabs;
-		num_slabs_free += n->free_slabs;
-
+		total_slabs += n->total_slabs;
+		free_slabs += n->free_slabs;
 		free_objs += n->free_objects;
 
 		if (n->shared)
@@ -4123,15 +4112,14 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 
 		spin_unlock_irq(&n->list_lock);
 	}
-	num_objs = num_slabs * cachep->num;
-	active_slabs = num_slabs - num_slabs_free;
-
+	num_objs = total_slabs * cachep->num;
+	active_slabs = total_slabs - free_slabs;
 	active_objs = num_objs - free_objs;
 
 	sinfo->active_objs = active_objs;
 	sinfo->num_objs = num_objs;
 	sinfo->active_slabs = active_slabs;
-	sinfo->num_slabs = num_slabs;
+	sinfo->num_slabs = total_slabs;
 	sinfo->shared_avail = shared_avail;
 	sinfo->limit = cachep->limit;
 	sinfo->batchcount = cachep->batchcount;
diff --git a/mm/slab.h b/mm/slab.h
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -447,8 +447,8 @@ struct kmem_cache_node {
 	struct list_head slabs_partial;	/* partial list first, better asm code */
 	struct list_head slabs_full;
 	struct list_head slabs_free;
-	unsigned long active_slabs;	/* length of slabs_partial+slabs_full */
-	unsigned long free_slabs;	/* length of slabs_free */
+	unsigned long total_slabs;	/* length of all slab lists */
+	unsigned long free_slabs;	/* length of free slab list only */
 	unsigned long free_objects;
 	unsigned int free_limit;
 	unsigned int colour_next;	/* Per-node cache coloring */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
