Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 666C56B0044
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 01:27:23 -0400 (EDT)
Message-ID: <505AAA8B.4020005@cn.fujitsu.com>
Date: Thu, 20 Sep 2012 13:32:59 +0800
From: Wen Congyang <wency@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: fix zone stat mismatch
References: <1348039748-32111-1-git-send-email-minchan@kernel.org> <CAHGf_=oSSsJEeh7eN+R6P3n0vq2h5+3DPmogpXqDiu1jJyKmpg@mail.gmail.com> <20120919201738.GA2425@barrios> <505A6EB7.5070305@cn.fujitsu.com> <20120920023053.GD13234@bbox> <505A89A8.8070008@cn.fujitsu.com> <20120920051628.GE13234@bbox>
In-Reply-To: <20120920051628.GE13234@bbox>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Shaohua Li <shli@fusionio.com>

At 09/20/2012 01:16 PM, Minchan Kim Wrote:
> On Thu, Sep 20, 2012 at 11:12:40AM +0800, Wen Congyang wrote:
>> At 09/20/2012 10:30 AM, Minchan Kim Wrote:
>>> On Thu, Sep 20, 2012 at 09:17:43AM +0800, Wen Congyang wrote:
>>>> At 09/20/2012 04:17 AM, Minchan Kim Wrote:
>>>>> Hi KOSAKI,
>>>>>
>>>>> On Wed, Sep 19, 2012 at 02:05:20PM -0400, KOSAKI Motohiro wrote:
>>>>>> On Wed, Sep 19, 2012 at 3:29 AM, Minchan Kim <minchan@kernel.org> wrote:
>>>>>>> During memory-hotplug stress test, I found NR_ISOLATED_[ANON|FILE]
>>>>>>> are increasing so that kernel are hang out.
>>>>>>>
>>>>>>> The cause is that when we do memory-hotadd after memory-remove,
>>>>>>> __zone_pcp_update clear out zone's ZONE_STAT_ITEMS in setup_pageset
>>>>>>> without draining vm_stat_diff of all CPU.
>>>>>>>
>>>>>>> This patch fixes it.
>>>>>>
>>>>>> zone_pcp_update() is called from online pages path. but IMHO,
>>>>>> the statistics should be drained offline path. isn't it?
>>>>>
>>>>> It isn't necessary because statistics is right until we reset it to zero
>>>>> in online path.
>>>>> Do you have something on your mind that we have to drain it in offline path?
>>>>
>>>> When a node is offlined and onlined again. We create node_data[i] in the
>>>
>>> I would like to clarify your word.
>>> Create or recreate?
>>> Why I have a question is as I look over the source code, hotadd_new_pgdat
>>> seem to be called if we do hotadd *new* memory. It's not the case for
>>> offline and online again you mentioned. If you're right, I should find 
>>> arch_free_nodedata to free pgdat when node is disappear but I can't find it.
>>> Do I miss something?
>>
>> Hmm, when a memory is removed, we don't do cleanup now. We(Fujitsu) posted
>> a patchset to do this:
>> https://lkml.org/lkml/2012/9/5/201
>>
>> We don't free pgdat in this patchset now. We have two choice:
>> 1. free pgdat
>> 2. don't free it, and reuse it when it is onlined again
>>
>> I'm not sure which choice is better.
> 
> I have no idea because I don't know how you guys uses.
> If there is use case that sometime you ues many node burstly but
> ues a few node in most time, 1) would be good POV memory efficiency
> although it makes code rather complicated.
> 
> Anyway, it's another story with this patch because it's not merged yet.
> 
>>
>>>
>>>
>>>> function hotadd_new_pgdat(), and we will lost the statistics stored in
>>>> zone->pageset. So we should drain it in offline path.
>>>
>>> Even we drain in offline patch, it still has a problem.
>>>
>>> 1. offline
>>> 2. drain -> OKAY 
>>> 3. schedule
>>> 4. Process A increase zone stat
>>> 5. Process B increase zone stat
>>> 6. online
>>> 7. reset it -> we ends up lost zone stat counter which is modified between 2-6
>>>
>>
>> I understand why you drain it in online path now. But it still should drain it
>> in offline path because if all pages in this zone are offlined, we will call
>> zone_pcp_reset() to reset zone's pcp. We should also drop it in the function
>> zone_pcp_reset().
> 
> Good point.
> How about this?
> 
>>From e92bf3e96720c89cb18ec32c5db095a27ad4133c Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Thu, 20 Sep 2012 14:11:49 +0900
> Subject: [PATCH v2] memory-hotplug: fix zone stat mismatch
> 
> During memory-hotplug, I found NR_ISOLATED_[ANON|FILE]
> are increasing so that kernel are hang out.
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
> * from v1
>   * drain offline patch - KOSAKI, Wen
> 
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: Wen Congyang <wency@cn.fujitsu.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  include/linux/vmstat.h |    4 ++++
>  mm/page_alloc.c        |    7 +++++++
>  mm/vmstat.c            |   12 ++++++++++++
>  3 files changed, 23 insertions(+)
> 
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index ad2cfd5..5d31876 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -198,6 +198,8 @@ extern void __dec_zone_state(struct zone *, enum zone_stat_item);
>  void refresh_cpu_vm_stats(int);
>  void refresh_zone_stat_thresholds(void);
>  
> +void drain_zonestat(struct zone *zone, struct per_cpu_pageset *);
> +
>  int calculate_pressure_threshold(struct zone *zone);
>  int calculate_normal_threshold(struct zone *zone);
>  void set_pgdat_percpu_threshold(pg_data_t *pgdat,
> @@ -251,6 +253,8 @@ static inline void __dec_zone_page_state(struct page *page,
>  static inline void refresh_cpu_vm_stats(int cpu) { }
>  static inline void refresh_zone_stat_thresholds(void) { }
>  
> +static inline void drain_zonestat(struct zone *zone,
> +			struct per_cpu_pageset *pset) { }
>  #endif		/* CONFIG_SMP */
>  
>  extern const char * const vmstat_text[];
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ab58346..980f2e7 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5904,6 +5904,7 @@ static int __meminit __zone_pcp_update(void *data)
>  		local_irq_save(flags);
>  		if (pcp->count > 0)
>  			free_pcppages_bulk(zone, pcp->count, pcp);
> +		drain_zonestat(zone, pset);
>  		setup_pageset(pset, batch);
>  		local_irq_restore(flags);
>  	}
> @@ -5920,10 +5921,16 @@ void __meminit zone_pcp_update(struct zone *zone)
>  void zone_pcp_reset(struct zone *zone)
>  {
>  	unsigned long flags;
> +	int cpu;
> +	struct per_cpu_pageset *pset;
>  
>  	/* avoid races with drain_pages()  */
>  	local_irq_save(flags);
>  	if (zone->pageset != &boot_pageset) {
> +		for_each_online_cpu(cpu) {

A cpu can be offlined before the pages in the zone are offlined. So
I think you should drain it on all possible cpu, not online cpu.

Thanks
Wen Congyang

> +			pset = per_cpu_ptr(zone->pageset, cpu);
> +			drain_zonestat(zone, pset);
> +		}
>  		free_percpu(zone->pageset);
>  		zone->pageset = &boot_pageset;
>  	}
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index b3e3b9d..d4cc1c2 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -495,6 +495,18 @@ void refresh_cpu_vm_stats(int cpu)
>  			atomic_long_add(global_diff[i], &vm_stat[i]);
>  }
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
>  #endif
>  
>  #ifdef CONFIG_NUMA

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
