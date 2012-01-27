Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 0945E6B0099
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 22:40:42 -0500 (EST)
Message-Id: <20120127031327.020100004@intel.com>
Date: Fri, 27 Jan 2012 11:05:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 5/9] readahead: add vfs/readahead tracing event
References: <20120127030524.854259561@intel.com>
Content-Disposition: inline; filename=readahead-tracer.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

This is very useful for verifying whether the readahead algorithms are
working to the expectation.

Example output:

# echo 1 > /debug/tracing/events/vfs/readahead/enable
# cp test-file /dev/null
# cat /debug/tracing/trace  # trimmed output
pattern=initial bdi=0:16 ino=100177 req=0+2 ra=0+4-2 async=0 actual=4
pattern=subsequent bdi=0:16 ino=100177 req=2+2 ra=4+8-8 async=1 actual=8
pattern=subsequent bdi=0:16 ino=100177 req=4+2 ra=12+16-16 async=1 actual=16
pattern=subsequent bdi=0:16 ino=100177 req=12+2 ra=28+32-32 async=1 actual=32
pattern=subsequent bdi=0:16 ino=100177 req=28+2 ra=60+60-60 async=1 actual=24
pattern=subsequent bdi=0:16 ino=100177 req=60+2 ra=120+60-60 async=1 actual=0

CC: Ingo Molnar <mingo@elte.hu>
CC: Jens Axboe <axboe@kernel.dk>
CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
Acked-by: Jan Kara <jack@suse.cz>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/Makefile                |    1 
 fs/trace.c                 |    2 
 include/trace/events/vfs.h |   77 +++++++++++++++++++++++++++++++++++
 mm/readahead.c             |   24 ++++++++++
 4 files changed, 104 insertions(+)

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-next/include/trace/events/vfs.h	2012-01-25 15:57:52.000000000 +0800
@@ -0,0 +1,77 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM vfs
+
+#if !defined(_TRACE_VFS_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_VFS_H
+
+#include <linux/fs.h>
+#include <linux/blkdev.h>
+#include <linux/backing-dev.h>
+#include <linux/tracepoint.h>
+
+#define READAHEAD_PATTERNS						   \
+			{ RA_PATTERN_INITIAL,		"initial"	}, \
+			{ RA_PATTERN_SUBSEQUENT,	"subsequent"	}, \
+			{ RA_PATTERN_CONTEXT,		"context"	}, \
+			{ RA_PATTERN_MMAP_AROUND,	"around"	}, \
+			{ RA_PATTERN_FADVISE,		"fadvise"	}, \
+			{ RA_PATTERN_OVERSIZE,		"oversize"	}, \
+			{ RA_PATTERN_RANDOM,		"random"	}, \
+			{ RA_PATTERN_ALL,		"all"		}
+
+TRACE_EVENT(readahead,
+	TP_PROTO(struct address_space *mapping,
+		 pgoff_t offset,
+		 unsigned long req_size,
+		 enum readahead_pattern pattern,
+		 pgoff_t start,
+		 unsigned long size,
+		 unsigned long async_size,
+		 unsigned int actual),
+
+	TP_ARGS(mapping, offset, req_size, pattern, start, size, async_size,
+		actual),
+
+	TP_STRUCT__entry(
+		__array(char,		bdi, 32)
+		__field(ino_t,		ino)
+		__field(pgoff_t,	offset)
+		__field(unsigned long,	req_size)
+		__field(unsigned int,	pattern)
+		__field(pgoff_t,	start)
+		__field(unsigned int,	size)
+		__field(unsigned int,	async_size)
+		__field(unsigned int,	actual)
+	),
+
+	TP_fast_assign(
+		strncpy(__entry->bdi,
+			dev_name(mapping->backing_dev_info->dev), 32);
+		__entry->ino		= mapping->host->i_ino;
+		__entry->offset		= offset;
+		__entry->req_size	= req_size;
+		__entry->pattern	= pattern;
+		__entry->start		= start;
+		__entry->size		= size;
+		__entry->async_size	= async_size;
+		__entry->actual		= actual;
+	),
+
+	TP_printk("pattern=%s bdi=%s ino=%lu "
+		  "req=%lu+%lu ra=%lu+%d-%d async=%d actual=%d",
+			__print_symbolic(__entry->pattern, READAHEAD_PATTERNS),
+			__entry->bdi,
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
--- linux-next.orig/mm/readahead.c	2012-01-25 15:57:52.000000000 +0800
+++ linux-next/mm/readahead.c	2012-01-25 15:57:52.000000000 +0800
@@ -17,6 +17,7 @@
 #include <linux/task_io_accounting_ops.h>
 #include <linux/pagevec.h>
 #include <linux/pagemap.h>
+#include <trace/events/vfs.h>
 
 /*
  * Initialise a struct file's readahead state.  Assumes that the caller has
@@ -32,6 +33,21 @@ EXPORT_SYMBOL_GPL(file_ra_state_init);
 
 #define list_to_page(head) (list_entry((head)->prev, struct page, lru))
 
+static inline void readahead_event(struct address_space *mapping,
+				   pgoff_t offset,
+				   unsigned long req_size,
+				   bool for_mmap,
+				   bool for_metadata,
+				   enum readahead_pattern pattern,
+				   pgoff_t start,
+				   unsigned long size,
+				   unsigned long async_size,
+				   int actual)
+{
+	trace_readahead(mapping, offset, req_size,
+			pattern, start, size, async_size, actual);
+}
+
 /*
  * see if a page needs releasing upon read_cache_pages() failure
  * - the caller of read_cache_pages() may have set PG_private or PG_fscache
@@ -228,6 +244,9 @@ int force_page_cache_readahead(struct ad
 			ret = err;
 			break;
 		}
+		readahead_event(mapping, offset, nr_to_read, 0, 0,
+				RA_PATTERN_FADVISE, offset, this_chunk, 0,
+				err);
 		ret += err;
 		offset += this_chunk;
 		nr_to_read -= this_chunk;
@@ -259,6 +278,11 @@ unsigned long ra_submit(struct file_ra_s
 	actual = __do_page_cache_readahead(mapping, filp,
 					ra->start, ra->size, ra->async_size);
 
+	readahead_event(mapping, offset, req_size,
+			ra->for_mmap, ra->for_metadata,
+			ra->pattern, ra->start, ra->size, ra->async_size,
+			actual);
+
 	ra->for_mmap = 0;
 	ra->for_metadata = 0;
 	return actual;
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-next/fs/trace.c	2012-01-25 15:57:52.000000000 +0800
@@ -0,0 +1,2 @@
+#define CREATE_TRACE_POINTS
+#include <trace/events/vfs.h>
--- linux-next.orig/fs/Makefile	2012-01-25 15:57:46.000000000 +0800
+++ linux-next/fs/Makefile	2012-01-25 15:57:52.000000000 +0800
@@ -50,6 +50,7 @@ obj-$(CONFIG_NFS_COMMON)	+= nfs_common/
 obj-$(CONFIG_GENERIC_ACL)	+= generic_acl.o
 
 obj-$(CONFIG_FHANDLE)		+= fhandle.o
+obj-$(CONFIG_TRACEPOINTS)	+= trace.o
 
 obj-y				+= quota/
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
