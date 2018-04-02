Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0DDB6B0026
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 05:25:03 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id h4so10724354qtj.11
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 02:25:03 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id m10si13719411qke.25.2018.04.02.02.25.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Apr 2018 02:25:01 -0700 (PDT)
From: Buddy Lumpkin <buddy.lumpkin@oracle.com>
Subject: [RFC PATCH 1/1] vmscan: Support multiple kswapd threads per node
Date: Mon,  2 Apr 2018 09:24:22 +0000
Message-Id: <1522661062-39745-2-git-send-email-buddy.lumpkin@oracle.com>
In-Reply-To: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
References: <1522661062-39745-1-git-send-email-buddy.lumpkin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: buddy.lumpkin@oracle.com, hannes@cmpxchg.org, riel@surriel.com, mgorman@suse.de, willy@infradead.org, akpm@linux-foundation.org

Page replacement is handled in the Linux Kernel in one of two ways:

1) Asynchronously via kswapd
2) Synchronously, via direct reclaim

At page allocation time the allocating task is immediately given a page
from the zone free list allowing it to go right back to work doing
whatever it was doing; Probably directly or indirectly executing business
logic.

Just prior to satisfying the allocation, free pages is checked to see if
it has reached the zone low watermark and if so, kswapd is awakened.
Kswapd will start scanning pages looking for inactive pages to evict to
make room for new page allocations. The work of kswapd allows tasks to
continue allocating memory from their respective zone free list without
incurring any delay.

When the demand for free pages exceeds the rate that kswapd tasks can
supply them, page allocation works differently. Once the allocating task
finds that the number of free pages is at or below the zone min watermark,
the task will no longer pull pages from the free list. Instead, the task
will run the same CPU-bound routines as kswapd to satisfy its own
allocation by scanning and evicting pages. This is called a direct reclaim.

The time spent performing a direct reclaim can be substantial, often
taking tens to hundreds of milliseconds for small order0 allocations to
half a second or more for order9 huge-page allocations. In fact, kswapd is
not actually required on a linux system. It exists for the sole purpose of
optimizing performance by preventing direct reclaims.

When memory shortfall is sufficient to trigger direct reclaims, they can
occur in any task that is running on the system. A single aggressive
memory allocating task can set the stage for collateral damage to occur in
small tasks that rarely allocate additional memory. Consider the impact of
injecting an additional 100ms of latency when nscd allocates memory to
facilitate caching of a DNS query.

The presence of direct reclaims 10 years ago was a fairly reliable
indicator that too much was being asked of a Linux system. Kswapd was
likely wasting time scanning pages that were ineligible for eviction.
Adding RAM or reducing the working set size would usually make the problem
go away. Since then hardware has evolved to bring a new struggle for
kswapd. Storage speeds have increased by orders of magnitude while CPU
clock speeds stayed the same or even slowed down in exchange for more
cores per package. This presents a throughput problem for a single
threaded kswapd that will get worse with each generation of new hardware.

Test Details

NOTE: The tests below were run with shadow entries disabled. See the
associated patch and cover letter for details

The tests below were designed with the assumption that a kswapd bottleneck
is best demonstrated using filesystem reads. This way, the inactive list
will be full of clean pages, simplifying the analysis and allowing kswapd
to achieve the highest possible steal rate. Maximum steal rates for kswapd
are likely to be the same or lower for any other mix of page types on the
system.

Tests were run on a 2U Oracle X7-2L with 52 Intel Xeon Skylake 2GHz cores,
756GB of RAM and 8 x 3.6 TB NVMe Solid State Disk drives. Each drive has
an XFS file system mounted separately as /d0 through /d7. SSD drives
require multiple concurrent streams to show their potential, so I created
eleven 250GB zero-filled files on each drive so that I could test with
parallel reads.

The test script runs in multiple stages. At each stage, the number of dd
tasks run concurrently is increased by 2. I did not include all of the
test output for brevity.

During each stage dd tasks are launched to read from each drive in a round
robin fashion until the specified number of tasks for the stage has been
reached. Then iostat, vmstat and top are started in the background with 10
second intervals. After five minutes, all of the dd tasks are killed and
the iostat, vmstat and top output is parsed in order to report the
following:

CPU consumption
- sy - aggregate kernel mode CPU consumption from vmstat output. The value
       doesn't tend to fluctuate much so I just grab the highest value.
       Each sample is averaged over 10 seconds
