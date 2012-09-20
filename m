Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 43E276B0044
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 03:21:35 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5D9253EE0BC
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 16:21:33 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 44B8D45DE54
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 16:21:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D21845DD78
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 16:21:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B2741DB8038
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 16:21:33 +0900 (JST)
Received: from g01jpexchkw04.g01.fujitsu.local (g01jpexchkw04.g01.fujitsu.local [10.0.194.43])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B64571DB803E
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 16:21:32 +0900 (JST)
Message-ID: <505AC3E9.4030009@jp.fujitsu.com>
Date: Thu, 20 Sep 2012 16:21:13 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3] memory-hotplug: fix zone stat mismatch
References: <1348123405-30641-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1348123405-30641-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Hi Minchan,

Sorry for late reply.

2012/09/20 15:43, Minchan Kim wrote:
> During memory-hotplug, I found NR_ISOLATED_[ANON|FILE]
> are increasing so that kernel are hang out.

Why does your system hang out by increasing NR_ISOLATED_[ANON|FILE]?
I cannot understand what has happened by your system.

Thanks,
Yasuaki Ishimatsu

> 
> The cause is that when we do memory-hotadd after memory-remove,
> __zone_pcp_update clear out zone's ZONE_STAT_ITEMS in setup_pageset
> although vm_stat_diff of all CPU still have value.
> 
> In addtion, when we offline all pages of the zone, we reset them
> in zone_pcp_reset without drain so that we lost zone stat item.
> 
> This patch fixes it.
> 
> * from v2
>    * Add Reviewed-by - Wen
> 
> * from v1
>    * drain offline patch - KOSAKI, Wen
> 
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>   include/linux/vmstat.h |    4 ++++
>   mm/page_alloc.c        |    7 +++++++
>   mm/vmstat.c            |   12 ++++++++++++
>   3 files changed, 23 insertions(+)
> 
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index ad2cfd5..5d31876 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -198,6 +198,8 @@ extern void __dec_zone_state(struct zone *, enum zone_stat_item);
>   void refresh_cpu_vm_stats(int);
>   void refresh_zone_stat_thresholds(void);
>   
> +void drain_zonestat(struct zone *zone, struct per_cpu_pageset *);
> +
>   int calculate_pressure_threshold(struct zone *zone);
>   int calculate_normal_threshold(struct zone *zone);
>   void set_pgdat_percpu_threshold(pg_data_t *pgdat,
> @@ -251,6 +253,8 @@ static inline void __dec_zone_page_state(struct page *page,
>   static inline void refresh_cpu_vm_stats(int cpu) { }
>   static inline void refresh_zone_stat_thresholds(void) { }
>   
> +static inline void drain_zonestat(struct zone *zone,
> +			struct per_cpu_pageset *pset) { }
>   #endif		/* CONFIG_SMP */
>   
>   extern const char * const vmstat_text[];
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ab58346..980f2e7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5904,6 +5904,7 @@ static int __meminit __zone_pcp_update(void *data)
>   		local_irq_save(flags);
>   		if (pcp->count > 0)
>   			free_pcppages_bulk(zone, pcp->count, pcp);
> +		drain_zonestat(zone, pset);
>   		setup_pageset(pset, batch);
>   		local_irq_restore(flags);
>   	}
> @@ -5920,10 +5921,16 @@ void __meminit zone_pcp_update(struct zone *zone)
>   void zone_pcp_reset(struct zone *zone)
>   {
>   	unsigned long flags;
> +	int cpu;
> +	struct per_cpu_pageset *pset;
>   
>   	/* avoid races with drain_pages()  */
>   	local_irq_save(flags);
>   	if (zone->pageset != &boot_pageset) {
> +		for_each_online_cpu(cpu) {
> +			pset = per_cpu_ptr(zone->pageset, cpu);
> +			drain_zonestat(zone, pset);
> +		}
>   		free_percpu(zone->pageset);
>   		zone->pageset = &boot_pageset;
>   	}
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index b3e3b9d..d4cc1c2 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -495,6 +495,18 @@ void refresh_cpu_vm_stats(int cpu)
>   			atomic_long_add(global_diff[i], &vm_stat[i]);
>   }
>   
> +void drain_zonestat(struct zone *zone, struct per_cpu_pageset *pset)
> +{
> +	int i;
> +
> +	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
> +		if (pset->vm_stat_diff[i]) {
> +			int v = pset->vm_stat_diff[i];
> +			pset->vm_stat_diff[i] = 0;
> +			atomic_long_add(v, &zone->vm_stat[i]);
> +			atomic_long_add(v, &vm_stat[i]);
> +		}
> +}
>   #endif
>   
>   #ifdef CONFIG_NUMA
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
