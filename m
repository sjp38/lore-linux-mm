Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD8956B02C4
	for <linux-mm@kvack.org>; Wed,  3 May 2017 14:45:03 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id i81so7681340qke.6
        for <linux-mm@kvack.org>; Wed, 03 May 2017 11:45:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 54si20744055qtv.179.2017.05.03.11.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 11:45:03 -0700 (PDT)
Message-Id: <20170503184039.818107646@redhat.com>
Date: Wed, 03 May 2017 15:40:09 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: [patch 2/3] MM: allow per-cpu vmstat_threshold configuration
References: <20170503184007.174707977@redhat.com>
Content-Disposition: inline; filename=vmstat-configurable-thresh
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, Marcelo Tosatti <mtosatti@redhat.com>

The per-CPU vmstat worker is a problem on -RT workloads (because
ideally the CPU is entirely reserved for the -RT app, without
interference). The worker transfers accumulated per-CPU 
vmstat counters to global counters.

To resolve the problem, create a userspace configurable per-CPU 
vmstat threshold: by default the VM code calculates the size of
the per-CPU vmstat arrays. This tunable allows userspace to 
configure the vmstat threshold values.

The patch below contains documentation which describes the tunables
in more detail.

Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>

---
 Documentation/vm/vmstat_thresholds.txt |   78 +++++++++++++
 mm/vmstat.c                            |  188 +++++++++++++++++++++++++++++----
 2 files changed, 247 insertions(+), 19 deletions(-)

Index: linux-2.6-git-disable-vmstat-worker/mm/vmstat.c
===================================================================
--- linux-2.6-git-disable-vmstat-worker.orig/mm/vmstat.c	2017-04-25 07:39:13.941019853 -0300
+++ linux-2.6-git-disable-vmstat-worker/mm/vmstat.c	2017-05-03 10:59:43.495714336 -0300
@@ -91,8 +91,16 @@
 EXPORT_SYMBOL(vm_zone_stat);
 EXPORT_SYMBOL(vm_node_stat);
 
+struct vmstat_uparam {
+	atomic_t user_stat_thresh;
+};
+
+static DEFINE_PER_CPU(struct vmstat_uparam, vmstat_uparam);
+
 #ifdef CONFIG_SMP
 
+#define MAX_THRESHOLD 125
+
 int calculate_pressure_threshold(struct zone *zone)
 {
 	int threshold;
@@ -110,9 +118,9 @@
 	threshold = max(1, (int)(watermark_distance / num_online_cpus()));
 
 	/*
-	 * Maximum threshold is 125
+	 * Maximum threshold is MAX_THRESHOLD == 125
 	 */
-	threshold = min(125, threshold);
+	threshold = min(MAX_THRESHOLD, threshold);
 
 	return threshold;
 }
@@ -188,15 +196,31 @@
 		threshold = calculate_normal_threshold(zone);
 
 		for_each_online_cpu(cpu) {
-			int pgdat_threshold;
+			int pgdat_threshold, ustat_thresh;
+			struct vmstat_uparam *vup;
 
-			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
-							= threshold;
+			struct per_cpu_nodestat __percpu *pcp;
+			struct per_cpu_pageset *p;
+
+			p = per_cpu_ptr(zone->pageset, cpu);
+
+			vup = &per_cpu(vmstat_uparam, cpu);
+			ustat_thresh = atomic_read(&vup->user_stat_thresh);
+
+			if (ustat_thresh)
+				p->stat_threshold = ustat_thresh;
+			else
+				p->stat_threshold = threshold;
+
+			pcp = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu);
 
 			/* Base nodestat threshold on the largest populated zone. */
-			pgdat_threshold = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold;
-			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
-				= max(threshold, pgdat_threshold);
+			pgdat_threshold = pcp->stat_threshold;
+			if (ustat_thresh)
+				pcp->stat_threshold = ustat_thresh;
+			else
+				pcp->stat_threshold = max(threshold,
+							  pgdat_threshold);
 		}
 
 		/*
@@ -226,9 +250,24 @@
 			continue;
 
 		threshold = (*calculate_pressure)(zone);
-		for_each_online_cpu(cpu)
+		for_each_online_cpu(cpu) {
+			int t, ustat_thresh;
+			struct vmstat_uparam *vup;
+
+			vup = &per_cpu(vmstat_uparam, cpu);
+			ustat_thresh = atomic_read(&vup->user_stat_thresh);
+			t = threshold;
+
+			/*
+			 * min because pressure could cause
+			 * calculate_pressure'ed value to be smaller.
+			 */
+			if (ustat_thresh)
+				t = min(threshold, ustat_thresh);
+
 			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
