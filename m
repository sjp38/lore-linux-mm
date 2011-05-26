Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E52EC6B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 17:08:43 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] memcg: add pgfault latency histograms
Date: Thu, 26 May 2011 14:07:49 -0700
Message-Id: <1306444069-5094-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This adds histogram to capture pagefault latencies on per-memcg basis. I used
this patch on the memcg background reclaim test, and figured there could be more
usecases to monitor/debug application performance.

The histogram is composed 8 bucket in ns unit. The last one is infinite (inf)
which is everything beyond the last one. To be more flexible, the buckets can
be reset and also each bucket is configurable at runtime.

memory.pgfault_histogram: exports the histogram on per-memcg basis and also can
be reset by echoing "reset". Meantime, all the buckets are writable by echoing
the range into the API. see the example below.

/proc/sys/vm/pgfault_histogram: the global sysfs tunablecan be used to turn
on/off recording the histogram.

Functional Test:
Create a memcg with 10g hard_limit, running dd & allocate 8g anon page.
Measure the anon page allocation latency.

$ mkdir /dev/cgroup/memory/B
$ echo 10g >/dev/cgroup/memory/B/memory.limit_in_bytes
$ echo $$ >/dev/cgroup/memory/B/tasks
$ dd if=/dev/zero of=/export/hdc3/dd/tf0 bs=1024 count=20971520 &
$ allocate 8g anon pages

$ echo 1 >/proc/sys/vm/pgfault_histogram

$ cat /dev/cgroup/memory/B/memory.pgfault_histogram
pgfault latency histogram (ns):
< 600            2051273
< 1200           40859
< 2400           4004
< 4800           1605
< 9600           170
< 19200          82
< 38400          6
< inf            0

$ echo reset >/dev/cgroup/memory/B/memory.pgfault_histogram
$ cat /dev/cgroup/memory/B/memory.pgfault_histogram
pgfault latency histogram (ns):
< 600            0
< 1200           0
< 2400           0
< 4800           0
< 9600           0
< 19200          0
< 38400          0
< inf            0

$ echo 500 520 540 580 600 1000 5000 >/dev/cgroup/memory/B/memory.pgfault_histogram
$ cat /dev/cgroup/memory/B/memory.pgfault_histogram
pgfault latency histogram (ns):
< 500            50
< 520            151
< 540            3715
< 580            1859812
< 600            202241
< 1000           25394
< 5000           5875
< inf            186

Performance Test:
I ran through the PageFaultTest (pft) benchmark to measure the overhead of
recording the histogram. There is no overhead observed on both "flt/cpu/s"
and "fault/wsec".

$ mkdir /dev/cgroup/memory/A
$ echo 16g >/dev/cgroup/memory/A/memory.limit_in_bytes
$ echo $$ >/dev/cgroup/memory/A/tasks
$ ./pft -m 15g -t 8 -T a

Result:
"fault/wsec"

$ ./ministat no_histogram histogram
x no_histogram
+ histogram
+--------------------------------------------------------------------------+
   N           Min           Max        Median           Avg        Stddev
x   5     813404.51     824574.98      821661.3     820470.83     4202.0758
+   5     821228.91     825894.66     822874.65     823374.15     1787.9355

"flt/cpu/s"

$ ./ministat no_histogram histogram
x no_histogram
+ histogram
+--------------------------------------------------------------------------+
   N           Min           Max        Median           Avg        Stddev
x   5     104951.93     106173.13     105142.73      105349.2     513.78158
+   5     104697.67      105416.1     104943.52     104973.77     269.24781
No difference proven at 95.0% confidence

Signed-off-by: Ying Han <yinghan@google.com>
---
 arch/x86/mm/fault.c        |    8 +++
 include/linux/memcontrol.h |    8 +++
 kernel/sysctl.c            |    7 +++
 mm/memcontrol.c            |  128 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 151 insertions(+), 0 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 20e3f87..d7a1490 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -12,6 +12,7 @@
 #include <linux/mmiotrace.h>		/* kmmio_handler, ...		*/
 #include <linux/perf_event.h>		/* perf_sw_event		*/
 #include <linux/hugetlb.h>		/* hstate_index_to_shift	*/
