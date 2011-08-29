Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 081D2900139
	for <linux-mm@kvack.org>; Sun, 28 Aug 2011 23:57:07 -0400 (EDT)
Message-Id: <20110829034932.000999180@intel.com>
Date: Mon, 29 Aug 2011 11:29:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 3/7] tracing/mm: create trace_objects.c
References: <20110829032951.677220552@intel.com>
Content-Disposition: inline; filename=trace-objects.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: Mel Gorman <mgorman@suse.de>, Steven Rostedt <srostedt@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Code refactor: create trace_objects.c and move relevant code from trace_mm.c

CC: Steven Rostedt <srostedt@redhat.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 kernel/trace/Makefile        |    1 +
 kernel/trace/trace.h         |    1 +
 kernel/trace/trace_mm.c      |   22 ----------------------
 kernel/trace/trace_objects.c |   26 ++++++++++++++++++++++++++
 4 files changed, 28 insertions(+), 22 deletions(-)

--- linux-mmotm.orig/kernel/trace/Makefile	2011-08-28 10:09:25.000000000 +0800
+++ linux-mmotm/kernel/trace/Makefile	2011-08-28 10:09:28.000000000 +0800
@@ -26,6 +26,7 @@ obj-$(CONFIG_RING_BUFFER) += ring_buffer
 obj-$(CONFIG_RING_BUFFER_BENCHMARK) += ring_buffer_benchmark.o
 
 obj-$(CONFIG_TRACING) += trace.o
+obj-$(CONFIG_TRACING) += trace_objects.o
 obj-$(CONFIG_TRACING) += trace_output.o
 obj-$(CONFIG_TRACING) += trace_stat.o
 obj-$(CONFIG_TRACING) += trace_printk.o
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
--- linux-mmotm.orig/kernel/trace/trace_mm.c	2011-08-28 10:09:27.000000000 +0800
+++ linux-mmotm/kernel/trace/trace_mm.c	2011-08-28 10:09:28.000000000 +0800
@@ -95,28 +95,6 @@ static const struct file_operations trac
 	.write		= trace_mm_pfn_range_write,
 };
 
-/* move this into trace_objects.c when that file is created */
-static struct dentry *trace_objects_dir(void)
-{
-	static struct dentry *d_objects;
-	struct dentry *d_tracer;
-
-	if (d_objects)
-		return d_objects;
-
-	d_tracer = tracing_init_dentry();
-	if (!d_tracer)
-		return NULL;
-
-	d_objects = debugfs_create_dir("objects", d_tracer);
-	if (!d_objects)
-		pr_warning("Could not create debugfs "
-			   "'objects' directory\n");
-
-	return d_objects;
-}
-
-
 static struct dentry *trace_objects_mm_dir(void)
 {
 	static struct dentry *d_mm;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
