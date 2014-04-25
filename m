Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id E88748298E
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 18:38:04 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id jt11so1960058pbb.40
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 15:37:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id nt4si5719162pbb.199.2014.04.25.15.37.55
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 15:37:55 -0700 (PDT)
Subject: [PATCH 8/8] x86: mm: instrument flush times
From: Dave Hansen <dave@sr71.net>
Date: Fri, 25 Apr 2014 15:37:53 -0700
References: <20140425223742.0A27E42E@viggo.jf.intel.com>
In-Reply-To: <20140425223742.0A27E42E@viggo.jf.intel.com>
Message-Id: <20140425223753.DC1CB0C0@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

The tracepoint code is a _bit_ too much overhead, so use some
percpu counters to aggregate it instead.

This is pretty quick and dirty, (like the big old kmalloc())
but it should be safe and function enough for developer use.

This is not fundamentally arch-dependent, so a move of this code
to mm/ would be prudent once a second user pops up.

I'm posting this so that others can replicate my experiments on
the per-page TLB flush limits on CPUs other than Intel's.  I
don't have a strong opinion about getting it in to mainline,
although it would make my life easier if it were merged.

The output looks like this:

# cat /sys/kernel/debug/x86/tlb_flush_stats
[FULL] 1037 285286
[1] 8159 3536885
[2] 1846 1095170
[3] 80 49731
[4] 842 699780
[6] 2 2665
[7] 773 1172234
[8] 8 11230
[10] 4 7014
[11] 1 1736
[15] 1 2081
[16] 101 227937
[19] 2 5581
[21] 4 11908
[25] 1 3204
[26] 4 14608
[27] 7 29729
[28] 2 7145
[32] 3 12690
[33] 3 12232

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
---

 b/arch/x86/mm/tlb.c |  137 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 b/lib/Kconfig.debug |   15 +++++
 2 files changed, 152 insertions(+)

diff -puN arch/x86/mm/tlb.c~instrument-flush-times arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~instrument-flush-times	2014-04-25 15:33:14.194108105 -0700
+++ b/arch/x86/mm/tlb.c	2014-04-25 15:33:14.199108331 -0700
@@ -6,6 +6,7 @@
 #include <linux/interrupt.h>
 #include <linux/module.h>
 #include <linux/cpu.h>
+#include <linux/slab.h>
 
 #include <asm/tlbflush.h>
 #include <asm/mmu_context.h>
@@ -17,6 +18,129 @@
 #define CREATE_TRACE_POINTS
 #include <trace/events/tlb.h>
 
+#ifndef CONFIG_DETAILED_TLB_FLUSH_STATS
+static inline void inc_tlb_stat(u64 flush_size, u64 time) {}
+static inline u64 tlb_clock(void) { return 0; }
+#else
+static inline u64 tlb_clock(void)
+{
+	return sched_clock();
+}
+struct one_tlb_stat {
+	u64 flushes;
+	u64 time;
+};
+/*
+ * make sure to bump TLB_STAT_LINE_SIZE if you make this
+ * larger than 4 digits
+ */
+#define NR_TO_TRACK 1024
+struct tlb_stats {
+	struct one_tlb_stat stats[NR_TO_TRACK];
+};
+
+DEFINE_PER_CPU(struct tlb_stats, tlb_stats);
+
+/*
+ * This is only called from two contexts: flush_tlb_mm_range(),
+ * during which preeption is off, and flush_tlb_func() which is
+ * called from an IPI.  That makes the use of smp_processor_id()
+ * safe.
+ */
+void inc_tlb_stat(u64 flush_size, u64 time)
+{
+	struct tlb_stats *thiscpu = &per_cpu(tlb_stats, smp_processor_id());
+	struct one_tlb_stat *stat;
+
+	if (flush_size == TLB_FLUSH_ALL)
+		flush_size = 0;
+	if (flush_size >= NR_TO_TRACK)
+		flush_size = NR_TO_TRACK-1;
+
+	stat = &thiscpu->stats[flush_size];
+	stat->time += time;
+	stat->flushes++;
+}
+
+/*
+ * '[' + 4-digits + ']' + space
+ * 20-digit long + space
+ * + \n
+ */
+#define TLB_STAT_LINE_SIZE (1+4+1+1+20+1+20+1)
+static ssize_t tlb_stat_read_file(struct file *file, char __user *user_buf,
+			     size_t count, loff_t *ppos)
+{
+	int cpu;
+	int flush_size;
+	unsigned int len = 0;
+	char *printbuf = kmalloc(TLB_STAT_LINE_SIZE * NR_TO_TRACK, GFP_KERNEL);
+
+	if (!printbuf)
+		return -ENOMEM;
+
+	for (flush_size = 0; flush_size < NR_TO_TRACK; flush_size++) {
+		struct one_tlb_stat tot;
+		tot.flushes = 0;
+		tot.time = 0;
+
+		for_each_online_cpu(cpu){
+			struct tlb_stats *thiscpu = &per_cpu(tlb_stats, cpu);
+			struct one_tlb_stat *stat;
+			stat = &thiscpu->stats[flush_size];
+			tot.flushes += stat->flushes;
+			tot.time += stat->time;
+		}
+		if (!tot.flushes)
+			continue;
+		if (flush_size == 0)
+			len += sprintf(&printbuf[len], "[FULL]");
+		else if (flush_size == NR_TO_TRACK-1)
+			len += sprintf(&printbuf[len], "[FBIG]");
+		else
+			len += sprintf(&printbuf[len], "[%d]", flush_size);
+
+		len += sprintf(&printbuf[len], " %lld %lld\n",
+			tot.flushes, tot.time);
+	}
+
+	kfree(printbuf);
+	return simple_read_from_buffer(user_buf, count, ppos, printbuf, len);
+}
+
+static ssize_t tlb_stat_write_file(struct file *file,
+		 const char __user *user_buf, size_t count, loff_t *ppos)
+{
+	int cpu;
+	int flush_size;
+
+	for_each_online_cpu(cpu){
+		struct tlb_stats *thiscpu = &per_cpu(tlb_stats, cpu);
+		for (flush_size = 0; flush_size < NR_TO_TRACK; flush_size++) {
+			struct one_tlb_stat *stat;
+			stat = &thiscpu->stats[flush_size];
+			stat->time = 0;
+			stat->flushes = 0;
+		}
+	}
+	return count;
+}
+
+static const struct file_operations fops_tlb_stat = {
+	.read = tlb_stat_read_file,
+	.write = tlb_stat_write_file,
+	.llseek = default_llseek,
+};
+
+static int __init create_tlb_stats(void)
+{
+	debugfs_create_file("tlb_flush_stats", S_IRUSR | S_IWUSR,
+			    arch_debugfs_dir, NULL, &fops_tlb_stat);
+	return 0;
+}
+late_initcall(create_tlb_stats);
+#endif /* CONFIG_DETAILED_TLB_FLUSH_STATS */
+
 DEFINE_PER_CPU_SHARED_ALIGNED(struct tlb_state, cpu_tlbstate)
 			= { &init_mm, 0, };
 
