Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 83AA76B02B4
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:49:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id q189so1015623wmd.6
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 02:49:43 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id c62si1014000wmh.228.2017.08.15.02.49.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 02:49:42 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id CB96C992C7
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 09:49:41 +0000 (UTC)
Date: Tue, 15 Aug 2017 10:49:41 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm: Change the call sites of numa statistics items
Message-ID: <20170815094941.scnrzybtvwa2wfip@techsingularity.net>
References: <1502786736-21585-1-git-send-email-kemi.wang@intel.com>
 <1502786736-21585-2-git-send-email-kemi.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1502786736-21585-2-git-send-email-kemi.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, Aug 15, 2017 at 04:45:35PM +0800, Kemi Wang wrote:
> In this patch,  NUMA statistics is separated from zone statistics
> framework, all the call sites of NUMA stats are changed to use
> numa-stats-specific functions, it does not have any functionality change
> except that the value of NUMA stats is shown behind zone page stats, and
> the threshold size of NUMA stats is shown behind pcp threshold when users
> *read* the zone info.
> 
> E.g. cat /proc/zoneinfo
>     ***Base***                           ***With this patch***
> nr_free_pages 3976                         nr_free_pages 3976
> nr_zone_inactive_anon 0                    nr_zone_inactive_anon 0
> nr_zone_active_anon 0                      nr_zone_active_anon 0
> nr_zone_inactive_file 0                    nr_zone_inactive_file 0
> nr_zone_active_file 0                      nr_zone_active_file 0
> nr_zone_unevictable 0                      nr_zone_unevictable 0
> nr_zone_write_pending 0                    nr_zone_write_pending 0
> nr_mlock     0                             nr_mlock     0
> nr_page_table_pages 0                      nr_page_table_pages 0
> nr_kernel_stack 0                          nr_kernel_stack 0
> nr_bounce    0                             nr_bounce    0
> nr_zspages   0                             nr_zspages   0
> numa_hit 0                                *nr_free_cma  0*
> numa_miss 0                                numa_hit     0
> numa_foreign 0                             numa_miss    0
> numa_interleave 0                          numa_foreign 0
> numa_local   0                             numa_interleave 0
> numa_other   0                             numa_local   0
> *nr_free_cma 0*                            numa_other 0
>     ...                                        ...
> vm stats threshold: 10                     vm stats threshold: 10
>     ...                                   *vm numa stats threshold: 10*
>                                                ...
> 
> The next patch updates the numa stats counter size and threshold.
> 
> Signed-off-by: Kemi Wang <kemi.wang@intel.com>
> ---
>  drivers/base/node.c    |  22 ++++---
>  include/linux/mmzone.h |  25 +++++---
>  include/linux/vmstat.h |  29 +++++++++
>  mm/page_alloc.c        |  10 +--
>  mm/vmstat.c            | 167 +++++++++++++++++++++++++++++++++++++++++++++++--
>  5 files changed, 227 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index d8dc830..12080c6 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -160,12 +160,12 @@ static ssize_t node_read_numastat(struct device *dev,
>  		       "interleave_hit %lu\n"
>  		       "local_node %lu\n"
>  		       "other_node %lu\n",
> -		       sum_zone_node_page_state(dev->id, NUMA_HIT),
> -		       sum_zone_node_page_state(dev->id, NUMA_MISS),
> -		       sum_zone_node_page_state(dev->id, NUMA_FOREIGN),
> -		       sum_zone_node_page_state(dev->id, NUMA_INTERLEAVE_HIT),
> -		       sum_zone_node_page_state(dev->id, NUMA_LOCAL),
> -		       sum_zone_node_page_state(dev->id, NUMA_OTHER));
> +		       sum_zone_node_numa_state(dev->id, NUMA_HIT),
> +		       sum_zone_node_numa_state(dev->id, NUMA_MISS),
> +		       sum_zone_node_numa_state(dev->id, NUMA_FOREIGN),
> +		       sum_zone_node_numa_state(dev->id, NUMA_INTERLEAVE_HIT),
> +		       sum_zone_node_numa_state(dev->id, NUMA_LOCAL),
> +		       sum_zone_node_numa_state(dev->id, NUMA_OTHER));
>  }

