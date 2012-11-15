Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 04AF46B0062
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 14:24:55 -0500 (EST)
Date: Thu, 15 Nov 2012 11:24:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix a regression with HIGHMEM introduced by
 changeset 7f1290f2f2a4d
Message-Id: <20121115112454.e582a033.akpm@linux-foundation.org>
In-Reply-To: <50A3B013.4030207@gmail.com>
References: <1352165517-9732-1-git-send-email-jiang.liu@huawei.com>
	<20121106124315.79deb2bc.akpm@linux-foundation.org>
	<50A3B013.4030207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Jianguo Wu <wujianguo@huawei.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Daniel Vetter <daniel.vetter@ffwll.ch>

On Wed, 14 Nov 2012 22:52:03 +0800
Jiang Liu <liuj97@gmail.com> wrote:

> 	So how about totally reverting the changeset 7f1290f2f2a4d2c3f1b7ce8e87256e052ca23125
> and I will post another version once I found a cleaner way?

We do need to get this regression fixed and I guess that a
straightforward revert is an acceptable way of doing that, for now.


I queued the below, with a plan to send it to Linus next week.


From: Andrew Morton <akpm@linux-foundation.org>
Subject: revert "mm: fix-up zone present pages"

Revert

commit 7f1290f2f2a4d2c3f1b7ce8e87256e052ca23125
Author:     Jianguo Wu <wujianguo@huawei.com>
AuthorDate: Mon Oct 8 16:33:06 2012 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Tue Oct 9 16:22:54 2012 +0900

    mm: fix-up zone present pages


That patch tried to fix a issue when calculating zone->present_pages, but
it caused a regression on 32bit systems with HIGHMEM.  With that
changeset, reset_zone_present_pages() resets all zone->present_pages to
zero, and fixup_zone_present_pages() is called to recalculate
zone->present_pages when the boot allocator frees core memory pages into
buddy allocator.  Because highmem pages are not freed by bootmem
allocator, all highmem zones' present_pages becomes zero.

Various options for improving the situation are being discussed but for
now, let's return to the 3.6 code.

Cc: Jianguo Wu <wujianguo@huawei.com>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: Petr Tesarik <ptesarik@suse.cz>
Cc: "Luck, Tony" <tony.luck@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/mm/init.c |    1 -
 include/linux/mm.h  |    4 ----
 mm/bootmem.c        |   10 +---------
 mm/memory_hotplug.c |    7 -------
 mm/nobootmem.c      |    3 ---
 mm/page_alloc.c     |   34 ----------------------------------
 6 files changed, 1 insertion(+), 58 deletions(-)

diff -puN arch/ia64/mm/init.c~revert-1 arch/ia64/mm/init.c
--- a/arch/ia64/mm/init.c~revert-1
+++ a/arch/ia64/mm/init.c
@@ -637,7 +637,6 @@ mem_init (void)
 
 	high_memory = __va(max_low_pfn * PAGE_SIZE);
 
-	reset_zone_present_pages();
 	for_each_online_pgdat(pgdat)
 		if (pgdat->bdata->node_bootmem_map)
 			totalram_pages += free_all_bootmem_node(pgdat);
diff -puN include/linux/mm.h~revert-1 include/linux/mm.h
--- a/include/linux/mm.h~revert-1
+++ a/include/linux/mm.h
@@ -1684,9 +1684,5 @@ static inline unsigned int debug_guardpa
 static inline bool page_is_guard(struct page *page) { return false; }
 #endif /* CONFIG_DEBUG_PAGEALLOC */
 
-extern void reset_zone_present_pages(void);
-extern void fixup_zone_present_pages(int nid, unsigned long start_pfn,
-				unsigned long end_pfn);
-
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff -puN mm/bootmem.c~revert-1 mm/bootmem.c
--- a/mm/bootmem.c~revert-1
+++ a/mm/bootmem.c
@@ -198,8 +198,6 @@ static unsigned long __init free_all_boo
 			int order = ilog2(BITS_PER_LONG);
 
 			__free_pages_bootmem(pfn_to_page(start), order);
