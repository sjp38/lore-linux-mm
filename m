Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD58828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 11:42:10 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id a4so34001305wme.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 08:42:10 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ee2si11485842wjd.88.2016.02.18.08.42.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 08:42:08 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH] mm: scale kswapd watermarks in proportion to memory
Date: Thu, 18 Feb 2016 11:41:59 -0500
Message-Id: <1455813719-2395-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

In machines with 140G of memory and enterprise flash storage, we have
seen read and write bursts routinely exceed the kswapd watermarks and
cause thundering herds in direct reclaim. Unfortunately, the only way
to tune kswapd aggressiveness is through adjusting min_free_kbytes -
the system's emergency reserves - which is entirely unrelated to the
system's latency requirements. In order to get kswapd to maintain a
250M buffer of free memory, the emergency reserves need to be set to
1G. That is a lot of memory wasted for no good reason.

On the other hand, it's reasonable to assume that allocation bursts
and overall allocation concurrency scale with memory capacity, so it
makes sense to make kswapd aggressiveness a function of that as well.

Change the kswapd watermark scale factor from the currently fixed 25%
of the tunable emergency reserve to a tunable 0.001% of memory.

On a 140G machine, this raises the default watermark steps - the
distance between min and low, and low and high - from 16M to 143M.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/sysctl/vm.txt | 18 ++++++++++++++++++
 include/linux/mm.h          |  1 +
 include/linux/mmzone.h      |  2 ++
 kernel/sysctl.c             | 10 ++++++++++
 mm/page_alloc.c             | 23 +++++++++++++++++++++--
 5 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 89a887c..b02d940 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -803,6 +803,24 @@ performance impact. Reclaim code needs to take various locks to find freeable
 directory and inode objects. With vfs_cache_pressure=1000, it will look for
 ten times more freeable objects than there are.
 
+=============================================================
+
+watermark_scale_factor:
+
+This factor controls the aggressiveness of kswapd. It defines the
+amount of memory left in a node/system before kswapd is woken up and
+how much memory needs to be free before kswapd goes back to sleep.
+
+The unit is in fractions of 10,000. The default value of 10 means the
+distances between watermarks are 0.001% of the available memory in the
+node/system. The maximum value is 1000, or 10% of memory.
+
+A high rate of threads entering direct reclaim (allocstall) or kswapd
+going to sleep prematurely (kswapd_low_wmark_hit_quickly) can indicate
+that the number of free pages kswapd maintains for latency reasons is
+too small for the allocation bursts occurring in the system. This knob
+can then be used to tune kswapd aggressiveness accordingly.
+
 ==============================================================
 
 zone_reclaim_mode:
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a0ad7af..d330cbb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1869,6 +1869,7 @@ extern void zone_pcp_reset(struct zone *zone);
 
 /* page_alloc.c */
 extern int min_free_kbytes;
+extern int watermark_scale_factor;
 
 /* nommu.c */
 extern atomic_long_t mmap_pages_allocated;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 03cbdd9..85d6702 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -833,6 +833,8 @@ static inline int is_highmem(struct zone *zone)
 struct ctl_table;
 int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+int watermark_scale_factor_sysctl_handler(struct ctl_table *, int,
+					void __user *, size_t *, loff_t *);
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d479707..780769e 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -126,6 +126,7 @@ static int __maybe_unused two = 2;
 static int __maybe_unused four = 4;
 static unsigned long one_ul = 1;
 static int one_hundred = 100;
+static int one_thousand = 1000;
 #ifdef CONFIG_PRINTK
 static int ten_thousand = 10000;
 #endif
@@ -1393,6 +1394,15 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 	},
 	{
+		.procname	= "watermark_scale_factor",
+		.data		= &watermark_scale_factor,
+		.maxlen		= sizeof(watermark_scale_factor),
+		.mode		= 0644,
+		.proc_handler	= watermark_scale_factor_sysctl_handler,
+		.extra1		= &one,
+		.extra2		= &one_thousand,
+	},
+	{
 		.procname	= "percpu_pagelist_fraction",
 		.data		= &percpu_pagelist_fraction,
 		.maxlen		= sizeof(percpu_pagelist_fraction),
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0c3eba3..87575a9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -249,6 +249,7 @@ compound_page_dtor * const compound_page_dtors[] = {
 
 int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
+int watermark_scale_factor = 10;
 
 static unsigned long __meminitdata nr_kernel_pages;
 static unsigned long __meminitdata nr_all_pages;
@@ -6330,8 +6331,11 @@ static void __setup_per_zone_wmarks(void)
 			zone->watermark[WMARK_MIN] = tmp;
 		}
 
-		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
-		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
+		tmp = mult_frac(zone->managed_pages,
+				watermark_scale_factor, 10000);
+
+		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
+		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
 
 		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
 			high_wmark_pages(zone) - low_wmark_pages(zone) -
@@ -6472,6 +6476,21 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *table, int write,
 	return 0;
 }
 
+int watermark_scale_factor_sysctl_handler(struct ctl_table *table, int write,
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int rc;
+
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (rc)
+		return rc;
+
+	if (write)
+		setup_per_zone_wmarks();
+
+	return 0;
+}
+
 #ifdef CONFIG_NUMA
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
