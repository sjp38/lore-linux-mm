Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CF1A3900139
	for <linux-mm@kvack.org>; Sun, 28 Aug 2011 23:57:07 -0400 (EDT)
Message-Id: <20110829034931.736694692@intel.com>
Date: Mon, 29 Aug 2011 11:29:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 1/7] tracing/mm: add page frame snapshot trace
References: <20110829032951.677220552@intel.com>
Content-Disposition: inline; filename=0001-tracing-mm-add-page-frame-snapshot-trace.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: Mel Gorman <mgorman@suse.de>, Steven Rostedt <rostedt@goodmis.org>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

From: Steven Rostedt <srostedt@redhat.com>

This is a prototype to dump out a snapshot of the page tables to the
tracing buffer. Currently it is very primitive, and just writes out
the events. There is no synchronization to not loose the events,
so /debug/tracing/buffer_size_kb has to be large enough for all
events to fit.

We will do something about synchronization later. That is, have a way
to read the buffer through the tracing/object/mm/page/X file and have
the two in sync.

But this is just a prototype to get the ball rolling.

Signed-off-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/mm.h |   48 ++++++++++
 kernel/trace/Makefile     |    1 
 kernel/trace/trace_mm.c   |  172 ++++++++++++++++++++++++++++++++++++
 3 files changed, 221 insertions(+)
 create mode 100644 include/trace/events/mm.h
 create mode 100644 kernel/trace/trace_mm.c

--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ mmotm/include/trace/events/mm.h	2011-03-03 19:18:02.000000000 +0800
@@ -0,0 +1,48 @@
+#if !defined(_TRACE_MM_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MM_H
+
+#include <linux/tracepoint.h>
+#include <linux/mm.h>
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM mm
+
+/**
+ * dump_pages - called by the trace page dump trigger
+ * @pfn: page frame number
+ * @page: pointer to the page frame
+ *
+ * This is a helper trace point into the dumping of the page frames.
+ * It will record various infromation about a page frame.
+ */
+TRACE_EVENT(dump_pages,
+
+	TP_PROTO(unsigned long pfn, struct page *page),
+
+	TP_ARGS(pfn, page),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	pfn		)
+		__field(	unsigned long,	flags		)
+		__field(	unsigned long,	index		)
+		__field(	unsigned int,	count		)
+		__field(	unsigned int,	mapcount	)
+	),
+
+	TP_fast_assign(
+		__entry->pfn		= pfn;
+		__entry->flags		= page->flags;
+		__entry->count		= atomic_read(&page->_count);
+		__entry->mapcount	= page_mapcount(page);
+		__entry->index		= page->index;
+	),
+
+	TP_printk("pfn=%lu flags=%lx count=%u mapcount=%u index=%lu",
+		  __entry->pfn, __entry->flags, __entry->count,
+		  __entry->mapcount, __entry->index)
+);
+
+#endif /*  _TRACE_MM_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
--- mmotm.orig/kernel/trace/Makefile	2011-03-03 19:12:42.000000000 +0800
+++ mmotm/kernel/trace/Makefile	2011-03-03 19:17:47.000000000 +0800
@@ -53,6 +53,7 @@ endif
 obj-$(CONFIG_EVENT_TRACING) += trace_events_filter.o
 obj-$(CONFIG_KPROBE_EVENT) += trace_kprobe.o
 obj-$(CONFIG_TRACEPOINTS) += power-traces.o
+obj-$(CONFIG_EVENT_TRACING) += trace_mm.o
 ifeq ($(CONFIG_TRACING),y)
 obj-$(CONFIG_KGDB_KDB) += trace_kdb.o
 endif
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ mmotm/kernel/trace/trace_mm.c	2011-03-03 19:17:48.000000000 +0800
@@ -0,0 +1,172 @@
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
+void trace_read_page_frames(unsigned long start, unsigned long end,
+			    void (*trace)(unsigned long pfn, struct page *page))
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
+static void trace_do_dump_pages(unsigned long pfn, struct page *page)
+{
+	trace_dump_pages(pfn, page);
+}
+
+static ssize_t
+trace_mm_trigger_read(struct file *filp, char __user *ubuf, size_t cnt,
+		 loff_t *ppos)
+{
+	return simple_read_from_buffer(ubuf, cnt, ppos, "0\n", 2);
+}
+
+
+static ssize_t
+trace_mm_trigger_write(struct file *filp, const char __user *ubuf, size_t cnt,
+		       loff_t *ppos)
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
+	if (trace_set_clr_event("mm", "dump_pages", 1))
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
+	trace_read_page_frames(start, end, trace_do_dump_pages);
+
+	*ppos += cnt;
+
+	return cnt;
+}
+
+static const struct file_operations trace_mm_fops = {
+	.open		= tracing_open_generic,
+	.read		= trace_mm_trigger_read,
+	.write		= trace_mm_trigger_write,
+};
+
+/* move this into trace_objects.c when that file is created */
+static struct dentry *trace_objects_dir(void)
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
+	trace_create_file("trigger", 0600, d_pages, NULL,
+			  &trace_mm_fops);
+
+	return 0;
+}
+fs_initcall(trace_objects_mm_init);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