-			fixup_zone_present_pages(page_to_nid(pfn_to_page(start)),
-					start, start + BITS_PER_LONG);
 			count += BITS_PER_LONG;
 			start += BITS_PER_LONG;
 		} else {
@@ -210,9 +208,6 @@ static unsigned long __init free_all_boo
 				if (vec & 1) {
 					page = pfn_to_page(start + off);
 					__free_pages_bootmem(page, 0);
-					fixup_zone_present_pages(
-						page_to_nid(page),
-						start + off, start + off + 1);
 					count++;
 				}
 				vec >>= 1;
@@ -226,11 +221,8 @@ static unsigned long __init free_all_boo
 	pages = bdata->node_low_pfn - bdata->node_min_pfn;
 	pages = bootmem_bootmap_pages(pages);
 	count += pages;
-	while (pages--) {
-		fixup_zone_present_pages(page_to_nid(page),
-				page_to_pfn(page), page_to_pfn(page) + 1);
+	while (pages--)
 		__free_pages_bootmem(page++, 0);
-	}
 
 	bdebug("nid=%td released=%lx\n", bdata - bootmem_node_data, count);
 
diff -puN mm/memory_hotplug.c~revert-1 mm/memory_hotplug.c
--- a/mm/memory_hotplug.c~revert-1
+++ a/mm/memory_hotplug.c
@@ -106,7 +106,6 @@ static void get_page_bootmem(unsigned lo
 void __ref put_page_bootmem(struct page *page)
 {
 	unsigned long type;
-	struct zone *zone;
 
 	type = (unsigned long) page->lru.next;
 	BUG_ON(type < MEMORY_HOTPLUG_MIN_BOOTMEM_TYPE ||
@@ -117,12 +116,6 @@ void __ref put_page_bootmem(struct page 
 		set_page_private(page, 0);
 		INIT_LIST_HEAD(&page->lru);
 		__free_pages_bootmem(page, 0);
-
-		zone = page_zone(page);
-		zone_span_writelock(zone);
-		zone->present_pages++;
-		zone_span_writeunlock(zone);
-		totalram_pages++;
 	}
 
 }
diff -puN mm/nobootmem.c~revert-1 mm/nobootmem.c
--- a/mm/nobootmem.c~revert-1
+++ a/mm/nobootmem.c
@@ -116,8 +116,6 @@ static unsigned long __init __free_memor
 		return 0;
 
 	__free_pages_memory(start_pfn, end_pfn);
-	fixup_zone_present_pages(pfn_to_nid(start >> PAGE_SHIFT),
-			start_pfn, end_pfn);
 
 	return end_pfn - start_pfn;
 }
@@ -128,7 +126,6 @@ unsigned long __init free_low_memory_cor
 	phys_addr_t start, end, size;
 	u64 i;
 
-	reset_zone_present_pages();
 	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
 		count += __free_memory_core(start, end);
 
diff -puN mm/page_alloc.c~revert-1 mm/page_alloc.c
--- a/mm/page_alloc.c~revert-1
+++ a/mm/page_alloc.c
@@ -6098,37 +6098,3 @@ void dump_page(struct page *page)
 	dump_page_flags(page->flags);
 	mem_cgroup_print_bad_page(page);
 }
-
-/* reset zone->present_pages */
-void reset_zone_present_pages(void)
-{
-	struct zone *z;
-	int i, nid;
-
-	for_each_node_state(nid, N_HIGH_MEMORY) {
-		for (i = 0; i < MAX_NR_ZONES; i++) {
-			z = NODE_DATA(nid)->node_zones + i;
-			z->present_pages = 0;
-		}
-	}
-}
-
-/* calculate zone's present pages in buddy system */
-void fixup_zone_present_pages(int nid, unsigned long start_pfn,
-				unsigned long end_pfn)
-{
-	struct zone *z;
-	unsigned long zone_start_pfn, zone_end_pfn;
-	int i;
-
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		z = NODE_DATA(nid)->node_zones + i;
-		zone_start_pfn = z->zone_start_pfn;
-		zone_end_pfn = zone_start_pfn + z->spanned_pages;
-
-		/* if the two regions intersect */
-		if (!(zone_start_pfn >= end_pfn	|| zone_end_pfn <= start_pfn))
-			z->present_pages += min(end_pfn, zone_end_pfn) -
-					    max(start_pfn, zone_start_pfn);
-	}
-}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
