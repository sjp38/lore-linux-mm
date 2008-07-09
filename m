Message-Id: <20080709150046.431564903@polymtl.ca>
References: <20080709145929.352201601@polymtl.ca>
Date: Wed, 09 Jul 2008 10:59:38 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 09/15] LTTng instrumentation - swap
Content-Disposition: inline; filename=lttng-instrumentation-swap.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Masami Hiramatsu <mhiramat@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Frank Ch. Eigler" <fche@redhat.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
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
CC: 'Hideo AOKI' <haoki@redhat.com>
CC: Takashi Nishiie <t-nishiie@np.css.fujitsu.com>
CC: 'Steven Rostedt' <rostedt@goodmis.org>
CC: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
---
 mm/memory.c     |    2 ++
 mm/page_io.c    |    2 ++
 mm/swap-trace.h |   20 ++++++++++++++++++++
 mm/swapfile.c   |    4 ++++
 4 files changed, 28 insertions(+)

Index: linux-2.6-lttng/mm/memory.c
===================================================================
--- linux-2.6-lttng.orig/mm/memory.c	2008-07-09 10:46:33.000000000 -0400
+++ linux-2.6-lttng/mm/memory.c	2008-07-09 10:58:31.000000000 -0400
@@ -51,6 +51,7 @@
 #include <linux/init.h>
 #include <linux/writeback.h>
 #include <linux/memcontrol.h>
+#include "swap-trace.h"
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -2213,6 +2214,7 @@ static int do_swap_page(struct mm_struct
 		/* Had to read the page from swap area: Major fault */
 		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
+		trace_swap_in(page, entry);
 	}
 
 	if (mem_cgroup_charge(page, mm, GFP_KERNEL)) {
Index: linux-2.6-lttng/mm/page_io.c
===================================================================
--- linux-2.6-lttng.orig/mm/page_io.c	2008-07-09 10:46:33.000000000 -0400
+++ linux-2.6-lttng/mm/page_io.c	2008-07-09 10:58:31.000000000 -0400
@@ -17,6 +17,7 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include "swap-trace.h"
 #include <asm/pgtable.h>
 
 static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
@@ -114,6 +115,7 @@ int swap_writepage(struct page *page, st
 		rw |= (1 << BIO_RW_SYNC);
 	count_vm_event(PSWPOUT);
 	set_page_writeback(page);
+	trace_swap_out(page);
 	unlock_page(page);
 	submit_bio(rw, bio);
 out:
Index: linux-2.6-lttng/mm/swapfile.c
===================================================================
--- linux-2.6-lttng.orig/mm/swapfile.c	2008-07-09 10:46:33.000000000 -0400
+++ linux-2.6-lttng/mm/swapfile.c	2008-07-09 10:58:31.000000000 -0400
@@ -32,6 +32,7 @@
 #include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 #include <linux/swapops.h>
+#include "swap-trace.h"
 
 DEFINE_SPINLOCK(swap_lock);
 unsigned int nr_swapfiles;
@@ -1310,6 +1311,7 @@ asmlinkage long sys_swapoff(const char _
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
 	p->flags = 0;
+	trace_swap_file_close(swap_file);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
@@ -1695,6 +1697,7 @@ asmlinkage long sys_swapon(const char __
 	} else {
 		swap_info[prev].next = p - swap_info;
 	}
+	trace_swap_file_open(swap_file, name);
 	spin_unlock(&swap_lock);
 	mutex_unlock(&swapon_mutex);
 	error = 0;
@@ -1796,6 +1799,7 @@ get_swap_info_struct(unsigned type)
 {
 	return &swap_info[type];
 }
+EXPORT_SYMBOL_GPL(get_swap_info_struct);
 
 /*
  * swap_lock prevents swap_map being freed. Don't grab an extra
Index: linux-2.6-lttng/mm/swap-trace.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-lttng/mm/swap-trace.h	2008-07-09 10:58:31.000000000 -0400
@@ -0,0 +1,20 @@
+#ifndef _SWAP_TRACE_H
+#define _SWAP_TRACE_H
+
+#include <linux/swap.h>
+#include <linux/tracepoint.h>
+
+DEFINE_TRACE(swap_in,
+	TPPROTO(struct page *page, swp_entry_t entry),
+	TPARGS(page, entry));
+DEFINE_TRACE(swap_out,
+	TPPROTO(struct page *page),
+	TPARGS(page));
+DEFINE_TRACE(swap_file_open,
+	TPPROTO(struct file *file, char *filename),
+	TPARGS(file, filename));
+DEFINE_TRACE(swap_file_close,
+	TPPROTO(struct file *file),
+	TPARGS(file));
+
+#endif

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
