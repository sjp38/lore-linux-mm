Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 7A1F66B0062
	for <linux-mm@kvack.org>; Sat, 10 Dec 2011 11:13:41 -0500 (EST)
From: Tao Ma <tm@tao.ma>
Subject: [PATCH] vmscan/trace: Add 'active' and 'file' info to trace_mm_vmscan_lru_isolate.
Date: Sun, 11 Dec 2011 00:10:51 +0800
Message-Id: <1323533451-2953-1-git-send-email-tm@tao.ma>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

From: Tao Ma <boyu.mt@taobao.com>

In trace_mm_vmscan_lru_isolate, we don't output 'active' and 'file'
information to the trace event and it is a bit inconvenient for the
user to get the real information(like pasted below).
mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0

So this patch adds these 2 info to the trace event and it now looks like:
mm_vmscan_lru_isolate: isolate_mode=2 order=0 nr_requested=32 nr_scanned=32
nr_taken=32 contig_taken=0 contig_dirty=0 contig_failed=0 lru=1,0

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Tao Ma <boyu.mt@taobao.com>
---
 include/trace/events/vmscan.h |   25 +++++++++++++++++--------
 mm/memcontrol.c               |    2 +-
 mm/vmscan.c                   |    6 +++---
 3 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index edc4b3d..a0083b8 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -266,9 +266,10 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		isolate_mode_t isolate_mode),
+		isolate_mode_t isolate_mode,
+		int active, int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode),
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, active, file),
 
 	TP_STRUCT__entry(
 		__field(int, order)
@@ -279,6 +280,8 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__field(unsigned long, nr_lumpy_dirty)
 		__field(unsigned long, nr_lumpy_failed)
 		__field(isolate_mode_t, isolate_mode)
+		__field(int, active)
+		__field(int, file)
 	),
 
 	TP_fast_assign(
@@ -290,9 +293,11 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__entry->nr_lumpy_dirty = nr_lumpy_dirty;
 		__entry->nr_lumpy_failed = nr_lumpy_failed;
 		__entry->isolate_mode = isolate_mode;
+		__entry->active = active;
+		__entry->file = file;
 	),
 
-	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu contig_taken=%lu contig_dirty=%lu contig_failed=%lu",
+	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu contig_taken=%lu contig_dirty=%lu contig_failed=%lu lru=%d,%d",
 		__entry->isolate_mode,
 		__entry->order,
 		__entry->nr_requested,
@@ -300,7 +305,9 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 		__entry->nr_taken,
 		__entry->nr_lumpy_taken,
 		__entry->nr_lumpy_dirty,
-		__entry->nr_lumpy_failed)
+		__entry->nr_lumpy_failed,
+		__entry->active,
+		__entry->file)
 );
 
 DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
@@ -312,9 +319,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		isolate_mode_t isolate_mode),
+		isolate_mode_t isolate_mode,
+		int active, int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, active, file)
 
 );
 
@@ -327,9 +335,10 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
 		unsigned long nr_lumpy_taken,
 		unsigned long nr_lumpy_dirty,
 		unsigned long nr_lumpy_failed,
-		isolate_mode_t isolate_mode),
+		isolate_mode_t isolate_mode,
+		int active, int file),
 
-	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode)
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode, active, file)
 
 );
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6aff93c..246fbce 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1249,7 +1249,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 	*scanned = scan;
 
 	trace_mm_vmscan_memcg_isolate(0, nr_to_scan, scan, nr_taken,
-				      0, 0, 0, mode);
+				      0, 0, 0, mode, active, file);
 
 	return nr_taken;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f54a05b..97955ca 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1103,7 +1103,7 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
 		unsigned long *scanned, int order, isolate_mode_t mode,
-		int file)
+		int active, int file)
 {
 	unsigned long nr_taken = 0;
 	unsigned long nr_lumpy_taken = 0;
@@ -1221,7 +1221,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			nr_to_scan, scan,
 			nr_taken,
 			nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed,
-			mode);
+			mode, active, file);
 	return nr_taken;
 }
 
@@ -1237,7 +1237,7 @@ static unsigned long isolate_pages_global(unsigned long nr,
 	if (file)
 		lru += LRU_FILE;
 	return isolate_lru_pages(nr, &z->lru[lru].list, dst, scanned, order,
-								mode, file);
+							mode, active, file);
 }
 
 /*
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
