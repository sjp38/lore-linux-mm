Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id EF2246B003A
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:49:40 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 03:15:13 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 64C0B1258055
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:20:58 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39LnS6c4129032
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:19:29 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39LnVQj020109
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:49:32 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 05/15] mm: Add data-structures to describe memory
 regions within the zones' freelists
Date: Wed, 10 Apr 2013 03:16:58 +0530
Message-ID: <20130409214655.4500.16003.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
index f772e05..76667bf 100644
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
index 05ccb4c..13912f5 100644
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
index af87471..963de6c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -593,12 +593,13 @@ static inline void __free_one_page(struct page *page,
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
@@ -831,7 +832,7 @@ static inline void expand(struct zone *zone, struct page *page,
 			continue;
 		}
 #endif
-		list_add(&page[size].lru, &area->free_list[migratetype]);
+		list_add(&page[size].lru, &area->free_list[migratetype].list);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -893,10 +894,10 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
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
@@ -968,7 +969,7 @@ int move_freepages(struct zone *zone,
 
 		order = page_order(page);
 		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype]);
+			  &zone->free_area[order].free_list[migratetype].list);
 		set_freepage_migratetype(page, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
@@ -1029,10 +1030,10 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 				break;
 
 			area = &(zone->free_area[current_order]);
-			if (list_empty(&area->free_list[migratetype]))
+			if (list_empty(&area->free_list[migratetype].list))
 				continue;
 
-			page = list_entry(area->free_list[migratetype].next,
+			page = list_entry(area->free_list[migratetype].list.next,
 					struct page, lru);
 			area->nr_free--;
 
@@ -1296,7 +1297,7 @@ void mark_free_pages(struct zone *zone)
 		}
 
 	for_each_migratetype_order(order, t) {
-		list_for_each(curr, &zone->free_area[order].free_list[t]) {
+		list_for_each(curr, &zone->free_area[order].free_list[t].list) {
 			unsigned long i;
 
 			pfn = page_to_pfn(list_entry(curr, struct page, lru));
@@ -3092,7 +3093,7 @@ void show_free_areas(unsigned int filter)
 
 			types[order] = 0;
 			for (type = 0; type < MIGRATE_TYPES; type++) {
-				if (!list_empty(&area->free_list[type]))
+				if (!list_empty(&area->free_list[type].list))
 					types[order] |= 1 << type;
 			}
 		}
@@ -3944,7 +3945,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 {
 	int order, t;
 	for_each_migratetype_order(order, t) {
-		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
+		INIT_LIST_HEAD(&zone->free_area[order].free_list[t].list);
 		zone->free_area[order].nr_free = 0;
 	}
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index e1d8ed1..63e12f0 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -860,7 +860,7 @@ static void pagetypeinfo_showfree_print(struct seq_file *m,
 
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
