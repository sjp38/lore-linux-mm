Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 55FF290013B
	for <linux-mm@kvack.org>; Sun, 28 Aug 2011 23:59:41 -0400 (EDT)
Date: Mon, 29 Aug 2011 11:59:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC][PATCH 0/7] trace memory objects
Message-ID: <20110829035937.GA21495@localhost>
References: <20110829032951.677220552@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110829032951.677220552@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: Mel Gorman <mgorman@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

> dump-pfn interface
> (it looks more clean and easier for review to fold patches 1-5 into one, but
> let's keep the changelog for the initial post)
> 
> 	[RFC][PATCH 1/7] tracing/mm: add page frame snapshot trace
> 	[RFC][PATCH 2/7] tracing/mm: rename trigger file to dump-pfn
> 	[RFC][PATCH 3/7] tracing/mm: create trace_objects.c
> 	[RFC][PATCH 4/7] tracing/mm: dump more page frame information
> 	[RFC][PATCH 5/7] tracing/mm: accept echo-able input format for pfn range

For your convenience, here is the combined diff for the above 5 incremental ones.

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-mmotm/include/trace/events/mm.h	2011-08-29 11:57:16.000000000 +0800
@@ -0,0 +1,69 @@
+#if !defined(_TRACE_MM_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MM_H
+
+#include <linux/tracepoint.h>
+#include <linux/page-flags.h>
+#include <linux/mm.h>
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM mm
+
+extern struct trace_print_flags pageflag_names[];
+
+/**
+ * dump_page_frame - called by the trace page dump trigger
+ * @pfn: page frame number
+ * @page: pointer to the page frame
+ *
+ * This is a helper trace point into the dumping of the page frames.
+ * It will record various infromation about a page frame.
+ */
+TRACE_EVENT(dump_page_frame,
+
+	TP_PROTO(unsigned long pfn, struct page *page),
+
+	TP_ARGS(pfn, page),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	pfn		)
+		__field(	struct page *,	page		)
+		__field(	u64,		stable_flags	)
+		__field(	unsigned long,	flags		)
+		__field(	unsigned int,	count		)
+		__field(	unsigned int,	mapcount	)
+		__field(	unsigned long,	private		)
+		__field(	unsigned long,	mapping		)
+		__field(	unsigned long,	index		)
+	),
+
+	TP_fast_assign(
+		__entry->pfn		= pfn;
+		__entry->page		= page;
+		__entry->stable_flags	= stable_page_flags(page);
+		__entry->flags		= page->flags;
+		__entry->count		= atomic_read(&page->_count);
+		__entry->mapcount	= page_mapcount(page);
+		__entry->private	= page->private;
+		__entry->mapping	= (unsigned long)page->mapping;
+		__entry->index		= page->index;
+	),
+
+	TP_printk("pfn=%lu page=%p count=%u mapcount=%u "
+		  "private=%lx mapping=%lx index=%lx flags=%s",
+		  __entry->pfn,
+		  __entry->page,
+		  __entry->count,
+		  __entry->mapcount,
+		  __entry->private,
+		  __entry->mapping,
+		  __entry->index,
+		  ftrace_print_flags_seq(p, "|",
+					 __entry->flags & PAGE_FLAGS_MASK,
+					 pageflag_names)
+	)
+);
+
+#endif /*  _TRACE_MM_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
--- linux-mmotm.orig/kernel/trace/Makefile	2011-08-28 10:09:25.000000000 +0800
+++ linux-mmotm/kernel/trace/Makefile	2011-08-28 10:09:28.000000000 +0800
@@ -26,6 +26,7 @@ obj-$(CONFIG_RING_BUFFER) += ring_buffer
 obj-$(CONFIG_RING_BUFFER_BENCHMARK) += ring_buffer_benchmark.o
 
 obj-$(CONFIG_TRACING) += trace.o
