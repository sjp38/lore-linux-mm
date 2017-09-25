Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7483F6B0038
	for <linux-mm@kvack.org>; Sun, 24 Sep 2017 21:36:37 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 6so13295698pgh.0
        for <linux-mm@kvack.org>; Sun, 24 Sep 2017 18:36:37 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p3si3295563pgc.512.2017.09.24.18.36.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Sep 2017 18:36:35 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH v2] mm, sysctl: make VM stats configurable
References: <1506069287-4614-1-git-send-email-kemi.wang@intel.com>
Date: Mon, 25 Sep 2017 09:36:20 +0800
In-Reply-To: <1506069287-4614-1-git-send-email-kemi.wang@intel.com> (Kemi
	Wang's message of "Fri, 22 Sep 2017 16:34:47 +0800")
Message-ID: <87tvzr36gb.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

Kemi Wang <kemi.wang@intel.com> writes:

> This is the second step which introduces a tunable interface that allow VM
> stats configurable for optimizing zone_statistics(), as suggested by Dave
> Hansen and Ying Huang.
>
> =======================================
> When performance becomes a bottleneck and you can tolerate some possible
> tool breakage and some decreased counter precision (e.g. numa counter), you
> can do:
> 	echo [C|c]oarse > /proc/sys/vm/vmstat_mode
> In this case, numa counter update is ignored. We can see about
> *4.8%*(185->176) drop of cpu cycles per single page allocation and reclaim
> on Jesper's page_bench01 (single thread) and *8.1%*(343->315) drop of cpu
> cycles per single page allocation and reclaim on Jesper's page_bench03 (88
> threads) running on a 2-Socket Broadwell-based server (88 threads, 126G
> memory).
>
> Benchmark link provided by Jesper D Brouer(increase loop times to
> 10000000):
> https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/
> bench
>
> =======================================
> When performance is not a bottleneck and you want all tooling to work,
> you

When page allocation performance isn't a bottleneck ...

