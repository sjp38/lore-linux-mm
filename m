Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 32F1D6B02F3
	for <linux-mm@kvack.org>; Wed,  3 May 2017 14:45:06 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id q71so7701583qkl.2
        for <linux-mm@kvack.org>; Wed, 03 May 2017 11:45:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y53si2681151qta.334.2017.05.03.11.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 11:45:05 -0700 (PDT)
Message-Id: <20170503184039.901336380@redhat.com>
Date: Wed, 03 May 2017 15:40:10 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: [patch 3/3] MM: allow per-cpu vmstat_worker configuration
References: <20170503184007.174707977@redhat.com>
Content-Disposition: inline; filename=vmstat-worker-disinterface
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, Marcelo Tosatti <mtosatti@redhat.com>

Following the reasoning on the last patch in the series,
this patch allows configuration of the per-CPU vmstat worker:
it allows the user to disable the per-CPU vmstat worker.

Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>

--- linux/mm/vmstat.c.sothresh	2017-05-03 11:01:17.465914562 -0300
+++ linux/mm/vmstat.c	2017-05-03 11:01:39.746961917 -0300
@@ -92,6 +92,7 @@
 EXPORT_SYMBOL(vm_node_stat);
 
 struct vmstat_uparam {
+	atomic_t vmstat_work_enabled;
 	atomic_t user_stat_thresh;
 };
 
@@ -1606,6 +1607,9 @@
 	long val;
 	int err;
 	int i;
+	int cpu;
+	struct work_struct __percpu *works;
+	static struct cpumask has_work;
 
 	/*
 	 * The regular update, every sysctl_stat_interval, may come later
@@ -1619,9 +1623,31 @@
 	 * transiently negative values, report an error here if any of
 	 * the stats is negative, so we know to go looking for imbalance.
 	 */
-	err = schedule_on_each_cpu(refresh_vm_stats);
-	if (err)
-		return err;
+
+	works = alloc_percpu(struct work_struct);
+	if (!works)
+		return -ENOMEM;
+
+	cpumask_clear(&has_work);
+	get_online_cpus();
+
+	for_each_online_cpu(cpu) {
+		struct work_struct *work = per_cpu_ptr(works, cpu);
+		struct vmstat_uparam *vup = &per_cpu(vmstat_uparam, cpu);
+
+		if (atomic_read(&vup->vmstat_work_enabled)) {
+			INIT_WORK(work, refresh_vm_stats);
+			schedule_work_on(cpu, work);
+			cpumask_set_cpu(cpu, &has_work);
+		}
+	}
+
+	for_each_cpu(cpu, &has_work)
+		flush_work(per_cpu_ptr(works, cpu));
+
+	put_online_cpus();
+	free_percpu(works);
+
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
 		val = atomic_long_read(&vm_zone_stat[i]);
 		if (val < 0) {
@@ -1713,6 +1739,10 @@
 	/* Check processors whose vmstat worker threads have been disabled */
 	for_each_online_cpu(cpu) {
 		struct delayed_work *dw = &per_cpu(vmstat_work, cpu);
+		struct vmstat_uparam *vup = &per_cpu(vmstat_uparam, cpu);
+
+		if (atomic_read(&vup->vmstat_work_enabled) == 0)
+			continue;
 
 		if (!delayed_work_pending(dw) && need_update(cpu))
 			queue_delayed_work_on(cpu, mm_percpu_wq, dw, 0);
@@ -1737,6 +1767,40 @@
 
 #ifdef CONFIG_SYSFS
 
+static ssize_t vmstat_worker_show(struct device *dev,
+				  struct device_attribute *attr, char *buf)
+{
+	unsigned int cpu = dev->id;
+	struct vmstat_uparam *vup = &per_cpu(vmstat_uparam, cpu);
+
+	return sprintf(buf, "%d\n", atomic_read(&vup->vmstat_work_enabled));
+}
+
+static ssize_t vmstat_worker_store(struct device *dev,
+				   struct device_attribute *attr,
+				   const char *buf, size_t count)
+{
+	int ret, val;
+	struct vmstat_uparam *vup;
+	unsigned int cpu = dev->id;
+
+	ret = sscanf(buf, "%d", &val);
+	if (ret != 1 || val > 1 || val < 0)
+		return -EINVAL;
+
+	preempt_disable();
+
+	if (cpu_online(cpu)) {
+		vup = &per_cpu(vmstat_uparam, cpu);
+		atomic_set(&vup->vmstat_work_enabled, val);
+	} else
+		count = -EINVAL;
+
+	preempt_enable();
+
+	return count;
+}
+
 static ssize_t vmstat_thresh_show(struct device *dev,
 				  struct device_attribute *attr, char *buf)
 {
@@ -1779,10 +1843,14 @@
 	return count;
 }
 
+struct device_attribute vmstat_worker_attr =
+	__ATTR(vmstat_worker, 0644, vmstat_worker_show, vmstat_worker_store);
+
 struct device_attribute vmstat_threshold_attr =
 	__ATTR(vmstat_threshold, 0644, vmstat_thresh_show, vmstat_thresh_store);
 
 static struct attribute *vmstat_attrs[] = {
+	&vmstat_worker_attr.attr,
 	&vmstat_threshold_attr.attr,
 	NULL
 };
@@ -1820,6 +1888,7 @@
 		struct vmstat_uparam *vup = &per_cpu(vmstat_uparam, cpu);
 
 		atomic_set(&vup->user_stat_thresh, 0);
+		atomic_set(&vup->vmstat_work_enabled, 1);
 	}
 }
 
@@ -1857,6 +1926,7 @@
 	node = cpu_to_node(cpu);
 
 	atomic_set(&vup->user_stat_thresh, 0);
+	atomic_set(&vup->vmstat_work_enabled, 1);
 
 	refresh_zone_stat_thresholds();
 	node_cpus = cpumask_of_node(node);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
