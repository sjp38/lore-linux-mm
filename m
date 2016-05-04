Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 446A46B025E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 11:14:52 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id aq1so109977024obc.2
        for <linux-mm@kvack.org>; Wed, 04 May 2016 08:14:52 -0700 (PDT)
Received: from mail-oi0-x230.google.com (mail-oi0-x230.google.com. [2607:f8b0:4003:c06::230])
        by mx.google.com with ESMTPS id f5si1969047oia.9.2016.05.04.08.14.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 08:14:51 -0700 (PDT)
Received: by mail-oi0-x230.google.com with SMTP id v145so68669472oie.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 08:14:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160504090448.GF29978@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
	<1461181647-8039-15-git-send-email-mhocko@kernel.org>
	<20160504062748.GC10899@js1304-P5Q-DELUXE>
	<20160504090448.GF29978@dhcp22.suse.cz>
Date: Thu, 5 May 2016 00:14:51 +0900
Message-ID: <CAAmzW4Ohnhrx1RkAFywwQyLW1b1NiHhB9AkvVCp8NVC9vyevtQ@mail.gmail.com>
Subject: Re: [PATCH 14/14] mm, oom, compaction: prevent from
 should_compact_retry looping for ever for costly orders
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-05-04 18:04 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> On Wed 04-05-16 15:27:48, Joonsoo Kim wrote:
>> On Wed, Apr 20, 2016 at 03:47:27PM -0400, Michal Hocko wrote:
> [...]
>> > +bool compaction_zonelist_suitable(struct alloc_context *ac, int order,
>> > +           int alloc_flags)
>> > +{
>> > +   struct zone *zone;
>> > +   struct zoneref *z;
>> > +
>> > +   /*
>> > +    * Make sure at least one zone would pass __compaction_suitable if we continue
>> > +    * retrying the reclaim.
>> > +    */
>> > +   for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
>> > +                                   ac->nodemask) {
>> > +           unsigned long available;
>> > +           enum compact_result compact_result;
>> > +
>> > +           /*
>> > +            * Do not consider all the reclaimable memory because we do not
>> > +            * want to trash just for a single high order allocation which
>> > +            * is even not guaranteed to appear even if __compaction_suitable
>> > +            * is happy about the watermark check.
>> > +            */
>> > +           available = zone_reclaimable_pages(zone) / order;
>>
>> I can't understand why '/ order' is needed here. Think about specific
>> example.
>>
>> zone_reclaimable_pages = 100 MB
>> NR_FREE_PAGES = 20 MB
>> watermark = 40 MB
>> order = 10
>>
>> I think that compaction should run in this situation and your logic
>> doesn't. We should be conservative when guessing not to do something
>> prematurely.
>
> I do not mind changing this. But pushing really hard on reclaim for
> order-10 pages doesn't sound like a good idea. So we should somehow
> reduce the target. I am open for any better suggestions.

If the situation is changed to order-2, it doesn't look good, either.
I think that some reduction on zone_reclaimable_page() are needed since
it's not possible to free all of them in certain case. But, reduction by order
doesn't make any sense. if we need to consider order to guess probability of
compaction, it should be considered in __compaction_suitable() instead of
reduction from here.

I think that following code that is used in should_reclaim_retry() would be
good for here.

available -= DIV_ROUND_UP(no_progress_loops * available, MAX_RECLAIM_RETRIES)

Any thought?

>> > +           available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
>> > +           compact_result = __compaction_suitable(zone, order, alloc_flags,
>> > +                           ac->classzone_idx, available);
>>
>> It misses tracepoint in compaction_suitable().
>
> Why do you think the check would be useful. I have considered it more
> confusing than halpful to I have intentionally not added it.

What confusing do you have in mind?
If we try to analyze OOM, we need to know why should_compact_retry()
return false and and tracepoint here could be helpful.

>>
>> > +           if (compact_result != COMPACT_SKIPPED &&
>> > +                           compact_result != COMPACT_NOT_SUITABLE_ZONE)
>>
>> It's undesirable to use COMPACT_NOT_SUITABLE_ZONE here. It is just for
>> detailed tracepoint output.
>
> Well this is a compaction code so I considered it acceptable. If you
> consider it a big deal I can extract a wrapper and hide this detail.

It is not a big deal.

> [...]
>
>> > @@ -3040,9 +3040,11 @@ should_compact_retry(unsigned int order, enum compact_result compact_result,
>> >     /*
>> >      * make sure the compaction wasn't deferred or didn't bail out early
>> >      * due to locks contention before we declare that we should give up.
>> > +    * But do not retry if the given zonelist is not suitable for
>> > +    * compaction.
>> >      */
>> >     if (compaction_withdrawn(compact_result))
>> > -           return true;
>> > +           return compaction_zonelist_suitable(ac, order, alloc_flags);
>>
>> I think that compaction_zonelist_suitable() should be checked first.
>> If compaction_zonelist_suitable() returns false, it's useless to
>> retry since it means that compaction cannot run if all reclaimable
>> pages are reclaimed. Logic should be as following.
>>
>> if (!compaction_zonelist_suitable())
>>         return false;
>>
>> if (compaction_withdrawn())
>>         return true;
>
> That is certainly an option as well. The logic above is that I really
> wanted to have a terminal condition when compaction can return
> compaction_withdrawn for ever basically. Normally we are bound by a
> number of successful reclaim rounds. Before we go an change there I
> would like to see where it makes real change though.

It would not make real change because !compaction_withdrawn() and
!compaction_zonelist_suitable() case doesn't happen easily.

But, change makes code more understandable so it's worth doing, IMO.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