> can do:
> 	echo [S|s]trict > /proc/sys/vm/vmstat_mode
>
> =======================================
> We recommend automatic detection of virtual memory statistics by system,
> this is also system default configuration, you can do:
> 	echo [A|a]uto > /proc/sys/vm/vmstat_mode
> In this case, automatic detection of VM statistics, numa counter update
> is skipped unless it has been read by users at least once, e.g. cat
> /proc/zoneinfo.
>
> Therefore, with different VM stats mode, numa counters update can operate
> differently so that everybody can benefit.
>
> Many thanks to Michal Hocko and Dave Hansen for comments to help improve
> the original patch.
>
> ChangeLog:
>   Since V1->V2:
>   a) Merge to one patch;
>   b) Use jump label to eliminate the overhead of branch selection;
>   c) Add a single-time log message at boot time to help tell users what
>   happened.
>
> Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> Suggested-by: Ying Huang <ying.huang@intel.com>
> Signed-off-by: Kemi Wang <kemi.wang@intel.com>
> ---
>  Documentation/sysctl/vm.txt |  26 +++++++++
>  drivers/base/node.c         |   2 +
>  include/linux/vmstat.h      |  22 ++++++++
>  init/main.c                 |   2 +
>  kernel/sysctl.c             |   7 +++
>  mm/page_alloc.c             |  14 +++++
>  mm/vmstat.c                 | 126 ++++++++++++++++++++++++++++++++++++++++++++
>  7 files changed, 199 insertions(+)
>
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 9baf66a..6ab2843 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -61,6 +61,7 @@ Currently, these files are in /proc/sys/vm:
>  - swappiness
>  - user_reserve_kbytes
>  - vfs_cache_pressure
> +- vmstat_mode
>  - watermark_scale_factor
>  - zone_reclaim_mode
>  
> @@ -843,6 +844,31 @@ ten times more freeable objects than there are.
>  
>  =============================================================
>  
> +vmstat_mode
> +
> +This interface allows virtual memory statistics configurable.
> +
> +When performance becomes a bottleneck and you can tolerate some possible
> +tool breakage and some decreased counter precision (e.g. numa counter), you
> +can do:
> +	echo [C|c]oarse > /proc/sys/vm/vmstat_mode
> +ignorable statistics list:
> +- numa counters
> +
> +When performance is not a bottleneck and you want all tooling to work, you
> +can do:
> +	echo [S|s]trict > /proc/sys/vm/vmstat_mode
> +
> +We recommend automatic detection of virtual memory statistics by system,
> +this is also system default configuration, you can do:
> +	echo [A|a]uto > /proc/sys/vm/vmstat_mode
> +
> +E.g. numa statistics does not affect system's decision and it is very
> +rarely consumed. If set vmstat_mode = auto, numa counters update is skipped
> +unless the counter is *read* by users at least once.
> +
> +==============================================================
> +
>  watermark_scale_factor:
>  
>  This factor controls the aggressiveness of kswapd. It defines the
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 3855902..033c0c3 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -153,6 +153,7 @@ static DEVICE_ATTR(meminfo, S_IRUGO, node_read_meminfo, NULL);
>  static ssize_t node_read_numastat(struct device *dev,
>  				struct device_attribute *attr, char *buf)
>  {
> +	disable_zone_statistics = false;
>  	return sprintf(buf,
>  		       "numa_hit %lu\n"
>  		       "numa_miss %lu\n"
> @@ -194,6 +195,7 @@ static ssize_t node_read_vmstat(struct device *dev,
>  			     NR_VM_NUMA_STAT_ITEMS],
>  			     node_page_state(pgdat, i));
>  
> +	disable_zone_statistics = false;
>  	return n;
>  }
>  static DEVICE_ATTR(vmstat, S_IRUGO, node_read_vmstat, NULL);
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index ade7cb5..22670cf 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -6,9 +6,27 @@
>  #include <linux/mmzone.h>
>  #include <linux/vm_event_item.h>
>  #include <linux/atomic.h>
> +#include <linux/static_key.h>
>  
>  extern int sysctl_stat_interval;
>  
> +DECLARE_STATIC_KEY_FALSE(vmstat_mode_key);
> +extern bool disable_zone_statistics;
> +/*
> + * vmstat_mode:
> + * 0 = auto mode of vmstat, automatic detection of VM statistics.
> + * 1 = strict mode of vmstat, keep all VM statistics.
> + * 2 = coarse mode of vmstat, ignore unimportant VM statistics.
> + */
> +#define VMSTAT_AUTO_MODE 0
> +#define VMSTAT_STRICT_MODE  1
> +#define VMSTAT_COARSE_MODE  2
> +#define VMSTAT_MODE_LEN 16
> +extern int vmstat_mode;
> +extern char sysctl_vmstat_mode[];
> +extern int sysctl_vmstat_mode_handler(struct ctl_table *table, int write,
> +		void __user *buffer, size_t *length, loff_t *ppos);
> +
>  #ifdef CONFIG_VM_EVENT_COUNTERS
>  /*
>   * Light weight per cpu counter implementation.
> @@ -229,6 +247,10 @@ extern unsigned long sum_zone_node_page_state(int node,
>  extern unsigned long sum_zone_numa_state(int node, enum numa_stat_item item);
>  extern unsigned long node_page_state(struct pglist_data *pgdat,
>  						enum node_stat_item item);
> +extern void zero_zone_numa_counters(struct zone *zone);
> +extern void zero_zones_numa_counters(void);
> +extern void zero_global_numa_counters(void);
> +extern void invalid_numa_statistics(void);
>  #else
>  #define sum_zone_node_page_state(node, item) global_zone_page_state(item)
>  #define node_page_state(node, item) global_node_page_state(item)
> diff --git a/init/main.c b/init/main.c
> index 0ee9c686..940b71c 100644
> --- a/init/main.c
> +++ b/init/main.c
> @@ -567,6 +567,8 @@ asmlinkage __visible void __init start_kernel(void)
>  	sort_main_extable();
>  	trap_init();
>  	mm_init();
> +	pr_info("vmstat: System detection of virtual memory statistics, NUMA\n"
> +"counters update is skipped unless they are read by users at least once\n");
>  
>  	ftrace_init();
>  
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 6648fbb..f5b813b 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1234,6 +1234,13 @@ static struct ctl_table kern_table[] = {
>  
>  static struct ctl_table vm_table[] = {
>  	{
> +		.procname	= "vmstat_mode",
> +		.data		= &sysctl_vmstat_mode,
> +		.maxlen		= VMSTAT_MODE_LEN,
> +		.mode		= 0644,
> +		.proc_handler	= sysctl_vmstat_mode_handler,
> +	},
> +	{
>  		.procname	= "overcommit_memory",
>  		.data		= &sysctl_overcommit_memory,
>  		.maxlen		= sizeof(sysctl_overcommit_memory),
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c841af8..46afc8a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -83,6 +83,9 @@ DEFINE_PER_CPU(int, numa_node);
>  EXPORT_PER_CPU_SYMBOL(numa_node);
>  #endif
>  
> +DEFINE_STATIC_KEY_FALSE(vmstat_mode_key);
> +bool disable_zone_statistics = true;
> +
>  #ifdef CONFIG_HAVE_MEMORYLESS_NODES
>  /*
>   * N.B., Do NOT reference the '_numa_mem_' per cpu variable directly.
> @@ -2743,6 +2746,17 @@ static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
>  #ifdef CONFIG_NUMA
>  	enum numa_stat_item local_stat = NUMA_LOCAL;
>  
> +	/*
> +	 * skip zone_statistics() if vmstat mode is coarse or zone statistics
> +	 * is inactive in auto mode
> +	 */
> +
> +	if (static_branch_unlikely(&vmstat_mode_key)) {
> +		if (vmstat_mode == VMSTAT_COARSE_MODE)
> +			return;
> +	} else if (disable_zone_statistics)
> +		return;