+#include <linux/memcontrol.h>
 
 #include <asm/traps.h>			/* dotraplinkage, ...		*/
 #include <asm/pgalloc.h>		/* pgd_*(), ...			*/
@@ -966,6 +967,7 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	int write = error_code & PF_WRITE;
 	unsigned int flags = FAULT_FLAG_ALLOW_RETRY |
 					(write ? FAULT_FLAG_WRITE : 0);
+	unsigned long long start, delta;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1125,6 +1127,7 @@ good_area:
 		return;
 	}
 
+	start = sched_clock();
 	/*
 	 * If for any reason at all we couldn't handle the fault,
 	 * make sure we exit gracefully rather than endlessly redo
@@ -1132,6 +1135,11 @@ good_area:
 	 */
 	fault = handle_mm_fault(mm, vma, address, flags);
 
+	delta = sched_clock() - start;
+	if (unlikely(delta < 0))
+		delta = 0;
+	memcg_histogram_record(current, delta);
+
 	if (unlikely(fault & VM_FAULT_ERROR)) {
 		mm_fault_error(regs, error_code, address, fault);
 		return;
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 29a945a..c7e6cb8 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -92,6 +92,8 @@ struct mem_cgroup *mem_cgroup_get_shrink_target(void);
 void mem_cgroup_put_shrink_target(struct mem_cgroup *mem);
 wait_queue_head_t *mem_cgroup_kswapd_waitq(void);
 
+extern void memcg_histogram_record(struct task_struct *tsk, u64 delta);
+
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
 {
@@ -131,6 +133,8 @@ extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 extern int do_swap_account;
 #endif
 
+extern unsigned int sysctl_pgfault_histogram;
+
 static inline bool mem_cgroup_disabled(void)
 {
 	if (mem_cgroup_subsys.disabled)
@@ -476,6 +480,10 @@ wait_queue_head_t *mem_cgroup_kswapd_waitq(void)
 	return NULL;
 }
 
+static inline
+void memcg_histogram_record(struct task_struct *tsk, u64 delta)
+{
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 927fc5a..0dd2939 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1132,6 +1132,13 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &one,
 		.extra2		= &three,
 	},
+	{
+		.procname	= "pgfault_histogram",
+		.data		= &sysctl_pgfault_histogram,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0666,
+		.proc_handler	= proc_dointvec,
+	},
 #ifdef CONFIG_COMPACTION
 	{
 		.procname	= "compact_memory",
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a98471b..c795f96 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -51,6 +51,7 @@
 #include "internal.h"
 #include <linux/kthread.h>
 #include <linux/freezer.h>
+#include <linux/ctype.h>
 
 #include <asm/uaccess.h>
 
@@ -207,6 +208,13 @@ struct mem_cgroup_eventfd_list {
 static void mem_cgroup_threshold(struct mem_cgroup *mem);
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
+#define MEMCG_NUM_HISTO_BUCKETS		8
+unsigned int sysctl_pgfault_histogram;
+
+struct memcg_histo {
+	u64 count[MEMCG_NUM_HISTO_BUCKETS];
+};
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -299,6 +307,9 @@ struct mem_cgroup {
 	 * last node we reclaimed from
 	 */
 	int last_scanned_node;
+
+	struct memcg_histo *memcg_histo;
+	u64 memcg_histo_range[MEMCG_NUM_HISTO_BUCKETS];
 };
 
 /* Stuffs for move charges at task migration. */
@@ -4692,6 +4703,105 @@ static int __init memcg_kswapd_init(void)
 }
 module_init(memcg_kswapd_init);
 
+static int mem_cgroup_histogram_seq_read(struct cgroup *cgrp,
+					struct cftype *cft, struct seq_file *m)
+{
+	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cgrp);
+	int i, cpu;
+
+	seq_printf(m, "pgfault latency histogram (ns):\n");
+
+	for (i = 0; i < MEMCG_NUM_HISTO_BUCKETS; i++) {
+		u64 sum = 0;
+
+		for_each_present_cpu(cpu) {
+			struct memcg_histo *histo;
+			histo = per_cpu_ptr(mem_cont->memcg_histo, cpu);
+			sum += histo->count[i];
+		}
+
+		if (i < MEMCG_NUM_HISTO_BUCKETS - 1)
+			seq_printf(m, "< %-15llu",
+					mem_cont->memcg_histo_range[i]);
+		else
+			seq_printf(m, "< %-15s", "inf");
+		seq_printf(m, "%llu\n", sum);
+	}
+
+	return 0;
+}
+
+static int mem_cgroup_histogram_seq_write(struct cgroup *cgrp,
+					struct cftype *cft, const char *buffer)
+{
+	int i;
+	u64 data[MEMCG_NUM_HISTO_BUCKETS];
+	char *end;
+	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cgrp);
+
+	if (!memcmp(buffer, "reset", 5)) {
+		for_each_present_cpu(i) {
+			struct memcg_histo *histo;
+
+			histo = per_cpu_ptr(mem_cont->memcg_histo, i);
+			memset(histo, 0, sizeof(*histo));
+		}
+		goto out;
+	}
+
+	for (i = 0; i < MEMCG_NUM_HISTO_BUCKETS - 1; i++, buffer = end) {
+		while ((isspace(*buffer)))
+			buffer++;
+		data[i] = simple_strtoull(buffer, &end, 10);
+	}
+	data[i] = ULLONG_MAX;
+
+	for (i = 1; i < MEMCG_NUM_HISTO_BUCKETS; i++)
+		if (data[i] < data[i - 1])
+			return -EINVAL;
+
+	memcpy(mem_cont->memcg_histo_range, data, sizeof(data));
+	for_each_present_cpu(i) {
+		struct memcg_histo *histo;
+		histo = per_cpu_ptr(mem_cont->memcg_histo, i);
+		memset(histo->count, 0, sizeof(*histo));
+	}
+out:
+	return 0;
+}
+
+/*
+ * Record values into histogram buckets
+ */
+void memcg_histogram_record(struct task_struct *tsk, u64 delta)
+{
+	u64 *base;
+	int index, first, last;
+	struct memcg_histo *histo;
+	struct mem_cgroup *mem = mem_cgroup_from_task(tsk);
+
+	if (sysctl_pgfault_histogram == 0)
+		return;
+
+	first = 0;
+	last = MEMCG_NUM_HISTO_BUCKETS - 1;
+	base = mem->memcg_histo_range;
+
+	if (delta >= base[first]) {
+		while (first < last) {
+			index = (first + last) / 2;
+			if (delta >= base[index])
+				first = index + 1;
+			else
+				last = index;
+		}
+	}
+	index = first;
+
+	histo = per_cpu_ptr(mem->memcg_histo, smp_processor_id());
+	histo->count[index]++;
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4769,6 +4879,12 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "reclaim_wmarks",
 		.read_map = mem_cgroup_wmark_read,
 	},
+	{
+		.name = "pgfault_histogram",
+		.read_seq_string = mem_cgroup_histogram_seq_read,
+		.write_string = mem_cgroup_histogram_seq_write,
+		.max_write_len = 256,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -4903,6 +5019,7 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
 		free_mem_cgroup_per_zone_info(mem, node);
 
 	free_percpu(mem->stat);
+	free_percpu(mem->memcg_histo);
 	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
 		kfree(mem);
 	else
@@ -5014,6 +5131,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	struct mem_cgroup *mem, *parent;
 	long error = -ENOMEM;
 	int node;
+	int i;
 
 	mem = mem_cgroup_alloc();
 	if (!mem)
@@ -5068,6 +5186,16 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mutex_init(&mem->thresholds_lock);
 	init_waitqueue_head(&mem->memcg_kswapd_end);
 	INIT_LIST_HEAD(&mem->memcg_kswapd_wait_list);
+
+	mem->memcg_histo = alloc_percpu(typeof(*mem->memcg_histo));
+	if (!mem->memcg_histo)
+		goto free_out;
+
+
+	for (i = 0; i < MEMCG_NUM_HISTO_BUCKETS - 1; i++)
+		mem->memcg_histo_range[i] = (1 << i) * 600ULL;
+	mem->memcg_histo_range[i] = ULLONG_MAX;
+
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