- dd_cpu - for all of the dd tasks averaged across the top samples since
           there is a lot of variation.

Throughput
- in Kbytes
- Command is iostat -x -d 10 -g total

This first test performs reads using O_DIRECT in order to show the maximum
throughput that can be obtained using these drives. It also demonstrates
how rapidly throughput scales as the number of dd tasks are increased.

The dd command for this test looks like this:

Command Used: dd iflag=direct if=/d${i}/$n of=/dev/null bs=4M

Test #1: Direct IO
dd sy dd_cpu throughput
6  0  2.33   14726026.40
10 1  2.95   19954974.80
16 1  2.63   24419689.30
22 1  2.63   25430303.20
28 1  2.91   26026513.20
34 1  2.53   26178618.00
40 1  2.18   26239229.20
46 1  1.91   26250550.40
52 1  1.69   26251845.60
58 1  1.54   26253205.60
64 1  1.43   26253780.80
70 1  1.31   26254154.80
76 1  1.21   26253660.80
82 1  1.12   26254214.80
88 1  1.07   26253770.00
90 1  1.04   26252406.40

Throughput was close to peak with only 22 dd tasks. Very little system CPU
was consumed as expected as the drives DMA directly into the user address
space when using direct IO.

In this next test, the iflag=direct option is removed and we only run the
test until the pgscan_kswapd from /proc/vmstat starts to increment. At
that point metrics are parsed and reported and the pagecache contents are
dropped prior to the next test. Lather, rinse, repeat.

Test #2: standard file system IO, no page replacement
dd sy dd_cpu throughput
6  2  28.78  5134316.40
10 3  31.40  8051218.40
16 5  34.73  11438106.80
22 7  33.65  14140596.40
28 8  31.24  16393455.20
34 10 29.88  18219463.60
40 11 28.33  19644159.60
46 11 25.05  20802497.60
52 13 26.92  22092370.00
58 13 23.29  22884881.20
64 14 23.12  23452248.80
70 15 22.40  23916468.00
76 16 22.06  24328737.20
82 17 20.97  24718693.20
88 16 18.57  25149404.40
90 16 18.31  25245565.60

Each read has to pause after the buffer in kernel space is populated while
those pages are added to the pagecache and copied into the user address
space. For this reason, more parallel streams are required to achieve peak
throughput. The copy operation consumes substantially more CPU than direct
IO as expected.

The next test measures throughput after kswapd starts running. This is the
same test only we wait for kswapd to wake up before we start collecting
metrics. The script actually keeps track of a few things that were not
mentioned earlier. It tracks direct reclaims and page scans by watching
the metrics in /proc/vmstat. CPU consumption for kswapd is tracked the
same way it is tracked for dd.

Since the test is 100% reads, you can assume that the page steal rate for
kswapd and direct reclaims is almost identical to the scan rate.

Test #3: 1 kswapd thread per node
dd sy dd_cpu kswapd0 kswapd1 throughput  dr    pgscan_kswapd pgscan_direct
10 4  26.07  28.56   27.03   7355924.40  0     459316976     0
16 7  34.94  69.33   69.66   10867895.20 0     872661643     0
22 10 36.03  93.99   99.33   13130613.60 489   1037654473    11268334
28 10 30.34  95.90   98.60   14601509.60 671   1182591373    15429142
34 14 34.77  97.50   99.23   16468012.00 10850 1069005644    249839515
40 17 36.32  91.49   97.11   17335987.60 18903 975417728     434467710
46 19 38.40  90.54   91.61   17705394.40 25369 855737040     582427973
52 22 40.88  83.97   83.70   17607680.40 31250 709532935     724282458
58 25 40.89  82.19   80.14   17976905.60 35060 657796473     804117540
64 28 41.77  73.49   75.20   18001910.00 39073 561813658     895289337
70 33 45.51  63.78   64.39   17061897.20 44523 379465571     1020726436
76 36 46.95  57.96   60.32   16964459.60 47717 291299464     1093172384
82 39 47.16  55.43   56.16   16949956.00 49479 247071062     1134163008
88 42 47.41  53.75   47.62   16930911.20 51521 195449924     1180442208
90 43 47.18  51.40   50.59   16864428.00 51618 190758156     1183203901

