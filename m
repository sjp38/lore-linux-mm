Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 176E26B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 03:01:21 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 02/12] vmscan: shrinker->nr updates race and go wrong
Date: Thu,  2 Jun 2011 17:00:57 +1000
Message-Id: <1306998067-27659-3-git-send-email-david@fromorbit.com>
In-Reply-To: <1306998067-27659-1-git-send-email-david@fromorbit.com>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

From: Dave Chinner <dchinner@redhat.com>

shrink_slab() allows shrinkers to be called in parallel so the
struct shrinker can be updated concurrently. It does not provide any
exclusio for such updates, so we can get the shrinker->nr value
increasing or decreasing incorrectly.

As a result, when a shrinker repeatedly returns a value of -1 (e.g.
a VFS shrinker called w/ GFP_NOFS), the shrinker->nr goes haywire,
sometimes updating with the scan count that wasn't used, sometimes
losing it altogether. Worse is when a shrinker does work and that
update is lost due to racy updates, which means the shrinker will do
the work again!

Fix this by making the total_scan calculations independent of
shrinker->nr, and making the shrinker->nr updates atomic w.r.t. to
other updates via cmpxchg loops.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/trace/events/vmscan.h |   26 ++++++++++++++----------
 mm/vmscan.c                   |   43 ++++++++++++++++++++++++++++++----------
 2 files changed, 47 insertions(+), 22 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index c798cd7..6147b4e 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -311,12 +311,13 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
 );
 
 TRACE_EVENT(mm_shrink_slab_start,
-	TP_PROTO(struct shrinker *shr, struct shrink_control *sc,
+	TP_PROTO(struct shrinker *shr, struct shrink_control *sc, long shr_nr,
 		unsigned long pgs_scanned, unsigned long lru_pgs,
 		unsigned long cache_items, unsigned long long delta,
 		unsigned long total_scan),
 
-	TP_ARGS(shr, sc, pgs_scanned, lru_pgs, cache_items, delta, total_scan),
+	TP_ARGS(shr, sc, shr_nr, pgs_scanned, lru_pgs,
+		cache_items, delta, total_scan),
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
@@ -331,7 +332,7 @@ TRACE_EVENT(mm_shrink_slab_start,
 
 	TP_fast_assign(
 		__entry->shr = shr;
-		__entry->shr_nr = shr->nr;
+		__entry->shr_nr = shr_nr;
 		__entry->gfp_flags = sc->gfp_mask;
 		__entry->pgs_scanned = pgs_scanned;
 		__entry->lru_pgs = lru_pgs;
@@ -353,27 +354,30 @@ TRACE_EVENT(mm_shrink_slab_start,
 
 TRACE_EVENT(mm_shrink_slab_end,
 	TP_PROTO(struct shrinker *shr, int shrinker_ret,
-		unsigned long total_scan),
+		long old_nr, long new_nr),
 
-	TP_ARGS(shr, shrinker_ret, total_scan),
+	TP_ARGS(shr, shrinker_ret, old_nr, new_nr),
 
 	TP_STRUCT__entry(
 		__field(struct shrinker *, shr)
-		__field(long, shr_nr)
+		__field(long, old_nr)
+		__field(long, new_nr)
 		__field(int, shrinker_ret)
-		__field(unsigned long, total_scan)
+		__field(long, total_scan)
 	),
 
 	TP_fast_assign(
 		__entry->shr = shr;
-		__entry->shr_nr = shr->nr;
+		__entry->old_nr = old_nr;
+		__entry->new_nr = new_nr;
 		__entry->shrinker_ret = shrinker_ret;
-		__entry->total_scan = total_scan;
+		__entry->total_scan = new_nr - old_nr;
 	),
 
-	TP_printk("shrinker %p: nr %ld total_scan %ld return val %d",
+	TP_printk("shrinker %p: old_nr %ld new_nr %ld total_scan %ld return val %d",
 		__entry->shr,
-		__entry->shr_nr,
+		__entry->old_nr,
+		__entry->new_nr,
 		__entry->total_scan,
 		__entry->shrinker_ret)
 );
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 48e3fbd..dce2767 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -251,17 +251,29 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		unsigned long total_scan;
 		unsigned long max_pass;
 		int shrink_ret = 0;
+		long nr;
+		long new_nr;
 
+		/*
+		 * copy the current shrinker scan count into a local variable
+		 * and zero it so that other concurrent shrinker invocations
+		 * don't also do this scanning work.
+		 */
+		do {
+			nr = shrinker->nr;
+		} while (cmpxchg(&shrinker->nr, nr, 0) != nr);
+
+		total_scan = nr;
 		max_pass = do_shrinker_shrink(shrinker, shrink, 0);
 		delta = (4 * nr_pages_scanned) / shrinker->seeks;
 		delta *= max_pass;
 		do_div(delta, lru_pages + 1);
-		shrinker->nr += delta;
-		if (shrinker->nr < 0) {
+		total_scan += delta;
+		if (total_scan < 0) {
 			printk(KERN_ERR "shrink_slab: %pF negative objects to "
 			       "delete nr=%ld\n",
-			       shrinker->shrink, shrinker->nr);
-			shrinker->nr = max_pass;
+			       shrinker->shrink, total_scan);
+			total_scan = max_pass;
 		}
 
 		/*
@@ -269,13 +281,11 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		 * never try to free more than twice the estimate number of
 		 * freeable entries.
 		 */
-		if (shrinker->nr > max_pass * 2)
-			shrinker->nr = max_pass * 2;
+		if (total_scan > max_pass * 2)
+			total_scan = max_pass * 2;
 
-		total_scan = shrinker->nr;
-		shrinker->nr = 0;
 
-		trace_mm_shrink_slab_start(shrinker, shrink, nr_pages_scanned,
+		trace_mm_shrink_slab_start(shrinker, shrink, nr, nr_pages_scanned,
 					lru_pages, max_pass, delta, total_scan);
 
 		while (total_scan >= SHRINK_BATCH) {
@@ -295,8 +305,19 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 			cond_resched();
 		}
 
-		shrinker->nr += total_scan;
-		trace_mm_shrink_slab_end(shrinker, shrink_ret, total_scan);
+		/*
+		 * move the unused scan count back into the shrinker in a
+		 * manner that handles concurrent updates. If we exhausted the
+		 * scan, there is no need to do an update.
+		 */
+		do {
+			nr = shrinker->nr;
+			new_nr = total_scan + nr;
+			if (total_scan <= 0)
+				break;
+		} while (cmpxchg(&shrinker->nr, nr, new_nr) != nr);
+
+		trace_mm_shrink_slab_end(shrinker, shrink_ret, nr, new_nr);
 	}
 	up_read(&shrinker_rwsem);
 out:
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
