Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id B24386B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 05:48:34 -0400 (EDT)
Message-ID: <500E6F1A.5060206@huawei.com>
Date: Tue, 24 Jul 2012 17:47:06 +0800
From: Jiang Liu <jiang.liu@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] mm/hotplug: free zone->pageset when a zone becomes
 empty
References: <1341481532-1700-1-git-send-email-jiang.liu@huawei.com> <1341481532-1700-3-git-send-email-jiang.liu@huawei.com> <CAA_GA1eePmUsYWrSg2k6TTER+ejciWg2bvGc+1zaAKS8kLNRKw@mail.gmail.com>
In-Reply-To: <CAA_GA1eePmUsYWrSg2k6TTER+ejciWg2bvGc+1zaAKS8kLNRKw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Bjorn Helgaas <bhelgaas@google.com>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>, Wei Wang <Bessel.Wang@huawei.com>

Hi Bob,
	Yes, we need to handle the wait table too. We has tried to remove the
pgdat and wait table altogether, but found it's really hard to remove pgdat
for empty nodes. I think the candidate solution is to free wait table but
keep pgdat. Any suggestions?
	Thanks!
	Gerry

On 2012-7-19 15:58, Bob Liu wrote:
> On Thu, Jul 5, 2012 at 5:45 PM, Jiang Liu <jiang.liu@huawei.com> wrote:
>> When a zone becomes empty after memory offlining, free zone->pageset.
>> Otherwise it will cause memory leak when adding memory to the empty
>> zone again because build_all_zonelists() will allocate zone->pageset
>> for an empty zone.
>>
> 
> What about other area allocated to the zone?  eg. wait_table?
> 
>> Signed-off-by: Jiang Liu <liuj97@gmail.com>
>> Signed-off-by: Wei Wang <Bessel.Wang@huawei.com>
>> ---
>>  include/linux/mm.h  |    1 +
>>  mm/memory_hotplug.c |    3 +++
>>  mm/page_alloc.c     |   13 +++++++++++++
>>  3 files changed, 17 insertions(+), 0 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index b36d08c..f8b62f2 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1331,6 +1331,7 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
>>  extern void setup_per_cpu_pageset(void);
>>
>>  extern void zone_pcp_update(struct zone *zone);
>> +extern void zone_pcp_reset(struct zone *zone);
>>
>>  /* nommu.c */
>>  extern atomic_long_t mmap_pages_allocated;
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index bce80c7..998b792 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -966,6 +966,9 @@ repeat:
>>
>>         init_per_zone_wmark_min();
>>
>> +       if (!populated_zone(zone))
>> +               zone_pcp_reset(zone);
>> +
>>         if (!node_present_pages(node)) {
>>                 node_clear_state(node, N_HIGH_MEMORY);
>>                 kswapd_stop(node);
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index ebf319d..5964b7a 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5872,6 +5872,19 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
>>  #endif
>>
>>  #ifdef CONFIG_MEMORY_HOTREMOVE
>> +void zone_pcp_reset(struct zone *zone)
>> +{
>> +       unsigned long flags;
>> +
>> +       /* avoid races with drain_pages()  */
>> +       local_irq_save(flags);
>> +       if (zone->pageset != &boot_pageset) {
>> +               free_percpu(zone->pageset);
>> +               zone->pageset = &boot_pageset;
>> +       }
>> +       local_irq_restore(flags);
>> +}
>> +
>>  /*
>>   * All pages in the range must be isolated before calling this.
>>   */
>> --
>> 1.7.1
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
