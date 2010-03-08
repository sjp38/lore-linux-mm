Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB37A6B00A1
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 06:48:27 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/3] page-allocator: Under memory pressure, wait on pressure to relieve instead of congestion
Date: Mon,  8 Mar 2010 11:48:21 +0000
Message-Id: <1268048904-19397-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Nick Piggin <npiggin@suse.de>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Under heavy memory pressure, the page allocator may call congestion_wait()
to wait for IO congestion to clear or a timeout. This is not as sensible
a choice as it first appears. There is no guarantee that BLK_RW_ASYNC is
even congested as the pressure could have been due to a large number of
SYNC reads and the allocator waits for the entire timeout, possibly uselessly.

At the point of congestion_wait(), the allocator is struggling to get the
pages it needs and it should back off. This patch puts the allocator to sleep
on a zone->pressure_wq for either a timeout or until a direct reclaimer or
kswapd brings the zone over the low watermark, whichever happens first.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    3 ++
 mm/internal.h          |    4 +++
 mm/mmzone.c            |   47 +++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c        |   50 +++++++++++++++++++++++++++++++++++++++++++----
 mm/vmscan.c            |    2 +
 5 files changed, 101 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 30fe668..72465c1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -398,6 +398,9 @@ struct zone {
 	unsigned long		wait_table_hash_nr_entries;
 	unsigned long		wait_table_bits;
 
+	/* queue for processes waiting for pressure to relieve */
+	wait_queue_head_t	*pressure_wq;
+
 	/*
 	 * Discontig memory support fields.
 	 */
diff --git a/mm/internal.h b/mm/internal.h
index 6a697bb..caa5bc8 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -251,6 +251,10 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 #define ZONE_RECLAIM_SUCCESS	1
 #endif
 
+extern void check_zone_pressure(struct zone *zone);
+extern long zonepressure_wait(struct zone *zone, unsigned int order,
+			long timeout);
+
 extern int hwpoison_filter(struct page *p);
 
 extern u32 hwpoison_filter_dev_major;
diff --git a/mm/mmzone.c b/mm/mmzone.c
index f5b7d17..e80b89f 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -9,6 +9,7 @@
 #include <linux/mm.h>
 #include <linux/mmzone.h>
 #include <linux/module.h>
+#include <linux/sched.h>
 
 struct pglist_data *first_online_pgdat(void)
 {
@@ -87,3 +88,49 @@ int memmap_valid_within(unsigned long pfn,
 	return 1;
 }
 #endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
+
+void check_zone_pressure(struct zone *zone)
+{
+	/* If no process is waiting, nothing to do */
+	if (!waitqueue_active(zone->pressure_wq))
+		return;
+
+	/* Check if the high watermark is ok for order 0 */
+	if (zone_watermark_ok(zone, 0, low_wmark_pages(zone), 0, 0))
+		wake_up_interruptible(zone->pressure_wq);
+}
+
+/**
+ * zonepressure_wait - Wait for pressure on a zone to ease off
+ * @zone: The zone that is expected to be under pressure
+ * @order: The order the caller is waiting on pages for
+ * @timeout: Wait until pressure is relieved or this timeout is reached
+ *
+ * Waits for up to @timeout jiffies for pressure on a zone to be relieved.
+ * It's considered to be relieved if any direct reclaimer or kswapd brings
+ * the zone above the high watermark
+ */
+long zonepressure_wait(struct zone *zone, unsigned int order, long timeout)
+{
+	long ret;
+	DEFINE_WAIT(wait);
+
+wait_again:
+	prepare_to_wait(zone->pressure_wq, &wait, TASK_INTERRUPTIBLE);
+
+	/*
+	 * The use of io_schedule_timeout() here means that it gets
+	 * accounted for as IO waiting. This may or may not be the case
+	 * but at least this way it gets picked up by vmstat
+	 */
+	ret = io_schedule_timeout(timeout);
+	finish_wait(zone->pressure_wq, &wait);
+
+	/* If woken early, check watermarks before continuing */
+	if (ret && !zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0)) {
+		timeout = ret;
+		goto wait_again;
+	}
+
+	return ret;
+}
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8deb9d0..1383ff9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1734,8 +1734,10 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
 			preferred_zone, migratetype);
 
-		if (!page && gfp_mask & __GFP_NOFAIL)
-			congestion_wait(BLK_RW_ASYNC, HZ/50);
+		if (!page && gfp_mask & __GFP_NOFAIL) {
+			/* If still failing, wait for pressure on zone to relieve */
+			zonepressure_wait(preferred_zone, order, HZ/50);
+		}
 	} while (!page && (gfp_mask & __GFP_NOFAIL));
 
 	return page;
@@ -1905,8 +1907,8 @@ rebalance:
 	/* Check if we should retry the allocation */
 	pages_reclaimed += did_some_progress;
 	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
-		/* Wait for some write requests to complete then retry */
-		congestion_wait(BLK_RW_ASYNC, HZ/50);
+		/* Too much pressure, back off a bit at let reclaimers do work */
+		zonepressure_wait(preferred_zone, order, HZ/50);
 		goto rebalance;
 	}
 
@@ -3254,6 +3256,38 @@ int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 	return 0;
 }
 
+static noinline __init_refok
+void zone_pressure_wq_cleanup(struct zone *zone)
+{
+	struct pglist_data *pgdat = zone->zone_pgdat;
+	size_t free_size = sizeof(wait_queue_head_t);
+
+	if (!slab_is_available())
+		free_bootmem_node(pgdat, __pa(zone->pressure_wq), free_size);
+	else
+		kfree(zone->pressure_wq);
+}
+
+static noinline __init_refok
+int zone_pressure_wq_init(struct zone *zone)
+{
+	struct pglist_data *pgdat = zone->zone_pgdat;
+	size_t alloc_size = sizeof(wait_queue_head_t);
+
+	if (!slab_is_available())
+		zone->pressure_wq = (wait_queue_head_t *)
+			alloc_bootmem_node(pgdat, alloc_size);
+	else
+		zone->pressure_wq = kmalloc(alloc_size, GFP_KERNEL);
+
+	if (!zone->pressure_wq)
+		return -ENOMEM;
+
+	init_waitqueue_head(zone->pressure_wq);
+
+	return 0;
+}
+
 static int __zone_pcp_update(void *data)
 {
 	struct zone *zone = data;
@@ -3306,9 +3340,15 @@ __meminit int init_currently_empty_zone(struct zone *zone,
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int ret;
-	ret = zone_wait_table_init(zone, size);
+
+	ret = zone_pressure_wq_init(zone);
 	if (ret)
 		return ret;
+	ret = zone_wait_table_init(zone, size);
+	if (ret) {
+		zone_pressure_wq_cleanup(zone);
+		return ret;
+	}
 	pgdat->nr_zones = zone_idx(zone) + 1;
 
 	zone->zone_start_pfn = zone_start_pfn;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c26986c..4f92a48 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1709,6 +1709,7 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 		}
 
 		shrink_zone(priority, zone, sc);
+		check_zone_pressure(zone);
 	}
 }
 
@@ -2082,6 +2083,7 @@ loop_again:
 			if (!zone_watermark_ok(zone, order,
 					8*high_wmark_pages(zone), end_zone, 0))
 				shrink_zone(priority, zone, &sc);
+			check_zone_pressure(zone);
 			reclaim_state->reclaimed_slab = 0;
 			nr_slab = shrink_slab(sc.nr_scanned, GFP_KERNEL,
 						lru_pages);
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
