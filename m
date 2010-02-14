Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 27B656B007B
	for <linux-mm@kvack.org>; Sat, 13 Feb 2010 22:57:13 -0500 (EST)
Date: Sun, 14 Feb 2010 11:56:07 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 08/11] readahead: add tracing event
Message-ID: <20100214035607.GB6423@localhost>
References: <20100202152835.683907822@intel.com> <20100202153317.365099890@intel.com> <1265991545.24271.36.camel@gandalf.stny.rr.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1265991545.24271.36.camel@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Feb 13, 2010 at 12:19:05AM +0800, Steven Rostedt wrote:
> On Tue, 2010-02-02 at 23:28 +0800, Wu Fengguang wrote:
> > plain text document attachment (readahead-tracer.patch)
> > Example output:
> 
> > +	TP_printk("readahead-%s(dev=%d:%d, ino=%lu, "
> > +		  "req=%lu+%lu, ra=%lu+%d-%d, async=%d) = %d",
> > +			ra_pattern_names[__entry->pattern],
> 
> The above totally breaks any parsing by tools. We have already have a
> way to map values to strings with __print_symbolic():
> 
> 		__print_symbolic(__entry->pattern,
> 			{ RA_PATTERN_INITIAL, "initial" },
> 			{ RA_PATTERN_SUBSEQUENT, "subsequent"},
> 			{ RA_PATTERN_CONTEXT, "context"},
> 			{ RA_PATTERN_THRASH, "thrash"},
> 			{ RA_PATTERN_MMAP_AROUND, "around"},
> 			{ RA_PATTERN_FADVISE, "fadvise" },
> 			{ RA_PATTERN_RANDOM, "random"},
> 			{ RA_PATTERN_ALL, "all" }),
> 
> see include/trace/irq.h for another example.

Thank you! Updated patch as follows.

To avoid unnecessary dependency, EXTRACT_TRACE_SYMBOL() calls are
leaved out for now.

Thanks,
Fengguang
---
readahead: add tracing event

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
CC: Peter Zijlstra <a.p.zijlstra@chello.nl> 
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/readahead.h |   78 +++++++++++++++++++++++++++++
 mm/readahead.c                   |   11 ++++
 2 files changed, 89 insertions(+)

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/include/trace/events/readahead.h	2010-02-14 11:49:17.000000000 +0800
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
--- linux.orig/mm/readahead.c	2010-02-14 11:19:25.000000000 +0800
+++ linux/mm/readahead.c	2010-02-14 11:24:13.000000000 +0800
@@ -19,6 +19,9 @@
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/readahead.h>
+
 /*
  * Set async size to 1/# of the thrashing threshold.
  */
@@ -274,6 +277,11 @@ int force_page_cache_readahead(struct ad
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
 
@@ -301,6 +309,9 @@ unsigned long ra_submit(struct file_ra_s
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
