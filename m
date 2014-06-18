Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A01796B003B
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 04:23:35 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id b13so441106wgh.11
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 01:23:35 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ej5si15717665wid.19.2014.06.18.01.23.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Jun 2014 01:23:32 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/4] mm: page_alloc: Reduce cost of dirty zone balancing
Date: Wed, 18 Jun 2014 09:23:27 +0100
Message-Id: <1403079807-24690-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1403079807-24690-1-git-send-email-mgorman@suse.de>
References: <1403079807-24690-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>
Cc: Jan Kara <jack@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mgorman@suse.de>

When allocating a page cache page for writing the allocator makes an attempt
to proportionally distribute dirty pages between populated zones. The call
to zone_dirty_ok is more expensive than expected because of the number of
vmstats it examines. This patch caches some of that information to reduce
the cost. It means the proportional allocation is based on stale data but
the heuristic should not need perfectly accurate information. The impact
is less than the fair zone policy patch but is still visible

                                      3.16.0-rc1            3.16.0-rc1            3.16.0-rc1            3.16.0-rc1                 3.0.0
                                         vanilla          cfq600              fairzone             lessdirty                     vanilla
Min    SeqRead-MB/sec-1         121.06 (  0.00%)      120.38 ( -0.56%)      130.25 (  7.59%)      132.03 (  9.06%)      134.04 ( 10.72%)
Min    SeqRead-MB/sec-2         100.06 (  0.00%)       99.17 ( -0.89%)      112.73 ( 12.66%)      114.83 ( 14.76%)      120.76 ( 20.69%)
Min    SeqRead-MB/sec-4          97.10 (  0.00%)       99.14 (  2.10%)      107.24 ( 10.44%)      108.06 ( 11.29%)      114.49 ( 17.91%)
Min    SeqRead-MB/sec-8          81.45 (  0.00%)       89.18 (  9.49%)       94.94 ( 16.56%)       96.41 ( 18.37%)       98.04 ( 20.37%)
Min    SeqRead-MB/sec-16         67.39 (  0.00%)       74.52 ( 10.58%)       81.37 ( 20.74%)       78.62 ( 16.66%)       79.49 ( 17.96%)
Min    RandRead-MB/sec-1          1.06 (  0.00%)        1.09 (  2.83%)        1.09 (  2.83%)        1.07 (  0.94%)        1.07 (  0.94%)
Min    RandRead-MB/sec-2          1.28 (  0.00%)        1.27 ( -0.78%)        1.29 (  0.78%)        1.29 (  0.78%)        1.19 ( -7.03%)
Min    RandRead-MB/sec-4          1.55 (  0.00%)        1.44 ( -7.10%)        1.49 ( -3.87%)        1.53 ( -1.29%)        1.47 ( -5.16%)
Min    RandRead-MB/sec-8          1.73 (  0.00%)        1.75 (  1.16%)        1.68 ( -2.89%)        1.70 ( -1.73%)        1.61 ( -6.94%)
Min    RandRead-MB/sec-16         1.76 (  0.00%)        1.83 (  3.98%)        1.86 (  5.68%)        1.77 (  0.57%)        1.73 ( -1.70%)
Min    SeqWrite-MB/sec-1        113.95 (  0.00%)      115.98 (  1.78%)      116.09 (  1.88%)      115.30 (  1.18%)      113.11 ( -0.74%)
Min    SeqWrite-MB/sec-2        103.00 (  0.00%)      103.27 (  0.26%)      104.31 (  1.27%)      104.26 (  1.22%)      103.49 (  0.48%)
Min    SeqWrite-MB/sec-4         98.42 (  0.00%)       98.16 ( -0.26%)       99.17 (  0.76%)       98.69 (  0.27%)       95.08 ( -3.39%)
Min    SeqWrite-MB/sec-8         92.91 (  0.00%)       93.32 (  0.44%)       93.14 (  0.25%)       93.33 (  0.45%)       89.43 ( -3.75%)
Min    SeqWrite-MB/sec-16        85.96 (  0.00%)       86.33 (  0.43%)       86.71 (  0.87%)       86.67 (  0.83%)       83.04 ( -3.40%)
Min    RandWrite-MB/sec-1         1.34 (  0.00%)        1.30 ( -2.99%)        1.34 (  0.00%)        1.32 ( -1.49%)        1.35 (  0.75%)
Min    RandWrite-MB/sec-2         1.40 (  0.00%)        1.30 ( -7.14%)        1.40 (  0.00%)        1.38 ( -1.43%)        1.44 (  2.86%)
Min    RandWrite-MB/sec-4         1.38 (  0.00%)        1.35 ( -2.17%)        1.36 ( -1.45%)        1.38 (  0.00%)        1.37 ( -0.72%)
Min    RandWrite-MB/sec-8         1.34 (  0.00%)        1.35 (  0.75%)        1.33 ( -0.75%)        1.32 ( -1.49%)        1.33 ( -0.75%)
Min    RandWrite-MB/sec-16        1.35 (  0.00%)        1.33 ( -1.48%)        1.33 ( -1.48%)        1.33 ( -1.48%)        1.33 ( -1.48%)
Mean   SeqRead-MB/sec-1         121.88 (  0.00%)      121.60 ( -0.23%)      131.68 (  8.04%)      133.84 (  9.81%)      134.59 ( 10.42%)
Mean   SeqRead-MB/sec-2         101.99 (  0.00%)      102.35 (  0.36%)      113.24 ( 11.04%)      115.01 ( 12.77%)      122.59 ( 20.20%)
Mean   SeqRead-MB/sec-4          97.42 (  0.00%)       99.71 (  2.35%)      107.43 ( 10.28%)      108.40 ( 11.27%)      114.78 ( 17.82%)
Mean   SeqRead-MB/sec-8          83.39 (  0.00%)       90.39 (  8.39%)       96.81 ( 16.09%)       97.50 ( 16.92%)      100.14 ( 20.09%)
Mean   SeqRead-MB/sec-16         68.90 (  0.00%)       77.29 ( 12.18%)       81.88 ( 18.85%)       82.14 ( 19.22%)       81.64 ( 18.50%)

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h    |  2 ++
 include/linux/writeback.h |  1 +
 mm/internal.h             |  1 +
 mm/page-writeback.c       | 15 +++++++++------
 mm/page_alloc.c           | 15 ++++++++++++---
 5 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e041f63..9ec4459 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -399,6 +399,8 @@ struct zone {
 	int			compact_order_failed;
 #endif
 
+	unsigned long		dirty_limit_cached;
+
 	ZONE_PADDING(_pad1_)
 
 	/* Fields commonly accessed by the page reclaim scanner */
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 5777c13..90190d4 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -121,6 +121,7 @@ static inline void laptop_sync_completion(void) { }
 #endif
 void throttle_vm_writeout(gfp_t gfp_mask);
 bool zone_dirty_ok(struct zone *zone);
+unsigned long zone_dirty_limit(struct zone *zone);
 
 extern unsigned long global_dirty_limit;
 
diff --git a/mm/internal.h b/mm/internal.h
index 7f22a11f..f31e3b2 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -370,5 +370,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
 #define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
 #define ALLOC_FAIR		0x100 /* fair zone allocation */
+#define ALLOC_DIRTY		0x200 /* spread GFP_WRITE allocations */
 
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 518e2c3..1990e9a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -298,10 +298,9 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
  * Returns the maximum number of dirty pages allowed in a zone, based
  * on the zone's dirtyable memory.
  */
-static unsigned long zone_dirty_limit(struct zone *zone)
+unsigned long zone_dirty_limit(struct zone *zone)
 {
 	unsigned long zone_memory = zone_dirtyable_memory(zone);
-	struct task_struct *tsk = current;
 	unsigned long dirty;
 
 	if (vm_dirty_bytes)
@@ -310,9 +309,6 @@ static unsigned long zone_dirty_limit(struct zone *zone)
 	else
 		dirty = vm_dirty_ratio * zone_memory / 100;
 
-	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk))
-		dirty += dirty / 4;
-
 	return dirty;
 }
 
