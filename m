Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EEFD76B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 12:09:22 -0400 (EDT)
Message-Id: <20090324160149.029092843@polymtl.ca>
References: <20090324155625.420966314@polymtl.ca>
Date: Tue, 24 Mar 2009 11:56:33 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 8/9] LTTng instrumentation - filemap
Content-Disposition: inline; filename=lttng-instrumentation-filemap.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, ltt-dev@lists.casi.polymtl.ca
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Masami Hiramatsu <mhiramat@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Frank Ch. Eigler" <fche@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Instrumentation of waits caused by memory accesses on mmap regions.

Those tracepoints are used by LTTng.

About the performance impact of tracepoints (which is comparable to markers),
even without immediate values optimizations, tests done by Hideo Aoki on ia64
show no regression. His test case was using hackbench on a kernel where
scheduler instrumentation (about 5 events in code scheduler code) was added.
See the "Tracepoints" patch header for performance result detail.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: linux-mm@kvack.org
CC: Dave Hansen <haveblue@us.ibm.com>
CC: Masami Hiramatsu <mhiramat@redhat.com>
CC: 'Peter Zijlstra' <peterz@infradead.org>
CC: "Frank Ch. Eigler" <fche@redhat.com>
CC: 'Ingo Molnar' <mingo@elte.hu>
CC: Frederic Weisbecker <fweisbec@gmail.com>
CC: 'Hideo AOKI' <haoki@redhat.com>
CC: Takashi Nishiie <t-nishiie@np.css.fujitsu.com>
CC: 'Steven Rostedt' <rostedt@goodmis.org>
CC: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 include/trace/filemap.h |   13 +++++++++++++
 mm/filemap.c            |    5 +++++
 2 files changed, 18 insertions(+)

Index: linux-2.6-lttng/mm/filemap.c
===================================================================
--- linux-2.6-lttng.orig/mm/filemap.c	2009-03-24 09:09:52.000000000 -0400
+++ linux-2.6-lttng/mm/filemap.c	2009-03-24 09:32:05.000000000 -0400
@@ -34,6 +34,7 @@
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
 #include <linux/mm_inline.h> /* for page_is_file_cache() */
+#include <trace/filemap.h>
 #include "internal.h"
 
 /*
@@ -43,6 +44,8 @@
 
 #include <asm/mman.h>
 
+DEFINE_TRACE(wait_on_page_start);
+DEFINE_TRACE(wait_on_page_end);
 
 /*
  * Shared mappings implemented 30.11.1994. It's not fully working yet,
@@ -558,9 +561,11 @@ void wait_on_page_bit(struct page *page,
 {
 	DEFINE_WAIT_BIT(wait, &page->flags, bit_nr);
 
+	trace_wait_on_page_start(page, bit_nr);
 	if (test_bit(bit_nr, &page->flags))
 		__wait_on_bit(page_waitqueue(page), &wait, sync_page,
 							TASK_UNINTERRUPTIBLE);
+	trace_wait_on_page_end(page, bit_nr);
 }
 EXPORT_SYMBOL(wait_on_page_bit);
 
Index: linux-2.6-lttng/include/trace/filemap.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-lttng/include/trace/filemap.h	2009-03-24 09:32:13.000000000 -0400
@@ -0,0 +1,13 @@
+#ifndef _TRACE_FILEMAP_H
+#define _TRACE_FILEMAP_H
+
+#include <linux/tracepoint.h>
+
+DECLARE_TRACE(wait_on_page_start,
+	TPPROTO(struct page *page, int bit_nr),
+		TPARGS(page, bit_nr));
+DECLARE_TRACE(wait_on_page_end,
+	TPPROTO(struct page *page, int bit_nr),
+		TPARGS(page, bit_nr));
+
+#endif

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
