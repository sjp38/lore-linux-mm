Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 66AB16B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 04:36:44 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so4428923wgh.11
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 01:36:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ux10si19017818wjc.72.2014.07.15.01.36.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 01:36:42 -0700 (PDT)
Message-ID: <53C4E813.7020108@suse.cz>
Date: Tue, 15 Jul 2014 10:36:35 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] fix freepage count problems due to memory isolation
References: <1404460675-24456-1-git-send-email-iamjoonsoo.kim@lge.com> <53B6C947.1070603@suse.cz> <20140707044932.GA29236@js1304-P5Q-DELUXE> <53BAAFA5.9070403@suse.cz> <20140714062222.GA11317@js1304-P5Q-DELUXE> <53C3A7A5.9060005@suse.cz> <20140715082828.GM11317@js1304-P5Q-DELUXE>
In-Reply-To: <20140715082828.GM11317@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, Lisa Du <cldu@marvell.com>, linux-kernel@vger.kernel.org

On 07/15/2014 10:28 AM, Joonsoo Kim wrote:
> On Mon, Jul 14, 2014 at 11:49:25AM +0200, Vlastimil Babka wrote:
>> On 07/14/2014 08:22 AM, Joonsoo Kim wrote:
>>> On Mon, Jul 07, 2014 at 04:33:09PM +0200, Vlastimil Babka wrote:
>>>> On 07/07/2014 06:49 AM, Joonsoo Kim wrote:
>>>>> Ccing Lisa, because there was bug report it may be related this
>>>>> topic last Saturday.
>>>>>
>>>>> http://www.spinics.net/lists/linux-mm/msg75741.html
>>>>>
>>>>> On Fri, Jul 04, 2014 at 05:33:27PM +0200, Vlastimil Babka wrote:
>>>>>> On 07/04/2014 09:57 AM, Joonsoo Kim wrote:
>>>>>>> Hello,
>>>>>>
>>>>>> Hi Joonsoo,
>>>>>>
>>>>>> please CC me on further updates, this is relevant to me.
>>>>>
>>>>> Hello, Vlastimil.
>>>>>
>>>>> Sorry for missing you. :)
>>>>>
>>>>>>
>>>>>>> This patchset aims at fixing problems due to memory isolation found by
>>>>>>> testing my patchset [1].
>>>>>>>
>>>>>>> These are really subtle problems so I can be wrong. If you find what I am
>>>>>>> missing, please let me know.
>>>>>>>
>>>>>>> Before describing bugs itself, I first explain definition of freepage.
>>>>>>>
>>>>>>> 1. pages on buddy list are counted as freepage.
>>>>>>> 2. pages on isolate migratetype buddy list are *not* counted as freepage.
>>>>>>
>>>>>> I think the second point is causing us a lot of trouble. And I wonder if it's really
>>>>>> justified! We already have some is_migrate_isolate() checks in the fast path and now you
>>>>>> would add more, mostly just to keep this accounting correct.
>>>>>
>>>>> It's not just for keeping accouting correct. There is another
>>>>> purpose for is_migrate_isolate(). It forces freed pages to go into
>>>>> isolate buddy list. Without it, freed pages would go into other
>>>>> buddy list and will be used soon. So memory isolation can't work well
>>>>> without is_migrate_isolate() checks and success rate could decrease.
>>>>
>>>> Well I think that could be solved also by doing a lru/pcplists drain
>>>> right after marking pageblock as MIGRATETYPE_ISOLATE. After that
>>>> moment, anything newly put on pcplists should observe the new
>>>> migratetype and go to the correct pcplists. As putting stuff on
>>>> pcplists is done with disabled interrupts, and draining is done by
>>>> IPI, I think it should work correctly if we put the migratetype
>>>> determination under the disabled irq part in free_hot_cold_page().
>>>
>>> Hello, sorry for late.
>>>
>>> Yes, this can close the race on migratetype buddy list, but, there is
>>> a problem. See the below.
>>>
>>>>
>>>>> And, I just added three more is_migrate_isolate() in the fast
>>>>> path, but, two checks are in same *unlikely* branch and I can remove
>>>>> another one easily. Therefore it's not quite problem I guess. (It even
>>>>> does no-op if MEMORY_ISOLATION is disabled.)
>>>>> Moreover, I removed one unconditional get_pageblock_migratetype() in
>>>>> free_pcppages_bulk() so, in performance point or view, freepath would
>>>>> be improved.
>>>>
>>>> I haven't checked the individual patches yet, but I'll try.
>>>>
>>>>>>
>>>>>> So the question is, does it have to be correct? And (admiteddly not after a completely
>>>>>> exhaustive analysis) I think the answer is, surprisingly, that it doesn't :)
>>>>>>
>>>>>> Well I of course don't mean that the freepage accounts could go random completely, but
>>>>>> what if we allowed them to drift a bit, limiting both the max error and the timeframe
>>>>>> where errors are possible? After all, watermarks checking is already racy so I don't think
>>>>>> it would be hurt that much.
>>>>>
>>>>> I understand your suggestion. I once thought like as you, but give up
>>>>> that idea. Watermark checking is already racy, but, it's *only*
>>>>> protection to prevent memory allocation. After passing that check,
>>>>> there is no mean to prevent us from allocating memory. So it should
>>>>> be accurate as much as possible. If we allow someone to get the
>>>>> memory without considering memory isolation, free memory could be in
>>>>> really low state and system could be broken occasionally.
>>>>
>>>> It would definitely require more thorough review, but I think with
>>>> the pcplists draining changes outlined above, there shouldn't be any
>>>> more inaccuracy happening.
>>>>
>>>>>>
>>>>>> Now if we look at what both CMA and memory hot-remove does is:
>>>>>>
>>>>>> 1. Mark a MAX_ORDER-aligned buch of pageblocks as MIGRATE_ISOLATE through
>>>>>> start_isolate_page_range(). As part of this, all free pages in that area are
>>>>>> moved on the isolate freelist through move_freepages_block().
>>>>>>
>>>>>> 2. Try to migrate away all non-free pages in the range. Also drain pcplists and lru_add
>>>>>> caches.
>>>>>>
>>>>>> 3. Check if everything was successfully isolated by test_pages_isolated(). Restart and/or
>>>>>> undo pageblock isolation if not.
>>>>>>
>>>>>> So my idea is to throw away all special-casing of is_migrate_isolate() in the buddy
>>>>>> allocator, which would therefore account free pages on the isolate freelist as normal free
>>>>>> pages.
>>>>>> The accounting of isolated pages would be instead done only on the top level of CMA/hot
>>>>>> remove in the three steps outlined above, which would be modified as follows:
>>>>>>
>>>>>> 1. Calculate N as the target number of pages to be isolated. Perform the actions of step 1
>>>>>> as usual. Calculate X as the number of pages that move_freepages_block() has moved.
>>>>>> Subtract X from freepages (this is the same as it is done now), but also *remember the
>>>>>> value of X*
>>>>>>
>>>>>> 2. Migrate and drain pcplists as usual. The new free pages will either end up correctly on
>>>>>> isolate freelist, or not. We don't care, they will be accounted as freepages either way.
>>>>>> This is where some inaccuracy in accounted freepages would build up.
>>>>>>
>>>>>> 3. If test_pages_isolated() checks pass, subtract (N - X) from freepages. The result is
>>>>>> that we have a isolated range of N pages that nobody can steal now as everything is on
>>>>>> isolate freelist and is MAX_ORDER aligned. And we have in total subtracted N pages (first
>>>>>> X, then N-X). So the accounting matches reality.
>>>>>>
>>>>>> If we have to undo, we undo the isolation and as part of this, we use
>>>>>> move_freepages_block() to move pages from isolate freelist to the normal ones. But we
>>>>>> don't care how many pages were moved. We simply add the remembered value of X to the
>>>>>> number of freepages, undoing the change from step 1. Again, the accounting matches reality.
>>>>>>
>>>>>>
>>>>>> The final point is that if we do this per MAX_ORDER blocks, the error in accounting cannot
>>>>>> be ever larger than 4MB and will be visible only during time a single MAX_ORDER block is
>>>>>> handled.
>>>>>
>>>>> The 4MB error in accounting looks serious for me. min_free_kbytes is
>>>>> 4MB in 1GB system. So this 4MB error would makes all things broken in
>>>>> such systems. Moreover, there are some ARCH having larger
>>>>> pageblock_order than MAX_ORDER. In this case, the error will be larger
>>>>> than 4MB.
>>>>>
>>>>> In addition, I have a plan to extend CMA to work in parallel. It means
>>>>> that there could be parallel memory isolation users rather than just
>>>>> one user at the same time, so, we cannot easily bound the error under
>>>>> some degree.
>>>>
>>>> OK. I had thought that the error would be much smaller in practice,
>>>> but probably due to how buddy merging works, it would be enough if
>>>> just the very last freed page in the MAX_ORDER block was misplaced,
>>>> and that would trigger a cascading merge that will end with single
>>>> page at MAX_ORDER size becoming misplaced. So let's probably forget
>>>> this approach.
>>>>
>>>>>> As a possible improvement, we can assume during phase 2 that every page freed by migration
>>>>>> will end up correctly on isolate free list. So we create M free pages by migration, and
>>>>>> subtract M from freepage account. Then in phase 3 we either subtract (N - X - M), or add X
>>>>>> + M in the undo case. (Ideally, if we succeed, X + M should be equal to N, but due to
>>>>>> pages on pcplists and the possible races it will be less). I think with this improvement,
>>>>>> any error would be negligible.
>>>>>>
>>>>>> Thoughts?
>>>>>
>>>>> Thanks for suggestion. :)
>>>>> It is really good topic to think deeply.
>>>>>
>>>>> For now, I'd like to fix these problems without side-effect as you
>>>>> suggested. Your suggestion changes the meaning of freepage that
>>>>> isolated pages are included in nr_freepage and there could be possible
>>>>> regression in success rate of memory hotplug and CMA. Possibly, it
>>>>> is the way we have to go, but, IMHO, it isn't the time to go. Before
>>>>> going that way, we should fix current implementation first so that
>>>>> fixes can be backported to old kernel if someone needs.
>>>>
>>>> Adding the extra pcplist drains and reordering
>>>> get_pageblock_migratetype() under disabled IRQ's should be small
>>>> enough to be backportable and not bring any regressions to success
>>>> rates. There will be some cost for the extra drains, but paid only
>>>> when the memory isolation actually happens. Extending the scope of
>>>> disabled irq's would affect fast path somewhat, but I guess less
>>>> than extra checks?
>>>
>>> Your approach would close the race on migratetype buddy list. But,
>>> I'm not sure how we can count number of freepages correctly. IIUC,
>>> unlike my approach, this approach allows merging between isolate buddy
>>> list and normal buddy list and it would results in miscounting number of
>>> freepages. You probably think that move_freepages_block() could fixup
>>> all the situation, but, I don't think so.
>>
>> No, I didn't think that, I simply overlooked this scenario. Good catch.
>>
>>> After applying your approach,
>>>
>>> CPU1                                    CPU2
>>> set_migratetype_isolate()               - free_one_page()
>>>    - lock
>>>    - set_pageblock_migratetype()
>>>    - unlock
>>>    - drain...
>>>                                          - lock
>>>                                          - __free_one_page() with MIGRATE_ISOLATE
>>>                                          - merged with normal page and linked with
>>>                                          isolate buddy list
>>>                                          - skip to count freepage, because of
>>>                                          MIGRATE_ISOLATE
>>>                                          - unlock
>>>    - lock
>>>    - move_freepages_block()
>>>      try to fixup freepages count
>>>    - unlock
>>>
>>> We want to fixup counting in move_freepages_block(), but, we can't
>>> because we don't have enough information whether this page is already
>>> accounted on number of freepage or not. Could you help me to find out
>>> the whole mechanism of your approach?
>>
>> I can't think of an easy fix to this situation.
>>
>> A non-trivial fix that comes to mind (and I might have overlooked
>> something) is something like:
>>
>> - distinguish MIGRATETYPE_ISOLATING and MIGRATETYPE_ISOLATED
>> - CPU1 first sets MIGRATETYPE_ISOLATING before the drain
>> - when CPU2 sees MIGRATETYPE_ISOLATING, it just puts the page on
>> special unbounded pcplist and that's it
>> - CPU1 does the drain as usual, potentially misplacing some pages
>> that move_freepages_block() will then fix. But no wrong merging can
>> occur.
>> - after move_freepages_block(), CPU1 changes MIGRATETYPE_ISOLATING
>> to MIGRATETYPE_ISOLATED
>> - CPU2 can then start freeing directly on isolate buddy list. There
>> might be some pages still on the special pcplist of CPU2/CPUx but
>> that means they won't merge yet.
>> - CPU1 executes on all CPU's a new operation that flushes the
>> special pcplist on isolate buddy list and merge as needed.
>>
>
> Really thanks for sharing idea.

