Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0607B6B0033
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 07:49:59 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g50so2216386wra.4
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 04:49:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si1152092edj.203.2017.09.15.04.49.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 04:49:57 -0700 (PDT)
Date: Fri, 15 Sep 2017 13:49:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, sysctl: make VM stats configurable
Message-ID: <20170915114952.czb7nbsioqguxxk3@dhcp22.suse.cz>
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
 <1505467406-9945-2-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1505467406-9945-2-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Fri 15-09-17 17:23:24, Kemi Wang wrote:
> This patch adds a tunable interface that allows VM stats configurable, as
> suggested by Dave Hansen and Ying Huang.
> 
> When performance becomes a bottleneck and you can tolerate some possible
> tool breakage and some decreased counter precision (e.g. numa counter), you
> can do:
> 	echo [C|c]oarse > /proc/sys/vm/vmstat_mode
> 
> When performance is not a bottleneck and you want all tooling to work, you
> can do:
> 	echo [S|s]trict > /proc/sys/vm/vmstat_mode
> 
> We recommend automatic detection of virtual memory statistics by system,
> this is also system default configuration, you can do:
> 	echo [A|a]uto > /proc/sys/vm/vmstat_mode
> 
> The next patch handles numa statistics distinctively based-on different VM
> stats mode.

I would just merge this with the second patch so that it is clear how
those modes are implemented. I am also wondering why cannot we have a
much simpler interface and implementation to enable/disable numa stats
(btw. sysctl_vm_numa_stats would be more descriptive IMHO).

Why do we need an auto-mode? Is it safe to enforce by default. Is it
possible that userspace can get confused to see 0 NUMA stats in the
first read while other allocation stats are non-zero?
 
> Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> Suggested-by: Ying Huang <ying.huang@intel.com>
> Signed-off-by: Kemi Wang <kemi.wang@intel.com>
> ---
>  include/linux/vmstat.h | 14 ++++++++++
>  kernel/sysctl.c        |  7 +++++
>  mm/vmstat.c            | 70 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 91 insertions(+)
> 
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index ade7cb5..c3634c7 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -9,6 +9,20 @@
>  
>  extern int sysctl_stat_interval;
>  
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
> +extern char sysctl_vmstat_mode[];
> +extern int sysctl_vmstat_mode_handler(struct ctl_table *table, int write,
> +		void __user *buffer, size_t *length, loff_t *ppos);
> +
>  #ifdef CONFIG_VM_EVENT_COUNTERS
>  /*
>   * Light weight per cpu counter implementation.
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
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 4bb13e7..e675ad2 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -32,6 +32,76 @@
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
> +	if (strcmp(str, "auto") == 0 || strcmp(str, "Auto") == 0)
> +		vmstat_mode = VMSTAT_AUTO_MODE;
> +	else if (strcmp(str, "strict") == 0 || strcmp(str, "Strict") == 0)
> +		vmstat_mode = VMSTAT_STRICT_MODE;
> +	else if (strcmp(str, "coarse") == 0 || strcmp(str, "Coarse") == 0)
> +		vmstat_mode = VMSTAT_COARSE_MODE;
> +	else {
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
> +		} else if (vmstat_mode == VMSTAT_AUTO_MODE)
> +			pr_info("vmstat mode changes from %s to auto mode\n",
> +					vmstat_mode_name[oldval]);
> +		else if (vmstat_mode == VMSTAT_STRICT_MODE)
> +			pr_info("vmstat mode changes from %s to strict mode\n",
> +					vmstat_mode_name[oldval]);
> +		else if (vmstat_mode == VMSTAT_COARSE_MODE)
> +			pr_info("vmstat mode changes from %s to coarse mode\n",
> +					vmstat_mode_name[oldval]);
> +		else
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
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
