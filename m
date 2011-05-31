Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 505896B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:23:38 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2] memcg: add reclaim pgfault latency histograms
Date: Tue, 31 May 2011 10:07:13 -0700
Message-Id: <1306861633-11085-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This adds histogram to capture pagefault latencies on per-memcg basis. I used
this patch on the memcg background reclaim test, and figured there could be more
usecases to monitor/debug application performance.

The histogram is composed 8 bucket in us unit. The last one is "rest" which is
everything beyond the last one. To be more flexible, the buckets can be reset
and also each bucket is configurable at runtime.

memory.pgfault_histogram: exports the histogram on per-memcg basis and also can
be reset by echoing "-1". Meantime, all the buckets are writable by echoing
the range into the API. see the example below.

change v2..v1:
1. record the page fault involving reclaim only and changing the unit to us.
2. rename the "inf" to "rest".
3. removed the global tunable to turn on/off the recording. this is ok since
there is no overhead measured by collecting the data.
4. changed reseting the history by echoing "-1".

Functional Test:
Create a memcg with 10g hard_limit, running dd & allocate 8g anon page.
Measure the anon page allocation latency.

$ mkdir /dev/cgroup/memory/D
$ echo 4g >/dev/cgroup/memory/D/memory.limit_in_bytes
$ echo $$ >/dev/cgroup/memory/D/tasks
$ cat /export/hdc3/dd_A/tf0 > /dev/zero
$ cat /dev/cgroup/memory/B/memory.pgfault_histogram
page reclaim latency histogram (us):
< 150            0
< 200            7
< 250            5245
< 300            10949
< 350            238
< 400            10
< 450            0
< rest           0

$ dd if=/dev/zero of=/export/hdc3/dd/tf0 bs=1024 count=20971520
page reclaim latency histogram (us):
< 150            1
< 200            62
< 250            2209
< 300            16574
< 350            2299
< 400            246
< 450            30
< rest           0

$ echo -1 >/dev/cgroup/memory/B/memory.pgfault_histogram
$ cat /dev/cgroup/memory/B/memory.pgfault_histogram
page reclaim latency histogram (us):
< 150            0
< 200            0
< 250            0
< 300            0
< 350            0
< 400            0
< 450            0
< rest           0

$ echo 500 520 540 580 600 1000 5000 >/dev/cgroup/memory/B/memory.pgfault_histogram
$ cat /dev/cgroup/memory/B/memory.pgfault_histogram
page reclaim latency histogram (us):
< 500            0
< 520            0
< 540            0
< 580            0
< 600            0
< 1000           0
< 5000           0
< rest           0

Performance Test:
I ran through the PageFaultTest (pft) benchmark to measure the overhead of
recording the histogram. There is no overhead observed on both "flt/cpu/s"
and "fault/wsec".

$ mkdir /dev/cgroup/memory/A
$ echo 16g >/dev/cgroup/memory/A/memory.limit_in_bytes
$ echo $$ >/dev/cgroup/memory/A/tasks
$ ./pft -m 15g -t 8 -T a

Result:
$ ./ministat no_histogram histogram

"fault/wsec"
x fault_wsec/no_histogram
+ fault_wsec/histogram
+-------------------------------------------------------------------------+
    N           Min           Max        Median           Avg        Stddev
x   5     813404.51     824574.98      821661.3     820470.83     4202.0758
+   5     824996.59     827958.08     825595.21     826228.87     1432.8493
Difference at 95.0% confidence

"flt/cpu/s"
x flt_cpu_s/no_histogram
+ flt_cpu_s/histogram
+-------------------------------------------------------------------------+
    N           Min           Max        Median           Avg        Stddev
x   5     104951.93     106173.13     105142.73      105349.2     513.78158
+   5     105353.97     105537.75     105472.65     105451.19     68.748103
No difference proven at 95.0% confidence

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    6 ++
 mm/memcontrol.c            |  130 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 136 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 29a945a..8f909b7 100644
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
@@ -476,6 +478,10 @@ wait_queue_head_t *mem_cgroup_kswapd_waitq(void)
 	return NULL;
 }
 