-							= threshold;
+							= t;
+		}
 	}
 }
 
@@ -249,7 +288,7 @@
 
 	t = __this_cpu_read(pcp->stat_threshold);
 
-	if (unlikely(x > t || x < -t)) {
+	if (unlikely(x >= t || x <= -t)) {
 		zone_page_state_add(x, zone, item);
 		x = 0;
 	}
@@ -269,7 +308,7 @@
 
 	t = __this_cpu_read(pcp->stat_threshold);
 
-	if (unlikely(x > t || x < -t)) {
+	if (unlikely(x >= t || x <= -t)) {
 		node_page_state_add(x, pgdat, item);
 		x = 0;
 	}
@@ -308,7 +347,7 @@
 
 	v = __this_cpu_inc_return(*p);
 	t = __this_cpu_read(pcp->stat_threshold);
-	if (unlikely(v > t)) {
+	if (unlikely(v >= t)) {
 		s8 overstep = t >> 1;
 
 		zone_page_state_add(v + overstep, zone, item);
@@ -324,7 +363,7 @@
 
 	v = __this_cpu_inc_return(*p);
 	t = __this_cpu_read(pcp->stat_threshold);
-	if (unlikely(v > t)) {
+	if (unlikely(v >= t)) {
 		s8 overstep = t >> 1;
 
 		node_page_state_add(v + overstep, pgdat, item);
@@ -352,7 +391,7 @@
 
 	v = __this_cpu_dec_return(*p);
 	t = __this_cpu_read(pcp->stat_threshold);
-	if (unlikely(v < - t)) {
+	if (unlikely(v <= - t)) {
 		s8 overstep = t >> 1;
 
 		zone_page_state_add(v - overstep, zone, item);
@@ -368,7 +407,7 @@
 
 	v = __this_cpu_dec_return(*p);
 	t = __this_cpu_read(pcp->stat_threshold);
-	if (unlikely(v < - t)) {
+	if (unlikely(v <= - t)) {
 		s8 overstep = t >> 1;
 
 		node_page_state_add(v - overstep, pgdat, item);
@@ -426,7 +465,7 @@
 		o = this_cpu_read(*p);
 		n = delta + o;
 
-		if (n > t || n < -t) {
+		if (n >= t || n <= -t) {
 			int os = overstep_mode * (t >> 1) ;
 
 			/* Overflow must be added to zone counters */
@@ -483,7 +522,7 @@
 		o = this_cpu_read(*p);
 		n = delta + o;
 
-		if (n > t || n < -t) {
+		if (n >= t || n <= -t) {
 			int os = overstep_mode * (t >> 1) ;
 
 			/* Overflow must be added to node counters */
@@ -1696,6 +1735,96 @@
 		round_jiffies_relative(sysctl_stat_interval));
 }
 
+#ifdef CONFIG_SYSFS
+
+static ssize_t vmstat_thresh_show(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	int ret;
+	struct vmstat_uparam *vup;
+	unsigned int cpu = dev->id;
+
+	preempt_disable();
+
+	vup = &per_cpu(vmstat_uparam, cpu);
+	ret = sprintf(buf, "%d\n", atomic_read(&vup->user_stat_thresh));
+
+	preempt_enable();
+
+	return ret;
+}
+
+static ssize_t vmstat_thresh_store(struct device *dev,
+				   struct device_attribute *attr,
+				   const char *buf, size_t count)
+{
+	int ret, val;
+	unsigned int cpu = dev->id;
+	struct vmstat_uparam *vup;
+
+	ret = sscanf(buf, "%d", &val);
+	if (ret != 1 || val < 1 || val > MAX_THRESHOLD)
+		return -EINVAL;
+
+	preempt_disable();
+
+	if (cpu_online(cpu)) {
+		vup = &per_cpu(vmstat_uparam, cpu);
+		atomic_set(&vup->user_stat_thresh, val);
+	} else
+		count = -EINVAL;
+
+	preempt_enable();
+
+	return count;
+}
+
+struct device_attribute vmstat_threshold_attr =
+	__ATTR(vmstat_threshold, 0644, vmstat_thresh_show, vmstat_thresh_store);
+
+static struct attribute *vmstat_attrs[] = {
+	&vmstat_threshold_attr.attr,
+	NULL
+};
+
+static struct attribute_group vmstat_attr_group = {
+	.attrs  =  vmstat_attrs,
+	.name   = "vmstat"
+};
+
+static int vmstat_thresh_cpu_online(unsigned int cpu)
+{
+	struct device *dev = get_cpu_device(cpu);
+	int ret;
+
+	ret = sysfs_create_group(&dev->kobj, &vmstat_attr_group);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
+static int vmstat_thresh_cpu_down_prep(unsigned int cpu)
+{
+	struct device *dev = get_cpu_device(cpu);
+
+	sysfs_remove_group(&dev->kobj, &vmstat_attr_group);
+	return 0;
+}
+
+static void init_vmstat_sysfs(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct vmstat_uparam *vup = &per_cpu(vmstat_uparam, cpu);
+
+		atomic_set(&vup->user_stat_thresh, 0);
+	}
+}
+
+#endif /* CONFIG_SYSFS */
+
 static void __init init_cpu_node_state(void)
 {
 	int node;
@@ -1723,9 +1852,12 @@
 {
 	const struct cpumask *node_cpus;
 	int node;
+	struct vmstat_uparam *vup = &per_cpu(vmstat_uparam, cpu);
 
 	node = cpu_to_node(cpu);
 
+	atomic_set(&vup->user_stat_thresh, 0);
+
 	refresh_zone_stat_thresholds();
 	node_cpus = cpumask_of_node(node);
 	if (cpumask_weight(node_cpus) > 0)
@@ -1735,7 +1867,7 @@
 	return 0;
 }
 
-#endif
+#endif /* CONFIG_SMP */
 
 struct workqueue_struct *mm_percpu_wq;
 
@@ -1772,6 +1904,24 @@
 #endif
 }
 
+static int __init init_mm_internals_late(void)
+{
+#ifdef CONFIG_SYSFS
+	int ret;
+
+	init_vmstat_sysfs();
+
+	ret = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "mm/vmstat_thresh:online",
+					vmstat_thresh_cpu_online,
+					vmstat_thresh_cpu_down_prep);
+	if (ret < 0)
+		pr_err("vmstat_thresh: failed to register 'online' hotplug state\n");
+#endif
+	return 0;
+}
+
+late_initcall(init_mm_internals_late);
+
 #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
 
 /*
Index: linux-2.6-git-disable-vmstat-worker/Documentation/vm/vmstat_thresholds.txt
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-git-disable-vmstat-worker/Documentation/vm/vmstat_thresholds.txt	2017-05-02 13:48:45.946840708 -0300
@@ -0,0 +1,78 @@
+Userspace configurable vmstat thresholds
+========================================
+
+This document describes the tunables to control
+per-CPU vmstat threshold and per-CPU vmstat worker
+thread.
+
+/sys/devices/system/cpu/cpuN/vmstat/vmstat_threshold:
+
+This file contains the per-CPU vmstat threshold.
+This value is the maximum that a single per-CPU vmstat statistic
+can accumulate before transferring to the global counters.
+
+A value of 0 indicates that the value is set
+by the in kernel algorithm.
+
+A value different than 0 indicates that particular
+value is used for vmstat_threshold.
+
+/sys/devices/system/cpu/cpuN/vmstat/vmstat_worker:
+
+Enable/disable the per-CPU vmstat worker.
+
+What does the vmstat_threshold value mean? What are the implications
+of changing this value? What's the difference in choosing 1, 2, 3
+or 500?
+====================================================================
+
+Its the maximum value for a vmstat statistics counter to hold. After
+that value, the statistics are transferred to the global counter:
+
+void __mod_node_page_state(struct pglist_data *pgdat, enum node_stat_item item,
+                                long delta)
+{
+        struct per_cpu_nodestat __percpu *pcp = pgdat->per_cpu_nodestats;
+        s8 __percpu *p = pcp->vm_node_stat_diff + item;
+        long x;
+        long t;
+
+        x = delta + __this_cpu_read(*p);
+
+        t = __this_cpu_read(pcp->stat_threshold);
+
+        if (unlikely(x > t || x < -t)) {
+                node_page_state_add(x, pgdat, item);
+                x = 0;
+        }
+        __this_cpu_write(*p, x);
+}
+
+Increasing the threshold value does two things:
+        1) It decreases the number of inter-processor accesses.
+        2) It increases how much the global counters stay out of
+           sync relative to actual current values.
+
+
+Usage example:
+=============
+
+In a realtime system, the worker thread waking up and executing
+vmstat_update can be an undesired source of latencies.
+
+To avoid the worker thread from waking up, executing vmstat_update
+on cpu 1, for example, perform the following steps:
+
+
+cd /sys/devices/system/cpu/cpu0/vmstat/
+
+# Set vmstat threshold to 1 for cpu1, so that no
+# vmstat statistics are collected in cpu1's per-cpu
+# stats, instead they are immediately transferred
+# to the global counter.
+
+$ echo 1 > vmstat_threshold
+
+# Disable vmstat_update worker for cpu1:
+$ echo 0 > vmstat_worker
+


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
