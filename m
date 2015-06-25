Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 197FD6B006E
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 13:11:19 -0400 (EDT)
Received: by obpn3 with SMTP id n3so51245128obp.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:11:18 -0700 (PDT)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id j188si20272520oif.115.2015.06.25.10.11.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 10:11:18 -0700 (PDT)
Received: by oigx81 with SMTP id x81so57344643oig.1
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 10:11:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150625110314.GJ11809@suse.de>
References: <1435193121-25880-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20150625110314.GJ11809@suse.de>
Date: Fri, 26 Jun 2015 02:11:17 +0900
Message-ID: <CAAmzW4OnE7A6sxEDFRcp9jbuxkYkJvJw_PH1TBFtS0nZOmrVGg@mail.gmail.com>
Subject: Re: [RFC PATCH 00/10] redesign compaction algorithm
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>

2015-06-25 20:03 GMT+09:00 Mel Gorman <mgorman@suse.de>:
> On Thu, Jun 25, 2015 at 09:45:11AM +0900, Joonsoo Kim wrote:
>> Recently, I got a report that android get slow due to order-2 page
>> allocation. With some investigation, I found that compaction usually
>> fails and many pages are reclaimed to make order-2 freepage. I can't
>> analyze detailed reason that causes compaction fail because I don't
>> have reproducible environment and compaction code is changed so much
>> from that version, v3.10. But, I was inspired by this report and started
>> to think limitation of current compaction algorithm.
>>
>> Limitation of current compaction algorithm:
>>
>
> I didn't review the individual patches unfortunately but have a few comments
> about things to watch out for.

Hello, Mel.

Your comment always helps me a lot.
Thanks in advance.

>> 1) Migrate scanner can't scan behind of free scanner, because
>> each scanner starts at both side of zone and go toward each other. If
>> they meet at some point, compaction is stopped and scanners' position
>> is reset to both side of zone again. From my experience, migrate scanner
>> usually doesn't scan beyond of half of the zone range.
>>
>
> This was deliberate because if the scanners cross then they can undo each
> others work. The free scanner can locate a pageblock that pages were
> recently migrated from. Finishing compaction when the scanners met was
> the easiest way of avoiding the problem without maintaining global
> state.

I internally have a patch that prevents this kind of undoing.
I don't submit it because it doesn't have any notable effect on current
benchmarks, but, i can include it on next version.

> Global state is required because there can be parallel compaction
> attempts. The global state requires locking to avoid two parallel
> compaction attempts selecting the same pageblock for migrating to and
> from.

I used skip-bit to prevent selecting same pageblock for migrating to
and from. If freepage scanner isolates some pages, skip-bit is set
on that pageblock. Migration scanner checks skip-bit before scanning
and will avoid to scan that marked pageblock.


> This global state then needs to be reset on each compaction cycle. The
> difficulty then is that there is a potential ping-pong effect. A pageblock
> that was previously a migration target for the free scanner may become a
> migration source for the migration scanner. Having the scanners operate
> in opposite directions and meet in the middle avoided this problem.

I admit that this patchset causes ping-pong effect between each compaction
cycle, because skip-bit is reset on each compaction cycle. But, I think that
we don't need to worry about it. We should make high order page up to
PAGE_COSTLY_ORDER by any means. If compaction fails, we need to
reclaim some pages and this would cause file I/O. It is more bad than
ping-pong effect on compaction.

> I'm not saying the current design is perfect but it avoids a number of
> problems that are worth keeping in mind. Regressions in this area will
> look like higher system CPU time with most of the additional time spent
> in compaction.
>
>> 2) Compaction capability is highly depends on amount of free memory.
>> If there is 50 MB free memory on 4 GB system, migrate scanner can
>> migrate 50 MB used pages at maximum and then will meet free scanner.
>> If compaction can't make enough high order freepages during this
>> amount of work, compaction would fail. There is no way to escape this
>> failure situation in current algorithm and it will scan same region and
>> fail again and again. And then, it goes into compaction deferring logic
>> and will be deferred for some times.
>>
>
> This is why reclaim/compaction exists. When this situation occurs, the
> kernel is meant to reclaim some order-0 pages and try again. Initially
> it was lumpy reclaim that was used but it severely disrupted the system.

No, current kernel implementation doesn't reclaim pages in this situation.
Watermark check for order 0 would be passed in this case and reclaim logic
regards this state as compact_ready and there is no need to reclaim. Even if
we change it to reclaim some pages in this case, there are usually parallel
tasks who want to use more memory so free memory size wouldn't increase
as much as we need and compaction wouldn't succeed.

>> 3) Compaction capability is highly depends on migratetype of memory,
>> because freepage scanner doesn't scan unmovable pageblock.
>>
>
> For a very good reason. Unmovable allocation requests that fallback to
> other pageblocks are the worst in terms of fragmentation avoidance. The
> more of these events there are, the more the system will decay. If there
> are many of these events then a compaction benchmark may start with high
> success rates but decay over time.
>
> Very broadly speaking, the more the mm_page_alloc_extfrag tracepoint
> triggers with alloc_migratetype == MIGRATE_UNMOVABLE, the faster the
> system is decaying. Having the freepage scanner select unmovable
> pageblocks will trigger this event more frequently.
>
> The unfortunate impact is that selecting unmovable blocks from the free
> csanner will improve compaction success rates for high-order kernel
> allocations early in the lifetime of the system but later fail high-order
> allocation requests as more pageblocks get converted to unmovable. It
> might be ok for kernel allocations but THP will eventually have a 100%
> failure rate.