+static inline
+void memcg_histogram_record(struct task_struct *tsk, u64 delta)
+{
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a98471b..90ec5c0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -51,6 +51,7 @@
 #include "internal.h"
 #include <linux/kthread.h>
 #include <linux/freezer.h>
+#include <linux/ctype.h>
 
 #include <asm/uaccess.h>
 
@@ -207,6 +208,12 @@ struct mem_cgroup_eventfd_list {
 static void mem_cgroup_threshold(struct mem_cgroup *mem);
 static void mem_cgroup_oom_notify(struct mem_cgroup *mem);
 
+#define MEMCG_NUM_HISTO_BUCKETS		8
+
+struct memcg_histo {
+	u64 count[MEMCG_NUM_HISTO_BUCKETS];
+};
+
 /*
  * The memory controller data structure. The memory controller controls both
  * page cache and RSS per cgroup. We would eventually like to provide
@@ -299,6 +306,9 @@ struct mem_cgroup {
 	 * last node we reclaimed from
 	 */
 	int last_scanned_node;
+
+	struct memcg_histo *memcg_histo;
+	u64 memcg_histo_range[MEMCG_NUM_HISTO_BUCKETS];
 };
 
 /* Stuffs for move charges at task migration. */
@@ -2096,6 +2106,7 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 	struct mem_cgroup *mem_over_limit;
 	struct res_counter *fail_res;
 	unsigned long flags = 0;
+	unsigned long long start, delta;
 	int ret;
 
 	ret = res_counter_charge(&mem->res, csize, &fail_res);
@@ -2125,8 +2136,14 @@ static int mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 	if (!(gfp_mask & __GFP_WAIT))
 		return CHARGE_WOULDBLOCK;
 
+	start = sched_clock();
 	ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, NULL,
 					      gfp_mask, flags);
+	delta = sched_clock() - start;
+	if (unlikely(delta < 0))
+		delta = 0;
+	memcg_histogram_record(current, delta);
+
 	if (mem_cgroup_margin(mem_over_limit) >= nr_pages)
 		return CHARGE_RETRY;
 	/*
@@ -4692,6 +4709,102 @@ static int __init memcg_kswapd_init(void)
 }
 module_init(memcg_kswapd_init);
 
+static int mem_cgroup_histogram_seq_read(struct cgroup *cgrp,
+					struct cftype *cft, struct seq_file *m)
+{
+	struct mem_cgroup *mem_cont = mem_cgroup_from_cont(cgrp);
+	int i, cpu;
+
+	seq_printf(m, "page reclaim latency histogram (us):\n");
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
+					mem_cont->memcg_histo_range[i] / 1000);
+		else
+			seq_printf(m, "< %-15s", "rest");
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
+	if (simple_strtol(buffer, &end, 10) == -1) {
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
+		data[i] = simple_strtoull(buffer, &end, 10) * 1000;
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
@@ -4769,6 +4882,12 @@ static struct cftype mem_cgroup_files[] = {
 		.name = "reclaim_wmarks",
 		.read_map = mem_cgroup_wmark_read,
 	},
+	{
+		.name = "pgfault_histogram",
+		.read_seq_string = mem_cgroup_histogram_seq_read,
+		.write_string = mem_cgroup_histogram_seq_write,
+		.max_write_len = 21 * MEMCG_NUM_HISTO_BUCKETS,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
@@ -4903,6 +5022,7 @@ static void __mem_cgroup_free(struct mem_cgroup *mem)
 		free_mem_cgroup_per_zone_info(mem, node);
 
 	free_percpu(mem->stat);
+	free_percpu(mem->memcg_histo);
 	if (sizeof(struct mem_cgroup) < PAGE_SIZE)
 		kfree(mem);
 	else
@@ -5014,6 +5134,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	struct mem_cgroup *mem, *parent;
 	long error = -ENOMEM;
 	int node;
+	int i;
 
 	mem = mem_cgroup_alloc();
 	if (!mem)
@@ -5068,6 +5189,15 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 	mutex_init(&mem->thresholds_lock);
 	init_waitqueue_head(&mem->memcg_kswapd_end);
 	INIT_LIST_HEAD(&mem->memcg_kswapd_wait_list);
+
+	mem->memcg_histo = alloc_percpu(typeof(*mem->memcg_histo));
+	if (!mem->memcg_histo)
+		goto free_out;
+
+	for (i = 0; i < MEMCG_NUM_HISTO_BUCKETS - 1; i++)
+		mem->memcg_histo_range[i] = (i + 3) * 50000ULL;
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
