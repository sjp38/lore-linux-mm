Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB6116B0268
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 03:03:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u138so1016091wmu.2
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 00:03:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g4si3008649wra.173.2017.09.29.00.03.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Sep 2017 00:03:13 -0700 (PDT)
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2be4a268-2b31-8aa5-9d09-ef2d34323ad8@suse.cz>
Date: Fri, 29 Sep 2017 09:03:12 +0200
MIME-Version: 1.0
In-Reply-To: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On 09/28/2017 08:11 AM, Kemi Wang wrote:
> This is the second step which introduces a tunable interface that allow
> numa stats configurable for optimizing zone_statistics(), as suggested by
> Dave Hansen and Ying Huang.
> 
> =========================================================================
> When page allocation performance becomes a bottleneck and you can tolerate
> some possible tool breakage and decreased numa counter precision, you can
> do:
> 	echo [C|c]oarse > /proc/sys/vm/numa_stats_mode
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
> =========================================================================
> When page allocation performance is not a bottleneck and you want all
> tooling to work, you can do:
> 	echo [S|s]trict > /proc/sys/vm/numa_stats_mode
> 
> =========================================================================
> We recommend automatic detection of numa statistics by system, this is also
> system default configuration, you can do:
> 	echo [A|a]uto > /proc/sys/vm/numa_stats_mode
> In this case, numa counter update is skipped unless it has been read by
> users at least once, e.g. cat /proc/zoneinfo.
> 
> Branch target selection with jump label:
> a) When numa_stats_mode is changed to *strict*, jump to the branch for numa
> counters update.
> b) When numa_stats_mode is changed to *coarse*, return back directly.
> c) When numa_stats_mode is changed to *auto*, the branch target used in
> last time is kept, and the branch target is changed to the branch for numa
> counters update once numa counters are *read* by users.
> 
> Therefore, with the help of jump label, the page allocation performance is
> hardly affected when numa counters are updated with a call in
> zone_statistics(). Meanwhile, the auto mode can give people benefit without
> manual tuning.
> 
> Many thanks to Michal Hocko, Dave Hansen and Ying Huang for comments to
> help improve the original patch.
> 
> ChangeLog:
>   V2->V3:
>   a) Propose a better way to use jump label to eliminate the overhead of
>   branch selection in zone_statistics(), as inspired by Ying Huang;
>   b) Add a paragraph in commit log to describe the way for branch target
>   selection;
>   c) Use a more descriptive name numa_stats_mode instead of vmstat_mode,
>   and change the description accordingly, as suggested by Michal Hocko;
>   d) Make this functionality NUMA-specific via ifdef
> 
>   V1->V2:
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
>  Documentation/sysctl/vm.txt |  24 +++++++++
>  drivers/base/node.c         |   4 ++
>  include/linux/vmstat.h      |  23 ++++++++
>  init/main.c                 |   3 ++
>  kernel/sysctl.c             |   7 +++
>  mm/page_alloc.c             |  10 ++++
>  mm/vmstat.c                 | 129 ++++++++++++++++++++++++++++++++++++++++++++
>  7 files changed, 200 insertions(+)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 9baf66a..e310e69 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -61,6 +61,7 @@ Currently, these files are in /proc/sys/vm:
>  - swappiness
>  - user_reserve_kbytes
>  - vfs_cache_pressure
> +- numa_stats_mode
>  - watermark_scale_factor
>  - zone_reclaim_mode
>  
> @@ -843,6 +844,29 @@ ten times more freeable objects than there are.
>  
>  =============================================================
>  
> +numa_stats_mode
> +
> +This interface allows numa statistics configurable.
> +
> +When page allocation performance becomes a bottleneck and you can tolerate
> +some possible tool breakage and decreased numa counter precision, you can
> +do:
> +	echo [C|c]oarse > /proc/sys/vm/numa_stats_mode
> +
> +When page allocation performance is not a bottleneck and you want all
> +tooling to work, you can do:
> +	echo [S|s]trict > /proc/sys/vm/numa_stat_mode
> +
> +We recommend automatic detection of numa statistics by system, because numa
> +statistics does not affect system's decision and it is very rarely
> +consumed. you can do:
> +	echo [A|a]uto > /proc/sys/vm/numa_stats_mode
> +This is also system default configuration, with this default setting, numa
> +counters update is skipped unless the counter is *read* by users at least
> +once.

It says "the counter", but it seems multiple files in /proc and /sys are
triggering this, so perhaps list them?
Also, is it possible that with contemporary userspace/distros (systemd
etc.) there will always be something that will read one of those upon boot?

