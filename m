Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1C26B0367
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 22:01:28 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id y68so299555535pfb.6
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 19:01:28 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id a62si3998830pge.65.2016.12.20.19.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 19:01:27 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id i5so4835073pgh.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 19:01:27 -0800 (PST)
Subject: Re: [PATCH RFC 1/1] mm, page_alloc: fix incorrect zone_statistics
 data
References: <1481522347-20393-1-git-send-email-hejianet@gmail.com>
 <1481522347-20393-2-git-send-email-hejianet@gmail.com>
 <20161220091814.GC3769@dhcp22.suse.cz>
From: hejianet <hejianet@gmail.com>
Message-ID: <84c018b5-bf63-6057-e39f-c8e0935bca09@gmail.com>
Date: Wed, 21 Dec 2016 11:01:08 +0800
MIME-Version: 1.0
In-Reply-To: <20161220091814.GC3769@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>



On 20/12/2016 5:18 PM, Michal Hocko wrote:
> On Mon 12-12-16 13:59:07, Jia He wrote:
>> In commit b9f00e147f27 ("mm, page_alloc: reduce branches in
>> zone_statistics"), it reconstructed codes to reduce the branch miss rate.
>> Compared with the original logic, it assumed if !(flag & __GFP_OTHER_NODE)
>>   z->node would not be equal to preferred_zone->node. That seems to be
>> incorrect.
> I am sorry but I have hard time following the changelog. It is clear
> that you are trying to fix a missed NUMA_{HIT,OTHER} accounting
> but it is not really clear when such thing happens. You are adding
> preferred_zone->node check. preferred_zone is the first zone in the
> requested zonelist. So for the most allocations it is a node from the
> local node. But if something request an explicit numa node (without
> __GFP_OTHER_NODE which would be the majority I suspect) then we could
> indeed end up accounting that as a NUMA_MISS, NUMA_FOREIGN so the
> referenced patch indeed caused an unintended change of accounting AFAIU.
>
> If this is correct then it should be a part of the changelog. I also
> cannot say I would like the fix. First of all I am not sure
> __GFP_OTHER_NODE is a good idea at all. How is an explicit usage of the
> flag any different from an explicit __alloc_pages_node(non_local_nid)?
> In both cases we ask for an allocation on a remote node and successful
> allocation is a NUMA_HIT and NUMA_OTHER.
>
> That being said, why cannot we simply do the following? As a bonus, we
> can get rid of a barely used __GFP_OTHER_NODE. Also the number of
> branches will stay same.
Yes, I agree maybe we can get rid of __GFP_OTHER_NODE if no objections
Seems currently it is only used for hugepage and statistics
> ---
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 429855be6ec9..f035d5c8b864 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2583,25 +2583,17 @@ int __isolate_free_page(struct page *page, unsigned int order)
>    * Update NUMA hit/miss statistics
>    *
>    * Must be called with interrupts disabled.
> - *
> - * When __GFP_OTHER_NODE is set assume the node of the preferred
> - * zone is the local node. This is useful for daemons who allocate
> - * memory on behalf of other processes.
>    */
>   static inline void zone_statistics(struct zone *preferred_zone, struct zone *z,
>   								gfp_t flags)
>   {
>   #ifdef CONFIG_NUMA
> -	int local_nid = numa_node_id();
> -	enum zone_stat_item local_stat = NUMA_LOCAL;
> -
> -	if (unlikely(flags & __GFP_OTHER_NODE)) {
> -		local_stat = NUMA_OTHER;
> -		local_nid = preferred_zone->node;
> -	}
> +	if (z->node == preferred_zone->node) {
> +		enum zone_stat_item local_stat = NUMA_LOCAL;
>   
> -	if (z->node == local_nid) {
>   		__inc_zone_state(z, NUMA_HIT);
> +		if (z->node != numa_node_id())
> +			local_stat = NUMA_OTHER;
>   		__inc_zone_state(z, local_stat);
>   	} else {
>   		__inc_zone_state(z, NUMA_MISS);
I thought the logic here is different
Here is the zone_statistics() before introducing __GFP_OTHER_NODE:

if (z->zone_pgdat == preferred_zone->zone_pgdat) {
         __inc_zone_state(z, NUMA_HIT);
     } else {
         __inc_zone_state(z, NUMA_MISS);
         __inc_zone_state(preferred_zone, NUMA_FOREIGN);
     }
     if (z->node == numa_node_id())
         __inc_zone_state(z, NUMA_LOCAL);
     else
         __inc_zone_state(z, NUMA_OTHER);

B.R.
Jia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
