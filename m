Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 35BCB6B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 12:15:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e64so2723323pfk.0
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:15:40 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTPS id y1si1893634plk.261.2017.10.26.09.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 09:15:38 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: oom: dump single excessive slab cache when oom
References: <1508971740-118317-1-git-send-email-yang.s@alibaba-inc.com>
 <1508971740-118317-3-git-send-email-yang.s@alibaba-inc.com>
 <20171026145312.6svuzriij33vzgw7@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <44577b73-2e2d-5571-4c8b-3233e3776a52@alibaba-inc.com>
Date: Fri, 27 Oct 2017 00:15:17 +0800
MIME-Version: 1.0
In-Reply-To: <20171026145312.6svuzriij33vzgw7@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/26/17 7:53 AM, Michal Hocko wrote:
> On Thu 26-10-17 06:49:00, Yang Shi wrote:
>> Per the discussion with David [1], it looks more reasonable to just dump
> 
> Please try to avoid external references in the changelog as much as
> possible.

OK.

> 
>> the single excessive slab cache instead of dumping all slab caches when
>> oom.
> 
> You meant to say
> "to just dump all slab caches which excess 10% of the total memory."
> 
> While we are at it. Abusing calc_mem_size seems to be rather clumsy and
> tt is not nodemask aware so you the whole thing is dubious for NUMA
> constrained OOMs.

Since we just need the total memory size of the node for NUMA 
constrained OOM, we should be able to use show_mem_node_skip() to bring 
in nodemask.

> 
> The more I think about this the more I am convinced that this is just
> fiddling with the code without a good reason and without much better
> outcome.

I don't get you. Do you mean the benefit is not that much with just 
dumping excessive slab caches?

Thanks,
Yang


>   
>> Dump single excessive slab cache if its size is > 10% of total system
> 
> s@single@all@
> 
>> memory size when oom regardless it is unreclaimable.
>>
>> [1] https://marc.info/?l=linux-mm&m=150819933626604&w=2
>>
>> Suggested-by: David Rientjes <rientjes@google.com>
>> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
>> ---
>>   mm/oom_kill.c    | 22 +---------------------
>>   mm/slab.h        |  4 ++--
>>   mm/slab_common.c | 21 ++++++++++++++++-----
>>   3 files changed, 19 insertions(+), 28 deletions(-)
>>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 26add8a..f996f29 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -162,25 +162,6 @@ static bool oom_unkillable_task(struct task_struct *p,
>>   	return false;
>>   }
>>   
>> -/*
>> - * Print out unreclaimble slabs info when unreclaimable slabs amount is greater
>> - * than all user memory (LRU pages)
>> - */
>> -static bool is_dump_unreclaim_slabs(void)
>> -{
>> -	unsigned long nr_lru;
>> -
>> -	nr_lru = global_node_page_state(NR_ACTIVE_ANON) +
>> -		 global_node_page_state(NR_INACTIVE_ANON) +
>> -		 global_node_page_state(NR_ACTIVE_FILE) +
>> -		 global_node_page_state(NR_INACTIVE_FILE) +
>> -		 global_node_page_state(NR_ISOLATED_ANON) +
>> -		 global_node_page_state(NR_ISOLATED_FILE) +
>> -		 global_node_page_state(NR_UNEVICTABLE);
>> -
>> -	return (global_node_page_state(NR_SLAB_UNRECLAIMABLE) > nr_lru);
>> -}
>> -
>>   /**
>>    * oom_badness - heuristic function to determine which candidate task to kill
>>    * @p: task struct of which task we should calculate
>> @@ -443,8 +424,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>>   		mem_cgroup_print_oom_info(oc->memcg, p);
>>   	else {
>>   		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
>> -		if (is_dump_unreclaim_slabs())
>> -			dump_unreclaimable_slab();
>> +		dump_slab_cache();
>>   	}
>>   	if (sysctl_oom_dump_tasks)
>>   		dump_tasks(oc->memcg, oc->nodemask);
>> diff --git a/mm/slab.h b/mm/slab.h
>> index 6a86025..818b569 100644
>> --- a/mm/slab.h
>> +++ b/mm/slab.h
>> @@ -507,9 +507,9 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
>>   int memcg_slab_show(struct seq_file *m, void *p);
>>   
>>   #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB_DEBUG)
>> -void dump_unreclaimable_slab(void);
>> +void dump_slab_cache(void);
>>   #else
>> -static inline void dump_unreclaimable_slab(void)
>> +static inline void dump_slab_cache(void)
>>   {
>>   }
>>   #endif
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index 1b14fe0..e5bfa07 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -1311,7 +1311,18 @@ static int slab_show(struct seq_file *m, void *p)
>>   	return 0;
>>   }
>>   
>> -void dump_unreclaimable_slab(void)
>> +static bool inline is_dump_slabs(struct kmem_cache *s, struct slabinfo *sinfo)
>> +{
>> +	unsigned long total = 0, reserved = 0, highmem = 0;
>> +	unsigned long slab_size = sinfo->num_objs * s->size;
>> +
>> +	calc_mem_size(&total, &reserved, &highmem);
>> +
>> +	/* Check if single slab > 10% of total memory size */
>> +	return (slab_size > (total * PAGE_SIZE / 10));
>> +}
>> +
>> +void dump_slab_cache(void)
>>   {
>>   	struct kmem_cache *s, *s2;
>>   	struct slabinfo sinfo;
>> @@ -1324,20 +1335,20 @@ void dump_unreclaimable_slab(void)
>>   	 * without acquiring the mutex.
>>   	 */
>>   	if (!mutex_trylock(&slab_mutex)) {
>> -		pr_warn("excessive unreclaimable slab but cannot dump stats\n");
>> +		pr_warn("excessive slab cache but cannot dump stats\n");
>>   		return;
>>   	}
>>   
>> -	pr_info("Unreclaimable slab info:\n");
>> +	pr_info("The list of excessive single slab cache:\n");
>>   	pr_info("Name                      Used          Total\n");
>>   
>>   	list_for_each_entry_safe(s, s2, &slab_caches, list) {
>> -		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
>> +		if (!is_root_cache(s))
>>   			continue;
>>   
>>   		get_slabinfo(s, &sinfo);
>>   
>> -		if (sinfo.num_objs > 0)
>> +		if (is_dump_slabs(s, &sinfo))
>>   			pr_info("%-17s %10luKB %10luKB\n", cache_name(s),
>>   				(sinfo.active_objs * s->size) / 1024,
>>   				(sinfo.num_objs * s->size) / 1024);
>> -- 
>> 1.8.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