> +
> +==============================================================
> +
>  watermark_scale_factor:
>  
>  This factor controls the aggressiveness of kswapd. It defines the
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 3855902..b57b5622 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -153,6 +153,8 @@ static DEVICE_ATTR(meminfo, S_IRUGO, node_read_meminfo, NULL);
>  static ssize_t node_read_numastat(struct device *dev,
>  				struct device_attribute *attr, char *buf)
>  {
> +	if (vm_numa_stats_mode == VM_NUMA_STAT_AUTO_MODE)
> +		static_branch_enable(&vm_numa_stats_mode_key);
>  	return sprintf(buf,
>  		       "numa_hit %lu\n"
>  		       "numa_miss %lu\n"
> @@ -186,6 +188,8 @@ static ssize_t node_read_vmstat(struct device *dev,
>  		n += sprintf(buf+n, "%s %lu\n",
>  			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
>  			     sum_zone_numa_state(nid, i));
> +	if (vm_numa_stats_mode == VM_NUMA_STAT_AUTO_MODE)
> +		static_branch_enable(&vm_numa_stats_mode_key);
>  #endif
>  
>  	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index ade7cb5..d52e882 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -6,9 +6,28 @@
>  #include <linux/mmzone.h>
>  #include <linux/vm_event_item.h>
>  #include <linux/atomic.h>
> +#include <linux/static_key.h>
>  
>  extern int sysctl_stat_interval;
>  
> +#ifdef CONFIG_NUMA
> +DECLARE_STATIC_KEY_FALSE(vm_numa_stats_mode_key);
> +/*
> + * vm_numa_stats_mode:
> + * 0 = auto mode of NUMA stats, automatic detection of NUMA statistics.
> + * 1 = strict mode of NUMA stats, keep NUMA statistics.
> + * 2 = coarse mode of NUMA stats, ignore NUMA statistics.
> + */
> +#define VM_NUMA_STAT_AUTO_MODE 0
> +#define VM_NUMA_STAT_STRICT_MODE  1
> +#define VM_NUMA_STAT_COARSE_MODE  2
> +#define VM_NUMA_STAT_MODE_LEN 16
> +extern int vm_numa_stats_mode;
> +extern char sysctl_vm_numa_stats_mode[];
> +extern int sysctl_vm_numa_stats_mode_handler(struct ctl_table *table, int write,
> +		void __user *buffer, size_t *length, loff_t *ppos);
> +#endif
> +
>  #ifdef CONFIG_VM_EVENT_COUNTERS
>  /*
>   * Light weight per cpu counter implementation.
> @@ -229,6 +248,10 @@ extern unsigned long sum_zone_node_page_state(int node,
>  extern unsigned long sum_zone_numa_state(int node, enum numa_stat_item item);
>  extern unsigned long node_page_state(struct pglist_data *pgdat,
>  						enum node_stat_item item);
> +extern void zero_zone_numa_counters(struct zone *zone);
> +extern void zero_zones_numa_counters(void);
> +extern void zero_global_numa_counters(void);
> +extern void invalid_numa_statistics(void);

These seem to be called only from within mm/vmstat.c where they live, so
I'd suggest removing these extern declarations, and making them static
in vmstat.c.

...

>  #define NUMA_STATS_THRESHOLD (U16_MAX - 2)
>  
> +#ifdef CONFIG_NUMA
> +int vm_numa_stats_mode = VM_NUMA_STAT_AUTO_MODE;
> +char sysctl_vm_numa_stats_mode[VM_NUMA_STAT_MODE_LEN] = "auto";
> +static const char *vm_numa_stats_mode_name[3] = {"auto", "strict", "coarse"};
> +static DEFINE_MUTEX(vm_numa_stats_mode_lock);
> +
> +static int __parse_vm_numa_stats_mode(char *s)
> +{
> +	const char *str = s;
> +
> +	if (strcmp(str, "auto") == 0 || strcmp(str, "Auto") == 0)
> +		vm_numa_stats_mode = VM_NUMA_STAT_AUTO_MODE;
> +	else if (strcmp(str, "strict") == 0 || strcmp(str, "Strict") == 0)
> +		vm_numa_stats_mode = VM_NUMA_STAT_STRICT_MODE;
> +	else if (strcmp(str, "coarse") == 0 || strcmp(str, "Coarse") == 0)
> +		vm_numa_stats_mode = VM_NUMA_STAT_COARSE_MODE;
> +	else {
> +		pr_warn("Ignoring invalid vm_numa_stats_mode value: %s\n", s);
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
> +int sysctl_vm_numa_stats_mode_handler(struct ctl_table *table, int write,
> +		void __user *buffer, size_t *length, loff_t *ppos)
> +{
> +	char old_string[VM_NUMA_STAT_MODE_LEN];
> +	int ret, oldval;
> +
> +	mutex_lock(&vm_numa_stats_mode_lock);
> +	if (write)
> +		strncpy(old_string, (char *)table->data, VM_NUMA_STAT_MODE_LEN);
> +	ret = proc_dostring(table, write, buffer, length, ppos);
> +	if (ret || !write) {
> +		mutex_unlock(&vm_numa_stats_mode_lock);
> +		return ret;
> +	}
> +
> +	oldval = vm_numa_stats_mode;
> +	if (__parse_vm_numa_stats_mode((char *)table->data)) {
> +		/*
> +		 * invalid sysctl_vm_numa_stats_mode value, restore saved string
> +		 */
> +		strncpy((char *)table->data, old_string, VM_NUMA_STAT_MODE_LEN);
> +		vm_numa_stats_mode = oldval;

Do we need to restore vm_numa_stats_mode? AFAICS it didn't change. Also,
should the EINVAL be returned also to userspace? (not sure what's the
API here, hmm man 2 sysctl doesn't list EINVAL...)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
