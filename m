Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id E75DB6B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 12:31:46 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id u74so14098606ota.0
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 09:31:46 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id d36si711103otd.360.2017.06.22.09.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 09:31:46 -0700 (PDT)
Subject: Re: [PATCH v2] fs/dcache.c: fix spin lockup issue on nlru->lock
References: <6ab790fe-de97-9495-0d3b-804bae5d7fbb@codeaurora.org>
 <1498027155-4456-1-git-send-email-stummala@codeaurora.org>
 <20170621163134.GA3273@esperanza>
From: Sahitya Tummala <stummala@codeaurora.org>
Message-ID: <8d82c32d-6cbb-c39d-2f0e-0af23925b3c1@codeaurora.org>
Date: Thu, 22 Jun 2017 22:01:39 +0530
MIME-Version: 1.0
In-Reply-To: <20170621163134.GA3273@esperanza>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Alexander Polakov <apolyakov@beget.ru>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org



On 6/21/2017 10:01 PM, Vladimir Davydov wrote:
>
>> index cddf397..c8ca150 100644
>> --- a/fs/dcache.c
>> +++ b/fs/dcache.c
>> @@ -1133,10 +1133,11 @@ void shrink_dcache_sb(struct super_block *sb)
>>   		LIST_HEAD(dispose);
>>   
>>   		freed = list_lru_walk(&sb->s_dentry_lru,
>> -			dentry_lru_isolate_shrink, &dispose, UINT_MAX);
>> +			dentry_lru_isolate_shrink, &dispose, 1024);
>>   
>>   		this_cpu_sub(nr_dentry_unused, freed);
>>   		shrink_dentry_list(&dispose);
>> +		cond_resched();
>>   	} while (freed > 0);
> In an extreme case, a single invocation of list_lru_walk() can skip all
> 1024 dentries, in which case 'freed' will be 0 forcing us to break the
> loop prematurely. I think we should loop until there's at least one
> dentry left on the LRU, i.e.
>
> 	while (list_lru_count(&sb->s_dentry_lru) > 0)
>
> However, even that wouldn't be quite correct, because list_lru_count()
> iterates over all memory cgroups to sum list_lru_one->nr_items, which
> can race with memcg offlining code migrating dentries off a dead cgroup
> (see memcg_drain_all_list_lrus()). So it looks like to make this check
> race-free, we need to account the number of entries on the LRU not only
> per memcg, but also per node, i.e. add list_lru_node->nr_items.
> Fortunately, list_lru entries can't be migrated between NUMA nodes.
It looks like list_lru_count() is iterating per node before iterating 
over all memory
cgroups as below -

unsigned long list_lru_count_node(struct list_lru *lru, int nid)
{
         long count = 0;
         int memcg_idx;

         count += __list_lru_count_one(lru, nid, -1);
         if (list_lru_memcg_aware(lru)) {
                 for_each_memcg_cache_index(memcg_idx)
                         count += __list_lru_count_one(lru, nid, memcg_idx);
         }
         return count;
}

The first call to __list_lru_count_one() is iterating all the items per 
node i.e, nlru->lru->nr_items.
Is my understanding correct? If not, could you please clarify on how to 
get the lru items per node?

-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
