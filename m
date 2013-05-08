Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 17C936B0139
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:17 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 09/22] mm: page allocator: Allocate/free order-0 pages from a per-zone magazine
Date: Wed,  8 May 2013 17:02:54 +0100
Message-Id: <1368028987-8369-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch introduces a simple magazine of order-0 pages that sits between
the buddy allocator and the caller. Simplistically there is a "struct
free_area zone->noirq_magazine" in each zone protected by an IRQ-unsafe
spinlock zone->magazine_lock. It replaces the per-cpu allocator that
used to exist but has several properties that may be better depending on
the workload.

1. IRQs do not have to be disabled to access the lists reducing IRQs
   disabled times.

2. As the list is protected by a spinlock, it is not necessary to
   send IPI to drain the list. As the lists are accessible by multiple CPUs,
   it is easier to tune.

3. The magazine_lock is potentially hot but it can be split to have
   one lock per CPU socket to reduce contention. Draining the lists
   in this case would acquire multiple locks be acquired.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |   7 +++
 mm/page_alloc.c        | 114 +++++++++++++++++++++++++++++++++++++++++--------
 mm/vmstat.c            |  14 ++++--
 3 files changed, 114 insertions(+), 21 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3ee9b27..a6f84f1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -361,6 +361,13 @@ struct zone {
 #endif
 	struct free_area	free_area[MAX_ORDER];
 
+	/*
+	 * Keep some order-0 pages on a separate free list
+	 * protected by an irq-unsafe lock
+	 */
+	spinlock_t		magazine_lock;
+	struct free_area	noirq_magazine;
+
 #ifndef CONFIG_SPARSEMEM
 	/*
 	 * Flags for a pageblock_nr_pages block. See pageblock-flags.h.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cd64c27..9ed05a5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -601,6 +601,8 @@ static inline void __free_one_page(struct page *page,
 	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
 out:
 	zone->free_area[order].nr_free++;
+	if (unlikely(!is_migrate_isolate(migratetype)))
+		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 }
 
 static inline int free_pages_check(struct page *page)
@@ -632,8 +634,6 @@ static void free_one_page(struct zone *zone, struct page *page,
 	__count_vm_events(PGFREE, 1 << order);
 
 	__free_one_page(page, zone, order, migratetype);
-	if (unlikely(!is_migrate_isolate(migratetype)))
-		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
 
@@ -1092,6 +1092,8 @@ void mark_free_pages(struct zone *zone)
 }
 #endif /* CONFIG_PM */
 
+#define MAGAZINE_LIMIT (1024)
+
 /*
  * Free a 0-order page
  * cold == 1 ? free a cold page : free a hot page
@@ -1100,13 +1102,51 @@ void free_hot_cold_page(struct page *page, bool cold)
 {
 	struct zone *zone = page_zone(page);
 	int migratetype;
+	struct free_area *area;
 
 	if (!free_pages_prepare(page, 0))
 		return;
 
 	migratetype = get_pageblock_migratetype(page);
 	set_freepage_migratetype(page, migratetype);
-	free_one_page(zone, page, 0, migratetype);
+
+	/* magazine_lock is not safe against IRQs */
+	if (in_interrupt() || irqs_disabled())
+		goto free_one;
+
+	/* Put the free page on the magazine list */
+	spin_lock(&zone->magazine_lock);
+	area = &(zone->noirq_magazine);
+	if (!cold)
+		list_add(&page->lru, &area->free_list[migratetype]);
+	else
+		list_add_tail(&page->lru, &area->free_list[migratetype]);
+	page = NULL;
+
+	/* If the magazine is full, remove a cold page for the buddy list */
+	if (area->nr_free > MAGAZINE_LIMIT) {
+		struct list_head *list = &area->free_list[migratetype];
+		int starttype = migratetype;
+
+		while (list_empty(list)) {
+			if (++migratetype == MIGRATE_PCPTYPES)
+				migratetype = 0;
+			list = &area->free_list[migratetype];;
+		
+			WARN_ON_ONCE(starttype == migratetype);
+		}
+			
+		page = list_entry(list->prev, struct page, lru);
+		list_del(&page->lru);
+	} else {
+		area->nr_free++;
+	}
+	spin_unlock(&zone->magazine_lock);
+
+free_one:
+	/* Free a page back to the buddy lists if necessary */
+	if (page)
+		free_one_page(zone, page, 0, migratetype);
 }
 
 /*
@@ -1216,18 +1256,45 @@ int split_free_page(struct page *page)
 	return nr_pages;
 }
 
+/* Remove a page from the noirq_magazine if one is available */
+static
+struct page *rmqueue_magazine(struct zone *zone, int migratetype)
+{
+	struct page *page = NULL;
+	struct free_area *area;
+
+	/* Check if it is worth acquiring the lock */
+	if (!zone->noirq_magazine.nr_free)
+		return NULL;
+		
+	spin_lock(&zone->magazine_lock);
+	area = &(zone->noirq_magazine);
+	if (list_empty(&area->free_list[migratetype]))
+		goto out;
+
+	/* Page is available in the magazine, allocate it */
+	page = list_entry(area->free_list[migratetype].next, struct page, lru);
+	list_del(&page->lru);
+	area->nr_free--;
+	set_page_private(page, 0);
+
+out:
+	spin_unlock(&zone->magazine_lock);
+	return page;
+}
+
 /*
  * Really, prep_compound_page() should be called from __rmqueue_bulk().  But
  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
  * or two.
  */
 static inline
