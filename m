Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 432216B0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 05:09:31 -0400 (EDT)
Received: by mail-bk0-f49.google.com with SMTP id w11so320311bku.36
        for <linux-mm@kvack.org>; Wed, 13 Mar 2013 02:09:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <513FD297.3050100@jp.fujitsu.com>
References: <1363082773-3598-1-git-send-email-handai.szj@taobao.com>
	<1363082977-3753-1-git-send-email-handai.szj@taobao.com>
	<513FD297.3050100@jp.fujitsu.com>
Date: Wed, 13 Mar 2013 17:09:23 +0800
Message-ID: <CAFj3OHVsLK0FH1K3d_XsW7swUhuz84r3UMusq_M37p60JfcvnA@mail.gmail.com>
Subject: Re: [PATCH 2/6] memcg: Don't account root memcg CACHE/RSS stats
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, glommer@parallels.com, akpm@linux-foundation.org, mgorman@suse.de, Sha Zhengju <handai.szj@taobao.com>

On Wed, Mar 13, 2013 at 9:12 AM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2013/03/12 19:09), Sha Zhengju wrote:
>> If memcg is enabled and no non-root memcg exists, all allocated pages
>> belong to root_mem_cgroup and go through root memcg statistics routines
>> which brings some overheads.
>>
>> So for the sake of performance, we can give up accounting stats of root
>> memcg for MEM_CGROUP_STAT_CACHE/RSS and instead we pay special attention
>> to memcg_stat_show() while showing root memcg numbers:
>> as we don't account root memcg stats anymore, the root_mem_cgroup->stat
>> numbers are actually 0. So we fake these numbers by using stats of global
>> state and all other memcg. That is for root memcg:
>>
>>       nr(MEM_CGROUP_STAT_CACHE) = global_page_state(NR_FILE_PAGES) -
>>                                sum_of_all_memcg(MEM_CGROUP_STAT_CACHE);
>>
>> Rss pages accounting are in the similar way.
>>
>> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
>> ---
>>   mm/memcontrol.c |   50 ++++++++++++++++++++++++++++++++++----------------
>>   1 file changed, 34 insertions(+), 16 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 735cd41..e89204f 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -958,26 +958,27 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
>>   {
>>       preempt_disable();
>>
>> -     /*
>> -      * Here, RSS means 'mapped anon' and anon's SwapCache. Shmem/tmpfs is
>> -      * counted as CACHE even if it's on ANON LRU.
>> -      */
>> -     if (anon)
>> -             __this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
>> -                             nr_pages);
>> -     else
>> -             __this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
>> -                             nr_pages);
>> -
>>       /* pagein of a big page is an event. So, ignore page size */
>>       if (nr_pages > 0)
>>               __this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
>> -     else {
>> +     else
>>               __this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
>> -             nr_pages = -nr_pages; /* for event */
>> -     }
>>
>> -     __this_cpu_add(memcg->stat->nr_page_events, nr_pages);
>> +     __this_cpu_add(memcg->stat->nr_page_events,
>> +                                     nr_pages < 0 ? -nr_pages : nr_pages);
>> +
>> +     if (!mem_cgroup_is_root(memcg)) {
>> +             /*
>> +              * Here, RSS means 'mapped anon' and anon's SwapCache. Shmem/tmpfs is
>> +              * counted as CACHE even if it's on ANON LRU.
>> +              */
>> +             if (anon)
>> +                     __this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_RSS],
>> +                                     nr_pages);
>> +             else
>> +                     __this_cpu_add(memcg->stat->count[MEM_CGROUP_STAT_CACHE],
>> +                                     nr_pages);
>> +     }
>
> Hmm. I don't like to add this check to this fast path. IIUC, with Costa's patch, root memcg
> will not make any charges at all and never call this function. I like his one rather than

Yes. But I think that one still has some other problems such as
PGPGIN/PGPGOUT and threshold events related things. I prefer to
improve this as a start.


Thanks,
Sha

> this patching.
>
> Thanks,
> -Kame
>
>
>>
>>       preempt_enable();
>>   }
>> @@ -5445,12 +5446,24 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
>>       struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>>       struct mem_cgroup *mi;
>>       unsigned int i;
>> +     enum zone_stat_item global_stat[] = {NR_FILE_PAGES, NR_ANON_PAGES};
>> +     long root_stat[MEM_CGROUP_STAT_NSTATS] = {0};
>>
>>       for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
>> +             long val = 0;
>> +
>>               if (i == MEM_CGROUP_STAT_SWAP && !do_swap_account)
>>                       continue;
>> +
>> +             if (mem_cgroup_is_root(memcg) && (i == MEM_CGROUP_STAT_CACHE
>> +                                     || i == MEM_CGROUP_STAT_RSS)) {
>> +                     val = global_page_state(global_stat[i]) -
>> +                             mem_cgroup_recursive_stat(memcg, i);
>> +                     root_stat[i] = val = val < 0 ? 0 : val;
>> +             } else
>> +                     val = mem_cgroup_read_stat(memcg, i);
>>               seq_printf(m, "%s %ld\n", mem_cgroup_stat_names[i],
>> -                        mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
>> +                                     val * PAGE_SIZE);
>>       }
>>
>>       for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
>> @@ -5478,6 +5491,11 @@ static int memcg_stat_show(struct cgroup *cont, struct cftype *cft,
>>                       continue;
>>               for_each_mem_cgroup_tree(mi, memcg)
>>                       val += mem_cgroup_read_stat(mi, i) * PAGE_SIZE;
>> +
>> +             /* Adding local stats of root memcg */
>> +             if (mem_cgroup_is_root(memcg))
>> +                     val += root_stat[i] * PAGE_SIZE;
>> +
>>               seq_printf(m, "total_%s %lld\n", mem_cgroup_stat_names[i], val);
>>       }
>>
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
