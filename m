Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EF5586B0037
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 13:02:00 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so15671337pde.35
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 10:02:00 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xu6si8956825pab.167.2014.01.03.10.01.54
        for <linux-mm@kvack.org>;
        Fri, 03 Jan 2014 10:01:55 -0800 (PST)
Subject: [PATCH 1/9] mm: slab/slub: use page->list consistently instead of page->lru
From: Dave Hansen <dave@sr71.net>
Date: Fri, 03 Jan 2014 10:01:48 -0800
References: <20140103180147.6566F7C1@viggo.jf.intel.com>
In-Reply-To: <20140103180147.6566F7C1@viggo.jf.intel.com>
Message-Id: <20140103180148.A61B8590@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

'struct page' has two list_head fields: 'lru' and 'list'.
Conveniently, they are unioned together.  This means that code
can use them interchangably, which gets horribly confusing like
with this nugget from slab.c:

>	list_del(&page->lru);
>	if (page->active == cachep->num)
>		list_add(&page->list, &n->slabs_full);

This patch makes the slab and slub code use page->list
universally instead of mixing ->list and ->lru.

It also adds some comments to attempt to keep new users from
picking up uses of ->list.

So, the new rule is: page->list is what the slabs use.  page->lru
is for everybody else.  This is a pretty arbitrary rule, but we
need _something_.  Maybe we should just axe the ->list one and
make the sl?bs use ->lru.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/include/linux/mm_types.h |    5 ++
 linux.git-davehans/mm/slab.c                |   50 ++++++++++++++--------------
 2 files changed, 29 insertions(+), 26 deletions(-)

diff -puN include/linux/mm_types.h~make-slab-use-page-lru-vs-list-consistently include/linux/mm_types.h
--- linux.git/include/linux/mm_types.h~make-slab-use-page-lru-vs-list-consistently	2014-01-02 13:40:29.087256768 -0800
+++ linux.git-davehans/include/linux/mm_types.h	2014-01-02 13:40:29.093257038 -0800
@@ -124,6 +124,8 @@ struct page {
 	union {
 		struct list_head lru;	/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
+					 * Can be used as a generic list
+					 * by the page owner.
 					 */
 		struct {		/* slub per cpu partial pages */
 			struct page *next;	/* Next partial slab */
@@ -136,7 +138,8 @@ struct page {
 #endif
 		};
 
-		struct list_head list;	/* slobs list of pages */
+		struct list_head list;	/* sl[aou]bs list of pages.
+					 * do not use outside of slabs */
 		struct slab *slab_page; /* slab fields */
 		struct rcu_head rcu_head;	/* Used by SLAB
 						 * when destroying via RCU
diff -puN mm/slab.c~make-slab-use-page-lru-vs-list-consistently mm/slab.c
--- linux.git/mm/slab.c~make-slab-use-page-lru-vs-list-consistently	2014-01-02 13:40:29.090256903 -0800
+++ linux.git-davehans/mm/slab.c	2014-01-02 13:40:29.095257128 -0800
@@ -765,15 +765,15 @@ static void recheck_pfmemalloc_active(st
 		return;
 
 	spin_lock_irqsave(&n->list_lock, flags);
-	list_for_each_entry(page, &n->slabs_full, lru)
+	list_for_each_entry(page, &n->slabs_full, list)
 		if (is_slab_pfmemalloc(page))
 			goto out;
 
-	list_for_each_entry(page, &n->slabs_partial, lru)
+	list_for_each_entry(page, &n->slabs_partial, list)
 		if (is_slab_pfmemalloc(page))
 			goto out;
 
-	list_for_each_entry(page, &n->slabs_free, lru)
+	list_for_each_entry(page, &n->slabs_free, list)
 		if (is_slab_pfmemalloc(page))
 			goto out;
 
@@ -1428,7 +1428,7 @@ void __init kmem_cache_init(void)
 {
 	int i;
 
-	BUILD_BUG_ON(sizeof(((struct page *)NULL)->lru) <
+	BUILD_BUG_ON(sizeof(((struct page *)NULL)->list) <
 					sizeof(struct rcu_head));
 	kmem_cache = &kmem_cache_boot;
 	setup_node_pointer(kmem_cache);
@@ -1624,15 +1624,15 @@ slab_out_of_memory(struct kmem_cache *ca
 			continue;
 
 		spin_lock_irqsave(&n->list_lock, flags);
-		list_for_each_entry(page, &n->slabs_full, lru) {
+		list_for_each_entry(page, &n->slabs_full, list) {
 			active_objs += cachep->num;
 			active_slabs++;
 		}
-		list_for_each_entry(page, &n->slabs_partial, lru) {
+		list_for_each_entry(page, &n->slabs_partial, list) {
 			active_objs += page->active;
 			active_slabs++;
 		}
-		list_for_each_entry(page, &n->slabs_free, lru)
+		list_for_each_entry(page, &n->slabs_free, list)
 			num_slabs++;
 
 		free_objects += n->free_objects;
@@ -2424,11 +2424,11 @@ static int drain_freelist(struct kmem_ca
 			goto out;
 		}
 
-		page = list_entry(p, struct page, lru);
+		page = list_entry(p, struct page, list);
 #if DEBUG
 		BUG_ON(page->active);
 #endif
-		list_del(&page->lru);
+		list_del(&page->list);
 		/*
 		 * Safe to drop the lock. The slab is no longer linked
 		 * to the cache.
@@ -2721,7 +2721,7 @@ static int cache_grow(struct kmem_cache
 	spin_lock(&n->list_lock);
 
 	/* Make slab active. */
-	list_add_tail(&page->lru, &(n->slabs_free));
+	list_add_tail(&page->list, &(n->slabs_free));
 	STATS_INC_GROWN(cachep);
 	n->free_objects += cachep->num;
 	spin_unlock(&n->list_lock);
@@ -2864,7 +2864,7 @@ retry:
 				goto must_grow;
 		}
 
-		page = list_entry(entry, struct page, lru);
+		page = list_entry(entry, struct page, list);
 		check_spinlock_acquired(cachep);
 
 		/*
@@ -2884,7 +2884,7 @@ retry:
 		}
 
 		/* move slabp to correct slabp list: */
-		list_del(&page->lru);
+		list_del(&page->list);
 		if (page->active == cachep->num)
 			list_add(&page->list, &n->slabs_full);
 		else
@@ -3163,7 +3163,7 @@ retry:
 			goto must_grow;
 	}
 
-	page = list_entry(entry, struct page, lru);
+	page = list_entry(entry, struct page, list);
 	check_spinlock_acquired_node(cachep, nodeid);
 
 	STATS_INC_NODEALLOCS(cachep);
@@ -3175,12 +3175,12 @@ retry:
 	obj = slab_get_obj(cachep, page, nodeid);
 	n->free_objects--;
 	/* move slabp to correct slabp list: */
-	list_del(&page->lru);
+	list_del(&page->list);
 
 	if (page->active == cachep->num)
-		list_add(&page->lru, &n->slabs_full);
+		list_add(&page->list, &n->slabs_full);
 	else
-		list_add(&page->lru, &n->slabs_partial);
+		list_add(&page->list, &n->slabs_partial);
 
 	spin_unlock(&n->list_lock);
 	goto done;
@@ -3337,7 +3337,7 @@ static void free_block(struct kmem_cache
 
 		page = virt_to_head_page(objp);
 		n = cachep->node[node];
-		list_del(&page->lru);
+		list_del(&page->list);
 		check_spinlock_acquired_node(cachep, node);
 		slab_put_obj(cachep, page, objp, node);
 		STATS_DEC_ACTIVE(cachep);
@@ -3355,14 +3355,14 @@ static void free_block(struct kmem_cache
 				 */
 				slab_destroy(cachep, page);
 			} else {
-				list_add(&page->lru, &n->slabs_free);
+				list_add(&page->list, &n->slabs_free);
 			}
 		} else {
 			/* Unconditionally move a slab to the end of the
 			 * partial list on free - maximum time for the
 			 * other objects to be freed, too.
 			 */
-			list_add_tail(&page->lru, &n->slabs_partial);
+			list_add_tail(&page->list, &n->slabs_partial);
 		}
 	}
 }
