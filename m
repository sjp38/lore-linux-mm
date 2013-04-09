Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id AD3A46B003B
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 17:49:48 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 10 Apr 2013 03:14:44 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 78553E004A
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:21:32 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r39Lnd2p11338224
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:19:40 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r39LnfRI007570
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 07:49:42 +1000
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 06/15] mm: Demarcate and maintain pageblocks in
 region-order in the zones' freelists
Date: Wed, 10 Apr 2013 03:17:09 +0530
Message-ID: <20130409214706.4500.94371.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
References: <20130409214443.4500.44168.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, matthew.garrett@nebula.com, dave@sr71.net, rientjes@google.com, riel@redhat.com, arjan@linux.intel.com, srinivas.pandruvada@linux.intel.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, paulmck@linux.vnet.ibm.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, wujianguo@huawei.com, kmpark@infradead.org, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The zones' freelists need to be made region-aware, in order to influence
page allocation and freeing algorithms. So in every free list in the zone, we
would like to demarcate the pageblocks belonging to different memory regions
(we can do this using a set of pointers, and thus avoid splitting up the
freelists).

Also, we would like to keep the pageblocks in the freelists sorted in
region-order. That is, pageblocks belonging to region-0 would come first,
followed by pageblocks belonging to region-1 and so on, within a given
freelist. Of course, a set of pageblocks belonging to the same region need
not be sorted; it is sufficient if we maintain the pageblocks in
region-sorted-order, rather than a full address-sorted-order.

For each freelist within the zone, we maintain a set of pointers to
pageblocks belonging to the various memory regions in that zone.

Eg:

    |<---Region0--->|   |<---Region1--->|   |<-------Region2--------->|
     ____      ____      ____      ____      ____      ____      ____
--> |____|--> |____|--> |____|--> |____|--> |____|--> |____|--> |____|-->

                 ^                  ^                              ^
                 |                  |                              |
                Reg0               Reg1                          Reg2


Page allocation will proceed as usual - pick the first item on the free list.
But we don't want to keep updating these region pointers every time we allocate
a pageblock from the freelist. So, instead of pointing to the *first* pageblock
of that region, we maintain the region pointers such that they point to the
*last* pageblock in that region, as shown in the figure above. That way, as
long as there are > 1 pageblocks in that region in that freelist, that region
pointer doesn't need to be updated.


Page allocation algorithm:
-------------------------

The heart of the page allocation algorithm remains as it is - pick the first
item on the appropriate freelist and return it.


Arrangement of pageblocks in the zone freelists:
-----------------------------------------------

This is the main change - we keep the pageblocks in region-sorted order,
where pageblocks belonging to region-0 come first, followed by those belonging
to region-1 and so on. But the pageblocks within a given region need *not* be
sorted, since we need them to be only region-sorted and not fully
address-sorted.

This sorting is performed when adding pages back to the freelists, thus
avoiding any region-related overhead in the critical page allocation
paths.

Strategy to consolidate allocations to a minimum no. of regions:
---------------------------------------------------------------

Page allocation happens in the order of increasing region number. We would
like to do light-weight page reclaim or compaction (for the purpose of memory
power management) in the reverse order, to keep the allocated pages within
a minimum number of regions (approximately). The latter part is implemented
in subsequent patches.

---------------------------- Increasing region number---------------------->

Direction of allocation--->                <---Direction of reclaim/compaction

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |  151 ++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 136 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 963de6c..7fb4254 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -505,6 +505,111 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	return 0;
 }
 
