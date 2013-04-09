Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 9DA886B005C
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:50:46 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 03:15:59 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 961F5E002D
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:22:29 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39Lobaq63832070
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:20:37 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39Lodhj018662
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:50:40 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 10/15] mm: Add support to accurately track
 per-memory-region allocation
Date: Wed, 10 Apr 2013 03:17:58 +0530
Message-ID: <20130409214756.4500.97085.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The page allocator needs to be able to detect events such as the first page
allocation in a new region etc, in order to make smart decisions to aid
memory power management. So add the necessary support to accurately track
allocations on a per-region basis.

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 include/linux/mmzone.h |    2 +
 mm/page_alloc.c        |   66 ++++++++++++++++++++++++++++++++++++------------
 2 files changed, 51 insertions(+), 17 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0258c68..6e209e9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -86,6 +86,7 @@ static inline int get_pageblock_migratetype(struct page *page)
 struct mem_region_list {
 	struct list_head	*page_block;
 	unsigned long		nr_free;
+	struct zone_mem_region	*zone_region;
 };
 
 struct free_list {
@@ -341,6 +342,7 @@ struct zone_mem_region {
 	unsigned long end_pfn;
 	unsigned long present_pages;
 	unsigned long spanned_pages;
+	unsigned long nr_free;
 };
 
 struct zone {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 52d8a59..541e4ab 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -625,7 +625,8 @@ out:
 	return prev_region_id;
 }
 
-static void add_to_freelist(struct page *page, struct free_list *free_list)
+static void add_to_freelist(struct page *page, struct free_list *free_list,
+			    int order)
 {
 	struct list_head *prev_region_list, *lru;
 	struct mem_region_list *region;
@@ -636,6 +637,7 @@ static void add_to_freelist(struct page *page, struct free_list *free_list)
 
 	region = &free_list->mr_list[region_id];
 	region->nr_free++;
+	region->zone_region->nr_free += 1 << order;
 
 	if (region->page_block) {
 		list_add_tail(lru, region->page_block);
@@ -690,9 +692,10 @@ out:
  * inside the freelist.
  */
 static void rmqueue_del_from_freelist(struct page *page,
-				      struct free_list *free_list)
+				      struct free_list *free_list, int order)
 {
 	struct list_head *lru = &page->lru;
+	struct mem_region_list *mr_list;
 	int region_id;
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
@@ -703,7 +706,10 @@ static void rmqueue_del_from_freelist(struct page *page,
 	list_del(lru);
 
 	/* Fastpath */
-	if (--(free_list->next_region->nr_free)) {
+	mr_list = free_list->next_region;
+	mr_list->zone_region->nr_free -= 1 << order;
+
+	if (--(mr_list->nr_free)) {
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 		WARN(free_list->next_region->nr_free < 0,
@@ -725,7 +731,8 @@ static void rmqueue_del_from_freelist(struct page *page,
 }
 
 /* Generic delete function for region-aware buddy allocator. */
-static void del_from_freelist(struct page *page, struct free_list *free_list)
+static void del_from_freelist(struct page *page, struct free_list *free_list,
+			      int order)
 {
 	struct list_head *prev_page_lru, *lru, *p;
 	struct mem_region_list *region;
@@ -735,11 +742,12 @@ static void del_from_freelist(struct page *page, struct free_list *free_list)
 
 	/* Try to fastpath, if deleting from the head of the list */
 	if (lru == free_list->list.next)
-		return rmqueue_del_from_freelist(page, free_list);
+		return rmqueue_del_from_freelist(page, free_list, order);
 
 	region_id = page_zone_region_id(page);
 	region = &free_list->mr_list[region_id];
 	region->nr_free--;
+	region->zone_region->nr_free -= 1 << order;
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
 	WARN(region->nr_free < 0, "%s: nr_free is negative\n", __func__);
@@ -794,10 +802,10 @@ page_found:
  * Move a given page from one freelist to another.
  */
 static void move_page_freelist(struct page *page, struct free_list *old_list,
-			       struct free_list *new_list)
+			       struct free_list *new_list, int order)
 {
-	del_from_freelist(page, old_list);
-	add_to_freelist(page, new_list);
+	del_from_freelist(page, old_list, order);
+	add_to_freelist(page, new_list, order);
 }
 
 /*
@@ -863,7 +871,8 @@ static inline void __free_one_page(struct page *page,
 						  migratetype);
 		} else {
 			area = &zone->free_area[order];
-			del_from_freelist(buddy, &area->free_list[migratetype]);
+			del_from_freelist(buddy, &area->free_list[migratetype],
+					  order);
 			area->nr_free--;
 			rmv_page_order(buddy);
 		}
@@ -898,12 +907,13 @@ static inline void __free_one_page(struct page *page,
 			 * switch off this entire "is next-higher buddy free?"
 			 * logic when memory regions are used.
 			 */
-			add_to_freelist(page, &area->free_list[migratetype]);
+			add_to_freelist(page, &area->free_list[migratetype],
+					order);
 			goto out;
 		}
 	}
 
-	add_to_freelist(page, &area->free_list[migratetype]);
+	add_to_freelist(page, &area->free_list[migratetype], order);
 out:
 	area->nr_free++;
 }
@@ -1136,7 +1146,8 @@ static inline void expand(struct zone *zone, struct page *page,
 			continue;
 		}
 #endif
-		add_to_freelist(&page[size], &area->free_list[migratetype]);
+		add_to_freelist(&page[size], &area->free_list[migratetype],
+				high);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -1203,7 +1214,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 
 		page = list_entry(area->free_list[migratetype].list.next,
 							struct page, lru);
-		rmqueue_del_from_freelist(page, &area->free_list[migratetype]);
+		rmqueue_del_from_freelist(page, &area->free_list[migratetype],
+					  current_order);
 		rmv_page_order(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
@@ -1276,7 +1288,7 @@ int move_freepages(struct zone *zone,
 		old_mt = get_freepage_migratetype(page);
 		area = &zone->free_area[order];
 		move_page_freelist(page, &area->free_list[old_mt],
-				    &area->free_list[migratetype]);
+				    &area->free_list[migratetype], order);
 		set_freepage_migratetype(page, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
@@ -1374,7 +1386,8 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			}
 
 			/* Remove the page from the freelists */
-			del_from_freelist(page, &area->free_list[migratetype]);
+			del_from_freelist(page, &area->free_list[migratetype],
+					  current_order);
 			rmv_page_order(page);
 
 			/* Take ownership for orders >= pageblock_order */
@@ -1728,7 +1741,7 @@ static int __isolate_free_page(struct page *page, unsigned int order)
 
 	/* Remove page from free list */
 	mt = get_freepage_migratetype(page);
-	del_from_freelist(page, &zone->free_area[order].free_list[mt]);
+	del_from_freelist(page, &zone->free_area[order].free_list[mt], order);
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
 
@@ -5017,6 +5030,22 @@ static void __meminit init_node_memory_regions(struct pglist_data *pgdat)
 	pgdat->nr_node_regions = idx;
 }
 
+static void __meminit zone_init_free_lists_late(struct zone *zone)
+{
+	struct mem_region_list *mr_list;
+	int order, t, i;
+
+	for_each_migratetype_order(order, t) {
+		for (i = 0; i < zone->nr_zone_regions; i++) {
+			mr_list =
+				&zone->free_area[order].free_list[t].mr_list[i];
+
+			mr_list->nr_free = 0;
+			mr_list->zone_region = &zone->zone_regions[i];
+		}
+	}
+}
+
 static void __meminit init_zone_memory_regions(struct pglist_data *pgdat)
 {
 	unsigned long start_pfn, end_pfn, absent;
@@ -5064,6 +5093,8 @@ static void __meminit init_zone_memory_regions(struct pglist_data *pgdat)
 
 		z->nr_zone_regions = idx;
 
+		zone_init_free_lists_late(z);
+
 		/*
 		 * Revisit the last visited node memory region, in case it
 		 * spans multiple zones.
@@ -6474,7 +6505,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		       pfn, 1 << order, end_pfn);
 #endif
 		mt = get_freepage_migratetype(page);
-		del_from_freelist(page, &zone->free_area[order].free_list[mt]);
+		del_from_freelist(page, &zone->free_area[order].free_list[mt],
+				  order);
 		rmv_page_order(page);
 		zone->free_area[order].nr_free--;
 		for (i = 0; i < (1 << order); i++)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
