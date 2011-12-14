Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 9F5666B02DF
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 10:17:26 -0500 (EST)
From: Tao Ma <tm@tao.ma>
Subject: [PATCH v3] vmscan/trace: Add 'file' info to trace_mm_vmscan_lru_isolate.
Date: Wed, 14 Dec 2011 23:14:53 +0800
Message-Id: <1323875693-3504-1-git-send-email-tm@tao.ma>
In-Reply-To: <20111213164507.fbee477c.akpm@linux-foundation.org>
References: <20111213164507.fbee477c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

From: Tao Ma <boyu.mt@taobao.com>

In trace_mm_vmscan_lru_isolate, we don't output 'file'
information to the trace event and it is a bit inconvenient for the
user to get the real information(like pasted below).
mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0

'active' can be gotten by analyzing mode(Thanks go to Minchan and Mel),
So this patch adds 'file' to the trace event and it now looks like:
mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0 file=0

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Tao Ma <boyu.mt@taobao.com>
---
 include/trace/events/vmscan.h |   22 ++++++++++++++--------
 mm/memcontrol.c               |    2 +-
 mm/vmscan.c                   |    2 +-
 3 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index edc4b3d..f64560e 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -266,9 +266,10 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		isolate_mode_t isolate_mode),
+		isolate_mode_t isolate_mode,
+		int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode),
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, file),
 
 	TP_STRUCT__entry(
 		__field(int, order)
@@ -279,6 +280,7 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__field(unsigned long, nr_lumpy_dirty)
 		__field(unsigned long, nr_lumpy_failed)
 		__field(isolate_mode_t, isolate_mode)
+		__field(int, file)
 	),
 
 	TP_fast_assign(
@@ -290,9 +292,10 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__entry->nr_lumpy_dirty = nr_lumpy_dirty;
 		__entry->nr_lumpy_failed = nr_lumpy_failed;
 		__entry->isolate_mode = isolate_mode;
+		__entry->file = file;
 	),
 
-	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu contig_taken=%lu contig_dirty=%lu contig_failed=%lu",
+	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu contig_taken=%lu contig_dirty=%lu contig_failed=%lu file=%d",
 		__entry->isolate_mode,
 		__entry->order,
 		__entry->nr_requested,
@@ -300,7 +303,8 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__entry->nr_taken,
 		__entry->nr_lumpy_taken,
 		__entry->nr_lumpy_dirty,
-		__entry->nr_lumpy_failed)
+		__entry->nr_lumpy_failed,
+		__entry->file)
 );
 
 DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
@@ -312,9 +316,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		isolate_mode_t isolate_mode),
+		isolate_mode_t isolate_mode,
+		int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, file)
 
 );
 
@@ -327,9 +332,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		isolate_mode_t isolate_mode),
+		isolate_mode_t isolate_mode,
+		int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, file)
 
 );
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6aff93c..cd0082d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1249,7 +1249,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 	*scanned = scan;
 
 	trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,
-				      0, 0, 0, mode);
+				      0, 0, 0, mode, file);
 
 	return nr_taken;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f54a05b..a444dc0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1221,7 +1221,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			nr_to_scan, scan,
 			nr_taken,
 			nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed,
-			mode);
+			mode, file);
 	return nr_taken;
 }
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
