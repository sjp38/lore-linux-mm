Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 54E216B00EE
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 15:27:11 -0400 (EDT)
Date: Thu, 1 Sep 2011 15:26:50 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <20110901152650.7a63cb8b@annuminas.surriel.com>
In-Reply-To: <20110901100650.6d884589.rdunlap@xenotime.net>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Satoru Moriya <smoriya@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, Seiji Aguchi <saguchi@redhat.com>, akpm@linux-foundation.org, hughd@google.com, hannes@cmpxchg.org

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

Signed-off-by: Rik van Riel<riel@redhat.com>

---
 Documentation/sysctl/vm.txt |   16 ++++++++++++++++
 kernel/sysctl.c             |    9 +++++++++
 mm/page_alloc.c             |   32 +++++++++++++++++++++++++-------
 3 files changed, 50 insertions(+), 7 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 96f0ee8..9c11d97 100644
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
@@ -168,6 +169,21 @@ fragmentation index is <= extfrag_threshold. The default value is 500.
 
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
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 11d65b5..01a9acd 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -96,6 +96,7 @@ extern char core_pattern[];
 extern unsigned int core_pipe_limit;
 extern int pid_max;
 extern int min_free_kbytes;
+extern int extra_free_kbytes;
 extern int pid_max_min, pid_max_max;
 extern int sysctl_drop_caches;
 extern int percpu_pagelist_fraction;
@@ -1189,6 +1190,14 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 	},
 	{
+		.procname	= "extra_free_kbytes",
+		.data		= &extra_free_kbytes,
+		.maxlen		= sizeof(extra_free_kbytes),
+		.mode		= 0644,
+		.proc_handler	= min_free_kbytes_sysctl_handler,
+		.extra1		= &zero,
+	},
+	{
 		.procname	= "percpu_pagelist_fraction",
 		.data		= &percpu_pagelist_fraction,
 		.maxlen		= sizeof(percpu_pagelist_fraction),
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e8ecb6..47d185c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -175,8 +175,20 @@ static char * const zone_names[MAX_NR_ZONES] = {
 	 "Movable",
 };
 
+/*
+ * Try to keep at least this much lowmem free.  Do not allow normal
+ * allocations below this point, only high priority ones. Automatically
+ * tuned according to the amount of memory in the system.
+ */
 int min_free_kbytes = 1024;
 
+/*
+ * Extra memory for the system to try freeing. Used to temporarily
+ * free memory, to make space for new workloads. Anyone can allocate
+ * down to the min watermarks controlled by min_free_kbytes above.
+ */
+int extra_free_kbytes = 0;
+
 static unsigned long __meminitdata nr_kernel_pages;
 static unsigned long __meminitdata nr_all_pages;
 static unsigned long __meminitdata dma_reserve;
@@ -5123,6 +5135,7 @@ static void setup_per_zone_lowmem_reserve(void)
 void setup_per_zone_wmarks(void)
 {
 	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned long pages_low = extra_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
 	unsigned long flags;
@@ -5134,11 +5147,14 @@ void setup_per_zone_wmarks(void)
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
@@ -5162,11 +5178,13 @@ void setup_per_zone_wmarks(void)
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
 	}
@@ -5264,7 +5282,7 @@ module_init(init_per_zone_wmark_min)
 /*
  * min_free_kbytes_sysctl_handler - just a wrapper around proc_dointvec() so 
  *	that we can call two helper functions whenever min_free_kbytes
- *	changes.
+ *	or extra_free_kbytes changes.
  */
 int min_free_kbytes_sysctl_handler(ctl_table *table, int write, 
 	void __user *buffer, size_t *length, loff_t *ppos)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
