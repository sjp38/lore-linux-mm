Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA3E6B004D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 12:09:44 -0400 (EDT)
Message-Id: <20090324160149.188175023@polymtl.ca>
References: <20090324155625.420966314@polymtl.ca>
Date: Tue, 24 Mar 2009 11:56:34 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 9/9] LTTng instrumentation - swap
Content-Disposition: inline; filename=lttng-instrumentation-swap.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, ltt-dev@lists.casi.polymtl.ca
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Masami Hiramatsu <mhiramat@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Frank Ch. Eigler" <fche@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

Instrumentation of waits caused by swap activity. Also instrumentation
swapon/swapoff events to keep track of active swap partitions.

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
 include/trace/swap.h |   20 ++++++++++++++++++++
 mm/memory.c          |    4 ++++
 mm/page_io.c         |    4 ++++
 mm/swapfile.c        |    6 ++++++
 4 files changed, 34 insertions(+)

Index: linux-2.6-lttng/mm/memory.c
===================================================================
--- linux-2.6-lttng.orig/mm/memory.c	2009-03-24 09:09:55.000000000 -0400
+++ linux-2.6-lttng/mm/memory.c	2009-03-24 09:32:15.000000000 -0400
@@ -55,6 +55,7 @@
 #include <linux/kallsyms.h>
 #include <linux/swapops.h>
 #include <linux/elf.h>
+#include <trace/swap.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -64,6 +65,8 @@
 
 #include "internal.h"
 
+DEFINE_TRACE(swap_in);
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
@@ -2431,6 +2434,7 @@ static int do_swap_page(struct mm_struct
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
+		trace_swap_in(page, entry);
 	}
 
 	mark_page_accessed(page);
Index: linux-2.6-lttng/mm/page_io.c
===================================================================
--- linux-2.6-lttng.orig/mm/page_io.c	2009-03-24 09:09:52.000000000 -0400
+++ linux-2.6-lttng/mm/page_io.c	2009-03-24 09:32:15.000000000 -0400
@@ -17,8 +17,11 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include <trace/swap.h>
 #include <asm/pgtable.h>
 
+DEFINE_TRACE(swap_out);
+
 static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
 				struct page *page, bio_end_io_t end_io)
 {
@@ -114,6 +117,7 @@ int swap_writepage(struct page *page, st
 		rw |= (1 << BIO_RW_SYNCIO) | (1 << BIO_RW_UNPLUG);
 	count_vm_event(PSWPOUT);
 	set_page_writeback(page);
+	trace_swap_out(page);
 	unlock_page(page);
 	submit_bio(rw, bio);
 out:
Index: linux-2.6-lttng/mm/swapfile.c
===================================================================
--- linux-2.6-lttng.orig/mm/swapfile.c	2009-03-24 09:09:52.000000000 -0400
+++ linux-2.6-lttng/mm/swapfile.c	2009-03-24 09:32:15.000000000 -0400
@@ -29,12 +29,16 @@
 #include <linux/capability.h>
 #include <linux/syscalls.h>
 #include <linux/memcontrol.h>
+#include <trace/swap.h>
 
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 #include <linux/swapops.h>
 #include <linux/page_cgroup.h>
 
+DEFINE_TRACE(swap_file_open);
+DEFINE_TRACE(swap_file_close);
+
 static DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
 long nr_swap_pages;
@@ -1497,6 +1501,7 @@ SYSCALL_DEFINE1(swapoff, const char __us
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
 	p->flags = 0;
+	trace_swap_file_close(swap_file);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
@@ -1886,6 +1891,7 @@ SYSCALL_DEFINE2(swapon, const char __use
 	} else {
 		swap_info[prev].next = p - swap_info;
 	}
+	trace_swap_file_open(swap_file, name);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	error = 0;
Index: linux-2.6-lttng/include/trace/swap.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-lttng/include/trace/swap.h	2009-03-24 09:32:26.000000000 -0400
@@ -0,0 +1,20 @@
+#ifndef _TRACE_SWAP_H
+#define _TRACE_SWAP_H
+
+#include <linux/swap.h>
+#include <linux/tracepoint.h>
+
+DECLARE_TRACE(swap_in,
+	TPPROTO(struct page *page, swp_entry_t entry),
+		TPARGS(page, entry));
+DECLARE_TRACE(swap_out,
+	TPPROTO(struct page *page),
+		TPARGS(page));
+DECLARE_TRACE(swap_file_open,
+	TPPROTO(struct file *file, char *filename),
+		TPARGS(file, filename));
+DECLARE_TRACE(swap_file_close,
+	TPPROTO(struct file *file),
+		TPARGS(file));
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
