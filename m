Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1526B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 22:38:43 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so13026311pac.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 19:38:43 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id rd5si1437941pdb.188.2015.03.24.19.38.41
        for <linux-mm@kvack.org>;
        Tue, 24 Mar 2015 19:38:42 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [RFCv2] mm: page allocation for less fragmentation
Date: Wed, 25 Mar 2015 11:39:15 +0900
Message-Id: <1427251155-12322-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, hannes@cmpxchg.org, rientjes@google.com, vdavydov@parallels.com, iamjoonsoo.kim@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, gunho.lee@lge.com, Gioh Kim <gioh.kim@lge.com>

My driver allocates more than 40MB pages via alloc_page() at a time and
maps them at virtual address. Totally it uses 300~400MB pages.

If I run a heavy load test for a few days in 1GB memory system, I cannot allocate even order=3 pages
because-of the external fragmentation.

I thought I needed a anti-fragmentation solution for my driver.
But there is no allocation function that considers fragmentation.
The compaction is not helpful because it is only for movable pages, not unmovable pages.

This patch proposes a allocation function allocates only pages in the same pageblock.

I tested this patch like following:

1. When the driver allocates about 400MB and do "cat /proc/pagetypeinfo;cat /proc/buddyinfo"

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
Node    0, zone   Normal, type    Unmovable   3864    728    394    216    129     47     18      9      1      0      0
Node    0, zone   Normal, type  Reclaimable    902     96     68     17      3      0      1      0      0      0      0
Node    0, zone   Normal, type      Movable   5146    663    178     91     43     16      4      0      0      0      0
Node    0, zone   Normal, type      Reserve      1      4      6      6      2      1      1      1      0      1      1
Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve          CMA      Isolate
Node 0, zone   Normal          135            3          124            2            0            0
Node 0, zone   Normal   9880   1489    647    332    177     64     24     10      1      1      1

2. The driver frees all pages and allocates pages again with alloc_pages_compact.
This is a kind of compaction of the driver.
Following is the result of "cat /proc/pagetypeinfo;cat /proc/buddyinfo"

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10
Node    0, zone   Normal, type    Unmovable      8      5      1    432    272     91     37     11      1      0      0
Node    0, zone   Normal, type  Reclaimable    901     96     68     17      3      0      1      0      0      0      0
Node    0, zone   Normal, type      Movable   4790    776    192     91     43     16      4      0      0      0      0
Node    0, zone   Normal, type      Reserve      1      4      6      6      2      1      1      1      0      1      1
Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve          CMA      Isolate
Node 0, zone   Normal          135            3          124            2            0            0
Node 0, zone   Normal   5693    877    266    544    320    108     43     12      1      1      1


I found that fragmentation is decreased.

This patch is based on 3.16. It is not change any code so that it can apply to any version.

Changelog since v1:
- change argument of page order into page count

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
---
 mm/page_alloc.c |  167 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 167 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 86c9a72..e269030 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6646,3 +6646,170 @@ void dump_page(struct page *page, const char *reason)
 	dump_page_badflags(page, reason, 0);
 }
 EXPORT_SYMBOL(dump_page);
