From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 2/7] tracing/mm: rename trigger file to dump-pfn
Date: Mon, 29 Aug 2011 11:29:53 +0800
Message-ID: <20110829034931.869901369__17990.2705400766$1314590261$gmane$org@intel.com>
References: <20110829032951.677220552@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0003-tracing-mm-rename-trigger-file-to-dump_range.patch
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: Mel Gorman <mgorman@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

From: Ingo Molnar <mingo@elte.hu>

Wu Fengguang noted that /debug/tracing/objects/mm/pages/trigger was
not very intuitively named - rename it to 'dump-pfn', which covers
its functionality better.

[ Impact: rename /debug/tracing file ]

Reported-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/trace/events/mm.h |    4 ++--
 kernel/trace/trace_mm.c   |   26 +++++++++++++-------------
 2 files changed, 15 insertions(+), 15 deletions(-)

--- mmotm.orig/kernel/trace/trace_mm.c	2011-03-03 19:17:48.000000000 +0800
+++ mmotm/kernel/trace/trace_mm.c	2011-03-03 19:18:17.000000000 +0800
@@ -15,8 +15,8 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/mm.h>
 
-void trace_read_page_frames(unsigned long start, unsigned long end,
-			    void (*trace)(unsigned long pfn, struct page *page))
+void trace_mm_page_frames(unsigned long start, unsigned long end,
+			  void (*trace)(unsigned long pfn, struct page *page))
 {
 	unsigned long pfn = start;
 	struct page *page;
@@ -37,22 +37,22 @@ void trace_read_page_frames(unsigned lon
 	}
 }
 
-static void trace_do_dump_pages(unsigned long pfn, struct page *page)
+static void trace_mm_page_frame(unsigned long pfn, struct page *page)
 {
-	trace_dump_pages(pfn, page);
+	trace_dump_page_frame(pfn, page);
 }
 
 static ssize_t
-trace_mm_trigger_read(struct file *filp, char __user *ubuf, size_t cnt,
-		 loff_t *ppos)
+trace_mm_pfn_range_read(struct file *filp, char __user *ubuf, size_t cnt,
+			loff_t *ppos)
 {
 	return simple_read_from_buffer(ubuf, cnt, ppos, "0\n", 2);
 }
 
 
 static ssize_t
-trace_mm_trigger_write(struct file *filp, const char __user *ubuf, size_t cnt,
-		       loff_t *ppos)
+trace_mm_pfn_range_write(struct file *filp, const char __user *ubuf, size_t cnt,
+			 loff_t *ppos)
 {
 	unsigned long val, start, end;
 	char buf[64];
@@ -67,7 +67,7 @@ trace_mm_trigger_write(struct file *filp
 	if (tracing_update_buffers() < 0)
 		return -ENOMEM;
 
-	if (trace_set_clr_event("mm", "dump_pages", 1))
+	if (trace_set_clr_event("mm", "dump_page_frame", 1))
 		return -EINVAL;
 
 	buf[cnt] = 0;
@@ -82,7 +82,7 @@ trace_mm_trigger_write(struct file *filp
 	else
 		end = start + val;
 
-	trace_read_page_frames(start, end, trace_do_dump_pages);
+	trace_mm_page_frames(start, end, trace_mm_page_frame);
 
 	*ppos += cnt;
 
@@ -91,8 +91,8 @@ trace_mm_trigger_write(struct file *filp
 
 static const struct file_operations trace_mm_fops = {
 	.open		= tracing_open_generic,
-	.read		= trace_mm_trigger_read,
-	.write		= trace_mm_trigger_write,
+	.read		= trace_mm_pfn_range_read,
+	.write		= trace_mm_pfn_range_write,
 };
 
 /* move this into trace_objects.c when that file is created */
@@ -164,7 +164,7 @@ static __init int trace_objects_mm_init(
 	if (!d_pages)
 		return 0;
 
-	trace_create_file("trigger", 0600, d_pages, NULL,
+	trace_create_file("dump-pfn", 0600, d_pages, NULL,
 			  &trace_mm_fops);
 
 	return 0;
--- mmotm.orig/include/trace/events/mm.h	2011-03-03 19:18:02.000000000 +0800
+++ mmotm/include/trace/events/mm.h	2011-03-03 19:18:17.000000000 +0800
@@ -8,14 +8,14 @@
 #define TRACE_SYSTEM mm
 
 /**
- * dump_pages - called by the trace page dump trigger
+ * dump_page_frame - called by the trace page dump trigger
  * @pfn: page frame number
  * @page: pointer to the page frame
  *
  * This is a helper trace point into the dumping of the page frames.
  * It will record various infromation about a page frame.
  */
-TRACE_EVENT(dump_pages,
+TRACE_EVENT(dump_page_frame,
 
 	TP_PROTO(unsigned long pfn, struct page *page),
 
