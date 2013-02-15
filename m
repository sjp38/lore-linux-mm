Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 294EC6B000C
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 05:54:38 -0500 (EST)
Message-ID: <511E13FF.8020803@parallels.com>
Date: Fri, 15 Feb 2013 14:54:55 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] memcg,list_lru: duplicate LRUs upon kmemcg creation
References: <1360328857-28070-1-git-send-email-glommer@parallels.com> <1360328857-28070-3-git-send-email-glommer@parallels.com> <xr934nhenz18.fsf@gthelen.mtv.corp.google.com>
In-Reply-To: <xr934nhenz18.fsf@gthelen.mtv.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Dave Shrinnker <david@fromorbit.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>


>>
>> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
>> index 02796da..370b989 100644
>> --- a/include/linux/list_lru.h
>> +++ b/include/linux/list_lru.h
>> @@ -16,11 +16,58 @@ struct list_lru_node {
>>  	long			nr_items;
>>  } ____cacheline_aligned_in_smp;
>>  
>> +struct list_lru_array {
>> +	struct list_lru_node node[1];
>> +};
>> +
>>  struct list_lru {
>> +	struct list_head	lrus;
>>  	struct list_lru_node	node[MAX_NUMNODES];
>>  	nodemask_t		active_nodes;
>> +#ifdef CONFIG_MEMCG_KMEM
>> +	struct list_lru_array	**memcg_lrus;
> 
> Probably need a comment regarding that 0x1 is a magic value and
> describing what indexes this lazily constructed array. 

Ok.

> Is the primary
> index memcg_kmem_id and the secondary index a nid?
> 

Precisely. The first level is an array of pointers to list_lru_array.
And each list_lru_array is an array of nids.

>> +struct mem_cgroup;
>> +#ifdef CONFIG_MEMCG_KMEM
>> +/*
>> + * We will reuse the last bit of the pointer to tell the lru subsystem that
>> + * this particular lru should be replicated when a memcg comes in.
>> + */
> 
> From this patch it seems like 0x1 is a magic value rather than bit 0
> being special.  memcg_lrus is either 0x1 or a pointer to an array of
> struct list_lru_array.  The array is indexed by memcg_kmem_id.
> 

Well, I thought in terms of "set the last bit". To be honest, when I
first designed this, I figured it could possibly be useful to keep the
bit set at all times, and that is why I used the LSB. Since I turned out
not using it, maybe we could actually resort to a fully fledged magical
to avoid the confusion?

>> +static inline void lru_memcg_enable(struct list_lru *lru)
>> +/*
>> + * This will return true if we have already allocated and assignment a memcg
>> + * pointer set to the LRU. Therefore, we need to mask the first bit out
>> + */
>> +static inline bool lru_memcg_is_assigned(struct list_lru *lru)
>> +{
>> +	return (unsigned long)lru->memcg_lrus & ~0x1ULL;
> 
> Is this equivalent to?
> 	return lru->memcg_lrus != NULL && lru->memcg_lrus != 0x1
> 
yes. What I've explained above should help clarifying why I wrote it
this way. But if we use an actual magical (0x1 is a bad magical, IMHO),
the intentions become a lot clearer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
