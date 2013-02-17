Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 67BF76B0002
	for <linux-mm@kvack.org>; Sun, 17 Feb 2013 18:48:33 -0500 (EST)
Date: Sun, 17 Feb 2013 15:48:31 -0800 (PST)
From: dormando <dormando@rydia.net>
Subject: [PATCH] add extra free kbytes tunable
In-Reply-To: <511EB5CB.2060602@redhat.com>
Message-ID: <alpine.DEB.2.02.1302171546120.10836@dflat>
References: <alpine.DEB.2.02.1302111734090.13090@dflat> <A5ED84D3BB3A384992CBB9C77DEDA4D414A98EBF@USINDEM103.corp.hds.com> <511EB5CB.2060602@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Seiji Aguchi <seiji.aguchi@hds.com>, Satoru Moriya <satoru.moriya@hds.com>, Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hughd@google.com" <hughd@google.com>

From: Rik van Riel <riel@redhat.com>

Add a userspace visible knob to tell the VM to keep an extra amount
of memory free, by increasing the gap between each zone's min and
low watermarks.

This is useful for realtime applications that call system
calls and have a bound on the number of allocations that happen
in any short time period.  In this application, extra_free_kbytes
would be left at an amount equal to or larger than than the
maximum number of allocations that happen in any burst.

It may also be useful to reduce the memory use of virtual
machines (temporarily?), in a way that does not cause memory
fragmentation like ballooning does.
---
 Documentation/sysctl/vm.txt |   16 ++++++++++++++++
 include/linux/mmzone.h      |    2 +-
 include/linux/swap.h        |    2 ++
 kernel/sysctl.c             |   11 +++++++++--
 mm/page_alloc.c             |   39 +++++++++++++++++++++++++++++----------
 5 files changed, 57 insertions(+), 13 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 078701f..5d12bbd 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -28,6 +28,7 @@ Currently, these files are in /proc/sys/vm:
 - dirty_writeback_centisecs
 - drop_caches
 - extfrag_threshold
+- extra_free_kbytes
 - hugepages_treat_as_movable
 - hugetlb_shm_group
 - laptop_mode
@@ -167,6 +168,21 @@ fragmentation index is <= extfrag_threshold. The default value is 500.

 ==============================================================

+extra_free_kbytes
+
+This parameter tells the VM to keep extra free memory between the threshold
+where background reclaim (kswapd) kicks in, and the threshold where direct
+reclaim (by allocating processes) kicks in.
+
+This is useful for workloads that require low latency memory allocations
+and have a bounded burstiness in memory allocations, for example a
+realtime application that receives and transmits network traffic
+(causing in-kernel memory allocations) with a maximum total message burst
+size of 200MB may need 200MB of extra free memory to avoid direct reclaim
+related latencies.
+
+==============================================================
+
 hugepages_treat_as_movable

 This parameter is only useful when kernelcore= is specified at boot time to
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 73b64a3..7f8f883 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -881,7 +881,7 @@ static inline int is_dma(struct zone *zone)

 /* These two functions are used to setup the per zone pages min values */
 struct ctl_table;
-int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
+int free_kbytes_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 68df9c1..66a12c4 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -215,6 +215,8 @@ struct swap_list_t {
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
+extern int min_free_kbytes;
+extern int extra_free_kbytes;
 extern unsigned long dirty_balance_reserve;
 extern unsigned int nr_free_buffer_pages(void);
 extern unsigned int nr_free_pagecache_pages(void);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c88878d..102e9a1 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -104,7 +104,6 @@ extern char core_pattern[];
 extern unsigned int core_pipe_limit;
 #endif
 extern int pid_max;
-extern int min_free_kbytes;
 extern int pid_max_min, pid_max_max;
 extern int sysctl_drop_caches;
 extern int percpu_pagelist_fraction;
@@ -1246,10 +1245,18 @@ static struct ctl_table vm_table[] = {
 		.data		= &min_free_kbytes,
 		.maxlen		= sizeof(min_free_kbytes),
 		.mode		= 0644,
-		.proc_handler	= min_free_kbytes_sysctl_handler,
+		.proc_handler	= free_kbytes_sysctl_handler,
 		.extra1		= &zero,
 	},
 	{
+		.procname   = "extra_free_kbytes",
+		.data       = &extra_free_kbytes,
+		.maxlen     = sizeof(extra_free_kbytes),
+		.mode       = 0644,
+		.proc_handler   = free_kbytes_sysctl_handler,
+		.extra1     = &zero,
+	},
+	{
 		.procname	= "percpu_pagelist_fraction",
 		.data		= &percpu_pagelist_fraction,
 		.maxlen		= sizeof(percpu_pagelist_fraction),
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9673d96..5380d84 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -194,8 +194,21 @@ static char * const zone_names[MAX_NR_ZONES] = {
 	 "Movable",
 };

+/*
+ * Try to keep at least this much lowmem free.  Do not allow normal
+ * allocations below this point, only high priority ones. Automatically
+ * tuned according to the amount of memory in the system.
+ */
 int min_free_kbytes = 1024;

+/*
+ * Extra memory for the system to try freeing between the min and
+ * low watermarks.  Useful for workloads that require low latency
+ * memory allocations in bursts larger than the normal gap between
+ * low and min.
+ */
+int extra_free_kbytes;
+
 static unsigned long __meminitdata nr_kernel_pages;
 static unsigned long __meminitdata nr_all_pages;
 static unsigned long __meminitdata dma_reserve;
@@ -5217,6 +5230,7 @@ static void setup_per_zone_lowmem_reserve(void)
 static void __setup_per_zone_wmarks(void)
 {
 	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned long pages_low = extra_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
 	unsigned long flags;
@@ -5228,11 +5242,14 @@ static void __setup_per_zone_wmarks(void)
 	}

 	for_each_zone(zone) {
-		u64 tmp;
+		u64 min, low;

 		spin_lock_irqsave(&zone->lock, flags);
-		tmp = (u64)pages_min * zone->present_pages;
-		do_div(tmp, lowmem_pages);
+		min = (u64)pages_min * zone->present_pages;
+		do_div(min, lowmem_pages);
+		low = (u64)pages_low * zone->present_pages;
+		do_div(low, vm_total_pages);
+
 		if (is_highmem(zone)) {
 			/*
 			 * __GFP_HIGH and PF_MEMALLOC allocations usually don't
@@ -5256,11 +5273,13 @@ static void __setup_per_zone_wmarks(void)
 			 * If it's a lowmem zone, reserve a number of pages
 			 * proportionate to the zone's size.
 			 */
-			zone->watermark[WMARK_MIN] = tmp;
+			zone->watermark[WMARK_MIN] = min;
 		}

-		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
-		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
+		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) +
+					low + (min >> 2);
+		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) +
+					low + (min >> 1);

 		setup_zone_migrate_reserve(zone);
 		spin_unlock_irqrestore(&zone->lock, flags);
@@ -5371,11 +5390,11 @@ int __meminit init_per_zone_wmark_min(void)
 module_init(init_per_zone_wmark_min)

 /*
- * min_free_kbytes_sysctl_handler - just a wrapper around proc_dointvec() so
- *	that we can call two helper functions whenever min_free_kbytes
- *	changes.
+ * free_kbytes_sysctl_handler - just a wrapper around proc_dointvec() so
+ * that we can call two helper functions whenever min_free_kbytes
+ * or extra_free_kbytes changes.
  */
-int min_free_kbytes_sysctl_handler(ctl_table *table, int write,
+int free_kbytes_sysctl_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	proc_dointvec(table, write, buffer, length, ppos);
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
