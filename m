Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 23E7F6B006A
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 19:10:49 -0500 (EST)
Message-ID: <4B5A3DD5.3020904@bx.jp.nec.com>
Date: Fri, 22 Jan 2010 19:07:49 -0500
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: [RFC PATCH -tip 1/2 v2] add tracepoints for pagecache
References: <4B5A3D00.8080901@bx.jp.nec.com>
In-Reply-To: <4B5A3D00.8080901@bx.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: lwoodman@redhat.com, linux-mm@kvack.org, mingo@elte.hu, tzanussi@gmail.com, riel@redhat.com, rostedt@goodmis.org, akpm@linux-foundation.org, fweisbec@gmail.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

This patch adds several tracepoints to track pagecach behavior.
These trecepoints would help us monitor pagecache usage with high resolution.

Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Atsushi Tsuji <a-tsuji@bk.jp.nec.com> 
---
 include/trace/events/filemap.h |   83 +++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c                   |    5 ++
 mm/truncate.c                  |    2 
 mm/vmscan.c                    |    3 +
 4 files changed, 93 insertions(+)

Index: linux-2.6-tip/include/trace/events/filemap.h
===================================================================
--- /dev/null
+++ linux-2.6-tip/include/trace/events/filemap.h
@@ -0,0 +1,83 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM filemap
+
+#if !defined(_TRACE_FILEMAP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_FILEMAP_H
+
+#include <linux/fs.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(find_get_page,
+
+	TP_PROTO(struct address_space *mapping, pgoff_t offset,
+		struct page *page),
+
+	TP_ARGS(mapping, offset, page),
+
+	TP_STRUCT__entry(
+		__field(dev_t, s_dev)
+		__field(ino_t, i_ino)
+		__field(pgoff_t, offset)
+		__field(struct page *, page)
+		),
+
+	TP_fast_assign(
+		__entry->s_dev = mapping->host ? mapping->host->i_sb->s_dev : 0;
+		__entry->i_ino = mapping->host ? mapping->host->i_ino : 0;
+		__entry->offset = offset;
+		__entry->page = page;
+		),
+
+	TP_printk("s_dev=%u:%u i_ino=%lu offset=%lu %s", MAJOR(__entry->s_dev),
+		MINOR(__entry->s_dev), __entry->i_ino, __entry->offset,
+		__entry->page == NULL ? "page_not_found" : "page_found")
+);
+
+TRACE_EVENT(add_to_page_cache,
+
+	TP_PROTO(struct address_space *mapping, pgoff_t offset),
+
+	TP_ARGS(mapping, offset),
+
+	TP_STRUCT__entry(
+		__field(dev_t, s_dev)
+		__field(ino_t, i_ino)
+		__field(pgoff_t, offset)
+		),
+
+	TP_fast_assign(
+		__entry->s_dev = mapping->host->i_sb->s_dev;
+		__entry->i_ino = mapping->host->i_ino;
+		__entry->offset = offset;
+		),
+
+	TP_printk("s_dev=%u:%u i_ino=%lu offset=%lu", MAJOR(__entry->s_dev),
+		MINOR(__entry->s_dev), __entry->i_ino, __entry->offset)
+);
+
+TRACE_EVENT(remove_from_page_cache,
+
+	TP_PROTO(struct address_space *mapping, pgoff_t offset),
+
+	TP_ARGS(mapping, offset),
+
+	TP_STRUCT__entry(
+		__field(dev_t, s_dev)
+		__field(ino_t, i_ino)
+		__field(pgoff_t, offset)
+		),
+
+	TP_fast_assign(
+		__entry->s_dev = mapping->host->i_sb->s_dev;
+		__entry->i_ino = mapping->host->i_ino;
+		__entry->offset = offset;
+		),
+
+	TP_printk("s_dev=%u:%u i_ino=%lu offset=%lu", MAJOR(__entry->s_dev),
+		MINOR(__entry->s_dev), __entry->i_ino, __entry->offset)
+);
+
+#endif /* _TRACE_FILEMAP_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
Index: linux-2.6-tip/mm/filemap.c
===================================================================
--- linux-2.6-tip.orig/mm/filemap.c
+++ linux-2.6-tip/mm/filemap.c
@@ -34,6 +34,8 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
+#define CREATE_TRACE_POINTS
+#include <trace/events/filemap.h>
 #include "internal.h"
 
 /*
@@ -149,6 +151,7 @@ void remove_from_page_cache(struct page 
 	spin_lock_irq(&mapping->tree_lock);
 	__remove_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);
+	trace_remove_from_page_cache(mapping, page->index);
 	mem_cgroup_uncharge_cache_page(page);
 }
 
@@ -419,6 +422,7 @@ int add_to_page_cache_locked(struct page
 			if (PageSwapBacked(page))
 				__inc_zone_page_state(page, NR_SHMEM);
 			spin_unlock_irq(&mapping->tree_lock);
+			trace_add_to_page_cache(mapping, offset);
 		} else {
 			page->mapping = NULL;
 			spin_unlock_irq(&mapping->tree_lock);
@@ -642,6 +646,7 @@ repeat:
 	}
 	rcu_read_unlock();
 
+	trace_find_get_page(mapping, offset, page);
 	return page;
 }
 EXPORT_SYMBOL(find_get_page);
Index: linux-2.6-tip/mm/truncate.c
===================================================================
--- linux-2.6-tip.orig/mm/truncate.c
+++ linux-2.6-tip/mm/truncate.c
@@ -20,6 +20,7 @@
 				   do_invalidatepage */
 #include "internal.h"
 
+#include <trace/events/filemap.h>
 
 /**
  * do_invalidatepage - invalidate part or all of a page
@@ -388,6 +389,7 @@ invalidate_complete_page2(struct address
 	BUG_ON(page_has_private(page));
 	__remove_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);
+	trace_remove_from_page_cache(mapping, page->index);
 	mem_cgroup_uncharge_cache_page(page);
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
Index: linux-2.6-tip/mm/vmscan.c
===================================================================
--- linux-2.6-tip.orig/mm/vmscan.c
+++ linux-2.6-tip/mm/vmscan.c
@@ -48,6 +48,8 @@
 
 #include "internal.h"
 
+#include <trace/events/filemap.h>
+
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
@@ -477,6 +479,7 @@ static int __remove_mapping(struct addre
 	} else {
 		__remove_from_page_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
+		trace_remove_from_page_cache(mapping, page->index);
 		mem_cgroup_uncharge_cache_page(page);
 	}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