I suspect this will not help performance.  I suggest to make the most
common case (auto mode + disable_zone_statistics (true)?)
unconditionally with jump label, and other combination conditionally.

Best Regards,
Huang, Ying

> +
>  	if (z->node != numa_node_id())
>  		local_stat = NUMA_OTHER;
>  
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 4bb13e7..d4ab53e 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -32,6 +32,94 @@
>  
>  #define NUMA_STATS_THRESHOLD (U16_MAX - 2)
>  
> +int vmstat_mode = VMSTAT_AUTO_MODE;
> +char sysctl_vmstat_mode[VMSTAT_MODE_LEN] = "auto";
> +static const char *vmstat_mode_name[3] = {"auto", "strict", "coarse"};
> +static DEFINE_MUTEX(vmstat_mode_lock);
> +
> +
> +static int __parse_vmstat_mode(char *s)
> +{
> +	const char *str = s;
> +
> +	if (strcmp(str, "auto") == 0 || strcmp(str, "Auto") == 0) {
> +		vmstat_mode = VMSTAT_AUTO_MODE;
> +		static_branch_disable(&vmstat_mode_key);
> +	} else if (strcmp(str, "strict") == 0 || strcmp(str, "Strict") == 0) {
> +		vmstat_mode = VMSTAT_STRICT_MODE;
> +		static_branch_enable(&vmstat_mode_key);
> +	} else if (strcmp(str, "coarse") == 0 || strcmp(str, "Coarse") == 0) {
> +		vmstat_mode = VMSTAT_COARSE_MODE;
> +		static_branch_enable(&vmstat_mode_key);
> +	} else {
> +		pr_warn("Ignoring invalid vmstat_mode value: %s\n", s);
> +		return -EINVAL;
> +	}
> +	return 0;
> +}
> +
> +int sysctl_vmstat_mode_handler(struct ctl_table *table, int write,
> +		void __user *buffer, size_t *length, loff_t *ppos)
> +{
> +	char old_string[VMSTAT_MODE_LEN];
> +	int ret, oldval;
> +
> +	mutex_lock(&vmstat_mode_lock);
> +	if (write)
> +		strncpy(old_string, (char *)table->data, VMSTAT_MODE_LEN);
> +	ret = proc_dostring(table, write, buffer, length, ppos);
> +	if (ret || !write) {
> +		mutex_unlock(&vmstat_mode_lock);
> +		return ret;
> +	}
> +
> +	oldval = vmstat_mode;
> +	if (__parse_vmstat_mode((char *)table->data)) {
> +		/*
> +		 * invalid sysctl_vmstat_mode value, restore saved string
> +		 */
> +		strncpy((char *)table->data, old_string, VMSTAT_MODE_LEN);
> +		vmstat_mode = oldval;
> +	} else {
> +		/*
> +		 * check whether vmstat mode changes or not
> +		 */
> +		if (vmstat_mode == oldval) {
> +			/* no change */
> +			mutex_unlock(&vmstat_mode_lock);
> +			return 0;
> +		} else if (vmstat_mode == VMSTAT_AUTO_MODE) {
> +			pr_info("vmstat mode changes from %s to auto mode\n",
> +					vmstat_mode_name[oldval]);
> +			/*
> +			 * Set default numa stats action when vmstat mode changes
> +			 * from coarse to auto
> +			 */
> +			if (oldval == VMSTAT_COARSE_MODE)
> +				disable_zone_statistics = true;
> +		} else if (vmstat_mode == VMSTAT_STRICT_MODE)
> +			pr_info("vmstat mode changes from %s to strict mode\n",
> +					vmstat_mode_name[oldval]);
> +		else if (vmstat_mode == VMSTAT_COARSE_MODE) {
> +			pr_info("vmstat mode changes from %s to coarse mode\n",
> +					vmstat_mode_name[oldval]);
> +#ifdef CONFIG_NUMA
> +			/*
> +			 * Invalidate numa counters when vmstat mode is set to coarse
> +			 * mode, because users can't tell the difference between the
> +			 * dead state and when allocator activity is quiet once
> +			 * zone_statistics() is turned off.
> +			 */
> +			invalid_numa_statistics();
> +#endif
> +		} else
> +			pr_warn("invalid vmstat_mode:%d\n", vmstat_mode);
> +	}
> +
> +	mutex_unlock(&vmstat_mode_lock);
> +	return 0;
> +}
> +
>  #ifdef CONFIG_VM_EVENT_COUNTERS
>  DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
>  EXPORT_PER_CPU_SYMBOL(vm_event_states);
> @@ -914,6 +1002,42 @@ unsigned long sum_zone_numa_state(int node,
>  	return count;
>  }
>  
> +/* zero numa counters within a zone */
> +void zero_zone_numa_counters(struct zone *zone)
> +{
> +	int item, cpu;
> +
> +	for (item = 0; item < NR_VM_NUMA_STAT_ITEMS; item++) {
> +		atomic_long_set(&zone->vm_numa_stat[item], 0);
> +		for_each_online_cpu(cpu)
> +			per_cpu_ptr(zone->pageset, cpu)->vm_numa_stat_diff[item] = 0;
> +	}
> +}
> +
> +/* zero numa counters of all the populated zones */
> +void zero_zones_numa_counters(void)
> +{
> +	struct zone *zone;
> +
> +	for_each_populated_zone(zone)
> +		zero_zone_numa_counters(zone);
> +}
> +
> +/* zero global numa counters */
> +void zero_global_numa_counters(void)
> +{
> +	int item;
> +
> +	for (item = 0; item < NR_VM_NUMA_STAT_ITEMS; item++)
> +		atomic_long_set(&vm_numa_stat[item], 0);
> +}
> +
> +void invalid_numa_statistics(void)
> +{
> +	zero_zones_numa_counters();
> +	zero_global_numa_counters();
> +}
> +
>  /*
>   * Determine the per node value of a stat item.
>   */
> @@ -1582,6 +1706,7 @@ static int zoneinfo_show(struct seq_file *m, void *arg)
>  {
>  	pg_data_t *pgdat = (pg_data_t *)arg;
>  	walk_zones_in_node(m, pgdat, false, false, zoneinfo_show_print);
> +	disable_zone_statistics = false;
>  	return 0;
>  }
>  
> @@ -1678,6 +1803,7 @@ static int vmstat_show(struct seq_file *m, void *arg)
>  
>  static void vmstat_stop(struct seq_file *m, void *arg)
>  {
> +	disable_zone_statistics = false;
>  	kfree(m->private);
>  	m->private = NULL;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
