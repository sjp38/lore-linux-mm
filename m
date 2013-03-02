Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 90ED86B0005
	for <linux-mm@kvack.org>; Sat,  2 Mar 2013 07:05:36 -0500 (EST)
From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH RESEND v2] mm: trace filemap add and del
Date: Sat,  2 Mar 2013 13:04:55 +0100
Message-Id: <1362225895-30790-1-git-send-email-robert.jarzmik@free.fr>
In-Reply-To: <1362084420-3840-1-git-send-email-robert.jarzmik@free.fr>
References: <1362084420-3840-1-git-send-email-robert.jarzmik@free.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Robert Jarzmik <robert.jarzmik@free.fr>, Dave Chinner <david@fromorbit.com>, Hugh Dickins <hughd@google.com>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Use the events API to trace filemap loading and unloading of file pieces
into the page cache.

This patch aims at tracing the eviction reload cycle of executable and
shared libraries pages in a memory constrained environment.

The typical usage is to spot a specific device and inode (for example
/lib/libc.so) to see the eviction cycles, and find out if frequently used
code is rather spread across many pages (bad) or coallesced (good).

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

---
Since RESEND v1:
 - took Stephen's comment into account (use FTrace templates)
 - took Andrew's comment into account (trace out of lock)
---
 include/trace/events/filemap.h |   58 ++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c                   |    5 ++++
 2 files changed, 63 insertions(+)
 create mode 100644 include/trace/events/filemap.h

diff --git a/include/trace/events/filemap.h b/include/trace/events/filemap.h
new file mode 100644
index 0000000..0421f49
--- /dev/null
+++ b/include/trace/events/filemap.h
@@ -0,0 +1,58 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM filemap
+
+#if !defined(_TRACE_FILEMAP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_FILEMAP_H
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
+#include <linux/mm.h>
+#include <linux/memcontrol.h>
+#include <linux/device.h>
+#include <linux/kdev_t.h>
+
+DECLARE_EVENT_CLASS(mm_filemap_op_page_cache,
+
+	TP_PROTO(struct page *page),
+
+	TP_ARGS(page),
+
+	TP_STRUCT__entry(
+		__field(struct page *, page)
+		__field(unsigned long, i_ino)
+		__field(unsigned long, index)
+		__field(dev_t, s_dev)
+	),
+
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->i_ino = page->mapping->host->i_ino;
+		__entry->index = page->index;
+		if (page->mapping->host->i_sb)
+			__entry->s_dev = page->mapping->host->i_sb->s_dev;
+		else
+			__entry->s_dev = page->mapping->host->i_rdev;
+	),
+
+	TP_printk("dev %d:%d ino %lx page=%p pfn=%lu ofs=%lu",
+		MAJOR(__entry->s_dev), MINOR(__entry->s_dev),
+		__entry->i_ino,
+		__entry->page,
+		page_to_pfn(__entry->page),
+		__entry->index << PAGE_SHIFT)
+);
+
+DEFINE_EVENT(mm_filemap_op_page_cache, mm_filemap_delete_from_page_cache,
+	TP_PROTO(struct page *page),
+	TP_ARGS(page)
+	);
+
+DEFINE_EVENT(mm_filemap_op_page_cache, mm_filemap_add_to_page_cache,
+	TP_PROTO(struct page *page),
+	TP_ARGS(page)
+	);
+
+#endif /* _TRACE_FILEMAP_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/filemap.c b/mm/filemap.c
index e1979fd..2581826 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -35,6 +35,9 @@
 #include <linux/cleancache.h>
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/filemap.h>
+
 /*
  * FIXME: remove all knowledge of the buffer layer from the core VM
  */
@@ -113,6 +116,7 @@ void __delete_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
 
+	trace_mm_filemap_delete_from_page_cache(page);
 	/*
 	 * if we're uptodate, flush out into the cleancache, otherwise
 	 * invalidate any existing cleancache entries.  We can't leave
@@ -464,6 +468,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
 			spin_unlock_irq(&mapping->tree_lock);
+			trace_mm_filemap_add_to_page_cache(page);
 		} else {
 			page->mapping = NULL;
 			/* Leave page->index set: truncation relies upon it */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
