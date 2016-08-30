Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B43B83116
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 20:45:12 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j203so14960188oih.1
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 17:45:12 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id i20si1674135iti.53.2016.08.29.17.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 17:45:11 -0700 (PDT)
From: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Subject: [PATCH v4 resend] mm/slab: Improve performance of gathering slabinfo stats
Date: Mon, 29 Aug 2016 17:44:36 -0700
Message-Id: <1472517876-26814-1-git-send-email-aruna.ramakrishna@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aruna.ramakrishna@oracle.com, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

On large systems, when some slab caches grow to millions of objects (and
many gigabytes), running 'cat /proc/slabinfo' can take up to 1-2 seconds.
During this time, interrupts are disabled while walking the slab lists
(slabs_full, slabs_partial, and slabs_free) for each node, and this
sometimes causes timeouts in other drivers (for instance, Infiniband).

This patch optimizes 'cat /proc/slabinfo' by maintaining a counter for
total number of allocated slabs per node, per cache. This counter is
updated when a slab is created or destroyed. This enables us to skip
traversing the slabs_full list while gathering slabinfo statistics, and
since slabs_full tends to be the biggest list when the cache is large, it
results in a dramatic performance improvement. Getting slabinfo statistics
now only requires walking the slabs_free and slabs_partial lists, and
those lists are usually much smaller than slabs_full. We tested this after
growing the dentry cache to 70GB, and the performance improved from 2s to
5ms.

Signed-off-by: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
Note: this has been tested only on x86_64.

 mm/slab.c | 43 +++++++++++++++++++++++++++----------------
 mm/slab.h |  1 +
 2 files changed, 28 insertions(+), 16 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index b672710..042017e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -233,6 +233,7 @@ static void kmem_cache_node_init(struct kmem_cache_node *parent)
 	spin_lock_init(&parent->list_lock);
 	parent->free_objects = 0;
 	parent->free_touched = 0;
+	parent->num_slabs = 0;
 }
 
 #define MAKE_LIST(cachep, listp, slab, nodeid)				\
@@ -1394,24 +1395,27 @@ slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 	for_each_kmem_cache_node(cachep, node, n) {
 		unsigned long active_objs = 0, num_objs = 0, free_objects = 0;
 		unsigned long active_slabs = 0, num_slabs = 0;
+		unsigned long num_slabs_partial = 0, num_slabs_free = 0;
+		unsigned long num_slabs_full;
 
 		spin_lock_irqsave(&n->list_lock, flags);
-		list_for_each_entry(page, &n->slabs_full, lru) {
-			active_objs += cachep->num;
-			active_slabs++;
-		}
+		num_slabs = n->num_slabs;
 		list_for_each_entry(page, &n->slabs_partial, lru) {
 			active_objs += page->active;
-			active_slabs++;
+			num_slabs_partial++;
 		}
 		list_for_each_entry(page, &n->slabs_free, lru)
-			num_slabs++;
+			num_slabs_free++;
 
 		free_objects += n->free_objects;
 		spin_unlock_irqrestore(&n->list_lock, flags);
 
-		num_slabs += active_slabs;
 		num_objs = num_slabs * cachep->num;
+		active_slabs = num_slabs - num_slabs_free;
+		num_slabs_full = num_slabs -
+			(num_slabs_partial + num_slabs_free);
+		active_objs += (num_slabs_full * cachep->num);
+
 		pr_warn("  node %d: slabs: %ld/%ld, objs: %ld/%ld, free: %ld\n",
 			node, active_slabs, num_slabs, active_objs, num_objs,
 			free_objects);
@@ -2326,6 +2330,7 @@ static int drain_freelist(struct kmem_cache *cache,
 
 		page = list_entry(p, struct page, lru);
 		list_del(&page->lru);
+		n->num_slabs--;
 		/*
 		 * Safe to drop the lock. The slab is no longer linked
 		 * to the cache.
@@ -2764,6 +2769,8 @@ static void cache_grow_end(struct kmem_cache *cachep, struct page *page)
 		list_add_tail(&page->lru, &(n->slabs_free));
 	else
 		fixup_slab_list(cachep, n, page, &list);
+
+	n->num_slabs++;
 	STATS_INC_GROWN(cachep);
 	n->free_objects += cachep->num - page->active;
 	spin_unlock(&n->list_lock);
@@ -3455,6 +3462,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp,
 
 		page = list_last_entry(&n->slabs_free, struct page, lru);
 		list_move(&page->lru, list);
+		n->num_slabs--;
 	}
 }
 
@@ -4111,6 +4119,8 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 	unsigned long num_objs;
 	unsigned long active_slabs = 0;
 	unsigned long num_slabs, free_objects = 0, shared_avail = 0;
+	unsigned long num_slabs_partial = 0, num_slabs_free = 0;
+	unsigned long num_slabs_full = 0;
 	const char *name;
 	char *error = NULL;
 	int node;
@@ -4123,33 +4133,34 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 		check_irq_on();
 		spin_lock_irq(&n->list_lock);
 
-		list_for_each_entry(page, &n->slabs_full, lru) {
-			if (page->active != cachep->num && !error)
-				error = "slabs_full accounting error";
-			active_objs += cachep->num;
-			active_slabs++;
-		}
+		num_slabs += n->num_slabs;
+
 		list_for_each_entry(page, &n->slabs_partial, lru) {
 			if (page->active == cachep->num && !error)
 				error = "slabs_partial accounting error";
 			if (!page->active && !error)
 				error = "slabs_partial accounting error";
 			active_objs += page->active;
-			active_slabs++;
+			num_slabs_partial++;
 		}
+
 		list_for_each_entry(page, &n->slabs_free, lru) {
 			if (page->active && !error)
 				error = "slabs_free accounting error";
-			num_slabs++;
+			num_slabs_free++;
 		}
+
 		free_objects += n->free_objects;
 		if (n->shared)
 			shared_avail += n->shared->avail;
 
 		spin_unlock_irq(&n->list_lock);
 	}
-	num_slabs += active_slabs;
 	num_objs = num_slabs * cachep->num;
+	active_slabs = num_slabs - num_slabs_free;
+	num_slabs_full = num_slabs - (num_slabs_partial + num_slabs_free);
+	active_objs += (num_slabs_full * cachep->num);
+
 	if (num_objs - active_objs != free_objects && !error)
 		error = "free_objects accounting error";
 
diff --git a/mm/slab.h b/mm/slab.h
index 9653f2e..bc05fdc 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -432,6 +432,7 @@ struct kmem_cache_node {
 	struct list_head slabs_partial;	/* partial list first, better asm code */
 	struct list_head slabs_full;
 	struct list_head slabs_free;
+	unsigned long num_slabs;
 	unsigned long free_objects;
 	unsigned int free_limit;
 	unsigned int colour_next;	/* Per-node cache coloring */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