The names are very similar and it would be preferred if the names were
visually different like sum_zone_numa_stat() which is hard to confuse with
the zone stat fields.

>  static DEVICE_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
>  
> @@ -181,9 +181,17 @@ static ssize_t node_read_vmstat(struct device *dev,
>  		n += sprintf(buf+n, "%s %lu\n", vmstat_text[i],
>  			     sum_zone_node_page_state(nid, i));
>  
> -	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
> +#ifdef CONFIG_NUMA
> +	for (i = 0; i < NR_VM_ZONE_NUMA_STAT_ITEMS; i++)
>  		n += sprintf(buf+n, "%s %lu\n",
>  			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS],
> +			     sum_zone_node_numa_state(nid, i));
> +#endif

Similar with NR_VM_ZONE_NUMA_STAT_ITEMS, it's too similar to
NR_VM_NODE_STAT_ITEMS.

> +
> +	for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++)
> +		n += sprintf(buf+n, "%s %lu\n",
> +			     vmstat_text[i + NR_VM_ZONE_STAT_ITEMS +
> +			     NR_VM_ZONE_NUMA_STAT_ITEMS],
>  			     node_page_state(pgdat, i));
>  
>  	return n;
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index fc14b8b..0b11ba7 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -114,6 +114,20 @@ struct zone_padding {
>  #define ZONE_PADDING(name)
>  #endif
>  
> +#ifdef CONFIG_NUMA
> +enum zone_numa_stat_item {
> +	NUMA_HIT,		/* allocated in intended node */
> +	NUMA_MISS,		/* allocated in non intended node */
> +	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
> +	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
> +	NUMA_LOCAL,		/* allocation from local node */
> +	NUMA_OTHER,		/* allocation from other node */
> +	NR_VM_ZONE_NUMA_STAT_ITEMS
> +};
> +#else
> +#define NR_VM_ZONE_NUMA_STAT_ITEMS 0
> +#endif
> +
>  enum zone_stat_item {
>  	/* First 128 byte cacheline (assuming 64 bit words) */
>  	NR_FREE_PAGES,
> @@ -132,14 +146,6 @@ enum zone_stat_item {
>  #if IS_ENABLED(CONFIG_ZSMALLOC)
>  	NR_ZSPAGES,		/* allocated in zsmalloc */
>  #endif
> -#ifdef CONFIG_NUMA
> -	NUMA_HIT,		/* allocated in intended node */
> -	NUMA_MISS,		/* allocated in non intended node */
> -	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
> -	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
> -	NUMA_LOCAL,		/* allocation from local node */
> -	NUMA_OTHER,		/* allocation from other node */
> -#endif
>  	NR_FREE_CMA_PAGES,
>  	NR_VM_ZONE_STAT_ITEMS };
>  
> @@ -276,6 +282,8 @@ struct per_cpu_pageset {
>  	struct per_cpu_pages pcp;
>  #ifdef CONFIG_NUMA
>  	s8 expire;
> +	s8 numa_stat_threshold;
> +	s8 vm_numa_stat_diff[NR_VM_ZONE_NUMA_STAT_ITEMS];
>  #endif
>  #ifdef CONFIG_SMP
>  	s8 stat_threshold;

Ok. this slightly increases the size of the per_cpu_pageset due to
numa_stat_threshold. The structure occupes 2 cache lines and still occupies
2 cache lines afterwards so that is ok but consider hard-coding the value
of it. The locality stats are never used as part of a decision made by the
kernel and they get summed when reading proc unconditionally. There is little
benefit to tuning that threshold at all and there should be a very small
performance gain if it's removed because it'll be a compile-time constant.

The rest of the patch is mostly mechanical.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
