Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 885056B0005
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 00:31:45 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id 36so10511776plb.18
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 21:31:45 -0800 (PST)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id d12si3387082pgu.218.2018.02.04.21.31.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Feb 2018 21:31:43 -0800 (PST)
Date: Mon, 5 Feb 2018 13:32:25 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH 2/2] rmqueue_bulk: avoid touching page structures under
 zone->lock
Message-ID: <20180205053225.GD16980@intel.com>
References: <20180124023050.20097-1-aaron.lu@intel.com>
 <20180205053013.GB16980@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180205053013.GB16980@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Daniel Jordan <daniel.m.jordan@oracle.com>

Profile on Intel Skylake server shows the most time consuming part
under zone->lock on allocation path is accessing those to-be-returned
page's struct page in rmqueue_bulk() and its child functions.

We do not really need to touch all those to-be-returned pages under
zone->lock, just need to move them out of the order 0's free_list and
adjust area->nr_free under zone->lock, other operations on page structure
like rmv_page_order(page) etc. could be done outside zone->lock.

So if it's possible to know the 1st and the last page structure of the
pcp->batch number pages in the free_list, we can achieve the above
without needing to touch all those page structures in between. The
problem is, the free page is linked in a doubly list so we only know
where the head and tail is, but not the Nth element in the list.

Assume order0 mt=Movable free_list has 7 pages available:
    head <-> p7 <-> p6 <-> p5 <-> p4 <-> p3 <-> p2 <-> p1

One experiment I have done here is to add a new list for it: say
cluster list, where it will link pages of every pcp->batch(th) element
in the free_list.

Take pcp->batch=3 as an example, we have:

free_list:     head <-> p7 <-> p6 <-> p5 <-> p4 <-> p3 <-> p2 <-> p1
cluster_list:  head <--------> p6 <---------------> p3

Let's call p6-p4 a cluster, similarly, p3-p1 is another cluster.

Then every time rmqueue_bulk() is called to get 3 pages, we will iterate
the cluster_list first. If cluster list is not empty, we can quickly locate
the first and last page, p6 and p4 in this case(p4 is retrieved by checking
p6's next on cluster_list and then check p3's prev on free_list). This way,
we can reduce the need to touch all those page structures in between under
zone->lock.

Note: a common pcp->batch should be 31 since it is the default PCP batch number.

With this change, on 2 sockets Skylake server, with will-it-scale/page_fault1
full load test, zone lock has gone, lru_lock contention rose to 70% and
performance increased by 16.7% compared to vanilla.

There are some fundemental problems with this patch though:
1 When compaction occurs, the number of pages in a cluster could be less than
  predefined; this will make "1 cluster can satify the request" not true any more.
  Due to this reason, the patch currently requires no compaction to happen;
2 When new pages are freed to order 0 free_list, it could merge with its buddy
  and that would also cause fewer pages left in a cluster. Thus, no merge
  for order-0 is required for this patch to work;
3 Similarly, when fallback allocation happens, the same problem could happen again.

Considering the above listed problems, this patch can only serve as a POC that
cache miss is the most time consuming operation in big server. Your comments
on a possible way to overcome them are greatly appreciated.

