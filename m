Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6D80B6B0039
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 04:14:49 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id cc10so2368718wib.0
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 01:14:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si3865171wjf.168.2014.06.27.01.14.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 01:14:48 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/5] mm: page_alloc: Reduce cost of dirty zone balancing
Date: Fri, 27 Jun 2014 09:14:40 +0100
Message-Id: <1403856880-12597-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1403856880-12597-1-git-send-email-mgorman@suse.de>
References: <1403856880-12597-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

When allocating a page cache page for writing the allocator makes an attempt
to proportionally distribute dirty pages between populated zones. The call
to zone_dirty_ok is more expensive than expected because of the number of
vmstats it examines. This patch caches some of that information to reduce
the cost. It means the proportional allocation is based on stale data but
the heuristic should not need perfectly accurate information. As before,
the benefit is marginal but cumulative and depends on the size of the
machine. For a very small machine the effect is visible in system CPU time
for a tiobench test but it'll vary between workloads.

          3.16.0-rc2  3.16.0-rc2
            fairzone   lessdirty
User          393.76      389.03
System        391.50      388.64
Elapsed      5182.86     5186.28

Even though the benefit is small it's generally worthwhile reducing overhead
in the page allocator as it has a tendency to creep up over time.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h    |  2 ++
 include/linux/writeback.h |  1 +
 mm/internal.h             |  1 +
 mm/page-writeback.c       | 23 +++++++++++++++--------
 mm/page_alloc.c           | 16 ++++++++++++----
 5 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f7f93d4..cd7a3d4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -480,6 +480,8 @@ struct zone {
 	/* zone flags, see below */
 	unsigned long		flags;
 
+	unsigned long		dirty_limit_cached;
+
 	ZONE_PADDING(_pad2_)
 
 	/* Write-intensive fields used by page reclaim */
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
index 518e2c3..a7d11b1 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -256,8 +256,6 @@ static unsigned long global_dirtyable_memory(void)
  * Calculate the dirty thresholds based on sysctl parameters
  * - vm.dirty_background_ratio  or  vm.dirty_background_bytes
  * - vm.dirty_ratio             or  vm.dirty_bytes
- * The dirty limits will be lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd) and
- * real-time tasks.
  */
 void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
 {
@@ -298,10 +296,9 @@ void global_dirty_limits(unsigned long *pbackground, unsigned long *pdirty)
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
@@ -310,9 +307,6 @@ static unsigned long zone_dirty_limit(struct zone *zone)
 	else
 		dirty = vm_dirty_ratio * zone_memory / 100;
 
-	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk))
-		dirty += dirty / 4;
-
 	return dirty;
 }
 
@@ -325,7 +319,20 @@ static unsigned long zone_dirty_limit(struct zone *zone)
  */
 bool zone_dirty_ok(struct zone *zone)
 {
-	unsigned long limit = zone_dirty_limit(zone);
+	unsigned long limit = zone->dirty_limit_cached;
+	struct task_struct *tsk = current;
+
+	/*
+	 * The dirty limits are lifted by 1/4 for PF_LESS_THROTTLE (ie. nfsd)
+	 * and real-time tasks to prioritise their allocations.
+	 * PF_LESS_THROTTLE tasks may be cleaning memory and rt tasks may be
+	 * blocking tasks that can clean pages.
+	 */
+	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
+		limit = zone_dirty_limit(zone);
+		zone->dirty_limit_cached = limit;
+		limit += limit / 4;
+	}
 
 	return zone_page_state(zone, NR_FILE_DIRTY) +
 	       zone_page_state(zone, NR_UNSTABLE_NFS) +
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d2ed2e0..cf8e858 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1941,9 +1941,7 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
-	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
-				(gfp_mask & __GFP_WRITE);
-	int nr_fair_skipped = 0;
+	int nr_fair_skipped = 0, nr_fail_dirty = 0;
 	bool zonelist_rescan;
 
 zonelist_scan:
@@ -2005,8 +2003,11 @@ zonelist_scan:
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
@@ -2108,6 +2109,11 @@ this_zone_full:
 		zonelist_rescan = true;
 	}
 
+	if ((alloc_flags & ALLOC_DIRTY) && nr_fail_dirty) {
+		alloc_flags &= ~ALLOC_DIRTY;
+		zonelist_rescan = true;
+	}
+
 	if (zonelist_rescan)
 		goto zonelist_scan;
 
@@ -2765,6 +2771,8 @@ retry_cpuset:
 
 	if (zonelist->fair_enabled)
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
