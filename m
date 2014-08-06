Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2BD6B0044
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 03:11:24 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so2891382pad.25
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 00:11:24 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ym5si132349pab.6.2014.08.06.00.11.18
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 00:11:19 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 4/8] mm/isolation: close the two race problems related to pageblock isolation
Date: Wed,  6 Aug 2014 16:18:33 +0900
Message-Id: <1407309517-3270-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We got migratetype of the freeing page without holding the zone lock so
it could be racy. There are two cases of this race.

1. pages are added to isolate buddy list after restoring original
migratetype.
2. pages are added to normal buddy list while pageblock is isolated.

If case 1 happens, we can't allocate freepages on isolate buddy list
until next pageblock isolation occurs.
In case of 2, pages could be merged with pages on isolate buddy list and
located on normal buddy list. This makes freepage counting incorrect
and break the property of pageblock isolation.

One solution to this problem is checking pageblock migratetype with
holding zone lock in __free_one_page() and I posted it before, but,
it didn't get welcome since it needs the hook in zone lock critical
section on freepath.

This is another solution to this problem and impose most overhead on
pageblock isolation logic. Following is how this solution works.

1. Extends irq disabled period on freepath to call
get_pfnblock_migratetype() with irq disabled. With this, we can be
sure that future freed pages will see modified pageblock migratetype
after certain synchronization point so we don't need to hold the zone
lock to get correct pageblock migratetype. Although it extends irq
disabled period on freepath, I guess it is marginal and better than
adding the hook in zone lock critical section.

2. #1 requires IPI for synchronization and we can't hold the zone lock
during processing IPI. In this time, some pages could be moved from buddy
list to pcp list on page allocation path and later it could be moved again
from pcp list to buddy list. In this time, this page would be on isolate
pageblock, so, the hook is required on free_pcppages_bulk() to prevent
misplacement. To remove this possibility, disabling and draining pcp
list is needed during isolation. It guaratees that there is no page on pcp
list on all cpus while isolation, so misplacement problem can't happen.

Note that this doesn't fix freepage counting problem. To fix it,
we need more logic. Following patches will do it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/internal.h       |    2 ++
 mm/page_alloc.c     |   27 ++++++++++++++++++++-------
 mm/page_isolation.c |   45 +++++++++++++++++++++++++++++++++------------
 3 files changed, 55 insertions(+), 19 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index a1b651b..81b8884 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -108,6 +108,8 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
 /*
  * in mm/page_alloc.c
  */
+extern void zone_pcp_disable(struct zone *zone);
+extern void zone_pcp_enable(struct zone *zone);
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3e1e344..4517b1d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -726,11 +726,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
-			if (likely(!is_migrate_isolate_page(page))) {
-				__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
-				if (is_migrate_cma(mt))
-					__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
-			}
+			__mod_zone_freepage_state(zone, 1, mt);
 		} while (--to_free && --batch_free && !list_empty(list));
 	}
 	spin_unlock(&zone->lock);
@@ -789,8 +785,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	if (!free_pages_prepare(page, order))
 		return;
 
-	migratetype = get_pfnblock_migratetype(page, pfn);
 	local_irq_save(flags);
+	migratetype = get_pfnblock_migratetype(page, pfn);
 	__count_vm_events(PGFREE, 1 << order);
 	set_freepage_migratetype(page, migratetype);
 	free_one_page(page_zone(page), page, pfn, order, migratetype);
@@ -1410,9 +1406,9 @@ void free_hot_cold_page(struct page *page, bool cold)
 	if (!free_pages_prepare(page, 0))
 		return;
 
+	local_irq_save(flags);
 	migratetype = get_pfnblock_migratetype(page, pfn);
 	set_freepage_migratetype(page, migratetype);
-	local_irq_save(flags);
 	__count_vm_event(PGFREE);
 
 	/*
@@ -6469,6 +6465,23 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 }
 #endif
 
+#ifdef CONFIG_MEMORY_ISOLATION
+void zone_pcp_disable(struct zone *zone)
+{
+	mutex_lock(&pcp_batch_high_lock);
+	pageset_update(zone, 1, 1);
+}
+
+void zone_pcp_enable(struct zone *zone)
+{
+	int high, batch;
+
+	pageset_get_values(zone, &high, &batch);
+	pageset_update(zone, high, batch);
+	mutex_unlock(&pcp_batch_high_lock);
+}
+#endif
+
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
  * The zone indicated has a new number of managed_pages; batch sizes and percpu
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 3100f98..439158d 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -16,9 +16,10 @@ int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
 	struct memory_isolate_notify arg;
 	int notifier_ret;
 	int ret = -EBUSY;
+	unsigned long nr_pages;
+	int migratetype;
 
 	zone = page_zone(page);
-
 	spin_lock_irqsave(&zone->lock, flags);
 
 	pfn = page_to_pfn(page);
@@ -55,20 +56,32 @@ int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
 	 */
 
 out:
-	if (!ret) {
-		unsigned long nr_pages;
-		int migratetype = get_pageblock_migratetype(page);
+	if (ret) {
+		spin_unlock_irqrestore(&zone->lock, flags);
+		return ret;
+	}
 
-		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
-		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
+	migratetype = get_pageblock_migratetype(page);
+	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
+	spin_unlock_irqrestore(&zone->lock, flags);
 
-		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
-	}
+	zone_pcp_disable(zone);
+
+	/*
+	 * After this point, freed pages will see MIGRATE_ISOLATE as
+	 * their pageblock migratetype on all cpus. And pcp list has
+	 * no free page.
+	 */
+	on_each_cpu(drain_local_pages, NULL, 1);
 
+	spin_lock_irqsave(&zone->lock, flags);
+	nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
+	__mod_zone_freepage_state(zone, -nr_pages, migratetype);
 	spin_unlock_irqrestore(&zone->lock, flags);
-	if (!ret)
-		drain_all_pages();
-	return ret;
+
+	zone_pcp_enable(zone);
+
+	return 0;
 }
 
 void unset_migratetype_isolate(struct page *page, unsigned migratetype)
@@ -80,9 +93,17 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	spin_lock_irqsave(&zone->lock, flags);
 	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 		goto out;
+
+	set_pageblock_migratetype(page, migratetype);
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	/* Freed pages will see original migratetype after this point */
+	kick_all_cpus_sync();
+
+	spin_lock_irqsave(&zone->lock, flags);
 	nr_pages = move_freepages_block(zone, page, migratetype);
 	__mod_zone_freepage_state(zone, nr_pages, migratetype);
-	set_pageblock_migratetype(page, migratetype);
+
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
