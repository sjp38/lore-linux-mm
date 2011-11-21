Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D0E746B006E
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 04:41:07 -0500 (EST)
Message-Id: <20111121093846.764030336@intel.com>
Date: Mon, 21 Nov 2011 17:18:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 6/8] readahead: add debug tracing event
References: <20111121091819.394895091@intel.com>
Content-Disposition: inline; filename=readahead-tracer.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Jens Axboe <jens.axboe@oracle.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

This is very useful for verifying whether the algorithms are working
to our expectaions.

Example output:

# echo 1 > /debug/tracing/events/vfs/readahead/enable
# cp test-file /dev/null
# cat /debug/tracing/trace  # trimmed output
readahead-initial(dev=0:15, ino=100177, req=0+2, ra=0+4-2, async=0) = 4
readahead-subsequent(dev=0:15, ino=100177, req=2+2, ra=4+8-8, async=1) = 8
readahead-subsequent(dev=0:15, ino=100177, req=4+2, ra=12+16-16, async=1) = 16
readahead-subsequent(dev=0:15, ino=100177, req=12+2, ra=28+32-32, async=1) = 32
readahead-subsequent(dev=0:15, ino=100177, req=28+2, ra=60+60-60, async=1) = 24
readahead-subsequent(dev=0:15, ino=100177, req=60+2, ra=120+60-60, async=1) = 0

CC: Ingo Molnar <mingo@elte.hu>
CC: Jens Axboe <jens.axboe@oracle.com>
CC: Steven Rostedt <rostedt@goodmis.org>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/vfs.h |   64 +++++++++++++++++++++++++++++++++++
 mm/readahead.c             |    5 ++
 2 files changed, 69 insertions(+)

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-next/include/trace/events/vfs.h	2011-11-21 17:17:45.000000000 +0800
@@ -0,0 +1,64 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM vfs
+
+#if !defined(_TRACE_VFS_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_VFS_H
+
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(readahead,
+	TP_PROTO(struct address_space *mapping,
+		 pgoff_t offset,
+		 unsigned long req_size,
+		 unsigned int ra_flags,
+		 pgoff_t start,
+		 unsigned int size,
+		 unsigned int async_size,
+		 unsigned int actual),
+
+	TP_ARGS(mapping, offset, req_size,
+		ra_flags, start, size, async_size, actual),
+
+	TP_STRUCT__entry(
+		__field(	dev_t,		dev		)
+		__field(	ino_t,		ino		)
+		__field(	pgoff_t,	offset		)
+		__field(	unsigned long,	req_size	)
+		__field(	unsigned int,	pattern		)
+		__field(	pgoff_t,	start		)
+		__field(	unsigned int,	size		)
+		__field(	unsigned int,	async_size	)
+		__field(	unsigned int,	actual		)
+	),
+
+	TP_fast_assign(
+		__entry->dev		= mapping->host->i_sb->s_dev;
+		__entry->ino		= mapping->host->i_ino;
+		__entry->pattern	= ra_pattern(ra_flags);
+		__entry->offset		= offset;
+		__entry->req_size	= req_size;
+		__entry->start		= start;
+		__entry->size		= size;
+		__entry->async_size	= async_size;
+		__entry->actual		= actual;
+	),
+
+	TP_printk("readahead-%s(dev=%d:%d, ino=%lu, "
+		  "req=%lu+%lu, ra=%lu+%d-%d, async=%d) = %d",
+			ra_pattern_names[__entry->pattern],
+			MAJOR(__entry->dev),
+			MINOR(__entry->dev),
+			__entry->ino,
+			__entry->offset,
+			__entry->req_size,
+			__entry->start,
+			__entry->size,
+			__entry->async_size,
+			__entry->start > __entry->offset,
+			__entry->actual)
+);
+
+#endif /* _TRACE_VFS_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
--- linux-next.orig/mm/readahead.c	2011-11-21 17:17:45.000000000 +0800
+++ linux-next/mm/readahead.c	2011-11-21 17:17:49.000000000 +0800
@@ -48,6 +48,9 @@ static int __init config_readahead_size(
 }
 early_param("readahead", config_readahead_size);
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/vfs.h>
+
 /*
  * Initialise a struct file's readahead state.  Assumes that the caller has
  * memset *ra to zero.
@@ -236,6 +239,8 @@ static void readahead_event(struct addre
 				start, size, async_size, actual);
 	}
 #endif
+	trace_readahead(mapping, offset, req_size, ra_flags,
+			start, size, async_size, actual);
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
