Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B47AE6B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 05:23:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u138so7346295wmu.2
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 02:23:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 89si10671393wrl.304.2017.10.03.02.23.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 02:23:55 -0700 (PDT)
Date: Tue, 3 Oct 2017 11:23:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm, sysctl: make NUMA stats configurable
Message-ID: <20171003092352.2wh2jbtt2dudfi5a@dhcp22.suse.cz>
References: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506579101-5457-1-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu 28-09-17 14:11:41, Kemi Wang wrote:
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

I am still not convinced the auto mode is worth all the additional code
and a safe default to use. The whole thing could have been 0/1 with a
simpler parsing and less code to catch readers.

E.g. why do we have to do static_branch_enable on any read or even
vmstat_stop? Wouldn't open be sufficient?

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
[...]
> @@ -1582,6 +1703,10 @@ static int zoneinfo_show(struct seq_file *m, void *arg)
>  {
>  	pg_data_t *pgdat = (pg_data_t *)arg;
>  	walk_zones_in_node(m, pgdat, false, false, zoneinfo_show_print);
> +#ifdef CONFIG_NUMA
> +	if (vm_numa_stats_mode == VM_NUMA_STAT_AUTO_MODE)
> +		static_branch_enable(&vm_numa_stats_mode_key);
> +#endif
>  	return 0;
>  }
>  
> @@ -1678,6 +1803,10 @@ static int vmstat_show(struct seq_file *m, void *arg)
>  
>  static void vmstat_stop(struct seq_file *m, void *arg)
>  {
> +#ifdef CONFIG_NUMA
> +	if (vm_numa_stats_mode == VM_NUMA_STAT_AUTO_MODE)
> +		static_branch_enable(&vm_numa_stats_mode_key);
> +#endif
>  	kfree(m->private);
>  	m->private = NULL;
>  }
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
