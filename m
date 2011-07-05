Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D8E32900122
	for <linux-mm@kvack.org>; Tue,  5 Jul 2011 04:23:10 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp08.au.ibm.com (8.14.4/8.13.1) with ESMTP id p658Hx8J019382
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:17:59 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p658N7AK987172
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:23:07 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p658N7ch029987
	for <linux-mm@kvack.org>; Tue, 5 Jul 2011 18:23:07 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 5/5] Logging the captured reference data
Date: Tue,  5 Jul 2011 13:52:39 +0530
Message-Id: <1309854159-8277-6-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
References: <1309854159-8277-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, linux-kernel@vger.kernel.org

Hi,

This patch logs the reference data collected using the trace events
framework. To enable capturing the trace, insert the module and mount
debugfs.

# modprobe memref
# echo "memtrace:memtrace" > /debug/tracing/set_event
# echo 1 > /debug/tracing/events/memtrace/memtrace/enable
# echo 1 > /debug/tracing/tracing_on
# echo 1 > /debug/tracing/tracing_enable
# cat /debug/tracing/trace


#
#   TASK-PID    CPU#    TIMESTAMP  FUNCTION
#      | |       |          |         |
  memref-4402  [000]   250.274467: memtrace: 2115 6208 1
  memref-4402  [000]   250.274467: memtrace: 2115 6272 0
  memref-4402  [000]   250.274467: memtrace: 2115 6336 0
  memref-4402  [000]   250.274467: memtrace: 2115 6400 1
                                               |   |   |
                                               V   |   V
                                     sample number | whether referenced
                                                   | or not
                                                   V
                                        physical address of the
                                        start of the block in MB

sample number is a monotonically increasing unique count associated with
a sample. Time stamp is for trace printing not access. The entire access
pattern for all blocks will be at each interval (10ms default).

This data can be post-processed by scripts to generate the overall memory
reference pattern for a given amount of time. Temporal and spatial
reference pattern can be obtained.

This is a statistical sample where any number of reference to a block
over the sampling interval is just marked as one.

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 include/trace/events/memtrace.h |   28 ++++++++++++++++++++++++++++
 lib/memtrace.c                  |    4 ++++
 2 files changed, 32 insertions(+), 0 deletions(-)
 create mode 100644 include/trace/events/memtrace.h

diff --git a/include/trace/events/memtrace.h b/include/trace/events/memtrace.h
new file mode 100644
index 0000000..8a6cdd6
--- /dev/null
+++ b/include/trace/events/memtrace.h
@@ -0,0 +1,28 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM memtrace
+
+#include <linux/tracepoint.h>
+
+#if !defined(_TRACE_MEMTRACE_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MEMTRACE_H
+
+TRACE_EVENT(memtrace,
+	TP_PROTO(unsigned int seq, unsigned long base, unsigned long access_flag),
+	TP_ARGS(seq, base, access_flag),
+	TP_STRUCT__entry(
+		__field(	unsigned int ,	seq		)
+		__field(	unsigned long,	base		)
+		__field(	unsigned long,	access_flag	)
+	),
+	TP_fast_assign(
+		__entry->seq		= seq;
+		__entry->base		= base;
+		__entry->access_flag	= access_flag;
+	),
+	TP_printk("%u %lu %lu", __entry->seq, __entry->base, __entry->access_flag)
+);
+
+#endif /* _TRACE_MEMTRACE_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/lib/memtrace.c b/lib/memtrace.c
index aec5b65..e9cb967 100644
--- a/lib/memtrace.c
+++ b/lib/memtrace.c
@@ -3,6 +3,9 @@
 #include <linux/module.h>
 #include <linux/mm.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/memtrace.h>
+
 /* Trace Unique identifier */
 atomic_t trace_sequence_number;
 pid_t pg_trace_pid;
@@ -195,6 +198,7 @@ void update_and_log_data(void)
 		 *  Can modify to dump only blocks that have been marked
 		 *  accessed
 		 */
+		trace_memtrace(seq, base_addr, access_flag);
 		memtrace_block_accessed[i].access_flag = 0;
  	}
 
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
