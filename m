Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A36476B005D
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 14:55:06 -0500 (EST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Wed, 7 Nov 2012 05:52:42 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qA6Jidgo35258542
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:44:39 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qA6Jt1SM020035
	for <linux-mm@kvack.org>; Wed, 7 Nov 2012 06:55:02 +1100
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Subject: [RFC PATCH 6/8] mm: Demarcate and maintain pageblocks in region-order
 in the zones' freelists
Date: Wed, 07 Nov 2012 01:23:55 +0530
Message-ID: <20121106195342.6941.94892.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
References: <20121106195026.6941.24662.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mjg59@srcf.ucam.org, paulmck@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, arjan@linux.intel.com, kmpark@infradead.org, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl
Cc: gargankita@gmail.com, amit.kachhap@linaro.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, santosh.shilimkar@ti.com, srivatsa.bhat@linux.vnet.ibm.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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

The heart of the page allocation algorithm remains it is - pick the first
item on the appropriate freelist and return it.


Pageblock order in the zone freelists:
-------------------------------------

This is the main change - we keep the pageblocks in region-sorted order,
where pageblocks belonging to region-0 come first, followed by those belonging
to region-1 and so on. But the pageblocks within a given region need *not* be
sorted, since we need them to be only region-sorted and not fully
address-sorted.

This sorting is performed when adding pages back to the freelists, thus
avoiding any region-related overhead in the critical page allocation
paths.

Page reclaim [Todo]:
--------------------

Page allocation happens in the order of increasing region number. We would
like to do page reclaim in the reverse order, to keep allocated pages within
a minimal number of regions (approximately).

---------------------------- Increasing region number---------------------->

Direction of allocation--->                         <---Direction of reclaim

Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---

 mm/page_alloc.c |  128 +++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 113 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 62d0a9a..52ff914 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -502,6 +502,79 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	return 0;
 }
 
