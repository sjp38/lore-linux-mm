Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 902476B02C5
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 17:33:02 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p5so7530842pgn.7
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 14:33:02 -0700 (PDT)
Received: from out0-223.mail.aliyun.com (out0-223.mail.aliyun.com. [140.205.0.223])
        by mx.google.com with ESMTPS id u59si1912252plb.351.2017.09.20.14.33.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Sep 2017 14:33:01 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: oom: show unreclaimable slab info when kernel
 panic
References: <1505934576-9749-1-git-send-email-yang.s@alibaba-inc.com>
 <1505934576-9749-3-git-send-email-yang.s@alibaba-inc.com>
 <alpine.DEB.2.10.1709201350490.105729@chino.kir.corp.google.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <3c1752f9-2443-a1a8-7cb5-84794a6d1d91@alibaba-inc.com>
Date: Thu, 21 Sep 2017 05:32:53 +0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1709201350490.105729@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 9/20/17 2:00 PM, David Rientjes wrote:
> On Thu, 21 Sep 2017, Yang Shi wrote:
> 
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 99736e0..173c423 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -43,6 +43,7 @@
>>   
>>   #include <asm/tlb.h>
>>   #include "internal.h"
>> +#include "slab.h"
>>   
>>   #define CREATE_TRACE_POINTS
>>   #include <trace/events/oom.h>
>> @@ -427,6 +428,14 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>>   		dump_tasks(oc->memcg, oc->nodemask);
>>   }
>>   
>> +static void dump_header_with_slabinfo(struct oom_control *oc, struct task_struct *p)
>> +{
>> +	dump_header(oc, p);
>> +
>> +	if (IS_ENABLED(CONFIG_SLABINFO))
>> +		show_unreclaimable_slab();
>> +}
>> +
>>   /*
>>    * Number of OOM victims in flight
>>    */
> 
> I don't think we need a new function for this.  Where you want to dump
> unreclaimable slab before panic, just call a new dump_unreclaimable_slab()
> function that gets declared in slab.h that is a no-op when CONFIG_SLABINFO
> is disabled.  We just want to do
> 
> 	dump_header(...);
> 	dump_unreclaimable_slab(...);
> 	panic(...);

Thanks for the comment, they will be solved in v4.

Yang

> 
>> diff --git a/mm/slab.c b/mm/slab.c
>> index 04dec48..4f4971c 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -4132,6 +4132,7 @@ void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
>>   	sinfo->shared = cachep->shared;
>>   	sinfo->objects_per_slab = cachep->num;
>>   	sinfo->cache_order = cachep->gfporder;
>> +	sinfo->reclaim = is_reclaimable(cachep);
> 
> We don't need a new field, we already have cachep->flags accessible.
> 
>>   }
>>   
>>   void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *cachep)
>> diff --git a/mm/slab.h b/mm/slab.h
>> index 0733628..2f1ebce 100644
>> --- a/mm/slab.h
>> +++ b/mm/slab.h
>> @@ -186,6 +186,7 @@ struct slabinfo {
>>   	unsigned int shared;
>>   	unsigned int objects_per_slab;
>>   	unsigned int cache_order;
>> +	unsigned int reclaim;
> 
> Not needed.
> 
>>   };
>>   
>>   void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo);
>> @@ -352,6 +353,11 @@ static inline void memcg_link_cache(struct kmem_cache *s)
>>   
>>   #endif /* CONFIG_MEMCG && !CONFIG_SLOB */
>>   
>> +static inline bool is_reclaimable(struct kmem_cache *s)
>> +{
>> +	return (s->flags & SLAB_RECLAIM_ACCOUNT) ? true : false;
>> +}
>> +
> 
> I don't think we need this.
> 
>>   static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
>>   {
>>   	struct kmem_cache *cachep;
>> @@ -504,6 +510,7 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
>>   void *memcg_slab_next(struct seq_file *m, void *p, loff_t *pos);
>>   void memcg_slab_stop(struct seq_file *m, void *p);
>>   int memcg_slab_show(struct seq_file *m, void *p);
>> +void show_unreclaimable_slab(void);
>>   
>>   void ___cache_free(struct kmem_cache *cache, void *x, unsigned long addr);
>>   
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index 904a83b..f2c6200 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -35,6 +35,8 @@
>>   static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
>>   		    slab_caches_to_rcu_destroy_workfn);
>>   
>> +#define K(x) ((x)/1024)
>> +
> 
> I don't think we need this.
> 
>>   /*
>>    * Set of flags that will prevent slab merging
>>    */
>> @@ -1272,6 +1274,35 @@ static int slab_show(struct seq_file *m, void *p)
>>   	return 0;
>>   }
>>   
>> +void show_unreclaimable_slab()
> 
> void show_unreclaimable_slab(void)
> 
>> +{
>> +	struct kmem_cache *s = NULL;
> 
> No initialization needed.
> 
>> +	struct slabinfo sinfo;
>> +
>> +	memset(&sinfo, 0, sizeof(sinfo));
>> +
>> +	printk("Unreclaimable slab info:\n");
>> +	printk("Name                      Used          Total\n");
>> +
>> +	/*
>> +	 * Here acquiring slab_mutex is unnecessary since we don't prefer to
>> +	 * get sleep in oom path right before kernel panic, and avoid race condition.
>> +	 * Since it is already oom, so there should be not any big allocation
>> +	 * which could change the statistics significantly.
>> +	 */
>> +	list_for_each_entry(s, &slab_caches, list) {
>> +		if (!is_root_cache(s))
>> +			continue;
>> +
> 
> We need to do the memset() here.
> 
>> +		get_slabinfo(s, &sinfo);
>> +
>> +		if (!is_reclaimable(s) && sinfo.num_objs > 0)
>> +			printk("%-17s %10luKB %10luKB\n", cache_name(s), K(sinfo.active_objs * s->size), K(sinfo.num_objs * s->size));
> 
> I think you can just check for SLAB_RECLAIM_ACCOUNT here.
> 
> Everything in this function should be pr_info().
> 
>> +	}
>> +}
>> +EXPORT_SYMBOL(show_unreclaimable_slab);
>> +#undef K
>> +
>>   #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>>   void *memcg_slab_start(struct seq_file *m, loff_t *pos)
>>   {
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 163352c..5c17c0a 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -5872,6 +5872,7 @@ void get_slabinfo(struct kmem_cache *s, struct slabinfo *sinfo)
>>   	sinfo->num_slabs = nr_slabs;
>>   	sinfo->objects_per_slab = oo_objects(s->oo);
>>   	sinfo->cache_order = oo_order(s->oo);
>> +	sinfo->reclaim = is_reclaimable(s);
> 
> Not needed.
> 
>>   }
>>   
>>   void slabinfo_show_stats(struct seq_file *m, struct kmem_cache *s)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