Ah, you didn't find a hole yet, good sign :D

> It looks possible but I guess that it needs more branches related to
> pageblock isolation. Now I have a quick thought to prevent merging,
> but, I'm not sure that it is better than current patchset. After more
> thinking, I will post rough idea here.

I was thinking about it more and maybe it wouldn't need a new 
migratetype after all. But it would always need to free isolate pages on 
the special pcplist. That means this pcplist would be used not only 
during the call to start_isolate_page_range, but all the way until 
undo_isolate_page_range(). I don't think it's a problem and it 
simplifies things. The only way to move to isolate freelist is through 
the new isolate pcplist flush operation initiated by a single CPU at 
well defined time.

The undo would look like:
- (migratetype is still set to MIGRATETYPE_ISOLATE, CPU2 frees affected 
pages to the special freelist)
- CPU1 does move_freepages_block() to put pages back from isolate 
freelist to e.g. MOVABLE or CMA. At this point, nobody will put new 
pages on isolate freelist.
- CPU1 changes migratetype of the pageblock to e.g. MOVABLE. CPU2 and 
others start freeing normally. Merging can occur only on the MOVABLE 
freelist, as isolate freelist is empty and nobody puts pages there.
- CPU1 flushes the isolate pcplists of all CPU's on the MOVABLE 
freelist. Merging is again correct.

I think your plan of multiple parallel CMA allocations (and thus 
multiple parallel isolations) is also possible. The isolate pcplists can 
be shared by pages coming from multiple parallel isolations. But the 
flush operation needs a pfn start/end parameters to only flush pages 
belonging to the given isolation. That might mean a bit of inefficient 
list traversing, but I don't think it's a problem.

Makes sense?
Vlastimil

> Thanks.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
