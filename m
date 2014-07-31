Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 94FF86B003B
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 11:42:01 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so3824408pab.33
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 08:42:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id sn4si6346435pab.203.2014.07.31.08.41.22
        for <linux-mm@kvack.org>;
        Thu, 31 Jul 2014 08:41:22 -0700 (PDT)
Subject: [PATCH 5/7] x86: mm: add tracepoints for TLB flushes
From: Dave Hansen <dave@sr71.net>
Date: Thu, 31 Jul 2014 08:40:59 -0700
References: <20140731154052.C7E7FBC1@viggo.jf.intel.com>
In-Reply-To: <20140731154052.C7E7FBC1@viggo.jf.intel.com>
Message-Id: <20140731154059.4C96CBA5@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, riel@redhat.com, mgorman@suse.de


Changes from v3:
 * remove trace_tlb.c and __print_symbolic() instead
 * make sure to cover all cases in flush_tlb_func()
 * remove _DONE "reason" since it was not precise enough

--

From: Dave Hansen <dave.hansen@linux.intel.com>

We don't have any good way to figure out what kinds of flushes
are being attempted.  Right now, we can try to use the vm
counters, but those only tell us what we actually did with the
hardware (one-by-one vs full) and don't tell us what was actually
_requested_.

This allows us to select out "interesting" TLB flushes that we
might want to optimize (like the ranged ones) and ignore the ones
that we have very little control over (the ones at context
switch).

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
---

 b/arch/x86/include/asm/mmu_context.h |    6 +++++
 b/arch/x86/mm/init.c                 |    7 +++++
 b/arch/x86/mm/tlb.c                  |   11 +++++++--
 b/include/linux/mm_types.h           |    8 ++++++
 b/include/trace/events/tlb.h         |   41 +++++++++++++++++++++++++++++++++++
 5 files changed, 71 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/mmu_context.h~tlb-trace-flushes arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~tlb-trace-flushes	2014-06-30 16:18:33.294800281 -0700
+++ b/arch/x86/include/asm/mmu_context.h	2014-06-30 16:18:33.306800827 -0700
@@ -3,6 +3,10 @@
 
 #include <asm/desc.h>
 #include <linux/atomic.h>
+#include <linux/mm_types.h>
+
+#include <trace/events/tlb.h>
+
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 #include <asm/paravirt.h>
@@ -44,6 +48,7 @@ static inline void switch_mm(struct mm_s
 
 		/* Re-load page tables */
 		load_cr3(next->pgd);
+		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
 
 		/* Stop flush ipis for the previous mm */
 		cpumask_clear_cpu(cpu, mm_cpumask(prev));
@@ -71,6 +76,7 @@ static inline void switch_mm(struct mm_s
 			 * to make sure to use no freed page tables.
 			 */
 			load_cr3(next->pgd);
+			trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
 			load_LDT_nolock(&next->context);
 		}
 	}
diff -puN arch/x86/mm/init.c~tlb-trace-flushes arch/x86/mm/init.c
--- a/arch/x86/mm/init.c~tlb-trace-flushes	2014-06-30 16:18:33.298800464 -0700
+++ b/arch/x86/mm/init.c	2014-06-30 16:18:37.515992478 -0700
@@ -18,6 +18,13 @@
 #include <asm/dma.h>		/* for MAX_DMA_PFN */
 #include <asm/microcode.h>
 
+/*
+ * We need to define the tracepoints somewhere, and tlb.c
+ * is only compied when SMP=y.
+ */
+#define CREATE_TRACE_POINTS
+#include <trace/events/tlb.h>
+
 #include "mm_internal.h"
 
 static unsigned long __initdata pgt_buf_start;
