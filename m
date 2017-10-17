Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D12436B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 03:54:25 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r18so904672pgu.9
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 00:54:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w22si5159059pge.298.2017.10.17.00.54.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 00:54:24 -0700 (PDT)
Date: Tue, 17 Oct 2017 09:54:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mm, sysctl: make NUMA stats configurable
Message-ID: <20171017075420.dege7aabzau5wrss@dhcp22.suse.cz>
References: <1508203258-9444-1-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508203258-9444-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue 17-10-17 09:20:58, Kemi Wang wrote:
[...]

Other than two remarks below, it looks good to me and it also looks
simpler.

> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 4bb13e7..e746ed1 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -32,6 +32,76 @@
>  
>  #define NUMA_STATS_THRESHOLD (U16_MAX - 2)
>  
> +#ifdef CONFIG_NUMA
> +int sysctl_vm_numa_stat = ENABLE_NUMA_STAT;
> +static DEFINE_MUTEX(vm_numa_stat_lock);

You can scope this mutex to the sysctl handler function

> +int sysctl_vm_numa_stat_handler(struct ctl_table *table, int write,
> +		void __user *buffer, size_t *length, loff_t *ppos)
> +{
> +	int ret, oldval;
> +
> +	mutex_lock(&vm_numa_stat_lock);
> +	if (write)
> +		oldval = sysctl_vm_numa_stat;
> +	ret = proc_dointvec(table, write, buffer, length, ppos);
> +	if (ret || !write)
> +		goto out;
> +
> +	if (oldval == sysctl_vm_numa_stat)
> +		goto out;
> +	else if (oldval == DISABLE_NUMA_STAT) {

So basically any value will enable numa stats. This means that we would
never be able to extend this interface to e.g. auto mode (say value 2).
I guess you meant to check sysctl_vm_numa_stat == ENABLE_NUMA_STAT?

> +		static_branch_enable(&vm_numa_stat_key);
> +		pr_info("enable numa statistics\n");
> +	} else if (sysctl_vm_numa_stat == DISABLE_NUMA_STAT) {
> +		static_branch_disable(&vm_numa_stat_key);
> +		invalid_numa_statistics();
> +		pr_info("disable numa statistics, and clear numa counters\n");
> +	}
> +
> +out:
> +	mutex_unlock(&vm_numa_stat_lock);
> +	return ret;
> +}
> +#endif
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
