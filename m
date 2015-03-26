Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A98856B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:46:13 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so56737157pac.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 01:46:13 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id qh9si411976pab.98.2015.03.26.01.46.11
        for <linux-mm@kvack.org>;
        Thu, 26 Mar 2015 01:46:12 -0700 (PDT)
From: Gioh Kim <gioh.kim@lge.com>
Subject: [RFCv3] mm: page allocation for less fragmentation
Date: Thu, 26 Mar 2015 17:45:40 +0900
Message-Id: <1427359540-14833-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Gioh Kim <gioh.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

My platform is suffering with the external fragmentation problem.
If I run a heavy load test for a few days in 1GB memory system, I cannot
allocate even order=3 pages because-of the external fragmentation.

I found that my driver is main reason.
It repeats to allocate 16MB pages with alloc_page(GFP_KERNEL) and
totally consumes 300~400MB pages of 1GB system.

I thought I needed a anti-fragmentation solution for my driver.
But there is no allocation function that considers fragmentation.
The compaction is not helpful because it is only for movable pages, not
unmovable pages.

This patch proposes a allocation function allocates only pages in the same
pageblock.

I tested this patch like following to check that I can get high order page
with new allocator.

1. When the driver allocates about 400MB and do "cat /proc/pagetypeinfo;cat
/proc/buddyinfo"

Free pages count per migrate type at order       0      1      2      3      4
5      6      7      8      9     10
Node    0, zone   Normal, type    Unmovable   3864    728    394    216    129
47     18      9      1      0      0
Node    0, zone   Normal, type  Reclaimable    902     96     68     17      3
0      1      0      0      0      0
Node    0, zone   Normal, type      Movable   5146    663    178     91     43
16      4      0      0      0      0
Node    0, zone   Normal, type      Reserve      1      4      6      6      2
1      1      1      0      1      1
Node    0, zone   Normal, type          CMA      0      0      0      0      0
0      0      0      0      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0      0
0      0      0      0      0      0

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve
CMA      Isolate
Node 0, zone   Normal          135            3          124            2
0            0
Node 0, zone   Normal   9880   1489    647    332    177     64     24     10
1      1      1

2. The driver allocates pages with alloc_pages_compact
and copy page contents and free old pages.
This is a kind of compaction of the driver.
Following is the result of "cat /proc/pagetypeinfo;cat /proc/buddyinfo"

Free pages count per migrate type at order       0      1      2      3      4
5      6      7      8      9     10
Node    0, zone   Normal, type    Unmovable      8      5      1    432    272
91     37     11      1      0      0
Node    0, zone   Normal, type  Reclaimable    901     96     68     17      3
0      1      0      0      0      0
Node    0, zone   Normal, type      Movable   4790    776    192     91     43
16      4      0      0      0      0
Node    0, zone   Normal, type      Reserve      1      4      6      6      2
1      1      1      0      1      1
Node    0, zone   Normal, type          CMA      0      0      0      0      0
0      0      0      0      0      0
Node    0, zone   Normal, type      Isolate      0      0      0      0      0
0      0      0      0      0      0

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve
CMA      Isolate
Node 0, zone   Normal          135            3          124            2
0            0
Node 0, zone   Normal   5693    877    266    544    320    108     43     12
1      1      1

I found that high order pages are increased.


And I did another test. Following test is counting mixed blocks
after page allocation.

In virtualbox system with 4-CPUs and 768MB memory I had runned kernel build
and I allocated pages with alloc_page and alloc_pages_compact.

1. kernel build make -j8 and cat /proc/pagetypeinfo
Number of mixed blocks    Unmovable  Reclaimable      Movable      Reserve
Node 0, zone      DMA            0            0            3            1
Node 0, zone   Normal            8           10           89            0

2. alloc_pages_compact(GFP_USER, 4096) X 10-times and cat /proc/pagetypeinfo
Number of mixed blocks    Unmovable  Reclaimable      Movable      Reserve
Node 0, zone      DMA            0            0            3            1
Node 0, zone   Normal            8           10           89            0

I found there is no more fragmentation.

Following is alloc_pages test.

1. kernel build naje -j8 and cat /proc/pagetypeinfo

Number of mixed blocks    Unmovable  Reclaimable      Movable      Reserve
Node 0, zone      DMA            0            0            3            1
Node 0, zone   Normal            8            7          100            1

2. alloc_page(GFP_USER) X 4096-times X 10-times and cat /proc/pagetypeinfo

Number of mixed blocks    Unmovable  Reclaimable      Movable      Reserve
Node 0, zone      DMA            0            0            3            1
Node 0, zone   Normal           37            7          105            1

It generates fragmentation.

With above two tests I can get more high order pages and less mixed blocks.
The new allocator isn't to replace the common allocator alloc_pages.
It can be applied to a certain drivers that allocates many pages and don't need
fast allocation.

When the system has serious fragmentation you can free pages and alloc pages
via alloc_page to decrease fragmentation. But it would last short and
fragmentation would increase soon. The new allocator can work like compaction
so that it decrease fragmentation for long time.


This patch is based on 3.16.
allocflags_to_migratetype should be changed into gfpflags_to_migratetype for
v4.0.


Changelog since v1:
- change argument of page order into page count

Changelog since v2:
- bug fix
- do not allocate page in different migratetype pageblock
- add new test result of mixed block count

Signed-off-by: Gioh Kim <gioh.kim@lge.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Mel Gorman <mgorman@suse.de>
CC: Rik van Riel <riel@redhat.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: David Rientjes <rientjes@google.com>
CC: Vladimir Davydov <vdavydov@parallels.com>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
---
 mm/page_alloc.c |  160 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 160 insertions(+)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 86c9a72..826618b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6646,3 +6646,163 @@ void dump_page(struct page *page, const char *reason)
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
+	while (current_order < 3) {
+		int alloc;
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
+		 * check migratetype of pageblock,
+		 * some pages can be set as different migratetype
+		 * by rmqueue_fallback
+		 */
+		if (get_pageblock_migratetype(page) != migratetype) {
+			if (list_is_last(&page->lru,
+					 &area->free_list[migratetype]))
+				goto next_order;
+			page = list_next_entry(page, lru);
+		}
+
+		block_start_pfn = page_to_pfn(page) & ~(pageblock_nr_pages - 1);
+		block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
+				    zone_end_pfn(zone));
+
+		alloc = alloc_freepages_block(block_start_pfn,
+						 block_end_pfn,
+						 nr_remain,
+						 freepages);
+		WARN(alloc == 0, "alloc can be ZERO????");
+
+		total_alloc += alloc;
+		nr_remain -= alloc;
+
+		if (nr_remain <= 0)
+			break;
+
+		continue;
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
