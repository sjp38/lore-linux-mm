Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 554FD6B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 11:52:49 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id m15so4028453wgh.2
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 08:52:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si5733732wik.4.2014.01.29.08.52.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 08:52:47 -0800 (PST)
Message-ID: <52E931D9.8050002@suse.cz>
Date: Wed, 29 Jan 2014 17:52:41 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] improve robustness on handling migratetype
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com> <20140109092720.GM27046@suse.de> <20140110084854.GA22058@lge.com>
In-Reply-To: <20140110084854.GA22058@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/10/2014 09:48 AM, Joonsoo Kim wrote:
> On Thu, Jan 09, 2014 at 09:27:20AM +0000, Mel Gorman wrote:
>> On Thu, Jan 09, 2014 at 04:04:40PM +0900, Joonsoo Kim wrote:
>>> Hello,
>>>
>>> I found some weaknesses on handling migratetype during code review and
>>> testing CMA.
>>>
>>> First, we don't have any synchronization method on get/set pageblock
>>> migratetype. When we change migratetype, we hold the zone lock. So
>>> writer-writer race doesn't exist. But while someone changes migratetype,
>>> others can get migratetype. This may introduce totally unintended value
>>> as migratetype. Although I haven't heard of any problem report about
>>> that, it is better to protect properly.
>>>
>>
>> This is deliberate. The migratetypes for the majority of users are advisory
>> and aimed for fragmentation avoidance. It was important that the cost of
>> that be kept as low as possible and the general case is that migration types
>> change very rarely. In many cases, the zone lock is held. In other cases,
>> such as splitting free pages, the cost is simply not justified.
>>
>> I doubt there is any amount of data you could add in support that would
>> justify hammering the free fast paths (which call get_pageblock_type).
>
> Hello, Mel.
>
> There is a possibility that we can get unintended value such as 6 as migratetype
> if reader-writer (get/set pageblock_migratetype) race happends. It can be
> possible, because we read the value without any synchronization method. And
> this migratetype, 6, has no place in buddy freelist, so array index overrun can
> be possible and the system can break, although I haven't heard that it occurs.

Hello,

it seems this can indeed happen. I'm working on memory compaction 
improvements and in a prototype patch, I'm basically adding calls of 
start_isolate_page_range() undo_isolate_page_range() some functions 
under compact_zone(). With this I've seen occurrences of NULL pointers 
in move_freepages(), free_one_page() in places where 
free_list[migratetype] is manipulated by e.g. list_move(). That lead me 
to question the value of migratetype and I found this thread. Adding 
some debugging in get_pageblock_migratetype() and voila, I get a value 
of 6 being read.

So is it just my patch adding a dangerous situation, or does it exist in
mainline as well? By looking at free_one_page(), it uses zone->lock, but
get_pageblock_migratetype() is called by its callers 
(free_hot_cold_page() or __free_pages_ok()) outside of the lock. This 
determined migratetype is then used under free_one_page() to access a 
free_list.

It seems that this could race with set_pageblock_migratetype() called 
from try_to_steal_freepages() (despite the latter being properly 
locked). There are also other callers but those seem to be either 
limited to initialization and isolation, which should be rare (?).
However, try_to_steal_freepages can occur repeatedly.
So I assume that the race happens but never manifests as a fatal error 
as long as MIGRATE_UNMOVABLE, MIGRATE_RECLAIMABLE and MIGRATE_MOVABLE
values are used. Only MIGRATE_CMA and MIGRATE_ISOLATE have values with 
bit 4 enabled and can thus result in invalid values due to non-atomic 
access.

Does that make sense to you and should we thus proceed with patching 
this race?

Vlastimil

> I think that my solution is too expensive. However, I think that we need
> solution. aren't we? Do you have any better idea?
>
>>
>>> Second, (get/set)_freepage_migrate isn't used properly. I guess that it
>>> would be introduced for per cpu page(pcp) performance, but, it is also
>>> used by memory isolation, now. For that case, the information isn't
>>> enough to use, so we need to fix it.
>>>
>>> Third, there is the problem on buddy allocator. It doesn't consider
>>> migratetype when merging buddy, so pages from cma or isolate region can
>>> be moved to other migratetype freelist. It makes CMA failed over and over.
>>> To prevent it, the buddy allocator should consider migratetype if
>>> CMA/ISOLATE is enabled.
>>
>> Without loioing at the patches, this is likely to add some cost to the
>> page free fast path -- heavy cost if it's a pageblock lookup and lighter
>> cost if you are using cached page information which is potentially stale.
>> Why not force CMA regions to be aligned on MAX_ORDER_NR_PAGES boundary
>> instead to avoid any possibility of merging issues?
>>
>
> There was my mistake. CMA region is aligned on MAX_ORDER_NR_PAGES, so it
> can't happed. Sorry for noise.
>
>>> This patchset is aimed at fixing these problems and based on v3.13-rc7.
>>>
>>>    mm/page_alloc: synchronize get/set pageblock
>>
>> cost with no justification.
>>
>>>    mm/cma: fix cma free page accounting
>>
>> sounds like it would be a fix but unrelated to the leader and should be
>> seperated out on its own
>
> Yes, it is not related to this topic and it is wrong patch as Laura
> pointed out, so I will drop it.
>
>>>    mm/page_alloc: move set_freepage_migratetype() to better place
>>
>> Very vague. If this does something useful then it could do with a better
>> subject.
>
> Okay.
>
>>>    mm/isolation: remove invalid check condition
>>
>> Looks harmless.
>>
>>>    mm/page_alloc: separate interface to set/get migratetype of freepage
>>>    mm/page_alloc: store freelist migratetype to the page on buddy
>>>      properly
>>
>> Potentially sounds useful
>>
>
> I made these two patches for last patch to reduce performance effect of it.
> In case of dropping last patch, it is better to remove the last callsite
> using freelist migratetype to know the buddy freelist type. I will do respin.
>
> Thanks.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