+obj-$(CONFIG_TRACING) += trace_objects.o
 obj-$(CONFIG_TRACING) += trace_output.o
 obj-$(CONFIG_TRACING) += trace_stat.o
 obj-$(CONFIG_TRACING) += trace_printk.o
@@ -53,6 +54,7 @@ endif
 obj-$(CONFIG_EVENT_TRACING) += trace_events_filter.o
 obj-$(CONFIG_KPROBE_EVENT) += trace_kprobe.o
 obj-$(CONFIG_TRACEPOINTS) += power-traces.o
+obj-$(CONFIG_EVENT_TRACING) += trace_mm.o
 ifeq ($(CONFIG_TRACING),y)
 obj-$(CONFIG_KGDB_KDB) += trace_kdb.o
 endif
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-mmotm/kernel/trace/trace_mm.c	2011-08-29 11:57:16.000000000 +0800
@@ -0,0 +1,150 @@
+/*
+ * Trace mm pages
+ *
+ * Copyright (C) 2009 Red Hat Inc, Steven Rostedt <srostedt@redhat.com>
+ *
+ * Code based on Matt Mackall's /proc/[kpagecount|kpageflags] code.
+ */
+#include <linux/module.h>
+#include <linux/bootmem.h>
+#include <linux/debugfs.h>
+#include <linux/uaccess.h>
+
+#include "trace_output.h"
+
+#define CREATE_TRACE_POINTS
+#include <trace/events/mm.h>
+
+void trace_mm_page_frames(unsigned long start, unsigned long end,
+			  void (*trace)(unsigned long pfn, struct page *page))
+{
+	unsigned long pfn = start;
+	struct page *page;
+
+	if (start > max_pfn - 1)
+		return;
+
+	if (end > max_pfn - 1)
+		end = max_pfn - 1;
+
+	while (pfn < end) {
+		page = NULL;
+		if (pfn_valid(pfn))
+			page = pfn_to_page(pfn);
+		pfn++;
+		if (page)
+			trace(pfn, page);
+	}
+}
+
+static void trace_mm_page_frame(unsigned long pfn, struct page *page)
+{
+	trace_dump_page_frame(pfn, page);
+}
+
+static ssize_t
+trace_mm_pfn_range_read(struct file *filp, char __user *ubuf, size_t cnt,
+			loff_t *ppos)
+{
+	return simple_read_from_buffer(ubuf, cnt, ppos, "0\n", 2);
+}
+
+
+static ssize_t
+trace_mm_pfn_range_write(struct file *filp, const char __user *ubuf, size_t cnt,
+			 loff_t *ppos)
+{
+	unsigned long val, start, end;
+	char buf[64];
+	int ret;
+
+	if (cnt >= sizeof(buf))
+		return -EINVAL;
+
+	if (copy_from_user(&buf, ubuf, cnt))
+		return -EFAULT;
+
+	if (tracing_update_buffers() < 0)
+		return -ENOMEM;
+
+	if (trace_set_clr_event("mm", "dump_page_frame", 1))
+		return -EINVAL;
+
+	buf[cnt] = 0;
+
+	ret = strict_strtol(buf, 10, &val);
+	if (ret < 0)
+		return ret;
+
+	start = *ppos;
+	if (val < 0)
+		end = max_pfn - 1;
+	else
+		end = start + val;
+
+	trace_mm_page_frames(start, end, trace_mm_page_frame);
+
+	*ppos += cnt;
+
+	return cnt;
+}
+
+static const struct file_operations trace_mm_fops = {
+	.open		= tracing_open_generic,
+	.read		= trace_mm_pfn_range_read,
+	.write		= trace_mm_pfn_range_write,
+};
+
+static struct dentry *trace_objects_mm_dir(void)
+{
+	static struct dentry *d_mm;
+	struct dentry *d_objects;
+
+	if (d_mm)
+		return d_mm;
+
+	d_objects = trace_objects_dir();
+	if (!d_objects)
+		return NULL;
+
+	d_mm = debugfs_create_dir("mm", d_objects);
+	if (!d_mm)
+		pr_warning("Could not create 'objects/mm' directory\n");
+
+	return d_mm;
+}
+
+static struct dentry *trace_objects_mm_pages_dir(void)
+{
+	static struct dentry *d_pages;
+	struct dentry *d_mm;
+
+	if (d_pages)
+		return d_pages;
+
+	d_mm = trace_objects_mm_dir();
+	if (!d_mm)
+		return NULL;
+
+	d_pages = debugfs_create_dir("pages", d_mm);
+	if (!d_pages)
+		pr_warning("Could not create debugfs "
+			   "'objects/mm/pages' directory\n");
+
+	return d_pages;
+}
+
+static __init int trace_objects_mm_init(void)
+{
+	struct dentry *d_pages;
+
+	d_pages = trace_objects_mm_pages_dir();
+	if (!d_pages)
+		return 0;
+
+	trace_create_file("dump-pfn", 0600, d_pages, NULL,
+			  &trace_mm_fops);
+
+	return 0;
+}
+fs_initcall(trace_objects_mm_init);
--- linux-mmotm.orig/kernel/trace/trace.h	2011-08-28 10:09:25.000000000 +0800
+++ linux-mmotm/kernel/trace/trace.h	2011-08-28 10:09:28.000000000 +0800
@@ -318,6 +318,7 @@ struct dentry *trace_create_file(const c
 				 const struct file_operations *fops);
 
 struct dentry *tracing_init_dentry(void);
