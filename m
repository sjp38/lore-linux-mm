Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D66766B006E
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 09:38:53 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/34] vmscan: add shrink_slab tracepoints
Date: Mon, 23 Jul 2012 14:38:19 +0100
Message-Id: <1343050727-3045-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Dave Chinner <dchinner@redhat.com>

commit 095760730c1047c69159ce88021a7fa3833502c8 upstream.

Stable note: This patch makes later patches easier to apply but otherwise
	has little to justify it. It is a diagnostic patch that was part
	of a series addressing excessive slab shrinking after GFP_NOFS
	failures. There is detailed information on the series' motivation
	at https://lkml.org/lkml/2011/6/2/42 .

It is impossible to understand what the shrinkers are actually doing
without instrumenting the code, so add a some tracepoints to allow
insight to be gained.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/trace/events/vmscan.h |   77 +++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                   |    8 ++++-
 2 files changed, 84 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index b2c33bd..36851f7 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -179,6 +179,83 @@ DEFINE_EVENT(mm_vmscan_direct_reclaim_end_template, mm_vmscan_memcg_softlimit_re
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
+		__field(void *, shrink)
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
+		__entry->shrink = shr->shrink;
+		__entry->nr_objects_to_shrink = nr_objects_to_shrink;
+		__entry->gfp_flags = sc->gfp_mask;
+		__entry->pgs_scanned = pgs_scanned;
+		__entry->lru_pgs = lru_pgs;
+		__entry->cache_items = cache_items;
+		__entry->delta = delta;
+		__entry->total_scan = total_scan;
+	),
+
+	TP_printk("%pF %p: objects to shrink %ld gfp_flags %s pgs_scanned %ld lru_pgs %ld cache items %ld delta %lld total_scan %ld",
+		__entry->shrink,
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
+		__field(void *, shrink)
+		__field(long, unused_scan)
+		__field(long, new_scan)
+		__field(int, retval)
+		__field(long, total_scan)
+	),
+
+	TP_fast_assign(
+		__entry->shr = shr;
+		__entry->shrink = shr->shrink;
+		__entry->unused_scan = unused_scan_cnt;
+		__entry->new_scan = new_scan_cnt;
+		__entry->retval = shrinker_retval;
+		__entry->total_scan = new_scan_cnt - unused_scan_cnt;
+	),
+
+	TP_printk("%pF %p: unused scan count %ld new scan count %ld total_scan %ld last shrinker return val %d",
+		__entry->shrink,
+		__entry->shr,
+		__entry->unused_scan,
+		__entry->new_scan,
+		__entry->total_scan,
+		__entry->retval)
+);
 
 DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 72340b84..d875058 100644
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
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
