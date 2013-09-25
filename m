Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id AF2296B003A
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 19:19:00 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so305312pbc.7
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 16:19:00 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 09:18:55 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id EA9462CE8051
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:18:51 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PNIe5M6554026
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:18:40 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8PNIog2013104
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:18:51 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v4 05/40] mm: Add data-structures to describe memory
 regions within the zones' freelists
Date: Thu, 26 Sep 2013 04:44:40 +0530
Message-ID: <20130925231437.26184.47160.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In order to influence page allocation decisions (i.e., to make page-allocation
region-aware), we need to be able to distinguish pageblocks belonging to
different zone memory regions within the zones' (buddy) freelists.

So, within every freelist in a zone, provide pointers to describe the
boundaries of zone memory regions and counters to track the number of free
pageblocks within each region.

Also, fixup the references to the freelist's list_head inside struct free_area.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mmzone.h |   17 ++++++++++++++++-
 mm/compaction.c        |    2 +-
 mm/page_alloc.c        |   23 ++++++++++++-----------
 mm/vmstat.c            |    2 +-
 4 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index a22358c..2ac8025 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -83,8 +83,23 @@ static inline int get_pageblock_migratetype(struct page *page)
 	return get_pageblock_flags_group(page, PB_migrate, PB_migrate_end);
 }
 
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
+	struct mem_region_list	mr_list[MAX_NR_ZONE_REGIONS];
+};
+
 struct free_area {
-	struct list_head	free_list[MIGRATE_TYPES];
+	struct free_list	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
 };
 
diff --git a/mm/compaction.c b/mm/compaction.c
index c437893..511b191 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -858,7 +858,7 @@ static int compact_finished(struct zone *zone,
 		struct free_area *area = &zone->free_area[order];
 
 		/* Job done if page is free of the right migratetype */
-		if (!list_empty(&area->free_list[cc->migratetype]))
+		if (!list_empty(&area->free_list[cc->migratetype].list))
 			return COMPACT_PARTIAL;
 
 		/* Job done if allocation would set block type */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d747f92..e9d8082 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -606,12 +606,13 @@ static inline void __free_one_page(struct page *page,
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
@@ -832,7 +833,7 @@ static inline void expand(struct zone *zone, struct page *page,
 			continue;
 		}
 #endif
-		list_add(&page[size].lru, &area->free_list[migratetype]);
+		list_add(&page[size].lru, &area->free_list[migratetype].list);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -894,10 +895,10 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
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
@@ -969,7 +970,7 @@ int move_freepages(struct zone *zone,
 
 		order = page_order(page);
 		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype]);
+			  &zone->free_area[order].free_list[migratetype].list);
 		set_freepage_migratetype(page, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
@@ -1076,10 +1077,10 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 				break;
 
 			area = &(zone->free_area[current_order]);
-			if (list_empty(&area->free_list[migratetype]))
+			if (list_empty(&area->free_list[migratetype].list))
 				continue;
 
-			page = list_entry(area->free_list[migratetype].next,
+			page = list_entry(area->free_list[migratetype].list.next,
 					struct page, lru);
 			area->nr_free--;
 
@@ -1323,7 +1324,7 @@ void mark_free_pages(struct zone *zone)
 		}
 
 	for_each_migratetype_order(order, t) {
-		list_for_each(curr, &zone->free_area[order].free_list[t]) {
+		list_for_each(curr, &zone->free_area[order].free_list[t].list) {
 			unsigned long i;
 
 			pfn = page_to_pfn(list_entry(curr, struct page, lru));
@@ -3193,7 +3194,7 @@ void show_free_areas(unsigned int filter)
 
 			types[order] = 0;
 			for (type = 0; type < MIGRATE_TYPES; type++) {
-				if (!list_empty(&area->free_list[type]))
+				if (!list_empty(&area->free_list[type].list))
 					types[order] |= 1 << type;
 			}
 		}
@@ -4049,7 +4050,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 {
 	int order, t;
 	for_each_migratetype_order(order, t) {
-		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
+		INIT_LIST_HEAD(&zone->free_area[order].free_list[t].list);
 		zone->free_area[order].nr_free = 0;
 	}
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9bb3145..c967043 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -901,7 +901,7 @@ static void pagetypeinfo_showfree_print(struct seq_file *m,
 
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
