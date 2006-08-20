Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k7K4Qmgh023325
	for <linux-mm@kvack.org>; Sat, 19 Aug 2006 21:26:48 -0700
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k7K1tP8s31241714
	for <linux-mm@kvack.org>; Sat, 19 Aug 2006 18:55:25 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k7K1tPnB52420764
	for <linux-mm@kvack.org>; Sat, 19 Aug 2006 18:55:25 -0700 (PDT)
Received: from christoph (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1GEcX7-0001b6-00
	for <linux-mm@kvack.org>; Sat, 19 Aug 2006 18:55:25 -0700
Date: Sat, 19 Aug 2006 18:54:38 -0700 (PDT)
From: Christoph Lameter <christoph@engr.sgi.com>
Subject: ZVC: Scale thresholds depending on the size of the system
Message-ID: <Pine.LNX.4.64.0608191853150.6123@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.64.0608191855170.6143@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: ak@suse.de, linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The ZVC counter update threshold is currently set to a fixed
value of 32. This patch sets up the threshold depending on the
number of processors and the sizes of the zones in the system.

With the current threshold of 32, I was able to observe slight
contention when more than 130-140 processors concurrently updated the
counters. The contention vanished when I either increased the threshold
to 64 or used Andrew's idea of overstepping the interval (see
ZVC overstep patch).

However, we saw contention again at 220-230 processors. So we need
higher values for larger systems.

But the current default is already a bit of an overkill for smaller systems.
Some systems have tiny zones where precision matters. For example i386
and x86_64 have 16M DMA zones and either 900M ZONE_NORMAL or ZONE_DMA32.
These are even present on SMP and NUMA systems.

The patch here sets up a threshold based on the number of processors
in the system and the size of the zone that these counters are used
for. The threshold should grow logarithmically, so we use fls() as
an easy approximation.

Results of tests on a system with 1024 processors (4TB RAM)

The following output is from a test allocating 1GB of memory concurrently
on each processor (Forking the process. So contention on mmap_sem
and the pte locks is not a factor):

                       X                   MIN
TYPE:               CPUS       WALL       WALL        SYS     USER     TOTCPU
fork                   1      0.552      0.552      0.540    0.012      0.552
fork                   4      0.552      0.548      2.164    0.036      2.200
fork                  16      0.564      0.548      8.812    0.164      8.976
fork                 128      0.580      0.572     72.204    1.208     73.412
fork                 256      1.300      0.660    310.400    2.160    312.560
fork                 512      3.512      0.696   1526.836    4.816   1531.652
fork                1020     20.024      0.700  17243.176    6.688  17249.863

So a threshold of 32 is fine up to 128 processors. At 256 processors contention
becomes a factor.

Overstepping the counter (earlier patch) improves the numbers a bit:

fork                   4      0.552      0.548      2.164    0.040      2.204
fork                  16      0.552      0.548      8.640    0.148      8.788
fork                 128      0.556      0.548     69.676    0.956     70.632
fork                 256      0.876      0.636    212.468    2.108    214.576
fork                 512      2.276      0.672    997.324    4.260   1001.584
fork                1020     13.564      0.680  11586.436    6.088  11592.523

Still contention at 512 and 1020. Contention at 1020 is down by a third.
256 still has a slight bit of contention.

After this patch the counter threshold will be set to 125 which reduces
contention significantly:

fork                 128      0.560      0.548     69.776    0.932     70.708
fork                 256      0.636      0.556    143.460    2.036    145.496
fork                 512      0.640      0.548    284.244    4.236    288.480
fork                1020      1.500      0.588   1326.152    8.892   1335.044

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4/mm/vmstat.c
===================================================================
--- linux-2.6.18-rc4.orig/mm/vmstat.c	2006-08-19 15:17:36.971128823 -0700
+++ linux-2.6.18-rc4/mm/vmstat.c	2006-08-19 18:40:23.561249684 -0700
@@ -12,6 +12,7 @@
 #include <linux/config.h>
 #include <linux/mm.h>
 #include <linux/module.h>
