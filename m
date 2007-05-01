Date: Tue, 1 May 2007 10:24:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Make vm statistics update interval configurable
Message-ID: <Pine.LNX.4.64.0705011022430.24428@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make it configurable. Code in mm makes the vm statistics intervals 
independent from the cache reaper use that opportunity to make
it configurable.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 Documentation/sysctl/vm.txt |   19 +++++++++++++++++++
 include/linux/sysctl.h      |    1 +
 kernel/sysctl.c             |   13 ++++++++++++-
 mm/vmstat.c                 |    4 +++-
 4 files changed, 35 insertions(+), 2 deletions(-)

Index: slub/Documentation/sysctl/vm.txt
===================================================================
--- slub.orig/Documentation/sysctl/vm.txt	2007-04-30 20:20:19.000000000 -0700
+++ slub/Documentation/sysctl/vm.txt	2007-04-30 20:56:18.000000000 -0700
@@ -34,6 +34,7 @@ Currently, these files are in /proc/sys/
 - swap_prefetch
 - readahead_ratio
 - readahead_hit_rate
+- stat_interval
 
 ==============================================================
 
@@ -275,3 +276,21 @@ Possible values can be:
 The larger value, the more capabilities, with more possible overheads.
 
 The default value is 1.
+
+================================================================
+
+stat_interval
+
+The period (seconds) in which the vm statistics are consolidated if the
+kernel supports SMP. Differentials to VM statistics are kept in per cpu
+fields and are only consolidated with per zone and global counters if the
+differentials cross certain limits. This limits the frequency of global
+updates and results in good scaling of the VM counters. However, if those
+counters are below the limits then the global and per zone counters are
+off by that value.  So we should consolidate the counters at some point.
+So the kernel runs a statistics update at regular intervals to consolidate
+the per cpu differentials that are below the update limits. The interval
+determines the frequency of these consolidations.
+
+The default value is 1 second.
+
Index: slub/include/linux/sysctl.h
===================================================================
--- slub.orig/include/linux/sysctl.h	2007-04-30 20:03:21.000000000 -0700
+++ slub/include/linux/sysctl.h	2007-04-30 20:31:13.000000000 -0700
@@ -208,6 +208,7 @@ enum
 	VM_VDSO_ENABLED=34,	/* map VDSO into new processes? */
 	VM_MIN_SLAB=35,		 /* Percent pages ignored by zone reclaim */
 	VM_HUGETLB_TREAT_MOVABLE=36, /* Allocate hugepages from ZONE_MOVABLE */
+	VM_STAT_INTERVAL=37,	/* Statistics timer */
 
 	/* s390 vm cmm sysctls */
 	VM_CMM_PAGES=1111,
Index: slub/kernel/sysctl.c
===================================================================
--- slub.orig/kernel/sysctl.c	2007-04-30 20:04:55.000000000 -0700
+++ slub/kernel/sysctl.c	2007-04-30 20:50:03.000000000 -0700
@@ -80,7 +80,7 @@ extern int sysctl_drop_caches;
 extern int percpu_pagelist_fraction;
 extern int compat_log;
 extern int maps_protect;
-
+extern int sysctl_stat_interval;
 #if defined(CONFIG_ADAPTIVE_READAHEAD)
 extern int readahead_ratio;
 extern int readahead_hit_rate;
@@ -894,6 +894,17 @@ static ctl_table vm_table[] = {
 		.extra2		= &one_hundred,
 	},
 #endif
+#ifdef CONFIG_SMP
+	{
+		.ctl_name	= VM_STAT_INTERVAL,
+		.procname	= "stat_interval",
+		.data		= &sysctl_stat_interval,
+		.maxlen		= sizeof(sysctl_stat_interval),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_jiffies,
+		.strategy	= &sysctl_jiffies,
+	},
+#endif
 #if defined(CONFIG_X86_32) || \
    (defined(CONFIG_SUPERH) && defined(CONFIG_VSYSCALL))
 	{
Index: slub/mm/vmstat.c
===================================================================
--- slub.orig/mm/vmstat.c	2007-04-30 20:16:18.000000000 -0700
+++ slub/mm/vmstat.c	2007-04-30 20:51:06.000000000 -0700
@@ -685,11 +685,13 @@ const struct seq_operations vmstat_op = 
 
 #ifdef CONFIG_SMP
 static DEFINE_PER_CPU(struct delayed_work, vmstat_work);
+int sysctl_stat_interval __read_mostly = HZ;
 
 static void vmstat_update(struct work_struct *w)
 {
 	refresh_cpu_vm_stats(smp_processor_id());
-	schedule_delayed_work(&__get_cpu_var(vmstat_work), HZ);
+	schedule_delayed_work(&__get_cpu_var(vmstat_work),
+		sysctl_stat_interval);
 }
 
 static void __devinit start_cpu_timer(int cpu)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