diff -puN arch/x86/mm/tlb.c~tlb-trace-flushes arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~tlb-trace-flushes	2014-06-30 16:18:33.301800600 -0700
+++ b/arch/x86/mm/tlb.c	2014-06-30 16:18:33.307800873 -0700
@@ -49,6 +49,7 @@ void leave_mm(int cpu)
 	if (cpumask_test_cpu(cpu, mm_cpumask(active_mm))) {
 		cpumask_clear_cpu(cpu, mm_cpumask(active_mm));
 		load_cr3(swapper_pg_dir);
+		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
 	}
 }
 EXPORT_SYMBOL_GPL(leave_mm);
@@ -107,15 +108,19 @@ static void flush_tlb_func(void *info)
 
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
-		if (f->flush_end == TLB_FLUSH_ALL)
+		if (f->flush_end == TLB_FLUSH_ALL) {
 			local_flush_tlb();
-		else {
+			trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, TLB_FLUSH_ALL);
+		} else {
 			unsigned long addr;
+			unsigned long nr_pages =
+				f->flush_end - f->flush_start / PAGE_SIZE;
 			addr = f->flush_start;
 			while (addr < f->flush_end) {
 				__flush_tlb_single(addr);
 				addr += PAGE_SIZE;
 			}
+			trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, nr_pages);
 		}
 	} else
 		leave_mm(smp_processor_id());
@@ -153,6 +158,7 @@ void flush_tlb_current_task(void)
 
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 	local_flush_tlb();
+	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
 	preempt_enable();
@@ -191,6 +197,7 @@ void flush_tlb_mm_range(struct mm_struct
 			__flush_tlb_single(addr);
 		}
 	}
+	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN, base_pages_to_flush);
 out:
 	if (base_pages_to_flush == TLB_FLUSH_ALL) {
 		start = 0UL;
diff -puN include/linux/mm_types.h~tlb-trace-flushes include/linux/mm_types.h
--- a/include/linux/mm_types.h~tlb-trace-flushes	2014-06-30 16:18:33.303800691 -0700
+++ b/include/linux/mm_types.h	2014-06-30 16:18:35.089882014 -0700
@@ -516,4 +516,12 @@ struct vm_special_mapping
 	struct page **pages;
 };
 
+enum tlb_flush_reason {
+	TLB_FLUSH_ON_TASK_SWITCH,
+	TLB_REMOTE_SHOOTDOWN,
+	TLB_LOCAL_SHOOTDOWN,
+	TLB_LOCAL_MM_SHOOTDOWN,
+	NR_TLB_FLUSH_REASONS,
+};
+
 #endif /* _LINUX_MM_TYPES_H */
diff -puN /dev/null include/trace/events/tlb.h
--- /dev/null	2014-04-10 11:28:14.066815724 -0700
+++ b/include/trace/events/tlb.h	2014-06-30 16:18:37.476990703 -0700
@@ -0,0 +1,41 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM tlb
+
+#if !defined(_TRACE_TLB_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_TLB_H
+
+#include <linux/mm_types.h>
+#include <linux/tracepoint.h>
+
+#define TLB_FLUSH_REASON	\
+	{ TLB_FLUSH_ON_TASK_SWITCH, 	"flush on task switch" },	\
+	{ TLB_REMOTE_SHOOTDOWN,		"remote shootdown" },		\
+	{ TLB_LOCAL_SHOOTDOWN, 		"local shootdown" },		\
+	{ TLB_LOCAL_MM_SHOOTDOWN,	"local mm shootdown" }
+
+TRACE_EVENT(tlb_flush,
+
+	TP_PROTO(int reason, unsigned long pages),
+	TP_ARGS(reason, pages),
+
+	TP_STRUCT__entry(
+		__field(	  int, reason)
+		__field(unsigned long,  pages)
+	),
+
+	TP_fast_assign(
+		__entry->reason = reason;
+		__entry->pages  = pages;
+	),
+
+	TP_printk("pages:%ld reason:%s (%d)",
+		__entry->pages,
+		__print_symbolic(__entry->reason, TLB_FLUSH_REASON),
+		__entry->reason)
+);
+
+#endif /* _TRACE_TLB_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
+
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