+#include <linux/cpu.h>
 
 void __get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free, struct pglist_data *pgdat)
@@ -114,17 +115,72 @@ EXPORT_SYMBOL(vm_stat);
 
 #ifdef CONFIG_SMP
 
-#define STAT_THRESHOLD 32
+static int calculate_threshold(struct zone *zone)
+{
+	int threshold;
+	int mem;	/* memory in 128 MB units */
+
+	/*
+	 * The threshold scales with the number of processors and the amount
+	 * of memory per zone. More memory means that we can defer updates for
+	 * longer, more processors could lead to more contention.
+ 	 * fls() is used to have a cheap way of logarithmic scaling.
+	 *
+	 * Some sample thresholds:
+	 *
+	 * Threshold	Processors	(fls)	Zonesize	fls(mem+1)
+	 * ------------------------------------------------------------------
+	 * 8		1		1	0.9-1 GB	4
+	 * 16		2		2	0.9-1 GB	4
+	 * 20 		2		2	1-2 GB		5
+	 * 24		2		2	2-4 GB		6
+	 * 28		2		2	4-8 GB		7
+	 * 32		2		2	8-16 GB		8
+	 * 4		2		2	<128M		1
+	 * 30		4		3	2-4 GB		5
+	 * 48		4		3	8-16 GB		8
+	 * 32		8		4	1-2 GB		4
+	 * 32		8		4	0.9-1GB		4
+	 * 10		16		5	<128M		1
+	 * 40		16		5	900M		4
+	 * 70		64		7	2-4 GB		5
+	 * 84		64		7	4-8 GB		6
+	 * 108		512		9	4-8 GB		6
+	 * 125		1024		10	8-16 GB		8
+	 * 125		1024		10	16-32 GB	9
+	 */
+
+	mem = zone->present_pages >> (27 - PAGE_SHIFT);
+
+	threshold = 2 * fls(num_online_cpus()) * (1 + fls(mem));
+
+	/*
+	 * Maximum threshold is 125
+	 */
+	threshold = min(125, threshold);
+
+	return threshold;
+}
 
 /*
- * Determine pointer to currently valid differential byte given a zone and
- * the item number.
- *
- * Preemption must be off
+ * Refresh the thresholds for each zone.
  */