@@ -325,7 +321,14 @@ static unsigned long zone_dirty_limit(struct zone *zone)
  */
 bool zone_dirty_ok(struct zone *zone)
 {
-	unsigned long limit = zone_dirty_limit(zone);
+	unsigned long limit = zone->dirty_limit_cached;
+	struct task_struct *tsk = current;
+
+	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
+		limit = zone_dirty_limit(zone);
+		zone->dirty_limit_cached = limit;
+		limit += limit / 4;
+	}
 
 	return zone_page_state(zone, NR_FILE_DIRTY) +
 	       zone_page_state(zone, NR_UNSTABLE_NFS) +
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7614404..c0cddae 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1941,9 +1941,8 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
-	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
-				(gfp_mask & __GFP_WRITE);
 	int nr_fair_skipped = 0, nr_fair_eligible = 0, nr_fail_watermark = 0;
+	int nr_fail_dirty = 0;
 	bool zonelist_rescan;
 
 zonelist_scan:
@@ -2005,8 +2004,11 @@ zonelist_scan:
 		 * will require awareness of zones in the
 		 * dirty-throttling and the flusher threads.
 		 */
-		if (consider_zone_dirty && !zone_dirty_ok(zone))
+		if ((alloc_flags & ALLOC_DIRTY) && !zone_dirty_ok(zone)) {
+			nr_fail_dirty++;
+			zone->dirty_limit_cached = zone_dirty_limit(zone);
 			continue;
+		}
 
 		mark = zone->watermark[alloc_flags & ALLOC_WMARK_MASK];
 		if (!zone_watermark_ok(zone, order, mark,
@@ -2120,6 +2122,11 @@ this_zone_full:
 		}
 	}
 
+	if ((alloc_flags & ALLOC_DIRTY) && nr_fail_dirty) {
+		alloc_flags &= ~ALLOC_DIRTY;
+		zonelist_rescan = true;
+	}
+
 	if (zonelist_rescan)
 		goto zonelist_scan;
 
@@ -2777,6 +2784,8 @@ retry_cpuset:
 
 	if (preferred_zoneref->fair_enabled)
 		alloc_flags |= ALLOC_FAIR;
+	if (gfp_mask & __GFP_WRITE)
+		alloc_flags |= ALLOC_DIRTY;
 #ifdef CONFIG_CMA
 	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
