Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2E8896B0023
	for <linux-mm@kvack.org>; Mon,  2 May 2011 21:24:39 -0400 (EDT)
Date: Mon, 2 May 2011 21:24:27 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH -mm] add extra free kbytes tunable
Message-ID: <20110502212427.42b5a90f@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: linux-mm@kvack.org, Ying Han <yinghan@google.com>, Mel Gorman <mel@suse.de>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Add a userspace visible knob to tell the VM to keep an extra amount
of memory free, by increasing the gap between each zone's min and
low watermarks.

This can be used to make the VM free up memory, for when an extra
workload is to be added to a system, or to temporarily reduce the
memory use of a virtual machine. In this application, extra_free_kbytes
would be raised temporarily and reduced again later.  The workload
management system could also monitor the current workloads with
reduced memory, to verify that there really is memory space for
an additional workload, before starting it.

It may also be useful for realtime applications that call system
calls and have a bound on the number of allocations that happen
in any short time period.  In this application, extra_free_kbytes
would be left at an amount equal to or larger than than the
maximum number of allocations that happen in any burst.

I realize nobody really likes this solution to their particular
issue, but it is hard to deny the simplicity - especially
considering that this one knob could solve three different issues
and is fairly simple to understand.

Signed-off-by: Rik van Riel<riel@redhat.com>

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c0bb324..feecc1a 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -95,6 +95,7 @@ extern char core_pattern[];
 extern unsigned int core_pipe_limit;
 extern int pid_max;
 extern int min_free_kbytes;
+extern int extra_free_kbytes;
 extern int pid_max_min, pid_max_max;
 extern int sysctl_drop_caches;
 extern int percpu_pagelist_fraction;
@@ -1173,6 +1174,14 @@ static struct ctl_table vm_table[] = {
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
index 9f8a97b..b85dcb1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -172,8 +172,20 @@ static char * const zone_names[MAX_NR_ZONES] = {
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
@@ -4999,6 +5011,7 @@ static void setup_per_zone_lowmem_reserve(void)
 void setup_per_zone_wmarks(void)
 {
 	unsigned long pages_min = min_free_kbytes >> (PAGE_SHIFT - 10);
+	unsigned long pages_low = extra_free_kbytes >> (PAGE_SHIFT - 10);
 	unsigned long lowmem_pages = 0;
 	struct zone *zone;
 	unsigned long flags;
@@ -5010,11 +5023,14 @@ void setup_per_zone_wmarks(void)
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
@@ -5038,11 +5054,13 @@ void setup_per_zone_wmarks(void)
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
@@ -5139,7 +5157,7 @@ module_init(init_per_zone_wmark_min)
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
