Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 774048D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:55:51 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p110aTeZ014309
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:36:30 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 541984DE803F
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:55:17 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p110tnGw400756
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:55:49 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p110tmOo026949
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:55:48 -0500
Subject: [RFC][PATCH] trace transparent huge page splits
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 31 Jan 2011 16:55:47 -0800
Message-Id: <20110201005547.85774260@kernel>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


When we see transparent huge pages being broken down, we generally
have no idea of finding anything out about how it happened, or what
it affected.

A simple static tracepoint like this should at least get us some
minimal information like a stack trace, the virtual address, and
the mm that it happened to.

I'm not sure if there is a better way to do this with any of the
other tracing mechanisms, but this seems to work at least for me.
Does anybody else have a better way?  Is it worth merging this
kind of stuff, or is it best left out of tree as a debugging
patch?

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/include/trace/events/huge_memory.h |   32 ++++++++++++++++++
 linux-2.6.git-dave/mm/huge_memory.c                   |    5 ++
 2 files changed, 37 insertions(+)

diff -puN /dev/null include/trace/events/huge_memory.h
--- /dev/null	2011-01-21 14:16:26.635488000 -0800
+++ linux-2.6.git-dave/include/trace/events/huge_memory.h	2011-01-31 16:42:37.607926454 -0800
@@ -0,0 +1,32 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM huge_memory
+
+#if !defined(_TRACE_HUGE_MEMORY_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_HUGE_MEMORY_H
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(mm_huge_memory_split,
+
+	TP_PROTO(struct mm_struct *mm, unsigned long address),
+
+	TP_ARGS(mm, address),
+
+	TP_STRUCT__entry(
+		__field(struct mm_struct *, mm)
+		__field(unsigned long,	    address)
+	),
+
+	TP_fast_assign(
+		__entry->mm	 = mm;
+		__entry->address = address;
+	),
+
+	TP_printk("mm=%p address=%p", __entry->mm, (void *)__entry->address)
+);
+
+#endif /* _TRACE_HUGE_MEMORY_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff -puN include/linux/huge_mm.h~huge_mem_trace include/linux/huge_mm.h
diff -puN mm/huge_memory.c~huge_mem_trace mm/huge_memory.c
--- linux-2.6.git/mm/huge_memory.c~huge_mem_trace	2011-01-31 16:40:38.752014520 -0800
+++ linux-2.6.git-dave/mm/huge_memory.c	2011-01-31 16:41:15.671987202 -0800
@@ -21,6 +21,9 @@
 #include <asm/pgalloc.h>
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/huge_memory.h>
+
 /*
  * By default transparent hugepage support is enabled for all mappings
  * and khugepaged scans all mappings. Defrag is only invoked by
@@ -1254,6 +1257,8 @@ static int __split_huge_page_map(struct 
 	pgtable_t pgtable;
 	unsigned long haddr;
 
+	trace_mm_huge_memory_split(vma->vm_mm, address);
+
 	spin_lock(&mm->page_table_lock);
 	pmd = page_check_address_pmd(page, mm, address,
 				     PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG);
diff -puN mm/vmscan.c~huge_mem_trace mm/vmscan.c
diff -puN mm/page_io.c~huge_mem_trace mm/page_io.c
diff -puN block/blk-core.c~huge_mem_trace block/blk-core.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
