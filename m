Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7F190011A
	for <linux-mm@kvack.org>; Fri,  8 Jul 2011 00:15:07 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 02/14] vmscan: add shrink_slab tracepoints
Date: Fri,  8 Jul 2011 14:14:34 +1000
Message-Id: <1310098486-6453-3-git-send-email-david@fromorbit.com>
In-Reply-To: <1310098486-6453-1-git-send-email-david@fromorbit.com>
References: <1310098486-6453-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

From: Dave Chinner <dchinner@redhat.com>

D?t is impossible to understand what the shrinkers are actually doing
without instrumenting the code, so add a some tracepoints to allow
insight to be gained.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 include/trace/events/vmscan.h |   71 +++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                   |    8 ++++-
 2 files changed, 78 insertions(+), 1 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index b2c33bd..5f3fea4 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -179,6 +179,77 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_re
 	TP_ARGS(nr_reclaimed)
 );
 
+TRACE_EVENT(mm_shrink_slab_start,
+	TP_PROTO(struct shrinker *shr, struct shrink_control *sc,
+		long nr_objects_to_shrink, unsigned long pgs_scanned,
+		unsigned long lru_pgs, unsigned long cache_items,
+		unsigned long long delta, unsigned long total_scan),
+
+	TP_ARGS(shr, sc, nr_objects_to_shrink, pgs_scanned, lru_pgs,
+		cache_items, delta, total_scan),
+
+	TP_STRUCT__entry(
+		__field(struct shrinker *, shr)
+		__field(long, nr_objects_to_shrink)
+		__field(gfp_t, gfp_flags)
+		__field(unsigned long, pgs_scanned)
+		__field(unsigned long, lru_pgs)
+		__field(unsigned long, cache_items)
+		__field(unsigned long long, delta)
+		__field(unsigned long, total_scan)
+	),
+
+	TP_fast_assign(
+		__entry->shr = shr;
+		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
+		__entry->gfp_flags = sc->gfp_mask;
+		__entry->pgs_scanned = pgs_scanned;
+		__entry->lru_pgs = lru_pgs;
+		__entry->cache_items = cache_items;
+		__entry->delta = delta;
+		__entry->total_scan = total_scan;
+	),
+
+	TP_printk("shrinker %p: objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
+		__entry->shr,
+		__entry->nr_objects_to_shrink,
+		show_gfp_flags(__entry->gfp_flags),
+		__entry->pgs_scanned,
+		__entry->lru_pgs,
+		__entry->cache_items,
+		__entry->delta,
+		__entry->total_scan)
+);
+
+TRACE_EVENT(mm_shrink_slab_end,
+	TP_PROTO(struct shrinker *shr, int shrinker_retval,
+		long unused_scan_cnt, long new_scan_cnt),
+
+	TP_ARGS(shr, shrinker_retval, unused_scan_cnt, new_scan_cnt),
+
+	TP_STRUCT__entry(
+		__field(struct shrinker *, shr)
+		__field(long, unused_scan)
+		__field(long, new_scan)
+		__field(int, retval)
+		__field(long, total_scan)
+	),
+
+	TP_fast_assign(
+		__entry->shr = shr;
+		__entry->unused_scan = unused_scan_cnt;
+		__entry->new_scan = new_scan_cnt;
+		__entry->retval = shrinker_retval;
+		__entry->total_scan = new_scan_cnt - unused_scan_cnt;
+	),
+
+	TP_printk("shrinker %p: unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+		__entry->shr,
+		__entry->unused_scan,
+		__entry->new_scan,
+		__entry->total_scan,
+		__entry->retval)
+);
 
 DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 8ff834e..646cb6c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -250,6 +250,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		unsigned long long delta;
 		unsigned long total_scan;
 		unsigned long max_pass;
+		int shrink_ret = 0;
 
 		max_pass = do_shrinker_shrink(shrinker, shrink, 0);
 		delta = (4 * nr_pages_scanned) / shrinker->seeks;
@@ -274,9 +275,12 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		total_scan = shrinker->nr;
 		shrinker->nr = 0;
 
+		trace_mm_shrink_slab_start(shrinker, shrink, total_scan,
+					nr_pages_scanned, lru_pages,
+					max_pass, delta, total_scan);
+
 		while (total_scan >= SHRINK_BATCH) {
 			long this_scan = SHRINK_BATCH;
-			int shrink_ret;
 			int nr_before;
 
 			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
@@ -293,6 +297,8 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 		}
 
 		shrinker->nr += total_scan;
+		trace_mm_shrink_slab_end(shrinker, shrink_ret, total_scan,
+					 shrinker->nr);
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
