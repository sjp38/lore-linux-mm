Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 57CED6B0039
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:30:17 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so17110946pab.40
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 11:30:17 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id va10si19294163pbc.128.2014.02.18.11.30.16
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 11:30:16 -0800 (PST)
Subject: [RFC][PATCH 4/6] x86: mm: trace tlb flushes
From: Dave Hansen <dave@sr71.net>
Date: Tue, 18 Feb 2014 11:30:15 -0800
References: <20140218193008.CA410E17@viggo.jf.intel.com>
In-Reply-To: <20140218193008.CA410E17@viggo.jf.intel.com>
Message-Id: <20140218193015.84BD2CB0@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, ak@linux.intel.com, alex.shi@linaro.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, tim.c.chen@linux.intel.com, x86@kernel.org, peterz@infradead.org, Dave Hansen <dave@sr71.net>


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

Also, since we have a pair of tracepoint calls in
flush_tlb_mm_range(), we can time the deltas between them to make
sure that we got the "invlpg vs. global flush" balance correct in
practice.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/include/asm/mmu_context.h |    6 +++++
 b/arch/x86/mm/tlb.c                  |   13 ++++++++++--
 b/include/linux/mm_types.h           |   10 +++++++++
 b/include/trace/events/tlb.h         |   37 +++++++++++++++++++++++++++++++++++
 b/mm/Makefile                        |    2 -
 b/mm/trace_tlb.c                     |   12 +++++++++++
 6 files changed, 77 insertions(+), 3 deletions(-)

diff -puN arch/x86/include/asm/mmu_context.h~tlb-trace-flushes arch/x86/include/asm/mmu_context.h
--- a/arch/x86/include/asm/mmu_context.h~tlb-trace-flushes	2014-02-18 10:59:38.570464074 -0800
+++ b/arch/x86/include/asm/mmu_context.h	2014-02-18 10:59:38.593465123 -0800
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
--- a/arch/x86/mm/tlb.c~tlb-trace-flushes	2014-02-18 10:59:38.574464256 -0800
+++ b/arch/x86/mm/tlb.c	2014-02-18 11:03:52.426034364 -0800
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
@@ -105,9 +109,10 @@ static void flush_tlb_func(void *info)
 
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
-		if (f->flush_end == TLB_FLUSH_ALL)
+		if (f->flush_end == TLB_FLUSH_ALL) {
 			local_flush_tlb();
-		else if (!f->flush_end)
+			trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, TLB_FLUSH_ALL);
+		} else if (!f->flush_end)
 			__flush_tlb_single(f->flush_start);
 		else {
 			unsigned long addr;
@@ -152,7 +157,9 @@ void flush_tlb_current_task(void)
 	preempt_disable();
 
 	count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
+	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN, TLB_FLUSH_ALL);
 	local_flush_tlb();
+	trace_tlb_flush(TLB_LOCAL_SHOOTDOWN_DONE, TLB_FLUSH_ALL);
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
 	preempt_enable();
@@ -180,6 +187,7 @@ void flush_tlb_mm_range(struct mm_struct
 	if ((end != TLB_FLUSH_ALL) && !(vmflag & VM_HUGETLB))
 		base_pages_to_flush = (end - start) >> PAGE_SHIFT;
 
+	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN, base_pages_to_flush);
 	if (base_pages_to_flush > tlb_single_page_flush_ceiling) {
 		base_pages_to_flush = TLB_FLUSH_ALL;
 		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
@@ -191,6 +199,7 @@ void flush_tlb_mm_range(struct mm_struct
 			__flush_tlb_single(addr);
 		}
 	}
+	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN_DONE, base_pages_to_flush);
 out:
 	if (base_pages_to_flush == TLB_FLUSH_ALL) {
 		start = 0UL;
diff -puN include/linux/mm_types.h~tlb-trace-flushes include/linux/mm_types.h
--- a/include/linux/mm_types.h~tlb-trace-flushes	2014-02-18 10:59:38.578464440 -0800
+++ b/include/linux/mm_types.h	2014-02-18 10:59:38.595465214 -0800
@@ -509,4 +509,14 @@ static inline void clear_tlb_flush_pendi
 }
 #endif
 
+enum tlb_flush_reason {
+	TLB_FLUSH_ON_TASK_SWITCH,
+	TLB_REMOTE_SHOOTDOWN,
+	TLB_LOCAL_SHOOTDOWN,
+	TLB_LOCAL_SHOOTDOWN_DONE,
+	TLB_LOCAL_MM_SHOOTDOWN,
+	TLB_LOCAL_MM_SHOOTDOWN_DONE,
+	NR_TLB_FLUSH_REASONS,
+};
+
 #endif /* _LINUX_MM_TYPES_H */
diff -puN /dev/null include/trace/events/tlb.h
--- /dev/null	2014-01-15 16:08:30.019511980 -0800
+++ b/include/trace/events/tlb.h	2014-02-18 11:05:13.176713847 -0800
@@ -0,0 +1,37 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM tlb
+
+#if !defined(_TRACE_TLB_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_TLB_H
+
+#include <linux/mm_types.h>
+#include <linux/tracepoint.h>
+
+extern const char * const tlb_flush_reason_desc[];
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
+	TP_printk("pages: %ld reason: %d (%s)",
+		__entry->pages,
+		__entry->reason,
+		tlb_flush_reason_desc[__entry->reason])
+);
+
+#endif /* _TRACE_TLB_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
+
diff -puN mm/Makefile~tlb-trace-flushes mm/Makefile
--- a/mm/Makefile~tlb-trace-flushes	2014-02-18 10:59:38.583464667 -0800
+++ b/mm/Makefile	2014-02-18 10:59:38.596465261 -0800
@@ -5,7 +5,7 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o pagewalk.o pgtable-generic.o
+			   vmalloc.o pagewalk.o pgtable-generic.o trace_tlb.o
 
 ifdef CONFIG_CROSS_MEMORY_ATTACH
 mmu-$(CONFIG_MMU)	+= process_vm_access.o
diff -puN /dev/null mm/trace_tlb.c
--- /dev/null	2014-01-15 16:08:30.019511980 -0800
+++ b/mm/trace_tlb.c	2014-02-18 10:59:38.596465261 -0800
@@ -0,0 +1,12 @@
+#define DEFINE_TRACE_POINTS
+#include <trace/events/tlb.h>
+
+const char * const tlb_flush_reason_desc[] = {
+	__stringify(TLB_FLUSH_ON_TASK_SWITCH),
+	__stringify(TLB_REMOTE_SHOOTDOWN),
+	__stringify(TLB_LOCAL_SHOOTDOWN),
+	__stringify(TLB_LOCAL_SHOOTDOWN_DONE),
+	__stringify(TLB_LOCAL_MM_SHOOTDOWN),
+	__stringify(TLB_LOCAL_MM_SHOOTDOWN_DONE),
+};
+
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