+static void add_to_freelist(struct page *page, struct list_head *lru,
+			    struct free_list *free_list)
+{
+	struct mem_region_list *region;
+	struct list_head *prev_region_list;
+	int region_id, i;
+
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
+static void del_from_freelist(struct page *page, struct list_head *lru,
+			      struct free_list *free_list)
+{
+	struct mem_region_list *region;
+	struct list_head *prev_page_lru;
+	int region_id;
+
+	region_id = page_zone_region_id(page);
+	region = &free_list->mr_list[region_id];
+	region->nr_free--;
+
+	if (lru != region->page_block) {
+		list_del(lru);
+		return;
+	}
+
+	prev_page_lru = lru->prev;
+	list_del(lru);
+
+	if (region->nr_free == 0)
+		region->page_block = NULL;
+	else
+		region->page_block = prev_page_lru;
+}
+
+/**
+ * Move pages of a given order from freelist of one migrate-type to another.
+ */
+static void move_pages_freelist(struct page *page, struct list_head *lru,
+				struct free_list *old_list,
+				struct free_list *new_list)
+{
+	del_from_freelist(page, lru, old_list);
+	add_to_freelist(page, lru, new_list);
+}
+
 /*
  * Freeing function for a buddy system allocator.
  *
@@ -534,6 +607,7 @@ static inline void __free_one_page(struct page *page,
 	unsigned long combined_idx;
 	unsigned long uninitialized_var(buddy_idx);
 	struct page *buddy;
+	struct free_area *area;
 
 	if (unlikely(PageCompound(page)))
 		if (unlikely(destroy_compound_page(page, order)))
@@ -561,8 +635,10 @@ static inline void __free_one_page(struct page *page,
 			__mod_zone_freepage_state(zone, 1 << order,
 						  migratetype);
 		} else {
-			list_del(&buddy->lru);
-			zone->free_area[order].nr_free--;
+			area = &zone->free_area[order];
+			del_from_freelist(buddy, &buddy->lru,
+					  &area->free_list[migratetype]);
+			area->nr_free--;
 			rmv_page_order(buddy);
 		}
 		combined_idx = buddy_idx & page_idx;
@@ -587,14 +663,23 @@ static inline void __free_one_page(struct page *page,
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
+			area = &zone->free_area[order];
+			add_to_freelist(page, &page->lru,
+					&area->free_list[migratetype]);
 			goto out;
 		}
 	}
 
-	list_add(&page->lru,
-		&zone->free_area[order].free_list[migratetype].list);
+	add_to_freelist(page, &page->lru,
+			&zone->free_area[order].free_list[migratetype]);
 out:
 	zone->free_area[order].nr_free++;
 }
@@ -812,7 +897,8 @@ static inline void expand(struct zone *zone, struct page *page,
 			continue;
 		}
 #endif
-		list_add(&page[size].lru, &area->free_list[migratetype].list);
+		add_to_freelist(&page[size], &page[size].lru,
+					&area->free_list[migratetype]);
 		area->nr_free++;
 		set_page_order(&page[size], high);
 	}
@@ -879,7 +965,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 
 		page = list_entry(area->free_list[migratetype].list.next,
 							struct page, lru);
-		list_del(&page->lru);
+		del_from_freelist(page, &page->lru,
+				  &area->free_list[migratetype]);
 		rmv_page_order(page);
 		area->nr_free--;
 		expand(zone, page, order, current_order, area, migratetype);
@@ -918,7 +1005,8 @@ int move_freepages(struct zone *zone,
 {
 	struct page *page;
 	unsigned long order;
-	int pages_moved = 0;
+	struct free_area *area;
+	int pages_moved = 0, old_mt;
 
 #ifndef CONFIG_HOLES_IN_ZONE
 	/*
@@ -946,8 +1034,11 @@ int move_freepages(struct zone *zone,
 		}
 
 		order = page_order(page);
-		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype].list);
+		old_mt = get_freepage_migratetype(page);
+		area = &zone->free_area[order];
+		move_pages_freelist(page, &page->lru,
+				    &area->free_list[old_mt],
+				    &area->free_list[migratetype]);
 		set_freepage_migratetype(page, migratetype);
 		page += 1 << order;
 		pages_moved += 1 << order;
@@ -1045,7 +1136,8 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			}
 
 			/* Remove the page from the freelists */
-			list_del(&page->lru);
+			del_from_freelist(page, &page->lru,
+					  &area->free_list[migratetype]);
 			rmv_page_order(page);
 
 			/* Take ownership for orders >= pageblock_order */
@@ -1399,12 +1491,14 @@ int capture_free_page(struct page *page, int alloc_order, int migratetype)
 	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 		return 0;
 
+	mt = get_pageblock_migratetype(page);
+
 	/* Remove page from free list */
-	list_del(&page->lru);
+	del_from_freelist(page, &page->lru,
+			  &zone->free_area[order].free_list[mt]);
 	zone->free_area[order].nr_free--;
 	rmv_page_order(page);
 
-	mt = get_pageblock_migratetype(page);
 	if (unlikely(mt != MIGRATE_ISOLATE))
 		__mod_zone_freepage_state(zone, -(1UL << order), mt);
 
@@ -6040,6 +6134,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	int order, i;
 	unsigned long pfn;
 	unsigned long flags;
+	int mt;
+
 	/* find the first valid pfn */
 	for (pfn = start_pfn; pfn < end_pfn; pfn++)
 		if (pfn_valid(pfn))
@@ -6062,7 +6158,9 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		printk(KERN_INFO "remove from free list %lx %d %lx\n",
 		       pfn, 1 << order, end_pfn);
 #endif
-		list_del(&page->lru);
+		mt = get_freepage_migratetype(page);
+		del_from_freelist(page, &page->lru,
+			  	  &zone->free_area[order].free_list[mt]);
 		rmv_page_order(page);
 		zone->free_area[order].nr_free--;
 		__mod_zone_page_state(zone, NR_FREE_PAGES,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
