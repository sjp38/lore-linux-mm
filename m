Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84A496B0262
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:08:20 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id kc8so70807029pab.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:20 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id f19si5287787pgk.152.2016.10.13.01.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 01:08:19 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id s8so4533580pfj.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:19 -0700 (PDT)
From: js1304@gmail.com
Subject: [RFC PATCH 3/5] mm/page_alloc: stop instantly reusing freed page
Date: Thu, 13 Oct 2016 17:08:20 +0900
Message-Id: <1476346102-26928-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Allocation/free pattern is usually sequantial. If they are freed to
the buddy list, they can be coalesced. However, we first keep these freed
pages at the pcp list and try to reuse them until threshold is reached
so we don't have enough chance to get a high order freepage. This reusing
would provide us some performance advantages since we don't need to
get the zone lock and we don't pay the cost to check buddy merging.
But, less fragmentation and more high order freepage would compensate
this overhead in other ways. First, we would trigger less direct
compaction which has high overhead. And, there are usecases that uses
high order page to boost their performance.

Instantly resuing freed page seems to provide us computational benefit
but the other affects more precious things like as I/O performance and
memory consumption so I think that it's a good idea to weight
later advantage more.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/mmzone.h |  6 +++--
 mm/page_alloc.c        | 71 ++++++++++++++++++++++++++++++++------------------
 mm/vmstat.c            |  7 ++---
 3 files changed, 53 insertions(+), 31 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7f2ae99..75a92d1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -260,12 +260,14 @@ enum zone_watermarks {
 #define high_wmark_pages(z) (z->watermark[WMARK_HIGH])
 
 struct per_cpu_pages {
-	int count;		/* number of pages in the list */
+	int alloc_count;	/* number of pages in the list */
+	int free_count;		/* number of pages in the list */
 	int high;		/* high watermark, emptying needed */
 	int batch;		/* chunk size for buddy add/remove */
 
 	/* Lists of pages, one per migrate type stored on the pcp-lists */
-	struct list_head lists[MIGRATE_PCPTYPES];
+	struct list_head alloc_lists[MIGRATE_PCPTYPES];
+	struct list_head free_lists[MIGRATE_PCPTYPES];
 };
 
 struct per_cpu_pageset {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 70427bf..a167754 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1091,7 +1091,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			batch_free++;
 			if (++migratetype == MIGRATE_PCPTYPES)
 				migratetype = 0;
-			list = &pcp->lists[migratetype];
+			list = &pcp->free_lists[migratetype];
 		} while (list_empty(list));
 
 		/* This is the only non-empty list. Free them all. */
@@ -2258,10 +2258,10 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 
 	local_irq_save(flags);
 	batch = READ_ONCE(pcp->batch);
-	to_drain = min(pcp->count, batch);
+	to_drain = min(pcp->free_count, batch);
 	if (to_drain > 0) {
 		free_pcppages_bulk(zone, to_drain, pcp);
-		pcp->count -= to_drain;
+		pcp->free_count -= to_drain;
 	}
 	local_irq_restore(flags);
 }
@@ -2279,14 +2279,24 @@ static void drain_pages_zone(unsigned int cpu, struct zone *zone)
 	unsigned long flags;
 	struct per_cpu_pageset *pset;
 	struct per_cpu_pages *pcp;
+	int mt;
 
 	local_irq_save(flags);
 	pset = per_cpu_ptr(zone->pageset, cpu);
 
 	pcp = &pset->pcp;
-	if (pcp->count) {
-		free_pcppages_bulk(zone, pcp->count, pcp);
-		pcp->count = 0;
+	if (pcp->alloc_count) {
+		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
+			list_splice_init(&pcp->alloc_lists[mt],
+				&pcp->free_lists[mt]);
+		}
+		pcp->free_count += pcp->alloc_count;
+		pcp->alloc_count = 0;
+	}
+
+	if (pcp->free_count) {
+		free_pcppages_bulk(zone, pcp->free_count, pcp);
+		pcp->free_count = 0;
 	}
 	local_irq_restore(flags);
 }