+static void add_to_freelist(struct page *page, struct free_list *free_list)
+{
+	struct list_head *prev_region_list, *lru;
+	struct mem_region_list *region;
+	int region_id, i;
+
+	lru = &page->lru;
+	region_id = page_zone_region_id(page);
+
+	region = &free_list->mr_list[region_id];
+	region->nr_free++;
+
+	if (region->page_block) {
+		list_add_tail(lru, region->page_block);
+		return;
+	}
+
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	WARN(region->nr_free != 1, "%s: nr_free is not unity\n", __func__);
+#endif
+
+	if (!list_empty(&free_list->list)) {
+		for (i = region_id - 1; i >= 0; i--) {
+			if (free_list->mr_list[i].page_block) {
+				prev_region_list =
+					free_list->mr_list[i].page_block;
+				goto out;
+			}
+		}
+	}
+
+	/* This is the first region, so add to the head of the list */
+	prev_region_list = &free_list->list;
+
+out:
+	list_add(lru, prev_region_list);
+
+	/* Save pointer to page block of this region */
+	region->page_block = lru;
+}
+
+static void del_from_freelist(struct page *page, struct free_list *free_list)
+{
+	struct list_head *prev_page_lru, *lru, *p;
+	struct mem_region_list *region;
+	int region_id;
+
+	lru = &page->lru;
+	region_id = page_zone_region_id(page);
+	region = &free_list->mr_list[region_id];
+	region->nr_free--;
+
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	WARN(region->nr_free < 0, "%s: nr_free is negative\n", __func__);
+
+	/* Verify whether this page indeed belongs to this free list! */
+
+	list_for_each(p, &free_list->list) {
+		if (p == lru)
+			goto page_found;
+	}
+
+	WARN(1, "%s: page doesn't belong to the given freelist!\n", __func__);
+
+page_found:
+#endif
+
+	/*
+	 * If we are not deleting the last pageblock in this region (i.e.,
+	 * farthest from list head, but not necessarily the last numerically),
+	 * then we need not update the region->page_block pointer.
+	 */
+	if (lru != region->page_block) {
+		list_del(lru);
+#ifdef CONFIG_DEBUG_PAGEALLOC
+		WARN(region->nr_free == 0, "%s: nr_free messed up\n", __func__);
+#endif
+		return;
+	}
+
+	prev_page_lru = lru->prev;
+	list_del(lru);
+
+	if (region->nr_free == 0) {
+		region->page_block = NULL;
+	} else {
+		region->page_block = prev_page_lru;
+#ifdef CONFIG_DEBUG_PAGEALLOC
+		WARN(prev_page_lru == &free_list->list,
+			"%s: region->page_block points to list head\n",
+								__func__);
+#endif
+	}
+}
+
+/**
+ * Move a given page from one freelist to another.
+ */
+static void move_page_freelist(struct page *page, struct free_list *old_list,
+			       struct free_list *new_list)
+{
+	del_from_freelist(page, old_list);
+	add_to_freelist(page, new_list);
+}
+
 /*
  * Freeing function for a buddy system allocator.
  *
@@ -537,6 +642,7 @@ static inline void __free_one_page(struct page *page,
 	unsigned long combined_idx;
 	unsigned long uninitialized_var(buddy_idx);
 	struct page *buddy;
+	struct free_area *area;
 
 	VM_BUG_ON(!zone_is_initialized(zone));
 
@@ -566,8 +672,9 @@ static inline void __free_one_page(struct page *page,
 			__mod_zone_freepage_state(zone, 1 << order,
 						  migratetype);
 		} else {
-			list_del(&buddy->lru);
-			zone->free_area[order].nr_free--;
+			area = &zone->free_area[order];
+			del_from_freelist(buddy, &area->free_list[migratetype]);
+			area->nr_free--;
 			rmv_page_order(buddy);
 		}
 		combined_idx = buddy_idx & page_idx;
@@ -576,6 +683,7 @@ static inline void __free_one_page(struct page *page,
 		order++;
 	}
 	set_page_order(page, order);
+	area = &zone->free_area[order];
 
 	/*
 	 * If this is not the largest possible page, check if the buddy
@@ -592,16 +700,22 @@ static inline void __free_one_page(struct page *page,
 		buddy_idx = __find_buddy_index(combined_idx, order + 1);
 		higher_buddy = higher_page + (buddy_idx - combined_idx);
 		if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
-			list_add_tail(&page->lru,
-				&zone->free_area[order].free_list[migratetype].list);
+
+			/*
+			 * Implementing an add_to_freelist_tail() won't be
+			 * very useful because both of them (almost) add to
+			 * the tail within the region. So we could potentially
+			 * switch off this entire "is next-higher buddy free?"
+			 * logic when memory regions are used.
+			 */
+			add_to_freelist(page, &area->free_list[migratetype]);
 			goto out;
 		}
 	}
 
-	list_add(&page->lru,
-		&zone->free_area[order].free_list[migratetype].list);
+	add_to_freelist(page, &area->free_list[migratetype]);
 out:
-	zone->free_area[order].nr_free++;
+	area->nr_free++;
 }
 
 static inline int free_pages_check(struct page *page)
@@ -832,7 +946,7 @@ static inline void expand(struct zone *zone, struct page *page,
 			continue;
 		}
 #endif
-		list_add(&page[size].lru, &area->free_list[migratetype].list);
+		add_to_freelist(&page[size], &area->free_list[migratetype]);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -899,7 +1013,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 
 		page = list_entry(area->free_list[migratetype].list.next,
 							struct page, lru);
-		list_del(&page->lru);
+		del_from_freelist(page, &area->free_list[migratetype]);
 		rmv_page_order(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
@@ -940,7 +1054,8 @@ int move_freepages(struct zone *zone,
 {
 	struct page *page;
 	unsigned long order;
-	int pages_moved = 0;
+	struct free_area *area;
+	int pages_moved = 0, old_mt;
 
 #ifndef CONFIG_HOLES_IN_ZONE
 	/*
@@ -968,8 +1083,10 @@ int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype].list);
+		old_mt = get_freepage_migratetype(page);
+		area = &zone->free_area[order];
+		move_page_freelist(page, &area->free_list[old_mt],
+				    &area->free_list[migratetype]);
 		set_freepage_migratetype(page, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
@@ -1067,7 +1184,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			}
 
 			/* Remove the page from the freelists */
-			list_del(&page->lru);
+			del_from_freelist(page, &area->free_list[migratetype]);
 			rmv_page_order(page);
 
 			/* Take ownership for orders >= pageblock_order */
@@ -1420,7 +1537,8 @@ static int __isolate_free_page(struct page *page, unsigned int order)
 	}
 
 	/* Remove page from free list */
-	list_del(&page->lru);
+	mt = get_freepage_migratetype(page);
+	del_from_freelist(page, &zone->free_area[order].free_list[mt]);
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
 
@@ -6131,6 +6249,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	int order, i;
 	unsigned long pfn;
 	unsigned long flags;
+	int mt;
+
 	/* find the first valid pfn */
 	for (pfn = start_pfn; pfn < end_pfn; pfn++)
 		if (pfn_valid(pfn))
@@ -6163,7 +6283,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		printk(KERN_INFO "remove from free list %lx %d %lx\n",
 		       pfn, 1 << order, end_pfn);
 #endif
-		list_del(&page->lru);
+		mt = get_freepage_migratetype(page);
+		del_from_freelist(page, &zone->free_area[order].free_list[mt]);
 		rmv_page_order(page);
 		zone->free_area[order].nr_free--;
 		for (i = 0; i < (1 << order); i++)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
