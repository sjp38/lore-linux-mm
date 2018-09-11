Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 027AF8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 01:36:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 132-v6so11725981pga.18
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 22:36:41 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c19-v6si20646945pfc.18.2018.09.10.22.36.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 22:36:40 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH 7/9] mm: use read_lock for free path
Date: Tue, 11 Sep 2018 13:36:14 +0800
Message-Id: <20180911053616.6894-8-aaron.lu@intel.com>
In-Reply-To: <20180911053616.6894-1-aaron.lu@intel.com>
References: <20180911053616.6894-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Yosef Lev <levyossi@icloud.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Daniel Jordan's patch has made it possible for multiple threads to
operate on a global list with smp_list_del() at any position and
smp_list_add/splice() at head position concurrently without taking
any lock.

This patch makes use of this technique on free list.
To make this happen, add_to_buddy_tail() is removed since only
adding to list head is safe with smp_list_del() so only
add_to_buddy() is used.

Once free path can run concurrently, it is possible for multiple
threads to free pages at the same time. If 2 pages being freed are
buddy, they can miss the oppotunity to be merged.

For this reason, introduce range locks to protect merge operation
that makes sure inside one range, only one merge can happen and a
page's Buddy status is properly set inside the lock. The range is
selected as an order of (MAX_ORDER-1) pages since merge can't
exceed that order.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 include/linux/list.h   |  1 +
 include/linux/mmzone.h |  3 ++
 lib/list.c             | 23 ++++++++++
 mm/page_alloc.c        | 95 +++++++++++++++++++++++-------------------
 4 files changed, 78 insertions(+), 44 deletions(-)

diff --git a/include/linux/list.h b/include/linux/list.h
index 5f203fb55939..608e40f6489e 100644
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -49,6 +49,7 @@ static inline bool __list_del_entry_valid(struct list_head *entry)
 
 extern void smp_list_del(struct list_head *entry);
 extern void smp_list_splice(struct list_head *list, struct list_head *head);
+extern void smp_list_add(struct list_head *entry, struct list_head *head);
 
 /*
  * Insert a new entry between two known consecutive entries.
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e66b8c63d5d1..0ea52e9bb610 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -467,6 +467,9 @@ struct zone {
 	/* Primarily protects free_area */
 	rwlock_t		lock;
 
+	/* Protects merge operation for a range of order=(MAX_ORDER-1) pages */
+	spinlock_t		*range_locks;
+
 	/* Write-intensive fields used by compaction and vmstats. */
 	ZONE_PADDING(_pad2_)
 
diff --git a/lib/list.c b/lib/list.c
index 104faa144abf..3ecf62b88c86 100644
--- a/lib/list.c
+++ b/lib/list.c
@@ -202,3 +202,26 @@ void smp_list_splice(struct list_head *list, struct list_head *head)
 	/* Simultaneously complete the splice and unlock the head node. */
 	WRITE_ONCE(head->next, first);
 }
+
+void smp_list_add(struct list_head *entry, struct list_head *head)
+{
+	struct list_head *succ;
+
+	/*
+	 * Lock the front of @head by replacing its next pointer with NULL.
+	 * Should another thread be adding to the front, wait until it's done.
+	 */
+	succ = READ_ONCE(head->next);
+	while (succ == NULL || cmpxchg(&head->next, succ, NULL) != succ) {
+		cpu_relax();
+		succ = READ_ONCE(head->next);
+	}
+
+	entry->next = succ;
+	entry->prev = head;
+	succ->prev = entry;
+
+	smp_wmb();
+
+	WRITE_ONCE(head->next, entry);
+}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dff3edc60d71..5f5cc671bcf7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -339,6 +339,17 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 }
 #endif
 
+/* Return a pointer to the spinblock for a pageblock this page belongs to */
+static inline spinlock_t *get_range_lock(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long zone_start_pfn = zone->zone_start_pfn;
+	unsigned long range = (page_to_pfn(page) - zone_start_pfn) >>
+								(MAX_ORDER - 1);
+
+	return &zone->range_locks[range];
+}
+
 /* Return a pointer to the bitmap storing bits affecting a block of pages */
 static inline unsigned long *get_pageblock_bitmap(struct page *page,
 							unsigned long pfn)
@@ -697,25 +708,12 @@ static inline void set_page_order(struct page *page, unsigned int order)
 	__SetPageBuddy(page);
 }
 
-static inline void add_to_buddy_common(struct page *page, struct zone *zone,
-					unsigned int order)
+static inline void add_to_buddy(struct page *page, struct zone *zone,
+				unsigned int order, int mt)
 {
 	set_page_order(page, order);
 	atomic_long_inc(&zone->free_area[order].nr_free);
-}
-
-static inline void add_to_buddy_head(struct page *page, struct zone *zone,
-					unsigned int order, int mt)
-{
-	add_to_buddy_common(page, zone, order);
-	list_add(&page->lru, &zone->free_area[order].free_list[mt]);
-}
-
-static inline void add_to_buddy_tail(struct page *page, struct zone *zone,
-					unsigned int order, int mt)
-{
-	add_to_buddy_common(page, zone, order);
-	list_add_tail(&page->lru, &zone->free_area[order].free_list[mt]);
+	smp_list_add(&page->lru, &zone->free_area[order].free_list[mt]);
 }
 
 static inline void rmv_page_order(struct page *page)