Suggested-by: Ying Huang <ying.huang@intel.com>
Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 include/linux/mm_types.h |  43 ++++++++++--------
 include/linux/mmzone.h   |   7 +++
 mm/page_alloc.c          | 114 ++++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 141 insertions(+), 23 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cfd0ac4e5e0e..e7aee48a224a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -43,26 +43,33 @@ struct page {
 	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
-	union {
-		struct address_space *mapping;	/* If low bit clear, points to
-						 * inode address_space, or NULL.
-						 * If page mapped as anonymous
-						 * memory, low bit is set, and
-						 * it points to anon_vma object
-						 * or KSM private structure. See
-						 * PAGE_MAPPING_ANON and
-						 * PAGE_MAPPING_KSM.
-						 */
-		void *s_mem;			/* slab first object */
-		atomic_t compound_mapcount;	/* first tail page */
-		/* page_deferred_list().next	 -- second tail page */
-	};
 
-	/* Second double word */
 	union {
-		pgoff_t index;		/* Our offset within mapping. */
-		void *freelist;		/* sl[aou]b first free object */
-		/* page_deferred_list().prev	-- second tail page */
+		struct {
+			union {
+				struct address_space *mapping;	/* If low bit clear, points to
+								 * inode address_space, or NULL.
+								 * If page mapped as anonymous
+								 * memory, low bit is set, and
+								 * it points to anon_vma object
+								 * or KSM private structure. See
+								 * PAGE_MAPPING_ANON and
+								 * PAGE_MAPPING_KSM.
+								 */
+				void *s_mem;			/* slab first object */
+				atomic_t compound_mapcount;	/* first tail page */
+				/* page_deferred_list().next	 -- second tail page */
+			};
+
+			/* Second double word */
+			union {
+				pgoff_t index;		/* Our offset within mapping. */
+				void *freelist;		/* sl[aou]b first free object */
+				/* page_deferred_list().prev	-- second tail page */
+			};
+		};
+
+		struct list_head cluster;
 	};
 
 	union {
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 67f2e3c38939..3f1451213184 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -355,6 +355,12 @@ enum zone_type {
 
 #ifndef __GENERATING_BOUNDS_H
 
+struct order0_cluster {
+	struct list_head list[MIGRATE_PCPTYPES];
+	unsigned long offset[MIGRATE_PCPTYPES];
+	int batch;
+};
+
 struct zone {
 	/* Read-mostly fields */
 
@@ -459,6 +465,7 @@ struct zone {
 
 	/* free areas of different sizes */
 	struct free_area	free_area[MAX_ORDER];
+	struct order0_cluster   order0_cluster;
 
 	/* zone flags, see below */
 	unsigned long		flags;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9497c8c5f808..3eaafe597a66 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -736,6 +736,7 @@ static inline void rmv_page_order(struct page *page)
 {
 	__ClearPageBuddy(page);
 	set_page_private(page, 0);
+	BUG_ON(page->cluster.next);
 }
 
 /*
@@ -793,6 +794,9 @@ static void inline __do_merge(struct page *page, unsigned int order,
 	VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 
+	/* order0 merge doesn't work yet */
+	BUG_ON(!order);
+
 continue_merging:
 	while (order < max_order - 1) {
 		buddy_pfn = __find_buddy_pfn(pfn, order);
@@ -883,6 +887,19 @@ void do_merge(struct zone *zone, struct page *page, int migratetype)
 	__do_merge(page, 0, zone, migratetype);
 }
 
+static inline void add_to_order0_free_list(struct page *page, struct zone *zone, int mt)
+{
+	struct order0_cluster *cluster = &zone->order0_cluster;
+
+	list_add(&page->lru, &zone->free_area[0].free_list[mt]);
+
+	/* If this is the pcp->batch(th) page, link it to the cluster list */
+	if (mt < MIGRATE_PCPTYPES && !(++cluster->offset[mt] % cluster->batch)) {
+		list_add(&page->cluster, &cluster->list[mt]);
+		cluster->offset[mt] = 0;
+	}
+}
+
 static inline bool should_skip_merge(struct zone *zone, unsigned int order)
 {
 #ifdef CONFIG_COMPACTION
@@ -929,7 +946,7 @@ static inline void __free_one_page(struct page *page,
 		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 
 	if (should_skip_merge(zone, order)) {
-		list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
+		add_to_order0_free_list(page, zone, migratetype);
 		/*
 		 * 1 << 16 set on page->private to indicate this order0
 		 * page skipped merging during free time
@@ -1732,7 +1749,10 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		list_add(&page[size].lru, &area->free_list[migratetype]);
+		if (high)
+			list_add(&page[size].lru, &area->free_list[migratetype]);
+		else
+			add_to_order0_free_list(&page[size], zone, migratetype);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -1881,6 +1901,11 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 		list_del(&page->lru);
 		rmv_page_order(page);
 		area->nr_free--;
+		if (!current_order && migratetype < MIGRATE_PCPTYPES) {
+			BUG_ON(!zone->order0_cluster.offset[migratetype]);
+			BUG_ON(page->cluster.next);
+			zone->order0_cluster.offset[migratetype]--;
+		}
 		expand(zone, page, order, current_order, area, migratetype);
 		set_pcppage_migratetype(page, migratetype);
 		return page;
@@ -1968,8 +1993,13 @@ static int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		list_move(&page->lru,
+		if (order) {
+			list_move(&page->lru,
 			  &zone->free_area[order].free_list[migratetype]);
+		} else {
+			__list_del_entry(&page->lru);
+			add_to_order0_free_list(page, zone, migratetype);
+		}
 		page += 1 << order;
 		pages_moved += 1 << order;
 	}
@@ -2118,7 +2148,12 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 
 single_page:
 	area = &zone->free_area[current_order];
-	list_move(&page->lru, &area->free_list[start_type]);
+	if (current_order)
+		list_move(&page->lru, &area->free_list[start_type]);
+	else {
+		__list_del_entry(&page->lru);
+		add_to_order0_free_list(page, zone, start_type);
+	}
 }
 
 /*
@@ -2379,6 +2414,45 @@ __rmqueue(struct zone *zone, unsigned int order, int migratetype)
 	return page;
 }
 
+static noinline int rmqueue_bulk_cluster(struct zone *zone, unsigned int order,
+			unsigned long count, struct list_head *list,
+			int migratetype)
+{
+	struct list_head *cluster_head;
+	struct page *head, *tail;
+
+	cluster_head = &zone->order0_cluster.list[migratetype];
+	head = list_first_entry_or_null(cluster_head, struct page, cluster);
+	if (!head)
+		return 0;
+
+	if (head->cluster.next == cluster_head)
+		tail = list_last_entry(&zone->free_area[0].free_list[migratetype], struct page, lru);
+	else {
+		struct page *tmp = list_entry(head->cluster.next, struct page, cluster);
+		tail = list_entry(tmp->lru.prev, struct page, lru);
+	}
+
+	zone->free_area[0].nr_free -= count;
+
+	/* Remove the page from the cluster list */
+	list_del(&head->cluster);
+	/* Restore the two page fields */
+	head->cluster.next = head->cluster.prev = NULL;
+
+	/* Take the pcp->batch pages off free_area list */
+	tail->lru.next->prev = head->lru.prev;
+	head->lru.prev->next = tail->lru.next;
+
+	/* Attach them to list */
+	head->lru.prev = list;
+	list->next = &head->lru;
+	tail->lru.next = list;
+	list->prev = &tail->lru;
+
+	return 1;
+}
+
 /*
  * Obtain a specified number of elements from the buddy allocator, all under
  * a single hold of the lock, for efficiency.  Add them to the supplied list.
@@ -2391,6 +2465,28 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 	int i, alloced = 0;
 
 	spin_lock(&zone->lock);
+	if (count == zone->order0_cluster.batch &&
+	    rmqueue_bulk_cluster(zone, order, count, list, migratetype)) {
+		struct page *page, *tmp;
+		spin_unlock(&zone->lock);
+
+		i = alloced = count;
+		list_for_each_entry_safe(page, tmp, list, lru) {
+			rmv_page_order(page);
+			set_pcppage_migratetype(page, migratetype);
+
+			if (unlikely(check_pcp_refill(page))) {
+				list_del(&page->lru);
+				alloced--;
+				continue;
+			}
+			if (is_migrate_cma(get_pcppage_migratetype(page)))
+				__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
+						-(1 << order));
+		}
+		goto done_alloc;
+	}
+
 	for (i = 0; i < count; ++i) {
 		struct page *page = __rmqueue(zone, order, migratetype);
 		if (unlikely(page == NULL))
@@ -2415,7 +2511,9 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
 					      -(1 << order));
 	}
+	spin_unlock(&zone->lock);
 
+done_alloc:
 	/*
 	 * i pages were removed from the buddy list even if some leak due
 	 * to check_pcp_refill failing so adjust NR_FREE_PAGES based
@@ -2423,7 +2521,6 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 	 * pages added to the pcp list.
 	 */
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
-	spin_unlock(&zone->lock);
 	return alloced;
 }
 
@@ -5451,6 +5548,10 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 		zone->free_area[order].nr_free = 0;
+		if (!order && t < MIGRATE_PCPTYPES) {
+			INIT_LIST_HEAD(&zone->order0_cluster.list[t]);
+			zone->order0_cluster.offset[t] = 0;
+		}
 	}
 }
 
@@ -5488,6 +5589,9 @@ static int zone_batchsize(struct zone *zone)
 	 * and the other with pages of the other colors.
 	 */
 	batch = rounddown_pow_of_two(batch + batch/2) - 1;
+	if (batch < 1)
+		batch = 1;
+	zone->order0_cluster.batch = batch;
 
 	return batch;
 
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
