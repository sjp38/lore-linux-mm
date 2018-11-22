Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CABA56B2BF2
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 10:38:53 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x98-v6so4712826ede.0
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 07:38:53 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t51si10793842edb.281.2018.11.22.07.38.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 07:38:52 -0800 (PST)
Subject: Re: [PATCH 3/4] mm: Reclaim small amounts of memory when an external
 fragmentation event occurs
References: <20181121101414.21301-1-mgorman@techsingularity.net>
 <20181121101414.21301-4-mgorman@techsingularity.net>
 <cc8ec820-1526-d753-4619-dedaa227a179@suse.cz>
 <20181122150446.GK23260@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c65bf59a-1134-0fc8-5718-dbd6752fa851@suse.cz>
Date: Thu, 22 Nov 2018 16:35:58 +0100
MIME-Version: 1.0
In-Reply-To: <20181122150446.GK23260@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 11/22/18 4:04 PM, Mel Gorman wrote:
> On Thu, Nov 22, 2018 at 02:53:08PM +0100, Vlastimil Babka wrote:
>>
>> So the reason I was wondering about movable vs unmovable fallbacks here
>> is that movable fallbacks are ok as they can be migrated later, but the
>> unmovable/reclaimable not, which is bad if they fallback to movable
>> pageblock. Movable fallbacks can however fill the unmovable pageblocks
>> and increase change of the unmovable fallback, but that would depend on
>> the workload. So hypothetically if the test workload was such that
>> movable fallbacks did not cause unmovable fallbacks, and a patch would
>> thus only decrease the movable fallbacks (at the cost of e.g. higher
>> reclaim, as this patch) with unmovable fallbacks unchanged, then it
>> would be useful to know that for better evaluation of the pros vs cons,
>> imho.
>>
> 
> I can give the breakdown in the next changelog as it'll be similar for
> each instance of the workload.
> 
> Movable fallbacks are ok in that they can fallback but not ok in that
> they can fill an unmovable/reclaimable pageblock causing them to
> fallback later. I think you understand this already.

Yes.

> If there is a
> movable pageblock, it is pretty much guaranteed to affect an
> unmovable/reclaimable pageblock and while it might not be enough to
> actually cause a unmovable/reclaimable fallback in the future, we cannot
> know that in advance so the patch takes the only option available to it.
> 
> In terms of reclaim, what I've observed for a few workloads is that
> reclaim is different but not necessarily worse. With the patch, reclaim
> is roughly similar overall but at a smoother rate. The vanilla kernel
> tends to spike with large amounts of reclaim at semi-regular intervals
> where as this path has a small amount of reclaim done steadily over
> time.
> 
> Now I did encounter a bug whereby fio reduced throughput because the
> boosted reclaim also reclaimed slab which caused secondary issues that
> were unrelated to the fragmentation pattern. This will be fixed in the
> next version.
> 
> While it does leave open the possibilty that a slab-intensive workload
> occupying lots of memory will still cause fragmentation, that is a
> different class of problem and would be approached differently. That
> particular problem is not covered by this approach but it does not exclude
> it either as the full solution would have to encompass both.

OK, thanks for explaining.

>>> +	max_boost = max(pageblock_nr_pages, max_boost);
>>> +
>>> +	zone->watermark_boost = min(zone->watermark_boost + pageblock_nr_pages,
>>> +		max_boost);
>>> +}
>>> +
>>>  /*
>>>   * This function implements actual steal behaviour. If order is large enough,
>>>   * we can steal whole pageblock. If not, we first move freepages in this
>>> @@ -2160,6 +2176,14 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
>>>  		goto single_page;
>>>  	}
>>>  
>>> +	/*
>>> +	 * Boost watermarks to increase reclaim pressure to reduce the
>>> +	 * likelihood of future fallbacks. Wake kswapd now as the node
>>> +	 * may be balanced overall and kswapd will not wake naturally.
>>> +	 */
>>> +	boost_watermark(zone);
>>> +	wakeup_kswapd(zone, 0, 0, zone_idx(zone));
>>> +
>>>  	/* We are not allowed to try stealing from the whole block */
>>>  	if (!whole_block)
>>>  		goto single_page;
>>> @@ -3277,11 +3301,19 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
>>>   * probably too small. It only makes sense to spread allocations to avoid
>>>   * fragmentation between the Normal and DMA32 zones.
>>>   */
>>> -static inline unsigned int alloc_flags_nofragment(struct zone *zone)
>>> +static inline unsigned int
>>> +alloc_flags_nofragment(struct zone *zone, gfp_t gfp_mask)
>>>  {
>>>  	if (zone_idx(zone) != ZONE_NORMAL)
>>>  		return 0;
>>>  
>>> +	/*
>>> +	 * A fragmenting fallback will try waking kswapd. ALLOC_NOFRAGMENT
>>> +	 * may break that so such callers can introduce fragmentation.
>>> +	 */
>>
>> I think I don't understand this comment :( Do you want to avoid waking
>> up kswapd from steal_suitable_fallback() (introduced above) for
>> allocations without __GFP_KSWAPD_RECLAIM? But returning 0 here means
>> actually allowing the allocation go through steal_suitable_fallback()?
>> So should it return ALLOC_NOFRAGMENT below, or was the intent different?
>>
> 
> I want to avoid waking kswapd in steal_suitable_fallback if waking
> kswapd is not allowed.

OK, but then this 'if' should return ALLOC_NOFRAGMENT, not 0?
But that will still not prevent waking kswapd for nodes where there's no
ZONE_DMA32, or any node when get_page_from_freelist() retries without
fallback.

> If the calling context does not allow it, it does
> mean that fragmentation will be allowed to occur. I'm banking on it
> being a relatively rare case but potentially it'll be problematic. The
> main source of allocation requests that I expect to hit this are THP and
> as they are already at pageblock_order, it has limited impact from a
> fragmentation perspective -- particularly as pageblock_order stealing is
> allowed even with ALLOC_NOFRAGMENT.

Yep, THP will skip the wakeup in steal_suitable_fallback() via 'goto
single_page' above it. For other users of ~__GFP_KSWAPD_RECLAIM (are
there any?) we could maybe just ignore and wakeup kswapd anyway, since
avoiding fragmentation is more important? Or if we wanted to avoid
wakeup reliably, then steal_suitable_fallback() would have to know and
check gfp_flags I'm afraid, and that doesn't seem worth the trouble.