In the previous test where kswapd was not involved, the system-wide kernel
mode CPU consumption with 90 dd tasks was 16%. In this test CPU consumption
with 90 tasks is at 43%. With 52 cores, and two kswapd tasks (one per NUMA
node), kswapd can only be responsible for a little over 4% of the increase.
The rest is likely caused by 51,618 direct reclaims that scanned 1.2
billion pages over the five minute time period of the test.

Same test, more kswapd tasks:

Test #4: 4 kswapd threads per node
dd sy dd_cpu kswapd0 kswapd1 throughput  dr    pgscan_kswapd pgscan_direct
10 5  27.09  16.65   14.17   7842605.60  0     459105291     0
16 10 37.12  26.02   24.85   11352920.40 15    920527796     358515
22 11 36.94  37.13   35.82   13771869.60 0     1132169011     0
28 13 35.23  48.43   46.86   16089746.00 0     1312902070     0
34 15 33.37  53.02   55.69   18314856.40 0     1476169080     0
40 19 35.90  69.60   64.41   19836126.80 0     1629999149     0
46 22 36.82  88.55   57.20   20740216.40 0     1708478106     0
52 24 34.38  93.76   68.34   21758352.00 0     1794055559     0
58 24 30.51  79.20   82.33   22735594.00 0     1872794397     0
64 26 30.21  97.12   76.73   23302203.60 176   1916593721     4206821
70 33 32.92  92.91   92.87   23776588.00 3575  1817685086     85574159
76 37 31.62  91.20   89.83   24308196.80 4752  1812262569     113981763
82 29 25.53  93.23   92.33   24802791.20 306   2032093122     7350704
88 43 37.12  76.18   77.01   25145694.40 20310 1253204719     487048202
90 42 38.56  73.90   74.57   22516787.60 22774 1193637495     545463615

By increasing the number of kswapd threads, throughput increased by ~50%
while kernel mode CPU utilization decreased or stayed the same, likely due
to a decrease in the number of parallel tasks at any given time doing page
replacement.

Signed-off-by: Buddy Lumpkin <buddy.lumpkin@oracle.com>
---
 Documentation/sysctl/vm.txt |  23 +++++++++
 include/linux/mm.h          |   2 +
 include/linux/mmzone.h      |  10 +++-
 kernel/sysctl.c             |  10 ++++
 mm/page_alloc.c             |  15 ++++++
 mm/vmscan.c                 | 116 +++++++++++++++++++++++++++++++++++++-------
 6 files changed, 157 insertions(+), 19 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index ff234d229cbb..aa54cbc14dd9 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -31,6 +31,7 @@ Currently, these files are in /proc/sys/vm:
 - drop_caches
 - extfrag_threshold
 - hugetlb_shm_group
+- kswapd_threads
 - laptop_mode
 - legacy_va_layout
 - lowmem_reserve_ratio
@@ -267,6 +268,28 @@ shared memory segment using hugetlb page.
 
 ==============================================================
 
+kswapd_threads
+
+kswapd_threads allows you to control the number of kswapd threads per node
+running on the system. This provides the ability to devote additional CPU
+resources toward proactive page replacement with the goal of reducing
+direct reclaims. When direct reclaims are prevented, the CPU consumed
+by them is prevented as well. Depending on the workload, the result can
+cause aggregate CPU usage on the system to go up, down or stay the same. 
+
+More aggressive page replacement can reduce direct reclaims which cause
+latency for tasks and decrease throughput when doing filesystem IO through
+the pagecache. Direct reclaims are recorded using the allocstall counter
+in /proc/vmstat.
+
+The default value is 1 and the range of acceptible values are 1-16.
+Always start with lower values in the 2-6 range. Higher values should
+be justified with testing. If direct reclaims occur in spite of high
+values, the cost of direct reclaims (in latency) that occur can be
+higher due to increased lock contention.
+
+==============================================================
+
 laptop_mode
 
 laptop_mode is a knob that controls "laptop mode". All the things that are
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42adb1a..e25b8da76f7d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2078,6 +2078,7 @@ static inline void zero_resv_unavail(void) {}
 extern void memmap_init_zone(unsigned long, int, unsigned long, unsigned long,
 		enum memmap_context, struct vmem_altmap *);
 extern void setup_per_zone_wmarks(void);
+extern void update_kswapd_threads(void);
 extern int __meminit init_per_zone_wmark_min(void);
 extern void mem_init(void);
 extern void __init mmap_init(void);
@@ -2098,6 +2099,7 @@ extern __printf(3, 4)
 extern void zone_pcp_reset(struct zone *zone);
 
 /* page_alloc.c */