@@ -2357,12 +2367,13 @@ void drain_all_pages(struct zone *zone)
 
 		if (zone) {
 			pcp = per_cpu_ptr(zone->pageset, cpu);
-			if (pcp->pcp.count)
+			if (pcp->pcp.alloc_count || pcp->pcp.free_count)
 				has_pcps = true;
 		} else {
 			for_each_populated_zone(z) {
 				pcp = per_cpu_ptr(z->pageset, cpu);
-				if (pcp->pcp.count) {
+				if (pcp->pcp.alloc_count ||
+					pcp->pcp.free_count) {
 					has_pcps = true;
 					break;
 				}
@@ -2454,15 +2465,12 @@ void free_hot_cold_page(struct page *page, bool cold)
 	}
 
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
-	if (!cold)
-		list_add(&page->lru, &pcp->lists[migratetype]);
-	else
-		list_add_tail(&page->lru, &pcp->lists[migratetype]);
-	pcp->count++;
-	if (pcp->count >= pcp->high) {
+	list_add(&page->lru, &pcp->free_lists[migratetype]);
+	pcp->free_count++;
+	if (pcp->free_count >= pcp->batch) {
 		unsigned long batch = READ_ONCE(pcp->batch);
 		free_pcppages_bulk(zone, batch, pcp);
-		pcp->count -= batch;
+		pcp->free_count -= batch;
 	}
 
 out:
@@ -2611,9 +2619,9 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 		local_irq_save(flags);
 		do {
 			pcp = &this_cpu_ptr(zone->pageset)->pcp;
-			list = &pcp->lists[migratetype];
+			list = &pcp->alloc_lists[migratetype];
 			if (list_empty(list)) {
-				pcp->count += rmqueue_bulk(zone, 0,
+				pcp->alloc_count += rmqueue_bulk(zone, 0,
 						pcp->batch, list,
 						migratetype, cold);
 				if (unlikely(list_empty(list)))
@@ -2626,7 +2634,7 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 				page = list_first_entry(list, struct page, lru);
 
 			list_del(&page->lru);
-			pcp->count--;
+			pcp->alloc_count--;
 
 		} while (check_new_pcp(page));
 	} else {
@@ -4258,13 +4266,17 @@ void show_free_areas(unsigned int filter)
 	int cpu;
 	struct zone *zone;
 	pg_data_t *pgdat;
+	struct per_cpu_pages *pcp;
 
 	for_each_populated_zone(zone) {
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
 			continue;
 
-		for_each_online_cpu(cpu)
-			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
+		for_each_online_cpu(cpu) {
+			pcp = &per_cpu_ptr(zone->pageset, cpu)->pcp;
+			free_pcp += pcp->alloc_count;
+			free_pcp += pcp->free_count;
+		}
 	}
 
 	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
@@ -4347,8 +4359,11 @@ void show_free_areas(unsigned int filter)
 			continue;
 
 		free_pcp = 0;
-		for_each_online_cpu(cpu)
-			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
+		for_each_online_cpu(cpu) {
+			pcp = &per_cpu_ptr(zone->pageset, cpu)->pcp;
+			free_pcp += pcp->alloc_count;
+			free_pcp += pcp->free_count;
+		}
 
 		show_node(zone);
 		printk("%s"
@@ -4394,7 +4409,8 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_PAGETABLE)),
 			K(zone_page_state(zone, NR_BOUNCE)),
 			K(free_pcp),
-			K(this_cpu_read(zone->pageset->pcp.count)),
+			K(this_cpu_read(zone->pageset->pcp.alloc_count) +
+				this_cpu_read(zone->pageset->pcp.free_count)),
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
@@ -5251,9 +5267,12 @@ static void pageset_init(struct per_cpu_pageset *p)
 	memset(p, 0, sizeof(*p));
 
 	pcp = &p->pcp;
-	pcp->count = 0;
-	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
-		INIT_LIST_HEAD(&pcp->lists[migratetype]);
+	pcp->alloc_count = 0;
+	pcp->free_count = 0;
+	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++) {
+		INIT_LIST_HEAD(&pcp->alloc_lists[migratetype]);
+		INIT_LIST_HEAD(&pcp->free_lists[migratetype]);
+	}
 }
 
 static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 604f26a..dbb9836 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -676,7 +676,7 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 			 * if not then there is nothing to expire.
 			 */
 			if (!__this_cpu_read(p->expire) ||
-			       !__this_cpu_read(p->pcp.count))
+			       !__this_cpu_read(p->pcp.free_count))
 				continue;
 
 			/*
@@ -690,7 +690,7 @@ static int refresh_cpu_vm_stats(bool do_pagesets)
 			if (__this_cpu_dec_return(p->expire))
 				continue;
 
-			if (__this_cpu_read(p->pcp.count)) {
+			if (__this_cpu_read(p->pcp.free_count)) {
 				drain_zone_pages(zone, this_cpu_ptr(&p->pcp));
 				changes++;
 			}
@@ -1408,7 +1408,8 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 			   "\n              high:  %i"
 			   "\n              batch: %i",
 			   i,
-			   pageset->pcp.count,
+			   pageset->pcp.alloc_count +
+			   pageset->pcp.free_count,
 			   pageset->pcp.high,
 			   pageset->pcp.batch);
 #ifdef CONFIG_SMP
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