I wrote rationale in the patch itself. We already use non-movable pageblock
for migration scanner. It empties non-movable pageblock so number of
freepage on non-movable pageblock will increase. Using non-movable
pageblock for freepage scanner negates this effect so number of freepage
on non-movable pageblock will be balanced. Could you tell me in detail
how freepage scanner select unmovable pageblocks will cause
more fragmentation? Possibly, I don't understand effect of this patch
correctly and need some investigation. :)

>> To investigate compaction limitations, I made some compaction benchmarks.
>> Base environment of this benchmark is fragmented memory. Before testing,
>> 25% of total size of memory is allocated. With some tricks, these
>> allocations are evenly distributed to whole memory range. So, after
>> allocation is finished, memory is highly fragmented and possibility of
>> successful order-3 allocation is very low. Roughly 1500 order-3 allocation
>> can be successful. Tests attempt excessive amount of allocation request,
>> that is, 3000, to find out algorithm limitation.
>>
>
> Did you look at forcing MIGRATE_SYNC for these allocation
> requests? Compaction was originally designed for huge page allocations and
> high-order kernel allocations up to PAGE_ALLOC_COSTLY_ORDER were meant to
> free naturally. MIGRATE_SYNC considers more pageblocks for migration and
> should improve success rates at the cost of longer stalls.

This test uses unmovable allocation with GFP_NORETRY, so it will fallback
sync compaction after failing async compaction and direct reclaim. It should be
mentioned but I missed it. Sorry about that. I will include it on next version.


>> <SNIP>
>> Column 'Success' and 'Success(N) are calculated by following equations.
>>
>> Success = successful allocation * 100 / attempts
>> Success(N) = successful allocation * 100 /
>>               number of successful order-3 allocation
>>
>
> I don't quite get this.
>
> Success    = success * 100 / attempts
> Success(N) = success * 100  / success
>
> Can you try explaining Success(N) again? It's not clear how the first
> "success allocation" differs from the "successful order-3" allocations.
> Is it all allocation attempts or any order in the system or what?

Sorry for confusing word.

Success = successful allocation * 100 / attempts
Success(N) = successful allocation * 100 / order 3 candidates

order 3 candidates is limited as roughly 1500 in my test setup because
I did some trick to make memory fragmented. So, Success(N) is
calculated as success * 100 / 1500 (1500 slightly varies on each test)
in my test setup.

>> <SNIP>
>>
>> Anyway, as free memory decreases, compaction success rate also decreases.
>> It is better to remove this dependency to get stable compaction result
>> in any case.
>>
>
> BTW, this is also expected. Early in the existence of compaction it had
> much higher success rates -- high 90%s around kernel 3.0. This has
> dropped over time because the *cost* of granting those allocations was
> so high. These are timing results from a high-order allocation stress
> test
>
> stress-highalloc
>                       3.0.0               3.0.101               3.12.38
> Ops 1       89.00 (  0.00%)       84.00 (  5.62%)       11.00 ( 87.64%)
> Ops 2       91.00 (  0.00%)       71.00 ( 21.98%)       11.00 ( 87.91%)
> Ops 3       93.00 (  0.00%)       89.00 (  4.30%)       80.00 ( 13.98%)
>
>                3.0.0     3.0.101     3.12.38
>              vanilla     vanilla     vanilla
> User         2904.90     2280.92     2873.42
> System        630.53      624.25      510.87
> Elapsed      3869.95     1291.28     1232.83
>
> Ops 1 and 2 are allocation attempts under heavy load and note how kernel
> 3.0 and 3.0.101 had success rates of over 80%. However, look at how long
> 3.0.0 took -- over an hour vs 20 minutes in later kernels.

I can attach elapsed time in one of stress-highalloc test.
Others have same tendency.

                 base                       threshold
Ops 1       24.00 (  0.00%)       81.00 (-237.50%)
Ops 2       30.00 (  0.00%)       83.00 (-176.67%)
Ops 3       91.00 (  0.00%)       94.00 ( -3.30%)
User         5219.23     4168.99
System       1100.04     1018.23
Elapsed      1357.40     1488.90
Compaction stalls                 5313       10250
Compaction success                1796        4893
Compaction failures               3517        5357
Compaction pages isolated      7069617    12330604
Compaction migrate scanned    64710910    59484302
Compaction free scanned      460910906   129035561
Compaction cost                   4202        6934

Elapsed time slightly increase, but, not much as 3.0.0.
With patch, we get double number of high order page and
roughly double pages isolated so I think it is reasonable trade-off.

