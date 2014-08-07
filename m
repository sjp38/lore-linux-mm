Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3ED496B0035
	for <linux-mm@kvack.org>; Wed,  6 Aug 2014 22:12:41 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so4474375pac.4
        for <linux-mm@kvack.org>; Wed, 06 Aug 2014 19:12:40 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id ku5si2226713pbc.174.2014.08.06.19.12.39
        for <linux-mm@kvack.org>;
        Wed, 06 Aug 2014 19:12:40 -0700 (PDT)
Message-ID: <53E2E042.3070803@cn.fujitsu.com>
Date: Thu, 7 Aug 2014 10:11:14 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/8] mm/page_alloc: fix pcp high, batch management
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com> <1407309517-3270-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1407309517-3270-7-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Joonsoo,

On 08/06/2014 03:18 PM, Joonsoo Kim wrote:
> per cpu pages structure, aka pcp, has high and batch values to control
> how many pages we perform caching. This values could be updated
> asynchronously and updater should ensure that this doesn't make any
> problem. For this purpose, pageset_update() is implemented and do some
> memory synchronization. But, it turns out to be wrong when I implemented
> new feature using this. There is no corresponding smp_rmb() in read-side

Out of curiosity, what new feature are you implementing?

IIRC, pageset_update() is used to update high and batch which can be changed
during:

system boot
sysfs
memory hot-plug

So it seems to me that the latter two would have the problems you described here.

Thanks.

