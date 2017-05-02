Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E6736B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 10:28:45 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f53so34248406qte.15
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:28:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n6si11583813qkc.212.2017.05.02.07.28.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 07:28:44 -0700 (PDT)
Date: Tue, 2 May 2017 10:28:36 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and
 vmstat_worker configuration
Message-ID: <20170502102836.4a4d34ba@redhat.com>
In-Reply-To: <20170425135846.203663532@redhat.com>
References: <20170425135717.375295031@redhat.com>
	<20170425135846.203663532@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cl@linux.com, cmetcalf@mellanox.com

On Tue, 25 Apr 2017 10:57:19 -0300
Marcelo Tosatti <mtosatti@redhat.com> wrote:

> The per-CPU vmstat worker is a problem on -RT workloads (because
> ideally the CPU is entirely reserved for the -RT app, without
> interference). The worker transfers accumulated per-CPU 
> vmstat counters to global counters.

This is a problem for non-RT too. Any task pinned to an isolated
CPU that doesn't want to be ever interrupted will be interrupted
by the vmstat kworker.

> To resolve the problem, create two tunables:
> 
> * Userspace configurable per-CPU vmstat threshold: by default the 
> VM code calculates the size of the per-CPU vmstat arrays. This 
> tunable allows userspace to configure the values.
> 
> * Userspace configurable per-CPU vmstat worker: allow disabling
> the per-CPU vmstat worker.

I have several questions about the tunables:

 - What does the vmstat_threshold value mean? What are the implications
   of changing this value? What's the difference in choosing 1, 2, 3
   or 500?

 - If the purpose of having vmstat_threshold is to allow disabling
   the vmstat kworker, why can't the kernel pick a value automatically?

 - What are the implications of disabling the vmstat kworker? Will vm
   stats still be collected someway or will it be completely off for
   the CPU?

Also, shouldn't this patch be split into two?