> Later kernels avoid any expensive step even though it means the success
> rates are lower. Your figures look impressive but remember that the
> success rates could be due to very long stalls.
>
>> Pageblock migratetype makes big difference on success rate. 3) would be
>> one of reason related to this result. Because freepage scanner doesn't
>> scan non-movable pageblock, compaction can't get enough freepage for
>> migration and compaction easily fails. This patchset try to solve it
>> by allowing freepage scanner to scan on non-movable pageblock.
>>
>
> I really think that using unmovable blocks as a freepage scanner target
> will cause all THP allocation attempts to eventually fail.

Please elaborate more on it. I can't imagine how it happens.

>> Result show that we cannot get all possible high order page through
>> current compaction algorithm. And, in case that migratetype of
>> pageblock is unmovable, success rate get worse. Although we can solve
>> problem 3) in current algorithm, there is unsolvable limitations, 1), 2),
>> so I'd like to change compaction algorithm.
>>
>> This patchset try to solve these limitations by introducing new compaction
>> approach. Main changes of this patchset are as following:
>>
>> 1) Make freepage scanner scans non-movable pageblock
>> Watermark check doesn't consider how many pages in non-movable pageblock.
>
> This was to avoid expensive checks in compaction. It was for huge page
> allocations so if compaction took too long then it offset any benefit
> from using huge pages.

I also think that counting number of freepage on non-movable pageblock by
compaction isn't appropriate solution.

>>
>> 2) Introduce compaction depletion state
>> Compaction algorithm will be changed to scan whole zone range. In this
>> approach, compaction inevitably do back and forth migration between
>> different iterations. If back and forth migration can make highorder
>> freepage, it can be justified. But, in case of depletion of compaction
>> possiblity, this back and forth migration causes unnecessary overhead.
>> Compaction depleteion state is introduced to avoid this useless
>> back and forth migration by detecting depletion of compaction possibility.
>>
>
> Interesting.
>
>> 3) Change scanner's behaviour
>> Migration scanner is changed to scan whole zone range regardless freepage
>> scanner position. Freepage scanner also scans whole zone from
>> zone_start_pfn to zone_end_pfn. To prevent back and forth migration
>> within one compaction iteration, freepage scanner marks skip-bit when
>> scanning pageblock. Migration scanner will skip this marked pageblock.
>
> At each iteration, this could ping pong with migration sources becoming
> migration targets and vice-versa. Keep an eye on the overall time spent
> in compaction and consider forcing MIGRATE_SYNC as a possible
> alternative.
>
>> Test: hogger-frag-unmovable
>>                                       base nonmovable   redesign  threshold
>> compact_free_scanned               2800710    5615427    6441095    2235764
>> compact_isolated                     58323     114183    2711081     647701
>> compact_migrate_scanned            1078970    2437597    4175464    1697292
>> compact_stall                          341       1066       2059       2092
>> compact_success                         80        123        207        210
>> pgmigrate_success                    27034      53832    1348113     318395
>> Success:                                22         29         44         40
>> Success(N):                             46         61         90         83
>>
>>
>> Test: hogger-frag-movable
>>                                       base nonmovable   redesign  threshold
>> compact_free_scanned               5240676    5883401    8103231    1860428
>> compact_isolated                     75048      83201    3108978     427602
>> compact_migrate_scanned            2468387    2755690    4316163    1474287
>> compact_stall                          710        664       2117       1964
>> compact_success                         98        102        234        183
>> pgmigrate_success                    34869      38663    1547318     208629
>> Success:                                25         26         45         44
>> Success(N):                             53         56         94         92
>>
>>
>> Test: build-frag-unmovable
>>                                       base nonmovable   redesign  threshold
>> compact_free_scanned               5032378    4110920    2538420    1891170
>> compact_isolated                     53368     330762    1020908     534680
>> compact_migrate_scanned            1456516    6164677    4809150    2667823
>> compact_stall                          538        746       2609       2500
>> compact_success                         93        350        438        403
>> pgmigrate_success                    19926     152754     491609     251977
>> Success:                                15         31         39         40
>> Success(N):                             33         65         80         81
>>
>>
>> Test: build-frag-movable
>>                                       base nonmovable   redesign  threshold
>> compact_free_scanned               3059086    3852269    2359553    1461131
>> compact_isolated                    129085     238856     907515     387373
>> compact_migrate_scanned            5029856    5051868    3785605    2177090
>> compact_stall                          388        540       2195       2157
>> compact_success                         99        218        247        225
>> pgmigrate_success                    52898     110021     439739     182366
>> Success:                                38         37         43         43
>> Success(N):                             82         77         89         90
>>
>
> The success rates look impressive. If you could, also report the total
> time and system CPU time for the test. Ideally also report just the time
> spent in compaction. Tony Jones posted a patch for perf that might
> help with this
> https://lkml.org/lkml/2015/5/26/18

Looks good. Maybe, compaction related stat already shows some aspect but
I will check it.

> Ideally also monitor the trace_mm_page_alloc_extfrag tracepoint and see
> how many externally fragmenting events are occuring, particularly ones
> for MIGRATE_UNMOVABLE requests.

Okay. Will do.

Thanks for detailed review.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
