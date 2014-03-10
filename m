Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id B41256B0055
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 13:12:56 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so7316284pdj.31
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 10:12:56 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id po10si17425571pab.189.2014.03.10.10.12.55
        for <linux-mm@kvack.org>;
        Mon, 10 Mar 2014 10:12:55 -0700 (PDT)
Subject: [PATCH 7/7] big time hack: instrument flush times
From: Dave Hansen <dave@sr71.net>
Date: Mon, 10 Mar 2014 10:11:34 -0700
References: <20140310171118.7E16CD45@viggo.jf.intel.com>
In-Reply-To: <20140310171118.7E16CD45@viggo.jf.intel.com>
Message-Id: <20140310171134.DFE096F8@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, ak@linux.intel.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, alex.shi@linaro.org, x86@kernel.org, linux-mm@kvack.org, davidlohr@hp.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

The tracepoint code is a _bit_ too much overhead, so use some
percpu counters to aggregate it instead.  Yes, this is racy
and ugly beyond reason, but it was quick to code up.

I'm posting this here because it's interesting to have around,
and if other folks like it, maybe I can get it in to shape to
stick in to mainline.

---

 b/arch/x86/mm/tlb.c |  112 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 112 insertions(+)

diff -puN arch/x86/mm/tlb.c~instrument-flush-times arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~instrument-flush-times	2014-03-05 16:10:11.255122898 -0800
+++ b/arch/x86/mm/tlb.c	2014-03-05 16:10:11.258123035 -0800
@@ -97,6 +97,8 @@ EXPORT_SYMBOL_GPL(leave_mm);
  * 1) Flush the tlb entries if the cpu uses the mm that's being flushed.
  * 2) Leave the mm if we are in the lazy tlb mode.
  */
+void inc_stat(u64 flush_size, u64 time);
+
 static void flush_tlb_func(void *info)
 {
 	struct flush_tlb_info *f = info;
@@ -109,17 +111,23 @@ static void flush_tlb_func(void *info)
 	count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
 		if (f->flush_end == TLB_FLUSH_ALL) {
+			u64 start_ns = sched_clock();
 			local_flush_tlb();
+			inc_stat(TLB_FLUSH_ALL, sched_clock() - start_ns);
 			trace_tlb_flush(TLB_REMOTE_SHOOTDOWN, TLB_FLUSH_ALL);
 		} else if (!f->flush_end)
 			__flush_tlb_single(f->flush_start);
 		else {
+			u64 start_ns;
 			unsigned long addr;
+			start_ns = sched_clock();
 			addr = f->flush_start;
 			while (addr < f->flush_end) {
 				__flush_tlb_single(addr);
 				addr += PAGE_SIZE;
 			}
+			inc_stat((f->flush_end - f->flush_start) / PAGE_SIZE,
+				 sched_clock() - start_ns);
 		}
 	} else
 		leave_mm(smp_processor_id());
@@ -164,12 +172,112 @@ void flush_tlb_current_task(void)
 	preempt_enable();
 }
 
+struct one_tlb_stat {
+	u64 flushes;
+	u64 time;
+};
+
+#define NR_TO_TRACK 1024
+
+struct tlb_stats {
+	struct one_tlb_stat stats[NR_TO_TRACK];
+};
+
+DEFINE_PER_CPU(struct tlb_stats, tlb_stats);
+
+void inc_stat(u64 flush_size, u64 time)
+{
+	struct tlb_stats *thiscpu =
+		&per_cpu(tlb_stats, smp_processor_id());
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
+char printbuf[80 * NR_TO_TRACK];
+static ssize_t tlb_stat_read_file(struct file *file, char __user *user_buf,
+			     size_t count, loff_t *ppos)
+{
+	int cpu;
+	int flush_size;
+	unsigned int len = 0;
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
+
+
 /* in units of pages */
 unsigned long tlb_single_page_flush_ceiling = 33;
 
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag)
 {
+	u64 start_ns = 0;
+	u64 end_ns;
 	unsigned long addr;
 	/* do a global flush by default */
 	unsigned long base_pages_to_flush = TLB_FLUSH_ALL;
@@ -187,6 +295,7 @@ void flush_tlb_mm_range(struct mm_struct
 		base_pages_to_flush = (end - start) >> PAGE_SHIFT;
 
 	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN, base_pages_to_flush);
+	start_ns = sched_clock();
 	if (base_pages_to_flush > tlb_single_page_flush_ceiling) {
 		base_pages_to_flush = TLB_FLUSH_ALL;
 		count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
@@ -198,12 +307,15 @@ void flush_tlb_mm_range(struct mm_struct
 			__flush_tlb_single(addr);
 		}
 	}
+	end_ns = sched_clock();
 	trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN_DONE, base_pages_to_flush);
 out:
 	if (base_pages_to_flush == TLB_FLUSH_ALL) {
 		start = 0UL;
 		end = TLB_FLUSH_ALL;
 	}
+	if (start_ns)
+		inc_stat(base_pages_to_flush, end_ns - start_ns);
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, start, end);
 	preempt_enable();
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
