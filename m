Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id D83716B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:20:47 -0400 (EDT)
Received: by ladw1 with SMTP id w1so37292592lad.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:20:47 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [95.108.253.251])
        by mx.google.com with ESMTPS id xk4si1293353lac.75.2015.03.18.07.20.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 07:20:46 -0700 (PDT)
Message-ID: <550989BB.5070400@yandex-team.ru>
Date: Wed, 18 Mar 2015 17:20:43 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: reset pages_scanned only when free pages are
 above high watermark
References: <20150311183023.4476.40069.stgit@buzz> <55098230.5080600@suse.cz>
In-Reply-To: <55098230.5080600@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: Roman Gushchin <klamm@yandex-team.ru>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On 18.03.2015 16:48, Vlastimil Babka wrote:
> On 03/11/2015 07:30 PM, Konstantin Khlebnikov wrote:
>> Technically, this counter works as OOM-countdown. Let's reset it only
>> when zone is completely recovered and ready to handle any allocations.
>> Otherwise system could never recover and stuck in livelock.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>
> Hmm, could this help in cases like this one?
> https://lkml.org/lkml/2015/1/23/688

Probably yes. I've seen several live-locks in reclaimer in similar
setup without swap. Unfortunately that happened on old kernel 3.10
so it's hard to understand how this will work for newer kernels.

I've seen some of cpus stuck in grab_super_passive(): in v4.0
it will be replaced with trylock_super which have trylock semantics.

Another problem is that get_scan_count() doesn't protect last
pages in pagecache if system have no swap: I mean (zonefile + zonefree
<= high_wmark_pages(zone))). With swap kernel balance between anon and
file lrus and makes proportional pressure to slab shrinkerers. Without
swap it can scan only file lru. (this suppose to change for MADV_FREE?)
It's unclear what to do with slabs when we have no lru pages to scan.

And the third is that starting from v3.12 commit
6e543d5780e36ff5ee56c44d7e2e30db3457a7ed kernel ignores leftovers in
shrinkable slabs when it sets all_unreclaimable mark. Probably that
was main reason of live-lock in my case: in v3.10 it's much harder to 
get all zones in all_unreclaimable state.

Anyway, all_unreclaimable seems too fragile: kernel drops is after
freeing just one page. Theoretically system might stuck in live-lock
where userspace application reclaims and faults into data, code and
stack pages endlessly. Each time kernel reclaims that page but cpu
needs at least three (up to six?) pages to execute at least one
instruction.

>
>> ---
>>   mm/page_alloc.c |    6 ++++--
>>   1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index ffd5ad2a6e10..ef7795c8c121 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -701,7 +701,8 @@ static void free_pcppages_bulk(struct zone *zone,
>> int count,
>>
>>       spin_lock(&zone->lock);
>>       nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
>> -    if (nr_scanned)
>> +    if (nr_scanned &&
>> +        zone_page_state(zone, NR_FREE_PAGES) > high_wmark_pages(zone))
>>           __mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
>>
>>       while (to_free) {
>> @@ -752,7 +753,8 @@ static void free_one_page(struct zone *zone,
>>       unsigned long nr_scanned;
>>       spin_lock(&zone->lock);
>>       nr_scanned = zone_page_state(zone, NR_PAGES_SCANNED);
>> -    if (nr_scanned)
>> +    if (nr_scanned &&
>> +        zone_page_state(zone, NR_FREE_PAGES) > high_wmark_pages(zone))
>>           __mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
>>
>>       if (unlikely(has_isolate_pageblock(zone) ||
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>


-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