@@ -112,18 +236,25 @@ static void flush_tlb_func(void *info)
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
 		if (f->flush_end == TLB_FLUSH_ALL) {
+			u64 start_ns = tlb_clock();
 			local_flush_tlb();
+			inc_tlb_stat(TLB_FLUSH_ALL, tlb_clock() - start_ns);
 			trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, TLB_FLUSH_ALL);
 		} else {
 			unsigned long addr;
 			unsigned long nr_pages =
 				f->flush_end - f->flush_start / PAGE_SIZE;
+			u64 start_ns;
+
+			start_ns = tlb_clock();
 			addr = f->flush_start;
 			while (addr < f->flush_end) {
 				__flush_tlb_single(addr);
 				addr += PAGE_SIZE;
 			}
 			trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, nr_pages);
+			inc_tlb_stat((f->flush_end - f->flush_start) / PAGE_SIZE,
+				     tlb_clock() - start_ns);
 		}
 	} else
 		leave_mm(smp_processor_id());
@@ -182,6 +313,8 @@ unsigned long tlb_single_page_flush_ceil
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag)
 {
+	u64 start_ns = 0;
+	u64 end_ns;
 	unsigned long addr;
 	/* do a global flush by default */
 	unsigned long base_pages_to_flush = TLB_FLUSH_ALL;
@@ -198,6 +331,7 @@ void flush_tlb_mm_range(struct mm_struct
 	if ((end != TLB_FLUSH_ALL) && !(vmflag & VM_HUGETLB))
 		base_pages_to_flush = (end - start) >> PAGE_SHIFT;
 
+	start_ns = tlb_clock();
 	if (base_pages_to_flush > tlb_single_page_flush_ceiling) {
 		base_pages_to_flush = TLB_FLUSH_ALL;
 		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
@@ -209,12 +343,15 @@ void flush_tlb_mm_range(struct mm_struct
 			__flush_tlb_single(addr);
 		}
 	}
+	end_ns = tlb_clock();
 	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN, base_pages_to_flush);
 out:
 	if (base_pages_to_flush == TLB_FLUSH_ALL) {
 		start = 0UL;
 		end = TLB_FLUSH_ALL;
 	}
+	if (start_ns)
+		inc_tlb_stat(base_pages_to_flush, end_ns - start_ns);
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, start, end);
 	preempt_enable();
diff -puN lib/Kconfig.debug~instrument-flush-times lib/Kconfig.debug
--- a/lib/Kconfig.debug~instrument-flush-times	2014-04-25 15:33:14.196108195 -0700
+++ b/lib/Kconfig.debug	2014-04-25 15:33:14.200108376 -0700
@@ -599,6 +599,21 @@ config DEBUG_STACKOVERFLOW
 
 	  If in doubt, say "N".
 
+config DETAILED_TLB_FLUSH_STATS
+	bool "Detailed TLB flush statistics"
+	depends on X86
+	---help---
+	  This creates a file at
+
+	  	/sys/kernel/debug/x86/tlb_flush_stats
+
+	  which exposes two bits of information:
+	  	1. The number of TLB flushes of each size
+		2. The amount of time spend doing those flushes
+
+	  If in doubt, say "N".  This option may have performance
+	  overhead and should only be used for debugging.
+
 source "lib/Kconfig.kmemcheck"
 
 endmenu # "Memory Debugging"
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
