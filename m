Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 922B26B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:54:42 -0500 (EST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 05:49:59 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6JiFZK62783628
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:44:15 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6Jsb46019823
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:54:38 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 5/8] mm: Add data-structures to describe memory regions
 within the zones' freelists
Date: Wed, 07 Nov 2012 01:23:30 +0530
Message-ID: <20121106195326.6941.95816.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In order to influence page allocation decisions (i.e., to make page-allocation
region-aware), we need to be able to distinguish pageblocks belonging to
different zone memory regions within the zones' freelists.

So, within every freelist in a zone, provide pointers to describe the
boundaries of zone memory regions and counters to track the number of free
pageblocks within each region.

Also, fixup the references to the freelist's list_head inside struct free_area.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mmzone.h |   17 ++++++++++++++++-
 mm/compaction.c        |    8 ++++----
 mm/page_alloc.c        |   21 +++++++++++----------
 mm/vmstat.c            |    2 +-
 4 files changed, 32 insertions(+), 16 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3982354..aba4d68 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -82,8 +82,23 @@ static inline int get_pageblock_migratetype(struct page *page)
 
 #define MAX_NR_REGIONS	256
 
+struct mem_region_list {
+	struct list_head	*page_block;
+	unsigned long		nr_free;
+};
+
+struct free_list {
+	struct list_head	list;
+
+	/*
+	 * Demarcates pageblocks belonging to different regions within
+	 * this freelist.
+	 */
+	struct mem_region_list	mr_list[MAX_NR_REGIONS];
+};
+
 struct free_area {
-	struct list_head	free_list[MIGRATE_TYPES];
+	struct free_list	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
 };
 
diff --git a/mm/compaction.c b/mm/compaction.c
index 9eef558..95f5c92 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -247,14 +247,14 @@ static void compact_capture_page(struct compact_control *cc)
 			struct page *page;
 			struct free_area *area;
 			area = &(cc->zone->free_area[order]);
-			if (list_empty(&area->free_list[mtype]))
+			if (list_empty(&area->free_list[mtype].list))
 				continue;
 
 			/* Take the lock and attempt capture of the page */
 			if (!compact_trylock_irqsave(&cc->zone->lock, &flags, cc))
 				return;
-			if (!list_empty(&area->free_list[mtype])) {
-				page = list_entry(area->free_list[mtype].next,
+			if (!list_empty(&area->free_list[mtype].list)) {
+				page = list_entry(area->free_list[mtype].list.next,
 							struct page, lru);
 				if (capture_free_page(page, cc->order, mtype)) {
 					spin_unlock_irqrestore(&cc->zone->lock,
@@ -866,7 +866,7 @@ static int compact_finished(struct zone *zone,
 		for (order = cc->order; order < MAX_ORDER; order++) {
 			struct free_area *area = &zone->free_area[cc->order];
 			/* Job done if page is free of the right migratetype */
-			if (!list_empty(&area->free_list[cc->migratetype]))
+			if (!list_empty(&area->free_list[cc->migratetype].list))
 				return COMPACT_PARTIAL;
 
 			/* Job done if allocation would set block type */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7fd89cd..62d0a9a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -588,12 +588,13 @@ static inline void __free_one_page(struct page *page,
 		higher_buddy = higher_page + (buddy_idx - combined_idx);
 		if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
 			list_add_tail(&page->lru,
-				&zone->free_area[order].free_list[migratetype]);
+				&zone->free_area[order].free_list[migratetype].list);
 			goto out;
 		}
 	}
 
-	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
+	list_add(&page->lru,
+		&zone->free_area[order].free_list[migratetype].list);
 out:
 	zone->free_area[order].nr_free++;
 }
@@ -811,7 +812,7 @@ static inline void expand(struct zone *zone, struct page *page,
 			continue;
 		}
 #endif
-		list_add(&page[size].lru, &area->free_list[migratetype]);
+		list_add(&page[size].lru, &area->free_list[migratetype].list);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -873,10 +874,10 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 	/* Find a page of the appropriate size in the preferred list */
 	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
 		area = &(zone->free_area[current_order]);
-		if (list_empty(&area->free_list[migratetype]))
+		if (list_empty(&area->free_list[migratetype].list))
 			continue;
 
-		page = list_entry(area->free_list[migratetype].next,
+		page = list_entry(area->free_list[migratetype].list.next,
 							struct page, lru);
 		list_del(&page->lru);
 		rmv_page_order(page);
@@ -946,7 +947,7 @@ int move_freepages(struct zone *zone,
 
 		order = page_order(page);
 		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype]);
+			  &zone->free_area[order].free_list[migratetype].list);
 		set_freepage_migratetype(page, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
@@ -1007,10 +1008,10 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 				break;
 
 			area = &(zone->free_area[current_order]);
-			if (list_empty(&area->free_list[migratetype]))
+			if (list_empty(&area->free_list[migratetype].list))
 				continue;
 
-			page = list_entry(area->free_list[migratetype].next,
+			page = list_entry(area->free_list[migratetype].list.next,
 					struct page, lru);
 			area->nr_free--;
 
@@ -1274,7 +1275,7 @@ void mark_free_pages(struct zone *zone)
 		}
 
 	for_each_migratetype_order(order, t) {
-		list_for_each(curr, &zone->free_area[order].free_list[t]) {
+		list_for_each(curr, &zone->free_area[order].free_list[t].list) {
 			unsigned long i;
 
 			pfn = page_to_pfn(list_entry(curr, struct page, lru));
@@ -3859,7 +3860,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 {
 	int order, t;
 	for_each_migratetype_order(order, t) {
-		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
+		INIT_LIST_HEAD(&zone->free_area[order].free_list[t].list);
 		zone->free_area[order].nr_free = 0;
 	}
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c737057..8183331 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -847,7 +847,7 @@ static void pagetypeinfo_showfree_print(struct seq_file *m,
 
 			area = &(zone->free_area[order]);
 
-			list_for_each(curr, &area->free_list[mtype])
+			list_for_each(curr, &area->free_list[mtype].list)
 				freecount++;
 			seq_printf(m, "%6lu ", freecount);
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
