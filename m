Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 870816B0005
	for <linux-mm@kvack.org>; Sun, 20 Jan 2013 22:43:25 -0500 (EST)
Date: Mon, 21 Jan 2013 14:43:00 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301210343.r0L3h0rP030204@como.maths.usyd.edu.au>
Subject: [RFC] Comments and questions
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: 695182@bugs.debian.org

Many comments and questions:

In __alloc_pages_slowpath(), did_some_progress is set twice but only
checked after the second setting, so the first setting is wasted.

[Setting of MAX_PAUSE reported previously.]

The setting of highmem_is_dirtyable seems used only to calculate limits
and threshholds, not used in any decisions: seems odd.

[Subtraction of min_free_kbytes reported previously.]

Sanity check of input values in bdi_position_ratio().

[Difference (setpoint-dirty) reported previously.]

Seems that bdi_max_pause() always returns a too-small value, maybe it
should simply return a fixed value.

A test in balance_dirty_pages() marked unlikely() observed to be quite
common.

Maybe zone_reclaimable() should return true with non-zero
NR_SLAB_RECLAIMABLE.

Seems that all_unreclaimable may be set wrongly or too early.

Maybe global_reclaimable_pages() and zone_reclaimable_pages() should add
or include NR_SLAB_RECLAIMABLE.

(This does not solve the PAE OOM issue.)

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

Reported-by: Paul Szabo <psz@maths.usyd.edu.au>
Reference: http://bugs.debian.org/695182
Signed-off-by: Paul Szabo <psz@maths.usyd.edu.au>

--- mm/page_alloc.c.old	2012-12-06 22:20:40.000000000 +1100
+++ mm/page_alloc.c	2013-01-18 14:07:31.000000000 +1100
@@ -2207,6 +2207,10 @@ rebalance:
 	 * If we failed to make any progress reclaiming, then we are
 	 * running out of options and have to consider going OOM
 	 */
+	/*
+	 * We had did_some_progress set twice, but is only checked here
+	 * so the first setting was lost. Is that as should be?
+	 */
 	if (!did_some_progress) {
 		if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
 			if (oom_killer_disabled)
--- mm/page-writeback.c.old	2012-12-06 22:20:40.000000000 +1100
+++ mm/page-writeback.c	2013-01-20 07:35:52.000000000 +1100
@@ -39,7 +39,7 @@
 /*
  * Sleep at most 200ms at a time in balance_dirty_pages().
  */
-#define MAX_PAUSE		max(HZ/5, 1)
+#define MAX_PAUSE		max(HZ/5, 4)
 
 /*
  * Estimate write bandwidth at 200ms intervals.
@@ -343,12 +343,22 @@ static unsigned long highmem_dirtyable_m
 unsigned long determine_dirtyable_memory(void)
 {
 	unsigned long x;
+	extern int min_free_kbytes;
 
 	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
 
+	/*
+	 * Seems that highmem_is_dirtyable is only used here, in the
+	 * calculation of limits and threshholds of dirtiness, not in deciding
+	 * where to put dirty things. Is that so? Is that as should be?
+	 * What is the recommended setting of highmem_is_dirtyable?
+	 */
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
 
+	/* Subtract min_free_kbytes */
+	x -= min(x, min_free_kbytes >> (PAGE_SHIFT - 10));
+
 	return x + 1;	/* Ensure that we never return 0 */
 }
 
@@ -541,6 +551,9 @@ static unsigned long bdi_position_ratio(
 
 	if (unlikely(dirty >= limit))
 		return 0;
+	/* Never seen this happen, just sanity-check paranoia */
+	if (unlikely(freerun >= dirty))
+		return 16 << RATELIMIT_CALC_SHIFT;
 
 	/*
 	 * global setpoint
@@ -559,7 +572,7 @@ static unsigned long bdi_position_ratio(
 	 *     => fast response on large errors; small oscillation near setpoint
 	 */
 	setpoint = (freerun + limit) / 2;
-	x = div_s64((setpoint - dirty) << RATELIMIT_CALC_SHIFT,
+	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
 		    limit - setpoint + 1);
 	pos_ratio = x;
 	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
@@ -995,6 +1008,13 @@ static unsigned long bdi_max_pause(struc
 	 * The pause time will be settled within range (max_pause/4, max_pause).
 	 * Apply a minimal value of 4 to get a non-zero max_pause/4.
 	 */
+	/*
+	 * On large machine it seems we always return 4,
+	 * on smaller desktop machine mostly return 5 (rarely 9 or 14).
+	 * Are those too small? Should we return something fixed e.g.
+	return (HZ/10);
+	 * instead of this wasted/useless calculation?
+	 */
 	return clamp_val(t, 4, MAX_PAUSE);
 }
 
@@ -1109,6 +1129,11 @@ static void balance_dirty_pages(struct a
 		}
 		pause = HZ * pages_dirtied / task_ratelimit;
 		if (unlikely(pause <= 0)) {
+			/*
+			 * Not unlikely: often we get zero.
+			 * Seems we always get 0 on large machine.
+			 * Should not do a pause of 1 here?
+			 */
 			trace_balance_dirty_pages(bdi,
 						  dirty_thresh,
 						  background_thresh,
--- mm/vmscan.c.old	2012-12-06 22:20:40.000000000 +1100
+++ mm/vmscan.c	2013-01-20 06:37:38.000000000 +1100
@@ -213,6 +213,8 @@ static inline int do_shrinker_shrink(str
 /*
  * Call the shrink functions to age shrinkable caches
  *
+ * These comments seem to be about filesystem caches, though slabs may be
+ * used elsewhere also.
  * Here we assume it costs one seek to replace a lru page and that it also
  * takes a seek to recreate a cache object.  With this in mind we age equal
  * percentages of the lru and ageable caches.  This should balance the seeks
@@ -2244,6 +2246,9 @@ static bool shrink_zones(int priority, s
 
 static bool zone_reclaimable(struct zone *zone)
 {
+	/* Should we return true with NR_SLAB_RECLAIMABLE ? */
+	/*if (zone_page_state(zone,NR_SLAB_RECLAIMABLE)>0) return true; */
+	/* Wonder about the "correctness" of that *6 factor. */
 	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
 }
 
@@ -2739,6 +2744,18 @@ loop_again:
 
 				if (nr_slab == 0 && !zone_reclaimable(zone))
 					zone->all_unreclaimable = 1;
+				/*
+				 * Beware of all_unreclaimable. We set it when
+				 *  - shrink_slab() returns 0, which may happen
+				 *    because of temporary failure or because of
+				 *    some internal restrictions, and
+				 *  - zone_reclaimable() returns false, which
+				 *    may happen though NR_SLAB_RECLAIMABLE is
+				 *    non-zero
+				 * so it may be set "wrong" or prematurely.
+				 * And then we do not unset all_unreclaimable
+				 * until some page is freed (in page_alloc.c).
+				 */
 			}
 
 			/*
@@ -3066,6 +3083,7 @@ unsigned long global_reclaimable_pages(v
 {
 	int nr;
 
+	/* Should we add/include global_page_state(NR_SLAB_RECLAIMABLE) ? */
 	nr = global_page_state(NR_ACTIVE_FILE) +
 	     global_page_state(NR_INACTIVE_FILE);
 
@@ -3080,6 +3098,7 @@ unsigned long zone_reclaimable_pages(str
 {
 	int nr;
 
+	/* Should we add/include zone_page_state(zone,NR_SLAB_RECLAIMABLE) ? */
 	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
 	     zone_page_state(zone, NR_INACTIVE_FILE);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
