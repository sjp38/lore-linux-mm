Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1DD536B0003
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 05:30:12 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id d12so5297618wri.4
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 02:30:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si4543377wrb.129.2018.03.02.02.30.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Mar 2018 02:30:10 -0800 (PST)
Subject: Re: [patch] mm, compaction: drain pcps for zone when kcompactd fails
References: <alpine.DEB.2.20.1803010340100.88270@chino.kir.corp.google.com>
 <672ebefc-483d-2932-37b5-4ffe58156f0f@suse.cz>
 <alpine.DEB.2.20.1803010446090.96418@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d516bac6-84de-dc5d-5ddb-1057e6337620@suse.cz>
Date: Fri, 2 Mar 2018 11:28:21 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1803010446090.96418@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/01/2018 02:05 PM, David Rientjes wrote:
> On Thu, 1 Mar 2018, Vlastimil Babka wrote:
> 
>> On 03/01/2018 12:42 PM, David Rientjes wrote:
>>> Consider a verbose example using the tools/vm/page-types tool at the
>>> beginning of a ZONE_NORMAL, where 'B' indicates a buddy page and 'S'
>>> indicates a slab page, which the migration scanner is attempting to
>>> defragment (and doing it well, absent coalescing up to cc.order):
>>
>> How can the migration scanner defragment a slab page?
>>
> 
> Hi Vlastimil,

Hi David,

> It doesn't, I'm showing an entire span of buddy pages that could be 
> coalesced into order >= 9 pages, so I thought to include the border pages.
Sure. But "slab page, which the migration scanner is attempting to
defragment (and doing it well..." sounds rather confusing, so please
reword it :)

...

>>> These buddy pages, spanning 1,621 pages, could be coalesced and allow for
>>> three transparent hugepages to be dynamically allocated.  Totaling all
>>> hugepage length spans that could be coalesced, this could yield over 400
>>> hugepages on the zone's free area when at the time this /proc/kpageflags
>>
>> I don't understand the numbers here. With order-9 hugepages it's 512
>> pages per hugepage. If the buddy pages span 1621 pages, how can they
>> yield 400 hugepages?
>>
> 
> The above span is 0x109faa - 0x109955 = 1,621 pages as an example which 
> could be coalesced into three transparent hugepages as stated if not 
> stranded on pcps and rather on the zone's free area.  For this system, 
> running the numbers on the extremely large /proc/kpageflags, I identified 
> spans >512 pages which could be coalesced into >400 hugepages if pcps were 
> drained.

Looks like I just didn't read that part properly, looks clear to me now.

> Check this out:
> 
> Node 1 MemTotal:       132115772 kB
> Node 1 MemFree:        125468300 kB
> 
> Free pages count per migrate type at order         0      1      2      3      4      5      6      7      8      9     10 
> Node    1, zone   Normal, type      Unmovable  18418  24325  10190   5545   1893    976    487    259     20      0      0 
> Node    1, zone   Normal, type        Movable 172691 177791 145558 125810 101482  82792  67745  58527  49923      0      0 
> Node    1, zone   Normal, type    Reclaimable   3909   4828   3505   2543   1246    410     47      5      0      0      0 
> Node    1, zone   Normal, type  Memcg_Reserve      0      0      0      0      0      0      0      0      0      0      0 
> Node    1, zone   Normal, type        Reserve      0      0      0      0      0      0      0      0      0      0      0 
> 
> I can't avoid cringing at that.  There is fragmentation as the result of 
> slab pages being allocated, which we have additional patches for that I'll 
> propose soon after I gather more data, but for this system I gathered 
> /proc/kpageflags and found >400 hugepages that could be coalesced from 
> this zone if pcps were drained.

Yeah that doesn't look very nice :(