> The patch below contains documentation which describes the tunables
> in more detail.
> 
> Signed-off-by: Marcelo Tosatti <mtosatti@redhat.com>
> 
> ---
>  Documentation/vm/vmstat_thresholds.txt |   38 +++++
>  mm/vmstat.c                            |  248 +++++++++++++++++++++++++++++++--
>  2 files changed, 272 insertions(+), 14 deletions(-)
> 
> Index: linux-2.6-git-disable-vmstat-worker/mm/vmstat.c
> ===================================================================
> --- linux-2.6-git-disable-vmstat-worker.orig/mm/vmstat.c	2017-04-25 07:39:13.941019853 -0300
> +++ linux-2.6-git-disable-vmstat-worker/mm/vmstat.c	2017-04-25 10:44:51.581977296 -0300
> @@ -91,8 +91,17 @@
>  EXPORT_SYMBOL(vm_zone_stat);
>  EXPORT_SYMBOL(vm_node_stat);
>  
> +struct vmstat_uparam {
> +	atomic_t vmstat_work_enabled;
> +	atomic_t user_stat_thresh;
> +};
> +
> +static DEFINE_PER_CPU(struct vmstat_uparam, vmstat_uparam);
> +
>  #ifdef CONFIG_SMP
>  
> +#define MAX_THRESHOLD 125
> +
>  int calculate_pressure_threshold(struct zone *zone)
>  {
>  	int threshold;
> @@ -110,9 +119,9 @@
>  	threshold = max(1, (int)(watermark_distance / num_online_cpus()));
>  
>  	/*
> -	 * Maximum threshold is 125
> +	 * Maximum threshold is MAX_THRESHOLD == 125
>  	 */
> -	threshold = min(125, threshold);
> +	threshold = min(MAX_THRESHOLD, threshold);
>  
>  	return threshold;
>  }
> @@ -188,15 +197,31 @@
>  		threshold = calculate_normal_threshold(zone);
>  
>  		for_each_online_cpu(cpu) {
> -			int pgdat_threshold;
> +			int pgdat_threshold, ustat_thresh;
> +			struct vmstat_uparam *vup;
>  
> -			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> -							= threshold;
> +			struct per_cpu_nodestat __percpu *pcp;
> +			struct per_cpu_pageset *p;
> +
> +			p = per_cpu_ptr(zone->pageset, cpu);
> +
> +			vup = &per_cpu(vmstat_uparam, cpu);
> +			ustat_thresh = atomic_read(&vup->user_stat_thresh);
> +
> +			if (ustat_thresh)
> +				p->stat_threshold = ustat_thresh;
> +			else
> +				p->stat_threshold = threshold;
> +
> +			pcp = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu);
>  
>  			/* Base nodestat threshold on the largest populated zone. */
> -			pgdat_threshold = per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold;
> -			per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->stat_threshold
> -				= max(threshold, pgdat_threshold);
> +			pgdat_threshold = pcp->stat_threshold;
> +			if (ustat_thresh)
> +				pcp->stat_threshold = ustat_thresh;
> +			else
> +				pcp->stat_threshold = max(threshold,
> +							  pgdat_threshold);
>  		}
>  
>  		/*
> @@ -226,9 +251,24 @@
>  			continue;
>  
>  		threshold = (*calculate_pressure)(zone);
> -		for_each_online_cpu(cpu)
> +		for_each_online_cpu(cpu) {
> +			int t, ustat_thresh;
> +			struct vmstat_uparam *vup;
> +
> +			vup = &per_cpu(vmstat_uparam, cpu);
> +			ustat_thresh = atomic_read(&vup->user_stat_thresh);
> +			t = threshold;
> +
> +			/*
> +			 * min because pressure could cause
> +			 * calculate_pressure'ed value to be smaller.
> +			 */
> +			if (ustat_thresh)
> +				t = min(threshold, ustat_thresh);
> +
>  			per_cpu_ptr(zone->pageset, cpu)->stat_threshold
> -							= threshold;
> +							= t;
> +		}
>  	}
>  }
>  
> @@ -1567,6 +1607,9 @@
>  	long val;
>  	int err;
>  	int i;
> +	int cpu;
> +	struct work_struct __percpu *works;
> +	static struct cpumask has_work;
>  
>  	/*
>  	 * The regular update, every sysctl_stat_interval, may come later
> @@ -1580,9 +1623,31 @@
>  	 * transiently negative values, report an error here if any of
>  	 * the stats is negative, so we know to go looking for imbalance.
>  	 */
> -	err = schedule_on_each_cpu(refresh_vm_stats);
> -	if (err)
> -		return err;
> +
> +	works = alloc_percpu(struct work_struct);
> +	if (!works)
> +		return -ENOMEM;
> +
> +	cpumask_clear(&has_work);
> +	get_online_cpus();
> +
> +	for_each_online_cpu(cpu) {
> +		struct work_struct *work = per_cpu_ptr(works, cpu);
> +		struct vmstat_uparam *vup = &per_cpu(vmstat_uparam, cpu);
> +
> +		if (atomic_read(&vup->vmstat_work_enabled)) {
> +			INIT_WORK(work, refresh_vm_stats);
> +			schedule_work_on(cpu, work);
> +			cpumask_set_cpu(cpu, &has_work);
> +		}
> +	}
> +
> +	for_each_cpu(cpu, &has_work)
> +		flush_work(per_cpu_ptr(works, cpu));
> +
> +	put_online_cpus();
> +	free_percpu(works);
> +
>  	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
>  		val = atomic_long_read(&vm_zone_stat[i]);
>  		if (val < 0) {
> @@ -1674,6 +1739,10 @@
>  	/* Check processors whose vmstat worker threads have been disabled */
>  	for_each_online_cpu(cpu) {
>  		struct delayed_work *dw = &per_cpu(vmstat_work, cpu);
> +		struct vmstat_uparam *vup = &per_cpu(vmstat_uparam, cpu);
> +
> +		if (atomic_read(&vup->vmstat_work_enabled) == 0)
> +			continue;
>  
>  		if (!delayed_work_pending(dw) && need_update(cpu))
>  			queue_delayed_work_on(cpu, mm_percpu_wq, dw, 0);
> @@ -1696,6 +1765,135 @@
>  		round_jiffies_relative(sysctl_stat_interval));
>  }
>  
> +#ifdef CONFIG_SYSFS
> +
> +static ssize_t vmstat_worker_show(struct device *dev,
> +				  struct device_attribute *attr, char *buf)
> +{
> +	unsigned int cpu = dev->id;
> +	struct vmstat_uparam *vup = &per_cpu(vmstat_uparam, cpu);
> +
> +	return sprintf(buf, "%d\n", atomic_read(&vup->vmstat_work_enabled));
> +}
> +
> +static ssize_t vmstat_worker_store(struct device *dev,
> +				   struct device_attribute *attr,
> +				   const char *buf, size_t count)
> +{
> +	int ret, val;
> +	struct vmstat_uparam *vup;
> +	unsigned int cpu = dev->id;
> +
> +	ret = sscanf(buf, "%d", &val);
> +	if (ret != 1 || val > 1 || val < 0)
> +		return -EINVAL;
> +
> +	preempt_disable();
> +
> +	if (cpu_online(cpu)) {
> +		vup = &per_cpu(vmstat_uparam, cpu);
> +		atomic_set(&vup->vmstat_work_enabled, val);
> +	} else
> +		count = -EINVAL;
> +
> +	preempt_enable();
> +
> +	return count;
> +}
> +
> +static ssize_t vmstat_thresh_show(struct device *dev,
> +				  struct device_attribute *attr, char *buf)
> +{
> +	int ret;
> +	struct vmstat_uparam *vup;
> +	unsigned int cpu = dev->id;
> +
> +	preempt_disable();
> +
> +	vup = &per_cpu(vmstat_uparam, cpu);
> +	ret = sprintf(buf, "%d\n", atomic_read(&vup->user_stat_thresh));
> +
> +	preempt_enable();
> +
> +	return ret;
> +}
> +
> +static ssize_t vmstat_thresh_store(struct device *dev,
> +				   struct device_attribute *attr,
> +				   const char *buf, size_t count)
> +{
> +	int ret, val;
> +	unsigned int cpu = dev->id;
> +	struct vmstat_uparam *vup;
> +
> +	ret = sscanf(buf, "%d", &val);
> +	if (ret != 1 || val < 1 || val > MAX_THRESHOLD)
> +		return -EINVAL;
> +
> +	preempt_disable();
> +
> +	if (cpu_online(cpu)) {
> +		vup = &per_cpu(vmstat_uparam, cpu);
> +		atomic_set(&vup->user_stat_thresh, val);
> +	} else
> +		count = -EINVAL;
> +
> +	preempt_enable();
> +
> +	return count;
> +}
> +
> +struct device_attribute vmstat_worker_attr =
> +	__ATTR(vmstat_worker, 0644, vmstat_worker_show, vmstat_worker_store);
> +
> +struct device_attribute vmstat_threshold_attr =
> +	__ATTR(vmstat_threshold, 0644, vmstat_thresh_show, vmstat_thresh_store);
> +
> +static struct attribute *vmstat_attrs[] = {
> +	&vmstat_worker_attr.attr,
> +	&vmstat_threshold_attr.attr,
> +	NULL
> +};
> +
> +static struct attribute_group vmstat_attr_group = {
> +	.attrs  =  vmstat_attrs,
> +	.name   = "vmstat"
> +};
> +
> +static int vmstat_thresh_cpu_online(unsigned int cpu)
> +{
> +	struct device *dev = get_cpu_device(cpu);
> +	int ret;
> +
> +	ret = sysfs_create_group(&dev->kobj, &vmstat_attr_group);
> +	if (ret)
> +		return ret;
> +
> +	return 0;
> +}
> +
> +static int vmstat_thresh_cpu_down_prep(unsigned int cpu)
> +{
> +	struct device *dev = get_cpu_device(cpu);
> +
> +	sysfs_remove_group(&dev->kobj, &vmstat_attr_group);
> +	return 0;
> +}
> +
> +static void init_vmstat_sysfs(void)
> +{
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		struct vmstat_uparam *vup = &per_cpu(vmstat_uparam, cpu);
> +
> +		atomic_set(&vup->user_stat_thresh, 0);
> +		atomic_set(&vup->vmstat_work_enabled, 1);
> +	}
> +}
> +
> +#endif /* CONFIG_SYSFS */
> +
>  static void __init init_cpu_node_state(void)
>  {
>  	int node;
> @@ -1723,9 +1921,13 @@
>  {
>  	const struct cpumask *node_cpus;
>  	int node;
> +	struct vmstat_uparam *vup = &per_cpu(vmstat_uparam, cpu);
>  
>  	node = cpu_to_node(cpu);
>  
> +	atomic_set(&vup->user_stat_thresh, 0);
> +	atomic_set(&vup->vmstat_work_enabled, 1);
> +
>  	refresh_zone_stat_thresholds();
>  	node_cpus = cpumask_of_node(node);
>  	if (cpumask_weight(node_cpus) > 0)
> @@ -1735,7 +1937,7 @@
>  	return 0;
>  }
>  
> -#endif
> +#endif /* CONFIG_SMP */
>  
>  struct workqueue_struct *mm_percpu_wq;
>  
> @@ -1772,6 +1974,24 @@
>  #endif
>  }
>  
> +static int __init init_mm_internals_late(void)
> +{
> +#ifdef CONFIG_SYSFS
> +	int ret;
> +
> +	init_vmstat_sysfs();
> +
> +	ret = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "mm/vmstat_thresh:online",
> +					vmstat_thresh_cpu_online,
> +					vmstat_thresh_cpu_down_prep);
> +	if (ret < 0)
> +		pr_err("vmstat_thresh: failed to register 'online' hotplug state\n");
> +#endif
> +	return 0;
> +}
> +
> +late_initcall(init_mm_internals_late);
> +
>  #if defined(CONFIG_DEBUG_FS) && defined(CONFIG_COMPACTION)
>  
>  /*
> Index: linux-2.6-git-disable-vmstat-worker/Documentation/vm/vmstat_thresholds.txt
> ===================================================================
> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ linux-2.6-git-disable-vmstat-worker/Documentation/vm/vmstat_thresholds.txt	2017-04-25 08:46:25.237395070 -0300
> @@ -0,0 +1,38 @@
> +Userspace configurable vmstat thresholds
> +========================================
> +
> +This document describes the tunables to control
> +per-CPU vmstat threshold and per-CPU vmstat worker
> +thread.
> +
> +/sys/devices/system/cpu/cpuN/vmstat/vmstat_threshold:
> +
> +This file contains the per-CPU vmstat threshold.
> +This value is the maximum that a single per-CPU vmstat statistic
> +can accumulate before transferring to the global counters.
> +
> +A value of 0 indicates that the value is set
> +by the in kernel algorithm.
> +
> +A value different than 0 indicates that particular
> +value is used for vmstat_threshold.
> +
> +/sys/devices/system/cpu/cpuN/vmstat/vmstat_worker:
> +
> +Enable/disable the per-CPU vmstat worker.
> +
> +Usage example:
> +=============
> +
> +To disable vmstat_update worker for cpu1:
> +
> +cd /sys/devices/system/cpu/cpu0/vmstat/
> +
> +# echo 1 > vmstat_threshold
> +# echo 0 > vmstat_worker
> +
> +Setting vmstat_threshold to 1 means the per-CPU
> +vmstat statistics will not be out-of-date
> +for CPU 1.
> +
> +
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