> so that it can't guarantee anything. Without correct updating, system
> could hang in free_pcppages_bulk() due to larger batch value than high.
> To properly update this values, we need to synchronization primitives on
> read-side, but, it hurts allocator's fastpath.
> 
> There is another choice for synchronization, that is, sending IPI. This
> is somewhat expensive, but, this is really rare case so I guess it has
> no problem here. However, reducing IPI is very helpful here. Current
> logic handles each CPU's pcp update one by one. To reduce sending IPI,
> we need to re-ogranize the code to handle all CPU's pcp update at one go.
> This patch implement these requirements.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/page_alloc.c |  139 ++++++++++++++++++++++++++++++++-----------------------
>  1 file changed, 80 insertions(+), 59 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e6fee4b..3e1e344 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3800,7 +3800,7 @@ static void build_zonelist_cache(pg_data_t *pgdat)
>   * not check if the processor is online before following the pageset pointer.
>   * Other parts of the kernel may not check if the zone is available.
>   */
> -static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch);
> +static void setup_pageset(struct per_cpu_pageset __percpu *pcp);
>  static DEFINE_PER_CPU(struct per_cpu_pageset, boot_pageset);
>  static void setup_zone_pageset(struct zone *zone);
>  
> @@ -3846,9 +3846,9 @@ static int __build_all_zonelists(void *data)
>  	 * needs the percpu allocator in order to allocate its pagesets
>  	 * (a chicken-egg dilemma).
>  	 */
> -	for_each_possible_cpu(cpu) {
> -		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
> +	setup_pageset(&boot_pageset);
>  
> +	for_each_possible_cpu(cpu) {
>  #ifdef CONFIG_HAVE_MEMORYLESS_NODES
>  		/*
>  		 * We now know the "local memory node" for each node--
> @@ -4230,24 +4230,59 @@ static int zone_batchsize(struct zone *zone)
>   * outside of boot time (or some other assurance that no concurrent updaters
>   * exist).
>   */
> -static void pageset_update(struct per_cpu_pages *pcp, unsigned long high,
> -		unsigned long batch)
> +static void pageset_update(struct zone *zone, int high, int batch)
>  {
> -       /* start with a fail safe value for batch */
> -	pcp->batch = 1;
> -	smp_wmb();
> +	int cpu;
> +	struct per_cpu_pages *pcp;
> +
> +	/* start with a fail safe value for batch */
> +	for_each_possible_cpu(cpu) {
> +		pcp = &per_cpu_ptr(zone->pageset, cpu)->pcp;
> +		pcp->batch = 1;
> +	}
> +	kick_all_cpus_sync();
> +
> +	/* Update high, then batch, in order */
> +	for_each_possible_cpu(cpu) {
> +		pcp = &per_cpu_ptr(zone->pageset, cpu)->pcp;
> +		pcp->high = high;
> +	}
> +	kick_all_cpus_sync();
>  
> -       /* Update high, then batch, in order */
> -	pcp->high = high;
> -	smp_wmb();
> +	for_each_possible_cpu(cpu) {
> +		pcp = &per_cpu_ptr(zone->pageset, cpu)->pcp;
> +		pcp->batch = batch;
> +	}
> +}
> +
> +/*
> + * pageset_get_values_by_high() gets the high water mark for
> + * hot per_cpu_pagelist to the value high for the pageset p.
> + */
> +static void pageset_get_values_by_high(int input_high,
> +				int *output_high, int *output_batch)
> +{
> +	*output_batch = max(1, input_high / 4);
> +	if ((input_high / 4) > (PAGE_SHIFT * 8))
> +		*output_batch = PAGE_SHIFT * 8;
> +}
>  
> -	pcp->batch = batch;
> +/* a companion to pageset_get_values_by_high() */
> +static void pageset_get_values_by_batch(int input_batch,
> +				int *output_high, int *output_batch)
> +{
> +	*output_high = 6 * input_batch;
> +	*output_batch = max(1, 1 * input_batch);
>  }
>  
> -/* a companion to pageset_set_high() */
> -static void pageset_set_batch(struct per_cpu_pageset *p, unsigned long batch)
> +static void pageset_get_values(struct zone *zone, int *high, int *batch)
>  {
> -	pageset_update(&p->pcp, 6 * batch, max(1UL, 1 * batch));
> +	if (percpu_pagelist_fraction) {
> +		pageset_get_values_by_high(
> +			(zone->managed_pages / percpu_pagelist_fraction),
> +			high, batch);
> +	} else
> +		pageset_get_values_by_batch(zone_batchsize(zone), high, batch);
>  }
>  
>  static void pageset_init(struct per_cpu_pageset *p)
> @@ -4263,51 +4298,38 @@ static void pageset_init(struct per_cpu_pageset *p)
>  		INIT_LIST_HEAD(&pcp->lists[migratetype]);
>  }
>  
> -static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
> +/* Use this only in boot time, because it doesn't do any synchronization */
> +static void setup_pageset(struct per_cpu_pageset __percpu *pcp)
>  {
> -	pageset_init(p);
> -	pageset_set_batch(p, batch);
> -}
> -
> -/*
> - * pageset_set_high() sets the high water mark for hot per_cpu_pagelist
> - * to the value high for the pageset p.
> - */
> -static void pageset_set_high(struct per_cpu_pageset *p,
> -				unsigned long high)
> -{
> -	unsigned long batch = max(1UL, high / 4);
> -	if ((high / 4) > (PAGE_SHIFT * 8))
> -		batch = PAGE_SHIFT * 8;
> -
> -	pageset_update(&p->pcp, high, batch);
> -}
> -
> -static void pageset_set_high_and_batch(struct zone *zone,
> -				       struct per_cpu_pageset *pcp)
> -{
> -	if (percpu_pagelist_fraction)
> -		pageset_set_high(pcp,
> -			(zone->managed_pages /
> -				percpu_pagelist_fraction));
> -	else
> -		pageset_set_batch(pcp, zone_batchsize(zone));
> -}
> +	int cpu;
> +	int high, batch;
> +	struct per_cpu_pageset *p;
>  
> -static void __meminit zone_pageset_init(struct zone *zone, int cpu)
> -{
> -	struct per_cpu_pageset *pcp = per_cpu_ptr(zone->pageset, cpu);
> +	pageset_get_values_by_batch(0, &high, &batch);
>  
> -	pageset_init(pcp);
> -	pageset_set_high_and_batch(zone, pcp);
> +	for_each_possible_cpu(cpu) {
> +		p = per_cpu_ptr(pcp, cpu);
> +		pageset_init(p);
> +		p->pcp.high = high;
> +		p->pcp.batch = batch;
> +	}
>  }
>  
>  static void __meminit setup_zone_pageset(struct zone *zone)
>  {
>  	int cpu;
> +	int high, batch;
> +	struct per_cpu_pageset *p;
> +
> +	pageset_get_values(zone, &high, &batch);
> +
>  	zone->pageset = alloc_percpu(struct per_cpu_pageset);
> -	for_each_possible_cpu(cpu)
> -		zone_pageset_init(zone, cpu);
> +	for_each_possible_cpu(cpu) {
> +		p = per_cpu_ptr(zone->pageset, cpu);
> +		pageset_init(p);
> +		p->pcp.high = high;
> +		p->pcp.batch = batch;
> +	}
>  }
>  
>  /*
> @@ -5928,11 +5950,10 @@ int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *table, int write,
>  		goto out;
>  
>  	for_each_populated_zone(zone) {
> -		unsigned int cpu;
> +		int high, batch;
>  
> -		for_each_possible_cpu(cpu)
> -			pageset_set_high_and_batch(zone,
> -					per_cpu_ptr(zone->pageset, cpu));
> +		pageset_get_values(zone, &high, &batch);
> +		pageset_update(zone, high, batch);
>  	}
>  out:
>  	mutex_unlock(&pcp_batch_high_lock);
> @@ -6455,11 +6476,11 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
>   */
>  void __meminit zone_pcp_update(struct zone *zone)
>  {
> -	unsigned cpu;
> +	int high, batch;
> +
>  	mutex_lock(&pcp_batch_high_lock);
> -	for_each_possible_cpu(cpu)
> -		pageset_set_high_and_batch(zone,
> -				per_cpu_ptr(zone->pageset, cpu));
> +	pageset_get_values(zone, &high, &batch);
> +	pageset_update(zone, high, batch);
>  	mutex_unlock(&pcp_batch_high_lock);
>  }
>  #endif
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
