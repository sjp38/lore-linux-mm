Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 177D66B005D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:50:46 -0500 (EST)
From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH] mm: trace filemap add and del
Date: Tue, 20 Nov 2012 19:50:31 +0100
Message-Id: <1353437431-25134-1-git-send-email-robert.jarzmik@free.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Robert Jarzmik <robert.jarzmik@free.fr>

Use the events API to trace filemap loading and
unloading of file pieces into the page cache.

This patch aims at tracing the eviction reload
cycle of executable and shared libraries pages in
a memory constrained environment.

The typical usage is to spot a specific device and
inode (for example /lib/libc.so) to see the eviction
cycles, and find out if frequently used code is
rather spread across many pages (bad) or coallesced
(good).

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
 include/trace/events/filemap.h |   79 ++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c                   |    5 +++
 2 files changed, 84 insertions(+)
 create mode 100644 include/trace/events/filemap.h

diff --git a/include/trace/events/filemap.h b/include/trace/events/filemap.h
new file mode 100644
index 0000000..a8319e2
--- /dev/null
+++ b/include/trace/events/filemap.h
@@ -0,0 +1,79 @@
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
+TRACE_EVENT(mm_filemap_delete_from_page_cache,
+
+	TP_PROTO(struct page *page),
+
+	TP_ARGS(page),
+
+	TP_STRUCT__entry(
+		__field(struct page *, page)
+		__field(unsigned long, i_no)
+		__field(unsigned long, pageofs)
+		__field(dev_t, s_dev)
+	),
+
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->i_no = page->mapping->host->i_ino;
+		__entry->pageofs = page->index;
+		if (page->mapping->host->i_sb)
+			__entry->s_dev = page->mapping->host->i_sb->s_dev;
+		else
+			__entry->s_dev = page->mapping->host->i_rdev;
+	),
+
+	TP_printk("page=%p pfn=%lu blk=%d:%d inode+ofs=%lu+%lu",
+		__entry->page,
+		page_to_pfn(__entry->page),
+		MAJOR(__entry->s_dev), MINOR(__entry->s_dev),
+		__entry->i_no,
+		__entry->pageofs << PAGE_SHIFT)
+);
+
+TRACE_EVENT(mm_filemap_add_to_page_cache,
+
+	TP_PROTO(struct page *page),
+
+	TP_ARGS(page),
+
+	TP_STRUCT__entry(
+		__field(struct page *, page)
+		__field(unsigned long, i_no)
+		__field(unsigned long, pageofs)
+		__field(dev_t, s_dev)
+	),
+
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->i_no = page->mapping->host->i_ino;
+		__entry->pageofs = page->index;
+		if (page->mapping->host->i_sb)
+			__entry->s_dev = page->mapping->host->i_sb->s_dev;
+		else
+			__entry->s_dev = page->mapping->host->i_rdev;
+	),
+
+	TP_printk("page=%p pfn=%lu blk=%d:%d inode+ofs=%lu+%lu",
+		__entry->page,
+		page_to_pfn(__entry->page),
+		MAJOR(__entry->s_dev), MINOR(__entry->s_dev),
+		__entry->i_no,
+		__entry->pageofs)
+);
+
+#endif /* _TRACE_FILEMAP_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/filemap.c b/mm/filemap.c
index 3843445..9753b7c 100644
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
@@ -467,6 +471,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		} else {
 			page->mapping = NULL;
 			/* Leave page->index set: truncation relies upon it */
+			trace_mm_filemap_add_to_page_cache(page);
 			spin_unlock_irq(&mapping->tree_lock);
 			mem_cgroup_uncharge_cache_page(page);
 			page_cache_release(page);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
