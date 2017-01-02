Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F21496B0069
	for <linux-mm@kvack.org>; Mon,  2 Jan 2017 10:07:07 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id w13so76229908wmw.0
        for <linux-mm@kvack.org>; Mon, 02 Jan 2017 07:07:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k188si69800751wmd.64.2017.01.02.07.07.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Jan 2017 07:07:06 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: fix remote numa hits statistics
References: <20161221075711.GF16502@dhcp22.suse.cz>
 <20161221080653.29437-1-mhocko@kernel.org>
 <1d9e466b-dc87-eb41-113f-e7737a4bb7ef@suse.cz>
 <20170102144634.GB18048@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <cd358060-7a68-2033-8e8a-5ab188099de7@suse.cz>
Date: Mon, 2 Jan 2017 16:07:05 +0100
MIME-Version: 1.0
In-Reply-To: <20170102144634.GB18048@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, Jia He <hejianet@gmail.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On 01/02/2017 03:46 PM, Michal Hocko wrote:
> On Mon 02-01-17 15:16:23, Vlastimil Babka wrote:
>> On 12/21/2016 09:06 AM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> Jia He has noticed that b9f00e147f27 ("mm, page_alloc: reduce branches
>>> in zone_statistics") has an unintentional side effect that remote node
>>> allocation requests are accounted as NUMA_MISS rathat than NUMA_HIT and
>>> NUMA_OTHER if such a request doesn't use __GFP_OTHER_NODE. There are
>>> many of these potentially because the flag is used very rarely while
>>> we have many users of __alloc_pages_node.
>>>
>>> Fix this by simply ignoring __GFP_OTHER_NODE (it can be removed in a
>>> follow up patch) and treat all allocations that were satisfied from the
>>> preferred zone's node as NUMA_HITS because this is the same node we
>>> requested the allocation from in most cases. If this is not the local
>>> node then we just account it as NUMA_OTHER rather than NUMA_LOCAL.
>>>
>>> One downsize would be that an allocation request for a node which is
>>> outside of the mempolicy nodemask would be reported as a hit which is a
>>> bit weird but that was the case before b9f00e147f27 already.
>>>
>>> Reported-by: Jia He <hejianet@gmail.com>
>>> Fixes: b9f00e147f27 ("mm, page_alloc: reduce branches in zone_statistics")
>>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>>
>> cbmc tells me that this patch is not equal to pre-commit b9f00e147f27
>> (in situation where __GFP_OTHER_NODE is not passed, as that's the only
>> relevant scenario after your patch), which seems unintended.
>>
>> counter example:
>> numa_node_id() == 1
>> preferred_zone on node 0
>> allocated from zone on node 1
>>
>> pre-b9f00e147f27:
>> allocated zone (node 1) increased NUMA_MISS and NUMA_LOCAL
>> preferred zone (node 0) increased NUMA_FOREIGN
>>
>> (that looks correct to me)
>>
>> your patch:
>> allocated zone (node 1) increased NUMA_MISS
>> preferred zone (node 0) increased NUMA_FOREIGN
>>
>> i.e. it's missing NUMA_LOCAL on node 1, which is IMHO wrong as this was
>> an allocation local to the CPU (albeit a MISS wrt the preferred node).
> 
> I guess the following should fix that, right?

Yes, it does.

With that, you can add:

Reviewed-by: Vlastimil Babka <vbabka@suse.cz>

(which is a lie, since the computer did that ;)

> ---
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 647e940e6921..ea60dc06d280 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2587,17 +2587,18 @@ int __isolate_free_page(struct page *page, unsigned int order)
>  static inline void zone_statistics(struct zone *preferred_zone, struct zone *z)
>  {
>  #ifdef CONFIG_NUMA
> -	if (z->node == preferred_zone->node) {
> -		enum zone_stat_item local_stat = NUMA_LOCAL;
> +	enum zone_stat_item local_stat = NUMA_LOCAL;
>  
> +	if (z->node != numa_node_id())
> +		local_stat = NUMA_OTHER;
> +
> +	if (z->node == preferred_zone->node)
>  		__inc_zone_state(z, NUMA_HIT);
> -		if (z->node != numa_node_id())
> -			local_stat = NUMA_OTHER;
> -		__inc_zone_state(z, local_stat);
> -	} else {
> +	else {
>  		__inc_zone_state(z, NUMA_MISS);
>  		__inc_zone_state(preferred_zone, NUMA_FOREIGN);
>  	}
> +	__inc_zone_state(z, local_stat);
>  #endif
>  }
>  
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