-static inline s8 *diff_pointer(struct zone *zone, enum zone_stat_item item)
+static void refresh_zone_stat_thresholds(void)
 {
-	return &zone_pcp(zone, smp_processor_id())->vm_stat_diff[item];
+	struct zone *zone;
+	int cpu;
+	int threshold;
+
+	for_each_zone(zone) {
+
+		if (!zone->present_pages)
+			continue;
+
+		threshold = calculate_threshold(zone);
+
+		for_each_online_cpu(cpu)
+			zone_pcp(zone, cpu)->stat_threshold = threshold;
+	}
 }
 
 /*
@@ -133,17 +189,16 @@ static inline s8 *diff_pointer(struct zo
 void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 				int delta)
 {
-	s8 *p;
+	struct per_cpu_pageset *pcp = zone_pcp(zone, smp_processor_id());
+	s8 *p = pcp->vm_stat_diff + item;
 	long x;
 
-	p = diff_pointer(zone, item);
 	x = delta + *p;
 
-	if (unlikely(x > STAT_THRESHOLD || x < -STAT_THRESHOLD)) {
+	if (unlikely(x > pcp->stat_threshold || x < -pcp->stat_threshold)) {
 		zone_page_state_add(x, zone, item);
 		x = 0;
 	}
-
 	*p = x;
 }
 EXPORT_SYMBOL(__mod_zone_page_state);
@@ -172,26 +227,31 @@ EXPORT_SYMBOL(mod_zone_page_state);
  * No overflow check is necessary and therefore the differential can be
  * incremented or decremented in place which may allow the compilers to
  * generate better code.
- *
  * The increment or decrement is known and therefore one boundary check can
  * be omitted.
  *
+ * NOTE: These functions are very performance sensitive. Change only
+ * with care.
+ *
  * Some processors have inc/dec instructions that are atomic vs an interrupt.
  * However, the code must first determine the differential location in a zone
  * based on the processor number and then inc/dec the counter. There is no
  * guarantee without disabling preemption that the processor will not change
- * in between and therefore the atomicity vs. interrupt cannot be exploited
+ * in between and therefore the atomicity vs. interrupt cannot be exploited
  * in a useful way here.
  */
 static void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 {
-	s8 *p = diff_pointer(zone, item);
+	struct per_cpu_pageset *pcp = zone_pcp(zone, smp_processor_id());
+	s8 *p = pcp->vm_stat_diff + item;
 
 	(*p)++;
 
-	if (unlikely(*p > STAT_THRESHOLD)) {
-		zone_page_state_add(*p + STAT_THRESHOLD / 2, zone, item);
-		*p = -STAT_THRESHOLD / 2;
+	if (unlikely(*p > pcp->stat_threshold)) {
+		int overstep = pcp->stat_threshold / 2;
+
+		zone_page_state_add(*p + overstep, zone, item);
+		*p = -overstep;
 	}
 }
 
@@ -204,13 +264,16 @@ EXPORT_SYMBOL(__inc_zone_page_state);
 void __dec_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	struct zone *zone = page_zone(page);
-	s8 *p = diff_pointer(zone, item);
+	struct per_cpu_pageset *pcp = zone_pcp(zone, smp_processor_id());
+	s8 *p = pcp->vm_stat_diff + item;
 
 	(*p)--;
 
-	if (unlikely(*p < -STAT_THRESHOLD)) {
-		zone_page_state_add(*p - STAT_THRESHOLD / 2, zone, item);
-		*p = STAT_THRESHOLD /2;
+	if (unlikely(*p < - pcp->stat_threshold)) {
+		int overstep = pcp->stat_threshold / 2;
+
+		zone_page_state_add(*p - overstep, zone, item);
+		*p = overstep;
 	}
 }
 EXPORT_SYMBOL(__dec_zone_page_state);
@@ -515,6 +579,8 @@ static int zoneinfo_show(struct seq_file
 					   pageset->pcp[j].high,
 					   pageset->pcp[j].batch);
 			}
+			seq_printf(m, "\n  vm stats threshold: %d\n",
+					pageset->stat_threshold);
 		}
 		seq_printf(m,
 			   "\n  all_unreclaimable: %u"
@@ -603,3 +669,34 @@ struct seq_operations vmstat_op = {
 
 #endif /* CONFIG_PROC_FS */
 
+/*
+ * Use the cpu notifier to insure that the thresholds are recalculated
+ * when necessary.
+ */
+static int __cpuinit vmstat_cpuup_callback(struct notifier_block *nfb,
+		unsigned long action,
+		void *hcpu)
+{
+	switch (action) {
+		case CPU_UP_PREPARE:
+		case CPU_UP_CANCELED:
+		case CPU_DEAD:
+			refresh_zone_stat_thresholds();
+			break;
+		default:
+			break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block __cpuinitdata vmstat_notifier =
+	{ &vmstat_cpuup_callback, NULL, 0 };
+
+int __init setup_vmstat(void)
+{
+	refresh_zone_stat_thresholds();
+	register_cpu_notifier(&vmstat_notifier);
+	return 0;
+}
+module_init(setup_vmstat)
+
Index: linux-2.6.18-rc4/include/linux/mmzone.h
===================================================================
--- linux-2.6.18-rc4.orig/include/linux/mmzone.h	2006-08-06 11:20:11.000000000 -0700
+++ linux-2.6.18-rc4/include/linux/mmzone.h	2006-08-19 18:40:23.563202688 -0700
@@ -77,6 +77,7 @@ struct per_cpu_pages {
 struct per_cpu_pageset {
 	struct per_cpu_pages pcp[2];	/* 0: hot.  1: cold */
 #ifdef CONFIG_SMP
+	s8 stat_threshold;
 	s8 vm_stat_diff[NR_VM_ZONE_STAT_ITEMS];
 #endif
 } ____cacheline_aligned_in_smp;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
