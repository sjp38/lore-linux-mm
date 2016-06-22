Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 205A36B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 12:00:25 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so6534709wma.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 09:00:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nj9si13267wjb.213.2016.06.22.09.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 09:00:23 -0700 (PDT)
Subject: Re: [PATCH 04/27] mm, vmscan: Begin reclaiming pages on a per-node
 basis
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <1466518566-30034-5-git-send-email-mgorman@techsingularity.net>
 <6eecdf50-7880-2bfe-5519-004a4beeece6@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <efa724ae-63fb-c09f-13a3-ca9a09849ae2@suse.cz>
Date: Wed, 22 Jun 2016 18:00:12 +0200
MIME-Version: 1.0
In-Reply-To: <6eecdf50-7880-2bfe-5519-004a4beeece6@suse.cz>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>

On 06/22/2016 04:04 PM, Vlastimil Babka wrote:
> On 06/21/2016 04:15 PM, Mel Gorman wrote:
>> This patch makes reclaim decisions on a per-node basis. A reclaimer knows
>> what zone is required by the allocation request and skips pages from
>> higher zones. In many cases this will be ok because it's a GFP_HIGHMEM
>> request of some description. On 64-bit, ZONE_DMA32 requests will cause
>> some problems but 32-bit devices on 64-bit platforms are increasingly
>> rare. Historically it would have been a major problem on 32-bit with big
>> Highmem:Lowmem ratios but such configurations are also now rare and even
>> where they exist, they are not encouraged. If it really becomes a problem,
>> it'll manifest as very low reclaim efficiencies.
>>
>> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
>
> [...]
>
>> @@ -2540,14 +2559,14 @@ static inline bool compaction_ready(struct zone *zone, int order, int classzone_
>>   * If a zone is deemed to be full of pinned pages then just give it a light
>>   * scan then give up on it.
>>   */
>> -static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>> +static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc,
>> +		enum zone_type classzone_idx)
>>  {
>>  	struct zoneref *z;
>>  	struct zone *zone;
>>  	unsigned long nr_soft_reclaimed;
>>  	unsigned long nr_soft_scanned;
>>  	gfp_t orig_mask;
>> -	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
>>
>>  	/*
>>  	 * If the number of buffer_heads in the machine exceeds the maximum
>> @@ -2560,15 +2579,20 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
>>
>>  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
>>  					gfp_zone(sc->gfp_mask), sc->nodemask) {
>
> Using sc->reclaim_idx could be faster/nicer here than gfp_zone()?
> Although after "mm, vmscan: Update classzone_idx if buffer_heads_over_limit"
> there would need to be a variable for the highmem adjusted value - maybe reuse
> "requested_highidx"? Not important though.
>
>> -		enum zone_type classzone_idx;
>> -
>>  		if (!populated_zone(zone))
>>  			continue;
>>
>> -		classzone_idx = requested_highidx;
>> +		/*
>> +		 * Note that reclaim_idx does not change as it is the highest
>> +		 * zone reclaimed from which for empty zones is a no-op but
>> +		 * classzone_idx is used by shrink_node to test if the slabs
>> +		 * should be shrunk on a given node.
>> +		 */
>>  		while (!populated_zone(zone->zone_pgdat->node_zones +
>> -							classzone_idx))
>> +							classzone_idx)) {
>>  			classzone_idx--;
>> +			continue;

Oh and Michal's comment on Patch 20 made me realize that my objection to v6 
about possible underflow of sc->reclaim_idx and classzone_idx seems to still 
apply here for classzone_idx? Updated example: Normal zone allocation. A small 
node 0 without Normal zone will get us classzone_idx == dma32. Node 1 next in 
zonelist won't have dma/dma32 zones so we won't see node_zones + classzone_idx 
populated, and the while loop will lead to underflow of classzone_idx.
I may be missing something, but I don't really see another way around it than 
resetting classzone_idx to sc->reclaim_idx before the while loop.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