+extern int kswapd_threads;
 extern int min_free_kbytes;
 extern int watermark_scale_factor;
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7522a6987595..ad36a5b5c3b8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -36,6 +36,8 @@
  */
 #define PAGE_ALLOC_COSTLY_ORDER 3
 
+#define MAX_KSWAPD_THREADS 16
+
 enum migratetype {
 	MIGRATE_UNMOVABLE,
 	MIGRATE_MOVABLE,
@@ -653,8 +655,10 @@ struct zonelist {
 	int node_id;
 	wait_queue_head_t kswapd_wait;
 	wait_queue_head_t pfmemalloc_wait;
-	struct task_struct *kswapd;	/* Protected by
-					   mem_hotplug_begin/end() */
+	/*
+	 * Protected by mem_hotplug_begin/end()
+	 */
+	struct task_struct *kswapd[MAX_KSWAPD_THREADS];
 	int kswapd_order;
 	enum zone_type kswapd_classzone_idx;
 
@@ -882,6 +886,8 @@ static inline int is_highmem(struct zone *zone)
 
 /* These two functions are used to setup the per zone pages min values */
 struct ctl_table;
+int kswapd_threads_sysctl_handler(struct ctl_table *, int,
+					void __user *, size_t *, loff_t *);
 int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index f98f28c12020..3cef65ce1d46 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -134,6 +134,7 @@
 #ifdef CONFIG_PERF_EVENTS
 static int six_hundred_forty_kb = 640 * 1024;
 #endif
+static int max_kswapd_threads = MAX_KSWAPD_THREADS;
 
 /* this is needed for the proc_doulongvec_minmax of vm_dirty_bytes */
 static unsigned long dirty_bytes_min = 2 * PAGE_SIZE;
@@ -1437,6 +1438,15 @@ static int sysrq_sysctl_handler(struct ctl_table *table, int write,
 		.extra1		= &zero,
 	},
 	{
+		.procname	= "kswapd_threads",
+		.data		= &kswapd_threads,
+		.maxlen		= sizeof(kswapd_threads),
+		.mode		= 0644,
+		.proc_handler	= kswapd_threads_sysctl_handler,
+		.extra1		= &one,
+		.extra2		= &max_kswapd_threads,
+	},
+	{
 		.procname	= "watermark_scale_factor",
 		.data		= &watermark_scale_factor,
 		.maxlen		= sizeof(watermark_scale_factor),
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1741dd23e7c1..de30683aeb0f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -7143,6 +7143,21 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *table, int write,
 	return 0;
 }
 
+int kswapd_threads_sysctl_handler(struct ctl_table *table, int write,
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int rc;
+
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (rc)
+		return rc;
+
+	if (write)
+		update_kswapd_threads();
+
+	return 0;
+}
+
 int watermark_scale_factor_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
diff --git a/mm/vmscan.c b/mm/vmscan.c
index cd5dc3faaa57..663ff14080e7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -118,6 +118,14 @@ struct scan_control {
 	unsigned long nr_reclaimed;
 };
 
+
+/*
+ * Number of active kswapd threads
+ */
+#define DEF_KSWAPD_THREADS_PER_NODE 1
+int kswapd_threads = DEF_KSWAPD_THREADS_PER_NODE;
+int kswapd_threads_current = DEF_KSWAPD_THREADS_PER_NODE;
+
 #ifdef ARCH_HAS_PREFETCH
 #define prefetch_prev_lru_page(_page, _base, _field)			\
 	do {								\
@@ -3624,21 +3632,83 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
    restore their cpu bindings. */
 static int kswapd_cpu_online(unsigned int cpu)
 {
-	int nid;
+	int nid, hid;
+	int nr_threads = kswapd_threads_current;
 
 	for_each_node_state(nid, N_MEMORY) {
 		pg_data_t *pgdat = NODE_DATA(nid);
 		const struct cpumask *mask;
 
 		mask = cpumask_of_node(pgdat->node_id);
-
-		if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids)
-			/* One of our CPUs online: restore mask */
-			set_cpus_allowed_ptr(pgdat->kswapd, mask);
+		if (cpumask_any_and(cpu_online_mask, mask) < nr_cpu_ids) {
+			for (hid = 0; hid < nr_threads; hid++) {
+				/* One of our CPUs online: restore mask */
+				set_cpus_allowed_ptr(pgdat->kswapd[hid], mask);
+			}
+		}
 	}
 	return 0;
 }
 
+static void update_kswapd_threads_node(int nid)
+{
+	pg_data_t *pgdat;
+	int drop, increase;
+	int last_idx, start_idx, hid;
+	int nr_threads = kswapd_threads_current;
+
+	pgdat = NODE_DATA(nid);
+	last_idx = nr_threads - 1;
+	if (kswapd_threads < nr_threads) {
+		drop = nr_threads - kswapd_threads;
+		for (hid = last_idx; hid > (last_idx - drop); hid--) {
+			if (pgdat->kswapd[hid]) {
+				kthread_stop(pgdat->kswapd[hid]);
+				pgdat->kswapd[hid] = NULL;
+			}
+		}
+	} else {
+		increase = kswapd_threads - nr_threads;
+		start_idx = last_idx + 1;
+		for (hid = start_idx; hid < (start_idx + increase); hid++) {
+			pgdat->kswapd[hid] = kthread_run(kswapd, pgdat,
+						"kswapd%d:%d", nid, hid);
+			if (IS_ERR(pgdat->kswapd[hid])) {
+				pr_err("Failed to start kswapd%d on node %d\n",
+					hid, nid);
+				pgdat->kswapd[hid] = NULL;
+				/*
+				 * We are out of resources. Do not start any
+				 * more threads.
+				 */
+				break;
+			}
+		}
+	}
+}
+
+void update_kswapd_threads(void)
+{
+	int nid;
+
+	if (kswapd_threads_current == kswapd_threads)
+		return;
+
+	/*
+	 * Hold the memory hotplug lock to avoid racing with memory
+	 * hotplug initiated updates
+	 */
+	mem_hotplug_begin();
+	for_each_node_state(nid, N_MEMORY)
+		update_kswapd_threads_node(nid);
+
+	pr_info("kswapd_thread count changed, old:%d new:%d\n",
+		kswapd_threads_current, kswapd_threads);
+	kswapd_threads_current = kswapd_threads;
+	mem_hotplug_done();
+}
+
+
 /*
  * This kswapd start function will be called by init and node-hot-add.
  * On node-hot-add, kswapd will moved to proper cpus if cpus are hot-added.
@@ -3647,18 +3717,25 @@ int kswapd_run(int nid)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
 	int ret = 0;
+	int hid, nr_threads;
 
-	if (pgdat->kswapd)
+	if (pgdat->kswapd[0])
 		return 0;
 
-	pgdat->kswapd = kthread_run(kswapd, pgdat, "kswapd%d", nid);
-	if (IS_ERR(pgdat->kswapd)) {
-		/* failure at boot is fatal */
-		BUG_ON(system_state < SYSTEM_RUNNING);
-		pr_err("Failed to start kswapd on node %d\n", nid);
-		ret = PTR_ERR(pgdat->kswapd);
-		pgdat->kswapd = NULL;
+	nr_threads = kswapd_threads;
+	for (hid = 0; hid < nr_threads; hid++) {
+		pgdat->kswapd[hid] = kthread_run(kswapd, pgdat, "kswapd%d:%d",
+							nid, hid);
+		if (IS_ERR(pgdat->kswapd[hid])) {
+			/* failure at boot is fatal */
+			BUG_ON(system_state < SYSTEM_RUNNING);
+			pr_err("Failed to start kswapd%d on node %d\n",
+				hid, nid);
+			ret = PTR_ERR(pgdat->kswapd[hid]);
+			pgdat->kswapd[hid] = NULL;
+		}
 	}
+	kswapd_threads_current = nr_threads;
 	return ret;
 }
 
@@ -3668,11 +3745,16 @@ int kswapd_run(int nid)
  */
 void kswapd_stop(int nid)
 {
-	struct task_struct *kswapd = NODE_DATA(nid)->kswapd;
+	struct task_struct *kswapd;
+	int hid;
+	int nr_threads = kswapd_threads_current;
 
-	if (kswapd) {
-		kthread_stop(kswapd);
-		NODE_DATA(nid)->kswapd = NULL;
+	for (hid = 0; hid < nr_threads; hid++) {
+		kswapd = NODE_DATA(nid)->kswapd[hid];
+		if (kswapd) {
+			kthread_stop(kswapd);
+			NODE_DATA(nid)->kswapd[hid] = NULL;
+		}
 	}
 }
 
-- 
1.8.3.1
