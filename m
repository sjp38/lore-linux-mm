Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1BB706B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 04:03:04 -0500 (EST)
Received: by lbiz12 with SMTP id z12so23314427lbi.11
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 01:03:03 -0800 (PST)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id dv9si5544324lbc.68.2015.02.24.01.03.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 01:03:02 -0800 (PST)
Received: by labge10 with SMTP id ge10so24156977lab.12
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 01:03:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150223143746.GG24272@dhcp22.suse.cz>
References: <20150220143942.19568.4548.stgit@buzz>
	<20150223143746.GG24272@dhcp22.suse.cz>
Date: Tue, 24 Feb 2015 13:03:01 +0400
Message-ID: <CALYGNiO8Y3oJbPMF8m2ndtBp5=RBiw3o6rKyWsGXF0RyT9JYVQ@mail.gmail.com>
Subject: Re: [PATCH] mm: hide per-cpu lists in output of show_mem()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Feb 23, 2015 at 5:37 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Fri 20-02-15 17:39:42, Konstantin Khlebnikov wrote:
>> This makes show_mem() much less verbose at huge machines. Instead of
>> huge and almost useless dump of counters for each per-zone per-cpu
>> lists this patch prints sum of these counters for each zone (free_pcp)
>> and size of per-cpu list for current cpu (local_pcp).
>
> I like this! I do not remember when I found this information useful
> while debugging either an allocation failure warning or OOM killer
> report.
>
>> Flag SHOW_MEM_PERCPU_LISTS reverts old verbose mode.
>
> Nobody seems to be using this flag so why bother?

Yes. But this might be important for architectures which has asymmetrical
memory topology, I've heard about unicorns like that.

>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>
> Acked-by: Michal Hocko <mhocko@suse.cz>
>
>> ---
>>  include/linux/mm.h |    1 +
>>  mm/page_alloc.c    |   32 +++++++++++++++++++++++++-------
>>  2 files changed, 26 insertions(+), 7 deletions(-)
>>
>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>> index 028565a..0538de0 100644
>> --- a/include/linux/mm.h
>> +++ b/include/linux/mm.h
>> @@ -1126,6 +1126,7 @@ extern void pagefault_out_of_memory(void);
>>   * various contexts.
>>   */
>>  #define SHOW_MEM_FILTER_NODES                (0x0001u)       /* disallowed nodes */
>> +#define SHOW_MEM_PERCPU_LISTS                (0x0002u)       /* per-zone per-cpu */
>>
>>  extern void show_free_areas(unsigned int flags);
>>  extern bool skip_free_areas_node(unsigned int flags, int nid);
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index a47f0b2..e591f3b 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3198,20 +3198,29 @@ static void show_migration_types(unsigned char type)
>>   */
>>  void show_free_areas(unsigned int filter)
>>  {
>> +     unsigned long free_pcp = 0;
>>       int cpu;
>>       struct zone *zone;
>>
>>       for_each_populated_zone(zone) {
>>               if (skip_free_areas_node(filter, zone_to_nid(zone)))
>>                       continue;
>> -             show_node(zone);
>> -             printk("%s per-cpu:\n", zone->name);
>> +
>> +             if (filter & SHOW_MEM_PERCPU_LISTS) {
>> +                     show_node(zone);
>> +                     printk("%s per-cpu:\n", zone->name);
>> +             }
>>
>>               for_each_online_cpu(cpu) {
>>                       struct per_cpu_pageset *pageset;
>>
>>                       pageset = per_cpu_ptr(zone->pageset, cpu);
>>
>> +                     free_pcp += pageset->pcp.count;
>> +
>> +                     if (!(filter & SHOW_MEM_PERCPU_LISTS))
>> +                             continue;
>> +
>>                       printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
>>                              cpu, pageset->pcp.high,
>>                              pageset->pcp.batch, pageset->pcp.count);
>> @@ -3220,11 +3229,10 @@ void show_free_areas(unsigned int filter)
>>
>>       printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
>>               " active_file:%lu inactive_file:%lu isolated_file:%lu\n"
>> -             " unevictable:%lu"
>> -             " dirty:%lu writeback:%lu unstable:%lu\n"
>> -             " free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
>> +             " unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
>> +             " slab_reclaimable:%lu slab_unreclaimable:%lu\n"
>>               " mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
>> -             " free_cma:%lu\n",
>> +             " free:%lu free_pcp:%lu free_cma:%lu\n",
>>               global_page_state(NR_ACTIVE_ANON),
>>               global_page_state(NR_INACTIVE_ANON),
>>               global_page_state(NR_ISOLATED_ANON),
>> @@ -3235,13 +3243,14 @@ void show_free_areas(unsigned int filter)
>>               global_page_state(NR_FILE_DIRTY),
>>               global_page_state(NR_WRITEBACK),
>>               global_page_state(NR_UNSTABLE_NFS),
>> -             global_page_state(NR_FREE_PAGES),
>>               global_page_state(NR_SLAB_RECLAIMABLE),
>>               global_page_state(NR_SLAB_UNRECLAIMABLE),
>>               global_page_state(NR_FILE_MAPPED),
>>               global_page_state(NR_SHMEM),
>>               global_page_state(NR_PAGETABLE),
>>               global_page_state(NR_BOUNCE),
>> +             global_page_state(NR_FREE_PAGES),
>> +             free_pcp,
>>               global_page_state(NR_FREE_CMA_PAGES));
>>
>>       for_each_populated_zone(zone) {
>> @@ -3249,6 +3258,11 @@ void show_free_areas(unsigned int filter)
>>
>>               if (skip_free_areas_node(filter, zone_to_nid(zone)))
>>                       continue;
>> +
>> +             free_pcp = 0;
>> +             for_each_online_cpu(cpu)
>> +                     free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
>> +
>>               show_node(zone);
>>               printk("%s"
>>                       " free:%lukB"
>> @@ -3275,6 +3289,8 @@ void show_free_areas(unsigned int filter)
>>                       " pagetables:%lukB"
>>                       " unstable:%lukB"
>>                       " bounce:%lukB"
>> +                     " free_pcp:%lukB"
>> +                     " local_pcp:%ukB"
>>                       " free_cma:%lukB"
>>                       " writeback_tmp:%lukB"
>>                       " pages_scanned:%lu"
>> @@ -3306,6 +3322,8 @@ void show_free_areas(unsigned int filter)
>>                       K(zone_page_state(zone, NR_PAGETABLE)),
>>                       K(zone_page_state(zone, NR_UNSTABLE_NFS)),
>>                       K(zone_page_state(zone, NR_BOUNCE)),
>> +                     K(free_pcp),
>> +                     K(this_cpu_read(zone->pageset->pcp.count)),
>>                       K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
>>                       K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
>>                       K(zone_page_state(zone, NR_PAGES_SCANNED)),
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Michal Hocko
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
