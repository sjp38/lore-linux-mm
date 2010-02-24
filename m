From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 09/15] readahead: add tracing event
Date: Wed, 24 Feb 2010 11:10:10 +0800
Message-ID: <20100224031054.876156496@intel.com>
References: <20100224031001.026464755@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1Nk7gV-0006XS-5r
	for glkm-linux-mm-2@m.gmane.org; Wed, 24 Feb 2010 04:13:11 +0100
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 402E36B0089
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 22:13:09 -0500 (EST)
Content-Disposition: inline; filename=readahead-tracer.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <jens.axboe@oracle.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Chris Mason <chris.mason@oracle.com>, Clemens Ladisch <clemens@ladisch.de>, Olivier Galibert <galibert@pobox.com>, Vivek Goyal <vgoyal@redhat.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Matt Mackall <mpm@selenic.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Example output:

# echo 1 > /debug/tracing/events/readahead/enable
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
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/readahead.h |   78 +++++++++++++++++++++++++++++
 mm/readahead.c                   |   11 ++++
 2 files changed, 89 insertions(+)

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/include/trace/events/readahead.h	2010-02-24 10:44:46.000000000 +0800
@@ -0,0 +1,78 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM readahead
+
+#if !defined(_TRACE_READAHEAD_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_READAHEAD_H
+
+#include <linux/tracepoint.h>
+
+#define show_pattern_name(val)						   \
+	__print_symbolic(val,						   \
+			{ RA_PATTERN_INITIAL,		"initial"	}, \
+			{ RA_PATTERN_SUBSEQUENT,	"subsequent"	}, \
+			{ RA_PATTERN_CONTEXT,		"context"	}, \
+			{ RA_PATTERN_THRASH,		"thrash"	}, \
+			{ RA_PATTERN_MMAP_AROUND,	"around"	}, \
+			{ RA_PATTERN_FADVISE,		"fadvise"	}, \
+			{ RA_PATTERN_RANDOM,		"random"	}, \
+			{ RA_PATTERN_ALL,		"all"		})
+
+/*
+ * Tracepoint for guest mode entry.
+ */
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
+			show_pattern_name(__entry->pattern),
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
+#endif /* _TRACE_READAHEAD_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
--- linux.orig/mm/readahead.c	2010-02-24 10:44:45.000000000 +0800
+++ linux/mm/readahead.c	2010-02-24 10:44:46.000000000 +0800
@@ -19,6 +19,9 @@
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/readahead.h>
+
 #define MIN_READAHEAD_PAGES DIV_ROUND_UP(VM_MIN_READAHEAD*1024, PAGE_CACHE_SIZE)
 
 static int __initdata user_defined_readahead_size;
@@ -322,6 +325,11 @@ int force_page_cache_readahead(struct ad
 		offset += this_chunk;
 		nr_to_read -= this_chunk;
 	}
+
+	trace_readahead(mapping, offset, nr_to_read,
+			RA_PATTERN_FADVISE << READAHEAD_PATTERN_SHIFT,
+			offset, nr_to_read, 0, ret);
+
 	return ret;
 }
 
@@ -349,6 +357,9 @@ unsigned long ra_submit(struct file_ra_s
 	actual = __do_page_cache_readahead(mapping, filp,
 					ra->start, ra->size, ra->async_size);
 
+	trace_readahead(mapping, offset, req_size, ra->ra_flags,
+			ra->start, ra->size, ra->async_size, actual);
+
 	return actual;
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