>>> was collected, there was _no_ order-9 or order-10 pages available for
>>> allocation even after triggering compaction through procfs.
>>>
>>> When kcompactd fails to defragment memory such that a cc.order page can
>>> be allocated, drain all pcps for the zone back to the buddy allocator so
>>> this stranding cannot occur.  Compaction for that order will subsequently
>>> be deferred, which acts as a ratelimit on this drain.
>>
>> I don't mind the change given the ratelimit, but what difference was
>> observed in practice?
>>
> 
> It's hard to make a direct correlation given the workloads that are 
> scheduled over this set of machines; it takes more than two weeks to get a 
> system this fragmented (the uptime from the above examples is ~34 days) so 
> any comparison between unpatched and patched kernels depends very heavily 
> on what happened over those 34 days and doesn't yield useful results.  The 
> significant data is that from collecting /proc/kpageflags at this moment 
> in time, I can identify 400 spans of >=512 buddy pages.  The reason we 
> have no order-9 and order-10 memory is that these buddy pages cannot be 
> coalesced because of stranding on pcps.
> 
> I wouldn't consider this a separate type of fragmentation such as 
> allocating one slab page from a pageblock that doesn't allow a hugepage to 
> be allocated.  Rather, it's a byproduct of a fast page allocator that 
> utilizes pcps for super fast allocation and freeing, which results in 
> stranding as a side effect.
> 
> The change here is to drain all pcp pages so they have a chance to be 
> coalesced into high-order pages in the chance that compaction fails on a 
> fragmented system, such as in the above examples.  I'm most interested in 
> the kcompactd failure case because that's where it would be most useful 

Right, I'm fine with the patch for kcompactd. You can add
Acked-by: Vlastimil Babka <vbabka@suse.cz>

> for our configurations, but I would understand if we'd want a similar 
> change for direct compaction (it would reasonably be done any time we 
> choose to defer).

I don't think that's needed. kcompactd should be woken up for any such
direct compaction anyway. Also with multiple parallel direct compaction
attempts, the drain might be too frequent even with deferring, without
any gain from it?

>> BTW I wonder if we could be smarter and quicker about the drains. Let a
>> pcp struct page be easily recognized as such, and store the cpu number
>> in there. Migration scanner could then maintain a cpumask, and recognize
>> if the only missing pages for coalescing a cc->order block are on the
>> pcplists, and then do a targeted drain.
>> But that only makes sense to implement if it can make a noticeable
>> difference to offset the additional overhead, of course.
>>
> 
> Right, that sounds doable with the extra overhead that I'm not sure is 
> warranted in this case.  We could certainly have the migration scanner 
> look at every buddy page on the pageblock

IIRC the pages on pcplists don't have PageBuddy, just page_count of 0
and migratetype in page->index.

> and set the cpu in a cpumask if 
> we store it as part of the pcp, and flag it if anything is non-buddy in 
> the case of cc.order >= 9.  It's more complicated for smaller orders.  
> Then isolate_migratepages() would store the cpumask for such blocks and 
> eventually drain pcps from those cpus only if compaction fails. 

My idea was that compaction would maintain an initially empty cpumask in
compact_control, when detecting a page that sits on some cpu's pcplist,
add it to the mask. Also a do_drain flag initially true, that would be
set to false if e.g. a slab page is encountered (cannot be migrated and
is not already free). If the flag is still true and mask non-empty as we
finish a block, drain the cpus in the mask.

> Most of 
> the time it won't fail until the extreme presented above, in which case 
> all that work wouldn't be valuable.

Yeah, maybe the kcompactd change will take care of most such cases already.

> In the cases that it is useful, I 
> found that doing drain_all_pages(zone) is most beneficial for the 
> side-effect of also freeing pcp pages back to MIGRATE_UNMOVABLE pageblocks 
> on the zone's free area to avoid falling back to MIGRATE_MOVABLE 
> pageblocks when pages from MIGRATE_UNMOVABLE pageblocks are similarly 
> stranded on pcps.

Interesting, there might be some value in trying to drain those before
falling back (independently of this patch).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