+struct dentry *trace_objects_dir(void);
 
 struct ring_buffer_event;
 
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-mmotm/kernel/trace/trace_objects.c	2011-08-28 10:09:28.000000000 +0800
@@ -0,0 +1,26 @@
+#include <linux/debugfs.h>
+
+#include "trace.h"
+#include "trace_output.h"
+
+struct dentry *trace_objects_dir(void)
+{
+	static struct dentry *d_objects;
+	struct dentry *d_tracer;
+
+	if (d_objects)
+		return d_objects;
+
+	d_tracer = tracing_init_dentry();
+	if (!d_tracer)
+		return NULL;
+
+	d_objects = debugfs_create_dir("objects", d_tracer);
+	if (!d_objects)
+		pr_warning("Could not create debugfs "
+			   "'objects' directory\n");
+
+	return d_objects;
+}
+
+
--- linux-mmotm.orig/mm/page_alloc.c	2011-08-29 10:43:01.000000000 +0800
+++ linux-mmotm/mm/page_alloc.c	2011-08-29 10:43:03.000000000 +0800
@@ -5743,7 +5743,7 @@ bool is_free_buddy_page(struct page *pag
 }
 #endif
 
-static struct trace_print_flags pageflag_names[] = {
+struct trace_print_flags pageflag_names[] = {
 	{1UL << PG_locked,		"locked"	},
 	{1UL << PG_error,		"error"		},
 	{1UL << PG_referenced,		"referenced"	},
@@ -5790,7 +5790,7 @@ static void dump_page_flags(unsigned lon
 	printk(KERN_ALERT "page flags: %#lx(", flags);
 
 	/* remove zone id */
-	flags &= (1UL << NR_PAGEFLAGS) - 1;
+	flags &= PAGE_FLAGS_MASK;
 
 	for (i = 0; pageflag_names[i].name && flags; i++) {
 
--- linux-mmotm.orig/include/linux/page-flags.h	2011-08-29 10:43:01.000000000 +0800
+++ linux-mmotm/include/linux/page-flags.h	2011-08-29 10:43:03.000000000 +0800
@@ -462,6 +462,7 @@ static inline int PageTransCompound(stru
  * there has been a kernel bug or struct page corruption.
  */
 #define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
+#define PAGE_FLAGS_MASK			((1 << NR_PAGEFLAGS) - 1)
 
 #define PAGE_FLAGS_PRIVATE				\
 	(1 << PG_private | 1 << PG_private_2)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
