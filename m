Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EE5656B00AE
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 13:04:23 -0400 (EDT)
Subject: RFC [Patch] few useful page reclaim mm tracepoints
From: Larry Woodman <lwoodman@redhat.com>
Content-Type: multipart/mixed; boundary="=-oBBWRKslsj8cAVvg1Ywk"
Date: Mon, 28 Sep 2009 12:09:26 -0400
Message-Id: <1254154166.3219.3.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--=-oBBWRKslsj8cAVvg1Ywk
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Here a few mm page reclaim tracepoints that really show what is being
reclaimed and from where.  mm_get_scanratio reports the number anonymous
and pagecache pages as well as the percent that will be reclaimed from
each.  mm_pagereclaim_shrinkactive reports whether it is shrinking
anonymous or pagecache pages, the number scanned and the number actually
moved(deactivated).  mm_pagereclaim_shrinkinactive reports whether it is
shrinking anonymous or pagecache pages, the number scanned and the
number actually reclaimed.  These three simple mm tracepoints capture
much of the page reclaim activity.

------------------------------------------------------------------------

# tracer: mm 
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
         kswapd1-549   [004]   149.524509: mm_get_scanratio: 2043329
anonymous pages, reclaiming 1% - 1312 pagecache pages, reclaiming 99%
         kswapd1-549   [004]   149.524709: mm_pagereclaim_shrinkactive:
anonymous, scanned 32, moved 32, priority 12
         kswapd1-549   [004]   149.524542:
mm_pagereclaim_shrinkinactive: anonymous, scanned 32, reclaimed 32,
priority 7




--=-oBBWRKslsj8cAVvg1Ywk
Content-Disposition: attachment; filename=upstream.diff
Content-Type: text/x-patch; name=upstream.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/include/trace/events/mm.h b/include/trace/events/mm.h
new file mode 100644
index 0000000..d5a5ec2
--- /dev/null
+++ b/include/trace/events/mm.h
@@ -0,0 +1,94 @@
+#if !defined(_TRACE_MM_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MM_H
+
+#include <linux/mm.h>
+#include <linux/tracepoint.h>
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM mm
+
+TRACE_EVENT(mm_pagereclaim_shrinkactive,
+
+	TP_PROTO(unsigned long scanned, unsigned long moved,
+			int file, int priority),
+
+	TP_ARGS(scanned, moved, file, priority),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, scanned)
+		__field(unsigned long, moved)
+		__field(int, file)
+		__field(int, priority)
+	),
+
+	TP_fast_assign(
+		__entry->scanned = scanned;
+		__entry->moved = moved;
+		__entry->file = file;
+		__entry->priority = priority;
+	),
+
+	TP_printk("%s, scanned %ld, moved %ld, priority %d",
+		__entry->file ? "pagecache" : "anonymous",
+		__entry->scanned, __entry->moved, 
+		__entry->priority)
+	);
+
+TRACE_EVENT(mm_pagereclaim_shrinkinactive,
+
+	TP_PROTO(unsigned long scanned, unsigned long reclaimed,
+			int file, int priority),
+
+	TP_ARGS(scanned, reclaimed, file, priority),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, scanned)
+		__field(unsigned long, reclaimed)
+		__field(int, file)
+		__field(int, priority)
+	),
+
+	TP_fast_assign(
+		__entry->scanned = scanned;
+		__entry->reclaimed = reclaimed;
+		__entry->file = file;
+		__entry->priority = priority;
+	),
+
+	TP_printk("%s, scanned %ld, reclaimed %ld, priority %d",
+		__entry->file ? "pagecache" : "anonymous",
+		__entry->scanned, __entry->reclaimed, 
+		__entry->priority)
+	);
+
+TRACE_EVENT(mm_get_scanratio,
+
+	TP_PROTO(unsigned long anon, unsigned long file,
+		 unsigned long percent_anon, unsigned long percent_file),
+
+	TP_ARGS(anon, file, percent_anon, percent_file),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, anon)
+		__field(unsigned long, file)
+		__field(unsigned long, percent_anon)
+		__field(unsigned long, percent_file)
+	),
+
+	TP_fast_assign(
+		__entry->anon = anon;
+		__entry->file = file;
+		__entry->percent_anon = percent_anon;
+		__entry->percent_file = percent_file;
+	),
+
+	TP_printk("%ld anonymous pages, reclaiming %ld%% - %ld pagecache pages, reclaiming %ld%%",
+		__entry->anon, __entry->percent_anon,
+		__entry->file, __entry->percent_file)
+
+	);
+
+#endif /* _TRACE_MM_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ba8228e..8797a26 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -40,6 +40,8 @@
 #include <linux/memcontrol.h>
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
+#define CREATE_TRACE_POINTS
+#include <trace/events/mm.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1168,6 +1170,8 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 done:
 	local_irq_enable();
 	pagevec_release(&pvec);
+	trace_mm_pagereclaim_shrinkinactive(nr_scanned, nr_reclaimed,
+						file, priority);
 	return nr_reclaimed;
 }
 
@@ -1325,6 +1329,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 						LRU_BASE   + file * LRU_FILE);
 
 	spin_unlock_irq(&zone->lru_lock);
+	trace_mm_pagereclaim_shrinkactive(pgscanned, pgmoved, file, priority);
 }
 
 static int inactive_anon_is_low_global(struct zone *zone)
@@ -1491,6 +1496,7 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
 	/* Normalize to percentages */
 	percent[0] = 100 * ap / (ap + fp + 1);
 	percent[1] = 100 - percent[0];
+	trace_mm_get_scanratio(anon, file, percent[0], percent[1]);
 }
 
 /*

--=-oBBWRKslsj8cAVvg1Ywk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
