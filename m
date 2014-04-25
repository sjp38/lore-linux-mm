Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id B9FB26B003B
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 18:37:50 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rq2so3711333pbb.11
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 15:37:50 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id zp5si2270611pac.352.2014.04.25.15.37.49
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 15:37:49 -0700 (PDT)
Subject: [PATCH 5/8] x86: mm: add tracepoints for TLB flushes
From: Dave Hansen <dave@sr71.net>
Date: Fri, 25 Apr 2014 15:37:49 -0700
References: <20140425223742.0A27E42E@viggo.jf.intel.com>
In-Reply-To: <20140425223742.0A27E42E@viggo.jf.intel.com>
Message-Id: <20140425223749.9D08513F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>


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
 b/arch/x86/mm/tlb.c                  |   14 ++++++++++-
 b/include/linux/mm_types.h           |    8 ++++++
 b/include/trace/events/tlb.h         |   41 +++++++++++++++++++++++++++++++++++
 4 files changed, 67 insertions(+), 2 deletions(-)

diff -puN arch/x86/include/asm/mmu_context.h~tlb-trace-flushes arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~tlb-trace-flushes	2014-04-25 15:33:13.352070158 -0700
+++ b/arch/x86/include/asm/mmu_context.h	2014-04-25 15:33:13.358070428 -0700
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
diff -puN arch/x86/mm/tlb.c~tlb-trace-flushes arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~tlb-trace-flushes	2014-04-25 15:33:13.353070203 -0700
+++ b/arch/x86/mm/tlb.c	2014-04-25 15:33:13.359070473 -0700
@@ -14,6 +14,9 @@
 #include <asm/uv/uv.h>
 #include <linux/debugfs.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/tlb.h>
+
 DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate)
 			= { &init_mm, 0, };
 
@@ -49,6 +52,7 @@ void leave_mm(int cpu)
 	if (cpumask_test_cpu(cpu, mm_cpumask(active_mm))) {
 		cpumask_clear_cpu(cpu, mm_cpumask(active_mm));
 		load_cr3(swapper_pg_dir);
+		trace_tlb_flush(TLB_FLUSH_ON_TASK_SWITCH, TLB_FLUSH_ALL);
 	}
 }
 EXPORT_SYMBOL_GPL(leave_mm);
@@ -107,15 +111,19 @@ static void flush_tlb_func(void *info)
 
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
@@ -153,6 +161,7 @@ void flush_tlb_current_task(void)
 
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
 	local_flush_tlb();
+	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
 	preempt_enable();
@@ -191,6 +200,7 @@ void flush_tlb_mm_range(struct mm_struct
 			__flush_tlb_single(addr);
 		}
 	}
+	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN, base_pages_to_flush);
 out:
 	if (base_pages_to_flush == TLB_FLUSH_ALL) {
 		start = 0UL;
diff -puN include/linux/mm_types.h~tlb-trace-flushes include/linux/mm_types.h
--- a/include/linux/mm_types.h~tlb-trace-flushes	2014-04-25 15:33:13.355070293 -0700
+++ b/include/linux/mm_types.h	2014-04-25 15:33:13.359070473 -0700
@@ -510,4 +510,12 @@ static inline void clear_tlb_flush_pendi
 }
 #endif
 
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
+++ b/include/trace/events/tlb.h	2014-04-25 15:33:13.359070473 -0700
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