-struct page *buffered_rmqueue(struct zone *preferred_zone,
+struct page *rmqueue(struct zone *preferred_zone,
 			struct zone *zone, unsigned int order,
 			gfp_t gfp_flags, int migratetype)
 {
 	unsigned long flags;
-	struct page *page;
+	struct page *page = NULL;
 
 	if (unlikely(gfp_flags & __GFP_NOFAIL)) {
 		/*
@@ -1244,13 +1311,27 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 	}
 
 again:
-	spin_lock_irqsave(&zone->lock, flags);
-	page = __rmqueue(zone, order, migratetype);
-	spin_unlock(&zone->lock);
-	if (!page)
-		goto failed;
-	__mod_zone_freepage_state(zone, -(1 << order),
-				  get_freepage_migratetype(page));
+	/*
+	 * For order-0 allocations that are not from irq context, try
+	 * allocate from a separate magazine of free pages
+	 */
+	if (order == 0 && !in_interrupt() && !irqs_disabled())
+		page = rmqueue_magazine(zone, migratetype);
+
+	/* IRQ disabled for buddy list access of updating statistics */
+	local_irq_save(flags);
+
+	if (!page) {
+		spin_lock(&zone->lock);
+		page = __rmqueue(zone, order, migratetype);
+		if (!page) {
+			spin_unlock_irqrestore(&zone->lock, flags);
+			return NULL;
+		}
+		__mod_zone_freepage_state(zone, -(1 << order),
+					get_freepage_migratetype(page));
+		spin_unlock(&zone->lock);
+	}
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
@@ -1260,10 +1341,6 @@ again:
 	if (prep_new_page(page, order, gfp_flags))
 		goto again;
 	return page;
-
-failed:
-	local_irq_restore(flags);
-	return NULL;
 }
 
 #ifdef CONFIG_FAIL_PAGE_ALLOC
@@ -1676,7 +1753,7 @@ zonelist_scan:
 		}
 
 try_this_zone:
-		page = buffered_rmqueue(preferred_zone, zone, order,
+		page = rmqueue(preferred_zone, zone, order,
 						gfp_mask, migratetype);
 		if (page)
 			break;
@@ -3615,6 +3692,8 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 		zone->free_area[order].nr_free = 0;
+		INIT_LIST_HEAD(&zone->noirq_magazine.free_list[t]);
+		zone->noirq_magazine.nr_free = 0;
 	}
 }
 
@@ -4164,6 +4243,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone->name = zone_names[j];
 		spin_lock_init(&zone->lock);
 		spin_lock_init(&zone->lru_lock);
+		spin_lock_init(&zone->magazine_lock);
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 45e699c..7274ca5 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1001,14 +1001,20 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 		seq_printf(m, ", %lu", zone->lowmem_reserve[i]);
 	seq_printf(m,
 		   ")"
-		   "\n  pagesets");
+		   "\n  noirq magazine");
+	seq_printf(m,
+		"\n    cpu: %i"
+		"\n              count: %lu",
+		i,
+		zone->noirq_magazine.nr_free);
+
 #ifdef CONFIG_SMP
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
 
-		pageset = per_cpu_ptr(zone->pageset, i);
-		seq_printf(m, "\n  vm stats threshold: %d",
-				pageset->stat_threshold);
+ 		pageset = per_cpu_ptr(zone->pageset, i);
+		seq_printf(m, "\n  pagesets\n  vm stats threshold: %d",
+ 				pageset->stat_threshold);
 	}
 #endif
 	seq_printf(m,
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