@@ -3404,7 +3404,7 @@ free_done:
 		while (p != &(n->slabs_free)) {
 			struct page *page;
 
-			page = list_entry(p, struct page, lru);
+			page = list_entry(p, struct page, list);
 			BUG_ON(page->active);
 
 			i++;
@@ -4029,13 +4029,13 @@ void get_slabinfo(struct kmem_cache *cac
 		check_irq_on();
 		spin_lock_irq(&n->list_lock);
 
-		list_for_each_entry(page, &n->slabs_full, lru) {
+		list_for_each_entry(page, &n->slabs_full, list) {
 			if (page->active != cachep->num && !error)
 				error = "slabs_full accounting error";
 			active_objs += cachep->num;
 			active_slabs++;
 		}
-		list_for_each_entry(page, &n->slabs_partial, lru) {
+		list_for_each_entry(page, &n->slabs_partial, list) {
 			if (page->active == cachep->num && !error)
 				error = "slabs_partial accounting error";
 			if (!page->active && !error)
@@ -4043,7 +4043,7 @@ void get_slabinfo(struct kmem_cache *cac
 			active_objs += page->active;
 			active_slabs++;
 		}
-		list_for_each_entry(page, &n->slabs_free, lru) {
+		list_for_each_entry(page, &n->slabs_free, list) {
 			if (page->active && !error)
 				error = "slabs_free accounting error";
 			num_slabs++;
@@ -4266,9 +4266,9 @@ static int leaks_show(struct seq_file *m
 		check_irq_on();
 		spin_lock_irq(&n->list_lock);
 
-		list_for_each_entry(page, &n->slabs_full, lru)
+		list_for_each_entry(page, &n->slabs_full, list)
 			handle_slab(x, cachep, page);
-		list_for_each_entry(page, &n->slabs_partial, lru)
+		list_for_each_entry(page, &n->slabs_partial, list)
 			handle_slab(x, cachep, page);
 		spin_unlock_irq(&n->list_lock);
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
