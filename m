Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5A70C90013D
	for <linux-mm@kvack.org>; Sun, 28 Aug 2011 23:57:07 -0400 (EDT)
Message-Id: <20110829034932.135446238@intel.com>
Date: Mon, 29 Aug 2011 11:29:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [RFC][PATCH 4/7] tracing/mm: dump more page frame information
References: <20110829032951.677220552@intel.com>
Content-Disposition: inline; filename=mm-export-pageflag_names.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>
Cc: Mel Gorman <mgorman@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Add 4 more fields to dump_page_frame trace event.

1) stable page flags in addition to the raw page flags

User space should only make use the stable page flags.  The raw page
flags is stored mainly to take advantage of ftrace_print_flags_seq()
for showing symbolic flag names.

2) struct page address
3) page->private
4) page->mapping

The above 3 fields are mainly targeted for VM debug aids.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/page-flags.h |    1 +
 include/trace/events/mm.h  |   29 +++++++++++++++++++++++++----
 mm/page_alloc.c            |    4 ++--
 3 files changed, 28 insertions(+), 6 deletions(-)

--- linux-mmotm.orig/mm/page_alloc.c	2011-08-28 10:09:24.000000000 +0800
+++ linux-mmotm/mm/page_alloc.c	2011-08-28 10:09:31.000000000 +0800
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
 
--- linux-mmotm.orig/include/linux/page-flags.h	2011-08-28 10:09:24.000000000 +0800
+++ linux-mmotm/include/linux/page-flags.h	2011-08-28 10:09:31.000000000 +0800
@@ -462,6 +462,7 @@ static inline int PageTransCompound(stru
  * there has been a kernel bug or struct page corruption.
  */
 #define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)
+#define PAGE_FLAGS_MASK			((1 << NR_PAGEFLAGS) - 1)
 
 #define PAGE_FLAGS_PRIVATE				\
 	(1 << PG_private | 1 << PG_private_2)
--- linux-mmotm.orig/include/trace/events/mm.h	2011-08-28 10:09:27.000000000 +0800
+++ linux-mmotm/include/trace/events/mm.h	2011-08-28 10:43:38.000000000 +0800
@@ -2,11 +2,14 @@
 #define _TRACE_MM_H
 
 #include <linux/tracepoint.h>
+#include <linux/page-flags.h>
 #include <linux/mm.h>
 
 #undef TRACE_SYSTEM
 #define TRACE_SYSTEM mm
 
+extern struct trace_print_flags pageflag_names[];
+
 /**
  * dump_page_frame - called by the trace page dump trigger
  * @pfn: page frame number
@@ -23,23 +26,41 @@ TRACE_EVENT(dump_page_frame,
 
 	TP_STRUCT__entry(
 		__field(	unsigned long,	pfn		)
+		__field(	struct page *,	page		)
+		__field(	u64,		stable_flags	)
 		__field(	unsigned long,	flags		)
-		__field(	unsigned long,	index		)
 		__field(	unsigned int,	count		)
 		__field(	unsigned int,	mapcount	)
+		__field(	unsigned long,	private		)
+		__field(	unsigned long,	mapping		)
+		__field(	unsigned long,	index		)
 	),
 
 	TP_fast_assign(
 		__entry->pfn		= pfn;
+		__entry->page		= page;
+		__entry->stable_flags	= stable_page_flags(page);
 		__entry->flags		= page->flags;
 		__entry->count		= atomic_read(&page->_count);
 		__entry->mapcount	= page_mapcount(page);
+		__entry->private	= page->private;
+		__entry->mapping	= (unsigned long)page->mapping;
 		__entry->index		= page->index;
 	),
 
-	TP_printk("pfn=%lu flags=%lx count=%u mapcount=%u index=%lu",
-		  __entry->pfn, __entry->flags, __entry->count,
-		  __entry->mapcount, __entry->index)
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
 );
 
 #endif /*  _TRACE_MM_H */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
