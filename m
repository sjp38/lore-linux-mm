Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E5BDF6B000C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 08:05:58 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id l7so5713328iog.10
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 05:05:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f3sor400932itf.138.2018.03.01.05.05.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 05:05:57 -0800 (PST)
Date: Thu, 1 Mar 2018 05:05:54 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, compaction: drain pcps for zone when kcompactd
 fails
In-Reply-To: <672ebefc-483d-2932-37b5-4ffe58156f0f@suse.cz>
Message-ID: <alpine.DEB.2.20.1803010446090.96418@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803010340100.88270@chino.kir.corp.google.com> <672ebefc-483d-2932-37b5-4ffe58156f0f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 1 Mar 2018, Vlastimil Babka wrote:

> On 03/01/2018 12:42 PM, David Rientjes wrote:
> > It's possible for buddy pages to become stranded on pcps that, if drained,
> > could be merged with other buddy pages on the zone's free area to form
> > large order pages, including up to MAX_ORDER.
> > 
> > Consider a verbose example using the tools/vm/page-types tool at the
> > beginning of a ZONE_NORMAL, where 'B' indicates a buddy page and 'S'
> > indicates a slab page, which the migration scanner is attempting to
> > defragment (and doing it well, absent coalescing up to cc.order):
> 
> How can the migration scanner defragment a slab page?
> 

Hi Vlastimil,

It doesn't, I'm showing an entire span of buddy pages that could be 
coalesced into order >= 9 pages, so I thought to include the border pages.  
This was simply the first lengthy span I saw, it's by no means the 
longest.

> > 109954  1       _______S________________________________________________________
> > 109955  2       __________B_____________________________________________________
> > 109957  1       ________________________________________________________________
> > 109958  1       __________B_____________________________________________________
> > 109959  7       ________________________________________________________________
> > 109960  1       __________B_____________________________________________________
> > 109961  9       ________________________________________________________________
> > 10996a  1       __________B_____________________________________________________
> > 10996b  3       ________________________________________________________________
> > 10996e  1       __________B_____________________________________________________
> > 10996f  1       ________________________________________________________________
> > 109970  1       __________B_____________________________________________________
> > 109971  f       ________________________________________________________________
> > ...
> > 109f88  1       __________B_____________________________________________________
> > 109f89  3       ________________________________________________________________
> > 109f8c  1       __________B_____________________________________________________
> > 109f8d  2       ________________________________________________________________
> > 109f8f  2       __________B_____________________________________________________
> > 109f91  f       ________________________________________________________________
> > 109fa0  1       __________B_____________________________________________________
> > 109fa1  7       ________________________________________________________________
> > 109fa8  1       __________B_____________________________________________________
> > 109fa9  1       ________________________________________________________________
> > 109faa  1       __________B_____________________________________________________
> > 109fab  1       _______S________________________________________________________
> > 
> > These buddy pages, spanning 1,621 pages, could be coalesced and allow for
> > three transparent hugepages to be dynamically allocated.  Totaling all
> > hugepage length spans that could be coalesced, this could yield over 400
> > hugepages on the zone's free area when at the time this /proc/kpageflags
> 
> I don't understand the numbers here. With order-9 hugepages it's 512
> pages per hugepage. If the buddy pages span 1621 pages, how can they
> yield 400 hugepages?
> 

The above span is 0x109faa - 0x109955 = 1,621 pages as an example which 
could be coalesced into three transparent hugepages as stated if not 
stranded on pcps and rather on the zone's free area.  For this system, 
running the numbers on the extremely large /proc/kpageflags, I identified 
spans >512 pages which could be coalesced into >400 hugepages if pcps were 
drained.

Check this out:

Node 1 MemTotal:       132115772 kB
Node 1 MemFree:        125468300 kB

Free pages count per migrate type at order         0      1      2      3      4      5      6      7      8      9     10 
Node    1, zone   Normal, type      Unmovable  18418  24325  10190   5545   1893    976    487    259     20      0      0 
Node    1, zone   Normal, type        Movable 172691 177791 145558 125810 101482  82792  67745  58527  49923      0      0 
Node    1, zone   Normal, type    Reclaimable   3909   4828   3505   2543   1246    410     47      5      0      0      0 
Node    1, zone   Normal, type  Memcg_Reserve      0      0      0      0      0      0      0      0      0      0      0 
Node    1, zone   Normal, type        Reserve      0      0      0      0      0      0      0      0      0      0      0 

I can't avoid cringing at that.  There is fragmentation as the result of 
slab pages being allocated, which we have additional patches for that I'll 
propose soon after I gather more data, but for this system I gathered 
/proc/kpageflags and found >400 hugepages that could be coalesced from 
this zone if pcps were drained.

> > was collected, there was _no_ order-9 or order-10 pages available for
> > allocation even after triggering compaction through procfs.
> > 
> > When kcompactd fails to defragment memory such that a cc.order page can
> > be allocated, drain all pcps for the zone back to the buddy allocator so
> > this stranding cannot occur.  Compaction for that order will subsequently
> > be deferred, which acts as a ratelimit on this drain.
> 
> I don't mind the change given the ratelimit, but what difference was
> observed in practice?
> 

It's hard to make a direct correlation given the workloads that are 
scheduled over this set of machines; it takes more than two weeks to get a 
system this fragmented (the uptime from the above examples is ~34 days) so 
any comparison between unpatched and patched kernels depends very heavily 
on what happened over those 34 days and doesn't yield useful results.  The 
significant data is that from collecting /proc/kpageflags at this moment 
in time, I can identify 400 spans of >=512 buddy pages.  The reason we 
have no order-9 and order-10 memory is that these buddy pages cannot be 
coalesced because of stranding on pcps.

I wouldn't consider this a separate type of fragmentation such as 
allocating one slab page from a pageblock that doesn't allow a hugepage to 
be allocated.  Rather, it's a byproduct of a fast page allocator that 
utilizes pcps for super fast allocation and freeing, which results in 
stranding as a side effect.

The change here is to drain all pcp pages so they have a chance to be 
coalesced into high-order pages in the chance that compaction fails on a 
fragmented system, such as in the above examples.  I'm most interested in 
the kcompactd failure case because that's where it would be most useful 
for our configurations, but I would understand if we'd want a similar 
change for direct compaction (it would reasonably be done any time we 
choose to defer).

> BTW I wonder if we could be smarter and quicker about the drains. Let a
> pcp struct page be easily recognized as such, and store the cpu number
> in there. Migration scanner could then maintain a cpumask, and recognize
> if the only missing pages for coalescing a cc->order block are on the
> pcplists, and then do a targeted drain.
> But that only makes sense to implement if it can make a noticeable
> difference to offset the additional overhead, of course.
> 

Right, that sounds doable with the extra overhead that I'm not sure is 
warranted in this case.  We could certainly have the migration scanner 
look at every buddy page on the pageblock and set the cpu in a cpumask if 
we store it as part of the pcp, and flag it if anything is non-buddy in 
the case of cc.order >= 9.  It's more complicated for smaller orders.  
Then isolate_migratepages() would store the cpumask for such blocks and 
eventually drain pcps from those cpus only if compaction fails.  Most of 
the time it won't fail until the extreme presented above, in which case 
all that work wouldn't be valuable.  In the cases that it is useful, I 
found that doing drain_all_pages(zone) is most beneficial for the 
side-effect of also freeing pcp pages back to MIGRATE_UNMOVABLE pageblocks 
on the zone's free area to avoid falling back to MIGRATE_MOVABLE 
pageblocks when pages from MIGRATE_UNMOVABLE pageblocks are similarly 
stranded on pcps.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