+
+static unsigned long alloc_freepages_block(unsigned long start_pfn,
+					   unsigned long end_pfn,
+					   int count,
+					   struct list_head *freelist)
+{
+	int total_alloc = 0;
+	struct page *cursor, *valid_page = NULL;
+
+	cursor = pfn_to_page(start_pfn);
+
+	/* Isolate free pages. */
+	for (; start_pfn < end_pfn; start_pfn++, cursor++) {
+		int alloc, i;
+		struct page *page = cursor;
+
+		if (!pfn_valid_within(start_pfn))
+			continue;
+
+		if (!valid_page)
+			valid_page = page;
+		if (!PageBuddy(page))
+			continue;
+
+		if (!PageBuddy(page))
+			continue;
+
+		/* allocate only low-order pages */
+		if (page_order(page) >= 3) {
+			start_pfn += (1 << page_order(page)) - 1;
+			cursor += (1 << page_order(page)) - 1;
+			continue;
+		}
+
+		/* Found a free pages, break it into order-0 pages */
+		alloc = split_free_page(page);
+
+		total_alloc += alloc;
+		for (i = 0; i < alloc; i++) {
+			list_add(&page->lru, freelist);
+			page++;
+		}
+
+		if (total_alloc >= count)
+			break;
+
+		if (alloc) {
+			start_pfn += alloc - 1;
+			cursor += alloc - 1;
+			continue;
+		}
+	}
+
+	return total_alloc;
+}
+
+static int rmqueue_compact(struct zone *zone, int nr_request,
+			   int migratetype, struct list_head *freepages)
+{
+	unsigned int current_order;
+	struct free_area *area;
+	struct page *page;
+	unsigned long block_start_pfn;	/* start of current pageblock */
+	unsigned long block_end_pfn;	/* end of current pageblock */
+	int total_alloc = 0;
+	unsigned long flags;
+	struct page *next;
+	int to_free = 0;
+	int nr_remain = nr_request;
+	int loop_count = 0;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	/* Find a page of the appropriate size in the preferred list */
+	current_order = 0;
+	page = NULL;
+	while (current_order <= pageblock_order) {
+		int alloc;
+
+		/* search all possible pages in each list? */
+		if (loop_count > (zone->managed_pages / (1 << current_order)))
+			goto next_order;
+		loop_count++;
+
+		area = &(zone->free_area[current_order]);
+
+		if (list_empty(&area->free_list[migratetype]))
+			goto next_order;
+
+		page = list_entry(area->free_list[migratetype].next,
+				  struct page, lru);
+
+		/*
+		 * check migratetype of pageblock again,
+		 * some pages can be set as different migratetype
+		 * by rmqueue_fallback
+		 */
+		if (get_pageblock_migratetype(page) != migratetype)
+			continue;
+
+		block_start_pfn = page_to_pfn(page) & ~(pageblock_nr_pages - 1);
+		block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
+				    zone_end_pfn(zone));
+
+		alloc = alloc_freepages_block(block_start_pfn,
+						 block_end_pfn,
+						 nr_remain,
+						 freepages);
+
+		total_alloc += alloc;
+		nr_remain -= alloc;
+
+		/*
+		 * alloc == 0: free buddy block is found but it is too big
+		 * or free buddy block is not valid page.
+		 * Try next order.
+		*/
+		if (alloc == 0)
+			goto next_order;
+
+		if (nr_remain <= 0)
+			break;
+
+next_order:
+		current_order++;
+		loop_count = 0;
+	}
+	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -total_alloc);
+	__count_zone_vm_events(PGALLOC, zone, total_alloc);
+
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	list_for_each_entry_safe(page, next, freepages, lru) {
+		if (to_free >= nr_request) {
+			list_del(&page->lru);
+			atomic_dec(&page->_count);
+			__free_pages_ok(page, 0);
+		}
+		to_free++;
+	}
+
+	list_for_each_entry(page, freepages, lru) {
+		arch_alloc_page(page, 0);
+		kernel_map_pages(page, 1, 1);
+	}
+	return total_alloc < nr_request ? total_alloc : nr_request;
+}
+
+int alloc_pages_compact(gfp_t gfp_mask, int nr_request,
+			struct list_head *freepages)
+{
+	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
+	struct zone *preferred_zone;
+	struct zoneref *preferred_zoneref;
+
+	preferred_zoneref = first_zones_zonelist(node_zonelist(numa_node_id(),
+							       gfp_mask),
+						 high_zoneidx,
+						 &cpuset_current_mems_allowed,
+						 &preferred_zone);
+	if (!preferred_zone)
+		return 0;
+
+	return rmqueue_compact(preferred_zone, nr_request,
+			       allocflags_to_migratetype(gfp_mask), freepages);
+}
+EXPORT_SYMBOL(alloc_pages_compact);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