@@ -724,12 +722,25 @@ static inline void rmv_page_order(struct page *page)
 	set_page_private(page, 0);
 }
 
+static inline void remove_from_buddy_common(struct page *page,
+				struct zone *zone, unsigned int order)
+{
+	atomic_long_dec(&zone->free_area[order].nr_free);
+	rmv_page_order(page);
+}
+
 static inline void remove_from_buddy(struct page *page, struct zone *zone,
 					unsigned int order)
 {
 	list_del(&page->lru);
-	atomic_long_dec(&zone->free_area[order].nr_free);
-	rmv_page_order(page);
+	remove_from_buddy_common(page, zone, order);
+}
+
+static inline void remove_from_buddy_concurrent(struct page *page,
+				struct zone *zone, unsigned int order)
+{
+	smp_list_del(&page->lru);
+	remove_from_buddy_common(page, zone, order);
 }
 
 /*
@@ -806,6 +817,7 @@ static inline void __free_one_page(struct page *page,
 	unsigned long uninitialized_var(buddy_pfn);
 	struct page *buddy;
 	unsigned int max_order;
+	spinlock_t *range_lock;
 
 	max_order = min_t(unsigned int, MAX_ORDER, pageblock_order + 1);
 
@@ -819,6 +831,8 @@ static inline void __free_one_page(struct page *page,
 	VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 
+	range_lock = get_range_lock(page);
+	spin_lock(range_lock);
 continue_merging:
 	while (order < max_order - 1) {
 		buddy_pfn = __find_buddy_pfn(pfn, order);
@@ -835,7 +849,7 @@ static inline void __free_one_page(struct page *page,
 		if (page_is_guard(buddy))
 			clear_page_guard(zone, buddy, order, migratetype);
 		else
-			remove_from_buddy(buddy, zone, order);
+			remove_from_buddy_concurrent(buddy, zone, order);
 		combined_pfn = buddy_pfn & pfn;
 		page = page + (combined_pfn - pfn);
 		pfn = combined_pfn;
@@ -867,28 +881,8 @@ static inline void __free_one_page(struct page *page,
 	}
 
 done_merging:
-	/*
-	 * If this is not the largest possible page, check if the buddy
-	 * of the next-highest order is free. If it is, it's possible
-	 * that pages are being freed that will coalesce soon. In case,
-	 * that is happening, add the free page to the tail of the list
-	 * so it's less likely to be used soon and more likely to be merged
-	 * as a higher order page
-	 */
-	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)) {
-		struct page *higher_page, *higher_buddy;
-		combined_pfn = buddy_pfn & pfn;
-		higher_page = page + (combined_pfn - pfn);
-		buddy_pfn = __find_buddy_pfn(combined_pfn, order + 1);
-		higher_buddy = higher_page + (buddy_pfn - combined_pfn);
-		if (pfn_valid_within(buddy_pfn) &&
-		    page_is_buddy(higher_page, higher_buddy, order + 1)) {
-			add_to_buddy_tail(page, zone, order, migratetype);
-			return;
-		}
-	}
-
-	add_to_buddy_head(page, zone, order, migratetype);
+	add_to_buddy(page, zone, order, migratetype);
+	spin_unlock(range_lock);
 }
 
 /*
@@ -1154,7 +1148,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		} while (--count && --batch_free && !list_empty(list));
 	}
 
-	write_lock(&zone->lock);
+	read_lock(&zone->lock);
 	isolated_pageblocks = has_isolate_pageblock(zone);
 
 	/*
@@ -1172,7 +1166,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 		__free_one_page(page, page_to_pfn(page), zone, 0, mt);
 		trace_mm_page_pcpu_drain(page, 0, mt);
 	}
-	write_unlock(&zone->lock);
+	read_unlock(&zone->lock);
 }
 
 static void free_one_page(struct zone *zone,
@@ -1826,7 +1820,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		add_to_buddy_head(&page[size], zone, high, migratetype);
+		add_to_buddy(&page[size], zone, high, migratetype);
 	}
 }
 
@@ -6286,6 +6280,18 @@ void __ref free_area_init_core_hotplug(int nid)
 }
 #endif
 
+static void __init setup_range_locks(struct zone *zone)
+{
+	unsigned long nr = (zone->spanned_pages >> (MAX_ORDER - 1)) + 1;
+	unsigned long size = nr * sizeof(spinlock_t);
+	unsigned long i;
+
+	zone->range_locks = memblock_virt_alloc_node_nopanic(size,
+						zone->zone_pgdat->node_id);
+	for (i = 0; i < nr; i++)
+		spin_lock_init(&zone->range_locks[i]);
+}
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -6357,6 +6363,7 @@ static void __init free_area_init_core(struct pglist_data *pgdat)
 		setup_usemap(pgdat, zone, zone_start_pfn, size);
 		init_currently_empty_zone(zone, zone_start_pfn, size);
 		memmap_init(size, nid, j, zone_start_pfn);
+		setup_range_locks(zone);
 	}
 }
 
-- 
2.17.1
